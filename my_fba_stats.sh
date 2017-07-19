#!/bin/bash
source `which my_do_cmd`
echo "  Running on `hostname`"


if [ "$#" -lt 5 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` analysis_prefix output_prefix fwhm nperms fixel_metric"
  echo ""
  echo "  This script is part of the set of scripts required for fixel-based analyses."
  echo "  See my_fba.sh for help."
  exit 2
fi



# 16. Perform statistical analysis of FD, FC, and FDC
# You will need to perform a separate analysis for FD, FC and FDC. Statistics is performed using connectivity-based fixel enhancement as follows:
# 
# fixelcfestats <input_files> <input_analysis_fixel.msf> <input_design_matrix.txt> <output_contrast_matrix.txt> <input_tracks_2_million_sift.tck> <output_prefix>
# 
# 
# 
# Where the input files.txt is a text file containing the file path and name of each input fixel file on a separate line. The line ordering should correspond to the lines in the design_matrix.txt. Note that for correlation analysis, a column of 1’s will not be automatically included (as per FSL randomise). Note that fixelcfestats currently only accepts a single contrast. However if the opposite (negative) contrast is also required (i.e. a two-tailed test), then use the -neg option. Several output files will generated all starting with the supplied prefix.


analysis_prefix=$1
output_prefix=$2
fwhm=$3
nperms=$4
fixel_metric=$5

subjects=${analysis_prefix}.subjects
designmat=${analysis_prefix}.design_matrix
contrasts=${analysis_prefix}.contrasts
analysis_fixel_mask=${FBA_DIR}/template_analysis_fixel_mask.msf
template_sift_tracks=${FBA_DIR}/template_fullTracto_sifted.tck






isOK=1
for f in $designmat $contrasts $analysis_fixel_mask $template_sift_tracks
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  fi
done





# populate the inputFiles
inputFiles=${FBA_DIR}/logs/inputFiles_`basename $analysis_prefix`_${fixel_metric}_$$.txt
if [ -f $inputFiles ]; then rm $inputFiles;fi
while read subj;
do
  f=${FBA_DIR}/${subj}/${fixel_metric}_templateSpace_corresp2template.msf
  frelative="../${subj}/${fixel_metric}_templateSpace_corresp2template.msf"
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  else
    echo $frelative >> $inputFiles
  fi
done < <(cat $subjects)

if [ $isOK -eq 0 ]
then
  echo "  [ERROR] Cannot compute statistics. Quitting."
  exit 2
fi

echo "  [INFO] Stat analysis to be performed:"
paste $designmat $inputFiles
cat   $contrasts
echo "  [INFO] End of design"


# mrtrix can only handle one contrast at a time. It is easier to write them all down in a single file, and this while will separate them.
c=0
RAMneeded=64
while read line;
do
  thisContrast=${FBA_DIR}/logs/`basename ${analysis_prefix}`_contrast_${c}.txt
  echo "  [INFO] Contrast $c is $thisContrast"
  echo "         $line"
  echo $line > $thisContrast
  fsl_sub -R $RAMneeded -N st${c}_${fixel_metric} -l ${FBA_DIR}/logs fixelcfestats \
    -nperms $nperms \
    -info \
    -negative \
    -smooth $fwhm \
    $inputFiles \
    $analysis_fixel_mask \
    $designmat \
    $thisContrast \
    $template_sift_tracks \
    ${output_prefix}_${fixel_metric}_contrast${c}_
  c=$(( $c+1 ))
done < <(cat $contrasts)






