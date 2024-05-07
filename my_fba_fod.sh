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
dwis_std_upsampled=${FBA_DIR}/${subj}/dwis_std_upsampled.mif
av_wm_response=${FBA_DIR}/average_wm_response.txt
av_gm_response=${FBA_DIR}/average_gm_response.txt
av_csf_response=${FBA_DIR}/average_csf_response.txt



if [ -f $wm_fod -a -f $gm_fod -a -f $csf_fod ]
then
  echo "  [INFO] File exists: $wm_fod"
  echo "  [INFO] File exists: $gm_fod"
  echo "  [INFO] File exists: $csf_fod"
  filesAreOK=1
  for f in $wm_fod $gm_fod $csf_fod
  do
    sz=`du  $f | awk '{print $1}'`
    if [ $sz -eq 0 ]
    then
      echo "  [WARNING] File size is zero for file $f"
      rm -v $f
      filesAreOK=0
    fi
  done
  if [ $filesAreOK -eq 1 ]
  then
    exit 0
  fi
fi


isOK=1
for f in $av_wm_response $av_gm_response $av_csf_response $mask_upsampled $dwis_std_upsampled
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  fi
done
if [ $isOK -eq 0 ]
then
  echo "  [ERROR] Cannot compute FOD. Quitting."
  exit 2
fi


tmpDir=$(mktemp -d)

tmp_wm_fod=${tmpDir}/wm_fod.mif
tmp_gm_fod=${tmpDir}/gm_fod.mif
tmp_csf_fod=${tmpDir}/csf_fod.mif

my_do_cmd dwi2fod msmt_csd \
  -mask $mask_upsampled \
  $dwis_std_upsampled \
  $av_wm_response $tmp_wm_fod \
  $av_gm_response $tmp_gm_fod \
  $av_csf_response $tmp_csf_fod


my_do_cmd cp $tmp_wm_fod  $wm_fod
my_do_cmd cp $tmp_gm_fod  $gm_fod
my_do_cmd cp $tmp_csf_fod $csf_fod

my_do_cmd rm -fR $tmpDir

