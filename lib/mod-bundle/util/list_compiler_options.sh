#!/bin/bash -u

 tar=tar ; [[ -z ${GTAR:-} ]] || tar=$GTAR
 sed=sed ; [[ -z ${GSED:-} ]] || sed=$GSED

grep -e '(BUILD_SCRIPT)' `find . -type f |grep Makefile.am` |awk '{print $1;}'|$sed -e 's/\(\.am\|\.in\)://;s/\.\///;' |sort|uniq -c|\
while read l ; do
 m=($l) ; file=${m[1]}.am
 m=(${file//\// })
 dir=${m[0]}
 #cflags="$(grep AM_CFLAGS $file | sed -e 's/^.*include *//')"
 #cflags="$(grep AM_CFLAGS $file | sed -e 's/^.*include *//;s/-D//g;s/\\/\\&/g;')"
 #cflags="$(grep AM_CFLAGS $file | sed -e 's/^.*include *//;s/-D//g;')"
 cflags="$(grep AM_CFLAGS $file | $sed -e 's/^.*include *//;s/-D//g;s/\\/@&/g;')"
 for i in RESTRICT Precision Colors  ; do
  eval "unset QLA_$i ;"
 done
 p=""
 for i in $cflags ; do
  m=(${i//=/ })
  p="$p ${m[0]}"
  eval "$i"
 done
 for i in $p ; do
  eval "i_=\$$i" ; i_=${i_//@/\\}
  #printf "%16s %16s\n" $i $i_
 done
 m=( $(grep -e '(BUILD_SCRIPT)' $file | awk '{print $3,$4;}') )
 include=$(basename ${m[1]})
 tag=${m[0]}
 #printf "$dir $include ${cflags//@/\\}\n"
 printf "%12s %12s %12s " $dir $include $tag
 for i in RESTRICT Precision Colors  ; do
  i=QLA_$i
  #eval "i_=\$$i" ; i_=${i_//@/\\}
  eval "i_=\${$i:-UNDEF}" ; i_=${i_//@/\\}
  if [[ $i_ == "UNDEF" ]] ; then
   #printf " %16s %-16s" "" ""
   printf " %15s %-6s" "" ""
  else
   #printf " %16s=%-16s" -D$i $i_
   printf " %15s=%-6s" -D$i $i_
  fi
 done
 printf "\n"
done
