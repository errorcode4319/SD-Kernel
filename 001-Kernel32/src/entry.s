[ORG 0x00]
[BITS 16]

SECTION .text


START:
    mov     ax, 0x1000      ;0x10000 <- Entry point Start Address 
    mov     ds, ax
    mov     es, ax      

    cli     ; block interrupt 
    lgdt    [GDTR]

    ; Entry to Protected Mode (32 bit)
    ; Set CR0 Control Register 
    ; Only Enable ProtectedMode
    mov     eax, 0x4000003B ; PG=0, CD=1, NW=0, AM=0, WP=0, NE=1, ET=1, TS=1, EM=0, MP=1, PE=1
    mov     cr0, eax 

    jmp     dword 0x08: ( PROTECTED_MODE - $$ + 0x10000 )



; Protected Mode 
[BITS 32]
PROTECTED_MODE:
    mov     ax, 0x10 
    mov     ds, ax 
    mov     es, ax 
    mov     fs, ax 
    mov     gs, ax 

    ;64KB Stack Memory 0x0000 ~ 0xFFFF
    mov     ss, ax 
    mov     esp, 0xFFFE     
    mov     ebp, 0xFFFE 

    push    ( MSG_MODE_SWITCH_SUCCDESS - $$ + 0x10000)
    push    6
    push    3 
    call    PRINTLINE32 
    add     esp, 12 

    jmp     $


PRINTLINE32:
    push    ebp 
    mov     ebp, esp 
    push    esi 
    push    edi 
    push    eax 
    push    ecx 
    push    edx 

    ; Y Pos 
    mov     eax, dword [ebp + 12]
    mov     esi, 160
    mul     esi 
    mov     edi, eax 

    ; X Pos 
    mov     eax, dword [ebp + 8]
    mov     esi, 2
    mul     esi 
    add     edi, eax 

    ;Set String Address 
    mov     esi, dword [ebp + 16]

.PRINT_LOOP:
    mov     cl, byte [esi]

    cmp     cl, 0
    je      .PRINT_END 

    mov     byte[edi + 0xB8000], cl

    add     esi, 1
    add     edi, 2
    jmp     .PRINT_LOOP 


.PRINT_END:
    pop     edx 
    pop     ecx 
    pop     eax 
    pop     edi 
    pop     esi 
    pop     ebp 
    ret 



; Datas 

align 8, db 0

dw  0x0000

; GDTR Struct 
GDTR:
    dw  GDTEND - GDT - 1 
    dd  (GDT - $$ + 0x10000)

GDT:
    ;Null Descriptors
    NULLDescriptor:
        dw  0x0000
        dw  0x0000
        db  0x00 
        db  0x00 
        db  0x00 
        db  0x00

    ;Code Segment Descriptor For Protected Mode 
    CODEDESCRIPTOR:
        dw  0xFFFF      ; Limit [15:0]
        dw  0x0000      ; Base [15:0]
        db  0x00        ; Base [23:16]
        db  0x9A        ; P=1, DPL=0, Code Segment, Execute/READ 
        db  0xCF        ; G=1, D=1, L=0, Limit[19:16]
        db  0x00        ; Base [31:24]

    DATADESCRIPTOR:
        dw  0xFFFF      ; Limit [15:0]
        dw  0x0000      ; Base [15:0]
        db  0x00        ; Base [23:16]
        db  0x92        ; P=1, DPL=0, Data Segment, Read/Write
        db  0xCF        ; G=1, D=1, L=0, Limit[19:16]
        db  0x00        ; Base [31:24]
GDTEND:


; Message 
MSG_MODE_SWITCH_SUCCDESS:   db 'Switch To Protected Mode Success', 0

times 512 - ($ - $$) db 0x00
