; Seonaidh Bootloader
;   By Heather Herbert


	BITS 16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Here should be the JMP followed by the FAT disk table
;


        jmp     short   start                   ; MS-DOS/Windows checks for this jump
        nop
bsOemName               DB      "BootProg"      ; 0x03

bpbBytesPerSector       DW      ?               ; 0x0B
bpbSectorsPerCluster    DB      ?               ; 0x0D
bpbReservedSectors      DW      ?               ; 0x0E
bpbNumberOfFATs         DB      ?               ; 0x10
bpbRootEntries          DW      ?               ; 0x11
bpbTotalSectors         DW      ?               ; 0x13
bpbMedia                DB      ?               ; 0x15
bpbSectorsPerFAT        DW      ?               ; 0x16
bpbSectorsPerTrack      DW      ?               ; 0x18
bpbHeadsPerCylinder     DW      ?               ; 0x1A
bpbHiddenSectors        DD      ?               ; 0x1C
bpbTotalSectorsBig      DD      ?               ; 0x20

bsDriveNumber           DB      ?               ; 0x24
bsUnused                DB      ?               ; 0x25
bsExtBootSignature      DB      ?               ; 0x26
bsSerialNumber          DD      ?               ; 0x27
bsVolumeLabel           DB      "SEONAIDH   "   ; 0x2B
bsFileSystem            DB      "FAT12   "      ; 0x36


start:

	cld

        int     12h
        shl     ax, 6  


        sub     ax, 512 / 16    
        mov     es, ax          

        sub     ax, 2048 / 16   
        mov     ss, ax          
        mov     sp, 2048        




	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature