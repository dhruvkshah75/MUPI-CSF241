; A program for bubble sort in assembly language 

.model small
.stack 100h

.data
    newline 13, 10, '$'
    array db 50 dup(0)         ; array that we will take input of (input is taken char by char)

.code 
main proc 

    mov ax, @data 
    mov ds, ax                 ; initialise the ds segment 

    xor ax, ax
    mov ah, 01h
    int 21h                    ; take the input of the length of the array in AL register

    mov cl, al                 ; store the length in cl

    mov bl, cl                 ; store the length in the bl for the input loop
    lea si, array              ; pointer of the array 

input_loop:
    xor ax, ax
    mov ah, 01h
    int 21h                    ; element of the array is stored in the AL register 

    



                                            

