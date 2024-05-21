#pragma once
' Scintilla
' https://www.scintilla.org/
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

#include once "Scintilla.bi"

Function TextFromSciData(ByRef txtData As Const ZString, ByVal CodePage As Integer = 0) ByRef As WString
	If CodePage = 65001 Then
		Return TextFromUtf8(txtData)
	Else
		Return TextFromAnsi(txtData)
	End If
End Function

Function TextToSciData(ByRef txtWStr As Const WString, ByVal CodePage As Integer = 0) ByRef As String
	If CodePage = 65001 Then
		Return TextToUtf8(txtWStr)
	Else
		Return TextToAnsi(txtWStr)
	End If
End Function

Type Scintilla
	Dim Handle As Any Ptr = NULL
	Dim mDarkMode As Boolean = False
	
	Declare Sub Create(ParentHandle As Any Ptr)
	
	'edit
	Declare Sub Redo()
	Declare Sub Undo()
	Declare Sub Cut()
	Declare Sub Copy()
	Declare Sub Paste()
	Declare Sub Clear()
	Declare Sub SelectAll()
	Declare Sub GotoLine(ByVal val As Integer)
	
	'search & replace
	Dim mStf As Sci_TextToFind
	Dim FindData As ZString Ptr = NULL
	Dim FindLength As Integer
	Dim FindPoses(Any) As Integer
	Dim FindLines(Any) As Integer
	Dim FindCount As Integer = -1
	Dim FindIndex As Integer = -1
	
	Declare Function IndexFind(ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False) As Integer
	Declare Function Find(ByRef FindData As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False, ByVal FindForce As Boolean = False) As Integer
	Declare Function ReplaceAll(ByRef FindData As Const ZString Ptr, ByRef ReplaceData As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False) As Integer
	
	'Indicator
	Declare Sub IndicatorClear()
	Declare Sub IndicatorSet(IndiPoses(Any) As Integer, ByVal IndiLength As Integer)
	Declare Property IndicatorSel As Integer
	Declare Property IndicatorSel(Val As Integer)
	
	'setting
	Declare Property EOLMode As Integer
	Declare Property EOLMode(ByVal val As Integer)
	Declare Property CodePage As Integer
	Declare Property CodePage(ByVal val As Integer)
	Declare Property CharSet(ByVal sty As Integer) As Integer
	Declare Property CharSet(ByVal sty As Integer, val As Integer)
	Declare Property WordWrap As Integer
	Declare Property WordWrap(ByVal val As Integer)
	
	Declare Property BackColor(ByVal sty As Integer) As Integer
	Declare Property BackColor(ByVal sty As Integer, ByVal val As Integer)
	Declare Property ForeColor(ByVal sty As Integer) As Integer
	Declare Property ForeColor(ByVal sty As Integer, ByVal val As Integer)
	Declare Property FontSize(ByVal sty As Integer) As Integer
	Declare Property FontSize(ByVal sty As Integer, ByVal val As Integer)
	Declare Property FontName(ByVal sty As Integer) ByRef As WString
	Declare Property FontName(ByVal sty As Integer, ByRef val As Const WString)
	
	Declare Property Bold(ByVal sty As Integer) As Integer
	Declare Property Bold(ByVal sty As Integer, ByVal val As Integer)
	Declare Property Italic(ByVal sty As Integer) As Integer
	Declare Property Italic(ByVal sty As Integer, ByVal val As Integer)
	Declare Property Underline(ByVal sty As Integer) As Integer
	Declare Property Underline(ByVal sty As Integer, ByVal val As Integer)
	
	Declare Property Zoom As Integer
	Declare Property Zoom(ByVal val As Integer)
	
	Declare Property CaretLineBackAlpha As Integer
	Declare Property CaretLineBackAlpha(ByVal val As Integer)
	Declare Property CaretLineBackColor As Integer
	Declare Property CaretLineBackColor(ByVal val As Integer)
	
	'text
	Declare Property LineCount As Integer
	Declare Property LineStart(ByVal LineNo As Integer) As Integer
	Declare Property LineEnd(ByVal LineNo As Integer) As Integer
	Declare Property LineLength(ByVal LineNo As Integer) As Integer
	Declare Property LineData(ByVal LineNo As Integer) ByRef As Any Ptr
	Declare Property LineText(ByVal LineNo As Integer) ByRef As WString
	
	Declare Property Length As Integer
	Declare Property Text ByRef As WString
	Declare Property Text(ByRef tData As Const WString)
	Declare Property SelText ByRef As WString
	Declare Property SelText(ByRef tData As Const WString)
	
	Declare Property TxtData(tSize As Integer) ByRef As Any Ptr
	Declare Property TxtData(tSize As Integer, tData As Any Ptr)
	Declare Property SelTxtData ByRef As Any Ptr
	Declare Property SelTxtData(tData As Any Ptr)
	
	'view
	Declare Property DarkMode As Boolean
	Declare Property DarkMode (ByVal val As Boolean)
	Declare Property ViewWhiteSpace As Boolean
	Declare Property ViewWhiteSpace(ByVal val As Boolean)
	Declare Property ViewEOL As Boolean
	Declare Property ViewEOL (ByVal val As Boolean)
	Declare Property ViewCaretLine As Boolean
	Declare Property ViewCaretLine(ByVal val As Boolean)
	Declare Property ViewLineNo As Integer
	Declare Property ViewLineNo(ByVal val As Integer)
	Declare Property ViewFold As Integer
	Declare Property ViewFold(ByVal val As Integer)
	
	Declare Property Margins() As Integer
	Declare Property Margins(margin As Integer)
	Declare Property MarginWidth(margin As Integer) As Integer
	Declare Property MarginWidth(margin As Integer, Val As Integer)
	Declare Sub MarginColor(ByVal margin As Integer = -1, ByVal fore As Integer = -1, ByVal back As Integer = -1)
	
	'selection
	Declare Sub SelColor(ByVal fore As Integer = -1, ByVal back As Integer = -1)
	Declare Property SelAlpha As Integer
	Declare Property SelAlpha(Val As Integer)
	Declare Property SelLayer As Integer
	Declare Property SelLayer(Val As Integer)
	
	Declare Function GetPosX(ByVal oPos As Integer = -1) As Integer
	Declare Function GetPosY(ByVal oPos As Integer = -1) As Integer
	Declare Property SelStart As Integer
	Declare Property SelStart(ByVal val As Integer)
	Declare Property SelEnd As Integer
	Declare Property SelEnd(ByVal val As Integer)
	Declare Property SelLength As Integer
	Declare Property SelLength(ByVal val As Integer)
	Declare Property Pos(ByVal val As Integer)
	Declare Property Pos As Integer
	Declare Property PosX As Integer
	Declare Property PosX(ByVal val As Integer)
	Declare Property PosY As Integer
	Declare Property PosY(ByVal val As Integer)
	
	Declare Constructor
	Declare Destructor
