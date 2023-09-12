org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ;Macro for ascii endline
start:
    jmp main
;
; Prints a string to the screen
; Inputs:
;       - ds:si points to string
;
puts:
    ; save registers we modify
    push si
    push ax

.loop:
    lodsb               ;Loads next char from SI and increments it
    or al, al           ;Bitwirse or to check for null. Sets flags if result is zero
    jz .done

    mov ah, 0x0e        ;Set interupt to TTY
    mov bh, 0           ;Set page number to zero
    int 0x10            ;Call bios video interupt

    jmp .loop

.done:
    pop ax
    pop si
    ret
main:
    ; setup data segments
    mov ax, 0           ;Can't write to ds/es directly 
    mov ds, ax
    mov es, ax

    ;setup stack
    mov ss, ax
    mov sp, 0x7C00      ;Stack grows downward so set it to the start of the operating system

    ;print name
    mov si, msg_name
    call puts

    hlt
.halt:
    jmp .halt


msg_name: db 'Hello, my name is Jacob', ENDL, 0
times 510-($-$$) db 0
dw 0AA55h