#!/bin/bash

Env=$1
Srclist=$3

source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/libs/shr/shr_orb_mod.F90
$CODEROOT/libs/shr/shr_sys_mod.F90
$CODEROOT/libs/shr/shr_mpi_mod.F90
$CODEROOT/libs/shr/shr_kind_mod.F90
$CODEROOT/libs/shr/shr_const_mod.F90
$CODEROOT/libs/c_coupler/Data_MGT
$CODEROOT/libs/c_coupler/Parallel_MGT
$CODEROOT/libs/c_coupler/Runtime_MGT
$CODEROOT/libs/c_coupler/External_Algorithms
$CODEROOT/libs/c_coupler/Driver
$CODEROOT/libs/c_coupler/Utils
$CODEROOT/libs/c_coupler/CoR
EOF

exit 0
