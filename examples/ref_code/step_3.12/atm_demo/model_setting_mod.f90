module model_setting_mod

    integer, public          :: time_length

contains

  subroutine atm_demo_init
      use mpi
      use parse_namelist_mod
      use CCPL_interface_mod
      use spmd_init_mod
      use coupling_ocn_model_mod
      use grid_init_mod
      use decomp_init_mod
      use variable_mod

      implicit none
      integer :: mpicom

      mpicom = CCPL_NULL_COMM

      call register_atm_demo_component(mpicom)

      call parse_namelist
      call spmd_init(mpicom)
      call grid_init
      call decomp_init
      call variable_init

      call register_component_coupling_configuration

  end subroutine atm_demo_init

  subroutine atm_demo_step_on

      use mpi
      use parse_namelist_mod, only:time_step
      use variable_mod, only:pslm, prectm, fldsm ,fsdsm, psl_l, prect_l, flds_l, fsds_l
      use coupling_ocn_model_mod, only:atm_demo_comp_id
      use CCPL_interface_mod

      implicit none

      integer    :: i
      logical    :: interface_status
      
      time_length = 12600

      do i=1,time_length/time_step
          
          pslm = psl_l
          prectm = prect_l
          fldsm = fsds_l
          fsdsm = flds_l
          
          interface_status = CCPL_execute_interface_using_name(atm_demo_comp_id, "send_data_to_ocn", .false., annotation = "execute interface for sending data to atmosphere")
          
          interface_status = CCPL_execute_interface_using_name(atm_demo_comp_id, "receive_data_from_ocn", .false., annotation = "execute interface for receiving data from atmosphere")
          
          call CCPL_do_restart_write_IO(atm_demo_comp_id, .false.)
          call CCPL_advance_time(atm_demo_comp_id, "atm_demo advances time for one step")
      end do

  end subroutine atm_demo_step_on

  subroutine finalize_atm_demo

      use mpi
      use spmd_init_mod, only:ier
      use variable_mod, only:pslm, prectm, fldsm, fsdsm, psl_l, prect_l, flds_l, &
          fsds_l, psl, prect,flds,fsds
      use grid_init_mod, only:lon,lat
      use decomp_init_mod, only:local_grid_cell_index
      use CCPL_interface_mod

      implicit none

      deallocate(pslm, prectm, fldsm, fsdsm)
      deallocate(psl_l, prect_l, flds_l, fsds_l)
      deallocate(local_grid_cell_index)
      deallocate(psl, prect,flds,fsds,lat,lon)

      call CCPL_finalize(.false., "atm_demo finalizes C-Coupler2")
      call mpi_finalize(ier)

  end subroutine finalize_atm_demo

end module model_setting_mod
