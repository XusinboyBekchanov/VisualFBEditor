#pragma once
' Text 文本处理
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "Text.bi"

'释放指针数组Subject
Private Sub ArrayDeallocate(Subject(Any) As Any Ptr)
	Dim Ub As Integer = UBound(Subject)
	Dim Lb As Integer = LBound(Subject)
	Dim i As Integer
	If (Ub - Lb) > 0 Then
		For i = Lb To Ub
			If Subject(i) Then Deallocate(Subject(i))
		Next
	End If
	Erase Subject
End Sub

'用指定的字符iChr生成指定长度iCount的字符Result,左lw中mw右rw的文字可指定
Private Sub TitleWStr(ByRef Result As WString Ptr, ByVal iCount As Integer = 80, ByRef iChr As Const WString = " ", ByRef LW As Const WString = "", ByRef MW As Const WString = "" , ByRef RW As Const WString = "")
	Dim sTL As Integer = iCount
	Dim sLL As Integer = Len(LW)
	Dim sRL As Integer = Len(RW)
	Dim sML As Integer = Len(MW)
	
	If sTL < sLL + sML + sRL Then sTL = sLL + sML + sRL
	
	WLet(Result, WString(sTL, iChr))
	
	If sLL Then Mid(*Result, 1, sLL) = LW
	If sML Then Mid(*Result, sTL / 2, sML) = MW
	If sRL Then Mid(*Result, sTL - sRL + 1, sRL) = RW
End Sub

'查找文字fFind在字符串fSource中的位置(指定开始位置fStartPos), 未找到返回0
Private Function InWStr Overload (ByVal fStartPos As Integer, ByRef fSource As Const WString, ByRef fFind As Const WString, ByVal MatchCase As Boolean = False) As Integer
	If fStartPos < 1 Then Return 0
	Dim lenSource As Integer = Len(fSource)
	If lenSource = 0 Then Return 0
	Dim lenFind As Integer = Len(fFind)
	If lenFind = 0 Then Return 0
	If fStartPos > lenSource - lenFind Then Return 0
	
	Dim i As Integer
	Dim j As Integer = 0
	Dim rtn As Integer = 0
	
	Dim pSource As WString Ptr
	Dim pFind As WString Ptr
	If MatchCase Then
		pSource = StrPtr(fSource)
		pFind = StrPtr(fFind)
	Else
		TextConvert(fSource, pSource, LCMAP_LOWERCASE)
		TextConvert(fFind, pFind, LCMAP_LOWERCASE)
	End If
	For i = fStartPos - 1 To lenSource - 1
		If (*pSource)[i] = (*pFind)[j] Then
			j += 1
			If j = lenFind Then
				rtn = i - lenFind + 2
			End If
		Else
			j = 0
		End If
		If rtn Then Exit For
	Next
	If MatchCase = False Then
		If pSource Then Deallocate(pSource)
		If pFind Then Deallocate(pFind)
	End If
	Return rtn
End Function

'查找文字fFind在字符串fSource中的位置, 未找到返回0
Private Function InWStr Overload (ByRef fSource As Const WString, ByRef fFind As Const WString, ByVal MatchCase As Boolean = False) As Integer
	Dim lenSource As Integer = Len(fSource)
	If lenSource = 0 Then Return 0
	Dim lenFind As Integer = Len(fFind)
	If lenFind = 0 Then Return 0
	Dim fStartPos As Integer = 1
	If fStartPos > lenSource - lenFind Then Return 0
	
	Dim i As Integer
	Dim j As Integer = 0
	Dim rtn As Integer = 0
	
	Dim pSource As WString Ptr
	Dim pFind As WString Ptr
	If MatchCase Then
		pSource = StrPtr(fSource)
		pFind = StrPtr(fFind)
	Else
		TextConvert(fSource, pSource, LCMAP_LOWERCASE)
		TextConvert(fFind, pFind, LCMAP_LOWERCASE)
	End If
	For i = fStartPos - 1 To lenSource - 1
		If (*pSource)[i] = (*pFind)[j] Then
			j += 1
			If j = lenFind Then
				rtn = i - lenFind + 2
			End If
		Else
			j = 0
		End If
		If rtn Then Exit For
	Next
	If MatchCase = False Then
		If pSource Then Deallocate(pSource)
		If pFind Then Deallocate(pFind)
	End If
	Return rtn
