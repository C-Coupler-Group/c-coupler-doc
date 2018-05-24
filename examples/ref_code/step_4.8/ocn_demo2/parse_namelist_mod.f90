module parse_namelist_mod
    integer, public :: time_step, coupling_freq, decomp_type_id
contains
    subroutine parse_namelist
        implicit none
        namelist /ocn_demo2_nml/ time_step  ,decomp_type_id  , &
            coupling_freq
        open(10, file="./ocn_demo2.nml")
        read(10, nml=ocn_demo2_nml)
    end subroutine parse_namelist
end module
