module grid_init_mod

    real, public, allocatable :: lat(:), lon(:)
    integer, public           :: latlen, lonlen

contains


    subroutine grid_init

        use spmd_init_mod, only:masterproc, mpicomm, ier
        use mpi
        implicit none
        include "netcdf.inc"

        character*1024 :: input_data_dir, input_file_name
        character*1024 :: input_file_dir_name
        integer        :: ncid_input, ret
        integer        :: latid, lonid
        integer        :: latdimid, londimid

        input_data_dir = ''
        input_file_name = 'ocn_demo2.059106-0591071.nc'
        input_file_dir_name = input_data_dir//input_file_name
        if (masterproc) then
            ret = nf_open (input_file_name, nf_nowrite, ncid_input)
            
            ret = nf_inq_dimid (ncid_input, "lat", latdimid)
            ret = nf_inq_dimid (ncid_input, "lon", londimid)
            ret = nf_inq_dimlen (ncid_input, latdimid, latlen)
            ret = nf_inq_dimlen (ncid_input, londimid, lonlen)
            
            allocate(lat(latlen), lon(lonlen))
            ret = nf_inq_varid (ncid_input, "lat", latid)
            ret = nf_inq_varid (ncid_input, "lon", lonid)
            ret = nf_get_var_real (ncid_input, latid, lat)
            ret = nf_get_var_real (ncid_input, lonid, lon)
        end if

        call mpi_bcast(latlen, 1, mpi_integer, 0, mpicomm, ier)
        call mpi_bcast(lonlen, 1, mpi_integer, 0, mpicomm, ier)

        if (masterproc == .false.) then
            allocate(lat(latlen), lon(lonlen))
        end if

        call mpi_bcast(lat, latlen, mpi_real4, 0, mpicomm, ier)
        call mpi_bcast(lon, lonlen, mpi_real4, 0, mpicomm, ier)

    end subroutine grid_init

end module grid_init_mod
