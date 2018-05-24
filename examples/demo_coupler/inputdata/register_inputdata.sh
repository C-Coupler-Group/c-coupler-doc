#!/bin/bash

# == Get the path of this script ==
MYPATH=$(readlink -f "${BASH_SOURCE[0]}")
MYPATH=$(dirname "$MYPATH")
# =================================

export DATAROOT=$MYPATH

