#! /bin/csh -f

# ---------------------------------------------------------------------------
#  determine input data files and resolution dependent variables
# ---------------------------------------------------------------------------
set CASESTR = $CASE_NAME

# --- set local atmosphere resolution dependent variables and surface data
if ($GRID == 'T85') then
   set atmres = '256x128'
   set lonlat = ( 256 128 )
   set dtime  =  600
   set rtm_nsteps = 18
else if ($GRID == 'T42') then
   set atmres = '128x064'
   set lonlat = ( 128 64 )
   set dtime  = 1200
   set rtm_nsteps = 9
else if ($GRID == '128x60') then
   set atmres = '128x60'
   set lonlat = ( 128 60 )
   set dtime  = 1200
   set rtm_nsteps = 9
else if ($GRID == '360x180') then
   set atmres = '360x180'
   set lonlat = ( 360 180 )
   set dtime  = 60
   set rtm_nsteps = 9
else if ($GRID == 'R42') then
   set atmres = '128x108'
   set lonlat = ( 128 108 )
   set dtime  = 1200
   set rtm_nsteps = 9
else if ($GRID == 'T31') then
   set atmres = '096x048'
   set lonlat = (  96 48 )
   set dtime  = 1800
   set rtm_nsteps = 6
else if ($GRID == '2x2.5') then
   set atmres = '144x091'
   set lonlat = ( 144 91 )
   set dtime  = 1800
   set rtm_nsteps = 6
else if ($GRID == '1x1.25') then
   set atmres = '288x181'
   set lonlat = ( 288 181 )
   set dtime  = 1800
   set rtm_nsteps = 6
else if ($GRID == '1x1.125') then
    set atmres = '320x192'
    set lonlat = ( 320 192 )
    set dtime  = 1800
    set rtm_nsteps = 6
endif

set OCN_GRID = 'eq1x1'
# --- set surface dataset
set datasurf = ""
if      ($GRID == 'T85'   && $OCN_GRID == 'gx1v3') then
   set datasurf = surface-data.256x128_atm.gx1v3_ocn.070903.nc
else if ($GRID == 'T42'   && $OCN_GRID == 'gx1v3') then
   set datasurf = surface-data.128x064_atm.gx1v3_ocn.080101.nc
else if ($GRID == 'R42'   && $OCN_GRID == 'gx1v3') then
   set datasurf = surface-data.128x108_081116.nc
else if ($GRID == '128x60'   && $OCN_GRID == 'gr1x1') then
   set datasurf = surface-data.128x060.nc
else if ($GRID == '128x60'   && $OCN_GRID == 'eq1x1') then
   set datasurf = surface-data.128x060.nc
else if ($GRID == '360x180'   && $OCN_GRID == 'eq1x1') then
   set datasurf = surface-data.360x180.nc
else if ($GRID == '360x180'   && $OCN_GRID == 'gx1v3') then
   set datasurf = surface-data.360x180_gx1v3.nc
else if ($GRID == 'R42'   && $OCN_GRID == 'gr1x1') then
   set datasurf = surface-data.128x108_ocn.gr1x1.nc
else if ($GRID == 'R42'   && $OCN_GRID == 'eq1x1') then
   set datasurf = surface-data.128x108_ocn.eq1x1.nc
else if ($GRID == 'T31'   && $OCN_GRID == 'gx3v5') then
   set datasurf = surface-data.096x048_atm.gx3v5_ocn.040209.nc
else if ($GRID == 'T31'   && $OCN_GRID == 'gx3v4') then
   set datasurf = surface-data.096x048_atm.gx3v4_ocn.nc
else if ($GRID == '2x2.5' && $OCN_GRID == 'gx1v3') then
   set datasurf = surface-data.144x091_atm.gx1v3_ocn.cpl6.nc
else if ($GRID == '1x1.25' && $OCN_GRID == 'gx1v3') then
   set datasurf = surface-data.288x181_atm.gx1v3_ocn.032505.nc
endif

# --- set initial or hybrid run initial dataset
set datainit = ""
if ($RUN_TYPE == 'initial')  then
   # if ($GRID == 'T42') set datainit = "b22.014.clm2.i.0251-01-01-00000.t42.031024.nc"
   # if ($GRID == 'T85') set datainit = "b22.014.clm2.i.0251-01-01-00000.t85.031024.nc"
