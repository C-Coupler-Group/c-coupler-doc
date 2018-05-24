#! /bin/csh -f

# started as a $RUN_TYPE run

set exedir = ${DATA_DST_DIR}
cd $exedir

set ATM_GRID = '128x60'

link_data ${DATA_SRC_DIR}/${ATM_GRID}/CoLM-${ATM_GRID}-const  ${DATA_DST_DIR}/
link_data ${DATA_SRC_DIR}/${ATM_GRID}/CoLM-${ATM_GRID}-restart  ${DATA_DST_DIR}/
link_data ${DATA_SRC_DIR}/${ATM_GRID}/CoLM-${ATM_GRID}-gridata  ${DATA_DST_DIR}/
link_data ${DATA_SRC_DIR}/${ATM_GRID}/CoLM-${ATM_GRID}-sbcini  ${DATA_DST_DIR}/
link_data ${DATA_SRC_DIR}/rtmdata/rdirc.05 ${DATA_DST_DIR}/

if ($RUN_TYPE == 'restart') then
   set nsrest   = '1'
   set frestart = "$exedir/${ORIGINAL_CASE_NAME}.CoLM-${ATM_GRID}-restart-$RUN_RESTART_DATE-$RUN_RESTART_SECOND"
else
   set nsrest   = '0'
   set frestart = "CoLM-${ATM_GRID}-restart"
endif


cat >! ${MODEL_NAME}.stdin << EOF
 &clmexp
 site           = '$CASE_NAME'
 nsrest         = $nsrest
 fgrid          = 'CoLM-${ATM_GRID}-gridata'
 fsbcini        = 'CoLM-${ATM_GRID}-sbcini'
 flai           = ''
 fmet           = ''
 fout           = '$exedir/${CASE_NAME}.CoLM-${ATM_GRID}'
 fconst         = 'CoLM-${ATM_GRID}-const'
 frestart       = '$frestart'
 frivinp_rtm    = 'rdirc.05'
 lon_points     = 128
 lat_points     = 60
 numcolumn      = 4801
 numpatch       = 42497
 mstep          = 150000
 dtime          = 1800.00000000000     
 /
EOF

