# rdi - adres zwracanej struktury (niejawnie)
# rsi - *a
# rdx - n

    .global puzzle8

    .text
puzzle8:
        movq %rdx, %r11             # r11 := n
        xorl %r10d, %r10d           # r10 := 0
        xorl %eax, %eax             # rax := 0
        movq $LONG_MIN, %r8         # r8 := 0x800...
        movq $LONG_MAX, %r9         # r9 := 0x7ff...
.L2:    cmpq %r11, %r10             # if n <= r10
        jge .L5                     # then jump to L5, else
        movq (%rsi,%r10,8), %rcx    # rcx := a[r10]
        cmpq %rcx, %r9              # if a[r10] < r9
        cmovg %rcx, %r9             # then r9 = a[r10]
        cmpq %rcx, %r8              # if a[r10] > r8
        cmovl %rcx, %r8             # then r8 = a[r10]
        addq %rcx, %rax             # rax += a[r10]
        incq %r10                   # r10++
        jmp .L2
.L5:    cqto                        # jeśli rax < 0 to niech rdx zaplonie
        movq %r9, (%rdi)            # rdi->0 := r9
        idivq %r11                  # podziel rax przez r11, efektywnie rax /= r11
        movq %r8, 8(%rdi)           # rdi->8 := r8
        movq %rax, 16(%rdi)         # rdi->16 := rax
        movq %rdi, %rax             # rax := rdi
    ret