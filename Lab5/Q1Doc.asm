; a program to print n + 1 lines of pattern of '*'

.model small
.stack 100h

.data
    newline db 13, 10, '$'

.code 
main proc 
    ; initialise the data segment 
    mov ax, @data 
    mov ds, ax

    ; now we take the input of the character => stores in the AL register 
    mov ah, 01h 
    int 21h 

    ; now bl has the inputed number but this number is ASCII => we need to convert it to number 
    mov bl, al    ; store the input number n  
    sub bl, '0'

    ; now we go to a newline => 09h in ah prints the contents of [dx]
    mov ah, 09h
    lea dx, newline
    int 21h

    mov cl, 0       ; i = 0

outer_loop:
    mov bh, 0       ; j = 0

inner_loop:         ; this loop runs from j = 0 to j <= i + 1
    ; we print the character by using 02h => it prints whatever is inside dx
    mov dl, '*'
    mov ah, 02h
    int 21h

    inc bh
    xor ch, ch      ; clear the register 
    add ch, cl      ; store i + 1 in ch and then we compare 
    inc ch
    cmp bh, ch      ; comparing values j and i (our condition to check is j < i + 1)
    jb inner_loop  ; jump if bh is below and equal to i+1 (ch)

    ; we now go to the next line
    mov ah, 09h
    lea dx, newline
    int 21h

    inc cl            ; increment i to i + 1
    cmp cl, bl        ; now we run the outer loop till i <= n
    jbe outer_loop    ; jump if al <= bl i.e i <= n (from i = 0 to i = n)

    ; exit the program 
    mov ah, 4ch
    int 21h

main endp
end
