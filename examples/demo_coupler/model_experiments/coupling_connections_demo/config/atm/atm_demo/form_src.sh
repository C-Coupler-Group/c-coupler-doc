#!/bin/bash

Env=$1
Srclist=$3
source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/demo/coupling_connections_demo/atm_demo
EOF

exit 0
