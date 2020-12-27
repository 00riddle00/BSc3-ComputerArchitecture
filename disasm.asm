; ============================================================
;  DESCRIPTION
; ============================================================
; Subject: Computer Architecture
; LAB-2 and LAB-3: x8086 Disassembler
; Vilnius University, MIF
; Author: Tomas Giedraitis
;
; Assignment: 
;    A program which takes 'input' file (.com or .exe) 
;    and disassembles it, writing to the 'output' file (.asm)
;
;    output file after the program's execution should look
;    like this:
;         ...
;         0100: B409    | MOV AH, 09
;         0102: BADE01  | MOV DX, 01DE
;         0105: CD21    | INT 21
;         01F9: 65      | UNDEFINED
;         ...
;         ...
;    i.e. on every line there should be Hex address of the 
;    command, it's bytes written in Hex and then the
;    recognized command (undefined, if no such command exists)
;
; ============================================================

; ============================================================
;  MACROS
; ============================================================

include macros.asm

; print register name
; registers can be byte, word, and segment registers
; ::param:: reg_group - address where reg names are
; Also, BX must contain the offset from reg_group where
; the required register is.
m_print_reg macro reg_group
   push ax bx dx
   add bx, offset reg_group
   mov dl, byte ptr [bx+1]
   mov ah, 02h
   int 21h
   mov dl, byte ptr [bx]
   int 21h
   pop dx bx ax
endm

; print asm pointer directive
; ::param:: DL must be either 0 (=byte) or 1 (=word)
m_print_ptr macro
local @@word_ptr, @@byte_ptr, @@endmacro
    cmp dl, 1
    jb @@byte_ptr

    ; word_ptr:
    m_puts 'word ptr'
    jmp @@endmacro

    @@byte_ptr:
        m_puts 'byte ptr'
@@endmacro:
endm

; ============================================================
;  SETTINGS
; ============================================================
.model small     ; one code segment, one data segment
.stack 100h
jumps

; ============================================================
;  CONSTANTS
; ============================================================
; ...
; -----------------------------------------------------------/

; ============================================================
;  DATA
; ============================================================

.data
    ; Byte-sized registers
    Rb dw 'AL', 'CL', 'DL', 'BL', 'AH', 'CH', 'DH', 'BH'

    ; Word-sized registers
    Rw dw 'AX', 'CX', 'DX', 'BX', 'SP', 'BP', 'SI', 'DI'

    ; Segment registers
    SR dw 'ES', 'CS', 'SS', 'DS'  

    ; Registers used as base in EA formation
    EAb dw 'BX', 'BX', 'BP', 'BP', 'SI', 'DI', 'BP', 'BX'

    ; Registers used as index in EA formation
    EAi dw 'SI', 'DI', 'SI', 'DI'

    sep db '=============================================================================$'

; ==================================== TESTING ===============================================

; --------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------

; ------------------------------------- GROUP 0 ----------------------------------------------
    data_octal db 0, 0, 0,  0, 2, 0           ; 0???: ??      | ADD byte ptr [BX+SI], DL

    db 2, 0, 4,  0, 3, 6,  1, 1, 1,  2, 2, 2  ; 0???: ??      | TEST BL, byte ptr [222111]
    db 2, 0, 5,  0, 2, 4                      ; 0???: ??      | TEST DX, word ptr [SI]

    db 2, 0, 6,  2, 0, 3,  1, 1, 1,  2, 2, 2  ; 0???: ??      | XCHG AL, byte ptr [BP+DI+222111]
    db 2, 0, 7,  3, 1, 4                      ; 0???: ??      | XCHG CX, SP

    db 0FFh

    ;data_octal db 0, 0, 0,  0, 2, 0           ; 0???: ??      | ADD byte ptr [BX+SI], DL
    db 0, 0, 1,  0, 2, 0                      ; 0???: ??      | ADD word ptr [BX+SI], DX

    db 0, 0, 0,  0, 2, 4                      ; 0???: ??      | ADD byte ptr [SI], DL
    db 0, 0, 1,  0, 2, 4                      ; 0???: ??      | ADD word ptr [SI], DX

    db 0, 0, 0,  3, 1, 0                      ; 0???: ??      | ADD AL, CL
    db 0, 1, 1,  3, 1, 0                      ; 0???: ??      | OR AX, CX

    db 0, 0, 0,  0, 3, 6,  1, 1, 1,  2, 2, 2  ; 0???: ??      | ADD byte ptr [222111], BL
    db 0, 0, 1,  0, 3, 6,  1, 1, 1,  2, 2, 2  ; 0???: ??      | ADD word ptr [222111], BX

    db 0, 0, 2,  3, 1, 0                      ; 0???: ??      | ADD CL, AL
    db 0, 0, 3,  3, 1, 0                      ; 0???: ??      | ADD CX, AX

    db 0, 0, 2,  1, 2, 4,  1, 1, 1            ; 0???: ??      | ADD DL, byte ptr [SI+111]
    db 0, 0, 3,  1, 2, 4,  1, 1, 1            ; 0???: ??      | ADD DX, word ptr [SI+111]

    db 0, 0, 2,  2, 2, 4,  1, 1, 1,  2, 2, 2  ; 0???: ??      | ADD DL, byte ptr [SI+222111]
    db 0, 0, 3,  2, 2, 4,  1, 1, 1,  2, 2, 2  ; 0???: ??      | ADD DX, word ptr [SI+222111]

    db 0, 1, 2,  0, 3, 6,  1, 1, 1,  2, 2, 2  ; 0???: ??      | OR BL, byte ptr [222111]
    db 0, 0, 3,  0, 3, 6,  1, 1, 1,  2, 2, 2  ; 0???: ??      | ADD BX, word ptr [222111]

    db 0, 2, 0,  1, 2, 4,  1, 1, 1            ; 0???: ??      | ADC byte ptr [SI+111], DL
    db 0, 3, 1,  1, 2, 4,  1, 1, 1            ; 0???: ??      | SBB word ptr [SI+111], DX

    db 0, 3, 2,  0, 2, 0                      ; 0???: ??      | SBB DL, byte ptr [BX+SI]
    db 0, 2, 3,  0, 2, 0                      ; 0???: ??      | ADC DX, word ptr [BX+SI]

    db 0, 4, 0,  2, 2, 4,  1, 1, 1,  2, 2, 2  ; 0???: ??      | AND byte ptr [SI+222111], DL
    db 0, 5, 1,  2, 2, 4,  1, 1, 1,  2, 2, 2  ; 0???: ??      | SUB word ptr [SI+222111], DX

    db 0, 5, 2,  0, 2, 4                      ; 0???: ??      | SUB DL, byte ptr [SI]
    db 0, 4, 3,  0, 2, 4                      ; 0???: ??      | AND DX, word ptr [SI]

    db 0, 6, 0,  1, 0, 3,  1, 1, 1            ; 0???: ??      | XOR byte ptr [BP+DI+111], AL
    db 0, 7, 1,  1, 0, 3,  1, 1, 1            ; 0???: ??      | CMP word ptr [BP+DI+111], AX

    db 0, 7, 2,  2, 0, 3,  1, 1, 1,  2, 2, 2  ; 0???: ??      | CMP AL, byte ptr [BP+DI+222111]
    db 0, 6, 3,  2, 0, 3,  1, 1, 1,  2, 2, 2  ; 0???: ??      | XOR AX, word ptr [BP+DI+222111]

