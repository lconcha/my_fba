#!/bin/bash
echo "Running on `hostname`"
source `which my_do_cmd`


if [ "$#" -lt 2 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` subj voxelsize"
  echo ""
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi


subj=$1
voxelsize=$2
dwis_upsampled=${FBA_DIR}/${subj}/dwis_std_upsampled.mif
mask_upsampled=${FBA_DIR}/${subj}/mask_upsampled.mif
dwis_std=${FBA_DIR}/${subj}/dwis_std.mif
mask=${FBA_DIR}/${subj}/mask.mif


# we will be using a tmp directory, so we manually check if outputs already exist

if [ -f $dwis_upsampled -a -f $mask_upsampled ]
then
  echo "  [INFO] Output file exists: $dwis_upsampled"
  echo "  [INFO] Output file exists: $mask_upsampled"
  filesAreOK=1
  for f in $dwis_upsampled $mask_upsampled
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

if [ ! -f $dwis_std ]
then
  echo "  [ERROR] Cannot find file: $dwis_std"
  exit 2
fi

if [ ! -f $mask ]
then
  echo "  [ERROR] Cannot find file: $mask"
  exit 2
fi


tmpDir=/tmp/upsample_$$
mkdir $tmpDir

tmpFile1=${tmpDir}/tmpFile1.mif
tmpFile2=${tmpDir}/tmpFile2.mif

my_do_cmd mrresize $dwis_std -voxel $voxelsize $tmpFile1
cp -v $tmpFile1 $dwis_upsampled

my_do_cmd mrresize -voxel $voxelsize -interp nearest $mask $tmpFile2
cp -v $tmpFile2 $mask_upsampled

rm -fR $tmpDir