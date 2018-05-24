#!/bin/bash

Env=$1
Srclist=$3
source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/lnd/CLM3/src/main
$CODEROOT/lnd/CLM3/src/biogeophys
$CODEROOT/lnd/CLM3/src/riverroute
$CODEROOT/lnd/CLM3/src/biogeochem
$CODEROOT/lnd/CLM3/src/mksrfdata
$CODEROOT/libs/shr
$CODEROOT/libs/timing
EOF

exit 0
