ifeq ($(subdir),csu)
gen-as-const-headers += tcb-offsets.sym
endif

ifeq ($(subdir),debug)
CFLAGS-backtrace.c += -funwind-tables
endif

ASFLAGS-.os += $(pic-ccflag)

ifeq ($(subdir),gmon)
sysdep_routines += csky-mcount
endif