End Function

'反向查找文字fFind在字符串fSource中的位置, 未找到返回0
Private Function InWStrRev(ByRef fSource As Const WString, ByRef fFind As Const WString, ByVal fStartPos As Integer = -1, ByVal MatchCase As Boolean = False) As Integer
	Dim lenSource As Integer = Len(fSource)
	If lenSource = 0 Then Return 0
	Dim lenFind As Integer = Len(fFind)
	If lenFind = 0 Then Return 0
	If fStartPos = -1 Then fStartPos = lenSource
	If fStartPos < lenFind Then Return 0
	If fStartPos > lenSource Then Return 0
	
	Dim i As Integer
	Dim j As Integer = lenFind - 1
	Dim rtn As Integer = 0
	
	Dim pSource As WString Ptr
	Dim pFind As WString Ptr
	If MatchCase Then
		pSource = StrPtr(fSource)
		pFind = StrPtr(fFind)
	Else
		TextConvert(fSource, pSource, LCMAP_LOWERCASE)
		TextConvert(fFind, pFind, LCMAP_LOWERCASE)
	End If
	For i = fStartPos - 1 To 0 Step -1
		If (*pSource)[i] = (*pFind)[j] Then
			j -= 1
			If j < 0 Then
				rtn = i + 1
			End If
		Else
			j = lenFind - 1
		End If
		If rtn Then Exit For
	Next
	
	If MatchCase = False Then
		If pSource Then Deallocate(pSource)
		If pFind Then Deallocate(pFind)
	End If
	Return rtn
End Function

'寻找文字Finding在字符串Expression中的数量和位置FoundPositions,返回数量(从1开始)0表示没有找到
Private Function FindCountWStr(ByRef Expression As WString, Finding As Const WString, ByRef FoundPositions As Integer Ptr, ByVal MatchCase As Boolean = False) As Integer
	Dim lenExpression As Integer = Len(Expression)
	Dim lenFinding As Integer = Len(Finding)
	Dim ptrExpression As WString Ptr
	Dim ptrFinding As WString Ptr
	Const As Long mGrowSize = 32768
	
	Dim i As Integer
	Dim j As Integer = 0
	Dim Count As Integer = -1
	If MatchCase Then
		ptrExpression = StrPtr(Expression)
		ptrFinding = StrPtr(Finding)
	Else
		TextConvert(Expression, ptrExpression, LCMAP_LOWERCASE)
		TextConvert(Finding, ptrFinding, LCMAP_LOWERCASE)
	End If
	For i = 0 To lenExpression - 1
		If (*ptrExpression)[i] = (*ptrFinding)[j] Then
			j += 1
			If j = lenFinding Then
				Count += 1
				If (Count Mod mGrowSize) = 0 Then
					FoundPositions = Reallocate(FoundPositions, (Count + mGrowSize)*SizeOf(Integer))
				End If
				* (FoundPositions + Count) = i - lenFinding + 1
				j = 0
			End If
		Else
			j = 0
		End If
	Next
	Count += 1
	FoundPositions = Reallocate(FoundPositions, (Count + 1)*SizeOf(Integer))
	* (FoundPositions + Count) = lenExpression
	If MatchCase = False Then
		If ptrExpression Then Deallocate(ptrExpression)
		If ptrFinding Then Deallocate(ptrFinding)
	End If
	Return Count
End Function

