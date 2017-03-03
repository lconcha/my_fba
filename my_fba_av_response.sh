#!/bin/bash
source `which my_do_cmd`
echo working on `hostname`






for tissue in wm gm csf
do
av_response=${FBA_DIR}/average_${tissue}_response.txt

  if [ -f $av_response ]
  then
    echo "  [INFO] Average response function exists: $av_response"
    continue
  fi



  isOK=1
  for s in $FBA_DIR/*
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
    


    this_response=${FBA_DIR}/${subj}/${tissue}_response.txt

    if [ ! -f $this_response ]
    then
      if [ -f ${FBA_DIR}/${subj}/exclude ]
      then
         echo "  [INFO] Subject excluded: $subj"
      else
	isOK=0
	echo "  [ERROR] Cannot find response function for subject $subj"
      fi
    else
      echo "  [INFO] Found response function: $this_response"
    fi
    
  done

  if [ $isOK -eq 0 ]
  then
    echo "  [ERROR] Cannot compute average response function. See above."
    exit 2
  fi

  my_do_cmd average_response ${FBA_DIR}/*/${tissue}_response.txt $av_response

done