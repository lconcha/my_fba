# my_fba
My fixel-based analysis pipeline


This is a framework for running fixel-based analyses (FBA) on DWI data based on [mrtrix3](http://www.mrtrix.org/).
It is intended to be an easy-to-use interface to the several steps needed to complete a FBA on a set of subjects.

The pipeline depends on mrtrix3 tools. Keep in mind that mrtrix3 is under active development, so it would not be surprising if some tools change and this pipeline needs some tweaking. Also, it would not be so surprising if the fine folk developing mrtrix3 release a pipeline that supersedes this one.

This pipeline works with mrtrix version 0.3.15-294-ge8a525c6. If newer versions of mrtrix break this pipeline, you can download this specific version from their github page.

The data must be organized in a certain way before you run my_fba, and you must perform decent pre-processing of your data before you begin any FBA. This includes denoising, motion-correction/eddy, and intensity normalization. Data organization is as follows:

1. Define a global variable $FBA_DIR that holds the absolute path to where all your data is stored for this study.
2. Within $FBA_DIR you should have a folder for each subject, named accordingly. Please make sure that the first character of each subject is not a number. Inside each folder, you should have two files: dwis.mif and mask.mif


An example folder structure is:

    export FBA_DIR=/home/lconcha/myFBAdata

    $FBA_DIR/subject01
    $FBA_DIR/subject02
                     \ dwis.mif
                     \ mask.mif
                 
                 
