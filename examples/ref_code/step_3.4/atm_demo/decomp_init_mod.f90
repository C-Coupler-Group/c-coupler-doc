module decomp_init_mod
    integer, public              :: decomp_size
    integer, public, allocatable :: local_grid_cell_index(:,:)
contains
    subroutine decomp_init
        use spmd_init_mod, only:npes, ier
        use mpi
        use grid_init_mod, only:latlen, lonlen
        use parse_namelist_mod, only : decomp_type_id
        implicit none

        integer :: i, j
        decomp_size = latlen*lonlen/npes
        if ((latlen*lonlen-decomp_size*npes) .ne. 0) then
            print *, "ERROR : grid cells cannot be equally decompsed to the current number of processes"
            call mpi_finalize(ier)
        end if

        allocate(local_grid_cell_index(decomp_size, npes))

        if (decomp_type_id == 1) then
            do j = 1, npes
            do i = 1, decomp_size
                local_grid_cell_index(i,j) = j+(i-1)*npes
            end do
            end do
        else
            do j = 1, npes
            do i = 1, decomp_size
                local_grid_cell_index(i,j) = i+(j-1)*decomp_size
            end do
            end do
        end if
    end subroutine decomp_init

end module decomp_init_mod
