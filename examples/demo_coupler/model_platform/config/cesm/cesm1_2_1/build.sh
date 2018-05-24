#!/bin/bash

function dump_Macros
{
cat > /tmp/makefile << EOF
include $2
all:
	@echo "CPPDEFS += \${CPPDEFS}"
	@echo 
	@echo "SLIBS += \${SLIBS}"
	@echo 
	@echo "CFLAGS := \${CFLAGS}"
	@echo 
	@echo "CXX_LDFLAGS := \${CXX_LDFLAGS}"
	@echo 
	@echo "CXX_LINKER := \${CXX_LINKER}"
	@echo 
	@echo "FC_AUTO_R8 := \${FC_AUTO_R8}"
	@echo 
	@echo "FFLAGS := \${FFLAGS}"
	@echo 
	@echo "FFLAGS_NOOPT := \${FFLAGS_NOOPT}"
	@echo 
	@echo "FIXEDFLAGS := \${FIXEDFLAGS}"
	@echo 
	@echo "FREEFLAGS := \${FREEFLAGS}"
	@echo 
	@echo "MPICC := \${MPICC}"
	@echo
	@echo "MPICXX := \${MPICXX}" 
	@echo
	@echo "MPIFC := \${MPIFC}"
	@echo
	@echo "SCC := \${SCC}"
	@echo
	@echo "SCXX := \${SCXX}"
	@echo
	@echo "SFC := \${SFC}"
	@echo
	@echo "SUPPORTS_CXX := \${SUPPORTS_CXX}"
	@echo
	@echo "ifeq (\\\$\$(DEBUG), true)"
	@echo "    FFLAGS += -g -CU -check pointers -fpe0 "
	@echo "endif"
	@echo
	@echo "LDFLAGS += \${LDFLAGS}"
	@echo
	@echo "ifeq (\\\$\$(compile_threaded), true) "
	@echo "    LDFLAGS += -openmp "
	@echo "    CFLAGS += -openmp "
	@echo "    FFLAGS += -openmp "
	@echo "endif"
	@echo
EOF
 
    make -f /tmp/makefile >& $3
    sed -i  "/\<FFLAGS\>/{s# -r8 # #; s# -i4 # #}" $3
    ncpath=$(grep "^NETCDFINC" $1) 
    ncpath=$(echo $ncpath|sed "s#.*-I\(.*\)/include#\1#g")
    echo "NETCDF_PATH := $ncpath" >> $3
}


export Env=$1
export Exedir=$2

error_exit() {
    cleanup
    exit 1
}

export ENV_COMPILE="${CASEROOT}/config/common/env_compile"
source ${ENV_COMPILE}

# == Get the path of this script ==
MYPATH=$(readlink -f "$0")
MYPATH=$(dirname "$MYPATH")
# =================================

Macfile=${CASEROOT}/config/common/machine/${MACH}/common_compiler.${MACH}.cfg
Common=$Macfile
if [ -f $MYPATH/compiler.cfg ]; then
   Macfile=$MYPATH/compiler.cfg
fi

cd $MYPATH/cesm_case_scripts

dump_Macros "$COMMON_COMPILER" "$MACFILE" "Macros"

cat Macros

if [ ! -e "./.env_run.xml" ]; then
   echo "Can't find .env_run.xml file"
   error_exit  
fi

rm -f $Exedir/cesm_bld/cesm.exe

./$CASE_NAME.build

if [ -f $Exedir/cesm_bld/cesm.exe ] ; then
   cp $Exedir/cesm_bld/cesm.exe $EXEC
else
   exit 1
fi

cd ${CASEROOT}
find ./ -name "seq_maps.rc" > .temp_file_list
while read line
do
    sed -i "s/'Y'/'X'/g" $line 
done < .temp_file_list
rm .temp_file_list

