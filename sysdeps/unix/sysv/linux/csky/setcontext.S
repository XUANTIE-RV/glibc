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
# include "abiv2_setcontext.S"
#else

# include <sysdep.h>

# include "ucontext_i.h"

/* int setcontext (const ucontext_t *ucp) */

ENTRY(__setcontext)
	mov	r7, r2

	/* set sigmask */
	movi	r2, SIG_SETMASK
	lrw	r3, UCONTEXT_SIGMASK
	add	r3, r7 
	movi	r4, 0

	subi	sp, 8
	stw	r7, (sp, 0)	/* save r7(ucp) */

        /* do sigprocmask syscall */
# ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	stw	lr, (sp, 4)
	bsr	.Lgetpc1
.Lgetpc1:
	lrw	gb, .Lgetpc1@GOTPC
	addu	gb, r15
	lrw	r7, __sigprocmask@PLT
	addu	r7, gb
	ldw	r7, (r7)
	jsr	r7
	ldw	gb, (sp, 0)
	ldw	lr, (sp, 4)
	addi	sp, 8
# else
	jsri	__sigprocmask
# endif /* __PIC__ */

	ldw	r1, (sp, 0)	/* restore r7(ucp) */
	addi	sp, 8

	lrw	r2, MCONTEXT_CSKY_A0
	add	r2, r1

	/* set r2-r14. Load r2-r7, for makecontext requires */
	ldw	r3, (r2, 4)
	ldw	r4, (r2, 8)
	ldw	r5, (r2, 12)
	ldw	r6, (r2, 16)
	ldw	r7, (r2, 20)
	ldw	r8, (r2, 24)
	ldw	r9, (r2, 28)
	ldw	r10, (r2, 32)
	ldw	r11, (r2, 36)
	ldw	r12, (r2, 40)
	ldw	r13, (r2, 44)
	ldw	r14, (r2, 48)

	ldw	r15, (r2, 56)			/* load lr */

	lrw	r2, MCONTEXT_CSKY_SP
	add	r2, r1
	ldw	sp, (r2)			/* load sp */

	lrw	r2, MCONTEXT_CSKY_PC
	add	r2, r1
	ldw	r2, (r2)			/* load start addr */
	
	subi	sp, 8				/* for getcontext success */
	stw	r2, (sp, 0)
	lrw	r2, MCONTEXT_CSKY_A0
	add	r2, r1
	ldw	r2, (r2)			/* load a0 */
	ldw	r1, (sp, 0)
	addi	sp, 8

	jmp	r1
END(setcontext)
weak_alias(__setcontext, setcontext)

ENTRY(__startcontext)
	mov	a0, r9
	cmpnei	r9, 0		/* r9 was set in makecontext */
	bf	1f		/* null, then exit */

	/* call setcontext */
# ifdef __PIC__
	mov	r5, r15		/* save r15 */
	bsr	.Lgetpc2
.Lgetpc2:
	lrw	r6, .Lgetpc2@GOTPC
	addu	r6, r15
	lrw	r7, __setcontext@GOT
	addu	r7, r6
	ldw	r7, (r7)
	mov	r15, r5		/* restore r15 */
# else
	lrw	r7, __setcontext
# endif
	jsr	r7

1:
	lrw	r1, __NR_exit
	trap	0
END(__startcontext)

#endif	/* __CSKYAVBI2__*/