; ------------------------------------- GROUP 2 ----------------------------------------------
    db 2, 0, 0,  1, 0, 4,  2, 2, 2,  3, 3, 3            ; 0???: ??   | ADD byte ptr [SI+222], 333
    ;     80        44        92        DB                           = ADD byte ptr [SI+92h], 0DBh
    ;     80        44        92        DB                           = ADD byte ptr [SI-06Eh], 0DBh

    db 2, 0, 3,  2, 0, 4,  1, 1, 1,  2, 2, 2,  3, 3, 3  ; 0???: ??   | ADD word ptr [SI+222111], 377333
    ;     83        84        49        92        DB                 = ADD word ptr [SI+9249h], 0FFDBh
    ;                                                                = ADD word ptr [SI-6DB7h], 0FFDBh

    db 2, 0, 0,  1, 1, 4,  2, 2, 2,  3, 3, 3            ; 0???: ??   | OR byte ptr [SI+222], 333
    db 2, 0, 3,  2, 2, 4,  1, 1, 1,  2, 2, 2,  3, 3, 3  ; 0???: ??   | ADC word ptr [SI+222111], 377333

    db 2, 0, 1,  2, 0, 4,  1, 1, 1,  2, 2, 2,  3, 3, 3,  4, 4, 4  ; 0???: ?? | ADD word ptr [SI+222111], 444333
    db 2, 0, 2,  2, 0, 4,  1, 1, 1,  2, 2, 2,  3, 3, 3  ; 0???: ??   | ADD byte ptr [SI+222111], 333

    db 2, 0, 0,  1, 3, 4,  2, 2, 2,  3, 3, 3            ; 0???: ??   | SBB byte ptr [SI+222], 333
    db 2, 0, 3,  2, 4, 4,  1, 1, 1,  2, 2, 2,  3, 3, 3  ; 0???: ??   | AND word ptr [SI+222111], 377333

    db 2, 0, 0,  1, 5, 4,  2, 2, 2,  3, 3, 3            ; 0???: ??   | SUB byte ptr [SI+222], 333
    db 2, 0, 0,  1, 6, 4,  2, 2, 2,  3, 3, 3            ; 0???: ??   | XOR byte ptr [SI+222], 333
    db 2, 0, 3,  2, 7, 4,  1, 1, 1,  2, 2, 2,  3, 3, 3  ; 0???: ??   | CMP word ptr [SI+222111], 377333

    db 2, 1, 0,  2, 0, 3,  1, 1, 1,  2, 2, 2  ; 0???: ??      | MOV byte ptr [BP+DI+222111], AL
    db 2, 1, 1,  2, 0, 3,  1, 1, 1,  2, 2, 2  ; 0???: ??      | MOV word ptr [BP+DI+222111], AX

    db 2, 1, 2,  1, 0, 3,  1, 1, 1            ; 0???: ??      | MOV AL, byte ptr [BP+DI+111]
    db 2, 1, 3,  1, 0, 3,  1, 1, 1            ; 0???: ??      | MOV AX, word ptr [BP+DI+111]

; --------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------

; ------------------------------------- GROUP 0 ----------------------------------------------
    db 0, 0, 4,  1, 1, 1            ; 0???: ??      | ADD AL, 111
    db 0, 0, 5,  1, 1, 1,  2, 2, 2  ; 0???: ??      | ADD AX, 222111
    db 0, 0, 7                      ; 0???: ??      | POP ES
    db 0, 1, 1,  3, 1, 0            ; 0???: ??      | OR AX, CX
    db 0, 1, 4,  1, 1, 1            ; 0???: ??      | OR AL, 111
    db 0, 1, 5,  1, 1, 1,  2, 2, 2  ; 0???: ??      | OR AX, 222111
    db 0, 1, 6                      ; 0???: ??      | PUSH CS
    db 0, 2, 4,  1, 1, 1            ; 0???: ??      | ADC AL, 111
    db 0, 2, 5,  1, 1, 1,  2, 2, 2  ; 0???: ??      | ADC AX, 222111
    db 0, 2, 7                      ; 0???: ??      | POP SS 
    db 0, 3, 6                      ; 0???: ??      | PUSH DS
    db 0, 4, 7                      ; 0???: ??      | DAA
    db 0, 5, 4,  1, 1, 1            ; 0???: ??      | SUB AL, 111
    db 0, 5, 5,  1, 1, 1,  2, 2, 2  ; 0???: ??      | SUB AX, 222111
    db 0, 7, 4,  1, 1, 1            ; 0???: ??      | CMP AL, 111
    db 0, 7, 5,  1, 1, 1,  2, 2, 2  ; 0???: ??      | CMP AX, 222111
    db 0, 7, 7                      ; 0???: ??      | AAS

; ------------------------------------- GROUP 1 ----------------------------------------------
    db 1, 0, 6                      ; 0???: ??      | INC SI
    db 1, 1, 3                      ; 0???: ??      | DEC BX
    db 1, 2, 0                      ; 0???: ??      | PUSH AX
    db 1, 3, 1                      ; 0???: ??      | POP CX
    db 1, 4, 5                      ; 0???: ??      | UNDEFINED

; ------------------------------------- GROUP 2 ----------------------------------------------
    db 2, 2, 0                      ; 0???: ??      | NOP
    db 2, 2, 5                      ; 0???: ??      | XCHG BP, AX
    db 2, 3, 0                      ; 0???: ??      | CBW
    db 2, 3, 3                      ; 0???: ??      | WAIT
    db 2, 3, 7                      ; 0???: ??      | LAHF
    db 2, 4, 0,  1, 1, 1,  2, 2, 2  ; 0???: ??      | MOV AL, [222111]
    db 2, 4, 1,  1, 1, 1,  2, 2, 2  ; 0???: ??      | MOV AX, [222111]
    db 2, 4, 2,  1, 1, 1,  2, 2, 2  ; 0???: ??      | MOV [222111], AL
    db 2, 4, 3,  1, 1, 1,  2, 2, 2  ; 0???: ??      | MOV [222111], AX
    db 2, 4, 4                      ; 0???: ??      | MOVSB
    db 2, 4, 7                      ; 0???: ??      | CMPSW
    db 2, 5, 0,  1, 1, 1            ; 0???: ????    | TEST AL, 111
    db 2, 5, 1,  1, 1, 1,  2, 2, 2  ; 0???: ??????  | TEST AX, 222111
    db 2, 5, 2                      ; 0???: ??      | STOSB
    db 2, 5, 5                      ; 0???: ??      | LODSW
    db 2, 5, 7                      ; 0???: ??      | SCASW
    db 2, 6, 4,  0, 1, 1            ; 0???: ????    | MOV AH, 011
    db 2, 7, 2,  3, 3, 6,  0, 0, 1  ; 0???: ??????  | MOV DX, 001336
    
