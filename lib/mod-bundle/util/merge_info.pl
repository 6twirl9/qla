#!/usr/bin/env perl

use strict ;
use Data::Dump qw/dump/ ;
use File::Slurp ;

my $mod = "mod-bundle" ;

my %t ;

my ($function_timing_info,$compiler_options,$mangled,$output) = @ARGV ;

my %m ;

map {
 my @d = split " ", $_ ;
 $m{$d[2]} = $d[1] ;
} split "\n", read_file($mangled) ;

# === compiler options
printf "%-64s ... ","Adding compiler options" ;
{
 open my $o, "<", "$compiler_options" ;
 while(<$o>)
 {
  chop $_ ; my ($alter_name,$header,$qla,@d) = split ' ', $_ ;

  $t{$qla}->{"alternative name"} = $alter_name ;
  $t{$qla}->{"compiler options"} = [ @d ] ;
#  printf "Debug $alter_name\n" ;
 }
 close $o ;
}
printf " [DONE]\n" ;
#///
# === listing mapping qla, id and function
printf "%-64s ... ","Adding timing & vectorization info" ;
{
 open my $o, "<", $function_timing_info ;
 while(<$o>)
 {
  next if $_ =~ m|^#| or $_ =~ m|^[ \t]*$| ;
  chop $_ ; my @d = split ' ', $_ ;

  #my $func = $d[-2] ;
  #my $vec_loop = $d[-1] ;
  my $vec_loop = $d[4] ;

  my @t = @d[1..3] ;

  @d = split '/', $d[0] ;

  #my $qla = $d[0] ;
  #my $id    = $d[-1] ;
  my $func = $d[2] ;
  my $qla = ($d[1] eq 'qla_int')?'QLA':uc($d[1]) ;

  $func =~ s|.c$|| ;

  $func = $m{$func} . ".c" ;

  @t = map { $_ =~ s#00*$## ; $_ ; } @t ;
  #push @{$t{$qla}->{function}} , [$func,$id,@t] ;
#  $t{$qla}->{function}->{$func}->{id}     = $id ;
  $t{$qla}->{function}->{$func}->{timing} = [@t] ;
  $t{$qla}->{function}->{$func}->{vectorized_loop} = $vec_loop ;
 }
 close $o ;
}
printf " [DONE]\n" ;
#///
# === read in for/case/switch info
printf "Adding for/case/switch info ...\n" ;
map {
 my $qla = $_ ;
 my $alt_name = $t{$qla}->{"alternative name"} ;
 printf "  %-12s %-12s ... ",$qla,$alt_name ;
 my %s = do "$mod/src/$alt_name/$qla.c.pm" ;
 map { my $function = $_ ;
  $t{$qla}->{function}->{$function}->{control} = $s{function}->{$function}->{control} ;
 } keys %{$s{function}} ;
 printf " [DONE]\n" ;
} sort keys %t ;
printf "\n" ;
#///

{
 open my $o, ">", "$output" ;
  print $o dump(%t) ;
 close $o ;
}

exit ;

# === Debug
my $qla_i = 0 ;
map {
 my $qla = $_ ;
 my $alt_name = $t{$qla}->{"alternative name"} ;
 map { my $function = $_ ;
  my @d ;
  if( defined $t{$qla}->{function}->{$function}->{control} )
  {
   map {
    if( defined $t{$qla}->{function}->{$function}->{control}->{$_} )
    {
     push @d, $t{$qla}->{function}->{$function}->{control}->{$_} ;
    }
    else
    {
     push @d, 0 ;
    }
   } qw/for switch case/ ;
  }
  else { @d = (0,0,0) ; }
  printf "%-12s %3d %-48s %8.3f %3d %3d %3d %3d\n", $qla, $qla_i, $function, ${$t{$qla}->{function}->{$function}->{timing}}[-2], @d, $t{$qla}->{function}->{$function}->{vectorized_loop} ;
 } keys %{$t{$qla}->{function}} ;
$qla_i++ ;
} sort keys %t ;
#///
