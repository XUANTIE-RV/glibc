/* Copyright (C) 1999-2012 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Philip Blundell <philb@gnu.org>.

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
#define _ERRNO_H	1
#include <bits/errno.h>

/* Clone the calling process, but without copying the whole address space.
   The calling process is suspended until the new process exits or is
   replaced by a call to `execve'.  Return -1 for errors, 0 to the new process,
   and the process ID of the new process to the old process.  */

ENTRY (vfork_compat)
#ifdef SAVE_PID
	SAVE_PID
#endif

#ifdef __CSKYABIV2__
	mov	t0, r7
	lrw	r7, __NR_vfork
	trap	0
	mov	r7, t0
#else
	lrw     r1, __NR_vfork
	trap    0
#endif

#ifdef RESTORE_PID
	RESTORE_PID
#endif
	PSEUDO_RET
	rts

PSEUDO_END (vfork_compat)

strong_alias (vfork_compat, vfork_compat2)
