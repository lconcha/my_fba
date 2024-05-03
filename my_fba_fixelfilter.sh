#!/bin/bash
source `which my_do_cmd`
echo working on `hostname`


fwhm=$1


if [ "$#" -lt 1 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` <fhwm>"
  echo ""
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi


matrix=${FBA_DIR}/template/matrix


isOK=1
if [ ! -d $matrix ]
then
  echo "[ERROR] Cannot find matrix: $matrix"
  isOK=0
fi

for metric in fd fdc log_fc
do
  d=${FBA_DIR}/template/${metric}
  if [ ! -d $d ]
  then
    echo "[ERROR] Cannot find directory: $d"
    isOK=0
  fi
done

if [ $isOK -eq 0 ]
then
  exit 2
fi



for metric in fd fdc log_fc
do
my_do_cmd fixelfilter \
  -fwhm $fwhm \
  ${FBA_DIR}/template/${metric} \
  smooth \
  ${FBA_DIR}/template/${metric}_smooth \
  -matrix $matrix
done
