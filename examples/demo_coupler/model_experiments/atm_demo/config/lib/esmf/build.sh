#!/bin/bash

export Env=$1
export Libdir=$2
export Makefile=$3

source $Env

cd $Libdir/obj

gmake -j $GMAKE_J -f $Makefile || exit 1

cp -f $Libdir/exe/libesmf.a $LIBROOT/
cp *.mod $LIBROOT/include

exit 0
