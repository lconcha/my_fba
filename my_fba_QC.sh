#!/bin/bash
source `which my_do_cmd`


help() {
echo "
  `basename $0` <prefix> <filetocheck> <nslices>

"
}


if [ "$#" -lt 3 ]
then
  echo "  [ERROR]. Insufficient arguments."
  help
  exit 2
fi



for arg in "$@"
do
  case "$arg" in
  -h|-help)
    help
    exit 1
  ;;
esac
done



prefix=$1
filetocheck=$2
nslices=$3


tmpDir=/tmp/mrtrix_QC_$$
mkdir $tmpDir

for d in `ls -d ${FBA_DIR}/${prefix}*`
do
  subj=`basename $d`
  F=${FBA_DIR}/${subj}/$filetocheck

  if [ -f ${FBA_DIR}/$subj/exclude ]
    then
      echo "  [INFO] Excluding subject $subj"
      continue
    else
    if [ ! -f $F ]
    then
      echo "  [ERROR] File not found for subject $subj : $F"
      problems="$problems $subj"
    else
        ndims=`mrinfo -ndim $F`
        if [ $ndims -gt 3 ]
        then
	  dim="-coord 3 0 -coord 2 0:$nslices"
        else
          dim="-coord 2 0:$nslices"
        fi
      echo "  [INFO] File found for subject $subj  : $F"
      mrinfo -size $F >> ${tmpDir}/sizes.txt
      my_do_cmd mrconvert -quiet $dim $F ${tmpDir}/${subj}.mif
    fi
  fi
done


cat ${tmpDir}/sizes.txt
ls ${tmpDir}/sizes.txt

my_do_cmd mrcat -quiet -force ${tmpDir}/*.mif QC_${filetocheck}


rm -fR $tmpDir
