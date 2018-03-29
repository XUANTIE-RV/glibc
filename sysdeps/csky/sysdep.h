/* Assembler macros for C-SKY.
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

#include <sysdeps/generic/sysdep.h>
#include <features.h>

#ifndef __CSKYABIV2__
# define CSKY_ABIV1
#else
# define CSKY_ABIV2
#endif

#ifdef __ASSEMBLER__

#define ASM_SIZE_DIRECTIVE(name) .size name,.-name

/* Define an entry point visible from C.  */
#define ENTRY(name)	\
  .globl name;		\
  .type name,@function;	\
  .align 4;		\
  name##:;		\
  cfi_startproc;	\

#undef  END
#define END(name)	\
  cfi_endproc;		\
  ASM_SIZE_DIRECTIVE(name)

#endif
