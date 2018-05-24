#! /bin/csh -f

# determine ice mode flags
#-----------------------------------------------------------------------

set kdyn = 0  # dynamics / rheology option
set CASESTR = $CASE_NAME


   set ncat                = 5  # number of ice catagories
   set kdyn                = 1  # dynamics / rheology option
   set prescribed_ice      = .false.
   set prescribed_ice_fill = .false.   # unused
   set stream_year_first   = 0         # unused
   set stream_year_last    = 0         # unused
   set model_year_align    = 0         # unused
   set pice_stream_txt     = "unused"  # unused
   set pice_stream_nc      = " "

# set local variables needed to prestage data and create resolved namelist
#-----------------------------------------------------------------------
#set icedata   = ice/cice_lasg
set icedata   = ${DATA_SRC_DIR}
set restart   = .false.

#-----------------------------------------------------------------------
# Write out resolved prestage and namelist
#-----------------------------------------------------------------------

 #******************************************************************#
 # If the user changes any input datasets - be sure to give it a    #
 # unique filename. Do not duplicate any existing input files       #
 #******************************************************************#

#set exedir = $EXEROOT/ice
set exedir =  "${DATA_DST_DIR}"
cd $exedir

set hstdir = $DATA_DST_DIR/hist ; if !(-d $hstdir) mkdir -p $hstdir
set rstdir = $DATA_DST_DIR/rest ; if !(-d $rstdir) mkdir -p $rstdir
set inidir = $DATA_DST_DIR/init ; if !(-d $inidir) mkdir -p $inidir
set runhstdir = $DATA_DST_DIR/hist
set runrstdir = $DATA_DST_DIR/rest
set runinidir = $DATA_DST_DIR/init

# Calculate year used in new hist/rest filenames
#-----------------------------------------------------------------------
if ($RUN_TYPE == 'restart') then
  set local_run_type = "continue"
    #TODO
  set datedash = $RUN_RESTART_DATE-00000
cat >! $DATA_DST_DIR/rpointer.ice << EOF
$DATA_DST_DIR/rest/$ORIGINAL_CASE_NAME.cice.r.$RUN_RESTART_DATE-$RUN_RESTART_SECOND
EOF
else
  set local_run_type = "initial"
  set datedash = $RUN_START_DATE-00000
endif

if ($prescribed_ice == .true.) then

#cat >> $CASEROOT/Buildnml_Prestage/cice.buildnml_prestage.csh << EOF1
set restart   = .false.
set no_ice_ic = 'default'
if ($RUN_TYPE == initial)  set restart = .false.

#set pice_stream_txt = $pice_stream_txt
#set pice_stream_nc  = $pice_stream_nc 
#TODO
$UTILROOT/Tools/ccsm_getinput $DIN_LOC_ROOT/ice/cice/$pice_stream_nc . || exit 3
sed -e "s#DIN_LOC_ROOT#$DIN_LOC_ROOT#" < $CASEROOT/Buildnml_Prestage/$pice_stream_txt >! $pice_stream_txt || exit 3

#EOF1

else

#cat >> $CASEROOT/Buildnml_Prestage/cice.buildnml_prestage.csh << EOF1
set restart   = .false.
set no_ice_ic = 'default'

# Note - no_ice_ic can only be set to true for a initial run, not
# a branch or a hybrid run. Furthermore, no_ice_ic must always
# be set to 'default' for a continuation run

if ($RUN_TYPE == 'restart') then
  set no_ice_ic = 'default'
else 
  if ($no_ice_ic == 'none') then
    if ($RUN_TYPE == initial) then
      set restart = .false.
    else
      echo "You requested no ice initial conditions for a $RUN_TYPE run"; exit -1
    endif
  endif
endif

endif

# read in ice datasets
#-----------------------------------------------------------------------
#cat >> $CASEROOT/Buildnml_Prestage/cice.buildnml_prestage.csh << EOF1
  rm -f data.domain.grid data.domain.kmt
if ($GRID == 'gx3v5') then
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}_20030806.grid data.domain.grid || exit 2
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}_20040323.kmt  data.domain.kmt  || exit 2
  link_data $icedata/global_${GRID}_20030806.grid data.domain.grid || exit 2
  link_data $icedata/global_${GRID}_20040323.kmt  data.domain.kmt  || exit 2
   set rstfile = iced.0001-01-01.${GRID}_20070209
