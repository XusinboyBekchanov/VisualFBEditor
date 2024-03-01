#pragma once
' ScintillaControl
' https://www.ScintillaControl.org/
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "ScintillaControl.bi"

#ifndef ReadProperty_Off
	Private Function ScintillaControl.ReadProperty(ByRef PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
#endif

#ifndef WriteProperty_Off
	Private Function ScintillaControl.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		If Value = 0 Then
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
		Else
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
		End If
		Return True
	End Function
#endif

Private Sub ScintillaControl.ProcessMessage(ByRef msg As Message)
	#ifndef __USE_GTK__
		Dim scMsg As SCNotification
		Select Case msg.Msg
		Case CM_NOTIFY
			CopyMemory(@scMsg, Cast(Any Ptr, msg.lParam), Len(scMsg))
			If (scMsg.hdr.hwndFrom = FHandle) Then
				'Scintilla has given some information. Let's see what it is
				'and route it to the proper place.
				'Any commented with TODO have not been implimented yet.
				Select Case scMsg.hdr.code
				Case SCN_MODIFIED
					'Debug.Print "SCN_MODIFIED"
					'Debug.Print "modificationType=" & scMsg.modificationType
					'Changed = True
					If OnModify Then OnModify(*Designer, This)
				Case SCN_HOTSPOTCLICK
					'Debug.Print "SCN_HOTSPOTCLICK"
				Case SCN_DOUBLECLICK
					'Debug.Print "SCN_DOUBLECLICK"
					If OnDblClick Then OnDblClick(*Designer, This)
					
				Case SCN_UPDATEUI
					'Debug.Print "SCN_UPDATEUI"
					'Debug.Print  "updated=" & scMsg.updated
					Select Case scMsg.updated
					Case SC_UPDATE_NONE
					Case SC_UPDATE_CONTENT
						If OnUpdate Then OnUpdate(*Designer, This)
						
					Case SC_UPDATE_SELECTION
						If OnUpdate Then OnUpdate(*Designer, This)
						
					Case SC_UPDATE_V_SCROLL
						'line number margin auto width
						If MarginWidth(0) <> 0 Then MarginWidth(0) = 10
						'Dim s As String = Format(SendMessage(FHandle, SCI_GETFIRSTVISIBLELINE, 0, 0) + SendMessage(FHandle, SCI_LINESONSCREEN, 0, 0), "#0")
						'MarginWidth(0) = SendMessage(FHandle, SCI_TEXTWIDTH, STYLE_DEFAULT, Cast(LPARAM, StrPtr(s))) + 5
						'End If
					Case SC_UPDATE_H_SCROLL
					End Select
				Case SCN_AUTOCSELECTIONCHANGE
					'Debug.Print "SCN_AUTOCSELECTIONCHANGE"
				Case SCN_KEY
					'Debug.Print "SCN_KEY"
				Case SCN_PAINTED
					'Debug.Print "SCN_PAINTED"
				End Select
			End If
		End Select
	#endif
	Base.ProcessMessage(msg)
End Sub

Private Property ScintillaControl.TabIndex As Integer
	Return FTabIndex
End Property

Private Property ScintillaControl.TabIndex(Value As Integer)
	ChangeTabIndex Value
End Property

Private Property ScintillaControl.TabStop As Boolean
	Return FTabStop
End Property

Private Property ScintillaControl.TabStop(Value As Boolean)
	ChangeTabStop Value
End Property

Namespace My.Sys.Forms

Private Function TextFromAnsi(ByRef AnsiStr As Const String, ByVal nCodePage As Integer = -1) ByRef As WString
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

Private Function TextFromSciData(ByRef TxtData As Const ZString, ByVal CodePage As Integer = 0) ByRef As WString
	If CodePage = 65001 Then
		Return TextFromUtf8(TxtData)
	Else
		Return TextFromAnsi(TxtData)
	End If
End Function

Private Function TextToSciData(ByRef txtWStr As Const WString, ByVal CodePage As Integer = 0) ByRef As String
	If CodePage = 65001 Then
		Return TextToUtf8(txtWStr)
	Else
		Return TextToAnsi(txtWStr)
	End If
End Function

End Namespace

#ifndef __USE_GTK__
	Private Sub ScintillaControl.HandleIsAllocated(ByRef Sender As Control)
		If Sender.Child Then
			
		End If
	End Sub
#endif

#ifndef __USE_GTK__
	Private Sub ScintillaControl.WndProc(ByRef message As Message)
	End Sub
#endif

Constructor ScintillaControl
	#ifdef __USE_GTK__
		'
	#else
		#ifdef __FB_64BIT__
			' Load the ScintillaControl code editing dll
			pLibLexilla = DyLibLoad("Lexilla64.dll")
			pLibScintilla = DyLibLoad("Scintilla64.dll")
		#else
			' Load the ScintillaControl code editing dll
			pLibLexilla = DyLibLoad("Lexilla32.dll")
			pLibScintilla = DyLibLoad("Scintilla32.dll")
		#endif
		FExStyle = 0
		FStyle = WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or WS_BORDER
		RegisterClass "ScintillaControl", "Scintilla"
		OnHandleIsAllocated = @HandleIsAllocated
		ChildProc		= @WndProc
	#endif
	WLet(FClassName, "ScintillaControl")
	WLet(FClassAncestor, "Scintilla")
	FTabIndex          = -1
	FTabStop           = True
	This.Child       = @This
	This.Width       = 121
	This.Height      = 121
End Constructor

Destructor ScintillaControl
	If Handle Then DestroyWindow(Handle)
	Handle = NULL
	'DyLibFree(pLibLexilla)
	'DyLibFree(pLibScintilla)
End Destructor

Private Sub ScintillaControl.CreateWnd()
	Base.CreateWnd
	'Creates a ScintillaControl editing window
	'Dim rt As Rect
	'GetClientRect(This.Parent->Handle, @rt)
	'Dim As Integer lExStyle = 0
	'Dim As Integer lStyle = WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or WS_BORDER
	'Handle = CreateWindowEx(lExStyle, "ScintillaControl", 0, lStyle, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, IIf(This.Parent = 0, 0, This.Parent->Handle), NULL, 0, 0)
	
	'font quality (antialiasing method)
	'SendMessage(FHandle, SCI_SETFONTQUALITY, SC_EFF_QUALITY_LCD_OPTIMIZED, 0)
	
	'set margin 0 as linenumber
	SendMessage(FHandle, SCI_SETMARGINTYPEN, 0, SC_MARGIN_NUMBER)
	'SendMessage(FHandle, SCI_SETMARGINMASKN, 0, STYLE_LINENUMBER)
	MarginWidth(0) = 35
	
	'set margin 1 as fold
	SendMessage(FHandle, SCI_SETMARGINTYPEN, 1, SC_MARGIN_SYMBOL)
	'SendMessage(FHandle, SCI_SETMARGINMASKN, 1, SC_MASK_FOLDERS)
	MarginWidth(1) = 0
	
	'set when text is pasted any line ends are converted to match the document's end of line mode
	SendMessage(FHandle, SCI_SETPASTECONVERTENDINGS, True, 0)
	
	CodePage = 0
	CharSet(STYLE_DEFAULT) = SC_CHARSET_DEFAULT
	
	'set indicator style
	'indicator 0 for find
	SendMessage(FHandle, SCI_INDICSETUNDER, 0, True)
	SendMessage(FHandle, SCI_INDICSETSTYLE, 0, INDIC_FULLBOX)
	SendMessage(FHandle, SCI_INDICSETALPHA, 0, &h40)
	SendMessage(FHandle, SCI_INDICSETOUTLINEALPHA, 0, &hff)
	
	'set select style
	SendMessage(Handle, SCI_HIDESELECTION, False, 0)
	SendMessage(Handle, SCI_SETSELECTIONLAYER, SC_LAYER_UNDER_TEXT, 0)
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_TEXT, RGBA(&hff, &hff, &hff, &hff))
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK, RGBA(&hff, &h40, &h40, &hff))
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_INACTIVE_TEXT, RGBA(&hff, &hff, &hff, &hff))
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_INACTIVE_BACK, RGBA(&h40, &h40, &hff, &hff))
	
	'set white space
	'SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h80, &h80, &h80, &h80))
	
	'set caretline layer
	SendMessage(FHandle, SCI_SETCARETLINELAYER, SC_LAYER_BASE, 0)
	
	'set an event mask that determines which document change events are notified to the container with SCN_MODIFIED and SCEN_CHANGE
	SendMessage(FHandle, SCI_SETMODEVENTMASK, SC_MOD_INSERTTEXT Or SC_MOD_DELETETEXT, 0)
	
	DarkMode = False
