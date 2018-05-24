#!/bin/csh -f

cd $NAMELIST_DST_DIR

set basedate_num = `echo $RUN_START_DATE | sed -e 's/-//g'`  

if !(-d $DATA_DST_DIR/input_data) mkdir -p $DATA_DST_DIR/input_data
if !(-d $DATA_DST_DIR/input_data/start) mkdir -p $DATA_DST_DIR/input_data/start
if !(-d $DATA_DST_DIR/output_data) mkdir -p $DATA_DST_DIR/output_data
if !(-d $DATA_DST_DIR/output_data/restart) mkdir -p $DATA_DST_DIR/output_data/restart

set start_year = `echo $RUN_START_DATE | awk -F '-' '{print $1}'`
set start_month = `echo $RUN_START_DATE | awk -F '-' '{print $2}'`
set start_day = `echo $RUN_START_DATE | awk -F '-' '{print $3}'`
@ start_hour_num = $RUN_START_SECOND / 3600
@ start_minute_num = ( $RUN_START_SECOND / 60 ) % 60
@ start_second_num = $RUN_START_SECOND % 60
set start_hour = "$start_hour_num"
set start_minute = "$start_minute_num"
set start_second = "$start_second_num"
if ( $start_hour_num < 10 ) set start_hour = "0$start_hour_num"
if ( $start_minute_num < 10 ) set start_minute = "0$start_minute_num"
if ( $start_second_num < 10 ) set start_second = "0$start_second_num"

link_data "$DATA_SRC_DIR/China_region/climatic/bc" "$DATA_DST_DIR/input_data/"
link_data "$DATA_SRC_DIR/China_region/climatic/csurf-bndry" "$DATA_DST_DIR/input_data/"
link_data "$DATA_SRC_DIR/China_region/climatic/initial" "$DATA_DST_DIR/input_data/"
link_data "$DATA_SRC_DIR/China_region/realtime/$start_year$start_month$start_day$start_hour/tide" "$DATA_DST_DIR/input_data/"
link_data "$DATA_SRC_DIR/China_region/realtime/$start_year$start_month$start_day$start_hour/wind" "$DATA_DST_DIR/input_data/"
link_data "$DATA_SRC_DIR/China_region/realtime/$start_year$start_month$start_day$start_hour/start/PomK.res.$start_year$start_month$start_day-$start_hour$start_minute$start_second.nc" "$DATA_DST_DIR/input_data/start"


cat >! runsetocean.dat << EOF
!==============================================================================!
!   INPUT FILE FOR PARAMETERS CONTROLLING EXECUTION OF wave                    !
!   DESCRIPTION OF VARIABLES AND SUGGESTED PARAMETERS CAN BE FOUND AT BOTTOM   !
!                                                                              !
!        FORMAT:			                                       !
!       1.) VARIABLE  = VALUE  (EQUAL SIGN MUST BE USED)                       !
!       2.) FLOATING POINT VARIABLES MUST CONTAIN A PERIOD "." EX: 1.3, 2.,etc !
!       3.) BLANK LINES ARE IGNORED AS ARE LINES BEGINNING WITH ! (F90 COMMENT)!
!       4.) COMMENTS CAN FOLLOW VALUES IF MARKED BY !                          !
!       5.) ORDER OF VARIABLES IS NOT IMPORTANT                                !
!       6.) FOR MULTIPLE VALUE VARIABLES FIRST ENTRY IS NUMBER OF VARIABLES    !
!           TO FOLLOW (OR 0 IF NONE)                                           !
!       7.) DO NOT USE COMMAS TO SEPARATE VARIABLES                            !
!       8.) DO NOT EXCEED EIGHTY CHARACTERS PER LINE                           !
!       9.) FOR LINE CONTINUATION ADD \\\\ TO END OF LINE TO FORCE CONTINUE      !
!           TO NEXT LINE.  MAXIMUM 4 CONTINUATIONS                             !
!       10.) TRUE = T, FALSE = F                                               !
!                                                                              ! 
!  THE PREVIOUS FORMAT OF "VARIABLE: VALUE" IS NO LONGER VALID                 !
!  THE MORE ATTRACTIVE " = " FORMAT WAS SUGGESTED BY Hernan G. Arango          !
!    AND SUBSEQUENTLY ADOPTED                                                  !
!==============================================================================!


!============ Case Title========================================================

ModelVersion =  PomK  !maximum number of character is 80  
RunType = $RUN_TYPE
Initial_DataFile = PomK.res.$start_year$start_month$start_day-$start_hour$start_minute$start_second.nc
INPUT = ./input_data/
OUTPUT = ./output_data/
!=========Parameters of model region============================================
GRID = 0.04166666666666666667 
LON = 105. 135.
LAT = 15. 41. 
SIGMA_LAYER = 30
!=========INITIAL DATA OF TEMPERATRUE AND SALINITY==============================
INITIAL_TS = T     !TRUE(T) MEAN THAT INITIAL DATA OF TEMPERATRUE AND SALINITY
                   !ARE PREPARED, OR NOT 
!=========Parameters controlling parallel size of CPU===========================
NUMX = $num_x_proc
NUMY = $num_y_proc
!========CONTROL TIME===========================================================
ISPLIT = 30
TIME_STEP = 4.  !units is second #DTE's value
REAL_TIME = T    !IF T respresent that the forcing data is real time,or climate
START_TIME = $RUN_START_DATE ${start_hour}:${start_minute}:${start_second}
                 !start run time example: yyyy-mm-dd HH:MM:SS
RUN_TIME = -70   !IF minus units is hour,IF plus units is day. 
                 !BUT all must be integer
!========CONTROL OUTFILE DATA====+=============================================
INTERVAL_OUT = 1          ! units hour
INTERVAL_RESTART = 24     ! units hour
#OUT_DATA_NAME = ctime bv windx windy hs tp tz th
OUT_DATA_FIG =  T     T  T     T     T  T  T  T   
                                 ! OUT_DATA_FIG respresent that each OUT_DATA_NAME 
                                 ! is or not exproted. T is exporting, F is Not
!========CONTROL FORCE DATA=======+============================================
! units is hour
INTERVAL_FORCING = 1
!=======CONTROL TIDE ==========================================================
TIDETYPE = T
!=======CONTROL ISPADV ========================================================
ISPADV = 5
!=======CONTROL WIND STRESS ===================================================
WINDTYPE = F  !IF WINDTYPE IS T MEANS THAT USING CLIMATIC WIND STRESS
              !IF WINDTYPE IS F MEANS THAT USING REAL TIME WIND STRESS
!=======CONTROL HEAT FLUX   ===================================================
HEATTYPE = F  !IF HEATTYPE IS T MEANS THAT USING CLIMATIC HEAT FLUX
              !IF HEATTYPE IS F MEANS THAT USING REAL TIME HEAT FLUX 
!=======CONTROL MODEL =========================================================
MODE = 3      !MODE = 2; 2-D CALCULATION (BOTTOM STRESS CALCULATED IN ADVAVE)
              !       3; 3-D CALCULATION (BOTTOM STRESS CALCULATED IN PROFU,V)
              !       4; 3-D CALCULATION WITH T AND S HELD FIXED
!========THE VERTICAL SIGMA GRID===============================================
! UNITS M
ZSS = 0. 10. 20. 30. 50. 75. 100. 125. 150. 200. 250.        \\\\ 
      300. 400. 500. 600. 700. 800. 900. 1000. 1100. 1200.   \\\\
      1300. 1400. 1500. 1750. 2000. 2500. 3000. 3500. 4000. 
EOF
