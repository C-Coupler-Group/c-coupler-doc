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

cd $NAMELIST_DST_DIR

create_symbol_copy $CODEROOT/atm_chem/GIGC/Code.v9-02/ $DATA_DST_DIR/../GIGC_code_mirror > /dev/null

set basedate_num = `echo $RUN_START_DATE | sed -e 's/-//g'`  

set start_year = `echo $RUN_START_DATE | awk -F '-' '{print $1}'`
set start_month = `echo $RUN_START_DATE | awk -F '-' '{print $2}'`
set start_day = `echo $RUN_START_DATE | awk -F '-' '{print $3}'`
set stop_year = `echo $RUN_STOP_DATE | awk -F '-' '{print $1}'`
set stop_month = `echo $RUN_STOP_DATE | awk -F '-' '{print $2}'`
set stop_day = `echo $RUN_STOP_DATE | awk -F '-' '{print $3}'`
@ start_hour_num = $RUN_START_SECOND / 3600
@ start_minute_num = ( $RUN_START_SECOND / 60 ) % 60
@ start_second_num = $RUN_START_SECOND % 60
set start_hour = "$start_hour_num"
set start_minute = "$start_minute_num"
set start_second = "$start_second_num"
if ( $start_hour_num < 10 ) set start_hour = "0$start_hour_num"
if ( $start_minute_num < 10 ) set start_minute = "0$start_minute_num"
if ( $start_second_num < 10 ) set start_second = "0$start_second_num"
@ stop_hour_num = $RUN_STOP_SECOND / 3600
@ stop_minute_num = ( $RUN_STOP_SECOND / 60 ) % 60
@ stop_second_num = $RUN_STOP_SECOND % 60
set stop_hour = "$stop_hour_num"
set stop_minute = "$stop_minute_num"
set stop_second = "$stop_second_num"
if ( $stop_hour_num < 10 ) set stop_hour = "0$stop_hour_num"
if ( $stop_minute_num < 10 ) set stop_minute = "0$stop_minute_num"
if ( $stop_second_num < 10 ) set stop_second = "0$stop_second_num"


cp -f $COMPONENT_CONFIG_ROOT/namelists/input.geos.template input.geos
cp -f $COMPONENT_CONFIG_ROOT/namelists/ratj.d ./
cp -f $COMPONENT_CONFIG_ROOT/namelists/*.dat ./

sed -i -e "s/Start.*/Start YYYYMMDD, HHMMSS  : $start_year$start_month$start_day $start_hour$start_minute$start_second/g" input.geos
sed -i -e "s/End.*/End   YYYYMMDD, HHMMSS  : $stop_year$stop_month$stop_day $stop_hour$stop_minute$stop_second/g" input.geos

set ROOT_DATA      = "GEOS_4x5"
set EMISSION_DATA  = "GEOS_1x1"
set OH_DATA        = "GEOS_MEAN/OHmerge/v5-07-08"
set O3_DATA        = "GEOS_MEAN/O3_PROD_LOSS/2003.v6-01-05"
mkdir -p GEOS_MEAN/OHmerge
mkdir -p GEOS_MEAN/O3_PROD_LOSS/

sed -i -e "s#Root data directory.*#Root data directory     : $DATA_DST_DIR/$ROOT_DATA/#g" input.geos
sed -i -e "s#Dir w/ 1x1 emissions etc.*#Dir w/ 1x1 emissions etc: $DATA_DST_DIR/$EMISSION_DATA/#g" input.geos
sed -i -e "s#Dir w/ archived OH files.*#Dir w/ archived OH files: $DATA_DST_DIR/$OH_DATA/#g" input.geos
sed -i -e "s#Dir w/ O3 P/L rate files.*#Dir w/ O3 P/L rate files: $DATA_DST_DIR/$O3_DATA/#g" input.geos

#link_data "$DATA_SRC_DIR/$ROOT_DATA" "$DATA_DST_DIR/"
#link_data "$DATA_SRC_DIR/$EMISSION_DATA" "$DATA_DST_DIR/"
#link_data "$DATA_SRC_DIR/$OH_DATA" "$DATA_DST_DIR/GEOS_MEAN/OHmerge"
#link_data "$DATA_SRC_DIR/$O3_DATA" "$DATA_DST_DIR/GEOS_MEAN/O3_PROD_LOSS/"