End Type

Constructor Scintilla
	
End Constructor

Destructor Scintilla
	If Handle Then DestroyWindow(Handle)
	Handle = NULL
End Destructor

Private Sub Scintilla.Create(ParentHandle As Any Ptr)
	' Creates a Scintilla editing window
	Dim rt As Rect
	GetClientRect(ParentHandle, @rt)
	Dim As Integer lExStyle = 0
	Dim As Integer lStyle = WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or WS_BORDER
	Handle = CreateWindowEx(lExStyle, "Scintilla", 0, lStyle, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, ParentHandle, NULL, 0, 0)
	
	'font quality (antialiasing method)
	'SendMessage(Handle, SCI_SETFONTQUALITY, SC_EFF_QUALITY_LCD_OPTIMIZED, 0)
	
	'set margin 0 as linenumber
	SendMessage(Handle, SCI_SETMARGINTYPEN, 0, SC_MARGIN_NUMBER)
	'SendMessage(Handle, SCI_SETMARGINMASKN, 0, STYLE_LINENUMBER)
	MarginWidth(0) = 35
	
	'set margin 1 as fold
	SendMessage(Handle, SCI_SETMARGINTYPEN, 1, SC_MARGIN_SYMBOL)
	'SendMessage(Handle, SCI_SETMARGINMASKN, 1, SC_MASK_FOLDERS)
	MarginWidth(1) = 0
	
	'set when text is pasted any line ends are converted to match the document's end of line mode
	SendMessage(Handle, SCI_SETPASTECONVERTENDINGS, True, 0)
	
	CodePage = 0
	CharSet(STYLE_DEFAULT) = SC_CHARSET_DEFAULT
	
	'set indicator style & color
	'indicator 0 for find
	SendMessage(Handle, SCI_INDICSETUNDER, 0, True)
	SendMessage(Handle, SCI_INDICSETSTYLE, 0, INDIC_FULLBOX)
	SendMessage(Handle, SCI_INDICSETALPHA, 0, &h40)
	SendMessage(Handle, SCI_INDICSETOUTLINEALPHA, 0, &hff)
	
	'set select style
	SendMessage(Handle, SCI_HIDESELECTION, False, 0)
	SendMessage(Handle, SCI_SETSELECTIONLAYER, SC_LAYER_UNDER_TEXT, 0)
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_TEXT, RGBA(&hff, &hff, &hff, &hff))
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK, RGBA(&hff, &h40, &h40, &hff))
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_INACTIVE_TEXT, RGBA(&hff, &hff, &hff, &hff))
	SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_INACTIVE_BACK, RGBA(&h40, &h40, &hff, &hff))
	
	'set white space
	'SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h80, &h80, &h80, &h80))
	
	'set caretline layer
	SendMessage(Handle, SCI_SETCARETLINELAYER, SC_LAYER_BASE, 0)
	
	'set an event mask that determines which document change events are notified to the container with SCN_MODIFIED and SCEN_CHANGE
	SendMessage(Handle, SCI_SETMODEVENTMASK, SC_MOD_INSERTTEXT Or SC_MOD_DELETETEXT, 0)
	
	DarkMode = False
