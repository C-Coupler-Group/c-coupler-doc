#! /bin/csh -f

#-----------------------------------------------------------------------------------
# write out resolved prestaging directives
#-----------------------------------------------------------------------------------

cd $NAMELIST_DST_DIR

cat >! ${MODEL_NAME}.stdin << EOF
 &cpl_nml
 fluxEpbal = 'inst'
 fluxEpfac = 0.0
 flx_albav = .false.
 /
EOF
