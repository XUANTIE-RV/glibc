/* Atomic operations.  C-SKY version.
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

#ifndef __CSKY_ATOMIC_H_
#define __CSKY_ATOMIC_H_

#include <stdint.h>

typedef int32_t atomic32_t;
typedef uint32_t uatomic32_t;

typedef intptr_t atomicptr_t;
typedef uintptr_t uatomicptr_t;
typedef intmax_t atomic_max_t;
typedef uintmax_t uatomic_max_t;

#define __HAVE_64B_ATOMICS 0
#define USE_ATOMIC_COMPILER_BUILTINS 0
#define ATOMIC_EXCHANGE_USES_CAS 0

# define __arch_compare_and_exchange_bool_8_int(mem, newval, oldval)	\
  (abort (), 0)

# define __arch_compare_and_exchange_bool_16_int(mem, newval, oldval)	\
  (abort (), 0)

# define __arch_compare_and_exchange_bool_32_int(mem, newval, oldval)	\
  ({ __typeof (mem) _mem = (mem);					\
    __typeof (oldval) _oldval = oldval;					\
    __typeof (newval) _newval = newval;					\
    register int _a0 asm ("a0") = (int)_oldval;				\
    register int _a1 asm ("a1") = (int)_newval;				\
    register int _a2 asm ("a2") = (int)_mem;				\
    __asm__ __volatile__ ("trap   2\n"					\
     : "+r" (_a0) : "r" (_a1) , "r" (_a2)				\
     : "a3", "memory");							\
    (int) _a0; })

# define __arch_compare_and_exchange_bool_64_int(mem, newval, oldval)	\
  (abort (), 0)

# define __arch_compare_and_exchange_val_8_int(mem, newval, oldval)	\
	(abort (), (__typeof (*mem))0)

# define __arch_compare_and_exchange_val_16_int(mem, newval, oldval)	\
	(abort (), (__typeof (*mem))0)

# define __arch_compare_and_exchange_val_32_int(mem, newval, oldval)	\
  ({ __typeof (mem) _mem = (mem);					\
    __typeof (*mem) __gret = *_mem;					\
    unsigned int _tmp = 0;						\
    __typeof (oldval) _oldval = oldval;					\
    __typeof (newval) _newval = newval;					\
    register int _a0 asm ("a0") = (int)_oldval;				\
    register int _a1 asm ("a1") = (int)_newval;				\
    register int _a2 asm ("a2") = (int)_mem;				\
	__asm__ __volatile__ ("1:\n"					\
      "ldw      %1, (%4, 0x0)\n"					\
      "cmpne    %1, %0\n"						\
      "bt       2f\n"							\
      "mov      %2, %0\n"						\
      "trap     2\n"							\
      "cmpnei   %0, 0\n"						\
      "mov      %0, %2\n"						\
      "bt       1b\n"							\
      "2:         \n"							\
     :"+r" (_a0), "+r"(__gret), "+r" (_tmp) :"r" (_a1) , "r" (_a2)	\
     : "a3", "memory");							\
    __gret; })

# define __arch_compare_and_exchange_val_64_int(mem, newval, oldval)	\
	(abort (), (__typeof (*mem))0)

# define atomic_compare_and_exchange_bool_acq(mem, new, old)		\
  __atomic_bool_bysize (__arch_compare_and_exchange_bool, int,		\
            mem, new, old)

# define atomic_compare_and_exchange_val_acq(mem, new, old)		\
  __atomic_val_bysize (__arch_compare_and_exchange_val, int,		\
               mem, new, old)

#endif
