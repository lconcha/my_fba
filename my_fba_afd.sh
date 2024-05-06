#!/bin/bash
source `which my_do_cmd`

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


# 9. Segment FOD images to estimate fixels and their fibre density (FD)
# Here we segment each FOD lobe to identify the number and orientation of fixels in each voxel. The output also contains the apparent fibre density (AFD) value per fixel estimated as the FOD lobe integral. Note that in the following steps we will use a more generic shortened acronym - Fibre Density (FD) instead of AFD.

# inputs
fod_std=${FBA_DIR}/${subj}/fod_templateSpace_noReorient.mif
analysis_voxel_mask=${FBA_DIR}/template/analysis_voxel_mask.mif

# outputs
sub_fixeldir=${FBA_DIR}/${subj}/fixels_in_template_space_NOT_REORIENTED
fd_noReoriented=fd.mif


fcheck=${sub_fixeldir}/${fd_noReoriented}
if [ -f $fcheck ]
then
  echo "  [INFO] File exists: $fcheck"
  exit 0
fi


for f in $fod_std $analysis_voxel_mask
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    exit 2
  fi
done



my_do_cmd fod2fixel \
  $fod_std \
  -mask $analysis_voxel_mask \
  -afd $fd_noReoriented \
  $sub_fixeldir
