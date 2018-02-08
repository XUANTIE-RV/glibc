/* consider this code LGPL - davidm */

#ifdef __CSKYABIV2__
#include "abiv2_brk.c"
#else

#include <unistd.h>
#include <sys/syscall.h>
#include <errno.h>

/* This must be initialized data because commons can't have aliases.  */
void * __curbrk = 0;

/* Old braindamage in GCC's crtstuff.c requires this symbol in an attempt
   to work around different old braindamage in the old Linux/x86 ELF
   dynamic linker.  Sigh.  */
weak_alias (__curbrk, ___brk_addr)

int __brk (void *addr)
{
    void *newbrk;

    {
      register long int res __asm__("r2") = (long int)addr;

      __asm__ volatile ("lrw  r1, %1\n\t"
                        "trap 0\n\t"
                        :"+r" (res)
                        :"i" (__NR_brk) :"r1");
      newbrk = (void *) res;
    }
    __curbrk = newbrk;

    if (newbrk < addr)
    {
        __set_errno (ENOMEM);
	return -1;
    }

    return 0;
}

weak_alias (__brk, brk)

#endif
