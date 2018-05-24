!===============================================================================
! CVS $Id: shr_cal_mod.F90,v 1.2 2003/11/22 00:27:07 tcraig Exp $
! CVS $Source: /fs/cgd/csm/models/CVS.REPOS/shared/csm_share/shr/shr_cal_mod.F90,v $
! CVS $Name: ccsm3_0_1_beta14 $
!===============================================================================
!BOP ===========================================================================
!
! !MODULE: shr_cal_mod -- calendar module, relates elapsed days to calendar date.
!
! !DESCRIPTION:
!   These calendar routines do conversions between...
!   \begin{itemize}
!   \item the integer number of elapsed days 
!   \item the integers year, month, day (three inter-related integers)
!   \item the integer coded calendar date (yyyymmdd)
!   \end{itemize}
!   Possible uses include: a calling routine can increment the elapsed days 
!   integer and use this module to determine what the corresponding calendar 
!   date is;  this module can be used to determine how many days apart two
!   arbitrary calendar dates are.
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - created initial version, taken from cpl5
!
! !REMARKS:
!   Following are some internal assumptions.  These assumptions are somewhat
!   arbitrary -- they were chosen because they result in the simplest code given
!   the requirements of this module.  These assumptions can be relaxed as 
!   necessary: 
!   o the valid range of years is [0,9999]
!   o elapsed days = 0 <=> January 1st, year 0000
!   o all years have 365 days (no leap years)
!     This module is hard-coded to implement a 365-day calendar, ie. there
!     are no leap years.  This module can be modified to implement a calendar
!     with leap years if this becomes desireable.  This would make the internal
!     logic of this module more complex, but would not require any change to the
!     module API or the calling code because the module API hides these details
!     from all external routines.
!
! !INTERFACE: ------------------------------------------------------------------

module shr_cal_mod

! !USES:

   use shr_kind_mod   ! kinds

   implicit none

   private ! except

! !PUBLIC TYPES: 
 
   ! none

! !PUBLIC MEMBER FUNCTIONS:

   public :: shr_cal_eday2date  ! converts elapsed days to coded-date
   public :: shr_cal_eday2ymd   ! converts elapsed days to yr,month,day
   public :: shr_cal_date2ymd   ! converts coded-date   to yr,month,day
   public :: shr_cal_date2eday  ! converts coded-date   to elapsed days
   public :: shr_cal_ymd2date   ! converts yr,month,day to coded-date
   public :: shr_cal_ymd2eday   ! converts yr,month,day to elapsed days
   public :: shr_cal_validDate  ! logical function: is coded-date valid?
   public :: shr_cal_validYMD   ! logical function: are yr,month,day valid?
   public :: shr_cal_numDaysinMonth ! number of days in a month
   public :: shr_cal_elapsDaysStrtMonth ! elapsed days on start of month

! !PUBLIC DATA MEMBERS:

   ! none

!EOP

   !----- local -----
   integer(SHR_KIND_IN),parameter :: dsm(12) = &     ! elapsed Days on Start of Month
   &                    (/ 0,31,59, 90,120,151, 181,212,243, 273,304,334/)
   integer(SHR_KIND_IN),parameter :: dpm(12) = &     ! Days Per Month
   &                    (/31,28,31, 30, 31, 30,  31, 31, 30,  31, 30, 31/)

!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
contains
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_eday2date - converts elapsed days to coded-date
!
! !DESCRIPTION:
!     Converts elapsed days to coded-date.
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

subroutine shr_cal_eday2date(eday,date)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in)  :: eday  ! number of elapsed days
   integer(SHR_KIND_IN),intent(out) :: date  ! coded (yyyymmdd) calendar date

!EOP

   !--- local ---
   integer(SHR_KIND_IN) :: k,year,month,day

