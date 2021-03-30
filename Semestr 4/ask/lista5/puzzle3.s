        .global puzzle3

        .text           
puzzle3:                                # rdi: n; rsi: d        
        movl    %edi, %edi              # zeruje 32 starsze bity rdi
        salq    $32, %rsi               # rsi <<= 32
        movl    $32, %edx               # edx := 32
        movl    $0x80000000, %ecx       # ecx := MIN_INT
        xorl    %eax, %eax              # eax := 0
.L3:    addq    %rdi, %rdi              # rdi *= 2
        movq    %rdi, %r8               # r8 := rdi 
        subq    %rsi, %r8               # r8 -= rsi
        js      .L2                     # if r8 < 0 then jump to L2
        orl     %ecx, %eax              # eax |= ecx
        movq    %r8, %rdi               # rdi := r8
.L2:    shrl    %ecx                    # ecx >>= 1
        decl    %edx                    # edx--
        jne     .L3                     # if (edx != 0) then jump to L3 
        ret
