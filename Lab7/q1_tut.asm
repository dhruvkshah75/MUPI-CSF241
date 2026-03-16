.model small
.stack 100h

.data 
    newline db 13, 10, '$'
    inputFile db 'INPUT.txt', 0     ; null terminated filename 
    outputFile db 'OUTPUT.txt', 0   ; null terminated filename 
    inputHandle dw ?
    outputHandle dw ?
    lineNum dw 1 
    buffer db 256 dup(?)            ; temporarily store the data read from the file 

.code 
main proc 

    mov ax, @data 
    mov ds, ax
    mov es, ax 

    ; =================================
    ;       OPEN THE INPUT FILE
    ; =================================

open_file:                  ; firstly we open input.txt file 
    mov ah, 3dh 
    lea dx, inputFile       ; dx must hold the points to the string 'INPUT.txt'
    mov al, 0h              ; we only want read access 
    int 21h

    jc exit_program
    mov inputHandle, ax     ; store the file handle in the variable from ax 

    ; ==================================
    ;      CREATE THE OUTPUT FILE
    ; ==================================
    
create_output:
    mov ah, 3ch
    mov cx, 0h              ; we create a new normal attributed file 
    lea dx, outputFile      ; store the outputFile address in dx 
    int 21h

    jc exit_program
    mov outputHandle, ax    ; store the output Handle 

    ; ===================================
    ;         READ THE INPUT FILE 
    ; ===================================

    jmp write_prefix         ; before reading anything write the prefix 

read_input:
    mov ah, 3fh              ; we read the input byte by byte and if ax = 0 then eof is reached 
    mov bx, inputHandle      ; bx must have the file handle of the input 
    mov cx, 1                ; read only 1 byte 
    lea dx, buffer           ; store result in the buffer 
    int 21h 

    jc close_files           ; if carry is not zero then close files 
    cmp ax, 0                ; ax = 0 means EOF is reached 
    je close_files           

    mov al, buffer           ; store the read character for checking if it is newline 
    cmp al, 0dh              ; every line ends with two chars => one is carriage return 0Dh and 0Ah 
    je read_input            ; if we get a carriage then read the next character 

    cmp al, 0ah              ; check if it a newline 
    je handle_newline        ; if the complete line ends we print that into the output file 


write_char:
    ; write the normal character to the file 
    mov ah, 40h 
    mov bx, outputHandle 
    mov cx, 1                 ; we output 1 byte to the output file 
    lea dx, buffer            
    int 21h   

    jc close_files
    jmp read_input          ; jump to read the next input 

    ; ==================================================
    ;              HANDLE NEWLINE 
    ; ==================================================

handle_newline:
    ; now we print the carriage return and newline into the file 
    mov ah, 40h
    mov buffer[0], 0dh      ; buffer[0] = carriage return 
    mov buffer[1], 0ah      ; buffer[1] = lf (line end)
    mov bx, outputHandle  
    lea dx, buffer          ; dx stores the buffer to print => we must print 2 bytes 
    mov cx, 2                 
    int 21h 

    jc close_files

    cmp ax, cx              ; if ax < cx then less characters were written => some error 
    jb close_files          

    inc lineNum             ; lineNum++
    jmp write_prefix        ; we write the "N: "

    ; ====================================================
    ;           WRITE "N: "
    ; ====================================================

write_prefix:
    ; convert the lineNum to ascii and then print 
    mov ax, lineNum
    mov si, 0        

    cmp ax, 10              ; check if the number is 2 digit or 1 digit 
    jb one_digit

two_digit:
    ; the number of lines is 10 - 99 => ax contains the number 
    mov bx, 10             
    xor dx, dx                     
    div bx                  ; 32 bit division => AX = tens digit, DX = units digit 

    add al, 30h             ; convert to ascii 
    mov buffer[si], al      ; add the tens digit to the buffer 
    inc si                
    add dl, 30h             
    mov buffer[si], dl      ; add the units digit to the buffer 
    inc si               
    jmp add_colon

one_digit:
    add ax, 30h             ; update to ascii 
    mov buffer[si], al      ; store the "N: " in the buffer 
    inc si               

add_colon: 
    mov buffer[si], ':'
    inc si  
    mov buffer[si], ' '
    inc si                 

    ; now write this buffer to the output file 
    mov ah, 40h 
    mov bx, outputHandle 
    lea dx, buffer            
    mov cx, si                ; technically si holds the length of the buffer 
    int 21h   

    ; if error occurred then close the file 
    jc close_files
    ; now start reading the next lines 
    jmp read_input

    ; ===========================================
    ;               CLOSE FILES 
    ; ===========================================

close_files:
    mov ah, 3eh              ; close file service
    mov bx, inputHandle
    int 21h

    mov ah, 3eh
    mov bx, outputHandle
    int 21h

    ; ===========================================
    ;           EXIT THE PROGRAM
    ; ===========================================

exit_program:
    mov ah, 4ch
    int 21h

main endp
end main 