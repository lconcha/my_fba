#!/bin/bash
source `which my_do_cmd`

subj=$1


echo "Running on `hostname`"
echo "TMPDIR is $TMPDIR"
df -h
free -h


