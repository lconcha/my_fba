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


template_fod=${FBA_DIR}/template_fod.mif
template_mask=${FBA_DIR}/template_mask_intersection.mif
analysis_fixel_mask=${FBA_DIR}/template_analysis_fixel_mask.msf

if [ -f $analysis_fixel_mask ]
then
  echo "  [INFO] Analysis fixel mask exists: $analysis_fixel_mask"
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
template_peaks=${FBA_DIR}/template_peaks.msf
my_do_cmd fod2fixel\
  $template_fod \
  -mask $template_mask \
  -peak $template_peaks




# Next view the peaks file using the vector plot tool in mrview and identify an appropriate threshold that removes peaks from grey matter, yet does not introduce any ‘holes’ in your white matter (approximately 0.33) (lconcha likes 0.25).
analysis_fixel_mask_tmp=${tmpDir}/template_analysis_fixel_mask.msf
my_do_cmd fixelthreshold -crop $template_peaks $peak_threshold $analysis_fixel_mask_tmp



# Generate an analysis voxel mask from the fixel mask. The median filter in this step should remove spurious voxels outside the brain, and fill in the holes in deep white matter where you have small peaks due to 3-fibre crossings:
analysis_voxel_mask=${FBA_DIR}/template_analysis_voxel_mask.mif
fixel2voxel $analysis_fixel_mask_tmp count - | mrthreshold - - -abs 0.5 | mrfilter - median $analysis_voxel_mask

# Recompute the fixel mask using the analysis voxel mask. Using the mask allows us to use a lower AFD threshold than possible in the steps above, to ensure we have included fixels with low AFD inside white matter:
my_do_cmd fod2fixel \
  -mask $analysis_voxel_mask \
  $template_fod \
  -peak ${tmpDir}/template_temp_step.msf

# we finalize the fixel mask
my_do_cmd fixelthreshold \
  ${tmpDir}/template_temp_step.msf \
  -crop 0.2 \
  $analysis_fixel_mask
  
 
# We recommend having no more than 500,000 fixels in the analysis_fixel_mask (you can check this with fixelstats), otherwise downstream statistical analysis (using fixelcfestats) will run out of RAM). A mask with 500,000 fixels will require a PC with 128GB of RAM for the statistical analysis step.
nfixels=`fixelstats $analysis_fixel_mask -output count`
echo "  [INFO] Number of fixels in fixel mask: $nfixels"


rm -fRv $tmpDir