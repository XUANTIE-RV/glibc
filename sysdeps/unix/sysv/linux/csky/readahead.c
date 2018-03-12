/* Provide kernel hint to read ahead.
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
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <endian.h>

#include <sysdep.h>
#include <sys/syscall.h>

ssize_t
__readahead (int fd, off64_t offset, size_t count)
{
#ifdef __CSKYABVI2__
  return INLINE_SYSCALL (readahead, 4, fd,
			 __LONG_LONG_PAIR ((off_t) (offset >> 32),
					   (off_t) (offset & 0xffffffff)),
			 count);
#else
  return INLINE_SYSCALL (readahead, 5, fd, 0,
			 __LONG_LONG_PAIR ((off_t) (offset >> 32),
					   (off_t) (offset & 0xffffffff)),
			 count);

#endif
}

weak_alias (__readahead, readahead)
