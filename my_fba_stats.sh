#!/bin/bash
source `which my_do_cmd`
echo "  Running on `hostname`"


if [ "$#" -lt 4 ]
then
  echo "  [ERROR]. Insufficient arguments."
  echo "  Usage: `basename $0` analysis_prefix output_prefix nperms fixel_metric"
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
nperms=$3
fixel_metric=$4

subjects=${analysis_prefix}.subjects
designmat=${analysis_prefix}.design_matrix
contrasts=${analysis_prefix}.contrasts
analysis_fixel_mask=${FBA_DIR}/template/fixel_mask
template_sift_tracks=${FBA_DIR}/template/fullTracto_sifted.tck
connmatrix=${FBA_DIR}/template/matrix





isOK=1
for f in $designmat $contrasts $template_sift_tracks
do
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  fi
done
for d in $connmatrix $analysis_fixel_mask
do
  if [ ! -d $d ]
  then
      echo "  [ERROR] Cannot find directory: $d"
      isOK=0
  fi
done
if [ $isOK -eq 0 ]
then
  exit 2
fi


fixel_dir_smooth=${FBA_DIR}/template/${fixel_metric}_smooth
if [ ! -d $fixel_dir_smooth ]
then
  echo "  [ERROR] Directory does not exist: $fixel_dir_smooth"
  echo "          Maybe it is not a valid metric? Remember to input the _smooth version!"
  exit 2
fi


# populate the inputFiles
inputFiles=${FBA_DIR}/logs/inputFiles_`basename $analysis_prefix`_${fixel_metric}_$$.txt
if [ -f $inputFiles ]; then rm $inputFiles;fi
while read subj;
do
  f=${FBA_DIR}/template/${fixel_metric}/${subj}.mif
  ff=$(basename $f)
  if [ ! -f $f ]
  then
    echo "  [ERROR] Cannot find file: $f"
    isOK=0
  else
    echo $ff >> $inputFiles
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


out_stats_dir=${FBA_DIR}/template/stats_${fixel_metric}/`basename $analysis_prefix`
mkdir -pv $out_stats_dir
echo;echo "  [USER] Now copy/paste this command and run it:"
my_do_cmd -fake fixelcfestats \
    -nshuffles $nperms \
    -info \
    $fixel_dir_smooth \
    $inputFiles \
    $designmat \
    $contrasts \
    $connmatrix \
    $out_stats_dir








