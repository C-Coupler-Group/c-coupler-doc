#!/bin/bash

Env=$1
Srclist=$3
source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/lnd/colm4_beta/mainc/
$CODEROOT/libs/shr
EOF

exit 0