End Sub

Private Function ScintillaControl.IndexFind(ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False) As Integer
	Dim curpos As Integer = SelStart
	
	If FindCount < 0 Then
	Else
		If MoveNext Then
			If FindWarp Then FindIndex = -1
			If FindIndex >-1 AndAlso curpos = FindPoses(FindIndex) Then
				If FindBack Then
					If FindIndex = 0 Then
					Else
						FindIndex -= 1
					End If
				Else
					If FindIndex = FindCount Then
					Else
						FindIndex += 1
					End If
				End If
			Else
				For i As Integer = 0 To FindCount
					If FindBack Then
						If FindPoses(i) + FindLength > curpos Then
							If i <> 0 Then
								FindIndex = i - 1
							End If
							Exit For
						End If
					Else
						If FindPoses(i) > curpos + FindLength Then
							FindIndex = i
							Exit For
						End If
					End If
				Next
			End If
		Else
			For i As Integer = 0 To FindCount
				If (curpos >= FindPoses(i)) And (curpos <= FindPoses(i) + FindLength) Then
					FindIndex = i
					Exit For
				End If
			Next
		End If
	End If
	
	If MoveNext AndAlso FindWarp AndAlso FindIndex < 0 Then
		If FindBack Then
			FindIndex = FindCount
		Else
			FindIndex = 0
		End If
	End If
	
	Return FindIndex