; ------------------------------------- GROUP 3 ----------------------------------------------
    db 3, 0, 2,  1, 1, 1,  2, 2, 2  ; 0???: ??      | RET 222111
    db 3, 0, 3                      ; 0???: ??      | RET
    db 3, 1, 2,  1, 1, 1,  2, 2, 2  ; 0???: ??      | RETF 222111
    db 3, 1, 3                      ; 0???: ??      | RETF
    db 3, 1, 5,  0, 4, 1            ; 0???: ??      | INT 041
    db 3, 1, 6                      ; 0???: ??      | INTO
    db 3, 2, 4                      ; 0???: ??      | UNDEFINED
    db 3, 2, 4,  0, 1, 2            ; 0???: ??      | AAM
    db 3, 2, 6                      ; 0???: ??      | UNDEFINED
    db 3, 2, 7                      ; 0???: ??      | XLAT
    db 3, 4, 4,  1, 1, 1            ; 0???: ??      | IN AL, 111
    db 3, 4, 7,  0, 0, 1            ; 0???: ??      | OUT 001, AX
    db 3, 5, 5                      ; 0???: ??      | IN AX, DX
    db 3, 5, 6                      ; 0???: ??      | OUT DX, AL
    db 3, 6, 0                      ; 0???: ??      | LOCK
    db 3, 6, 1                      ; 0???: ??      | UNDEFINED
    db 3, 6, 3                      ; 0???: ??      | REP
    db 3, 6, 4                      ; 0???: ??      | HLT
    db 3, 7, 1                      ; 0???: ??      | STC
    db 3, 7, 2                      ; 0???: ??      | CLI
    db 3, 7, 4                      ; 0???: ??      | CLD

    db 0FFh
; ============================================================================================

; ============================================================
;  CODE
; ============================================================

.code

; ------------------------------------------------------------
; PROCEDURES
; ------------------------------------------------------------

; Before call: SI must point to the first octal 
; digit of the byte to be printed
;
; After call: SI increases by 3
proc p_print_next_byte
    push ax dx
    inc si
    mov dl, byte ptr [data_octal+si]
    add dl, 30h
    mov ah, 02h
    int 21h

    inc si
    mov dl, byte ptr [data_octal+si]
    add dl, 30h
    int 21h

    inc si
    mov dl, byte ptr [data_octal+si]
    add dl, 30h
    int 21h
    pop dx ax
    ret
endp

; Before call: SI must point to the first octal 
; digit of the youngest byte
;
; After call: SI increases by 6
proc p_print_next_word
    push ax dx
    inc si
    mov dl, byte ptr [data_octal+si+3]
    add dl, 30h
    mov ah, 02h
    int 21h

    inc si
    mov dl, byte ptr [data_octal+si+3]
    add dl, 30h
    int 21h

    inc si
    mov dl, byte ptr [data_octal+si+3]
    add dl, 30h
    int 21h

    inc si
    mov dl, byte ptr [data_octal+si-3]
    add dl, 30h
    int 21h

    inc si
    mov dl, byte ptr [data_octal+si-3]
    add dl, 30h
    int 21h

    inc si
    mov dl, byte ptr [data_octal+si-3]
    add dl, 30h
    int 21h

    pop dx ax
    ret
endp

; Decode 'reg' from 'mod reg r/m [offset]'
; Before call: SI must point to 'mod' byte
;              DL must be either 0 (=byte) or 1 (=word)
;
; After call: SI is not changed.
proc p_decode_reg
    push ax bx dx
 
    ; get 'reg' value (3 bits, represented as an octal number)
    inc si
    mov al, byte ptr [data_octal+si]

    ; check if it's byte or word instruction
    cmp dl, 1
    jb print_byte_reg

    print_word_reg:
        ; TODO move this part to m_print_reg macro
        mov bl, al
        shl bl, 1 ; times 2
        m_print_reg Rw
        jmp reg_printed

    ; print byte register according to 'reg' value
    print_byte_reg:
        ; TODO move this part to m_print_reg macro
        mov bl, al
        shl bl, 1 ; times 2
        m_print_reg Rb

    reg_printed:
    ; place SI back to point at 'mod'
    dec si
    pop dx bx ax
    ret
endp

; Decode 'r/m' from 'mod reg r/m [offset]'
; Before call: SI must point to 'mod' byte
;              DL must be either 0 (=byte) or 1 (=word)
;
; After call: SI is not changed.
;             CL will contain how many bytes (as in octal digits)
;                were used for offset (or direct address)
proc p_decode_rm
    push ax bx dx

    ; get 'mod' value (2 bits, represented as an octal number)
    mov al, byte ptr [data_octal+si]

    ; check 'mod' value
    cmp al, 3
    jb __rm_is_mem ; so 'r/m' is memory (according to 'mod')

    ; 'r/m' is register (according to 'mod')
    _rm_is_reg:
        ; point SI to 'reg' and call decode_reg procedure.
        inc si
        ; It will think that SI points to 'mod', and will treat
        ; 'r/m' as 'reg', which is what is needed here.
        ; TODO comment: it will use DL
        call p_decode_reg 
        ; point SI back to 'mod'
        dec si

        ; save in CL how many additional bytes (in octal) were read after 'r/m' byte
        mov cl, 0 
        jmp endp_decode_rm

    ; 'r/m' is memory (according to 'mod')
    __rm_is_mem:
        ; check 'mod' value again
        cmp al, 1
        jb _rm_is_mem_no_offset ; so offset is not used for EA (according to 'mod')

        ; offset is used for EA (according to 'mod')
        _rm_is_mem_with_offset:
            ; place 'mod' value in CH (needed later for specifying offset)
            mov ch, al

            ; get 'r/m' value (3 bits, represented as an octal number)
            inc si
            inc si
            mov al, byte ptr [data_octal+si]

            m_print_ptr
            m_puts ' ['

            mov bl, al 
            shl bl, 1 ; times 2
            ; print register (used as a base) according to 'r/m' value
            m_print_reg EAb
            m_puts '+'

            ; check 'r/m' value again
            cmp al, 4
            jae no_index_L0; so index register is not used for EA

            ; index register is also used for EA
            add_index_L0:
                ; print register (used as an index) according to 'r/m' value
                m_print_reg EAi
                m_puts '+'

            ; if jumped to this label, index register is not used for EA
            no_index_L0:
            ; CH contains 'mod' value
            cmp ch, 2
            jb print_offset_byte ; offset is one byte (according to 'mod')

            ; offset is two bytes (according to 'mod')
            print_offset_word:
                call p_print_next_word
                ; save in CL how many additional bytes (in octal) were read after 'r/m' byte
                mov cl, 6
                ; place SI back to point at 'r/m'
                sub si, 6

                jmp offset_printed

            ; offset is one byte (according to 'mod')
            print_offset_byte:
                call p_print_next_byte
                ; save in CL how many additional bytes (in octal) were read after 'r/m' byte
                mov cl, 3
                ; place SI back to point at 'r/m'
                sub si, 3

            offset_printed:
            m_puts ']'

            ; place SI back to point at 'mod'
            dec si
            dec si
            jmp endp_decode_rm

        ; offset is not used for EA (according to 'mod')
        _rm_is_mem_no_offset:
            ; get 'r/m' value (3 bits, represented as an octal number)
            inc si
            inc si
            mov al, byte ptr [data_octal+si]

            ; check 'r/m' value for a special case - direct address
            cmp al, 6
            je _rm_is_mem_no_offset_direct_address ; so only direct address is used for EA

            m_print_ptr
            m_puts ' ['

            mov bl, al 
            shl bl, 1 ; times 2
            ; print register (used as a base) according to 'r/m' value
            m_print_reg EAb

            ; check 'r/m' value again
            cmp al, 4
            jae short no_index_L1; so index register is not used for EA

            ; index register is also used for EA
            add_index_L1:
                ; print register (used as an index) according to 'r/m' value
                m_puts '+'
                m_print_reg EAi

            ; if jumped to this label, index register is not used for EA
            no_index_L1:
            m_puts ']'

            ; save in CL how many additional bytes (in octal) were read after 'r/m' byte
            mov cl, 0 
            ; place SI back to point at 'mod'
            dec si
            dec si
            jmp endp_decode_rm

            ; only direct address is used for EA
            _rm_is_mem_no_offset_direct_address:
                m_print_ptr
                m_puts ' ['
                ; print direct address (two bytes)
                call p_print_next_word
                m_puts ']'

                ; save in CL how many additional bytes (in octal) were read after 'r/m' byte
                mov cl, 6

                ; place SI back to point at 'r/m'
                sub si, 6

                ; place SI back to point at 'mod'
                dec si
                dec si

    endp_decode_rm:
        pop dx bx ax
    ret
