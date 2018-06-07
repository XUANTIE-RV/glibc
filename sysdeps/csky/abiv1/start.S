/* Startup code compliant to the ELF C-SKY ABI.
   Copyright (C) 2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   In addition to the permissions in the GNU Lesser General Public
   License, the Free Software Foundation gives you unlimited
   permission to link the compiled version of this file with other
   programs, and to distribute those programs without any restriction
   coming from the use of this file. (The GNU Lesser General Public
   License restrictions do apply in other respects; for example, they
   cover modification of the file, and distribution when not linked
   into another program.)

   Note that people who make modified versions of this file are not
   obligated to grant this special exception for their modified
   versions; it is their choice whether to do so. The GNU Lesser
   General Public License gives permission to release a modified
   version without this exception; this exception also makes it
   possible to release a modified version which carries forward this
   exception.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <http://www.gnu.org/licenses/>.  */

/* We need to call:
   __libc_start_main (int (*main) (int, char **, char **), int argc,
		      char **argv, void (*init) (void), void (*fini) (void),
		      void (*rtld_fini) (void), void *stack_end)
*/

#include <sysdep.h>

.text
	.globl _start
	.type _start,@function
_start:
	/* Clear the frame pointer and link register since this is the outermost frame. */
	movi	lr, 0
	/* Pop argc off the stack and save a pointer to argv */
	ldw 	a1, (sp, 0)	/* __libc_start_main(arg1): argc */
	addi    sp, 4
	mov 	a2, sp		/* __libc_start_main(arg1): argv */

	subi	sp, 4
	/* Push stack limit */
	stw 	a2, (sp, 0)
#ifdef	__CSKYABIV2__
	/* Push rtld_fini */
	subi	sp, 4
	stw 	a0, (sp, 0)
#else
	mov	r7, a0
#endif

#ifdef SHARED
	subi sp,8
	stw lr,(sp,0)
	stw gb,(sp,4)
	bsr .Lgetpc
.Lgetpc:
	lrw  gb, .Lgetpc@GOTPC
	addu gb, lr
	lrw  a3, __libc_csu_fini@GOT
	addu a3, gb
	ldw  a3, (a3)
# ifdef	__CSKYABIV2__
	subi sp, 4
	stw  a3, (sp,0)
# else
	mov  a4, a3
# endif /* !__CSKYABIV2__ */
	lrw  a3, __libc_csu_init@GOT
	addu a3, gb
	ldw  a3,(a3,0)
# ifdef __CSKYABIV2__
	lrw  t0, main@GOT
	addu t0, gb
	ldw  a0,(t0,0)
	lrw  t1,__libc_start_main@PLT
	addu t1, gb
	ldw  t1, (t1, 0)
	jsr  t1
# else
	lrw  a0, main@GOT
	addu a0, gb
	ldw  a0,(a0,0)
	lrw  r13,__libc_start_main@PLT
	addu r13, gb
	ldw  r13, (r13, 0)
	jsr  r13
# endif /* !__CSKYABIV2__ */
	ldw  lr,(sp,0)
	ldw  gb,(sp,4)
	addi sp, 8
#else /* !SHARED */
# ifdef	__CSKYABIV2__
	/* Fetch address of __libc_csu_fini */
	lrw a0, __libc_csu_fini
	/* Push __libc_csu_fini */
	subi sp,4
	stw a0, (sp,0)
# else
	lrw a4, __libc_csu_fini
# endif /* !__CSKYABIV2__ */
	/* Set up the other arguments in registers */
	lrw a0, main
	lrw a3, __libc_csu_init
	/* __libc_start_main (main, argc, argv, init, fini, rtld_fini, stack_end) */
	/* Let the libc call main and exit with its return code.  */
	jsri __libc_start_main
#endif /* !SHARED */

	/* should never get here....*/
	jsri abort

/* Define a symbol for the first piece of initialized data.  */
	.data
	.globl __data_start
__data_start:
	.long 0
	.weak data_start
	data_start = __data_start
