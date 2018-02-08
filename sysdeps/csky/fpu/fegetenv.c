/* Store current floating-point environment.
   Copyright (C) 1998, 1999, 2000, 2002, 2010 Free Software Foundation, Inc.
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
#include <fpu_control.h>

int
__fegetenv (fenv_t *envp)
{
#ifdef __csky_hard_float__
  unsigned int fpcr;
  unsigned int fpsr;
  _FPU_GETCW (fpcr);
  _FPU_GETFPSR (fpsr);
  envp->__fpcr = fpcr;
  envp->__fpsr = fpsr;
  
  /* Success.  */
  return 0;
#else
  /* Unsupported, so fail.  */
  return 1;
#endif
}

//#include <shlib-compat.h>
//libm_hidden_ver (__fegetenv, fegetenv)
//versioned_symbol (libm, __fegetenv, fegetenv, GLIBC_2_2);
libm_hidden_def (__fegetenv)
weak_alias (__fegetenv, fegetenv)
libm_hidden_weak (fegetenv)

