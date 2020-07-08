	.file	"Help Add-In.c"
	.intel_syntax noprefix
.lcomm MFF$,88,32
.lcomm VFBEDITORLIB$,8,8
.lcomm VFBEDITORAPP$,8,8
.lcomm MAINFORM$,8,8
.lcomm TBSTANDARD$,8,8
.lcomm TBHELP$,8,8
.lcomm TBHELPSEPARATOR$,8,8
.lcomm MNUSERVICE$,8,8
.lcomm MNUHELP$,8,8
.lcomm MNUHELPSEPARATOR$,8,8
.lcomm S$,8,8
	.text
	.globl	DllMain
	.def	DllMain;	.scl	2;	.type	32;	.endef
DllMain:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR 16[rbp], rcx
	mov	QWORD PTR 24[rbp], rdx
	mov	QWORD PTR 32[rbp], r8
	mov	QWORD PTR -8[rbp], 0
.L2:
	mov	QWORD PTR -8[rbp], 1
	cmp	QWORD PTR 24[rbp], 1
	jne	.L7
	mov	edx, 0
	mov	ecx, 0
	call	tmp$2
	jmp	.L5
.L4:
.L7:
	nop
.L5:
	mov	rax, QWORD PTR -8[rbp]
	leave
	ret
	.section .rdata,"dr"
	.align 2
.LC0:
	.ascii "M\0s\0g\0B\0o\0x\0\0\0"
	.align 2
.LC1:
	.ascii "R\0e\0a\0d\0P\0r\0o\0p\0e\0r\0t\0y\0\0\0"
	.align 8
.LC2:
	.ascii "A\0p\0p\0l\0i\0c\0a\0t\0i\0o\0n\0M\0a\0i\0n\0F\0o\0r\0m\0\0\0"
	.align 2
.LC3:
	.ascii "C\0o\0n\0t\0r\0o\0l\0B\0y\0N\0a\0m\0e\0\0\0"
	.align 8
.LC4:
	.ascii "T\0o\0o\0l\0B\0a\0r\0A\0d\0d\0B\0u\0t\0t\0o\0n\0W\0i\0t\0h\0I\0m\0a\0g\0e\0K\0e\0y\0\0\0"
	.align 8
.LC5:
	.ascii "T\0o\0o\0l\0B\0a\0r\0R\0e\0m\0o\0v\0e\0B\0u\0t\0t\0o\0n\0\0\0"
	.align 8
.LC6:
	.ascii "T\0o\0o\0l\0B\0a\0r\0I\0n\0d\0e\0x\0O\0f\0B\0u\0t\0t\0o\0n\0\0\0"
	.align 2
.LC7:
	.ascii "M\0e\0n\0u\0I\0t\0e\0m\0A\0d\0d\0\0\0"
	.align 2
.LC8:
	.ascii "M\0e\0n\0u\0I\0t\0e\0m\0R\0e\0m\0o\0v\0e\0\0\0"
	.align 2
.LC9:
	.ascii "M\0e\0n\0u\0F\0i\0n\0d\0B\0y\0N\0a\0m\0e\0\0\0"
	.align 2
.LC10:
	.ascii "O\0b\0j\0e\0c\0t\0D\0e\0l\0e\0t\0e\0\0\0"
	.text
	.globl	LOADMFFPROCS
	.def	LOADMFFPROCS;	.scl	2;	.type	32;	.endef
