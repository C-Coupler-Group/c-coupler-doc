module restart_mod

contains
    subroutine restart_read
        use coupling_atm_model_mod, only: ocn_demo_comp_id
        use CCPL_interface_mod

        call CCPL_start_restart_read_IO(ocn_demo_comp_id)
        call CCPL_restart_read_fields_all(ocn_demo_comp_id)
        if (CCPL_is_first_restart_step(ocn_demo_comp_id)) &
        then
            call CCPL_advance_time(ocn_demo_comp_id, &
                "ocn_demo advances time after restart")
        endif
            
    end subroutine restart_read
end module restart_mod
