#! /bin/csh -f

cd $NAMELIST_DST_DIR
set GDDEF=nodef
if ($GRID == 'eq1x1')then
set GDDEF    = eq1x1
set  IDTB       = 60
set  IDTC       = 720
set  IDTS       = 3600
endif
if ($GRID == 'gr1x1')then
set GDDEF    = gr1x1
set  IDTB       = 60
set  IDTC       = 2400
set  IDTS       = 3600
endif
if($GDDEF == 'nodef')then
echo GRID = $GRID Not Surport,Licom Surport GRID is gr1x1 ,eq1x1
exit -1
endif
setenv OCNDPATH ${DATA_SRC_DIR}/DATA_$GDDEF
setenv DATAPATH $OCNDPATH

# started as a $RUN_TYPE run
if ($RUN_TYPE == 'initial' ) then
  set NSTART = 1
  link_data $OCNDPATH/fort.22.startup_db fort.22 copy
else
  set NSTART = 0
endif
#
#
set HISTOUT=1
set RESTOUT=1
set NUMBER = 12000
cat >! ocn.parm << EOF
 &namctl
  AFB1       = 0.43
  AFC1       = 0.43
  AFT1       = 0.43
  IDTB       = $IDTB
  IDTC       = $IDTC
  IDTS       = $IDTS
  AMV        = 1.0E-3
  AHV        = 0.6E-4
  NUMBER     = $NUMBER
  NSTART     = $NSTART
  IO_HIST    = $HISTOUT
  IO_REST    = $RESTOUT
  klv        = 30
  DLAM       = 1.0
  AM_TRO     = 1600
  AM_EXT     = 1600
  diag_mth   = .true. 
  diag_bsf   = .true.
  diag_msf   = .true.
 /
EOF

link_data $DATAPATH/INDEX.DATA_${GDDEF}_db_g.nc INDEX.DATA
link_data $DATAPATH/TSinitial_${GDDEF}_db_g.nc  TSinitial
link_data $DATAPATH/MODEL.FRC_${GDDEF}_db_g.nc  MODEL.FRC
link_data $DATAPATH/BASIN_$GDDEF.nc BASIN.nc
link_data $DATAPATH/dncoef_$GDDEF.h dncoef.h1
link_data $DATAPATH/domain_${GDDEF}.nc domain_licom.nc
link_data $DATAPATH/ahv_back_2011Jan26.txt ahv_back.txt

if ($RUN_TYPE == 'restart') then
   link_data $NAMELIST_DST_DIR/fort.22.$RUN_RESTART_DATE-$RUN_RESTART_SECOND $NAMELIST_DST_DIR/fort.22  copy
endif

