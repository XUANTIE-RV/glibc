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

#ifdef __CSKYABIV2__
#include "abiv2_getcontext.S"
#else

#include <sysdep.h>

#include "ucontext_i.h"

/* int getcontext (ucontext_t *ucp) */

ENTRY(__getcontext)
	/* No need to save r2-r7 or a0-a3 */
	mov	r7, r2

	/* return zero */
	lrw	r2, MCONTEXT_CSKY_A0
	add	r2, r7
	movi	r1, 0
	stw	r1, (r2)

	lrw	r2, MCONTEXT_CSKY_R8
	add	r2, r7
	stw	r8, (r2, 0)			/* save r8 */
	stw	r9, (r2, 4)			/* save r9 */
	stw	r10, (r2, 8)			/* save r10 */
	stw	r11, (r2, 12)			/* save r11 */
	stw	r12, (r2, 16)			/* save r12 */
	stw	r13, (r2, 20)			/* save r13 */
	stw	r14, (r2, 24)			/* save r14 */
	stw	r15, (r2, 28)			/* save lr */


	lrw	r2, MCONTEXT_CSKY_SP
	add	r2, r7
	stw	sp, (r2)			/* save sp */

	lrw	r2, MCONTEXT_CSKY_LR
	add	r2, r7
	stw	r15, (r2)			/* Return to LR */

	lrw	r2, MCONTEXT_CSKY_PC
	add	r2, r7
	stw	r15, (r2)			/* Return to LR */

	lrw	r2, MCONTEXT_CSKY_A0
	add	r2, r7
	movi	r3, 0
	stw	r3, (r2)			/* Return zero */

	/* __sigprocmask(SIG_BLOCK, NULL, &(ucontext->uc_sigmask)) */
	lrw	r2, SIG_BLOCK
	movi	r3, 0
	lrw	r4, UCONTEXT_SIGMASK
	add	r4, r7

	subi	sp, 8
	stw	r7, (sp, 0)

	/* do sigprocmask syscall */
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	stw	lr, (sp, 4)
	bsr	.Lgetpc
.Lgetpc:
	lrw	gb, .Lgetpc@GOTPC
	addu	gb, r15
	lrw	r7, __sigprocmask@PLT
	addu	r7, gb
	ldw	r7, (r7)
	jsr	r7
	ldw	gb, (sp, 0)
	ldw	lr, (sp, 4)
	addi	sp, 8
#else
        jsri	__sigprocmask
#endif

	ldw	r7, (sp, 0)
	addi	sp, 8
	lrw	r2, MCONTEXT_CSKY_LR
	add	r2, r7
	/* restore r15 for sigprocmask changes */
	ldw	r15, (r2)
	movi	r2, 0				/* return 0 */
	jmp	r15
END(__getcontext)

weak_alias(__getcontext, getcontext)

#endif	/* __CSKYABIV2__*/
