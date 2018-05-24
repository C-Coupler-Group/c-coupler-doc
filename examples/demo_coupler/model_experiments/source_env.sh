#!/bin/sh


MYPATH=$(readlink -f "${BASH_SOURCE[0]}")
MYPATH=$(dirname "$MYPATH")

source $MYPATH/../model_platform/scripts/register_platform.sh

MYPATH=$(readlink -f "${BASH_SOURCE[0]}")
MYPATH=$(dirname "$MYPATH")

source $MYPATH/../inputdata/register_inputdata.sh