End Function

Private Sub App_DoEvents
	#ifdef __USE_GTK__
		While gtk_events_pending()
			gtk_main_iteration
		Wend
	#elseif defined(__USE_WINAPI__)
		Dim As MSG M
		While PeekMessage(@M, NULL, 0, 0, PM_REMOVE)
			If M.message <> WM_QUIT Then
				TranslateMessage @M
				DispatchMessage @M
			Else
				If (GetWindowLong(M.hwnd,GWL_EXSTYLE) And WS_EX_APPWINDOW) = WS_EX_APPWINDOW Then End -1
			End If
		Wend
	#endif
End Sub

Private Function ScintillaControl.Find(ByRef toFind As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False, ByVal FindForce As Boolean = False) As Integer
	Dim FindAct As Boolean = False
	If Len(*toFind) > 0 Then
		If FindData Then
			If MatchCase Then
				If *FindData <> *toFind Then
					Deallocate(FindData)
					FindAct = True
				End If
			Else
				If LCase(*FindData) <> LCase(*toFind) Then
					Deallocate(FindData)
					FindAct = True
				End If
			End If
		Else
			FindAct = True
		End If
	End If
	
	If FindAct Or FindForce Then
		FindLength = Len(*toFind)
		FindData = CAllocate(FindLength + 1)
		*FindData = *toFind
		FindCount = -1
		Erase FindPoses
		Erase FindLines
		IndicatorClear()
		If Len(*toFind) = 0 Then Return -1
		
		Dim mc As Integer = IIf(MatchCase, SCFIND_MATCHCASE, SCFIND_NONE)
		mc = IIf(RegularExp, mc Or SCFIND_REGEXP Or SCFIND_POSIX Or SCFIND_CXX11REGEX, mc )
		
		With mStf
			.chrg.cpMin = 0
			.chrg.cpMax = Length
			.lpstrText = FindData
		End With
		
		Dim curpos As Integer = SelStart
		Dim mStart As Integer = -1
		Do
			mStart = SendMessage(FHandle, SCI_FINDTEXT, mc, Cast(LPARAM, @mStf))
			If mStart < 0 Then Exit Do
			
			FindCount += 1
			ReDim Preserve FindPoses(FindCount)
			FindPoses(FindCount)=mStart
			ReDim Preserve FindLines(FindCount)
			FindLines(FindCount) = SendMessage(FHandle, SCI_LINEFROMPOSITION, mStart, 0)
			mStf.chrg.cpMin = mStart + FindLength
			App_DoEvents
		Loop While mStart <> -1
		IndicatorSet(FindPoses(), FindLength)
	End If
	IndexFind(FindWarp, FindBack, MoveNext)
	
	Return FindCount