endif
if ($RUN_TYPE == 'restart')  then
   set datainit = ${CASE_NAME}.clm2.i.${RUN_RESTART_DATE}-00000.nc
endif

# --- set branch run restart dataset
set nrevsn = ""

# --- set basedate_num - used for branch or hybrid runs
set basedate_num = `echo $RUN_START_DATE | sed -e 's/-//g'`  # remove "-"

# ---------------------------------------------------------------------------
#  Create resolved namelist and prestage data script
# ---------------------------------------------------------------------------

# Prestage data
#--------------------------------------------------------------------
#set BUILDCSH=$CASEROOT/Buildnml_Prestage/clm.buildnml_prestage.csh
#cat >! $BUILDCSH << EOF1
#! /bin/csh -f
 #******************************************************************#
 # If the user changes any input datasets - be sure to give it a    #
 # unique filename. Do not duplicate any existing input files       #
 #******************************************************************#

set exedir = ${DATA_DST_DIR}
cd $exedir

set fsurdat = $datasurf
set finidat = $datainit
#set nrevsn  = '$nrevsn'

link_data ${DATA_SRC_DIR}/pftdata/pft-physiology ${DATA_DST_DIR}/
link_data ${DATA_SRC_DIR}/rtmdata/rdirc.05 ${DATA_DST_DIR}/
if ($fsurdat != "") then
  link_data ${DATA_SRC_DIR}/srfdata/${COMPSET}/$fsurdat ${DATA_DST_DIR}/
else
  link_data ${DATA_SRC_DIR}/rawdata/mksrf_soicol_clm2.nc ${DATA_DST_DIR}/
  link_data ${DATA_SRC_DIR}/rawdata/mksrf_lanwat.nc ${DATA_DST_DIR}/
  link_data ${DATA_SRC_DIR}/rawdata/mksrf_glacier.nc ${DATA_DST_DIR}/
  link_data ${DATA_SRC_DIR}/rawdata/mksrf_urban.nc ${DATA_DST_DIR}/
  link_data ${DATA_SRC_DIR}/rawdata/mksrf_lai.nc ${DATA_DST_DIR}/
  link_data ${DATA_SRC_DIR}/rawdata/mksrf_pft.nc ${DATA_DST_DIR}/
  link_data ${DATA_SRC_DIR}/rawdata/mksrf_soitex.10level.nc ${DATA_DST_DIR}/
endif


# Create resolved namelist
#--------------------------------------------------------------------
#cat >> $BUILDCSH << EOF1

if ($RUN_TYPE == 'initial' ) set nsrest = 0
if ($RUN_TYPE == 'restart') then
    set nsrest = 1
cat >! $DATA_DST_DIR/rpointer.lnd << EOF
./$ORIGINAL_CASE_NAME.clm2.r.$RUN_RESTART_DATE-$RUN_RESTART_SECOND
EOF
endif


cat >! ${MODEL_NAME}.stdin << EOF
 &clmexp
 caseid           = '$CASE_NAME'
 ctitle           = '$CASE_NAME $CASESTR'
 brnch_retain_casename = .true.
 nsrest           =  $nsrest
 start_ymd        =  $basedate_num
 start_tod        =  0
 nelapse          = -9999
 rtm_nsteps       =  $rtm_nsteps
 dtime            =  $dtime
 irad             = -1
 csm_doflxave     = .true.
 hist_nhtfrq      =  0
 hist_crtinic     = 'YEARLY'
 nrevsn           = '$nrevsn'
 finidat          = '$finidat'
 fsurdat          = '$fsurdat'
 fpftcon          = 'pft-physiology'
 frivinp_rtm      = 'rdirc.05'
 mss_irt          =  0
 rpntpath         = 'rpointer.lnd'
 mksrf_fvegtyp    = 'mksrf_pft.nc'
 mksrf_fsoitex    = 'mksrf_soitex.10level.nc'
 mksrf_fsoicol    = 'mksrf_soicol_clm2.nc'
 mksrf_flanwat    = 'mksrf_lanwat.nc'
 mksrf_fglacier   = 'mksrf_glacier.nc'
 mksrf_furban     = 'mksrf_urban.nc'
 mksrf_flai       = 'mksrf_lai.nc'
 /
EOF

