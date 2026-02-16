.model small
.stack 100h

.data
    newline   db 13, 10, '$'
    inputStr  db 255, ?, 255 dup('$')  ; Buffered input
    outputStr db 255 dup('$')          ; Output buffer
    len       db ?

.code
main proc
    ; 1. Initialize Segments
    mov ax, @data
    mov ds, ax
    mov es, ax              ; ES is needed for STOSB/MOVSB

    ; 2. Take Input
    mov ah, 0Ah
    lea dx, inputStr
    int 21h

    ; Print Newline
    mov ah, 09h
    lea dx, newline
    int 21h

    ; 3. Setup Pointers
    lea si, inputStr + 1    ; SI points to Length byte
    xor ch, ch
    mov cl, [si]            ; CX = Length
    cmp cx, 0
    je exit_program         ; Exit if empty string

    add si, cx              ; SI now points to the LAST character
    mov bx, si              ; BX remembers the END of the current word
    
    lea di, outputStr       ; DI points to Start of Output

    ; --- MAIN LOOP: Scan Backwards ---
scan_loop:
    cmp si, offset inputStr + 2 ; Check if we hit the start of the string
    jb copy_last_word           ; If SI < Start, we are done scanning

    std                     ; SET Direction (Backwards)
    lodsb                   ; Load char at [SI] into AL, then DEC SI
                            ; (We use LODSB to read while moving back)

    cmp al, ' '             ; Is it a space?
    je space_found
    jmp scan_loop

space_found:
    ; We found a space. The word is between (SI + 2) and (BX).
    ; Note: LODSB decremented SI, so the space is actually at SI+1.
    ; The word starts at SI+2.

    push si                 ; Save current scan position => so we can use it again to to go backwards 

    ; --- COPY WORD (Forward) ---
    cld                     ; CLEAR Direction (Forwards)
    
    mov cx, bx              ; Calculate length of word: (BX - (SI+1))
    sub cx, si
    dec cx                  ; CX = Length of word
    
    inc si                  ; Point SI to the space
    inc si                  ; Point SI to start of the word
    
    rep movsb               ; Copy CX bytes from [SI] to [DI]

    ; --- ADD SPACE (Forward) ---
    mov al, ' '
    stosb                   ; Store ' ' at [DI], Inc DI

    ; --- RESUME SCAN (Backward) ---
    pop si                  ; Restore scan position (at the space)
    mov bx, si              ; Update End-of-Word pointer
    
    ; We need to restart scanning from the char BEFORE the space.
    ; Since we are about to loop and LODSB will read/dec, strictly speaking
    ; SI is currently pointing 1 byte before the space (due to the lodsb that found it).
    ; So we are good to continue.
    
    jmp scan_loop

copy_last_word:
    ; Copy the final remaining word (the first word of the sentence)
    cld                     ; Forward direction
    lea si, inputStr + 2    ; Start of string
    
    mov cx, bx              ; Length = BX - Start + 1
    sub cx, si
    inc cx
    
    rep movsb               ; Copy it

    ; Print Result
    mov ah, 09h
    lea dx, outputStr
    int 21h

exit_program:
    mov ah, 4ch
    int 21h

main endp
end main