End Function

Private Function ScintillaControl.ReplaceAll(ByRef FindData As Const ZString Ptr, ByRef ReplaceData As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False) As Integer
	SendMessage(Handle, SCI_TARGETWHOLEDOCUMENT, 0, 0)
	
	Dim mc As Integer = IIf(MatchCase, SCFIND_MATCHCASE, SCFIND_NONE)
	mc = IIf(RegularExp, mc Or SCFIND_REGEXP Or SCFIND_POSIX Or SCFIND_CXX11REGEX, mc )
	SendMessage(Handle, SCI_SETSEARCHFLAGS, mc, 0)
	
	Dim targetstart As Integer = 0
	Dim targetend As Integer = Length
	Dim lenSearch As Integer = Len(*FindData)
	Dim lenReplace As Integer = Len(*ReplaceData)
	Dim replacecount As Integer = -1
	Dim findpos As Integer
	Do
		SendMessage(Handle, SCI_SETTARGETSTART, targetstart, 0)
		SendMessage(Handle, SCI_SETTARGETEND, targetend, 0)
		findpos = SendMessage(Handle, SCI_SEARCHINTARGET, lenSearch, Cast(LPARAM, FindData))
		If findpos < 0 Then Exit Do
		SendMessage(Handle, SCI_REPLACETARGET, lenReplace, Cast(LPARAM, ReplaceData))
		replacecount += 1
		targetstart = findpos + lenReplace
		targetend = Length
	Loop While findpos > -1
	Return replacecount
End Function

Private Property ScintillaControl.IndicatorSel As Integer
	Return SendMessage(FHandle, SCI_GETINDICATORCURRENT, 0, 0)
End Property

Private Property ScintillaControl.IndicatorSel(val As Integer)
	If val >= 0 And val <= INDICATOR_MAX Then SendMessage(FHandle, SCI_SETINDICATORCURRENT, val, 0)
End Property

Private Sub ScintillaControl.IndicatorClear()
	SendMessage(FHandle, SCI_INDICATORCLEARRANGE, 0, Length)
End Sub

Private Sub ScintillaControl.IndicatorSet(IndiPoses(Any) As Integer, ByVal IndiLength As Integer)
	IndicatorClear()
	Dim i As Long
	For i = 0 To UBound(IndiPoses)
		SendMessage(FHandle, SCI_INDICATORFILLRANGE, IndiPoses(i), IndiLength)
	Next
End Sub

Private Property ScintillaControl.WordWrap As Integer
	Return SendMessage(FHandle, SCI_GETWRAPMODE, 0, 0)
End Property

Private Property ScintillaControl.WordWrap(val As Integer)
	SendMessage(FHandle, SCI_SETWRAPMODE, val, 0)
End Property

Private Property ScintillaControl.EOLMode As Integer
	Return SendMessage(FHandle, SCI_GETEOLMODE, 0, 0)
End Property

Private Property ScintillaControl.EOLMode(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETEOLMODE, val, 0)
	SendMessage(FHandle, SCI_CONVERTEOLS, val, 0)
End Property

Private Property ScintillaControl.CodePage As Integer
	Return SendMessage(FHandle, SCI_GETCODEPAGE, 0, 0)
End Property

Private Property ScintillaControl.CodePage(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCODEPAGE, val, 0)
End Property

Private Property ScintillaControl.CharSet(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETCHARACTERSET, sty, 0)
End Property

Private Property ScintillaControl.CharSet(ByVal sty As Integer, ByVal Val As Integer)
	SendMessage(FHandle, SCI_STYLESETCHARACTERSET, sty, Val)
End Property

Private Property ScintillaControl.BackColor(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETBACK, sty, 0)
End Property

Private Property ScintillaControl.BackColor(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETBACK, sty, val)
	If sty = STYLE_DEFAULT Then SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property ScintillaControl.ForeColor(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETFORE, sty, 0)
End Property

Private Property ScintillaControl.ForeColor(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETFORE, sty, val)
	If sty = STYLE_DEFAULT Then SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property ScintillaControl.FontSize(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETSIZE, sty, 0)