endp

; Handles printing "r/m, immediate" for the 
; commands of the format:
; 1000 00sw mod XXX r/m [offset] lsb [msb]
; where each 'X' is one of 0 or 1.
proc p_op_0sw_rm_imm
    push ax bx dx

    ; AL so far contains 3 bits '0sw' as an octal number.
    inc si ; SI must point to 'mod' before calling 
           ; the decode procedure
    mov dl, al
    and dl, 01b
    ; now DL has information (w=0)/(w=1)
    ; which is expected by the decode procedure
    call p_decode_rm
    ; after the procedure, CL contains how many bytes
    ; the offset took (if any)

    m_puts ', '
    
    ; TODO wrap this in macro/proc
    ; point SI to the last byte read
    inc si 
    inc si ; SI points to r/m now

    cmp cl, 0
    je si_in_right_place_L0 ; offset was not used

    ; offset was used
    ; point SI to the last byte read
    ;
    ; cl contains information about how many 
    ; bytes (=octal digits?) were read as an offset or direct address
    xor ch, ch
    loop_L0:
        inc si
    loop loop_L0

    si_in_right_place_L0:

    ; AL still contains '0sw'
    ; DL still contains (w=0) or (w=1)

    ; check 'w' bit
    cmp dl, 1
    jb imm_1_byte

    ; w = 1
    ; check 's' bit (info about immediate operand)
    cmp al, 2
    jb imm_2_bytes ; so s = 0

    ; w = 1, s = 1
    imm_byte_to_word_sign_extended:
        ; get 1st octal digit of lsb
        inc si
        mov al, byte ptr [data_octal+si]
        dec si

        cmp al, 2
        jb zero_padding

        one_padding:
            m_puts "377"
            jmp padding_done

        zero_padding:
            m_puts "000"

        padding_done:
        call p_print_next_byte
        jmp endp_op_0sw_rm_imm

    ; w = 0, s = 0 or 1
    imm_1_byte:
        call p_print_next_byte
        jmp endp_op_0sw_rm_imm

    ; w = 1, s = 0
    imm_2_bytes:
        call p_print_next_word

    endp_op_0sw_rm_imm:
        m_print_nl
        pop dx bx ax
    ret
endp

; Handles printing "reg, r/m" or "r/m, reg" for the 
; commands of the format:
;   XXXX X0dw mod reg r/m [offset]  
; where each 'X' is one of 0 or 1.
;
; It applies to 
;   ADD, OR, ADC, SBB, AND, SUB, XOR, CMP (all from 1st octal group) 
;   and one MOV command
;
; Before call: SI should point to the octal digit for '0dw',
;              AL should contain the value of '0dw' as an octal digit
;
; After call: SI points to the last byte read in a command
proc p_op_0dw_reg_rm
    push ax bx dx
    inc si ; si must point to 'mod' before calling decode procedures

    ; AL so far contains 3 bits '0dw' as an octal number.
    ; check 'd' (destination) bit
    cmp al, 2
    jb __op_rm_reg  ; so d = 0

    ; d = 1
    __op_reg_rm:
        ; AL currently contains either 2 (w=0) or 3 (w=1)
        ; By subtracting 2 from AL, AL will contain either 0 (w=0) or 1 (w=1)
        ; This information will be used by the decode procedures
        sub al, 2
        ; place (w=0)/(w=1) information in DL,
        ; which is expected by decode procedures
        mov dl, al
        ; decode which register is used in place of 'reg'
        call p_decode_reg
        m_puts ', '
        ; decode what should be used in place of 'r/m'
        call p_decode_rm
        jmp move_index

    ; d = 0
    __op_rm_reg:
        ; AL currently contains either 0 (w=0) or 1 (w=1)
        ; This information will be used by the decode procedures
        ;
        ; place (w=0)/(w=1) information in DL,
        ; which is expected by decode procedures
        mov dl, al
        call p_decode_rm
        m_puts ', '
        call p_decode_reg

    ; move SI to the last byte read
    move_index:
        ; point SI to 'r/m'
        inc si
        inc si

        cmp cl, 0
        je si_in_right_place_L1 ; offset was not used

        ; offset was used
        ; point SI to the last byte read
        ;
        ; cl contains information about how many 
        ; bytes were read as an offset or direct address
        xor ch, ch
        loop_L1:
            inc si
        loop loop_L1

    si_in_right_place_L1:
    m_print_nl
    pop dx bx ax
    ret
endp

; -----------------------------------------------------------/

start:
    mov ax, @data                  ; move @data to AX (@data - address where data segment starts)
    mov ds, ax                     ; move AX (@data) to DS (data segment)
    mov es, ax                     ; move AX (@data) to ES (extended data segment)

    ; print program description
    m_println sep
    m_puts   '                                   '
    m_puts   'DISASM'
    m_putsln '                                   '
    m_println sep

    xor ax, ax
    xor si, si

    mov si, 0FFFFh

_xxx:
    ; get 1st octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 0FFh
    je short exit_program

    cmp al, 3
    je _3xx
    ja short undefined_1st_octal

    cmp al, 1
    jb short _0xx
    je _1xx
    jmp _2xx

    jmp short _xxx

undefined_1st_octal:
    inc si
    inc si
    jmp short undefined

undefined_2nd_octal:
    inc si
    jmp short undefined

undefined:
    m_putsln 'UNDEFINED'
    jmp short _xxx

exit_program:
    m_exit0

; ============================================================
;  _0XX
; ============================================================
_0xx:
    ; get 2nd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    ; get 3rd octal digit
    inc si ; SI now also points to 3rd octal
    mov bl, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined ; undefined_2nd_octal is not used here, since 
                 ; SI already points to the last octal digit

    ; --------- check the 3rd octal digit -------------

    ; check if it's a (POP seg)/(adjust) operation
    cmp bl, 7
    je short __0x7
    ja undefined

    ; check if it's a (PUSH seg)/(seg change prefix) operation
    cmp bl, 6
    je short __0x6

    ; --------- check the 2nd octal digit -------------

    cmp al, 4
    jb short __0_0123_x
    je _04x
    jmp short __0_567_x
    
    __0_0123_x:
        cmp al, 2
        jb short __0_01_x
        je _02x
        jmp _03x

    __0_567_x:
        cmp al, 6
        jb _05x
        je _06x
        jmp _07x

    __0_01_x:
        cmp al, 1
        jb short _00x
        jmp _01x

    ; if it's a (PUSH seg)/(seg change prefix) operation
    __0x6:
        cmp al, 4
        jb _0x6_push_seg
        jmp _0x6_seg_change_prefix

    ; if it's a (POP seg)/(adjust) operation
    __0x7:
        cmp al, 4
        jb _0x7_pop_seg
        je _047_add_sub_adjust
        
        cmp al, 6
        jb _057_add_sub_adjust
        jb _067_add_sub_adjust
        jmp _077_add_sub_adjust

