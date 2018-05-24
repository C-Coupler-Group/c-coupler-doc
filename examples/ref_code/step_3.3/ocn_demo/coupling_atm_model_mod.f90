module coupling_atm_model_mod

    use CCPL_interface_mod

    implicit none

    integer, public             :: ocn_demo_comp_id
    
contains

    subroutine register_ocn_demo_component(comm)
        use CCPL_interface_mod
        integer, intent(inout) :: comm
        ocn_demo_comp_id = CCPL_register_component(-1, "ocn_demo", "ocn", comm, change_dir=.true., annotation = "register ocn model ocn_demo")
    end subroutine register_ocn_demo_component

    subroutine register_component_coupling_configuration

        use CCPL_interface_mod
        use parse_namelist_mod,only:time_step

        implicit none

        call CCPL_set_normal_time_step(ocn_demo_comp_id, time_step, annotation="setting the time step for ocn_demo")

    end subroutine register_component_coupling_configuration

end module coupling_atm_model_mod
