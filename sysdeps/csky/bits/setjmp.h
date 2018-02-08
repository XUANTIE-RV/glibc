/* Copyright (C) 2004, 2005, 2006, 2009 Free Software Foundation, Inc.
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

/* Define the machine-dependent type `jmp_buf'.  ARM EABI version.  */

#ifndef _BITS_SETJMP_H
#define _BITS_SETJMP_H 1

typedef struct __jmp_buf_str
  {
    /* Stack pointer.  */
    int __sp;
    int __lr;
    /* Callee-saved registers a0 through a5.  */
    int __regs[16];
  } __jmp_buf[1];


#endif