End Property

Private Property ScintillaControl.FontSize(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETSIZE, sty, val)
	'SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property ScintillaControl.FontName(ByVal sty As Integer) ByRef As WString
	Static w As WString Ptr
	If w Then Deallocate(w)
	
	Dim iSize As Integer = SendMessage(FHandle, SCI_STYLEGETFONT, sty, 0)
	w = CAllocate(iSize * 2)
	Dim a As ZString Ptr
	a = CAllocate(iSize)
	SendMessage(FHandle, SCI_STYLEGETFONT, sty, Cast(LPARAM, a))
	
	*w = TextFromAnsi(*a)
	
	'TextAnsi2Unicode(*a, w)
	If a Then Deallocate(a)
	
	Return *w
End Property

Private Property ScintillaControl.FontName(ByVal sty As Integer, ByRef val As Const WString)
	Dim a As ZString Ptr
	Dim iSize As Integer = Len(val)
	a = CAllocate(iSize)
	
	'*a = TextUnicode2Ansi(val)
	*a = TextToAnsi(val)
	
	SendMessage(FHandle, SCI_STYLESETFONT, sty, Cast(LPARAM, a))
	'SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
	
	If a Then Deallocate(a)
End Property

Private Property ScintillaControl.Bold(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETBOLD, sty, 0)
End Property

Private Property ScintillaControl.Bold(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETBOLD, sty, val)
	'SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property ScintillaControl.Italic(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETITALIC, sty, 0)
End Property

Private Property ScintillaControl.Italic(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETITALIC, sty, val)
	'SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property ScintillaControl.Underline(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETUNDERLINE, sty, 0)
End Property

Private Property ScintillaControl.Underline(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETUNDERLINE, sty, val)
	'SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property ScintillaControl.Zoom As Integer
	Return SendMessage(FHandle, SCI_GETZOOM, 0, 0)
End Property

Private Property ScintillaControl.Zoom(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETZOOM, val, 0)
End Property

Private Property ScintillaControl.CaretLineBackAlpha As Integer
	Return SendMessage(FHandle, SCI_GETCARETLINEBACKALPHA, 0, 0)
End Property

Private Property ScintillaControl.CaretLineBackAlpha(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCARETLINEBACKALPHA, val, 0)
End Property

Private Property ScintillaControl.CaretLineBackColor As Integer
	Return SendMessage(FHandle, SCI_GETCARETLINEBACK, 0, 0)
End Property

Private Property ScintillaControl.CaretLineBackColor(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCARETLINEBACK, val, 0)
End Property

Private Sub ScintillaControl.Redo()
	SendMessage(FHandle, SCI_REDO, 0, 0)
End Sub

Private Sub ScintillaControl.Undo()
	SendMessage(FHandle, SCI_UNDO, 0, 0)
End Sub

Private Sub ScintillaControl.Cut()
	SendMessage(FHandle, SCI_CUT, 0, 0)
End Sub

Private Sub ScintillaControl.Copy()
	SendMessage(FHandle, SCI_COPY, 0, 0)
End Sub

Private Sub ScintillaControl.Paste()
	SendMessage(FHandle, SCI_PASTE, 0, 0)
End Sub

Private Sub ScintillaControl.Clear()
	SendMessage(FHandle, SCI_CLEAR, 0, 0)
End Sub

Private Sub ScintillaControl.GotoLine(ByVal val As Integer)
	SendMessage(FHandle, SCI_GOTOLINE, val, 0)
End Sub

Private Sub ScintillaControl.SelectAll()
	SendMessage(FHandle, SCI_SELECTALL, 0, 0)
End Sub

Private Property ScintillaControl.LineCount As Integer
	Return SendMessage(FHandle, SCI_GETLINECOUNT, 0, 0)
End Property

Private Property ScintillaControl.LineStart(ByVal LineNo As Integer) As Integer
	Return SendMessage(FHandle, SCI_GETLINEENDPOSITION, LineNo, 0)
End Property

Private Property ScintillaControl.LineEnd(ByVal LineNo As Integer) As Integer
	Return SendMessage(FHandle, SCI_GETLINEENDPOSITION, LineNo, 0)
