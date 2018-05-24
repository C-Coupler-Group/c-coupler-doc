#!/bin/csh -f

# === Note by Li Ruizhe ===
# Required paramters:
#   NAMELIST_DST_DIR
#   DATA_DST_DIR
#   DATA_SRC_DIR
#
#   RUNTYPE
#   GRID
#   RUN_REFCASE
#   RUN_START_DATE
#   RAMP_CO2_START_YMD
#   DOUT_L_MSNAME
# =========================

set called=($_)
if ("$called" != "") then
    set me = "$called[2]"    # the script was sourced from this location
endif
if ("$0" != "csh") then
    set me = "$0"                # the script was run from this location
endif
set me = `readlink -f $me`
set MYPATH = `dirname "$me"`

cd $NAMELIST_DST_DIR

cp $CODEROOT/demo/coupling_connections_demo/ocn_demo2/*.nc .
cp $CODEROOT/demo/coupling_connections_demo/ocn_demo2/*.nml .

