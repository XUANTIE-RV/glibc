/* Macro defiation for string/mem operations on different cpu types
   Copyright (C) 2011     Hangzhou C-SKY
   Copyright (C) 2003-2005,2007,2009,2011,2012 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Jakub Jelinek <jakub@redhat.com>, 2003.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */


#if defined ( __ck802__ )
.macro M_BEZ rx, label
       cmpnei \rx, 0
       bf     \label
.endm
.macro M_BNEZ rx, label
      cmpnei \rx, 0
      bt     \label 
.endm
#else
.macro M_BEZ rx, label
      bez  \rx, \label
.endm
.macro M_BNEZ rx, label
      bnez \rx, \label
.endm
#endif

.macro M_BNE rx, ry, label
      cmpne \rx, \ry
      bt    \label
.endm

