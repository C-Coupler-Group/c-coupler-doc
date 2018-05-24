#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

source $env

NCINC=$(grep "^NETCDFINC" $COMMON_COMPILER)  
NCINC=$(echo $NCINC | sed "s#NETCDFINC *:=##")
MPIINC=$(grep "^MPIINC" $COMMON_COMPILER)  
MPIINC=$(echo $MPIINC | sed "s#MPIINC *:=##")
export GC_INCLUDE="$NCINC $CASE_LOCAL_INCL $MPIINC"
NCLIB=$(grep "^NETCDFLIB" $COMMON_COMPILER)  
NCLIB=$(echo $NCLIB | sed "s#NETCDFLIB *:=##")
MPILIB=$(grep "^MPILIB" $COMMON_COMPILER)  
MPILIB=$(echo $MPILIB | sed "s#MPILIB *:=##")
export GC_LIB="$NCLIB $MPILIB $CCPL_LIB"

cd $exedir/GIGC_code_mirror/
rm -f $exedir/GIGC_code_mirror/bin/geos
make -f Makefile MET=geos5 GRID=4x5 || exit 1

if [ -f $exedir/GIGC_code_mirror/bin/geos ] ; then
   cp $exedir/GIGC_code_mirror/bin/geos $exedir/exe/GIGC
else
   echo "$exedir/GIGC_code_mirror/bin/geos does not exist"
   exit 1
fi


exit 0
