/* BSD `setjmp' entry point to `sigsetjmp (..., 1)'.  MIPS version.
   Copyright (C) 1996, 1997, 2000 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <http://www.gnu.org/licenses/>.  */

/* This just does a tail-call to `__sigsetjmp (ARG, 1)'.
   We cannot do it in C because it must be a tail-call, so frame-unwinding
   in setjmp doesn't clobber the state restored by longjmp.  */

#include <sysdep.h>

ENTRY(setjmp)
	movi    a1, 1
#ifdef __PIC__
#ifdef  __CSKYABIV2__
        grs     t1, .Lgetpc
.Lgetpc:
        lrw     t0, .Lgetpc@GOTPC
        addu    t1, t0
        lrw     a3, __sigsetjmp@PLT
        addu    a3, t1
        ldw     a3, (a3)
#else
	mov	r7, lr
	bsr     .Lgetpc
.Lgetpc:
	lrw     a3, .Lgetpc@GOTPC
	addu    a3, lr
	lrw     a2, __sigsetjmp@PLT
	addu    a3, a2
	ldw     a3, (a3)
	mov     lr, r7
#endif
	jmp     a3
#else
	jmpi    __sigsetjmp
#endif

END(setjmp)

