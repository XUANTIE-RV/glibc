/* Copyright (C) 1998, 1999, 2001 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Andreas Schwab <schwab@issan.informatik.uni-dortmund.de>, 1998.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#define SIGCONTEXT siginfo_t *_si, struct ucontext *
#define SIGCONTEXT_EXTRA_ARGS _si,
#define GET_PC(ctx)	((void *) (ctx)->uc_mcontext.sc_pc)
// r8 is fp, but it's no in the same area in sigcontext.
#if (__CSKY__ == 2)
#define GET_FRAME(ctx)	((void *) (ctx)->uc_mcontext.sc_regs[2])
#else
#define GET_FRAME(ctx)	((void *) (ctx)->uc_mcontext.sc_regs[2])
#endif
#define GET_STACK(ctx)	((void *) (ctx)->uc_mcontext.sc_usp)
#define CALL_SIGHANDLER(handler, signo, ctx) \
  (handler)((signo), SIGCONTEXT_EXTRA_ARGS (ctx))

/* There is no reliable way to get the sigcontext unless we use a
   three-argument signal handler.  */
#define __sigaction(sig, act, oact) ({ \
  (act)->sa_flags |= SA_SIGINFO; \
  (__sigaction) (sig, act, oact); \
})

#define sigaction(sig, act, oact) ({ \
  (act)->sa_flags |= SA_SIGINFO; \
  (sigaction) (sig, act, oact); \
})
