/* Copyright (C) 2002, 2003 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Andreas Schwab <schwab@suse.de>, 2002.

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

#include <sysdep.h>
#include <tls.h>
#include <csky_readtp.h>
#ifndef __ASSEMBLER__
# include <nptl/pthreadP.h>
#endif


#if IS_IN (libc) || IS_IN (libpthread) || IS_IN (librt)

# ifdef __PIC__

#define __GET_GB  \
           bsr 1f; 1: lrw gb, 1b@GOTPC; addu gb, lr;

#  define __JSR(symbol)    \
           lrw a2, symbol@PLT; add a2, gb; ld.w a2, (a2); jsr a2;

# if !IS_IN (libc)
#  define PSEUDO_ERRJMP \
           subi sp, 8; st.w lr, (sp); st.w gb, (sp, 4);         \
	   __GET_GB				\
	   bsr SYSCALL_ERROR;			\
           ld.w lr, (sp); ld.w gb, (sp, 4); addi sp, 8;         \
	   rts;
# else
#  define PSEUDO_ERRJMP  \
           subi sp, 8; st.w lr, (sp); st.w gb, (sp, 4);         \
           __GET_GB            \
           lrw a2, SYSCALL_ERROR@PLT; add a2, gb; ld.w a2, (a2);  \
	   jsr a2;						\
           ld.w lr, (sp); ld.w gb, (sp, 4); addi sp, 8;         \
           rts;
# endif

# else

#  define __GET_GB
#  define __JSR(symbol) jsri symbol;
#  define PSEUDO_ERRJMP jmpi SYSCALL_ERROR;
# endif


#ifdef	__CSKYABIV2__
#undef PSEUDO
#define PSEUDO(name, syscall_name, args)                                      \
  .section ".text";                                                           \
   99: PSEUDO_ERRJMP                                                          \
   .type __##syscall_name##_nocancel,@function;                               \
   .globl __##syscall_name##_nocancel;                                        \
   __##syscall_name##_nocancel:                                               \
    cfi_startproc;                                                                      \
    DO_CALL (syscall_name, args);                                             \
    btsti a0, 31;                                                             \
    bt    99b;                                                                \
    rts;                                                                      \
    cfi_endproc;                                                                      \
   .size __##syscall_name##_nocancel,.-__##syscall_name##_nocancel;           \
  ENTRY (name);                                                               \
    SINGLE_THREAD_P;                                                          \
    bt .Lpseudo_cancel;                                                       \
    DO_CALL (syscall_name, args);                                             \
    btsti a0, 31;                                                             \
    bt    99b;                                                                \
    rts;                                                                      \
.Lpseudo_cancel:                                                              \
    DOCARGS_##args;     /* save syscall reg(r7),  syscall args and lr */      \
    __GET_GB;                                                                 \
    CENABLE;                                                                  \
    mov	t0, a0;         /* Save result of CENABLE */                          \
    UNDOSYSARGS_##args; /* restore syscall args */                            \
    DO_CALL_2 (syscall_name, args);                                           \
    mov r7, a0;         /* save result of syscall */                          \
    mov a0, t0;         /* restore result of CENABLE */                       \
    CDISABLE;                                                                 \
    mov	a0, r7;         /* restore result of syscall */                       \
    RESTORE_LR_R7_##args;                                                     \
    btsti a0, 31;                                                             \
    bt    99b;                                                                \
    rts;                                                                      \


#else	/* __CSKYABIV1__ */

#undef PSEUDO
#define PSEUDO(name, syscall_name, args)                                      \
  .section ".text";                                                           \
   99: PSEUDO_ERRJMP                                                          \
   .type __##syscall_name##_nocancel,@function;                               \
   .globl __##syscall_name##_nocancel;                                        \
   __##syscall_name##_nocancel:                                               \
    DO_CALL (syscall_name, args);                                             \
    btsti a0, 31;                                                             \
    bt    99b;                                                                \
    rts;                                                                      \
   .size __##syscall_name##_nocancel,.-__##syscall_name##_nocancel;           \
  ENTRY (name);                                                               \
    SINGLE_THREAD_P;                                                          \
    bt .Lpseudo_cancel;                                                       \
    DO_CALL (syscall_name, args);                                             \
    btsti a0, 31;                                                             \
    bt    99b;                                                                \
    rts;                                                                      \
