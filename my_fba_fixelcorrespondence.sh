#!/bin/bash
echo "Running on `hostname`"
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



# 11. Assign subject fixels to template fixels
# In step 8 we obtained spatial correspondence between subject and template. In step 10 we corrected the fixel orientations to ensure angular correspondence of the segmented peaks of subject and template. Here, for each fixel in the template fixel analysis mask, we identify the corresponding fixel in each voxel of the subject image and assign the FD value of the subject fixel to the corresponding fixel in template space. If no fixel exists in the subject that corresponds to the template fixel then it is assigned a value of zero. See this paper for more information:



fd_std_reorient=${FBA_DIR}/${subj}/fd_templateSpace_reorient.msf
analysis_fixel_mask=${FBA_DIR}/template_analysis_fixel_mask.msf
fd_std_corr2template=${FBA_DIR}/${subj}/fd_templateSpace_corresp2template.msf


isOK=1
for f in $fd_std_reorient $analysis_fixel_mask
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  fi
done
if [ $isOK -eq 0 ]
then
  echo "  [ERROR] Cannot perform fixel correspondence for subject $subj. Quitting."
  exit 2
fi


my_do_cmd fixelcorrespondence $fd_std_reorient \
  $analysis_fixel_mask \
  $fd_std_corr2template