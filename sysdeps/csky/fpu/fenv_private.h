/* Private floating point rounding and exceptions handling. C-SKY version.
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

#ifndef FENV_PRIVATE_H
#define FENV_PRIVATE_H 1

#include <fenv.h>
#include <fpu_control.h>

#ifdef __csky_hard_float__
# include <fenv_libc.h>

static __always_inline void
libc_feholdexcept_vfp (fenv_t *envp)
{
  unsigned int fpsr;
  unsigned int fpcr;

  _FPU_GETCW (fpcr);
  envp->__fpcr = fpcr;

  _FPU_GETFPSR (fpsr);
  envp->__fpsr = fpsr;

  /* Now set all exceptions to non-stop.  */
  fpcr &= ~FE_ALL_EXCEPT;

  /* And clear all exception flags.  */
  fpsr &= ~(FE_ALL_EXCEPT << CAUSE_SHIFT);

  _FPU_SETFPSR (fpsr);

  _FPU_SETCW (fpcr);
}

static __always_inline void
libc_fesetround_vfp (int round)
{
  fpu_control_t fpcr;

  _FPU_GETCW (fpcr);

  /* Set new rounding mode if different.  */
  if (__glibc_unlikely ((fpcr & FE_DOWNWARD) != round))
    _FPU_SETCW ((fpcr & ~FE_DOWNWARD) | round);
}

static __always_inline void
libc_feholdexcept_setround_vfp (fenv_t *envp, int round)
{
  fpu_control_t fpsr;
  fpu_control_t fpcr;

  _FPU_GETCW (fpcr);
  envp->__fpcr = fpcr;

  _FPU_GETFPSR (fpsr);
  envp->__fpsr = fpsr;

  /* Clear exception flags, set all exceptions to non-stop,
     and set new rounding mode.  */
  fpcr &= ~(FE_ALL_EXCEPT | FE_DOWNWARD);
  _FPU_SETCW (fpcr | round);

  fpsr &= ~(FE_ALL_EXCEPT << CAUSE_SHIFT);
  _FPU_SETFPSR (fpsr);
}

static __always_inline void
libc_feholdsetround_vfp (fenv_t *envp, int round)
{
  fpu_control_t fpcr;

  _FPU_GETCW (fpcr);
  envp->__fpcr = fpcr;

  /* Set new rounding mode if different.  */
  if (__glibc_unlikely ((fpcr & FE_DOWNWARD) != round))
    _FPU_SETCW ((fpcr & ~FE_DOWNWARD) | round);
}

static __always_inline void
libc_feresetround_vfp (fenv_t *envp)
{
  fpu_control_t fpcr, round;

  _FPU_GETCW (fpcr);

  /* Check whether rounding modes are different.  */
  round = (envp->__fpcr ^ fpcr) & FE_DOWNWARD;

  /* Restore the rounding mode if it was changed.  */
  if (__glibc_unlikely (round != 0))
    _FPU_SETCW (fpcr ^ round);
}

static __always_inline int
libc_fetestexcept_vfp (int ex)
{
  fpu_control_t fpsr;

  _FPU_GETFPSR (fpsr);
  fpsr = fpsr >> CAUSE_SHIFT;
  return fpsr & ex & FE_ALL_EXCEPT;
}

static __always_inline void
libc_fesetenv_vfp (const fenv_t *envp)
{
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
}

static __always_inline int
libc_feupdateenv_test_vfp (const fenv_t *envp, int ex)
{
  fpu_control_t fpsr, new_fpsr;
  int excepts;

  _FPU_GETFPSR (fpsr);

  /* Merge current exception flags with the saved fenv.  */
  excepts = (fpsr >> CAUSE_SHIFT) & FE_ALL_EXCEPT;
  new_fpsr = envp->__fpsr | (excepts << CAUSE_SHIFT);

  /* Write new FPSCR if different (ignoring NZCV flags).  */
  if (__glibc_unlikely (((fpsr ^ new_fpsr)) != 0))
    _FPU_SETFPSR (new_fpsr);

  /* Raise the exceptions if enabled in the new FP state.  */
  if (__glibc_unlikely (excepts & (new_fpsr >> CAUSE_SHIFT)))
    __feraiseexcept (excepts);

  return excepts & ex;
}

static __always_inline void
libc_feupdateenv_vfp (const fenv_t *envp)
{
  libc_feupdateenv_test_vfp (envp, 0);
}

