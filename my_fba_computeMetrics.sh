#!/bin/bash
source `which my_do_cmd`

subj=$1




# 12. Compute fibre cross-section (FC) metric
# Apparent fibre density, and other related measures that are influenced by the quantity of restricted water,
# only permit the investigation of group differences in the number of axons that manifest as a change to within-voxel density. 
# However, depending on the disease type and stage, changes to the number of axons may also manifest as macroscopic differences
# in brain morphology. This step computes a fixel-based metric related to morphological differences in fibre cross-section,
# where information is derived entirely from the warps generated during registration (paper under review):



echo "[INFO] Computing fc"
warp_subj2template=${FBA_DIR}/${subj}/fod_subj2template_warp.mif
fixel_mask=${FBA_DIR}/template/fixel_mask
template_fd=${FBA_DIR}/template/fd
template_fc=${FBA_DIR}/template/fc
template_log_fc=${FBA_DIR}/template/log_fc
template_fdc=${FBA_DIR}/template/fdc
subj_fd=${subj}.mif
subj_fc=${subj}.mif
subj_log_fc=${subj}.mif
subj_fdc=${subj}.mif


fcheck=${template_fc}/${subj_fc}
if [ ! -f $fcheck ]
then
my_do_cmd warp2metric \
  $warp_subj2template \
  -fc \
    $fixel_mask \
    $template_fc \
    $subj_fc
else
  echo "[INFO] File exists, not overwriting: $fcheck"
fi


echo "[INFO] Computing log_fc"
if [ ! -d $template_log_fc ]; then mkdir -v $template_log_fc; fi
if [ ! -f ${template_log_fc}/directions.mif ]
then
	my_do_cmd cp ${template_fc}/index.mif ${template_fc}/directions.mif $template_log_fc/
fi
mrcalc \
  ${template_fc}/$subj_fc \
  -log \
  ${template_log_fc}/${subj_log_fc}



echo "[INFO] Compute combined fd and fc (fdc)"
if [ ! -d $template_fdc ]; then mkdir -v $template_fdc;fi
if [ ! -f ${template_fdc}/directions.mif ]
then
	my_do_cmd cp ${template_fc}/index.mif ${template_fc}/directions.mif $template_fdc/
fi
mrcalc \
  ${template_fd}/${subj_fd} \
  ${template_fc}/${subj_fc} \
  -mult \
 ${template_fdc}/${subj_fdc}
