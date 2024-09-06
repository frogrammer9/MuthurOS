#include "stdio.h"

int* putn(int* np, u16 length /*in bytes*/, bool sign /*0-unsigned, 1-signed*/, u32 radix) {
	cstr m_hex = "0123456789abcdef";
	u64 m_number;
	char m_buffer[64];
	bool m_minusSign = false;
	i16 pos = 0;
	switch (length)
	{
		case 1:
		case 2:
			if(sign) {
				int tempNum = *np;
				m_minusSign = tempNum < 0;
				if(m_minusSign) { tempNum = -tempNum; }
				m_number = (u64)tempNum;
			}
			else { m_number = *(u16*)np; }
			np++;
			break;
		case 4:
			if(sign) {
				i32 tempNum = *(i32*)np;
				m_minusSign = tempNum < 0;
				if(m_minusSign) { tempNum = -tempNum; }
				m_number = (u64)tempNum;
			}
			else { m_number = *(u32*)np; }
			np+=2;
			break;
		case 8:
			if(sign) {
				i64 tempNum = *(i64*)np;
				m_minusSign = tempNum < 0;
				if(m_minusSign) { tempNum = -tempNum; }
				m_number = (u64)tempNum;
			}
			else { m_number = *(u64*)np; }
			np+=4;
			break;
	}
	do {
		u32 rem;
		x86_div_64_32(m_number, radix, &m_number, &rem);
		m_buffer[pos++] = m_hex[rem];
	} while(m_number > 0) ;
	if(m_minusSign) {m_buffer[pos++] = '-';}
	while(--pos >= 0) {
		putc(m_buffer[pos]);
	}
	return np;
}

void putc(char c) { 
	x86_write_char_teletype(c, 0);
}

void puts(cstr str) {
	while(*str) { x86_write_char_teletype(*(str++), 0); }
}

void __cdecl printf(const char* format, ...) {
	enum stateType { st_normal, st_length, st_specifier };
	enum stateType m_state;
	u16 m_length = 2;
	char m_lengthBuffer = '\0';

	int* argp = (int*)&format + 1;

	while(*format) {
		switch (m_state) {
			case st_normal:
				m_length = 2;
				m_lengthBuffer = '\0';
				switch (*format) {
					case '%':
						m_state = st_length;
					break;
					default:
						putc(*format);
					break;
				}
			break;
			case st_length:
				switch (*format) {
					case 'l':
						switch (m_lengthBuffer) {
							case 'l':
								m_length = 8;
								m_state = st_specifier;
							break;
							case 'h':
								puts("error : printf - invalid format string: \"");
								putc(*format);
								puts("\".\n");
								return;
							break;
							default:
								m_length = 4;
								m_lengthBuffer = 'l';
							break;
						}
					break;
					case 'h':
						switch (m_lengthBuffer) {
							case 'h':
								m_length = 1;
								m_state = st_specifier;
							break;
							case 'l':
								puts("error : printf - invalid format string: \"");
								putc(*format);
								puts("\".\n");
								return;
							break;
							default:
								m_length = 2;
								m_lengthBuffer = 'h';
							break;
						}
					break;
					default:
						m_state = st_specifier;
						goto st_specifier;
					break;
				}
			break;
			case st_specifier:
			st_specifier:
				switch (*format) {
					case '%': 
						putc('%');
					break;
					case 'd':
					case 'i':
						argp = putn(argp, m_length, true, 10);
					break;
					case 'u':
						argp = putn(argp, m_length, false, 10);
					break;
					case 'o':
						argp = putn(argp, m_length, false, 8);
					break;
					case 'x':
					case 'X':
					case 'p':
						argp = putn(argp, m_length, false, 16);
					break;
					case 'c':
						putc((char)*argp);
						argp++;
					break;
					case 's':
						puts(*(const char**)argp);
						argp++;
					break;
					default:
						puts("error : printf - invalid format string: \"");
						putc(*format);
						puts("\".\n");
					break;
				}
				m_state = st_normal;
			break;
		}
		format++;
	}
}
