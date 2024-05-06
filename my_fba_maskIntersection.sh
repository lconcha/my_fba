#!/bin/bash
source `which my_do_cmd`
echo "  Running on `hostname`"


# Different subjects will have subtly different brain coverage. 
# To ensure subsequent analysis is performed in voxels that contain data from all subjects, 
# we warp all subject masks into template space and compute the mask intersection. 

mask_intersection=${FBA_DIR}/template/template_mask.mif
mask_prevalence=${FBA_DIR}/template/template_mask_prevalence.mif

listOfMasks=""
for f in ${FBA_DIR}/*/mask_templateSpace.mif
do
  tmpvar=`dirname $f`
  subj=`basename $tmpvar`
  if [ ! -f $f ]
  then
    echo "  [WARNING] Did not find mask: $f"
  else
    echo "  [INFO] Found mask for subject $subj"
    listOfMasks="$listOfMasks $f"
  fi
done

my_do_cmd mrmath $listOfMasks min $mask_intersection
my_do_cmd mrmath $listOfMasks sum $mask_prevalence