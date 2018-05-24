module coupling_atm_model_mod

    use CCPL_interface_mod

    implicit none

    integer, public             :: ocn_demo_comp_id
    integer, private            :: decomp_id, grid_h2d_id
    
contains

    subroutine register_ocn_demo_component(comm)
        use CCPL_interface_mod
        integer, intent(inout) :: comm
        ocn_demo_comp_id = CCPL_register_component(-1, "ocn_demo", "ocn", comm, change_dir=.true., annotation = "register ocn model ocn_demo")
    end subroutine register_ocn_demo_component

    subroutine register_component_coupling_configuration

        use CCPL_interface_mod
        use spmd_init_mod, only:mytask_id, npes
        use parse_namelist_mod,only:time_step, coupling_freq
        use grid_init_mod, only:latlen, lonlen, lon, lat
        use decomp_init_mod, only:decomp_size, local_grid_cell_index
        use variable_mod, only:sstm, shfm, sshm, mldm, mask, psl,prect,flds,fsds

        implicit none

        integer          :: export_interface_id, import_interface_id
        integer          :: timer_id, fields_id(5)
        integer          :: field_id_psl, field_id_prect, field_id_flds, field_id_fsds
        integer          :: field_id_sst, field_id_ssh, field_id_shf, field_id_mld

        call CCPL_set_normal_time_step(ocn_demo_comp_id, time_step, annotation="setting the time step for ocn_demo")

        grid_h2d_id = CCPL_register_H2D_grid_via_global_data(ocn_demo_comp_id, "ocn_demo_H2D_grid", "LON_LAT", "degrees", "cyclic", lonlen, latlen, 0.0, 360.0, -90.0, 90.0, lon, lat, mask, annotation="register ocn_demo H2D grid ")
        decomp_id = CCPL_register_normal_parallel_decomp("decomp_ocn_demo_grid", grid_H2D_id, decomp_size, local_grid_cell_index(:,mytask_id+1), annotation="allocate decomp for ocn_demo grid")

        !------------register field instances to C-Coupler2--------------

        field_id_psl = CCPL_register_field_instance(psl(1:decomp_size), "psl", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="Pa", annotation="register field instance of Sea level pressure") 
        field_id_prect = CCPL_register_field_instance(prect(1:decomp_size), "prect", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="m/s", annotation="register field instance of precipitation")
        field_id_fsds = CCPL_register_field_instance(fsds(1:decomp_size), "fsds", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="W/m2", annotation="register field instance of Short wave downward flux at surface")
        field_id_flds  = CCPL_register_field_instance(flds(1:decomp_size), "flds", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="W/m2", annotation="register field instance of Long wave downward flux at surface")
        field_id_sst  = CCPL_register_field_instance(sstm, "sst", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="C", annotation="register field instance of Sea surface temperature")
        field_id_shf  = CCPL_register_field_instance(shfm, "shf", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="W/m2", annotation="register field instance of Net surface heat flux")
        field_id_ssh = CCPL_register_field_instance(sshm, "ssh", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="m", annotation="register field instance of Sea surface height")
        field_id_mld = CCPL_register_field_instance(mldm, "mld", decomp_id, grid_h2d_id, 0, usage_tag=CCPL_TAG_CPL_REST, field_unit="m", annotation="register field instance of Mixed layer depth")

        !--------register coupling frequency to C-Coupler2-------------
        timer_id = CCPL_define_single_timer(ocn_demo_comp_id, "seconds", coupling_freq, 0, 1800, annotation="define a single timer for ocn_demo")

        !--------register export & import interface to C-Coupler2------
        fields_id(1) = field_id_sst
        fields_id(2) = field_id_shf
        fields_id(3) = field_id_ssh
        fields_id(4) = field_id_mld
        export_interface_id = CCPL_register_export_interface("send_data_to_atm", 4, fields_id, timer_id, annotation="register interface for sending data to atmosphere")

        fields_id(1) = field_id_psl
        fields_id(2) = field_id_prect
        fields_id(3) = field_id_fsds
        fields_id(4) = field_id_flds
        import_interface_id = CCPL_register_import_interface("receive_data_from_atm", 4, fields_id, timer_id, 1, annotation="register interface for receiving data from atmosphere")

        call CCPL_end_coupling_configuration(ocn_demo_comp_id, annotation = "component ocn_demo ends configuration")

    end subroutine register_component_coupling_configuration

end module coupling_atm_model_mod
