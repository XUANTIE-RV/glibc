/* Set current rounding direction.
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

#include <fenv.h>
#include <fpu_control.h>
#include <fenv_private.h>

#include <stdio.h>
int
__fesetround (int round)
{
#ifdef __csky_hard_float__
  libc_fesetround_vfp (round);
  return 0;
#else
  if (round == FE_TONEAREST)
  /* This is the only supported rounding mode for soft-fp.  */
    return 0;

  /* Unsupported, so fail.  */
  return 1;
#endif /* __csky_hard_float__ */
}
libm_hidden_def (__fesetround)
weak_alias (__fesetround, fesetround)
libm_hidden_weak (fesetround)