LOADMFFPROCS:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 560
.L9:
	lea	rax, -208[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -208[rbp]
	mov	r9d, 0
	lea	r8, .LC0[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -8[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -208[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -16[rbp], rax
	lea	rax, MFF$[rip]
	mov	rdx, QWORD PTR -16[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -208[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -240[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -240[rbp]
	mov	r9d, 0
	lea	r8, .LC1[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -24[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -240[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -32[rbp], rax
	lea	rax, MFF$[rip+8]
	mov	rdx, QWORD PTR -32[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -240[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -272[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -272[rbp]
	mov	r9d, 0
	lea	r8, .LC2[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -40[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -272[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -48[rbp], rax
	lea	rax, MFF$[rip+16]
	mov	rdx, QWORD PTR -48[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -272[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -304[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -304[rbp]
	mov	r9d, 0
	lea	r8, .LC3[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -56[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -304[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -64[rbp], rax
	lea	rax, MFF$[rip+24]
	mov	rdx, QWORD PTR -64[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -304[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -336[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -336[rbp]
	mov	r9d, 0
	lea	r8, .LC4[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -72[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -336[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -80[rbp], rax
	lea	rax, MFF$[rip+32]
	mov	rdx, QWORD PTR -80[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -336[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -368[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -368[rbp]
	mov	r9d, 0
	lea	r8, .LC5[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -88[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -368[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -96[rbp], rax
	lea	rax, MFF$[rip+40]
	mov	rdx, QWORD PTR -96[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -368[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -400[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -400[rbp]
	mov	r9d, 0
	lea	r8, .LC6[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -104[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -400[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -112[rbp], rax
	lea	rax, MFF$[rip+48]
	mov	rdx, QWORD PTR -112[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -400[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -432[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -432[rbp]
	mov	r9d, 0
	lea	r8, .LC7[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -120[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -432[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -128[rbp], rax
	lea	rax, MFF$[rip+56]
	mov	rdx, QWORD PTR -128[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -432[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -464[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -464[rbp]
	mov	r9d, 0
	lea	r8, .LC8[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -136[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -464[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -144[rbp], rax
	lea	rax, MFF$[rip+64]
	mov	rdx, QWORD PTR -144[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -464[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -496[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -496[rbp]
	mov	r9d, 0
	lea	r8, .LC9[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -152[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -496[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -160[rbp], rax
	lea	rax, MFF$[rip+72]
	mov	rdx, QWORD PTR -160[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -496[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -528[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -528[rbp]
	mov	r9d, 0
	lea	r8, .LC10[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -168[rbp], rax
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	lea	rdx, -528[rbp]
	mov	rcx, rax
	call	fb_DylibSymbol
	mov	QWORD PTR -176[rbp], rax
	lea	rax, MFF$[rip+80]
	mov	rdx, QWORD PTR -176[rbp]
	mov	QWORD PTR [rax], rdx
	lea	rax, -528[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	nop
	leave
	ret
.L10:
	.section .rdata,"dr"
	.align 2
.LC11:
	.ascii "\\\0\0\0"
	.align 2
.LC12:
	.ascii "/\0\0\0"
	.align 2
.LC13:
	.ascii "\0\0"
	.text
	.globl	GETFOLDERPATH
	.def	GETFOLDERPATH;	.scl	2;	.type	32;	.endef
GETFOLDERPATH:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 112
	mov	QWORD PTR 16[rbp], rcx
	mov	QWORD PTR -80[rbp], 0
.L12:
	mov	r8, -1
	lea	rdx, .LC11[rip]
	mov	rcx, QWORD PTR 16[rbp]
	call	fb_WstrInstrRev
	mov	QWORD PTR -24[rbp], rax
	mov	rax, QWORD PTR -24[rbp]
	mov	DWORD PTR -12[rbp], eax
	mov	r8, -1
	lea	rdx, .LC12[rip]
	mov	rcx, QWORD PTR 16[rbp]
	call	fb_WstrInstrRev
	mov	QWORD PTR -32[rbp], rax
	mov	rax, QWORD PTR -32[rbp]
	mov	DWORD PTR -36[rbp], eax
	cmp	DWORD PTR -12[rbp], 0
	je	.L25
	mov	eax, DWORD PTR -36[rbp]
	cmp	eax, DWORD PTR -12[rbp]
	setg	al
	movzx	eax, al
	neg	eax
	cdqe
	mov	QWORD PTR -8[rbp], rax
	jmp	.L15
.L25:
	nop
.L14:
	mov	QWORD PTR -8[rbp], -1
.L15:
	cmp	QWORD PTR -8[rbp], 0
	je	.L26
	mov	eax, DWORD PTR -36[rbp]
	mov	DWORD PTR -12[rbp], eax
	jmp	.L17
.L26:
	nop
.L17:
	cmp	DWORD PTR -12[rbp], 0
	jle	.L27
	mov	eax, DWORD PTR -12[rbp]
	cdqe
	add	rax, rax
	mov	rdx, rax
	mov	rax, QWORD PTR S$[rip]
	mov	rcx, rax
	call	realloc
	mov	QWORD PTR -48[rbp], rax
	mov	rax, QWORD PTR -48[rbp]
	mov	QWORD PTR S$[rip], rax
	mov	eax, DWORD PTR -12[rbp]
	cdqe
	mov	rdx, rax
	mov	rcx, QWORD PTR 16[rbp]
	call	fb_WstrLeft
	mov	QWORD PTR -56[rbp], rax
	mov	rax, QWORD PTR -56[rbp]
	mov	QWORD PTR -64[rbp], rax
	mov	rax, QWORD PTR S$[rip]
	mov	rdx, QWORD PTR -64[rbp]
	mov	r8, rdx
	mov	edx, 0
	mov	rcx, rax
	call	fb_WstrAssign
	mov	QWORD PTR -72[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	mov	rcx, rax
	call	fb_WstrDelete
	mov	rax, QWORD PTR S$[rip]
	mov	QWORD PTR -80[rbp], rax
	jmp	.L20
.L19:
.L27:
	nop
.L21:
	lea	rax, .LC13[rip]
	mov	QWORD PTR -80[rbp], rax
	nop
.L20:
	mov	rax, QWORD PTR -80[rbp]
	leave
	ret
	.section .rdata,"dr"
	.align 2
.LC14:
	.ascii "H\0e\0l\0p\0\0\0"
	.text
	.globl	ONHELPBUTTONCLICK
	.def	ONHELPBUTTONCLICK;	.scl	2;	.type	32;	.endef
ONHELPBUTTONCLICK:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR 16[rbp], rcx
.L29:
	lea	rax, MFF$[rip]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L34
	lea	rax, MFF$[rip]
	mov	rax, QWORD PTR [rax]
	mov	r9d, 1
	mov	r8d, 0
	lea	rdx, .LC13[rip]
	lea	rcx, .LC14[rip]
	call	rax
	jmp	.L33
.L31:
.L32:
.L34:
	nop
.L33:
	nop
	leave
	ret
	.section .rdata,"dr"
	.align 8
.LC15:
	.ascii "/\0M\0y\0F\0b\0F\0r\0a\0m\0e\0w\0o\0r\0k\0/\0m\0f\0f\0"
	.ascii "6\0"
	.ascii "4\0.\0d\0l\0l\0\0\0"
	.align 2
.LC16:
	.ascii "S\0t\0a\0n\0d\0a\0r\0d\0\0\0"
	.align 2
.LC17:
	.ascii "H\0e\0l\0p\0S\0e\0p\0a\0r\0a\0t\0o\0r\0\0\0"
	.align 2
.LC18:
	.ascii "M\0e\0n\0u\0\0\0"
	.align 2
.LC19:
	.ascii "S\0e\0r\0v\0i\0c\0e\0\0\0"
	.align 2
.LC20:
	.ascii "-\0\0\0"
	.align 2
.LC21:
	.ascii "H\0e\0l\0p\0 \0A\0d\0d\0-\0I\0n\0\0\0"
	.text
	.globl	OnConnection
	.def	OnConnection;	.scl	2;	.type	32;	.endef
OnConnection:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 400
	mov	QWORD PTR 16[rbp], rcx
	mov	QWORD PTR 24[rbp], rdx
.L36:
	mov	rax, QWORD PTR 16[rbp]
	mov	QWORD PTR VFBEDITORAPP$[rip], rax
	lea	rax, -192[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	mov	rax, QWORD PTR 24[rbp]
	mov	rcx, rax
	call	GETFOLDERPATH
	mov	QWORD PTR -32[rbp], rax
	mov	rax, QWORD PTR -32[rbp]
	lea	rdx, .LC15[rip]
	mov	rcx, rax
	call	fb_WstrConcat
	mov	QWORD PTR -40[rbp], rax
	mov	rax, QWORD PTR -40[rbp]
	mov	QWORD PTR -48[rbp], rax
	mov	rdx, QWORD PTR -48[rbp]
	lea	rax, -192[rbp]
	mov	r9d, 0
	mov	r8, rdx
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -56[rbp], rax
	lea	rax, -192[rbp]
	mov	rcx, rax
	call	fb_DylibLoad
	mov	QWORD PTR -64[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	mov	QWORD PTR VFBEDITORLIB$[rip], rax
	mov	rax, QWORD PTR -48[rbp]
	mov	rcx, rax
	call	fb_WstrDelete
	lea	rax, -192[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	mov	rax, QWORD PTR S$[rip]
	test	rax, rax
	je	.L72
	mov	rax, QWORD PTR S$[rip]
	mov	rcx, rax
	call	free
	jmp	.L38
.L72:
	nop
.L38:
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	test	rax, rax
	je	.L73
	nop
.L40:
	call	LOADMFFPROCS
	lea	rax, MFF$[rip+16]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L74
	lea	rax, MFF$[rip+16]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR 16[rbp]
	call	rax
	mov	QWORD PTR -72[rbp], rax
	mov	rax, QWORD PTR -72[rbp]
	mov	QWORD PTR MAINFORM$[rip], rax
	mov	rax, QWORD PTR MAINFORM$[rip]
	test	rax, rax
	je	.L75
	lea	rax, MFF$[rip+24]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L76
	lea	rax, -224[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -224[rbp]
	mov	r9d, 0
	lea	r8, .LC16[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -80[rbp], rax
	lea	rax, MFF$[rip+24]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR MAINFORM$[rip]
	lea	rdx, -224[rbp]
	call	rax
	mov	QWORD PTR -88[rbp], rax
	mov	rax, QWORD PTR -88[rbp]
	mov	QWORD PTR TBSTANDARD$[rip], rax
	lea	rax, -224[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	mov	rax, QWORD PTR TBSTANDARD$[rip]
	test	rax, rax
	je	.L77
	lea	rax, MFF$[rip+32]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	setne	al
	movzx	eax, al
	neg	eax
	cdqe
	mov	QWORD PTR -16[rbp], rax
	jmp	.L48
.L77:
	nop
.L47:
	mov	QWORD PTR -16[rbp], 0
.L48:
	cmp	QWORD PTR -16[rbp], 0
	je	.L78
	lea	rax, MFF$[rip+32]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR TBSTANDARD$[rip]
	mov	QWORD PTR 72[rsp], 4
	mov	DWORD PTR 64[rsp], 0
	lea	rdx, .LC13[rip]
	mov	QWORD PTR 56[rsp], rdx
	lea	rdx, .LC13[rip]
	mov	QWORD PTR 48[rsp], rdx
	lea	rdx, .LC13[rip]
	mov	QWORD PTR 40[rsp], rdx
	mov	QWORD PTR 32[rsp], 0
	mov	r9, -1
	lea	r8, .LC17[rip]
	mov	edx, 1
	call	rax
	mov	QWORD PTR -96[rbp], rax
	mov	rax, QWORD PTR -96[rbp]
	mov	QWORD PTR TBHELPSEPARATOR$[rip], rax
	lea	rax, MFF$[rip+32]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR TBSTANDARD$[rip]
	mov	QWORD PTR 72[rsp], 4
	mov	DWORD PTR 64[rsp], 1
	lea	rdx, .LC14[rip]
	mov	QWORD PTR 56[rsp], rdx
	lea	rdx, .LC13[rip]
	mov	QWORD PTR 48[rsp], rdx
	lea	rdx, .LC14[rip]
	mov	QWORD PTR 40[rsp], rdx
	lea	rdx, ONHELPBUTTONCLICK[rip]
	mov	QWORD PTR 32[rsp], rdx
	mov	r9, -1
	lea	r8, .LC14[rip]
	mov	edx, 16
	call	rax
	mov	QWORD PTR -104[rbp], rax
	mov	rax, QWORD PTR -104[rbp]
	mov	QWORD PTR TBHELP$[rip], rax
	jmp	.L52
.L50:
.L51:
.L45:
.L76:
	nop
	jmp	.L52
.L78:
	nop
.L52:
	lea	rax, MFF$[rip+8]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L79
	lea	rax, MFF$[rip+72]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	setne	al
	movzx	eax, al
	neg	eax
	cdqe
	mov	QWORD PTR -8[rbp], rax
	jmp	.L55
.L79:
	nop
.L54:
	mov	QWORD PTR -8[rbp], 0
.L55:
	cmp	QWORD PTR -8[rbp], 0
	je	.L80
	lea	rax, -256[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -256[rbp]
	mov	r9d, 0
	lea	r8, .LC18[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -112[rbp], rax
	lea	rax, MFF$[rip+8]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR MAINFORM$[rip]
	lea	rdx, -256[rbp]
	call	rax
	mov	QWORD PTR -120[rbp], rax
	mov	rax, QWORD PTR -120[rbp]
	mov	QWORD PTR -128[rbp], rax
	lea	rax, -256[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, MFF$[rip+72]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR -128[rbp]
	lea	rdx, .LC19[rip]
	call	rax
	mov	QWORD PTR -136[rbp], rax
	mov	rax, QWORD PTR -136[rbp]
	mov	QWORD PTR MNUSERVICE$[rip], rax
	mov	rax, QWORD PTR MNUSERVICE$[rip]
	test	rax, rax
	je	.L81
	lea	rax, MFF$[rip+56]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	setne	al
	movzx	eax, al
	neg	eax
	cdqe
	mov	QWORD PTR -24[rbp], rax
	jmp	.L59
.L81:
	nop
.L58:
	mov	QWORD PTR -24[rbp], 0
.L59:
	cmp	QWORD PTR -24[rbp], 0
	je	.L82
	lea	rax, -288[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -288[rbp]
	mov	r9d, 0
	lea	r8, .LC13[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -144[rbp], rax
	lea	rax, MFF$[rip+56]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR MNUSERVICE$[rip]
	lea	rdx, -288[rbp]
	mov	QWORD PTR 40[rsp], 1
	mov	QWORD PTR 32[rsp], 0
	mov	r9, rdx
	lea	r8, .LC13[rip]
	lea	rdx, .LC20[rip]
	call	rax
	mov	QWORD PTR -152[rbp], rax
	mov	rax, QWORD PTR -152[rbp]
	mov	QWORD PTR MNUHELPSEPARATOR$[rip], rax
	lea	rax, -288[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	lea	rax, -320[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	QWORD PTR 16[rax], 0
	lea	rax, -320[rbp]
	mov	r9d, 0
	lea	r8, .LC13[rip]
	mov	rdx, -1
	mov	rcx, rax
	call	fb_WstrAssignToA
	mov	QWORD PTR -160[rbp], rax
	lea	rax, MFF$[rip+56]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR MNUSERVICE$[rip]
	lea	r8, -320[rbp]
	mov	QWORD PTR 40[rsp], 2
	lea	rdx, ONHELPBUTTONCLICK[rip]
	mov	QWORD PTR 32[rsp], rdx
	mov	r9, r8
	lea	r8, .LC14[rip]
	lea	rdx, .LC21[rip]
	call	rax
	mov	QWORD PTR -168[rbp], rax
	mov	rax, QWORD PTR -168[rbp]
	mov	QWORD PTR MNUHELP$[rip], rax
	lea	rax, -320[rbp]
	mov	rcx, rax
	call	fb_StrDelete
	jmp	.L68
.L61:
.L62:
.L41:
.L63:
.L64:
.L65:
.L66:
.L67:
.L73:
	nop
	jmp	.L68
.L74:
	nop
	jmp	.L68
.L75:
	nop
	jmp	.L68
.L80:
	nop
	jmp	.L68
.L82:
	nop
.L68:
	nop
	leave
	ret
	.globl	OnDisconnection
	.def	OnDisconnection;	.scl	2;	.type	32;	.endef
OnDisconnection:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 80
	mov	QWORD PTR 16[rbp], rcx
.L84:
	mov	rax, QWORD PTR TBSTANDARD$[rip]
	test	rax, rax
	je	.L127
	lea	rax, MFF$[rip+40]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	setne	al
	movzx	eax, al
	neg	eax
	cdqe
	mov	QWORD PTR -8[rbp], rax
	jmp	.L87
.L127:
	nop
.L86:
	mov	QWORD PTR -8[rbp], 0
.L87:
	cmp	QWORD PTR -8[rbp], 0
	je	.L128
	lea	rax, MFF$[rip+48]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	setne	al
	movzx	eax, al
	neg	eax
	cdqe
	mov	QWORD PTR -16[rbp], rax
	jmp	.L90
.L128:
	nop
.L89:
	mov	QWORD PTR -16[rbp], 0
.L90:
	cmp	QWORD PTR -16[rbp], 0
	je	.L129
	mov	rax, QWORD PTR TBHELPSEPARATOR$[rip]
	test	rax, rax
	je	.L130
	lea	rax, MFF$[rip+48]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR TBHELPSEPARATOR$[rip]
	mov	rcx, QWORD PTR TBSTANDARD$[rip]
	call	rax
	mov	QWORD PTR -32[rbp], rax
	lea	rax, MFF$[rip+40]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR TBSTANDARD$[rip]
	mov	rdx, QWORD PTR -32[rbp]
	call	rax
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L131
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR TBHELPSEPARATOR$[rip]
	mov	rcx, rdx
	call	rax
	jmp	.L97
.L94:
.L96:
.L130:
	nop
	jmp	.L97
.L131:
	nop
.L97:
	mov	rax, QWORD PTR TBHELP$[rip]
	test	rax, rax
	je	.L132
	lea	rax, MFF$[rip+48]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR TBHELP$[rip]
	mov	rcx, QWORD PTR TBSTANDARD$[rip]
	call	rax
	mov	QWORD PTR -40[rbp], rax
	lea	rax, MFF$[rip+40]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR TBSTANDARD$[rip]
	mov	rdx, QWORD PTR -40[rbp]
	call	rax
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L133
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR TBHELP$[rip]
	mov	rcx, rdx
	call	rax
	jmp	.L103
.L92:
.L100:
.L101:
.L102:
.L129:
	nop
	jmp	.L103
.L132:
	nop
	jmp	.L103
.L133:
	nop
.L103:
	mov	rax, QWORD PTR MNUSERVICE$[rip]
	test	rax, rax
	je	.L134
	lea	rax, MFF$[rip+64]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	setne	al
	movzx	eax, al
	neg	eax
	cdqe
	mov	QWORD PTR -24[rbp], rax
	jmp	.L106
.L134:
	nop
.L105:
	mov	QWORD PTR -24[rbp], 0
.L106:
	cmp	QWORD PTR -24[rbp], 0
	je	.L135
	mov	rax, QWORD PTR MNUHELPSEPARATOR$[rip]
	test	rax, rax
	je	.L136
	lea	rax, MFF$[rip+64]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR MNUHELPSEPARATOR$[rip]
	mov	rcx, QWORD PTR MNUSERVICE$[rip]
	call	rax
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L137
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR MNUHELPSEPARATOR$[rip]
	mov	rcx, rdx
	call	rax
	jmp	.L113
.L110:
.L112:
.L136:
	nop
	jmp	.L113
.L137:
	nop
.L113:
	mov	rax, QWORD PTR MNUHELP$[rip]
	test	rax, rax
	je	.L138
	lea	rax, MFF$[rip+64]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR MNUHELP$[rip]
	mov	rcx, QWORD PTR MNUSERVICE$[rip]
	call	rax
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	test	rax, rax
	je	.L139
	lea	rax, MFF$[rip+80]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR MNUHELP$[rip]
	mov	rcx, rdx
	call	rax
	jmp	.L119
.L108:
.L116:
.L117:
.L118:
.L135:
	nop
	jmp	.L119
.L138:
	nop
	jmp	.L119
.L139:
	nop
.L119:
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	test	rax, rax
	je	.L140
	mov	rax, QWORD PTR VFBEDITORLIB$[rip]
	mov	rcx, rax
	call	fb_DylibFree
	jmp	.L123
.L121:
.L122:
.L140:
	nop
.L123:
	nop
	leave
	ret
	.def	tmp$2;	.scl	3;	.type	32;	.endef
tmp$2:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	DWORD PTR 16[rbp], ecx
	mov	QWORD PTR 24[rbp], rdx
	mov	DWORD PTR -4[rbp], 0
	mov	rax, QWORD PTR 24[rbp]
	mov	r8d, 0
	mov	rdx, rax
	mov	ecx, DWORD PTR 16[rbp]
	call	fb_Init
.L142:
.L143:
	mov	eax, DWORD PTR -4[rbp]
	leave
	ret
/APP
	.section .drectve
	.ascii " -export:\"OnConnection\""
	.ascii " -export:\"OnDisconnection\""

	.ident	"GCC: (x86_64-win32-sjlj-rev0, Built by MinGW-W64 project) 5.2.0"
	.def	fb_WstrAssignToA;	.scl	2;	.type	32;	.endef
	.def	fb_DylibSymbol;	.scl	2;	.type	32;	.endef
	.def	fb_StrDelete;	.scl	2;	.type	32;	.endef
	.def	fb_WstrInstrRev;	.scl	2;	.type	32;	.endef
	.def	realloc;	.scl	2;	.type	32;	.endef
	.def	fb_WstrLeft;	.scl	2;	.type	32;	.endef
	.def	fb_WstrAssign;	.scl	2;	.type	32;	.endef
	.def	fb_WstrDelete;	.scl	2;	.type	32;	.endef
	.def	fb_WstrConcat;	.scl	2;	.type	32;	.endef
	.def	fb_DylibLoad;	.scl	2;	.type	32;	.endef
	.def	free;	.scl	2;	.type	32;	.endef
	.def	fb_DylibFree;	.scl	2;	.type	32;	.endef
	.def	fb_Init;	.scl	2;	.type	32;	.endef
