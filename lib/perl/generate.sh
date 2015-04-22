#!/bin/bash -u

mod=mod-bundle

# === command
if [[ $# -lt 1 ]] ; then
 echo "Usage: $0 [ precision & colour -> (.*/)?qla_(df?[23n]?|f[23n]?|int)/[^/]+ ] [ mode -> c_source|perl_data|show_generated_only ]+"
 exit
fi

for i in file ; do
 [[ $# -eq 0 ]] && break ;
 eval $i=$1 ; shift ;
done

show_generated_only=false

mode_l=""
for i in $* ; do
 [[ $i == show_generated_only ]] && { eval "$i=true;" ; continue ; }
 mode_l="$mode_l $i"
done

eval "$(echo $file | perl -e '$_=<>; chop $_; $_ =~ s/.c$// ; @a=split "/", $_ ; printf "output=%s ; qla=%s ; tag=%s ;", (join("/",@a[0..$#a-2])),@a[-2,-1];')"

#///

mkdir -p $output/$qla
mkdir -p $output/debug

for mode in $mode_l ; do

printf "\n\nMODE = $mode\n\n"

# === alias to and wrappers for perl scripts

template=$(dirname $0)

for i in virtualNc ; do
 eval $i=\"$template/generate_$i.pl $mode\"
done

function virtualNc { local in out this ; in=$1 ; out=$2; this="virtualNc" ;
 if $show_generated_only ; then printf "%s %8s %s\n" GENERATED $this $out ; else
  printf "# %-16s -> %8s -> %-12s ...\n" $(basename $in) $this $(basename $out) ; $virtualNc $in $out ;
 fi
}

#///

if [[ $mode == c_source  ]] ; then # ===
 if [[ ! -f $output/$qla/$tag.c ]] ; then
#  printf "Generating source file %8s %-12s ... " "" $qla
   start=$(date +%s)
    perl/build_qla.pl $tag $output/$qla/$qla.h $output/$qla >& $output/debug/$tag
   end=$(date +%s)
#  printf "  [DONE] %2ds\n" $((end-start))
  printf "Generating source file %8s %-12s ...   [DONE] %2ds\n" "" $qla $((end-start))

 else
  printf "Use existing $output/$qla/$tag.c\n"
 fi
fi
#///
if [[ $mode == perl_data ]] ; then # ===
# if [[ ! -f $output/$qla/$tag.c.pm ]] ; then
#  printf "Splitting  source file %8s %-12s ... " "" $qla
   start=$(date +%s)
    $mod/util/split.pl      $output/$qla/$tag.c              >  $output/$qla/$tag.c.pm
   end=$(date +%s)
#  printf "  [DONE] %2ds\n" $((end-start))
  printf "Splitting  source file %8s %-12s ...   [DONE] %2ds\n" "" $qla $((end-start))
# else
#  printf "Use existing $output/$qla/$tag.c.pm\n"
# fi
fi
#///
if [[ $mode == virtualNc ]] ; then # === <- make_virtualNc                      (qla commit eaffb9220793ec5048150d6abba940a96be3c006)

pc=${qla/qla_}

[[ $pc =~ ^[dfq]n$ ]] && tag_=( "" "_color" "_precision" ) ;
[[ $pc =~ ^d[fq]n$ ]] && tag_=(    "_color"              ) ;

# not sure where to put the virtual Nc = 1, leave it where Nc = n is.
pc_=${pc%n}1 ; output_=$output ;

# n = 1
virtualNc $output/qla_${pc}.h $output_/qla_${pc_}.h

if $show_generated_only ; then
 for(( i = 0 ; i < ${#tag_[*]} ; i++ )) ; do
   echo GENERATED virtualNc $output_/qla_${pc_}${tag_[$i]}_generic.h
 done
else
 for(( i = 0 ; i < ${#tag_[*]} ; i++ )) ; do
  cat $output/qla_${pc}${tag_[$i]}_generic.h			\
   | sed -e 's/QLA_Nc,\?//;s/\(QLA_[DFQ]*\)N/\11/g;'	\
   > $output_/qla_${pc_}${tag_[$i]}_generic.h
 done
fi

fi
#///

done

