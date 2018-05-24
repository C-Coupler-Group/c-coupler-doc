#!/bin/bash

function replace_xml_entry
{
    sed -i "s#\(<entry\s*id=\"$2\"\s*value=\"\)[^\"]*\(.*\)#\1$3\2#g" $1
}

function config_diff
{
    config_value=$(cat "$1"|grep "^\s*$2\s*="| sed "s#^\s*$2\s*=\s*\(.*\)\$#\1#g")
	test "$config_value" = "$3"
}

function check_cesm_config
{
	config_diff "$1" "run_type" "$RUN_TYPE" && \
	config_diff "$1" "run_start_date" "$RUN_START_DATE" && \
	config_diff "$1" "run_start_second" "$RUN_START_SECOND" && \
	config_diff "$1" "run_stop_second" "$RUN_STOP_SECOND" && \
	config_diff "$1" "run_stop_date" "$RUN_STOP_DATE" && \
	config_diff "$1" "run_restart_date" "$RUN_RESTART_DATE" && \
	config_diff "$1" "run_restart_second" "$RUN_RESTART_SECOND" && \
	config_diff "$1" "rest_freq_unit" "$REST_FREQ_UNIT" && \
	config_diff "$1" "rest_freq_count" "$REST_FREQ_COUNT" && \
	config_diff "$1" "leap_year" "$LEAP_YEAR" && \
	config_diff "$1" "original_case_name" "$ORIGINAL_CASE_NAME"
}

# == Get the path of this script ==
MYPATH=$(readlink -f "$0")
MYPATH=$(dirname "$MYPATH")
# =================================

cd $MYPATH/cesm_case_scripts

if [ ! -e "./.env_run.xml" ]; then
    cp -f env_run.xml .env_run.xml
fi

if [ -e "logs/bld/" ]; then
    rm -f logs/bld/*
fi

if [ ! -e "$COMP_RUN_DATA_DIR/timing" ]; then
    mkdir $COMP_RUN_DATA_DIR/timing
fi

sed -i "s#entry id *= *\"CASE\" *value *=.*#entry id=\"CASE\"   value = \"$CASE_NAME\" \/\>#" env_case.xml
sed -i "s#entry id *= *\"CASEROOT\" *value *=.*#entry id=\"CASEROOT\"   value = \"$MYPATH/cesm_case_scripts/\" \/\>#" env_case.xml
sed -i "s#entry id *= *\"CCSMROOT\" *value *=.*#entry id=\"CCSMROOT\"   value = \"$CODEROOT/cesm/$MODEL_REALNAME/\" \/\>#" env_case.xml
sed -i "s#entry id *= *\"CCSM_MACHDIR\" *value *=.*#entry id=\"CCSM_MACHDIR\"   value = \"$CODEROOT/cesm/$MODEL_REALNAME/scripts/ccsm_utils/Machines/\" \/\>#" env_case.xml

cp -f env_case.xml LockedFiles/env_case.xml.locked

cp -f .env_run.xml env_run.xml
sed -i "s#CCPL_DATAROOT#$DATAROOT#" env_run.xml
sed -i "s#entry id *= *\"RUNDIR\" *value *=.*#entry id=\"RUNDIR\"   value = \"$COMP_RUN_DATA_DIR/\" \/\>#" env_build.xml
sed -i "s#entry id *= *\"EXEROOT\" *value *=.*#entry id=\"EXEROOT\"   value=\"$COMP_RUN_DATA_DIR/../cesm_bld\"  \/\>    #" env_build.xml
rm -f LockedFiles/env_build.xml.locked

change_files_name $PREVIOUS_CASE_NAME\. $CASE_NAME\.


rewrite_config=1
if [ -f $MYPATH/../../common/.original.case.conf ]; then
    if check_cesm_config "$MYPATH/../../common/.original.case.conf"; then
        rewrite_config=0
    else
        rm -f $MYPATH/../../common/.original.case.conf
    fi
fi

if [ $rewrite_config = 1 ]; then
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_STARTDATE" "$RUN_START_DATE"
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "START_TOD" "$RUN_START_SECOND"
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_REFDATE" "$RUN_RESTART_DATE"
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_REFTOD" "$RUN_RESTART_SECOND"
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_REFCASE" "$ORIGINAL_CASE_NAME"
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "CONTINUE_RUN" "FALSE"
    if [ "$RUN_TYPE" = "initial" ]; then
        replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_TYPE" "startup"
    elif [ "$RUN_TYPE" = "restart" ]; then 
        if [ "$CONTINUE_RUN" = "false" ]; then 
            replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_TYPE" "branch"
        else
            ./xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
            replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_REFCASE" "$CASE_NAME"
            replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "BRNCH_RETAIN_CASENAME" "TRUE"
#        replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_TYPE" "branch"
#        replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "CONTINUE_RUN" "TRUE"
        fi
    elif [ "$RUN_TYPE" = "hybrid" ]; then 
        replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "RUN_TYPE" "hybrid"
    fi
    if [ $[RUN_STOP_SECOND] != 0 ]; then
        echo
        echo
        echo "ERROR!!!!! The RUN_STOP_SECOND must be 0 when the compset uses the CESM as a component.  Please check. "
        echo "***ERROR*** The RUN_STOP_SECOND must be 0 when the compset uses the CESM as a component.  Please check. "   >> $CONFIG_LOG_FILE
        echo
        echo
    fi
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "STOP_OPTION" "date"
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "STOP_DATE" $(echo $RUN_STOP_DATE|sed 's/-//g')
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "REST_OPTION" $(echo "n$REST_FREQ_UNIT")
    replace_xml_entry $MYPATH/cesm_case_scripts/env_run.xml "REST_N" "$REST_FREQ_COUNT"
    if [ "$LEAP_YEAR" = "false" ]; then
        replace_xml_entry $MYPATH/cesm_case_scripts/env_build.xml "CALENDAR" "NO_LEAP"
    else
        replace_xml_entry $MYPATH/cesm_case_scripts/env_build.xml "CALENDAR" "GREGORIAN"
    fi
fi


if [ -e LockedFiles/env_mach_pes.xml.locked ]; then
if ! diff env_mach_pes.xml LockedFiles/env_mach_pes.xml.locked > /dev/null ; then
    ./configure -cleanall >> cesm_configure.log
fi
fi

./configure -case >> cesm_configure.log


if [ $rewrite_config = 1 ]; then
    sed -i "s#orb_iyear .*=.*# orb_iyear = $ORBYEAR#" CaseDocs/drv_in
    sed -i "s#orb_iyear_align.*=.*# orb_iyear_align = $ORBYEAR#" CaseDocs/drv_in
    sed -i "s#orb_iyear *=.*# orb_iyear = $ORBYEAR#" $DATA_DST_DIR/drv_in
    sed -i "s#orb_iyear_align.*=.*# orb_iyear_align = $ORBYEAR#" $DATA_DST_DIR/drv_in

    sed -i "s#setenv LID.*#setenv LID \"$configuration_time\"#" $CASE_NAME.CCPL.build 
fi

link_cesm_data

cesm_pes=$(cat env_mach_pes.xml|grep "<entry.*id=\"TOTALPES"|sed 's#<entry\s*id="TOTALPES"\s*value="\([0-9]*\)".*$#\1#g')
echo "process number is $cesm_pes" > /tmp/${MODEL_REALNAME}_pes


cd ${CASEROOT}
find ./ -name "seq_maps.rc" > .temp_file_list
while read line
do
    sed -i "s/'Y'/'X'/g" $line 
done < .temp_file_list
rm .temp_file_list


