#!/bin/bash
source `which my_do_cmd`

prefix=$1
filetocheck=$2


problems=""
for d in `ls -d ${FBA_DIR}/${prefix}*`
do
  subj=`basename $d`
  F=${FBA_DIR}/${subj}/$filetocheck

  if [ -f ${FBA_DIR}/$subj/exclude ]
    then
      echo "  [INFO] Excluding subject $subj"
      continue
    else
    if [ ! -f $F ]
    then
      echo "  [ERROR] File not found for subject $subj : $F"
      problems="$problems $subj"
    else
      echo "  [INFO] File found for subject $subj  : $F"
      sz_du=`du  $F | awk '{print $1}'`
      if [ $sz_du -eq 0 ]
      then
	echo "  [ERROR] But file size is zero!  : $F"
        problems="$problems $subj"
      fi
      ext=${F#*.} 
      if [[ $ext = "mif" ]]
      then
	ndims=`mrinfo -ndim $F`
        #echo "  [INFO] File is an image in mif format with $ndims dimensions" 
        if [ $ndims -gt 3 ]
        then
	  std=`mrconvert -quiet -coord 3 0 $F - | mrstats -output std -`
        else
          std=`mrstats -output std $F`
        fi
        if [[ "${std/ /}" = 0 ]]
        then
          echo "  [ERROR] File standard deviation is zero :  $F"
          problems="$problems $subj"
        fi
      fi
      
    fi
  fi
done


if [ ! -z "$problems" ]
then
  echo ""
  echo "  Problems with subjects:"
  echo $problems
else
  echo ""
  echo "  [INFO] No problems detected."
fi

