/* Copyright (C) 1996-2012 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Pat Beirne <patb@corelcomputer.com>

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

/* clone() is even more special than fork() as it mucks with stacks
   and invokes a function in the right context after its all over.  */

#include <sysdep.h>
#define _ERRNO_H	1
#include <bits/errno.h>
#include <csky_readtp.h>

#define CLONE_VM      8  /* 8 makes btsti easier, 0x00000100 in real */
#define CLONE_THREAD  16  /* 0x00010000 in real */

/* int clone(int (*fn)(void *arg), void *child_stack, int flags, void *arg,
	     pid_t *ptid, struct user_desc *tls, pid_t *ctid); */

        .text
ENTRY(__clone)
	/* Sanity check arguments.  */
	cmpnei	a0, 0		/* no NULL function pointers */
	bf	__error_arg
	cmpnei	a1, 0		/* no NULL function pointers */
	bf	__error_arg

	subi	a1, 8
	stw	a0, (a1, 0)	/* insert the args onto the new stack */
	stw	a3, (a1, 4)	/* insert the args onto the new stack */

#ifdef RESET_PID
	mov	t0, a2		/* save a2(flags) */
#endif
	mov	t1, r7		/* save r7 */
	mov	t2, r4		/* save r4 (has t2 ?)*/

	mov	a0, a2		/* arg1 = flags */
	ldw	a2, (sp, 0)	/* arg3 = ptid */
	ldw	a3, (sp, 8)	/* arg4 = ctid */
	ldw	r4, (sp, 4)	/* arg5 = tls */
	lrw	r7, __NR_clone
	trap	0

//	cfi_adjust_cfa_offset(-8)
//	cfi_restore(r4)
	mov	r7, t1		/* restore r7 */
	mov	r4, t2		/* restore r4 */
	btsti	a0, 31		/* is a0 less than zero? */
	bt	do_syscall_error
	cmpnei	a0, 0
	bf	1f
	rts
PSEUDO_END (__clone)

1:
#ifdef RESET_PID
	ldw	a2, (sp, 0)
	btsti	t0, CLONE_THREAD	/* judge flags */
	bt	3f
	csky_read_tp
	mov	a3, a0

	btsti	t0, CLONE_VM		/* judge flags */
	bmaski	a0, 0			/* if not set CLONE_VM, set pid=tid=-1*/
	bt	2f
	mov	t1, r7
	lrw	r7, __NR_getpid		/* else get pid via getpid syscall */
	trap	0
	mov	r7, t1
2:
	lrw	t0, PID_OFFSET
	add	t0, a3
	stw	a0, (t0)		/* save pid */
	lrw	t0, TID_OFFSET
	add	t0, a3
	stw	a0, (t0)		/* save tid */
	
3:
#endif
	ldw	a0, (sp, 4)	/* restore args from new sp */
	ldw	a1, (sp, 0)	/* restore args from new sp */
	addi	sp, 8
	jsr	a1

	/* exit */
#ifdef __PIC__
        grs     t1, .Lgetpc1
.Lgetpc1:
        lrw     t0, .Lgetpc1@GOTPC
        addu    t1, t1, t0
        lrw     t0, _exit@GOT
        ldr.w   t0, (t1, t0 << 0)
#else
        lrw     t0, _exit       /* exit */
#endif
        jmp     t0

	
__error_arg:
	lrw	a0, -EINVAL

do_syscall_error:
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	stw	r15, (sp, 4)
	grs	gb, .Lgetpc2
.Lgetpc2:
	lrw	t0, .Lgetpc2@GOTPC
	addu	gb, gb, t0
	lrw	t0, __syscall_error@PLT
	ldr.w	t0, (gb, t0 << 0)
	jsr	t0
	ldw	gb, (sp, 0)
	ldw	r15, (sp, 4)
	addi	sp, 8
#else
	jmpi	__syscall_error
#endif
	rts

libc_hidden_def (__clone)
weak_alias (__clone, clone)