End Property

Private Property ScintillaControl.LineLength(ByVal LineNo As Integer) As Integer
	Return SendMessage(FHandle, SCI_LINELENGTH, LineNo, 0)
End Property

Private Property ScintillaControl.LineText(ByVal LineNo As Integer) ByRef As WString
	Dim s As Integer = LineLength(LineNo)
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETLINE, LineNo, Cast(LPARAM, p))
	Return TextFromSciData(*p)
End Property

Private Property ScintillaControl.LineData(ByVal LineNo As Integer) ByRef As Any Ptr
	Dim s As Integer = LineLength(LineNo)
	Static p As Any Ptr
	If p Then Deallocate(p)
	p = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETLINE, LineNo, Cast(LPARAM, p))
	Return p
End Property

Private Property ScintillaControl.Length As Integer
	Return SendMessage(FHandle, SCI_GETLENGTH, 0, 0)
End Property

Private Property ScintillaControl.Text ByRef As WString
	Dim s As Integer = Length
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETTEXT, s, Cast(LPARAM, p))
	Return TextFromSciData(*p)
End Property

Private Property ScintillaControl.Text(ByRef tData As Const WString)
	Dim p As ZString Ptr
	p = StrPtr(TextToSciData(tData))
	SendMessage(FHandle, SCI_SETTEXT, Len(*p), Cast(LPARAM, p))
End Property

Private Property ScintillaControl.SelText ByRef As WString
	Dim s As Integer = SelLength
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETSELTEXT, s, Cast(LPARAM, p))
	Return TextFromSciData(*p)
End Property

Private Property ScintillaControl.SelText(ByRef tData As Const WString)
	Dim p As ZString Ptr
	p = StrPtr(TextToSciData(tData))
	SendMessage(FHandle, SCI_REPLACESEL, Len(*p), Cast(LPARAM, p))
End Property

Private Property ScintillaControl.TxtData(tSize As Integer) ByRef As Any Ptr
	Static p As Any Ptr = NULL
	If p Then Deallocate(p)
	p = CAllocate(tSize + 1)
	SendMessage(FHandle, SCI_GETTEXT, tSize, Cast(LPARAM, p))
	Return p
End Property

Private Property ScintillaControl.TxtData(tSize As Integer, tData As Any Ptr)
	SendMessage(FHandle, SCI_SETTEXT, tSize, Cast(LPARAM, tData))
End Property

Private Property ScintillaControl.SelTxtData ByRef As Any Ptr
	Static p As Any Ptr = NULL
	If p Then Deallocate(p)
	p = CAllocate(SelLength + 1)
	SendMessage(FHandle, SCI_GETSELTEXT, 0, Cast(LPARAM, p))
	Return p
End Property

Private Property ScintillaControl.SelTxtData(tData As Any Ptr)
	SendMessage(FHandle, SCI_REPLACESEL, 0, Cast(LPARAM, tData))
End Property

Private Property ScintillaControl.DarkMode As Boolean
	Return mDarkMode
End Property

Private Property ScintillaControl.DarkMode (ByVal bVal As Boolean)
	mDarkMode = bVal
	If bVal Then
		'set white space
		SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h40, &h40, &h40, &hff))
		'SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE_BACK, RGBA(&h40, &h40, &h40, &h40))
		
		ForeColor(STYLE_DEFAULT) = RGB(&ha0, &ha0, &ha0)
		BackColor(STYLE_DEFAULT) = RGB(0, 0, 0)
		
		'ForeColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h40, &h40, &h40)
		'BackColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h10, &h10, &h10)
		
		ForeColor(STYLE_LINENUMBER) = RGB(&hFF, &h80, &h80)
		BackColor(STYLE_LINENUMBER) = RGB(&h20, &h20, &h20)
	Else
		'set white space
		SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h40, &h40, &h40, &hff))
		'SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE_BACK, RGBA(&h40, &h40, &h40, &h40))
		
		ForeColor(STYLE_DEFAULT) = RGB(0, 0, 0)
		BackColor(STYLE_DEFAULT) = RGB(255, 255, 255)
		
		'ForeColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h10, &h10, &h10)
		'BackColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h70, &h70, &h70)
		
		ForeColor(STYLE_LINENUMBER) = RGB(&hFF, &h00, &h00)
		BackColor(STYLE_LINENUMBER) = RGB(&hE0, &hE0, &hE0)
	End If
