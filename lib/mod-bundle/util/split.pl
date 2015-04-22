#!/usr/bin/env perl

use strict ;
use Data::Dump qw/dump/ ;

my $file = $ARGV[0] ;

#$file = "$file/$file.c" ;

my %t ;
my $func_name ;
my $i = 0 ;
my @include ;

# === in function definition (preserve order)
{
 open my $o,"<",$file ;
 while(<$o>)
 {
  chop $_ ;
  if( $_ =~ /FUNC_NAME/ )
  {
   my @d = split ' ',$_ ;
   $func_name = $d[2] ;
   $t{$func_name}->{id} = $i ; $i++ ;
   next ;
  }
  else
  {
   if( $i == 0 ) {
    if( $_ =~ /^#include/ )
    {
      push @include, $_ ;
    }
   next ;
   }
  }
  push @{$t{$func_name}->{definition}}, $_ ;
 }
 close $o ;
}
#///

if( 0 ) {
if( @include )
{
 printf "%32s\n", "--include--" ;
 map { printf "| %s\n", $_ ; } ("",@include,"") ;
}

map {
 my $func_name = $_ ;
 printf "%32s %4d\n", $func_name, $t{$func_name}->{id} ;
 map { printf "| %s\n", $_ ; } @{$t{$func_name}->{definition}} ;
} sort {$t{$a}->{id}<=>$t{$b}->{id}} keys %t ;
}

my %file ;

$file{include} = \@include ;

$file{function} = \%t ;

map {
 my $function = $_ ;
 my %control ;
 my $signature ;
 map {
  $signature = $_     if $_ =~ /\bvoid\b  *QLA_[\w_]*  *\(/ ;
  $control{for}    ++ if $_ =~ /\bfor\b/ ;
  $control{switch} ++ if $_ =~ /\bswitch\b/ ;
  $control{case}   ++ if $_ =~ /\bcase\b/ ;
 } @{$file{function}->{$function}->{definition}} ;
 my @control = keys %control ;
 if( @control > 0 )
 {
  $file{function}->{$function}->{control} = \%control ;
 }
 if( defined $signature )
 {
  $file{function}->{$function}->{signature} = $signature ;
 }
} keys %{$file{function}} ;


print dump(%file) ;
