/* Install given floating-point environment.
   Copyright (C) 1998, 1999, 2000, 2002 Free Software Foundation, Inc.
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
__fesetenv (const fenv_t *envp)
{
#ifdef __csky_hard_float__
  unsigned int fpcr;
  unsigned int fpsr;

  _FPU_GETCW (fpcr);
  _FPU_GETFPSR (fpsr);

  fpcr &= _FPU_RESERVED;
  fpsr &= _FPU_FPSR_RESERVED;

  if (envp == FE_DFL_ENV)
    {
      fpcr |= _FPU_DEFAULT;
      fpsr |= _FPU_FPSR_DEFAULT;
    }
  else if (envp == FE_NOMASK_ENV)
    {
      fpcr |= _FPU_FPCR_IEEE;
      fpsr |= _FPU_FPSR_IEEE;
    }
  else
    {
      fpcr |= envp->__fpcr & ~_FPU_RESERVED;
      fpsr |= envp->__fpsr & ~_FPU_FPSR_RESERVED;
    }

  _FPU_SETFPSR (fpsr);

  _FPU_SETCW (fpcr);

  /* Success.  */
  return 0;
#else
  /* Unsupported, so fail.  */
  return 1;
#endif
}

//#include <shlib-compat.h>
//libm_hidden_ver (__fesetenv, fesetenv)
//versioned_symbol (libm, __fesetenv, fesetenv, GLIBC_2_2);
libm_hidden_def (__fesetenv)
weak_alias (__fesetenv, fesetenv)
libm_hidden_weak (fesetenv)

