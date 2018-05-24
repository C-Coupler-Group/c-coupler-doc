#!/bin/bash

function get_xml_entry
{
   cat "$1"|grep "<entry.*id=\"$2\""|sed "s#<entry\s*id=\"$2\"\s*value=\"\([^\"]*\).*#\1#g"
}

source "$SCRIPTSROOT/utils/common"
source "$SCRIPTSROOT/utils/hashtable"
source $1

if [ "$CESM_RES" = "" ]; then
    report_logs "ERROR" "Environment variable CESM_RES (the label of resolution for the CESM simulation) must be specified in the input parameter file. Please verify."
    exit 1
fi

if [ "$CESM_COMPSET" = "" ]; then
    report_logs "ERROR" "Environment variable CESM_COMPSET (the label of compset for the CESM simulation) must be specified in the input parameter file. Please verify."
    exit 1
fi

path=${CODEROOT}/cesm/cesm1_2_1/scripts
CASENAME=$(basename "$CASEROOT")
pushd $path >& /dev/null
echo -e "./create_newcase -case $CASEROOT/config/cesm/cesm/$CASENAME -res $CESM_RES -compset $CESM_COMPSET -mach CCPL\n\n\n" > "${CASEROOT}/config/common/CESM_case_creation.log"
./create_newcase -case $CASEROOT/config/cesm/cesm/$CASENAME -res $CESM_RES -compset $CESM_COMPSET -mach CCPL >> "${CASEROOT}/config/common/CESM_case_creation.log"
mv $CASEROOT/config/cesm/cesm/$CASENAME $CASEROOT/config/cesm/cesm/cesm_case_scripts 
report_logs "NOTICE" "The experiment model \"$COMPSET\" for this new simulation consists of the CESM model version CESM1_2_1. The log information for creating the corresponding CESM case is recorded in file ${CASEROOT}/config/common/CESM_case_creation.log"
popd > /dev/null 2>&1


echo "total_num_comp is $total_num_components"
if [ ${total_num_components} == 1 ]; then
    run_type_="$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml RUN_TYPE)"
    continue_="$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml CONTINUE_RUN)"
        if [ "$continue_" == "TRUE"    ]; then
        hash_put "common_param" "run_type" "continue"
    elif [ "$run_type_" == "startup" ]; then
        hash_put "common_param" "run_type" "initial"
    elif [ "$run_type_" == "branch" ]; then
        hash_put "common_param" "run_type" "restart"
    elif [ "$run_type_" == "hybrid" ]; then
        hash_put "common_param" "run_type" "hybrid"
    fi
    hash_put "common_param" "run_start_date" "$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml RUN_STARTDATE)"
    hash_put "common_param" "run_start_second" "$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml START_TOD)"
    hash_put "common_param" "original_case_name" "$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml RUN_REFCASE)"
    hash_put "common_param" "run_restart_date" "$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml RUN_REFDATE)"
    hash_put "common_param" "run_restart_second" "$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml RUN_REFTOD)"
    hash_put "common_param" "run_stop_date" "9999-12-31"
    hash_put "common_param" "run_stop_second" "00000"
    STOP_OPTION="$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml STOP_OPTION)"
        if [ "$STOP_OPTION" == "date" ]; then
       hash_put "common_param" "run_stop_date" "$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_run.xml STOP_DATE)"
        fi
    leap_year_=$(get_xml_entry $CASEROOT/config/cesm/cesm/cesm_case_scripts/env_build.xml CALENDAR) 
    if [ "$leap_year_" == "NO_LEAP" ]; then
        hash_put "common_param" "leap_year" "false"
    elif [ "$leap_year_" = "GREGORIAN" ]; then
        hash_put "common_param" "leap_year" "true"
    fi
fi


exit 0
