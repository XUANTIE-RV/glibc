/* Copyright (C) 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 2002, 2003,
   2004, 2005, 2009, 2011, 2012
   Free Software Foundation, Inc.
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
#define _ERRNO_H
#include <bits/errno.h>
#include <csky_readtp.h>

#if !IS_IN (rtld)
# include <dl-sysdep.h>			/* Defines RTLD_PRIVATE_ERRNO.  */
#endif

#include <tls.h>

#undef syscall_error
__syscall_error:
#if defined (EWOULDBLOCK_sys) && EWOULDBLOCK_sys != EAGAIN
	/* We translate the system's EWOULDBLOCK error into EAGAIN.
	   The GNU C library always defines EWOULDBLOCK==EAGAIN.
	   EWOULDBLOCK_sys is the original number.  */
	cmpnei	a0, EWOULDBLOCK	/* Is it the old EWOULDBLOCK?  */
	bt	1f
	mov	a0, EAGAIN	/* Yes; translate it to EAGAIN.  */
#endif

1:
#if !IS_IN (rtld)
	mov	a1, a0
	csky_read_tp

	grs	t1, .Lgetpc1
.Lgetpc1:
	lrw	t0, errno@gottpoff
	add	t1, t1, t0
	ldw	t1, (t1)
	add	t1, a0
	stw	a1, (t1)
	bmaski	a0, 0
	jsr	r15
#elif RTLD_PRIVATE_ERRNO
#ifdef	__PIC__
	grs	t1, .Lgetpc2
.Lgetpc2:
	lrw	t0, .Lgetpc2@GOTPC
	addu	t1, t1, t0
	lrw	t0, rtld_errno@PLT
	ldr.w	t0, (t1, t0 << 0)
#else
	lrw	t0, rtld_errno
#endif
	stw	a0, (t0)
	bmaski	a0, 0
	jsr	r15
#else
#error "Unsupported non-TLS case"
#endif

#undef	__syscall_error
END (__syscall_error)
