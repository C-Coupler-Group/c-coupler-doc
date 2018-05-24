# $Id: makefile,v 1.1.2.6 2003/02/18 20:59:31 erik Exp $ 
ALL: lib 

CFLAGS    =
FFLAGS    =
SOURCEC	  = \
		ESMC_Alarm.c \
		ESMC_AlarmF.c \
		ESMC_Calendar.c \
		ESMC_Date.c \
		ESMC_DateF.c \
		ESMC_TOD.c \
		ESMC_Time.c \
		ESMC_TimeF.c \
		ESMC_TimeMgr.c \
		ESMC_TimeMgrF.c 

SOURCEF	  = \
		ESMF_TODMod.F \
		ESMF_CalendarMod.F \
		ESMF_TimeMod.F \
		ESMF_DateMod.F \
		ESMF_TimeMgrMod.F \
		ESMF_AlarmMod.F \
		ESMF_TimeMgmtMod.F 
SOURCEH	  = \
		ESMC_Alarm.h \
		ESMC_Calendar.h \
		ESMC_Date.h \
		ESMC_TOD.h \
		ESMC_Time.h \
		ESMC_TimeMgr.h                

OBJSC     = $(addsuffix .o, $(basename $(SOURCEC)))
OBJSF     = $(addsuffix .o, $(basename $(SOURCEF)))
TEXFILES  = $(addsuffix .tex, $(basename $(SOURCEF))) \
            $(addsuffix .tex, $(basename $(SOURCEH)))
MANSEC	  = Timeobj
LIBBASE	  = libesmf
DIRS	  = 
LOCDIR	  = src/Infrastructure/TimeMgmt/
CLEANFILES = $(LIBNAME) $(addprefix doc/, $(addsuffix .tex, $(basename $(SOURCEF))))

include ${ESMF_DIR}/build/${ESMF_ARCH}/base





