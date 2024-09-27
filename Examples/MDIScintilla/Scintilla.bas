' Scintilla
' https://www.scintilla.org/
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#pragma once
#include once "Scintilla.bi"

Function TextFromSciData(ByRef txtData As Const ZString, ByRef pText As WString Ptr, ByVal CodePage As Integer = 0) As Integer
	If CodePage = 65001 Then
		TextFromUtf8(txtData, pText)
	Else
		TextFromAnsi(txtData, pText)
	End If
	Return 0
End Function

Function TextToSciData(ByRef txtWStr As Const WString, ByRef SciData As ZString Ptr, ByVal CodePage As Integer = 0) As Integer
	If CodePage = 65001 Then
		TextToUtf8(txtWStr, SciData)
	Else
		TextToAnsi(txtWStr, SciData)
	End If
	Return 0
End Function

Type Scintilla
	Dim FHandle As Any Ptr = NULL
	Dim mDarkMode As Boolean = False
	
	'others
	Declare Sub Create(ParentFHandle As Any Ptr)
	Declare Property Handle As Any Ptr
	
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
	
	'indicator
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
	Declare Property WordWraps As Integer
	Declare Property WordWraps(ByVal val As Integer)
	
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
	
	'tab and indentation
	Declare Property UseTabs As Boolean
	Declare Property UseTabs (uTabs As Boolean)
	Declare Property TabWidth As Integer
	Declare Property TabWidth (tWidth As Integer)
	Declare Property IndentSize As Integer
	Declare Property IndentSize (iSize As Integer)
	Declare Property TabIndents As Boolean
	Declare Property TabIndents (tIndents As Boolean)
	
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
	
	'margin
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
	Declare Property SelStart As Integer
	Declare Property SelStart(ByVal val As Integer)
	Declare Property SelEnd As Integer
	Declare Property SelEnd(ByVal val As Integer)
	Declare Property SelLength As Integer
	Declare Property SelLength(ByVal val As Integer)
	
	'position
	Declare Function GetPosX(ByVal oPos As Integer = -1) As Integer
	Declare Function GetPosY(ByVal oPos As Integer = -1) As Integer
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
	If FHandle Then DestroyWindow(FHandle)
	FHandle = NULL
End Destructor

Private Property Scintilla.Handle As Any Ptr
	Return FHandle
End Property

Private Sub Scintilla.Create(ParentFHandle As Any Ptr)
	' Creates a Scintilla editing window
	Dim rt As Rect
	GetClientRect(ParentFHandle, @rt)
	Dim As Integer lExStyle = 0
	Dim As Integer lStyle = WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or WS_BORDER
	FHandle = CreateWindowEx(lExStyle, "Scintilla", 0, lStyle, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, ParentFHandle, NULL, 0, 0)
	
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
	
	'set indicator style & color
	'indicator 0 for find
	SendMessage(FHandle, SCI_INDICSETUNDER, 0, True)
	SendMessage(FHandle, SCI_INDICSETSTYLE, 0, INDIC_FULLBOX)
	SendMessage(FHandle, SCI_INDICSETALPHA, 0, &h40)
	SendMessage(FHandle, SCI_INDICSETOUTLINEALPHA, 0, &hff)
	
	'set select style
	SendMessage(FHandle, SCI_HIDESELECTION, False, 0)
	SendMessage(FHandle, SCI_SETSELECTIONLAYER, SC_LAYER_UNDER_TEXT, 0)
	SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_TEXT, RGBA(&hff, &hff, &hff, &hff))
	SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK, RGBA(&hff, &h40, &h40, &hff))
	SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_INACTIVE_TEXT, RGBA(&hff, &hff, &hff, &hff))
	SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_INACTIVE_BACK, RGBA(&h40, &h40, &hff, &hff))
	
	'set white space
	'SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h80, &h80, &h80, &h80))
	
	'set caretline layer
	SendMessage(FHandle, SCI_SETCARETLINELAYER, SC_LAYER_BASE, 0)
	
	'set an event mask that determines which document change events are notified to the container with SCN_MODIFIED and SCEN_CHANGE
	SendMessage(FHandle, SCI_SETMODEVENTMASK, SC_MOD_INSERTTEXT Or SC_MOD_DELETETEXT, 0)
	
	'Disable scintilla vertical scroll bar (wParam = 1 to enable)
	'SendMessage(FHandle, SCI_SETVSCROLLBAR, 0, 0)
	'SendMessage(FHandle, SCI_SETHSCROLLBAR, 0, 0)
	
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
			mStart = SendMessage(FHandle, SCI_FINDTEXT, mc, Cast(LPARAM, @mStf))
			If mStart < 0 Then Exit Do
			
			FindCount += 1
			ReDim Preserve FindPoses(FindCount)
			FindPoses(FindCount)=mStart
			ReDim Preserve FindLines(FindCount)
			FindLines(FindCount) = SendMessage(FHandle, SCI_LINEFROMPOSITION, mStart, 0)
			mStf.chrg.cpMin = mStart + FindLength
			App.DoEvents
		Loop While mStart <> -1
		IndicatorSet(FindPoses(), FindLength)
	End If
	IndexFind(FindWarp, FindBack, MoveNext)
	
	Return FindCount
