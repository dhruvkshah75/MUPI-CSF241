; A program for bubble sort in assembly language 

.model small
.stack 100h

.data
    newline db 13, 10, '$'
    array db 50 dup(0)         ; array that we will take input of (input is taken char by char)
    len db ?                   ; store the len of the array 

.code 
main proc 

    mov ax, @data 
    mov ds, ax                 ; initialise the ds segment 

    xor ax, ax
    mov ah, 01h
    int 21h                    ; take the input of the length of the array in AL register (ASCII)
    sub al, '0'


    mov len, al                ; store the length in len  

    mov cl, len                ; store the length in the cl for the input loop
    lea si, array              ; pointer of the array 

input_loop:
    xor ax, ax
    mov ah, 01h
    int 21h                    ; element of the array is stored in the AL register 

    ; ----- FILTERING -----
    cmp al, ' '
    je input_loop              ; skip this element if a white space is inputed 

    cmp al, 13                 ; Check for ENTER key (CR)
    je input_loop              ; If Enter, skip it too!

    sub al, '0'                ; convert the number from ASCII back to a number 

    mov [si], al               ; store the element in array
    inc si
    dec cl
    cmp cl, 0
    jne input_loop


bubble_sort:                  ; Now we sort the inputed array
    xor si, si               
    mov si, 0                 ; i = 0 => si = i

outer_loop:
    xor di, di                
    mov di, 0                 ; j = 0 => di = j

inner_loop:                   ; the inner loop runs from j = 0 to j < len - i - 1
    mov bh, array[di]
    mov dh, array[di+1]          
    cmp bh, dh                ; if a[i] > a[j] then swap
    jbe skip_swap
    mov array[di], dh         ; now we swap the elements 
    mov array[di+1], bh 

skip_swap:
    inc di
    xor bx, bx
    mov bl, len               ; bx now stores 00len   
    sub bx, si
    dec bx                    ; now bx stores len - i - 1 (bl = len - si - 1)
    cmp di, bx                ; cmp j, len - i - 1
    jb inner_loop

    inc si
    xor cx, cx
    mov cl, len
    cmp si, cx                ; cmp i < len(cx holds the value of len)
    jb outer_loop


print_result: 
    xor si, si
    lea si, array
    xor cx, cx
    mov cl, len

    lea dx, newline          ; print a newline 
    mov ah, 09h
    int 21h

print_loop:
    xor dx, dx
    mov dl, [si]
    mov ah, 02h
    add dl, '0'               ; convert to ASCII
    int 21h

    mov dl, ' '
    int 21h                   ; print the space

    inc si
    dec cl
    cmp cl, 0
    jne print_loop 

exit_program:
    mov ah, 4ch
    int 21h

main endp
end









                                            

