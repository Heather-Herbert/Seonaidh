[BITS 16]	;tell the assembler that its a 16 bit code
[ORG 0x7C00]	;Origin, tell the assembler that where the code will
;be in memory after it is been loaded

	JMP short	over_data        ;Three bytes off start.
	NOP                   ;If short jump, must have NOP to make 3 bytes

OEM_ID            db 0x00
		  db 0x00
		  db 0x00
		  db 0x00
		  db 0x00	
		  db 0x00
		  db 0x00	
		  db 0x00

BytesPerSector    dw 0x0200        ;512 bytes per sector
SectorsPerCluster db 0x01          ;1 sector per cluster
ReservedSectors   dw 0x0001        ;Reserved sectors.. ie boot sector
TotalFats         db 0x02          ;2 copies of the FAT
MaxRootEntries    dw 0x0E0         ;Number of entries in the root. 224
TotalSectors      dw 0x0B40        ;Number of sectors in volume 2880
MediaDescriptor   db 0xF0          ; 1.44 floppy
SectorsPerFat     dw 0x0009        ;Number of sectors in a FAT 9
SectorsPerTrack   dw 0x0012        ;Sectors per Track 18
NumHeads          dw 0x0002        ;2 heads
HiddenSectors     dd 0x00000000
TotalSectorsLarge dd 0x00000000
DriveNumber       db 0x00
Flags             db 0x00
Signature        db 0x29
VolumeID          dd 0xFFFFFFFF
VolumeLabel	  db "Seonaidh   ",0
SystemID          db "FAT12   "     ;8 bytes

over_data:
;	MOV 		SI, VolumeLabel ;Store string pointer to SI;
;	CALL 		PrintString	;Call print string procedure

	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov sp, 0x7c00 ; thanks to Octocontrabass on OSDEV.org
	
	mov byte [SAVEDDRIVE], dl
	
	mov ah, 0x02
	mov al, 0x01
	mov ch, 0 ; track
	mov cl, 2 ; sector
	mov dh, 1
	mov byte dl, [SAVEDDRIVE]
	xor bx, bx
	mov es, bx
	mov bx, 0x7e00
	int 0x13
	
	mov si, 0x7e00
	mov di, KERNELNAME
	mov cx, 0
	jmp compare
	notequal:
		sub si, cx
		add si, 32
		mov cx, 0
		mov di, KERNELNAME
	compare:
		inc cx
		cmpsb
		jne notequal
		cmp cx, 11
		jge .compare_done
		jmp compare
	.compare_done:
	sub si, 11
	add si, 0x1a
	mov dx, [si]
	mov word [FILESECTOR], dx
	
	add si, 2
	mov word ax, [si]
	add si, 2
	mov word dx, [si]
	mov bx, 512
	div bx
	inc ax
	mov byte [FILESIZE], al
	
	mov ax, 32
	mov word dx, [FILESECTOR]
	add ax, dx
	call chs_convert
	
	mov ch, cl
	mov cl, bh
	mov dh, bl
	
	mov ah, 0x02
	mov byte al, [FILESIZE]
	mov byte dl, [SAVEDDRIVE]
	xor bx, bx
	mov es, bx
	mov bx, 0x8000
	int 0x13
	
	jmp 0:0x8000
	
	cli
	hlt
	.done:
		jmp .done
		
; ax = lba
; bh = sector
; bl = head
; cl = cylinder
chs_convert:	
	cmp ax, 18
	jg .gthan18
	jmp .ngthan18

	.gthan18:
		mov bl, 18
		div bl
		; ah = remainder, al = result
		cmp al, 2
		jl .lthan32
		jmp .gthan32
	
	.gthan32:
		mov bh, ah
		
		xor ah, ah
		mov bl, 2
		div bl
		; ah = remainder, al = result
		
		mov bl, ah
		mov cl, al
		jmp .done
	.lthan32:
		mov bh, ah
		mov bl, 1
		mov cl, 0
		jmp .done
	.ngthan18:
		mov bh, al
		xor bl, bl
		xor cl, cl
	.done:
		ret

FILESECTOR: dw 0
FILESIZE: db 0
SAVEDDRIVE: db 0
KERNELNAME: db "SEONAIDHCOM"

;CPE1704TKS




TIMES 510 - ($ - $$) db 0	;fill the rest of sector with 0
DW 0xAA55			; add boot signature at the end of bootloader