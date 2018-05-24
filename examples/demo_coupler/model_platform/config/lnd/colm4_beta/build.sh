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
#define COUP_CSM
#undef  EcoDynamics
#undef  USGS
#undef  DyN
#define PFT
#define DGVM
#define RTM
#define SPMD
#define CMIP
EOF

gmake -j $GMAKE_J -f $makefile || exit 1

exit 0
