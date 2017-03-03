#!/bin/bash

subj=$1


dwis=${FBA_DIR}/${subj}/dwis.mif
mask=${FBA_DIR}/${subj}/mask.mif
fa=${FBA_DIR}/${subj}/fa.mif
v1=${FBA_DIR}/${subj}/v1.mif

dwi2tensor -mask $mask $dwis - | tensor2metric -fa $fa -vector $v1 -