; ------------------------------------------------------------
;  _00X
; ------------------------------------------------------------
_00x:
    ; 3rd octal digit is already in BL, and it 
    ; cannot be 6 or 7 (since it was checked before)
    mov al, bl

    cmp al, 4
    jb short __00_0123_add_reg_rm
    je _004_add_acc_imm_byte
    jmp _005_add_acc_imm_word

; ------------------------------------------------------------
__00_0123_add_reg_rm:
    m_puts 'ADD '
    call p_op_0dw_reg_rm
    jmp _xxx

; -------------------------------------------------------------
_004_add_acc_imm_byte:
    m_puts 'ADD AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_005_add_acc_imm_word:
    m_puts 'ADD AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _01X
; ------------------------------------------------------------
_01x:
    ; 3rd octal digit is already in BL
    mov al, bl

    cmp al, 4
    jb short __01_0123_or_reg_rm
    je _014_or_acc_imm_byte
    jmp _015_or_acc_imm_word

; ------------------------------------------------------------
__01_0123_or_reg_rm:
    m_puts 'OR '
    call p_op_0dw_reg_rm
    jmp _xxx

; -------------------------------------------------------------
_014_or_acc_imm_byte:
    m_puts 'OR AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_015_or_acc_imm_word:
    m_puts 'OR AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _02X
; ------------------------------------------------------------
_02x:
    ; 3rd octal digit is already in BL
    mov al, bl

    cmp al, 4
    jb short __02_0123_adc_reg_rm
    je _024_adc_acc_imm_byte
    jmp _025_adc_acc_imm_word
    
; ------------------------------------------------------------
__02_0123_adc_reg_rm:
    m_puts 'ADC '
    call p_op_0dw_reg_rm
    jmp _xxx

; ------------------------------------------------------------
_024_adc_acc_imm_byte:
    m_puts 'ADC AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_025_adc_acc_imm_word:
    m_puts 'ADC AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _03X
; ------------------------------------------------------------
_03x:
    ; 3rd octal digit is already in BL
    mov al, bl

    cmp al, 4
    jb short __03_0123_sbb_reg_rm
    je _034_sbb_acc_imm_byte
    jmp _035_sbb_acc_imm_word

; ------------------------------------------------------------
__03_0123_sbb_reg_rm:
    m_puts 'SBB '
    call p_op_0dw_reg_rm
    jmp _xxx

; -------------------------------------------------------------
_034_sbb_acc_imm_byte:
    m_puts 'SBB AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_035_sbb_acc_imm_word:
    m_puts 'SBB AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _04X
; ------------------------------------------------------------
_04x:
    ; 3rd octal digit is already in BL
    mov al, bl

    cmp al, 4
    jb short __04_0123_and_reg_rm
    je _044_and_acc_imm_byte
    jmp _045_and_acc_imm_word

; ------------------------------------------------------------
__04_0123_and_reg_rm:
    m_puts 'AND '
    call p_op_0dw_reg_rm
    jmp _xxx

; -------------------------------------------------------------
_044_and_acc_imm_byte:
    m_puts 'AND AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_045_and_acc_imm_word:
    m_puts 'AND AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _05X
; ------------------------------------------------------------
_05x:
    ; 3rd octal digit is already in BL
    mov al, bl

    cmp al, 4
    jb short __05_0123_sub_reg_rm
    je _054_sub_acc_imm_byte
    jmp _055_sub_acc_imm_word

; ------------------------------------------------------------
__05_0123_sub_reg_rm:
    m_puts 'SUB '
    call p_op_0dw_reg_rm
    jmp _xxx

; -------------------------------------------------------------
_054_sub_acc_imm_byte:
    m_puts 'SUB AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_055_sub_acc_imm_word:
    m_puts 'SUB AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _06X
; ------------------------------------------------------------
_06x:
    ; 3rd octal digit is already in BL
    mov al, bl

    cmp al, 4
    jb short __06_0123_xor_reg_rm
    je _064_xor_acc_imm_byte
    jmp _065_xor_acc_imm_word

; ------------------------------------------------------------
__06_0123_xor_reg_rm:
    m_puts 'XOR '
    call p_op_0dw_reg_rm
    jmp _xxx

; -------------------------------------------------------------
_064_xor_acc_imm_byte:
    m_puts 'XOR AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_065_xor_acc_imm_word:
    m_puts 'XOR AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _07X
; ------------------------------------------------------------
_07x:
    ; 3rd octal digit is already in BL
    mov al, bl

    cmp al, 4
    jb short __07_0123_cmp_reg_rm
    je _074_cmp_acc_imm_byte
    jmp _075_cmp_acc_imm_word

; ------------------------------------------------------------
__07_0123_cmp_reg_rm:
    m_puts 'CMP '
    call p_op_0dw_reg_rm
    jmp _xxx

; -------------------------------------------------------------
_074_cmp_acc_imm_byte:
    m_puts 'CMP AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_075_cmp_acc_imm_word:
    m_puts 'CMP AX, '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _0X6
; ------------------------------------------------------------
_0x6_push_seg:
    ; 2nd octal digit is already in AL
    ; it is one of {0,1,2,3}

    m_puts 'PUSH '

    mov bl, al 
    shl bl, 1 ; times 2
    m_print_reg SR

    m_print_nl
    jmp _xxx

_0x6_seg_change_prefix:
    ; 2nd octal digit is already in AL
    ; AL is one of {4,5,6,7}

    m_putsln '0x6_seg_change_prefix'
    jmp _xxx

; ------------------------------------------------------------
;  _0X7
; ------------------------------------------------------------
_0x7_pop_seg:
    ; 2nd octal digit is already in AL
    ; it is one of {0,1,2,3}

    m_puts 'POP '

    mov bl, al 
    shl bl, 1 ; times 2
    m_print_reg SR

    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_047_add_sub_adjust:
    m_putsln 'DAA'
    jmp _xxx

; -------------------------------------------------------------
_057_add_sub_adjust:
    m_putsln 'DAS'
    jmp _xxx

; -------------------------------------------------------------
_067_add_sub_adjust:
    m_putsln 'AAA'
    jmp _xxx

; -------------------------------------------------------------
_077_add_sub_adjust:
    m_putsln 'AAS'
    jmp _xxx

; ============================================================
;  _1XX
; ============================================================
_1xx:
    ; get 2nd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    je _17x
    ja undefined_2nd_octal

    cmp al, 3
    jb short __1_012_x
    je _13_pop_reg_word
    jmp short __1_456_x

    __1_012_x:
        cmp al, 1
        jb short _10x_inc_reg_word
        je _11_dec_reg_word
        jmp _12_push_reg_word

    __1_456_x:
        cmp al, 6
        je _16x
        jmp undefined_2nd_octal ; _14x, _15x

; ------------------------------------------------------------
;  _10X
; ------------------------------------------------------------
_10x_inc_reg_word:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    m_puts 'INC '

    mov bl, al
    shl bl, 1 ; times 2
    m_print_reg Rw

    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _11X
; ------------------------------------------------------------
_11_dec_reg_word:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    m_puts 'DEC '

    mov bl, al
    shl bl, 1; times 2. bl = 4
    m_print_reg Rw

    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _12X
; ------------------------------------------------------------
_12_push_reg_word:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    m_puts 'PUSH '

    mov bl, al
    shl bl, 1; times 2. bl = 4
    m_print_reg Rw

    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _13X