.Lpseudo_cancel:							      \
    DOCARGS_##args;      /* save syscall args and lr */                       \
    __GET_GB;                                                                 \
    CENABLE;                                                                  \
    mov  r9, a0;                                                              \
    UNDOSYSARGS_##args; /* restore syscall args */                            \
    lrw r1, SYS_ify (syscall_name);                                           \
    trap 0;                                                                   \
    mov  r1, a0;        /* save result of syscall */                          \
    mov  a0, r9;        /* restore result of CENABLE */                       \
    mov  r9, r1;                                                              \
    CDISABLE;                                                                 \
    mov  a0, r9;        /* restore result of syscall */                       \
    RESTORE_LR_##args;                                                        \
    btsti a0, 31;                                                             \
    bt    99b;                                                                \
    rts;                                                                      \

#endif/* __CSKYABIV2__ */

#ifdef	__CSKYABIV2__
#define DOCARGS_0       \
  subi  sp, 12; .cfi_def_cfa_offset 12;         \
  stw   r15, (sp, 0);  .cfi_offset 15, -12; 	\
  stw   gb, (sp, 4);   .cfi_offset 28, -8; 	\
  stw   r7, (sp, 8);    .cfi_offset 7, -4;
#define UNDOSYSARGS_0
#define RESTORE_LR_R7_0 \
  ldw   r15, (sp, 0);   \
  ldw   gb, (sp, 4);    \
  ldw   r7, (sp, 8);    \
  addi  sp, 12

#define DOCARGS_1       \
  subi  sp, 16; .cfi_def_cfa_offset 16;         \
  stw   a0, (sp, 0);    \
  stw   r15, (sp, 4);   .cfi_offset 15, -12;	\
  stw   gb, (sp, 8);    .cfi_offset 28, -8;	\
  stw   r7, (sp, 12);   .cfi_offset 7, -4;
#define UNDOSYSARGS_1   \
  ldw   a0, (sp, 0);    \
  addi  sp, 4;	.cfi_adjust_cfa_offset -4;
#define RESTORE_LR_R7_1 RESTORE_LR_R7_0

#define DOCARGS_2       \
  subi  sp, 20; .cfi_def_cfa_offset 20; 	\
  stw   a0, (sp, 0);    \
  stw   a1, (sp, 4);    \
  stw   r15, (sp, 8);   .cfi_offset 15, -12;	\
  stw   gb, (sp, 12);   .cfi_offset 28, -8;	\
  stw   r7, (sp, 16);	.cfi_offset 7, -4;
#define UNDOSYSARGS_2   \
  ldw   a0, (sp, 0);    \
  ldw   a1, (sp, 4);    \
  addi  sp, 8; .cfi_adjust_cfa_offset -8;
#define RESTORE_LR_R7_2 RESTORE_LR_R7_0

#define DOCARGS_3       \
  subi  sp, 24; .cfi_def_cfa_offset 24;        	\
  stw   a0, (sp, 0);    \
  stw   a1, (sp, 4);    \
  stw   a2, (sp, 8);    \
  stw   r15, (sp, 12);  .cfi_offset 15, -12;	\
  stw   gb, (sp, 16);   .cfi_offset 28, -8;	\
  stw   r7, (sp, 20);	.cfi_offset 7, -4;
#define UNDOSYSARGS_3   \
  ldw   a0, (sp, 0);    \
  ldw   a1, (sp, 4);    \
  ldw   a2, (sp, 8);    \
  addi  sp, 12; .cfi_adjust_cfa_offset -12;
#define RESTORE_LR_R7_3 RESTORE_LR_R7_0

#define DOCARGS_4       \
  subi  sp, 28;; .cfi_def_cfa_offset 28;         \
  stw   a0, (sp, 0);    \
  stw   a1, (sp, 4);    \
  stw   a2, (sp, 8);    \
  stw   a3, (sp, 12);   \
  stw   r15, (sp, 16);  .cfi_offset 15, -12;	\
  stw   gb, (sp, 20);   .cfi_offset 28, -8;	\
  stw   r7, (sp, 24);   .cfi_offset 7, -4;
#define UNDOSYSARGS_4   \
  ldw   a0, (sp, 0);    \
  ldw   a1, (sp, 4);    \
  ldw   a2, (sp, 8);    \
  ldw   a3, (sp, 12);   \
  addi  sp, 16; .cfi_adjust_cfa_offset -16;
#define RESTORE_LR_R7_4 RESTORE_LR_R7_0

