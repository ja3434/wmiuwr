        .global eval

        .text
eval:
        movq %rdi, %rax
        movq 16(%rsp), %rcx
        movq 24(%rsp), %rdx
        movq (%rdx), %rsi
        movq %rcx, %rdx
        imulq %rsi, %rdx
        movq %rdx, (%rdi)
        movq 8(%rsp), %rdx
        movq %rdx, %rdi
        subq %rsi, %rdi
        movq %rdi, 8(%rax)
        subq %rcx, %rdx
        movq %rdx, 16(%rax)
        ret