org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

;FAT 12 header
jmp short start
nop

bdb_oem:					db 'MSWIN4.1'
bdb_bytes_per_sector:		dw 512
bdb_sectors_per_cluser:		db 1
bdb_reserved_sectors:		dw 1
bdb_fat_count:				db 2
bdb_dir_entries_count:		dw 0E0h
bdb_total_sectors:			dw 2880
bdb_media_descriptor_type:	db 0F0h
bdb_sectors_per_fat:		dw 9
bdb_sectors_per_track:		dw 18
bdb_head_count:				dw 2
bdb_hidden_sectors:			dd 0
bdb_large_sectors_count:	dd 0

;extended boot record

ebr_drive_number:			db 0
ebr_reserved:				db 0
ebr_signature:				db 29h
ebr_volume_id:				db 12h, 34h, 56h, 78h
ebr_volume_lable:			db 'MUTHUR 6000'		;must be 11 chars
ebr_system_id:				db 'FAT12   '			;must be 8 chars

start:
;sectors setup
	mov ax, 0
	mov ds, ax
	mov es, ax
;stack setup
	mov ss, ax
	mov sp, 0x7C00

	push es
	push word .after
	retf

.after:
	mov [ebr_drive_number], dl
	push es
	mov ah, 08h
	int 13h
	jc disk_fail
	pop es

	and cl, 0x3F
	xor ch, ch
	mov [bdb_sectors_per_track], cx

	inc dh
	mov [bdb_head_count], dh

	mov ax, [bdb_sectors_per_fat]
	mov bl, [bdb_fat_count]
	xor bh, bh
	mul bx 
	add ax, [bdb_reserved_sectors]
	push ax

	mov ax, [bdb_dir_entries_count]
	shl ax, 5
	xor dx, dx
	div word [bdb_bytes_per_sector]

	test dx, dx
	jz .root_dir_after
	inc ax

.root_dir_after:
	mov cl, al
	pop ax
	mov dl, [ebr_drive_number]
	mov bx, buffer
	call disk_read

	xor bx, bx
	mov di, buffer

.search_stage2:
	mov si, stage2_file_name
	mov cx, 11
	push di
	repe cmpsb
	pop di
	je .found_stage2
	add di, 32
	inc bx
	cmp bx, [bdb_dir_entries_count]
	jl .search_stage2
	mov si, stage2_not_found_error_msg
	call puts
	jmp reboot
.found_stage2:
	mov ax, [di + 26]
	mov [stage2_cluster], ax

	mov ax, [bdb_reserved_sectors]
	mov bx, buffer
	mov cl, [bdb_sectors_per_fat]
	mov dl, [ebr_drive_number]
	call disk_read

	mov bx, stage2_LOAD_SEGMENT
	mov es, bx
	mov bx, stage2_LOAD_OFFSET

.load_stage2_loop:
	mov ax, [stage2_cluster]
	add ax, 31		; This is hardcoded and possibly bad

	mov cl, 1
	mov dl, [ebr_drive_number]
	call disk_read 

	add bx, [bdb_bytes_per_sector] ; This will overflow if stage2.bin is larger then 64kB

	mov ax, [stage2_cluster]
	mov cx, 3
	mul cx
	mov cx, 2
	div cx

	mov si, buffer
	add si, ax
	mov ax, [ds:si]

	or dx, dx
	jz .even
.odd:
	shr ax, 4
	jmp .next_cluster_after
.even:
	and ax, 0x0FFF
.next_cluster_after:
	cmp ax, 0x0FF8
	jae .read_finish

	mov [stage2_cluster], ax
	jmp .load_stage2_loop
.read_finish:
	mov dl, [ebr_drive_number]

	mov ax, stage2_LOAD_SEGMENT
	mov ds, ax
	mov es, ax
	jmp stage2_LOAD_SEGMENT:stage2_LOAD_OFFSET
	jmp reboot ; Should never happen

	cli 
	hlt

puts:
	push si
	push ax
	push bx
.loop:
	lodsb
	or al, al
	jz .done
	mov ah, 0x0e
	mov bh, 0
	int 0x10
	jmp .loop
.done:
	pop bx
	pop ax
	pop si
ret

reboot:
	mov ah, 0
	int 16h
	jmp 0FFFFh:0


;ax - LBA adress
; returns:
; cx - sector number and cylinders
; dh - head
lba_to_chs: 
	push ax
	push dx

	xor dx, dx
	div word [bdb_sectors_per_track]
	inc dx
	mov cx, dx
	xor dx, dx
	div word [bdb_head_count]
	mov dh, dl
	mov ch, al
	shl ah, 6
	or cl, ah  

	pop ax
	mov dl, al
	pop ax
ret

; ax - LBA adress
; cl - number of sectores to read
; dl - drive number
; es::bx - memory adress where to store the data
disk_read: 
	push ax
	push bx
	push cx
	push dx
	push di

	push cx
	call lba_to_chs
	pop ax
	mov ah, 02h
	mov di, 3
.retry:
	pusha
	stc
	int 13h
	jnc .done
	popa
	call disk_reset
	dec di
	test di, di
	jnz .retry
	jmp disk_fail
.done:
	popa
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
ret

disk_fail:
	mov si, read_fail
	call puts 
	jmp reboot

disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc disk_fail
	popa
ret

read_fail:						db 'Failed to read from disk', ENDL, 0
stage2_file_name:				db 'BOOTS2  BIN'
stage2_not_found_error_msg:		db 'error: stage2 not found', ENDL, 0
stage2_cluster:					dw 0

stage2_LOAD_SEGMENT				equ 0x2000
stage2_LOAD_OFFSET				equ 0


times 510 - ($ - $$) db 0
dw 0AA55h

buffer:

