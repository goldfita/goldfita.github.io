	.file	"gcctest.c"
	.section	".rodata"
	.align 8
.LLC0:
	.asciz	"%d %d\n"
	.section	".text"
	.align 4
	.global inc
	.type	inc,#function
	.proc	04
inc:
	!#PROLOGUE# 0
	save	%sp, -328, %sp
	!#PROLOGUE# 1
	st	%i0, [%fp+68]
	mov	5, %o0
	st	%o0, [%fp-216]
	mov	40, %o0
	call	malloc, 0
	 nop
	st	%o0, [%fp-232]
	mov	24, %o0
	sub	%sp, %o0, %sp
	add	%sp, 92, %o0
	add	%o0, 7, %o0
	srl	%o0, 3, %o0
	sll	%o0, 3, %o0
	st	%o0, [%fp-228]
	ldd	[%fp-232], %o0
	std	%o0, [%fp-224]
	mov	12, %o1
	ld	[%fp-224], %o0
	add	%o1, %o0, %o1
	mov	88, %o0
	st	%o0, [%o1]
	mov	20, %o1
	ld	[%fp-224], %o0
	add	%o1, %o0, %o1
	mov	87, %o0
	st	%o0, [%o1]
	ld	[%fp-220], %o1
	mov	86, %o0
	st	%o0, [%o1]
	ld	[%fp-224], %o0
	call	free, 0
	 nop
	ld	[%fp-220], %o1
	sethi	%hi(.LLC0), %o0
	or	%o0, %lo(.LLC0), %o0
	ld	[%o1], %o1
	ld	[%fp-256], %o2
	call	printf, 0
	 nop
	ld	[%fp+68], %o0
	add	%o0, 1, %o0
	mov	%o0, %i0
	nop
	ret
	restore
.LLfe1:
	.size	inc,.LLfe1-inc
	.align 4
	.global main
	.type	main,#function
	.proc	04
main:
	!#PROLOGUE# 0
	save	%sp, -496, %sp
	!#PROLOGUE# 1
	mov	99, %o0
	st	%o0, [%fp-20]
	mov	102, %o0
	st	%o0, [%fp-24]
	mov	101, %o0
	st	%o0, [%fp-28]
	mov	102, %o0
	st	%o0, [%fp-236]
	mov	8, %o0
	st	%o0, [%fp-232]
	ld	[%fp-28], %o0
	add	%o0, 1, %o0
	call	inc, 0
	 nop
	mov	131, %o0
	st	%o0, [%fp-236]
	mov	123, %o0
	st	%o0, [%fp-28]
	mov	321, %o0
	st	%o0, [%fp-240]
	mov	7, %o0
	st	%o0, [%fp-232]
	ld	[%fp-232], %o0
	cmp	%o0, 6
	bne	.LL3
	nop
	st	%g0, [%fp-400]
	mov	0, %o0
	call	inc, 0
	 nop
.LL3:
	ld	[%fp-24], %o0
	add	%o0, 1, %o0
	call	inc, 0
	 nop
	ld	[%fp-20], %o0
	call	inc, 0
	 nop
	mov	%o0, %i0
	nop
	ret
	restore
.LLfe2:
	.size	main,.LLfe2-main
	.ident	"GCC: (GNU) 3.2.1"
