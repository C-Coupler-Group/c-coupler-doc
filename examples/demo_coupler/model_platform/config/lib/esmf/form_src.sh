#!/bin/bash

Env=$1
Srclist=$3

source $Env

case $OS in
	"AIX")
	ESMF_ARCH=rs6000_sp
	if [ $OBJECT_MODE -eq 64 ]; then
		ESMF_ARCH=rs6000_64
	fi
	;;
	"OSF1")
	ESMF_ARCH=alpha
	;;
	"IRIX64")
	ESMF_ARCH=IRIX64
	;;
	"Linux")
	ESMF_ARCH=linux_intel
	;;
	"SUPER-UX")
	ESMF_ARCH=SX6
	;;
	"ESOS")
	ESMF_ARCH=ES
	;;
	"UNICOS")
	ESMF_ARCH=cray_x1
	;;
esac

ESMF_ROOT=$CODEROOT/libs/esmf

touch $Srclist
cat > $Srclist << EOF
$ESMF_ROOT/src/Infrastructure/BasicUtil
$ESMF_ROOT/src/Infrastructure/Error
$ESMF_ROOT/src/Infrastructure/TimeMgmt
$ESMF_ROOT/src/include
$ESMF_ROOT/include
$ESMF_ROOT/build/$ESMF_ARCH
EOF

exit 0
