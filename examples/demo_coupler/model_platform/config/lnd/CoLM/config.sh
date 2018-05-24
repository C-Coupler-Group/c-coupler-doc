#! /bin/csh -f

# started as a $RUN_TYPE run

set exedir = ${DATA_DST_DIR}
cd $exedir

set ATM_GRID = '128x60'

link_data ${DATA_SRC_DIR}/inidata/colm_sole.one_cell.33.1_57.6-Const ${DATA_DST_DIR}/
link_data ${DATA_SRC_DIR}/inidata/colm_sole.one_cell.33.1_57.6-Init-1966-001-00000 ${DATA_DST_DIR}/
link_data ${DATA_SRC_DIR}/forcedata/VAL.DAT.CTRL.INT ${DATA_DST_DIR}/

cat >! ${MODEL_NAME}.stdin << EOF
 &clmexp
 site           = '$CASE_NAME'
 flaidat        = ''
 fmetdat        = 'VAL.DAT.CTRL.INT'
 fconst         = 'colm_sole.one_cell.33.1_57.6-Const'
 frestart       = 'colm_sole.one_cell.33.1_57.6-Init-1966-001-00000'
 foutdat        = '$CASE_NAME'
 luconst        =          150
 lurestart      =          160
 lulai          =          120
 lumet          =          140
 luhistory      =          170
 lon_points     =            1
 lat_points     =            1
 numpatch       =            2
 mstep          =       315552
 deltim         =    1800.00000000000     
 /
EOF

