#!/usr/bin/env perl

use strict ;
use File::Slurp ;
use File::Path qw(make_path) ;

my $mod = "mod-bundle" ;

my ($specialized) = @ARGV ;

my %t ;

map {
 my @d = split "/",$_ ;
 my $tag = $d[-2] ;
 my $base = "$mod/src/$tag/bundle/specialized" ;

 push @{$t{$base}->{c_source}}, $_ ;
}
 grep { ! m|^#| }
 split "\n", read_file($specialized) ;

map {
 my $base = $_ ;
 make_path $base ;
 printf "Copy ... -> %s\n", $base ;
 map {
  printf " ... %s\n", $_ ;
  `cp -p $_ $base/` ;
 } @{$t{$_}->{c_source}} ;
}
 keys %t ;