'返回位置FindPos所在寻找结果FindPositions,FindCount,FindLength的索引
Private Function FindIndexByPos(ByRef FindPositions As Integer Ptr, FindCount As Integer, FindPos As Integer, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False) As Integer
	Dim i As Integer
	If FindBack Then
		For i = FindCount - 1 To 0 Step -1
			If * (FindPositions + i) < FindPos Then
				Return i
			End If
		Next
		If FindWarp Then Return FindCount - 1
	Else
		For i = 0 To FindCount - 1
			If * (FindPositions + i) > FindPos Then
				Return i
			End If
		Next
		If FindWarp Then Return 0
	End If
	Return -1
End Function

'用文字Delimiter将字符串Subject分离成数组Result,返回数组数(从0开始)
Private Function SplitWStr(ByRef Subject As WString, ByRef Delimiter As Const WString, Result(Any) As WString Ptr, ByVal MatchCase As Boolean = False) As Integer
	ArrayDeallocate(Result())
	Dim FoundPositions As Integer Ptr = 0
	Dim FindCount As Integer = FindCountWStr(Subject, Delimiter, FoundPositions, MatchCase)
	
	If FindCount < 1 Then
		ReDim Result(0)
		WLet(Result(0), Subject)
	Else
		ReDim Result(FindCount)
		Dim i As Integer
		Dim lenDelimiter As Integer = Len(Delimiter)
		
		Result(0) = CAllocate((* FoundPositions) * 2 + 2)
		memcpy(Result(0), @Subject, (*FoundPositions) * 2)
		
		Dim iSt As Integer
		Dim iLen As Integer
		For i = 0 To FindCount - 1
			iSt = * (FoundPositions + i) + lenDelimiter
			iLen = * (FoundPositions + i + 1) - iSt
			Result(i + 1) = CAllocate(iLen * 2 + 2)
			memcpy(Result(i + 1), @Subject + iSt, iLen * 2)
		Next
	End If
	
	If FoundPositions Then Deallocate(FoundPositions)
	Return FindCount
End Function

'快排（Quick Sort）
Sub QuickSort(arr() As WString Ptr, ByVal low As Integer, ByVal high As Integer, ByVal Ascending As Boolean)
	Dim i As Integer = low
	Dim j As Integer = high
	Dim pivot As WString Ptr = arr((low + high) \ 2)
	Dim temp As WString Ptr
	
	' 快排核心：根据 pivot 分区
	Do
		If Ascending Then
			While *arr(i) < *pivot: i += 1: Wend
			While *arr(j) > *pivot: j -= 1: Wend
		Else
			While *arr(i) > *pivot: i += 1: Wend
			While *arr(j) < *pivot: j -= 1: Wend
		End If
		
		If i <= j Then
			temp = arr(i)
			arr(i) = arr(j)
			arr(j) = temp
			i += 1
			j -= 1
		End If
	Loop While i <= j
	
	' 递归调用左右分区
	If low < j Then QuickSort(arr(), low, j, Ascending)
	If i < high Then QuickSort(arr(), i, high, Ascending)
End Sub

'快速给字符串数组Subject()按照指定顺序Ordering排序
Private Function SortArray(Subject() As WString Ptr, ByVal Ordering As SortOrders = SortOrders.Ascending) As Boolean
	If UBound(Subject) > 0 Then
		QuickSort(Subject(), 0, UBound(Subject), Ordering)
		Return True
	Else
		Return False
	End If
End Function

