#!/bin/bash

fixel_mask=${FBA_DIR}/template/fixel_mask
tracto_sifted=${FBA_DIR}/template/fullTracto_sifted.tck
matrix=${FBA_DIR}/template/matrix

if [ -d $matrix ]
then
  echo "[INFO] Output exists, not overwriting: $matrix"
  exit 0
fi



fixelconnectivity \
  $fixel_mask \
  $tracto_sifted \
  $matrix
