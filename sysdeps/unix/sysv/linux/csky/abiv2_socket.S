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

#include <sysdep-cancel.h>
#include <socketcall.h>

#define P(a, b) P2(a, b)
#define P2(a, b) a##b

/* The socket-oriented system calls are handled unusally in Linux.
   They are all gated through the single `socketcall' system call number.
   `socketcall' takes two arguments: the first is the subcode, specifying
   which socket function is being called; and the second is a pointer to
   the arguments to the specific function.

   The .S files for the other calls just #define socket and #include this.  */

#ifndef NARGS
#ifdef socket
#error NARGS not defined
#endif
#define NARGS 3
#endif

#ifndef __socket
# ifndef NO_WEAK_ALIAS
#  define __socket P(__,socket)
# else
#  define __socket socket
# endif
#endif

ENTRY (__socket)
	subi	sp, 32
	.cfi_def_cfa_offset 32
#if NARGS >= 1
	stw a0, (sp, 0)
#endif

#if NARGS >= 2
	stw	a1, (sp, 4)
#endif

#if NARGS >= 3
	stw	a2, (sp, 8)
#endif

#if NARGS >= 4
	stw	a3, (sp, 12)
#endif

#if NARGS >= 5
	ldw	t0, (sp, 32)
	stw	t0, (sp, 16)
#endif

#if NARGS >= 6
	ldw	t0, (sp, 36)
	stw	t0, (sp, 20)
#endif

#if defined NEED_CANCELLATION && defined CENABLE
	stw	r15, (sp, 24)
	.cfi_offset 15, -8
	stw	gb, (sp, 28)
	.cfi_offset 28, -4
	SINGLE_THREAD_P
	bt	.Lsocket_cancel
#endif

	mov	t0, r7
	lrw	r7, __NR_socketcall
	movi	a0, P(SOCKOP_, socket)
	mov	a1, sp
	trap	0
	cfi_remember_state
	.cfi_def_cfa_offset 40
	addi	sp, 32
	.cfi_def_cfa_offset 0
	mov	r7, t0
	PSEUDO_RET

#if defined NEED_CANCELLATION && defined CENABLE
.Lsocket_cancel:
	/* GET GB */
	cfi_restore_state
	grs	gb, .Lgetpc
.Lgetpc:
	lrw	t0, .Lgetpc@GOTPC
	addu	gb, t0

	CENABLE
	mov	t1, a0	/* save CENABLE return value */
	mov	t0, r7
	lrw	r7, __NR_socketcall
	movi	a0, P(SOCKOP_, socket)
	mov	a1, sp
	trap	0
	stw	a0, (sp, 0)
	mov	r7, t0
	mov	a0, t1
	CDISABLE
	ldw	a0, (sp, 0)
	ldw	r15, (sp, 24)
	.cfi_restore 15
	ldw	gb, (sp, 28)
	.cfi_restore 28
	addi	sp, 32
	.cfi_def_cfa_offset 0
	btsti	a0, 31
	bf	3f
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	stw	r15, (sp, 4)
	/* must cal gb here, gb used by SYSCALL_ERROR ,why? FIXME */
	grs	gb, .Lgetpc2
.Lgetpc2:
	lrw	t0, .Lgetpc2@GOTPC
	addu	gb, gb, t0

	bsr	SYSCALL_ERROR
	ldw	r15, (sp, 4)
	ldw	gb, (sp, 0)
	addi	sp, 8
#else
	jmpi	SYSCALL_ERROR
#endif
3:
	rts
#endif

PSEUDO_END(__socket)

libc_hidden_def (__socket)
#ifndef NO_WEAK_ALIAS
weak_alias (__socket, socket)
#endif
