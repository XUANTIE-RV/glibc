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

/* This function is not called directly. It is jumped when attempting to use a 
   symbol that has not yet been resolved.
 
   .plt*:
     subi r0, 32
     stw r2, (r0, 0)
     stw r3, (r0, 4)
     lrw r3, #offset
     ldw r2, (gb, 8)
     jmp r2
 */

.import _dl_fixup

.text
.globl _dl_runtime_resolve
.type  _dl_runtime_resolve,@function

_dl_runtime_resolve:
#if !defined(__CSKYABIV2__)
# if !defined(__ck810__)
	stw  r4, (r0, 8)
	stw  r5, (r0, 12)
	stw  r6, (r0, 16)
	stw  r7, (r0, 20)
	stw  r15,(r0, 24)
	# load the ID of this module  
	ldw  r2, (gb, 4)  
	mov  r6, r3
	addu r6, r6
	addu r3, r6
	lsli r3, 2
	# r2 = id, r3 = offset(do it in plt*)
	bsr  _dl_fixup
	# Return from _dl_fixup, the address of function is in r2
	mov  r1, r2
	# Restore the registers
	ldw  r2, (r0, 0)
	ldw  r3, (r0, 4)
	ldw  r4, (r0, 8)
	ldw  r5, (r0, 12)
	ldw  r6, (r0, 16)
	ldw  r7, (r0, 20)
	ldw  r15,(r0, 24)
	# Restore the r0, because r0 is subtracted in PLT table
	addi r0, 32
	# The address of function is in r1, call the function without saving pc
	jmp  r1
# else /* __ck810__ */
	subi sp, 32
	stm  r2-r7, (sp)
	stw  r15, (sp, 24)
	ldw  r2,  (gb, 4)
	mov  r6, r3
	addu r6, r6
	addu r3, r6
	lsli r3, 2
	mov  r3, r21
	bsr  _dl_fixup
	mov  r20, r2
	ldw  r15, (sp, 24)
	ldm  r2-r7, (sp)
	addi sp, 32
	jmp  r20
# endif /* __ck810__ */
#else /* __CSKYABIV2__ */
	subi sp, 20
	stm  a0-a3, (sp)
	stw  lr, (sp, 16)
	# a0 = id, a1 = offset(do it in plt*)
	ldw  a0,  (gb, 4)
	movi a1, 12
	mult a1, t1
	bsr  _dl_fixup
	mov  t0, a0
	ldw  lr, (sp, 16)
	ldm  a0-a3, (sp)
	addi sp, 20
	jmp  t0
#endif /* __CSKYABIV2__ */
