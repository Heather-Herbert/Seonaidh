
ORG 100h       ; this is a DOS app at the mo

	call	Display_mesh
	xor	ax,ax
	mov	es,ax
	cli
	mov	ax, word [es:70h]
	mov	word [cs:oldint1ch],ax
	mov	ax, word [es:72h]
	mov	word [cs:oldint1ch+2],ax

	mov	word [es:70h],int_1Ch
	mov	word [es:72h],cs
	sti
	int 20h

oldint1ch	dd	0h

PRNGDATA:

PRNG_seed	DB	69h
PRNG_a		DB	13h
PRNG_b		DB	05h
	

PRNG:
	pusha

	mov	al,[PRNG_seed]
	xor	ah,ah
	mov	bl,[PRNG_a]
	mov	bh,[PRNG_b]
	mul	bl
	add	al,bh
	xor	[PRNG_seed],al
	xor	[PRNG_b],ah
	xor	[PRNG_a],dl
	xor	ax,ax
	int	1ah
	xor	[PRNG_b],dl
	xor	[PRNG_a],dh
	popa
	mov	al,[PRNG_seed]
	ret

Seconds		DW	00h

delay:
	pusha
	xor	ax,ax
	int	1ah
	mov	[Seconds],DX
delayInner:
	xor	ax,ax
	int	1ah
	cmp	[Seconds],DX
	jne	delayInner

	popa
	ret


Display_mesh:
	pusha
	mov	ax,13h
	int	10h
	mov	DX,320
	mov	CX,320
Draw_pixel:	
	mov	bh,00h
	Call	PRNG
	mov	AH,0Ch
	int	10h
	loop	Draw_pixel
	mov	CX, 320
	dec	DX
	jnz	Draw_pixel
	popa
	ret

DisplayX	dw	320
DisplayY	dw	320

int_1Ch:
	pusha
	pushf
	mov	cx,[DisplayX]
	mov	dx,[DisplayY]
	mov	bh,00h
	mov	al,01h
	mov	AH,0Ch
	int	10h

	dec	word [DisplayX]
	jnz	OutOfInt1ch
	mov	word [DisplayX],320
	dec	word [DisplayY]
	jnz	OutOfInt1ch
	;Remove the handle
	cli
	xor	ax,ax
	mov	es,ax
	mov	word [es:70h],oldint1ch
	sti
OutOfInt1ch:
	popf
	popa
	jmp	[cs:oldint1ch]

