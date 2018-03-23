/* The assembly function for string compare. C-SKY version.
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

#include <sysdep.h>
#include "macro.S"

ENTRY(strcmp)
#ifndef  __CSKYABIV2__
	mov        r6, r2

	or         r2, r3
	andi       r2, 0x3
	cmpnei     r2, 0x0     /* d or s is aligned ?*/
	bt         4f          /* if not aligned, goto 4f*/
	1:                   /* if aligned, load word each time.*/
	ldw        r2, (r6, 0)
	ldw        r7, (r3, 0)
	cmpne      r2, r7
	bt         1f       /* if d[i] != s[i], goto 1f */
	tstnbz     r2       /* if d[i] == s[i], check if d or s is at the end. */
	bf         3f       /* if at the end, goto 3f (finish comparing) */

	ldw        r2, (r6, 4)
	ldw        r7, (r3, 4)
	cmpne      r2, r7
	bt         1f
	tstnbz     r2
	bf         3f

	ldw        r2, (r6, 8)
	ldw        r7, (r3, 8)
	cmpne      r2, r7
	bt         1f
	tstnbz     r2
	bf         3f

	ldw        r2, (r6, 12)
	ldw        r7, (r3, 12)
	cmpne      r2, r7
	bt         1f
	tstnbz     r2
	bf         3f

	ldw        r2, (r6, 16)
	ldw        r7, (r3, 16)
	cmpne      r2, r7
	bt         1f
	tstnbz     r2
	bf         3f

	ldw        r2, (r6, 20)
	ldw        r7, (r3, 20)
	cmpne      r2, r7
	bt         1f
	tstnbz     r2
	bf         3f

	ldw        r2, (r6, 24)
	ldw        r7, (r3, 24)
	cmpne      r2, r7
	bt         1f
	tstnbz     r2
	bf         3f

	ldw        r2, (r6, 28)
	ldw        r7, (r3, 28)
	cmpne      r2, r7
	bt         1f
	tstnbz     r2
	bf         3f

	addi       r6, 32
	addi       r3, 32
	br         1b

#ifdef __CSKYBE__
	/* d[i] != s[i] in word, so we check byte 0 ? */
1:
	xtrb0      r1, r2
	mov        r4, r1
	xtrb0      r1, r7
	cmpne      r4, r1
	bt         2f
	cmpnei     r4, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb1      r1, r2
	mov        r4, r1
	xtrb1      r1, r7
	cmpne      r4, r1
	bt         2f
	cmpnei     r4, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb2      r1, r2
	mov        r4, r1
	xtrb2      r1, r7
	cmpne      r4, r1
	bt         2f
	cmpnei     r4, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb3      r1, r2
	mov        r4, r1
	xtrb3      r1, r7

#else /* little endian */
	/* d[i] != s[i] in word, so we check byte 0 ? */
1:
	xtrb3      r1, r2
	mov        r4, r1
	xtrb3      r1, r7
	cmpne      r4, r1
	bt         2f
	cmpnei     r4, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb2      r1, r2
	mov        r4, r1
	xtrb2      r1, r7
	cmpne      r4, r1
	bt         2f
	cmpnei     r4, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb1      r1, r2
	mov        r4, r1
	xtrb1      r1, r7
	cmpne      r4, r1
	bt         2f
	cmpnei     r4, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb0      r1, r2
	mov        r4, r1
	xtrb0      r1, r7

#endif
	/* get the result when d[i] != s[i] */
2:
	subu       r4, r1
	mov        r2, r4
	jmp        r15

	/* return when d[i] == s[i] */
3:
	subu       r2, r7
	jmp        r15

	/* cmp when d or s is not aligned */
4:
	ldb       r2, (r6,0)
	ldb       r7, (r3, 0)
	cmpne     r2, r7
	bt        3b
	addi      r3, 1
	addi      r6, 1
	cmpnei    r2, 0
	bt        4b
	jmp       r15
