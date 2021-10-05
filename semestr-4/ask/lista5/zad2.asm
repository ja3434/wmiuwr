puzzle2:
        movq    %rdi, %rax      ; rax := rdi
.L3:    movb    (%rax), %r9b    ; r9b := *rax
        leaq    1(%rax), %r8    ; r8  := rax + 1
        movq    %rsi, %rdx    ; rdx := *rsi
.L2:    movb    (%rdx), %cl     ; cl := *rdx
        incq    %rdx            ; rdx++
        testb   %cl, %cl        ; if (cl == 0)
        je      .L4             ; then jump to L4        
        cmpb    %cl, %r9b       ; if (cl != r9b)
        jne     .L2             ; then jump to L2
        movq    %r8, %rax       ; rax := r8
        jmp     .L3             ; jump to L3
.L4     subq    %rdi, %rax      ; rax -= rdi
        ret