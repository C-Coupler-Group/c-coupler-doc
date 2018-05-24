module coupling_ocn_model_mod

    use CCPL_interface_mod

    implicit none

    integer, public             :: atm_demo_comp_id
    integer, private            :: decomp_id, grid_h2d_id
    
contains

    subroutine register_atm_demo_component(comm)
        use CCPL_interface_mod
        integer, intent(inout) :: comm
        atm_demo_comp_id = CCPL_register_component(-1, "atm_demo", "atm", comm, change_dir=.true., annotation = "register atm model atm_demo")
    end subroutine register_atm_demo_component

    subroutine register_component_coupling_configuration

        use CCPL_interface_mod
        use spmd_init_mod, only:mytask_id, npes
        use parse_namelist_mod,only:time_step
        use grid_init_mod, only:latlen, lonlen, lon, lat
        use decomp_init_mod, only:decomp_size, local_grid_cell_index

        implicit none

        call CCPL_set_normal_time_step(atm_demo_comp_id, time_step, annotation="setting the time step for atm_demo")

        grid_h2d_id = CCPL_register_H2D_grid_via_global_data(atm_demo_comp_id, "atm_demo_H2D_grid", "LON_LAT", "degrees", "cyclic", lonlen, latlen, 0.0, 360.0, -90.0, 90.0, lon, lat, annotation="register atm_demo H2D grid ")
        decomp_id = CCPL_register_normal_parallel_decomp("decomp_atm_demo_grid", grid_H2D_id, decomp_size, local_grid_cell_index(:,mytask_id+1), annotation="allocate decomp for atm_demo grid")

    end subroutine register_component_coupling_configuration

end module coupling_ocn_model_mod
