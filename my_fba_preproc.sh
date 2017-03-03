#!/bin/bash
source `which my_do_cmd`


echo "  [INFO] Running on `hostname`"


if [ "$#" -lt 1 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` <dwis.mif> <mask.mif> <$subj>"
  echo ""
  echo "  "
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi



IN=$1
mask=$2
OUT=${FBA_DIR}/${subj}/dwis.mif

tmpDir=/tmp/preproc_$$
mkdir -v $tmpDir

my_do_cmd dwidenoise $IN ${tmpDir}/denoised.mif
my_do_cmd dwipreproc AP ${tmpDir}/denoised.mif ${tmpDir}/denoised_ec.mif -rpe_none
my_do_cmd my_dwibiascorrect.sh ${tmpDir}/denoised_ec.mif $mask ${tmpDir}/denoised_ec_biascorr.mif
mv -v ${tmpDir}/denoised_ec_biascorr.mif $OUT



rm -fRv $tmpDir
