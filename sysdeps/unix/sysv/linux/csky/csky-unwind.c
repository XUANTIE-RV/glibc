#include <sysdeps/generic/unwind.h>

#undef SjLj_Function_Context
#undef _Unwind_SjLj_Register
#undef _Unwind_SjLj_Unregister
#undef _Unwind_SjLj_RaiseException
#undef _Unwind_SjLj_ForcedUnwind
#undef __gcc_personality_sj0
#undef _Unwind_Find_FDE
__attribute__((weak)) struct SjLj_Function_Context;


__attribute__((weak)) void  _Unwind_SjLj_Register (struct SjLj_Function_Context *test){}
__attribute__((weak)) void _Unwind_SjLj_Unregister (struct SjLj_Function_Context *test){}
__attribute__((weak)) _Unwind_Reason_Code _Unwind_SjLj_RaiseException
     (struct _Unwind_Exception *test){}
__attribute__((weak)) _Unwind_Reason_Code _Unwind_SjLj_ForcedUnwind
     (struct _Unwind_Exception *test1, _Unwind_Stop_Fn test2, void *test3){}
__attribute__((weak)) void _Unwind_SjLj_Resume (struct _Unwind_Exception *test){}



__attribute__((weak)) void __gcc_personality_sj0(){}


__attribute__((weak)) void *
_Unwind_Find_FDE (void *a1, struct dwarf_eh_bases *a2)
{
  abort ();
}


__attribute__((weak)) _Unwind_Reason_Code _Unwind_ForcedUnwind (struct _Unwind_Exception *test1,
                                                 _Unwind_Stop_Fn test2 ,
                                                 void *test3){}
