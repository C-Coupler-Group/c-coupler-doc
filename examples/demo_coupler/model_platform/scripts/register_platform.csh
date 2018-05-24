#!/bin/csh

# == Get the path of this script ==
set called=($_)

if ("$called" != "") then
        set me="$called[2]"
else
        set me="$0"
endif
set MYPATH=`readlink -f "$me"`
set MYPATH=`dirname "$MYPATH"`
# =================================

setenv CONFIGROOT `readlink -f "$MYPATH/../config"`
setenv CODEROOT `readlink -f "$MYPATH/../models"`
setenv SCRIPTSROOT `readlink -f "$MYPATH/../scripts"`