!-------------------------------------------------------------------------------
! ASSUMPTIONS:
!   this calendar has a year zero (but no day or month zero)
!-------------------------------------------------------------------------------

   year = eday/365       ! calendar year (note: Fortran truncation)
   day  = mod(eday,365)  ! elapsed days within current year
   do k=1,12
     IF (day >= dsm(k)) month=k   ! calendar month
   end do
   day = day-dsm(month) + 1         ! calendar day
  
   date = year*10000 + month*100 + day  ! coded calendar date

end subroutine shr_cal_eday2date

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_eday2ymd - converts elapsed days to year/month/day.
!
! !DESCRIPTION:
!     Converts elapsed days to year/month/day.
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

subroutine shr_cal_eday2ymd (eday,year,month,day)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in)  :: eday             ! elapsed days
   integer(SHR_KIND_IN),intent(out) :: year,month,day   ! calendar year,month,day

!EOP

   !--- local ---
   integer(SHR_KIND_IN) :: k

!-------------------------------------------------------------------------------
! ASSUMPTIONS:
!   this calendar has a year zero (but no day or month zero)
!-------------------------------------------------------------------------------

   year = eday/365       ! calendar year (note: Fortran truncation)
   day  = mod(eday,365)  ! elapsed days within current year
   do k=1,12
     IF (day .ge. dsm(k)) month=k   ! calendar month
   end do
   day = day-dsm(month) + 1         ! calendar day

end subroutine shr_cal_eday2ymd 

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_date2ymd - converts coded-date to year/month/day.
!
! !DESCRIPTION:
!     Converts coded-date (yyyymmdd) to year/month/day.
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

subroutine shr_cal_date2ymd (date,year,month,day)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in)  :: date             ! coded-date (yyyymmdd)
   integer(SHR_KIND_IN),intent(out) :: year,month,day   ! calendar year,month,day

!EOP

!-------------------------------------------------------------------------------
!
!-------------------------------------------------------------------------------

   if (.not. shr_cal_validDate(date)) then
      write(6,*) "(cal_date2ymd) ERROR: invalid date = ",date
   endif

   year =int(     date       /10000)
   month=int( mod(date,10000)/  100)
   day  =     mod(date,  100) 

end subroutine shr_cal_date2ymd 

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_date2eday - converts coded-date to elapsed days
!
! !DESCRIPTION:
!     Converts coded-date to elapsed days
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

subroutine shr_cal_date2eday(date,eday)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in ) :: date            ! coded (yyyymmdd) calendar date
   integer(SHR_KIND_IN),intent(out) :: eday            ! number of elapsed days

!EOP

   !--- local ---
   integer(SHR_KIND_IN) :: year,month,day

!-------------------------------------------------------------------------------
! NOTE:
!   elapsed days since yy-mm-dd = 00-01-01, with 0 elapsed seconds
!-------------------------------------------------------------------------------

   if (.not. shr_cal_validDate(date)) stop 

   year =int(     date       /10000)
   month=int( mod(date,10000)/  100)
   day  =     mod(date,  100) 

   eday = year*365 + dsm(month) + (day-1)

end subroutine shr_cal_date2eday

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_ymd2date - converts year, month, day to coded-date
!
! !DESCRIPTION:
!     Converts  year, month, day to coded-date
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

subroutine shr_cal_ymd2date(year,month,day,date)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in ) :: year,month,day  ! calendar year,month,day
   integer(SHR_KIND_IN),intent(out) :: date            ! coded (yyyymmdd) calendar date

!EOP

   !--- local ---

!-------------------------------------------------------------------------------
! NOTE:
!   this calendar has a year zero (but no day or month zero)
!-------------------------------------------------------------------------------

   if (.not. shr_cal_validYMD(year,month,day)) stop 

   date = year*10000 + month*100 + day  ! coded calendar date

end subroutine shr_cal_ymd2date

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_ymd2eday - converts year, month, day to elapsed days
!
! !DESCRIPTION:
!     Converts  year, month, day to elapsed days
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

subroutine  shr_cal_ymd2eday(year,month,day,eday)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in ) :: year,month,day  ! calendar year,month,day
   integer(SHR_KIND_IN),intent(out) :: eday            ! number of elapsed days

