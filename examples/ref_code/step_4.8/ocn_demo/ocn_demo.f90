program ocn_demo
    use mpi
    use model_setting_mod
    use spmd_init_mod

    implicit none

    call ocn_demo_init
    if (masterproc) then
        print *, "ocn_demo_init finished"
    end if
    call ocn_demo_step_on
    if (masterproc) then
        print *, "ocn_demo finished time integration"
    end if
    call finalize_ocn_demo
    if (masterproc) then
        print *, "ocn_demo has been finalized"
    end if

end program
