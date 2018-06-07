/* Copyright (C) 2018 Free Software Foundation, Inc.
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

#include <sysdep.h>
#include <csky_readtp.h>

/* The syscall stubs jump here when they detect an error.
   The code for Linux is almost identical to the canonical Unix
   code, except that the error number in R0 is negated.  */

#undef CALL_MCOUNT
#define CALL_MCOUNT /* Don't insert the profiling call, it clobbers R0.  */

	.text
ENTRY(__syscall_error)
	movi	a1, 0
	rsub	a0, a0, a1

# if !IS_IN (rtld)
        mov     r7, r15
	mov	r1, r2
        csky_read_tp

        bsr     .Lgetpc1
.Lgetpc1:
        lrw     r5, errno@gottpoff
        add     r5, r15
        ldw     r5, (r5)
        add     r5, r2
        stw     r1, (r5)
        bmaski  r2, 0
	mov	r15, r7
        rts
# elif RTLD_PRIVATE_ERRNO /* !IS_IN (rtld) */
#  ifdef __PIC__
        mov     r7, r15
        bsr     .Lgetpc2
.Lgetpc2:
        lrw     r6, .Lgetpc2@GOTPC
        addu    r6, r15
        lrw     r5, rtld_errno@PLT
        addu    r5, r6
        ldw     r5, (r5)
	mov	r15, r7
#  else /* __PIC__ */
        lrw     r5, rtld_errno
#  endif /* __PIC__ */
        stw     r2, (r5)
        bmaski  r2, 0
        rts
# else
#  error "Unsupported non-TLS case"
# endif /* RTLD_PRIVATE_ERRNO */

END (__syscall_error)
