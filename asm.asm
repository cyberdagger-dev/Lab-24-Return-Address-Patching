[BITS 64]

DEFAULT REL

GLOBAL Patch

section .text

; Patch( PVOID Function, SIZE_T nArgs, PVOID r12_gadget, PVOID argN, ... )
Patch:
    ; Some space to work with
    sub rsp, 0x100

    ; Store nonvol regs
    mov [ rsp + 0x8  ], rsi
    mov [ rsp + 0x10 ], rdi
    mov [ rsp + 0x18 ], r12

    ; R10: Function to call
    ; R12: Address of handler
    mov r10, rcx
    lea r12, Fixup

    ; Some more space to work with
    sub rsp, 0x200

    ; Place the gadget into our return address
    mov [rsp], r8

    ; If no arguments, just make the call
    cmp rdx, 0
    je Do_Call

    ; Back these up, we'll need this later
    ; R11: nArgs 
    mov r11, rdx

    ; Move the arguments. Everything to be shifted down 3
    ; It does not matter if we move args to rcx/rdx/r8/r9 if a function doesn't use them, so move them all just in case
    cmp rdx, 4
    mov rcx, r9
    mov rdx, [ rsp + 0x300 + 0x28 ] 
    mov r8,  [ rsp + 0x300 + 0x30 ] 
    mov r9,  [ rsp + 0x300 + 0x38 ] 
    jle Do_Call

    ; movsq: move QWORD -- RSI -> RDI
    ; rep: repeats RCX amount of times
    ; additional 0x18 offset because technically the 4th arg was in the 7th slot
    mov rax, rcx
    mov rcx, r11
    sub rcx, 0x4
    lea rsi, [ rsp + 0x28 + 0x18 + 0x300 ]
    lea rdi, [ rsp + 0x28 ]
    rep movsq

    ; Restore original rcx for patched call
    mov rcx, rax

Do_Call:

    ; Jump to the function we want to call
    jmp r10


Fixup:

    ; Restore nonvol regs and stack frame
    mov rsi, [ rsp + 0x200 + 0x8  ]
    mov rdi, [ rsp + 0x200 + 0x10 ]
    mov r12, [ rsp + 0x200 + 0x18 ]
    add rsp, 0x300

    ret