#!/bin/bash

function dump_Macros
{
echo $1
cat > /tmp/makefile << EOF
include $1
all:
	@echo "FC = \${FC}"
	@echo "CC = \${CC}"
	@echo "CXX = \${CXX}"
	@echo "CPP = \${CPP}"
	@echo "FPP = \${FPP}"
	@echo "AR = \${AR}"
	@echo "LD = \${LD}"
	@echo "CFLAGS = \${CFLAGS}"
	@echo "CPPFLAGS = \${CPPFLAGS}"
	@echo "CXXFLAGS = \${CXXFLAGS}"
	@echo "FIXEDFLAGS = \${FIXEDFLAGS}"
	@echo "FREEFLAGS = \${FREEFLAGS}"
	@echo "FFLAGS = \${FFLAGS}"
	@echo "LDFLAGS = \${LDFLAGS}"
	@echo "ULIBS = \${ULIBS}"
	@echo "MOD_SUFFIX = \${MOD_SUFFIX}"
	@echo "NETCDFINC = \${NETCDFINC}"
	@echo "NETCDFLIB = \${NETCDFLIB}"
	@echo "MPIINC = \${MPIINC}"
	@echo "MPILIB = \${MPILIB}"
	@echo "MCPPFLAG = \${MCPPFLAG}"
	@echo "INCLDIR = \${INCLDIR}"
	@echo "SLIBS = \${SLIBS}"
	@echo "CPPDEFS = \${CPPDEFS}"
EOF
    make -f /tmp/makefile >& /tmp/Macros
    wrf_file=${exedir}/WRFV3/configure.wrf
    if [ "$USE_OMP" = "FALSE" ]; then
    	sed -i "s#\(^OMPCPP *= *\).*#\1 #" $wrf_file
     	sed -i "s#\(^OMP *= *\).*#\1 -fpp -auto#" $wrf_file
    	sed -i "s#\(^OMPCC *= *\).*#\1 -fpp -auto#" $wrf_file
    else
    	sed -i "s#\(^OMPCPP *= *\).*#\1 -D_OPENMP#" $wrf_file
    	sed -i "s#\(^OMP *= *\).*#\1 -openmp -fpp -auto#" $wrf_file
    	sed -i "s#\(^OMPCC *= *\).*#\1 -openmp -fpp -auto#" $wrf_file
    fi

    var=$(grep "^FC *=" /tmp/Macros | sed "s#^FC *= *\(.*\)#\1#")
    sed -i "s#\(^SFC *= *\).*#\1 $var#" $wrf_file
    sed -i "s#\(^DM_FC *= *\).*#\1 $var#" $wrf_file

    var=$(grep "^CC *=" /tmp/Macros | sed "s#^CC *= *\(.*\)#\1#")
    sed -i "s#\(^SCC *= *\).*#\1 $var#" $wrf_file
    sed -i "s#\(^CCOMP *= *\).*#\1 $var#" $wrf_file
    sed -i "s#\(^DM_CC *= *\).*#\1 $var -DMPI2_SUPPORT -DMPI2_THREAD_SUPPORT#" $wrf_file

    var=$(grep "^LD *=" /tmp/Macros | sed "s#^LD *= *\(.*\)#\1#")
    sed -i "s#\(^LD *= *\).*#\1 $var#" $wrf_file

    var=$(grep "^FFLAGS" /tmp/Macros | grep " -i[0-9]* " /tmp/Macros | sed "s#.* \(-i[0-9]\).*#\1#")
    if [[ "$var" =~ -i[0-9] ]]; then
        sed -i "s#\(^PROMOTION *= *\).*#\1 $var#" $wrf_file
    else
        sed -i "s#\(^PROMOTION *= *\).*#\1 -i4#" $wrf_file
    fi

    var=$(grep "^CFLAGS *=" /tmp/Macros | sed "s#^CFLAGS *= *\(.*\)#\1#")
    sed -i "s#\(^CFLAGS_LOCAL *= *\).*#\1 $var#" $wrf_file

    var=$(grep " -convert" /tmp/Macros | sed "s#.*\(-convert .*endian\).*#\1#")
    sed -i "s#\(^BYTESWAPIO *= *\).*#\1 $var#" $wrf_file

    var=$(grep "^CPP *=" /tmp/Macros | sed "s#^CPP *=\(.*\)#\1#")
    sed -i "s#\(^CPP *= *\).*#\1 $var#" $wrf_file

    var=$(grep "^AR *=" /tmp/Macros | sed "s#^AR *=\(.*\)#\1#")
    sed -i "s#\(^AR *= *\).*#\1 $var#" $wrf_file

    #var=$(grep NETCDFINC /tmp/Macros  | sed "s#.*-I\(.*\)/include.*#\1#")
    #sed -i "s#\(^NETCDFPATH *= *\).*#\1 $var#" $wrf_file

    var=$(grep "^LDFLAGS *=" /tmp/Macros | sed "s#^LDFLAGS *= *\(.*\)#\1#")
    sed -i "s#\(^LDFLAGS_LOCAL *= *\).*#\1 $var#" $wrf_file

    var=$(grep "^FFLAGS" /tmp/Macros | grep " -O[0-3] " | sed "s#.*\(-O[0-3]\).*#\1#")
    if [[ "$var" =~ -O[0-3] ]]; then
        sed -i "s#\(^FCOPTIM *= *\).*#\1 $var#" $wrf_file
    else
        sed -i "s#\(^FCOPTIM *= *\).*#\1 -O2#" $wrf_file
    fi

    var=$(grep "^FFLAGS" /tmp/Macros | sed "s# -O[0-3] # #" | sed "s# -i[0-9]* # #" | sed "s# -r[0-9]* # #" | sed "s#^FFLAGS *=\(.*\)#\1#")
    sed -i "s#\(^FCBASEOPTS_NO_G *= *\).*#\1 $var#" $wrf_file

    rm /tmp/makefile
    rm /tmp/Macros
}

export env=${1}
export exedir=${2}
export makefile=${3}
export ntasks=${4}
export nthrds=${5}
export grid=${6}

source $env

# == Get the path of this script ==
MYPATH=$(readlink -f "$0")
MYPATH=$(dirname "$MYPATH")
# =================================

Macfile=${CASEROOT}/config/common/machine/${MACH}/common_compiler.${MACH}.cfg
Common=$Macfile
if [ -f $MYPATH/compiler.cfg ]; then
   Macfile=$MYPATH/compiler.cfg
fi

cd $exedir/WRFV3

dump_Macros "$Macfile"
rm -f $exedir/WRFV3/main/wrf.exe
./compile -j 1  em_real 
cp $exedir/WRFV3/main/wrf.exe $exedir/exe/wrf 
