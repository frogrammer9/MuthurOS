#ifndef _STDM_X86_
#define _STDM_X86_

#include "stdint.h"

void __cdecl x86_write_char_teletype(char, u8);

void __cdecl x86_div_64_32(u64, u32, u64*, u32*);

#endif
