#!/bin/bash

Env=$1
Srclist=$3

source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/libs/c_coupler/src/Data_MGT
$CODEROOT/libs/c_coupler/src/Parallel_MGT
$CODEROOT/libs/c_coupler/src/Runtime_MGT
$CODEROOT/libs/c_coupler/src/XML
$CODEROOT/libs/c_coupler/src/Driver
$CODEROOT/libs/c_coupler/src/Utils
$CODEROOT/libs/c_coupler/src/CoR
EOF

exit 0
