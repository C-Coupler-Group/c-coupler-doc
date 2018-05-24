#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

source $env

cd $exedir/WRFV3
rm -f $exedir/WRFV3/main/wrf.exe
./compile -j 1  em_real 
cp $exedir/WRFV3/main/wrf.exe $exedir/exe/wrf 
