module model_setting_mod

    integer, public          :: time_length

contains

  subroutine atm_demo_init
      use mpi
      use parse_namelist_mod
      use spmd_init_mod
      use grid_init_mod
      use decomp_init_mod
      use variable_mod

      implicit none
      integer :: mpicom

      mpicom = MPI_COMM_WORLD

      call parse_namelist
      call spmd_init(mpicom)
      call grid_init
      call decomp_init
      call variable_init

  end subroutine atm_demo_init

  subroutine atm_demo_step_on

      use mpi
      use parse_namelist_mod, only:time_step
      use variable_mod, only:pslm, tsm, fldsm ,fsdsm, psl_l, ts_l, flds_l, fsds_l

      implicit none

      integer    :: i
      
      time_length = 12600

      do i=1,time_length/time_step
          
          pslm = psl_l
          tsm = ts_l
          fldsm = fsds_l
          fsdsm = flds_l
          
      end do

  end subroutine atm_demo_step_on

  subroutine finalize_atm_demo

      use mpi
      use spmd_init_mod, only:ier
      use variable_mod, only:pslm, tsm, fldsm, fsdsm, psl_l, ts_l, flds_l, &
          fsds_l, psl, ts,flds,fsds
      use grid_init_mod, only:lon,lat
      use decomp_init_mod, only:local_grid_cell_index

      implicit none

      deallocate(pslm, tsm, fldsm, fsdsm)
      deallocate(psl_l, ts_l, flds_l, fsds_l)
      deallocate(local_grid_cell_index)
      deallocate(psl, ts,flds,fsds,lat,lon)

      call mpi_finalize(ier)

  end subroutine finalize_atm_demo

end module model_setting_mod
