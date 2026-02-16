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
N, factor:FAR PTR SWORD, power:FAR PTR SWORD

        .CODE

Power2  PROC   FORTRAN, factor:FAR PTR SWORD, power:FAR PTR SWORD

        les     bx, factor
        mov     ax, ES:[bx]
        les     bx, power
        mov     cx, ES:[bx]
        shl     ax, cl
        ret
Power2  ENDP
        END
; Power2 routine called by FMAIN.FOR
; Assemble with ML /c FORTRAN.ASM

        .MODEL LARGE, FORTRAN

Power2  PROTO  FORTRAN, factor:FAR PTR SWORD, power:FAR PTR SWORD

        .CODE

Power2  PROC   FORTRAN, factor:FAR PTR SWORD, power:FAR PTR SW