#define DOCARGS_5	DOCARGS_4
#define UNDOSYSARGS_5	UNDOSYSARGS_4
#define RESTORE_LR_R7_5	RESTORE_LR_R7_0
#define DOCARGS_6	DOCARGS_4
#define UNDOSYSARGS_6	UNDOSYSARGS_4
#define RESTORE_LR_R7_6	RESTORE_LR_R7_0
#else	/* __CSKYABIV1__ */
#define DOCARGS_0	\
  subi	sp, 16;	 .cfi_def_cfa_offset 16;	\
  stw	r15, (sp, 0); .cfi_offset 15, -16;	\
  stw	r9, (sp, 4);  .cfi_offset 9, -12;	\
  stw   r14, (sp, 8); .cfi_offset 14, -8;
#define UNDOSYSARGS_0
#define RESTORE_LR_0	\
  ldw	r15, (sp, 0);	\
  ldw	r9, (sp, 4);	\
  ldw	r14, (sp, 8);	\
  addi	sp, 16

#define DOCARGS_1	\
  subi	sp, 16;	.cfi_def_cfa_offset 16;	\
  stw	r15, (sp, 0); .cfi_offset 15, -16;	\
  stw	r9, (sp, 4);  .cfi_offset 9, -12;	\
  stw	r14, (sp, 8); .cfi_offset 14, -8;   \
  stw	r2, (sp, 12); 	
#define UNDOSYSARGS_1	\
  ldw	r2, (sp, 12);	
#define RESTORE_LR_1	RESTORE_LR_0

#define DOCARGS_2	\
  subi	sp, 24;	  .cfi_def_cfa_offset 24;	\
  stw	r2, (sp, 0); 	\
  stw	r3, (sp, 4);	\
  stw	r15, (sp, 8);   .cfi_offset 15, -16;	\
  stw	r9, (sp, 12);   .cfi_offset 9, -12; 	\
  stw	r14, (sp, 16);  .cfi_offset 14, -8;
#define UNDOSYSARGS_2	\
  ldw	r2, (sp, 0);	\
  ldw	r3, (sp, 4);	\
  addi	sp, 8; .cfi_adjust_cfa_offset -8;
#define RESTORE_LR_2	RESTORE_LR_0

#define DOCARGS_3	\
  subi	sp, 24;	 .cfi_def_cfa_offset 24;	\
  stw	r2, (sp, 0);	\
  stw	r3, (sp, 4);	\
  stw	r15, (sp, 8);   .cfi_offset 15, -16;	\
  stw	r9, (sp, 12);   .cfi_offset 9, -12;	\
  stw	r14, (sp, 16);  .cfi_offset 14, -8;  \
  stw	r4, (sp, 20);	
#define UNDOSYSARGS_3	\
  ldw	r2, (sp, 0);	\
  ldw	r3, (sp, 4);	\
  ldw	r4, (sp, 20);	\
  addi	sp, 8; .cfi_adjust_cfa_offset -8;
#define RESTORE_LR_3	RESTORE_LR_0

#define DOCARGS_4	\
  subi	sp, 32;	  .cfi_def_cfa_offset 32;	\
  stw	r2, (sp, 0); 	\
  stw	r3, (sp, 4);	\
  stw	r4, (sp, 8);	\
  stw	r5, (sp, 12);	\
  stw	r15, (sp, 16);  .cfi_offset 15, -16;	\
  stw	r9, (sp, 20);	.cfi_offset 9, -12;  \
  stw	r14, (sp, 24);  .cfi_offset 14, -8;
#define UNDOSYSARGS_4	\
  ldw	r2, (sp, 0);	\
  ldw	r3, (sp, 4);	\
  ldw	r4, (sp, 8);	\
  ldw	r5, (sp, 12);	\
  addi	sp, 16; .cfi_adjust_cfa_offset -16;
#define RESTORE_LR_4	RESTORE_LR_0

#define DOCARGS_5	\
  subi	sp, 32;	 .cfi_def_cfa_offset 32;	\
  stw	r2, (sp, 0);	\
  stw	r3, (sp, 4);	\
  stw	r4, (sp, 8);	\
  stw	r5, (sp, 12);	\
  stw	r15, (sp, 16);	.cfi_offset 15, -16; \
  stw	r9, (sp, 20);	.cfi_offset 9, -12;  \
  stw	r14, (sp, 24);  .cfi_offset 14, -8;  \
  stw	r6, (sp, 28);	
#define UNDOSYSARGS_5	\
  ldw	r2, (sp, 0);	\
  ldw	r3, (sp, 4);	\
  ldw	r4, (sp, 8);	\
  ldw	r5, (sp, 12);	\
  ldw	r6, (sp, 28);	\
  addi	sp, 16; .cfi_adjust_cfa_offset -16;
