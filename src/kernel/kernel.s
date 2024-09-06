org 0x0
bits 16

%define ENDL 0x0D, 0x0A

main:
	mov si, hello_os
	call puts
	jmp halt

puts:
	push si
	push ax
.loop:
	lodsb
	or al, al
	jz .done
	mov ah, 0x0e
	int 0x10
	jmp .loop
.done:
	pop ax
	pop si
ret

halt:
	cli
	hlt
	jmp halt


hello_os: db 'Hello OS!', ENDL, 0
