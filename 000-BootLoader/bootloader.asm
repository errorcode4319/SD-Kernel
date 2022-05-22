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

.RESET_DISK:
    ; call bios reset function 
    ; https://wiki.osdev.org/Real_Mode
    ; service 0 (ax), drive 0 (dl)
    mov     ax, 0
    mov     dl, 0
    int     0x13 
    ; Exception - Reset Drive Failed 
    jc      HANDLE_DISK_ERROR 


    mov     si, 0x1000 
    mov     es, si              ; 0x10000 - Image Copy Address 
    mov     bx, 0x0000

    mov     di, word [ TOTAL_SECTOR_COUNT ]

READ_DISK:
    cmp     di, 0
    je      READ_END
    sub     di, 0x01 

    ; call bios read function 
    ;service 2 (ah),
    mov     ah, 0x02 
    mov     al, 0x1             ; Read 1 Sector 
    mov     ch, byte [ DISK_NUM_TRACK ]
    mov     cl, byte [ DISK_NUM_SECTOR ]
    mov     dh, byte [ DISK_NUM_HEAD ]
    mov     dl, 0x00            ; drive 0
    int     0x13 
    ; Exception - Read Disk Failed 
    jc      HANDLE_DISK_ERROR


    add     si, 0x0020  ; 512byte == 1 sector 
    mov     es, si 

    mov     al, byte [ DISK_NUM_SECTOR ]
    add     al, 0x01 
    mov     byte [ DISK_NUM_SECTOR ], al 
    cmp     al, 19 
    jl      READ_DISK 

    xor     byte [ DISK_NUM_HEAD ], 0x01    ; Head Number Toggle
    mov     byte [ DISK_NUM_SECTOR ], 0x01  ; Sector Number to 1

    cmp     byte [ DISK_NUM_HEAD ], 0x00    ; If Head == 0 -> Read Track Done
    jne     READ_DISK 

    add     byte [ DISK_NUM_TRACK ], 0x01   
    jmp     READ_DISK 
    
READ_END:
    push    MSG_IMG_LOADING_COMPLETE 
    push    4
    push    20 
    call    PRINTLINE 
    add     sp, 6

    ;Start Loaded OS Image
    jmp     0x1000:0x0000 


HANDLE_DISK_ERROR:
    push    MSG_IMG_LOADING_FAILED
    push    4
    push    20 
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
MSG_BOOT_2:   db  'Boot Loader Running...', 0     
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