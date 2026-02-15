.model small
.stack 100h

.data
    a db ?
    b db ?
    e db ?
    discriminant dw ?
    newline db 0dh, 0ah, '$'
    realEqualMsg  db 0dh,0ah,"The roots are real and equal.$"
    realDistinctMsg  db 0dh,0ah,"The roots are real and distinct.$"
    imaginaryMsg  db 0dh,0ah,"The roots are imaginary.$"

.code
main proc 
	;Initialize data segment
    mov ax, @data
    mov ds, ax
   

main endp
end main
