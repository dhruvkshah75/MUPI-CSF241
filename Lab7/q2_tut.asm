.model small 
.stack 100h 

.data 
    inputFile db 'RECS.TXT', 0
    inputHandle dw ?
    newline db 13, 10, '$'

    ; =========== buffers to store =============== 
    subjectBuf db 30 dup(0)
    studentBuf db 10 dup(0)
    marksBuf db 10 dup(0)

    outputFileName db 20 dup(0)
    outputHandle dw ? 

    ; ========== prefixes to skip through =========
    subjecttPf db 'Subject: ', 0
    studentPf db 'Student: ', 0
    marksPf db 'Marks: ', 0

    ; ========= buffers to store output =============
    outLine db 50 dup(0)              ; stores something like "Math:85\r\n"
    outLen dw 0                       ; we need to store the length as we will output it directly
    
    ; ============ temp buffers ====================
    lineBuffer db 100 dup(0)
    lineLen dw 0     
    
    ; =========== temp one character buffer ========
    temp db ?


.code 

; =====================================================
;   PROC: read_line
;   Reads one full line from inputHandle into lineBuffer
;   Sets lineLen = number of chars (not counting CR/LF)
;   Returns: lineLen = 0 if blank line, or filled line
; =====================================================

read_input proc uses ax bx cx dx si di

    ; reset lineBuffer and lineLen 
    mov lineLen, 0 
    mov si, 0 

    read_byte: 
        mov ah, 3fh 
        mov bx, inputHandle
        mov cx, 1
        lea dx, temp                ; store the read byte into temp 
        int 21h 

        jc read_error
        cmp ax, 0
        je eof_reached

        mov al, temp

        ; now check for line end 
        cmp al, 0dh                 ; check for carriage return 
        je read_byte

        cmp al, 0ah 
        je read_done 

        mov lineBuffer[si], al
        inc si  
        inc lineLen                 ; increase the pointer and lineLen 
        jmp read_byte 

    read_error:
        ; to have some sort of check if error occurred we update the lineLen 
        mov lineLen, 0FFFEh
        jmp read_exit

    eof_reached:
        ; check if we collected any chars before EOF hit
        cmp lineLen, 0          ; did we read anything?
        je  true_eof            ; no chars → real EOF signal
        ; yes we have chars → null terminate and return normally
        ; main will process this last line normally
        ; next call to read_input will hit true_eof
        mov lineBuffer[si], 0   ; null terminate the partial line
        jmp read_exit           ; return with lineLen = actual count

    true_eof:
        mov lineLen, 0FFFFh     ; signal EOF to main
        jmp read_exit

    read_done: 
        mov lineBuffer[si], 0       ; null terminate the read buffer 

    read_exit:
        ret


read_input endp


write_output proc uses ax bx cx dx si di 
    ; first we build the filename 

    mov si, 0
    mov di, 0 

    build_filename:
        mov al, studentBuf[si]
        cmp al, 0 
        je add_extension

        mov outputFileName[di], al 
        inc si
        inc di 
        jmp build_filename

    add_extension:
        ; now we manually add the extension 
        mov outputFileName[di], '.'
        inc di 
        mov outputFileName[di], 'T'
        inc di 
        mov outputFileName[di], 'X'
        inc di 
        mov outputFileName[di], 'T'
        inc di 
        mov outputFileName[di], 0         ; null terminate the buffer 


    ; now we open the existing file or create a new file 
    open_file: 
        mov ah, 3dh 
        mov al, 1          ; write access 
        lea dx, outputFileName
        int 21h 

        jc create_file       ; file not found so we create a new file 
        mov outputHandle, ax 

        ; file exists so we move to the end of the file to start printing 
        mov ah, 42h 
        mov al, 02h          ; we seek to the end of file 
        mov bx, outputHandle
        xor cx, cx 
        xor dx, dx           ; keep the offsets 
        int 21h 
        ; =========== now the pointer moves to end ==================
        jmp buildLine 

    create_file:
        mov ah, 3ch 
        mov cx, 0            ; normal attribute 
        lea dx, outputFileName
        int 21h 

        jc exit_proc
        mov outputHandle, ax    ; save the handle 
        jmp buildLine

    buildLine:
        mov si, 0
        mov di, 0 

        ; first we copy the subject 
    copy_subj: 
        mov al, subjectBuf[si]
        cmp al, 0 
        je add_colon 

        mov outLine[di], al
        inc di
        inc si 
        jmp copy_subj

    add_colon: 
        mov outLine[di], ':'
        inc di 
        ; now we copy the marks 
        mov si, 0
        jmp copy_name

    copy_name: 
        mov al, marksBuf[si]
        cmp al, 0 
        je copy_done

        mov outLine[di], al 
        inc di 
        inc si 
        jmp copy_name

    copy_done:
        ; now we must add cr and lf to the output line 
        mov outLine[di], 0dh 
        inc di 
        mov outLine[di], 0ah 
        inc di 

    ; now we must simply write this to the file 
    ; now di holds the length of the output line 
    ; ===========================================
    ;           Write to the output 
    ; ===========================================
    write_line: 
        mov ah, 40h 
        mov bx, outputHandle
        mov cx, di                 ; number of bytes to write = di 
        lea dx, outLine
        int 21h 

        jc close_file

        ; ===== now close the file =====
    close_file: 
        mov ah, 3eh             ; close file service
        mov bx, outputHandle
        int 21h

    clear_buffers: 
        mov subjectBuf[0], 0    ; null first byte is enough
        mov studentBuf[0], 0    ; extraction always starts from 0
        mov marksBuf[0],   0

    exit_proc:
        ret 

