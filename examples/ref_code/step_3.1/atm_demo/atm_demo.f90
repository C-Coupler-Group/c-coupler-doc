program atm_demo
    use mpi
    use model_setting_mod
    use spmd_init_mod, only:masterproc

    implicit none

    call atm_demo_init
    if (masterproc) then
        print *, "atm_demo_init finished"
    end if
    call atm_demo_step_on
    if (masterproc) then
        print *, "atm_demo finished time integration"
    end if
    call finalize_atm_demo
    if (masterproc) then
        print *, "atm_demo has been finalized"
    end if
end program
