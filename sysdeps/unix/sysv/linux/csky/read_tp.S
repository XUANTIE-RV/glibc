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

#include <features.h>
#include <sysdep.h>

/* This function is exported from libc for use by user code.  libpthread, librt,
   and the dynamic linker get their own private copies, for
   performance (and in the case of ld.so, out of necessity); those are
   all hidden.  */

/* 
 * __read_tp
 * clobbe r0, others had to be saved 
 *
 */
#if IS_IN (libc)
	.global __read_tp
#else
	.hidden __read_tp
#endif
#ifdef __CSKYABIV2__
ENTRY (__read_tp)
	mov	r0, r31 
	rts
END (__read_tp)
#else
ENTRY (__read_tp)
	trap	3
	rts
END (__read_tp)
#endif

