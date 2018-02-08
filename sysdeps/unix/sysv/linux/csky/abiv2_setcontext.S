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

/* int setcontext (const ucontext_t *ucp) */

ENTRY(__setcontext)
	mov	t0, a0
	subi	sp, 8
	stw	a0, (sp, 0)

#ifdef __csky_hard_float__
//	addi	t1, a0, MCONTEXT_CSKY_FR0
//	/* set fpu registers first, for a0, a1, a2... will change here */
//	ldw	a0, (t1, 0)
//	ldw	a1, (t1, 4)
//	ldw	a2, (t1, 8)
//	ldw	a3, (t1, 12)
//	fmtvrl	vr0, a0
//	fmtvrh	vr0, a1
//	fmtvrl	vr1, a2
//	fmtvrh	vr1, a3
//	ldw	a0, (t1, 16)
//	ldw	a1, (t1, 20)
//	ldw	a2, (t1, 24)
//	ldw	a3, (t1, 28)
//	fmtvrl	vr2, a0
//	fmtvrh	vr2, a1
//	fmtvrl	vr3, a2
//	fmtvrh	vr3, a3
//	ldw	a0, (t1, 32)
//	ldw	a1, (t1, 36)
//	ldw	a2, (t1, 40)
//	ldw	a3, (t1, 44)
//	fmtvrl	vr, a0
//	fmtvrh	vr4, a1
//	fmtvrl	vr4, a2
//	fmtvrh	vr5, a3
//	ldw	a05, (t1, 48)
//	ldw	a1, (t1, 52)
//	ldw	a2, (t1, 56)
//	ldw	a3, (t1, 60)
//	fmtvrl	vr6, a0
//	fmtvrh	vr6, a1
//	fmtvrl	vr7, a2
//	fmtvrh	vr7, a3
//	ldw	a0, (t1, 64)
//	ldw	a1, (t1, 68)
//	ldw	a2, (t1, 72)
//	ldw	a3, (t1, 76)
//	fmtvrl	vr8, a0
//	fmtvrh	vr8, a1
//	fmtvrl	vr9, a2
//	fmtvrh	vr9, a3
//	ldw	a0, (t1, 80)
//	ldw	a1, (t1, 84)
//	ldw	a2, (t1, 88)
//	ldw	a3, (t1, 92)
//	fmtvrl	vr10, a0
//	fmtvrh	vr10, a1
//	fmtvrl	vr11, a2
//	fmtvrh	vr11, a3
//	ldw	a0, (t1, 96)
//	ldw	a1, (t1, 100)
//	ldw	a2, (t1, 104)
//	ldw	a3, (t1, 108)
//	fmtvrl	vr12, a0
//	fmtvrh	vr12, a1
//	fmtvrl	vr13, a2
//	fmtvrh	vr13, a3
//	ldw	a0, (t1, 112)
//	ldw	a1, (t1, 116)
//	ldw	a2, (t1, 120)
//	ldw	a3, (t1, 124)
//	fmtvrl	vr14, a0
//	fmtvrh	vr14, a1
//	fmtvrl	vr15, a2
//	fmtvrh	vr15, a3
#endif

	/* set sigmask */
	movi	a0, SIG_SETMASK
	addi	a1, t0, UCONTEXT_SIGMASK
	movi	a2, 0

	 /* do sigprocmask syscall */
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0) 
	grs	gb, .Lgetpc1
.Lgetpc1:
	lrw	a3, .Lgetpc1@GOTPC
	addu	gb, gb, a3
	lrw	a3, __sigprocmask@PLT
	ldr.w	a3, (gb, a3 << 0)
	jsr	a3
	ldw	gb, (sp, 0)
	addi	sp, 8
#else
	jsri	__sigprocmask
#endif

	ldw	t0, (sp, 0)
	addi	sp, 8
	/* set r0-r11. Load a0-a3, for makecontext requires */
	addi	t1, t0, MCONTEXT_CSKY_A0
	ldm	r0-r11, (t1)
	ldw	sp, (t0, MCONTEXT_CSKY_SP)	/* load sp */
	ldw	r15, (t0, MCONTEXT_CSKY_LR)	/* load lr */
	ldw	t0, (t0, MCONTEXT_CSKY_PC)	/* load start addr */
	jmp	t0
END(setcontext)
weak_alias(__setcontext, setcontext)

ENTRY(__startcontext)
	mov	a0, r9
	cmpnei	r9, 0	/* r9 was set in makecontext */
	bf	1f	/* null, then exit */

	/* call setcontext */
#ifdef __PIC__  
	grs	t1, .Lgetpc2
.Lgetpc2:
	lrw	t0, .Lgetpc2@GOTPC
	addu	t1, t1, t0
	lrw	t0, __setcontext@GOT
	ldr.w	t0, (t1, t0 << 0)
#else
	lrw	t0, __setcontext
#endif
	jsr	t0

1:
	/* call _exit */
#ifdef __PIC__  
	grs	t1, .Lgetpc3
.Lgetpc3:
	lrw	t0, .Lgetpc3@GOTPC
	addu	t1, t1, t0
	lrw	t0, _exit@GOT
	ldr.w	t0, (t1, t0 << 0)
#else
	lrw	t0, _exit
#endif
	jsr	t0

END(__startcontext)
