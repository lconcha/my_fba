#!/bin/bash
echo "  [INFO] Running on `hostname`"


if [ "$#" -lt 1 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` $subj"
  echo ""
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi



subj=$1

if [ -f  ${FBA_DIR}/${subj}/mask.mif ]
then
  echo "  [INFO] Mask exists:  ${FBA_DIR}/${subj}/mask.mif"
  exit 0
fi


dwi2mask ${FBA_DIR}/${subj}/dwis.mif ${FBA_DIR}/${subj}/mask.mif