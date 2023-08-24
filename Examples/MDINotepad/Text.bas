#pragma once
' Text 文本处理
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

#include once "Text.bi"

Const As Long  mGrowSize = 32768

Private Function WStr2Ptr Overload (ByRef SourceText As Const WString, ByRef RtnPtr As WString Ptr) As Integer
	Dim i As Integer = Len(SourceText) + 1
	If RtnPtr Then Deallocate(RtnPtr)
	RtnPtr = CAllocate(i * 2)
	*RtnPtr = SourceText
	Return i
End Function

Private Function WStr2Ptr Overload (ByVal SourceText As WString Ptr, ByRef RtnPtr As WString Ptr) As Integer
	Dim i As Integer = Len(*SourceText) + 1
	If RtnPtr Then Deallocate(RtnPtr)
	RtnPtr = CAllocate(i * 2)
	*RtnPtr = *SourceText
	Return i
End Function

Private Sub WStrTitle(ByVal iCount As Integer = 80, ByRef ch As Const WString = " ", ByRef LW As Const WString = "", ByRef MW As Const WString = "" , ByRef RW As Const WString = "", ByRef RtnPtr As WString Ptr)
	Dim tl As Integer = iCount
	Dim ll As Integer = Len(LW)
	Dim rl As Integer = Len(RW)
	Dim ml As Integer = Len(MW)
	
	If tl < ll + ml + rl Then tl = ll + ml + rl
	
	If RtnPtr Then Deallocate(RtnPtr)
	RtnPtr = CAllocate(tl * 2 + 2)
	*RtnPtr = WString(tl, ch)
	
	If ll Then Mid(*RtnPtr, 1, ll) = LW
	If ml Then Mid(*RtnPtr, tl / 2, ml) = MW
	If rl Then Mid(*RtnPtr, tl - rl + 1, rl) = RW
End Sub

Private Function InWStr Overload (ByVal StartPos As Integer, ByRef Source As Const WString, ByRef Find As Const WString) As Integer
	If StartPos < 1 Then Return 0
	Dim lenSource As Integer = Len(Source)
	Dim lenFind As Integer = Len(Find)
	If lenSource = 0 Then Return 0
	If lenFind = 0 Then Return 0
	If StartPos > lenSource - lenFind Then Return 0
	
	Dim i As Integer
	Dim j As Integer = 0
	For i = StartPos - 1 To lenSource - 1
		If Source[i] = Find[j] Then
			j += 1
			If j = lenFind Then
				Return i - lenFind + 2
			End If
		Else
			j = 0
		End If
	Next
End Function

Private Function InWStr Overload (ByRef Source As Const WString, ByRef Find As Const WString) As Integer
	Dim lenSource As Integer = Len(Source)
	Dim lenFind As Integer = Len(Find)
	Dim StartPos As Integer = 1
	If lenSource = 0 Then Return 0
	If lenFind = 0 Then Return 0
	If StartPos > lenSource - lenFind Then Return 0
	
	Dim i As Integer
	Dim j As Integer = 0
	For i = StartPos - 1 To lenSource - 1
		If Source[i] = Find[j] Then
			j += 1
			If j = lenFind Then
				Return i - lenFind + 2
			End If
		Else
			j = 0
		End If
	Next
	Return 0
End Function

Private Function InWStrRev(ByRef Source As Const WString, ByRef Find As Const WString, ByVal StartPos As Integer = -1) As Integer
	Dim lenSource As Integer = Len(Source)
	Dim lenFind As Integer = Len(Find)
	
	If lenSource = 0 Then Return 0
	If lenFind = 0 Then Return 0
	If StartPos = -1 Then StartPos = lenSource
	If StartPos < lenFind Then Return 0
	If StartPos > lenSource Then Return 0
	
	Dim i As Integer
	Dim j As Integer = lenFind - 1
	For i = StartPos - 1 To 0 Step -1
		If Source[i] = Find[j] Then
			j -= 1
			If j < 0 Then
				Return i + 1
			End If
		Else
			j = lenFind - 1
		End If
	Next
	Return 0
End Function

