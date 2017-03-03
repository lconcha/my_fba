#!/bin/bash
source `which my_do_cmd`

subj=$1




# 12. Compute fibre cross-section (FC) metric
# Apparent fibre density, and other related measures that are influenced by the quantity of restricted water, only permit the investigation of group differences in the number of axons that manifest as a change to within-voxel density. However, depending on the disease type and stage, changes to the number of axons may also manifest as macroscopic differences in brain morphology. This step computes a fixel-based metric related to morphological differences in fibre cross-section, where information is derived entirely from the warps generated during registration (paper under review):


warp_subj2template=${FBA_DIR}/${subj}/fod_subj2template_warp.mif
analysis_fixel_mask=${FBA_DIR}/template_analysis_fixel_mask.msf
subject_fc=${FBA_DIR}/${subj}/fc_templateSpace_corresp2template.msf
subject_fc_log=${FBA_DIR}/${subj}/fc_log_templateSpace_corresp2template.msf
subject_jdet=${FBA_DIR}/${subj}/jacobian_determinant.mif
subject_fd=${FBA_DIR}/${subj}/fd_templateSpace_corresp2template.msf
subject_fdc=${FBA_DIR}/${subj}/fdc_templateSpace_corresp2template.msf

my_do_cmd warp2metric $warp_subj2template -fc $analysis_fixel_mask $subject_fc
my_do_cmd warp2metric $warp_subj2template -jdet $subject_jdet



# The FC files will be used in the next step. However, for group statistical analysis of FC we recommend taking the log (FC) to ensure data are centred about zero and normally distributed:

my_do_cmd fixellog $subject_fc $subject_fc_log



# 13. Compute a combined measure of fibre density and cross-section (FDC)
# To account for changes to both within-voxel fibre density and macroscopic atrophy, fibre density and fibre cross-section must be combined (a measure we call fibre density & cross-section, FDC). This enables a more complete picture of group differences in white matter. Note that as discussed in our future work (under review), group differences in FD or FC alone must be interpreted with care in crossing-fibre regions. However group differences in FDC are more directly interpretable. To generate the combined measure we ‘modulate’ the FD by FC:

my_do_cmd fixelcalc $subject_fd mult $subject_fc $subject_fdc
