'#########################################################
'#  EditControl.bas                                      #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "EditControl.bi"
#ifndef __USE_GTK__
	#include once "win/mmsystem.bi"
#endif

Dim Shared As WStringList KeywordLists 'keywords0, keywords1, keywords2, keywords3
'pkeywords0 = @keywords0
'pkeywords1 = @keywords1
'pkeywords2 = @keywords2
'pkeywords3 = @keywords3

Namespace My.Sys.Forms
	Destructor EditControlHistory
		If Comment Then Deallocate_( Comment)
		For i As Integer = Lines.Count - 1 To 0 Step -1
			Delete_( Cast(EditControlLine Ptr, Lines.Items[i]))
		Next i
		Lines.Clear
	End Destructor
	
	Constructor EditControlLine
		Visible = True
	End Constructor
	
	Destructor EditControlLine
		If This.Text <> 0 Then Deallocate_( This.Text)
	End Destructor
End Namespace

' Add Try End_Try
ReDim Constructions(22) As Construction
Constructions(0)  = Type<Construction>("If",            "",                     "",                     "",                 "ElseIf",   "Else",         "",         "End If",           "Then ",    False,  False)
Constructions(1)  = Type<Construction>("#If",           "#IfDef",               "#IfNDef",              "",                 "#ElseIf",  "#Else",        "",         "#EndIf",           "",         False,  False)
Constructions(2)  = Type<Construction>("#Macro",        "",                     "",                     "",                 "",         "",             "",         "#EndMacro",        "",         False,  False)
Constructions(3)  = Type<Construction>("Extern",        "",                     "",                     "",                 "",         "",             "",         "End Extern",       "",         False,  False)
Constructions(4)  = Type<Construction>("Try",           "",                     "",                     "",                 "Catch",    "Finally",      "",         "EndTry",           "",         False,  False)
Constructions(5)  = Type<Construction>("Asm",           "",                     "",                     "",                 "",         "",             "",         "End Asm",          " ",        False,  False)
Constructions(6)  = Type<Construction>("Select Case",   "",                     "",                     "",                 "Case",     "",             "",         "End Select",       "",         False,  False)
Constructions(7)  = Type<Construction>("For",           "",                     "",                     "",                 "",         "",             "",         "Next",             "",         False,  False)
Constructions(8)  = Type<Construction>("Do",            "",                     "",                     "",                 "",         "",             "",         "Loop",             "",         False,  False)
Constructions(9)  = Type<Construction>("While",         "",                     "",                     "",                 "",         "",             "",         "Wend",             "",         False,  False)
Constructions(10) = Type<Construction>("With",          "",                     "",                     "",                 "",         "",             "",         "End With",         "",         False,  False)
Constructions(11) = Type<Construction>("Scope",         "",                     "",                     "",                 "",         "",             "",         "End Scope",        "",         False,  False)
Constructions(12) = Type<Construction>("'#Region",      "",                     "",                     "",                 "",         "",             "",         "'#End Region",     "",         True,   False)
Constructions(13) = Type<Construction>("Namespace",     "",                     "",                     "",                 "",         "",             "",         "End Namespace",    "",         True,   False)
Constructions(14) = Type<Construction>("Enum",          "Public Enum",          "Private Enum",         "",                 "",         "",             "",         "End Enum",         "",         True,   True)
Constructions(15) = Type<Construction>("Type",          "Public Type",          "Private Type",         "",                 "Private:", "Protected:",   "Public:",  "End Type",         "As ",      True,   True)
Constructions(16) = Type<Construction>("Union",         "Public Union",         "Private Union",        "",                 "",         "",             "",         "End Union",        "",         True,   True)
Constructions(17) = Type<Construction>("Sub",           "Public Sub",           "Private Sub",          "Static Sub",       "",         "",             "",         "End Sub",          "",         True,   True)
Constructions(18) = Type<Construction>("Function",      "Public Function",      "Private Function",     "Static Function",  "",         "",             "",         "End Function",     "",         True,   True)
Constructions(19) = Type<Construction>("Property",      "Public Property",      "Private Property",     "",                 "",         "",             "",         "End Property",     "",         True,   True)
Constructions(20) = Type<Construction>("Operator",      "Public Operator",      "Private Operator",     "",                 "",         "",             "",         "End Operator",     "",         True,   True)
Constructions(21) = Type<Construction>("Constructor",   "Public Constructor",   "Private Constructor",  "",                 "",         "",             "",         "End Constructor",  "",         True,   True)
Constructions(22) = Type<Construction>("Destructor",    "Public Destructor",    "Private Destructor",   "",                 "",         "",             "",         "End Destructor",   "",         True,   True)

