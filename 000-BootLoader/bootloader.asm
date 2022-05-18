[ORG 0x00]
[BITS 16]

SECTION .text

jmp         0x07C0:START            ;mov 0x07C0 to CS Segment Register 

START:
    mov     ax, 0x07C0
    mov     ds, ax
    mov     ax, 0xB800              ;0xB8000 - bios video offset 
    mov     es, ax                  ;use es segment register 
    
    mov     si, 0       

.SCREEN_CLEAR_LOOP:
    mov     byte[es: si],   0
    mov     byte[es: si+1], 0x0A    ;black bg, green fg

    add     si, 2
    cmp     si, 80 * 25 * 2         ;80*25 cli, [char][props] <- 2byte 
    jl      .SCREEN_CLEAR_LOOP 

    mov     si, 0               
    mov     di, 0                   ; init src, dst index register 



mov         ax, 0x00                ; lines

.PRINT_MESSAGE_LOOP:
    mov     cl, byte [si + MESSAGE1]

    cmp     cl, 0X0A
    je      .PRINT_NEW_LINE 
    cmp     cl, 0
    je      .PRINT_END 

    mov     byte[es: di], cl 

    add     si, 1       
    add     di, 2       

    jmp     .PRINT_MESSAGE_LOOP 


.PRINT_NEW_LINE:   
    add     ax, 160     ; 80(cols) * 2 
    add     si, 1 
    mov     di, ax    
    jmp     .PRINT_MESSAGE_LOOP 

.PRINT_END:
    mov     ax, 0       
    jmp     $


MESSAGE1:   
    db      0x0A 
    db      '    [SDos v0.1]', 0x0A 
    db      '    Boot Loader Running', 0x0A     
    db      '    SourceCode => http://github.com/errorcode4319/SD-Kernel', 0; booting message 

times       510 - ( $ - $$ )  db  0x00 

db 0x55
db 0xAA     ; Boot Sector End => 0x55AA