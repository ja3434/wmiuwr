400590 <switch_prob>:
400590: 48 83                       subq    $0x3c, %rsi         # rsi -= 0x3c
400594: 48 83 fe 0                  cmpq    $0x5,  %rsi         # if rsi > 0x5
400598: 77 29                       ja      *0x4005c3           # then jump to line 16
40059a: ff 24 f5 f8 06 40 00        jmpq    *0x4006f8(,%rsi,8)  # jump to 19 + rsi
4005a1: 48 8d 04 fd 00 00 00 00     lea     0x0(,%rdi,8),%rax   # rax := rdi * 8
4005a9: c3                          retq                        # return rax
4005aa: 48 89 f8                    movq    %rdi,%rax           # rax := rdi
4005ad: 48 c1 f8 03                 sarq    $0x3,%rax           # rax >>= 3 (arithmetic)
4005b1: c3                          retq                        # return rax
4005b2: 48 89 f8                    movq    %rdi,%rax           # rax := rdi
4005b5: 48 c1 e0 04                 shlq    $0x4,%rax           # rax <<= 4 (logic)
4005b9: 48 29 f8                    subq    %rdi,%rax           # rax -= rdi
4005bc: 48 89 c7                    movq    %rax,%rdi           # rdi := rax
4005bf: 48 0f af ff                 imulq   %rdi,%rdi           # rdi *= rdi
4005c3: 48 8d 47 4b                 leaq    0x4b(%rdi),%rax     # rax := 0x4b + rdi
4005c7: c3                          retq                        # return rax

0x4006f8: 0x4005a1  # line 6
0x400700: 0x4005a1  # line 6
0x400708: 0x4005b2  # line 11
0x400710: 0x4005c3  # line 16
0x400718: 0x4005aa  # line 8
0x400720: 0x4005bf  # line 15
