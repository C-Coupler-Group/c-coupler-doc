module restart_mod

contains
    subroutine restart_read
        use coupling_ocn_model_mod, only: atm_demo_comp_id
        use CCPL_interface_mod

        call CCPL_start_restart_read_IO(atm_demo_comp_id)
        call CCPL_restart_read_fields_all(atm_demo_comp_id)
        if (CCPL_is_first_restart_step(atm_demo_comp_id)) &
        then
            call CCPL_advance_time(atm_demo_comp_id, &
                "atm_demo advances time after restart")
        endif

    end subroutine restart_read
end module restart_mod
