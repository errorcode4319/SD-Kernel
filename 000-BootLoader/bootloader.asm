[ORG 0x00]
[BITS 16]

SECTION .text

jmp         0x07C0:START            ;mov 0x07C0 to CS Segment Register 
;===========================================;
;Environment Datas 
;===========================================;
TOTAL_SECTOR_COUNT: dw  1024 


START:
    mov     ax, 0x07C0              ;0x7C00 - Start Address
    mov     ds, ax
    mov     ax, 0xB800              ;0xB8000 - bios video offset 
    mov     es, ax                  
    
    ; Init Stack Memory 
    ; Stack Segment <- 0x0000
    ; Base Pointer <- 0xFFFE 
    mov     ax, 0x0000              
    mov     ss, ax                   
    mov     sp, 0xFFFE 
    mov     bp, 0xFFFE

    mov     si, 0       

.SCREEN_CLEAR_LOOP:
    mov     byte[es: si],   0
    mov     byte[es: si+1], 0x0A    ;black bg, green fg

    add     si, 2
    cmp     si, 80 * 25 * 2         ;80*25 cli, [char][props] <- 2byte 
    jl      .SCREEN_CLEAR_LOOP 


.PRINT_BOOT_MESSAGE:
    push    MSG_BOOT_1      
    push    0           ;Y pos 
    push    3           ;X pos 
    call    PRINTLINE
    add     sp, 6
    push    MSG_BOOT_2
    push    1
    push    3
    call    PRINTLINE   
    add     sp, 6
    push    MSG_BOOT_3
    push    2
    push    3
    call    PRINTLINE   
    add     sp, 6


.LOAD_OS_IMAGE:
    push    MSG_IMG_LOADING_START 
    push    4
    push    3
    call    PRINTLINE 
    add     sp, 6

    jmp     $


; Print Message in 16bit real mode 
; param X, Y, String Address 
; push -> String, Y, X 
PRINTLINE:
    push    bp
    mov     bp, sp 

    push    es
    push    si
    push    di 
    push    ax
    push    cx
    push    dx  

    mov     ax, 0xB800 
    mov     es, ax      ; Video Memory Address 0xB8000
    
    ;Y -> Y * 160
    mov     ax, word [ bp + 6 ]
    mov     si, 160
    mul     si 
    mov     di, ax 
    ;X -> X * 2
    mov     ax, word [ bp + 4 ]
    mov     si, 2
    mul     si
    add     di, ax 

    mov     si, word [ bp + 8 ]

.PRINT_LOOP:
    mov     cl, byte [ si ]
    cmp     cl, 0
    je      .PRINT_END 
    mov     byte [es: di], cl 
    
    add     si, 1
    add     di, 2

    jmp     .PRINT_LOOP 

.PRINT_END:
    pop     dx 
    pop     cx 
    pop     ax 
    pop     di 
    pop     si 
    pop     es
    pop     bp
    ret 


;===========================================;
; Data Section 
;===========================================;

; bootloader launch messages
MSG_BOOT_1:   db  '[SDos v0.1]', 0 
MSG_BOOT_2:   db  'Boot Loader Running', 0     
MSG_BOOT_3:   db  'SourceCode => http://github.com/errorcode4319/SD-Kernel', 0

; Image Loading Messages 
MSG_IMG_LOADING_START:      db  'OS Image Loading...', 0
MSG_IMG_LOADING_FAILED:     db  'DISK Error~!!', 0
MSG_IMG_LOADING_COMPLETE:   db  'Image Loading Complete!', 0

; Disk Read Start Offset 
DISK_NUM_SECTOR:    db  0x02
DISK_NUM_HEAD:      db  0x00 
DISK_NUM_TRACK:     db  0x00      


; Empty Spaces
times       510 - ( $ - $$ )  db  0x00 

db 0x55
db 0xAA     ; Boot Sector End => 0x55AA