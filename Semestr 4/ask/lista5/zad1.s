	.file	"zad1.c"
	.text
	.p2align 4
	.globl	puzzle
	.type	puzzle, @function
puzzle:
.LFB23:
	.cfi_startproc
	endbr64
	xorl	%r8d, %r8d
	testl	%esi, %esi
	je	.L1
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L3:
	movl	%edi, %edx
	addl	$1, %eax
	sarq	%rdi
	andl	$1, %edx
	addl	%edx, %r8d
	cmpl	%esi, %eax
	jne	.L3
.L1:
	movl	%r8d, %eax
	ret
	.cfi_endproc
.LFE23:
	.size	puzzle, .-puzzle
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%ld%u"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB24:
	.cfi_startproc
	endbr64
	subq	$40, %rsp
	.cfi_def_cfa_offset 48
	leaq	.LC0(%rip), %rdi
	movq	%fs:40, %rax
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	leaq	12(%rsp), %rdx
	leaq	16(%rsp), %rsi
	call	__isoc99_scanf@PLT
	movl	12(%rsp), %ecx
	movq	16(%rsp), %rax
	xorl	%r8d, %r8d
	testl	%ecx, %ecx
	je	.L8
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.L10:
	movl	%eax, %esi
	addl	$1, %edx
	sarq	%rax
	andl	$1, %esi
	addl	%esi, %r8d
	cmpl	%ecx, %edx
	jne	.L10
.L8:
	movq	24(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L16
	movl	%r8d, %eax
	addq	$40, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L16:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE24:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
