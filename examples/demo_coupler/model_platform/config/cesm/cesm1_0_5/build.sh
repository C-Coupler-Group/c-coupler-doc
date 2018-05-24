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
	@echo "CC := \${MPICC}"
	@echo
	@echo "CXX := \${MPICXX}" 
	@echo
	@echo "FC := \${MPIFC}"
	@echo
	@echo "F90 := \${MPIFC}"
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
	@echo "CONFIG_ARGS := "
	@echo "ifeq (\\\$\$(USE_MPISERIAL),TRUE) "
	@echo "   CONFIG_ARGS= --enable-mpiserial "
	@echo "endif"
	@echo "ifeq (\\\$\$(MODEL),pio) "
	@echo "  ifneq (\\\$\$(strip \\\$\$(PIO_CONFIG_OPTS)),) "
	@echo "     CONFIG_ARGS += \\\$\$(PIO_CONFIG_OPTS)"
	@echo "  endif "
	@echo "  CONFIG_ARGS += CC=\"\\\$\$(CC)\" F90=\"\\\$\$(FC)\" FC=\"\\\$\$(FC)\" NETCDF_PATH=\"\\\$\$(NETCDF_PATH)\" MPI_INC=\"-I\\\$\$(INC_MPI)\""
	@echo "endif "
	@echo "ifeq (\\\$\$(MODEL),mct) "
	@echo "  CONFIG_ARGS += CC=\"\\\$\$(CC)\" F90=\"\\\$\$(FC)\" FC=\"\\\$\$(FC)\" INCLUDEPATH=\"-I\\\$\$(INC_MPI)\""
	@echo "endif "
	@echo "ifeq (\\\$\$(strip \\\$\$(MODEL)),cam) "
	@echo "rrtmg_lw_k_g.o: rrtmg_lw_k_g.f90"
	@echo "\\\$\$(FC) -c \\\$\$(CPPDEFS) \\\$\$(INCLDIR) \\\$\$(INCS) \\\$\$(FREEFLAGS) \\\$\$(FFLAGS_NOOPT) \\\$\$<"
	@echo "rrtmg_sw_k_g.o: rrtmg_sw_k_g.f90"
	@echo "\\\$\$(FC) -c \\\$\$(CPPDEFS) \\\$\$(INCLDIR) \\\$\$(INCS) \\\$\$(FREEFLAGS) \\\$\$(FFLAGS_NOOPT) \\\$\$<"
	@echo "endif"



EOF
 
    ncpath=$(grep "^NETCDFINC" $1) 
    ncpath=$(echo $ncpath|sed "s#.*-I\(.*\)/include#\1#g")
    echo "NETCDF_PATH := $ncpath" > $3
    mpipath=$(grep "^MPIINC" $1) 
    mpipath=$(echo $mpipath|sed "s#.*:=\(.*\)#\1#g")
    echo "INC_MPI := $mpipath" >> $3
    make -f /tmp/makefile >> $3 2>&1
    sed -i  "/\<FFLAGS\>/{s# -r8 # #; s# -i4 # #}" $3
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

cd $MYPATH/cesm_case_scripts

dump_Macros "$COMMON_COMPILER" "$MACFILE" "Macros.CCPL"
cp $MYPATH/Macros.CCPL ./

if [ ! -e "./.env_run.xml" ]; then
   echo "Can't find .env_run.xml file"
   error_exit  
fi

rm -f $Exedir/data/ccsm.exe

#./$CASE_NAME.CCPL.clean_build
./$CASE_NAME.CCPL.build

if [ -f $Exedir/data/ccsm.exe ] ; then
   cp $Exedir/data/ccsm.exe $EXEC
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

exit 0