; ------------------------------------------------------------
_13_pop_reg_word:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    m_puts 'POP '

    mov bl, al
    shl bl, 1; times 2. bl = 4
    m_print_reg Rw

    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _16X
; ------------------------------------------------------------
_16x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    je _167
    ja undefined

    cmp al, 3
    jb short __16_012
    je _163
    jmp short __16_456

    __16_012:
        cmp al, 1
        jb short _160
        je _161
        jmp _162

    __16_456:
        cmp al, 5
        jb _164
        je _165
        jmp _166

; ------------------------------------------------------------
_160:
    m_putsln '160'
    jmp _xxx

; ------------------------------------------------------------
_161:
    m_putsln '161'
    jmp _xxx

; ------------------------------------------------------------
_162:
    m_putsln '162'
    jmp _xxx

; ------------------------------------------------------------
_163:
    m_putsln '163'
    jmp _xxx

; ------------------------------------------------------------
_164:
    m_putsln '164'
    jmp _xxx

; ------------------------------------------------------------
_165:
    m_putsln '165'
    jmp _xxx

; ------------------------------------------------------------
_166:
    m_putsln '166'
    jmp _xxx

; ------------------------------------------------------------
_167:
    m_putsln '167'
    jmp _xxx

; ------------------------------------------------------------
;  _17X
; ------------------------------------------------------------
_17x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    je _177
    ja undefined

    cmp al, 3
    jb short __17_012
    je _173
    jmp short __17_456

    __17_012:
        cmp al, 1
        jb short _170
        je _171
        jmp _172

    __17_456:
        cmp al, 5
        jb _174
        je _175
        jmp _176

; ------------------------------------------------------------
_170:
    m_putsln '170'
    jmp _xxx

; ------------------------------------------------------------
_171:
    m_putsln '171'
    jmp _xxx

; ------------------------------------------------------------
_172:
    m_putsln '172'
    jmp _xxx

; ------------------------------------------------------------
_173:
    m_putsln '173'
    jmp _xxx

; ------------------------------------------------------------
_174:
    m_putsln '174'
    jmp _xxx

; ------------------------------------------------------------
_175:
    m_putsln '175'
    jmp _xxx

; ------------------------------------------------------------
_176:
    m_putsln '176'
    jmp _xxx

; ------------------------------------------------------------
_177:
    m_putsln '177'
    jmp _xxx

; ============================================================
;  _2XX
; ============================================================
_2xx:
    ; get 2nd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    je _27x_mov_reg_imm_word
    ja undefined_2nd_octal

    cmp al, 3
    jb short __2_012_x
    je _23x
    jmp short __2_456_x

    __2_012_x:
        cmp al, 1
        jb short _20x
        je _21x
        jmp _22x_xchg_reg_ax

    __2_456_x:
        cmp al, 5
        jb _24x
        je _25x
        jmp _26x_mov_reg_imm_byte

; ------------------------------------------------------------
;  _20X
; ------------------------------------------------------------
_20x:
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __20_0123

    cmp al, 6
    jb _20_45_test_reg_rm
    jmp _20_67_xchg_reg_rm

    __20_0123:
        inc si ; point to 'mod'
        inc si ; point SI to next octal digit after 'mod'
        mov bl, byte ptr [data_octal+si]
        dec si
        dec si ; return SI back
        ; find out which operation is used
        cmp bl, 4
        jb short __20_0123_mod_0123
        je _20_0123_and_rm_imm

        cmp bl, 6
        jb _20_0123_sub_rm_imm
        je _20_0123_xor_rm_imm
        jmp _20_0123_cmp_rm_imm

    __20_0123_mod_0123:
        cmp bl, 2
        jb short __20_0123_mod_01
        je _20_0123_adc_rm_imm
        jmp _20_0123_sbb_rm_imm

    __20_0123_mod_01:
        cmp bl, 1
        jb _20_0123_add_rm_imm
        jmp _20_0123_or_rm_imm

; ------------------------------------------------------------
_20_0123_add_rm_imm:
    m_puts 'ADD '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_0123_or_rm_imm:
    m_puts 'OR '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_0123_adc_rm_imm:
    m_puts 'ADC '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_0123_sbb_rm_imm:
    m_puts 'SBB '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_0123_and_rm_imm:
    m_puts 'AND '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_0123_sub_rm_imm:
    m_puts 'SUB '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_0123_xor_rm_imm:
    m_puts 'XOR '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_0123_cmp_rm_imm:
    m_puts 'CMP '
    call p_op_0sw_rm_imm
    jmp _xxx

; ------------------------------------------------------------
_20_45_test_reg_rm:
    m_puts 'TEST '
    ; AL contains '10w'
    mov dl, al
    and dl, 001b ; will be used for decode procedures

    inc si ; si points to 'mod' now

    call p_decode_reg
    m_puts ', '
    call p_decode_rm

    ; point SI to 'r/m'
    inc si
    inc si

    cmp cl, 0
    je si_in_right_place_L2 ; offset was not used

    ; offset was used
    ; point SI to the last byte read
    ;
    ; cl contains information about how many 
    ; bytes were read as an offset or direct address
    xor ch, ch
    loop_L2:
        inc si
    loop loop_L2

    si_in_right_place_L2:
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
_20_67_xchg_reg_rm:
    m_puts 'XCHG '
    ; AL contains '11w'
    mov dl, al
    and dl, 001b ; will be used for decode procedures

    inc si ; si points to 'mod' now

    call p_decode_reg
    m_puts ', '
    call p_decode_rm

    ; point SI to 'r/m'
    inc si
    inc si

    cmp cl, 0
    je si_in_right_place_L3 ; offset was not used

    ; offset was used
    ; point SI to the last byte read
    ;
    ; cl contains information about how many 
    ; bytes were read as an offset or direct address
    xor ch, ch
    loop_L3:
        inc si
    loop loop_L3

    si_in_right_place_L3:
    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _21X
; ------------------------------------------------------------
_21x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    je _217_pop_rm
    ja undefined

    cmp al, 4
    jb short __21_0123_mov_reg_rm
    je _214_mov_rm_segreg

    cmp al, 6
    jb _215_lea_reg_mem
    jmp _216_mov_segreg_rm

; ------------------------------------------------------------
__21_0123_mov_reg_rm:
    m_puts 'MOV '
    call p_op_0dw_reg_rm
    jmp _xxx

; ------------------------------------------------------------
_214_mov_rm_segreg:
    m_putsln '214'
    jmp _xxx

; ------------------------------------------------------------
_215_lea_reg_mem:
    m_putsln '215'
    jmp _xxx

; ------------------------------------------------------------
_216_mov_segreg_rm:
    m_putsln '216'
    jmp _xxx

; ------------------------------------------------------------
_217_pop_rm:
    m_putsln '217'
    jmp _xxx

; ------------------------------------------------------------
;  _22X
; ------------------------------------------------------------
_22x_xchg_reg_ax:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 0
    je short _22x_nop

    m_puts 'XCHG '

    mov bl, al
    shl bl, 1; times 2. bl = 4
    m_print_reg Rw

    m_putsln ', AX'
    jmp _xxx

    _22x_nop:
        m_putsln 'NOP'
        jmp _xxx

; ------------------------------------------------------------
;  _23X
; ------------------------------------------------------------
_23x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __23_0123
    je _234_pushf

    cmp al, 6
    jb _235_popf
    je _236_sahf
    jmp _237_lahf

    __23_0123:
        cmp al, 2
        jb short __23_01
        je _232_call_label_far_absolute
        jmp _233_wait

    __23_01:
        cmp al, 1
        jb short _230_cbw
        jmp _231_cwd

