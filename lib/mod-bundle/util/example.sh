#!/bin/bash -u

export MOD_BUNDLE=1

mod=mod-bundle

 tar=tar ; [[ -z ${GTAR:-} ]] || tar=$GTAR
 sed=sed ; [[ -z ${GSED:-} ]] || sed=$GSED

mkdir -p $mod/src/debug

# generate the sources -- including the specialized ones
/usr/bin/time make -f $mod/util/Makefile.qla qla_source -j >& $mod/src/debug/qla_source

mkdir -p $mod/listing

optimized_for=intel # intel | ibm (nevertested for ibm)

# === list the optimized versions of functions
optimized_functions=$mod/listing/optimized
if [[ ! -f $optimized_functions ]] ; then
 printf "%-64s ... " "Generating $optimized_functions"
  $mod/util/list_optimized_functions.pl intel > $optimized_functions
 printf " [DONE]\n" ;
else
 printf "Use existing $optimized_functions\n"
fi
printf "\n"
#///

rm -fr $mod/src/qla*/bundle/optimized
$mod/util/setup-optimized.pl $optimized_functions

# === list the specialized versions of functions
specialized_functions=$mod/listing/specialized
if [[ ! -f $specialized_functions ]] ; then
 printf "%-64s ... " "Generating $specialized_functions"
  find $mod/src/specialized -type f -name '*.c' > $specialized_functions
 printf " [DONE]\n" ;
else
 printf "Use existing $specialized_functions\n"
fi
printf "\n"
#///

rm -fr $mod/src/qla*/bundle/specialized
$mod/util/setup-specialized.pl $specialized_functions

# This should be integrated into build/qla-::version::/makefile
$mod/util/makepp-cpp-opt.pl > $mod/listing/qla-makepp-cpp-opt.pm

# === extract the compiler flags for each set
compiler_options=$mod/listing/compiler_options
if [[ ! -f  $compiler_options ]] ; then
 printf "%-64s ... " "Generating $compiler_options"
  $mod/util/list_compiler_options.sh          > $compiler_options
 printf " [DONE]\n" ;
else
 printf "Use existing $compiler_options\n"
fi
printf "\n" ;
#///

# === not all soucre files are named after the functions they contain
#
# 22628
# 2440 c -> c1
#  132 d -> d1
#  132 h -> h1
#   50 i -> i1
#  132 m -> m1
#  132 p -> p1
# 2606 r -> r1
#  132 v -> v1
#
mangled=$mod/listing/mangled
grep MANGLE $mod/src/debug/* > $mangled
#///

timing_info=$mod/listing/qla.timing.info
merged_info=$mod/listing/info.merged.pm
# === merge timing, vectorization and control structure info
if [[ ! -f  $merged_info ]] ; then
 printf "%-64s ... \n" "Generating $merged_info"
  $mod/util/merge_info.pl $timing_info $compiler_options $mangled $merged_info
else
 printf "Use existing $merged_info\n"
fi
printf "\n" ;
#///

s=$(date +%s)
printf "Setting up alternative compilation source files & directories for QLA ... "
/usr/bin/time make -f $mod/util/Makefile.qla bundle -j >& $mod/src/debug/bundle
e=$(date +%s)
printf " [DONE] <--- %d seconds\n" $((e-s))