endif
if ($GRID == 'gx1v3') then
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}.grid data.domain.grid || exit 2
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}.kmt  data.domain.kmt  || exit 2
  link_data $icedata/global_${GRID}.grid data.domain.grid || exit 2
  link_data $icedata/global_${GRID}.kmt  data.domain.kmt  || exit 2
   set rstfile = iced.0001-01-01.${GRID}.20lay
endif
if ($GRID == 'gx1v4') then
  link_data $icedata/global_${GRID}_20010402.grid data.domain.grid || exit 2
  link_data $icedata/global_${GRID}_20060831.kmt  data.domain.kmt  || exit 2
   set rstfile = iced.0001-01-01.${GRID}_20070209
endif
if ($GRID == 'gx1v5') then
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}_20010402.grid data.domain.grid || exit 2
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}_20061229.kmt  data.domain.kmt  || exit 2
  link_data $icedata/global_${GRID}_20010402.grid data.domain.grid || exit 2
  link_data $icedata/global_${GRID}_20061229.kmt  data.domain.kmt  || exit 2
   set rstfile = iced.0001-01-01.${GRID}_20070209
endif
if ($GRID == 'eq1x1') then
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}.grid data.domain.grid || exit 2
  #$UTILROOT/Tools/ccsm_getinput $icedata/global_${GRID}.kmt  data.domain.kmt  || exit 2
  link_data $icedata/global_${GRID}.grid data.domain.grid || exit 2
  link_data $icedata/global_${GRID}.kmt  data.domain.kmt  || exit 2
   set rstfile = iced.2048-01-01-00000.${GRID} 
endif

if ($RUN_TYPE == initial && $restart == .true.) then
#cat >> $CASEROOT/Buildnml_Prestage/cice.buildnml_prestage.csh << EOF1
  if ($RUN_TYPE != 'restart') then
     if ($restart == .true.) then
        #$UTILROOT/Tools/ccsm_getinput $icedata/$rstfile $rstdir/ || exit 2
        link_data $icedata/$rstfile $rstdir/ || exit 2
        echo $runrstdir/$rstfile >! $exedir/rpointer.ice
     endif
  endif
#EOF1
endif


#-------------------------------------------------------------------
# b. create the namelist input file                                      
#-------------------------------------------------------------------
#cat >> $CASEROOT/Buildnml_Prestage/cice.buildnml_prestage.csh << EOF1

# PRESCRIBED_ICE      is $prescribed_ice      

#EOF1

# New default albedos based on observations. DAB 05/01/2007

if ($GRID == 'gx3v5') then
  set albicev  = 0.68
  set albicei  = 0.30
  set albsnowv = 0.91
  set albsnowi = 0.63
else
  set albicev  = 0.72
  set albicei  = 0.40
  set albsnowv = 0.92
  set albsnowi = 0.70
endif

  set kstrength = 1
  set kitd = 1
if ($prescribed_ice == .true. ) then
  set kstrength = 0
  set kitd = 0
endif

#cat >> $CASEROOT/Buildnml_Prestage/cice.buildnml_prestage.csh << EOF1

cat << EOF >! ice_in
 &setup_nml
    days_per_year  = 365
  , year_init      = 1
  , istep0         = 0
  , dt             = 3600.0
  , npt            = 10000000
  , ndyn_dt        = 1
  , runtype        = '$local_run_type' 
  , ice_ic         = '$no_ice_ic' 
  , restart        = $restart 
  , restart_dir    = '$runrstdir/' 
  , restart_file   = '$CASE_NAME.cice.r' 
  , pointer_file   = 'rpointer.ice'
  , dumpfreq       = 'm'
  , dumpfreq_n     = 1
  , diagfreq       = 24
  , diag_type      = 'stdout'
  , diag_file      = 'ice_diag.d'
  , print_global   = .false.
  , print_points   = .false.
  , latpnt(1)      =  90.
  , lonpnt(1)      =   0.
  , latpnt(2)      = -65.
  , lonpnt(2)      = -45.
  , dbug           = .false.
  , histfreq       = 'm'
  , histfreq_n     = 1
  , hist_avg       = .true.
  , history_dir    = '$runhstdir/'
  , history_file   = '$CASE_NAME.cice.h'
  , history_format = 'nc'
  , write_ic       = .true.
  , incond_dir     = '$runinidir/' 
  , incond_file    = '$CASE_NAME.cice.i.' 
  , runid          = '$CASE_NAME $CASESTR'