End Function

Private Function Scintilla.ReplaceAll(ByRef FindData As Const ZString Ptr, ByRef ReplaceData As Const ZString Ptr, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False) As Integer
	SendMessage(FHandle, SCI_TARGETWHOLEDOCUMENT, 0, 0)
	
	Dim mc As Integer = IIf(MatchCase, SCFIND_MATCHCASE, SCFIND_NONE)
	mc = IIf(RegularExp, mc Or SCFIND_REGEXP Or SCFIND_POSIX Or SCFIND_CXX11REGEX, mc )
	SendMessage(FHandle, SCI_SETSEARCHFLAGS, mc, 0)
	
	Dim targetstart As Integer = 0
	Dim targetend As Integer = Length
	Dim lenSearch As Integer = Len(*FindData)
	Dim lenReplace As Integer = Len(*ReplaceData)
	Dim replacecount As Integer = -1
	Dim findpos As Integer
	Do
		SendMessage(FHandle, SCI_SETTARGETSTART, targetstart, 0)
		SendMessage(FHandle, SCI_SETTARGETEND, targetend, 0)
		findpos = SendMessage(FHandle, SCI_SEARCHINTARGET, lenSearch, Cast(LPARAM, FindData))
		If findpos < 0 Then Exit Do
		SendMessage(FHandle, SCI_REPLACETARGET, lenReplace, Cast(LPARAM, ReplaceData))
		replacecount += 1
		targetstart = findpos + lenReplace
		targetend = Length
	Loop While findpos > -1
	Return replacecount
End Function

Private Property Scintilla.IndicatorSel As Integer
	Return SendMessage(FHandle, SCI_GETINDICATORCURRENT, 0, 0)
End Property

Private Property Scintilla.IndicatorSel(val As Integer)
	If val >= 0 And val <= INDICATOR_MAX Then SendMessage(FHandle, SCI_SETINDICATORCURRENT, val, 0)
End Property

Private Sub Scintilla.IndicatorClear()
	SendMessage(FHandle, SCI_INDICATORCLEARRANGE, 0, Length)
End Sub

Private Sub Scintilla.IndicatorSet(IndiPoses(Any) As Integer, ByVal IndiLength As Integer)
	IndicatorClear()
	Dim i As Long
	For i = 0 To UBound(IndiPoses)
		SendMessage(FHandle, SCI_INDICATORFILLRANGE, IndiPoses(i), IndiLength)
	Next
End Sub

Private Property Scintilla.WordWraps As Integer
	Return SendMessage(FHandle, SCI_GETWRAPMODE, 0, 0)
End Property

Private Property Scintilla.WordWraps(val As Integer)
	SendMessage(FHandle, SCI_SETWRAPMODE, val, 0)
End Property

Private Property Scintilla.EOLMode As Integer
	Return SendMessage(FHandle, SCI_GETEOLMODE, 0, 0)
End Property

Private Property Scintilla.EOLMode(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETEOLMODE, val, 0)
	SendMessage(FHandle, SCI_CONVERTEOLS, val, 0)
End Property

Private Property Scintilla.CodePage As Integer
	Return SendMessage(FHandle, SCI_GETCODEPAGE, 0, 0)
End Property

Private Property Scintilla.CodePage(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCODEPAGE, val, 0)
End Property

Private Property Scintilla.CharSet(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETCHARACTERSET, sty, 0)
End Property

Private Property Scintilla.CharSet(ByVal sty As Integer, ByVal Val As Integer)
	SendMessage(FHandle, SCI_STYLESETCHARACTERSET, sty, Val)
End Property

Private Property Scintilla.BackColor(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETBACK, sty, 0)
End Property

Private Property Scintilla.BackColor(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETBACK, sty, val)
	If sty = STYLE_DEFAULT Then SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.ForeColor(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETFORE, sty, 0)
End Property

Private Property Scintilla.ForeColor(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETFORE, sty, val)
	If sty = STYLE_DEFAULT Then SendMessage(FHandle, SCI_STYLECLEARALL, 0, 0)
End Property

Private Property Scintilla.FontSize(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETSIZE, sty, 0)
End Property

Private Property Scintilla.FontSize(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETSIZE, sty, val)
End Property

Private Property Scintilla.FontName(ByVal sty As Integer) ByRef As WString
	Dim iSize As Integer = SendMessage(FHandle, SCI_STYLEGETFONT, sty, 0)
	Dim a As ZString Ptr
	a = CAllocate(iSize)
	SendMessage(FHandle, SCI_STYLEGETFONT, sty, Cast(LPARAM, a))
	
	Dim w As UString
	TextFromAnsi(*a, w)
	If a Then Deallocate(a)
	Return *Cast(WString Ptr,w.vptr)
End Property

Private Property Scintilla.FontName(ByVal sty As Integer, ByRef val As Const WString)
	Dim a As ZString Ptr
	TextToAnsi(val, a)
	SendMessage(FHandle, SCI_STYLESETFONT, sty, Cast(LPARAM, a))
	If a Then Deallocate(a)
End Property

Private Property Scintilla.Bold(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETBOLD, sty, 0)
End Property

Private Property Scintilla.Bold(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETBOLD, sty, val)
End Property

Private Property Scintilla.Italic(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETITALIC, sty, 0)
End Property

Private Property Scintilla.Italic(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETITALIC, sty, val)
End Property

Private Property Scintilla.Underline(ByVal sty As Integer) As Integer
	Return SendMessage(FHandle, SCI_STYLEGETUNDERLINE, sty, 0)
End Property

Private Property Scintilla.Underline(ByVal sty As Integer, ByVal val As Integer)
	SendMessage(FHandle, SCI_STYLESETUNDERLINE, sty, val)
End Property

Private Property Scintilla.Zoom As Integer
	Return SendMessage(FHandle, SCI_GETZOOM, 0, 0)
End Property

Private Property Scintilla.Zoom(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETZOOM, val, 0)
End Property

Private Property Scintilla.CaretLineBackAlpha As Integer
	Return SendMessage(FHandle, SCI_GETCARETLINEBACKALPHA, 0, 0)
End Property

Private Property Scintilla.CaretLineBackAlpha(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCARETLINEBACKALPHA, val, 0)
End Property

Private Property Scintilla.CaretLineBackColor As Integer
	Return SendMessage(FHandle, SCI_GETCARETLINEBACK, 0, 0)
End Property

Private Property Scintilla.CaretLineBackColor(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCARETLINEBACK, val, 0)
End Property

Private Sub Scintilla.Redo()
	SendMessage(FHandle, SCI_REDO, 0, 0)
End Sub

Private Sub Scintilla.Undo()
	SendMessage(FHandle, SCI_UNDO, 0, 0)
End Sub

Private Sub Scintilla.Cut()
	SendMessage(FHandle, SCI_CUT, 0, 0)
End Sub

Private Sub Scintilla.Copy()
	SendMessage(FHandle, SCI_COPY, 0, 0)
End Sub

Private Sub Scintilla.Paste()
	SendMessage(FHandle, SCI_PASTE, 0, 0)
End Sub

Private Sub Scintilla.Clear()
	SendMessage(FHandle, SCI_CLEAR, 0, 0)
End Sub

Private Sub Scintilla.GotoLine(ByVal val As Integer)
	SendMessage(FHandle, SCI_GOTOLINE, val, 0)
End Sub

Private Sub Scintilla.SelectAll()
	SendMessage(FHandle, SCI_SELECTALL, 0, 0)
End Sub

Private Property Scintilla.LineCount As Integer
	Return SendMessage(FHandle, SCI_GETLINECOUNT, 0, 0)
End Property

Private Property Scintilla.LineStart(ByVal LineNo As Integer) As Integer
	Return SendMessage(FHandle, SCI_GETLINEENDPOSITION, LineNo, 0)
