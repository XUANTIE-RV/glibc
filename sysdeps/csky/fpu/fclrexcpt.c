/* Clear given exceptions in current floating-point environment.
   Copyright (C) 1998-2012 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Andreas Jaeger <aj@suse.de>, 1998.

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

#include <fenv.h>
#include <fenv_libc.h>
#include <fpu_control.h>

int
__feclearexcept (int excepts)
{
#ifdef __csky_hard_float__
	int fpsr;

    /* Mask out unsupported bits/exceptions.  */
	excepts &= FE_ALL_EXCEPT;
	
    /* Read the complete control word.  */
	_FPU_GETFPSR (fpsr);
	
    /* Clear the relevant bits.  */
	fpsr &= ~(excepts | (excepts << CAUSE_SHIFT)); 
	
    /* Put the new data in effect.  */
    _FPU_SETFPSR (fpsr);
	
	/* Success.  */
	return 0;
#else
	/* Unsupported, so fail unless nothing needs to be done.  */
	return (excepts != 0);
#endif
}

#include <shlib-compat.h>
libm_hidden_ver (__feclearexcept, feclearexcept)
versioned_symbol (libm, __feclearexcept, feclearexcept, GLIBC_2_2);
