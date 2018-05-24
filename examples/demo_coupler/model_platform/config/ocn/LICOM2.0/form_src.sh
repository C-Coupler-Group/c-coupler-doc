#!/bin/bash

Env=$1
Srclist=$3
source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/ocn/LICOM2.0/src_20100720/source
$CODEROOT/ocn/LICOM2.0/src_20100720/coupled
$CODEROOT/libs/shr
EOF

exit 0
