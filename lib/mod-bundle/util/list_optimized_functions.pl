#!/usr/bin/env perl

use strict ;

if( not @ARGV )
{
 printf "Usage: %s [intel|ibm|list]\n", $0 ;
 exit ;
}

# === list files in optmized
my @dir= qw/440 440d qpx c sse sse2/ ;

my @file ;
 map {
  my $dir = "optimized/$_/src" ;
  opendir(DIR, $dir) or die $!;
   push @file,
   map { "$dir/$_" }
   grep {
    /\.c$/ &&
    -f "$dir/$_" ;   # and is a file
   } readdir(DIR);
  closedir(DIR) ;
 } @dir ;

#map { printf "%s\n", $_ ; } @file ;
#///
# === classify what is available according to manufacturer
my %avail ;

my $show_files = 0 ;

map
{
 my $sys = $_ ;
 if( $sys eq "intel" ) { map { $avail{$_} = 1 } qw/c sse sse2/ ; }
 if( $sys eq "ibm"   ) { map { $avail{$_} = 1 } qw/c 440 440d qpx/ ; }
 if( $sys eq "list"  ) { $show_files = 1 ; }
} @ARGV ;

#printf "System: @ARGV\n" ;

my %t ;

map {
 my @d = split '/', $_ ;
 my $type = $d[1] ;
 my $file = $d[3] ;

  push @{$t{$file} }, $type ;
} @file ;

my %o ;

{
 my $o = 0 ; map { $o{$_} = $o ; $o++ ; } qw/c 440 440d qpx sse sse2/ ;
}

map {
 my $ok = 0 ;
 map { $ok++ if defined $avail{$_} } @{$t{$_}} ;
 if( $ok > 0 ) {
  printf "%-64s ", $_ ; map { printf " %8s", $_ if defined $avail{$_} } sort { $o{$b}<=>$o{$a} } @{$t{$_}} ; printf "\n" ;
  if( $show_files == 1 )
  {
   my $file=$_ ; map { printf " optimized/%s/src/$file\n", $_ if defined $avail{$_} } sort { $o{$b}<=>$o{$a} } @{$t{$_}} ; printf "\n" ;
  }
 }
} sort keys %t ;
#///

