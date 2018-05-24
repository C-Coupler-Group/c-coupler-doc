#!/bin/bash

Env=$1
Srclist=$3
source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/atm_chem/GIGC/Code.v9-02/
EOF

exit 0
