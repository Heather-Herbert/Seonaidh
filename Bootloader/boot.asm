; Seonaidh Bootloader
;   By Heather Herbert


	BITS 16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Here should be the JMP followed by the FAT disk table
;

diskStart:

        jmp     short   start                   ; MS-DOS/Windows checks for this jump
        nop
bsOemName               DB      "BootProg"      ; 0x03

bpbBytesPerSector       DW      0               ; 0x0B
bpbSectorsPerCluster    DB      0               ; 0x0D
bpbReservedSectors      DW      0               ; 0x0E
bpbNumberOfFATs         DB      0               ; 0x10
bpbRootEntries          DW      0               ; 0x11
bpbTotalSectors         DW      0               ; 0x13
bpbMedia                DB      0               ; 0x15
bpbSectorsPerFAT        DW      0               ; 0x16
bpbSectorsPerTrack      DW      0               ; 0x18
bpbHeadsPerCylinder     DW      0               ; 0x1A
bpbHiddenSectors        DD      0               ; 0x1C
bpbTotalSectorsBig      DD      0               ; 0x20

bsDriveNumber           DB      0               ; 0x24
bsUnused                DB      0               ; 0x25
bsExtBootSignature      DB      0               ; 0x26
bsSerialNumber          DD      0               ; 0x27
bsVolumeLabel           DB      "SEONAIDH   "   ; 0x2B
bsFileSystem            DB      "FAT12   "      ; 0x36


start:

	cld

        int     12h
        shl     ax, 6  


        sub     ax, (EndOfDiskData - diskStart)/ 16    
        mov     es, ax          

        sub     ax, 2048 / 16   
        mov     ss, ax          
        mov     sp, 2048        


LoadTheRestOfBootCode:

;;;;;;;;;;;;;;;;;;;;;;;;;
;;	INT 13h
;;	AH = 02
;;	AL = number of sectors to read	(1-128 dec.)
;;	CH = track/cylinder number  (0-1023 dec., see below)
;;	CL = sector number  (1-17 dec.)
;;	DH = head number  (0-15 dec.)
;;	DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;;	ES:BX = pointer to buffer
;;
;;
;;	on return:
;;	AH = status  (see INT 13,STATUS)
;;	AL = number of sectors read
;;	CF = 0 if successful
;;	   = 1 if error
ReadDiskSectors:
	mov	ah,0h
	mov	dl,0h
	int	13h
	add	ah,30h
	mov	al,ah
	mov 	ah,0Eh
	int	10h

	mov     ah, 02h
	mov	al, 02h
	xor	cx,cx
	inc	cl
	xor	dx,dx
 	lea	bx,[diskStart]
	int	13h
	jc	DisplayErrors
	add	al,30h
	mov 	ah,0Eh
	int	10h
	mov	al,2Dh
	mov 	ah,0Eh
	int	10h
	push	es
	pop	cs
	nop
	nop
	nop
	jmp	RestOfDiskData
	
DisplayErrors:
	add	ah,30h
	mov	al,ah
	mov 	ah,0Eh
	int	10h
	mov	al,20h
	mov 	ah,0Eh
	int	10h	
	jmp	ReadDiskSectors

RestOfDiskDataLink:

	jmp	RestOfDiskData





	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature



text_string db " Seonaidh By Heather Herbert      ",10,13
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


RestOfDiskData:

;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Now we're in where we want to be in memory, we should load the rest of the bootsectors in
;; then jump to the start of the main code.

;; Display the welcome message
	
 	mov	si, text_string
print_string:      ; Routine: output string in SI to screen 
  	mov 	ah, 0Eh    ; int 10h 'print char' function 
 
.repeat: 
  	lodsb   
  	cmp 	al, 0 
  	je 	.WeAreDonePrinting    ; If char is zero, end of string 
  	int 	10h      ; Otherwise, print it 
	jmp 	.repeat

.WeAreDonePrinting:
  	jmp 	.WeAreDonePrinting
EndOfDiskData: