module parse_namelist_mod
    integer, public :: time_step, coupling_freq, decomp_type_id
contains
    subroutine parse_namelist
        implicit none

        namelist /atm_demo_nml/ time_step  ,decomp_type_id  , &
            coupling_freq
        open(10, file="atm_demo.nml")
        read(10, nml=atm_demo_nml)
    end subroutine parse_namelist
end module
