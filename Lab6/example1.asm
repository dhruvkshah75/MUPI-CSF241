; create a file and write a message into the file 
.model small 
.stack 100h

; macro for creating a file 
CREATE_FILE MACRO filename_addr
    ; create file / rewrite file 
    mov ah, 3ch  
    lea dx, filename_addr
    mov cl, 0                   ; normal file attribute 
    int 21h 
ENDM

; macro for writing in the file 
WRITE_TO_FILE MACRO handle, buffer, bytes 
    mov ah, 40h
    mov bx, handle
    mov cx, bytes              ; bytes holds no of bytes to write 
    lea dx, buffer             ; data buffer that we want to write 
    int 21h

ENDM

.data 
    msg db 'Hello, World!$'
    ; name of the file => (ASCIIZ - ends in 0)
    filename db 'file_print.txt', 0
    count dw 13
    fhandle dw ? 
    error_msg db 'Error!$'

.code 
main proc 
    mov ax, @data 
    mov ds, ax

    ; -- CREATE THE FILE --
    CREATE_FILE filename         
    jc print_err
    mov fhandle, ax             ; store the file handle in ax 

    ; -- WRITE TO THE FILE 
    WRITE_TO_FILE fhandle, msg, count
    jc print_err 
    
    ; -- CLOSE THE FILE -- 
    mov ah, 3eh 
    mov bx, fhandle            ; store the handle in the bx 
    int 21h 
    
    jmp exit_program
    
print_err:
    mov ah, 09h 
    lea dx, error_msg
    int 21h   
    
exit_program:
    mov ah, 4ch
    int 21h 
     
main endp 
end 
