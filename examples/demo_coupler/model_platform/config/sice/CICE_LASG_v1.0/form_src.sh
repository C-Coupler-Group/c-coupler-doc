#!/bin/bash

Env=$1
Ntask=$2
Srclist=$3

source $Env

if [ $Ntask -eq 1 ] ; then
	COMMDIR=serial
else
	COMMDIR=mpi
fi
touch $Srclist
cat > $Srclist << EOF
$CODEROOT/sice/CICE_LASG_v1.0/drivers/cice4
$CODEROOT/sice/CICE_LASG_v1.0/$COMMDIR
$CODEROOT/sice/CICE_LASG_v1.0/source
$CODEROOT/sice/CICE_LASG_v1.0/coupled/c_coupler
$CODEROOT/libs/shr
EOF

exit 0
