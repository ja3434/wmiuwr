        .globl  puzzle
	
	.text
puzzle:
        push %rbp               # adres koncu ramki, callee-saved
        xorl %eax, %eax         # zeruje %rax
        mov %rsi, %rbp          # rbp := rsi, czyli rbp := p  
        push %rbx               # rbx na stos, callee-saved
        mov %rdi, %rbx          # rbx := rdi, czyli rbx := n
        sub $24, %rsp           # rsp -= 24, czyli przesun rsp o 3 bajty w dół
        test %rdi, %rdi         # rdi == 0?, czyli n == 0?
        jle .L1                 # jesli tak, skocz do L1
        lea 8(%rsp), %rsi       # w p.w. rsi := rsp + 8
        lea (%rdi,%rdi), %rdi   # rdi := 2*rdi
        call puzzle             # wywolanie rekurencyjne puzzle
        add 8(%rsp), %rax       # rax := rax + *(rsp + 8)
        add %rax, %rbx          # rbx := rbx + rax
.L1:    mov %rbx, (%rbp)        # *rbp := rbx, czyli *p := rbx
        add $24, %rsp           # rsp := rsp + 24 (przesun adres stacka o 3 bajty)
        pop %rbx                # przywracamy rbx
        pop %rbp                # przywracamy rbp
    ret
