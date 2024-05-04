#!/bin/bash

subj=$1


dwis=${FBA_DIR}/${subj}/dwis.mif
mask=${FBA_DIR}/${subj}/mask.mif
fa=${FBA_DIR}/${subj}/fa.mif
v1=${FBA_DIR}/${subj}/v1.mif

tmpDir=$(mktemp -d)

#dwi2tensor -mask $mask $dwis - | tensor2metric -fa $fa -vector $v1 -
dwi2tensor -mask $mask $dwis - | tensor2metric -fa ${tmpDir}/fa.mif -vector ${tmpDir}/v1.mif -

cp  ${tmpDir}/fa.mif $fa
cp  ${tmpDir}/v1.mif $v1

rm -fR $tmpDir
