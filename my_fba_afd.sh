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

sub_fixeldir=${FBA_DIR}/${subj}/fixels
fd_noReoriented=fd_templateSpace_noReorient.mif
fod_std=${FBA_DIR}/${subj}/fod_templateSpace_noReorient.mif
analysis_voxel_mask=${FBA_DIR}/template_analysis_voxel_mask.mif

if [ -f $fd_noReoriented ]
then
  echo "  [INFO] File exists: $fd_noReoriented"
  exit 0
fi


if [ ! -f $fod_std ]
then
  echo "  [ERROR] Cannot find file: $fod_std"
  exit 2
fi

if [ ! -f $analysis_voxel_mask ]
then
  echo "  [ERROR] Cannot find file: $analysis_voxel_mask"
  exit 2
fi



my_do_cmd fod2fixel \
  $fod_std \
  -mask $analysis_voxel_mask \
  -afd $fd_noReoriented \
  $sub_fixeldir