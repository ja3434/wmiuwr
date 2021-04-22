        .global wrap

        .text
wrap:
        subq $72, %rsp
        movq %rdx, (%rsp)
        movq %rsp, %rdx
        leaq 8(%rsp), %rax
        pushq %rdx
        pushq %rsi
        pushq %rdi
        movq %rax, %rdi
        call eval
        movq 40(%rsp), %rax
        addq 32(%rsp), %rax
        imulq 48(%rsp), %rax
        addq $96, %rsp
        ret