/
 
&grid_nml
    grid_format  = 'bin'
  , grid_type    = 'displaced_pole'
  , grid_file    = 'data.domain.grid' 
  , kmt_file     = 'data.domain.kmt' 
  , kcatbound    = 0
/ 

&ice_nml
    kitd            = $kitd 
  , kdyn            = $kdyn 
  , ndte            = 120
  , kstrength       = $kstrength 
  , krdg_partic     = 1
  , krdg_redist     = 1
  , advection       = 'remap'
  , heat_capacity   = .true.
  , shortwave       = 'default'
  , albedo_type     = 'default'
  , albicev         = $albicev 
  , albicei         = $albicei
  , albsnowv        = $albsnowv
  , albsnowi        = $albsnowi
  , R_ice           = 0.
  , R_pnd           = 0.
  , R_snw           = 0.
  , atmbndy         = 'default'
  , fyear_init      = 1981
  , ycycle          = 1
  , atm_data_format = 'bin'
  , atm_data_type   = 'LYq'
  , atm_data_dir    = '/scratch2/eclare/DATA/gx1v3/LargeYeager/'
  , calc_strair     = .true.
  , calc_Tsfc       = .true.
  , precip_units    = 'mm_per_sec'
  , Tfrzpt          = 'linear_S'
  , update_ocn_f    = .false.
  , oceanmixed_ice  = .false. 
  , ocn_data_format = 'bin'
  , sss_data_type   = 'default'
  , ocn_data_dir    = '/scratch2/eclare/DATA/gx1v3/gx1v3/forcing/'
  , oceanmixed_file = 'pop_frc.gx1v3.051202.nc'
  , restore_sst     = .false.
  , trestore        =  90
  , restore_ice     = .false.
  , fresh_s2i       = .false.
/

&tracer_nml
    tr_iage      = .false.
  , restart_age  = .false.
  , tr_pond      = .false.
  , restart_pond = .false.
/

 &domain_nml
    nprocs = $NUM_TOTAL_PROC
  , processor_shape   = 'slenderX1'
  , distribution_type = 'cartesian'
  , ew_boundary_type  = 'cyclic'
  , ns_boundary_type  = 'open'
/
EOF

if ($prescribed_ice == .true.) then

cat >> ice_in << EOF1

 &ice_prescribed_nml
    prescribed_ice      = $prescribed_ice
  , stream_info_file    = '$pice_stream_txt'
  , stream_year_first   = $stream_year_first
  , stream_year_last    = $stream_year_last 
  , model_year_align    = $model_year_align
  , prescribed_ice_fill = $prescribed_ice_fill
/

  &icefields_nml
    f_sst       = .false.
  , f_sss       = .false.
  , f_uocn      = .false.
  , f_vocn      = .false.
  , f_frzmlt    = .false.
  , f_strtltx   = .false.
  , f_strtlty   = .false.
  , f_mlt_onset = .false. 
  , f_frz_onset = .false. 
  , f_icepresent= .true.
  , f_aicen     = .false.
  , f_vicen     = .false.
  , f_fsalt     = .false. 
  , f_fsalt_ai  = .false. 
  , f_fresh     = .false. 
  , f_fresh_ai  = .false. 
  , f_fhocn     = .false. 
  , f_fhocn_ai  = .false. 
  , f_dvidtt    = .false. 
  , f_dvidtd    = .false. 
  , f_daidtt    = .false. 
  , f_daidtd    = .false. 
  , f_sig1      = .false. 
  , f_sig2      = .false. 
  , f_strairx   = .false. 
  , f_strairy   = .false. 
  , f_strcorx   = .false. 
  , f_strcory   = .false. 
  , f_strocnx   = .false. 
  , f_strocny   = .false. 
  , f_strintx   = .false. 
  , f_strinty   = .false. 
  , f_strength  = .false. 
  , f_opening   = .false. 
  , f_divu      = .false. 
  , f_shear     = .false. 
  , f_congel    = .false.
  , f_snoice    = .false.
  , f_meltt     = .false.
  , f_meltb     = .false.
  , f_meltl     = .false.
  , f_uvel      = .false.
  , f_vvel      = .false.
  , f_frazil    = .false.
 /
