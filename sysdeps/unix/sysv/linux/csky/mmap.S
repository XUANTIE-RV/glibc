/* Copyright (C) 1998-2012 Free Software Foundation, Inc.
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
#include "abiv2_mmap.S"
#else

#include <sysdep.h>

/*void *mmap(void *addr, size_t len, int prot, int flags,
              int fildes, off_t off);
*/
ENTRY (__mmap)
	subi	sp, 24
	stw	r2, (sp, 0)
	stw	r3, (sp, 4)
	stw	r4, (sp, 8)
	stw	r5, (sp, 12)
	stw	r6, (sp, 16)
	stw	r7, (sp, 20)
	mov	r2, sp
	lrw	r1, __NR_mmap
	trap	0
	addi	sp, 24
	lrw	r3, 0xfffff000
	cmphs	r2, r3
	bf	1f
#ifdef __PIC__
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
#else
	jmpi	__syscall_error
#endif
1:
	rts
PSEUDO_END (__mmap)

weak_alias (__mmap, mmap)
libc_hidden_builtin_def (__mmap)
#endif	/* __CSKYABVI2__*/
