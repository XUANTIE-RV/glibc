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
#ifndef	__CSKYABIV2__
	/* If len less than 4 bytes */
	mov     r7, r2
	cmplti  r4, 4
	jbt     .L_copy_by_byte

	/* If dest is not 4 bytes aligned */
	mov     r6, r2
	andi    r6, 3
	cmpnei  r6, 0
	jbt     .L_dest_not_aligned
	.L0:
	mov     r6, r3
	andi    r6, 3
	cmpnei  r6, 0
	/* If dest is aligned, but src is not aligned */
	jbt     .L_dest_aligned_but_src_not_aligned     

	/* If dest and src are all aligned and len less than 16 bytes */
	cmplti  r4, 16                                  
	jbt     .L_aligned_and_len_less_16bytes

	/* src and dst are all aligned, and len > 16 bytes */
	subi    sp, 8
	stw     r8, (sp, 0)
	stw     r9, (sp, 4)
.L_aligned_and_len_larger_16bytes:                  
	ldw     r1, (r3, 0)
	ldw     r5, (r3, 4)
	ldw     r8, (r3, 8)
	ldw     r9, (r3, 12)
	stw     r1, (r7, 0)
	stw     r5, (r7, 4)
	stw     r8, (r7, 8)
	stw     r9, (r7, 12)
	subi    r4, 16
	addi    r3, 16
	addi    r7, 16
	cmplti  r4, 16
	jbf     .L_aligned_and_len_larger_16bytes
	ldw     r8, (sp, 0)
	ldw     r9, (sp, 4)
	addi    sp, 8

.L_aligned_and_len_less_16bytes:
	cmplti  r4, 4
	jbt     .L_copy_by_byte
	ldw     r1, (r3, 0)
	stw     r1, (r7, 0)
	subi    r4, 4
	addi    r3, 4
	addi    r7, 4
	jbr     .L_aligned_and_len_less_16bytes

	/* len less than 4 bytes */
.L_copy_by_byte:
	cmpnei  r4, 0
	jbf     .L_return
	ldb     r1, (r3, 0)
	stb     r1, (r7, 0)
	subi    r4, 1
	addi    r3, 1
	addi    r7, 1
	jbr     .L_copy_by_byte

.L_return:
	rts

	/* If dest is not aligned, we copy some bytes to make dest align.
	Then we should judge whether src is aligned. */

	/* consider overlapped case */
.L_dest_not_aligned:
	mov     r5, r3
	rsub    r5, r5, r7
	abs     r5, r5
	cmplt   r5, r4
	jbt     .L_copy_by_byte

	/* Makes the dest align. */
.L1:
	ldb     r1, (r3, 0)
	stb     r1, (r7, 0)
	addi    r6, 1
	subi    r4, 1
	addi    r3, 1
	addi    r7, 1
	cmpnei  r6, 4
	jbt     .L1
	cmplti  r4, 4
	jbt     .L_copy_by_byte
	/* Judge whether the src is aligned. */
	jbf     .L0                                     

	/* consider overlapped case */
.L_dest_aligned_but_src_not_aligned:
	mov     r5, r3
	rsub    r5, r5, r7
	abs     r5, r5
	cmplt   r5, r4
	jbt     .L_copy_by_byte

	bclri   r3, 0
	bclri   r3, 1
	ldw     r1, (r3, 0)
	addi    r3, 4

	subi    sp, 16
	stw     r11, (sp,0)
	stw     r12, (sp,4)
	stw     r13, (sp,8)
	movi    r5, 8
	/* r6 is used to store tne misaligned bits */
	mult    r5, r6
	mov     r12, r5
	rsubi   r5, 31
	addi    r5, 1
	mov     r13, r5

	cmplti  r4, 16
	jbt     .L_not_aligned_and_len_less_16bytes

	stw     r8, (sp, 12)
	subi    sp, 8
	stw     r9, (sp, 0)
	stw     r10, (sp, 4)
.L_not_aligned_and_len_larger_16bytes:
	ldw     r5, (r3, 0)
	ldw     r11, (r3, 4)
	ldw     r8, (r3, 8)
	ldw     r9, (r3, 12)

	/* little or big endian? */
	GET_FRONT_BITS r1 r12
	mov     r10, r5
	GET_AFTER_BITS r5 r13
	or      r5, r1

	GET_FRONT_BITS r10 r12
	mov     r1, r11
	GET_AFTER_BITS r11 r13
	or      r11, r10

	GET_FRONT_BITS r1 r12
	mov     r10, r8
	GET_AFTER_BITS r8 r13
	or      r8, r1

	GET_FRONT_BITS r10 r12
	mov     r1, r9
	GET_AFTER_BITS r9 r13
	or      r9, r10

	stw     r5, (r7, 0)
	stw     r11, (r7, 4)
	stw     r8, (r7, 8)
	stw     r9, (r7, 12)
	subi    r4, 16
	addi    r3, 16
	addi    r7, 16
	cmplti  r4, 16
	jbf     .L_not_aligned_and_len_larger_16bytes
	ldw     r9, (sp, 0)
	ldw     r10, (sp, 4)
	addi    sp, 8
	ldw     r8, (sp,12)

.L_not_aligned_and_len_less_16bytes:
	cmplti  r4, 4
	jbf     .L2
	/* r6 is used to stored the misaligned bits */
	rsubi   r6, 4
	/* initial the position */                                  
	subu    r3, r6
	ldw     r11, (sp, 0)
	ldw     r12, (sp, 4)
	ldw     r13, (sp, 8)
	addi    sp, 16
	jbr     .L_copy_by_byte
	.L2:
	ldw     r5, (r3, 0)
	GET_FRONT_BITS r1 r12
	mov     r11, r1
	mov     r1, r5
	GET_AFTER_BITS r5 r13
	or      r5, r11
	stw     r5, (r7, 0)
	subi    r4, 4
	addi    r3, 4
	addi    r7, 4
	jbr     .L_not_aligned_and_len_less_16bytes

#else /* __CSKYABIV2__ */
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

# endif
END(memcpy)

libc_hidden_builtin_def(memcpy)
.weak memcpy