#define RESTORE_LR_5	RESTORE_LR_0

#define DOCARGS_6	\
  subi	sp, 32;	 .cfi_def_cfa_offset 32;	\
  subi	sp, 8;   .cfi_def_cfa_offset 8;		\
  stw	r2, (sp, 0);	\
  stw	r3, (sp, 4);	\
  stw	r4, (sp, 8);	\
  stw	r5, (sp, 12);	\
  stw	r6, (sp, 16);	\
  stw	r7, (sp, 20);	\
  stw	r15, (sp, 24);	.cfi_offset 15, -16; \
  stw	r9, (sp, 28);	.cfi_offset 9, -12;  \
  stw	r14, (sp, 32);  .cfi_offset 14, -8;
#define UNDOSYSARGS_6	\
  ldw	r2, (sp, 0);  	\
  ldw	r3, (sp, 4);  	\
  ldw	r4, (sp, 8);  	\
  ldw	r5, (sp, 12); 	\
  ldw	r6, (sp, 16); 	\
  ldw	r7, (sp, 20); 	\
  addi	sp, 24; .cfi_adjust_cfa_offset -24;
#define RESTORE_LR_6	RESTORE_LR_0

#define UNDOARGS_0
#define UNDOARGS_1
#define UNDOARGS_2
#define UNDOARGS_3
#define UNDOARGS_4
#define UNDOARGS_5
#define UNDOARGS_6

#endif	/* __CSKYABIV2__ */



# if IS_IN (libpthread)
#  ifdef __PIC__
#   define CENABLE	__JSR (__pthread_enable_asynccancel)
#   define CDISABLE	__JSR (__pthread_disable_asynccancel)
#  else
#   define CENABLE	__JSR (__pthread_enable_asynccancel)
#   define CDISABLE	__JSR (__pthread_disable_asynccancel)
#  endif
# elif IS_IN (libc)
#  ifdef __PIC__
#   define CENABLE	__JSR (__libc_enable_asynccancel)
#   define CDISABLE	__JSR (__libc_disable_asynccancel)
#  else
#   define CENABLE	__JSR (__libc_enable_asynccancel)
#   define CDISABLE	__JSR (__libc_disable_asynccancel)
#  endif
# else
#  ifdef __PIC__
#   define CENABLE	__JSR (__librt_enable_asynccancel)
#   define CDISABLE	__JSR (__librt_disable_asynccancel)
#  else
#   define CENABLE	__JSR (__librt_enable_asynccancel)
#   define CDISABLE	__JSR (__librt_disable_asynccancel)
#  endif
# endif

# if IS_IN (libc)
#  define __local_multiple_threads __libc_multiple_threads
# elif IS_IN (libpthread)
#  define __local_multiple_threads __pthread_multiple_threads
# else
#  define __local_multiple_threads __librt_multiple_threads
# endif

#ifndef __ASSEMBLER__
#  if IS_IN (libpthread) || IS_IN (libc)
extern int __local_multiple_threads attribute_hidden;
#     define SINGLE_THREAD_P __builtin_expect (__local_multiple_threads == 0, 1)
#  else /* IS_IN_libpthread || !defined NOT_IN_libc  */
#     define SINGLE_THREAD_P                      \
        __builtin_expect (THREAD_GETMEM (THREAD_SELF,             \
                   header.multiple_threads) == 0, 1)
#  endif
#else
#     define SINGLE_THREAD_P    \
      subi      sp, 8;          \
      stw       a0, (sp, 0);    \
      stw       a1, (sp, 4);    \
      csky_read_tp;             \
      lrw       a1, MULTIPLE_THREADS_OFFSET;    \
      add       a0, a1;         \
      ldw       a0, (a0);       \
      cmpnei    a0, 0;          \
      ldw       a0, (sp, 0);    \
      ldw       a1, (sp, 4);    \
      addi      sp, 8
# endif



#elif !defined __ASSEMBLER__

/* This code should never be used but we define it anyhow.  */
# define SINGLE_THREAD_P (1)
# define NO_CANCELLATION (1)

#endif

#ifndef __ASSEMBLER__
# define RTLD_SINGLE_THREAD_P                                     \
  __builtin_expect (THREAD_GETMEM (THREAD_SELF,                   \
                                   header.multiple_threads) == 0, \
                    1)
#endif