Private Function FindCountWStr Overload (ByRef SourceText As Const WString, Find As Const WString, ByRef Finds As Integer Ptr) As Integer
	Dim lenSource As Integer = Len(SourceText)
	Dim lenFind As Integer = Len(Find)
	
	Dim i As Integer
	Dim j As Integer = 0
	Dim Count As Integer = -1
	If Finds Then Deallocate(Finds)
	Finds = CAllocate(mGrowSize * SizeOf(Integer))
	For i = 0 To lenSource - 1
		If SourceText[i] = Find[j] Then
			j += 1
			If j = lenFind Then
				Count += 1
				If (Count Mod mGrowSize) = 0 Then
					Finds = Reallocate(Finds, (Count + mGrowSize)*SizeOf(Integer))
				End If
				* (Finds + Count) = i - lenFind + 1
				j = 0
			End If
		Else
			j = 0
		End If
	Next
	Count += 1
	Reallocate(Finds, (Count + 1)*SizeOf(Integer))
	* (Finds + Count) = lenSource
	Return Count
End Function

Private Function ReplaceWStr Overload (ByRef SourceText As Const WString, ByRef Find As Const WString, ByRef Target As Const WString, ByRef ReplacePtr As WString Ptr, ByVal CaseSensitive As Integer = False) As Integer
	Dim ptrFinds As Integer Ptr
	Dim countFind As Integer
	If CaseSensitive Then
		countFind = FindCountWStr(SourceText, Find, ptrFinds)
	Else
		countFind = FindCountWStr(LCase(SourceText), LCase(Find), ptrFinds)
	End If
	
	Dim lenSource As Integer = Len(SourceText)
	
	If ReplacePtr Then
		Deallocate(ReplacePtr)
		ReplacePtr = 0
	End If
	
	Dim lenReturn As Integer = 0
	If countFind Then
		Dim lenFind As Integer = Len(Find)
		Dim lenTarget As Integer = Len(Target)
		lenReturn = lenSource - lenFind * countFind + lenTarget * countFind
		ReplacePtr = CAllocate(lenReturn *2 + 2)
		Dim i As Integer
		For i = 0 To *ptrFinds - 1
			(*ReplacePtr)[i] = SourceText[i]
		Next
		Dim k As Integer = *ptrFinds
		Dim j As Integer
		Dim l As Integer
		Dim a As Integer
		Dim b As Integer
		Dim c As Integer = lenTarget - 1
		For j = 1 To countFind
			For i = 0 To c
				(*ReplacePtr)[k + i] = Target[i]
			Next
			k = k + lenTarget
			l = 0
			a = * (ptrFinds + j - 1) + lenFind
			b = * (ptrFinds + j) - 1
			For i = a To b
				(*ReplacePtr)[k + l] = SourceText[i]
				l += 1
			Next
			k = k + l
		Next
		Return lenReturn
	Else
		WStr2Ptr(SourceText, ReplacePtr)
		Return lenSource
	End If
	Deallocate (ptrFinds)
End Function

