#!/bin/bash
echo "Running on `hostname`"
source `which my_do_cmd`

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


wm_fod=${FBA_DIR}/${subj}/wm_fod.mif
gm_fod=${FBA_DIR}/${subj}/gm_fod.mif
csf_fod=${FBA_DIR}/${subj}/csf_fod.mif
mask_upsampled=${FBA_DIR}/${subj}/mask_upsampled.mif



isOK=1
for f in $wm_fod $gm_fod $csf_fod $mask_upsampled
do
    if [ -f $f ]
    then
        echo "  [INFO] File exists: $f"
    else
        echo "  [ERROR] Cannot find file: $f"
        isOK=0
    fi
    sz=`du  $f | awk '{print $1}'`
    if [ $sz -eq 0 ]
    then
      echo "  [ERROR] File size is zero for file $f"
      rm -v $f
      isOK=0
    fi
done


if [ $isOK -eq 0 ]
then
  echo "  [ERROR] Cannot compute FOD. Quitting."
  exit 2
fi


wm_fod_norm=${wm_fod%.mif}_normalised.mif
gm_fod_norm=${gm_fod%.mif}_normalised.mif
csf_fod_norm=${csf_fod%.mif}_normalised.mif
f_check_norm=${FBA_DIR}/${subj}/mt_normalisation_factor.mif
f_check_factors=${FBA_DIR}/${subj}/mt_normalisation_tissue_balance_factors.txt

my_do_cmd mtnormalise \
    $wm_fod  $wm_fod_norm \
    $gm_fod  $gm_fod_norm \
    $csf_fod $csf_fod_norm \
    -mask $mask_upsampled \
    -check_norm $f_check_norm \
    -check_factors $f_check_factors
  

