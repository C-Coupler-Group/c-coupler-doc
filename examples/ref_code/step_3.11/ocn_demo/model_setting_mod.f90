module model_setting_mod

    integer, public          :: time_length

contains

  subroutine ocn_demo_init
      use mpi
      use parse_namelist_mod
      use CCPL_interface_mod
      use spmd_init_mod
      use coupling_atm_model_mod
      use grid_init_mod
      use decomp_init_mod
      use variable_mod

      implicit none
      integer :: mpicom

      mpicom = CCPL_NULL_COMM

      call register_ocn_demo_component(mpicom)

      call parse_namelist
      call spmd_init(mpicom)
      call grid_init
      call decomp_init
      call variable_init

      call register_component_coupling_configuration

  end subroutine ocn_demo_init

  subroutine ocn_demo_step_on

      use mpi
      use parse_namelist_mod, only:time_step
      use variable_mod, only:sstm, shfm, sshm ,mldm, sst_l, shf_l, mld_l, ssh_l
      use coupling_atm_model_mod, only:ocn_demo_comp_id
      use CCPL_interface_mod

      implicit none

      integer    :: i
      logical    :: interface_status
      
      time_length = 12600

      do i=1,time_length/time_step
          
          sstm = sst_l
          shfm = shf_l
          sshm = ssh_l
          mldm = mld_l
          
          interface_status = CCPL_execute_interface_using_name(ocn_demo_comp_id, "send_data_to_atm", .false., annotation = "execute interface for sending data to atmosphere")
          
          interface_status = CCPL_execute_interface_using_name(ocn_demo_comp_id, "receive_data_from_atm", .false., annotation = "execute interface for receiving data from atmosphere")
          
          call CCPL_advance_time(ocn_demo_comp_id, "ocn_demo advances time for one step")
      end do

  end subroutine ocn_demo_step_on

  subroutine finalize_ocn_demo

      use mpi
      use spmd_init_mod, only:ier
      use variable_mod, only:sstm, shfm, sshm, mldm, sst_l, shf_l, ssh_l, &
          mld_l, ssh, sst,shf,mld,mask
      use grid_init_mod, only:lon,lat
      use decomp_init_mod, only:local_grid_cell_index
      use CCPL_interface_mod

      implicit none

      deallocate(sstm, shfm, sshm, mldm)
      deallocate(sst_l, shf_l, ssh_l, mld_l)
      deallocate(local_grid_cell_index)
      deallocate(ssh, sst,shf,mld,lat,lon,mask)

      call mpi_finalize(ier)

  end subroutine finalize_ocn_demo

end module model_setting_mod
