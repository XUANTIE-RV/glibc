/* The assembly function for memcpy.  C-SKY version.
   Copyright (C) 2018 Free Software Foundation, Inc.
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

.macro	GET_FRONT_BITS rx ry
#ifdef	__cskyLE__
	lsr 	\rx, \ry
#else
	lsl 	\rx, \ry
#endif
.endm

.macro	GET_AFTER_BITS rx ry
#ifdef	__cskyLE__
	lsl 	\rx, \ry
#else
	lsr     \rx, \ry
#endif
.endm

ENTRY(memcpy)
	/* If len less than 4 bytes */
	mov     r3, r0
	cmplti  r2, 4
	jbt     .L_copy_by_byte

	mov     r12, r0
	andi    r12, 3
	/* If dest is not 4 bytes aligned */
	bnez    r12, .L_dest_not_aligned
.L0:
	/* If dest is aligned, but src is not aligned */
	mov     r12, r1
	andi    r12, 3
	bnez    r12, .L_dest_aligned_but_src_not_aligned

	/* dest and src are all aligned */
	cmplti  r2, 16
	/* If len less than 16 bytes */
	jbt     .L_aligned_and_len_less_16bytes

	/* src and dst are all aligned, and len > 16 bytes */
.L_aligned_and_len_larger_16bytes:
	ldw     r18, (r1, 0)
	ldw     r19, (r1, 4)
	ldw     r20, (r1, 8)
	ldw     r21, (r1, 12)
	stw     r18, (r3, 0)
	stw     r19, (r3, 4)
	stw     r20, (r3, 8)
	stw     r21, (r3, 12)
	subi    r2, 16
	addi    r1, 16
	addi    r3, 16
	cmplti  r2, 16
	jbf     .L_aligned_and_len_larger_16bytes

.L_aligned_and_len_less_16bytes:
	cmplti  r2, 4
	jbt     .L_copy_by_byte
	ldw     r18, (r1, 0)
	stw     r18, (r3, 0)
	subi    r2, 4
	addi    r1, 4
	addi    r3, 4
	jbr     .L_aligned_and_len_less_16bytes

	/* len less than 4 bytes */
.L_copy_by_byte:
	cmpnei  r2, 0
	jbf     .L_return
	ldb     r18, (r1, 0)
	stb     r18, (r3, 0)
	subi    r2, 1
	addi    r1, 1
	addi    r3, 1
	jbr     .L_copy_by_byte

.L_return:
	rts

	/* If dest is not aligned, just copying some bytes makes the dest align.
	After that, we judge whether the src is aligned. */

	/* consider overlapped case */
.L_dest_not_aligned:
	rsub    r13, r1, r3
	abs     r13, r13
	cmplt   r13, r2
	jbt     .L_copy_by_byte

.L1:
	/* makes the dest align. */
	ldb     r18, (r1, 0)
	stb     r18, (r3, 0)
	addi    r12, 1
	subi    r2, 1
	addi    r1, 1
	addi    r3, 1
	cmpnei  r12, 4
	jbt     .L1
	cmplti  r2, 4
	jbt     .L_copy_by_byte
	/* judge whether the src is aligned. */
	jbf     .L0

	/* consider overlapped case */
.L_dest_aligned_but_src_not_aligned:
	rsub    r13, r1, r3
	abs     r13, r13
	cmplt   r13, r2
	jbt     .L_copy_by_byte

	bclri   r1, 0
	bclri   r1, 1
	ldw     r18, (r1, 0)
	addi    r1, 4

	/* r12 is used to store the misaligned bits */
	movi    r13, 8
	mult    r13, r12
	mov     r24, r13
	rsubi   r13, 32
	mov     r25, r13

	cmplti  r2, 16
	jbt     .L_not_aligned_and_len_less_16bytes

.L_not_aligned_and_len_larger_16bytes:
	ldw     r20, (r1, 0)
	ldw     r21, (r1, 4)
	ldw     r22, (r1, 8)
	ldw     r23, (r1, 12)

	/* little or big endian? */
	GET_FRONT_BITS r18 r24
	mov     r19, r20
	GET_AFTER_BITS r20 r25
	or      r20, r18

	GET_FRONT_BITS r19 r24
	mov     r18, r21
	GET_AFTER_BITS r21 r13
	or      r21, r19

	GET_FRONT_BITS r18 r24
	mov     r19, r22
	GET_AFTER_BITS r22 r25
	or      r22, r18

	GET_FRONT_BITS r19 r24
	mov     r18, r23
	GET_AFTER_BITS r23 r25
	or      r23, r19

	stw     r20, (r3, 0)
	stw     r21, (r3, 4)
	stw     r22, (r3, 8)
	stw     r23, (r3, 12)
	subi    r2, 16
	addi    r1, 16
	addi    r3, 16
	cmplti  r2, 16
	jbf     .L_not_aligned_and_len_larger_16bytes

	.L_not_aligned_and_len_less_16bytes:
	cmplti  r2, 4
	jbf     .L2
	/* r12 is used to stored the misaligned bits */
	rsubi   r12, 4
	/* initial the position */
	subu    r1, r12
	jbr     .L_copy_by_byte
	.L2:
	ldw     r21, (r1, 0)
	GET_FRONT_BITS r18 r24
	mov     r19, r18
	mov     r18, r21
	GET_AFTER_BITS r21 r25
	or      r21, r19
	stw     r21, (r3, 0)
	subi    r2, 4
	addi    r1, 4
	addi    r3, 4
	jbr     .L_not_aligned_and_len_less_16bytes

END(memcpy)

libc_hidden_builtin_def(memcpy)
.weak memcpy