; -------------------------------------------------------------
_230_cbw:
    m_putsln 'CBW'
    jmp _xxx

; -------------------------------------------------------------
_231_cwd:
    m_putsln 'CWD'
    jmp _xxx

; ------------------------------------------------------------
_232_call_label_far_absolute:
    m_putsln '_232_call_label_far_absolute'
    jmp _xxx

; -------------------------------------------------------------
_233_wait:
    m_putsln 'WAIT'
    jmp _xxx

; -------------------------------------------------------------
_234_pushf:
    m_putsln 'PUSHF'
    jmp _xxx

; -------------------------------------------------------------
_235_popf:
    m_putsln 'POPF'
    jmp _xxx

; -------------------------------------------------------------
_236_sahf:
    m_putsln 'SAHF'
    jmp _xxx

; -------------------------------------------------------------
_237_lahf:
    m_putsln 'LAHF'
    jmp _xxx

; ------------------------------------------------------------
;  _24X
; ------------------------------------------------------------
_24x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __24_0123
    je _244_movsb

    cmp al, 6
    jb _245_movsw
    je _246_cmpsb
    jmp _247_cmpsw

    __24_0123:
        cmp al, 2
        jb short __24_01
        je _242_mov_mem_acc_byte
        jmp _243_mov_mem_acc_word

    __24_01:
        cmp al, 1
        jb short _240_mov_acc_mem_byte
        jmp _241_mov_acc_mem_word

; -------------------------------------------------------------
_240_mov_acc_mem_byte:
    m_puts 'MOV AL, ['
    call p_print_next_word
    m_putsln ']'
    jmp _xxx

; -------------------------------------------------------------
_241_mov_acc_mem_word:
    m_puts 'MOV AX, ['
    call p_print_next_word
    m_putsln ']'
    jmp _xxx

; -------------------------------------------------------------
_242_mov_mem_acc_byte:
    m_puts 'MOV ['
    call p_print_next_word
    m_putsln '], AL'
    jmp _xxx

; -------------------------------------------------------------
_243_mov_mem_acc_word:
    m_puts 'MOV ['
    call p_print_next_word
    m_putsln '], AX'
    jmp _xxx

; -------------------------------------------------------------
_244_movsb:
    m_putsln 'MOVSB'
    jmp _xxx

; -------------------------------------------------------------
_245_movsw:
    m_putsln 'MOVSW'
    jmp _xxx

; -------------------------------------------------------------
_246_cmpsb:
    m_putsln 'CMPSB'
    jmp _xxx

; -------------------------------------------------------------
_247_cmpsw:
    m_putsln 'CMPSW'
    jmp _xxx

; ------------------------------------------------------------
;  _25X
; ------------------------------------------------------------
_25x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __25_0123
    je _254_lodsb

    cmp al, 6
    jb _255_lodsw
    je _256_scasb
    jmp _257_scasw

    __25_0123:
        cmp al, 2
        jb short __25_01
        je _252_stosb
        jmp _253_stosw

    __25_01:
        cmp al, 1
        jb _250_test_acc_imm_byte
        jmp _251_test_acc_imm_word

; -------------------------------------------------------------
_250_test_acc_imm_byte:
    m_puts 'TEST AL, '
    call p_print_next_byte

    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_251_test_acc_imm_word:
    m_puts 'TEST AX, '
    call p_print_next_word

    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
_252_stosb:
    m_putsln 'STOSB'
    jmp _xxx

; ------------------------------------------------------------
_253_stosw:
    m_putsln 'STOSW'
    jmp _xxx

; ------------------------------------------------------------
_254_lodsb:
    m_putsln 'LODSB'
    jmp _xxx

; ------------------------------------------------------------
_255_lodsw:
    m_putsln 'LODSW'
    jmp _xxx

; ------------------------------------------------------------
_256_scasb:
    m_putsln 'SCASB'
    jmp _xxx

; ------------------------------------------------------------
_257_scasw:
    m_putsln 'SCASW'
    jmp _xxx

; ------------------------------------------------------------
;  _26X
; ------------------------------------------------------------
_26x_mov_reg_imm_byte:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    m_puts 'MOV '

    mov bl, al
    shl bl, 1 ; times 2
    m_print_reg Rb
    m_puts ', '
    call p_print_next_byte

    m_print_nl
    jmp _xxx

; ------------------------------------------------------------
;  _27X
; ------------------------------------------------------------
_27x_mov_reg_imm_word:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    m_puts 'MOV '

    mov bl, al
    shl bl, 1; times 2. bl = 4
    m_print_reg Rw
    m_puts ', '
    call p_print_next_word

    m_print_nl
    jmp _xxx

; ============================================================
;  _3XX
; ============================================================
_3xx:
    ; get 2nd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    je _37x
    ja undefined_2nd_octal

    cmp al, 3
    jb short __3_012_x
    je _33x
    jmp short __3_456_x

    __3_012_x:
        cmp al, 1
        jb short _30x
        je _31x
        jmp _32x

    __3_456_x:
        cmp al, 5
        jb _34x
        je _35x
        jmp _36x

; ------------------------------------------------------------
;  _30X
; ------------------------------------------------------------
_30x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __30_23
    je _304_les_reg_mem

    cmp al, 6
    jb _305_lds_reg_mem
    je _306_mov_rm_imm_byte
    jmp _307_mov_rm_imm_word

    __30_23:
        cmp al, 3
        jb short _302_ret_imm
        jmp _303_ret

; -------------------------------------------------------------
_302_ret_imm:
    m_puts 'RET '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_303_ret:
    m_putsln 'RET'
    jmp _xxx

; ------------------------------------------------------------
_304_les_reg_mem:
    m_putsln '304_les_reg_mem'
    jmp _xxx

; ------------------------------------------------------------
_305_lds_reg_mem:
    m_putsln '_305_lds_reg_mem'
    jmp _xxx

; ------------------------------------------------------------
_306_mov_rm_imm_byte:
    m_putsln '_306_mov_rm_imm_byte'
    jmp _xxx

; ------------------------------------------------------------
_307_mov_rm_imm_word:
    m_putsln '_307_mov_rm_imm_word'
    jmp _xxx

; ------------------------------------------------------------
;  _31X
; ------------------------------------------------------------
_31x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 5
    jb short __31_234
    je _315_int_number

    cmp al, 6
    je _316_into
    jmp _317_iret

    __31_234:
        cmp al, 3
        jb _312_retf_imm
        je _313_retf
        jmp _314_int3

; -------------------------------------------------------------
_312_retf_imm:
    m_puts 'RETF '
    call p_print_next_word
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_313_retf:
    m_putsln 'RETF'
    jmp _xxx

; -------------------------------------------------------------
_314_int3:
    m_putsln 'INT 3'
    jmp _xxx

; -------------------------------------------------------------
_315_int_number:
    m_puts 'INT '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_316_into:
    m_putsln 'INTO'
    jmp _xxx

; -------------------------------------------------------------
_317_iret:
    m_putsln 'IRET'
    jmp _xxx

