;  Code for bubble sort in assembly language 

.model small
.stack 100h

.data 
  org 0200h                              ; the org directive tells the assembler to start placing data at this offset address
  array db 5, 3, 8, 1, 9, 4, 7, 2, 6     ; array to be sorted 
  len equ 9                              ; this creates a constant => assembler simply replaces the word len with the number 9 everywhere it appears
  msg1 db "Printing the Sorted array: $" ; message we will print after we have sorted the array 
  
.code 
main proc 
  ; initialise the ds segment 
  mov ax, @data
  mov ds, ax  
  
  ; initialise the counter cx 
  mov cx, len - 1

outer_loop:
  ; we also need to define a inner loop counter 
  mov bx, cx;
  mov si, offset array           ; store the pointer to the first element 
  
inner_loop:
  mov al, [si]                   ; store the ith element the one that outer element has 
  cmp al, [si+1]                 ; we compare the ith and ith + 1 element if arr[i] > arr[i+1] then we swap elements 
  jbe skip_swap                  ; jump if below or equal i.e. arr[i] <= arr[i+1]  => we skip the if statement 
  ; swap elements 
  mov dl, [si+1]
  mov [si+1], al
  mov [si], dl                   
  
; this segment is the one that executes in the inner loop
skip_swap:               
  inc si                        ; now point to the next element 
  loop inner_loop               ; the loop directive relies on cx, so we had to store the counter somewhere 
  mov cx, bx                    ; restore the cx counter for the outer variable 
  loop outer_loop
  
printing_message:
; These 3 statements prints the message 
  mov dx, offset msg1
  mov ah, 09h
  int 21h    
  
 ; before printing the array we initialise the variables
  mov cx, len-1 
  mov si, offset array 
  
print_array:
  mov dl, [si] 
  add dl, '0'         ; convert to ascii 
  mov ah, 02h         ; This interrupt is used for printing a single character 
  int 21h
  
  mov dl, ' '
  mov ah, 02h
  int 21h 
  
  inc si
  loop print_array

end_program:
; terminate the program successfully 
  mov ah, 4ch
  int 21h
  
main endp
end main
  
  
