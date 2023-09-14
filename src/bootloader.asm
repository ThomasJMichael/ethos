org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ;Macro for ascii endline
start:
    jmp main

; Initialize the serial port
init_serial:
    mov dx, 0x03F8      ; COM1 Port Address
    mov al, 0x00
    out dx, al          ; Disable interrupts
    inc dx              ; Increment dx register to point to Line Control Register
    mov al, 0x80
    out dx, al          ; Enable DLAB (Set baud rate divisor)
    dec dx              ; W/ DLAB set to 1 points to Divisor Latch Low Byte (for setting baud rate)
    mov al, 0x03
    out dx, al          ; Set divisor to 3 (lo byte) 38400 baud
    inc dx              ; With DLAB set to 1 points to Divisor Latch High Byte (for setting baud rate)
    mov al, 0x00
    out dx, al          ; Sets hi byte
    dec dx              ; Decrement dx to point back to LCR
    mov al, 0x03        
    out dx, al          ; 8 bits, no parity, one stop bit
    inc dx              ; Increment dx to point to the FIFO Counter Register
    mov al, 0xC7
    out dx, al          ; 0x01 Enable FIFOs, 0x02 clear recieve FIFO, 0x04 Clear transmit FIFO
                        ; Set trigger level to 14 bytes (UART will generate an interupt when FIFO has 14 bytes)
    inc dx              ; Points to Modem Control Register (MCR)
    mov al, 0x0B
    out dx, al          ; IRQs enabled, RTS, DSR set
                        ; 0x01 Enable data terminal (DTR), 0x02 Enable request to send (RTS)
                        ; 0x08 Enable auxiliary output 2. (Often used to enable interupts on some UARTS)

    ret

; write_serial
; Prints a string to the COM1 port
; Inputs:
;       - ds:si points to string
write_serial:
    push si
    push ax

    mov dx, 0x3F8       ; COM1 Port Address
.write_loop:
    ;in al, dx
    ;test al, 0x20       ; Check if transmitter holding register is empty
    ;jz .write_loop
    
    lodsb
    or al, al
    jz .done_write_serial

    out dx, al
    jmp .write_loop

.done_write_serial:
    pop ax
    pop si
    ret

test_serial:
    mov dx, 0x03F8      ; COM1 port address
.wait_ready:
    in al, dx
    test al, 0x20       ; Check if transmitter holding register is empty
    mov si, msg_name
    call puts
    jz .wait_ready
    mov al, 'A'
    out dx, al          ; Send 'A' to the serial port
    ret

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

    mov si, msg_name
    call init_serial
    call write_serial

.halt:
    jmp .halt


msg_name: db 'Hello, my name is Jacob', ENDL, 0
times 510-($-$$) db 0
dw 0AA55h
