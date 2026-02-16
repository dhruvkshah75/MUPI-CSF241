
.model small
.stack 100h

.data 
    newline db 13, 10, '$'
    inputStr db 255, ?, 255 dup('$')
    target db 255, ?, 255 dup('$')
    replace db 255, ?, 255 dup('$')
    lenInputStr db ?
    lenTarget db ?                            ; the len of target and replacement will be the same 

.code 
main proc 
    mov ax, @data 
    mov ds, ax
    mov es, ax

intput_strings:
    ; --- Input String ----
    xor ax, ax
    mov ah, 0Ah
    lea dx, inputStr
    int 21h 

    xor ax, ax
    mov ah, 09h
    lea dx, newline
    int 21h

    ; --- input target string ---
    xor ax, ax
    mov ah, 0Ah
    lea dx, target
    int 21h

    xor ax, ax
    mov ah, 09h
    lea dx, newline
    int 21h

    ; --- input replacement string 
    xor ax, ax
    mov ah, 0Ah
    lea dx, replace
    int 21h

    xor ax, ax
    mov ah, 09h
    lea dx, newline 
    int 21h

Question:   
    lea si, inputStr + 1
    mov cl, [si]
    mov lenInputStr, cl              ; store the length of the inputString 

    xor cx, cx
    lea si, target + 1
    mov cl, [si]
    mov lenTarget, cl
    xor dx, dx 
    mov dl, 0                        ; run till al < len

    lea si, inputStr + 2             ; si now points to first element of the string 

traverse_string:
    push si                          ; store si in stack so we can run the inner check loop
    mov bl, lenTarget                ; store the len of the target so we can run the inner loop till it becomes 0
    lea di, target + 2               ; di must point to the target string 
    cld 

inner_loop:
    lodsb                            ; this stores the first character in AL 
    cmp al, [di]                     
    jne skip_check
    inc di
    dec bl
    cmp bl, 0
    jne inner_loop                    
    ; if we reach here that means that we must replcae this in the string 
    pop si                          ; get the original si where the pointer actually was 
    push si                         ; store it again as we will need it at the end of the outer loop
    mov di, si                      ; now the di points to the actual string 
    lea si, replace + 2             ; let si point the replace string so that we can use movsb
    xor cx, cx
    mov cl, lenTarget               ; movsb uses cx as the counter 
    cld                             ; make the direction flag = 0 (forward)
    rep movsb                       ; movsb transfers the contents of si to di => si points replace string 


skip_check:
    pop si                          ; now si points the original 
    inc si
    inc dl
    cmp dl, lenInputStr
    jb traverse_string              ; traverse the string until cl < len of the input of string 

; now the complete transfer is done, now we print the final updated string 
print_result:
    xor ax, ax
    xor dx, dx
    mov ah, 09h
    lea dx, inputStr + 2
    int 21h

exit_program:
    xor ax, ax
    mov ah, 4ch
    int 21h

main endp
end

