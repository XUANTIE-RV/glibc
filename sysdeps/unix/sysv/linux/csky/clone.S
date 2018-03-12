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

/* clone() is even more special than fork() as it mucks with stacks
   and invokes a function in the right context after its all over.  */

#ifdef	__CSKYABIV2__
# include "abiv2_clone.S"
#else

# include <sysdep.h>
# define _ERRNO_H	1
# include <bits/errno.h>
# include <csky_readtp.h>

# define CLONE_VM      8  /* 11 makes btsti easier, 0x00000100 in real */
# define CLONE_THREAD  16  /* 0x00010000 in real */

/* int clone(int (*fn)(void *arg), void *child_stack, int flags, void *arg,
	     pid_t *ptid, struct user_desc *tls, pid_t *ctid); */

        .text
ENTRY(__clone)
	/* Sanity check arguments. */
	cmpnei	r2, 0
	bf	__error_arg	/* no NULL function pointers */
	cmpnei	r3, 0
	bf	__error_arg	/* no NULL function pointers */

	subi	r3, 8
	stw	r2, (r3, 0)	/* insert the args onto the new stack */
	stw	r5, (r3, 4)	/* insert the args onto the new stack */

	ldw	r5, (sp, 0)	/* arg4 = ctid */
# ifdef RESET_PID
	subi	r3, 8
	stw	r4, (r3, 0x0)	/* save r4(flags) */
# endif

	mov	r2, r4		/* arg1 = flags */
	mov	r4, r6		/* arg3 = ptid */
	mov	r6, r7		/* arg5 = tls */
	lrw	r1, __NR_clone	/* do syscall */
	trap	0

	btsti	r2, 31		/* is r2 less than zero? */
	bt	do_syscall_error
	cmpnei	r2, 0
	bf	1f
	rts
PSEUDO_END (__clone)

1:
# ifdef RESET_PID
	ld.w    r4, (sp, 0x0)
	btsti	r4, CLONE_THREAD	/* judge flags */
	bt	3f
	csky_read_tp
	mov	r6, r2

	btsti	r4, CLONE_VM		/* judge flags */
	bmaski	r2, 0			/* if CLONE_VM not set, pid=tid=-1 */
	bt	2f
	lrw	r1, __NR_getpid		/* else get pid via getpid syscall */
	trap	0
2:
	lrw	r7, PID_OFFSET
	add	r7, r6
	stw	r2, (r7)	/* save pid */
	lrw	r7, TID_OFFSET
	add	r7, r6
	stw	r2, (r7)	/* save tid */
3:
	addi	sp, 8
# endif /* RESET_PID */
	ldw	r2, (sp, 4)	/* restore args from new sp */
	ldw	r3, (sp, 0)	/* restore args from new sp */
	addi	sp, 8

	jsr	r3
	lrw	r1, __NR_exit
	trap	0

__error_arg:
	lrw	r2, -EINVAL

do_syscall_error:
# ifdef __PIC__
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
# else
	jmpi	 __syscall_error
# endif /* __PIC__ */
	rts

libc_hidden_def (__clone)
weak_alias (__clone, clone)

#endif	/* __CSKYABIV2__*/
