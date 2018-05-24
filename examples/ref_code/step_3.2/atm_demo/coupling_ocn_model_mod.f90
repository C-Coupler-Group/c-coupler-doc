module coupling_ocn_model_mod

    use CCPL_interface_mod

    implicit none

    integer, public             :: atm_demo_comp_id
    
contains

    subroutine register_atm_demo_component(comm)
        use CCPL_interface_mod
        integer, intent(inout) :: comm
        atm_demo_comp_id = CCPL_register_component(-1, "atm_demo", "atm", comm, change_dir=.true., annotation = "register atm model atm_demo")
    end subroutine register_atm_demo_component

end module coupling_ocn_model_mod
