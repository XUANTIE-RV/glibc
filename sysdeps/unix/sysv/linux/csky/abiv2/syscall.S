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

/* long syscall(long sysnum, long a, long b, long c, long d, long e, long f) */

ENTRY (syscall)
	subi	sp, 8
	stw	r4, (sp, 0)
	stw	r5, (sp, 4)

	mov	t0, r7
	mov	r7, a0		/* r7 = sysnum */

	mov	a0, a1		/* arg1 = a */
	mov	a1, a2		/* arg2 = b */
	mov	a2, a3		/* arg3 = c */
	ldw	a3, (sp, 8)	/* arg4 = d */
	ldw	r4, (sp, 12)	/* arg5 = e */
	ldw	r5, (sp, 16)	/* arg6 = f */
	trap	0

	mov	r7, t0

	ldw	r4, (sp, 0)
	ldw	r5, (sp, 4)
	addi	sp, 8

	lrw	t0, 0xfffff000
	cmphs	a0, t0
	bt	do_syscall_error
	rts
PSEUDO_END (syscall)

do_syscall_error:
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
        stw     lr, (sp, 4)
	grs	gb, .Lgetpc
.Lgetpc:
	lrw	t0, .Lgetpc@GOTPC
	addu	gb, gb, t0
	lrw	t0, __syscall_error@PLT
	ldr.w	t0, (gb, t0 << 0)
	jsr	t0
	ldw	gb, (sp, 0)
        ldw     lr, (sp, 4)
	addi	sp, 8
#else
	jmpi	__syscall_error
#endif /* __PIC__ */
	rts