# else /* __CSKYABIV2__ */
	mov        a3, a0

	or         a0, a1
	andi       a0, 0x3
	M_BNEZ     a0, 4f
	1:                   
	/* if aligned, load word each time. */
	ldw        a0, (a3, 0)
	ldw        t0, (a1, 0)
	/* if d[i] != s[i], goto 1f */
	M_BNE      a0, t0, 1f
	/* if d[i] == s[i], check if d or s is at the end. */
	tstnbz     a0
	/* if at the end, goto 3f (finish comparing) */      
	bf         3f
#if defined ( __ck802__ )
	addi       a3, 4
	addi       a1, 4
#else
	ldw        a0, (a3, 4)
	ldw        t0, (a1, 4)
	M_BNE      a0, t0, 1f
	tstnbz     a0
	bf         3f

	ldw        a0, (a3, 8)
	ldw        t0, (a1, 8)
	M_BNE      a0, t0, 1f
	tstnbz     a0
	bf         3f

	ldw        a0, (a3, 12)
	ldw        t0, (a1, 12)
	M_BNE      a0, t0, 1f
	tstnbz     a0
	bf         3f

	ldw        a0, (a3, 16)
	ldw        t0, (a1, 16)
	M_BNE      a0, t0, 1f
	tstnbz     a0
	bf         3f

	ldw        a0, (a3, 20)
	ldw        t0, (a1, 20)
	M_BNE      a0, t0, 1f
	tstnbz     a0
	bf         3f

	ldw        a0, (a3, 24)
	ldw        t0, (a1, 24)
	M_BNE      a0, t0, 1f
	tstnbz     a0
	bf         3f

	ldw        a0, (a3, 28)
	ldw        t0, (a1, 28)
	M_BNE      a0, t0, 1f
	tstnbz     a0
	bf         3f

	addi       a3, 32
	addi       a1, 32
#endif
	br         1b

# ifdef __CSKYBE__
	/* d[i] != s[i] in word, so we check byte 0 ? */
1:
	xtrb0      t1, a0
	mov        a2, t1
	xtrb0      t1, t0
	M_BNE      a2, t1, 2f
	cmpnei     a2, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb1      t1, a0
	mov        a2, t1
	xtrb1      t1, t0
	M_BNE      a2, t1, 2f
	cmpnei     a2, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb2      t1, a0
	mov        a2, t1
	xtrb2      t1, t0
	M_BNE      a2, t1, 2f
	cmpnei     a2, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb3      t1, a0
	mov        a2, t1
	xtrb3      t1, t0

# else /* !__CSKYBE__ */
	/* d[i] != s[i] in word, so we check byte 0 ? */
1:
	xtrb3      t1, a0
	mov        a2, t1
	xtrb3      t1, t0
	M_BNE      a2, t1, 2f
	cmpnei     a2, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb2      t1, a0
	mov        a2, t1
	xtrb2      t1, t0
	M_BNE      a2, t1, 2f
	cmpnei     a2, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb1      t1, a0
	mov        a2, t1
	xtrb1      t1, t0
	M_BNE      a2, t1, 2f
	cmpnei     a2, 0
	bf         2f

	/* d[i] != s[i] in word, so we check byte 1 ? */
	xtrb0      t1, a0
	mov        a2, t1
	xtrb0      t1, t0

# endif /* !__CSKYBE__ */
	/* get the result when d[i] != s[i] */
2:
	subu       a2, t1
	mov        a0, a2
	jmp        r15

	/* return when d[i] == s[i] */
3:
	subu       a0, t0
	jmp        r15

	/* cmp when d or s is not aligned */
4:
	ldb       a0, (a3,0)
	ldb       t0, (a1, 0)
	M_BNE     a0, t0, 3b
	addi      a1, 1
	addi      a3, 1
	M_BNEZ    a0, 4b
	jmp        r15
#endif /* __CSKYABIV2__ */
END(strcmp)

libc_hidden_def(strcmp)
.weak strcmp