; ------------------------------------------------------------
;  _32X
; ------------------------------------------------------------
_32x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __32_0123

    cmp al, 6
    jb short __32_45
    je undefined ; _326
    jmp _327_xlat

    __32_0123:
        ; TODO
        ; ...

    __32_45:
        ; check if next byte is part of AAM/AAD opcode
        cmp byte ptr [data_octal+si+1], 0
        jne undefined

        mov byte ptr [data_octal+si+2], 1
        jne undefined

        mov byte ptr [data_octal+si+3], 2
        jne undefined

        ; if AAM/AAD is recognized, move index to the 
        ; end of next byte, which is part of the opcode
        inc si
        inc si
        inc si

        cmp al, 4
        je _324_aam
        jmp _325_aad

; -------------------------------------------------------------
_324_aam:
    m_putsln 'AAM'
    jmp _xxx

; -------------------------------------------------------------
_325_aad:
    m_putsln 'AAD'
    jmp _xxx

; -------------------------------------------------------------
_327_xlat:
    m_putsln 'XLAT'
    jmp _xxx

; ------------------------------------------------------------
;  _33X
; ------------------------------------------------------------
_33x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    je _337
    ja undefined

    cmp al, 3
    jb short __33_012
    je _333
    jmp short __33_456

    __33_012:
        cmp al, 1
        jb short _330
        je _331
        jmp _332

    __33_456:
        cmp al, 5
        jb _334
        je _335
        jmp _336

; ------------------------------------------------------------
_330:
    m_putsln '330'
    jmp _xxx

; ------------------------------------------------------------
_331:
    m_putsln '331'
    jmp _xxx

; ------------------------------------------------------------
_332:
    m_putsln '332'
    jmp _xxx

; ------------------------------------------------------------
_333:
    m_putsln '333'
    jmp _xxx

; ------------------------------------------------------------
_334:
    m_putsln '334'
    jmp _xxx

; ------------------------------------------------------------
_335:
    m_putsln '335'
    jmp _xxx

; ------------------------------------------------------------
_336:
    m_putsln '336'
    jmp _xxx

; ------------------------------------------------------------
_337:
    m_putsln '337'
    jmp _xxx

; ------------------------------------------------------------
;  _34X
; ------------------------------------------------------------
_34x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __34_0123
    je _344_in_acc_port_direct_byte

    cmp al, 6
    jb _345_in_acc_port_direct_word
    je _346_out_acc_port_direct_byte
    jmp _347_out_acc_port_direct_word

    __34_0123:
        cmp al, 2
        jb short __34_01
        je _342_loop_label
        jmp _343_jcxz_label

    __34_01:
        cmp al, 1
        jb short _340_loopne_label
        jmp _341_loope_label

; ------------------------------------------------------------
_340_loopne_label:
    m_putsln '_340_loopne_label'
    jmp _xxx

; ------------------------------------------------------------
_341_loope_label:
    m_putsln '_341_loope_label'
    jmp _xxx

; ------------------------------------------------------------
_342_loop_label:
    m_putsln '_342_loop_label'
    jmp _xxx

; ------------------------------------------------------------
_343_jcxz_label:
    m_putsln '343_343_jcxz_label'
    jmp _xxx

; -------------------------------------------------------------
_344_in_acc_port_direct_byte:
    m_puts 'IN AL, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_345_in_acc_port_direct_word:
    m_puts 'IN AX, '
    call p_print_next_byte
    m_print_nl
    jmp _xxx

; -------------------------------------------------------------
_346_out_acc_port_direct_byte:
    m_puts 'OUT ' 
    call p_print_next_byte
    m_putsln ', AL'
    jmp _xxx

; -------------------------------------------------------------
_347_out_acc_port_direct_word:
    m_puts 'OUT ' 
    call p_print_next_byte
    m_putsln ', AX'
    jmp _xxx

; ------------------------------------------------------------
;  _35X
; ------------------------------------------------------------
_35x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 4
    jb short __35_0123
    je _354_in_acc_port_indirect_byte

    cmp al, 6
    jb _355_in_acc_port_indirect_word
    je _356_out_acc_port_indirect_byte
    jmp _357_out_acc_port_indirect_word

    __35_0123:
        cmp al, 2
        jb short __35_01
        je _352_jmp_label_far_absolute
        jmp _353_jmp_label_short_relative

    __35_01:
        cmp al, 1
        jb short _350_call_label_near_relative
        jmp _351_jmp_label_near_relative

; ------------------------------------------------------------
_350_call_label_near_relative:
    m_putsln '_350_call_label_near_relative'
    jmp _xxx

; ------------------------------------------------------------
_351_jmp_label_near_relative:
    m_putsln '_351_jmp_label_near_relative'
    jmp _xxx

; ------------------------------------------------------------
_352_jmp_label_far_absolute:
    m_putsln '_352_jmp_label_far_absolute'
    jmp _xxx

; ------------------------------------------------------------
_353_jmp_label_short_relative:
    m_putsln '_353_jmp_label_short_relative'
    jmp _xxx

; -------------------------------------------------------------
_354_in_acc_port_indirect_byte:
    m_putsln 'IN AL, DX'
    jmp _xxx

; -------------------------------------------------------------
_355_in_acc_port_indirect_word:
    m_putsln 'IN AX, DX'
    jmp _xxx

; -------------------------------------------------------------
_356_out_acc_port_indirect_byte:
    m_putsln 'OUT DX, AL'
    jmp _xxx

; -------------------------------------------------------------
_357_out_acc_port_indirect_word:
    m_putsln 'OUT DX, AX'
    jmp _xxx

; ------------------------------------------------------------
;  _36X
; ------------------------------------------------------------
_36x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 6
    jb short __36_012345

    ; TODO __36_67
    ; ...

    __36_012345:
        cmp al, 3
        jb short __36_012
        je _36_3_rep

    cmp al, 5
    jb _36_4_hlt
    jmp _36_5_cmc

    __36_012:
        cmp al, 1
        jb _360_lock
        je undefined ; _361
        jmp _362_repne

; -------------------------------------------------------------
_360_lock:
    m_putsln 'LOCK'
    jmp _xxx

; -------------------------------------------------------------
_362_repne:
    m_putsln 'REPNE'
    jmp _xxx

; -------------------------------------------------------------
_36_3_rep:
    m_putsln 'REP'
    jmp _xxx

; -------------------------------------------------------------
_36_4_hlt:
    m_putsln 'HLT'
    jmp _xxx

; -------------------------------------------------------------
_36_5_cmc:
    m_putsln 'CMC'
    jmp _xxx

; ------------------------------------------------------------
;  _37X
; ------------------------------------------------------------
_37x:
    ; get 3rd octal digit
    inc si
    mov al, byte ptr [data_octal+si]

    cmp al, 7
    ja undefined

    cmp al, 6
    jb short __37_012345

    ; TODO __37_67
    ; ...

    __37_012345:
        cmp al, 3
        jb short __37_012
        je _37_3_sti

    cmp al, 5
    jb _37_4_cld
    jmp _37_5_std

    __37_012:
        cmp al, 1
        jb _370_clc
        je _371_stc
        jmp _372_cli

; -------------------------------------------------------------
_370_clc:
    m_putsln 'CLC'
    jmp _xxx

; -------------------------------------------------------------
_371_stc:
    m_putsln 'STC'
    jmp _xxx

; -------------------------------------------------------------
_372_cli:
    m_putsln 'CLI'
    jmp _xxx

; -------------------------------------------------------------
_37_3_sti:
    m_putsln 'STI'
    jmp _xxx

; -------------------------------------------------------------
_37_4_cld:
    m_putsln 'CLD'
    jmp _xxx

; -------------------------------------------------------------
_37_5_std:
    m_putsln 'STD'
    jmp _xxx

; -----------------------------------------------------------/

end start