End Property

Private Property ScintillaControl.ViewWhiteSpace As Boolean
	Return SendMessage(FHandle, SCI_GETVIEWWS, 0, 0)
End Property

Private Property ScintillaControl.ViewWhiteSpace(ByVal bVal As Boolean)
	If bVal Then SendMessage(FHandle, SCI_SETVIEWWS, SCWS_VISIBLEALWAYS, 0) Else SendMessage(FHandle, SCI_SETVIEWWS, SCWS_INVISIBLE, 0)
End Property

Private Property ScintillaControl.ViewEOL As Boolean
	Return SendMessage(FHandle, SCI_GETVIEWEOL, 0, 0)
End Property

Private Property ScintillaControl.ViewEOL (ByVal bVal As Boolean)
	SendMessage(FHandle, SCI_SETVIEWEOL, bVal, 0)
End Property

Private Property ScintillaControl.ViewCaretLine As Boolean
	Return SendMessage(FHandle, SCI_GETCARETLINEVISIBLE, 0, 0)
End Property

Private Property ScintillaControl.ViewCaretLine(ByVal bVal As Boolean)
	SendMessage(FHandle, SCI_SETCARETLINEVISIBLEALWAYS, bVal, 0)
	SendMessage(FHandle, SCI_SETCARETLINEVISIBLE, bVal, 0)
	If bVal = False Then Exit Property
	CaretLineBackAlpha = &H40
	CaretLineBackColor = RGB(&h80, &h80, &h80)
End Property

Private Property ScintillaControl.ViewLineNo As Integer
	Return MarginWidth(0)
	'Return SendMessage(Handle, SCI_GETMARGINWIDTHN, 0, 0)
End Property

Private Property ScintillaControl.ViewLineNo(ByVal iSize As Integer)
	MarginWidth(0) = iSize
	'SendMessage(Handle, SCI_SETMARGINWIDTHN, 0, iSize)
End Property

Private Property ScintillaControl.ViewFold As Integer
	Return MarginWidth(1)
	'Return SendMessage(Handle, SCI_GETMARGINWIDTHN, 2, 0)
End Property

Private Property ScintillaControl.ViewFold(ByVal iSize As Integer)
	MarginWidth(1) = iSize
	'SendMessage(Handle, SCI_SETMARGINWIDTHN, 2, iSize)
End Property

Private Property ScintillaControl.MarginWidth(margin As Integer) As Integer
	Return SendMessage(FHandle, SCI_GETMARGINWIDTHN, margin, 0)
End Property

Private Property ScintillaControl.MarginWidth(margin As Integer, Val As Integer)
	If margin = 0 And Val <> 0 Then
		Dim s As String = Format(SendMessage(FHandle, SCI_GETFIRSTVISIBLELINE, 0, 0) + SendMessage(FHandle, SCI_LINESONSCREEN, 0, 0), "#0")
		SendMessage(FHandle, SCI_SETMARGINWIDTHN, margin, SendMessage(FHandle, SCI_TEXTWIDTH, STYLE_DEFAULT, Cast(LPARAM, StrPtr(s))) + 5)
	Else
		SendMessage(FHandle, SCI_SETMARGINWIDTHN, margin, Val)
	End If
End Property

Private Sub ScintillaControl.MarginColor(ByVal margin As Integer = 0, ByVal fore As Integer = -1, ByVal back As Integer = -1)
	SendMessage(FHandle, SCI_SETMARGINS, margin, 0)
	If fore <> -1 Then SendMessage(FHandle, SCI_SETFOLDMARGINHICOLOUR, True, fore)
	If back <> -1 Then SendMessage(FHandle, SCI_SETFOLDMARGINCOLOUR, True, back)
End Sub

Private Sub ScintillaControl.SelColor(ByVal fore As Integer = -1, ByVal back As Integer = -1)
	If fore <> -1 Then SendMessage(FHandle, SCI_SETSELFORE, True, fore)
	If back <> -1 Then SendMessage(FHandle, SCI_SETSELBACK, True, back)
