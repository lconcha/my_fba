# my_fba
My fixel-based analysis pipeline


This is a framework for running fixel-based analyses (FBA) on DWI data based on [mrtrix3](http://www.mrtrix.org/).
It is intended to be an easy-to-use interface to the several steps needed to complete a FBA on a set of subjects.
At its core, this follows the detailed step-by-step instructions available [here](https://mrtrix.readthedocs.io/en/3.0.4/fixel_based_analysis/mt_fibre_density_cross-section.html) and wraps them for use in a HPC cluster using `fsl_sub` (tested on SGE, but very likely to run on other job schedulers supported by `fsl_sub`).

The pipeline depends on mrtrix3 tools (and fsl just for job scheduling). Keep in mind that mrtrix3 is under active development, so it would not be surprising if some tools change and this pipeline needs some tweaking. Also, it would not be so surprising if the fine people developing mrtrix3 release a pipeline that supersedes this one.

This pipeline works with **mrtrix version 0.3.4**, which uses a fixel directory structure. If newer versions of mrtrix break this pipeline, you can download this specific version from their github page.

The data must be organized in a certain way before you run `my_fba.sh`, and you must perform decent pre-processing of your data before you begin any FBA. This includes denoising, unringing, and motion/eddy correction, all of which can be performed with [`dwidenoise`](https://mrtrix.readthedocs.io/en/dev/reference/commands/dwidenoise.html) or  other preprocessing pipelines, such as [DESIGNER-v2](https://github.com/NYU-DiffusionMRI/DESIGNER-v2)

Data organization is as follows:

1. Define a global variable $FBA_DIR that holds the absolute path to where all your data is stored for this study.
2. Within $FBA_DIR you should have a folder for each subject, named accordingly. Please make sure that the first character of each subject is not a number. Inside each folder, you should have two files: dwis.mif and mask.mif


An example folder structure is:

    export FBA_DIR=/home/lconcha/myFBAdata

    $FBA_DIR/subject01
    $FBA_DIR/subject02
                     \ dwis.mif
                     \ mask.mif
                 

The mask is optional, since `my_fba.sh` has a step to create them.

Once the data is organized and you have exported `FBA_DIR` as environment variable, you can run the main script, `my_fba.sh`. Invoking it without any arguments explains its use and the steps to perform.

```
Usage: my_fba.sh <-step stepName> [Options]


Perform fixel-based analysis using mrtrix3.

Options:
-subjects <subjects_to_process.txt> Default is to process all subjects in $FBA_DIR
-subject_list <"id1 id2 id3 ..."> Same as above, but inline.
-analysis_prefix <string>     : Analysis prefix.
                       Three files that start with this string are needed:
                       prefix.subjects       The IDs of the subjects to analyze.
                       prefix.design_matrix  The design matrix (according to the previous file)
                       prefix.contrasts      The contrast to do (only one, for now)
-results_prefix <string>      : The prefix of resulting files from the statistical analysis.
-fwhm <int>
-nperms <int>
-nsubjs_for_template <int>    : Number of subjects to build template from. Default is all available.
-voxelsize <float>            : Define the desired voxel resolution for the upsampling step.
                                This value is in mm and is applied to all three dimensions
                                (thus producing isometric voxels). Default is 1.0 mm.
                                NOTE: Input -voxelsize 0 if you do not wish to resample your dwis.
-nTracksOrig <int>            : Number of tracks to obtain from FOD template.
                                Default is 20000000
-nTracksSift <int>            : Number of tracks to keep after SIFT
                                Default is 2000000
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
                           as defined by -voxelsize (Default 1.0 mm).
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
                            Will create 20000000 tracks
                            then run SIFT to get it down to 2000000.
fixelconnectivity     : 16. Compute the fixel-fixel connectivity  matrix.
                            It is highly recommended to increase -nthreads
                            (check your cluster with qhost and find how high you can go)
fixelfilter           : 17. Smooth the fixels. 
                            Change the fwhm using -fwhm. Default is 10.
stats                 : 18. Compute statistics
                            Requires some additional information, supplied by these switches:
                            -analysis_prefix <string> (no default)
                            -results_prefix   <string> (no default)
                            -fwhm <float>    FWHM of smoothing kernel in mm (Default = 10)
                            -nperms <int>    Number of permutations to execute (Default = 5000)
                            -fixel_metric <string>   Which fixel metric to evaluate.
                               Options are fd, fc_log, and fdc (fiber density, log of fiber cross-section, and
                               fiber density and cross-section, respectively).
                               Default is fd


Note that the Steps need to be executed in order.

Remember to export FBA_DIR before starting!
$FBA_DIR has a directory per subject
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
```
