.model small
.code
org 256
s:	push	cs
	pop	ds
	call	t
db	'ѥ$'
t:	pop	dx
	mov	ah,9
	int	33
	mov	ah,76
	int	33
end s
wer:PTR WORD
        .CODE
Power2  PROC    PASCAL, Factor:PTR WORD, Power:PTR WORD

        mov     bx, WORD PTR Factor   ; Load Factor into
        mov     ax, [bx]              ;  AX
        mov     bx, WORD PTR Power    ; Load Power into
        mov     cx, [bx]              ;   CX
        shl     ax, cl                ; AX = AX * (2 to power of CX)
                
        ret
Power2  ENDP     

        END
; Called by BASMAIN.BAS
; Assemble with ML /c BASIC.ASM

        .MODEL  medium

Power2  PROTO   PASCAL, Factor:PTR WORD, Power:PTR WORD
        .CODE
Power2  PROC    PASCAL, Factor:PTR WORD, Power:PTR WORD

        mov     bx, WORD PTR Factor   ;