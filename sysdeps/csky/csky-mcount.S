/* Implementation of profiling support.  C-SKY version.
   Copyright (C) 2018 Free Software Foundation, Inc.
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

/* Don't call mcount when calling mcount...  */
#undef PROF

#include <sysdep.h>

/* Use an assembly stub with a special ABI.  The calling lr has been
   pushed to the stack (which will be misaligned).  We should preserve
   all registers except ip and pop a word off the stack.

   NOTE: This assumes mcount_internal does not clobber any non-core
   (coprocessor) registers.  Currently this is true, but may require
   additional attention in the future.

   The calling sequence looks something like:
func:
   push lr
   jbsr __gnu_mount_nc
   <function body>
*/

ENTRY(_mcount)
#ifdef __CSKYABIV2__
	subi	sp,20
	stw	    a0,(sp, 0)
	stw	    a1,(sp, 4)
	stw	    a2,(sp, 8)
	stw	    a3,(sp, 12)
	stw	lr,(sp, 16)
	mov	    a1, lr
	ldw	a0, (sp, 20)
	jbsr	__mcount_internal
	ldw	a0,(sp, 0)
	ldw	a1,(sp, 4)
	ldw	a2,(sp, 8)
	ldw	a3,(sp, 12)
	ldw	t1,(sp, 16)
	ldw	lr,(sp, 20)
	addi	sp,24
	jmp	t1
#else
	subi	sp,28
	stw	    a0,(sp, 0)
	stw	    a1,(sp, 4)
	stw	    a2,(sp, 8)
	stw	    a3,(sp, 12)
	stw	    a4,(sp, 16)
	stw	    a5,(sp, 20)
	stw	lr,(sp, 24)
	mov	    a1, lr
	ldw	a0, (sp, 28)
	jbsr	__mcount_internal
	ldw	a0,(sp, 0)
	ldw	a1,(sp, 4)
	ldw	a2,(sp, 8)
	ldw	a3,(sp, 12)
	ldw	a4,(sp, 16)
	ldw	a5,(sp, 20)
	ldw	r1,(sp, 24)
	ldw	lr,(sp, 28)
	addi	sp,32
	jmp	r1
#endif

END(_mcount)

/* The canonical name for the function is `_mcount' in both C and asm,
   but some old asm code might assume it's `mcount'.  */
#undef mcount
weak_alias (_mcount, mcount)
