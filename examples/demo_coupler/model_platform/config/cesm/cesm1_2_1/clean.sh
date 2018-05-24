#!/bin/bash

echo "mypath"
# == Get the path of this script ==
MYPATH=$(readlink -f "$0")
MYPATH=$(dirname "$MYPATH")
# =================================

echo "$CASEROOT = "
cd $MYPATH/cesm_case_scripts

./$CASE_NAME.clean_build 


