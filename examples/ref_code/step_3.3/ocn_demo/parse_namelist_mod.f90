module parse_namelist_mod
    integer, public :: time_step, coupling_freq, decomp_type_id
contains
    subroutine parse_namelist
        implicit none
        namelist /ocn_demo_nml/ time_step  ,decomp_type_id  , &
            coupling_freq
        open(10, file="./ocn_demo.nml")
        read(10, nml=ocn_demo_nml)
    end subroutine parse_namelist
end module
