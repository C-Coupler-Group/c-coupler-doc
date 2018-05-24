#! /bin/csh -f
##################################################################################
#  Copyright (c) 2013, Tsinghua University. 
#  This code is initially finished by Dr. Li Liu on 2013/3/21. 
#  If you have any problem, please contact:
#  Dr. Li Liu via liuli-cess@tsinghua.edu.cn
##################################################################################



set START_DATE = `echo $RUN_START_DATE | sed -e 's/-//g'`
set STOP_DATE = `echo $RUN_STOP_DATE | sed -e 's/-//g'`
if ($RUN_TYPE == "restart" || $RUN_TYPE == "hybrid") then
  set RESTART_DATE = `echo $RUN_RESTART_DATE | sed -e 's/-//g'`
endif

if ($LEAP_YEAR == 'true') then
   set local_leap_year = '.true.' 
else if ($LEAP_YEAR == 'false') then 
   set local_leap_year = '.false.'
else
   set local_leap_year = 'wrong'
endif

cat >! $RUN_ALL_DIR/${MODEL_NAME}.nml << EOF
&compset_nml
  exp_model               = "$COMPSET"
  case_name               = "$CASE_NAME"
  case_desc               = "$CASE_NAME : $CASE_DESC, did configuration at $CONFIGURATION_TIME"
  config_time             = "$CONFIGURATION_TIME"
  run_type                = "$RUN_TYPE"
  start_date              = $START_DATE
  start_second            = $RUN_START_SECOND
  stop_date               = $STOP_DATE
  stop_second             = $RUN_STOP_SECOND
  rest_freq_unit          = "$REST_FREQ_UNIT"
  rest_freq_count         = $REST_FREQ_COUNT
  stop_latency_seconds    = $STOP_LATENCY_SECONDS
  component_name          = "$MODEL_NAME"
  compset_filename        = "comp_list.cfg"
  comp_run_data_dir       = "$COMP_RUN_DATA_DIR"
  comp_model_nml          = "$COMP_MODEL_NML"
  cpl_interface_time_step = $CPL_INTERFACE_TIME_STEP
  comp_log_filename       = "$COMP_LOG_FILENAME"
  leap_year               = $local_leap_year
EOF


if ( $?RUN_REFERENCE_DATE ) then
   set REFERENCE_DATE = `echo $RUN_REFERENCE_DATE | sed -e 's/-//g'`
cat >> $RUN_ALL_DIR/${MODEL_NAME}.nml << EOF1
  reference_date          = $REFERENCE_DATE
EOF1
endif


if ($RUN_TYPE == "restart" || $RUN_TYPE == "hybrid") then
  set restart_read_file = ${COMP_RUN_DATA_DIR}/${ORIGINAL_CASE_NAME}.${MODEL_NAME}.restart.${RESTART_DATE}00000.nc
cat >> $RUN_ALL_DIR/${MODEL_NAME}.nml << eof1
  original_case_name      = "$ORIGINAL_CASE_NAME"
  restart_read_file       = "$restart_read_file"
  restart_date            = $RESTART_DATE
  restart_second          = $RUN_RESTART_SECOND
  original_config_time    = $ORIGINAL_CONFIG_TIME
eof1
endif

cat >> $RUN_ALL_DIR/${MODEL_NAME}.nml << EOF1
/
EOF1

cat >> $RUN_ALL_DIR/${MODEL_NAME}.nml << EOF1

&orb_nml
EOF1

if ( $?ORBYEAR ) then
cat >> $RUN_ALL_DIR/${MODEL_NAME}.nml << EOF1
  iyear_AD                = $ORBYEAR
EOF1
endif

cat >> $RUN_ALL_DIR/${MODEL_NAME}.nml << EOF1
/
EOF1

cat >> $RUN_ALL_DIR/${MODEL_NAME}.nml << EOF1
&ensemble_setting_nml
  ensemble_member_id             = $ENSEMBLE_IDX
  random_seed_for_perturb_roundoff_errors = -9999
  roundoff_errors_perturbation_type = "none"
/
EOF1

