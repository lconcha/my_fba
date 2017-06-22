#!/bin/bash
source `which my_do_cmd`

help() {
echo "
  `basename $0` [nSubjects]

"
}



for arg in "$@"
do
  case "$arg" in
  -h|-help)
    help
    exit 1
  ;;
esac
done



auto_nsubjs=0
if [ $1 -eq 0 ]
then
  echo "  [INFO] number of subjects for template not specified. Will use all available."
  auto_nsubjs=1
  nsubjs="XXX"
else
  if [ -f $1 ]
  then
    nsubjs=$1
  else
    nsubjs=$1
    echo "  [INFO] Number of subjects explicitly set to $nsubjs"
  fi
fi


# auto_nsubjs=0
# if [ "$#" -lt 2 ]; then
#   echo "  [INFO] number of subjects for template not specified. Will use all available."
#   auto_nsubjs=1
#   nsubjs="XXX"
# else
#   nsubjs=$1
# fi


mkdir -p ${FBA_DIR}/logs/template

ln_fod_dir=${FBA_DIR}/logs/template/fods
ln_mask_dir=${FBA_DIR}/logs/template/masks
for d in $ln_fod_dir $ln_mask_dir
  do
  if [ ! -d $d ]
  then
    mkdir $d
  fi
done


echo "  [INFO] Making sure the template directories are empty"
rm ${ln_fod_dir}/*
rm ${ln_mask_dir}/*

subjects_file=${FBA_DIR}/logs/template/subjects_to_build_template_from.txt



if [ -f $nsubjs -a $auto_nsubjs -eq 0 ]
then
  echo "  [INFO] Taking the subjects to build template from file: $nsubjs"
  cp $nsubjs $subjects_file
fi

available_subjects_file=${FBA_DIR}/logs/template/available_subjects_to_build_template_from.txt
ls ${FBA_DIR}/*/wm_fod.mif > $available_subjects_file
n_available_subjects=`wc -l $available_subjects_file | awk '{print $1}'`

if [ $n_available_subjects -eq 0 ]
then
  echo "  [ERROR] There are no FOD files to build template from. Bye."
  exit 2
fi


if [ $auto_nsubjs -eq 1 ]
then
  nsubjs=$n_available_subjects
fi


echo "  [INFO] There are $n_available_subjects available subjects to build template from"
echo "  [INFO] We will randomly take $nsubjs from these."
echo "  [INFO] List of subjects written to $subjects_file"

shuf $available_subjects_file -n $nsubjs | sort > $subjects_file



while read fod;
do
  ff=${fod#${FBA_DIR}/}
  subj=${ff%%/*}
  mask=${FBA_DIR}/$subj/mask_upsampled.mif
  if [ ! -f $fod -a -f $mask ]
  then
    echo "  [WARNING] Mismatch between FOD and mask of subject $subj (not including)"
    continue
  fi
  ln_fod=${ln_fod_dir}/${subj}_fod.mif
  ln_mask=${ln_mask_dir}/${subj}_mask.mif
  ln -s $fod $ln_fod
  ln -s $mask $ln_mask

done < <(cat $subjects_file)


echo "  [INFO] Listing the FODs to use for template"
cat $subjects_file
echo "  [INFO] End of FOD list"

echo "  [INFO] It is best to run this step on an execution host.
               Below is the command you should run.
               If you want to run it on the cluster, prepend fsl_sub to the command.
               * Also, your /tmp partition should be plentiful (several GB)
               If it is not, then use the switch -tempdir \${FBA_DIR}/logs/template
               in the following command.
"

my_do_cmd -fake population_template \
  -mask_dir $ln_mask_dir \
  -warp_dir ${FBA_DIR}/logs/template/warps \
  -linear_transformations_dir ${FBA_DIR}/logs/template/xfms \
  -template_mask ${FBA_DIR}/logs/template/template_mask.mif \
  $ln_fod_dir  \
  ${FBA_DIR}/template_fod.mif
