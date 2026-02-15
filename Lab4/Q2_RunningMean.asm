.model small
.stack 100h

.data 
    newline db 13, 10, '$'

.code 
main proc 
    ; initialise the ds segment 
    mov ax, @data
    mov ds, ax
    
    xor bx, bx   ; bx => stores the current sum 
    xor cl, cl  ; cl => no of numbers inputed 

; note: since the inputted character is between 0 - 9 then the mean always will also be a single digit 
running_mean:
    
    mov ah, 01h       ; take the input of the character with no echo 
    int 21h           ; the input is stored in the AL register 
    
    cmp al, 'X'       ; terminate the program if X is inputed 
    je exit_program

    mov ah, 09h       ; After input and checking condition we must print a newline 
    lea dx, newline
    int 21h
    xor dx, dx        ; clear out the dx register 


    sub al, '0'       ; convert from ASCII back to a number 
    xor ah, ah        ; clear out ah register so that we can do bx = bx + ax
    add bx, ax
    inc cl

    xor ax, ax        ; clear out the ax register 
    mov ax, bx        ; store the current sum into the ax register for division
    div cl            ; ax/cl => AL = Quotient and AH => Remainder (since we are doing integer division we dont care about remaineder )

    mov dl, al
    add dl, '0'       ; convert to ASCII
    mov ah, 02h
    int 21h
 
    mov ah, 09h       ; after printing the mean we go to a newline
    lea dx, newline 
    int 21h
    xor dx, dx        ; clear out the dx register 

    jmp running_mean  ; keep the loop running until 'X' is inputed  

exit_program:
    mov ah, 4ch
    int 21h

main endp
end