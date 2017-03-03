#!/bin/bash
echo "  [INFO] Running on `hostname`"


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
metric=$2

tmpDir=/tmp/`hostname`_$$
mkdir $tmpDir

dwi=${FBA_DIR}/${subj}/dwis.mif
mask=${FBA_DIR}/${subj}/mask.mif
dwi_std=${FBA_DIR}/${subj}/dwis_std.mif


isOK=1
for f in $dwi $mask
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


if [ -f $dwi_std ]
then
  echo "  [INFO] File exists: $dwi_std"
  exit 0
fi




dwiextract -bzero $dwi - | mrmath -axis 3 - mean ${tmpDir}/avb0.mif
maskfilter -npass 4 $mask erode ${tmpDir}/mask_eroded.mif




if [[ "$metric" = "adc" ]]
then
  dwi2tensor -mask $mask $dwi - | tensor2metric -adc - - | \
	    mrthreshold -abs 0.002 - - | \
	    mrcalc - ${tmpDir}/mask_eroded.mif -mult ${tmpDir}/tissuemask.mif
fi


if [[ "$metric" = "fa" ]]
then
  echo "  [INFO] Using FA to find average b=0 signal in WM"
  dwi2tensor -mask $mask $dwi - | tensor2metric -fa - - | \
           mrthreshold -abs 0.5 - - | \
           mrcalc - ${tmpDir}/mask_eroded.mif -mult ${tmpDir}/tissuemask.mif
fi




nVoxels=`mrstats -mask ${tmpDir}/tissuemask.mif ${tmpDir}/tissuemask.mif -output count`
theMean=`mrstats -mask ${tmpDir}/tissuemask.mif ${tmpDir}/avb0.mif -output mean`
echo "  [INFO] Number of voxels in tissue mask: $nVoxels"
echo "  [INFO] The mean of the average of the b=0 images is $theMean"
mrcalc $dwi $theMean -div $dwi_std

rm -fR $tmpDir

