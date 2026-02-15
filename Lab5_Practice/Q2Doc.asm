.model small
.stack 100h

.data
    newline db 13, 10, '$'  
    ; 21 => max characters to read (20 chars + Enter key)
    ; ? => Placeholder for actual number of chars read (filled by DOS) 
    ; 21 dup('$') = The actual storage area (filled with '$' initially)
    buffer db 21, ?, 21 dup('$')

    ; when we make the buffer => buffer[0] => offset 0 stores the Max size (here 21)
    ; at offset = 1 => buffer[1] => stores the actual characters read e.g. if "HELLO" then offset = 1 is 5
    
.code
main proc 
    ; initialise data segment 
    mov ax, @data
    mov ds, ax

    ; now we take the input of the buffer string 
    mov ah, 0Ah             ; we use 0ah for buffered input 
    lea dx, buffer
    int 21h

    xor cx, cx
    mov cl, [buffer + 1]    ; the offset + 1 stores the actual len of str => store in cl as its byte 
    ; the len is set 

    ; if the length is 0
    cmp cl, 0
    je print_result      ; if cl is equal to 0 then print the ans 

    lea si, buffer + 2   ; store the pointer in si to point at the first element of the string 

; checked if the char is a lower case 
string_loop:
    xor bl, bl        ; clear the value of bl
    mov bl, [si]      ; now we check if bl is between 'a' and 'z'  
    cmp bl, 'a'
    jb skip_check1    ; => if bl < 'a' then go to skip_check and bl > 'z' skip check 
    cmp bl, 'z'
    ja skip_check1      
                      ; now since the bl is a lower case character 
    sub bl, 20h       ; convert to uppercase 
    mov [si], bl
    jmp skip_check2    
                      ; this step is needed as => when lower case is made into upper case we must go to the next char

; in the skip_check if the char is upper case 
skip_check1:
    xor bl, bl
    mov bl, [si]
    cmp bl, 'A'
    jb skip_check2
    cmp bl, 'Z'
    ja skip_check2
    ; now since the char is upper case convert it to lower case
    add bl, 20h 
    mov [si], bl

skip_check2:
    inc si                ; point to the next char and decrease the length 
    dec cl 
    cmp cl, 0
    jne string_loop       ; if cl is not equal to 0 then runn the loop again 


print_result:
    ; now we print the answer 
    mov ah, 09h
    lea dx, buffer + 2    ; the string is stored from offset = 2
    int 21h

    ; exit the program 
    mov ah, 4ch
    int 21h

main endp
end 
