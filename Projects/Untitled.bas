#define BufferSize 100
Private Sub FillBuffer( ByVal BaseBuffer As Any Ptr )
	Dim As ULong HalfBuffer
	Dim As ULongInt RecoverBuffer
	Dim As Any Ptr ptrRecoverBuffer
	Dim As Any Ptr Dummy = BaseBuffer
	
	ptrRecoverBuffer = Cast( Any Ptr, @RecoverBuffer)
	
	HalfBuffer = BufferSize\2
	
	Randomize , 5
	
	#ifndef __FB_64BIT__ ' 32_bit
		Asm
			mov edi, dword ptr [HalfBuffer]
			mov esi, 0
			mov ebx, dword ptr [Dummy]
			rptRdRand32:
			mov ecx, 10 ' Max number Of tries before going into a recovery
			queryAgain32:
			RdRand eax
			jc OK32 ' A random value was available
			dec ecx
			jnz queryAgain32
			call Recover32
			OK32:
			mov dword ptr [ebx + esi], eax ' Store RdRand
			add esi, 4
			cmp edi, esi
			jne rptRdRand32
			jmp Done32
			Recover32:
			pushad ' I am playing it safe here
		End Asm
		*(Cast( ULong Ptr, ptrRecoverBuffer )) = Int(Rnd*2^32)
		Asm
			popad
			mov eax, dword ptr [ptrRecoverBuffer]
			ret
			Done32:
		End Asm
	#Else '64-bt
		Asm
			mov rdi, qword ptr [HalfBuffer]
			mov rsi, 0
			mov rbx, qword ptr [Dummy]
			rptRdRand64:
			mov ecx, 10 ' Max number Of tries before going into a recovery
			queryAgain64:
			RdRand rax
			jc OK64 ' A random value was available
			dec ecx
			jnz queryAgain64
			call Recover64
			OK64:
			mov qword ptr [rbx + rsi], rax ' Store RdRand
			add rsi, 8
			cmp rdi, rsi
			jne rptRdRand64
			jmp Done64
			Recover64:
		End Asm
		*(Cast( ULongInt Ptr, ptrRecoverBuffer )) = Int(Rnd*2^32)
		*(Cast( ULongInt Ptr, ptrRecoverBuffer + 1 )) = Int(Rnd*2^32)
		Asm
			mov rax, qword ptr [ptrRecoverBuffer]
			ret
			Done64:
		End Asm
	#endif
End Sub

