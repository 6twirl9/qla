#!/usr/bin/env perl

use strict ;
use Data::Dump qw/dump/;

my $mod = "mod-bundle" ;

my @d = map { chomp ; $_ ; } (`$mod/util/list_compiler_options.sh`) ;

# $CPPFLAGS{$MODULE_this}->{qla_d2}    = "-DQLA_RESTRICT=restrict -DQLA_Precision='D' -DQLA_Colors=2  " ;

map {
 my @d = split " ", $_, 4 ;
 my %t ; map { $_=~ s|^-D|| ; my @d = split "=", $_ ; $t{$d[0]} = $d[1] ; } split " ", ( $d[-1] =~ s,\\,,gr ) ;
 my $tag =
 join " ",
 map {
  my $tag = "QLA_" . $_ ;
  if( not defined $t{$tag} )
  {
   " " x ( 2 + length($tag) + 1 + 3 ) ;
  }
  else
  {
   sprintf "-D%s=%-3s", $tag, $t{$tag} ;
  }
 } qw/RESTRICT Precision Colors/ ;
 printf "%-48s = \"%s\" ;\n", sprintf("\$CPPFLAGS{\$MODULE_this}->{%s}",lc $d[2]), $tag ;

 printf "%-48s = %s ;\n"
  , sprintf("\$CPPFLAGS{\$MODULE_this}->{%s}","qla_int")
  , sprintf("\$CPPFLAGS{\$MODULE_this}->{%s}","qla")
 if lc($d[2]) eq 'qla' ;
 ;
} @d ;

