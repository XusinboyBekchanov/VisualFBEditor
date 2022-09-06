#include once "Text.bi"

Const As Long  mGrowSize = 32768

Private Function WStr2Ptr(ByRef SourceText As Const WString, ByRef rtnptr As WString Ptr) As Long
	Dim i As Integer = Len(SourceText) + 1
	If rtnptr Then Deallocate(rtnptr)
	rtnptr = CAllocate (i * 2)
	*rtnptr = SourceText
	Return i
End Function


Private Function InWStr Overload (ByVal StartPos As Integer, ByRef Source As Const WString, ByRef Find As Const WString) As Integer
	Dim lenSource As Integer = Len(Source)
	Dim lenFind As Integer = Len(Find)
	If lenSource = 0 Then Return 0
	If lenFind = 0 Then Return 0
	If StartPos > lenSource - lenFind Then Return 0
	If StartPos < 1 Then Return 0
	
	Dim i As Integer
	Dim j As Integer = 0
	Dim Count As Integer = 0
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
	If StartPos < 1 Then Return 0
	
	Dim i As Integer
	Dim j As Integer = 0
	Dim Count As Integer = 0
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
	Dim Count As Integer = 0
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
				EndIf
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
		WStr2Ptr(Left(FullName, i), rtn)
		Return *rtn
	Else
		Return WStr("")
	End If
End Function

Private Function TextUnicode2Ansi(UnicodeStr As WString, ByVal nCodePage As UINT = -1) ByRef As String
	Dim CodePage As UINT = IIf(nCodePage= -1, GetACP(), nCodePage)

	Static ansiStr As String
	Dim As LongInt nLength = WideCharToMultiByte(CodePage, 0, StrPtr(UnicodeStr), -1, NULL, 0, NULL, NULL)
	ansiStr = String(nLength, 0)
	Dim DataSize As LongInt = WideCharToMultiByte(CodePage, 0, StrPtr(UnicodeStr), nLength, StrPtr(ansiStr), nLength, NULL, NULL)
	Return ansiStr
End Function

Private Sub TextAnsi2Unicode(ByRef AnsiStr As Const String, ByRef UnicodeStr As WString Ptr, ByVal nCodePage As UINT = -1)
	Dim CodePage As UINT = IIf(nCodePage= -1, GetACP(), nCodePage)
	
	Dim As LongInt nLength = MultiByteToWideChar(CodePage, 0, StrPtr(AnsiStr), -1, NULL, 0)
	MultiByteToWideChar(CodePage, 0, StrPtr(AnsiStr), -1, UnicodeStr, nLength)
End Sub

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
				Dim CodePage As UINT = IIf(nCodePage= -1, GetACP(), nCodePage)
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
				Dim CodePage As UINT = IIf(nCodePage= -1, GetACP(), nCodePage)
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

