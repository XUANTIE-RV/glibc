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

#include <sysdep.h>

/* void *mmap(void *addr, size_t len, int prot, int flags,
              int fildes, off_t off); */

ENTRY (__mmap)
	subi	sp, 24
	stm	a0-a3, (sp)	/* store arg1-arg4 */
	ldw	t0, (sp, 24)
	stw	t0, (sp, 16)	/* store arg5 */
	ldw	t0, (sp, 28)
	stw	t0, (sp, 20)	/* store arg6 */

	mov	t0, r7		/* save r7 */
	lrw	r7, __NR_mmap
	mov	a0, sp
	trap	0
	addi	sp, sp, 24
	mov	r7, t0
	lrw	t0, 0xfffff000
	cmphs	a0, t0
	bf	1f
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	stw	r15, (sp, 4)
	grs	gb, .Lgetpc
.Lgetpc:
	lrw	t0, .Lgetpc@GOTPC
	addu	gb, gb, t0
	lrw	t0, __syscall_error@PLT
	ldr.w	t0, (gb, t0 << 0)
	jsr	t0
	ldw	gb, (sp, 0)
	ldw	r15, (sp, 4)
	addi	sp, 8
#else
	jmpi	__syscall_error
#endif /* __PIC__ */
1:
	rts
PSEUDO_END (__mmap)

weak_alias (__mmap, mmap)
libc_hidden_builtin_def (__mmap)
