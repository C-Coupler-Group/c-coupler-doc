#!/bin/csh -f

# === Written by Dr. Li Liu ===
# =========================

cd $NAMELIST_DST_DIR

set basedate_num = `echo $RUN_START_DATE | sed -e 's/-//g'`  

mkdir $basedate_num

cat >! ${MODEL_NAME}.stdin << EOF
$DATA_SRC_DIR/china.cur/
./
$basedate_num
1
$num_y_proc
$num_x_proc
EOF