End Property

Private Property Scintilla.LineEnd(ByVal LineNo As Integer) As Integer
	Return SendMessage(FHandle, SCI_GETLINEENDPOSITION, LineNo, 0)
End Property

Private Property Scintilla.LineLength(ByVal LineNo As Integer) As Integer
	Return SendMessage(FHandle, SCI_LINELENGTH, LineNo, 0)
End Property

Private Property Scintilla.Length As Integer
	Return SendMessage(FHandle, SCI_GETLENGTH, 0, 0)
End Property

Private Property Scintilla.LineText(ByVal LineNo As Integer) ByRef As WString
	Dim s As Integer = LineLength(LineNo)
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETLINE, LineNo, Cast(LPARAM, p))
	Static t As WString Ptr
	TextFromSciData(*p, t)
	If p Then Deallocate(p)
	Return *t
End Property

Private Property Scintilla.Text ByRef As WString
	Dim s As Integer = Length
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETTEXT, s, Cast(LPARAM, p))
	Static w As WString Ptr
	TextFromSciData(*p, w)
	If p Then Deallocate(p)
	Return *w
End Property

Private Property Scintilla.Text(ByRef tData As Const WString)
	Dim p As ZString Ptr
	TextToSciData(tData, p)
	SendMessage(FHandle, SCI_SETTEXT, Len(*p), Cast(LPARAM, p))
	If p Then Deallocate(p)
End Property

Private Property Scintilla.SelText ByRef As WString
	Dim s As Integer = SelLength
	Dim p As ZString Ptr = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETSELTEXT, s, Cast(LPARAM, p))
	Static t As WString Ptr
	TextFromSciData(*p, t)
	If p Then Deallocate(p)
	Return *t
End Property

Private Property Scintilla.SelText(ByRef tData As Const WString)
	Dim p As ZString Ptr
	TextToSciData(tData, p)
	SendMessage(FHandle, SCI_REPLACESEL, Len(tData), Cast(LPARAM, p))
	If p Then Deallocate(p)
End Property

Private Property Scintilla.TxtData(tSize As Integer) ByRef As Any Ptr
	Static p As Any Ptr = NULL
	If p Then Deallocate(p)
	p = CAllocate(tSize + 1)
	SendMessage(FHandle, SCI_GETTEXT, tSize, Cast(LPARAM, p))
	Return p
End Property

Private Property Scintilla.TxtData(tSize As Integer, tData As Any Ptr)
	SendMessage(FHandle, SCI_SETTEXT, tSize, Cast(LPARAM, tData))
End Property

Private Property Scintilla.SelTxtData ByRef As Any Ptr
	Static p As Any Ptr = NULL
	If p Then Deallocate(p)
	p = CAllocate(SelLength + 1)
	SendMessage(FHandle, SCI_GETSELTEXT, 0, Cast(LPARAM, p))
	Return p
End Property

Private Property Scintilla.SelTxtData(tData As Any Ptr)
	SendMessage(FHandle, SCI_REPLACESEL, 0, Cast(LPARAM, tData))
End Property

Private Property Scintilla.LineData(ByVal LineNo As Integer) ByRef As Any Ptr
	Dim s As Integer = LineLength(LineNo)
	Static p As Any Ptr
	If p Then Deallocate(p)
	p = CAllocate(s + 1)
	SendMessage(FHandle, SCI_GETLINE, LineNo, Cast(LPARAM, p))
	Return p
End Property

Private Property Scintilla.DarkMode As Boolean
	Return mDarkMode
End Property

