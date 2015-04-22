#!/usr/bin/env perl

use strict ;
use File::Path qw(mkpath) ;
use File::Copy ;
use File::Copy::Recursive qw/dircopy/ ;
use Data::Dump qw(dump) ;
use List::Util qw/min max/ ;
use File::Slurp ;

my $mod = "mod-bundle" ;

my ($info_merged,$optimized_version,$specialized_version) = @ARGV ;

# === index the full list of functions
my %t = do $info_merged ;

my %t_i ;

map {
 my $qla = $_ ;
 #map { push @{$t_i{$_->[0]}}, $qla ; } @{$t{$qla}->{function}} ;
 map { push @{$t_i{$_}}, $qla ; } keys %{$t{$qla}->{function}} ;
} sort keys %t ; 
#///

printf "\n\nOptimized version ...\n\n" ;
# === index the functions that have optimized versions

my %optimized ;

map
{
 my @d = split ' ',$_ ;
 $optimized{$d[0]} = [@d] ;
 printf "$_\n" ;
}
 grep { ! m|^#| }
 split "\n", read_file($optimized_version) ;

my %optimized_ ;

map {
 my $function = $_ ;
 my $qla = $t_i{$function}->[0] ;
 push @{$optimized_{$qla}}, $function ;
} keys %optimized ;

#
#{
# open my $o, ">", "$optimized_version.exclude.pm" ;
#  print $o dump(%optimized_) ;
# close $o ;
#}
#

#///
# === output these functions as individual files

printf "\n# Excluding the following functions from bundling (you'll find them in $mod/src/optimized/qla_.../)\n\n" ;

map {
 my $qla = $_ ;
 my $alt_name = $t{$qla}->{"alternative name"} ;
 my $src = "$mod/src/$alt_name/$qla.c.pm" ;

 my $from = "$mod/src/$alt_name" ;
 my $to   = "$mod/src/replace_with_optimized/$alt_name" ;

 mkpath $to ;

 my %s = do $src ;

 my %o ;

 map {
  my $function = $_ ;
  my $timing = $t{$qla}->{function}->{$function}->{timing}->[3] ;
  my $optimization = $optimized{$function}->[1] ;
  printf "%-48s %8s %8s [%8.3f] %-64s %s\n", $function, $qla, $optimization, $timing, $src, "$to/$function" ;
   open my $o,">","$to/$function" ;
   map { printf $o "$_\n" ; } @{$s{include}} ;
   map { printf $o "$_\n" ; } @{$s{function}->{$function}->{definition}} ;
   close $o ;
  push @{$o{$optimization}}, $function ;
 } @{$optimized_{$qla}} ;

 printf "\n" ;
 my @h = glob( "$from/*.h" ) ;
 if( @h > 0 ) {
 printf " Copy ... to $to/\n" ;
 map { printf "  ... $_\n" ; copy($_,$to) ; } @h ;
 printf "\n\n" ;
 }

{
 my @d = keys %o ;
 if( @d > 0 )
 {
  printf "Copying optimized version ...\n" ;
  map {
   my $optimization = $_ ;
 
    my   $to_optimized="$from/optimized/$optimization" ;
    my $from_optimized="optimized/$optimization" ;

    mkpath $to_optimized ;

    printf " %-64s -> %-64s ...\n",$from_optimized,$to_optimized ;
     #dircopy("$from_optimized/src"    ,$to_optimized) ;
     #dircopy("$from_optimized/include","$to_optimized/include") ;
     `cp -pr $from_optimized/include $to_optimized/` ;
     #mkpath $to_optimized ;
     map {
      printf "  ... $_\n" ; copy("$from_optimized/src/$_",$to_optimized) ;
     } @{$o{$optimization}} ;
    #printf " [DONE]\n" ;

  } keys %o ;
  printf "\n" ;
 }
}

} sort keys %optimized_ ;
#///
# === exclude the said functions from the list
map { my $qla = $_ ;
 map { my $function = $_ ;
  delete $t{$qla}->{function}->{$function} ;
  printf "Deleting ... %-64s ", "$qla/$function" ;
  if( defined $t{$qla}->{function}->{$function} ) { printf " ... Oops $qla/$function not deleted" ; }
  printf "\n" ;
 } @{$optimized_{$qla}} ;
} keys %optimized_ ;
#///

printf "\n\nSpecialized version ...\n\n" ;
# === index the functions that have specialized versions

my %specialized ;

map
{
 my @d = split '/',$_ ;
 $specialized{$d[-1]} = [@d] ;
 printf "$_\n" ;
}
 grep { ! m|^#| }
 split "\n", read_file($specialized_version) ;

my %specialized_ ;

map {
 my $function = $_ ;
 my $qla = $t_i{$function}->[0] ;
 push @{$specialized_{$qla}}, $function ;
} keys %specialized ;

#
#{
# open my $o, ">", "$specialized_version.exclude.pm" ;
#  print $o dump(%specialized_) ;
# close $o ;
#}
#

#///
# === output these functions as individual files

printf "\n# Excluding the following functions from bundling (you'll find them in $mod/src/specialized/qla_.../)\n\n" ;

map {
 my $qla = $_ ;
 my $alt_name = $t{$qla}->{"alternative name"} ;
 my $src = "$mod/src/$alt_name/$qla.c.pm" ;

 my $from = "$mod/src/$alt_name" ;
 my $to   = "$mod/src/replace_with_specialized/$alt_name" ;

 mkpath $to ;

 my %s = do $src ;

 my %o ;

 map {
  my $function = $_ ;
  my $timing = $t{$qla}->{function}->{$function}->{timing}->[3] ;
#  my $optimization = $specialized{$function}->[1] ;
  printf "%-48s %8s %8s [%8.3f] %-64s %s\n", $function, $qla, "", $timing, $src, "$to/$function" ;
   open my $o,">","$to/$function" ;
   map { printf $o "$_\n" ; } @{$s{include}} ;
   map { printf $o "$_\n" ; } @{$s{function}->{$function}->{definition}} ;
   close $o ;
  #push @{$o{$optimization}}, $function ;
 } @{$specialized_{$qla}} ;

 printf "\n" ;
 my @h = glob( "$from/*.h" ) ;
 if( @h > 0 ) {
 printf " Copy ... to $to/\n" ;
 map { printf "  ... $_\n" ; copy($_,$to) ; } @h ;
 printf "\n\n" ;
 }

} sort keys %specialized_ ;
#///
# === exclude the said functions from the list
map { my $qla = $_ ;
 map { my $function = $_ ;
  delete $t{$qla}->{function}->{$function} ;
  printf "Deleting ... %-64s ", "$qla/$function" ;
  if( defined $t{$qla}->{function}->{$function} ) { printf " ... Oops $qla/$function not deleted" ; }
  printf "\n" ;
 } @{$specialized_{$qla}} ;
} keys %specialized_ ;
#///

# === bundle the functions into files

printf "\n# Bundling files (you'll find them in $mod/src/qla_.../bundle/)\n\n" ;

map {
 my $qla = $_ ;
 my $alt_name = $t{$qla}->{"alternative name"} ;
 my $src = "$mod/src/$alt_name/$qla.c.pm" ;
 my $to = "$mod/src/$alt_name/bundle" ;

 mkpath $to ;

 # load function definitions

 my %s = do $src ;

 # classify according to whether the function is vectorizable

 my @s ; map { @{$s[$_]} = () } 0..1 ;

 map {
  push @{$s[ 0 < ($t{$qla}->{function}->{$_}->{vectorized_loop}) ]}, $_ ;
 } keys %{$t{$qla}->{function}} ;

 # distribute the functions in N parts, N = 16 is enough

 my $N = 1 ;

  $N = 16 if $qla =~ /QLA_[DF][23N]/ ;

  min $N,grep { $_ > 0 } map{0+@{$_}}@s ;

 my @s_ ;

  map { my $s = $_ ; map { @{$s_[$_][$s]} = () } 0..$N-1 ; } 0..$#s ;
  map { my ($s,$i) = ($_,0) ; map { push @{$s_[$i%$N][$s]}, $_ ; $i++ ; } @{$s[$s]} ; } 0..$#s ;

 printf "%8s %-48s %d [non-vec = %4d, vec = %4d, parts = %4d] ->  ", $qla, $src, 0+@s, (map{0+@{$_}} @s), $N ;

 map {
  my $i = $_ ;
  open my $o,">", "$to/$qla.c.$i.c" ;
  map { printf $o "$_\n" ; } @{$s{include}} ;
  map { my $vectorizable = $_ ;
   printf $o "// === %s functions [%d]\n", ( $vectorizable == 1 ) ? "Vectorizable" : "Non-vectorizable", 0+@{$s_[$i][$vectorizable]} ;
   map {
    my $function = $_ ;
    if( $vectorizable == 1 )
    {
     my $vectorized_loop = $t{$qla}->{function}->{$function}->{vectorized_loop} ;
     printf $o "// vectorized $vectorized_loop loop(s)\n" ;
     printf $o "__attribute__((optimize(\"tree-vectorize\",\"tree-vectorizer-verbose=1\")))\n" ;
    }
    map { printf $o "%s\n",$_ ; } @{$s{function}->{$function}->{definition}} ;
   } @{$s_[$i][$vectorizable]} ;
   printf $o "///\n" ;
  } (1,0) ;
  close $o ;
  printf "[%d]", $i ;
 } 0..$#s_ ;
 printf "\n" ;

} sort keys %t ;
#///

