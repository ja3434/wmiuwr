```c=
       0:   55 	                                pushq   %rbp
       1:   48 89 e5 	                        movq    %rsp, %rbp
       4:   48 83 ec 10 	                    subq    $16, %rsp         
       8:   48 89 e0 	                        movq    %rsp, %rax        #wsk stosu to rax
       b:   48 8d 0c fd 0f 00 00 00 	        leaq    15(,%rdi,8), %rcx #n * rozmiar longa + 15 do rcx (+15 to kwestia wyrównania/sufit)
      13:   48 83 e1 f0 	                    andq    $-16, %rcx        #zerujemy ostatnie 4 bity
      17:   48 29 c8 	                        subq    %rcx, %rax        #oblicz nowy wskaźnik stosu
      1a:   48 89 c4 	                        movq    %rax, %rsp        #nowy wskaźnik wrzuć do rsp
      1d:   48 8d 4d f8 	                    leaq    -8(%rbp), %rcx
      21:   48 89 4c f8 f8 	                    movq    %rcx, -8(%rax,%rdi,8)
      26:   48 c7 45 f8 00 00 00 00 	        movq    $0, -8(%rbp)
      2e:   48 85 ff 	                        testq   %rdi, %rdi
      31:   7e 1d 	                            jle	29 <_aframe+0x50>
      33:   31 c9 	                            xorl    %ecx, %ecx
      35:   66 2e 0f 1f 84 00 00 00 00 00       nopw    %cs:(%rax,%rax)
      3f:   90                                  nop
      40:   48 89 14 c8                         movq    %rdx, (%rax,%rcx,8)
      44:   48 ff c1                            incq    %rcx
      47:   48 39 cf                            cmpq    %rcx, %rdi
      4a:   75 f4                               jne -12 <_aframe+0x40>
      4c:   48 89 7d f8                         movq    %rdi, -8(%rbp)
      50:   48 8b 04 f0                         movq    (%rax,%rsi,8), %rax
      54:   48 8b 00                            movq    (%rax), %rax
      57:   48 89 ec                            movq    %rbp, %rsp            #powrót do poprzedniej ramki
      5a:   5d                                  popq    %rbp                  #wrzucenie do rbp poprzedniego adresu
      5b:   c3                                  retq    
```