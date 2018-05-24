#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}
source $env

cd $exedir/obj

touch .tmp
cat > .tmp << EOF; cmp -s .tmp define.h || cp -f .tmp define.h 
#undef  coup_atmosmodel
#undef  RDGRID
#undef  SOILINI
#define offline
#define SPMD
#define USGS
#define EcoDynamics
#define LANDONLY
#undef  LAND_SEA
#undef  SINGLE_POINT
#define WR_MONTHLY
#define NCHIST
EOF

gmake -j $GMAKE_J -f $makefile || exit 1

exit 0
