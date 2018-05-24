#!/bin/bash

# == Get the path of this script ==
MYPATH=$(readlink -f "${BASH_SOURCE[0]}")
MYPATH=$(dirname "$MYPATH")
# =================================

export CONFIGROOT=$(readlink -f "$MYPATH/../config")
export CODEROOT=$(readlink -f "$MYPATH/../models")
export SCRIPTSROOT=$(readlink -f "$MYPATH/../scripts")

