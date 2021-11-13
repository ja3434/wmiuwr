	.file	"segv.c"
	.text
	.globl	p
	.bss
	.align 8
	.type	p, @object
	.size	p, 8
p:
	.zero	8
	.section	.rodata
.LC0:
	.string	"Segv handler! p: %p\n"
	.text
	.globl	segv_handler
	.type	segv_handler, @function
segv_handler:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	addq	$-128, %rsp
	movl	%edi, -116(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movq	p(%rip), %rdx
	leaq	-112(%rbp), %rax
	leaq	.LC0(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	sprintf@PLT
	movq	p(%rip), %rax
	testq	%rax, %rax
	jne	.L2
	movl	$8, %edi
	call	malloc@PLT
	movq	%rax, p(%rip)
.L2:
	leaq	-112(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movq	%rax, %rdx
	leaq	-112(%rbp), %rax
	movq	%rax, %rsi
	movl	$1, %edi
	call	write@PLT
	nop
	movq	-8(%rbp), %rax
	subq	%fs:40, %rax
	je	.L3
	call	__stack_chk_fail@PLT
.L3:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	segv_handler, .-segv_handler
	.globl	main
	.type	main, @function
main:
.LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	segv_handler(%rip), %rax
	movq	%rax, %rsi
	movl	$11, %edi
	call	signal@PLT
	movq	p(%rip), %rax
	movb	$1, (%rax)
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	main, .-main
	.ident	"GCC: (GNU) 11.1.0"
	.section	.note.GNU-stack,"",@progbits