'字符串数组Subject用文字Delimiter从iStart到iEnd连接合并,返回合并后的字符串长度
Private Function JoinWStr(Subject(Any) As WString Ptr, ByRef Delimiter As Const WString, ByRef Result As WString Ptr, ByVal iStart As Integer = -1, ByVal iEnd As Integer = -1) As Integer
	Dim Ub As Integer = UBound(Subject)             '开始索引值
	Dim Lb As Integer = LBound(Subject)             '结束索引值
	If iStart >= Lb And iStart <= Ub Then Lb = iStart
	If iEnd >= Lb And iEnd <= Ub Then Ub = iEnd
	If Ub < Lb Then Return -1                       '不符合返回-1
	
	'长度计算
	Dim lenResult As Integer = 0                    '返回长度
	Dim lenDelimiter As Integer = Len(Delimiter)    '分隔字符串长度
	Dim lenSubject() As Integer                     '每个元素的长度
	ReDim lenSubject(Lb To Ub)
	Dim i As Integer
	For i = Lb To Ub
		lenSubject(i) = Len(*Subject(i))
		lenResult += lenSubject(i)
	Next
	lenResult += (Ub - Lb)*lenDelimiter
	
	'申请返回空间
	If Result Then Deallocate(Result)
	Result = CAllocate(lenResult * 2 + 2)
	
	'填充返回内容
	*Result = *Subject(Lb)
	Dim l As Integer = lenSubject(Lb)
	For i = Lb + 1 To Ub
		* (Result + l) = Delimiter
		l += lenDelimiter
		* (Result + l) = *Subject(i)
		l += lenSubject(i)
	Next
	
	'返回长度
	Return lenResult
End Function

'寻找文字Finding在字符串Expression所在的所有行LinesFound,返回找到的行数(从0开始)
Private Function FindLinesWStr(ByRef Expression As WString, ByRef Finding As Const WString, ByRef LinesFound As WString Ptr, ByVal MatchCase As Boolean = False) As Integer
	Dim Lines(Any) As WString Ptr
	Dim Founds(Any) As WString Ptr
	Dim FoundCount As Integer = InWStr(Expression, Finding, MatchCase)
	If FoundCount < 1 Then Return -1
	
	Dim FoundIndex As Integer = -1
	Dim LineCount As Integer = SplitWStr(Expression, vbCrLf, Lines(), MatchCase)
	
	Dim i As Integer
	For i = 0 To LineCount
		If InWStr(*Lines(i), Finding, MatchCase) Then
			FoundIndex += 1
			ReDim Preserve Founds(FoundIndex)
			Founds(FoundIndex) = Lines(i)
		End If
	Next
	JoinWStr(Founds(), vbCrLf, LinesFound)
	ArrayDeallocate(Lines())
	Erase Founds
	Return FoundIndex
End Function

'在Expression中寻找Finding并用Replacing替换成Replaced,返回找到的个数,从1开始,0表示未找到
Private Function ReplaceWStr(ByRef Expression As WString, ByRef Finding As WString, ByRef Replacing As WString, ByRef Replaced As WString Ptr, ByVal MatchCase As Boolean = False) As Integer
	Dim FoundPositions As Integer Ptr
	Dim CountFind As Integer = FindCountWStr(Expression, Finding, FoundPositions, MatchCase)
	If CountFind Then
		Dim lenReturn As Integer = 0
		Dim lenExpression As Integer = Len(Expression)
		Dim lenFinding As Integer = Len(Finding)
		Dim lenReplacing As Integer = Len(Replacing)
		lenReturn = lenExpression - lenFinding * CountFind + lenReplacing * CountFind
		If Replaced Then Deallocate(Replaced)
		Replaced = CAllocate(lenReturn *2 + 2)
		Dim iPos As Integer = *FoundPositions
		memcpy(Replaced, @Expression, iPos * 2)
		
		Dim i As Integer
		Dim iSt As Integer
		Dim iLen As Integer
		
		For i = 1 To CountFind
			memcpy(Replaced + iPos, @Replacing, lenReplacing * 2)
			iPos += lenReplacing
			iSt = * (FoundPositions + i - 1) + lenFinding
			iLen = * (FoundPositions + i) - iSt
			
			memcpy(Replaced + iPos , @Expression + iSt, iLen * 2)
			iPos += iLen
		Next
	End If
	Deallocate (FoundPositions)
	Return CountFind
End Function

