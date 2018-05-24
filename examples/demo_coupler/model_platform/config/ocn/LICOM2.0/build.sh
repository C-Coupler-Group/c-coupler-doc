#!/bin/bash

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

source $env

cd $exedir/obj

#needed change
if [ "$grid" = "gr1x1" ] ; then
	JMT_GLOBAL=170
elif [ "$grid" = "eq1x1" ] ; then
	JMT_GLOBAL=196
else
	echo "The grid of licom2.0 is wrong!"
	exit -1
fi


CARBONDEF=""

SPMDDEF="!#define SPMD"
CANUTODEF="!#define CANUTO"

if [ $ntasks -gt 1 ] ; then
	SPMDDEF="#define SPMD"
fi

export USE_CANUTO=TRUE
if [ $USE_CANUTO = 'TRUE' ] ; then
	CANUTODEF="#define CANUTO"
fi

touch .tmp
cat > .tmp << EOF; cmp -s .tmp def-undef.h || mv -f .tmp def-undef.h
$SPMDDEF
$CANUTODEF
#define D_PRECISION
#define JMT_GLOBAL $JMT_GLOBAL
#define N_PROC $ntasks
#define COUP
#define LDD97
#define  SYNCH
#define  FRC_ANN
#define CDFIN
#undef  FRC_DAILY
#define SOLAR
#define ISO
#undef  ACOS
#undef  BIHAR
#undef  SMAG
#undef  SMAG_FZ
#undef  SMAG_OUT
#define NETCDF
#undef  BOUNDARY
#define NODIAG
#undef  ICE
#define SHOW_TIME

! For carbon tracer
$CARBONDEF
#ifdef PTRACER
#define  online
#undef   C20
#undef   carbonC14
#undef   cfc
#undef   carbonC
#define  carbonBio
#undef   Pacific
#define  preindustrial
#define  murnane1999
#define  anderson1995
#undef   carbonDebug
#undef   printcall
#endif
EOF

gmake -j $GMAKE_J -f $makefile || exit 1
