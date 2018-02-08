/* Copyright (C) 1996, 1997, 1998, 2010, 2012 Free Software Foundation, Inc.
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
#include "abiv2_socket.S"
#else

#include <sysdep-cancel.h>
#include <socketcall.h>

#define P(a, b) P2(a, b)
#define P2(a, b) a##b

	.text
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


.globl __socket
ENTRY (__socket)
	subi	sp, 32
	subi	sp, 8
	.cfi_def_cfa_offset 40
#if NARGS >= 1
	stw	r2, (sp, 0)
	.cfi_offset 2, -40
#endif

#if NARGS >= 2
	stw	r3, (sp, 4)
	.cfi_offset 3, -36
#endif

#if NARGS >= 3
	stw	r4, (sp, 8)
	.cfi_offset 4, -32
#endif

#if NARGS >= 4
	stw	r5, (sp, 12)
	.cfi_offset 5, -28
#endif

#if NARGS >= 5
	stw	r6, (sp, 16)
	.cfi_offset 6, -24
#endif

#if NARGS >= 6
	stw	r7, (sp, 20)
	.cfi_offset 7, -20
#endif

#if defined NEED_CANCELLATION && defined CENABLE
	stw	r15, (sp, 24)
	.cfi_offset 15, -16
	st.w	r14, (sp, 28)
	.cfi_offset 14, -12
	st.w	r9, (sp, 32) 
	.cfi_offset 9, -8
	SINGLE_THREAD_P
	bt	.Lsocket_cancel
#endif

	lrw	r1, __NR_socketcall
	movi	r2, P(SOCKOP_, socket)
	mov	r3, sp
	trap	0
	cfi_remember_state
	.cfi_def_cfa_offset 40
	addi	sp, 32
	addi	sp, 8
	.cfi_def_cfa_offset 0
	mov     r1, r15
	PSEUDO_RET

#if defined NEED_CANCELLATION && defined CENABLE
.Lsocket_cancel:
	cfi_restore_state
	/* GET GB */
	bsr	1f
1:
	lrw	r14, 1b@GOTPC
	add	r14, lr

	CENABLE  
	mov	r4, r2	/* save CENABLE return value */
	lrw	r1, __NR_socketcall
	movi	r2, P(SOCKOP_, socket)
	mov	r3, sp
	trap	0
	mov	r9, r2 	/* (sp,0) save r9  */
	mov	r2, r4
	CDISABLE
	mov	r2, r9
	ldw	r15, (sp, 24)
	.cfi_restore 15
	ldw	r14, (sp, 28)
	.cfi_restore 14
	ldw	r9, (sp, 32)
	.cfi_restore 9
	addi	sp, 32
	addi	sp, 8
	.cfi_def_cfa_offset 0
	btsti	r2, 31
	bf	3f
#ifdef __PIC__
	subi	sp, 8
	.cfi_def_cfa_offset 8
	stw	gb, (sp, 0)
	.cfi_offset 14, -8
	stw	r15, (sp, 4)
	.cfi_offset 15, -4
	bsr     .Lgetpc
.Lgetpc:
	lrw     gb, .Lgetpc@GOTPC
	addu    gb, r15
	lrw     r7, SYSCALL_ERROR@GOTOFF
	addu    r7, gb
	jsr	r7
	ldw	gb, (sp, 0)
	ldw	r15, (sp, 4)
	addi	sp, 8
	.cfi_def_cfa_offset 0
#else
	jmpi	SYSCALL_ERROR
#endif

3:
	rts
#endif

PSEUDO_END (__socket)

libc_hidden_def (__socket)
#ifndef NO_WEAK_ALIAS
weak_alias (__socket, socket)
#endif


#endif	/* __CSKYABIV2__*/