static __always_inline void
libc_feholdsetround_vfp_ctx (struct rm_ctx *ctx, int r)
{
  fpu_control_t fpcr, round;

  _FPU_GETCW (fpcr);
  ctx->updated_status = false;
  ctx->env.__fpcr = fpcr;

  /* Check whether rounding modes are different.  */
  round = (fpcr ^ r) & FE_DOWNWARD;

  /* Set the rounding mode if changed.  */
  if (__glibc_unlikely (round != 0))
    {
      ctx->updated_status = true;
      _FPU_SETCW (fpcr ^ round);
    }
}

static __always_inline void
libc_feresetround_vfp_ctx (struct rm_ctx *ctx)
{
  /* Restore the rounding mode if updated.  */
  if (__glibc_unlikely (ctx->updated_status))
    {
      fpu_control_t fpcr;

      _FPU_GETCW (fpcr);
      fpcr = (fpcr & ~FE_DOWNWARD) | (ctx->env.__fpcr & FE_DOWNWARD);
      _FPU_SETCW (fpcr);
    }
}

static __always_inline void
libc_fesetenv_vfp_ctx (struct rm_ctx *ctx)
{
  fpu_control_t fpcr, new_fpcr;

  _FPU_GETCW (fpcr);
  new_fpcr = ctx->env.__fpcr;

  /* Write new FPSCR if different (ignoring NZCV flags).  */
  if (__glibc_unlikely (((fpcr ^ new_fpcr)) != 0))
    _FPU_SETCW (new_fpcr);
}

# define libc_feholdexcept  libc_feholdexcept_vfp
# define libc_feholdexceptf libc_feholdexcept_vfp
# define libc_feholdexceptl libc_feholdexcept_vfp

# define libc_fesetround  libc_fesetround_vfp
# define libc_fesetroundf libc_fesetround_vfp
# define libc_fesetroundl libc_fesetround_vfp

# define libc_feresetround  libc_feresetround_vfp
# define libc_feresetroundf libc_feresetround_vfp
# define libc_feresetroundl libc_feresetround_vfp

# define libc_feresetround_noex  libc_fesetenv_vfp
# define libc_feresetround_noexf libc_fesetenv_vfp
# define libc_feresetround_noexl libc_fesetenv_vfp

# define libc_feholdexcept_setround  libc_feholdexcept_setround_vfp
# define libc_feholdexcept_setroundf libc_feholdexcept_setround_vfp
# define libc_feholdexcept_setroundl libc_feholdexcept_setround_vfp

# define libc_feholdsetround  libc_feholdsetround_vfp
# define libc_feholdsetroundf libc_feholdsetround_vfp
# define libc_feholdsetroundl libc_feholdsetround_vfp

# define libc_fetestexcept  libc_fetestexcept_vfp
# define libc_fetestexceptf libc_fetestexcept_vfp
# define libc_fetestexceptl libc_fetestexcept_vfp

# define libc_fesetenv  libc_fesetenv_vfp
# define libc_fesetenvf libc_fesetenv_vfp
# define libc_fesetenvl libc_fesetenv_vfp

# define libc_feupdateenv  libc_feupdateenv_vfp
# define libc_feupdateenvf libc_feupdateenv_vfp
# define libc_feupdateenvl libc_feupdateenv_vfp

# define libc_feupdateenv_test  libc_feupdateenv_test_vfp
# define libc_feupdateenv_testf libc_feupdateenv_test_vfp
# define libc_feupdateenv_testl libc_feupdateenv_test_vfp

/* We have support for rounding mode context.  */
# define HAVE_RM_CTX 1

# define libc_feholdsetround_ctx	libc_feholdsetround_vfp_ctx
# define libc_feresetround_ctx		libc_feresetround_vfp_ctx
# define libc_feresetround_noex_ctx	libc_fesetenv_vfp_ctx

# define libc_feholdsetroundf_ctx	libc_feholdsetround_vfp_ctx
# define libc_feresetroundf_ctx		libc_feresetround_vfp_ctx
# define libc_feresetround_noexf_ctx	libc_fesetenv_vfp_ctx

# define libc_feholdsetroundl_ctx	libc_feholdsetround_vfp_ctx
# define libc_feresetroundl_ctx		libc_feresetround_vfp_ctx
# define libc_feresetround_noexl_ctx	libc_fesetenv_vfp_ctx

#endif /* __csky_hard_float__ */

#endif /* FENV_PRIVATE_H */
