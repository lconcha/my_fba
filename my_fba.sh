#!/bin/bash


### Defaults
list_of_subjects=""
fixel_mask_threshold=0.06
fwhm=10
nperms=5000
prefix=""
suffix=""
nsubjs_for_template=0
voxelsize=1.0
nTracksOrig=20000000
nTracksSift=2000000
fixel_metric="fd"
nthreads=6
### end defaults




help() {
echo "

Usage: `basename $0` <-step stepName> [Options]


Perform fixel-based analysis using mrtrix3.

Options:
-subjects <subjects_to_process.txt> Default is to process all subjects in \$FBA_DIR
-subject_list <\"id1 id2 id3 ...\"> Same as above, but inline.
-analysis_prefix <string>     : Analysis prefix.
                       Three files that start with this string are needed:
                       prefix.subjects       The IDs of the subjects to analyze.
                       prefix.design_matrix  The design matrix (according to the previous file)
                       prefix.contrasts      The contrast to do, one per row.
-results_prefix <string>      : The prefix of resulting files from the statistical analysis.
-fwhm <int>
-nperms <int>
-nsubjs_for_template <int>    : Number of subjects to build template from. Default is all available.
-voxelsize <float>            : Define the desired voxel resolution for the upsampling step.
                                This value is in mm and is applied to all three dimensions
                                (thus producing isometric voxels). Default is $voxelsize mm.
                                NOTE: Input -voxelsize 0 if you do not wish to resample your dwis.
-nTracksOrig <int>            : Number of tracks to obtain from FOD template.
                                Default is $nTracksOrig
-nTracksSift <int>            : Number of tracks to keep after SIFT
                                Default is $nTracksSift
-nthreads <int>               : Number of threads per job.

Note that -analysis_prefix and -results_prefix are mandatory if the Step stats is to be executed.

Step Names:

test                  : Just print the name of the subjects to process.
qtest                 : Test the SGE system.
simplemetrics         : Compute simple metrics from the tensor (useful for QC)
mask                  : 1. Compute a mask per subject
std_signal            : 2. Signal intensity normalization and scaling based on whole white matter.
                           This is necessary to make AFD metric have similar units between subjects.
upsample              : 3. Upsample the images to have a resolution
                           as defined by -voxelsize (Default $voxelsize mm).
                           NOTE: Input -voxelsize 0 if you do not wish to resample your dwis.
response              : 4. Compute the response function.
av_response           : 5. Average all subjects response functions to a single one.
                           This response function will be used to estimate FODs on each subject.
fod                   : 6. Compute the FOD
mtnormalise           : 6a. Multi-tissue intensity normalisation of FODs.
build_fod_template    : 7. Build the FOD template. Very time consuming.
fod2template          : 8. Register the subject FOD to the template FOD.
maskIntersection      : 9. Calculate the intersection of masks of all subjects.
fixel_mask            : 10. Estimate a fixel mask on the template.
                           Group analyses will be done in this mask.
afd                   : 11. Compute AFD metrics.
fixel_reorient        : 12. Reorient fixels to the template.
fixel_correspondence  : 13. Estimate fixel correspondence between subject and template.
fixel_metrics         : 14. Compute fibre cross-section (FC) and fibre density and cross-section (FDC).
tracto                : 15. Run tractography on the template FOD.
                            Will create $nTracksOrig tracks
                            then run SIFT to get it down to $nTracksSift.
fixelconnectivity     : 16. Compute the fixel-fixel connectivity  matrix.
                            It is highly recommended to increase -nthreads
                            (check your cluster with qhost and find how high you can go)
fixelfilter           : 17. Smooth the fixels. 
                            Change the fwhm using -fwhm. Default is $fwhm.
stats                 : 18. Compute statistics
                            Requires some additional information, supplied by these switches:
                            -analysis_prefix <string> (no default)
                            -results_prefix   <string> (no default)
                            -fwhm <float>    FWHM of smoothing kernel in mm (Default = $fwhm)
                            -nperms <int>    Number of permutations to execute (Default = $nperms)
                            -fixel_metric <string>   Which fixel metric to evaluate.
                               Options are fd, fc_log, and fdc (fiber density, log of fiber cross-section, and
                               fiber density and cross-section, respectively).
                               Default is $fixel_metric


Note that the Steps need to be executed in order.

Remember to export FBA_DIR before starting!
\$FBA_DIR has a directory per subject
each directory should have a dwis.mif file.
the dwis.mif should already be pre-processed: denoised, topup and biasfield corrected.
example:
export FBA_DIR=/misc/mansfield/lconcha/TMP/FBA_DIR
FBA_DIR
   \- s001
   \- s002
   \- s003
       \- dwis.mif


LU15 (0N(H4
INB, UNAM
lconcha@unam.mx

"
}


if [ "$#" -lt 2 ]
then
  echo "  [ERROR]. Insufficient arguments."
  help
  exit 2
fi



for arg in "$@"
do
  case "$arg" in
  -h|-help)
    help
    exit 1
  ;;
  -step)
    stepToRun=$2
    shift;shift
  ;;
  -subjects)
    list_of_subjects=$2
    shift;shift
  ;;
  -subject_list)
    list_of_subjects=$2
    shift;shift
  ;;
  -analysis_prefix)
    analysis_prefix=$2
    echo "  [INFO] Analysis prefix is $analysis_prefix"
    shift;shift
  ;;
  -results_prefix)
    results_prefix=$2
    echo "  [INFO] Results prefix is $results_prefix"
    shift;shift
  ;;
  -fwhm)
    fwhm=$2
    shift;shift
  ;;
  -nperms)
    nperms=$2
    shift;shift
  ;;
  -nsubjs_for_template)
    nsubjs_for_template=$2
    echo "  [INFO] Number of subjects to build template from: $nsubjs_for_template"
    shift;shift
  ;;
  -voxelsize)
    voxelsize=$2
    echo "  [INFO] Desired voxel size: $voxelsize"
    shift;shift
  ;;
  -nTracksOrig)
    nTracksOrig=$2
    echo "  [INFO] User specified number of tracks to get from template to $nTracksOrig"
    shift;shift
  ;;
  -nTracksSift)
    nTracksSift=$2
    echo "  [INFO] User specified number of tracks to keep after SIFT to $nTracksSift"
    shift;shift
  ;;
  -fixel_metric)
   fixel_metric=$2
   echo "  [INFO] User specified fixel metric to evaluate in stats, setting it to $fixel_metric"
   shift;shift
  ;;
  -nthreads)
   nthreads=$2
   echo "  [INFO] User specified nthreads: $nthreads"
   shift;shift
  ;;
  esac
