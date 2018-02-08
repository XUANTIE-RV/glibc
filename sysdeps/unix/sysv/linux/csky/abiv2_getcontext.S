/* Copyright (C) 2012 Free Software Foundation, Inc.
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
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#include <sysdep.h>

#include "ucontext_i.h"

/* int getcontext (ucontext_t *ucp) */

ENTRY(__getcontext)
	/* No need to save r2-r7 or a0-a3 */
	mov	t0, a0

	addi	a0, MCONTEXT_CSKY_R4

	stm	r4-r13, (a0)		/* save r4-r13 */
	stw	sp, (t0, MCONTEXT_CSKY_SP)	/* save sp */
	stw	r15, (t0, MCONTEXT_CSKY_LR)	/* save lr */
	stw	r15, (t0, MCONTEXT_CSKY_PC)	/* Return to PC */
	addi	a0, t0, MCONTEXT_CSKY_R16
	stm	r16-r31, (a0)			/* save r16-r31 */
	movi	a0, 0
	stw	a0, (t0, MCONTEXT_CSKY_A0)	/* Return zero */

	subi	sp, 8
	stw	t0, (sp, 0)	/* save t0 after "save sp" */

//	stw	t1, (t0, MCONTEXT_CSKY_HI)	/* save hi */
//	stw	t1, (t0, MCONTEXT_CSKY_LO)	/* save lo */

	/* __sigprocmask(SIG_BLOCK, NULL, &(ucontext->uc_sigmask)) */
	movi	a0, SIG_BLOCK
	movi	a1, 0
	addi	a2, t0, UCONTEXT_SIGMASK

	/* do sigprocmask syscall */
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	grs	gb, .Lgetpc
.Lgetpc:
	lrw	a3, .Lgetpc@GOTPC
	addu	gb, gb, a3
	lrw	a3, __sigprocmask@PLT
	ldr.w	a3, (gb, a3 << 0)
	jsr	a3
	ldw	gb, (sp, 0)
	addi	sp, 8
#else
	jsri    __sigprocmask
#endif

#ifdef __csky_hard_float__
	/* cannot access to fesr fsr fcr in user mode,
           save fpu common regs only */
//	addi	t1, t0, MCONTEXT_CSKY_FR0
//	fmfvrl	a0, vr0
//	fmfvrl	a0, vr0
//	fmfvrh	a1, vr0
//	fmfvrl	a2, vr1
//	fmfvrh	a3, vr1
//	stw	a0, (t1, 0)	/* save vr0 low 32 bits */
//	stw	a1, (t1, 4)	/* save vr0 high 32 bits */
//	stw	a2, (t1, 8)	/* save vr1 low 32 bits */
//	stw	a3, (t1, 12)	/* save vr1 high 32 bits */
//	fmfvrl	a0, vr2
//	fmfvrh	a1, vr2
//	fmfvrl	a2, vr3
//	fmfvrh	a3, vr3
//	stw	a0, (t1, 16)
//	stw	a1, (t1, 20)
//	stw	a2, (t1, 24)
//	stw	a3, (t1, 28)
//	fmfvrl	a0, vr4
//	fmfvrh	a1, vr4
//	fmfvrl	a2, vr5
//	fmfvrh	a3, vr5
//	stw	a0, (t1, 32)
//	stw	a1, (t1, 36)
//	stw	a2, (t1, 40)
//	stw	a3, (t1, 44)
//	fmfvrl	a0, vr6
//	fmfvrh	a1, vr6
//	fmfvrl	a2, vr7
//	fmfvrh	a3, vr7
//	stw	a0, (t1, 48)
//	stw	a1, (t1, 52)
//	stw	a2, (t1, 56)
//	stw	a3, (t1, 60)
//	fmfvrl	a0, vr8
//	fmfvrh	a1, vr8
//	fmfvrl	a2, vr9
//	fmfvrh	a3, vr9
//	stw	a0, (t1, 64)
//	stw	a1, (t1, 68)
//	stw	a2, (t1, 72)
//	stw	a3, (t1, 76)
//	fmfvrl	a0, vr10
//	fmfvrh	a1, vr10
//	fmfvrl	a2, vr11
//	fmfvrh	a3, vr11
//	stw	a0, (t1, 80)
//	stw	a1, (t1, 84)
//	stw	a2, (t1, 88)
//	stw	a3, (t1, 92)
//	fmfvrl	a0, vr12
//	fmfvrh	a1, vr12
//	fmfvrl	a2, vr13
//	fmfvrh	a3, vr13
//	stw	a0, (t1, 96)
//	stw	a1, (t1, 100)
//	stw	a2, (t1, 104)
//	stw	a3, (t1, 108)
//	fmfvrl	a0, vr14
//	fmfvrh	a1, vr14
//	fmfvrl	a2, vr15
//	fmfvrh	a3, vr15
//	stw	a0, (t1, 112)
//	stw	a1, (t1, 116)
//	stw	a2, (t1, 120)
//	stw	a3, (t1, 124)
#endif

	ldw	t0, (sp, 0)
	addi	sp, 8
	ldw	r15, (t0, MCONTEXT_CSKY_LR)	/* restore r15 for sigprocmask changes*/
	movi	a0, 0				/* return 0 */
	jmp	r15
END(__getcontext)

weak_alias(__getcontext, getcontext)
