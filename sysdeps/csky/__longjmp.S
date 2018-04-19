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

ENTRY(__longjmp)
	mov     a2, a0
	mov     a0, a1		/* get the return value in place */
	cmpnei  a0,	 0
	bt      have_return
	movi    a0, 1		/* can't let setjmp() return zero! */
have_return:
#ifdef CHECK_SP
	ldw     r10, (a2, 0)	/* jmpbuf's sp */
#ifdef PTR_MANGLE
        PTR_DEMANGLE(r10, r10, a3)
#endif
	CHECK_SP(r10)
#endif
#ifdef __CSKYABIV2__
	ldw     sp, (a2, 0)
	ldw     lr, (a2, 4)
	ldw     r4, (a2, 8)
	ldw     r5, (a2, 12)
	ldw     r6, (a2, 16)
	ldw     r7, (a2, 20)
	ldw     r8, (a2, 24)
	ldw     r9, (a2, 28)
	ldw     r10, (a2, 32)
	ldw     r11, (a2, 36)
	ldw     r16, (a2, 40)
	ldw     r17, (a2, 44)
	ldw     r26, (a2, 48)
	ldw     r27, (a2, 52)
	ldw     r28, (a2, 56)
	ldw     r29, (a2, 60)
	ldw     r30, (a2, 64)
	ldw     r31, (a2, 68)
	addi    a2, 72
#else
	ldw     sp, (a2, 0)
	ldw     lr, (a2, 4)
	ldw     r8, (a2, 8)
	ldw     r9, (a2, 12)
	ldw     r10, (a2, 16)
	ldw     r11, (a2, 20)
	ldw     r12, (a2, 24)
	ldw     r13, (a2, 28)
	ldw     r14, (a2, 32)
	addi    a2, 32
	addi	a2, 4
#endif

#ifdef PTR_MANGLE
#ifdef CHECK_SP
        PTR_DEMANGLE2(sp, sp, a3)
#else
        PTR_DEMANGLE(sp, sp, a3)
#endif
        PTR_DEMANGLE2(lr, lr, a3)
#endif
	jmp lr

END(__longjmp)
