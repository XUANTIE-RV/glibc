/* Copyright (C) 2005, 2009 Free Software Foundation, Inc.
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

#ifdef __CSKYABIV2__
#include "abiv2_syscall.S"
#else

#include <sysdep.h>

ENTRY (syscall)
	mov	r1, r2		/* syscall num */

	mov	r2, r3		/* arg1 */
	mov	r3, r4		/* arg2 */
	mov	r4, r5		/* arg3 */
	mov	r5, r6		/* arg4*/
	mov	r6, r7		/* arg5*/
	ld	r7, (sp, 0)	/* arg6 */
	trap	0
	lrw	r3, 0xfffff000
	cmphs	r2, r3
	bt	do_syscall_error
	rts
PSEUDO_END (syscall)

do_syscall_error:
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	stw	r15, (sp, 4)
	bsr	.Lgetpc
.Lgetpc:
	lrw	gb, .Lgetpc@GOTPC
	addu	gb, r15
	lrw	r7, __syscall_error@PLT
	addu	r7, gb
	ldw	r7, (r7)
	jsr	r7
	ldw	gb, (sp, 0)
	ldw	r15, (sp, 4)
	addi	sp, 8
#else
	jmpi	__syscall_error
#endif
	rts

#endif	/* __CSKYABVI2__ */
