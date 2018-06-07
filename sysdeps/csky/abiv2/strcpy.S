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

END(strcpy)

libc_hidden_def(strcpy)
.weak strcpy
