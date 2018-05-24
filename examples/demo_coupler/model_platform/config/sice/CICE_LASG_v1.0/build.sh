#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

source $env

cd $exedir/obj

if [ $ntasks -le 0 ] ; then
	echo "The tasks of ice must be > 0"
	exit -1
fi

if [ $nthrds -ne 1 ] ; then
	echo "The threads of ice must be 1"
	exit -1
fi

#Calculate processor tiling based on $ntasks

export NY=1
nlon=360
let nx=$ntasks/$NY
export NX=$nx
let erm=$nlon%$nx
if [ $erm -ne 0 ] ; then
	echo ERROR: NX must devide evenly into grid, 360,$NX
	exit -1
fi

export BPX=1
export BPY=1

let a=360/$NX ; let rem1=360%$NX ; let b=$a+1
export BLCKX=$a
if [ $rem1 -ne 0 ]; then
	export BLCKX=$b
fi

let a=$BLCKX/$BPX; let rem2=$BLCKX%$BPX; let b=$a+1
export BLCKX=$a
if [ $rem2 -ne 0 ]; then
	export BLCKX=$b
fi

let a=196/$NY; let rem1=196%$NY; let b=$a+1
export BLCKY=$a
if [ $rem1 -ne 0 ]; then
	export BLCKY=$b
fi

let a=$BLCKY/$BPY; let rem1=$BLCKY%$BPY; let b=$a+1
export BLCKY=$a
if [ $rem1 -ne 0 ]; then
	export BLCKY=$b
fi

let m=$BPX*$BPY; export MXBLCKS=$m

recompile=FALSE
echo 360 196 5 $NX $NY > iceres.new
if [ ! -e iceres.old ] ; then
	echo > iceres.old
fi

cmp -s iceres.new iceres.old || recompile=TRUE
if [ $recompile = "TRUE" ]; then
	rm -f *.o
	rm -f *.d
	rm -f *.f
	rm -f *.f90
	rm -f $exedir/exe/cice_lasg_v1.0
fi

gmake -j $GMAKE_J  NXGLOB=360 NYGLOB=196 NCAT=5 BLCKX=$BLCKX BLCKY=$BLCKY MXBLCKS=$MXBLCKS -f $makefile || exit 1

mv iceres.new iceres.old

exit 0