done








### group_level steps
 case $stepToRun in
  av_response)
    my_fba_av_response.sh
    exit 0
  ;;
  build_fod_template)
    my_fba_build_template.sh $nsubjs_for_template
    exit 0
  ;;
  maskIntersection)
    fsl_sub -s smp,$nthreads  -N maskIntx -l ${FBA_DIR}/logs \
    my_fba_maskIntersection.sh
    exit 0
  ;;
  fixel_mask)
    fsl_sub -s smp,$nthreads  -N fixelmask -l ${FBA_DIR}/logs \
    my_fba_createFixelMask.sh $fixel_mask_threshold
    exit 0
  ;;
  tracto)
    fsl_sub -s smp,$nthreads  -N tracto -l ${FBA_DIR}/logs \
    my_fba_fullTemplateTracto.sh $nTracksOrig $nTracksSift
    exit 0
  ;;
  fixelfilter)
    echo "[INFO] This step needs a lot of RAM. fsl_sub will try to find a PC with at least 24G."
    fsl_sub -s smp,$nthreads  -N fixelfilt -l ${FBA_DIR}/logs -R 24000 \
    my_fba_fixelfilter.sh $fwhm
    exit 0
  ;;
  fixelconnectivity)
    echo "[INFO] This step needs a lot of RAM. fsl_sub will try to find a PC with at least 24G."
    fsl_sub -s smp,$nthreads  -N fixelconn -l ${FBA_DIR}/logs -R 24000 \
    my_fba_fixelconnectivity.sh
    exit 0
  ;;
  stats)
    #fsl_sub -N stats -l ${FBA_DIR}/logs \
    if [[ -z "$analysis_prefix" ]]
    then
      echo "  [ERROR]  Please specify a valid -analysis_prefix"
      exit 2
    fi
    if [[ -z "$results_prefix" ]]
    then
      echo "  [ERROR]  Please specify a valid -results_prefix"
      exit 2
    fi
      my_fba_stats.sh $analysis_prefix $results_prefix $nperms $fixel_metric
    exit 0
 esac








