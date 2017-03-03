#!/bin/bash
echo "  [INFO] Running on `hostname`"
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


mask=${FBA_DIR}/${subj}/mask.mif
dwis=${FBA_DIR}/${subj}/dwis_std.mif
wm_response=${FBA_DIR}/${subj}/wm_response.txt
gm_response=${FBA_DIR}/${subj}/gm_response.txt
csf_response=${FBA_DIR}/${subj}/csf_response.txt



isOK=1
for f in $dwis $mask
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  else
    echo "  [INFO] found file: $f"
  fi
done
if [ $isOK -eq 0 ]
then
  echo "THINGS ARE NOT OK"
  exit 2
fi



if [ -f $wm_response ]
then
  echo "  [INFO]  Response function exists: $wm_response"
  exit 0
fi



my_do_cmd dwi2response dhollander \
   -tempdir ${FBA_DIR}/logs/tmp \
   -mask $mask \
   -voxels ${FBA_DIR}/${subj}/sf_final_mask.mif \
   $dwis \
   $wm_response $gm_response $csf_response



