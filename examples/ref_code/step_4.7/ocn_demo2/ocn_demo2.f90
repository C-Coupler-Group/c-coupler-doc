program ocn_demo2
    use mpi
    use model_setting_mod
    use spmd_init_mod

    implicit none

    call ocn_demo2_init
    if (masterproc) then
        print *, "ocn_demo2_init finished"
    end if
    call ocn_demo2_step_on
    if (masterproc) then
        print *, "ocn_demo2 finished time integration"
    end if
    call finalize_ocn_demo2
    if (masterproc) then
        print *, "ocn_demo2 has been finalized"
    end if

end program