Private Function FullName2File(ByRef FullName As Const WString) ByRef As WString
	Static rtn As WString Ptr
	Dim i As Integer = InStrRev(FullName, WStr("\"))
	If i Then
		Dim j As Integer = (Len(FullName) - i)
		WStr2Ptr(Right(FullName, j), rtn)
		Return *rtn
	Else
		Return WStr("")
	End If
End Function

Private Function FullName2Path(ByRef FullName As Const WString) ByRef As WString
	Static rtn As WString Ptr
	Dim i As Integer = InStrRev(FullName, WStr("\"))
	If i Then
		WStr2Ptr(Left(FullName, i - 1), rtn)
		Return *rtn
	Else
		Return WStr("")
	End If
End Function

Private Function TextUnicode2Ansi(ByRef UnicodeStr As Const WString, ByVal nCodePage As Integer = -1) ByRef As String
	Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
	
	Static ansiStr As String
	Dim As LongInt nLength = WideCharToMultiByte(CodePage, 0, StrPtr(UnicodeStr), -1, NULL, 0, NULL, NULL) - 1
	ansiStr = String(nLength, 0)
	Dim DataSize As LongInt = WideCharToMultiByte(CodePage, 0, StrPtr(UnicodeStr), nLength, StrPtr(ansiStr), nLength, NULL, NULL)
	Return ansiStr
End Function

Private Function TextAnsi2Unicode (ByRef AnsiStr As Const String, ByRef UnicodeStr As WString Ptr, ByVal nCodePage As Integer = -1) ByRef As WString
	Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
	
	Dim As LongInt nLength = MultiByteToWideChar(CodePage, 0, StrPtr(AnsiStr), -1, NULL, 0) - 1
	MultiByteToWideChar(CodePage, 0, StrPtr(AnsiStr), -1, UnicodeStr, nLength)
	Return ""
End Function

Private Function TextFromAnsi (ByRef AnsiStr As Const String, ByVal nCodePage As Integer = -1) ByRef As WString
	Static UnicodeStr As WString Ptr
	Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
	
	Dim As LongInt nLength = MultiByteToWideChar(CodePage, 0, StrPtr(AnsiStr), -1, NULL, 0) - 1
	If UnicodeStr Then Deallocate(UnicodeStr)
	UnicodeStr = CAllocate(nLength * 2 + 2)
	
	MultiByteToWideChar(CodePage, 0, StrPtr(AnsiStr), -1, UnicodeStr, nLength)
	Return *UnicodeStr
End Function

Private Function TextToAnsi(ByRef UnicodeStr As Const WString, ByVal nCodePage As Integer = -1) ByRef As String
	Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
	
	Static ansiStr As String
	Dim As LongInt nLength = WideCharToMultiByte(CodePage, 0, StrPtr(UnicodeStr), -1, NULL, 0, NULL, NULL) - 1
	ansiStr = String(nLength+1, 0)
	Dim DataSize As LongInt = WideCharToMultiByte(CodePage, 0, StrPtr(UnicodeStr), nLength, StrPtr(ansiStr), nLength, NULL, NULL)
	Return ansiStr
End Function

Private Function TextFromUtf8(ByRef pZString As Const ZString) ByRef As WString
	Static As WString Ptr buffer
	Dim m_BufferLen As Integer = Len(pZString) + 1
	If buffer Then Deallocate(buffer)
	buffer = CAllocate(m_BufferLen * 2)
	Return *UTFToWChar(1, StrPtr(pZString), buffer, @m_BufferLen)
End Function

Private Function TextToUtf8(ByRef nWString As Const WString) ByRef As String
	Static As String ansiStr
	Dim As Integer m_BufferLen = Len(nWString)
	Dim i1 As ULong = m_BufferLen * 5 + 1
	ansiStr = String(i1, 0)
	'Return *Cast(String Ptr, WCharToUTF(1, StrPtr(nWString), m_BufferLen, StrPtr(ansiStr), Cast(Integer Ptr, @i1)))
	WCharToUTF(1, StrPtr(nWString), m_BufferLen, StrPtr(ansiStr), Cast(Integer Ptr, @i1))
	Return ansiStr
End Function

Private Sub TextConvert(ByRef SourceText As Const WString, ByRef Target As WString Ptr, ByVal CnvCode As DWORD)
	Dim lid As LCID = MAKELCID(MAKELANGID(LANG_CHINESE, SUBLANG_CHINESE_SIMPLIFIED), SORT_CHINESE_PRC)
	Dim As LongInt nLength = LCMapString(lid, CnvCode, StrPtr(SourceText), -1, NULL, 0)
	LCMapString(lid, CnvCode, StrPtr(SourceText), -1, Target, nLength)
End Sub

Private Function TextFileGetEncode(ByRef FileName As WString, ByRef FileEncoding As FileEncodings = FileEncodings.Utf8BOM) As LongInt
	Dim As String Buff
	Dim As Integer Result = -1, Fn = FreeFile
	Dim As LongInt FileSize = 0, tmp = 1024
	
	Result = Open(FileName For Binary Access Read As #Fn)
	
	If Result = 0 Then
		FileSize = LOF(Fn)
		tmp = IIf(tmp < FileSize, FileSize, tmp)
		Buff = String(tmp, 0)
		Get #Fn, , Buff
		Close(Fn)
		
		If FileEncoding < 0 Then
			If Buff[0] = &HFF AndAlso Buff[1] = &HFE AndAlso Buff[2] = 0 AndAlso Buff[3] = 0 Then 'Utf32BOM
				FileEncoding = FileEncodings.Utf32BOM
			ElseIf Buff[0] = &HFF AndAlso Buff[1] = &HFE Then 'Utf16BOM
				FileEncoding = FileEncodings.Utf16BOM
			ElseIf Buff[0] = &HEF AndAlso Buff[1] = &HBB AndAlso Buff[2] = &HBF Then 'Utf8BOM
				FileEncoding = FileEncodings.Utf8BOM
			Else
				If (CheckUTF8NoBOM(Buff)) Then 'UTF8
					FileEncoding = FileEncodings.Utf8
				Else 'PlainText
					FileEncoding = FileEncodings.PlainText
				End If
			End If
		End If
	End If
	Return FileSize
End Function

Private Function TextChangeEOL(ByRef SourceText As Const WString, SrcEOF As NewLineTypes, NewEOF As NewLineTypes) ByRef As WString Ptr
	Dim SrcEOFStr As WString Ptr
	Dim NewEOFStr As WString Ptr
	
	Select Case SrcEOF
	Case NewLineTypes.WindowsCRLF
		WStr2Ptr(WChr(13, 10), SrcEOFStr)
	Case NewLineTypes.LinuxLF
		WStr2Ptr(WChr(10), SrcEOFStr)
	Case NewLineTypes.MacOSCR
		WStr2Ptr(WChr(13), SrcEOFStr)
	End Select
	
	Select Case NewEOF
	Case NewLineTypes.WindowsCRLF
		WStr2Ptr(WChr(13, 10), NewEOFStr)
	Case NewLineTypes.LinuxLF
		WStr2Ptr(WChr(10), NewEOFStr)
	Case NewLineTypes.MacOSCR
		WStr2Ptr(WChr(13), NewEOFStr)
	End Select
	
	Static pTmp As WString Ptr
	ReplaceWStr(SourceText, *SrcEOFStr, *NewEOFStr, pTmp)
	Deallocate(SrcEOFStr)
	Deallocate(NewEOFStr)
	Return pTmp
End Function

Private Function TextGetEncodeStr(FileEncoding As FileEncodings = FileEncodings.Utf8BOM) As String
	Select Case FileEncoding
	Case FileEncodings.Utf8
		Return "ascii"
	Case FileEncodings.PlainText
		Return "ascii"
	Case FileEncodings.Utf8BOM
		Return "utf8"
	Case FileEncodings.Utf16BOM
		Return "utf16"
	Case FileEncodings.Utf32BOM
		Return "utf32"
	Case Else
		Return ""
	End Select
End Function

Private Function TextGetEncode(ByRef FileName As Const WString, ByRef FileEncoding As FileEncodings = FileEncodings.Utf8BOM) As LongInt
	Dim As String Buff
	Dim As Integer Result = -1, Fn = FreeFile
	Dim As LongInt FileSize = 0, tmp = 1024
	
	Result = Open(FileName For Binary Access Read As #Fn)
	
	If Result = 0 Then
		FileSize = LOF(Fn)
		tmp = IIf(tmp < FileSize, FileSize, tmp)
		Buff = String(tmp, 0)
		Get #Fn, , Buff
		Close(Fn)
		
		If FileEncoding < 0 Then
			If Buff[0] = &HFF AndAlso Buff[1] = &HFE AndAlso Buff[2] = 0 AndAlso Buff[3] = 0 Then 'Utf32BOM
				FileEncoding = FileEncodings.Utf32BOM
			ElseIf Buff[0] = &HFF AndAlso Buff[1] = &HFE Then 'Utf16BOM
				FileEncoding = FileEncodings.Utf16BOM
			ElseIf Buff[0] = &HEF AndAlso Buff[1] = &HBB AndAlso Buff[2] = &HBF Then 'Utf8BOM
				FileEncoding = FileEncodings.Utf8BOM
			Else
				If (CheckUTF8NoBOM(Buff)) Then 'UTF8
					FileEncoding = FileEncodings.Utf8
				Else 'PlainText
					FileEncoding = FileEncodings.PlainText
				End If
			End If
		End If
	End If
	Return FileSize
End Function

Private Function TextFromFile(ByRef FileName As Const WString, ByRef FileEncoding As FileEncodings = FileEncodings.Utf8BOM, ByRef NewLineType As NewLineTypes = NewLineTypes.WindowsCRLF, ByRef nCodePage As Integer = -1) ByRef As WString
	Dim As String Buff
	Dim As Integer Result
	Dim As Integer Fn = FreeFile
	Dim As Integer FileSize = TextGetEncode(FileName, FileEncoding)
	If FileSize= 0 Then Return ""
	
	Static As WString Ptr pBuff = NULL
	If pBuff Then Deallocate(pBuff)
	pBuff = CAllocate(FileSize * SizeOf(WString) + SizeOf(WString))
	If FileEncoding < FileEncodings.Utf8BOM Then
		Result = Open(FileName For Binary Access Read As #Fn)
		If Result = 0 Then
			Buff = String(FileSize, 0)
			Get #Fn, 0, Buff
			Close(Fn)
			If FileEncoding = FileEncodings.PlainText Then
				Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
				TextAnsi2Unicode(Buff, pBuff, CodePage)
			Else
				UTFToWChar(UTF_ENCOD_UTF8, StrPtr(Buff), *pBuff, @FileSize)
			End If
		End If
	Else
		Dim e As String = TextGetEncodeStr(FileEncoding)
		Result = Open(FileName For Input Encoding e As #Fn)
		If Result = 0 Then
			*pBuff =  WInput(FileSize, #Fn)
			Close(Fn)
		End If
	End If
	
	If NewLineType<0 Then
		If InStr(*pBuff, WChr(13, 10)) Then
			NewLineType= NewLineTypes.WindowsCRLF
		ElseIf InStr(*pBuff, WChr(10)) Then
			NewLineType= NewLineTypes.LinuxLF
		ElseIf InStr(*pBuff, WChr(13)) Then
			NewLineType= NewLineTypes.MacOSCR
		Else
			NewLineType= WindowsCRLF
		End If
	End If
	
	Dim OsEol As NewLineTypes
	#if defined (__FB_WIN32__)
		OsEol = NewLineTypes.WindowsCRLF
	#else
		#if defined (__FB_LINUX__)
			OsEol = NewLineTypes.LinuxLF
		#else
			OsEol = NewLineTypes.MacOSCR
		#endif
	#endif
	
	Dim As WString Ptr pTmp
	If NewLineType<>OsEol Then
		pTmp = TextChangeEOL(*pBuff, NewLineType, OsEol)
		WStr2Ptr(*pTmp, pBuff)
	End If
	
	Return *pBuff
End Function

Private Function TextToFile(ByRef FileName As Const WString, ByRef SourceText As Const WString, ByVal FileEncoding As FileEncodings = FileEncodings.Utf8BOM, ByVal NewLineType As NewLineTypes = NewLineTypes.WindowsCRLF, ByVal nCodePage As Integer = -1) As Boolean
	Dim As Integer Fn = FreeFile
	Dim As Integer Result
	Dim As LongInt FileSize = Len(SourceText)
	
	If FileSize= 0 Then Return False
	
	Dim OsEol As NewLineTypes
	#if defined (__FB_WIN32__)
		OsEol = NewLineTypes.WindowsCRLF
	#else
		#if defined (__FB_LINUX__)
			OsEol = NewLineTypes.LinuxLF
		#else
			OsEol = NewLineTypes.MacOSCR
		#endif
	#endif
	
	Dim As WString Ptr pTmp
	If NewLineType <> OsEol Then
		pTmp = TextChangeEOL(SourceText, OsEol, NewLineType)
	Else
		pTmp = StrPtr(SourceText)
	End If
	
	If FileEncoding < FileEncodings.Utf8BOM Then
		Result = Open(FileName For Binary Access Write As #Fn)
		If Result = 0 Then
			Dim pData As String
			If FileEncoding = FileEncodings.PlainText Then
				Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
				pData = TextUnicode2Ansi(*pTmp, CodePage)
			Else
				Dim dSize As Integer
				pData = *Cast(ZString Ptr, WCharToUTF(UTF_ENCOD_UTF8, pTmp, FileSize, 0, @dSize))
			End If
			Put #Fn, 0, pData
			Close(Fn)
			Return True
		End If
	Else
		Result = Open(FileName For Output Encoding TextGetEncodeStr(FileEncoding) As #Fn)
		If Result = 0 Then
			Print #Fn, *pTmp;
			Close(Fn)
			Return True
		End If
	End If
	Return False
End Function

Private Sub ArrayDeallocate(Target(Any) As Any Ptr)
	Dim Ub As Integer = UBound(Target)
	Dim Lb As Integer = LBound(Target)
	Dim i As Integer
	If Ub - Lb Then
		For i = Lb To Ub
			If Target(i) Then Deallocate(Target(i))
			Target(i) = NULL
		Next
	End If
	Erase Target
End Sub

Private Function SplitWStr(ByRef Source As Const WString, ByRef Deli As Const WString, Target(Any) As WString Ptr) As Integer
	ArrayDeallocate(Target())
	Dim Finds As Integer Ptr = 0
	Dim FindCount As Integer = FindCountWStr(Source, Deli, Finds)
	
	ReDim Target(FindCount)
	If FindCount < 1 Then
		WStr2Ptr(Source, Target(0))
	Else
		Dim i As Integer
		Dim lenFind As Integer = Len(Deli)
		Dim j As Integer
		Dim l As Integer = 0
		
		Target(0) = CAllocate((* Finds) * 2 + 2)
		For i = 0 To * Finds - 1
			(* Target(0))[i] = Source[i]
		Next
		
		Dim iSt As Integer
		Dim iEn As Integer
		
		For j = 0 To FindCount - 1
			iSt = * (Finds + j) + lenFind
			iEn = * (Finds + j + 1)
			Target(j + 1) = CAllocate((iEn - iSt) * 2 + 2)
			iEn -= 1
			l = 0
			For i = iSt To iEn
				(* Target(j + 1))[l] = Source[i]
				l += 1
			Next
		Next
	End If
	
	If Finds Then Deallocate(Finds)
	Return FindCount
End Function

Private Function JoinWStr(Source(Any) As WString Ptr, ByRef Deli As Const WString, ByRef Target As WString Ptr, ByVal defLb As Integer = -1, ByVal defUb As Integer = -1) As Integer
	Dim Ub As Integer = UBound(Source)
	Dim Lb As Integer = LBound(Source)
	
	If defLb >= Lb And defLb <= Ub Then Lb = defLb
	If defUb >= Lb And defUb <= Ub Then Ub = defUb
	
	If Target Then Deallocate(Target)
	If Ub < Lb Then Return -1
	
	Dim lenTarget As Integer = 0
	Dim lenSplit As Integer = Len(Deli)
	Dim lenSource() As Integer
	ReDim lenSource(Lb To Ub)
	Dim i As Integer
	For i = Lb To Ub
		lenSource(i) = Len(*Source(i))
		lenTarget += lenSource(i)
	Next
	lenTarget += (Ub - Lb)*lenSplit
	If lenTarget > -1 Then
		Target = CAllocate(lenTarget * 2 + 2)
	Else
		Target = CAllocate(2)
	End If
	Dim j As Integer
	For j = 0 To lenSource(Lb) - 1
		(*Target)[j] = (* Source(Lb))[j]
	Next
	Dim l As Integer = lenSource(Lb)
	For i = Lb + 1 To Ub
		For j = 0 To lenSplit - 1
			(*Target)[l + j] = Deli[j]
		Next
		l += lenSplit
		For j = 0 To lenSource(i) - 1
			(*Target)[l + j] = (*Source(i))[j]
		Next
		l += lenSource(i)
	Next
	Return lenTarget
End Function


Function FindLinesWStr Overload (ByRef Source As Const WString, ByRef Find As Const WString, ByRef LinesPtr As WString Ptr, ByVal CaseSensitive As Integer = False) As Integer
	Dim Finds As Integer Ptr = 0
	Dim Lines As Integer Ptr = 0
	Dim lenFind As Integer = Len(Find)
	Dim pFindCount As Integer
	If CaseSensitive Then
		pFindCount = FindCountWStr(Source, Find, Finds)
	Else
		pFindCount = FindCountWStr(LCase(Source), LCase(Find), Finds)
	End If
	Dim pLineCount As Integer
	Dim pLineSize As Integer = 0
	Dim i As Integer
	Dim j As Integer = 0
	Dim k As Integer = 0
	Dim m As Integer
	Dim n As Integer = -1
	Dim iSt As Integer
	Dim iEn As Integer
	
	If LinesPtr Then Deallocate(LinesPtr)
	Dim pTmp As WString Ptr = CAllocate(2)
	If pFindCount Then
		pLineCount = FindCountWStr(Source, vbCrLf, Lines)
		
		'第一行
		For i = 0 To pFindCount - 1
			If * (Finds + i) <= *Lines Then
				iSt = 0
				iEn = *Lines
				If n > 0 Then
					pLineSize = pLineSize + iEn - iSt + 3
					pTmp = Reallocate(pTmp, pLineSize * 2 + 2)
					n += 1
					(*pTmp)[n] = 13
					n += 1
					(*pTmp)[n] = 10
				Else
					pLineSize = pLineSize + iEn - iSt + 1
					pTmp = Reallocate(pTmp, pLineSize * 2 + 2)
				End If
				For m = iSt To iEn
					n += 1
					(*pTmp)[n] = Source[m]
				Next
			Else
				k = i
				Exit For
			End If
		Next
		
		'第一行之外
		For i = k To pFindCount - 1
			Do
				If (* (Finds + i) >= * (Lines + j)) And (* (Finds + i) <= * (Lines + j + 1 )) Then
					If n > 0 Then
						iSt = * (Lines + j)
					Else
						iSt = * (Lines + j) + 2
					End If
					iEn = * (Lines + j + 1)
					pLineSize = pLineSize + iEn - iSt + 1
					pTmp = Reallocate(pTmp, pLineSize * 2 + 2)
					For m = iSt To iEn
						n += 1
						(*pTmp)[n] = Source[m]
					Next
					Exit Do
				Else
					j += 1
					If j >= pLineCount Then Exit For
				End If
			Loop
		Next
		
		LinesPtr = CAllocate(pLineSize * 2 + 2)
		*LinesPtr = Left(*pTmp, pLineSize)
	Else
		LinesPtr = CAllocate(2)
		*LinesPtr = ""
	End If
	Deallocate(pTmp)
	
	If Finds Then Deallocate(Finds)
	If Lines Then Deallocate(Lines)
	
	Return pFindCount
End Function

Private Function FindLinesWStr Overload (ByRef Source As Const WString, ByRef Find As Const WString, ByRef LinesPtr As WString Ptr, ByRef Finds As Integer Ptr, ByVal CaseSensitive As Integer = False) As Integer
	'	Dim Finds As Integer Ptr = 0
	Dim Lines As Integer Ptr = 0
	Dim lenFind As Integer = Len(Find)
	Dim pFindCount As Integer
	If CaseSensitive Then
		pFindCount = FindCountWStr(Source, Find, Finds)
	Else
		pFindCount = FindCountWStr(LCase(Source), LCase(Find), Finds)
	End If
	Dim pLineCount As Integer
	Dim pLineSize As Integer = 0
	Dim i As Integer
	Dim j As Integer = 0
	Dim k As Integer = 0
	Dim m As Integer
	Dim n As Integer = -1
	Dim iSt As Integer
	Dim iEn As Integer
	
	If pFindCount Then
		If LinesPtr Then Deallocate(LinesPtr)
		Dim pTmp As WString Ptr = CAllocate(2)
		pLineCount = FindCountWStr(Source, vbCrLf, Lines)
		
		'第一行
		For i = 0 To pFindCount - 1
			If * (Finds + i) <= *Lines Then
				iSt = 0
				iEn = *Lines
				If n > 0 Then
					pLineSize = pLineSize + iEn - iSt + 2
					pTmp = Reallocate(pTmp, pLineSize * 2 + 2)
					n += 1
					(*pTmp)[n] = 13
					n += 1
					(*pTmp)[n] = 10
				Else
					pLineSize = pLineSize + iEn - iSt
					pTmp = Reallocate(pTmp, pLineSize * 2 + 2)
				End If
				For m = iSt To iEn - 1
					n += 1
					(*pTmp)[n] = Source[m]
				Next
			Else
				k = i
				Exit For
			End If
		Next
		
		'第一行之外
		For i = k To pFindCount - 1
			Do
				If (* (Finds + i) >= * (Lines + j)) And (* (Finds + i) <= * (Lines + j + 1 )) Then
					If n > 0 Then
						iSt = * (Lines + j)
					Else
						iSt = * (Lines + j) + 2
					End If
					iEn = * (Lines + j + 1)
					pLineSize = pLineSize + iEn - iSt
					pTmp = Reallocate(pTmp, pLineSize * 2 + 2)
					For m = iSt To iEn - 1
						n += 1
						(*pTmp)[n] = Source[m]
					Next
					Exit Do
				Else
					j += 1
					If j >= pLineCount Then Exit For
				End If
			Loop
		Next
		
		LinesPtr = CAllocate(pLineSize * 2 + 2)
		*LinesPtr = Left(*pTmp, pLineSize)
		Deallocate(pTmp)
	End If
	
	If Lines Then Deallocate(Lines)
	Return pFindCount
End Function
