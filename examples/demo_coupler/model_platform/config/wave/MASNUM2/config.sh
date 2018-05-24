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

link_data "$DATA_SRC_DIR/China_region/topo/WaveK_topo.nc" "$DATA_DST_DIR/input_data/"
link_data "$DATA_SRC_DIR/China_region/realtime/$start_year$start_month$start_day$start_hour/wind/wind$start_year$start_month$start_day$start_hour.nc" "$DATA_DST_DIR/input_data/"
link_data "$DATA_SRC_DIR/China_region/realtime/$start_year$start_month$start_day$start_hour/start/WaveK.res.$start_year$start_month$start_day-$start_hour$start_minute$start_second.nc" "$DATA_DST_DIR/input_data/start"

cat >! runset.dat << EOF

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

!maximum number of ModelVersion character is 80

ModelVersion = WaveK
RunType = $RUN_TYPE
Initial_DataFile = WaveK.res.$start_year$start_month$start_day-$start_hour$start_minute$start_second.nc

!============ PATH OF INPUT AND OUTPUT =========================================
!mximum number of INPUT AND OUTPUT character is 80
INPUT = input_data/
OUTPUT = output_data/

!=========Parameters of model region============================================

GRID = 0.04166666666666666667
! maximum lon 360. minimum lon 0.
LON = 105. 135. 
LAT = 15. 41. 

!=========Parameters controlling parallel size of CPU===========================

NUMX = $num_x_proc
NUMY = $num_y_proc

!========CONTROL TIME===========================================================

TIME_STEP = 2.  !units is minute
REAL_TIME = T    !IF T respresent that the forcing data is real time,or climate
START_TIME = $RUN_START_DATE ${start_hour}:${start_minute}:${start_second}
                 !start run time example: yyyy-mm-dd HH:MM:SS
RUN_TIME = -73  !IF minus units is hour,IF plus units is day. 
                 !BUT all must be integer

!========CONTROL OUTFILE DATA===================================================

! units is hour
INTERVAL_OUT = 1 
! units is hour
INTERVAL_RESTART = 120
#OUT_DATA_NAME = ctime bv windx windy hs tp tz th
OUT_DATA_FIG =  T     F  T     T     T  T  T  T   
                                 ! OUT_DATA_FIG respresent that each OUT_DATA_NAME 
                                 ! is or not exproted. T is exporting, F is Not

!========CONTROL FORCE DATA====================================================

FORCING_NAME = windu windv datatime
! units is hour
INTERVAL_FORCING = 1 

!=========Standard Depth Levels=================================================

KSL    =  40
DEPTHSL =  0. 2.5 5. 7.5 10. 15. 20. 25. 30. 35. 40. 45. 50. 60. 70. 80. 90. \\\\
100. 110. 120. 130. 140. 150. 160. 170. 180. 190. 200. 225. 250. 275. 300.  \\\\
325. 350. 375. 400. 450. 500. 750. 1000.

EOF