Private Property Scintilla.DarkMode (ByVal bVal As Boolean)
	mDarkMode = bVal
	If bVal Then
		'set white space color
		SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h40, &h40, &h40, &h40))
		'set caret color
		SendMessage(FHandle, SCI_SETCARETFORE, RGB(&hff, &hFF, &hFF), 0)
		
		ForeColor(STYLE_DEFAULT) = RGB(&ha0, &ha0, &ha0)
		BackColor(STYLE_DEFAULT) = RGB(0, 0, 0)
		
		ForeColor(STYLE_LINENUMBER) = RGB(&hFF, &h80, &h80)
		BackColor(STYLE_LINENUMBER) = RGB(&h20, &h20, &h20)
		SetWindowTheme(FHandle, "DarkMode_Explorer", nullptr)
	Else
		'set white space color
		SendMessage(FHandle, SCI_SETELEMENTCOLOUR, SC_ELEMENT_WHITE_SPACE, RGBA(&h40, &h40, &h40, &h40))
		'set caret color
		SendMessage(FHandle, SCI_SETCARETFORE, RGB(&h0, &h0, &h0), 0)
		
		ForeColor(STYLE_DEFAULT) = RGB(0, 0, 0)
		BackColor(STYLE_DEFAULT) = RGB(255, 255, 255)
		
		ForeColor(STYLE_LINENUMBER) = RGB(&hFF, &h00, &h00)
		BackColor(STYLE_LINENUMBER) = RGB(&hE0, &hE0, &hE0)
		SetWindowTheme(FHandle, NULL, NULL)
	End If
End Property

Private Property Scintilla.ViewWhiteSpace As Boolean
	Return SendMessage(FHandle, SCI_GETVIEWWS, 0, 0)
End Property

Private Property Scintilla.ViewWhiteSpace(ByVal bVal As Boolean)
	If bVal Then SendMessage(FHandle, SCI_SETVIEWWS, SCWS_VISIBLEALWAYS, 0) Else SendMessage(FHandle, SCI_SETVIEWWS, SCWS_INVISIBLE, 0)
End Property

Private Property Scintilla.ViewEOL As Boolean
	Return SendMessage(FHandle, SCI_GETVIEWEOL, 0, 0)
End Property

Private Property Scintilla.ViewEOL (ByVal bVal As Boolean)
	SendMessage(FHandle, SCI_SETVIEWEOL, bVal, 0)
End Property

Private Property Scintilla.ViewCaretLine As Boolean
	Return SendMessage(FHandle, SCI_GETCARETLINEVISIBLE, 0, 0)
End Property

Private Property Scintilla.ViewCaretLine(ByVal bVal As Boolean)
	SendMessage(FHandle, SCI_SETCARETLINEVISIBLEALWAYS, bVal, 0)
	SendMessage(FHandle, SCI_SETCARETLINEVISIBLE, bVal, 0)
	If bVal = False Then Exit Property
	CaretLineBackAlpha = &H40
	CaretLineBackColor = RGB(&h80, &h80, &h80)
End Property

Private Property Scintilla.ViewLineNo As Integer
	Return MarginWidth(0)
End Property

Private Property Scintilla.ViewLineNo(ByVal iSize As Integer)
	MarginWidth(0) = iSize
End Property

Private Property Scintilla.ViewFold As Integer
	Return MarginWidth(1)
End Property

Private Property Scintilla.ViewFold(ByVal iSize As Integer)
	MarginWidth(1) = iSize
End Property

Private Property Scintilla.Margins() As Integer
	Return SendMessage(FHandle, SCI_GETMARGINS, 0, 0)
End Property

Private Property Scintilla.Margins(margin As Integer)
	SendMessage(FHandle, SCI_SETMARGINS, margin, 0)
End Property

Private Property Scintilla.MarginWidth(margin As Integer) As Integer
	Return SendMessage(FHandle, SCI_GETMARGINWIDTHN, margin, 0)
End Property

Private Property Scintilla.MarginWidth(margin As Integer, Val As Integer)
	If margin = 0 And Val <> 0 Then
		Dim s As String = Format(SendMessage(FHandle, SCI_GETFIRSTVISIBLELINE, 0, 0) + SendMessage(FHandle, SCI_LINESONSCREEN, 0, 0), "#0")
		SendMessage(FHandle, SCI_SETMARGINWIDTHN, margin, SendMessage(FHandle, SCI_TEXTWIDTH, STYLE_LINENUMBER, Cast(LPARAM, StrPtr(s))) + 5)
	Else
		SendMessage(FHandle, SCI_SETMARGINWIDTHN, margin, Val)
	End If
End Property

Private Sub Scintilla.MarginColor(ByVal margin As Integer = -1, ByVal fore As Integer = -1, ByVal back As Integer = -1)
	If margin <>-1 Then Margins = margin
	If fore <> -1 Then SendMessage(FHandle, SC_MARGIN_FORE, fore, 0)
	If back <> -1 Then SendMessage(FHandle, SC_MARGIN_BACK, back, 0)
End Sub

