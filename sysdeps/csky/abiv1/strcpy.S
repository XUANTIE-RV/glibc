/* The assembly function for string copy.  C-SKY version.
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

ENTRY(strcpy)
#ifndef  __CSKYABIV2__
	mov     r6, r2
	mov     r7, r3
	or      r7, r6
	andi    r7, 3
	cmpnei  r7, 0
	bf      2f
1:
	ldb     r5, (r3)
	stb     r5, (r6)
	addi    r3, 1
	addi    r6, 1
	cmpnei  r5, 0
	bt      1b
1:
	jmp     r15

2:
	ldw     r5, (r3)
	tstnbz  r5
	bf      10f
	stw     r5, (r6)

	ldw     r5, (r3, 4)
	tstnbz  r5
	bf      3f
	stw     r5, (r6, 4)

	ldw     r5, (r3, 8)
	tstnbz  r5
	bf      4f
	stw     r5, (r6, 8)

	ldw     r5, (r3, 12)
	tstnbz  r5
	bf      5f
	stw     r5, (r6, 12)

	ldw     r5, (r3, 16)
	tstnbz  r5
	bf      6f
	stw     r5, (r6, 16)

	ldw     r5, (r3, 20)
	tstnbz  r5
	bf      7f
	stw     r5, (r6, 20)

	ldw     r5, (r3, 24)
	tstnbz  r5
	bf      8f
	stw     r5, (r6, 24)

	ldw     r5, (r3, 28)
	tstnbz  r5
	bf      9f
	stw     r5, (r6, 28)

	addi    r6, 32
	addi    r3, 32
	br      2b

3:
	addi    r6, 4
	br      10f

4:
	addi    r6, 8
	br      10f

5:
	addi    r6, 12
	br      10f

6:
	addi    r6, 16
	br      10f

7:
	addi    r6, 20
	br      10f

8:
	addi    r6, 24
	br      10f

9:
	addi    r6, 28

10:
# ifdef __CSKYBE__
	xtrb0   r1, r5
	stb     r1, (r6)
	cmpnei  r1, 0
	bf      5f
	xtrb1   r1, r5
	stb     r1, (r6, 1)
	cmpnei  r1, 0
	bf      5f
	xtrb2   r1, r5
	stb     r1, (r6, 2 )
	cmpnei  r1, 0
	bf      5f
	stw     r5, (r6)

# else /* !__CSKYBE__ */
	xtrb3   r1, r5
	stb     r1, (r6)
	cmpnei  r1, 0
	bf      5f
	xtrb2   r1, r5
	stb     r1, (r6, 1)
	cmpnei  r1, 0
	bf      5f
	xtrb1   r1, r5
	stb     r1, (r6, 2)
	cmpnei  r1, 0
	bf      5f
	stw     r5, (r6)
# endif /* !__CSKYBE__ */
5:
	jmp     r15
#else /* __CSKYABIV2__ */
	mov     a3, a0
	or      a2, a1, a3
	andi    t0, a2, 3
	M_BEZ   t0, 2f
	mov     t0, a1
1:
	ld.b    a2, (t0)
	stb     a2, (a3)
	addi    t0, t0, 1
	addi    a3, a3, 1
	M_BNEZ  a2, 1b

	jmp     r15

2:
# if defined (__ck802__)
	ldw     a2, (a1)
	tstnbz  a2
	bf      11f
	stw     a2, (a3)
	addi    a3, 4
	addi    a1, 4
	br      2b
# else /* !__ck802__ */
	ldw     a2, (a1)
	tstnbz  a2
	bf      11f
	stw     a2, (a3)

	ldw     a2, (a1, 4)
	tstnbz  a2
	bf      4f
	stw     a2, (a3, 4)

	ldw     a2, (a1, 8)
	tstnbz  a2
	bf      5f
	stw     a2, (a3, 8)

	ldw     a2, (a1, 12)
	tstnbz  a2
	bf      6f
	stw     a2, (a3, 12)

	ldw     a2, (a1, 16)
	tstnbz  a2
	bf      7f
	stw     a2, (a3, 16)

	ldw     a2, (a1, 20)
	tstnbz  a2
	bf      8f
	stw     a2, (a3, 20)

	ldw     a2, (a1, 24)
	tstnbz  a2
	bf      9f
	stw     a2, (a3, 24)

	ldw     a2, (a1, 28)
	tstnbz  a2
	bf      10f
	stw     a2, (a3, 28)

	addi     a3, 32
	addi     a1, 32
	br       2b


4:
	addi    a3, 4
	br      11f

5:
	addi    a3, 8
	br      11f

6:
	addi    a3, 12
	br      11f

7:
	addi    a3, 16
	br      11f

8:
	addi    a3, 20
	br      11f

9:
	addi    a3, 24
	br      11f

10:
	addi    a3, 28
# endif /* !__ck802__ */
11:
# ifdef __CSKYBE__
	xtrb0   t0, a2
	st.b    t0, (a3)
	M_BEZ   t0, 5f
	xtrb1   t0, a2
	st.b    t0, (a3, 1)
	M_BEZ   t0, 5f
	xtrb2   t0, a2
	st.b    t0, (a3, 2 )
	M_BEZ   t0, 5f
	stw     a2, (a3)
# else
	xtrb3   t0, a2
	st.b    t0, (a3)
	M_BEZ   t0, 5f
	xtrb2   t0, a2
	st.b    t0, (a3, 1)
	M_BEZ   t0, 5f
	xtrb1   t0, a2
	st.b    t0, (a3, 2)
	M_BEZ   t0, 5f
	stw     a2, (a3)
# endif /* !__CSKYBE__ */
5:
	jmp     r15

#endif /* !__CSKYABIV2__ */
END(strcpy)

libc_hidden_def(strcpy)
.weak strcpy
