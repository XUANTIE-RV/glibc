ifeq ($(subdir),csu)
gen-as-const-headers += tcb-offsets.sym
endif

ifeq ($(subdir),misc)
sysdep_headers += sysdep.h
endif

ifeq ($(subdir),signal)
sysdep_headers += sysdep.h
endif

ifeq ($(subdir),debug)
CFLAGS-backtrace.c += -funwind-tables
endif

ifeq ($(subdir),csu)
CPPFLAGS-crti.S += $(pic-ccflag)
CPPFLAGS-crtn.S += $(pic-ccflag)
endif

ifeq ($(subdir),nptl)
CPPFLAGS-pt-crti.S += $(pic-ccflag)
CPPFLAGS-crtn.S += $(pic-ccflag)
endif

ASFLAGS-.os += $(pic-ccflag)


ifeq ($(subdir),gmon)
sysdep_routines += csky-mcount
endif

