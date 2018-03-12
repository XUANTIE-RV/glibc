/* Macros for accessing thread-local storage.  C-SKY version.
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

#ifdef __CSKYABIV2__
# define TLS_LE(x)					\
  ({ int *__result;					\
     extern void * __read_tp (void);			\
     void *tp = __read_tp ();				\
     __asm__ ("lrw %0, " #x "@TPOFF; "			\
	  "add %0, %1, %0; "				\
	  : "=&r" (__result) : "r" (tp));		\
     __result; })

# define TLS_IE(x)					\
  ({ int *__result;					\
     extern void * __read_tp (void);			\
     void *tp = __read_tp ();				\
     __asm__ ("grs a1, 1f;"				\
      "1: lrw %0, " #x "@GOTTPOFF;"			\
	  "ldr.w %0, (a1, %0 << 0);"			\
	  "add %0, %1, %0; "				\
	  : "=&r" (__result): "r" (tp) : "a1" );	\
     __result; })

# define TLS_LD(x)					\
  ({ char *__result;					\
     int __offset;					\
     extern void *__tls_get_addr (void *);		\
     __asm__ ("grs a1, 1f;"				\
      "1: lrw %0, " #x "@TLSLDM32;"			\
	  "add %0, a1, %0; "				\
	  : "=r" (__result) : : "a1");			\
     __result = (char *)__tls_get_addr (__result);	\
     __asm__ ("lrw %0, " #x "@TLSLDO32; "		\
	  : "=r" (__offset));				\
     (int *) (__result + __offset); })

# define TLS_GD(x)					\
  ({ int *__result;					\
     extern void *__tls_get_addr (void *);		\
     __asm__ ("grs a1, 1f;"				\
      "1: lrw %0, " #x "@TLSGD32; "			\
	  "add %0, a1, %0; "				\
	  : "=r" (__result) : : "a1" );			\
     (int *)__tls_get_addr (__result); })

#else
# define TLS_LE(x)					\
  ({ int *__result;					\
     extern void * __read_tp (void);			\
     void *tp = __read_tp ();				\
     __asm__ ("lrw %0, " #x "@TPOFF\n\t "		\
	  "add %0, %1\n\t"				\
	  : "=&r" (__result) : "r" (tp));		\
     __result; })

# define TLS_IE(x)					\
  ({ int *__result;					\
     extern void * __read_tp (void);			\
     void *tp = __read_tp ();				\
     __asm__ ("bsr 1f\n\t"				\
	"1: lrw %0, " #x "@GOTTPOFF\n\t"		\
	"add	%0, r15\n\t"				\
	"ldw 	%0, (%0, 0)\n\t"			\
	"add	%0, %1\n\t"				\
	  : "=&r" (__result): "r" (tp) : "r15" );	\
     __result; })

# define TLS_LD(x)					\
  ({ char *__result;					\
     int __offset;					\
     extern void *__tls_get_addr (void *);		\
     __asm__ ("bsr 1f\n\t"				\
      "1: lrw %0, " #x "@TLSLDM32\n\t"			\
	  "add %0, r15\n\t"				\
	  : "=r" (__result) : : "r15");			\
     __result = (char *)__tls_get_addr (__result);	\
     __asm__ ("lrw %0, " #x "@TLSLDO32\n\t "		\
	  : "=r" (__offset));				\
     (int *) (__result + __offset); })

# define TLS_GD(x)					\
  ({ int *__result;					\
     extern void *__tls_get_addr (void *);		\
     __asm__ ("bsr 1f;"					\
      "1: lrw %0, " #x "@TLSGD32\n\t "			\
	  "add %0, r15\n\t"				\
	  : "=r" (__result) : : "r15" );		\
     (int *)__tls_get_addr (__result); })

#endif
