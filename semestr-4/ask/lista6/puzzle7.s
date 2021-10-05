        .global puzzle7

        .text
puzzle7:
        movq %rsi, -40(%rsp)
        movq %rdx, -32(%rsp)
        movq %rcx, -24(%rsp)
        movq %r8, -16(%rsp)
        movq %r9, -8(%rsp)
        movl $8, -72(%rsp)
        leaq 8(%rsp), %rax
        movq %rax, -64(%rsp)
        leaq -48(%rsp), %rax
        movq %rax, -56(%rsp)
        movl $0, %eax
        jmp .L2
.L3:    movq -64(%rsp), %rdx
        leaq 8(%rdx), %rcx
        movq %rcx, -64(%rsp)
.L4:    addq (%rdx), %rax
.L2:    subq $1, %rdi
        js .L6
        cmpl $47, -72(%rsp)
        ja .L3
        movl -72(%rsp), %edx
        addq -56(%rsp), %rdx
        addl $8, -72(%rsp)
        jmp .L4
.L6:    ret
