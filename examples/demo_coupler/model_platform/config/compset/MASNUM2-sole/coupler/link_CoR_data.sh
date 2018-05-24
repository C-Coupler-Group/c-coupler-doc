#! /bin/csh -f
##################################################################################
#  Copyright (c) 2013, Tsinghua University. 
#  This code is initially finished by Dr. Li Liu on 2013/3/21. 
#  If you have any problem, please contact:
#  Dr. Li Liu via liuli-cess@tsinghua.edu.cn
##################################################################################



link_data "$DATAROOT/grids/WaveK_topo.nc" "$RUN_ALL_DIR/grids"
link_data "$DATAROOT/grids/masnum2_40_lev_grid.nc" "$RUN_ALL_DIR/grids"
link_data "$DATAROOT/grids/PomK_topo.nc" "$RUN_ALL_DIR/grids"
link_data "$DATAROOT/cpl/remap_weights_files/remap_weights_files_by_CoR/masnum2_pomfio2_3D_bilinear_linear_remap_wgts.bin" "$RUN_ALL_DIR/remap_weights_files/remap_weights_files_by_CoR/"

