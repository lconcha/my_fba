#!/bin/bash
echo "Running on `hostname`"
source `which my_do_cmd`

peak_threshold=$1

if [ "$#" -lt 1 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` peak_threshold"
  echo ""
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi


template_fod=${FBA_DIR}/template/fod.mif
template_mask=${FBA_DIR}/template/template_mask.mif
template_fixel_mask=${FBA_DIR}/template/fixel_mask

if [ -d $template_fixel_mask ]
then
  echo "  [INFO] Analysis fixel mask exists: $template_fixel_mask"
  echo "         Not overwriting. Exit now."
  exit 0
fi



tmpDir=/tmp/template_$$
mkdir $tmpDir


# Here we perform a 2-step threshold to identify template white matter fixels to be included in the analysis. Fixels in the template fixel analysis mask are also used to identify the best fixel correspondence across all subjects (i.e. match fixels across subjects within a voxel).
# Compute a template AFD peaks fixel image:
isOK=1
for f in $template_fod $template_mask
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  fi
done
if [ $isOK -eq 0 ]
then
  echo "  [ERROR] Cannot create a fixel image from the template fod."
  exit 2
fi


template_fixels=${FBA_DIR}/template/fixels
my_do_cmd fod2fixel\
  -mask $template_mask \
  $template_fod \
  $template_fixels



# Generate an analysis voxel mask from the fixel mask. 
# The median filter in this step should remove spurious voxels outside the brain,
#  and fill in the holes in deep white matter where you have small peaks due to 3-fibre crossings:
echo "[INFO] Cleaning the fixel mask a bit..."
analysis_voxel_mask=${FBA_DIR}/template/analysis_voxel_mask.mif
my_do_cmd fixel2voxel ${template_fixels}/directions.mif count ${tmpDir}/fixelcounts.mif 
my_do_cmd mrthreshold ${tmpDir}/fixelcounts.mif ${tmpDir}/fixelcounts_abs.mif -abs 0.5
my_do_cmd mrfilter ${tmpDir}/fixelcounts_abs.mif median $analysis_voxel_mask

# Generate a fixel mask
my_do_cmd fod2fixel \
  -mask $analysis_voxel_mask  \
  -fmls_peak_value $peak_threshold \
  $template_fod \
  $template_fixel_mask


rm -fRv $tmpDir