Namespace My.Sys.Forms
	Function EditControl.deltaToScrollAmount(lDelta As Integer) As Integer
		If Abs(lDelta) < 12 Then
			deltaToScrollAmount = 0
		ElseIf Abs(lDelta) < 32 Then
			deltaToScrollAmount = Sgn(lDelta)
		ElseIf Abs(lDelta) < 56 Then
			deltaToScrollAmount = Sgn(lDelta) * 2
		ElseIf Abs(lDelta) < 80 Then
			deltaToScrollAmount = Sgn(lDelta) * 4
		ElseIf Abs(lDelta) < 104 Then
			deltaToScrollAmount = Sgn(lDelta) * 8
		ElseIf Abs(lDelta) < 128 Then
			deltaToScrollAmount = Sgn(lDelta) * 32
		Else
			deltaToScrollAmount = Sgn(lDelta) * 80
		End If
	End Function
	
	Sub EditControl.MiddleScroll()
		#ifndef __USE_GTK__
			GetCursorPos @tP
			lXOffset = tP.X - m_tP.X
			lYOffset = tP.Y - m_tP.Y
			Dim As Boolean bChanged, bDoIt
			si.cbSize = Len(si)
			si.fMask = SIF_RANGE Or SIF_PAGE Or SIF_POS Or SIF_TRACKPOS
			GetScrollInfo FHandle, SB_HORZ, @si
			lHorzOffset = deltaToScrollAmount(lXOffset)
			If Not (lHorzOffset = 0) Then
				bDoIt = True
				If (lHorzOffset < 32) Then
					If (timeGetTime() - m_lLastHorzTime) < 100 Then
						bDoIt = False
					Else
						m_lLastHorzTime = timeGetTime()
					End If
				End If
				If bDoIt Then
					si.fMask = SIF_POS Or SIF_TRACKPOS
					Var lNewPos = si.nPos + lHorzOffset
					If (lNewPos < 0) Then lNewPos = 0
					If (lNewPos > si.nMax + si.nPage) Then lNewPos = si.nMax + si.nPage
					si.nPos = lNewPos
					si.nTrackPos = lNewPos
					SetScrollInfo FHandle, SB_HORZ, @si, True
					GetScrollInfo(FHandle, SB_HORZ, @si)
					If (Not si.nPos = HScrollPos) Then
						HScrollPos = si.nPos
						bChanged = True
					End If
				End If
			End If
			si.cbSize = Len(si)
			si.fMask = SIF_RANGE Or SIF_PAGE Or SIF_POS Or SIF_TRACKPOS
			GetScrollInfo FHandle, SB_VERT, @si
			lVertOffset = deltaToScrollAmount(lYOffset)
			If Not (lVertOffset = 0) Then
				bDoIt = True
				If (lVertOffset < 32) Then
					If (timeGetTime() - m_lLastVertTime) < 100 Then
						bDoIt = False
					Else
						m_lLastVertTime = timeGetTime()
					End If
				End If
				If (bDoIt) Then
					si.fMask = SIF_POS Or SIF_TRACKPOS
					Var lNewPos = si.nPos + lVertOffset
					If (lNewPos < 0) Then lNewPos = 0
					If (lNewPos > si.nMax + si.nPage) Then lNewPos = si.nMax + si.nPage
					si.nPos = lNewPos
					si.nTrackPos = lNewPos
					SetScrollInfo(FHandle, SB_VERT, @si, True)
					GetScrollInfo(FHandle, SB_VERT, @si)
					If (Not si.nPos = VScrollPos) Then
						VScrollPos = si.nPos
						bChanged = True
					End If
				End If
			End If
			If bChanged Then
				ShowCaretPos False
				PaintControl
			End If
		#endif
	End Sub
	
	#ifdef __USE_GTK__
		Function EditControl.Blink_cb(ByVal user_data As gpointer) As gboolean
			Dim As EditControl Ptr ec = Cast(Any Ptr, user_data)
			If ec->InFocus Then
				ec->CaretOn = Not ec->CaretOn
				If gtk_is_widget(ec->widget) Then gtk_widget_queue_draw(ec->widget)
				'gdk_threads_add_timeout(ec->BlinkTime, @Blink_cb, ec)
				Return True
			Else
				ec->CaretOn = False
				If gtk_is_widget(ec->widget) Then gtk_widget_queue_draw(ec->widget)
				Return False
			End If
		End Function
	#else
		Sub EditControl.EC_TimerProc(hwnd As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
			If ScrEC Then
				If ScrEC->bInMiddleScroll Then
					ScrEC->MiddleScroll
				Else
					KillTimer ScrEC->Handle, 1
				End If
			End If
		End Sub
	#endif
	
	Sub EditControl.Breakpoint
		FECLine = FLines.Items[FSelEndLine]
		If CInt(Trim(*FECLine->Text, Any !"\t ") = "") OrElse CInt(StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'")) OrElse _
			CInt(StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t ") & " ", "rem ")) Then
			MsgBox ML("Don't set breakpoint to this line"), "VisualFBEditor", mtWarning
			This.SetFocus
		Else
			FECLine->Breakpoint = Not FECLine->Breakpoint
			PaintControl
		End If
	End Sub
	
	Sub EditControl.Bookmark '...'
		Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Bookmark = Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Bookmark
		PaintControl
	End Sub
	
	Sub EditControl.ClearAllBookmarks
		For i As Integer = 0 To FLines.Count - 1
			FECLine = FLines.Items[i]
			If FECLine->Bookmark Then
				FECLine->Bookmark = False
			End If
		Next
		PaintControl
	End Sub
	
	Property EditControl.TopLine As Integer
		Return VScrollPos
	End Property
	
	Property EditControl.TopLine(Value As Integer)
		VScrollPos = Min(GetCaretPosY(Value), VScrollMax)
		#ifdef __USE_GTK__
			gtk_adjustment_set_value(adjustmentv, VScrollPos)
		#else
			si.cbSize = SizeOf (si)
			si.fMask = SIF_POS
			si.nPos = VScrollPos
			SetScrollInfo(FHandle, SB_VERT, @si, True)
		#endif
		PaintControl
	End Property
	
	Sub EditControl._FillHistory(ByRef item As EditControlHistory Ptr, ByRef Comment As WString)
		WLet(item->Comment, Comment)
		Dim ecItem As EditControlLine Ptr
		For i As Integer = 0 To FLines.Count - 1
			With *Cast(EditControlLine Ptr, FLines.Items[i])
				FECLine = New_( EditControlLine)
				WLet(FECLine->Text, *.Text)
				FECLine->Breakpoint = .Breakpoint
				FECLine->Bookmark = .Bookmark
				FECLine->CommentIndex = .CommentIndex
				FECLine->ConstructionIndex = .ConstructionIndex
				FECLine->ConstructionPart = .ConstructionPart
				FECLine->InConstructionIndex = .InConstructionIndex
				FECLine->InConstructionPart = .InConstructionPart
				FECLine->Multiline = .Multiline
				FECLine->Collapsed = .Collapsed
				FECLine->Collapsible = .Collapsible
				FECLine->Collapsed = .Collapsed
				FECLine->Visible = .Visible
			End With
			item->Lines.Add FECLine
		Next i
	End Sub
	
	Sub EditControl._ClearHistory(Index As Integer = 0)
		For i As Integer = FHistory.Count - 1 To Index Step -1
			Delete_( Cast(EditControlHistory Ptr, FHistory.Items[i]))
			FHistory.Remove i
		Next i
		If Index = 0 Then FHistory.Clear
	End Sub
	
	Function TextWithoutQuotesAndComments(subject As String, OldCommentIndex As Integer = 0, WithoutComments As Boolean = True) As String
		Dim As String result, ch, sLine = subject
		Dim As Integer cc, iPos = -1
		Dim As Boolean q, c
		For i As Integer = 1 To OldCommentIndex
			iPos = InStr(iPos + 1, sLine, "'/")
		Next
		If iPos = 0 Then Return "" Else sLine = Mid(sLine, iPos + 2)
		For i As Integer = 0 To Len(sLine)
			ch = Mid(sLine, i, 1)
			If Not c AndAlso ch = """" Then
				q = Not q
				result += """"
			ElseIf Not q AndAlso ch = "/" AndAlso Mid(sLine, i + 1, 1) = "'" Then
				c = True
				cc += 1
				result += " "
			ElseIf Not q AndAlso ch = "'" AndAlso Mid(sLine, i + 1, 1) = "/" Then
				cc -= 1
				If cc = 0 Then
					c = False
				ElseIf cc < 0 Then
					Exit For
				End If
				result += " "
			ElseIf CInt(WithoutComments) AndAlso CInt(Not q) AndAlso CInt(ch = "'" OrElse LCase(Mid(sLine, i, 4)) = "rem ") Then
				Exit For
			ElseIf c OrElse q Then
				result += " "
			Else
				result += ch
			End If
		Next
		Return result
	End Function
	
	Function EditControl.GetConstruction(ByRef wLine As WString, ByRef iType As Integer = 0, OldCommentIndex As Integer = 0) As Integer
		On Error Goto ErrorHandler
		Dim As String sLine = wLine
		If Trim(sLine, Any !"\t ") = "" Then Return -1
		'		iPos = -1
		'		For i As Integer = 1 To OldCommentIndex
		'			iPos = InStr(iPos + 1, sLine, "'/")
		'		Next
		'		If iPos = 0 Then Return -1 Else sLine = Mid(sLine, iPos + 2)
		'		iPos = InStr(sLine, "/'")
		sLine = TextWithoutQuotesAndComments(sLine, OldCommentIndex, False)
		iPos = InStr(sLine, "'")
		If iPos = 0 Then iPos = Len(sLine) Else iPos -= 1
		For i As Integer = 0 To UBound(Constructions)
			With Constructions(i)
				If CInt(CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name0 & " "))) OrElse _
					CInt(CInt(CInt(.Name01 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name01 & " "))) OrElse _
					CInt(.Name02 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name02 & " "))) OrElse _
					CInt(.Name03 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name03 & " ")))))) AndAlso _
					CInt(CInt(.Exception = "") OrElse CInt(InStr(LCase(Trim(..Left(Replace(sLine, !"\t", " "), iPos), Any !"\t ")), LCase(.Exception)) = 0)) AndAlso _
					CInt(..Left(LTrim(Mid(LTrim(sLine, Any !"\t "), Len(Trim(.Name0)) + 1), Any !"\t "), 1) <> "=") AndAlso _
					CInt(LCase(..Left(LTrim(Mid(LTrim(sLine, Any !"\t "), Len(Trim(.Name0)) + 1), Any !"\t "), 3)) <> "as " OrElse InStr(Trim(.Name0), " ") > 0) Then
					iType = 0
					Return i
				ElseIf CInt(CInt(CInt(.Name1 <> "") AndAlso (CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name1) & " ")) OrElse CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & ":", LCase(.Name1))))) OrElse _
					CInt(CInt(.Name2 <> "") AndAlso (CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name2) & " ")) OrElse CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & ":", LCase(.Name2))))) OrElse _
					CInt(CInt(.Name3 <> "") AndAlso (CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name3) & " ")) OrElse CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & ":", LCase(.Name3)))))) AndAlso _
					CInt(CInt(.Exception = "") OrElse CInt(InStr(LCase(Trim(..Left(sLine, iPos), Any !"\t ")), LCase(.Exception)) = 0)) Then
					iType = 1
					Return i
				ElseIf CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.EndName & " "))) OrElse _
					CInt(CInt(i = 0) AndAlso CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", "endif "))) Then
					iType = 2
					Return i
				End If
			End With
		Next i
		Return -1
		Exit Function
		ErrorHandler:
		MsgBox ErrDescription(Err) & " (" & Err & ") " & _
		"in line " & Erl() & " " & _
		"in function " & ZGet(Erfn()) & " " & _
		"in module " & ZGet(Ermn())
	End Function
	
	Function IsArg(j As Integer) As Boolean
		Return j >= Asc("A") And j <= Asc("Z") OrElse _
		j >= Asc("a") And j <= Asc("z") OrElse _
		j >= Asc("0") And j <= Asc("9") OrElse _
		j = Asc("_")
	End Function
	
	Function FindCommentIndex(ByRef Value As WString, ByRef OldiC As Integer) As Integer
		Dim As Boolean bQ
		Dim As Integer j = 1, l = Len(Value)
		Dim As Integer iC = OldiC
		Do While j <= l
			If iC = 0 AndAlso Mid(Value, j, 1) = """" Then
				bQ = Not bQ
			ElseIf Not bQ Then
				If Mid(Value, j, 2) = "/'" Then
					iC = iC + 1
					j = j + 1
				ElseIf iC > 0 AndAlso Mid(Value, j, 2) = "'/" Then
					iC = iC - 1
					j = j + 1
				ElseIf iC = 0 AndAlso Mid(Value, j, 1) = "'" Then
					Exit Do
				End If
			End If
			j = j + 1
		Loop
		Return iC
	End Function
	
	Sub EditControl.ChangeCollapseState(LineIndex As Integer, Value As Boolean)
		If LineIndex < 0 OrElse LineIndex > FLines.Count - 1 Then Exit Sub
		Dim As Integer j, Idx
		Dim FECLine As EditControlLine Ptr = FLines.Items[LineIndex]
		Dim As EditControlLine Ptr FECLine2
		FECLine->Collapsed = Value
		If FECLine->Collapsed Then
			If Not EndsWith(*FECLine->Text, "'...'") Then
				WLetEx(FECLine->Text, *FECLine->Text & " '...'", True)
			End If
			For i As Integer = LineIndex + 1 To FLines.Count - 1
				FECLine2 = FLines.Items[i]
				FECLine2->Visible = False
'				Idx = VisibleLines.IndexOf(FECLine2)
'				If Idx > -1 Then VisibleLines.Remove Idx
				If FECLine2->ConstructionIndex = FECLine->ConstructionIndex Then
					If FECLine2->ConstructionPart = 2 Then
						j -= 1
						If j = -1 Then
							Exit For
						End If
					ElseIf FECLine2->ConstructionPart = 0 Then
						j += 1
					End If
				End If
			Next i
		Else
			If EndsWith(*FECLine->Text, "'...'") Then
				WLetEx(FECLine->Text, RTrim(.Left(*FECLine->Text, Len(*FECLine->Text) - 5)), True)
			End If
			Dim As EditControlLine Ptr OldCollapsed
			For i As Integer = LineIndex + 1 To FLines.Count - 1
				FECLine2 = FLines.Items[i]
				If FECLine2->Visible Then Exit For
				FECLine2->Visible = True
				If CInt(OldCollapsed = 0) AndAlso CInt(FECLine2->Collapsed) Then
					OldCollapsed = FECLine2
					j = 0
				ElseIf OldCollapsed <> 0 Then
					If FECLine2->ConstructionIndex = OldCollapsed->ConstructionIndex Then
						If FECLine2->ConstructionPart = 2 Then
							j -= 1
							If j = -1 Then
								OldCollapsed = 0
							End If
						ElseIf FECLine2->ConstructionPart = 0 Then
							j += 1
						End If
					End If
					FECLine2->Visible = False
				End If
				If FECLine2->Visible Then
'					Idx = VisibleLines.IndexOf(FECLine2)
'					If Idx = -1 Then VisibleLines.Insert VisibleLines.IndexOf(FECLine) + 1, FECLine2
					FECLine = FECLine2
				End If
			Next i
		End If
	End Sub
	
	Sub EditControl.CollapseAll
		For i As Integer = 0 To FLines.Count - 1
			With *Cast(EditControlLine Ptr, FLines.Items[i])
				If .Collapsible AndAlso Not .Collapsed Then ChangeCollapseState i, True
			End With
		Next
		PaintControl
	End Sub
	
	Sub EditControl.UnCollapseAll
		For i As Integer = 0 To FLines.Count - 1
			With *Cast(EditControlLine Ptr, FLines.Items[i])
				If .Collapsible AndAlso .Collapsed Then ChangeCollapseState i, False
			End With
		Next
		PaintControl
	End Sub
	
	Sub EditControl.ChangeCollapsibility(LineIndex As Integer)
		Dim As Integer i, j, k, Idx
		Dim OldCollapsed As Boolean, OldLineIndex As Integer = LineIndex - 1
		If LineIndex < 0 OrElse LineIndex > FLines.Count - 1 Then Exit Sub
		Dim ecl As EditControlLine Ptr = FLines.Items[LineIndex]
		If ecl = 0 OrElse ecl->Text = 0 Then Exit Sub
		i = GetConstruction(*ecl->Text, j)
		ecl->ConstructionIndex = i
		ecl->ConstructionPart = j
		ecl->Multiline = InStr(*ecl->Text, ":") > 0
		OldCollapsed = ecl->Collapsed
		If i > -1 And j = 0 Then
			ecl->Collapsible = Constructions(i).Collapsible
			If EndsWith(*ecl->Text, "'...'") Then
				ecl->Collapsed = Constructions(i).Collapsible
			Else
				ecl->Collapsed = False
			End If
		Else
			ecl->Collapsible = False
			ecl->Collapsed = False
		End If
		If OldCollapsed <> ecl->Collapsed Then
			ChangeCollapseState LineIndex, ecl->Collapsed
		End If
		If OldLineIndex > -1 Then
			Dim As EditControlLine Ptr FECLine2, eclOld = FLines.Items[OldLineIndex]
			If Not eclOld->Visible Then
				k = GetLineIndex(OldLineIndex, 0)
				Dim FECLine As EditControlLine Ptr = FLines.Items[k]
				j = 0
				For k = k + 1 To OldLineIndex
					FECLine2 = FLines.Items[k]
					If FECLine2->ConstructionIndex = FECLine->ConstructionIndex Then
						If FECLine2->ConstructionPart = 2 Then
							j -= 1
							If j = -1 Then
								Exit For
							End If
						ElseIf FECLine2->ConstructionPart = 0 Then
							j += 1
						End If
					End If
				Next
				ecl->Visible = j = -1
			ElseIf eclOld->Collapsed Then
				ecl->Visible = False
			End If
'			Idx = VisibleLines.IndexOf(ecl)
'			If ecl->Visible AndAlso Idx = -1 Then
'				If eclOld->Visible Then VisibleLines.Insert VisibleLines.IndexOf(eclOld) + 1, ecl
'			ElseIf (Not ecl->Visible) AndAlso Idx > -1 Then
'				VisibleLines.Remove Idx
'			End If
		End If
	End Sub
	
	Sub EditControl.ChangeSelPos(bLeft As Boolean)
		If bLeft Then
			If FSelStartLine < FSelEndLine Then
				FSelEndLine = FSelStartLine
				FSelEndChar = FSelStartChar
			ElseIf FSelStartLine > FSelEndLine Then
				FSelStartLine = FSelEndLine
				FSelStartChar = FSelEndChar
			Else
				FSelStartChar = Min(FSelStartChar, FSelEndChar)
				FSelEndChar = FSelStartChar
			End If
		Else
			If FSelStartLine > FSelEndLine Then
				FSelEndLine = FSelStartLine
				FSelEndChar = FSelStartChar
			ElseIf FSelStartLine < FSelEndLine Then
				FSelStartLine = FSelEndLine
				FSelStartChar = FSelEndChar
			Else
				FSelStartChar = Max(FSelStartChar, FSelEndChar)
				FSelEndChar = FSelStartChar
			End If
		End If
	End Sub
	
	Sub EditControl.ChangePos(CharTo As Integer = 0)
		Var LengthEndLine = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
		FSelEndChar += CharTo
		If FSelEndChar < 0 Then
			If FSelEndLine > 0 Then
				FSelEndLine = GetLineIndex(FSelEndLine, -1)
				FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
			Else
				FSelEndChar = 0
			End If
		ElseIf FSelEndChar > LengthEndLine Then
			If FSelEndLine < GetLineIndex(FLines.Count - 1) Then
				FSelEndLine = GetLineIndex(FSelEndLine, +1)
				FSelEndChar = 0
			Else
				FSelEndChar = LengthEndLine
			End If
		End If
	End Sub
	
	Sub EditControl.GetSelection(ByRef iSelStartLine As Integer, ByRef iSelEndLine As Integer, ByRef iSelStartChar As Integer, ByRef iSelEndChar As Integer, iCurrProcedure As Boolean = False)
		If FSelStartLine < 0 OrElse FLines.Count<1 OrElse FSelStartLine>FLines.Count - 1 Then Exit Sub
		If iCurrProcedure  Then ' For get the top line and bottom line of tne current procedure
			Dim As Integer lLineCount
			iSelStartLine = 0
			For lLineCount = FSelStartLine To 1 Step -1
				FECLine = FLines.Items[lLineCount]
				If FECLine->ConstructionIndex > 12  Then
					If FECLine->ConstructionPart = 0 Then
						iSelStartLine = lLineCount
						Exit For
					End If
				End If
			Next
			
			iSelEndLine = FLines.Count - 1
			For lLineCount = FSelStartLine To FLines.Count - 1
				FECLine = FLines.Items[lLineCount]
				If FECLine->ConstructionIndex > 12  Then
					If FECLine->ConstructionPart = 0 Then
						iSelEndLine = lLineCount
						Exit For
					End If
				End If
			Next
			iSelStartChar=1
			iSelEndChar=1
		Else
			If FSelStartLine < FSelEndLine Then
				iSelStartChar = FSelStartChar
				iSelEndChar = FSelEndChar
				iSelStartLine = FSelStartLine
				iSelEndLine = FSelEndLine
			ElseIf FSelStartLine > FSelEndLine Then
				iSelStartChar = FSelEndChar
				iSelEndChar = FSelStartChar
				iSelStartLine = FSelEndLine
				iSelEndLine = FSelStartLine
			Else
				iSelStartChar = Min(FSelStartChar, FSelEndChar)
				iSelEndChar = Max(FSelStartChar, FSelEndChar)
				iSelStartLine = FSelStartLine
				iSelEndLine = FSelEndLine
			End If
		End If
	End Sub
	
	Function EditControl.GetOldCharIndex() As Integer
		If FSelEndLine >= 0 AndAlso FSelEndLine <= FLines.Count - 1 Then
			Return Len(GetTabbedText(.Left(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text, FSelEndChar)))
		Else
			Return FSelEndChar
		End If
	End Function
	
	Function EditControl.GetCharIndexFromOld() As Integer
		If FSelEndLine >= 0 AndAlso FSelEndLine <= FLines.Count - 1 Then
			WLet(FLine, *Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
			Dim As Integer p, i
			For i = 1 To Len(*FLine)
				If Mid(*FLine, i, 1) = !"\t" Then
					p += TabWidth
				Else
					p += 1
				End If
				If p > OldCharIndex Then Return i - 1
			Next
			Return i - 1
		Else
			Return OldCharIndex
		End If
	End Function
	
	Sub EditControl.SetSelection(iSelStartLine As Integer, iSelEndLine As Integer, iSelStartChar As Integer, iSelEndChar As Integer)
		FSelStartChar = Max(0, iSelStartChar)
		FSelEndChar = Max(0, iSelEndChar)
		FSelStartLine = Min(FLines.Count - 1, Max(0, iSelStartLine))
		FSelEndLine = Min(FLines.Count - 1, Max(0, iSelEndLine))
		#ifdef __USE_GTK__
			If Handle Then
		#else
			If Handle Then
		#endif
			ScrollToCaret
		End If
		OldnCaretPosX = nCaretPosX
		OldCharIndex = GetOldCharIndex
	End Sub
	
	Sub EditControl.Changing(ByRef Comment As WString = "")
		FOldSelStartLine = FSelStartLine
		FOldSelEndLine = FSelEndLine
		FOldSelStartChar = FSelStartChar
		FOldSelEndChar = FSelEndChar
		Dim As EditControlHistory Ptr item
		If Comment = "" Then
			If bOldCommented Then
				_ClearHistory curHistory + 1
				item = New_( EditControlHistory)
				item->OldSelStartLine = FSelStartLine
				item->OldSelEndLine = FSelEndLine
				item->OldSelStartChar = FSelStartChar
				item->OldSelEndChar = FSelEndChar
				FHistory.Add item
				If HistoryLimit > -1 AndAlso FHistory.Count > HistoryLimit Then
					Delete_( Cast(EditControlHistory Ptr, FHistory.Items[0]))
					FHistory.Remove 0
				End If
				curHistory = FHistory.Count - 1
			End If
		ElseIf CInt(Not bOldCommented) AndAlso CInt(FHistory.Count > 0) Then
			item = FHistory.Items[FHistory.Count - 1]
			_FillHistory item, "Matn kiritildi"
			item->SelStartLine = FSelStartLine
			item->SelEndLine = FSelEndLine
			item->SelStartChar = FSelStartChar
			item->SelEndChar = FSelEndChar
		End If
		bOldCommented = Comment <> ""
	End Sub
	
	Sub EditControl.Changed(ByRef Comment As WString = "")
		OldnCaretPosX = nCaretPosX
		OldCharIndex = GetOldCharIndex
		If WithHistory Then
			If Comment <> "" Then
				Var item = New_( EditControlHistory)
				_FillHistory item, Comment
				item->OldSelStartLine = FOldSelStartLine
				item->OldSelEndLine = FOldSelEndLine
				item->OldSelStartChar = FOldSelStartChar
				item->OldSelEndChar = FOldSelEndChar
				item->SelStartLine = FSelStartLine
				item->SelEndLine = FSelEndLine
				item->SelStartChar = FSelStartChar
				item->SelEndChar = FSelEndChar
				_ClearHistory curHistory + 1
				FHistory.Add item
				If HistoryLimit > -1 AndAlso FHistory.Count > HistoryLimit Then
					Delete_( Cast(EditControlHistory Ptr, FHistory.Items[0]))
					FHistory.Remove 0
				End If
				curHistory = FHistory.Count - 1
			End If
		End If
		If OnChange Then OnChange(This)
		Modified = True
		#ifdef __USE_GTK__
			If widget AndAlso cr Then
		#else
			If Handle Then
		#endif
			ScrollToCaret
		End If
	End Sub
	
	Sub EditControl.ChangeText(ByRef Value As WString, CharTo As Integer = 0, ByRef Comment As WString = "", SelStartLine As Integer = -1, SelStartChar As Integer = -1)
		Changing Comment
		ChangePos CharTo
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Var ecStartLine = Cast(EditControlLine Ptr, FLines.Item(iSelStartLine)), ecEndLine = Cast(EditControlLine Ptr, FLines.Item(iSelEndLine))
		FECLine = ecStartLine
		'If iSelStartLine <> iSelEndLine Or iSelStartChar <> iSelEndChar Then AddHistory
		WLet(FLine, Mid(*ecEndLine->Text, iSelEndChar + 1))
		WLet(FECLine->Text, .Left(*ecStartLine->Text, iSelStartChar))
		Var iC = 0, OldiC = ecEndLine->CommentIndex, OldPreviC = 0, PreviC = 0, Pos1 = 0, p = 1, c = 0, l = 0
		If iSelEndLine > 0 Then PreviC = Cast(EditControlLine Ptr, FLines.Item(iSelEndLine - 1))->CommentIndex: OldPreviC = PreviC
		For i As Integer = iSelEndLine To iSelStartLine + 1 Step -1
			Delete_( Cast(EditControlLine Ptr, FLines.Items[i]))
			FLines.Remove i
		Next i
		If iSelStartLine > 0 Then iC = Cast(EditControlLine Ptr, FLines.Item(iSelStartLine - 1))->CommentIndex
		Do
			Pos1 = InStr(p, Value, Chr(13))
			c = c + 1
			If Pos1 = 0 Then
				l = Len(Value) - p + 1
			Else
				l = Pos1 - p
			End If
			If c = 1 Then
				WLet(FECLine->Text, *FECLine->Text & Mid(Value, p, l))
				ChangeCollapsibility iSelStartLine
			Else
				FECLine = New_( EditControlLine)
				WLet(FECLine->Text, Mid(Value, p, l))
				'ecItem->CharIndex = p - 1
				'ecItem->LineIndex = c - 1
			End If
			'item->Length = Len(*item->Text)
			iC = FindCommentIndex(*FECLine->Text, PreviC)
			FECLine->CommentIndex = iC
			If c > 1 Then
				FLines.Insert iSelStartLine + c - 1, FECLine
				ChangeCollapsibility iSelStartLine + c - 1
			End If
			p = Pos1 + 1
			PreviC = iC
		Loop While Pos1 > 0
		FSelStartLine = iSelStartLine + c - 1
		FSelStartChar = Len(*FECLine->Text)
		WLet(Cast(EditControlLine Ptr, FLines.Item(FSelStartLine))->Text, *FECLine->Text & *FLine)
		ChangeCollapsibility FSelStartLine
		'item->Length = Len(*item->Text)
		'p = item->CharIndex + item->Length + 1
		If OldiC <> iC Then
			iC = OldPreviC
			For i As Integer = iSelStartLine To FLines.Count - 1 ' + 1
				FECLine = Cast(EditControlLine Ptr, FLines.Item(i))
				'Item->CharIndex = p - 1
				'Item->LineIndex = i
				iC = FindCommentIndex(*FECLine->Text, iC)
				FECLine->CommentIndex = iC
				'p = p + ecItem->Length
			Next i
		End If
		If SelStartLine <> -1 Then FSelStartLine = SelStartLine
		If SelStartChar <> -1 Then FSelStartChar = SelStartChar
		FSelEndLine = FSelStartLine
		FSelEndChar = FSelStartChar
		Changed Comment
	End Sub
	
	Sub EditControl.SelectAll
		FSelStartLine = 0
		FSelStartChar = 0
		FSelEndLine = FLines.Count - 1
		FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
		ShowCaretPos True
	End Sub
	
	Sub EditControl.CutToClipboard
		CopyToClipboard
		ChangeText "", 0, "Belgilangan matn qirqib olindi"
	End Sub
	
	Sub EditControl.CopyToClipboard
		pClipboard->SetAsText SelText
	End Sub
	
	Sub EditControl.PasteFromClipboard
		Dim Value As WString Ptr
		WLet(Value, pClipBoard->GetAsText)
		If Value Then
			WLetEx Value, Replace(*Value, Chr(13) & Chr(10), Chr(13)), True
			WLetEx Value, Replace(*Value, Chr(10), Chr(13)), True
			ChangeText *Value, 0, "Xotiradan qo`yildi"
			WDeallocate Value
		End If
	End Sub
	
	Sub EditControl.ClearUndo
		On Error Goto A
		For i As Integer = curHistory To 0 Step -1
			If FHistory.Count > curHistory Then
				Delete_( Cast(EditControlHistory Ptr, FHistory.Items[i]))
			End If
			'FHistory.Remove i
		Next i
		FHistory.Clear
		curHistory = 0
		'Changed "Matn almashtirildi"
		If FLines.Count = 0 Then
			FECLine = New_( EditControlLine)
			WLet(FECLine->Text, "")
			FLines.Add(FECLine)
		End If
		ChangeText "", 0, "Matn almashtirildi"
		Exit Sub
		A:
		MsgBox ErrDescription(Err) & " (" & Err & ") " & _
		"in function " & ZGet(Erfn()) & " " & _
		"in module " & ZGet(Ermn())' & " " & _
		'"in line " & Erl()
	End Sub
	
	Property EditControl.Text ByRef As WString
		Return WStr("")
	End Property
	
	Property EditControl.Text(ByRef Value As WString) '...'
		'ChangeText Value, "Matn almashtirildi"
	End Property
	
	Property EditControl.HintWord ByRef As WString
		Return WGet(FHintWord)
	End Property
	
	Property EditControl.HintWord(ByRef Value As WString)
		WLet(FHintWord, Value)
	End Property
	
	Property EditControl.SelText ByRef As WString
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		WLet(FLine, "")
		For i As Integer = iSelStartLine To iSelEndLine
			If i = iSelStartLine And i = iSelEndLine Then
				WLet(FLine, Mid(Lines(i), iSelStartChar + 1, iSelEndChar - iSelStartChar))
			ElseIf i = iSelStartLine Then
				WLet(FLine, Mid(Lines(i), iSelStartChar + 1))
			ElseIf i = iSelEndLine Then
				WAdd FLine, Chr(13) & Chr(10) & .Left(Lines(i), iSelEndChar)
			Else
				WAdd FLine, Chr(13) & Chr(10) & Lines(i)
			End If
		Next i
		Return *FLine
	End Property
	
	Property EditControl.SelText(ByRef Value As WString)
		ChangeText Value, 0, "Matn qo`shildi"
	End Property
	
	Sub EditControl.LoadFromFile(ByRef FileName As WString, ByRef FileEncoding As FileEncodings, ByRef NewLineType As NewLineTypes)
		'Dim Buff As WString * 1024 '  for V1.07 Line Input not working fine
		Dim pBuff As WString Ptr
		Dim As Integer Result = -1, Fn = FreeFile_, FileSize
		Var iC = 0, OldiC = 0, i = 0
		Result = Open(FileName For Input Encoding "utf-8" As #Fn): FileEncoding = FileEncodings.Utf8
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn): FileEncoding = FileEncodings.Utf32
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn): FileEncoding = FileEncodings.Utf16
		If Result <> 0 Then Result = Open(FileName For Input As #Fn): FileEncoding = FileEncodings.PlainText
		If Result = 0 Then
			FileSize = LOF(Fn)
			WReallocate(pBuff, FileSize)
			For i As Integer = FLines.Count - 1 To 0 Step -1
				Delete_( Cast(EditControlLine Ptr, FLines.Items[i]))
			Next i
			FLines.Clear
			'VisibleLines.Clear
			i = 0
			Do Until EOF(Fn)
				'Line Input #Fn, Buff
				LineInputWstr Fn, pBuff, FileSize
				FECLine = New_( EditControlLine)
				If FECLine = 0 Then
					CloseFile_(Fn)
					Return
				End If
				WLet(FECLine->Text, *pBuff)
				iC = FindCommentIndex(*pBuff, OldiC)
				FECLine->CommentIndex = iC
				FLines.Add(FECLine)
				ChangeCollapsibility i
				'If FECLine->Visible Then VisibleLines.Add(FECLine)
				OldiC = iC
				i += 1
			Loop
			NewLineType = NewLineTypes.WindowsCRLF
			If i = 1 Then
				If InStr(*pBuff, Chr(10)) > 0 Then
					NewLineType = NewLineTypes.LinuxLF
				ElseIf InStr(*pBuff, Chr(13)) > 0 Then
					NewLineType = NewLineTypes.MacOSCR
				End If
			End If
			ScrollToCaret
			CloseFile_(Fn)
		Else
			MsgBox ML("Open file failure!") &  " " & ML("in function") & " EditControl.LoadFromFile" & Chr(13,10) & " " & FileName
		End If
		WDeallocate pBuff
	End Sub
	
	Sub EditControl.SaveToFile(ByRef File As WString, FileEncoding As FileEncodings, NewLineType As NewLineTypes)
		Dim As Integer Fn = FreeFile_
		Dim As Integer Result
		Dim As String FileEncodingText, NewLine
		If FileEncoding = FileEncodings.Utf8 Then
			FileEncodingText = "utf-8"
		ElseIf FileEncoding = FileEncodings.Utf16 Then
			FileEncodingText = "utf-16"
		ElseIf FileEncoding = FileEncodings.Utf32 Then
			FileEncodingText = "utf-32"
		Else
			FileEncodingText = "ascii"
		End If
		If NewLineType = NewLineTypes.LinuxLF Then
			NewLine = Chr(10)
		ElseIf NewLineType = NewLineTypes.MacOSCR Then
			NewLine = Chr(13)
		Else
			NewLine = Chr(13, 10)
		End If
		If Open(File For Output Encoding FileEncodingText As #Fn) = 0 Then
			For i As Integer = 0 To FLines.Count - 1
				Print #Fn, *Cast(EditControlLine Ptr, FLines.Item(i))->Text & NewLine;
			Next
		Else
			MsgBox ML("Save file failure!") & Chr(13,10) & File
		End If
		CloseFile_(Fn)
	End Sub
	
	Sub EditControl.Clear
		ChangeText "", 0, "Matn tozalandi"
	End Sub
	
	Function EditControl.LinesCount As Integer '...'
		Return FLines.Count
	End Function
	
	Sub EditControl.InsertLine(Index As Integer, ByRef sLine As WString)
		Var iC = 0, OldiC = 0
		If Index > 0 AndAlso Index < FLines.Count - 1 Then
			OldiC = Cast(EditControlLine Ptr, FLines.Items[Index])->CommentIndex
		End If
		FECLine = New_( EditControlLine)
		WLet(FECLine->Text, sLine)
		iC = FindCommentIndex(sLine, OldiC)
		FECLine->CommentIndex = iC
		FLines.Insert Index, FECLine
		ChangeCollapsibility Index
		If Index <= FSelEndLine Then FSelEndLine += 1
		If Index <= FSelStartLine Then FSelStartLine += 1
	End Sub
	
	Sub EditControl.ReplaceLine(Index As Integer, ByRef sLine As WString)
		Var iC = 0, OldiC = 0
		If Index > 0 AndAlso Index < FLines.Count - 1 Then
			OldiC = Cast(EditControlLine Ptr, FLines.Items[Index])->CommentIndex
		End If
		FECLine = FLines.Items[Index]
		WLet(FECLine->Text, sLine)
		iC = FindCommentIndex(sLine, OldiC)
		FECLine->CommentIndex = iC
		ChangeCollapsibility Index
	End Sub
	
	Sub EditControl.DuplicateLine(Index As Integer = -1)
		Changing "Duplicate line"
		Var iC = 0, OldiC = 0
		Var Idx = IIf(Index = -1, FSelEndLine, Index)
		If Idx > 0 AndAlso Idx < FLines.Count - 1 Then
			OldiC = Cast(EditControlLine Ptr, FLines.Items[Idx])->CommentIndex
		End If
		FECLine = New_( EditControlLine)
		WLet(FECLine->Text, *Cast(EditControlLine Ptr, FLines.Items[Idx])->Text)
		iC = FindCommentIndex(*FECLine->Text, OldiC)
		FECLine->CommentIndex = iC
		FLines.Insert Idx + 1, FECLine
		ChangeCollapsibility Idx + 1
		If FSelStartLine = FSelEndLine Then FSelStartLine += 1
		FSelEndLine += 1
		Changed "Duplicate line"
	End Sub
	
	Sub EditControl.DeleteLine(Index As Integer = -1)
		Delete_( Cast(EditControlLine Ptr, FLines.Items[IIf(Index = -1, FSelEndLine, Index)]))
		FLines.Remove Index
	End Sub
	
	Sub EditControl.UnFormatCode(WithoutUpdate As Boolean = False)
		If Not WithoutUpdate Then UpdateLock
		Changing("UnFormat")
		For i As Integer = 0 To FLines.Count - 1
			FECLine = FLines.Items[i]
			WLet(FECLine->Text, LTrim(*FECLine->Text, Any !"\t "))
		Next i
		Changed("UnFormat")
		If Not WithoutUpdate Then 
			UpdateUnLock
			ShowCaretPos True
		End If
	End Sub
	
	Sub EditControl.FormatCode(WithoutUpdate As Boolean = False)
		Dim As Integer iIndents, CurIndents, iCount, iComment, ConstructionIndex, ConstructionPart
		Dim As EditControlLine Ptr ECLine2
		Dim As UString LineParts(Any), LineQuotes(Any)
		Dim As Integer iType = -1 '
		If Not WithoutUpdate Then UpdateLock
		Changing("Format")
		For i As Integer = 0 To FLines.Count - 1
			FECLine = FLines.Items[i]
			'
			If Trim(*FECLine->Text, Any !"\t ") <> "" Then WLet(FECLine->Text, Trim(*FECLine->Text, Any !"\t "))
			'If *FECLine->Text = "" Then Continue For
			If .Left(Trim(LCase(*FECLine->Text), Any !"\t "), 3) = "if(" Then wLet(FECLine->Text, "If (" & Mid(*FECLine->Text, 4))
			'If LCase(*FECLine->Text) = "endif" Then wLet FECLine->Text,"End If"
			If iComment = 0 Then
				If FECLine->Multiline Then
					Split(*FECLine->Text, """", LineQuotes())
					WLet(FLine, "")
					For k As Integer = 0 To UBound(LineQuotes) Step 2
						WAdd FLine, LineQuotes(k)
					Next
					iPos = InStr(*FLine, "'") - 1
					If iPos = -1 Then iPos = Len(*FLine)
					Split(.Left(*FLine, iPos), ":", LineParts())
					ConstructionIndex = GetConstruction(LineParts(0), ConstructionPart)
					If ConstructionIndex > -1 AndAlso ConstructionPart > 0 Then
						iIndents = Max(0, iIndents - 1)
					End If
				Else
					If FECLine->ConstructionIndex > -1 AndAlso FECLine->ConstructionPart > 0 Then
						iIndents = Max(0, iIndents - 1)
					End If
				End If
				CurIndents = iIndents
				If FECLine->ConstructionIndex = 1 AndAlso FECLine->ConstructionPart > 0 Then
					iCount = 0
					For j As Integer = i - 1 To 0 Step -1
						ECLine2 = FLines.Items[j]
						If ECLine2->ConstructionIndex >= 1 AndAlso ECLine2->ConstructionIndex <= 3 Then
							If ECLine2->ConstructionPart = 2 Then
								iCount += 1
							ElseIf ECLine2->ConstructionPart = 0 Then
								If iCount = 0 Then
									CurIndents = (Len(Replace(*ECLine2->Text, !"\t", WSpace(TabWidth))) - Len(LTrim(*ECLine2->Text, Any !"\t"))) / TabWidth
									If FECLine->ConstructionPart = 1 Then iIndents = CurIndents
									Exit For
								Else
									iCount -= 1
								End If
							End If
						End If
					Next
				ElseIf FECLine->ConstructionIndex = 7 AndAlso FECLine->ConstructionPart = 2 Then
					iPos = InStr(*FECLine->Text, "'") - 1
					If iPos = -1 Then iPos = Len(*FECLine->Text)
					iPos = InStrCount(.Left(*FECLine->Text, iPos), ",")
					iIndents -= iPos
					CurIndents = iIndents
				End If
			End If
			WLet(FECLine->Text, IIf(TabAsSpaces AndAlso ChoosedTabStyle = 0, WSpace(CurIndents * TabWidth), WString(CurIndents, !"\t")) & LTrim(*FECLine->Text, Any !"\t "))
			If iComment = 0 Then
				If FECLine->Multiline Then
					For k As Integer = 0 To UBound(LineParts)
						ConstructionIndex = GetConstruction(LineParts(k), ConstructionPart)
						If k > 0 AndAlso ConstructionIndex > -1 AndAlso ConstructionPart > 0 Then
							iIndents = Max(0, iIndents - 1)
						End If
						If ConstructionIndex > -1 AndAlso ConstructionPart < 2 Then
							iIndents += 1
						End If
					Next k
				Else
					If FECLine->ConstructionIndex > -1 AndAlso FECLine->ConstructionPart < 2 Then
						iIndents += 1
					End If
				End If
			End If
			CurIndents = iIndents
			iComment = FECLine->CommentIndex
		Next i
		Changed("Format")
		If Not WithoutUpdate Then
			UpdateUnLock
			ShowCaretPos True
		End If
	End Sub
	
	Function EditControl.VisibleLinesCount() As Integer
		Return (dwClientY) / dwCharY
	End Function
	
	Function EditControl.CharIndexFromPoint(X As Integer, Y As Integer) As Integer
		WLet(FLine, *Cast(EditControlLine Ptr, FLines.Item(LineIndexFromPoint(X, Y)))->Text)
		Dim As Integer nCaretPosX = X - LeftMargin + HScrollPos * dwCharX
		Dim As Integer w = TextWidth(GetTabbedText(*FLine))
		Dim As Integer Idx = Len(*FLine)
		If w - 2 > nCaretPosX Then
			Idx = 0
			For i As Integer = 0 To Len(*FLine)
				w = TextWidth(GetTabbedText(Mid(*FLine, 1, i)))
				If w - 2 > nCaretPosX Then Exit For
				Idx = i
			Next i
		End If
		Return Idx
	End Function
	
	Function EditControl.LineIndexFromPoint(X As Integer, Y As Integer) As Integer
		Return GetLineIndex(0, Max(0, Min(Fix(Y / dwCharY) + VScrollPos, LinesCount - 1)))
	End Function
	
	Function EditControl.Lines(Index As Integer) ByRef As WString
		If Index >= 0 And Index < FLines.Count Then Return *Cast(EditControlLine Ptr, FLines.Item(Index))->Text
	End Function
	
	Function EditControl.LineLength(Index As Integer) As Integer '...'
		If Index >= 0 And Index < FLines.Count Then Return Len(*Cast(EditControlLine Ptr, FLines.Item(Index))->Text) Else Return 0
	End Function
	
	Function EditControl.GetCaretPosY(LineIndex As Integer) As Integer
		Static As Integer i, j
		j = 0
		For i = 1 To Min(FLines.Count - 1, LineIndex)
			If Cast(EditControlLine Ptr, FLines.Items[i])->Visible Then j = j + 1
		Next
		Return j
	End Function
	
	Sub EditControl.ShowLine(LineIndex As Integer)
		Do
			ChangeCollapseState GetLineIndex(LineIndex, 0), False
		Loop While Not Cast(EditControlLine Ptr, FLines.Items[LineIndex])->Visible
	End Sub
	
	Function IsArg2(ByRef sLine As WString) As Boolean
		For i As Integer = 1 To Len(sLine)
			If Not IsArg(Asc(Mid(sLine, i, 1))) Then Return False
		Next
		Return True
	End Function
	
	Function GetNextCharIndex(ByRef sLine As WString, iEndChar As Integer, WithDot As Boolean = False) As Integer
		Dim i As Integer
		Dim s As String
		For i = iEndChar + 1 To Len(sLine)
			s = Mid(sLine, i, 1)
			If Not CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(i = iEndChar + 1) AndAlso CInt(s = "#" OrElse s = "$")) OrElse CInt(WithDot AndAlso s = ".")) Then
				Return i - 1
			End If
		Next
		Return i - 1
	End Function
	
	Function EditControl.GetWordAt(LineIndex As Integer, CharIndex As Integer, WithDot As Boolean = False) As String
		Dim As Integer i
		Dim As String s, sWord, sLine = Lines(LineIndex)
		For i = CharIndex To 1 Step -1
			s = Mid(sLine, i, 1)
			If CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(s = "#" OrElse s = "$"))) OrElse IIf(WithDot, s = ".", 0) Then sWord = s & sWord Else Exit For
		Next
		For i = CharIndex + 1 To Len(sLine)
			s = Mid(sLine, i, 1)
			If CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(s = "#" OrElse s = "$"))) OrElse IIf(WithDot, s = ".", 0) Then sWord = sWord & s Else Exit For
		Next
		Return sWord
	End Function
	
	Function EditControl.GetWordAtCursor(WithDot As Boolean = False) As String
		Return GetWordAt(FSelEndLine, FSelEndChar, WithDot)
	End Function
	
	Function EditControl.GetWordAtPoint(X As Integer, Y As Integer, WithDot As Boolean = False) As String
		If X <= LeftMargin Then Return ""
		Var LineIndex = Fix(Y / dwCharY) + VScrollPos
		Var j = -1, k = -1
		For i As Integer = 0 To FLines.Count - 1
			If Cast(EditControlLine Ptr, FLines.Items[i])->Visible Then
				j = j + 1
				If j = LineIndex Then k = j: Exit For
			End If
		Next
		If k = -1 Then Return ""
		WLet(FLine, *Cast(EditControlLine Ptr, FLines.Item(k))->Text)
		Dim As Integer nCaretPosX = X - LeftMargin + HScrollPos * dwCharX
		Dim As Integer w = TextWidth(GetTabbedText(*FLine))
		Dim As Integer Idx = Len(*FLine)
		If w - 2 <= nCaretPosX Then Return ""
		Idx = 0
		For i As Integer = 0 To Len(*FLine)
			w = TextWidth(GetTabbedText(Mid(*FLine, 1, i)))
			If w - 2 > nCaretPosX Then Exit For
			Idx = i
		Next i
		Return GetWordAt(k, Idx, WithDot)
	End Function
	
	Function EditControl.GetTabbedLength(ByRef SourceText As WString) As Integer
		lText = Len(SourceText)
		iPos = 0
		ii = 1
		Do While ii <= lText
			sChar = Mid(SourceText, ii, 1)
			If sChar = !"\t" Then
				iPP = TabWidth - (iPos + TabWidth) Mod TabWidth
				iPos += iPP
			Else
				iPos += 1
			End If
			ii += 1
		Loop
		Return iPos
	End Function
	
	Function EditControl.GetTabbedText(ByRef SourceText As WString, ByRef PosText As Integer = 0, ForPrint As Boolean = False) ByRef As WString
		lText = Len(SourceText)
		WReallocate(FLineTab, lText * TabWidth + 1)
		*FLineTab = ""
		iPos = PosText
		ii = 1
		Do While ii <= lText
			sChar = Mid(SourceText, ii, 1)
			If sChar = !"\t" Then
				iPP = TabWidth - ((iPos + TabWidth) Mod TabWidth)
				If ForPrint Then
					*FLineTab &= String(iPP - 1, 1) & Chr(2)
				Else
					*FLineTab &= Space(iPP)
				End If
				iPos += iPP
			Else
				*FLineTab &= sChar
				iPos += 1
			End If
			ii += 1
		Loop
		PosText = iPos
		Return *FLineTab
	End Function
	
	Sub EditControl.ShowCaretPos(Scroll As Boolean = False)
		nCaretPosY = GetCaretPosY(FSelEndLine)
		FCurLineCharIdx = FSelEndChar
		nCaretPosX = TextWidth(GetTabbedText(.Left(Lines(FSelEndLine), FCurLineCharIdx)))
		If CInt(DropDownShowed) AndAlso CInt(CInt(FSelEndChar < DropDownChar) OrElse CInt(FSelEndChar > GetNextCharIndex(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, DropDownChar))) Then
			CloseDropDown()
		End If
		If CInt(ToolTipShowed) AndAlso CInt(CInt(FSelEndChar < ToolTipChar) OrElse CInt(Mid(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, FSelEndChar + 1, 1) = ":") OrElse CInt(GetWordAt(FSelEndLine, ToolTipChar) <> HintWord AndAlso Mid(Lines(FSelEndLine), ToolTipChar + 2, 1) <> "?")) Then
			CloseToolTip()
		End If
		If OldLine <> FSelEndLine OrElse OldChar <> FSelEndChar Then
			If This.OnSelChange Then This.OnSelChange(This, FSelEndLine, FSelEndChar)
		End If
		If OldLine <> FSelEndLine Then
			If ToolTipShowed Then CloseToolTip()
			If Not bOldCommented Then Changing "Matn kiritildi"
			If This.OnLineChange Then This.OnLineChange(This, FSelEndLine, OldLine)
		End If
		
		If CInt(FSelStartLine > -1) AndAlso CInt(FSelStartLine < FLines.Count) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelStartLine])->Visible) Then
			ShowLine FSelStartLine
		End If
		If CInt(FSelEndLine > -1) AndAlso CInt(FSelEndLine < FLines.Count) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Visible) Then
			ShowLine FSelEndLine
		End If
		
		SetScrollsInfo
		If Scroll Then
			Var OldHScrollPos = HScrollPos, OldVScrollPos = VScrollPos
			If nCaretPosX < HScrollPos * dwCharX Then
				HScrollPos = nCaretPosX / dwCharX
			ElseIf LeftMargin + nCaretPosX > HScrollPos * dwCharX + (dwClientX - dwCharX) Then
				HScrollPos = (LeftMargin + nCaretPosX - (dwClientX - dwCharX)) / dwCharX
			ElseIf HScrollPos > HScrollMax Then
				HScrollPos = HScrollMax
			End If
			If nCaretPosY < VScrollPos Then
				VScrollPos = nCaretPosY
			ElseIf nCaretPosY > VScrollPos + (VisibleLinesCount - 2) Then
				VScrollPos = nCaretPosY - (VisibleLinesCount - 2)
			ElseIf VScrollPos > VScrollMax Then
				VScrollPos = VScrollMax
			End If
			
			If OldHScrollPos <> HScrollPos Then
				#ifdef __USE_GTK__
					gtk_adjustment_set_value(adjustmenth, HScrollPos)
				#else
					si.cbSize = SizeOf (si)
					si.fMask = SIF_POS
					si.nPos = HScrollPos
					SetScrollInfo(FHandle, SB_HORZ, @si, True)
				#endif
			End If
			If OldVScrollPos <> VScrollPos Then
				#ifdef __USE_GTK__
					gtk_adjustment_set_value(adjustmentv, VScrollPos)
				#else
					si.cbSize = SizeOf (si)
					si.fMask = SIF_POS
					si.nPos = VScrollPos
					SetScrollInfo(FHandle, SB_VERT, @si, True)
				#endif
			End If
			'If OldHScrollPos <> HScrollPos Or OldVScrollPos <> VScrollPos Then PaintControl
			#ifndef __USE_GTK__
				PaintControl
			#endif
		End If
		
		HCaretPos = LeftMargin + nCaretPosX - HScrollPos * dwCharX
		VCaretPos = (nCaretPosY - VScrollPos) * dwCharY
		If HCaretPos < LeftMargin Or FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then HCaretPos = -1
		#ifdef __USE_GTK__
			If Scroll Then
				CaretOn = True
				PaintControl
			End If
			'gtk_render_insertion_cursor(gtk_widget_get_style_context(widget), cr, 10, 10, layout, 0, PANGO_DIRECTION_LTR)
		#else
			SetCaretPos(ScaleX(HCaretPos), ScaleY(VCaretPos))
		#endif
		OldLine = FSelEndLine
		OldChar = FSelEndChar
		
	End Sub
	
	Sub EditControl.Indent
		Dim n As Integer
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		If FSelStartLine = FSelEndLine Then
			n = Len(GetTabbedText(.Left(Lines(FSelStartLine), Min(FSelStartChar, FSelEndChar))))
			If TabAsSpaces AndAlso (ChoosedTabStyle = 0 OrElse Trim(.Left(Lines(iSelStartLine), iSelStartChar), Any !"\t ") <> "") Then
				SelText = Space(TabWidth - (n Mod TabWidth))
			Else
				SelText = !"\t"
			End If
		Else
			UpdateLock
			Changing("Oldga surish")
			For i As Integer = iSelStartLine To iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
				FECLine = FLines.Items[i]
				If TabAsSpaces AndAlso ChoosedTabStyle = 0 Then
					n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
					n = TabWidth - (n Mod TabWidth)
					WLet(FECLine->Text, Space(n) & *FECLine->Text)
				Else
					n = 1
					WLet(FECLine->Text, !"\t" & *FECLine->Text)
				End If
				If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += n
				If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += n
			Next i
			Changed("Oldga surish")
			UpdateUnLock
		End If
		ShowCaretPos True
	End Sub
	
	Sub EditControl.Outdent
		UpdateLock
		Dim n As Integer
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Changing("Ortga surish")
		For i As Integer = iSelStartLine To iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
			FECLine = FLines.Items[i]
			n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
			n = Min(n, TabWidth - (n Mod TabWidth))
			If n = 0 AndAlso .Left(*FECLine->Text, 1) = !"\t" Then n = 1
			WLet(FECLine->Text, Mid(*FECLine->Text, n + 1))
			If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar -= n
			If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar -= n
		Next i
		Changed("Ortga surish")
		UpdateUnLock
		ShowCaretPos True
	End Sub
	
	Sub EditControl.CommentSingle
		UpdateLock
		Dim n As Integer
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Changing("Izoh qilish")
		For i As Integer = iSelStartLine To iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
			FECLine = FLines.Items[i]
			WLet(FECLine->Text, "'" & *FECLine->Text)
			If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += 1
			If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += 1
		Next i
		Changed("Izoh qilish")
		UpdateUnLock
		ShowCaretPos True
	End Sub
	
	Sub EditControl.CommentBlock
		UpdateLock
		Dim n As Integer
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Changing("Blokli izoh qilish")
		iSelEndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		For i As Integer = iSelStartLine To iSelEndLine
			FECLine = FLines.Items[i]
			If i = iSelStartLine Or i = iSelEndLine Then
				If i = iSelStartLine Then
					WLet(FECLine->Text, "/'" & *FECLine->Text)
					FECLine->CommentIndex += 1
					If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += 2
					If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += 2
				ElseIf i = iSelEndLine Then
					WLet(FECLine->Text, *FECLine->Text & "'/")
				End If
			Else
				FECLine->CommentIndex += 1
			End If
		Next i
		Changed("Blokli izoh qilish")
		UpdateUnLock
		ShowCaretPos True
	End Sub
	
	Sub EditControl.UnComment
		UpdateLock
		Dim n As Integer
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Changing("Izohni olish")
		For i As Integer = iSelStartLine To iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
			FECLine = FLines.Items[i]
			If .Left(Trim(*FECLine->Text, Any !"\t "), 1) = "'" Then
				n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text, Any !"\t "))
				WLet(FLineTemp, .Left(*FECLine->Text, n))
				WLet(FECLine->Text, *FLineTemp & Mid(*FECLine->Text, n + 2))
				If i = FSelEndLine And FSelEndChar > n Then FSelEndChar -= 1
				If i = FSelStartLine And FSelStartChar > n Then FSelStartChar -= 1
			End If
		Next i
		Changed("Izohni olish")
		UpdateUnLock
		ShowCaretPos True
	End Sub
	
	Sub EditControl.ScrollToCaret
		ShowCaretPos True
	End Sub
	
	Function EditControl.MaxLineWidth() As Integer
		Dim As Integer Pos1 = InStr(FText, Chr(13)), l = Len(Chr(13)), c = 0, p = 1, MaxLW = 0, lw = 0
		While Pos1 > 0
			c = c + 1
			lw = TextWidth(Mid(FText, p, Pos1 - p))
			If lw > MaxLW Then MaxLW = lw
			p = Pos1 + l
			Pos1 = InStr(p, FText, Chr(13))
		Wend
		lw = TextWidth(Mid(FText, p, Len(FText) - p + 1))
		If lw > MaxLW Then MaxLW = lw
		Return MaxLW
	End Function
	
	Sub EditControl.SetScrollsInfo()
		
		HScrollMax = 10000 'Max(0, (MaxLineWidth - (dwClientX - LeftMargin - dwCharX))) \ dwCharX
		#ifdef __USE_GTK__
			gtk_adjustment_set_upper(adjustmenth, HScrollMax)
			'gtk_adjustment_configure(adjustmenth, gtk_adjustment_get_value(adjustmenth), 0, HScrollMax, 1, 10, HScrollMax)
		#else
			si.cbSize = SizeOf(si)
			si.fMask  = SIF_RANGE Or SIF_PAGE
			si.nMin   = 0
			si.nMax   = HScrollMax
			si.nPage  = 10
			SetScrollInfo(FHandle, SB_HORZ, @si, True)
		#endif
		
		VScrollMax = Max(0, LinesCount - VisibleLinesCount + 1)
		LeftMargin = Len(Str(LinesCount)) * dwCharX + 30
		
		#ifdef __USE_GTK__
			gtk_adjustment_set_upper(adjustmentv, VScrollMax)
			gtk_adjustment_set_page_size(adjustmentv, 0)
			'gtk_adjustment_configure(adjustmentv, gtk_adjustment_get_value(adjustmentv), 0, VScrollMax, 1, 10, VScrollMax / 10)
		#else
			si.cbSize = SizeOf(si)
			si.fMask  = SIF_RANGE Or SIF_PAGE
			si.nMin   = 0
			si.nMax   = VScrollMax
			si.nPage  = 1
			SetScrollInfo(FHandle, SB_VERT, @si, True)
		#endif
	End Sub
	
	'Sub PaintGliphs(x As Integer, y As Integer, ByRef utf8 As WString)
	'	Dim As cairo_status_t status
	'	'	Dim As cairo_glyph_t Ptr glyphs = NULL
	'	Dim As Integer num_glyphs
	'	Dim As cairo_text_cluster_t Ptr clusters = NULL
	'	Dim As Integer num_clusters
	'	Dim As cairo_text_cluster_flags_t cluster_flags
	
	'	status = cairo_scaled_font_text_to_glyphs (scaled_font, _
	'                                      x, y, _
	'                                     utf8, utf8_len, _
	'                                    @glyphs, @num_glyphs, _
	''                                   @clusters, @num_clusters, @cluster_flags)
	
	'if (status == CAIRO_STATUS_SUCCESS) Then
	'	cairo_show_text_glyphs (cr, _
	'							utf8, utf8_len, _
	'							glyphs, num_glyphs, _
	'							clusters, num_clusters, cluster_flags)
	'
	'			cairo_glyph_free (glyphs)
	'			cairo_text_cluster_free (clusters)
	'		End If
	'	End Sub
	
	Function EditControl.TextWidth(ByRef sText As WString) As Integer
		#ifdef __USE_GTK__
			pango_layout_set_text(layout, ToUTF8(sText), Len(ToUTF8(sText)))
			If cr Then
				pango_cairo_update_layout(cr, layout)
			End If
			#ifdef PANGO_VERSION
				Dim As PangoLayoutLine Ptr pll = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pll = pango_layout_get_line(layout, 0)
			#endif
			Dim As PangoRectangle extend
			pango_layout_line_get_pixel_extents(pll, NULL, @extend)
			Return extend.width
		#else
			Return Canvas.TextWidth(sText)
		#endif
	End Function
	
	Sub GetColor(iColor As Long, ByRef iRed As Double, ByRef iGreen As Double, ByRef iBlue As Double)
		Select Case iColor
			'		Case clBlack:	iRed = 0: iGreen = 0: iBlue = 0
			'		Case clRed:		iRed = 0.8: iGreen = 0: iBlue = 0
			'		Case clGreen:	iRed = 0: iGreen = 0.8: iBlue = 0
			'		Case clBlue:	iRed = 0: iGreen = 0: iBlue = 1
			'		Case clWhite:	iRed = 1: iGreen = 1: iBlue = 1
			'		Case clOrange:	iRed = 1: iGreen = 83 / 255.0: iBlue = 0
		Case Else: iRed = Abs(GetRed(iColor) / 255.0): iGreen = Abs(GetGreen(iColor) / 255.0): iBlue = Abs(GetBlue(iColor) / 255.0)
		End Select
	End Sub
	
	#ifdef __USE_GTK__
		Sub cairo_rectangle(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As Boolean)
			.cairo_rectangle(cr, x, y, x1 - x, y1 - y)
		End Sub
	#endif
	
	#ifdef __USE_GTK__
		Sub cairo_rectangle_(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As Boolean)
			'.cairo_rectangle(cr, x, y, x1 - x, y1 - y)
			cairo_move_to (cr, x, y)
			cairo_line_to (cr, x1, y)
			cairo_line_to (cr, x1, y1)
			cairo_line_to (cr, x, y1)
			cairo_line_to (cr, x, y)
		End Sub
	#endif
	
	Sub EditControl.PaintText(iLine As Integer, ByRef sText As WString, iStart As Integer, iEnd As Integer, ByRef Colors As ECColorScheme, ByRef addit As WString = "", Bold As Boolean = False, Italic As Boolean = False, Underline As Boolean = False)
		'Dim s As WString Ptr
		'WLet s, sText 'Mid(sText, 1, HScrollPos + This.Width / dwCharX)