!EOP

   !--- local ---

!-------------------------------------------------------------------------------
! NOTE:
!   elapsed days since yy-mm-dd = 00-01-01, with 0 elapsed seconds
!-------------------------------------------------------------------------------

   if (.not. shr_cal_validYMD(year,month,day)) stop 

   eday = year*365 + dsm(month) + (day-1)

end subroutine  shr_cal_ymd2eday

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_validDate - determines if coded-date is a valid date
!
! !DESCRIPTION:
!    Determines if the given coded-date is a valid date.
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

logical function shr_cal_validDate(date) 

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in ) :: date            ! coded (yyyymmdd) calendar date

!EOP

   !--- local ---
   integer(SHR_KIND_IN) :: year,month,day

!-------------------------------------------------------------------------------
!
!-------------------------------------------------------------------------------

   year =int(     date       /10000)
   month=int( mod(date,10000)/  100)
   day  =     mod(date,  100) 

   shr_cal_validDate = .true.
   if (year  <    0) shr_cal_validDate = .false.
   if (year  > 9999) shr_cal_validDate = .false.
   if (month <    1) shr_cal_validDate = .false.
   if (month >   12) shr_cal_validDate = .false.
   if (day   <    1) shr_cal_validDate = .false.
   if (shr_cal_validDate) then
      if (day > dpm(month)) shr_cal_validDate = .false.
   endif

end function shr_cal_validDate

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_validYMD - determines if year, month, day is a valid date
!
! !DESCRIPTION:
!    Determines if the given year, month, and day indicate a valid date.
!
! !REVISION HISTORY:
!     2001-dec-28 - B. Kauffman - initial version, taken from cpl5
!
! !INTERFACE:  -----------------------------------------------------------------

logical function shr_cal_validYMD(year,month,day)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in ) :: year,month,day  ! calendar year,month,day

!EOP

   !--- local ---

!-------------------------------------------------------------------------------
!
!-------------------------------------------------------------------------------

   shr_cal_validYMD = .true.
   if (year  <    0) shr_cal_validYMD = .false.
   if (year  > 9999) shr_cal_validYMD = .false.
   if (month <    1) shr_cal_validYMD = .false.
   if (month >   12) shr_cal_validYMD = .false.
   if (day   <    1) shr_cal_validYMD = .false.
   if (shr_cal_validYMD) then
      if (day > dpm(month)) shr_cal_validYMD = .false.
   endif

end function shr_cal_validYMD

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_numDaysInMonth - return the number of days in a month.
!
! !DESCRIPTION:
!    Deturn the number of days in a month.
!
! !REVISION HISTORY:
!     2002-sep-18 - B. Kauffman - initial version.
!
! !INTERFACE:  -----------------------------------------------------------------

integer function shr_cal_numDaysInMonth(year,month)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in ) :: year,month  ! calendar year,month

!EOP

!-------------------------------------------------------------------------------
!
!-------------------------------------------------------------------------------

   shr_cal_numDaysInMonth = dpm(month)

end function shr_cal_numDaysInMonth

!===============================================================================
!BOP ===========================================================================
!
! !IROUTINE: shr_cal_elapsDaysStrtMonth - return the number of elapsed days
!            at start of month
!
! !DESCRIPTION:
!    Return the number of elapsed days at start of a month.
!
! !REVISION HISTORY:
!     2002-Oct-29 - R. Jacob - initial version
!
! !INTERFACE:  -----------------------------------------------------------------

integer function shr_cal_elapsDaysStrtMonth(year,month)

   implicit none

! !INPUT/OUTPUT PARAMETERS:

   integer(SHR_KIND_IN),intent(in ) :: year,month  ! calendar year,month

!EOP

!-------------------------------------------------------------------------------
!
!-------------------------------------------------------------------------------

   shr_cal_elapsDaysStrtMonth = dsm(month)

end function shr_cal_elapsDaysStrtMonth

!===============================================================================
!===============================================================================

end module shr_cal_mod