'全路径文件名补全
Private Function FullNameFromFile(sFileName As WString, ByRef sDefPath As Const WString = "") As UString
	If Len(sFileName) Then
		If InStr(sFileName, "\") Then
			'如果文件名已经包含路径直接返回文件名
			Return sFileName
		Else
			If sDefPath = "" Then
				'如果没有默认路径就用app路径
				Return ExePath & "\" & sFileName
			Else
				'如果有设置默认路径
				Return sDefPath & sFileName
			End If
		End If
	Else
		Return ""
	End If
End Function

'取全文件名sFullName的文件名部分
Private Function FullName2File(sFullName As WString, ByRef sDefPath As Const WString = "\") As UString
	Dim sSLen As Integer = Len(sFullName)
	Dim sPLen As Integer
	Dim sPLoc As Integer
	
	Select Case sDefPath
	Case ""
		sPLen = Len(ExePath & "\")
		sPLoc = InStr(sFullName, ExePath & "\")
	Case "\" 'return only file name
		sPLen = Len(sDefPath)
		sPLoc = InStrRev(sFullName, sDefPath)
	Case Else
		sPLen = Len(sDefPath)
		sPLoc = InStr(sFullName, sDefPath)
	End Select
	If sSLen Then
		If sPLoc Then
			Return Right(sFullName, sSLen - sPLen - sPLoc + 1)
		Else
			Return sFullName
		End If
	Else
		Return ""
	End If
End Function

'取全文件名sFullName的路径部分
Private Function FullName2Path(sFullName As WString, ByRef sDefPath As Const WString = "") As UString
	Dim sSLen As Integer = Len(sFullName)
	Dim sPLen As Integer
	Dim sPLoc As Integer
	
	If sDefPath = "" Then
		sPLen = Len(ExePath & "\")
		sPLoc = InStr(sFullName, ExePath & "\")
	Else
		sPLen = Len(sDefPath)
		sPLoc = InStr(sFullName, sDefPath)
	End If
	If sSLen Then
		If sPLoc Then
			Return Left(sFullName, sPLoc - 1)
		Else
			Return sFullName
		End If
	Else
		Return ""
	End If
End Function

'Ansi编码文字pAnsi用指定nCodePage转换为文本pToText
Private Function TextFromAnsi(ByRef pAnsi As Const String, ByRef pToText As WString Ptr, ByVal nCodePage As Integer = -1) As Long
	Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
	Dim nLength As LongInt = MultiByteToWideChar(CodePage, 0, StrPtr(pAnsi), -1, NULL, 0) - 1
	If pToText Then Deallocate(pToText)
	pToText = CAllocate(nLength * 2 + 2)
	Return MultiByteToWideChar(CodePage, 0, StrPtr(pAnsi), -1, pToText, nLength)
End Function

'文本pText用指定nCodePage转换为Ansi编码到pToAnsi
Private Function TextToAnsi(ByRef pText As Const WString, ByRef pToAnsi As ZString Ptr, ByVal nCodePage As Integer = -1) As Long
	Dim CodePage As Integer = IIf(nCodePage= -1, GetACP(), nCodePage)
	Dim nLength As LongInt = WideCharToMultiByte(CodePage, 0, StrPtr(pText), -1, NULL, 0, NULL, NULL) - 1
	If pToAnsi Then Deallocate(pToAnsi)
	pToAnsi = CAllocate(nLength * 2 + 2)
	Return WideCharToMultiByte(CodePage, 0, StrPtr(pText), nLength, pToAnsi, nLength, NULL, NULL)
End Function

'文本pUtf8从Utf8转换为文本pToText
Private Function TextFromUtf8(ByRef pUtf8 As Const ZString, ByRef pToText As WString Ptr) As Integer
	Return TextFromAnsi(pUtf8, pToText, CodePage_UTF8)
End Function

'文本pText转换为Utf8编码pToUtf8
Private Function TextToUtf8(ByRef pText As Const WString, ByRef pToUtf8 As ZString Ptr) As Integer
	Return TextToAnsi(pText, pToUtf8, CodePage_UTF8)
End Function

'文本pSource指定转换码CnvCode转换为pConverted
Private Function TextConvert(ByRef pSource As Const WString, ByRef pConverted As WString Ptr, ByVal CnvCode As DWORD) As Long
	Dim lid As LCID = MAKELCID(MAKELANGID(LANG_CHINESE, SUBLANG_CHINESE_SIMPLIFIED), SORT_CHINESE_PRC)
	Dim nLength As LongInt = LCMapString(lid, CnvCode, StrPtr(pSource), -1, NULL, 0)
	If pConverted Then Deallocate(pConverted)
	pConverted = CAllocate(Len(pSource) * 2 + 2)
	LCMapString(lid, CnvCode, StrPtr(pSource), -1, pConverted, nLength)
	Return nLength
End Function

'返回换行SrcEOL编码对应的字符串
Private Function TextGetEofStr(ByVal SrcEOL As NewLineTypes = OsEol) ByRef As WString
	Select Case SrcEOL
	Case NewLineTypes.WindowsCRLF
		Return WChr(13, 10)
	Case NewLineTypes.LinuxLF
		Return WChr(10)
	Case NewLineTypes.MacOSCR
		Return WChr(13)
	End Select
End Function

'返回文本编码FileEncoding对应的字符串
Private Function TextGetEncodeStr(FileEncoding As FileEncodings = FileEncodings.Utf8BOM) ByRef As WString
	Select Case FileEncoding
	Case FileEncodings.Utf8
		Return WStr("ascii")
	Case FileEncodings.PlainText
		Return WStr("ascii")
	Case FileEncodings.Utf8BOM
		Return WStr("utf8")
	Case FileEncodings.Utf16BOM
		Return WStr("utf16")
	Case FileEncodings.Utf32BOM
		Return WStr("utf32")
	Case Else
		Return WStr("")
	End Select
End Function

'获取文本文件FileName的文件编码格式FileEncoding和换行格式NewLineType, 并且返回文件的大小
Private Function TextFileGetFormat(ByRef FileName As Const WString, ByRef FileEncoding As FileEncodings = -1, ByRef NewLineType As NewLineTypes = -1, ByVal LoadSize As Integer = &Hfffff) As LongInt
	Dim Buff As String
	Dim Result As LongInt = -1
	Dim Fn As Integer = FreeFile
	Dim FileSize As LongInt = 0
	Dim TempSize As LongInt = 0
	
	Result = Open(FileName For Binary Access Read As #Fn)
	If Result = 0 Then
		FileSize = LOF(Fn)
		TempSize = IIf(LoadSize > 0, IIf(LoadSize > FileSize, FileSize, LoadSize), FileSize)
		Buff = String(TempSize, 0)
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
				Dim Buff2 As String
				Result = Open(FileName For Binary Access Read As #Fn)
				Buff2 = String(FileSize, 0)
				Get #Fn, , Buff2
				Close(Fn)
				If (CheckUTF8NoBOM(Buff2)) Then 'UTF8
					FileEncoding = FileEncodings.Utf8
				Else 'PlainText
					FileEncoding = FileEncodings.PlainText
				End If
			End If
		End If
		
		If NewLineType < 0 Then
			Dim pText As WString Ptr
			If FileEncoding < FileEncodings.Utf8BOM Then
				If FileEncoding = FileEncodings.PlainText Then
					TextFromAnsi(Buff, pText, GetACP())
				Else
					TextFromAnsi(Buff, pText, CodePage_UTF8)
				End If
			Else
				Result = Open(FileName For Input Encoding TextGetEncodeStr(FileEncoding) As #Fn)
				If Result = 0 Then
					pText = CAllocate(TempSize* SizeOf(WString) + SizeOf(WString))
					*pText =  WInput(TempSize, #Fn)
					Close(Fn)
				End If
			End If
			If InWStr(*pText, WChr(13, 10)) Then
				NewLineType = NewLineTypes.WindowsCRLF
			ElseIf InWStr(*pText, WChr(10)) Then
				NewLineType = NewLineTypes.LinuxLF
			ElseIf InWStr(*pText, WChr(13)) Then
				NewLineType = NewLineTypes.MacOSCR
			Else
				NewLineType = OsEol
			End If
			If pText Then Deallocate(pText)
		End If
	End If
	
	Return FileSize
End Function

'从件FileName中读取文本pText, 用指定的编码格式FileEncoding和换行格式NewLineType
Private Function TextFromFile(ByRef FileName As Const WString, ByRef pText As WString Ptr, ByRef FileEncoding As FileEncodings = FileEncodings.Utf8BOM, ByRef NewLineType As NewLineTypes = OsEol, ByRef nCodePage As Integer = -1, ByVal LoadSize As Integer = 0) As LongInt
	Dim FileSize As LongInt = TextFileGetFormat(FileName, FileEncoding, NewLineType)
	If FileSize = 0 Then Return 0
	
	Dim TempSize As Integer = IIf(LoadSize > 0, IIf(LoadSize > FileSize, FileSize, LoadSize), FileSize)
	Dim Result As Integer
	Dim Fn As Integer = FreeFile
	If FileEncoding < FileEncodings.Utf8BOM Then
		Result = Open(FileName For Binary Access Read As #Fn)
		If Result = 0 Then
			Dim Buff As String = String(TempSize, 0)
			Get #Fn, , Buff
			Close(Fn)
			Select Case FileEncoding
			Case FileEncodings.Utf8
				TextFromAnsi(Buff, pText, CodePage_UTF8)
			Case FileEncodings.PlainText
				TextFromAnsi(Buff, pText, IIf(nCodePage= -1, GetACP(), nCodePage))
			End Select
		End If
	Else
		Result = Open(FileName For Input Encoding TextGetEncodeStr(FileEncoding) As #Fn)
		If Result = 0 Then
			If pText Then Deallocate(pText)
			pText = CAllocate(TempSize* SizeOf(WString) + SizeOf(WString))
			*pText =  WInput(TempSize, #Fn)
			Close(Fn)
		End If
	End If
	
	If NewLineType<>OsEol Then
		Dim tmp As WString Ptr
		WLet(tmp, *pText)
		ReplaceWStr(*tmp, TextGetEofStr(NewLineType), TextGetEofStr(OsEol), pText)
		Deallocate(tmp)
	End If
	
	Return TempSize
End Function

'保存文本fSource到文件FileName, 用指定的编码格式FileEncoding,换行符NewLineType
Private Function TextToFile(ByRef FileName As Const WString, pText As WString, ByVal FileEncoding As FileEncodings = FileEncodings.Utf8BOM, ByVal NewLineType As NewLineTypes = OsEol, ByVal nCodePage As Integer = -1) As Boolean
	Dim Fn As Integer = FreeFile
	Dim Result As Integer
	Dim FileSize As Integer = Len(pText)
	
	If FileSize= 0 Then Return False
	
	Dim pTmp As WString Ptr
	If NewLineType <> OsEol Then
		WLet(pTmp, Replace(pText, TextGetEofStr(OsEol), TextGetEofStr(NewLineType)))
		FileSize = Len(*pTmp)
	Else
		WLet(pTmp, pText)
	End If
	
	If FileEncoding < FileEncodings.Utf8BOM Then
		Result = Open(FileName For Binary Access Write As #Fn)
		If Result = 0 Then
			Dim pData As ZString Ptr
			If FileEncoding = FileEncodings.PlainText Then
				TextToAnsi(*pTmp, pData, IIf(nCodePage= -1, GetACP(), nCodePage))
			Else
				TextToAnsi(*pTmp, pData, CodePage_UTF8)
			End If
			Put #Fn, 0, *pData
			Close(Fn)
			If pData Then Deallocate(pData)
			If pTmp Then Deallocate(pTmp)
			Return True
		End If
	Else
		Result = Open(FileName For Output Encoding TextGetEncodeStr(FileEncoding) As #Fn)
		If Result = 0 Then
			Print #Fn, *pTmp;
			Close(Fn)
			If pTmp Then Deallocate(pTmp)
			Return True
		End If
	End If
	If pTmp Then Deallocate(pTmp)
	Return False
End Function