### subject_level steps
if [ -z "$list_of_subjects" ]
then
  echo "  [INFO] List of subjects automatically populated."
  list_of_subjects=`ls -d ${FBA_DIR}/*`

fi

for s in $list_of_subjects
do
  if [ ! -d $s ]
  then
    continue
  fi
  subj=`basename $s`

  if [[ "$subj" = "logs" ]]
  then
    continue
  fi

  if [ -f ${FBA_DIR}/${subj}/exclude ]
  then
    echo "  [INFO] Excluding subject $subj"
    continue
  fi

  if [ ! -f ${FBA_DIR}/${subj}/dwis.mif ]
  then
    echo "  [INFO] $subj is not a valid subject."
    continue
  fi

  echo "  [INFO] Submitting job $stepToRun for subject $subj"

  case $stepToRun in
  test)
    echo "  This is just a test for subject $subj"
  ;;
  qtest)
    fsl_sub -s smp,$nthreads -N s${subj}_test -l ${FBA_DIR}/logs \
    my_fba_test.sh $subj
  ;;
  mask)
    fsl_sub -s smp,$nthreads -N s${subj}_mask -l ${FBA_DIR}/logs \
        my_fba_mask.sh $subj
  ;;
  std_signal)
    fsl_sub -s smp,$nthreads -N s${subj}_std -l ${FBA_DIR}/logs \
        my_fba_stdSignal.sh $subj fa
  ;;
  response)
    fsl_sub -s smp,$nthreads -N s${subj}_resp -l ${FBA_DIR}/logs \
        my_fba_response.sh $subj
  ;;
  upsample)
    fsl_sub -s smp,$nthreads -N s${subj}_up -l ${FBA_DIR}/logs -R 6 \
        my_fba_upsample.sh $subj $voxelsize
  ;;
  fod)
    fsl_sub -s smp,$nthreads -N s${subj}_fod -l ${FBA_DIR}/logs -R 6 \
        my_fba_fod.sh $subj
  ;;
  mtnormalise)
    fsl_sub -s smp,$nthreads -N s${subj}_fod -l ${FBA_DIR}/logs -R 6 \
        my_fba_mtnormalise.sh $subj
  ;;
  fod2template)
     fsl_sub -s smp,$nthreads -N s${subj}_rfod -l ${FBA_DIR}/logs -R 6 \
        my_fba_fod2template.sh $subj
  ;;
  afd)
     fsl_sub -s smp,$nthreads -N s${subj}_afd -l ${FBA_DIR}/logs -R 6 \
        my_fba_afd.sh $subj
  ;;
  fixel_reorient)
     fsl_sub -s smp,$nthreads -N s${subj}_fr -l ${FBA_DIR}/logs -R 6 \
        my_fba_fixelReorient.sh $subj
  ;;
  fixel_correspondence)
     fsl_sub -s smp,$nthreads -N s${subj}_fc -l ${FBA_DIR}/logs -R 6 \
        my_fba_fixelcorrespondence.sh $subj
  ;;
  fixel_metrics)
     fsl_sub -s smp,$nthreads -N s${subj}_fm -l ${FBA_DIR}/logs -R 6 \
        my_fba_computeMetrics.sh $subj
  ;;
  simplemetrics)
     fsl_sub -s smp,$nthreads -N s${subj}_t -l ${FBA_DIR}/logs -R 6 \
        my_fba_simplemetrics.sh $subj
  ;;
  *)
    echo "  [ERROR] No such step $stepToRun"
    echo "  [INFO] Type `basename $0` -help to learn how to use this script."
    exit 2
  ;;
  esac
done
