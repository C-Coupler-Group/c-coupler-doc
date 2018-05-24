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

end module coupling_atm_model_mod
