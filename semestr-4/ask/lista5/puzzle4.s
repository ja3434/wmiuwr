.global puzzle4

.text
puzzle4:                                # argumenty: rdi - long*, rsi - long, rdx - uint64, rcx - uint64 
        movq    %rcx, %rax              # rax := rcx
        subq    %rdx, %rax              # rax -= rdx
        shrq    %rax                    # rax >>= 1;    // ale logiczne!
        addq    %rdx, %rax              # rax += rdx;
        cmpq    %rdx, %rcx              # if rcx < rdx
        jb      .L5                     # then jump to L5
        movq    (%rdi,%rax,8), %r8      # r8 = *(rdi + 8*rax)
        cmpq    %rsi, %r8               # if rsi == r8
        je      .L10                    # then jump to L10
        cmpq    %rsi, %r8               # if (r8 - rsi < 0) <=> r8 < rsi
        jg      .L11                    # then jump to L11        
        leaq    1(%rax), %rdx           # rdx := rax + 1
        call    puzzle4                 # call recursively puzzle4
.L10:   ret                             # return rax
.L11:   leaq    -1(%rax), %rcx          # rcx := rax - 1
        call    puzzle4                 # call recursively puzzle4
        ret                             # return rax
.L5:    movl    $-1, %eax               # eax := -1
        ret                             # return rax
        
