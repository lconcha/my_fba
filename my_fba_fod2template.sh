#!/bin/bash
source `which my_do_cmd`
echo "  Running on `hostname`"

subj=$1

if [ "$#" -lt 1 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` subj"
  echo ""
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi



fod=${FBA_DIR}/${subj}/wm_fod.mif
mask=${FBA_DIR}/${subj}/mask_upsampled.mif
fod_template=${FBA_DIR}/template_fod.mif
warp_subj2template=${FBA_DIR}/${subj}/fod_subj2template_warp.mif
warp_template2subj=${FBA_DIR}/${subj}/fod_template2subj_warp.mif
transformed_fod=${FBA_DIR}/${subj}/fod_templateSpace_noReorient.mif
transformed_mask=${FBA_DIR}/${subj}/mask_templateSpace.mif

echo "  [INFO] Starting FOD registration for subject $subj"


# check for files that should already exist
echo "  [INFO] Checking inputs..."
isOK=1
for f in $fod $mask $fod_template
do
  if [ ! -f $f ]
  then
    echo "    [ERROR] File does not exist: $f"
    isOK=0
  else
    echo "    [OK] Found file $f"
  fi
done

if [ $isOK -eq 0 ]
then
  echo "  [ERROR] Cannot register FOD to template."
  exit 2
fi


echo "  [INFO] Registering wm_fod of subject $subj to template. Will only produce warps."
my_do_cmd mrregister $fod \
  $fod_template \
  -mask1 $mask \
  -affine_init_translation mass -affine_init_rotation search -init_rotation.search.scale 0.2 \
  -nl_warp $warp_subj2template $warp_template2subj


echo "  [INFO] Transforming fod to template without fixel reorientation"
my_do_cmd mrtransform $fod \
  -warp $warp_subj2template \
  -noreorientation \
  $transformed_fod



echo "  [INFO] Transform the mask to template space"
my_do_cmd mrtransform \
  -warp $warp_subj2template \
  -interp nearest \
  $mask \
  $transformed_mask

