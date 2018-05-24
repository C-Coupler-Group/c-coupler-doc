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

# --- set grid related variables
if ($GRID =~ 128x60*)     set params = (128  60 26 .true. 1200)
if ($GRID =~ 360x180*)     set params = (360  180 26 .true. 60)

# --- set grid resolution variables
set plon =  $params[1]; set plat = $params[2] ; set plev = $params[3]

#--- set namelist parameters dependent on grid resolution
set flxave = $params[4]

set bndtvo    = ozone/Ozone_CMIP5_ACC_SPARC_1850-2099_RCP2.6_T3M_O3.nc
set absdata   = radiation/abs_ems_factors_fastvx.052001.nc
set bndtvaer  = aerosol/Aerosol1850-2105RCP26gamil_55.nc
set datinit   = boundary_condition/new.si.ts.gamil.i.0011-01-01-00000.nc

link_data "$DATA_SRC_DIR/$bndtvo" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/$absdata" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/$bndtvaer" "$DATA_DST_DIR/"
link_data "$DATA_SRC_DIR/$datinit" "$DATA_DST_DIR"

set nsrest = 0
if ($RUN_TYPE == 'restart') set nsrest = 1

cat >! ${MODEL_NAME}.stdin << EOF
 &atmexp
 caseid      = '$CASE_NAME'
!PUYE brnch_retain_casename = .true.
 ncdata      = '$datinit'
 nsrest      = $nsrest
 absems_data = '$absdata'
 iyear_AD    =  1990
 linebuf     = .false.
 flxave      =  $flxave
 mss_irt     =  0
 bndtvo      = '$bndtvo'
 bndtvaer    = '$bndtvaer'
 num_x_proc  = $num_x_proc
 num_y_proc  = $num_y_proc
!add by PUYE
 co2vmr      = 2.84e-4
 n2ovmr      = 0.275e-6
 ch4vmr      = 0.79e-6
 f11vmr      = 0.0
 f12vmr      = 0.0
 scon        =1.365e6
 /
EOF
