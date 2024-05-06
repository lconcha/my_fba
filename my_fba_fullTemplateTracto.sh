#!/bin/bash
echo "Running on `hostname`"



# 14. Perform whole-brain fibre tractography on the FOD template
# Statistical analysis using connectivity-based fixel enhancement exploits connectivity information derived from probabilistic fibre tractography. To generate a whole-brain tractogram from the FOD template:

# default nTracks is 20 million!
# default after SIFT is 2 million.

nTracksOrig=$1
nTracksSift=$2
template_fod=${FBA_DIR}/template/fod.mif
template_mask=${FBA_DIR}/template/template_mask.mif
analysis_fixel_mask=${FBA_DIR}/template/analysis_fixel_mask.msf
template_full_tracks=${FBA_DIR}/template/fullTracto.tck
template_sift_tracks=${FBA_DIR}/template/fullTracto_sifted.tck

angle=22.5
maxlen=250
minlen=10
power=1.0



isOK=1
for f in $template_fod $template_mask
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




echo "  [INFO] Running full tractography on template ($nTracks tracks)"
cmd="tckgen \
  -angle $angle \
  -maxlen $maxlen \
  -minlen $minlen \
  -power $power \
  $template_fod \
  -seed_image $template_mask \
  -mask $template_mask \
  -select $nTracksOrig \
  $template_full_tracks"
echo "  --> $cmd"
time $cmd

# 15. Reduce biases in tractogram densities
# Perform SIFT to reduce tractography biases in the whole-brain tractogram:


echo "  [INFO] Running SIFT (leaving $nTracksSift tracks)"
cmd="tcksift \
  $template_full_tracks \
  $template_fod \
  $template_sift_tracks \
  -term_number $nTracksSift"
echo "  --> $cmd"
time $cmd