End Sub

Private Function Scintilla.IndexFind(ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False) As Integer
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

Private Function Scintilla.Find(ByRef toFind As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal MoveNext As Boolean = False, ByVal FindForce As Boolean = False) As Integer
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
			mStart = SendMessage(Handle, SCI_FINDTEXT, mc, Cast(LPARAM, @mStf))
			If mStart < 0 Then Exit Do
			
			FindCount += 1
			ReDim Preserve FindPoses(FindCount)
			FindPoses(FindCount)=mStart
			ReDim Preserve FindLines(FindCount)
			FindLines(FindCount) = SendMessage(Handle, SCI_LINEFROMPOSITION, mStart, 0)
			mStf.chrg.cpMin = mStart + FindLength
			App.DoEvents
		Loop While mStart <> -1
		IndicatorSet(FindPoses(), FindLength)
	End If
	IndexFind(FindWarp, FindBack, MoveNext)
	
	Return FindCount
End Function

Private Function Scintilla.ReplaceAll(ByRef FindData As Const ZString Ptr, ByRef ReplaceData As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False) As Integer
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

Private Property Scintilla.IndicatorSel As Integer
	Return SendMessage(Handle, SCI_GETINDICATORCURRENT, 0, 0)
End Property

Private Property Scintilla.IndicatorSel(val As Integer)
	If val >= 0 And val <= INDICATOR_MAX Then SendMessage(Handle, SCI_SETINDICATORCURRENT, val, 0)
End Property

Private Sub Scintilla.IndicatorClear()
	SendMessage(Handle, SCI_INDICATORCLEARRANGE, 0, Length)
End Sub

Private Sub Scintilla.IndicatorSet(IndiPoses(Any) As Integer, ByVal IndiLength As Integer)
	IndicatorClear()
	Dim i As Long
	For i = 0 To UBound(IndiPoses)
		SendMessage(Handle, SCI_INDICATORFILLRANGE, IndiPoses(i), IndiLength)
	Next
End Sub

Private Property Scintilla.WordWrap As Integer
	Return SendMessage(Handle, SCI_GETWRAPMODE, 0, 0)
End Property

Private Property Scintilla.WordWrap(val As Integer)
	SendMessage(Handle, SCI_SETWRAPMODE, val, 0)
End Property

Private Property Scintilla.EOLMode As Integer
	Return SendMessage(Handle, SCI_GETEOLMODE, 0, 0)
End Property

Private Property Scintilla.EOLMode(ByVal val As Integer)
	SendMessage(Handle, SCI_SETEOLMODE, val, 0)
	SendMessage(Handle, SCI_CONVERTEOLS, val, 0)
End Property

Private Property Scintilla.CodePage As Integer
	Return SendMessage(Handle, SCI_GETCODEPAGE, 0, 0)
End Property

Private Property Scintilla.CodePage(ByVal val As Integer)
	SendMessage(Handle, SCI_SETCODEPAGE, val, 0)
End Property

Private Property Scintilla.CharSet(ByVal sty As Integer) As Integer
	Return SendMessage(Handle, SCI_STYLEGETCHARACTERSET, sty, 0)
