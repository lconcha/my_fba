#!/bin/bash
source `which my_do_cmd`



###
N4opt="-s 2 -v"
####

help() {
echo "
  `basename` <dwiIN.mif> <mask.mif|nomask> <dwiOUT.mif> [-N4opt Options]

  Perform bias field correction (removes intensity inhomogeneities)
  from a DWI data set in mif format (includes gradient information).

  Uses N4 for bias field estimation.

  Needs mrtrix version 3 or superior.

  It is almost identical to mrtrix dwibiascorrect, but the options passed
  to N4BiasFieldCorrection make it run faster and produces smoother biasfield maps.


-N4opt:  These are any options you would normally pass to N4BiasFieldCorrection,
         Type  N4BiasFieldCorrection to see what they are.
         Default is $N4opt.
         Pass the arguments to -N4opt between double quotes.

If you specify \"nomask\" in place of mask.mif then the entire volume is used.


LU15 (0N(H4
INB, UNAM
August 2016
lconcha@unam.mx

"
}

if [ "$#" -lt 3 ]; then
  echo "[ERROR] - Not enough arguments"
  help
  exit 2
fi



dwiIN=$1
mask=$2
dwiOUT=$3



declare -i i
i=1
for arg in "$@"
do
  case "$arg" in
  -h|-help)
    print_help
    exit 1
  ;;
  -n4opt)
    fnextarg=`expr $i + 1`
    eval n4opt=\${${nextarg}}
  ;;
  esac
  i=$[$i+1]
done










tmpDir=/tmp/mybiascorrect_$$
mkdir $tmpDir

dwiextract -bzero $dwiIN - | mrmath -axis 3 - mean ${tmpDir}/b0.nii

if [[ "$mask" == "nomask" ]]
then
 echolor orange "Generating a full-volume mask"
 mrcalc ${tmpDir}/b0.nii 0 -mul 1 -add ${tmpDir}/mask.nii
else
  my_do_cmd mrconvert $mask ${tmpDir}/mask.nii
fi

corrb0=${tmpDir}/b0_corr.nii
biasfield=${tmpDir}/biasfield.nii
my_do_cmd N4BiasFieldCorrection \
  -v \
  -d 3 \
  -i ${tmpDir}/b0.nii \
  -w ${tmpDir}/mask.nii \
  -o [$corrb0,$biasfield] \
  $n4opt

my_do_cmd mrcalc $dwiIN $biasfield -div $dwiOUT
my_do_cmd mrconvert $biasfield ${dwiOUT%.mif}_biasfield.mif

rm -fR $tmpDir
