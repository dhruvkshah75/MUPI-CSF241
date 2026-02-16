.model small
.stack 100h 

.data
msg db "Hello world!$"

.code 
main proc
  ; Initialise the data segment 
  mov ax, @data
  mov ds, ax               ; done in two steps as direct transfer into ds is not allowed 

  ; store the address in dx so that we can use interrupt to print the ans 
  mov dx, offset msg

  mov ah, 09h
  int 21h                 ; these two statements print the string 

  ; now we terminate the program 

  mov ah, 4ch
  int 21h

main endp
end main
