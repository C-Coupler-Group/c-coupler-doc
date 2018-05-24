module variable_mod
    real(kind=4), public, allocatable :: psl(:,:), prect(:,:)
    real(kind=4), public, allocatable :: flds(:,:), fsds(:,:)
    real(kind=4), public, allocatable :: psl_l(:), prect_l(:)
    real(kind=4), public, allocatable :: flds_l(:), fsds_l(:)
    real(kind=4), public, allocatable :: pslm(:), prectm(:)
    real(kind=4), public, allocatable :: fldsm(:), fsdsm(:)
    integer, public, allocatable      :: maskm(:)
    real(kind=4), public, allocatable   :: sst(:),ssh(:),shf(:),mld(:)
contains
    subroutine variable_init
        call read_input_variables
        call scatter_fields
    end subroutine variable_init

    subroutine read_input_variables
        use mpi
        use spmd_init_mod, only:masterproc
        use grid_init_mod, only:latlen, lonlen

        implicit none
        include "netcdf.inc"

        character*1024 :: input_data_dir, input_file_name
        character*1024 :: input_file_dir_name
        integer :: ncid_input, ret
        integer :: pslid, prectid, fldsid, fsdsid, maskid
        integer :: i, j
        integer, allocatable      :: mask(:,:)

        input_data_dir = ''
        input_file_name = "atm_demo.h0.0591-06.nc"
        input_file_dir_name = input_data_dir//input_file_name
        allocate(mask(lonlen, latlen))
        allocate(maskm(lonlen*latlen))

        if (masterproc) then
            ret = nf_open (input_file_name, nf_nowrite, ncid_input)
            ret = nf_inq_varid (ncid_input, "PSL", pslid)
            ret = nf_inq_varid (ncid_input, "PRECT", prectid)
            ret = nf_inq_varid (ncid_input, "FLDS", fldsid)
            ret = nf_inq_varid (ncid_input, "FSDS", fsdsid)
            ret = nf_inq_varid (ncid_input, "MASK_ATM", maskid)

            allocate(psl(lonlen, latlen))
            allocate(prect(lonlen, latlen))
            allocate(flds(lonlen, latlen))
            allocate(fsds(lonlen, latlen))

            ret = nf_get_var_real (ncid_input, pslid, psl)
            ret = nf_get_var_real (ncid_input, prectid, prect)
            ret = nf_get_var_real (ncid_input, fldsid, flds)
            ret = nf_get_var_real (ncid_input, fsdsid, fsds)
            ret = nf_get_var_int (ncid_input, maskid, mask)

            do i = 1,lonlen
            do j = 1,latlen
                maskm(i+lonlen*(j-1)) = mask(i,j)
            end do
            end do

        else
            allocate(psl(1,1),prect(1,1),flds(1,1),fsds(1,1))
        end if
    end subroutine read_input_variables
    subroutine scatter_field(global_field, local_field)
        use mpi
        use spmd_init_mod, only:masterproc, ier, mpicomm, npes
        use decomp_init_mod, only:local_grid_cell_index, decomp_size
        use grid_init_mod, only:latlen, lonlen
        implicit none
        real(kind=4), intent(in)  :: global_field(lonlen, latlen)
        real(kind=4), intent(out) :: local_field(decomp_size)
        !----------local variables-----------------------------------
        real(kind=4) gfield(decomp_size, npes)
        real(kind=4) lfield(decomp_size)
        integer :: p, i, j, m
        integer :: displs(1:npes)  !scatter displacements
        integer :: sndcnts(1:npes) !scatter send counts
        integer :: recvcnt  !scatter receive count

        sndcnts(:) = decomp_size
        displs(1) = 0
        do p=2, npes
            displs(p) = displs(p-1)+decomp_size
        end do
        recvcnt = decomp_size
        if (masterproc) then
            j = 1
            do p=1,npes
                do i=1,decomp_size
                    m = local_grid_cell_index(i,p)
                    gfield(i,p) = global_field(mod(m-1,lonlen)+1,(m-1)/lonlen+1)
                end do
            end do
        end if
        call mpi_scatterv(gfield, sndcnts, displs, mpi_real4, lfield, recvcnt, mpi_real4, 0, mpicomm, ier)
        do i=1,decomp_size
            local_field(i) = lfield(i)
        end do
    end subroutine scatter_field
    
    subroutine scatter_fields
        use mpi
        use spmd_init_mod, only:mpicomm, ier
        use decomp_init_mod, only:decomp_size
        use grid_init_mod, only:lonlen, latlen
        implicit none

        allocate(psl_l(decomp_size))
        allocate(prect_l(decomp_size))
        allocate(flds_l(decomp_size))
        allocate(fsds_l(decomp_size))

        call scatter_field(psl, psl_l)
        call scatter_field(prect, prect_l)
        call scatter_field(flds, flds_l)
        call scatter_field(fsds, fsds_l)

        call mpi_barrier(mpicomm)
        call mpi_bcast(maskm,lonlen*latlen, mpi_integer, 0, mpicomm, ier)

        allocate(pslm(decomp_size))
        allocate(prectm(decomp_size))
        allocate(fldsm(decomp_size))
        allocate(fsdsm(decomp_size))

        allocate(sst(decomp_size))
        allocate(ssh(decomp_size))
        allocate(mld(decomp_size))
        allocate(shf(decomp_size))
    end subroutine scatter_fields

end module
