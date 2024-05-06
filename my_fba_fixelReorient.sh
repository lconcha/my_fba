#!/bin/bash
source `which my_do_cmd`
echo "Running on `hostname`"

if [ "$#" -lt 1 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` subj"
  echo ""
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi


subj=$1




# Here we reorient the direction of all fixels based on the Jacobian matrix (local affine transformation) at each voxel in the warp:


fixels_std_noReorient=${FBA_DIR}/${subj}/fixels_in_template_space_NOT_REORIENTED
warp_subj2template=${FBA_DIR}/${subj}/fod_subj2template_warp.mif
fixels_std_reorient=${FBA_DIR}/${subj}/fixels_in_template_space_reoriented


isOK=1

if [ ! -d $fixels_std_noReorient ]
then
    echo "  [ERROR] Cannot find fixel directory: $fixels_std_noReorient"
    isOK=0
fi

for f in $warp_subj2template
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  fi
done
if [ $isOK -eq 0 ]
then
  echo "  [ERROR] Cannot perform fixel reorientation. Quitting."
  exit 2
fi


echo "  [INFO] Performing fixel reorientaion"
my_do_cmd fixelreorient \
  $fixels_std_noReorient \
  $warp_subj2template \
  $fixels_std_reorient
