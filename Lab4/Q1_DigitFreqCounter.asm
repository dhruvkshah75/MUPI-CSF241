; A simple program for making a hash array of a given string 
.model small
.stack 100h

.data 
    newline db 13, 10, '$'
    ; buffer[0] is stores the max length of the buffer and buffer[1] stores the characters read => actual length of the input 
    buffer db 21, ?, 21 dup('$')     ; buffer for taking input of the string 

    freq db 10 dup(0)

.code 
main proc 
    ; initiliase the data segment 
    mov ax, @data
    mov ds, ax

    ; taking the buffered input 
    mov ah, 0Ah
    lea dx, buffer
    int 21h

    xor cx, cx             ; clear out the cx register 
    mov cl, [buffer + 1]   ; this is the length of the inputed string 

    lea si, buffer + 2     ; initiliase the si pointer 

string_loop:
    mov bl, [si]           ; store the character (ASCII) into the bl register
    sub bl, '0'
    xor bh, bh             ; for indexing we must use 16 bit registers => so we clear the bh register 
    inc freq[bx]           ; increment the freq array at that index => similar to hash array 

    inc si
    dec cx
    cmp cx, 0
    jne string_loop 


    lea si, freq           ; store the address of freq 
    mov cx, 0Ah            ; the length of the freq array is 10 => 0Ah

print_result: 
    ; what if the dl stores more than 9 then we must print the string (eg '10' or '12')
    xor ax, ax
    mov al, [si]  

    cmp al, 0Ah           ; check if AL has 2 digits => as 2 digits cannot be printed 
    jb print_OneDigit     ; jump if below (al < 10)

; now we check if the no is of 2 digits or not if it is 
print_TwoDigist:

    mov bl, 10            ; divide the contents of al to get the quotient and remainder and convert each to ASCII and print 
    div bl                ; AL = Quoteint and AH = Remainder 

    ; now we print the two chars in ascii first the quotient and then the remainder 
    mov bh, ah            ; store the result as we will be needing ah 
    mov bl, al            

    mov dl, bl            ; Quotient
    add dl, '0'
    mov ah, 02h
    int 21h

    mov dl, bh            ; Remainder 
    add dl, '0'
    mov ah, 02h
    int 21h

    jmp print_space       ; now jump to printing the the space and looping back 

print_OneDigit:
    ; the char is a single digit so we print it directly 
    mov dl, [si]
    add dl, '0'           ; covert the no to ASCII before printing  
    mov ah, 02h
    int 21h
    jmp print_space

print_space: 

    mov dl, ' '            ; print the space char and then loop again 
    mov ah, 02h
    int 21h

    inc si
    dec cx
    cmp cx, 0
    jne print_result

exit_program:
    ; exit the program
    mov ah, 4ch
    int 21h

main endp
end