End Property

Private Property Scintilla.CharSet(ByVal sty As Integer, ByVal Val As Integer)
	SendMessage(Handle, SCI_STYLESETCHARACTERSET, sty, Val)
End Property

Private Property Scintilla.BackColor(ByVal sty As Integer) As Integer
	Return SendMessage(Handle, SCI_STYLEGETBACK, sty, 0)
End Property

Private Property Scintilla.BackColor(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(Handle, SCI_STYLESETBACK, sty, val)
	If sty = STYLE_DEFAULT Then SendMessage(Handle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.ForeColor(ByVal sty As Integer) As Integer
	Return SendMessage(Handle, SCI_STYLEGETFORE, sty, 0)
End Property

Private Property Scintilla.ForeColor(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(Handle, SCI_STYLESETFORE, sty, val)
	If sty = STYLE_DEFAULT Then SendMessage(Handle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.FontSize(ByVal sty As Integer) As Integer
	Return SendMessage(Handle, SCI_STYLEGETSIZE, sty, 0)
End Property

Private Property Scintilla.FontSize(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(Handle, SCI_STYLESETSIZE, sty, val)
	'SendMessage(Handle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.FontName(ByVal sty As Integer) ByRef As WString
	Static a As WString Ptr
	If a Then Deallocate(a)
	
	Dim s As Integer = SendMessage(Handle, SCI_STYLEGETFONT, sty, 0)
	a = CAllocate(s * 2)
	Dim b As ZString Ptr
	b = CAllocate(s)
	SendMessage(Handle, SCI_STYLEGETFONT, sty, Cast(LPARAM, b))
	TextAnsi2Unicode(*b, a)
	If b Then Deallocate(b)
	
	Return *a
End Property

Private Property Scintilla.FontName(ByVal sty As Integer, ByRef val As Const WString)
	Dim b As ZString Ptr
	Dim s As Integer = Len(val)
	b = CAllocate(s)
	*b = TextUnicode2Ansi(val)
	
	SendMessage(Handle, SCI_STYLESETFONT, sty, Cast(LPARAM, b))
	'SendMessage(Handle, SCI_STYLECLEARALL, 0, 0)
	
	If b Then Deallocate(b)
End Property

Private Property Scintilla.Bold(ByVal sty As Integer) As Integer
	Return SendMessage(Handle, SCI_STYLEGETBOLD, sty, 0)
End Property

Private Property Scintilla.Bold(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(Handle, SCI_STYLESETBOLD, sty, val)
	'SendMessage(Handle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.Italic(ByVal sty As Integer) As Integer
	Return SendMessage(Handle, SCI_STYLEGETITALIC, sty, 0)
End Property

Private Property Scintilla.Italic(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(Handle, SCI_STYLESETITALIC, sty, val)
	'SendMessage(Handle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.Underline(ByVal sty As Integer) As Integer
	Return SendMessage(Handle, SCI_STYLEGETUNDERLINE, sty, 0)
End Property

Private Property Scintilla.Underline(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(Handle, SCI_STYLESETUNDERLINE, sty, val)
	'SendMessage(Handle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.Zoom As Integer
	Return SendMessage(Handle, SCI_GETZOOM, 0, 0)
End Property

Private Property Scintilla.Zoom(ByVal val As Integer)
	SendMessage(Handle, SCI_SETZOOM, val, 0)
End Property

Private Property Scintilla.CaretLineBackAlpha As Integer
	Return SendMessage(Handle, SCI_GETCARETLINEBACKALPHA, 0, 0)
End Property

Private Property Scintilla.CaretLineBackAlpha(ByVal val As Integer)
	SendMessage(Handle, SCI_SETCARETLINEBACKALPHA, val, 0)
End Property

Private Property Scintilla.CaretLineBackColor As Integer
	Return SendMessage(Handle, SCI_GETCARETLINEBACK, 0, 0)
End Property

Private Property Scintilla.CaretLineBackColor(ByVal val As Integer)
	SendMessage(Handle, SCI_SETCARETLINEBACK, val, 0)
End Property

Private Sub Scintilla.Redo()
	SendMessage(Handle, SCI_REDO, 0, 0)
End Sub

Private Sub Scintilla.Undo()
	SendMessage(Handle, SCI_UNDO, 0, 0)
End Sub

Private Sub Scintilla.Cut()
	SendMessage(Handle, SCI_CUT, 0, 0)
End Sub

Private Sub Scintilla.Copy()
	SendMessage(Handle, SCI_COPY, 0, 0)
End Sub

Private Sub Scintilla.Paste()
	SendMessage(Handle, SCI_PASTE, 0, 0)
End Sub

Private Sub Scintilla.Clear()
	SendMessage(Handle, SCI_CLEAR, 0, 0)
End Sub

Private Sub Scintilla.GotoLine(ByVal val As Integer)
	SendMessage(Handle, SCI_GOTOLINE, val, 0)
End Sub

Private Sub Scintilla.SelectAll()
	SendMessage(Handle, SCI_SELECTALL, 0, 0)
End Sub

Private Property Scintilla.LineCount As Integer
	Return SendMessage(Handle, SCI_GETLINECOUNT, 0, 0)
End Property

Private Property Scintilla.LineStart(ByVal LineNo As Integer) As Integer
	Return SendMessage(Handle, SCI_GETLINEENDPOSITION, LineNo, 0)
End Property

Private Property Scintilla.LineEnd(ByVal LineNo As Integer) As Integer
	Return SendMessage(Handle, SCI_GETLINEENDPOSITION, LineNo, 0)
End Property

Private Property Scintilla.LineLength(ByVal LineNo As Integer) As Integer
	Return SendMessage(Handle, SCI_LINELENGTH, LineNo, 0)
End Property

Private Property Scintilla.LineText(ByVal LineNo As Integer) ByRef As WString
	Dim s As Integer = LineLength(LineNo)
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(Handle, SCI_GETLINE, LineNo, Cast(LPARAM, p))
	Return TextFromSciData(*p)
End Property

Private Property Scintilla.LineData(ByVal LineNo As Integer) ByRef As Any Ptr
	Dim s As Integer = LineLength(LineNo)
	Static p As Any Ptr
	If p Then Deallocate(p)
	p = CAllocate(s + 1)
	SendMessage(Handle, SCI_GETLINE, LineNo, Cast(LPARAM, p))
	Return p
End Property

Private Property Scintilla.Length As Integer
	Return SendMessage(Handle, SCI_GETLENGTH, 0, 0)
End Property

Private Property Scintilla.Text ByRef As WString
	Dim s As Integer = Length
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(Handle, SCI_GETTEXT, s, Cast(LPARAM, p))
	Return TextFromSciData(*p)
End Property

Private Property Scintilla.Text(ByRef tData As Const WString)
	Dim p As ZString Ptr
	p = StrPtr(TextToSciData(tData))
	SendMessage(Handle, SCI_SETTEXT, Len(*p), Cast(LPARAM, p))
End Property

Private Property Scintilla.SelText ByRef As WString
	Dim s As Integer = SelLength
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(Handle, SCI_GETSELTEXT, s, Cast(LPARAM, p))
	Return TextFromSciData(*p)
End Property

Private Property Scintilla.SelText(ByRef tData As Const WString)
	Dim p As ZString Ptr
	p = StrPtr(TextToSciData(tData))
	SendMessage(Handle, SCI_REPLACESEL, Len(*p), Cast(LPARAM, p))
End Property

Private Property Scintilla.TxtData(tSize As Integer) ByRef As Any Ptr
	Static p As Any Ptr = NULL
	If p Then Deallocate(p)
	p = CAllocate(tSize + 1)
	SendMessage(Handle, SCI_GETTEXT, tSize, Cast(LPARAM, p))
	Return p
End Property

Private Property Scintilla.TxtData(tSize As Integer, tData As Any Ptr)
	SendMessage(Handle, SCI_SETTEXT, tSize, Cast(LPARAM, tData))
End Property

Private Property Scintilla.SelTxtData ByRef As Any Ptr
	Static p As Any Ptr = NULL
	If p Then Deallocate(p)
	p = CAllocate(SelLength + 1)
	SendMessage(Handle, SCI_GETSELTEXT, 0, Cast(LPARAM, p))
	Return p
End Property

Private Property Scintilla.SelTxtData(tData As Any Ptr)
	SendMessage(Handle, SCI_REPLACESEL, 0, Cast(LPARAM, tData))
End Property

Private Property Scintilla.DarkMode As Boolean
	Return mDarkMode
End Property

Private Property Scintilla.DarkMode (ByVal bVal As Boolean)
	mDarkMode = bVal
	If bVal Then
		'set white space
		SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h40, &h40, &h40, &h40))
		
		ForeColor(STYLE_DEFAULT) = RGB(&ha0, &ha0, &ha0)
		BackColor(STYLE_DEFAULT) = RGB(0, 0, 0)
		
		'ForeColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h40, &h40, &h40)
		'BackColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h10, &h10, &h10)
		
		ForeColor(STYLE_LINENUMBER) = RGB(&hFF, &h80, &h80)
		BackColor(STYLE_LINENUMBER) = RGB(&h20, &h20, &h20)
	Else
		'set white space
		SendMessage(Handle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h40, &h40, &h40, &h40))
		
		ForeColor(STYLE_DEFAULT) = RGB(0, 0, 0)
		BackColor(STYLE_DEFAULT) = RGB(255, 255, 255)
		
		'ForeColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h10, &h10, &h10)
		'BackColor(STYLE_FOLDDISPLAYTEXT) = RGB(&h70, &h70, &h70)
		
		ForeColor(STYLE_LINENUMBER) = RGB(&hFF, &h00, &h00)
		BackColor(STYLE_LINENUMBER) = RGB(&hE0, &hE0, &hE0)
	End If
	If bVal Then
		SetWindowTheme(Handle, "DarkMode_Explorer", nullptr)
	Else
		SetWindowTheme(Handle, NULL, NULL)
	End If
End Property

Private Property Scintilla.ViewWhiteSpace As Boolean
	Return SendMessage(Handle, SCI_GETVIEWWS, 0, 0)
End Property

Private Property Scintilla.ViewWhiteSpace(ByVal bVal As Boolean)
	If bVal Then SendMessage(Handle, SCI_SETVIEWWS, SCWS_VISIBLEALWAYS, 0) Else SendMessage(Handle, SCI_SETVIEWWS, SCWS_INVISIBLE, 0)
End Property

Private Property Scintilla.ViewEOL As Boolean
	Return SendMessage(Handle, SCI_GETVIEWEOL, 0, 0)
End Property

Private Property Scintilla.ViewEOL (ByVal bVal As Boolean)
	SendMessage(Handle, SCI_SETVIEWEOL, bVal, 0)
End Property

Private Property Scintilla.ViewCaretLine As Boolean
	Return SendMessage(Handle, SCI_GETCARETLINEVISIBLE, 0, 0)
End Property

Private Property Scintilla.ViewCaretLine(ByVal bVal As Boolean)
	SendMessage(Handle, SCI_SETCARETLINEVISIBLEALWAYS, bVal, 0)
	SendMessage(Handle, SCI_SETCARETLINEVISIBLE, bVal, 0)
	If bVal = False Then Exit Property 
	CaretLineBackAlpha = &H40
	CaretLineBackColor = RGB(&h80, &h80, &h80)
End Property

Private Property Scintilla.ViewLineNo As Integer
	Return MarginWidth(0)
	'Return SendMessage(Handle, SCI_GETMARGINWIDTHN, 0, 0)
End Property

Private Property Scintilla.ViewLineNo(ByVal iSize As Integer)
	MarginWidth(0) = iSize
	'SendMessage(Handle, SCI_SETMARGINWIDTHN, 0, iSize)
End Property

Private Property Scintilla.ViewFold As Integer
	Return MarginWidth(1)
	'Return SendMessage(Handle, SCI_GETMARGINWIDTHN, 2, 0)
End Property

Private Property Scintilla.ViewFold(ByVal iSize As Integer)
	MarginWidth(1) = iSize
	'SendMessage(Handle, SCI_SETMARGINWIDTHN, 2, iSize)
End Property

Private Property Scintilla.Margins() As Integer
	Return SendMessage(Handle, SCI_GETMARGINS, 0, 0)
End Property

Private Property Scintilla.Margins(margin As Integer)
	SendMessage(Handle, SCI_SETMARGINS, margin, 0)
End Property

Private Property Scintilla.MarginWidth(margin As Integer) As Integer
	Return SendMessage(Handle, SCI_GETMARGINWIDTHN, margin, 0)
End Property

Private Property Scintilla.MarginWidth(margin As Integer, Val As Integer)
	If margin = 0 And Val <> 0 Then
		Dim s As String = Format(SendMessage(Handle, SCI_GETFIRSTVISIBLELINE, 0, 0) + SendMessage(Handle, SCI_LINESONSCREEN, 0, 0), "#0")
		SendMessage(Handle, SCI_SETMARGINWIDTHN, margin, SendMessage(Handle, SCI_TEXTWIDTH, STYLE_LINENUMBER, Cast(LPARAM, StrPtr(s))) + 5)
	Else
		SendMessage(Handle, SCI_SETMARGINWIDTHN, margin, Val)
	End If
End Property

Private Sub Scintilla.MarginColor(ByVal margin As Integer = -1, ByVal fore As Integer = -1, ByVal back As Integer = -1)
	If margin <>-1 Then Margins = margin
	If fore <> -1 Then SendMessage(Handle, SC_MARGIN_FORE, fore, 0)
	If back <> -1 Then SendMessage(Handle, SC_MARGIN_BACK, back, 0)
	'If fore <> -1 Then SendMessage(Handle, SCI_SETFOLDMARGINHICOLOUR, True, fore)
	'If back <> -1 Then SendMessage(Handle, SCI_SETFOLDMARGINCOLOUR, True, back)
End Sub

Private Sub Scintilla.SelColor(ByVal fore As Integer = -1, ByVal back As Integer = -1)
	If fore <> -1 Then SendMessage(Handle, SCI_SETSELFORE, True, fore)
	If back <> -1 Then SendMessage(Handle, SCI_SETSELBACK, True, back)
End Sub

Private Property Scintilla.SelAlpha As Integer
	Return SendMessage(Handle, SCI_GETSELALPHA, 0, 0)
End Property

Private Property Scintilla.SelAlpha(Val As Integer)
	SendMessage(Handle, SCI_SETSELALPHA, Val, 0)
End Property

Private Property Scintilla.SelLayer As Integer
	Return SendMessage(Handle, SCI_GETSELECTIONLAYER, 0, 0)
End Property

Private Property Scintilla.SelLayer(Val As Integer)
	SendMessage(Handle, SCI_SETSELECTIONLAYER, Val, 0)
End Property

Private Function Scintilla.GetPosX(ByVal oPos As Integer = -1) As Integer
	Dim p As Integer = IIf(oPos < 0, Pos, oPos)
	Return p - SendMessage(Handle, SCI_POSITIONFROMLINE, GetPosY(p), 0)
End Function

Private Function Scintilla.GetPosY(ByVal oPos As Integer = -1) As Integer
	Return SendMessage(Handle, SCI_LINEFROMPOSITION, IIf(oPos < 0, Pos, oPos), 0)
End Function

Private Property Scintilla.SelStart As Integer
	Return SendMessage(Handle, SCI_GETSELECTIONSTART, 0, 0)
End Property

Private Property Scintilla.SelStart(ByVal val As Integer)
	SendMessage(Handle, SCI_SETSELECTIONSTART, val, 0)
End Property

Private Property Scintilla.SelEnd As Integer
	Return SendMessage(Handle, SCI_GETSELECTIONEND, 0, 0)
End Property

Private Property Scintilla.SelEnd(ByVal val As Integer)
	SendMessage(Handle, SCI_SETSELECTIONEND, val, 0)
End Property

Private Property Scintilla.SelLength As Integer
	Return SelEnd - SelStart
End Property

Private Property Scintilla.SelLength(ByVal val As Integer)
	SelEnd = SelStart + val
End Property

Private Property Scintilla.Pos(ByVal val As Integer)
	SendMessage(Handle, SCI_SETCURRENTPOS, val, 0)
	SendMessage(Handle, SCI_SETSEL, val, val)
	SelStart = val
End Property

Private Property Scintilla.Pos As Integer
	Return SendMessage(Handle, SCI_GETCURRENTPOS, 0, 0)
End Property

Private Property Scintilla.PosX As Integer
	Return Pos - SendMessage(Handle, SCI_POSITIONFROMLINE, PosY, 0)
End Property

Private Property Scintilla.PosX(ByVal val As Integer)
	Pos = SendMessage(Handle, SCI_POSITIONFROMLINE, PosY, 0) + val
End Property

Private Property Scintilla.PosY As Integer
	Return SendMessage(Handle, SCI_LINEFROMPOSITION, Pos, 0)
End Property

Private Property Scintilla.PosY(ByVal val As Integer)
	Pos = SendMessage(Handle, SCI_POSITIONFROMLINE, val, 0) + PosX
End Property
