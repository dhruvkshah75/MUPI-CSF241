; A program for Q1 PYQ Lab5 Eval  

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

    ; we can take the input of a 2 digit number as taking input of two characters 
    ; the first inputed number * 10 + second number 

    ; NOTE: For 8 bit multiplication => AX = AL * Operand 

    ; ---- Get FIRST Digit ----
    mov ah, 01h
    int 21h            ; input is stored in AL
    mov bl, al 
    sub bl, '0'

    ; ---- GET SECOND Digit ----
    xor ax, ax 
    mov ah, 01h
    int 21h
    mov cl, al 
    sub cl, '0'

    mov al, bl          
    mov ch, 10 
    mul ch              ; Now AX store the val of first char * 10
    xor ch, ch
    add ax, cx          ; cx => 00cl we must make ch 0 for 

    mov num, al         ; Finally store the number into num variable => note: the max val is 99(decimal) can be stored in db
                        ; So AX holds 00AL => the number is stored in AL 

    ; we can just run a loop from 1 to num and then check if the remainder division is 0 
 
    lea dx, newline     ; now we move to a newline
    mov ah, 09h
    int 21h

    xor ax, ax
    xor bx, bx
    mov bl, 1            ; bl => i = 1 

    mov dx, 0            ; we maintain the current sum => can exceed 8 bits 

factor_loop:
    xor ax, ax
    mov al, num  
    ; now ax holds the number => divident is 16 bit 
    ; now on division by bl we get AL => Quotient, AH => Remainder 
    div bl              ; we divide the num in ax by bl (i)
    cmp ah, 0    
    jne skip_factor
    add dx, bx          ; if rem = 0 then add (i) bl to dx => dx = dx + bx (as bx = 00bl)
    
skip_factor:
    inc bl              ; now we increment bl 
    cmp bl, num 
    jbe factor_loop     ; continue if bl <= num


    ; now we have to print the modulo 10 of the sum => divide by 10 
    xor ax, ax
    mov ax, dx  
    xor bl, bl
    mov bl, 10
    div bl              ; now AH stores the modulo 10 of the sum of factors 

    mov dl, ah 
    add dl, '0'         ; convert to ASCII
    xor ax, ax
    mov ah, 02h
    int 21h

exit_program:
    mov ah, 4ch
    int 21h
   
main endp
end main
