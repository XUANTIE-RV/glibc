ifeq ($(subdir),csu)
sysdep_routines += read_tp libc-read_tp
static-only-routines += read_tp
shared-only-routines += libc-read_tp
endif

ifeq ($(subdir),elf)
sysdep-rtld-routines += read_tp
endif

#ifeq ($(subdir),iconv)
#sysdep_routines += read_tp
##static-only-routines += read_tp
##shared-only-routines += read_tp
#endif

ifeq ($(subdir),misc)
sysdep_routines += cacheflush
sysdep_headers += sys/cachectl.h
endif

ifeq ($(subdir),resource)
#sysdep_routines += oldgetrlimit64
endif

ifeq ($(subdir),stdlib)
gen-as-const-headers += ucontext_i.sym 
endif

ifeq ($(subdir), csky)
sysdep_headers += csky_readtp.h
endif

ifeq ($(subdir), malloc)
libmemusage-routines += read_tp
endif