write_output endp

main proc 

    mov ax, @data 
    mov ds, ax
    mov es, ax 

    ; =========================================
    ;            OPEN RECS.TXT FILE
    ; =========================================

open_input_file:
    mov ah, 3dh 
    mov al, 0                          ; read access attribute 
    lea dx, inputFile
    int 21h 

    jc exit_program
    mov inputHandle, ax                ; store the input file handle 


main_loop: 
    ; now start reading lines 
    call read_input

    cmp lineLen, 0FFFFh     ; was it EOF? => if eof comes then we must process the last entry 
    je  handle_eof

    cmp lineLen, 0FFFEh     ; was it a read error?
    je  close_files

    cmp lineLen, 0          ; was it a blank line?
    je  record_complete     ; ; if nothing in the lineBuffer we must go to output them into the file 

    ; =====================================================
    ; "Subject: Math"  → lineBuffer[1] = 'u'
    ; "Student: s1"    → lineBuffer[1] = 't'
    ; "Marks: 85"      → lineBuffer[1] = 'a'
    ; =====================================================

    ; we need to compare the the lineBuffer[1]

    mov al, lineBuffer[1]
    
    cmp al, 'u'
    je extractSubject 

    cmp al, 't'
    je extractStudent 

    cmp al, 'a'
    je extractMarks

    ; other than these 3 restart reading 
    jmp main_loop 

    ; ================================================
    ;              Subject Extraction 
    ; ================================================

extractSubject:
    ; for subject the subject name starts from 9th index 
    mov si, 9
    mov di, 0               ; pointer for subjectBuff 

extract_sub_name:
    mov al, lineBuffer[si]
    cmp al, 0             ; compare with carriage return if that is reached then stop extraction 
    je extract_sub_done

    mov subjectBuf[di], al  
    inc di
    inc si 
    jmp extract_sub_name

extract_sub_done:
    ; null terminate the subject buffer 
    mov subjectBuf[di], 0 
    jmp main_loop               ; now fill the next buffers 

    ; ===============================================
    ;             Student Extraction
    ; ===============================================

extractStudent: 
    ; for student we start extracting from 9 
    mov si, 9 
    mov di, 0

extract_std_name:
    mov al, lineBuffer[si]
    cmp al, 0                    ; compare with null terminator
    je ext_std_done

    mov studentBuf[di], al
    inc si  
    inc di 
    jmp extract_std_name

ext_std_done:
    ; null terminate the string 
    mov studentBuf[di], 0
    jmp main_loop


    ; ================================================
    ;            Marks Extraction 
    ; ================================================

extractMarks: 
    ; we start extracting from 7 
    mov si, 7
    mov di, 0 

ext_marks:
    mov al, lineBuffer[si]
    cmp al, 0 
    je ext_marks_done

    mov marksBuf[di], al 
    inc si
    inc di 
    jmp ext_marks

ext_marks_done: 
    mov marksBuf[di], 0
    jmp main_loop


record_complete: 
    ; ============== We have this =================
    ;           subjectBuf = "Math\0"
    ;           studentBuf = "s1\0"
    ;           marksBuf   = "85\0"
    ; =============================================
    call write_output
    jmp main_loop           ; conintue reading the file 


handle_eof:
    cmp marksBuf[0], 0      ; is marksBuf empty?
    je  close_files         ; yes → nothing to write 
    call write_output       ; no  → write the last record FIRST
    jmp close_files         ; then close

close_files:
    ; we must close the input file 
    mov ah, 3eh 
    mov bx, inputHandle
    int 21h 

exit_program:
    mov ah, 4ch 
    int 21h 

main endp
end main 
