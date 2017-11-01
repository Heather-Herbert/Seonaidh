[BITS 16]
[ORG 0x8000]

	MOV 		SI, IntroText	;Store string pointer to SI;
	CALL 		PrintString	;Call print string procedure

	mov		dword [VESAInfo_Signature],'VBE2'
	mov		ax,4f00h   ; Is Vesa installed ?
	mov		di,VESAInfo    ; This is the address of our info block.
	int		10h

	pusha
	mov		SI,GotVESAInfo
	CALL		PrintString
	popa

	cmp		ax,004Fh   ; Is vesa installed ?,
	jne		near VESAError_NoVESA    ; If not print a mesage & quit.

	pusha
	mov		SI,dot
	CALL		PrintString
	popa

	mov		ax,4f01h   ; Get Vesa Mode information.
	mov		di,Mode_Info   ; This is the address of how info block.
	;mov		cx,0x4101   ; 4112h = 32/24bit ; 0x4101 = 8bit ;4111h = 15bit (640*480)
	;and		cx,0xfff
	int		10h

	pusha
	mov		SI,dot
	CALL		PrintString
	popa

	cmp		dword [VESAInfo_Signature], 'VESA'
	jne		near VESAError_NoVESA

	pusha
	mov		SI,dot
	CALL		PrintString
	popa

	cmp		byte [VESAInfo_Version+1], 2
	jb		VESAError_ToLow   ; VESA version below 2.0

	pusha
	mov		SI,dot
	CALL		PrintString
	mov		SI,VESADataLoaded
	CALL		PrintString
	popa

	jmp		JUMP_TO_PROTECTED_MODE
VESAError_ToLow:
	mov		SI,VESATooLow
	jmp		DisplayErrorMessage
VESAError_NoVESA:
	mov		SI,VESAMissing
DisplayErrorMessage:
	Call		PrintString
	jmp		$


IntroText		DB	"Seonaidh Version 1.1a by Heather Herbert (2017)",10,13,0

VESAMissing		DB	"VESA not installed",10,13,0
VESATooLow		DB	"VESA below version 2",10,13,0
VESADataLoaded		DB	"VESA data loaded and mode set",10,13,0
GotVESAInfo		DB	"Got VESA Info",10,13,0
dot			DB	".",0

;VESA Data Block
VESAInfo:
VESAInfo_Signature   db   'VESA'      ; 4 signature bytes
VESAInfo_Version     dw   0           ; VESA version number
VESAInfo_OEMStringPtr    dd   0          ; Pointer to OEM string
VESAInfo_Capabilities    times 4 db 0    ; capabilities of the video environment
VESAInfo_VideoModePtr    dd   0           ; pointer to supported Super VGA modes
VESAInfo_TotalMemory     dw   0           ; Number of 64kb memory blocks on board
VESAInfo_Reserved        times 236 db 0 ; Remainder of VgaInfoBlock

Mode_Info:
ModeInfo_ModeAttributes		dw	1
ModeInfo_WinAAttributes		db	1
ModeInfo_WinBAttributes		db	1
ModeInfo_WinGranularity		dw	1
ModeInfo_WinSize		dw	1
ModeInfo_WinASegment		dw	1
ModeInfo_WinBSegment		dw	1
ModeInfo_WinFuncPtr		dd	1
ModeInfo_BytesPerScanLine	dw	1
ModeInfo_XResolution		dw	1
ModeInfo_YResolution		dw	1
ModeInfo_XCharSize		db	1
ModeInfo_YCharSize		db	1
ModeInfo_NumberOfPlanes		db	1
ModeInfo_BitsPerPixel		db	1
ModeInfo_NumberOfBanks		db	1
ModeInfo_MemoryModel		db	1
ModeInfo_BankSize		db	1
ModeInfo_NumberOfImagePages	db	1
ModeInfo_Reserved_page		db	1
ModeInfo_RedMaskSize		db	1
ModeInfo_RedMaskPos		db	1
ModeInfo_GreenMaskSize		db	1
ModeInfo_GreenMaskPos		db	1
ModeInfo_BlueMaskSize		db	1
ModeInfo_BlueMaskPos		db	1
ModeInfo_ReservedMaskSize	db	1
ModeInfo_ReservedMaskPos	db	1
ModeInfo_DirectColorModeInfo	db	1
; VBE 2.0 extensions
ModeInfo_PhysBasePtr		dd	1
ModeInfo_OffScreenMemOffset	dd	1
ModeInfo_OffScreenMemSize	dw	1

PrintCharacter:	;Procedure to print character on screen
	;Assume that ASCII value is in register AL
	MOV 		AH, 0x0E	;Tell BIOS that we need to print one charater on screen.
	MOV 		BH, 0x00	;Page no.
	MOV 		BL, 0x08	;Text attribute 0x07 is lightgrey font on black background

	INT 		0x10		;Call video interrupt
	RET				;Return to calling procedure

PrintString:	;Procedure to print string on screen
	;Assume that string starting pointer is in register SI

next_character:	;Lable to fetch next character from string
	MOV 		AL, [SI]	;Get a byte from string and store in AL register
	INC 		SI		;Increment SI pointer
	OR 		AL, AL		;Check if value in AL is zero (end of string)
	JZ 		exit_function 	;If end then return
	CALL 		PrintCharacter 	;Else print the character which is in AL register
	JMP 		next_character	;Fetch next character from string
exit_function:	;End label
	RET		;Return from procedure

;XYZZY
	MOV		AL,0x58
	MOV		AL,0x59
	MOV		AL,0x5A
	MOV		AL,0x5A
	MOV		AL,0x59
;PLUGH
	MOV		AL,0x50
	MOV		AL,0x4C
	MOV		AL,0x55
	MOV		AL,0x47
	MOV		AL,0x48

JUMP_TO_PROTECTED_MODE:

    xor ax, ax
    mov ds, ax              ; update data segment

    cli                     ; clear interrupts

    lgdt [gdtr]             ; load GDT from GDTR (see gdt_32.inc)

    call OpenA20Gate        ; open the A20 gate 

    call EnablePMode        ; jumps to ProtectedMode

;******************
;* Opens A20 Gate *
;******************
OpenA20Gate:
    in al, 0x93         ; switch A20 gate via fast A20 port 92

    or al, 2            ; set A20 Gate bit 1
    and al, ~1          ; clear INIT_NOW bit
    out 0x92, al

    ret

;**************************
;* Enables Protected Mode *
;**************************
EnablePMode:
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp (CODE_DESC - NULL_DESC) : ProtectedMode

;***************
;* data fields *
;*  &includes  *
;***************
;%include "gdt_32.inc"
;*********************************
;* Global Descriptor Table (GDT) *
;*********************************
NULL_DESC:
    dd 0            ; null descriptor
    dd 0

CODE_DESC:
    dw 0xFFFF       ; limit low
    dw 0            ; base low
    db 0            ; base middle
    db 10011010b    ; access
    db 11001111b    ; granularity
    db 0            ; base high

DATA_DESC:
    dw 0xFFFF       ; limit low
    dw 0            ; base low
    db 0            ; base middle
    db 10010010b    ; access
    db 11001111b    ; granularity
    db 0            ; base high

gdtr:
    Limit dw gdtr - NULL_DESC - 1 ; length of GDT
    Base dd NULL_DESC   ; base of GDT

;******************
;* Protected Mode *
;******************
bits 32

ProtectedMode:
    mov     ax, DATA_DESC - NULL_DESC
    mov     ds, ax ; update data segment



    .halt:
        hlt
        jmp 	.halt






