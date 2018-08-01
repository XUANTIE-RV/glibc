/* The assembly function for string copy.  C-SKY ABIV1 version.
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

ENTRY (strcpy)
	mov	r6, r2
	mov	r7, r3
	or	r7, r6
	andi	r7, 3
	cmpnei	r7, 0
	bf	2f
1:
	ldb	r5, (r3)
	stb	r5, (r6)
	addi	r3, 1
	addi	r6, 1
	cmpnei	r5, 0
	bt	1b
1:
	jmp	r15

2:
	ldw	r5, (r3)
	tstnbz	r5
	bf	10f
	stw	r5, (r6)

	ldw	r5, (r3, 4)
	tstnbz	r5
	bf	3f
	stw	r5, (r6, 4)

	ldw	r5, (r3, 8)
	tstnbz	r5
	bf	4f
	stw	r5, (r6, 8)

	ldw	r5, (r3, 12)
	tstnbz	r5
	bf	5f
	stw	r5, (r6, 12)

	ldw	r5, (r3, 16)
	tstnbz	r5
	bf	6f
	stw	r5, (r6, 16)

	ldw	r5, (r3, 20)
	tstnbz	r5
	bf	7f
	stw	r5, (r6, 20)

	ldw	r5, (r3, 24)
	tstnbz	r5
	bf	8f
	stw	r5, (r6, 24)

	ldw	r5, (r3, 28)
	tstnbz	r5
	bf	9f
	stw	r5, (r6, 28)

	addi	r6, 32
	addi	r3, 32
	br	2b

3:
	addi	r6, 4
	br	10f

4:
	addi	r6, 8
	br	10f

5:
	addi	r6, 12
	br	10f

6:
	addi	r6, 16
	br	10f

7:
	addi	r6, 20
	br	10f

8:
	addi	r6, 24
	br	10f

9:
	addi	r6, 28

10:
#ifdef __CSKYBE__
	xtrb0	r1, r5
	stb	r1, (r6)
	cmpnei	r1, 0
	bf	5f
	xtrb1	r1, r5
	stb	r1, (r6, 1)
	cmpnei	r1, 0
	bf	5f
	xtrb2	r1, r5
	stb	r1, (r6, 2 )
	cmpnei	r1, 0
	bf	5f
	stw	r5, (r6)

#else
	xtrb3	r1, r5
	stb	r1, (r6)
	cmpnei	r1, 0
	bf	5f
	xtrb2	r1, r5
	stb	r1, (r6, 1)
	cmpnei	r1, 0
	bf	5f
	xtrb1	r1, r5
	stb	r1, (r6, 2)
	cmpnei	r1, 0
	bf	5f
	stw	r5, (r6)
#endif /* !__CSKYBE__ */
5:
	jmp	r15
END (strcpy)

libc_hidden_def (strcpy)
.weak strcpy
