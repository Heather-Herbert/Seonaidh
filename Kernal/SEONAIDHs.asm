[BITS 16]
[ORG 0x8000]

	MOV 		SI, IntroText	;Store string pointer to SI;
	CALL 		PrintString	;Call print string procedure

	jmp		$

	jmp		JUMP_TO_PROTECTED_MODE


IntroText   db " Seonaidh By Heather Herbert      ",10,13
  	    db "                                  ",10,13
            db "            !1Y|||=4D?            ",10,13
	    db "          P|ii||iiii|i||          ",10,13
	    db "        PT<i|iiii|ii|ii|jW        ",10,13
	    db "       E|||i|i|i|ii|ii|ii9        ",10,13
	    db "       =|ii|ii|i|i>+i|ii|i]       ",10,13
	    db "     P1|i|ii<|<wva/^<ii|ii|4      ",10,13
	    db "    W|ii|ii+WWWmGr   :|ii|i3      ",10,13
	    db "    fii|i+<yWmW3S     ii|i|3W     ",10,13
	    db "    kiii|]WWBWWD(  _Qg:+i|i=$     ",10,13
	    db "    P|i>` '#WWmE(  ]QQf iiii]     ",10,13
	    db "   W||i]   )mWB$c  'Q@` ii|iv     ",10,13
	    db "   E|i>u   ,$mWyX,      <i|ij     ",10,13
	    db "    =ivS  yQdWW6$o,    Jc|i|4     ",10,13
	    db "    (i>m. 4QfWBWm5Xs_snZ<|i|}     ",10,13
	    db "   F|i>m(  ' WWBWmU5mZ4y|i|i=     ",10,13
	    db "   f|i|jp,  .WWf9WWBWBWPi|ii=     ",10,13
	    db "   kiii|$Zs_wmZ=)$BWBWP|iii|j     ",10,13
	    db "    <|i|%4QVdW6=+mWBWY=l|i|i4     ",10,13
	    db "   B|i|ii|?WWWWWWWW7(|iii|iiI     ",10,13
	    db "   Ei|ii||i=)????^.naii|iii|v     ",10,13
	    db "    /ii|iiisL<w%iw2wp;ii|i|<m     ",10,13
	    db "     /iii|i7mLLJLJ5BB\i|ii|       ",10,13
	    db "     Ci|ii||7\m6m67?tiii|i|d      ",10,13
	    db "     f|ii|ii|><ZA(':i|i|ii>       ",10,13
	    db "     m<i|i|i|I<,+??^li|ii|v       ",10,13
	    db "      maa%|iijmp)4V#+ii|ay        ",10,13
	    db "         g<|i_/`|jQ@|i|3W         ",10,13
	    db "          mwa/'.||.a ~a           ",10,13
	    db "           WQmay  ,'              ",10,13
	    db "                   aw             ",10,13,0
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
[bits 32]

ProtectedMode:
    mov     ax, DATA_DESC - NULL_DESC
    mov     ds, ax ; update data segment



    .halt:
        hlt
        jmp 	.halt






