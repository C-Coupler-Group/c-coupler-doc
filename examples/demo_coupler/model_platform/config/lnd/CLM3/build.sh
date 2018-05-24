#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}
source $env

cd $exedir/obj

if [ "$grid" = "360x180" ] ; then
	NLON=360
    NLAT=180
elif [ "$grid" = "128x60" ] ; then
    NLON=128
    NLAT=60
else
	echo "The grid of LCM3 is wrong!"
	exit -1
fi

touch .tmp
cat > .tmp << EOF; cmp -s .tmp preproc.h || cp -f .tmp preproc.h
#ifndef PREPROC_SET
#define PREPROC_SET
#define COUP_CSM
#define LSMLON $NLON
#define LSMLAT $NLAT
#define RTM
#endif
EOF

spmd="#undef SPMD"
if [ $ntasks -gt 1 ]; then
	spmd="#define SPMD"
fi

cat > .tmp << EOF; cmp -s .tmp misc.h || mv -f .tmp misc.h
#ifndef MISC_SET
#define MISC_SET
$spmd
#endif
EOF

gmake -j $GMAKE_J -f $makefile || exit 1

exit 0