EOF1

else 

cat >> ice_in << EOF1
&icefields_nml
    f_tmask        = .true.
  , f_tarea        = .true.
  , f_uarea        = .true.
  , f_dxt          = .false.
  , f_dyt          = .false.
  , f_dxu          = .false.
  , f_dyu          = .false.
  , f_HTN          = .false.
  , f_HTE          = .false.
  , f_ANGLE        = .true.
  , f_ANGLET       = .true.
  , f_bounds       = .false.
  , f_hi           = .true.
  , f_hs           = .true.
  , f_Tsfc         = .true.
  , f_aice         = .true.
  , f_uvel         = .true.
  , f_vvel         = .true.
  , f_fswdn        = .true.
  , f_flwdn        = .true.
  , f_snow         = .false.
  , f_snow_ai      = .true.
  , f_rain         = .false.
  , f_rain_ai      = .true.
  , f_sst          = .true.
  , f_sss          = .true.
  , f_uocn         = .true.
  , f_vocn         = .true.
  , f_frzmlt       = .true.
  , f_fswfac       = .true.
  , f_fswabs       = .false.
  , f_fswabs_ai    = .true.
  , f_albsni       = .true.
  , f_alvdr        = .false.
  , f_alidr        = .false.
  , f_albice       = .false.
  , f_albsno       = .false.
  , f_albpnd       = .false.
  , f_coszen       = .false.
  , f_flat         = .false.
  , f_flat_ai      = .true.
  , f_fsens        = .false.
  , f_fsens_ai     = .true.
  , f_flwup        = .false.
  , f_flwup_ai     = .true.
  , f_evap         = .false.
  , f_evap_ai      = .true.
  , f_Tair         = .true.
  , f_Tref         = .false.
  , f_Qref         = .false.
  , f_congel       = .true.
  , f_frazil       = .true.
  , f_snoice       = .true.
  , f_meltt        = .true.
  , f_meltb        = .true.
  , f_meltl        = .true.
  , f_fresh        = .false.
  , f_fresh_ai     = .true.
  , f_fsalt        = .false.
  , f_fsalt_ai     = .true.
  , f_fhocn        = .false.
  , f_fhocn_ai     = .true.
  , f_fswthru      = .false.
  , f_fswthru_ai   = .true.
  , f_fsurf_ai     = .true.
  , f_fcondtop_ai  = .false.
  , f_fmeltt_ai    = .false.
  , f_strairx      = .true.
  , f_strairy      = .true.
  , f_strtltx      = .false.
  , f_strtlty      = .false.
  , f_strcorx      = .false.
  , f_strcory      = .false.
  , f_strocnx      = .false.
  , f_strocny      = .false.
  , f_strintx      = .false.
  , f_strinty      = .false.
  , f_strength     = .true.
  , f_divu         = .true.
  , f_shear        = .true.
  , f_sig1         = .true.
  , f_sig2         = .true.
  , f_dvidtt       = .true.
  , f_dvidtd       = .true.
  , f_daidtt       = .true.
  , f_daidtd       = .true.
  , f_mlt_onset    = .true.
  , f_frz_onset    = .true.
  , f_dardg1dt     = .true.
  , f_dardg2dt     = .true.
  , f_dvirdgdt     = .true.
  , f_opening      = .true.
  , f_hisnap       = .false.
  , f_aisnap       = .false.
  , f_trsig        = .true.
  , f_icepresent   = .true.
  , f_iage         = .true.
  , f_aicen        = .false.
  , f_vicen        = .false.
  , f_fsurfn_ai    = .false.
  , f_fcondtopn_ai = .false.
  , f_fmelttn_ai   = .false.
  , f_flatn_ai     = .false.
  , f_apondn       = .false.
  , f_sice         = .true.
  , f_sicen        = .false.
  , f_salinpfl     = .true.
  , f_salinavg     = .true.
/
EOF1

endif

