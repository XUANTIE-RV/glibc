ifeq ($(subdir),csu)
sysdep_routines += read_tp libc-read_tp
static-only-routines += read_tp
shared-only-routines += libc-read_tp
endif

ifeq ($(subdir),elf)
sysdep-rtld-routines += read_tp
endif

ifeq ($(subdir), malloc)
libmemusage-routines += read_tp
endif
