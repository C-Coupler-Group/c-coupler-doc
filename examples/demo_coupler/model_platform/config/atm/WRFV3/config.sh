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


set start_year = `echo $RUN_START_DATE | awk -F '-' '{print $1}'`
set start_month = `echo $RUN_START_DATE | awk -F '-' '{print $2}'`
set start_day = `echo $RUN_START_DATE | awk -F '-' '{print $3}'`
set stop_year = `echo $RUN_STOP_DATE | awk -F '-' '{print $1}'`
set stop_month = `echo $RUN_STOP_DATE | awk -F '-' '{print $2}'`
set stop_day = `echo $RUN_STOP_DATE | awk -F '-' '{print $3}'`
@ start_hour = $RUN_START_SECOND / 3600
@ start_minute = ( $RUN_START_SECOND / 60 ) % 60
@ start_second = $RUN_START_SECOND % 60
@ stop_hour = $RUN_STOP_SECOND / 3600
@ stop_minute = ( $RUN_STOP_SECOND / 60 ) % 60
@ stop_second = $RUN_STOP_SECOND % 60

set restart = .false.
if ($RUN_TYPE == 'restart') then
    set restart = .true.
endif

cp $MYPATH/namelist.input namelist.input
$MYPATH/set_namelist start_year "$start_year"
$MYPATH/set_namelist start_year "$start_year"
$MYPATH/set_namelist start_year "$start_year"
$MYPATH/set_namelist start_month "$start_month"
$MYPATH/set_namelist start_day "$start_day"
$MYPATH/set_namelist start_hour "$start_hour"
$MYPATH/set_namelist start_minute "$start_minute"
$MYPATH/set_namelist start_second "$start_second"
$MYPATH/set_namelist end_year "$stop_year"
$MYPATH/set_namelist end_month "$stop_month"
$MYPATH/set_namelist end_day "$stop_day"
$MYPATH/set_namelist end_hour "$stop_hour"
$MYPATH/set_namelist end_minute "$stop_minute"
$MYPATH/set_namelist end_second "$stop_second"
$MYPATH/set_namelist restart "$restart"

if ($BYPASS_CONFIGURATION == 'FALSE') then
    create_symbol_copy $CODEROOT/atm/WRF3.6/WRFV3 $DATA_DST_DIR/../WRFV3 > /dev/null
    unlink $DATA_DST_DIR/../WRFV3/configure > /dev/null
    unlink $DATA_DST_DIR/../WRFV3/compile > /dev/null
    cp $CODEROOT/atm/WRF3.6/WRFV3/configure $DATA_DST_DIR/../WRFV3/
    cp $CODEROOT/atm/WRF3.6/WRFV3/compile $DATA_DST_DIR/../WRFV3/
    cd $DATA_DST_DIR/../WRFV3
    echo "*****************************"
    echo "configure WRF now"
    ./configure
    echo "configuration for WRF ends"
    echo "*****************************"
endif

set basedate_num = `echo $RUN_START_DATE | sed -e 's/-//g'`  
set bndtvo    = ozone/Ozone_CMIP5_ACC_SPARC_1850-2099_RCP2.6_T3M_O3.nc
set absdata   = radiation/abs_ems_factors_fastvx.052001.nc
set bndtvaer  = aerosol/Aerosol1850-2105RCP26gamil_55.nc
set datinit   = boundary_condition/new.si.ts.gamil.i.0011-01-01-00000.nc

link_data "$DATA_SRC_DIR/China_region/$basedate_num/GENPARM.TBL" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/China_region/$basedate_num/LANDUSE.TBL" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/China_region/$basedate_num/RRTM_DATA" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/China_region/$basedate_num/SOILPARM.TBL" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/China_region/$basedate_num/VEGPARM.TBL" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/China_region/$basedate_num/wrfbdy_d01" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/China_region/$basedate_num/wrfinput_d01" "$DATA_DST_DIR/"

