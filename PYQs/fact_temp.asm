.model small
.stack 100h
.data
    newline db 0dh, 0ah, '$'  ; newline characters
    num db ?
    sum db 0

.code
main proc 
	;Initialize data segment
    mov ax, @data
    mov ds, ax
   

main endp
end main
