; a program to check the discriminant of a quadratic eqaution 
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

take_input: 
    ; now we take the inputs of a, b, e with newline 
    xor ax, ax
    mov ah, 01h
    int 21h
    sub al, '0'        ; convert to number from ASCII
    mov a, al          ; store in the data (a)

    xor ax, ax
    lea dx, newline
    mov ah, 09h
    int 21h            ; print a newline 

    xor ax, ax
    mov ah, 01h
    int 21h
    sub al, '0'
    mov b, al          ; store in the data (b)

    xor ax, ax
    lea dx, newline
    mov ah, 09h
    int 21h            ; print a newline 

    xor ax, ax         ; clear out the ax register 
    mov ah, 01h
    int 21h
    sub al, '0'
    mov e, al          ; store in the data (e)

discriminant_calc:
    ; in 8 bit mul we get AX = AL * (what we multiply)
    xor al, al
    mov al, b 
    mul al             ; now b^2 is stored in ax 

    mov discriminant, ax  

    ; now we want to find 4*a*c
    xor ax, ax
    mov al, 4
    mul a            ; now ax holds 4*a (AX = 4*a)

    xor cx, cx
    mov cl, e        ; store e in cx as 00cl  (CX = e)

    ; since 4*a is stored in AX and c is stored in cx now we do 16 bit mul to get 4*a*e
    ; in 16 bit multiplication stores the upper 16 bits in DX and lower 16 bits in AX
    mul cx           ; since the discriminant is dw then we ignore the part stored in DX

    sub discriminant, ax   ; b^2 - 4*a*e


; note very important => jb, ja work only on unsigned numbers => we should use jl, jg for signed numbers 
discriminant_check:
    ; now we check the discriminant 
    cmp discriminant, 0
    jl imaginary_roots

    cmp discriminant, 0
    jg real_roots

    cmp discriminant, 0
    je same_roots

imaginary_roots:
    xor ax, ax
    xor dx, dx
    lea dx, imaginaryMsg
    mov ah, 09h
    int 21h
    jmp exit_program 

real_roots:
    xor ax, ax
    xor dx, dx
    lea dx, realDistinctMsg
    mov ah, 09h
    int 21h
    jmp exit_program

same_roots:
    xor ax, ax
    xor dx, dx
    lea dx, realEqualMsg
    mov ah, 09h
    int 21h
    jmp exit_program 

exit_program:
    xor ax, ax
    mov ah, 4ch
    int 21h

main endp
end main
