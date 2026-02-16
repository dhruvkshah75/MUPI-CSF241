; a simple program to take input of a character and then print it

.model small 
.stack 100h

.data 
    msg db "Enter a character: $"

.code 
main proc 
    ; initiliase the data segment 
    mov ax, @data
    mov ds, ax

    ; using the interrupt we print out the message 
    mov ah, 09h    ; putting 09h into ah will print the bytes stored at address located in dx
    lea dx, msg    ; store the address of msg into dx => same as (mov dx, offset msg)
    int 21h

    ; Now we take the input of the character => by storing 01h into ah
    mov ah, 01h
    int 21h
    ; now the character is stored in AL register 

    ; now we print this charcater onto the screen
    ; for printing we store 02h into ah register => but it prints whatever is stored in DL register   
    mov ah, 02h   
    mov dl, al              ; our character was stored in al then we put into dl so we can print it 
    int 21h

    ; exit the program 
    mov ah, 4ch
    int 21h
main endp
end