'		If LeftMargin + (-HScrollPos + iStart) * dwCharX > dwClientX Then
'			Exit Sub
'		End If
'		'ElseIf LeftMargin + (-HScrollPos + InStrCount(Left(sText, iEnd), !"\t") * TabWidth) * dwCharX < 0 Then
'		If LeftMargin + (-HScrollPos + iEnd + InStrCount(Left(sText, iEnd), !"\t") * (TabWidth - 1)) * dwCharX < 0 Then
'			Exit Sub
'		End If
		iPPos = 0
		WLet(FLineLeft, GetTabbedText(.Left(sText, iStart), iPPos))
		WLet(FLineRight, GetTabbedText(Mid(sText, iStart + 1, iEnd - iStart) & addit, iPPos))
		#ifdef __USE_GTK__
			Dim As PangoRectangle extend, extend2
			Dim As Double iRed, iGreen, iBlue
			extend.width = TextWidth(*FLineLeft)
			pango_layout_set_text(layout, ToUTF8(*FLineRight), Len(ToUTF8(*FLineRight)))
			pango_cairo_update_layout(cr, layout)
			#ifdef PANGO_VERSION
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			pango_layout_line_get_pixel_extents(pl, NULL, @extend2)
			If HighlightCurrentWord AndAlso @Colors <> @Selection AndAlso CurWord = *FLineRight Then
				'GetColor BKColor, iRed, iGreen, iBlue
				cairo_set_source_rgb(cr, CurrentWord.BackgroundRed, CurrentWord.BackgroundGreen, CurrentWord.BackgroundBlue)
				.cairo_rectangle (cr, LeftMargin + -HScrollPos * dwCharX + extend.width, (iLine - VScrollPos) * dwCharY, extend2.width, dwCharY)
				cairo_fill (cr)
			ElseIf Colors.Background <> -1 Then
				pango_layout_line_get_pixel_extents(pl, NULL, @extend2)
				'GetColor BKColor, iRed, iGreen, iBlue
				cairo_set_source_rgb(cr, Colors.BackgroundRed, Colors.BackgroundGreen, Colors.BackgroundBlue)
				.cairo_rectangle (cr, LeftMargin + -HScrollPos * dwCharX + extend.width, (iLine - VScrollPos) * dwCharY, extend2.width, dwCharY)
				cairo_fill (cr)
			End If
			cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + extend.width - 0.5, (iLine - VScrollPos) * dwCharY + dwCharY - 5 - 0.5)
			'GetColor TextColor, iRed, iGreen, iBlue
			cairo_set_source_rgb(cr, Colors.ForegroundRed, Colors.ForegroundGreen, Colors.ForegroundBlue)
			pango_cairo_show_layout_line(cr, pl)
		#else
			If HighlightCurrentWord AndAlso @Colors <> @Selection AndAlso CurWord = *FLineRight Then
				SetBKColor(bufDC, CurrentWord.Background)
				'ElseIf @Colors = @NormalText Then
				'	SetBKMode(bufDC, TRANSPARENT)
			Else
				If Colors.Background = -1 Then
					SetBKMode(bufDC, TRANSPARENT)
				Else
					SetBKColor(bufDC, Colors.Background)
				End If
			End If
			SetTextColor(bufDC, Colors.Foreground)
			GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @Sz)
			If Bold Or Italic Or Underline Then
				Canvas.Font.Bold = Bold
				Canvas.Font.Italic = Italic
				Canvas.Font.Underline = Underline
				SelectObject(bufDC, This.Canvas.Font.Handle)
			End If
			TextOut(bufDC, ScaleX(LeftMargin + -HScrollPos * dwCharX) + IIf(iStart = 0, 0, Sz.cx), ScaleY((iLine - VScrollPos) * dwCharY), FLineRight, Len(*FLineRight))
			If Colors.Background = -1 Then SetBKMode(bufDC, OPAQUE)
			If Bold Or Italic Or Underline Then
				Canvas.Font.Bold = False
				Canvas.Font.Italic = False
				Canvas.Font.Underline = False
				SelectObject(bufDC, This.Canvas.Font.Handle)
			End If
		#endif
		'WDeallocate s
	End Sub
	
	Sub EditControl.FontSettings()
		Canvas.Font = This.Font
		WLet(CurrentFontName, *EditorFontName)
		CurrentFontSize = EditorFontSize
		#ifndef __USE_GTK__
			'hd = GetDc(FHandle)
			SelectObject(hd, This.Font.Handle)
			GetTextMetrics(hd, @tm)
			'ReleaseDC(FHandle, hd)
			
			dwCharX = UnScaleX(tm.tmAveCharWidth)
			dwCharY = UnScaleY(tm.tmHeight)
		#endif
		LeftMargin = Len(Str(LinesCount)) * dwCharX + 5 * dwCharX '30
		
		dwClientX = ClientWidth
		dwClientY = ClientHeight
	End Sub
	
	Sub EditControl.PaintControlPriv
		'	On Error Goto ErrHandler
		#ifdef __USE_GTK__
			If cr = 0 Then Exit Sub
		#else
			hd = GetDC(FHandle)
			If CurrentFontSize <> EditorFontSize OrElse *CurrentFontName <> *EditorFontName Then
				This.Font.Name = *EditorFontName
				This.Font.Size = EditorFontSize
				FontSettings
			End If
			bufDC = CreateCompatibleDC(hD)
			bufBMP = CreateCompatibleBitmap(hD, ScaleX(dwClientX), ScaleY(dwClientY))
		#endif
		'iMin = Min(FSelEnd, FSelStart)
		'iMax = Max(FSelEnd, FSelStart)
		'iLineIndex = LineFromCharIndex(iMax)
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		iCount = 0
		BracketsStart = -1
		BracketsStartLine = -1
		BracketsEnd = -1
		BracketsEndLine = -1
		If HighlightBrackets Then
			Symb = Mid(Lines(iSelEndLine), iSelEndChar + 1, 1)
			If InStr(OpenBrackets, Symb) Then
				iStartBS = iSelEndChar + 1
				iStartBE = iSelEndChar + 2
				SymbOpenBrackets = Symb
				SymbCloseBrackets = Mid(CloseBrackets, InStr(OpenBrackets, Symb), 1)
			ElseIf InStr(CloseBrackets, Symb) Then
				iStartBS = iSelEndChar
				iStartBE = iSelEndChar + 1
				SymbOpenBrackets = Mid(OpenBrackets, InStr(CloseBrackets, Symb), 1)
				SymbCloseBrackets = Symb
			ElseIf InStr(CloseBrackets, Mid(Lines(iSelEndLine), iSelEndChar, 1)) Then
				iStartBS = iSelEndChar - 1
				iStartBE = iSelEndChar
				Symb = Mid(Lines(iSelEndLine), iSelEndChar, 1)
				SymbOpenBrackets = Mid(OpenBrackets, InStr(CloseBrackets, Symb), 1)
				SymbCloseBrackets = Symb
			Else
				iStartBS = iSelEndChar + 1
				iStartBE = iSelEndChar + 1
				SymbOpenBrackets = ""
				SymbCloseBrackets = ""
			End If
			bFinded = False
			For j As Integer = iSelEndLine To 0 Step -1
				BracketsLine = TextWithoutQuotesAndComments(Lines(j))
				For i As Integer = IIf(j = iSelEndLine, iStartBS, Len(BracketsLine)) To 1 Step -1
					Symb = Mid(BracketsLine, i, 1)
					If Symb = SymbOpenBrackets OrElse SymbOpenBrackets = "" AndAlso InStr(OpenBrackets, Symb) Then
						If iCount = 0 Then
							BracketsStart = i - 1
							BracketsStartLine = j
							SymbOpenBrackets = Symb
							SymbCloseBrackets = Mid(CloseBrackets, InStr(OpenBrackets, Symb), 1)
							bFinded = True
							Exit For
						Else
							iCount -= 1
						End If
					ElseIf Symb = SymbCloseBrackets OrElse SymbCloseBrackets = "" AndAlso InStr(CloseBrackets, Symb) Then
						iCount += 1
					End If
				Next
				If CInt(bFinded) OrElse CInt(j > 0 AndAlso Not EndsWith(Lines(j - 1), " _")) Then Exit For
			Next
			bFinded = False
			For j As Integer = iSelEndLine To FLines.Count - 1
				BracketsLine = TextWithoutQuotesAndComments(Lines(j))
				For i As Integer = IIf(j = iSelEndLine, iStartBE, 1) To Len(BracketsLine)
					Symb = Mid(BracketsLine, i, 1)
					If Symb = SymbCloseBrackets OrElse SymbCloseBrackets = "" AndAlso InStr(CloseBrackets, Symb) Then
						If iCount = 0 Then
							BracketsEnd = i - 1
							BracketsEndLine = j
							SymbOpenBrackets = Mid(OpenBrackets, InStr(CloseBrackets, Symb), 1)
							SymbCloseBrackets = Symb
							bFinded = True
							Exit For
						Else
							iCount -= 1
						End If
					ElseIf Symb = SymbOpenBrackets OrElse SymbOpenBrackets = "" AndAlso InStr(OpenBrackets, Symb) Then
						iCount += 1
					End If
				Next
				If bFinded OrElse Not EndsWith(Lines(j), " _") Then Exit For
			Next
		End If
		If CInt(HighlightCurrentWord) AndAlso iSelStartLine = iSelEndLine AndAlso iSelStartChar = iSelEndChar Then CurWord = GetWordAtCursor Else CurWord = ""
		iC = 0
		vlc = Min(LinesCount, VScrollPos + VisibleLinesCount + 2)
		vlc1 = VisibleLinesCount
		IzohBoshi = 0
		QavsBoshi = 0
		MatnBoshi = 0
		Matn = ""
		#ifndef __USE_GTK__
			SelectObject(bufDC, bufBMP)
			HideCaret(FHandle)
		#endif
		This.Canvas.Brush.Color = NormalText.Background
		#ifdef __USE_GTK__
			Dim As Double iRed, iGreen, iBlue
			#ifdef __USE_GTK3__
				cairo_rectangle (cr, 0.0, 0.0, gtk_widget_get_allocated_width (widget), gtk_widget_get_allocated_height (widget), True)
			#else
				cairo_rectangle (cr, 0.0, 0.0, widget->allocation.width, widget->allocation.height, True)
			#endif
			cairo_set_source_rgb(cr, NormalText.BackgroundRed, NormalText.BackgroundGreen, NormalText.BackgroundBlue)
			cairo_fill (cr)
		#else
			'			This.Canvas.Font.Name = *EditorFontName
			'			This.Canvas.Font.Size = EditorFontSize
			This.Canvas.Pen.Color = FoldLines.Foreground
			SetRect(@rc, ScaleX(LeftMargin), 0, ScaleX(dwClientX), ScaleY(dwClientY))
			SelectObject(bufDC, This.Canvas.Brush.Handle)
			SelectObject(bufDC, This.Canvas.Font.Handle)
			SelectObject(bufDC, This.Canvas.Pen.Handle)
			SetROP2 bufDC, This.Canvas.Pen.Mode
			FillRect bufDC, @rc, This.Canvas.Brush.Handle
		#endif
		i = -1
		If VScrollPos > 0 AndAlso VScrollPos <= FLines.Count Then iC = Cast(EditControlLine Ptr, FLines.Items[VScrollPos - 1])->CommentIndex
		CollapseIndex = 0
		OldCollapseIndex = 0
		'ChangeCase = False
		For z As Integer = 0 To FLines.Count - 1
			FECLine = FLines.Items[z]
			If FECLine->ConstructionIndex >= 0 AndAlso Constructions(FECLine->ConstructionIndex).Collapsible Then
				If FECLine->ConstructionPart = 0 Then
					CollapseIndex += 1
				ElseIf FECLine->ConstructionPart = 2 Then
					CollapseIndex = Max(0, CollapseIndex - 1)
				End If
			End If
			If Not FECLine->Visible Then OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Continue For
			i = i + 1
			If i < VScrollPos Then OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Continue For
			If z > 0 Then iC = Cast(EditControlLine Ptr, FLines.Items[z - 1])->CommentIndex
			'If FECLine->Visible = False Then Continue For
			'SelectObject(bufDC, This.Canvas.Brush.Handle)
			'Pos1 = Instr(p, *FText, Chr(13))
			'c = c + 1
			'If c <= VScrollPos Then Continue Do
			'i = c - 1
			'ss = FECLine->CharIndex 'p - 1
			'If Pos1 = 0 Then
			'    *FLine = Mid(*FText, p, Len(*FText) - p + 1)
			'Else
			'        *FLine = Mid(*FText, p, Pos1 - p)
			'End If
			s = FECLine->Text 'FLine
			l = Len(*s) 'FECLine->Length 'Len(*s)
			bQ = False
			j = 1
			IzohBoshi = 0
			QavsBoshi = 0
			MatnBoshi = 0
			Matn = ""
			If i < VScrollPos Then
				Do While j <= l
					If iC = 0 AndAlso Mid(*s, j, 1) = """" Then
						bQ = Not bQ
					ElseIf Not bQ Then
						If Mid(*s, j, 2) = "/'" Then
							iC = iC + 1
							If iC = 1 Then
								IzohBoshi = j
							End If
							j = j + 1
						ElseIf iC > 0 AndAlso Mid(*s, j, 2) = "'/" Then
							iC = iC - 1
							j = j + 1
						ElseIf iC = 0 AndAlso (Mid(*s, j, 1) = "'" OrElse LCase(Mid(" " & *s & " ", j, 5)) = " rem " OrElse LCase(Mid(" " & *s & " ", j - 1, 5)) = !"\trem ") Then
							Exit Do
						End If
					End If
					j = j + 1
				Loop
			Else
				#ifndef __USE_GTK__
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
				#endif
				LinePrinted = False
				If FECLine->BreakPoint Then
					PaintText i, *s, 0, Len(*s), Breakpoints, "", Breakpoints.Bold, Breakpoints.Italic, Breakpoints.Underline
					LinePrinted = True
				End If
				If CurExecutedLine = z AndAlso CurEC <> 0 Then
					PaintText i, *s, Len(*s) - Len(LTrim(*s, Any !"\t ")), Len(*s), IIf(CurEC = @This, ExecutionLine, CurrentLine), ""
					LinePrinted = True
				End If
				If Not SyntaxEdit Then
					PaintText i, *s, 0, Len(*s), NormalText, "", NormalText.Bold, NormalText.Italic, NormalText.Underline
					LinePrinted = True
				End If
				If Not LinePrinted Then
					'					Canvas.Font.Bold = False
					'					Canvas.Font.Italic = False
					'					Canvas.Font.Underline = False
					#ifndef __USE_GTK__
						'SelectObject(bufDC, This.Canvas.Font.Handle)
					#endif
					IzohBoshi = 1
					Do While j <= l
						If LeftMargin + (-HScrollPos + j) * dwCharX > dwClientX AndAlso Mid(*s, j, 1) = " " Then
							If iC = 0 AndAlso FECLine->CommentIndex > 0 Then IzohBoshi = j + 1
							OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Exit Do
						End If
						If iC = 0 AndAlso Mid(*s, j, 1) = """" Then
							bQ = Not bQ
							If bQ Then
								QavsBoshi = j
							Else
								'								If StringsBold Then Canvas.Font.Bold = True
								'								If StringsItalic Then Canvas.Font.Italic = True
								'								If StringsUnderline OrElse bInIncludeFileRect AndAlso iCursorLine = z Then Canvas.Font.Underline = True: SelectObject(bufDC, This.Canvas.Font.Handle)
								PaintText i, *s, QavsBoshi - 1, j, Strings, , Strings.Bold, Strings.Italic, CBool(Strings.Underline) Or CBool(bInIncludeFileRect) And CBool(iCursorLine = z)
								'txtCode.SetSel ss + QavsBoshi - 1, ss + j
								'txtCode.SelColor = clMaroon
							End If
						ElseIf Not bQ Then
							If Mid(*s, j, 2) = IIf(CStyle, "/*", "/'") Then
								iC = iC + 1
								If iC = 1 Then
									IzohBoshi = j
								End If
								j = j + 1
							ElseIf iC > 0 AndAlso Mid(*s, j, 2) = IIf(CStyle, "*/", "'/") Then
								iC = iC - 1
								j = j + 1
								If iC = 0 Then
									PaintText i, *s, IzohBoshi - 1, j, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
								End If
							ElseIf iC = 0 Then
								t = Asc(Mid(*s, j, 1))
								u = Asc(Mid(*s, j + 1, 1))
								If LCase(Mid(" " & *s & " ", j, 5)) = " rem " OrElse LCase(Mid(" " & *s & " ", j, 5)) = !"\trem " Then
									If CInt(ChangeKeyWordsCase) AndAlso CInt(FSelEndLine <> z) AndAlso pkeywords2 <> 0 Then
										Keyword = GetKeyWordCase("rem", pkeywords2)
										If KeyWord <> Mid(*s, j, 3) Then Mid(*s, j, 3) = Keyword
									End If
									PaintText i, *s, j - 1, l, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
									Exit Do
								ElseIf t >= 48 AndAlso t <= 57 OrElse t >= 65 AndAlso t <= 90 OrElse t >= 97 AndAlso t <= 122 OrElse t = Asc("#") OrElse t = Asc("$") OrElse t = Asc("_") OrElse t = Asc(".") Then
									If MatnBoshi = 0 Then MatnBoshi = j
									If Not (u >= 48 AndAlso u <= 57 OrElse u >= 65 AndAlso u <= 90 OrElse u >= 97 AndAlso u <= 122 OrElse u = Asc("#") OrElse u = Asc("$") OrElse u = Asc("_") OrElse (u = Asc(".") AndAlso t >= 48 AndAlso t <= 57)) Then
										If LeftMargin + (-HScrollPos + j + InStrCount(..Left(*s, j), !"\t") * (TabWidth - 1)) * dwCharX > 0 Then
											Matn = Mid(*s, MatnBoshi, j - MatnBoshi + 1)
											sc = @Identifiers
											'ss = NormalText.Background
											If MatnBoshi > 0 Then r = Asc(Mid(*s, MatnBoshi - 1, 1)) Else r = 0
											If r <> 46 AndAlso r <> 62 Then ' . > THEN
												pkeywords = 0
												If CStyle Then
													If LCase(Matn) = "#define" OrElse LCase(Matn) = "#include" Then
														If pkeywords0 <> 0 Then
															sc = @Keywords(KeywordLists.IndexOfObject(pkeywords0)) '@Preprocessors
														End If
													End If
												Else
													For k As Integer = 0 To KeywordLists.Count - 1
														pkeywords = KeywordLists.Object(k)
														If pkeywords->Contains(LCase(Matn)) Then
															sc = @Keywords(k)
															Exit For
														End If
														pkeywords = 0
	'													If keywords0.Contains(LCase(Matn)) Then
	'														sc = @Preprocessors '
	'														pkeywords = @keywords0
	'													ElseIf keywords1.Contains(LCase(Matn)) Then
	'														sc = @Keywords
	'														pkeywords = @keywords1
	'													ElseIf keywords2.Contains(LCase(Matn)) Then
	'														sc = @Keywords
	'														pkeywords = @keywords2
	'													ElseIf keywords3.Contains(LCase(Matn)) Then
	'														sc = @Keywords
	'														pkeywords = @keywords3
	'													End If
													Next k
													If CInt(ChangeKeyWordsCase) AndAlso CInt(pkeywords <> 0) AndAlso CInt(FSelEndLine <> z) Then
														Keyword = GetKeyWordCase(Matn, pkeywords)
														If Keyword <> Matn Then
															'ChangeCase = True
															Mid(*s, MatnBoshi, j - MatnBoshi + 1) = Keyword
														End If
													ElseIf pkeywords = 0 Then
														If IsNumeric(Matn) Then
															If InStr(Matn, ".") Then
																sc = @RealNumbers
															Else
																sc = @Numbers
															End If
														Else
															sc = @Identifiers
														End If
													End If
												End If
											End If
											'If sc <> 0 Then
											PaintText i, *s, MatnBoshi - 1, j, *sc
											'txtCode.SetSel ss + MatnBoshi - 1, ss + j
											'txtCode.SelColor = sc
											'End If
										End If
										MatnBoshi = 0
									End If
								ElseIf IIf(CStyle, Mid(*s, j, 2) = "//", Chr(t) = "'") Then
									PaintText i, *s, j - 1, l, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
									'txtCode.SetSel ss + j - 1, ss + l
									'txtCode.SelColor = clGreen
									Exit Do
								ElseIf Chr(t) <> " " Then
									PaintText i, *s, j - 1, j, NormalText
								End If
							End If
						End If
						j = j + 1
					Loop
					If iC > 0 Then
						PaintText i, *s, Max(0, IzohBoshi - 1), l, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
						'txtCode.SetSel IzohBoshi - 1, ss + l
						'txtCode.SelColor = clGreen
						'If i = EndLine Then k = txtCode.LinesCount
					ElseIf bQ Then
						'						If StringsBold Then Canvas.Font.Bold = True
						'						If StringsItalic Then Canvas.Font.Italic = True
						'						If StringsUnderline OrElse bInIncludeFileRect AndAlso iCursorLine = z Then Canvas.Font.Underline = True: SelectObject(bufDC, This.Canvas.Font.Handle)
						PaintText i, *s, QavsBoshi - 1, j, Strings, , Strings.Bold, Strings.Italic, Strings.Underline Or bInIncludeFileRect And CBool(iCursorLine = z)
					End If
				End If
				If CInt(HighlightCurrentLine) AndAlso CInt(CInt(z = FSelEndLine + 1) OrElse CInt(z = FSelEndLine AndAlso z = FLines.Count - 1)) Then
					Dim As ..Rect rec
					If z = FSelEndLine + 1 Then
						rec = Type(ScaleX(LeftMargin + -HScrollPos * dwCharX), ScaleY((i - VScrollPos - 1) * dwCharY), ScaleX(This.Width), ScaleY((i - VScrollPos - 1) * dwCharY + dwCharY + 1))
					Else
						rec = Type(ScaleX(LeftMargin + -HScrollPos * dwCharX), ScaleY((i - VScrollPos) * dwCharY), ScaleX(This.Width), ScaleY((i - VScrollPos) * dwCharY + dwCharY + 1))
					End If
					#ifdef __USE_GTK__
						cairo_set_source_rgb(cr, CurrentLine.FrameRed, CurrentLine.FrameGreen, CurrentLine.FrameBlue)
						cairo_rectangle (cr, rec.Left, rec.Top, rec.Right, rec.Bottom, True)
						cairo_stroke(cr)
					#else
						This.Canvas.Brush.Color = CurrentLine.Frame
						FrameRect bufDC, @rec, This.Canvas.Brush.Handle
					#endif
				End If
				If FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
					'If iMin <> iMax Then
					If z >= iSelStartLine And z <= iSelEndLine Then
						'    If iMin >= ss And iMin <= ss + l Or iMax >= ss And iMax <= ss + l Or iMin <= ss And iMax >= ss + l Then
						'iStart = Max(iMin - j, 0)
						'iEnd = Min(iMax - j, l)
						'						#ifdef __USE_GTK__
						'							Dim As GdkRGBA colorHighlightText, colorHighlight
						'							Dim As Integer colHighlightText, colHighlight
						'							gtk_style_context_get_color(scontext, GTK_STATE_FLAG_SELECTED, @colorHighlightText)
						'							gtk_style_context_get_background_color(scontext, GTK_STATE_FLAG_SELECTED, @colorHighlight)
						'							colHighlight = clOrange 'rgb(colorHighlight.red * 255, colorHighlight.green * 255, colorHighlight.blue * 255)
						'							colHighlightText = clWhite 'clWhite 'rgb(colorHighlightText.red * 255, colorHighlightText.green * 255, colorHighlightText.blue * 255)
						'							?clBlue, getred(clBlue), getgreen(clBlue), getblue(clBlue)
						'							PaintText i, *s, IIf(iSelStartLine = z, iSelStartChar, 0), IIf(iSelEndLine = z, iSelEndChar, Len(*s)), SelectionBackground, SelectionForeground, IIf(z <> iSelEndLine, " ", "")
						'						#else
						PaintText i, *s, IIf(iSelStartLine = z, iSelStartChar, 0), IIf(iSelEndLine = z, iSelEndChar, Len(*s)), Selection, IIf(z <> iSelEndLine, " ", "")
						'						#endif
						'WLet n, Left(*s, iStart)
						'WLet h, Mid(*s, iStart + 1, iEnd - iStart) & IIF(iLineIndex <> i, " ", "")
						'SetBKColor(bufDC, clHighlight)
						'SetTextColor(bufDC, clHighlightText)
						'GetTextExtentPoint32(bufDC, n, Len(*n), @Sz)
						'TextOut(bufDC, LeftMargin + -HScrollPos * dwCharX + IIF(iStart = 0, 0, Sz.cx), (i - VScrollPos - 1) * dwCharY, h, Len(*h))
					End If
				End If
				If HighlightBrackets Then
					If z = BracketsStartLine AndAlso BracketsStart > -1 Then
						Dim As ..Rect rec = Type(ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsStart))) * (dwCharX)), ScaleY((i - VScrollPos) * dwCharY + 1), ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsStart))) * (dwCharX) + dwCharX), ScaleY((i - VScrollPos) * dwCharY + dwCharY))
						#ifdef __USE_GTK__
							cairo_set_source_rgb(cr, CurrentBrackets.FrameRed, CurrentBrackets.FrameGreen, CurrentBrackets.FrameBlue)
							cairo_rectangle (cr, rec.Left, rec.Top, rec.Right, rec.Bottom, True)
							cairo_stroke(cr)
						#else
							This.Canvas.Brush.Color = CurrentBrackets.Frame
							FrameRect bufDC, @rec, This.Canvas.Brush.Handle
						#endif
					End If
					If z = BracketsEndLine AndAlso BracketsEnd > -1 Then
						Dim As ..Rect rec = Type(ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsEnd))) * (dwCharX)), ScaleY((i - VScrollPos) * dwCharY + 1), ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsEnd))) * (dwCharX) + dwCharX), ScaleY((i - VScrollPos) * dwCharY + dwCharY))
						#ifdef __USE_GTK__
							cairo_set_source_rgb(cr, CurrentBrackets.FrameRed, CurrentBrackets.FrameGreen, CurrentBrackets.FrameBlue)
							cairo_rectangle (cr, rec.Left, rec.Top, rec.Right, rec.Bottom, True)
							cairo_stroke(cr)
						#else
							This.Canvas.Brush.Color = CurrentBrackets.Frame
							FrameRect bufDC, @rec, This.Canvas.Brush.Handle
						#endif
					End If
				End If
				#ifdef __USE_GTK__
					cairo_set_line_width (cr, 1)
				#endif
				If ShowSpaces Then
					#ifdef __USE_GTK__
						cairo_set_source_rgb(cr, SpaceIdentifiers.ForegroundRed, SpaceIdentifiers.ForegroundGreen, SpaceIdentifiers.ForegroundBlue)
					#else
						This.Canvas.Pen.Color = SpaceIdentifiers.Foreground 'rgb(100, 100, 100) 'clLtGray
						SelectObject(bufDC, This.Canvas.Pen.Handle)
					#endif
					'WLet FLineLeft, GetTabbedText(*s, 0, True)
					jj = 1
					jPos = 0
					lLen = Len(*s)
					Do While jj <= lLen
						sChar = Mid(*s, jj, 1)
						If sChar = " " Then
							jPos += 1
							'WLet FLineLeft, GetTabbedText(Left(*s, jj - 1))
							#ifdef __USE_GTK__
								.cairo_rectangle(cr, LeftMargin + -HScrollPos * dwCharX + (jPos - 1) * (dwCharX) + dwCharX / 2, (i - VScrollPos) * dwCharY + dwCharY / 2, 1, 1)
								cairo_fill(cr)
							#else
								'GetTextExtentPoint32(bufDC, @Wstr(Left(*FLineLeft, jj - 1)), jj - 1, @Sz) 'Len(*FLineLeft)
								'SetPixel bufDC, LeftMargin + -HScrollPos * dwCharX + IIF(jPos = 0, 0, Sz.cx) + dwCharX / 2, (i - VScrollPos) * dwCharY + dwCharY / 2, clBtnShadow
								SetPixel bufDC, ScaleX(LeftMargin + -HScrollPos * dwCharX + (jPos - 1) * (dwCharX) + dwCharX / 2), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2)), SpaceIdentifiers.Foreground
							#endif
						ElseIf sChar = !"\t" Then
							jPP = TabWidth - (jPos + TabWidth) Mod TabWidth
							'WLet FLineLeft, GetTabbedText(Left(*s, jj - 1))
							#ifdef __USE_GTK__
								cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + 2 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 3 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 7 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 3 - 0.5)
								cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) +jPP * dwCharX - 7 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 + 3 - 0.5)
								cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_stroke (cr)
							#else
								'GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @Sz)
								MoveToEx bufDC,   ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + 2), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2)), 0
								LineTo bufDC,     ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 3), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2))
								MoveToEx bufDC,   ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 7), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) - 3), 0
								LineTo bufDC,     ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2))
								MoveToEx bufDC,   ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 7), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) + 3), 0
								LineTo bufDC,     ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2))
							#endif
							jPos += jPP
						Else
							jPos += 1
						End If
						jj += 1
					Loop
				End If
			End If
			'If c >= vlc Then Exit Do
			'p = Pos1 + 1
			'Loop While Pos1 > 0
			'Canvas.Font.Bold = False
			#ifdef __USE_GTK__
				cairo_rectangle (cr, 0.0, (i - VScrollPos) * dwCharY, LeftMargin - 25, (i - VScrollPos + 1) * dwCharY, True)
				cairo_set_source_rgb(cr, LineNumbers.BackgroundRed, LineNumbers.BackgroundGreen, LineNumbers.BackgroundBlue)
				cairo_fill (cr)
				WLet(FLineLeft, WStr(z + 1))
				'Dim extend As cairo_text_extents_t
				'cairo_text_extents (cr, *FLineLeft, @extend)
				cairo_move_to(cr, LeftMargin - 30 - TextWidth(ToUTF8(*FLineLeft)), (i - VScrollPos) * dwCharY + dwCharY - 5)
				cairo_set_source_rgb(cr, LineNumbers.ForegroundRed, LineNumbers.ForegroundGreen, LineNumbers.ForegroundBlue)
				pango_layout_set_text(layout, ToUTF8(*FLineLeft), Len(ToUTF8(*FLineLeft)))
				pango_cairo_update_layout(cr, layout)
				#ifdef PANGO_VERSION
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
				#else
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
				#endif
				pango_cairo_show_layout_line(cr, pl)
				'cairo_show_text(cr, *FLineLeft)
			#else
				'SelectObject(bufDC, This.Canvas.Font.Handle)
				This.Canvas.Brush.Color = LineNumbers.Background
				SetRect(@rc, 0, ScaleY((i - VScrollPos) * dwCharY), ScaleX(LeftMargin - 25), ScaleY((i - VScrollPos + 1) * dwCharY))
				'SelectObject(bufDC, This.Canvas.Brush.Handle)
				FillRect bufDC, @rc, This.Canvas.Brush.Handle
				SetBKMode(bufDC, TRANSPARENT)
				WLet(FLineLeft, WStr(z + 1))
				GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @Sz)
				SetTextColor(bufDC, LineNumbers.Foreground)
				TextOut(bufDC, ScaleX(LeftMargin - 25) - Sz.cx, ScaleY((i - VScrollPos) * dwCharY), FLineLeft, Len(*FLineLeft))
				SetBKMode(bufDC, OPAQUE)
			#endif
			This.Canvas.Brush.Color = NormalText.Background
			#ifdef __USE_GTK__
				cairo_rectangle(cr, LeftMargin - 25, (i - VScrollPos) * dwCharY, LeftMargin, (i - VScrollPos + 1) * dwCharY, True)
				cairo_set_source_rgb(cr, NormalText.BackgroundRed, NormalText.BackgroundGreen, NormalText.BackgroundBlue)
				cairo_fill (cr)
			#else
				SetRect(@rc, ScaleX(LeftMargin - 25), ScaleY((i - VScrollPos) * dwCharY), ScaleX(LeftMargin), ScaleY((i - VScrollPos + 1) * dwCharY))
				FillRect bufDC, @rc, This.Canvas.Brush.Handle
			#endif
			If FECLine->BreakPoint Then
				This.Canvas.Pen.Color = IndicatorLines.Foreground
				This.Canvas.Brush.Color = Breakpoints.Indicator
				#ifdef __USE_GTK__
					cairo_set_source_rgb(cr, IndicatorLines.ForegroundRed, IndicatorLines.ForegroundGreen, IndicatorLines.ForegroundBlue)
					cairo_arc(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 8 - 0.5, 5, 0, 2 * G_PI)
					cairo_fill_preserve(cr)
					cairo_set_source_rgb(cr, Breakpoints.IndicatorRed, Breakpoints.IndicatorGreen, Breakpoints.IndicatorBlue)
					cairo_stroke(cr)
				#else
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
					Ellipse bufDC, ScaleX(LeftMargin - 16), ScaleY((i - VScrollPos) * dwCharY + 2), ScaleX(LeftMargin - 5), ScaleY((i - VScrollPos) * dwCharY + 13)
				#endif
			End If
			If FECLine->Bookmark Then
				This.Canvas.Pen.Color = IndicatorLines.Foreground
				This.Canvas.Brush.Color = Bookmarks.Indicator
				#ifdef __USE_GTK__
					Var x = LeftMargin - 18, y = (i - VScrollPos) * dwCharY + 3
					Var width1 = 14, height1 = 10, radius = 2
					cairo_set_source_rgb(cr, Bookmarks.IndicatorRed, Bookmarks.IndicatorGreen, Bookmarks.IndicatorBlue)
					cairo_move_to cr, x - 0.5, y + radius - 0.5
					cairo_arc (cr, x + radius - 0.5, y + radius - 0.5, radius, G_PI, -G_PI / 2)
					cairo_line_to (cr, x + width1 - radius - 0.5, y - 0.5)
					cairo_arc (cr, x + width1 - radius - 0.5, y + radius - 0.5, radius, -G_PI / 2, 0)
					cairo_line_to (cr, x + width1 - 0.5, y + height1 - radius - 0.5)
					cairo_arc (cr, x + width1 - radius - 0.5, y + height1 - radius - 0.5, radius, 0, G_PI / 2)
					cairo_line_to (cr, x + radius - 0.5, y + height1 - 0.5)
					cairo_arc (cr, x + radius - 0.5, y + height1 - radius - 0.5, radius, G_PI / 2, G_PI)
					cairo_close_path cr
					cairo_fill_preserve(cr)
					cairo_set_source_rgb(cr, IndicatorLines.ForegroundRed, IndicatorLines.ForegroundGreen, IndicatorLines.ForegroundBlue)
					cairo_stroke(cr)
				#else
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
					RoundRect bufDC, ScaleX(LeftMargin - 18), ScaleY((i - VScrollPos) * dwCharY + 2), ScaleX(LeftMargin - 3), ScaleY((i - VScrollPos) * dwCharY + 13), ScaleX(5), ScaleY(5)
				#endif
			End If
			#ifdef __USE_GTK__
				cairo_set_source_rgb(cr, FoldLines.ForegroundRed, FoldLines.ForegroundGreen, FoldLines.ForegroundBlue)
			#endif
			If SyntaxEdit AndAlso Not CStyle Then
				If FECLine->Collapsible Then
					#ifdef __USE_GTK__
						'cairo_set_source_rgb(cr, abs(GetRed(clGray) / 255.0), abs(GetGreen(clGray) / 255.0), abs(GetBlue(clGray) / 255.0))
						cairo_rectangle(cr, LeftMargin - 15 - 0.5, (i - VScrollPos) * dwCharY + 4 - 0.5, LeftMargin - 7 - 0.5, (i - VScrollPos) * dwCharY + 12 - 0.5, True)
						cairo_move_to(cr, LeftMargin - 13 - 0.5, (i - VScrollPos) * dwCharY + 8 - 0.5)
						cairo_line_to(cr, LeftMargin - 9 - 0.5, (i - VScrollPos) * dwCharY + 8 - 0.5)
						cairo_move_to(cr, LeftMargin - 0.5, (i - VScrollPos) * dwCharY - 0.5)
						cairo_line_to(cr, dwClientX - 0.5, (i - VScrollPos) * dwCharY - 0.5)
						cairo_stroke (cr)
					#else
						This.Canvas.Pen.Color = FoldLines.Foreground
						SelectObject(bufDC, This.Canvas.Brush.Handle)
						SelectObject(bufDC, This.Canvas.Pen.Handle)
						Rectangle bufDC, ScaleX(LeftMargin - 15), ScaleY((i - VScrollPos) * dwCharY + 3), ScaleX(LeftMargin - 6), ScaleY((i - VScrollPos) * dwCharY + 12)
						MoveToEx bufDC, ScaleX(LeftMargin - 13), ScaleY((i - VScrollPos) * dwCharY + 7), 0
						LineTo bufDC, ScaleX(LeftMargin - 8), ScaleY((i - VScrollPos) * dwCharY + 7)
						MoveToEx bufDC, ScaleX(LeftMargin), ScaleY((i - VScrollPos) * dwCharY), 0
						LineTo bufDC, ScaleX(dwClientX), ScaleY((i - VScrollPos) * dwCharY)
					#endif
					If OldCollapseIndex > 0 Then
						#ifdef __USE_GTK__
							cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 0 - 0.5)
							cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 4 - 0.5)
							cairo_stroke (cr)
						#else
							MoveToEx bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + 0), 0
							LineTo bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + 3)
						#endif
					End If
					If FECLine->Collapsed Then
						#ifdef __USE_GTK__
							cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 6 - 0.5)
							cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 10 - 0.5)
							cairo_stroke (cr)
						#else
							MoveToEx bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + 5), 0
							LineTo bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + 10)
						#endif
					End If
					If CInt(CInt(OldCollapseIndex = 0) And CInt(Not FECLine->Collapsed)) OrElse CInt(OldCollapseIndex > 0) Then
						#ifdef __USE_GTK__
							cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 12 - 0.5)
							cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + dwCharY - 0.5)
							cairo_stroke (cr)
						#else
							MoveToEx bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + 12), 0
							LineTo bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + dwCharY)
						#endif
					End If
				ElseIf OldCollapseIndex > 0 Then
					#ifdef __USE_GTK__
						cairo_set_source_rgb(cr, FoldLines.ForegroundRed, FoldLines.ForegroundGreen, FoldLines.ForegroundBlue)
						cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 0 - 0.5)
					#else
						This.Canvas.Pen.Color = FoldLines.Foreground
						SelectObject(bufDC, This.Canvas.Brush.Handle)
						SelectObject(bufDC, This.Canvas.Pen.Handle)
						MoveToEx bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + 0), 0
					#endif
					If CollapseIndex = 0 Then
						#ifdef __USE_GTK__
							cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
							cairo_stroke (cr)
						#else
							LineTo bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + dwCharY / 2)
						#endif
					Else
						#ifdef __USE_GTK__
							cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos + 1) * dwCharY + dwCharY - 0.5)
							cairo_stroke (cr)
						#else
							LineTo bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos + 1) * dwCharY + dwCharY)
						#endif
					End If
					If FECLine->ConstructionIndex >= 0 AndAlso CInt(Constructions(FECLine->ConstructionIndex).Collapsible) And CInt(FECLine->ConstructionPart = 2) Then
						#ifdef __USE_GTK__
							cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
							cairo_line_to(cr, LeftMargin - 6 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
							cairo_stroke (cr)
						#else
							MoveToEx bufDC, ScaleX(LeftMargin - 11), ScaleY((i - VScrollPos) * dwCharY + dwCharY / 2), 0
							LineTo bufDC, ScaleX(LeftMargin - 6), ScaleY((i - VScrollPos) * dwCharY + dwCharY / 2)
						#endif
					End If
				End If
			End If
			If i - VScrollPos > vlc1 Then Exit For 'AndAlso Not ChangeCase
			OldCollapseIndex = CollapseIndex
		Next z
		#ifdef __USE_GTK__
			cairo_rectangle (cr, 0, (i - VScrollPos + 1) * dwCharY, LeftMargin - 25, dwClientY, True)
			cairo_set_source_rgb(cr, LineNumbers.BackgroundRed, LineNumbers.BackgroundGreen, LineNumbers.BackgroundBlue)
			cairo_fill (cr)
			cairo_rectangle (cr, LeftMargin - 25, (i - VScrollPos + 1) * dwCharY, LeftMargin, dwClientY, True)
			cairo_set_source_rgb(cr, NormalText.BackgroundRed, NormalText.BackgroundGreen, NormalText.BackgroundBlue)
			cairo_fill (cr)
			If CaretOn Then
				#ifdef __USE_GTK3__
					cairo_set_source_rgb(cr, NormalText.ForegroundRed, NormalText.ForegroundGreen, NormalText.ForegroundBlue)
					gtk_render_insertion_cursor(gtk_widget_get_style_context(widget), cr, HCaretPos, VCaretPos, layout, 0, PANGO_DIRECTION_LTR)
				#else
					cairo_rectangle (cr, HCaretPos, VCaretPos, HCaretPos + 0.5, VCaretPos + dwCharY, True)
					cairo_set_source_rgb(cr, NormalText.ForegroundRed, NormalText.ForegroundGreen, NormalText.ForegroundBlue)
					cairo_fill (cr)
				#endif
			End If
			'cairo_paint(cr)
		#else
			SetRect(@rc, 0, ScaleY((i - VScrollPos + 1) * dwCharY), ScaleX(LeftMargin - 25), ScaleY(dwClientY))
			This.Canvas.Brush.Color = LineNumbers.Background
			FillRect bufDC, @rc, This.Canvas.Brush.Handle
			SetRect(@rc, ScaleX(LeftMargin - 25), ScaleY((i - VScrollPos + 1) * dwCharY), ScaleX(LeftMargin), ScaleY(dwClientY))
			This.Canvas.Brush.Color = NormalText.Background
			FillRect bufDC, @rc, This.Canvas.Brush.Handle
			If bInMiddleScroll Then
				#ifdef __USE_GTK__
					'					cairo_set_source_rgb(cr, Abs(GetRed(clMaroon) / 255.0), Abs(GetGreen(clMaroon) / 255.0), Abs(GetBlue(clMaroon) / 255.0))
					'					cairo_arc(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 8 - 0.5, 5, 0, 2 * G_PI)
					'					cairo_fill_preserve(cr)
					'					cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
					'					cairo_stroke(cr)
				#else
					This.Canvas.Pen.Color = SpaceIdentifiers.Foreground
					This.Canvas.Brush.Color = SpaceIdentifiers.Foreground
					SelectObject(bufDC, This.Canvas.Pen.Handle)
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					Ellipse bufDC, ScaleX(MButtonX + 10), ScaleY(MButtonY + 10), ScaleX(MButtonX + 14), ScaleY(MButtonY + 14)
					Dim pPoint1(3) As ..Point = {(ScaleX(MButtonX + 11), ScaleY(MButtonY + 1)), (ScaleX(MButtonX + 7), ScaleY(MButtonY + 5)), (ScaleX(MButtonX + 16), ScaleY(MButtonY + 5)), (ScaleX(MButtonX + 12), ScaleY(MButtonY + 1))}
					PolyGon(bufDC, @pPoint1(0), 4)
					Dim pPoint2(3) As ..Point = {(ScaleX(MButtonX + 11), ScaleY(MButtonY + 22)), (ScaleX(MButtonX + 7), ScaleY(MButtonY + 18)), (ScaleX(MButtonX + 16), ScaleY(MButtonY + 18)), (ScaleX(MButtonX + 12), ScaleY(MButtonY + 22))}
					PolyGon(bufDC, @pPoint2(0), 4)
					Dim pPoint3(3) As ..Point = {(ScaleX(MButtonX + 1), ScaleY(MButtonY + 11)), (ScaleX(MButtonX + 5), ScaleY(MButtonY + 7)), (ScaleX(MButtonX + 5), ScaleY(MButtonY + 16)), (ScaleX(MButtonX + 1), ScaleY(MButtonY + 12))}
					PolyGon(bufDC, @pPoint3(0), 4)
					Dim pPoint4(3) As ..Point = {(ScaleX(MButtonX + 22), ScaleY(MButtonY + 11)), (ScaleX(MButtonX + 18), ScaleY(MButtonY + 7)), (ScaleX(MButtonX + 18), ScaleY(MButtonY + 16)), (ScaleX(MButtonX + 22), ScaleY(MButtonY + 12))}
					PolyGon(bufDC, @pPoint4(0), 4)
				#endif
			End If
			BitBlt(hD, 0, 0, ScaleX(dwClientX), ScaleY(dwClientY), bufDC, 0, 0, SRCCOPY)
			DeleteDc bufDC
			DeleteObject bufBMP
			ReleaseDc FHandle, hd
			ShowCaret(FHandle)
		#endif
		
		Exit Sub
		ErrHandler:
		?ErrDescription(Err) & " (" & Err & ") " & _
		"in function " & ZGet(Erfn()) & " " & _
		"in module " & ZGet(Ermn())  & " " & _
		"in line " & Erl()
	End Sub
	
	Sub EditControl.PaintControl
		#ifdef __USE_GTK__
			'PaintControlPriv
			bChanged = True
			If gtk_is_widget(widget) Then gtk_widget_queue_draw(widget)
		#else
			PaintControlPriv
		#endif
	End Sub
	
	Sub EditControl._LoadFromHistory(ByRef HistoryItem As EditControlHistory Ptr, bToBack As Boolean, ByRef oldItem As EditControlHistory Ptr)
		For i As Integer = FLines.Count - 1 To 0 Step -1
			Delete_( Cast(EditControlLine Ptr, FLines.Items[i]))
		Next i
		FLines.Clear
		For i As Integer = 0 To HistoryItem->Lines.Count - 1
			FECLine = New_( EditControlLine)
			With *Cast(EditControlLine Ptr, HistoryItem->Lines.Item(i))
				WLet(FECLine->Text, *.Text)
				FECLine->Breakpoint = .Breakpoint
				FECLine->Bookmark = .Bookmark
				FECLine->CommentIndex = .CommentIndex
				FECLine->ConstructionIndex = .ConstructionIndex
				FECLine->ConstructionPart = .ConstructionPart
				FECLine->InConstructionIndex = .InConstructionIndex
				FECLine->InConstructionPart = .InConstructionPart
				FECLine->Multiline = .Multiline
				FECLine->Collapsible = .Collapsible
				FECLine->Collapsed = .Collapsed
				FECLine->Visible = .Visible
			End With
			FLines.Add FECLine
		Next i
		If FLines.Count = 0 Then
			FECLine = New_( EditControlLine)
			WLet(FECLine->Text, "")
			FLines.Add FECLine
		End If
		If bToBack Then
			FSelStartLine = oldItem->OldSelStartLine
			FSelStartChar = oldItem->OldSelStartChar
			FSelEndLine = oldItem->OldSelEndLine
			FSelEndChar = oldItem->OldSelEndChar
		Else
			FSelStartLine = HistoryItem->SelStartLine
			FSelStartChar = HistoryItem->SelStartChar
			FSelEndLine = HistoryItem->SelEndLine
			FSelEndChar = HistoryItem->SelEndChar
		End If
		bOldCommented = True
		#ifdef __USE_GTK__
			If cr Then
		#else
			If Handle Then
		#endif
			ScrollToCaret
		End If
		OldnCaretPosX = nCaretPosX
		OldCharIndex = GetOldCharIndex
		If OnChange Then OnChange(This)
		Modified = True
	End Sub
	
	Sub EditControl.Undo
		If curHistory <= 0 Then Exit Sub
		curHistory = curHistory - 1
		_LoadFromHistory FHistory.Items[curHistory], True, FHistory.Items[curHistory + 1]
	End Sub
	
	Sub EditControl.Redo
		If curHistory >= FHistory.Count - 1 Then Exit Sub
		curHistory = curHistory + 1
		_LoadFromHistory FHistory.Item(curHistory), False, FHistory.Item(curHistory - 1)
	End Sub
	
	Function EditControl.CharType(ByRef ch As WString) As Integer '...'
		If ch = " " Then: Return 0
		ElseIf ch = Chr(13) Or ch = "" Then: Return 1
		ElseIf Instr(Symbols, ch) > 0 Then: Return 2
		Else: Return 3
		End If
	End Function
	
	Sub EditControl.WordLeft() '...'
		Dim f As Integer
		Var item = Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))
		If FSelEndChar = 0 Then
			f = 1
		Else
			f = CharType(Mid(*item->Text, FSelEndChar - 1 + 1, 1))
		End If
		Dim c As Integer, i As Integer, j As Integer, k As Integer
		For i = FSelEndLine To 0 Step -1
			item = Cast(EditControlLine Ptr, FLines.Item(i))
			If i = FSelEndLine Then k = FSelEndChar Else k = Len(*item->Text)
			For j = k - 1 To -1 Step -1
				If j = -1 Then
					c = CharType(Chr(13))
				Else
					c = CharType(Mid(*item->Text, j + 1, 1))
				End If
				If f = 0 Then f = c
				If c <> f Then FSelEndChar = j + 1: FSelEndLine = i: Exit Sub
			Next j
		Next i
		FSelEndChar = 0
		FSelEndLine = 0
	End Sub
	
	Sub EditControl.WordRight() '...'
		Dim f As Integer
		Var item = Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))
		If FSelEndChar = Len(*item->Text) Then
			f = 1
		Else
			f = CharType(Mid(*item->Text, FSelEndChar + 1, 1))
		End If
		Dim c As Integer, i As Integer, j As Integer, k As Integer
		For i = FSelEndLine To FLines.Count - 1
			item = Cast(EditControlLine Ptr, FLines.Item(i))
			If i = FSelEndLine Then k = FSelEndChar + 1 Else k = -1
			For j = k To Len(*item->Text)
				If j = -1 Then
					c = CharType(Chr(13))
				Else
					c = CharType(Mid(*item->Text, j + 1, 1))
				End If
				If c = 0 Then f = 0
				If c <> f Then FSelEndChar = j: FSelEndLine = i: Exit Sub
			Next j
		Next i
		FSelEndChar = Len(*item->Text)
		FSelEndLine = i - 1
	End Sub
	
	Function GetLeftSpace(ByRef Value As WString) As Integer
		Return Len(Value) - Len(LTrim(Value, " "))
	End Function
	
	Function EditControl.InCollapseRect(i As Integer, X As Integer, Y As Integer) As Boolean
		Return CInt(X >= LeftMargin - 15 AndAlso X <= LeftMargin - 6) AndAlso _
		CInt(Cast(EditControlLine Ptr, FLines.Items[i])->Collapsible)
		'Y >= (i - VScrollPos) * dwCharY + 3 AndAlso Y <= (i - VScrollPos) * dwCharY + 12) AndAlso _
	End Function
	
	Function EditControl.InIncludeFileRect(i As Integer, X As Integer, Y As Integer) As Boolean
		Dim As WString Ptr ECText = Cast(EditControlLine Ptr, FLines.Items[i])->Text
		If StartsWith(LTrim(LCase(*ECText), Any !"\t "), "#include ") Then
			Var CharIdx = CharIndexFromPoint(X, Y)
			Var Pos1 = InStr(*ECText, """")
			If Pos1 > 0 Then
				Var Pos2 = InStr(Pos1 + 1, *ECText, """")
				Return CharIdx >= Pos1 AndAlso CharIdx < Pos2
			End If
		End If
		Return False
	End Function
	
	Function EditControl.GetLineIndex(Index As Integer, iTo As Integer = 0) As Integer
		Var j = -1, iStep = IIf(iTo <= 0, -1, 1), k = Index
		Var iEnd = IIf(iTo <= 0, 0, FLines.Count - 1)
		For i As Integer = Index To iEnd Step iStep
			If Cast(EditControlLine Ptr, FLines.Items[i])->Visible Then
				j = j + 1
				k = i
				If j = Abs(iTo) Then Return i
			End If
		Next
		Return k
	End Function
	
	Sub EditControl.ShowDropDownAt(iSelEndLine As Integer, iSelEndChar As Integer)
		Var nCaretPosY = GetCaretPosY(iSelEndLine)
		Var nCaretPosX = TextWidth(GetTabbedText(..Left(Lines(iSelEndLine), iSelEndChar)))
		Var HCaretPos = LeftMargin + nCaretPosX - HScrollPos * dwCharX
		Var VCaretPos = (nCaretPosY - VScrollPos + 1) * dwCharY
		DropDownChar = iSelEndChar
		DropDownShowed = True
		#ifdef __USE_GTK__
			Dim As gint x, y
			gdk_window_get_origin(gtk_widget_get_window(widget), @x, @y)
			gtk_window_move(gtk_window(winIntellisense), HCaretPos + x, VCaretPos + y)
			gtk_widget_show_all(winIntellisense)
		#else
			pnlIntellisense.SetBounds HCaretPos, VCaretPos, 250, 0
			cboIntellisense.ShowDropDown True
			If LastItemIndex = -1 Then cboIntellisense.ItemIndex = -1
		#endif
	End Sub
	
	Sub EditControl.ShowToolTipAt(iSelEndLine As Integer, iSelEndChar As Integer)
		Var nCaretPosY = GetCaretPosY(iSelEndLine)
		Var nCaretPosX = TextWidth(GetTabbedText(..Left(Lines(iSelEndLine), iSelEndChar)))
		Var HCaretPos = LeftMargin + nCaretPosX - HScrollPos * dwCharX
		Var VCaretPos = (nCaretPosY - VScrollPos + 1) * dwCharY
		ToolTipChar = iSelEndChar
		ToolTipShowed = True
		#ifdef __USE_GTK__
			Dim As gint x, y
			gtk_label_set_markup(gtk_label(lblTooltip), ToUTF8(*FHint))
			gdk_window_get_origin(gtk_widget_get_window(widget), @x, @y)
			gtk_window_move(gtk_window(winTooltip), HCaretPos + x, VCaretPos + y)
			gtk_window_resize(gtk_window(winTooltip), 100, 25)
			gtk_widget_show_all(winTooltip)
		#else
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = FHandle
			'ti.uId    = Cast(UINT, FHandle)
			
			If hwndTT = 0 Then
				hwndTT = CreateWindow(TOOLTIPS_CLASS, "", WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, Cast(HMENU, NULL), GetModuleHandle(NULL), NULL)
				
				ti.uFlags = TTF_IDISHWND Or TTF_TRACK Or TTF_ABSOLUTE Or TTF_PARSELINKS Or TTF_TRANSPARENT
				ti.hinst  = GetModuleHandle(NULL)
				ti.lpszText  = FHint
				
				SendMessage(hwndTT, TTM_ADDTOOL, 0, Cast(LPARAM, @ti))
			Else
				SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
				
				ti.lpszText = FHint
				
				SendMessage(hwndTT, TTM_UPDATETIPTEXT, 0, CInt(@ti))
			End If
			
			SendMessage(hwndTT, TTM_SETMAXTIPWIDTH, 0, 1000)
			SendMessage(hwndTT, TTM_TRACKACTIVATE, True, Cast(LPARAM, @ti))
			
			Dim As ..RECT rc
			GetWindowRect(FHandle, @rc)
			SendMessage(hwndTT, TTM_TRACKPOSITION, 0, MAKELPARAM(rc.Left + ScaleX(HCaretPos), rc.Top + ScaleY(VCaretPos + 5)))
		#endif
	End Sub
	
	Sub EditControl.UpdateToolTip()
		#ifdef __USE_GTK__
			gtk_label_set_markup(gtk_label(lblTooltip), ToUTF8(*FHint))
		#else
			If hwndTT <> 0 Then
				Dim As TOOLINFO    ti
				ZeroMemory(@ti, SizeOf(ti))
				
				ti.cbSize = SizeOf(ti)
				ti.hwnd   = FHandle
				
				SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
				
				ti.lpszText = FHint
				
				SendMessage(hwndTT, TTM_UPDATETIPTEXT, 0, CInt(@ti))
			End If
		#endif
	End Sub
	
	Sub EditControl.CloseDropDown()
		DropDownShowed = False
		#ifdef __USE_GTK__
			gtk_widget_hide(gtk_widget(winIntellisense))
		#else
			cboIntellisense.ShowDropDown False
		#endif
	End Sub
	
	Sub EditControl.CloseToolTip()
		ToolTipShowed = False
		#ifdef __USE_GTK__
			gtk_widget_hide(gtk_widget(winTooltip))
		#else
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = FHandle
			'ti.uId    = Cast(UINT, FHandle)
			
			SendMessage(hwndTT, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
		#endif
	End Sub
	
	Function GetKeyWordCase(ByRef KeyWord As String, KeyWordsList As WStringList Ptr = 0) As String
		If ChangeKeyWordsCase Then
			Select Case ChoosedKeyWordsCase
			Case KeyWordsCase.OriginalCase
				If KeyWordsList <> 0 Then
					Var Idx = KeyWordsList->IndexOf(LCase(KeyWord))
					If Idx <> -1 Then Return KeyWordsList->Item(Idx)
				End If
			Case KeyWordsCase.LowerCase: Return LCase(KeyWord) ': Return *TempString
			Case KeyWordsCase.UpperCase: Return UCase(KeyWord) ': Return *TempString
			End Select
		End If
		Return KeyWord
	End Function
	
	#ifdef __USE_GTK__
		Function EditControl.ActivateLink(label As GtkLabel Ptr, uri As gchar Ptr, user_data As gpointer) As Boolean
			Dim As EditControl Ptr ec = user_data
			If ec <> 0 Then
				If ec->OnToolTipLinkClicked Then ec->OnToolTipLinkClicked(*ec, *uri)
			End If
			Return True
		End Function
	#endif
	
	Sub EditControl.ProcessMessage(ByRef msg As Message)
		Static bShifted As Boolean
		Static bCtrl As Boolean
		Static scrStyle As Integer, scrDirection As Integer
		#ifdef __USE_GTK__
			bShifted = msg.event->Key.state And GDK_Shift_MASK
			bCtrl = msg.event->Key.state And GDK_Control_MASK
		#else
			bShifted = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
		#endif
		'Base.ProcessMessage(msg)
		#ifdef __USE_GTK__
			Dim As GdkEvent Ptr e = msg.event
			Select Case msg.event->Type
		#else
			Select Case msg.msg
			Case CM_CREATE
				'FontSettings()
				
				PaintControl
		#endif
			#ifdef __USE_GTK__
			Case GDK_CONFIGURE
				dwClientX = ClientWidth
				dwClientY = ClientHeight
				'Msg.result = True
			Case GDK_EXPOSE
				#ifndef __USE_GTK__
					PaintControl
				#endif
			#else
			Case WM_SIZE
				dwClientX = UnScaleX(LoWord(msg.lParam))
				dwClientY = UnScaleY(HiWord(msg.lParam))
			#endif
			
			SetScrollsInfo
			#ifdef __USE_GTK__
			Case GDK_SCROLL
			#else
			Case WM_MOUSEWHEEL
			#endif
			bInMiddleScroll = False
			#ifdef __USE_GTK__
				OldPos = gtk_adjustment_get_value(adjustmentv)
				#ifdef __USE_GTK3__
					scrDirection = e->scroll.delta_y
				#else
					scrDirection = IIf(e->scroll.direction = GDK_SCROLL_UP, -1, 1)
				#endif
				If scrDirection = 1 Then
					gtk_adjustment_set_value(adjustmentv, Min(OldPos + 3, gtk_adjustment_get_upper(adjustmentv)))
				ElseIf scrDirection = -1 Then
					gtk_adjustment_set_value(adjustmentv, Max(OldPos - 3, gtk_adjustment_get_lower(adjustmentv)))
				End If
				'If Not gtk_adjustment_get_value(adjustmentv) = OldPos Then
				VScrollPos = gtk_adjustment_get_value(adjustmentv)
				ShowCaretPos False
				'PaintControl
				If gtk_is_widget(widget) Then gtk_widget_queue_draw(widget)
				'End If
			#else
				#ifdef __FB_64BIT__
					If msg.wParam < 4000000000 Then
						scrDirection = 1
					Else
						scrDirection = -1
					End If
				#else
					scrDirection = Sgn(msg.wParam)
				#endif
				si.cbSize = SizeOf (si)
				si.fMask  = SIF_ALL
				GetScrollInfo (FHandle, SB_VERT, @si)
				OldPos = si.nPos
				If scrDirection = -1 Then
					si.nPos = Min(si.nPos + 3, si.nMax)
				Else
					si.nPos = Max(si.nPos - 3, si.nMin)
				End If
				si.fMask = SIF_POS
				SetScrollInfo(FHandle, SB_VERT, @si, True)
				GetScrollInfo(FHandle, SB_VERT, @si)
				If (Not si.nPos = OldPos) Then
					VScrollPos = si.nPos
					ShowCaretPos False
					If DownButton = 0 Then
						#ifdef __USE_GTK__
							FSelEndLine = LineIndexFromPoint(IIf(e->button.x > 60000, 0, e->button.x), IIf(e->button.y > 60000, 0, e->button.y))
							FSelEndChar = CharIndexFromPoint(IIf(e->button.x > 60000, 0, e->button.x), IIf(e->button.y > 60000, 0, e->button.y))
							If e->button.x < LeftMargin Then
						#else
							dwTemp = GetMessagePos
							psPoints = MAKEPOINTS(dwTemp)
							poPoint.X = psPoints.X
							poPoint.Y = psPoints.Y
							..ScreenToClient(Handle, @poPoint)
							FSelEndLine = LineIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
							FSelEndChar = CharIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
							If poPoint.X < LeftMargin Then
						#endif
							If FSelEndLine < FSelStartLine Then
								'FSelStart = LineFromCharIndex(FSelStart)
								'FSelStart = CharIndexFromLine(FSelStart) + LineLength(FSelStart)
								FSelStartChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelStartLine))->Text)
							Else
								FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
							End If
						End If
					End If
					PaintControl
				End If
			#endif
			#ifndef __USE_GTK__
			Case WM_NOTIFY
				Dim As LPNMHDR lp = Cast(LPNMHDR, msg.LParam)
				Select Case lp->Code
				Case TTN_LINKCLICK
					Dim As PNMLINK pNMLink1 = Cast(PNMLINK, msg.lParam)
					Dim As LITEM item = pNMLink1->item
					If OnToolTipLinkClicked Then OnToolTipLinkClicked(This, item.szUrl)
				End Select
			#endif
			#ifndef __USE_GTK__
			Case WM_SETCURSOR
				dwTemp = GetMessagePos
				psPoints = MAKEPOINTS(dwTemp)
				poPoint.X = psPoints.X
				poPoint.Y = psPoints.Y
				..ScreenToClient(Handle, @poPoint)
				iCursorLine = LineIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
				'If Cast(EditControlLine Ptr, FLines.Items[i])->Collapsible Then
				'If p.X < LeftMargin AndAlso p.X > LeftMargin - 15 Then
				If InCollapseRect(iCursorLine, UnScaleX(poPoint.X), UnScaleY(poPoint.Y)) Then
					msg.Result = Cast(LResult, SetCursor(crHand.Handle))
					Return
				ElseIf bInMiddleScroll Then
					If Abs(UnScaleX(poPoint.X) - MButtonX) < 12 AndAlso Abs(UnScaleY(poPoint.Y) - MButtonY) < 12 Then
						msg.Result = Cast(LResult, SetCursor(crScroll.Handle))
					ElseIf UnScaleX(poPoint.X) < MButtonX AndAlso Abs(UnScaleY(poPoint.Y) - MButtonY) <= Abs(UnScaleX(poPoint.X) - MButtonX) Then
						msg.Result = Cast(LResult, SetCursor(crScrollLeft.Handle))
					ElseIf UnScaleX(poPoint.X) > MButtonX AndAlso Abs(UnScaleY(poPoint.Y) - MButtonY) <= Abs(UnScaleX(poPoint.X) - MButtonX) Then
						msg.Result = Cast(LResult, SetCursor(crScrollRight.Handle))
					ElseIf UnScaleY(poPoint.Y) < MButtonY AndAlso Abs(UnScaleX(poPoint.X) - MButtonX) <= Abs(UnScaleY(poPoint.Y) - MButtonY) Then
						msg.Result = Cast(LResult, SetCursor(crScrollUp.Handle))
					ElseIf UnScaleY(poPoint.Y) > MButtonY AndAlso Abs(UnScaleX(poPoint.X) - MButtonX) <= Abs(UnScaleY(poPoint.Y) - MButtonY) Then
						msg.Result = Cast(LResult, SetCursor(crScrollDown.Handle))
					End If
					If bScrollStarted Then
						bScrollStarted = False
						PaintControl
					End If
					Return
				Else
					bInIncludeFileRect = bCtrl AndAlso InIncludeFileRect(iCursorLine, UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
					If bInIncludeFileRectOld <> bInIncludeFileRect OrElse iCursorLineOld <> iCursorLine Then PaintControl
					iCursorLineOld = iCursorLine
					bInIncludeFileRectOld = bInIncludeFileRect
					If bInIncludeFileRect Then
						msg.Result = Cast(LResult, SetCursor(crHand.Handle))
						Return
					End If
				End If
				'End If
				'If LoWord(msg.lParam) = HTCLIENT Then
				'    'msg.Result = Cast(LResult, SetCursor(crHand.Handle))
				'    SetCursor(crHand.Handle)
				'    Return
				'End If
			Case WM_HSCROLL, WM_VSCROLL
				If msg.msg = WM_HSCROLL Then
					scrStyle = SB_HORZ
				Else
					scrStyle = SB_VERT
				End If
				si.cbSize = SizeOf (si)
				si.fMask  = SIF_ALL
				GetScrollInfo (FHandle, scrStyle, @si)
				OldPos = si.nPos
				Select Case msg.wParamLo
				Case SB_TOP, SB_LEFT
					si.nPos = si.nMin
				Case SB_BOTTOM, SB_RIGHT
					si.nPos = si.nMax
				Case SB_LINEUP, SB_LINELEFT
					si.nPos -= 1
				Case SB_LINEDOWN, SB_LINERIGHT
					si.nPos += 1
				Case SB_PAGEUP, SB_PAGELEFT
					si.nPos -= si.nPage
				Case SB_PAGEDOWN, SB_PAGERIGHT
					si.nPos += si.nPage
				Case SB_THUMBPOSITION, SB_THUMBTRACK
					si.nPos = si.nTrackPos
				End Select
				si.fMask = SIF_POS
				SetScrollInfo(FHandle, scrStyle, @si, True)
				GetScrollInfo(FHandle, scrStyle, @si)
				If (Not si.nPos = OldPos) Then
					If scrStyle = SB_HORZ Then
						HScrollPos = si.nPos
					Else
						VScrollPos = si.nPos
					End If
					ShowCaretPos False
					PaintControl
				End If
			#endif
			#ifdef __USE_GTK__
			Case GDK_FOCUS_CHANGE
				InFocus = Cast(GdkEventFocus Ptr, e)->in
				If InFocus Then
					gdk_threads_add_timeout(This.BlinkTime, Cast(GSourceFunc, @Blink_cb), @This)
				Else
					If DropDownShowed Then CloseDropDown
					If ToolTipShowed Then CloseToolTip
				End If
			#else
			Case WM_SETFOCUS
				CreateCaret(FHandle, 0, 0, ScaleY(dwCharY))
				ScrollToCaret
				ShowCaret(FHandle)
			Case WM_KILLFOCUS
				HideCaret(FHandle)
				DestroyCaret()
			Case WM_UNDO
				Undo
				'Case WM_REDO
			Case WM_CUT
				CutToClipboard
			Case WM_COPY
				CopyToClipboard
			Case WM_PASTE
				PasteFromClipboard
			Case WM_GETDLGCODE: msg.Result = DLGC_HASSETSEL Or DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTMESSAGE Or DLGC_WANTTAB
			#endif
			#ifdef __USE_GTK__
			Case GDK_KEY_PRESS
				'bInMButtonClicked = False
				Select Case e->Key.keyval
			#else
			Case WM_KEYDOWN
				bInMiddleScroll = False
				Select Case msg.wParam
			#endif
				#ifdef __USE_GTK__
				Case GDK_KEY_Cut
					CutToClipboard
				Case GDK_KEY_Copy
					CopyToClipboard
				Case GDK_KEY_Paste
					PasteFromClipboard
				Case GDK_KEY_Redo
					Redo
				Case GDK_KEY_Undo
					Undo
				#endif
				#ifdef __USE_GTK__
				Case GDK_KEY_Home
				#else
				Case VK_HOME
				#endif
				Dim As WString Ptr sTmpLine = Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text '
				Dim As Integer lChar = Len(*sTmpLine) - Len(LTrim(*sTmpLine, Any !"\t ")) ' Skip the space oe TABs.
				If FSelEndChar = lChar Then FSelEndChar = 0 Else FSelEndChar = lChar
				If bCtrl Then FSelEndLine = 0
				If Not bShifted Then
					FSelStartChar = FSelEndChar
					FSelStartLine = FSelEndLine
				End If
				ScrollToCaret
				OldnCaretPosX = nCaretPosX
				OldCharIndex = GetOldCharIndex
				#ifdef __USE_GTK__
				Case GDK_KEY_END
				#else
				Case VK_END
				#endif
				If bCtrl Then FSelEndLine = FLines.Count - 1
				FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
				If Not bShifted Then
					FSelStartLine = FSelEndLine
					FSelStartChar = FSelEndChar
				End If
				ScrollToCaret
				OldnCaretPosX = nCaretPosX
				OldCharIndex = GetOldCharIndex
				#ifdef __USE_GTK__
				Case GDK_KEY_Escape
					If DropDownShowed Then CloseDropDown()
					If ToolTipShowed Then CloseToolTip()
				#else
				Case VK_ESCAPE
					If DropDownShowed Then CloseDropDown()
					If ToolTipShowed Then CloseToolTip()
				#endif
				#ifdef __USE_GTK__
				Case GDK_KEY_Delete
				#else
				Case VK_DELETE
				#endif
				If bShifted Then
					CutToClipboard
				Else
					If FSelEndLine = FLines.Count - 1 And FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FLines.Count - 1))->Text) And FSelStartLine = FSelEndLine And FSelStartChar = FSelEndChar Then
						Return
					ElseIf FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
						ChangeText "", 0, "Belgilangan matnni o`chirish"
					ElseIf bCtrl Then
						WordRight
						ChangeText "", 0, "Olddagi so`zni o`chirish"
					Else
						ChangeText "", 1, "Olddagi belgini o`chirish"
					End If
				End If
				#ifdef __USE_GTK__
				Case GDK_KEY_BACKSPACE
					If FSelStartLine = 0 And FSelEndLine = 0 And FSelStartChar = 0 And FSelEndChar = 0 Then
						Return
					ElseIf FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
						ChangeText "", 0, "Belgilangan matn o`chirildi"
					ElseIf bCtrl Then
						WordLeft
						ChangeText "", 0, "Ortdagi so`z o`chirildi"
					Else
						WLet(FLine, Lines(FSelEndLine))
						Var n = Len(*FLine) - Len(LTrim(*FLine))
						If n > 0 AndAlso n = FSelEndChar AndAlso Mid(*FLine, FSelEndChar + 1, 1) <> " " Then
							Var d = Min(n, TabWidth - (n Mod TabWidth))
							bAddText = True
							ChangeText "", -d
						Else
							If FSelEndChar = 0 And FSelStartChar = 0 And FSelStartLine = FSelEndLine Then
								If CInt(FSelEndLine > 0) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine - 1])->Visible) Then
									ShowLine FSelEndLine - 1
								End If
							End If
							bAddText = True
							ChangeText "", -1
						End If
					End If
				#endif
				#ifdef __USE_GTK__
				Case GDK_KEY_Left
					msg.Result = True
				#else
				Case VK_LEFT
				#endif
				If CInt(FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar) AndAlso CInt(Not bShifted) Then
					ChangeSelPos True
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
				ElseIf FSelEndChar > 0 Or (FSelEndChar = 0 And FSelEndLine > 0) Then
					If CInt(bCtrl) Then
						WordLeft
					Else
						ChangePos -1
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
				End If
				#ifdef __USE_GTK__
				Case GDK_KEY_RIGHT
					msg.Result = True
				#else
				Case VK_RIGHT
				#endif
				If CInt(FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar) And CInt(Not bShifted) Then
					ChangeSelPos False
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
				ElseIf FSelEndChar < Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text) Or (FSelEndLine < FLines.Count - 1) Then
					If CInt(bCtrl) Then
						WordRight
					Else
						ChangePos 1
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
				End If
				#ifdef __USE_GTK__
				Case GDK_KEY_UP
					msg.Result = True
				#else
				Case VK_UP
				#endif
				If DropDownShowed Then
					#ifdef __USE_GTK__
						If Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex) > 0 Then
							LastItemIndex = Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex) - 1
							FocusedItemIndex = LastItemIndex
							lvIntellisense.SelectedItemIndex = LastItemIndex
						End If
					#else
						If Max(FocusedItemIndex, cboIntellisense.ItemIndex) > 0 Then
							LastItemIndex = Max(FocusedItemIndex, cboIntellisense.ItemIndex) - 1
							FocusedItemIndex = LastItemIndex
							cboIntellisense.ItemIndex = LastItemIndex
						End If
					#endif
				ElseIf bCtrl Then
					Dim bFind As Boolean
					For i As Integer = FSelEndLine - 1 To 1 Step -1
						With *Cast(EditControlLine Ptr, FLines.Item(i - 1))
							If .ConstructionIndex > 13 AndAlso .ConstructionPart = 0 Then
								FSelEndLine = i
								'FSelEndChar = Len(*.Text)
								bFind = True
								Exit For
							End If
						End With
					Next
					If Not bFind Then
						FSelEndLine = 0
						'FSelEndChar = 0
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					This.TopLine = FSelEndLine - 1
					ScrollToCaret
				ElseIf FSelEndLine = 0 Then
					If bShifted Then
						FSelEndChar = 0
						ScrollToCaret
					ElseIf FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar Then
						ChangeSelPos True
						ScrollToCaret
					End If
				Else
					If FSelEndLine > 0 Then
						FSelEndLine = GetLineIndex(FSelEndLine, -1)
						FSelEndChar = GetCharIndexFromOld
						Var LengthOf = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
						If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					ScrollToCaret
				End If
				#ifdef __USE_GTK__
				Case GDK_KEY_Down
					msg.Result = True
				#else
				Case VK_DOWN
				#endif
				If DropDownShowed Then
					'keybd_event(VK_DOWN, 0, KEYEVENTF_EXTENDEDKEY, 0)
					'                    SendMessage(cboIntellisense.Handle, WM_KEYDOWN, Cast(WPAram, VK_DOWN), 0)
					'Dim As ComboBoxInfo Info
					'Info.cbSize = SizeOf(ComboBoxInfo)
					'If GetComboBoxInfo(cboIntellisense.Handle,  @Info) AndAlso (Info.hwndList <> 0) Then
					'    PostMessage(Info.hwndList, LB_SETCURSEL, cboIntellisense.ItemIndex + 1, 0)
					'End If
					'?Info.hwndList
					#ifdef __USE_GTK__
						If Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex) < lvIntellisense.ListItems.Count - 1 Then
							LastItemIndex = Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex + 1)
							FocusedItemIndex = LastItemIndex
							lvIntellisense.SelectedItemIndex = LastItemIndex
						End If
					#else
						If Max(FocusedItemIndex, cboIntellisense.ItemIndex) < cboIntellisense.Items.Count - 1 Then
							LastItemIndex = Max(FocusedItemIndex, cboIntellisense.ItemIndex + 1)
							FocusedItemIndex = LastItemIndex
							cboIntellisense.ItemIndex = LastItemIndex
						End If
					#endif
				ElseIf bCtrl Then
					Dim bFind As Boolean
					For i As Integer = FSelEndLine + 1 To GetLineIndex(FLines.Count - 1) - 1
						With *Cast(EditControlLine Ptr, FLines.Item(i))
							If .ConstructionIndex > 13 AndAlso .ConstructionPart = 0 Then
								FSelEndLine = i + 1
								'FSelEndChar = Len(*.Text)
								bFind = True
								Exit For
							End If
						End With
					Next
					If Not bFind Then
						FSelEndLine = GetLineIndex(FLines.Count - 1)
						'FSelEndChar = 0
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					This.TopLine = FSelEndLine - 1
					ScrollToCaret
				ElseIf FSelEndLine = GetLineIndex(FLines.Count - 1) Then
					If bShifted Then
						Var LengthOf = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
						FSelEndChar = LengthOf
						ScrollToCaret
					ElseIf FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar Then
						ChangeSelPos False
						ScrollToCaret
					End If
				Else
					If FSelEndLine < GetLineIndex(FLines.Count - 1) Then
						FSelEndLine = GetLineIndex(FSelEndLine, +1)
						FSelEndChar = GetCharIndexFromOld
						Var LengthOf = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
						If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					ScrollToCaret
				End If
				#ifdef __USE_GTK__
				Case GDK_KEY_Page_Up
				#else
				Case VK_PRIOR
				#endif
				If DropDownShowed Then
					#ifdef __USE_GTK__
						If lvIntellisense.SelectedItemIndex > 1 Then LastItemIndex = Max(0, lvIntellisense.SelectedItemIndex - 6): lvIntellisense.SelectedItemIndex = LastItemIndex
					#else
						If cboIntellisense.ItemIndex > 1 Then LastItemIndex = Max(0, cboIntellisense.ItemIndex - 6): cboIntellisense.ItemIndex = LastItemIndex
					#endif
				ElseIf bCtrl Then
					Dim bFind As Boolean
					For i As Integer = FSelEndLine - 1 To 0 Step -1
						With *Cast(EditControlLine Ptr, FLines.Item(i))
							If .ConstructionIndex > 13 AndAlso .ConstructionPart = 0 Then
								FSelEndLine = i
								bFind = True
								Exit For
							End If
						End With
					Next
					If Not bFind Then
						FSelEndLine = 0
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					This.TopLine = FSelEndLine
					ScrollToCaret
				ElseIf FSelEndLine < GetLineIndex(0, +VisibleLinesCount) Then
					FSelEndLine = 0
					FSelEndChar = 0
				Else
					FSelEndLine = GetLineIndex(FSelEndLine, -VisibleLinesCount)
					FSelEndChar = GetCharIndexFromOld
					Var LengthOf = LineLength(FSelEndLine)
					If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
				End If
				If Not bShifted Then
					FSelStartLine = FSelEndLine
					FSelStartChar = FSelEndChar
				End If
				ScrollToCaret
				#ifdef __USE_GTK__
				Case GDK_KEY_Page_Down
				#else
				Case VK_NEXT
				#endif
				If DropDownShowed Then
					#ifdef __USE_GTK__
						If lvIntellisense.SelectedItemIndex < lvIntellisense.ListItems.Count - 1 Then LastItemIndex = Min(lvIntellisense.SelectedItemIndex + 6, lvIntellisense.ListItems.Count - 1): lvIntellisense.SelectedItemIndex = LastItemIndex
					#else
						If cboIntellisense.ItemIndex < cboIntellisense.Items.Count - 1 Then LastItemIndex = Min(cboIntellisense.ItemIndex + 6, cboIntellisense.Items.Count - 1): cboIntellisense.ItemIndex = LastItemIndex
					#endif
				ElseIf bCtrl Then
					Dim bFind As Boolean
					For i As Integer = FSelEndLine + 1 To GetLineIndex(FLines.Count - 1)
						With *Cast(EditControlLine Ptr, FLines.Item(i))
							If .ConstructionIndex > 13 AndAlso .ConstructionPart = 0 Then
								FSelEndLine = i
								bFind = True
								Exit For
							End If
						End With
					Next
					If Not bFind Then
						FSelEndLine = GetLineIndex(FLines.Count - 1)
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					This.TopLine = FSelEndLine
					ScrollToCaret
				ElseIf FSelEndLine > GetLineIndex(FLines.Count - 1, -VisibleLinesCount) Then
					FSelEndLine = GetLineIndex(FLines.Count - 1)
					FSelEndChar = LineLength(FSelEndLine)
				Else
					FSelEndLine = GetLineIndex(FSelEndLine, +VisibleLinesCount)
					FSelEndChar = GetCharIndexFromOld
					Var LengthOf = LineLength(FSelEndLine)
					If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
				End If
				If Not bShifted Then
					FSelStartLine = FSelEndLine
					FSelStartChar = FSelEndChar
				End If
				ScrollToCaret
				#ifdef __USE_GTK__
				Case GDK_KEY_Insert
				#else
				Case VK_INSERT
				#endif
				If bCtrl Then
					CopyToClipboard
				ElseIf bShifted Then
					PasteFromClipboard
				End If
				#ifdef __USE_GTK__
				Case GDK_KEY_F9
				#else
				Case VK_F9
				#endif
				Breakpoint
				#ifdef __USE_GTK__
				Case GDK_KEY_F6
				#else
				Case VK_F6
				#endif
				Bookmark
				#ifdef __USE_GTK__
				Case GDK_KEY_Tab
					If DropDownShowed Then
						CloseDropDown()
						#ifdef __USE_GTK__
							If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
						#else
							If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
						#endif
					End If
					'If TabAsSpaces Then
					'                                Var d = 4 - (FSelEndChar Mod 4)
					'                                for i As Integer = 0 to d - 1
					'                                    SendMessage(FHandle, WM_CHAR, 32, 0)
					'                                Next i
					'                                Return
					'Else
					bAddText = True
					If FSelStartLine <> FSelEndLine Then
						Indent
					Else
						#ifdef __USE_GTK__
							ChangeText !"\t" '*e->Key.string
						#else
							ChangeText WChr(msg.wParam)
						#endif
					End If
					'End If
					msg.Result = True
				Case GDK_KEY_ISO_Left_Tab ', 65056
					Outdent
					Msg.Result = True
				#endif
				#ifdef __USE_GTK__
				Case Else
					
					Select Case (Asc(*e->Key.string))
				#else
				End Select
			Case WM_CHAR
				Select Case (msg.wParam)
				#endif
			Case 8:  ' backspace
				If FSelStartLine = 0 And FSelEndLine = 0 And FSelStartChar = 0 And FSelEndChar = 0 Then
					Return
				ElseIf FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
					ChangeText "", 0, "Belgilangan matn o`chirildi"
				ElseIf bCtrl Then
					WordLeft
					ChangeText "", 0, "Ortdagi so`z o`chirildi"
				Else
					WLet(FLine, Lines(FSelEndLine))
					Var n = Len(*FLine) - Len(LTrim(*FLine))
					If n > 0 AndAlso n = FSelEndChar AndAlso Mid(*FLine, FSelEndChar + 1, 1) <> " " Then
						Var d = Min(n, TabWidth - (n Mod TabWidth))
						bAddText = True
						ChangeText "", -d
					Else
						If FSelEndChar = 0 And FSelStartChar = 0 And FSelStartLine = FSelEndLine Then
							If CInt(FSelEndLine > 0) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine - 1])->Visible) Then
								ShowLine FSelEndLine - 1
							End If
						End If
						bAddText = True
						ChangeText "", -1
					End If
				End If
			Case 10:  ' перевод строки
			Case 27:  ' esc
				#ifndef __USE_GTK__
					MessageBeep(-1)
				#endif
				msg.Result = 0
			Case 9:  ' tab
				If DropDownShowed Then
					CloseDropDown()
					#ifdef __USE_GTK__
						If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
					#else
						If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
					#endif
				End If
				'If TabAsSpaces Then
				'                                Var d = 4 - (FSelEndChar Mod 4)
				'                                for i As Integer = 0 to d - 1
				'                                    SendMessage(FHandle, WM_CHAR, 32, 0)
				'                                Next i
				'                                Return
				'Else
				bAddText = True
				If FSelStartLine <> FSelEndLine Then
					Indent
				Else
					#ifdef __USE_GTK__
						ChangeText *e->Key.string
					#else
						ChangeText WChr(msg.wParam)
					#endif
				End If
				'End If
				msg.Result = True
			Case 13:  ' возврат каретки
				If ToolTipShowed Then CloseToolTip
				If DropDownShowed Then
					CloseDropDown()
					#ifdef __USE_GTK__
						If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
					#else
						If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
					#endif
					Exit Sub
				End If
				If CInt(FSelEndLine = FSelStartLine) AndAlso CInt(FSelEndChar = FSelStartChar) AndAlso CInt(FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text)) Then
					Var iEndLine = GetLineIndex(FSelEndLine, 1)
					If iEndLine = FSelEndLine Then FSelEndLine = FLines.Count - 1 Else FSelEndLine = iEndLine - 1
					FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text)
					FSelStartLine = FSelEndLine
					FSelStartChar = FSelEndChar
				End If
				WLet(FLine, ..Left(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, FSelEndChar))
				WLet(FLineLeft, "")
				WLet(FLineRight, "")
				WLet(FLineTemp, "")
				Dim j As Integer = 0
				Dim i As Integer = GetConstruction(RTrim(*FLine, Any !"\t "), j)
				Var d = Len(*FLine) - Len(LTrim(*FLine, Any !"\t "))
				WLet(FLineSpace, ..Left(*FLine, d))
				Var k = 0
				Var p = 0
				Var z = 0
				If CInt(AutoIndentation) And CInt(i > -1) Then
					If j > 0 Then
						Dim y As Integer
						For o As Integer = FSelEndLine - 1 To 0 Step -1
							With *Cast(EditControlLine Ptr, FLines.Items[o])
								If .ConstructionIndex = i Then
									If .ConstructionPart = 2 Then
										y = y + 1
									ElseIf .ConstructionPart = 0 Then
										If y = 0 Then
											Var ltt0 = Len(GetTabbedText(*.Text))
											Var ltt1 = Len(GetTabbedText(*FLine))
											If ltt0 <> ltt1 Then
												d = Len(*.Text) - Len(LTrim(*.Text, Any !"\t "))
												FSelEndChar = FSelEndChar - (Len(*FLineSpace) - d)
												FSelStartChar = FSelEndChar
												WLet(FLineSpace, ..Left(*.Text, d))
												WLet(Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, *FLineSpace & LTrim(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, Any !"\t "))
											End If
											Exit For
										Else
											y = y - 1
										End If
									End If
								End If
							End With
						Next
					End If
					If CInt(j < 2) Then
						If TabAsSpaces AndAlso ChoosedTabStyle = 0 Then
							k = TabWidth
						Else
							k = 1
						End If
						If j = 0 Then
							If FSelEndLine < FLines.Count - 1 Then WLetEx(FLineTemp, GetTabbedText(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine + 1])->Text), True)
							Dim n As Integer
							Dim m As Integer = GetConstruction(*FLineTemp, n)
							Var e = Len(*FLineTemp) - Len(LTrim(*FLineTemp, Any !"\t "))
							WLetEx(FLineTemp, GetTabbedText(*FLine), True)
							Var r = Len(*FLineTemp) - Len(LTrim(*FLineTemp, Any !"\t "))
							If e > r OrElse (e = r And m = i And n > 0) Then
							Else
								WLet(FLineTemp,  Mid(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, FSelEndChar + 1))
								WLet(FLineRight, LTrim(*FLineTemp, Any !"\t ") & Chr(13) & *FLineSpace & GetKeyWordCase(Constructions(i).EndName))
								p = Len(*FLineTemp)
							End If
						End If
						If i = 0 And (j = 0 Or j = 1) Then
							If (StartsWith(LTrim(LCase(*FLine), Any !"\t "), "if ") Or StartsWith(LTrim(LCase(*FLine), Any !"\t "), "elseif ")) And (Not EndsWith(RTrim(LCase(*FLine), Any !"\t "), "then")) And (Not EndsWith(RTrim(LCase(*FLine), Any !"\t "), "_")) Then
								p = Len(RTrim(*FLine, Any !"\t ")) - Len(*FLine)
								WLet(FLineLeft, GetKeyWordCase(" Then"))
							End If
						End If
					End If
				End If
				If CInt(TabAsSpaces AndAlso ChoosedTabStyle = 0) OrElse CInt(k = 0) Then
					WAdd FLineSpace, WSpace(k)
				Else
					WAdd FLineSpace, !"\t"
				End If
				ChangeText *FLineLeft & WChr(13) & *FLineSpace & *FLineRight, p, "Enter bosildi", Min(FSelStartLine, FSelEndLine) + 1, d + k
				'Var n = Min(FSelStart, FSelEnd)
				'Var x = Max(FSelStart, FSelEnd)
				'Var l = LineFromCharIndex(n)
				'Var c = CharIndexFromLine(l)
				'Var l1 = LineFromCharIndex(x)
				'If l1 + 1 < FLines.Count Then
				'    WLet FLineRight, *Cast(EditControlLine Ptr, FLines.Item(l1 + 1))->Text
				'Else
				'    WLet FLineRight, ""
				'End If
				'WLet FLine, Mid(*FText, c + 1, n - c + 1)
				'Var d = GetLeftSpace(*FLine)
				'Var k = 0
				'WLet FLineLeft, ""
				'For i As Integer = 0 To Ubound(Constructions)
				'    If Constructions(i).Name0 <> "" AndAlso Instr(" " & LCase(*FLine), " " & LCase(Constructions(i).Name0) & " ") AndAlso _
				'    (Constructions(i).Exception = "" OrElse Instr(LCase(*FLine), LCase(Constructions(i).Exception)) = 0) Then
				'        Var e = GetLeftSpace(*FLineRight)
				'        If e > d OrElse (e = d AndAlso ((Constructions(i).Name1 <> "" AndAlso Instr(" " & LCase(*FLineRight) & " ", " " & LCase(Constructions(i).Name1) & " ")) OrElse _
				'           (Constructions(i).Name2 <> "" AndAlso Instr(" " & LCase(*FLineRight) & " ", " " & LCase(Constructions(i).Name2) & " ")) OrElse _
				'           (Constructions(i).EndName <> "" AndAlso Instr(" " & LCase(*FLineRight) & " ", " " & LCase(Constructions(i).EndName) & " "))) AndAlso _
				'           (Constructions(i).Exception = "" OrElse Instr(LCase(*FLineRight), LCase(Constructions(i).Exception)) = 0)) Then
				'
				'        Else
				'            WLet FLineLeft, Chr(13) & Space(d) & Constructions(i).EndName
				'        End If
				'        k = 4
				'        Exit For
				'    ElseIf ((Constructions(i).Name1 <> "" AndAlso Instr(" " & LCase(*FLine) & " ", " " & LCase(Constructions(i).Name1) & " ")) OrElse _
				'           (Constructions(i).Name2 <> "" AndAlso Instr(" " & LCase(*FLine) & " ", " " & LCase(Constructions(i).Name2) & " "))) AndAlso _
				'           (Constructions(i).Exception = "" OrElse Instr(LCase(*FLine), LCase(Constructions(i).Exception)) = 0) Then
				'        k = 4
				'        Exit For
				'    End If
				'Next i
				'ChangeText Left(*FText, n) & Chr(13) & Space(d) & Space(k) & *FLineLeft & Mid(*FText, x + 1), "Enter bosildi", n + 1 + d + k
				'ChangeText Chr(13), 0, "Enter bosildi", FSelStartLine + 1, 0
				'End If
			Case Else:    ' отображаемые символы
				#ifdef __USE_GTK__
					If CInt(Not bCtrl) AndAlso CInt(*e->Key.string <> "") Then
				#else
					If GetKeyState(VK_CONTROL) >= 0 OrElse GetKeyState(VK_RMENU) < 0 Then
				#endif
					#ifdef __USE_GTK__
						If *e->Key.string = " " Then
					#else
						If msg.wParam = Asc(" ") Then
					#endif
						If DropDownShowed Then
							CloseDropDown()
							#ifdef __USE_GTK__
								If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
							#else
								If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
							#endif
						End If
					End If
					bAddText = True
					#ifdef __USE_GTK__
						ChangeText *e->Key.string
					#else
						ChangeText WChr(msg.wParam)
					#endif
					#ifdef __USE_GTK__
					ElseIf Asc(*e->Key.string) = 26 Then
					#else
					ElseIf msg.wParam = 26 Then
					#endif
					Undo
					#ifdef __USE_GTK__
					ElseIf Asc(*e->Key.string) = 25 Then
					#else
					ElseIf msg.wParam = 25 Then
					#endif
					Redo
					#ifdef __USE_GTK__
					ElseIf Asc(*e->Key.string) = 24 Then
					#else
					ElseIf msg.wParam = 24 Then
					#endif
					CutToClipBoard
					#ifdef __USE_GTK__
					ElseIf Asc(*e->Key.string) = 3 Then
					#else
					ElseIf msg.wParam = 3 Then
					#endif
					CopyToClipBoard
					#ifdef __USE_GTK__
					ElseIf Asc(*e->Key.string) = 22 Then
					#else
					ElseIf msg.wParam = 22 Then
					#endif
					PasteFromClipBoard
					#ifdef __USE_GTK__
					ElseIf Asc(*e->Key.string) = 127 Then
					#else
					ElseIf msg.wParam = 127 Then
					#endif
					WordLeft
					ChangeText "", 0, "Ortdagi so`z o`chirildi"
				End If
			End Select
			#ifdef __USE_GTK__
			End Select
		Case GDK_KEY_RELEASE
			#else
			Case WM_KEYUP
			#endif
			bInMiddleScroll = False
			#ifdef __USE_GTK__
			Case GDK_2BUTTON_PRESS ', GDK_DOUBLE_BUTTON_PRESS
			#else
			Case WM_LBUTTONDBLCLK
			#endif
			bInMiddleScroll = False
			#ifdef __USE_GTK__
				FSelEndLine = LineIndexFromPoint(e->button.x, e->button.y)
				If InCollapseRect(FSelEndLine, e->button.x, e->button.y) Then
			#else
				FSelEndLine = LineIndexFromPoint(msg.lParamLo, msg.lParamHi)
				If InCollapseRect(FSelEndLine, msg.lParamLo, msg.lParamHi) Then
			#endif
			Else
				#ifdef __USE_GTK__
					FSelEndChar = CharIndexFromPoint(e->button.x, e->button.y)
				#else
					FSelEndChar = CharIndexFromPoint(msg.lParamLo, msg.lParamHi)
				#endif
				If CInt(Not bShifted) And CInt(FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar) Then
					FSelStartLine = FSelEndLine
					FSelStartChar = FSelEndChar
				Else
					If Not bShifted Then
						WordLeft
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
						'FSelEndChar = FSelEndChar + 1
						WordRight
					End If
				End If
				ScrollToCaret
			End If
			#ifdef __USE_GTK__
			Case GDK_BUTTON_PRESS
				gtk_widget_grab_focus(widget)
				If e->button.button - 1 <> 0 Then Exit Select
			#else
			Case WM_LBUTTONDOWN
			#endif
			bInMiddleScroll = False
			DownButton = 0
			#ifdef __USE_GTK__
				FSelEndLine = LineIndexFromPoint(e->button.x, e->button.y)
				If InCollapseRect(FSelEndLine, e->button.x, e->button.y) Then
			#else
				FSelEndLine = LineIndexFromPoint(UnScaleX(msg.lParamLo), UnScaleY(msg.lParamHi))
				If InCollapseRect(FSelEndLine, UnScaleX(msg.lParamLo), UnScaleY(msg.lParamHi)) Then
			#endif
				FSelStartLine = FSelEndLine
				FSelEndLine = FSelEndLine
				FSelStartChar = 0
				FSelEndChar = 0
				FECLine = FLines.Items[FSelEndLine]
				ChangeCollapseState FSelEndLine, Not FECLine->Collapsed
				ScrollToCaret
				OldnCaretPosX = nCaretPosX
				OldCharIndex = GetOldCharIndex
			Else
				#ifdef __USE_GTK__
					FSelEndChar = CharIndexFromPoint(e->button.x, e->button.y)
				#else
					FSelEndChar = CharIndexFromPoint(UnScaleX(msg.lParamLo), UnScaleY(msg.lParamHi))
				#endif
				If Not bShifted Then
					FSelStartLine = FSelEndLine
					FSelStartChar = FSelEndChar
				End If
				#ifdef __USE_GTK__
					If e->button.x < LeftMargin Then
				#else
					If UnScaleX(msg.lParamLo) < LeftMargin Then
				#endif
					FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
				End If
				If Not Focused Then This.SetFocus
				ScrollToCaret
				OldnCaretPosX = nCaretPosX
				OldCharIndex = GetOldCharIndex
				#ifndef __USE_GTK__
					SetCapture FHandle
				#endif
			End If
			#ifdef __USE_GTK__
			Case GDK_KEY_RELEASE
			#else
			Case WM_LBUTTONUP
				ReleaseCapture
			#endif
			If bInIncludeFileRect Then
				FECLine = FLines.Items[FSelEndLine]
				Var Pos1 = InStr(*FECLine->Text, """")
				If Pos1 > 0 Then
					Var Pos2 = InStr(Pos1 + 1, *FECLine->Text, """")
					If Pos2 > 0 Then
						If OnLinkClicked Then OnLinkClicked(This, Mid(*FECLine->Text, Pos1 + 1, Pos2 - Pos1 - 1))
					End If
				End If
			End If
			DownButton = -1
			#ifdef __USE_GTK__
			Case GDK_BUTTON_PRESS
				'				gtk_widget_grab_focus(widget)
				'				If e->button.button - 1 <> 0 Then Exit Select
			#else
			Case WM_MBUTTONDOWN
				bInMiddleScroll = Not bInMiddleScroll
				bScrollStarted = True
				ScrEC = @This
				MButtonX = UnScaleX(msg.lParamLo)
				MButtonY = UnScaleY(msg.lParamHi)
				GetCursorPos @m_tP
				SetTimer Handle, 1, 25, @EC_TimerProc
			#endif
			#ifdef __USE_GTK__
			Case GDK_MOTION_NOTIFY
			#else
			Case WM_MOUSEMOVE
			#endif
			#ifdef __USE_GTK__
				iTemp = LineIndexFromPoint(e->button.x, e->button.y)
				If InCollapseRect(iTemp, e->button.x, e->button.y) Then
					gdk_window_set_cursor(win, gdkCursorHand)
				Else
					gdk_window_set_cursor(win, gdkCursorIBeam)
				End If
			#endif
			'			#ifdef __USE_GTK__
			'				bInIncludeFileRect = bCtrl AndAlso InIncludeFileRect(iCursorLine, e->button.x, e->button.y)
			'			#else
			'				bInIncludeFileRect = bCtrl AndAlso InIncludeFileRect(iCursorLine, msg.lParamLo, msg.lParamHi)
			'			#endif
			'			If bInIncludeFileRectOld <> bInIncludeFileRect Then PaintControl
			'			bInIncludeFileRectOld = bInIncludeFileRect
			If DownButton = 0 Then
				#ifdef __USE_GTK__
					lParamLo = IIf(e->button.x > 60000, e->button.x - 65535, e->button.x)
					lParamHi = IIf(e->button.y > 60000, e->button.y - 65535, e->button.y)
				#else
					lParamLo = IIf(msg.lParamLo > 60000, msg.lParamLo - 65535, msg.lParamLo)
					lParamHi = IIf(msg.lParamHi > 60000, msg.lParamHi - 65535, msg.lParamHi)
				#endif
				FSelEndLine = LineIndexFromPoint(UnScaleX(lParamLo), UnScaleY(lParamHi))
				FSelEndChar = CharIndexFromPoint(UnScaleX(lParamLo), UnScaleY(lParamHi))
				If lParamLo < LeftMargin Then
					If FSelEndLine < FSelStartLine Then
						FSelStartChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelStartLine))->Text)
					Else
						FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
					End If
				End If
				ScrollToCaret
			End If
			#ifndef __USE_GTK__
			Case WM_CTLCOLORMSGBOX To WM_CTLCOLORSTATIC: PaintControl ': Message.Result = -1
			Case WM_ERASEBKGND
				PaintControl
				ShowCaretPos False: msg.Result = -1
			#endif
			#ifdef __USE_GTK__
			Case GDK_EXPOSE
			#else
			Case WM_PAINT
			#endif
			PaintControl
			ShowCaretPos False
		Case Else
		End Select
		Base.ProcessMessage(msg)
	End Sub
	
	Sub EditControl.HandleIsAllocated(ByRef Sender As Control)
		If Sender.Child Then
			With QEditControl(Sender.Child)
				#ifdef __USE_WINAPI__
					If g_darkModeSupported AndAlso g_darkModeEnabled Then
						SetWindowTheme(.FHandle, "DarkMode_Explorer", nullptr)
						SendMessageW(.FHandle, WM_THEMECHANGED, 0, 0)
						_AllowDarkModeForWindow(.FHandle, g_darkModeEnabled)
						UpdateWindow(.FHandle)
					End If
				#endif
				'Var s1Pos = 100, s1Min = 1, s1Max = 100
				'SetScrollRange(.FHandle, SB_CTL, s1Min, s1Max, TRUE)
				'SetScrollPos(.FHandle, SB_CTL, s1Pos, TRUE)
			End With
		End If
	End Sub
	
	#ifdef __USE_GTK__
		Function EditControl_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
			Dim As EditControl Ptr ec = Cast(Any Ptr, data1)
			If ec->cr = 0 Then
				ec->cr = cr
				#ifdef __FB_WIN32__
					cairo_select_font_face(cr, "Courier", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
				#else
					cairo_select_font_face(cr, "Noto Mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
				#endif
				cairo_set_font_size(cr, 11)
				
				Dim As PangoRectangle extend
				pango_layout_set_text(ec->layout, ToUTF8("|"), 1)
				pango_cairo_update_layout(cr, ec->layout)
				#ifdef PANGO_VERSION
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(ec->layout, 0)
				#else
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(ec->layout, 0)
				#endif
				pango_layout_line_get_pixel_extents(pl, NULL, @extend)
				ec->dwCharX = extend.width
				ec->dwCharY = extend.height
				
				'Dim extend As cairo_text_extents_t
				'cairo_text_extents (cr, "|", @extend)
				
				ec->LeftMargin = Len(Str(ec->LinesCount)) * ec->dwCharX + 30
				
				ec->pdisplay = gtk_widget_get_display(widget)
				ec->gdkCursorIBeam = gdk_cursor_new_for_display(ec->pdisplay, GDK_XTERM)
				ec->gdkCursorHand = gdk_cursor_new_from_name(ec->pdisplay, "pointer")
				#ifdef __USE_GTK3__
					ec->win = gtk_layout_get_bin_window(gtk_layout(widget))
				#endif
				gdk_window_set_cursor(ec->win, ec->gdkCursorIBeam)
				
				ec->ShowCaretPos False
				ec->HScrollPos = 0
				If ec->VScrollPos <> 0 Then
					ec->ShowCaretPos True
				End If
				'ec->VScrollPos = 0
				
				gtk_window_set_transient_for(gtk_window(ec->winIntellisense), gtk_window(pfrmMain->Handle))
				gtk_window_set_transient_for(gtk_window(ec->winTooltip), gtk_window(pfrmMain->Handle))
			
			End If
			#ifdef __USE_GTK3__
			#else
				ec->cr = cr
			#endif
			'If ec->bChanged Then
			'ec->bChanged = False
			#ifdef __USE_GTK3__
				Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
			#else
				Dim As Integer AllocatedWidth = widget->allocation.width, AllocatedHeight = widget->allocation.height
			#endif
			If AllocatedWidth <> ec->dwClientX Or AllocatedHeight <> ec->dwClientY Then
				ec->dwClientX = AllocatedWidth
				ec->dwClientY = AllocatedHeight
				
				#ifdef __USE_GTK3__
					gtk_layout_move(gtk_layout(ec->Handle), ec->scrollbarv, ec->dwClientX - ec->verticalScrollBarWidth, 0)
					gtk_widget_set_size_request(ec->scrollbarv, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
					gtk_layout_move(gtk_layout(ec->Handle), ec->scrollbarh, 0, ec->dwClientY - ec->horizontalScrollBarHeight)
					gtk_widget_set_size_request(ec->scrollbarh, ec->dwClientX - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
				#else
					gtk_layout_move(gtk_layout(ec->Handle), ec->scrollbarv, ec->dwClientX - ec->verticalScrollBarWidth + 2, 0)
					gtk_widget_set_size_request(ec->scrollbarv, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
					gtk_layout_move(gtk_layout(ec->Handle), ec->scrollbarh, 0, ec->dwClientY - ec->horizontalScrollBarHeight + 2)
					gtk_widget_set_size_request(ec->scrollbarh, ec->dwClientX - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
				#endif
				'Ctrl->RequestAlign AllocatedWidth, AllocatedHeight
				ec->SetScrollsInfo
			End If
			
			ec->PaintControlPriv
			
			Return False
		End Function
		
		Function EditControl_OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
			Dim As EditControl Ptr ec = Cast(Any Ptr, data1)
			Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
			ec->win = Event->window
			EditControl_OnDraw widget, cr, data1
			cairo_destroy(cr)
			Return False
		End Function
		
		Sub EditControl_SizeAllocate(widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr)
			Dim As EditControl Ptr ec = Cast(Any Ptr, user_data)
			
			'	ec->PaintControl
			'	'gtk_fixed_move(gtk_fixed(ec->fixedwidget), ec->scrollbarv, ec->dwClientX - ec->verticalScrollBarWidth, 0)
			'	'gtk_widget_set_size_request(ec->scrollbarv, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
			'	'gtk_fixed_move(gtk_fixed(ec->fixedwidget), ec->scrollbarh, 0, ec->dwClientY - ec->horizontalScrollBarHeight)
			'	'gtk_widget_set_size_request(ec->scrollbarh, ec->dwClientX - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
			'	'gtk_widget_set_size_request(ec->wText, ec->dwClientX - ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
			'	'Ctrl->RequestAlign
			'	'?Ctrl->ClassName
		End Sub
		
		Sub EditControl_ScrollValueChanged(widget As GtkAdjustment Ptr, user_data As Any Ptr)
			Dim As EditControl Ptr ec = Cast(Any Ptr, user_data)
			If widget = ec->adjustmentv Then
				ec->VScrollPos = gtk_adjustment_get_value(ec->adjustmentv)
			Else
				ec->HScrollPos = gtk_adjustment_get_value(ec->adjustmenth)
			End If
			#ifdef __USE_GTK3__
				ec->ShowCaretPos False
				ec->PaintControl
			#endif
		End Sub
		
	#endif
	
	Constructor EditControl
		Child       = @This
		#ifdef __USE_GTK__
			widget = gtk_layout_new(NULL, NULL)
			'tooltip = gtk_tooltip_new()
			#ifdef __USE_GTK3__
				scontext = gtk_widget_get_style_context (widget)
			#endif
			'gtk_layout_set_size(gtk_layout(widget), 1000, 1000)
			'g_object_set (gtk_widget_get_settings(widget), "gtk-keynav-use-caret", true, NULL)
			'gtk_scrolled_window_set_policy(gtk_scrolled_window(widget), GTK_POLICY_EXTERNAL, GTK_POLICY_EXTERNAL)
			This.RegisterClass "EditControl", @This
			'gtk_container_add(GTK_CONTAINER(widget), fixedwidget)
			'EditControlObject = @This
			'wText = mycustomwidget_new()
			'gtk_widget_set_parent(wText, widget)
			'gtk_fixed_put(gtk_fixed(fixedwidget), wText, 0, 0)
			'gtk_widget_set_size_request(wText, 100, 100)
			'gtk_scrolled_window_set_policy(gtk_scrolled_window(widget), GTK_POLICY_EXTERNAL, GTK_POLICY_EXTERNAL)
			'gtk_widget_show(wText)
			'gtk_widget_set_events(wText, GDK_EXPOSURE_MASK)
			gtk_widget_set_can_focus(widget, True)
			'gtk_widget_set_focus_on_click(widget, True)
			'gtk_widget_set_events(widget, _
			'            GDK_EXPOSURE_MASK Or _
			'              GDK_SCROLL_MASK Or _
			'             GDK_STRUCTURE_MASK Or _
			'              GDK_KEY_PRESS_MASK Or _
			'            GDK_KEY_RELEASE_MASK Or _
			'              GDK_FOCUS_CHANGE_MASK Or _
			'              GDK_LEAVE_NOTIFY_MASK Or _
			'              GDK_BUTTON_PRESS_MASK Or _
			'              GDK_BUTTON_RELEASE_MASK Or _
			'              GDK_POINTER_MOTION_MASK Or _
			'              GDK_POINTER_MOTION_HINT_MASK)
			gtk_widget_set_events(widget, _
			GDK_EXPOSURE_MASK Or _
			GDK_SCROLL_MASK Or _
			GDK_STRUCTURE_MASK Or _
			GDK_KEY_PRESS_MASK Or _
			GDK_KEY_RELEASE_MASK Or _
			GDK_FOCUS_CHANGE_MASK Or _
			GDK_LEAVE_NOTIFY_MASK Or _
			GDK_BUTTON_PRESS_MASK Or _
			GDK_BUTTON_RELEASE_MASK Or _
			GDK_POINTER_MOTION_MASK Or _
			GDK_POINTER_MOTION_HINT_MASK)
			g_signal_connect(widget, "size-allocate", G_CALLBACK(@EditControl_SizeAllocate), @This)
			'g_signal_connect(widget, "event", G_CALLBACK(@EventProc), @This)
			'g_signal_connect(widget, "event-after", G_CALLBACK(@EventAfterProc), @This)
			'g_signal_connect(wText, "draw", G_CALLBACK(@EditControl_OnDraw), @This)
			#ifdef __USE_GTK3__
				g_signal_connect(widget, "draw", G_CALLBACK(@EditControl_OnDraw), @This)
			#else
				g_signal_connect(widget, "expose-event", G_CALLBACK(@EditControl_OnExposeEvent), @This)
			#endif
			pcontext = gtk_widget_create_pango_context(widget)
			layout = pango_layout_new(pcontext)
			Dim As PangoFontDescription Ptr desc
			#ifdef __FB_WIN32__
				desc = pango_font_description_from_string ("Courier 11")
			#else
				desc = pango_font_description_from_string ("Noto Mono 11")
			#endif
			pango_layout_set_font_description (layout, desc)
			pango_font_description_free (desc)
			
			g_object_get(G_OBJECT(gtk_settings_get_default()), "gtk-cursor-blink-time", @BlinkTime, NULL)
			'BlinkTime = BlinkTime / 1.75
			'gdk_threads_add_timeout(BlinkTime, @Blink_cb, @This)
			adjustmentv = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 201.0, 1.0, 20.0, 20.0))
			#ifdef __USE_GTK3__
				scrollbarv = gtk_scrollbar_new(GTK_ORIENTATION_VERTICAL, GTK_ADJUSTMENT(adjustmentv))
			#else
				scrollbarv = gtk_vscrollbar_new(GTK_ADJUSTMENT(adjustmentv))
			#endif
			gtk_widget_set_can_focus(scrollbarv, False)
			g_signal_connect(adjustmentv, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarv, widget)
			If gtk_is_widget(scrollbarv) Then gtk_layout_put(gtk_layout(widget), scrollbarv, 0, 0)
			gtk_widget_show(scrollbarv)
			adjustmenth = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 20.0, 20.0))
			#ifdef __USE_GTK3__
				scrollbarh = gtk_scrollbar_new(GTK_ORIENTATION_HORIZONTAL, GTK_ADJUSTMENT(adjustmenth))
			#else
				scrollbarh = gtk_hscrollbar_new(GTK_ADJUSTMENT(adjustmenth))
			#endif
			gtk_widget_set_can_focus(scrollbarh, False)
			g_signal_connect(adjustmenth, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarh, widget)
			If gtk_is_widget(scrollbarh) Then gtk_layout_put(gtk_layout(widget), scrollbarh, 0, 0)
			gtk_widget_show(scrollbarh)
			Dim As GtkRequisition vminimum, hminimum, vrequisition, hrequisition
			#ifdef __USE_GTK3__
				gtk_widget_get_preferred_size(scrollbarv, @vminimum, @vrequisition)
				gtk_widget_get_preferred_size(scrollbarh, @hminimum, @hrequisition)
			#else
				gtk_widget_size_request(scrollbarv, @vrequisition)
				gtk_widget_size_request(scrollbarh, @hrequisition)
			#endif
			Var minVScrollBarHeight = hminimum.height
			Var minHScrollBarWidth = vminimum.width
			verticalScrollBarWidth = vrequisition.width
			horizontalScrollBarHeight = hrequisition.height
			'layoutwidget = widget
			'gtk_widget_grab_focus(wText)
		#else
			OnHandleIsAllocated = @HandleIsAllocated
		#endif
		dwCharY = 5
		'MultiLine = True
		'ChildProc   = @WndProc
		#ifndef __USE_GTK__
			ExStyle     = WS_EX_CLIENTEDGE
			Style       = WS_CHILD Or WS_TABSTOP Or ES_WANTRETURN Or WS_HSCROLL Or WS_VSCROLL Or CS_DBLCLKS
		#endif
		This.Width       = 121
		Height          = 121
		#ifndef __USE_GTK__
			This.Cursor = LoadCursor(NULL, IDC_IBEAM)
		#endif
		This.BackColor       = clWhite
		WLet(FClassName, "EditControl")
		#ifndef __USE_GTK__
			This.RegisterClass "EditControl", ""
		#endif
		Canvas.Ctrl = @This
		crRArrow.LoadFromResourceName("Select")
		crHand.LoadFromResourceName("Hand")
		crScroll.LoadFromResourceName("Scroll")
		crScrollLeft.LoadFromResourceName("ScrollLeft")
		crScrollDown.LoadFromResourceName("ScrollDown")
		crScrollRight.LoadFromResourceName("ScrollRight")
		crScrollUp.LoadFromResourceName("ScrollUp")
		crScrollLeftRight.LoadFromResourceName("ScrollLeftRight")
		crScrollUpDown.LoadFromResourceName("ScrollUpDown")
		'Text = ""
		#ifdef __USE_GTK__
			winIntellisense = gtk_window_new(GTK_WINDOW_POPUP)
			gtk_scrolled_window_set_policy(gtk_scrolled_window(lvIntellisense.scrolledwidget), GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC)
			gtk_container_add(gtk_container(winIntellisense), lvIntellisense.scrolledwidget)
			'gtk_window_set_transient_for(gtk_window(winIntellisense), gtk_window(pfrmMain->widget))
			gtk_window_resize(gtk_window(winIntellisense), 250, 7 * 22)
			lvIntellisense.Columns.Add "AutoComplete"
			lvIntellisense.ColumnHeaderHidden = True
			lvIntellisense.SingleClickActivate = True
			
			winTooltip = gtk_window_new(GTK_WINDOW_POPUP)
			lblTooltip = gtk_label_new(NULL)
			#ifdef __USE_GTK3__
				gtk_widget_set_margin_left(lblTooltip, 1)
				gtk_widget_set_margin_top(lblTooltip, 1)
				gtk_widget_set_margin_right(lblTooltip, 1)
				gtk_widget_set_margin_bottom(lblTooltip, 1)
			#endif
			gtk_container_add(gtk_container(winTooltip), lblTooltip)
			'gtk_window_set_transient_for(gtk_window(winTooltip), gtk_window(pfrmMain->widget))
			g_signal_connect(lblTooltip, "activate-link", G_CALLBACK(@ActivateLink), @This)
			'gtk_window_resize(gtk_window(winTooltip), 1000, 21)
		#else
			pnlIntellisense.SetBounds 0, -50, 250, 0
			'cboIntellisense.Visible = False
			'cboIntellisense.SetBounds 0, -50, 250, 0
			cboIntellisense.Left = 0
			cboIntellisense.Top = -22
			cboIntellisense.Width = 250
			cboIntellisense.Height = 7 * 22
			pnlIntellisense.Add @cboIntellisense
			This.Add @pnlIntellisense
		#endif
		Var item = New_( EditControlLine)
		WLet(item->Text, "")
		FLines.Add item
		bOldCommented = True
		ChangeText "", 0, "Bo`sh"
		ShowHint = False
		WithHistory = True
		'ClearUndo
		'Brush.Color = clWindowColor
	End Constructor
	
	Destructor EditControl
		'If FText Then Deallocate FText
		_ClearHistory
		If CurEC = @This Then CurEC = 0
		For i As Integer = FLines.Count - 1 To 0 Step -1
			Delete_( Cast(EditControlLine Ptr, FLines.Items[i]))
		Next i
		#ifdef __USE_GTK__
			lvIntellisense.ListItems.Clear
		#else
			cboIntellisense.Items.Clear
		#endif
		WDeallocate FLine
		WDeallocate FLineLeft 
		WDeallocate FLineRight 
		WDeallocate FLineTemp 
		WDeallocate FLineTab
		WDeallocate FLineSpace 
		WDeallocate FHintWord 
		WDeallocate CurrentFontName
	End Destructor
End Namespace

Sub LoadKeyWords
	Dim b As String
	Dim As UString file
	Dim As WStringList Ptr keywordlist
	Dim As Integer k = -1
	file = Dir(ExePath & "/Settings/Keywords/*")
	Do Until file = ""
		k += 1
		ReDim Preserve Keywords(k)
		keywordlist = New WStringList
		KeywordLists.Add file, keywordlist
		If Trim(file) = "Preprocessors" Then
			pkeywords0 = keywordlist
		ElseIf Trim(file) = "Standard Data Types" Then
			pkeywords1 = keywordlist
		ElseIf Trim(file) = "Statements And Operators" Then
			pkeywords2 = keywordlist
		End If
		Dim Fn As Integer = FreeFile_
		Open ExePath & "/Settings/Keywords/" & file For Input As #Fn
		Do Until EOF(Fn)
			Input #Fn, b
			keywordlist->Add b
		Loop
		CloseFile_(Fn)
		file = Dir()
	Loop
'	Fn = FreeFile
'	Open ExePath & "/Settings/Keywords/keywords1" For Input As #Fn
'	Do Until EOF(Fn)
'		Input #Fn, b
'		keywords1.Add b
'	Loop
'	Close #Fn
'	Fn = FreeFile
'	Open ExePath & "/Settings/Keywords/keywords2" For Input As #Fn
'	Do Until EOF(Fn)
'		Input #Fn, b
'		keywords2.Add b
'	Loop
'	Close #Fn
'	Fn = FreeFile
'	Open ExePath & "/Settings/Keywords/keywords3" For Input As #Fn
'	Do Until EOF(Fn)
'		Input #Fn, b
'		keywords3.Add b
'	Loop
'	Close #Fn
End Sub
