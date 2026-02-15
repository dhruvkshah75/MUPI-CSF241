.model small
.stack 100h

.data 

    newline db 13, 10, '$'

.code 
main proc 
    ; initialise the ds segment 
    mov ax, @data
    mov ds, ax

    


main endp
end