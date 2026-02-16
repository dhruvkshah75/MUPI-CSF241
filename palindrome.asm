.model small
.stack 100h

.data 
    newline db 13, 10, '$'
    inputStr db 255, ?, 255 dup('$')
    yesMsg db "Yes!$"
    noMsg db "No!$"

.code 
main proc 
    ; intiliase the ds segment 
    mov ax, @data
    mov ds, ax 
    
    xor ax, ax
    mov ah, 0Ah
    lea dx, inputStr
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

    lea si, inputStr + 1
    xor cx, cx
    mov cl, [si]             ; cl now holds the length of the string 
    mov di, si
    add di, cx               ; now di points the last char
    inc si                   ; now si points the first char

check_palindrome:
    xor dx, dx
    mov dl, [si]
    mov dh, [di]
    cmp dl, dh
    jne print_no
    inc si
    dec di
    cmp si, di
    jb check_palindrome

print_yes:
    xor ax, ax
    mov ah, 09h
    lea dx, yesMsg
    int 21h
    jmp exit_program

print_no:
    xor ax, ax
    mov ah, 09h
    lea dx, noMsg
    int 21h

exit_program:
    xor ax, ax
    mov ah, 4ch
    int 21h

main endp
end