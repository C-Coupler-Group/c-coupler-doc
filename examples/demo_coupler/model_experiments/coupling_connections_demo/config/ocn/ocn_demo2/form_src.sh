#!/bin/bash

Env=$1
Srclist=$3
source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/demo/coupling_connections_demo/ocn_demo2/
EOF

exit 0
