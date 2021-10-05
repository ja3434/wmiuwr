puzzle: testl   %esi, %esi
        je      .L4             ; jesli esi == 0, skocz do L4
        xorl    %edx, %edx      ; edx := 0
        xorl    %eax, %eax      ; eax := 0
.L3:    movl    %edi, %ecx      ; ecx := edi
        andl    $1,   %ecx      ; ecx &= 1
        addl    %ecx, %eax      ; eax += eax
        sarq    %rdi            ; rdi >>= 1
        incl    %edx,           ; edx++
        cmpl    %edx, %esi      ; edx - esi != 0? <=> edx != esi
        jne     .L3             ; jesli tak, skocz do L3
        ret 
.L4     movl    %esi, %eax      ; return esi
        ret

