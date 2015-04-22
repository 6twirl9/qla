#!/usr/bin/env perl

use strict ;
use File::Slurp ;
use File::Path qw(make_path) ;

my $mod = "mod-bundle" ;

my ($optimized) = @ARGV ;

my %t ;

map {
 my @d = split " ",$_ ;
 my $tag = lc ( join "_", @{[split "_",$d[0]]}[0..1] ) ;
 my $base = "$mod/src/$tag/bundle/optimized/$d[1]" ;
 my $c_source = "optimized/$d[1]/src/$d[0]" ;
 my $include  = "optimized/$d[1]/include" ;

# printf "%s\n", $c_source ;
# printf "%s\n", $include if -d $include ;
# printf "\n" ;

 push @{$t{$base}->{c_source}}, $c_source ;
 $t{$base}->{include}->{$include} ++
  if -d $include ;
}
 grep { ! m|^#| }
 split "\n", read_file($optimized) ;

map {
 my $base = $_ ;
 make_path $base ;
 printf "Copy ... -> %s\n", $base ;
 map {
  printf " ... %s\n", $_ ;
  `cp -pr $_ $base/` ;
 } keys %{$t{$_}->{include}} ;
 map {
  printf " ... %s\n", $_ ;
  `cp -p $_ $base/` ;
 } @{$t{$_}->{c_source}} ;
}
 keys %t ;