End Sub

Private Property ScintillaControl.SelAlpha As Integer
	Return SendMessage(FHandle, SCI_GETSELALPHA, 0, 0)
End Property

Private Property ScintillaControl.SelAlpha(Val As Integer)
	SendMessage(FHandle, SCI_SETSELALPHA, Val, 0)
End Property

Private Property ScintillaControl.SelLayer As Integer
	Return SendMessage(FHandle, SCI_GETSELECTIONLAYER, 0, 0)
End Property

Private Property ScintillaControl.SelLayer(Val As Integer)
	SendMessage(FHandle, SCI_SETSELECTIONLAYER, Val, 0)
End Property

Private Function ScintillaControl.GetPosX(ByVal oPos As Integer = -1) As Integer
	Dim p As Integer = IIf(oPos < 0, Pos, oPos)
	Return p - SendMessage(FHandle, SCI_POSITIONFROMLINE, GetPosY(p), 0)
End Function

Private Function ScintillaControl.GetPosY(ByVal oPos As Integer = -1) As Integer
	Return SendMessage(FHandle, SCI_LINEFROMPOSITION, IIf(oPos < 0, Pos, oPos), 0)
End Function

Private Property ScintillaControl.SelStart As Integer
	Return SendMessage(FHandle, SCI_GETSELECTIONSTART, 0, 0)
End Property

Private Property ScintillaControl.SelStart(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETSELECTIONSTART, val, 0)
End Property

Private Property ScintillaControl.SelEnd As Integer
	Return SendMessage(FHandle, SCI_GETSELECTIONEND, 0, 0)
End Property

Private Property ScintillaControl.SelEnd(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETSELECTIONEND, val, 0)
End Property

Private Property ScintillaControl.SelLength As Integer
	Return SelEnd - SelStart
End Property

Private Property ScintillaControl.SelLength(ByVal val As Integer)
	SelEnd = SelStart + val
End Property

Private Property ScintillaControl.Pos(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCURRENTPOS, val, 0)
	SendMessage(FHandle, SCI_SETSEL, val, val)
	SelStart = val
End Property

Private Property ScintillaControl.Pos As Integer
	Return SendMessage(FHandle, SCI_GETCURRENTPOS, 0, 0)
End Property

Private Property ScintillaControl.PosX As Integer
	Return Pos - SendMessage(FHandle, SCI_POSITIONFROMLINE, PosY, 0)
End Property

Private Property ScintillaControl.PosX(ByVal val As Integer)
	Pos = SendMessage(FHandle, SCI_POSITIONFROMLINE, PosY, 0) + val
End Property

Private Property ScintillaControl.PosY As Integer
	Return SendMessage(FHandle, SCI_LINEFROMPOSITION, Pos, 0)
End Property

Private Property ScintillaControl.PosY(ByVal val As Integer)
	Pos = SendMessage(FHandle, SCI_POSITIONFROMLINE, val, 0) + PosX
End Property

Private Property ScintillaControl.UseTabs As Boolean
	Return SendMessage(Handle, SCI_GETUSETABS, 0, 0)
End Property

Private Property ScintillaControl.UseTabs (uTabs As Boolean)
	SendMessage(Handle, SCI_SETUSETABS, uTabs, 0)
End Property

Private Property ScintillaControl.TabWidth As Integer
	Return SendMessage(Handle, SCI_GETTABWIDTH, Pos, 0)
End Property

Private Property ScintillaControl.TabWidth (tWidth As Integer)
	SendMessage(Handle, SCI_SETTABWIDTH, tWidth, 0)
End Property

Private Property ScintillaControl.IndentSize As Integer
	Return SendMessage(Handle, SCI_GETINDENT, 0, 0)
End Property

Private Property ScintillaControl.IndentSize (iSize As Integer)
	SendMessage(Handle, SCI_SETINDENT, iSize, 0)
End Property

Private Property ScintillaControl.TabIndents As Boolean
	Return SendMessage(Handle, SCI_GETTABINDENTS, 0, 0)
End Property

Private Property ScintillaControl.TabIndents (tIndents As Boolean)
	SendMessage(Handle, SCI_SETTABINDENTS, tIndents, 0)
End Property