Private Sub Scintilla.SelColor(ByVal fore As Integer = -1, ByVal back As Integer = -1)
	If fore <> -1 Then SendMessage(FHandle, SCI_SETSELFORE, True, fore)
	If back <> -1 Then SendMessage(FHandle, SCI_SETSELBACK, True, back)
End Sub

Private Property Scintilla.SelAlpha As Integer
	Return SendMessage(FHandle, SCI_GETSELALPHA, 0, 0)
End Property

Private Property Scintilla.SelAlpha(Val As Integer)
	SendMessage(FHandle, SCI_SETSELALPHA, Val, 0)
End Property

Private Property Scintilla.SelLayer As Integer
	Return SendMessage(FHandle, SCI_GETSELECTIONLAYER, 0, 0)
End Property

Private Property Scintilla.SelLayer(Val As Integer)
	SendMessage(FHandle, SCI_SETSELECTIONLAYER, Val, 0)
End Property

Private Function Scintilla.GetPosX(ByVal oPos As Integer = -1) As Integer
	Dim p As Integer = IIf(oPos < 0, Pos, oPos)
	Return p - SendMessage(FHandle, SCI_POSITIONFROMLINE, GetPosY(p), 0)
End Function

Private Function Scintilla.GetPosY(ByVal oPos As Integer = -1) As Integer
	Return SendMessage(FHandle, SCI_LINEFROMPOSITION, IIf(oPos < 0, Pos, oPos), 0)
End Function

Private Property Scintilla.SelStart As Integer
	Return SendMessage(FHandle, SCI_GETSELECTIONSTART, 0, 0)
End Property

Private Property Scintilla.SelStart(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETSELECTIONSTART, val, 0)
End Property

Private Property Scintilla.SelEnd As Integer
	Return SendMessage(FHandle, SCI_GETSELECTIONEND, 0, 0)
End Property

Private Property Scintilla.SelEnd(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETSELECTIONEND, val, 0)
End Property

Private Property Scintilla.SelLength As Integer
	Return SelEnd - SelStart
End Property

Private Property Scintilla.SelLength(ByVal val As Integer)
	SelEnd = SelStart + val
End Property

Private Property Scintilla.Pos(ByVal val As Integer)
	SendMessage(FHandle, SCI_SETCURRENTPOS, val, 0)
	SendMessage(FHandle, SCI_SETSEL, val, val)
	SelStart = val
End Property

Private Property Scintilla.Pos As Integer
	Return SendMessage(FHandle, SCI_GETCURRENTPOS, 0, 0)
End Property

Private Property Scintilla.PosX As Integer
	Return Pos - SendMessage(FHandle, SCI_POSITIONFROMLINE, PosY, 0)
End Property

Private Property Scintilla.PosX(ByVal val As Integer)
	Pos = SendMessage(FHandle, SCI_POSITIONFROMLINE, PosY, 0) + val
End Property

Private Property Scintilla.PosY As Integer
	Return SendMessage(FHandle, SCI_LINEFROMPOSITION, Pos, 0)
End Property

Private Property Scintilla.PosY(ByVal val As Integer)
	Pos = SendMessage(FHandle, SCI_POSITIONFROMLINE, val, 0) + PosX
End Property


Private Property Scintilla.UseTabs As Boolean
	Return SendMessage(FHandle, SCI_GETUSETABS, 0, 0)
End Property

Private Property Scintilla.UseTabs (uTabs As Boolean)
	SendMessage(FHandle, SCI_SETUSETABS, uTabs, 0)
End Property

Private Property Scintilla.TabWidth As Integer
	Return SendMessage(FHandle, SCI_GETTABWIDTH, Pos, 0)
End Property

Private Property Scintilla.TabWidth (tWidth As Integer)
	SendMessage(FHandle, SCI_SETTABWIDTH, tWidth, 0)
End Property

Private Property Scintilla.IndentSize As Integer
	Return SendMessage(FHandle, SCI_GETINDENT, 0, 0)
End Property

Private Property Scintilla.IndentSize (iSize As Integer)
	SendMessage(FHandle, SCI_SETINDENT, iSize, 0)
End Property

Private Property Scintilla.TabIndents As Boolean
	Return SendMessage(FHandle, SCI_GETTABINDENTS, 0, 0)
End Property

Private Property Scintilla.TabIndents (tIndents As Boolean)
	SendMessage(FHandle, SCI_SETTABINDENTS, tIndents, 0)
End Property

