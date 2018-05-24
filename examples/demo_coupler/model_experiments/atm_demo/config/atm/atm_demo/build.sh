#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

source $env

cd $exedir/obj

gmake -j $GMAKE_J -f $makefile  || exit 1

exit 0
