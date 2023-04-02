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

Namespace My.Sys.Forms
	Destructor EditControlHistory
		If Comment Then Deallocate_( Comment)
		For i As Integer = Lines.Count - 1 To 0 Step -1
			Delete_( Cast(EditControlLine Ptr, Lines.Items[i]))
		Next i
		Lines.Clear
	End Destructor
	
	Destructor EditControlStatement
		If This.Text <> 0 Then Deallocate_( This.Text)
	End Destructor
	
	Constructor EditControlLine
		'WLet(Text, "")
		Visible = True
	End Constructor
	
	Destructor EditControlLine
		If This.Text <> 0 Then Deallocate_( This.Text)
		For i As Integer = Statements.Count - 1 To 0 Step -1
			Delete_(Cast(EditControlStatement Ptr, Statements.Item(i)))
		Next
	End Destructor
End Namespace

' Add Try End_Try
ReDim Constructions(C_Count - 1) As Construction
Constructions(C_If)             = Type<Construction>("If",            "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "ElseIf",   "Else",       "",        "End If",          "Then ", True,  False)
Constructions(C_P_If)           = Type<Construction>("#If",           "#IfDef",             "#IfNDef",             "",                   "",                          "",                           "",                "",                       "",                        "#ElseIf",  "#Else",      "",        "#EndIf",          "",      True,  False)
Constructions(C_P_Macro)        = Type<Construction>("#Macro",        "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "#EndMacro",       "",      True,  True)
Constructions(C_Extern)         = Type<Construction>("Extern",        "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End Extern",      "As ",   True,  False)
Constructions(C_Try)            = Type<Construction>("Try",           "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "Catch",    "Finally",    "",        "EndTry",          "",      True,  False)
Constructions(C_Asm)            = Type<Construction>("Asm",           "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End Asm",         " ",     True,  False)
Constructions(C_Select_Case)    = Type<Construction>("Select Case",   "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "Case",     "",           "",        "End Select",      "",      True,  False)
Constructions(C_For)            = Type<Construction>("For",           "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "Next",            "",      True,  False)
Constructions(C_Do)             = Type<Construction>("Do",            "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "Loop",            "",      True,  False)
Constructions(C_While)          = Type<Construction>("While",         "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "Wend",            "",      True,  False)
Constructions(C_With)           = Type<Construction>("With",          "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End With",        "",      True,  False)
Constructions(C_Scope)          = Type<Construction>("Scope",         "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End Scope",       "",      True,  False)
Constructions(C_P_Region)       = Type<Construction>("'#Region",      "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "'#End Region",    "",      True,  False)
Constructions(C_Namespace)      = Type<Construction>("Namespace",     "",                   "",                    "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End Namespace",   "",      True,  False)
Constructions(C_Enum)           = Type<Construction>("Enum",          "Public Enum",        "Private Enum",        "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End Enum",        "",      True,  True)
Constructions(C_Class)          = Type<Construction>("Class",         "Public Class",       "Private Class",       "",                   "",                          "",                           "",                "",                       "",                        "Private:", "Protected:", "Public:", "End Class",       "As ",   True,  True)
Constructions(C_Type)           = Type<Construction>("Type",          "Public Type",        "Private Type",        "",                   "",                          "",                           "",                "",                       "",                        "Private:", "Protected:", "Public:", "End Type",        "As ",   True,  True)
Constructions(C_Union)          = Type<Construction>("Union",         "Public Union",       "Private Union",       "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End Union",       "",      True,  True)
Constructions(C_Sub)            = Type<Construction>("Sub",           "Public Sub",         "Private Sub",         "Virtual Sub",        "Public Virtual Sub",        "Private Virtual Sub",        "Static Sub",      "Public Static Sub",      "Private Static Sub",      "",         "",           "",        "End Sub",         "",      True,  True)
Constructions(C_Function)       = Type<Construction>("Function",      "Public Function",    "Private Function",    "Virtual Function",   "Public Virtual Function",   "Private Virtual Function",   "Static Function", "Public Static Function", "Private Static Function", "",         "",           "",        "End Function",    "",      True,  True)
Constructions(C_Property)       = Type<Construction>("Property",      "Public Property",    "Private Property",    "Virtual Property",   "Public Virtual Property",   "Private Virtual Property",   "",                "",                       "",                        "",         "",           "",        "End Property",    "",      True,  True)
Constructions(C_Operator)       = Type<Construction>("Operator",      "Public Operator",    "Private Operator",    "Virtual Operator",   "Public Virtual Operator",   "Private Virtual Operator",   "",                "",                       "",                        "",         "",           "",        "End Operator",    "",      True,  True)
Constructions(C_Constructor)    = Type<Construction>("Constructor",   "Public Constructor", "Private Constructor", "",                   "",                          "",                           "",                "",                       "",                        "",         "",           "",        "End Constructor", "",      True,  True)
Constructions(C_Destructor)     = Type<Construction>("Destructor",    "Public Destructor",  "Private Destructor",  "Virtual Destructor", "Public Virtual Destructor", "Private Virtual Destructor", "",                "",                       "",                        "",         "",           "",        "End Destructor",  "",      True,  True)

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
			Var sbScrollBarh = IIf(MiddleScrollIndexX = 0, sbScrollBarhLeft, sbScrollBarhRight)
			Dim As Integer Ptr pHScrollPos
			If MiddleScrollIndexX = 0 Then
				pHScrollPos = @HScrollPosLeft
			Else
				pHScrollPos = @HScrollPosRight
			End If
			GetScrollInfo sbScrollBarh, SB_CTL, @si
			'GetScrollInfo FHandle, SB_HORZ, @si
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
					SetScrollInfo sbScrollBarh, SB_CTL, @si, True
					'SetScrollInfo FHandle, SB_HORZ, @si, True
					GetScrollInfo(sbScrollBarh, SB_CTL, @si)
					'GetScrollInfo(FHandle, SB_HORZ, @si)
					If (Not si.nPos = *pHScrollPos) Then
						*pHScrollPos = si.nPos
						bChanged = True
					End If
				End If
			End If
			si.cbSize = Len(si)
			si.fMask = SIF_RANGE Or SIF_PAGE Or SIF_POS Or SIF_TRACKPOS
			Var sbScrollBarv = IIf(MiddleScrollIndexY = 0, sbScrollBarvTop, sbScrollBarvBottom)
			Dim As Integer Ptr pVScrollPos
			If MiddleScrollIndexY = 0 Then
				pVScrollPos = @VScrollPosTop
			Else
				pVScrollPos = @VScrollPosBottom
			End If
			GetScrollInfo sbScrollBarv, SB_CTL, @si
			'GetScrollInfo FHandle, SB_VERT, @si
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
					SetScrollInfo(sbScrollBarv, SB_CTL, @si, True)
					'SetScrollInfo(FHandle, SB_VERT, @si, True)
					GetScrollInfo(sbScrollBarv, SB_CTL, @si)
					'GetScrollInfo(FHandle, SB_VERT, @si)
					If (Not si.nPos = *pVScrollPos) Then
						*pVScrollPos = si.nPos
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
				If GTK_IS_WIDGET(ec->widget) Then gtk_widget_queue_draw(ec->widget)
				'gdk_threads_add_timeout(ec->BlinkTime, @Blink_cb, ec)
				Return True
			Else
				ec->CaretOn = False
				If GTK_IS_WIDGET(ec->widget) Then gtk_widget_queue_draw(ec->widget)
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
		FECLine = Content.Lines.Items[FSelEndLine]
		If CInt(Trim(*FECLine->Text, Any !"\t ") = "") OrElse CInt(StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'")) OrElse _
			CInt(StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t ") & " ", "rem ")) Then
			MsgBox ML("Don't set breakpoint to this line"), "VisualFBEditor", mtWarning
			This.SetFocus
		Else
			FECLine->Breakpoint = Not FECLine->Breakpoint
			PaintControl
		End If
	End Sub
	
	Sub EditControl.Bookmark
		Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Bookmark = Not Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Bookmark
		PaintControl
	End Sub
	
	Sub EditControl.ClearAllBookmarks
		For i As Integer = 0 To Content.Lines.Count - 1
			FECLine = Content.Lines.Items[i]
			If FECLine->Bookmark Then
				FECLine->Bookmark = False
			End If
		Next
		PaintControl
	End Sub
	
	Private Property EditControl.SplittedVertically As Boolean
		Return bDividedX
	End Property
	
	Private Property EditControl.SplittedVertically(Value As Boolean)
		Var iOffset = 0
		#ifdef __USE_GTK2__
			iOffset = 2
		#endif
		If Not Value Then
			bDividedX = False
			bInDivideX = False
			iDivideX = 0
			iDividedX = 0
			ActiveCodePane = 1
			#ifdef __USE_WINAPI__
				ShowWindow sbScrollBarvTop, SW_HIDE
				ShowWindow sbScrollBarhLeft, SW_HIDE
				MoveWindow sbScrollBarhRight, ScaleX(7), ScaleY(dwClientY - 17), ScaleX(dwClientX - 17 - 7), ScaleY(17), True
			#else
				gtk_widget_hide(scrollbarvTop)
				gtk_widget_hide(scrollbarhLeft)
				gtk_layout_move(GTK_LAYOUT(FHandle), scrollbarhRight, 7, dwClientY - horizontalScrollBarHeight + iOffset)
				gtk_widget_set_size_request(scrollbarhRight, dwClientX - verticalScrollBarWidth - 7, horizontalScrollBarHeight)
			#endif
		Else
			If bDividedY Then SplittedHorizontally = False
			If Not bDividedX Then
				HScrollPosLeft = HScrollPosRight
			End If
			bDividedX = True
			If iDivideX <= 0 Then iDivideX = (dwClientX - 17) / 2: iDividedX = iDivideX
			#ifdef __USE_WINAPI__
				MoveWindow sbScrollBarvTop, ScaleX(iDivideX - 17), 0, ScaleX(17), ScaleY(dwClientY - 17), True
				MoveWindow sbScrollBarhLeft, 0, ScaleY(dwClientY - 17), ScaleX(iDivideX - 17), ScaleY(17), True
				MoveWindow sbScrollBarhRight, ScaleX(iDivideX + 7), ScaleY(dwClientY - 17), ScaleX(dwClientX - iDivideX - 7 - 17), ScaleY(17), True
				ShowWindow sbScrollBarvTop, SW_SHOW
				ShowWindow sbScrollBarhLeft, SW_SHOW
			#else
				gtk_layout_move(GTK_LAYOUT(FHandle), scrollbarvTop, iDividedX - verticalScrollBarWidth + iOffset, 0)
				gtk_widget_set_size_request(scrollbarvTop, verticalScrollBarWidth, dwClientY - horizontalScrollBarHeight)
				gtk_layout_move(GTK_LAYOUT(FHandle), scrollbarhLeft, 0, dwClientY - horizontalScrollBarHeight + iOffset)
				gtk_widget_set_size_request(scrollbarhLeft, iDivideX - verticalScrollBarWidth, horizontalScrollBarHeight)
				gtk_layout_move(GTK_LAYOUT(FHandle), scrollbarhRight, iDivideX + 7, dwClientY - horizontalScrollBarHeight + iOffset)
				gtk_widget_set_size_request(scrollbarhRight, dwClientX - iDivideX - 7 - verticalScrollBarWidth, horizontalScrollBarHeight)
				gtk_widget_show(scrollbarvTop)
				gtk_widget_show(scrollbarhLeft)
			#endif
		End If
		If OnSplitVerticallyChange Then OnSplitVerticallyChange(This, Value)
	End Property
	
	Private Property EditControl.SplittedHorizontally As Boolean
		Return bDividedY
	End Property
	
	Private Property EditControl.SplittedHorizontally(Value As Boolean)
		Var iOffset = 0
		#ifdef __USE_GTK2__
			iOffset = 2
		#endif
		If Not Value Then
			bDividedY = False
			bInDivideY = False
			iDivideY = 0
			iDividedY = 0
			ActiveCodePane = 1
			#ifdef __USE_WINAPI__
				ShowWindow sbScrollBarvTop, SW_HIDE
				MoveWindow sbScrollBarvBottom, ScaleX(dwClientX - 17), ScaleY(7), ScaleX(17), ScaleY(dwClientY - 17 - 7), True
			#else
				gtk_widget_hide(scrollbarvTop)
				gtk_layout_move(GTK_LAYOUT(FHandle), scrollbarvBottom, dwClientX - verticalScrollBarWidth + iOffset, 7)
				gtk_widget_set_size_request(scrollbarvBottom, verticalScrollBarWidth, dwClientY - horizontalScrollBarHeight - 7)
			#endif
		Else
			If bDividedX Then SplittedVertically = False
			If Not bDividedY Then
				VScrollPosTop = VScrollPosBottom
			End If
			bDividedY = True
			If iDivideY <= 0 Then iDivideY = (dwClientY - 17) / 2: iDividedY = iDivideY
			#ifdef __USE_WINAPI__
				ShowWindow sbScrollBarvTop, SW_SHOW
				MoveWindow sbScrollBarvTop, ScaleX(dwClientX - 17), 0, ScaleX(17), ScaleY(iDivideY), True
				MoveWindow sbScrollBarvBottom, ScaleX(dwClientX - 17), ScaleY(iDivideY + 7), ScaleX(17), ScaleY(dwClientY - iDivideY - 7 - 17), True
			#else
				gtk_widget_show(scrollbarvTop)
				gtk_layout_move(GTK_LAYOUT(FHandle), scrollbarvTop, dwClientX - verticalScrollBarWidth + iOffset, 0)
				gtk_widget_set_size_request(scrollbarvTop, verticalScrollBarWidth, iDivideY)
				gtk_layout_move(GTK_LAYOUT(FHandle), scrollbarvBottom, dwClientX - verticalScrollBarWidth + iOffset, iDivideY + 7)
				gtk_widget_set_size_request(scrollbarvBottom, verticalScrollBarWidth, dwClientY - iDivideY - 7 - horizontalScrollBarHeight)
			#endif
		End If
		If OnSplitHorizontallyChange Then OnSplitHorizontallyChange(This, Value)
	End Property
	
	Property EditControl.TopLine As Integer
		If ActiveCodePane = 0 Then
			Return VScrollPosTop
		Else
			Return VScrollPosBottom
		End If
	End Property
	
	Property EditControl.TopLine(Value As Integer)
		Dim As Integer Ptr pVScrollPos
		If ActiveCodePane = 0 Then
			pVScrollPos = @VScrollPosTop
		Else
			pVScrollPos = @VScrollPosBottom
		End If
		*pVScrollPos = Min(GetCaretPosY(Value), Max(0, IIf(ActiveCodePane = 0, VScrollMaxTop, VScrollMaxBottom) - VisibleLinesCount(ActiveCodePane)))
		#ifdef __USE_GTK__
			If ActiveCodePane = 0 Then
				gtk_adjustment_set_value(adjustmentvTop, *pVScrollPos)
			Else
				gtk_adjustment_set_value(adjustmentvBottom, *pVScrollPos)
			End If
		#else
			si.cbSize = SizeOf (si)
			si.fMask = SIF_POS
			si.nPos = *pVScrollPos
			If ActiveCodePane = 0 Then
				SetScrollInfo(sbScrollBarvTop, SB_CTL, @si, True)
			Else
				SetScrollInfo(sbScrollBarvBottom, SB_CTL, @si, True)
			End If
		#endif
		PaintControl
	End Property
	
	Sub EditControl._LoadFromHistory(ByRef HistoryItem As EditControlHistory Ptr, bToBack As Boolean, ByRef oldItem As EditControlHistory Ptr, bWithoutPaint As Boolean = False)
		For i As Integer = Content.Lines.Count - 1 To 0 Step -1
			Delete_( Cast(EditControlLine Ptr, Content.Lines.Items[i]))
		Next i
		Content.Lines.Clear
		For i As Integer = 0 To HistoryItem->Lines.Count - 1
			FECLine = New_( EditControlLine)
			OlddwClientX = 0
			With *Cast(EditControlLine Ptr, HistoryItem->Lines.Item(i))
				WLet(FECLine->Text, * (.Text))
				FECLine->Breakpoint = .Breakpoint
				FECLine->Bookmark = .Bookmark
				FECLine->CommentIndex = .CommentIndex
				FECLine->ConstructionIndex = .ConstructionIndex
				FECLine->ConstructionPart = .ConstructionPart
				FECLine->ConstructionPartCount = .ConstructionPartCount
				FECLine->InAsm = .InAsm
				FECLine->InConstructionIndex = .InConstructionIndex
				FECLine->InConstructionPart = .InConstructionPart
				FECLine->InCondition = .InCondition
				FECLine->Collapsible = .Collapsible
				FECLine->Collapsed = .Collapsed
				FECLine->CollapsedFully = .CollapsedFully
				FECLine->LineContinues = .LineContinues
				FECLine->Visible = .Visible
				For ii As Integer = 0 To .Statements.Count - 1
					With *Cast(EditControlStatement Ptr, .Statements.Item(ii))
						FECStatement = New_( EditControlStatement)
						WLet(FECStatement->Text, * (.Text))
						FECStatement->ConstructionIndex = .ConstructionIndex
						FECStatement->ConstructionPart = .ConstructionPart
						FECStatement->ConstructionPartCount = .ConstructionPartCount
						FECStatement->InAsm = .InAsm
						FECStatement->InConstructionIndex = .InConstructionIndex
						FECStatement->InConstructionPart = .InConstructionPart
						If Cast(EditControlLine Ptr, HistoryItem->Lines.Item(i))->MainStatement = Cast(EditControlLine Ptr, HistoryItem->Lines.Item(i))->Statements.Item(ii) Then
							FECLine->MainStatement = FECStatement
						End If
						FECLine->Statements.Add FECStatement
					End With
				Next
			End With
			Content.Lines.Add FECLine
		Next i
		If Content.Lines.Count = 0 Then
			FECLine = New_( EditControlLine)
			OlddwClientX = 0
			WLet(FECLine->Text, "")
			Content.Lines.Add FECLine
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
			If Not bWithoutPaint Then ScrollToCaret
		End If
		OldnCaretPosX = nCaretPosX
		OldCharIndex = GetOldCharIndex
		If OnChange Then OnChange(This)
		Modified = True
	End Sub
	
	Sub EditControl._FillHistory(ByRef item As EditControlHistory Ptr, ByRef Comment As WString)
		WLet(item->Comment, Comment)
		Dim ecItem As EditControlLine Ptr
		For i As Integer = 0 To Content.Lines.Count - 1
			With *Cast(EditControlLine Ptr, Content.Lines.Items[i])
				FECLine = New_( EditControlLine)
				WLet(FECLine->Text, * (.Text))
				FECLine->Breakpoint = .Breakpoint
				FECLine->Bookmark = .Bookmark
				FECLine->CommentIndex = .CommentIndex
				FECLine->ConstructionIndex = .ConstructionIndex
				FECLine->ConstructionPart = .ConstructionPart
				FECLine->ConstructionPartCount = .ConstructionPartCount
				FECLine->InAsm = .InAsm
				FECLine->InConstructionIndex = .InConstructionIndex
				FECLine->InConstructionPart = .InConstructionPart
				FECLine->InCondition = .InCondition
				FECLine->Collapsed = .Collapsed
				FECLine->CollapsedFully = .CollapsedFully
				FECLine->Collapsible = .Collapsible
				FECLine->LineContinues = .LineContinues
				FECLine->Visible = .Visible
				For ii As Integer = 0 To .Statements.Count - 1
					With *Cast(EditControlStatement Ptr, .Statements.Item(ii))
						FECStatement = New_( EditControlStatement)
						WLet(FECStatement->Text, * (.Text))
						FECStatement->ConstructionIndex = .ConstructionIndex
						FECStatement->ConstructionPart = .ConstructionPart
						FECStatement->ConstructionPartCount = .ConstructionPartCount
						FECStatement->InAsm = .InAsm
						FECStatement->InConstructionIndex = .InConstructionIndex
						FECStatement->InConstructionPart = .InConstructionPart
						If Cast(EditControlLine Ptr, Content.Lines.Items[i])->MainStatement = Cast(EditControlLine Ptr, Content.Lines.Items[i])->Statements.Item(ii) Then
							FECLine->MainStatement = FECStatement
						End If
						FECLine->Statements.Add FECStatement
					End With
				Next
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
	
	Function TextWithoutQuotesAndComments(subject As String, OldCommentIndex As Integer = 0, WithoutComments As Boolean = True, WithoutBracket As Boolean = False, WithoutDoubleSpaces As Boolean = False) As String
		Dim As String Result, ch, sLine = subject
		Dim As Integer cc, iPos = -1
		Dim As Boolean q, c
		For i As Integer = 1 To OldCommentIndex
			iPos = InStr(iPos + 1, sLine, "'/")
		Next
		If iPos = 0 Then Return Space(Len(subject)) Else sLine = Space(iPos + 1) & Mid(sLine, iPos + 2)
		For i As Integer = 0 To Len(sLine)
			ch = Mid(sLine, i, 1)
			If Not c AndAlso ch = """" Then
				q = Not q
				Result += """"
			ElseIf Not q AndAlso ch = "/" AndAlso Mid(sLine, i + 1, 1) = "'" Then
				c = True
				cc += 1
				Result += " "
			ElseIf Not q AndAlso ch = "/" AndAlso Mid(sLine, i - 1, 1) = "'" Then
				cc -= 1
				If cc = 0 Then
					c = False
				ElseIf cc < 0 Then
					Result += Space(Len(subject) - i + 1)
					Exit For
				End If
				Result += " "
			ElseIf c OrElse q Then
				Result += " "
			ElseIf CInt(WithoutComments) AndAlso CInt(ch = "'" OrElse LCase(Mid(sLine, i, 4)) = "rem ") Then
				Result += Space(Len(subject) - i + 1)
				Exit For
			ElseIf WithoutBracket AndAlso ch = "(" Then
				Result += " "
			ElseIf ch = !"\t" Then
				Result += " "
			ElseIf WithoutDoubleSpaces AndAlso CBool(ch = " ") AndAlso EndsWith(Result, " ") Then
				Result += ""
			Else
				Result += ch
			End If
		Next
		Return Result
	End Function
	
	Function EditControlContent.GetConstruction(ByRef wLine As WString, ByRef iType As Integer = 0, OldCommentIndex As Integer = 0, InAsm As Boolean = False) As Integer
		On Error Goto ErrorHandler
		If Trim(wLine, Any !"\t ") = "" Then Return -1
		Dim As String sLine = wLine
		If InAsm AndAlso CBool(InStr(LCase(wLine), "asm") = 0) Then Return -1
		If CStyle Then Return -1
		If Trim(sLine, Any !"\t ") = "" Then Return -1
		'		iPos = -1
		'		For i As Integer = 1 To OldCommentIndex
		'			iPos = InStr(iPos + 1, sLine, "'/")
		'		Next
		'		If iPos = 0 Then Return -1 Else sLine = Mid(sLine, iPos + 2)
		'		iPos = InStr(sLine, "/'")
		sLine = TextWithoutQuotesAndComments(sLine, OldCommentIndex, False, True, True)
		iPos = InStr(sLine, "'")
		If iPos = 0 Then iPos = Len(sLine) Else iPos -= 1
		For i As Integer = 0 To UBound(Constructions)
			With Constructions(i)
				If CInt(CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name0 & " "))) OrElse _
					CInt(CInt(CInt(.Name01 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name01 & " "))) OrElse _
					CInt(.Name02 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name02 & " "))) OrElse _
					CInt(.Name03 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name03 & " "))) OrElse _
					CInt(.Name04 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name04 & " "))) OrElse _
					CInt(.Name05 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name05 & " "))) OrElse _
					CInt(.Name06 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name06 & " "))) OrElse _
					CInt(.Name07 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name07 & " "))) OrElse _
					CInt(.Name08 <> "" AndAlso StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(.Name08 & " ")))))) AndAlso _
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
		Var Slash_ = Asc("/"), Apostrophe = Asc("'"), Quotes = Asc("""")
		Do While j <= l
			If iC = 0 AndAlso Value[j - 1] = Quotes Then
				bQ = Not bQ
			ElseIf Not bQ Then
				If Value[j - 1] = Slash_ AndAlso Value[j] = Apostrophe Then
					iC = iC + 1
					j = j + 1
				ElseIf iC > 0 AndAlso Value[j - 1] = Apostrophe AndAlso Value[j] = Slash_ Then
					iC = iC - 1
					j = j + 1
				ElseIf iC = 0 AndAlso Value[j - 1] = Apostrophe Then
					Exit Do
				End If
			End If
			j = j + 1
		Loop
		Return iC
	End Function
	
	Sub EditControl.ChangeCollapseState(LineIndex As Integer, Value As Boolean)
		If LineIndex < 0 OrElse LineIndex > Content.Lines.Count - 1 Then Exit Sub
		Dim As Integer j, Idx
		Dim FECLine As EditControlLine Ptr = Content.Lines.Items[LineIndex]
		Dim As EditControlLine Ptr FECLine2
		Dim As EditControlStatement Ptr FECStatement
		OlddwClientX = 0
		FECLine->Collapsed = Value
		If FECLine->Collapsed Then
			FECLine->CollapsedFully = True
			If Not EndsWith(*FECLine->Text, "'...'") Then
				WLetEx(FECLine->Text, *FECLine->Text & " '...'", True)
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
			End If
			For i As Integer = LineIndex To Content.Lines.Count - 1
				FECLine2 = Content.Lines.Items[i]
				If i > LineIndex Then FECLine2->Visible = False
				For iii As Integer = IIf(i = LineIndex, FECLine->Statements.IndexOf(FECLine->MainStatement) + 1, 0) To FECLine2->Statements.Count - 1
					FECStatement = FECLine2->Statements.Item(iii)
					If FECStatement->ConstructionIndex = FECLine->ConstructionIndex OrElse (FECLine->ConstructionPart = 1 AndAlso FECLine->ConstructionIndex = C_Class AndAlso FECStatement->ConstructionIndex = C_Type) Then
						If FECStatement->ConstructionPart = 2 Then
							j -= 1 - FECStatement->ConstructionPartCount
							If j = -1 Then
								If (FECLine->ConstructionPart = 1) OrElse FECLine2->Collapsible Then
									If FECLine2->Statements.IndexOf(FECLine2->MainStatement) > iii Then FECLine->CollapsedFully = False
									FECLine2->Visible = True
								End If
								Exit For, For
							End If
						ElseIf FECStatement->ConstructionPart = 0 Then
							j += 1
						ElseIf FECStatement->ConstructionPart = 1 Then
							j -= FECStatement->ConstructionPartCount
							If FECLine->ConstructionPart = 1 Then
								If j = 0 Then
									FECLine2->Visible = True
									Exit For, For
								End If
							End If
						End If
					End If
				Next iii
			Next i
		Else
			If EndsWith(*FECLine->Text, "'...'") Then
				FECLine->CollapsedFully = False
				WLetEx(FECLine->Text, RTrim(.Left(*FECLine->Text, Len(*FECLine->Text) - 5)), True)
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
			End If
			Dim As EditControlLine Ptr OldCollapsed
			Dim As Boolean bSetVisible
			For i As Integer = LineIndex + 1 To Content.Lines.Count - 1
				FECLine2 = Content.Lines.Items[i]
				If FECLine2->Visible Then Exit For
				FECLine2->Visible = True
				If CInt(OldCollapsed = 0) AndAlso CInt(FECLine2->Collapsed) Then
					OldCollapsed = FECLine2
					j = 0
				ElseIf OldCollapsed <> 0 Then
					bSetVisible = True
					If FECLine2->ConstructionIndex = OldCollapsed->ConstructionIndex OrElse (OldCollapsed->ConstructionPart = 1 AndAlso OldCollapsed->ConstructionIndex = C_Class AndAlso FECLine2->ConstructionIndex = C_Type) Then
						If FECLine2->ConstructionPart = 2 Then
							j -= 1
							If j = -1 Then
								If OldCollapsed->ConstructionPart = 1 Then bSetVisible = False
								OldCollapsed = 0
							End If
						ElseIf FECLine2->ConstructionPart = 0 Then
							j += 1
						ElseIf FECLine2->ConstructionPart = 1 Then
							If j = 0 Then
								bSetVisible = False
								If FECLine2->Collapsed Then
									OldCollapsed = FECLine2
								Else
									OldCollapsed = 0
								End If
							End If
						End If
					End If
					If bSetVisible Then FECLine2->Visible = False
				End If
				If FECLine2->Visible Then
					'					Idx = VisibleLines.IndexOf(FECLine2)
					'					If Idx = -1 Then VisibleLines.Insert VisibleLines.IndexOf(FECLine) + 1, FECLine2
					FECLine = FECLine2
				End If
			Next i
		End If
	End Sub
	
	Sub EditControl.ChangeInConstruction(LineIndex As Integer, OldConstructionIndex As Integer, OldConstructionPart As Integer)
		'		If LineIndex < 0 OrElse LineIndex > Content.Lines.Count - 1 Then Exit Sub
		'		Dim As Integer j, Idx
		'		Dim FECLine As EditControlLine Ptr = Content.Lines.Items[LineIndex]
		'		Dim As EditControlLine Ptr FECLine2
		'		If FECLine->Construction Then
		'			If Not EndsWith(*FECLine->Text, "'...'") Then
		'				WLetEx(FECLine->Text, *FECLine->Text & " '...'", True)
		'			End If
		'			For i As Integer = LineIndex + 1 To Content.Lines.Count - 1
		'				FECLine2 = Content.Lines.Items[i]
		'				FECLine2->Visible = False
		''				Idx = VisibleLines.IndexOf(FECLine2)
		''				If Idx > -1 Then VisibleLines.Remove Idx
		'				If FECLine2->ConstructionIndex = FECLine->ConstructionIndex Then
		'					If FECLine2->ConstructionPart = 2 Then
		'						j -= 1
		'						If j = -1 Then
		'							Exit For
		'						End If
		'					ElseIf FECLine2->ConstructionPart = 0 Then
		'						j += 1
		'					End If
		'				End If
		'			Next i
		'		Else
		'			If EndsWith(*FECLine->Text, "'...'") Then
		'				WLetEx(FECLine->Text, RTrim(.Left(*FECLine->Text, Len(*FECLine->Text) - 5)), True)
		'			End If
		'			Dim As EditControlLine Ptr OldCollapsed
		'			For i As Integer = LineIndex + 1 To Content.Lines.Count - 1
		'				FECLine2 = Content.Lines.Items[i]
		'				If FECLine2->Visible Then Exit For
		'				FECLine2->Visible = True
		'				If CInt(OldCollapsed = 0) AndAlso CInt(FECLine2->Collapsed) Then
		'					OldCollapsed = FECLine2
		'					j = 0
		'				ElseIf OldCollapsed <> 0 Then
		'					If FECLine2->ConstructionIndex = OldCollapsed->ConstructionIndex Then
		'						If FECLine2->ConstructionPart = 2 Then
		'							j -= 1
		'							If j = -1 Then
		'								OldCollapsed = 0
		'							End If
		'						ElseIf FECLine2->ConstructionPart = 0 Then
		'							j += 1
		'						End If
		'					End If
		'					FECLine2->Visible = False
		'				End If
		'				If FECLine2->Visible Then
		''					Idx = VisibleLines.IndexOf(FECLine2)
		''					If Idx = -1 Then VisibleLines.Insert VisibleLines.IndexOf(FECLine) + 1, FECLine2
		'					FECLine = FECLine2
		'				End If
		'			Next i
		'		End If
	End Sub
	
	Sub EditControl.CollapseAll
		For i As Integer = 0 To Content.Lines.Count - 1
			With *Cast(EditControlLine Ptr, Content.Lines.Items[i])
				If .Collapsible AndAlso Not .Collapsed Then ChangeCollapseState i, True
			End With
		Next
		PaintControl
	End Sub
	
	Sub EditControl.UnCollapseAll
		For i As Integer = 0 To Content.Lines.Count - 1
			With *Cast(EditControlLine Ptr, Content.Lines.Items[i])
				If .Collapsible AndAlso .Collapsed Then ChangeCollapseState i, False
			End With
		Next
		PaintControl
	End Sub
	
	Sub EditControl.CollapseAllProcedures
		For i As Integer = 0 To Content.Lines.Count - 1
			With *Cast(EditControlLine Ptr, Content.Lines.Items[i])
				If .Collapsible AndAlso CBool(.ConstructionIndex >= C_P_Region) AndAlso Not .Collapsed Then ChangeCollapseState i, True
			End With
		Next
		PaintControl
	End Sub
	
	Sub EditControl.UnCollapseAllProcedures
		For i As Integer = 0 To Content.Lines.Count - 1
			With *Cast(EditControlLine Ptr, Content.Lines.Items[i])
				If .Collapsible AndAlso CBool(.ConstructionIndex >= C_P_Region) AndAlso .Collapsed Then ChangeCollapseState i, False
			End With
		Next
		PaintControl
	End Sub
	
	Sub EditControl.CollapseCurrent
		With *Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])
			If .Collapsible AndAlso Not .Collapsed Then ChangeCollapseState FSelEndLine, True
		End With
		PaintControl
	End Sub
	
	Sub EditControl.UnCollapseCurrent
		With *Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])
			If .Collapsible AndAlso .Collapsed Then ChangeCollapseState FSelEndLine, False
		End With
		PaintControl
	End Sub
	
	Sub EditControlContent.ChangeCollapsibility(LineIndex As Integer, ByRef LineText As UString = "", EC As Any Ptr = 0)
		Dim As EditControlLine Ptr ecl = Lines.Items[LineIndex], eclOld, eclOld_
		Dim As Integer i, j, OldLineIndex = LineIndex - 1
		If OldLineIndex > -1 Then
			eclOld = Lines.Items[OldLineIndex]
		End If
		If ecl = 0 OrElse ecl->Text = 0 Then Exit Sub
		For ii As Integer = ecl->Statements.Count - 1 To 0 Step -1
			Delete_(Cast(EditControlStatement Ptr, ecl->Statements.Item(ii)))
		Next
		ecl->Statements.Clear
		Dim As UString LineText_
		'If LineText <> "" Then
		'	LineText_ = LineText
		'Else
			LineText_ = TextWithoutQuotesAndComments(*ecl->Text, IIf(eclOld = 0, 0, eclOld->CommentIndex))
		'End If
		Dim As Boolean Collapsible
		Dim As List Statements
		Dim As UString res()
		Split(LineText_, ":", res())
		Dim As EditControlStatement Ptr ecs, ecs_, ecsOld_
		For ii As Integer = 0 To UBound(res)
			ecs = New_(EditControlStatement)
			WLet(ecs->Text, res(ii))
			ecl->Statements.Add ecs
			LineText_ = *ecs->Text
			If ii = 0 Then
				ecsOld_ = 0
				If eclOld > 0 AndAlso eclOld->Statements.Count > 0 Then
					ecsOld_ = eclOld->Statements.Item(eclOld->Statements.Count - 1)
				End If
				If (ecsOld_ > 0) AndAlso EndsWith(Trim(*ecsOld_->Text), " _") Then
					Dim iii As Integer
					For iii = LineIndex - 1 To 0 Step -1
						eclOld_ = Lines.Items[iii]
						For iiii As Integer = eclOld_->Statements.Count - 1 To 0 Step -1
							ecs_ = eclOld_->Statements.Items[iiii]
							If Not EndsWith(Trim(*ecs_->Text), " _") Then
								Exit For, For
							End If
							LineText_ = ..Left(Trim(*ecs_->Text), Len(Trim(*ecs_->Text)) - 1) & LineText_
							ecsOld_ = ecs_
						Next iiii
					Next
					i = GetConstruction(LineText_, j, 0, ecsOld_->InAsm)
					If ecsOld_->ConstructionIndex <> i OrElse ecsOld_->ConstructionPart <> j Then
						ecsOld_->ConstructionIndex = i
						ecsOld_->ConstructionPart = j
						If EC Then
							 Cast(EditControl Ptr, EC)->ChangeCollapsibility iii + 1, LineText_
						Else
							ChangeCollapsibility iii + 1, LineText_
						End If
					End If
					LineText_ = ""
					ecs->ConstructionIndex = -1
					ecs->ConstructionPart = -1
					Continue For
				End If
			End If
			If (LineText_ <> "") AndAlso EndsWith(Trim(LineText_), " _") AndAlso (ii = UBound(res)) Then
				For iii As Integer = LineIndex + 1 To Lines.Count - 1
					eclOld_ = Lines.Items[iii]
					For iiii As Integer = 0 To eclOld_->Statements.Count - 1
						ecs_ = eclOld_->Statements.Items[iiii]
						LineText_ = ..Left(LineText_, Len(LineText_) - IIf(EndsWith(Trim(LineText_), " _"), 1, 0)) & Trim(*ecs_->Text)
						If Not EndsWith(Trim(*ecs_->Text), " _") Then
							Exit For, For
						End If
					Next iiii
				Next
			End If
			If StartsWith(Trim(LCase(*ecl->Text), Any !"\t "), "'#region") Then
				i = C_P_Region
				j = 0
			ElseIf StartsWith(Trim(LCase(*ecl->Text), Any !"\t "), "'#end region") Then
				i = C_P_Region
				j = 2
			Else
				i = GetConstruction(LineText_, j, IIf(eclOld = 0, 0, eclOld->CommentIndex), ecl->InAsm)
			End If
			ecs->ConstructionIndex = i
			ecs->ConstructionPart = j
			If i > -1 Then
				If j = 0 OrElse j = 1 Then
					Statements.Add ecs
				Else
					Dim bFind As Boolean
					For iii As Integer = Statements.Count - 1 To 0 Step -1
						ecsOld_ = Statements.Items[iii]
						If ecsOld_->ConstructionPart = 1 Then
							Statements.Remove iii
						ElseIf ecsOld_->ConstructionPart = 0 Then
							bFind = True
							Statements.Remove iii
							Exit For
						End If
					Next
					If Not bFind Then
						Statements.Add ecs
					End If
				End If
			End If
		Next
		'i = Content.GetConstruction(*ecl->Text, j, IIf(eclOld = 0, 0, eclOld->CommentIndex), ecl->InAsm)
		ecl->MainStatement = 0
		For iii As Integer = 0 To Statements.Count - 1
			ecsOld_ = Statements.Items[iii]
			If ecsOld_->ConstructionPart = 0 OrElse ecsOld_->ConstructionPart = 1 Then
				ecl->MainStatement = ecsOld_
				Exit For
			Else
				ecl->MainStatement = ecsOld_
			End If
		Next
		If ecl->MainStatement = 0 Then ecl->MainStatement = ecl->Statements.Items[0]
		i = ecl->MainStatement->ConstructionIndex
		j = ecl->MainStatement->ConstructionPart
		ecl->ConstructionIndex = i
		ecl->ConstructionPart = j
	End Sub
	
	Sub EditControl.ChangeCollapsibility(LineIndex As Integer, ByRef LineText As UString = "")
		Dim As Integer i, j, k, Idx
		Dim OldCollapsed As Boolean, OldConstructionIndex As Integer = -1, OldConstructionPart As Integer = 0, OldLineIndex As Integer = LineIndex - 1
		If LineIndex < 0 OrElse LineIndex > Content.Lines.Count - 1 Then Exit Sub
		Dim As EditControlLine Ptr ecl = Content.Lines.Items[LineIndex], eclOld, eclOld_
		If OldLineIndex > -1 Then
			eclOld = Content.Lines.Items[OldLineIndex]
		End If
		If ecl = 0 OrElse ecl->Text = 0 Then Exit Sub
		OldConstructionIndex = ecl->ConstructionIndex
		OldConstructionPart = ecl->ConstructionPart
		'For ii As Integer = ecl->Statements.Count - 1 To 0 Step -1
		'	Delete_(Cast(EditControlStatement Ptr, ecl->Statements.Item(ii)))
		'Next
		'ecl->Statements.Clear
		'Dim As UString LineText_
		''If LineText <> "" Then
		''	LineText_ = LineText
		''Else
		'	LineText_ = TextWithoutQuotesAndComments(*ecl->Text, IIf(eclOld = 0, 0, eclOld->CommentIndex))
		''End If
		'Dim As Boolean Collapsible
		'Dim As List Statements
		'Dim As UString res()
		'Split(LineText_, ":", res())
		'Dim As EditControlStatement Ptr ecs, ecs_, ecsOld_
		'For ii As Integer = 0 To UBound(res)
		'	ecs = New_(EditControlStatement)
		'	WLet(ecs->Text, res(ii))
		'	ecl->Statements.Add ecs
		'	LineText_ = *ecs->Text
		'	If ii = 0 Then
		'		ecsOld_ = 0
		'		If eclOld > 0 AndAlso eclOld->Statements.Count > 0 Then
		'			ecsOld_ = eclOld->Statements.Item(eclOld->Statements.Count - 1)
		'		End If
		'		If (ecsOld_ > 0) AndAlso EndsWith(Trim(*ecsOld_->Text), " _") Then
		'			Dim iii As Integer
		'			For iii = LineIndex - 1 To 0 Step -1
		'				eclOld_ = Content.Lines.Items[iii]
		'				For iiii As Integer = eclOld_->Statements.Count - 1 To 0 Step -1
		'					ecs_ = eclOld_->Statements.Items[iiii]
		'					If Not EndsWith(Trim(*ecs_->Text), " _") Then
		'						Exit For, For
		'					End If
		'					LineText_ = ..Left(Trim(*ecs_->Text), Len(Trim(*ecs_->Text)) - 1) & LineText_
		'					ecsOld_ = ecs_
		'				Next iiii
		'			Next
		'			i = Content.GetConstruction(LineText_, j, 0, ecsOld_->InAsm)
		'			If ecsOld_->ConstructionIndex <> i OrElse ecsOld_->ConstructionPart <> j Then
		'				ecsOld_->ConstructionIndex = i
		'				ecsOld_->ConstructionPart = j
		'				ChangeCollapsibility iii + 1, LineText_
		'			End If
		'			LineText_ = ""
		'			ecs->ConstructionIndex = -1
		'			ecs->ConstructionPart = -1
		'			Continue For
		'		End If
		'	End If
		'	If (LineText_ <> "") AndAlso EndsWith(Trim(LineText_), " _") AndAlso (ii = UBound(res)) Then
		'		For iii As Integer = LineIndex + 1 To Content.Lines.Count - 1
		'			eclOld_ = Content.Lines.Items[iii]
		'			For iiii As Integer = 0 To eclOld_->Statements.Count - 1
		'				ecs_ = eclOld_->Statements.Items[iiii]
		'				LineText_ = ..Left(LineText_, Len(LineText_) - IIf(EndsWith(Trim(LineText_), " _"), 1, 0)) & Trim(*ecs_->Text)
		'				If Not EndsWith(Trim(*ecs_->Text), " _") Then
		'					Exit For, For
		'				End If
		'			Next iiii
		'		Next
		'	End If
		'	If StartsWith(Trim(LCase(*ecl->Text), Any !"\t "), "'#region") Then
		'		i = C_P_Region
		'		j = 0
		'	ElseIf StartsWith(Trim(LCase(*ecl->Text), Any !"\t "), "'#end region") Then
		'		i = C_P_Region
		'		j = 2
		'	Else
		'		i = Content.GetConstruction(LineText_, j, IIf(eclOld = 0, 0, eclOld->CommentIndex), ecl->InAsm)
		'	End If
		'	ecs->ConstructionIndex = i
		'	ecs->ConstructionPart = j
		'	If i > -1 Then
		'		If j = 0 OrElse j = 1 Then
		'			Statements.Add ecs
		'		Else
		'			Dim bFind As Boolean
		'			For iii As Integer = Statements.Count - 1 To 0 Step -1
		'				ecsOld_ = Statements.Items[iii]
		'				If ecsOld_->ConstructionPart = 1 Then
		'					Statements.Remove iii
		'				ElseIf ecsOld_->ConstructionPart = 0 Then
		'					bFind = True
		'					Statements.Remove iii
		'					Exit For
		'				End If
		'			Next
		'			If Not bFind Then
		'				Statements.Add ecs
		'			End If
		'		End If
		'	End If
		'Next
		''i = Content.GetConstruction(*ecl->Text, j, IIf(eclOld = 0, 0, eclOld->CommentIndex), ecl->InAsm)
		'ecl->MainStatement = 0
		'For iii As Integer = 0 To Statements.Count - 1
		'	ecsOld_ = Statements.Items[iii]
		'	If ecsOld_->ConstructionPart = 0 OrElse ecsOld_->ConstructionPart = 1 Then
		'		ecl->MainStatement = ecsOld_
		'		Exit For
		'	Else
		'		ecl->MainStatement = ecsOld_
		'	End If
		'Next
		'If ecl->MainStatement = 0 Then ecl->MainStatement = ecl->Statements.Items[0]
		Content.ChangeCollapsibility LineIndex, LineText, @This
		i = ecl->MainStatement->ConstructionIndex
		j = ecl->MainStatement->ConstructionPart
		ecl->ConstructionIndex = i
		ecl->ConstructionPart = j
		ecl->Ends.Clear
		ecl->EndsCompleted = False
		OldCollapsed = ecl->Collapsed
		If i > -1 And (j = 0 OrElse j = 1) Then
			ecl->Collapsible = Constructions(i).Collapsible
			If EndsWith(*ecl->Text, "'...'") Then
				ecl->Collapsed = ecl->Collapsible
				ecl->CollapsedFully = ecl->Collapsible
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
		If OldConstructionIndex <> ecl->ConstructionIndex OrElse OldConstructionPart <> ecl->ConstructionPart Then
			ChangeInConstruction LineIndex, OldConstructionIndex, OldConstructionPart
		End If
		If OldLineIndex > -1 Then
			Dim As EditControlLine Ptr FECLine2
			If Not eclOld->Visible Then
				k = GetLineIndex(OldLineIndex, 0)
				Dim FECLine As EditControlLine Ptr = Content.Lines.Items[k]
				j = 0
				Var OldVisibleLineIndex = k
				For k = OldVisibleLineIndex To OldLineIndex + 1
				'For k = k + 1 To OldLineIndex
					FECLine2 = Content.Lines.Items[k]
					For iii As Integer = IIf(k = OldVisibleLineIndex, FECLine->Statements.IndexOf(FECLine->MainStatement) + 1, 0) To IIf(k = OldLineIndex + 1, ecl->Statements.IndexOf(ecl->MainStatement), FECLine2->Statements.Count - 1)
						FECStatement = FECLine2->Statements.Item(iii)
						If FECStatement->ConstructionIndex = FECLine->ConstructionIndex OrElse (FECLine->ConstructionPart = 1 AndAlso FECLine->ConstructionIndex = C_Class AndAlso FECStatement->ConstructionIndex = C_Type) Then
							If FECStatement->ConstructionPart = 2 Then
								j -= 1 - FECStatement->ConstructionPartCount
								If j = -1 Then
									If (FECLine->ConstructionPart = 1) OrElse FECLine2->Collapsible Then
										If FECLine2->Statements.IndexOf(FECLine2->MainStatement) > iii Then FECLine->CollapsedFully = False
										j = -1
									ElseIf (k = OldLineIndex + 1) AndAlso (iii = ecl->Statements.IndexOf(ecl->MainStatement)) Then
										j = 0
									End If
									Exit For, For
								End If
							ElseIf FECStatement->ConstructionPart = 0 Then
								j += 1
							ElseIf FECStatement->ConstructionPart = 1 Then
								j -= FECStatement->ConstructionPartCount
								If FECLine->ConstructionPart = 1 Then
									If j = 0 Then
										j = -1
										Exit For, For
									End If
								End If
							End If
						End If
					Next
				Next
				ecl->Visible = j = -1
				'If ecl->Visible AndAlso ecl->Collapsible AndAlso CBool(ecl = FECLine2) Then FECLine->CollapsedFully = False
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
		Var LengthEndLine = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
		FSelEndChar += CharTo
		If FSelEndChar < 0 Then
			If FSelEndLine > 0 Then
				FSelEndLine = GetLineIndex(FSelEndLine, -1)
				FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
			Else
				FSelEndChar = 0
			End If
		ElseIf FSelEndChar > LengthEndLine Then
			If FSelEndLine < GetLineIndex(Content.Lines.Count - 1) Then
				FSelEndLine = GetLineIndex(FSelEndLine, +1)
				FSelEndChar = 0
			Else
				FSelEndChar = LengthEndLine
			End If
		End If
	End Sub
	
	Sub EditControl.GetSelection(ByRef iSelStartLine As Integer, ByRef iSelEndLine As Integer, ByRef iSelStartChar As Integer, ByRef iSelEndChar As Integer, iCurrProcedure As Boolean = False)
		If FSelStartLine < 0 OrElse Content.Lines.Count<1 OrElse FSelStartLine>Content.Lines.Count - 1 Then Exit Sub
		If iCurrProcedure  Then ' For get the top line and bottom line of tne current procedure
			Dim As Integer lLineCount
			iSelStartLine = 0
			For lLineCount = FSelStartLine To 1 Step -1
				FECLine = Content.Lines.Items[lLineCount]
				If FECLine->ConstructionIndex >= C_Sub Then
					If FECLine->ConstructionPart = 0 Then
						iSelStartLine = lLineCount
						Exit For
					End If
				End If
			Next
			
			iSelEndLine = Content.Lines.Count - 1
			For lLineCount = FSelStartLine To Content.Lines.Count - 1
				FECLine = Content.Lines.Items[lLineCount]
				If FECLine->ConstructionIndex >= C_Sub Then
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
		If FSelEndLine >= 0 AndAlso FSelEndLine <= Content.Lines.Count - 1 Then
			Return Len(GetTabbedText(.Left(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text, FSelEndChar)))
		Else
			Return FSelEndChar
		End If
	End Function
	
	Function EditControl.GetCharIndexFromOld() As Integer
		If FSelEndLine >= 0 AndAlso FSelEndLine <= Content.Lines.Count - 1 Then
			WLet(FLine, *Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
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
		FSelStartLine = Min(Content.Lines.Count - 1, Max(0, iSelStartLine))
		FSelEndLine = Min(Content.Lines.Count - 1, Max(0, iSelEndLine))
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
		ChangingStarted = True
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
		OldLinesCount = LinesCount
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
		If OldLinesCount <> LinesCount Then
			If OnLineChange Then OnLineChange(This, FSelEndLine, IIf(Abs(LinesCount - OldLinesCount) = 1, OldLine, -1))
		End If
		#ifdef __USE_GTK__
			If widget AndAlso cr Then
		#else
			If Handle Then
		#endif
			ScrollToCaret
		End If
		ChangingStarted = False
	End Sub
	
	Sub EditControl.ChangeText(ByRef Value As WString, CharTo As Integer = 0, ByRef Comment As WString = "", SelStartLine As Integer = -1, SelStartChar As Integer = -1)
		Changing Comment
		ChangePos CharTo
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As EditControlLine Ptr ecStartLine = Content.Lines.Item(iSelStartLine), ecEndLine = Content.Lines.Item(iSelEndLine), ecOldLine, ecRemovingLine
		FECLine = ecStartLine
		'If iSelStartLine <> iSelEndLine Or iSelStartChar <> iSelEndChar Then AddHistory
		WLet(FLine, Mid(*ecEndLine->Text, iSelEndChar + 1))
		WLet(FECLine->Text, .Left(*ecStartLine->Text, iSelStartChar))
		Var iC = 0, OldiC = ecEndLine->CommentIndex, OldPreviC = 0, PreviC = 0, InAsm = False, OldInAsm = ecEndLine->InAsm, Pos1 = 0, p = 1, c = 0, l = 0
		If iSelEndLine > 0 Then ecOldLine = Content.Lines.Item(iSelEndLine - 1): PreviC = ecOldLine->CommentIndex: OldPreviC = PreviC: InAsm = ecOldLine->InAsm
		For i As Integer = iSelEndLine To iSelStartLine + 1 Step -1
			ecRemovingLine = Content.Lines.Items[i]
			If OnLineRemoving Then OnLineRemoving(This, i)
			Content.Lines.Remove i
			If OnLineRemoved Then OnLineRemoved(This, i)
			Delete_(ecRemovingLine)
			OlddwClientX = 0
		Next i
		If iSelStartLine > 0 Then iC = Cast(EditControlLine Ptr, Content.Lines.Item(iSelStartLine - 1))->CommentIndex
		Do
			Pos1 = InStr(p, Value, Chr(13))
			c = c + 1
			If Pos1 = 0 Then
				l = Len(Value) - p + 1
			Else
				l = Pos1 - p
			End If
			FECLine->InAsm = InAsm
			If c = 1 Then
				WLet(FECLine->Text, *FECLine->Text & Mid(Value, p, l))
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
				ChangeCollapsibility iSelStartLine
			Else
				FECLine = New_( EditControlLine)
				WLet(FECLine->Text, Mid(Value, p, l))
				OlddwClientX = 0
				'ecItem->CharIndex = p - 1
				'ecItem->LineIndex = c - 1
			End If
			'item->Length = Len(*item->Text)
			iC = FindCommentIndex(*FECLine->Text, PreviC)
			FECLine->CommentIndex = iC
			FECLine->InAsm = InAsm
			If c > 1 Then
				If OnLineAdding Then OnLineAdding(This, iSelStartLine + c - 1)
				Content.Lines.Insert iSelStartLine + c - 1, FECLine
				If OnLineAdded Then OnLineAdded(This, iSelStartLine + c - 1)
				ChangeCollapsibility iSelStartLine + c - 1
			End If
			If FECLine->ConstructionIndex = C_Asm Then
				InAsm = FECLine->ConstructionPart = 0
			End If
			FECLine->InAsm = InAsm
			p = Pos1 + 1
			PreviC = iC
		Loop While Pos1 > 0
		FSelStartLine = iSelStartLine + c - 1
		FSelStartChar = Len(*FECLine->Text)
		WLet(Cast(EditControlLine Ptr, Content.Lines.Item(FSelStartLine))->Text, *FECLine->Text & *FLine)
		ChangeCollapsibility FSelStartLine
		'item->Length = Len(*item->Text)
		'p = item->CharIndex + item->Length + 1
		If OldiC <> iC Then
			iC = OldPreviC
			For i As Integer = iSelStartLine To Content.Lines.Count - 1 ' + 1
				FECLine = Cast(EditControlLine Ptr, Content.Lines.Item(i))
				'Item->CharIndex = p - 1
				'Item->LineIndex = i
				iC = FindCommentIndex(*FECLine->Text, iC)
				FECLine->CommentIndex = iC
				'p = p + ecItem->Length
			Next i
		End If
		If OldInAsm <> InAsm Then
			For i As Integer = iSelStartLine To Content.Lines.Count - 1
				FECLine = Cast(EditControlLine Ptr, Content.Lines.Item(i))
				If FECLine->ConstructionIndex = C_Asm Then
					InAsm = FECLine->ConstructionPart = 0
				End If
				FECLine->InAsm = InAsm
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
		FSelEndLine = Content.Lines.Count - 1
		FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
		ShowCaretPos True
	End Sub
	
	Sub EditControl.CutCurrentLineToClipboard
		If FSelEndLine = Content.Lines.Count - 1 AndAlso Lines(FSelEndLine) = "" Then Exit Sub
		CopyCurrentLineToClipboard
		Changing "Current line was cut"
		If FSelEndLine = Content.Lines.Count - 1 Then ReplaceLine FSelEndLine, "" Else DeleteLine
		Changed "Current line was cut"
	End Sub
	
	Sub EditControl.CutToClipboard
		CopyToClipboard
		ChangeText "", 0, "Belgilangan matn qirqib olindi"
	End Sub
	
	Sub EditControl.CopyCurrentLineToClipboard
		pClipboard->SetAsText Lines(FSelEndLine) & Chr(13, 10)
	End Sub
	
	Sub EditControl.CopyToClipboard
		pClipboard->SetAsText SelText
	End Sub
	
	Sub EditControl.PasteFromClipboard
		Dim Value As WString Ptr
		WLet(Value, pClipboard->GetAsText)
		If Value Then
			WLetEx Value, Replace(*Value, Chr(13) & Chr(10), Chr(13)), True
			WLetEx Value, Replace(*Value, Chr(10), Chr(13)), True
			ChangeText *Value, 0, "Xotiradan qo`yildi"
			WDeAllocate(Value)
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
		If Content.Lines.Count = 0 Then
			FECLine = New_( EditControlLine)
			OlddwClientX = 0
			WLet(FECLine->Text, "")
			Content.Lines.Add(FECLine)
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
		FText = ""
		For i As Integer = 0 To Content.Lines.Count - 1
			If i <> Content.Lines.Count - 1 Then
				WAdd FText.vptr, Lines(i) + Chr(13) + Chr(10)
			Else
				WAdd FText.vptr, Lines(i)
			End If
		Next i
		Return *FText.vptr
	End Property
	
	Property EditControl.Text(ByRef Value As WString)
		FText = ""
		For i As Integer = Content.Lines.Count - 1 To 0 Step -1
			Delete_( Cast(EditControlLine Ptr, Content.Lines.Items[i]))
		Next i
		Content.Lines.Clear
		Dim j As Integer
		For i As Integer = 0 To Len(Value)
			WAdd FText.vptr, WChr(Value[i])
			If Value[i] = 10 Or Value[i] = 0 Then
				InsertLine(j, Trim(Mid(*FText.vptr, 1, Len(*FText.vptr) - 1), Any WChr(13)))
				j = j + 1
				FText = ""
			End If
		Next i
	End Property
	
	Property EditControl.HintDropDown ByRef As WString
		Return WGet(FHintDropDown)
	End Property
	
	Property EditControl.HintDropDown(ByRef Value As WString)
		WLet(FHintDropDown, Value)
		
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
	
	Sub EditControl.CalculateLeftMargin
		LeftMargin = Len(Str(LinesCount)) * dwCharX + dwCharY + 30 '5 * dwCharX
	End Sub
	
	Sub EditControl.LoadFromFile(ByRef FileName As WString, ByRef FileEncoding As FileEncodings, ByRef NewLineType As NewLineTypes, WithoutScroll As Boolean = False)
		Dim As WString Ptr pBuff
		Dim As String Buff, EncodingStr, NewLineStr
		Dim As WString Ptr BuffRead
		Dim As Integer Result = -1, Fn, FileSize
		Dim As FileEncodings OldFileEncoding
		Dim As Integer iC = 0, OldiC = 0, i = 0
		Dim As Boolean InAsm = False, FileLoaded
		'check the Newlinetype again for missing Cr in AsicII file
		Fn = FreeFile_
		If Not FileExists(FileName) Then
			MsgBox ML("File not found") & ": " & FileName
			Exit Sub
		End If
		#ifdef __USE_WINAPI__
			Buff = FileName
			If Buff <> FileName Then
				FileLoaded = True
				Dim As .HANDLE hFile
				Dim As DWORD dwBytesToRead, dwBytesRead
				Dim As String sFileContents
				Dim As WString Ptr wsFileContents
				Dim As Integer BOMSymbolsCount
				hFile = CreateFile(@FileName, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
				If hFile = INVALID_HANDLE_VALUE Then
					MsgBox ML("Open file failure!") &  " " & ML("in function") & " EditControl.LoadFromFile" & Chr(13, 10) & " " & FileName
				Else
					dwBytesToRead = GetFileSize(hFile, 0)
					If dwBytesToRead <> 0 Then
						sFileContents = Space(dwBytesToRead)
						ReadFile(hFile, @sFileContents[0], dwBytesToRead, @dwBytesRead, 0)
						Buff = .Left(sFileContents, 4)
						If Buff[0] = &HFF AndAlso Buff[1] = &HFE AndAlso Buff[2] = 0 AndAlso Buff[3] = 0 Then 'Little Endian
							FileEncoding = FileEncodings.Utf32BOM
							BOMSymbolsCount = 4
						ElseIf Buff[0] = 0 AndAlso Buff[1] = 0 AndAlso Buff[2] = &HFE AndAlso Buff[3] = &HFF Then 'Big Endian
							FileEncoding = FileEncodings.Utf32BOM
							BOMSymbolsCount = 4
						ElseIf Buff[0] = &HFF AndAlso Buff[1] = &HFE Then 'Little Endian
							FileEncoding = FileEncodings.Utf16BOM
							BOMSymbolsCount = 2
						ElseIf Buff[0] = &HFE AndAlso Buff[1] = &HFF Then 'Big Endian
							FileEncoding = FileEncodings.Utf16BOM
							BOMSymbolsCount = 2
						ElseIf Buff[0] = &HEF AndAlso Buff[1] = &HBB AndAlso Buff[2] = &HBF Then
							FileEncoding = FileEncodings.Utf8BOM
							BOMSymbolsCount = 3
						Else
							If (CheckUTF8NoBOM(sFileContents)) Then
								FileEncoding = FileEncodings.Utf8
								BOMSymbolsCount = 0
							Else
								FileEncoding = FileEncodings.PlainText
								BOMSymbolsCount = 0
							End If
						End If
					End If
					CloseHandle(hFile)
					For i As Integer = Content.Lines.Count - 1 To 0 Step -1
						Delete_( Cast(EditControlLine Ptr, Content.Lines.Items[i]))
					Next i
					Content.Lines.Clear
					i = 0
					OldFileEncoding = FileEncoding
					If FileEncoding = FileEncodings.PlainText Then
						WLet(wsFileContents, sFileContents)
					Else
						If BOMSymbolsCount Then
							sFileContents = Mid(sFileContents, BOMSymbolsCount + 1)
						End If
						WReAllocate(wsFileContents, dwBytesRead)
						MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, StrPtr(sFileContents), dwBytesRead, wsFileContents, dwBytesRead)
					End If
					Dim As WString Ptr FText
					Dim As EditControlLine Ptr FECLine
					WLet(FText, "")
					For j As Integer = 0 To Len(*wsFileContents)
						WAdd FText, WChr((*wsFileContents)[j])
						If (*wsFileContents)[j] = 10 OrElse (*wsFileContents)[j] = 0 Then
							FECLine = New_(EditControlLine)
							OlddwClientX = 0
							If FECLine = 0 Then
								Return
							End If
							pBuff = 0
							WLet(pBuff, Trim(Trim(Mid(*FText, 1, Len(*FText)), Any WChr(10)), Any WChr(13)))
							FECLine->Text = pBuff 'Do not Deallocate the pointer. transffer the point to FECLine->Text already.
							iC = FindCommentIndex(*pBuff, OldiC)
							FECLine->CommentIndex = iC
							FECLine->InAsm = InAsm
							Content.Lines.Add(FECLine)
							ChangeCollapsibility i
							If FECLine->ConstructionIndex = C_Asm Then
								InAsm = FECLine->ConstructionPart = 0
							End If
							FECLine->InAsm = InAsm
							OldiC = iC
							i += 1
							WLet(FText, "")
						End If
					Next
					CalculateLeftMargin
					If Not WithoutScroll Then ScrollToCaret
				End If
			End If
		#EndIf
		If Not FileLoaded Then
			If Open(FileName For Binary Access Read As #Fn) = 0 Then
				FileSize = LOF(Fn) + 1
				Buff = String(4, 0)
				Get #Fn, , Buff
				If Buff[0] = &HFF AndAlso Buff[1] = &HFE AndAlso Buff[2] = 0 AndAlso Buff[3] = 0 Then 'Little Endian
					FileEncoding = FileEncodings.Utf32BOM
					EncodingStr = "utf-32"
					Buff = String(1024, 0)
					Get #Fn, 0, Buff
					'ElseIf (Buff[0] = = OxFE && Buff[1] = = 0xFF) 'Big Endian
				ElseIf Buff[0] = &HFF AndAlso Buff[1] = &HFE Then 'Little Endian
					FileEncoding = FileEncodings.Utf16BOM
					EncodingStr = "utf-16"
					Buff = String(1024, 0)
					Get #Fn, 0, Buff
				ElseIf Buff[0] = &HEF AndAlso Buff[1] = &HBB AndAlso Buff[2] = &HBF Then
					FileEncoding = FileEncodings.Utf8BOM
					EncodingStr = "utf-8"
					Buff = String(1024, 0)
					Get #Fn, , Buff
				Else
					Buff = String(FileSize, 0)
					Get #Fn, 0, Buff
					If (CheckUTF8NoBOM(Buff)) Then
						FileEncoding = FileEncodings.Utf8
						EncodingStr = "ascii"
					Else
						FileEncoding = FileEncodings.PlainText
						EncodingStr = "ascii"
					End If
				End If
				If InStr(Buff, Chr(13, 10)) Then
					NewLineType= NewLineTypes.WindowsCRLF
					NewLineStr = Chr(10)
				ElseIf InStr(Buff, Chr(10)) Then
					NewLineType= NewLineTypes.LinuxLF
					NewLineStr = Chr(10)
				ElseIf InStr(Buff, Chr(13)) Then
					NewLineType= NewLineTypes.MacOSCR
					NewLineStr = Chr(13)
				Else
					NewLineType= NewLineTypes.WindowsCRLF
					NewLineStr = Chr(10)
				End If
			Else
				MsgBox ML("Open file failure!") &  " " & ML("in function") & " EditControl.LoadFromFile" & Chr(13, 10) & " " & FileName
				CloseFile_(Fn)
				Exit Sub
			End If
			CloseFile_(Fn)
			For i As Integer = Content.Lines.Count - 1 To 0 Step -1
				Delete_( Cast(EditControlLine Ptr, Content.Lines.Items[i]))
			Next i
			Content.Lines.Clear
			'VisibleLines.Clear
			i = 0
			Fn = FreeFile_
			Result = Open(FileName For Input Encoding EncodingStr As #Fn)
			If Result = 0 Then
				OldFileEncoding = FileEncoding
				Dim As Integer MaxChars = LOF(Fn)
				WReAllocate(BuffRead, MaxChars)
				Do Until EOF(Fn)
					FECLine = New_( EditControlLine)
					OlddwClientX = 0
					If FECLine = 0 Then
						CloseFile_(Fn)
						Return
					End If
					pBuff = 0
					If OldFileEncoding = FileEncodings.Utf8 Then
						Line Input #Fn, Buff
						WLet(pBuff, FromUtf8(StrPtr(Buff)))
					Else
						LineInputWstr Fn, BuffRead, MaxChars
						WLet(pBuff, *BuffRead)
					End If
					FECLine->Text = pBuff 'Do not Deallocate the pointer. transffer the point to FECLine->Text already.
					iC = FindCommentIndex(*pBuff, OldiC)
					FECLine->CommentIndex = iC
					FECLine->InAsm = InAsm
					Content.Lines.Add(FECLine)
					ChangeCollapsibility i
					If FECLine->ConstructionIndex = C_Asm Then
						InAsm = FECLine->ConstructionPart = 0
					End If
					FECLine->InAsm = InAsm
					OldiC = iC
					i += 1
				Loop
				CalculateLeftMargin
				If Not WithoutScroll Then ScrollToCaret
			End If
			WDeAllocate(BuffRead)
			CloseFile_(Fn)
		End If
	End Sub
	
	Sub EditControl.SaveToFile(ByRef FileName As WString, FileEncoding As FileEncodings, NewLineType As NewLineTypes)
		Dim As Integer Fn = FreeFile_
		Dim As Integer Result
		Dim As String FileEncodingText, NewLine, FileEncodingSymbols
		Dim As Boolean FileSaved
		If FileEncoding = FileEncodings.Utf8 Then
			FileEncodingText = "ascii"
			FileEncodingSymbols = ""
		ElseIf FileEncoding = FileEncodings.Utf8BOM Then
			FileEncodingText = "utf-8"
			FileEncodingSymbols = Chr(&HEF, &HBB, &HBF)
		ElseIf FileEncoding = FileEncodings.Utf16BOM Then
			FileEncodingText = "utf-16"
			FileEncodingSymbols = Chr(&HFF, &HFE)
		ElseIf FileEncoding = FileEncodings.Utf32BOM Then
			FileEncodingText = "utf-32"
			FileEncodingSymbols = Chr(&HFF, &HFE, 0, 0)
		Else
			FileEncodingText = "ascii"
			FileEncodingSymbols = ""
		End If
		If NewLineType = NewLineTypes.LinuxLF Then
			NewLine = Chr(10)
		ElseIf NewLineType = NewLineTypes.MacOSCR Then
			NewLine = Chr(13)
		Else
			NewLine = Chr(13, 10)
		End If
		#ifdef __USE_WINAPI__
			Dim Buff As String
			Buff = FileName
			If Buff <> FileName Then
				FileSaved = True
				Dim As .HANDLE hFile
				Dim As DWORD dwBytesToWrite, dwBytesWrite
				Dim As String sFileContents = FileEncodingSymbols
				hFile = CreateFile(@FileName, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
				If hFile = INVALID_HANDLE_VALUE Then
					MsgBox ML("Save file failure!") & Chr(13, 10) & FileName
				Else
					If FileEncoding = FileEncodings.PlainText  Then
						For i As Integer = 0 To Content.Lines.Count - 1
							sFileContents &= *Cast(EditControlLine Ptr, Content.Lines.Item(i))->Text & IIf(i = Content.Lines.Count - 1, "", WStr(NewLine))
						Next
					Else
						For i As Integer = 0 To Content.Lines.Count - 1
							sFileContents &= ToUtf8(*Cast(EditControlLine Ptr, Content.Lines.Item(i))->Text) & IIf(i = Content.Lines.Count - 1, "", WStr(NewLine))
						Next
					End If
					dwBytesToWrite = Len(sFileContents)
					WriteFile(hFile, @sFileContents[0], dwBytesToWrite, @dwBytesWrite, NULL)
  					CloseHandle(hFile)
				End If
			End If
		#endif
		If Not FileSaved Then
			If Open(FileName For Output Encoding FileEncodingText As #Fn) = 0 Then
				If FileEncoding = FileEncodings.Utf8 Then
					For i As Integer = 0 To Content.Lines.Count - 1
						Print #Fn, ToUtf8(*Cast(EditControlLine Ptr, Content.Lines.Item(i))->Text) & NewLine;
					Next
				ElseIf FileEncoding = FileEncodings.PlainText  Then
					For i As Integer = 0 To Content.Lines.Count - 1
						Print #Fn, *Cast(EditControlLine Ptr, Content.Lines.Item(i))->Text & NewLine;
					Next
				Else
					For i As Integer = 0 To Content.Lines.Count - 1
						Print #Fn, *Cast(EditControlLine Ptr, Content.Lines.Item(i))->Text & NewLine;
					Next
				End If
			Else
				MsgBox ML("Save file failure!") & Chr(13, 10) & FileName
			End If
			CloseFile_(Fn)
		End If
	End Sub
	
	Sub EditControl.Clear
		ChangeText "", 0, "Matn tozalandi"
	End Sub
	
	Function EditControl.LinesCount As Integer
		Return Content.Lines.Count
	End Function
	
	Sub EditControl.InsertLine(Index As Integer, ByRef sLine As WString)
		Var iC = 0, OldiC = 0, InAsm = False
		If Index > 0 AndAlso Index < Content.Lines.Count - 1 Then
			OldiC = Cast(EditControlLine Ptr, Content.Lines.Items[Index])->CommentIndex
			InAsm = Cast(EditControlLine Ptr, Content.Lines.Items[Index])->InAsm
		End If
		FECLine = New_( EditControlLine)
		WLet(FECLine->Text, sLine)
		OlddwClientX = 0
		iC = FindCommentIndex(sLine, OldiC)
		FECLine->CommentIndex = iC
		FECLine->InAsm = InAsm
		If OnLineAdding Then OnLineAdding(This, Index)
		Content.Lines.Insert Index, FECLine
		ChangeCollapsibility Index
		If FECLine->ConstructionIndex = C_Asm Then
			InAsm = FECLine->ConstructionPart = 0
		End If
		FECLine->InAsm = InAsm
		If Index <= FSelEndLine Then FSelEndLine += 1
		If Index <= FSelStartLine Then FSelStartLine += 1
		If OnLineAdded Then OnLineAdded(This, Index)
	End Sub
	
	Sub EditControl.ReplaceLine(Index As Integer, ByRef sLine As WString)
		Var iC = 0, OldiC = 0, InAsm = False
		If Index > 0 AndAlso Index < Content.Lines.Count - 1 Then
			OldiC = Cast(EditControlLine Ptr, Content.Lines.Items[Index])->CommentIndex
			InAsm = Cast(EditControlLine Ptr, Content.Lines.Items[Index])->InAsm
		End If
		FECLine = Content.Lines.Items[Index]
		WLet(FECLine->Text, sLine)
		FECLine->Ends.Clear
		FECLine->EndsCompleted = False
		iC = FindCommentIndex(sLine, OldiC)
		FECLine->CommentIndex = iC
		FECLine->InAsm = InAsm
		ChangeCollapsibility Index
		If FECLine->ConstructionIndex = C_Asm Then
			InAsm = FECLine->ConstructionPart = 0
		End If
		FECLine->InAsm = InAsm
	End Sub
	
	Sub EditControl.DuplicateLine(Index As Integer = -1)
		Changing "Duplicate line"
		Var iC = 0, OldiC = 0, InAsm = False
		Var Idx = IIf(Index = -1, FSelEndLine, Index)
		If Idx > 0 AndAlso Idx < Content.Lines.Count - 1 Then
			OldiC = Cast(EditControlLine Ptr, Content.Lines.Items[Idx])->CommentIndex
			InAsm = Cast(EditControlLine Ptr, Content.Lines.Items[Idx])->InAsm
		End If
		FECLine = New_( EditControlLine)
		OlddwClientX = 0
		WLet(FECLine->Text, *Cast(EditControlLine Ptr, Content.Lines.Items[Idx])->Text)
		iC = FindCommentIndex(*FECLine->Text, OldiC)
		FECLine->CommentIndex = iC
		FECLine->InAsm = InAsm
		If OnLineAdding Then OnLineAdding(This, Idx + 1)
		Content.Lines.Insert Idx + 1, FECLine
		ChangeCollapsibility Idx + 1
		If FECLine->ConstructionIndex = C_Asm Then
			InAsm = FECLine->ConstructionPart = 0
		End If
		FECLine->InAsm = InAsm
		If FSelStartLine = FSelEndLine Then FSelStartLine += 1
		FSelEndLine += 1
		If OnLineAdded Then OnLineAdded(This, Idx + 1)
		Changed "Duplicate line"
	End Sub
	
	Sub EditControl.DeleteLine(Index As Integer = -1)
		Dim As Integer i = IIf(Index = -1, FSelEndLine, Index)
		If OnLineRemoving Then OnLineRemoving(This, i)
		Dim As EditControlLine Ptr ecRemovingLine = Content.Lines.Items[i]
		Content.Lines.Remove i
		If OnLineRemoved Then OnLineRemoved(This, i)
		Delete_(ecRemovingLine)
		If Index <= FSelEndLine Then FSelEndLine -= 1
		If Index <= FSelStartLine Then FSelStartLine -= 1
		OlddwClientX = 0
	End Sub
	
	Sub EditControl.UnformatCode(WithoutUpdate As Boolean = False)
		If Not WithoutUpdate Then UpdateLock
		Changing("UnFormat")
		For i As Integer = 0 To Content.Lines.Count - 1
			FECLine = Content.Lines.Items[i]
			WLet(FECLine->Text, LTrim(*FECLine->Text, Any !"\t "))
			FECLine->Ends.Clear
			FECLine->EndsCompleted = False
		Next i
		Changed("UnFormat")
		If Not WithoutUpdate Then
			UpdateUnLock
			ShowCaretPos True
			PaintControl True
		End If
	End Sub
	
	Sub EditControl.FormatCode(WithoutUpdate As Boolean = False)
		Dim As Integer iIndents, CurIndents, iCount, iComment, ConstructionIndex, ConstructionPart
		Dim As EditControlLine Ptr ECLine2
		Dim As UString LineParts(Any), LineQuotes(Any)
		Dim As Integer iType = -1 '
		If Not WithoutUpdate Then UpdateLock
		Changing("Format")
		For i As Integer = 0 To Content.Lines.Count - 1
			FECLine = Content.Lines.Items[i]
			FECLine->Ends.Clear
			FECLine->EndsCompleted = False
			If Trim(*FECLine->Text, Any !"\t ") <> "" Then WLet(FECLine->Text, Trim(*FECLine->Text, Any !"\t "))
			'If *FECLine->Text = "" Then Continue For
			If .Left(Trim(LCase(*FECLine->Text), Any !"\t "), 3) = "if(" Then WLet(FECLine->Text, "If (" & Mid(*FECLine->Text, 4))
			If LCase(Trim(*FECLine->Text, Any !"\t ")) = "endif" Then WLet(FECLine->Text, "End If")
			If iComment = 0 Then
				If FECLine->Statements.Count > 1 Then
					Split(*FECLine->Text, """", LineQuotes())
					WLet(FLine, "")
					For k As Integer = 0 To UBound(LineQuotes) Step 2
						WAdd FLine, LineQuotes(k)
					Next
					iPos = InStr(*FLine, "'") - 1
					If iPos = -1 Then iPos = Len(*FLine)
					Split(.Left(*FLine, iPos), ":", LineParts())
					ConstructionIndex = Content.GetConstruction(LineParts(0), ConstructionPart, 0, FECLine->InAsm)
					If ConstructionIndex > -1 AndAlso ConstructionPart > 0 Then
						iIndents = Max(0, iIndents - 1)
					End If
				Else
					If FECLine->ConstructionIndex > -1 AndAlso FECLine->ConstructionPart > 0 Then
						iIndents = Max(0, iIndents - 1)
					End If
				End If
				CurIndents = iIndents
				If FECLine->ConstructionIndex = C_P_If AndAlso FECLine->ConstructionPart > 0 Then
					iCount = 0
					For j As Integer = i - 1 To 0 Step -1
						ECLine2 = Content.Lines.Items[j]
						If ECLine2->ConstructionIndex = C_P_If Then
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
				ElseIf FECLine->ConstructionIndex = C_For AndAlso FECLine->ConstructionPart = 2 Then
					iPos = InStr(*FECLine->Text, "'") - 1
					If iPos = -1 Then iPos = Len(*FECLine->Text)
					iPos = InStrCount(.Left(*FECLine->Text, iPos), ",")
					iIndents -= iPos
					CurIndents = iIndents
				End If
			End If
			WLet(FECLine->Text, IIf(TabAsSpaces AndAlso ChoosedTabStyle = 0, WSpace(CurIndents * TabWidth), WString(CurIndents, !"\t")) & LTrim(*FECLine->Text, Any !"\t "))
			If iComment = 0 Then
				If FECLine->Statements.Count > 1 Then
					For k As Integer = 0 To UBound(LineParts)
						ConstructionIndex = Content.GetConstruction(LineParts(k), ConstructionPart, 0, FECLine->InAsm)
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
			PaintControl True
		End If
	End Sub
	
	Function EditControl.CountOfVisibleLines() As Integer
		Dim As Integer cCount
		For i As Integer = 0 To Content.Lines.Count - 1
			If Cast(EditControlLine Ptr, Content.Lines.Item(i))->Visible Then cCount += 1
		Next
		Return cCount
	End Function
	
	Function EditControl.VisibleLinesCount(CodePane As Integer = -1) As Integer
		If bDividedY Then
			If IIf(CodePane = -1, ActiveCodePane, CodePane) = 1 Then
				Return (dwClientY - iDividedY - 7 - 17) / dwCharY
			Else
				Return (iDividedY) / dwCharY
			End If
		Else
			Return (dwClientY - 17) / dwCharY
		End If
	End Function
	
	Function EditControl.CharIndexFromPoint(X As Integer, Y As Integer, CodePane As Integer = -1) As Integer
		WLet(FLine, *Cast(EditControlLine Ptr, Content.Lines.Item(LineIndexFromPoint(X, Y, CodePane)))->Text)
		Var CurCodePane = IIf(CodePane = -1, ActiveCodePane, CodePane)
		Dim As Integer nCaretPosX = X - LeftMargin + IIf(CurCodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX - IIf(bDividedX AndAlso CurCodePane = 1, iDividedX + 7, 0)
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
	
	Function EditControl.LineIndexFromPoint(X As Integer, Y As Integer, CodePane As Integer = -1) As Integer
		If bDividedY Then
			If IIf(CodePane = -1, ActiveCodePane, CodePane) = 1 Then
				Return GetLineIndex(0, Max(0, Min(Fix((Y - iDividedY - 7) / dwCharY) + VScrollPosBottom, LinesCount - 1)))
			Else
				Return GetLineIndex(0, Max(0, Min(Fix(Y / dwCharY) + VScrollPosTop, LinesCount - 1)))
			End If
		Else
			Return GetLineIndex(0, Max(0, Min(Fix(Y / dwCharY) + IIf(bDividedX AndAlso IIf(CodePane = -1, ActiveCodePane, CodePane) = 0, VScrollPosTop, VScrollPosBottom), LinesCount - 1)))
		End If
	End Function
	
	Function EditControl.Lines(Index As Integer) ByRef As WString
		If Index >= 0 And Index < Content.Lines.Count Then Return *Cast(EditControlLine Ptr, Content.Lines.Item(Index))->Text
	End Function
	
	Function EditControl.LineLength(Index As Integer) As Integer '...'
		If Index >= 0 And Index < Content.Lines.Count Then Return Len(*Cast(EditControlLine Ptr, Content.Lines.Item(Index))->Text) Else Return 0
	End Function
	
	Function EditControl.GetCaretPosY(LineIndex As Integer) As Integer
		Static As Integer i, j
		j = 0
		For i = 1 To Min(Content.Lines.Count - 1, LineIndex)
			If Cast(EditControlLine Ptr, Content.Lines.Items[i])->Visible Then j = j + 1
		Next
		Return j
	End Function
	
	Sub EditControl.ShowLine(LineIndex As Integer)
		Do
			ChangeCollapseState GetLineIndex(LineIndex, 0), False
		Loop While Not Cast(EditControlLine Ptr, Content.Lines.Items[LineIndex])->Visible
	End Sub
	
	Function IsArg2(ByRef sLine As WString) As Boolean
		If sLine = "" Then Return False
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
	
	Function EditControl.GetWordAt(LineIndex As Integer, CharIndex As Integer, WithDot As Boolean = False, WithQuestion As Boolean = False, ByRef StartChar As Integer = 0) As String
		If LineIndex < 0 OrElse Content.Lines.Item(LineIndex) = 0 Then Return ""
		Dim As Integer i
		Dim As String s, sWord
		Dim As WString Ptr sLine = Cast(EditControlLine Ptr, Content.Lines.Item(LineIndex))->Text
		If sLine = 0 OrElse Trim(*sLine, Any !"\t ") = "" Then Return ""
		StartChar = CharIndex
		For i = CharIndex To 1 Step -1
			s = Mid(*sLine, i, 1)
			If CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(s = "#" OrElse s = "$"))) OrElse IIf(WithDot, s = ".", 0) OrElse IIf(WithQuestion, s = "?", 0) Then sWord = s & sWord: StartChar = i - 1 Else Exit For
		Next
		For i = CharIndex + 1 To Len(*sLine)
			s = Mid(*sLine, i, 1)
			If CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(s = "#" OrElse s = "$"))) OrElse IIf(WithDot, s = ".", 0) OrElse IIf(WithQuestion, s = "?", 0) Then sWord = sWord & s Else Exit For
		Next
		Return sWord
	End Function
	
	Function EditControl.GetWordAtCursor(WithDot As Boolean = False) As String
		Return GetWordAt(FSelEndLine, FSelEndChar, WithDot)
	End Function
	
	Function EditControl.GetWordAtPoint(X As Integer, Y As Integer, WithDot As Boolean = False) As String
		If X <= LeftMargin OrElse Content.Lines.Count < 1 Then Return ""
		Dim As Integer LineIndex
		If Y <= iDividedY AndAlso bDividedY Then
			LineIndex = Fix(Y / dwCharY) + VScrollPosTop
		Else
			LineIndex = Fix((Y - IIf(bDividedY, iDividedY + 7, 0)) / dwCharY) + VScrollPosBottom
		End If
		Var j = -1, k = -1
		For i As Integer = 0 To Content.Lines.Count - 1
			If Cast(EditControlLine Ptr, Content.Lines.Items[i])->Visible Then
				j = j + 1
				If j = LineIndex Then k = j: Exit For
			End If
		Next
		If k = -1 OrElse Content.Lines.Item(k) = 0 Then Return ""
		WLet(FLine, *Cast(EditControlLine Ptr, Content.Lines.Item(k))->Text)
		Dim As Integer nCaretPosX = X - LeftMargin + IIf(X <= iDividedX AndAlso bDividedX, HScrollPosLeft, HScrollPosRight - IIf(bDividedX, iDividedX + 7, 0)) * dwCharX
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
		WReAllocate(FLineTab, lText * TabWidth + 1)
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
		If CInt(DropDownShowed) AndAlso CInt(CInt(FSelEndChar < DropDownChar) OrElse CInt(FSelEndChar > GetNextCharIndex(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text, DropDownChar) AndAlso Not FileDropDown)) Then
			CloseDropDown()
		End If
		If CInt(ToolTipShowed) AndAlso CInt(CInt(FSelEndChar < ToolTipChar) OrElse CInt(Mid(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text, FSelEndChar + 1, 1) = ":") OrElse CInt(GetWordAt(FSelEndLine, ToolTipChar) <> HintWord AndAlso Mid(Lines(FSelEndLine), ToolTipChar + 1, 1) <> "?")) Then
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
		
		If CInt(FSelStartLine > -1) AndAlso CInt(FSelStartLine < Content.Lines.Count) AndAlso CInt(Not Cast(EditControlLine Ptr, Content.Lines.Items[FSelStartLine])->Visible) Then
			ShowLine FSelStartLine
		End If
		If CInt(FSelEndLine > -1) AndAlso CInt(FSelEndLine < Content.Lines.Count) AndAlso CInt(Not Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Visible) Then
			ShowLine FSelEndLine
		End If
		
		SetScrollsInfo
		Dim As Integer Ptr pHScrollPos
		If bDividedX AndAlso ActiveCodePane = 0 Then
			pHScrollPos = @HScrollPosLeft
		Else
			pHScrollPos = @HScrollPosRight
		End If
		Dim As Integer Ptr pVScrollPos
		If ActiveCodePane = 0 Then
			pVScrollPos = @VScrollPosTop
		Else
			pVScrollPos = @VScrollPosBottom
		End If
		Dim As Integer HScrollMax = IIf(bDividedX AndAlso ActiveCodePane = 0, HScrollMaxLeft, HScrollMaxRight)
		Dim As Integer VScrollMax = IIf(ActiveCodePane = 0, VScrollMaxTop, VScrollMaxBottom)
		If Scroll Then
			Var OldHScrollPos = *pHScrollPos, OldVScrollPos = *pVScrollPos
			If nCaretPosX < *pHScrollPos * dwCharX Then
				*pHScrollPos = nCaretPosX / dwCharX
			ElseIf LeftMargin + nCaretPosX > *pHScrollPos * dwCharX + (IIf(bDividedX, IIf(ActiveCodePane = 0, iDividedX, dwClientX - iDividedX - 7), dwClientX) - dwCharX - 17) Then
				*pHScrollPos = (LeftMargin + nCaretPosX - (IIf(bDividedX, IIf(ActiveCodePane = 0, iDividedX, dwClientX - iDividedX - 7), dwClientX) - dwCharX - 17)) / dwCharX
			ElseIf *pHScrollPos > HScrollMax Then
				*pHScrollPos = HScrollMax
			End If
			If nCaretPosY < *pVScrollPos Then
				*pVScrollPos = nCaretPosY
			ElseIf nCaretPosY > *pVScrollPos + (VisibleLinesCount - 2) Then
				*pVScrollPos = nCaretPosY - (VisibleLinesCount - 2)
			ElseIf *pVScrollPos > VScrollMax Then
				*pVScrollPos = VScrollMax
			End If
			
			If OldHScrollPos <> *pHScrollPos Then
				#ifdef __USE_GTK__
					If bDividedX AndAlso ActiveCodePane = 0 Then
						gtk_adjustment_set_value(adjustmenthLeft, *pHScrollPos)
					Else
						gtk_adjustment_set_value(adjustmenthRight, *pHScrollPos)
					End If
				#else
					si.cbSize = SizeOf (si)
					si.fMask = SIF_POS
					si.nPos = *pHScrollPos
					If bDividedX AndAlso ActiveCodePane = 0 Then
						SetScrollInfo(sbScrollBarhLeft, SB_CTL, @si, True)
					Else
						SetScrollInfo(sbScrollBarhRight, SB_CTL, @si, True)
					End If
					'SetScrollInfo(FHandle, SB_HORZ, @si, True)
				#endif
			End If
			If OldVScrollPos <> *pVScrollPos Then
				#ifdef __USE_GTK__
					If ActiveCodePane = 0 Then
						gtk_adjustment_set_value(adjustmentvTop, *pVScrollPos)
					Else
						gtk_adjustment_set_value(adjustmentvBottom, *pVScrollPos)
					End If
				#else
					si.cbSize = SizeOf (si)
					si.fMask = SIF_POS
					si.nPos = *pVScrollPos
					If ActiveCodePane = 0 Then
						SetScrollInfo(sbScrollBarvTop, SB_CTL, @si, True)
					Else
						SetScrollInfo(sbScrollBarvBottom, SB_CTL, @si, True)
					End If
					'SetScrollInfo(FHandle, SB_VERT, @si, True)
				#endif
			End If
			'If OldHScrollPos <> HScrollPos Or OldVScrollPos <> VScrollPos Then PaintControl
			#ifndef __USE_GTK__
				PaintControl
			#endif
		End If
		
		HCaretPos = LeftMargin + nCaretPosX - *pHScrollPos * dwCharX
		VCaretPos = (nCaretPosY - *pVScrollPos) * dwCharY
		If ActiveCodePane = 1 Then
			If bDividedX AndAlso HCaretPos >= 0 Then HCaretPos += iDividedX + 7
			If bDividedY AndAlso VCaretPos >= 0 Then VCaretPos += iDividedY + 7
		End If
		If HCaretPos < LeftMargin + IIf(bDividedX AndAlso ActiveCodePane = 1, iDividedX + 7, 0) OrElse FSelStartLine <> FSelEndLine OrElse FSelStartChar <> FSelEndChar _
			OrElse (ActiveCodePane = 0 AndAlso ((bDividedX AndAlso (HCaretPos > iDividedX - dwCharX)) OrElse (bDividedY AndAlso (VCaretPos > iDividedY - dwCharY)))) Then
			HCaretPos = -1
		End If
		#ifdef __USE_GTK__
			If Scroll Then
				CaretOn = True
				PaintControl
			End If
			'gtk_render_insertion_cursor(gtk_widget_get_style_context(widget), cr, 10, 10, layout, 0, PANGO_DIRECTION_LTR)
		#else
			'			If OldCaretVisible <> CaretVisible Then
			'				If CaretVisible Then
			'					ShowCaret FHandle
			'				Else
			'					HideCaret FHandle
			'				End If
			'			End If
			'If CaretVisible Then
			SetCaretPos(ScaleX(HCaretPos), ScaleY(VCaretPos))
			'End If
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
				FECLine = Content.Lines.Items[i]
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
				FECLine->Ends.Clear
				FECLine->EndsCompleted = False
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
			FECLine = Content.Lines.Items[i]
			n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
			n = Min(n, TabWidth - (n Mod TabWidth))
			If n = 0 AndAlso .Left(*FECLine->Text, 1) = !"\t" Then n = 1
			WLet(FECLine->Text, Mid(*FECLine->Text, n + 1))
			If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar -= n
			If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar -= n
			FECLine->Ends.Clear
			FECLine->EndsCompleted = False
		Next i
		Changed("Ortga surish")
		UpdateUnLock
		ShowCaretPos True
	End Sub
	
	Sub EditControl.CommentSingle
		UpdateLock
		Dim As Integer n, nStart
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Changing("Izoh qilish")
		For i As Integer = iSelStartLine To iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
			FECLine = Content.Lines.Items[i]
			If i = iSelStartLine Then
				nStart = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text, Any !"\t "))
			End If
			n = Min(nStart, Len(*FECLine->Text) - Len(LTrim(*FECLine->Text, Any !"\t ")))
			WLet(FECLine->Text, ..Left(*FECLine->Text, n) & "'" & Mid(*FECLine->Text, n + 1))
			If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += 1
			If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += 1
			ChangeCollapsibility i
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
			FECLine = Content.Lines.Items[i]
			If i = iSelStartLine Or i = iSelEndLine Then
				If i = iSelStartLine Then
					n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text, Any !"\t "))
					WLet(FECLine->Text, ..Left(*FECLine->Text, n) & "/'" & Mid(*FECLine->Text, n + 1))
					FECLine->CommentIndex += 1
					If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += 2
					If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += 2
				ElseIf i = iSelEndLine Then
					WLet(FECLine->Text, *FECLine->Text & "'/")
				End If
			Else
				FECLine->CommentIndex += 1
			End If
			ChangeCollapsibility i
		Next i
		Changed("Blokli izoh qilish")
		UpdateUnLock
		ShowCaretPos True
	End Sub
	
	Sub EditControl.UnComment
		UpdateLock
		Dim As Integer n
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Changing("Izohni olish")
		For i As Integer = iSelStartLine To iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
			FECLine = Content.Lines.Items[i]
			If .Left(Trim(*FECLine->Text, Any !"\t "), 1) = "'" Then
				n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text, Any !"\t "))
				WLet(FLineTemp, .Left(*FECLine->Text, n))
				WLet(FECLine->Text, *FLineTemp & Mid(*FECLine->Text, n + 2))
				If i = FSelEndLine And FSelEndChar > n Then FSelEndChar -= 1
				If i = FSelStartLine And FSelStartChar > n Then FSelStartChar -= 1
				ChangeCollapsibility i
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
		
		Var OldHScrollEnabledRight = CBool(HScrollMaxRight)
		Var OldHScrollMaxRight = HScrollMaxRight
		Var OldHScrollVCRight = HScrollVCRight
		HScrollMaxRight = 10000 'Max(0, (MaxLineWidth - (dwClientX - LeftMargin - dwCharX))) \ dwCharX
		HScrollVCRight = 10
		If OldHScrollMaxRight <> HScrollMaxRight OrElse OldHScrollVCRight <> HScrollVCRight Then
			#ifdef __USE_GTK__
				gtk_adjustment_set_upper(adjustmenthRight, HScrollMaxRight)
				'gtk_adjustment_configure(adjustmenth, gtk_adjustment_get_value(adjustmenth), 0, HScrollMax, 1, 10, HScrollMax)
			#else
				'If HScrollEnabledRight Then
				si.cbSize = SizeOf(si)
				si.fMask  = SIF_RANGE Or SIF_PAGE
				si.nMin   = 0
				si.nMax   = HScrollMaxRight
				si.nPage  = HScrollVCRight
				SetScrollInfo(sbScrollBarhRight, SB_CTL, @si, True)
				'End If
				'EnableWindow sbScrollBarhRight, HScrollEnabledRight
				'SetScrollInfo(FHandle, SB_HORZ, @si, True)
			#endif
		End If
		
		If bDividedX Then
			Var OldHScrollEnabledLeft = CBool(HScrollMaxLeft)
			Var OldHScrollMaxLeft = HScrollMaxLeft
			Var OldHScrollVCLeft = HScrollVCLeft
			HScrollMaxLeft = 10000 'Max(0, (MaxLineWidth - (dwClientX - LeftMargin - dwCharX))) \ dwCharX
			HScrollVCLeft = 10
			Var HScrollEnabledLeft = CBool(HScrollMaxLeft)
			
			If OldHScrollMaxLeft <> HScrollMaxLeft OrElse OldHScrollVCLeft <> HScrollVCLeft Then
				#ifdef __USE_GTK__
					gtk_adjustment_set_upper(adjustmenthLeft, HScrollMaxRight)
					'gtk_adjustment_configure(adjustmentv, gtk_adjustment_get_value(adjustmentv), 0, VScrollMax, 1, 10, VScrollMax / 10)
				#else
					If HScrollEnabledLeft Then
						si.cbSize = SizeOf(si)
						si.fMask  = SIF_RANGE Or SIF_PAGE
						si.nMin   = 0
						si.nMax   = HScrollMaxLeft
						si.nPage  = HScrollVCLeft
						SetScrollInfo(sbScrollBarhLeft, SB_CTL, @si, True)
					End If
					'If OldHScrollEnabled <> HScrollEnabled Then
					'EnableWindow sbScrollBarhTop, HScrollEnabledLeft
					'End If
					'SetScrollInfo(FHandle, SB_VERT, @si, True)
				#endif
			End If
		End If
		
		Var LinesCount_ = CountOfVisibleLines
		Var OldVScrollEnabledBottom = CBool(VScrollMaxBottom)
		Var OldVScrollMaxBottom = VScrollMaxBottom
		Var OldVScrollVCBottom = VScrollVCBottom
		VScrollMaxBottom = LinesCount_ 'Max(0, LinesCount - VisibleLinesCount(1) + 1)
		VScrollVCBottom = VisibleLinesCount(1)
		CalculateLeftMargin
		Var VScrollEnabledBottom = CBool(VScrollMaxBottom)
		
		If OldVScrollMaxBottom <> VScrollMaxBottom OrElse OldVScrollVCBottom <> VScrollVCBottom Then
			#ifdef __USE_GTK__
				gtk_adjustment_set_upper(adjustmentvBottom, VScrollMaxBottom)
				gtk_adjustment_set_page_size(adjustmentvBottom, 0)
				'gtk_adjustment_configure(adjustmentv, gtk_adjustment_get_value(adjustmentv), 0, VScrollMax, 1, 10, VScrollMax / 10)
			#else
				If VScrollEnabledBottom Then
					si.cbSize = SizeOf(si)
					si.fMask  = SIF_RANGE Or SIF_PAGE
					si.nMin   = 0
					si.nMax   = VScrollMaxBottom
					si.nPage  = VScrollVCBottom
					SetScrollInfo(sbScrollBarvBottom, SB_CTL, @si, True)
				End If
				'If OldVScrollEnabled <> VScrollEnabled Then
				EnableWindow sbScrollBarvBottom, VScrollEnabledBottom
				'End If
				'SetScrollInfo(FHandle, SB_VERT, @si, True)
			#endif
		End If
		
		If bDividedY OrElse bDividedX Then
			Var OldVScrollEnabledTop = CBool(VScrollMaxTop)
			Var OldVScrollMaxTop = VScrollMaxTop
			Var OldVScrollVCTop = VScrollVCTop
			VScrollMaxTop = LinesCount_ 'Max(0, LinesCount - VisibleLinesCount(0) + 1)
			VScrollVCTop = VisibleLinesCount(0)
			CalculateLeftMargin
			Var VScrollEnabledTop = CBool(VScrollMaxTop)
			
			If OldVScrollMaxTop <> VScrollMaxTop OrElse OldVScrollVCTop <> VScrollVCTop Then
				#ifdef __USE_GTK__
					gtk_adjustment_set_upper(adjustmentvTop, VScrollMaxTop)
					gtk_adjustment_set_page_size(adjustmentvTop, 0)
					'gtk_adjustment_configure(adjustmentv, gtk_adjustment_get_value(adjustmentv), 0, VScrollMax, 1, 10, VScrollMax / 10)
				#else
					If VScrollEnabledTop Then
						si.cbSize = SizeOf(si)
						si.fMask  = SIF_RANGE Or SIF_PAGE
						si.nMin   = 0
						si.nMax   = VScrollMaxTop
						si.nPage  = VScrollVCTop
						SetScrollInfo(sbScrollBarvTop, SB_CTL, @si, True)
					End If
					'If OldVScrollEnabled <> VScrollEnabled Then
					EnableWindow sbScrollBarvTop, VScrollEnabledTop
					'End If
					'SetScrollInfo(FHandle, SB_VERT, @si, True)
				#endif
			End If
		End If
		
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
			pango_layout_set_text(layout, ToUtf8(sText), Len(ToUtf8(sText)))
			If cr Then
				pango_cairo_update_layout(cr, layout)
			End If
			#ifdef pango_version
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
	
	Sub GetColor(iColor As Long, ByRef iRED As Double, ByRef iGREEN As Double, ByRef iBLUE As Double)
		Select Case iColor
			'		Case clBlack:	iRed = 0: iGreen = 0: iBlue = 0
			'		Case clRed:		iRed = 0.8: iGreen = 0: iBlue = 0
			'		Case clGreen:	iRed = 0: iGreen = 0.8: iBlue = 0
			'		Case clBlue:	iRed = 0: iGreen = 0: iBlue = 1
			'		Case clWhite:	iRed = 1: iGreen = 1: iBlue = 1
			'		Case clOrange:	iRed = 1: iGreen = 83 / 255.0: iBlue = 0
		Case Else: iRED = Abs(GetRed(iColor) / 255.0): iGREEN = Abs(GetGreen(iColor) / 255.0): iBLUE = Abs(GetBlue(iColor) / 255.0)
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
	
	Sub EditControl.PaintText(CodePane As Integer, iLine As Integer, ByRef sText As WString, iStart As Integer, iEnd As Integer, ByRef Colors As ECColorScheme, ByRef addit As WString = "", Bold As Boolean = False, Italic As Boolean = False, Underline As Boolean = False)
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
			Dim As Double iRED, iGREEN, iBLUE
			extend.width = TextWidth(*FLineLeft)
			pango_layout_set_text(layout, ToUtf8(*FLineRight), Len(ToUtf8(*FLineRight)))
			Dim As PangoAttrList Ptr attribs = pango_attr_list_new()
			If Underline Then
				Dim As PangoAttribute Ptr pUnderline = pango_attr_underline_new(PANGO_UNDERLINE_SINGLE)
				pango_attr_list_insert(attribs, pUnderline)
			End If
			pango_layout_set_attributes(layout, attribs)
			pango_attr_list_unref(attribs)
			pango_cairo_update_layout(cr, layout)
			#ifdef pango_version
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			pango_layout_line_get_pixel_extents(pl, NULL, @extend2)
			If HighlightCurrentWord AndAlso @Colors <> @Selection AndAlso CurWord = Trim(*FLineRight) AndAlso CurWord <> "" Then
				'GetColor BKColor, iRed, iGreen, iBlue
				cairo_set_source_rgb(cr, CurrentWord.BackgroundRed, CurrentWord.BackgroundGreen, CurrentWord.BackgroundBlue)
				.cairo_rectangle (cr, LeftMargin - IIf(bDividedX AndAlso CodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX + extend.width + IIf(bDividedX AndAlso CodePane = 1, iDividedX + 7, 0), (iLine - IIf(CodePane = 0, VScrollPosTop, VScrollPosBottom)) * dwCharY + IIf(bDividedY AndAlso CodePane = 1, iDividedY + 7, 0), extend2.width, dwCharY)
				cairo_fill (cr)
			ElseIf Colors.Background <> -1 Then
				pango_layout_line_get_pixel_extents(pl, NULL, @extend2)
				'GetColor BKColor, iRed, iGreen, iBlue
				cairo_set_source_rgb(cr, Colors.BackgroundRed, Colors.BackgroundGreen, Colors.BackgroundBlue)
				.cairo_rectangle (cr, LeftMargin - IIf(bDividedX AndAlso CodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX + extend.Width + IIf(bDividedX AndAlso CodePane = 1, iDividedX + 7, 0), (iLine - IIf(CodePane = 0, VScrollPosTop, VScrollPosBottom)) * dwCharY + IIf(bDividedY AndAlso CodePane = 1, iDividedY + 7, 0), extend2.width, dwCharY)
				cairo_fill (cr)
			End If
			cairo_move_to(cr, LeftMargin - IIf(bDividedX AndAlso CodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX + IIf(bDividedX AndAlso CodePane = 1, iDividedX + 7, 0) + extend.Width - 0.5, _
			(iLine - IIf(CodePane = 0, VScrollPosTop, VScrollPosBottom)) * dwCharY + dwCharY - 5 - 0.5 + IIf(bDividedY AndAlso CodePane = 1, iDividedY + 7, 0))
			'GetColor TextColor, iRed, iGreen, iBlue
			cairo_set_source_rgb(cr, Colors.ForegroundRed, Colors.ForegroundGreen, Colors.ForegroundBlue)
			pango_cairo_show_layout_line(cr, pl)
		#else
			If HighlightCurrentWord AndAlso @Colors <> @Selection AndAlso CurWord = Trim(*FLineRight) AndAlso CurWord <> "" Then
				If StartsWith(*FLineRight, " ") Then
					Var n = Len(*FLineRight) - Len(Trim(*FLineRight))
					PaintText(CodePane, iLine, sText, iStart + n, iEnd, Colors, addit, Bold, Italic, Underline)
					Exit Sub
				End If
				SetBkColor(bufDC, CurrentWord.Background)
				'ElseIf @Colors = @NormalText Then
				'	SetBKMode(bufDC, TRANSPARENT)
			Else
				If Colors.Background = -1 Then
					SetBkMode(bufDC, TRANSPARENT)
				Else
					SetBkColor(bufDC, Colors.Background)
				End If
			End If
			SetTextColor(bufDC, Colors.Foreground)
			GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @sz)
			If Bold Or Italic Or Underline Then
				Canvas.Font.Bold = Bold
				Canvas.Font.Italic = Italic
				Canvas.Font.Underline = Underline
				SelectObject(bufDC, This.Canvas.Font.Handle)
			End If
			'TextOut(bufDC, ScaleX(LeftMargin - IIf(bDividedX AndAlso CodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX + IIf(bDividedX AndAlso CodePane = 1, iDividedX + 7, 0)) + IIf(iStart = 0, 0, Sz.cx), ScaleY((iLine - IIf(CodePane = 0, VScrollPosTop, VScrollPosBottom)) * dwCharY + IIf(bDividedY AndAlso CodePane = 1, iDividedY + 7, 0)), FLineRight, Len(*FLineRight))
			'Dim As POLYTEXT ppt
			Var x = ScaleX(LeftMargin - IIf(bDividedX AndAlso CodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX + IIf(bDividedX AndAlso CodePane = 1, iDividedX + 7, 0)) + IIf(iStart = 0, 0, sz.cx)
			Var y = ScaleY((iLine - IIf(CodePane = 0, VScrollPosTop, VScrollPosBottom)) * dwCharY + IIf(bDividedY AndAlso CodePane = 1, iDividedY + 7, 0))
			SetRect(@rc, IIf(bDividedX And CodePane = 1, ScaleX(iDividedX + 7), 0), y, _
			ScaleX(IIf(bDividedX AndAlso CodePane = 0, iDividedX, dwClientX)), y + ScaleY(dwCharY))
			'ppt.lpstr = FLineRight
			'ppt.n = Len(*FLineRight)
			'ppt.uiFlags = ETO_CLIPPED Or ETO_OPAQUE
			'DrawText(bufDC, FLineRight, Len(*FLineRight), @rc, DT_SINGLELINE Or DT_NOPREFIX)
			ExtTextOut bufDC, x, y, ETO_CLIPPED, @rc, FLineRight, Len(*FLineRight), 0
			'PolyTextOut bufDC, @ppt, 1
			If Colors.Background = -1 Then SetBkMode(bufDC, OPAQUE)
			If Bold Or Italic Or Underline Then
				Canvas.Font.Bold = False
				Canvas.Font.Italic = False
				Canvas.Font.Underline = False
				SelectObject(bufDC, This.Canvas.Font.Handle)
			End If
		#endif
		If CBool(CurExecutedLine <> iLine) AndAlso CBool(OldExecutedLine <> iLine) AndAlso CBool(Not FECLine->EndsCompleted) Then
			FECLine->Ends.Add iEnd, @Colors
		End If
		'WDeallocate s
	End Sub
	
	Sub EditControl.FontSettings()
		This.Canvas.Font = This.Font
		WLet(CurrentFontName, *EditorFontName)
		CurrentFontSize = EditorFontSize
		#ifndef __USE_GTK__
			'hd = GetDc(FHandle)
			SelectObject(hd, This.Font.Handle)
			GetTextMetrics(hd, @tm)
			'ReleaseDC(FHandle, hd)
			If bufDC <> 0 Then SelectObject(bufDC, This.Font.Handle)
			
			dwCharX = UnScaleX(tm.tmAveCharWidth)
			dwCharY = UnScaleY(tm.tmHeight)
			CreateCaret(FHandle, 0, 0, ScaleY(dwCharY))
			ShowCaret FHandle
		#endif
		CalculateLeftMargin
		
		dwClientX = ClientWidth
		dwClientY = ClientHeight
	End Sub
	
	Function EditControlContent.ContainsIn(ByRef ClassName As String, ByRef ItemText As String, pList As WStringOrStringList Ptr, pFiles As WStringList Ptr, pFileLines As IntegerList Ptr, bLocal As Boolean = False, bAll As Boolean = False, TypesOnly As Boolean = False, ByRef te As TypeElement Ptr = 0, LineIndex As Integer = -1) As Boolean
		If ClassName = "" OrElse pList = 0 Then Return False
		Var Index = -1
		If pList = @Types OrElse pList = @Enums OrElse pList = @Namespaces Then
			Index = pList->IndexOf(ClassName)
		Else
			Index = IndexOfInListFiles(pList, ClassName, pFiles, pFileLines)
		End If
		If Index = -1 Then Return False
		Dim tbi As TypeElement Ptr = pList->Object(Index)
		te = 0
		If tbi Then
			If LineIndex <>-1 AndAlso tbi->StartLine > LineIndex Then Return False
			Index = -1
			If tbi->Elements.Contains(ItemText, , , , Index) Then
				te = tbi->Elements.Object(Index)
				'ElseIf ContainsIn(tbi->TypeName, ItemText, pList, bLocal, bAll, TypesOnly, te) Then
			ElseIf ContainsIn(tbi->TypeName, ItemText, @Types, pFiles, pFileLines, bLocal, bAll, TypesOnly, te, LineIndex) Then
			ElseIf ContainsIn(tbi->TypeName, ItemText, @Enums, pFiles, pFileLines, bLocal, bAll, TypesOnly, te, LineIndex) Then
			ElseIf ContainsIn(tbi->TypeName, ItemText, @Namespaces, pFiles, pFileLines, bLocal, bAll, TypesOnly, te, LineIndex) Then
			ElseIf ContainsIn(tbi->TypeName, ItemText, pComps, pFiles, pFileLines, bLocal, bAll, TypesOnly, te) Then
			ElseIf ContainsIn(tbi->TypeName, ItemText, pGlobalTypes, pFiles, pFileLines, bLocal, bAll, TypesOnly, te) Then
			ElseIf ContainsIn(tbi->TypeName, ItemText, pGlobalEnums, pFiles, pFileLines, bLocal, bAll, TypesOnly, te) Then
			ElseIf ContainsIn(tbi->TypeName, ItemText, pGlobalNamespaces, pFiles, pFileLines, bLocal, bAll, TypesOnly, te) Then
			End If
		End If
		If te > 0 Then Return True Else Return False
	End Function

	Function GetFromConstructionBlock(cb As ConstructionBlock Ptr, ByRef Text As String, z As Integer) As TypeElement Ptr
		If cb = 0 Then Return 0
		Var tIndex = cb->Elements.IndexOf(Text)
		If tIndex <> -1 Then
			Dim te As TypeElement Ptr = cb->Elements.Object(tIndex)
			If (te->StartLine <= z) OrElse te->ElementType = E_LineLabel Then
				Return te
			End If
		ElseIf cb->Construction Then
			tIndex = cb->Construction->Elements.IndexOf(Text)
			If tIndex <> -1 Then
				Dim te As TypeElement Ptr = cb->Construction->Elements.Object(tIndex)
				If (te->StartLine <= z) OrElse te->ElementType = E_LineLabel Then
					Return te
				End If
			End If
		End If
		Return GetFromConstructionBlock(cb->InConstructionBlock, Text, z)
	End Function
	
	Function EditControlContent.GetTypeFromValue(ByRef Value As String, iSelEndLine As Integer) As String
		If Value = "" Then Return ""
		Dim As String sTemp
		If (StartsWith(LCase(Value), "cast(") OrElse StartsWith(LCase(Value), "@cast(") OrElse StartsWith(LCase(Value), "*cast(") OrElse StartsWith(LCase(Value), "(*cast(")) AndAlso EndsWith(LCase(Value), ")") Then
			Var Pos1 = InStr(2, Value, "(")
			Var Pos2 = InStr(Value, ",")
			If Pos2 > 0 Then
				sTemp = WithoutPointers(Trim(Mid(Value, Pos1 + 1, Pos2 - Pos1 - 1)))
			End If
		ElseIf StartsWith(LCase(Value), "new_(") Then
			Var Pos1 = InStr(Value, "(")
			Var Pos2 = InStr(Value, ")")
			If Pos2 > 0 Then
				sTemp = Trim(Mid(Value, Pos1 + 1, Pos2 - Pos1 - 1))
			End If
		Else
			Dim As String TypeName
			Dim As Integer j, iCount
			Dim As String ch
			Dim As Boolean b
			For i As Integer = Len(Value) To 1 Step -1
				ch = Chr(Value[i - 1]) 'Mid(Value, i, 1)
				If ch = ")" Then
					iCount += 1
					b = True
				ElseIf b AndAlso ch = "(" Then
					iCount -= 1
					If iCount = 0 Then b = False
				ElseIf Not b Then
					If IsArg(Asc(ch)) Then
						sTemp = ch & sTemp
					ElseIf sTemp <> "" Then
						If ch = "." Then
							If Trim(..Left(Value, i - 1)) = "" Then
								Dim As String OldTypeName
								TypeName = GetLeftArgTypeName(iSelEndLine, 0, , , OldTypeName, , )
							Else
								TypeName = GetTypeFromValue(..Left(Value, i - 1), iSelEndLine)
							End If
						ElseIf ch = ">" AndAlso i > 0 AndAlso Mid(Value, i - 1, 1) = "-" Then
							TypeName = GetTypeFromValue(..Left(Value, i - 2), iSelEndLine)
						End If
						Exit For
					Else
						Exit For
					End If
				End If
			Next
			Dim As String TypeNameFromLine
			Var teC = Cast(EditControlLine Ptr, Lines.Item(iSelEndLine))->InConstruction
			If teC > 0 Then
				TypeNameFromLine = teC->OwnerTypeName
				'Var Pos1 = InStr(teC->FullName, ".")
				'If Pos1 > 0 Then
				'	TypeNameFromLine = ..Left(teC->FullName, Pos1 - 1)
				'Else
				'	TypeNameFromLine = teC->Name
				'End If
				If CInt(LCase(sTemp) = "this") Then
					sTemp = TypeNameFromLine
				End If
			End If
			Dim As EditControlLine Ptr ECLine = Lines.Item(iSelEndLine)
			Dim As WStringList Ptr pFiles
			Dim As IntegerList Ptr pFileLines
			If ECLine Then
				pFiles = ECLine->FileList
				pFileLines = ECLine->FileListLines
			End If
			Dim As TypeElement Ptr te, te1
			Dim As Integer Pos1
			Dim As Integer Idx = -1
			If TypeName <> "" Then
				If ContainsIn(TypeName, sTemp, @Types, pFiles, pFileLines, True, , , te, iSelEndLine) Then
				ElseIf ContainsIn(TypeName, sTemp, @Enums, pFiles, pFileLines, True, , , te, iSelEndLine) Then
				ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Types, pFiles, pFileLines, True, , , te) Then
				ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Enums, pFiles, pFileLines, True, , , te) Then
				ElseIf ContainsIn(TypeName, sTemp, pComps, pFiles, pFileLines, True, , , te) Then
				ElseIf ContainsIn(TypeName, sTemp, pGlobalTypes, pFiles, pFileLines, True, , , te) Then
				ElseIf ContainsIn(TypeName, sTemp, pGlobalEnums, pFiles, pFileLines, True, , , te) Then
				End If
			Else
				If ECLine AndAlso ECLine->InConstructionBlock Then
					te = GetFromConstructionBlock(ECLine->InConstructionBlock, sTemp, iSelEndLine)
					If te Then
						If te->TypeName = "" AndAlso te->Value <> "" Then
							Return GetTypeFromValue(te->Value, iSelEndLine)
						Else
							Return te->TypeName
						End If
					End If
				End If
				te1 = teC
				If teC > 0 Then TypeName = TypeNameFromLine
				If te1 <> 0 AndAlso te1->Elements.Contains(sTemp, , , , Idx) AndAlso Cast(TypeElement Ptr, te1->Elements.Object(Idx))->StartLine <= iSelEndLine Then
					te = te1->Elements.Object(Idx)
				ElseIf Procedures.Contains(sTemp, , , , Idx) AndAlso Cast(TypeElement Ptr, Procedures.Object(Idx))->StartLine <= iSelEndLine Then
					te = Procedures.Object(Idx)
				ElseIf Args.Contains(sTemp, , , , Idx) AndAlso Cast(TypeElement Ptr, Args.Object(Idx))->StartLine <= iSelEndLine Then
					te = Args.Object(Idx)
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Functions, sTemp, Idx, pFiles, pFileLines) Then
					te = Globals->Functions.Object(Idx)
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Args, sTemp, Idx, pFiles, pFileLines) Then
					te = Globals->Args.Object(Idx)
				ElseIf ContainsInListFiles(pGlobalFunctions, sTemp, Idx, pFiles, pFileLines) Then
					te = pGlobalFunctions->Object(Idx)
				ElseIf ContainsInListFiles(pGlobalArgs, sTemp, Idx, pFiles, pFileLines) Then
					te = pGlobalArgs->Object(Idx)
				ElseIf TypeName <> "" Then
					If ContainsIn(TypeName, sTemp, @Types, pFiles, pFileLines, True, , , te, iSelEndLine) Then
					ElseIf ContainsIn(TypeName, sTemp, @Enums, pFiles, pFileLines, True, , , te, iSelEndLine) Then
					ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Types, pFiles, pFileLines, True, , , te) Then
					ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Enums, pFiles, pFileLines, True, , , te) Then
					ElseIf ContainsIn(TypeName, sTemp, pComps, pFiles, pFileLines, True, , , te) Then
					ElseIf ContainsIn(TypeName, sTemp, pGlobalTypes, pFiles, pFileLines, True, , , te) Then
					ElseIf ContainsIn(TypeName, sTemp, pGlobalEnums, pFiles, pFileLines, True, , , te) Then
					End If
				End If
			End If
			If te > 0 Then
				sTemp = te->TypeName
				If sTemp = "" AndAlso te->Value <> "" Then
					sTemp = GetTypeFromValue(te->Value, iSelEndLine)
				End If
			End If
		End If
		Return sTemp
	End Function
	
	Function EditControlContent.GetLeftArgTypeName(iSelEndLine As Integer, iSelEndChar As Integer, ByRef teEnum As TypeElement Ptr = 0, ByRef teEnumOld As TypeElement Ptr = 0, ByRef OldTypeName As String = "", ByRef bTypes As Boolean = False, ByRef bWithoutWith As Boolean = False) As String
		Dim As String sTemp, sTemp2, TypeName, sOldTypeName, BaseTypeName
		Dim sLine As WString Ptr
		Dim As Integer j, iCount, Pos1
		Dim As String ch
		Dim As Boolean b, OneDot, TwoDots, bArg, bArgEnded
		For j = iSelEndLine To 0 Step -1
			sLine = Cast(EditControlLine Ptr, Lines.Item(j))->Text
			If j < iSelEndLine AndAlso Not EndsWith(RTrim(*sLine, Any !"\t "), " _") Then Exit For
			For i As Integer = IIf(j = iSelEndLine, Min(Len(RTrim(*sLine, Any !"\t ")), iSelEndChar), Len(RTrim(*sLine, Any !"\t "))) To 1 Step -1
				ch = Chr((*sLine)[i - 1])
				If ch = ")" OrElse ch = "]" Then
					iCount += 1
					b = True
				ElseIf CInt(b) AndAlso CInt(ch = "(" OrElse ch = "[") Then
					iCount -= 1
					If iCount = 0 Then b = False
				ElseIf Not b Then
					If IsArg(Asc(ch)) Then 'AndAlso Not bArgEnded Then
						sTemp = ch & sTemp
						bArg = True
					'ElseIf (ch = " " OrElse ch = !"\t") Then
					'	If bArg Then bArgEnded = True
					'	Continue For
					ElseIf sTemp <> "" Then
						If ch = "." Then
							If i > 0 AndAlso Mid(*sLine, i - 1, 1) = "." Then
								TwoDots = True
							Else
								OneDot = True
								TypeName = GetLeftArgTypeName(j, i - 1, teEnumOld, , sOldTypeName, bTypes, bWithoutWith)
							End If
						ElseIf ch = ">" AndAlso i > 0 AndAlso Mid(*sLine, i - 1, 1) = "-" Then
							OneDot = True
							TypeName = GetLeftArgTypeName(j, i - 2, teEnumOld, , sOldTypeName, bTypes)
						ElseIf CBool(CBool(ch = " ") OrElse CBool(ch = !"\t")) AndAlso CBool(i > 0) AndAlso EndsWith(RTrim(LCase(..Left(*sLine, i - 1)), Any "\t "), " as") Then
							bTypes = True
						End If
						Exit For, For
					Else
						Exit For, For
					End If
				End If
				sTemp2 = ch & sTemp2
			Next
		Next
		If StartsWith(LCase(sTemp2), "cast") Then
			Return GetTypeFromValue(sTemp2, iSelEndLine)
		End If
		If CInt(sTemp = "") AndAlso CInt(StartsWith(sTemp2, "(")) AndAlso CInt(EndsWith(sTemp2, ")")) Then
			Return GetTypeFromValue(..Left(sTemp2, Len(sTemp2) - 1), iSelEndLine)
		ElseIf sTemp = "" AndAlso sTemp2 = "" Then
			'			If Cast(EditControlLine Ptr, Content.Lines.Items[j])->InWithConstruction = WithOldI Then
			'				teEnum = WithTeEnumOld
			'				Return WithOldTypeName
			'			End If
			Var WithCount = 1
			Dim As EditControlLine Ptr ECLine
			For i As Integer = j - 1 To 0 Step -1
				ECLine = Lines.Items[i]
				If ECLine->ConstructionIndex > C_P_Region Then
					bWithoutWith = True
					Return ""
				ElseIf ECLine->ConstructionIndex = C_With Then
					If ECLine->ConstructionPart = 2 Then
						WithCount += 1
					ElseIf ECLine->ConstructionPart = 0 Then
						WithCount -= 1
						If WithCount < 0 Then
							bWithoutWith = True
							Return ""
						ElseIf WithCount = 0 Then
							Pos1 = InStr(*ECLine->Text, "'")
							If Pos1 Then
								Pos1 -= Len(Left(*ECLine->Text, Pos1 - 1)) - Len(RTrim(Left(*ECLine->Text, Pos1 - 1), Any !"\t "))
							Else
								Pos1 = Len(*ECLine->Text) + 1
							End If
							TypeName = GetLeftArgTypeName(i, Pos1 - 1, teEnumOld, , sOldTypeName, bTypes)
							WithOldI = i
							WithOldTypeName = TypeName
							WithTeEnumOld = teEnumOld
							teEnum = teEnumOld
							Return TypeName
						End If
					End If
				End If
			Next
		End If
		Dim As String TypeNameFromLine
		Dim teC As TypeElement Ptr = Cast(EditControlLine Ptr, Lines.Item(iSelEndLine))->InConstruction
		If teC > 0 Then
			TypeNameFromLine = teC->OwnerTypeName
			'Var Pos1 = InStr(teC->FullName, ".")
			'Var Pos2 = InStr(teC->DisplayName, "[")
			'If Pos1 > 0 Then
			'	TypeNameFromLine = Trim(..Left(teC->FullName, Pos1 - 1), Any !"\t ")
			'ElseIf Pos2 > 0 Then
			'	TypeNameFromLine = Trim(..Left(teC->DisplayName, Pos2 - 1), Any !"\t ")
			'Else
			'	TypeNameFromLine = teC->Name
			'End If
			If CInt(LCase(sTemp) = "this") Then
				teEnum = teC
				Return TypeNameFromLine
			End If
		End If
		Var Idx = -1
		Dim As TypeElement Ptr te, te1, te2
		Dim As String InCondition
		Dim As EditControlLine Ptr ECLine = Lines.Item(iSelEndLine)
		Dim As WStringList Ptr pFiles
		Dim As IntegerList Ptr pFileLines
		If ECLine Then
			pFiles = ECLine->FileList
			pFileLines = ECLine->FileListLines
			InCondition = ECLine->InCondition
		End If
		If TypeName <> "" Then
			If LCase(sTemp) = "base" Then
				If Types.Contains(TypeName, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->StartLine <= iSelEndLine Then
					te2 = Types.Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Types, TypeName, Idx, pFiles, pFileLines) Then
					te2 = Globals->Types.Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				ElseIf ContainsInListFiles(pComps, TypeName, Idx, pFiles, pFileLines) Then
					te2 = pComps->Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				ElseIf ContainsInListFiles(pGlobalTypes, TypeName, Idx, pFiles, pFileLines) Then
					te2 = pGlobalTypes->Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				End If
				If BaseTypeName <> "" Then
					If Types.Contains(BaseTypeName, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->StartLine <= iSelEndLine Then
						teEnum = Types.Object(Idx)
					ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Types, BaseTypeName, Idx, pFiles, pFileLines) Then
						teEnum = Globals->Types.Object(Idx)
					ElseIf ContainsInListFiles(pComps, BaseTypeName, Idx, pFiles, pFileLines) Then
						teEnum = pComps->Object(Idx)
					ElseIf ContainsInListFiles(pGlobalTypes, BaseTypeName, Idx, pFiles, pFileLines) Then
						teEnum = pGlobalTypes->Object(Idx)
					End If
					teEnumOld = 0
					OldTypeName = ""
					Return BaseTypeName
				End If
			End If
			If ContainsIn(TypeName, sTemp, @Types, pFiles, pFileLines, True, , , te, iSelEndLine) Then
			ElseIf ContainsIn(TypeName, sTemp, @Enums, pFiles, pFileLines, True, , , te, iSelEndLine) Then
			ElseIf ContainsIn(TypeName, sTemp, @Namespaces, pFiles, pFileLines, True, , , te, iSelEndLine) Then
			ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Types, pFiles, pFileLines, True, , , te, iSelEndLine) Then
			ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Enums, pFiles, pFileLines, True, , , te, iSelEndLine) Then
			ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Namespaces, pFiles, pFileLines, True, , , te, iSelEndLine) Then
			ElseIf ContainsIn(TypeName, sTemp, pComps, pFiles, pFileLines, True, , , te) Then
			ElseIf ContainsIn(TypeName, sTemp, pGlobalTypes, pFiles, pFileLines, True, , , te) Then
			ElseIf ContainsIn(TypeName, sTemp, pGlobalEnums, pFiles, pFileLines, True, , , te) Then
			ElseIf ContainsIn(TypeName, sTemp, pGlobalNamespaces, pFiles, pFileLines, True, , , te) Then
			End If
			If te Then
				OldTypeName = TypeName
			End If
		Else
			te1 = teC
			If teC > 0 Then TypeName = TypeNameFromLine
			If LCase(sTemp) = "this" Then
				Return TypeName
			ElseIf LCase(sTemp) = "base" Then
				If Types.Contains(TypeName, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->StartLine <= iSelEndLine Then
					te2 = Types.Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Types, TypeName, Idx, pFiles, pFileLines) Then
					te2 = Globals->Types.Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				ElseIf ContainsInListFiles(pComps, TypeName, Idx, pFiles, pFileLines) Then
					te2 = pComps->Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				ElseIf ContainsInListFiles(pGlobalTypes, TypeName, Idx, pFiles, pFileLines) Then
					te2 = pGlobalTypes->Object(Idx)
					If te2 <> 0 Then BaseTypeName = te2->TypeName
				End If
				If BaseTypeName <> "" Then
					If Types.Contains(BaseTypeName, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->StartLine <= iSelEndLine Then
						teEnum = Types.Object(Idx)
					ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Types, BaseTypeName, Idx, pFiles, pFileLines) Then
						teEnum = Globals->Types.Object(Idx)
					ElseIf ContainsInListFiles(pComps, BaseTypeName, Idx, pFiles, pFileLines) Then
						teEnum = pComps->Object(Idx)
					ElseIf ContainsInListFiles(pGlobalTypes, BaseTypeName, Idx, pFiles, pFileLines) Then
						teEnum = pGlobalTypes->Object(Idx)
					End If
					teEnumOld = 0
					OldTypeName = ""
					Return BaseTypeName
				End If
			End If
			Var tIndex = -1
			If (Not TwoDots) AndAlso tIndex = -1 AndAlso teC > 0 AndAlso teC->StartLine <> iSelEndLine Then 'AndAlso LCase(OldMatn) <> "as"
				Var tIndex = teC->Elements.IndexOf(LCase(sTemp))
				If tIndex <> -1 Then
					Var pkeywords = @teC->Elements
					teEnum = pkeywords->Object(tIndex)
					teEnumOld = teC
					OldTypeName = "" 'teC->DisplayName
					sTemp = teEnum->TypeName
					If sTemp = "" AndAlso teEnum->Value <> "" Then
						sTemp = GetTypeFromValue(teEnum->Value, iSelEndLine)
					End If
					Return sTemp
				Else
					TypeName = teC->OwnerTypeName
					'Pos1 = InStr(TypeName, ".")
					'If CBool(Pos1 > 0) OrElse EndsWith(teC->DisplayName, "[Constructor]") OrElse EndsWith(teC->DisplayName, "[Destructor]") Then
					If Len(TypeName) > 0 Then
						'If Pos1 > 0 Then
						'	TypeName = ..Left(TypeName, Pos1 - 1)
						'Else
						'	TypeName = teC->Name
						'End If
						If ContainsIn(TypeName, sTemp, @Types, pFiles, pFileLines, True, , , te, iSelEndLine) Then
						ElseIf ContainsIn(TypeName, sTemp, @Enums, pFiles, pFileLines, True, , , te, iSelEndLine) Then
						ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Types, pFiles, pFileLines, True, , , te) Then
						ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Enums, pFiles, pFileLines, True, , , te) Then
						ElseIf ContainsIn(TypeName, sTemp, pComps, pFiles, pFileLines, True, , , te) Then
						ElseIf ContainsIn(TypeName, sTemp, pGlobalTypes, pFiles, pFileLines, True, , , te) Then
						ElseIf ContainsIn(TypeName, sTemp, pGlobalEnums, pFiles, pFileLines, True, , , te) Then
						End If
						If te > 0 Then
							tIndex = 0
							teEnum = te
							'teEnumOld = teC
							OldTypeName = TypeName
							Return teEnum->TypeName
						End If
					End If
				End If
			End If
			If tIndex = -1 Then
				If ECLine->InConstructionBlock Then
					te = GetFromConstructionBlock(ECLine->InConstructionBlock, sTemp, iSelEndLine)
					If te Then
						If te->TypeName = "" AndAlso te->Value <> "" Then
							Return GetTypeFromValue(te->Value, iSelEndLine)
						Else
							teEnum = te
							teEnumOld = 0
							OldTypeName = "" 'teC->DisplayName
							Return teEnum->TypeName
						End If
					End If
				End If
				If te1 <> 0 AndAlso te1->Elements.Contains(sTemp, , , , Idx) AndAlso Cast(TypeElement Ptr, te1->Elements.Object(Idx))->StartLine <= iSelEndLine Then
					te = te1->Elements.Object(Idx)
				ElseIf Procedures.Contains(sTemp, , , , Idx) AndAlso Cast(TypeElement Ptr, Procedures.Object(Idx))->StartLine <= iSelEndLine Then
					te = Procedures.Object(Idx)
				ElseIf ContainsInList(Args, sTemp, iSelEndLine, InCondition, Idx) Then
					te = Args.Object(Idx)
				ElseIf Namespaces.Contains(sTemp, , , , Idx) AndAlso Cast(TypeElement Ptr, Namespaces.Object(Idx))->StartLine <= iSelEndLine Then
					te = Namespaces.Object(Idx)
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Functions, sTemp, Idx, pFiles, pFileLines) Then
					te = Globals->Functions.Object(Idx)
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Args, sTemp, Idx, pFiles, pFileLines) Then
					te = Globals->Args.Object(Idx)
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Types, sTemp, Idx, pFiles, pFileLines) Then
					te = Globals->Types.Object(Idx)
				ElseIf (Globals <> 0) AndAlso ContainsInListFiles(@Globals->Namespaces, sTemp, Idx, pFiles, pFileLines) Then
					te = Globals->Namespaces.Object(Idx)
				ElseIf ContainsInListFiles(pGlobalFunctions, sTemp, Idx, pFiles, pFileLines) Then
					te = pGlobalFunctions->Object(Idx)
				ElseIf ContainsInListFiles(pGlobalArgs, sTemp, Idx, pFiles, pFileLines) Then
					te = pGlobalArgs->Object(Idx)
				ElseIf ContainsInListFiles(pGlobalTypes, sTemp, Idx, pFiles, pFileLines) Then
					te = pGlobalTypes->Object(Idx)
				ElseIf ContainsInListFiles(pGlobalNamespaces, sTemp, Idx, pFiles, pFileLines) Then
					te = pGlobalNamespaces->Object(Idx)
				ElseIf TypeName <> "" Then
					If ContainsIn(TypeName, sTemp, @Types, pFiles, pFileLines, True, , , te, iSelEndLine) Then
					ElseIf ContainsIn(TypeName, sTemp, @Enums, pFiles, pFileLines, True, , , te, iSelEndLine) Then
					ElseIf ContainsIn(TypeName, sTemp, @Namespaces, pFiles, pFileLines, True, , , te, iSelEndLine) Then
					ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Types, pFiles, pFileLines, True, , , te) Then
					ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Enums, pFiles, pFileLines, True, , , te) Then
					ElseIf (Globals <> 0) AndAlso ContainsIn(TypeName, sTemp, @Globals->Namespaces, pFiles, pFileLines, True, , , te) Then
					ElseIf ContainsIn(TypeName, sTemp, pComps, pFiles, pFileLines, True, , , te) Then
					ElseIf ContainsIn(TypeName, sTemp, pGlobalTypes, pFiles, pFileLines, True, , , te) Then
					ElseIf ContainsIn(TypeName, sTemp, pGlobalEnums, pFiles, pFileLines, True, , , te) Then
					ElseIf ContainsIn(TypeName, sTemp, pGlobalNamespaces, pFiles, pFileLines, True, , , te) Then
					End If
					If te Then
						OldTypeName = TypeName
					End If
				End If
			End If
		End If
		If te <> 0 Then
			sTemp = te->TypeName
			If te->ElementType = E_Namespace OrElse te->ElementType = E_Type OrElse te->ElementType = E_TypeCopy OrElse te->ElementType = E_Union OrElse te->ElementType = E_Enum Then
				sTemp = te->Name
			Else
				Pos1 = InStrRev(sTemp, ".")
				If Pos1 > 0 Then sTemp = Mid(sTemp, Pos1 + 1)
			End If
			If sTemp = "" AndAlso te->Value <> "" Then
				sTemp = GetTypeFromValue(te->Value, iSelEndLine)
			End If
		End If
		teEnum = te
		Return sTemp
	End Function
	
	Function EditControlContent.IndexOfInList(List As WStringOrStringList, ByRef Matn As String, SelEndLine As Integer, ByRef InCondition As String) As Integer
		Dim As Integer tIndex = List.IndexOf(Matn)
		If tIndex > -1 Then
			Dim As TypeElement Ptr te = List.Object(tIndex)
			For i As Integer = tIndex To List.Count - 1
				te = List.Object(i)
				If te->StartLine > SelEndLine Then Return -1
				If LCase(te->Name) <> LCase(Matn) Then Return -1
				If InCondition <> "" Then
					If (LCase(te->InCondition) = LCase("Not " & InCondition)) OrElse (LCase(InCondition) = LCase("Not " & te->InCondition)) Then Continue For
				End If
				Return i
			Next
		End If
		Return -1
	End Function
	
	Function EditControlContent.ContainsInList(List As WStringOrStringList, ByRef Matn As String, SelEndLine As Integer, ByRef InCondition As String, ByRef Index As Integer) As Boolean
		Index = IndexOfInList(List, Matn, SelEndLine, InCondition)
		Return Index <> -1
	End Function
	
	Function EditControlContent.IndexOfInListFiles(pList As WStringOrStringList Ptr, ByRef Matn As String, Files As WStringList Ptr, FileLines As IntegerList Ptr) As Integer
		If pList = 0 OrElse Files = 0 OrElse FileLines = 0 Then Return -1
		Dim As Integer tIndex = pList->IndexOf(Matn)
		Var Idx = -1, iLine = -1
		If tIndex > -1 Then
			Dim As TypeElement Ptr te = pList->Object(tIndex)
			If te->ElementType = E_Namespace Then Return tIndex
			For i As Integer = tIndex To pList->Count - 1
				te = pList->Object(i)
				If LCase(te->Name) <> LCase(Matn) Then Return -1
				If Not Files->Contains(te->FileName, , , , Idx) Then Continue For
				iLine = FileLines->Item(Idx)
				If iLine <> -1 AndAlso te->StartLine > iLine Then Continue For
				Return i
			Next
		End If
		Return -1
	End Function
	
	Function EditControlContent.ContainsInListFiles(pList As WStringOrStringList Ptr, ByRef Matn As String, ByRef Index As Integer, Files As WStringList Ptr, FileLines As IntegerList Ptr) As Boolean
		Index = IndexOfInListFiles(pList, Matn, Files, FileLines)
		Return Index <> -1
	End Function
	
	Constructor EditControlContent
		Types.Sorted = True
		Enums.Sorted = True
		Functions.Sorted = True
		Procedures.Sorted = True
		TypeProcedures.Sorted = True
		Args.Sorted = True
		CheckedFiles.Sorted = True
	End Constructor
	
	Constructor GlobalTypeElements
		Namespaces.Sorted = True
		Types.Sorted = True
		Enums.Sorted = True
		Functions.Sorted = True
		TypeProcedures.Sorted = True
		Args.Sorted = True
	End Constructor
	
	Sub EditControl.PaintControlPriv(Full As Boolean = False)
		'	On Error Goto ErrHandler
		Dim As Boolean bFull = Full
		#ifdef __USE_GTK__
			If cr = 0 Then Exit Sub
		#else
			Dim As Boolean bFontChanged
			hd = GetDC(FHandle)
			If CurrentFontSize <> EditorFontSize OrElse *CurrentFontName <> *EditorFontName Then
				This.Font.Name = *EditorFontName
				This.Font.Size = EditorFontSize
				FontSettings
				bFull = True
			End If
			If bufDC = 0 Then
				bufDC = CreateCompatibleDC(hd)
				bufBMP = CreateCompatibleBitmap(hd, ScaleX(dwClientX), ScaleY(dwClientY))
				This.Canvas.Handle = bufDC
				This.Canvas.HandleSetted = True
				SelectObject(bufDC, This.Font.Handle)
				SelectObject(bufDC, bufBMP)
			ElseIf OlddwClientX <> dwClientX OrElse OlddwClientY <> dwClientY Then
				DeleteDC bufDC
				DeleteObject bufBMP
				bufDC = CreateCompatibleDC(hd)
				bufBMP = CreateCompatibleBitmap(hd, ScaleX(dwClientX), ScaleY(dwClientY))
				This.Canvas.Handle = bufDC
				This.Canvas.HandleSetted = True
				SelectObject(bufDC, This.Font.Handle)
				SelectObject(bufDC, bufBMP)
			End If
			This.Canvas.Handle = bufDC
			This.Canvas.HandleSetted = True
			HideCaret(FHandle)
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
		'WithOldI = -1
		Dim As Integer PosiBD, tIndex, i, Pos1
		Dim As Boolean bKeyWord, bWithoutWith, TwoDots, OneDot
		Dim As WString * 255 OriginalCaseWord, OldTypeName, TypeName
		Dim As TypeElement Ptr te, Oldte
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
			For j As Integer = iSelEndLine To Content.Lines.Count - 1
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
		For zz As Integer = 0 To 1
			Dim As Integer HScrollPos, VScrollPos, CodePaneX, CodePaneY
			If CBool(zz = 0) AndAlso (Not bDividedX) AndAlso (Not bDividedY) Then
				Continue For
			End If
			HScrollPos = IIf(bDividedX AndAlso zz = 0, HScrollPosLeft, HScrollPosRight)
			VScrollPos = IIf(zz = 0, VScrollPosTop, VScrollPosBottom)
			If zz = 1 Then
				If bDividedY Then
					CodePaneY = iDividedY + 7
				ElseIf bDividedX Then
					CodePaneX = iDividedX + 7
				End If
			End If
			iC = 0
			vlc = Min(LinesCount, VScrollPos + VisibleLinesCount(zz) + 2)
			vlc1 = VisibleLinesCount(zz)
			IzohBoshi = 0
			QavsBoshi = 0
			MatnBoshi = 0
			Matn = ""
			#ifdef __USE_GTK__
				Dim As Double iRED, iGREEN, iBLUE
				If bDividedY Then
					If zz = 0 Then
						#ifdef __USE_GTK3__
							cairo_rectangle (cr, LeftMargin, 0.0, gtk_widget_get_allocated_width (widget), iDividedY, True)
						#else
							cairo_rectangle (cr, LeftMargin, 0.0, widget->allocation.Width, iDividedY, True)
						#endif
					Else
						#ifdef __USE_GTK3__
							cairo_rectangle (cr, LeftMargin, iDividedY + 7, gtk_widget_get_allocated_width (widget), gtk_widget_get_allocated_height(widget), True)
						#else
							cairo_rectangle (cr, LeftMargin, iDividedY + 7, widget->allocation.Width, widget->allocation.Height, True)
						#endif
					End If
				ElseIf bDividedX Then
					If zz = 0 Then
						#ifdef __USE_GTK3__
							cairo_rectangle (cr, LeftMargin, 0, iDividedX, gtk_widget_get_allocated_height(widget), True)
						#else
							cairo_rectangle (cr, LeftMargin, 0, iDividedX, widget->allocation.Height, True)
						#endif
					Else
						#ifdef __USE_GTK3__
							cairo_rectangle (cr, iDividedX + 7 + LeftMargin, 0, gtk_widget_get_allocated_width (widget), gtk_widget_get_allocated_height(widget), True)
						#else
							cairo_rectangle (cr, iDividedX + 7 + LeftMargin, 0, widget->allocation.Width, widget->allocation.Height, True)
						#endif
					End If
				Else
					#ifdef __USE_GTK3__
						cairo_rectangle (cr, LeftMargin, 0.0, gtk_widget_get_allocated_width (widget), gtk_widget_get_allocated_height (widget), True)
					#else
						cairo_rectangle (cr, LeftMargin, 0.0, widget->allocation.Width, widget->allocation.height, True)
					#endif
				End If
				cairo_set_source_rgb(cr, NormalText.BackgroundRed, NormalText.BackgroundGreen, NormalText.BackgroundBlue)
				cairo_fill (cr)
			#else
				'			This.Canvas.Font.Name = *EditorFontName
				'			This.Canvas.Font.Size = EditorFontSize
				This.Canvas.Brush.Color = NormalText.Background
				This.Canvas.Pen.Color = FoldLines.Foreground
				If bDividedY Then
					If zz = 0 Then
						SetRect(@rc, ScaleX(LeftMargin), 0, ScaleX(dwClientX), ScaleY(iDividedY))
					Else
						SetRect(@rc, ScaleX(LeftMargin), ScaleY(iDividedY + 7), ScaleX(dwClientX), ScaleY(dwClientY))
					End If
				ElseIf bDividedX Then
					If zz = 0 Then
						SetRect(@rc, ScaleX(LeftMargin), 0, ScaleX(iDividedX), ScaleY(dwClientY))
					Else
						SetRect(@rc, ScaleX(iDividedX + 7 + LeftMargin), 0, ScaleX(dwClientX), ScaleY(dwClientY))
					End If
				Else
					SetRect(@rc, ScaleX(LeftMargin), 0, ScaleX(dwClientX), ScaleY(dwClientY))
				End If
				'			SelectObject(bufDC, This.Canvas.Brush.Handle)
				'			SelectObject(bufDC, This.Canvas.Font.Handle)
				'			SelectObject(bufDC, This.Canvas.Pen.Handle)
				'			SetROP2 bufDC, This.Canvas.Pen.Mode
				If bFull OrElse OlddwClientX <> dwClientX OrElse OlddwClientY <> dwClientY OrElse OldPaintedVScrollPos(zz) <> VScrollPos OrElse OldPaintedHScrollPos(zz) <> HScrollPos OrElse iOldDivideY <> iDivideY OrElse iOldDividedY <> iDividedY OrElse iOldDivideX <> iDivideX OrElse iOldDividedX <> iDividedX OrElse CInt(bOldDividedX <> bDividedX) OrElse CInt(bOldDividedY <> bDividedY) Then
					FillRect bufDC, @rc, This.Canvas.Brush.Handle
				End If
			#endif
			i = -1
			Var OldI = i
			If VScrollPos > 0 AndAlso VScrollPos <= Content.Lines.Count Then iC = Cast(EditControlLine Ptr, Content.Lines.Items[VScrollPos - 1])->CommentIndex
			CollapseIndex = 0
			OldCollapseIndex = 0
			'ChangeCase = False
			OldMatnLCase = ""
			For z As Integer = 0 To Content.Lines.Count - 1
				FECLine = Content.Lines.Items[z]
				Dim As WStringList Ptr pFiles = FECLine->FileList
				Dim As IntegerList Ptr pFileLines = FECLine->FileListLines
				If z < Content.Lines.Count - 1 Then
					FECLineNext = Content.Lines.Items[z + 1]
				Else
					FECLineNext = 0
				End If
				For ii As Integer = 0 To FECLine->Statements.Count - 1
					FECStatement = FECLine->Statements.Items[ii]
					If FECStatement->ConstructionIndex >= 0 AndAlso Constructions(FECStatement->ConstructionIndex).Collapsible Then
						If FECStatement->ConstructionPart = 0 Then
							CollapseIndex += 1
						ElseIf FECStatement->ConstructionPart = 1 Then
							CollapseIndex -= FECStatement->ConstructionPartCount
						ElseIf FECStatement->ConstructionPart = 2 Then
							CollapseIndex = Max(0, CollapseIndex - 1 - FECStatement->ConstructionPartCount)
						End If
					End If
				Next ii
				If Not FECLine->Visible Then OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Continue For
				i = i + 1
				If i < VScrollPos Then OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Continue For
				If i - VScrollPos > vlc1 - 1 Then Exit For
				OldI = i
				#ifdef __USE_WINAPI__
					If bFull = False AndAlso OlddwClientX = dwClientX AndAlso OlddwClientY = dwClientY AndAlso OldPaintedVScrollPos(zz) = VScrollPos AndAlso OldPaintedHScrollPos(zz) = HScrollPos AndAlso iOldDivideY = iDivideY AndAlso iOldDividedY = iDividedY AndAlso iOldDivideX = iDivideX AndAlso iOldDividedX = iDividedX AndAlso CInt(bOldDividedX = bDividedX) AndAlso CInt(bOldDividedY = bDividedY) Then
						If (z < iSelStartLine OrElse z > iSelEndLine) AndAlso (z < iOldSelStartLine OrElse z > iOldSelEndLine) AndAlso BracketsStartLine <> z AndAlso BracketsEndLine <> z AndAlso OldBracketsStartLine <> z AndAlso OldBracketsEndLine <> z AndAlso OldExecutedLine <> z AndAlso CInt(bInIncludeFileRectOld = bInIncludeFileRect) Then
							' AndAlso (z <> FSelEndLine + 1)
							If CurWord <> "" OrElse OldCurWord <> "" Then
								If (CurWord = "" OrElse CurWord <> "" AndAlso InStr(LCase(*FECLine->Text), LCase(CurWord)) = 0) AndAlso (OldCurWord = "" OrElse OldCurWord <> "" AndAlso InStr(LCase(*FECLine->Text), LCase(OldCurWord)) = 0) Then
									OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Continue For
								End If
							Else
								OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Continue For
							End If
						End If
						This.Canvas.Brush.Color = NormalText.Background
						This.Canvas.Pen.Color = FoldLines.Foreground
						rc = Type(ScaleX(Max(-1, LeftMargin + -HScrollPos * dwCharX) + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + CodePaneY), ScaleX(IIf(bDividedX AndAlso zz = 0, iDividedX, This.Width)), ScaleY((i - VScrollPos) * dwCharY + dwCharY + 1 + CodePaneY))
						FillRect bufDC, @rc, This.Canvas.Brush.Handle
					End If
				#endif
				If z > 0 Then iC = Cast(EditControlLine Ptr, Content.Lines.Items[z - 1])->CommentIndex
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
							ElseIf iC = 0 AndAlso (Mid(*s, j, 1) = "'" OrElse LCase(Mid(" " & *s & " ", j, 5)) = " rem " OrElse LCase(Mid(" " & *s & " ", j, 6)) = " @rem " OrElse LCase(Mid(" " & *s & " ", j - 1, 5)) = !"\trem ") Then
								Exit Do
							End If
						End If
						j = j + 1
					Loop
				Else
					'				#ifndef __USE_GTK__
					'					SelectObject(bufDC, This.Canvas.Brush.Handle)
					'					SelectObject(bufDC, This.Canvas.Pen.Handle)
					'				#endif
					LinePrinted = False
					If FECLine->Breakpoint Then
						PaintText zz, i, *s, 0, Len(*s), Breakpoints, "", Breakpoints.Bold, Breakpoints.Italic, Breakpoints.Underline
						LinePrinted = True
					End If
					If CurExecutedLine = z AndAlso CurEC <> 0 Then
						PaintText zz, i, *s, Len(*s) - Len(LTrim(*s, Any !"\t ")), Len(*s), IIf(CurEC = @This, ExecutionLine, CurrentLine), ""
						LinePrinted = True
					End If
					If Not SyntaxEdit Then
						PaintText zz, i, *s, 0, Len(*s), NormalText, "", NormalText.Bold, NormalText.Italic, NormalText.Underline
						LinePrinted = True
					End If
					If Not LinePrinted Then
						If FECLine->EndsCompleted Then
							Var OldJ = 0
							Dim As ECColorScheme Ptr ecc
							For j As Integer = 0 To FECLine->Ends.Count - 1
								ecc = FECLine->Ends.Object(j)
								PaintText zz, i, *s, OldJ, FECLine->Ends.Item(j), *ecc, , ecc->Bold, ecc->Italic, CBool(ecc->Underline) OrElse CBool(ecc = @Strings) AndAlso CBool(bInIncludeFileRect) AndAlso CBool(iCursorLine = z)
								OldJ = FECLine->Ends.Item(j)
							Next
						Else
							'					Canvas.Font.Bold = False
							'					Canvas.Font.Italic = False
							'					Canvas.Font.Underline = False
							'#ifndef __USE_GTK__
							'SelectObject(bufDC, This.Canvas.Font.Handle)
							'#endif
							IzohBoshi = 1
							Do While j <= l
								'If LeftMargin + (-HScrollPos + j) * dwCharX > dwClientX AndAlso Mid(*s, j, 1) = " " Then
								'	If iC = 0 AndAlso FECLine->CommentIndex > 0 Then IzohBoshi = j + 1
								'	OldCollapseIndex = CollapseIndex: iC = FECLine->CommentIndex: Exit Do
								'End If
								If iC = 0 AndAlso Mid(*s, j, 1) = """" Then
									bQ = Not bQ
									If bQ Then
										QavsBoshi = j
									Else
										'								If StringsBold Then Canvas.Font.Bold = True
										'								If StringsItalic Then Canvas.Font.Italic = True
										'								If StringsUnderline OrElse bInIncludeFileRect AndAlso iCursorLine = z Then Canvas.Font.Underline = True: SelectObject(bufDC, This.Canvas.Font.Handle)
										PaintText zz, i, *s, QavsBoshi - 1, j, Strings, , Strings.Bold, Strings.Italic, CBool(Strings.Underline) Or CBool(bInIncludeFileRect) And CBool(iCursorLine = z)
										'txtCode.SetSel ss + QavsBoshi - 1, ss + j
										'txtCode.SelColor = clMaroon
									End If
								ElseIf Not bQ Then
									If Mid(*s, j, 2) = IIf(Content.CStyle, "/*", "/'") Then
										iC = iC + 1
										If iC = 1 Then
											IzohBoshi = j
										End If
										j = j + 1
									ElseIf iC > 0 AndAlso Mid(*s, j, 2) = IIf(Content.CStyle, "*/", "'/") Then
										iC = iC - 1
										j = j + 1
										If iC = 0 Then
											PaintText zz, i, *s, IzohBoshi - 1, j, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
										End If
									ElseIf iC = 0 Then
										t = Asc(Mid(*s, j, 1))
										u = Asc(Mid(*s, j + 1, 1))
										If LCase(Mid(" " & *s & " ", j, 5)) = " rem " OrElse LCase(Mid(" " & *s & " ", j, 6)) = " @rem " OrElse LCase(Mid(" " & *s & " ", j, 5)) = !"\trem " Then
											If CInt(ChangeKeyWordsCase) AndAlso CInt(FSelEndLine <> z) AndAlso pkeywords2 <> 0 Then
												If Not Content.CStyle Then
													KeyWord = GetKeyWordCase("rem", pkeywords2)
													If KeyWord <> Mid(*s, j, 3) Then Mid(*s, j, 3) = KeyWord
												End If
											End If
											PaintText zz, i, *s, j - 1, l, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
											Exit Do
										ElseIf t >= 48 AndAlso t <= 57 OrElse t >= 65 AndAlso t <= 90 OrElse t >= 97 AndAlso t <= 122 OrElse (CInt(FECLine->InAsm = False) AndAlso t = Asc("#")) OrElse t = Asc("$") OrElse t = Asc("_") Then
											If MatnBoshi = 0 Then MatnBoshi = j
											If Not (u >= 48 AndAlso u <= 57 OrElse u >= 65 AndAlso u <= 90 OrElse u >= 97 AndAlso u <= 122 OrElse u = Asc("#") OrElse u = Asc("$") OrElse u = Asc("_")) Then
												'If LeftMargin + (-HScrollPos + j + InStrCount(..Left(*s, j), !"\t") * (TabWidth - 1)) * dwCharX > 0 Then
												Matn = Mid(*s, MatnBoshi, j - MatnBoshi + 1)
												MatnLCase = LCase(Matn)
												If InStr("#$", .Left(Matn, 1)) Then
													MatnLCaseWithoutOldSymbol = Mid(MatnLCase, 2)
													MatnWithoutOldSymbol = Mid(Matn, 2)
													WithOldSymbol = True
												Else
													MatnLCaseWithoutOldSymbol = MatnLCase
													MatnWithoutOldSymbol = Matn
													WithOldSymbol = False
												End If
												bTypeAs = StartsWith(LCase(Trim(*s, Any !"\t ")), "type ") AndAlso OldMatnLCase = "as"
												sc = @Identifiers
												OriginalCaseWord = "":   TypeName = "" : te = 0
												If MatnBoshi > 0 Then r = Asc(Mid(*s, MatnBoshi - 1, 1)) Else r = 0 '  ' "->"=45-62
												If MatnBoshi > 1 Then q = Asc(Mid(*s, MatnBoshi - 2, 1)) Else q = 0
												pkeywords = 0
												If Content.CStyle Then
													If MatnLCase = "#define" OrElse MatnLCase = "#include" OrElse MatnLCase = "#macro" Then
														If pkeywords0 <> 0 Then
															sc = @Keywords(KeywordLists.IndexOfObject(pkeywords0)) '@Preprocessors
														End If
													End If
												Else
													bKeyWord = False
													tIndex  = -1
													OriginalCaseWord = ""
													bInAsm = (FECLine->InAsm OrElse StartsWith(LCase(Trim(*s, Any !"\t ")), "asm")) AndAlso CBool(MatnLCase <> "asm")
													If bInAsm Then
														tIndex = pkeywordsAsm->IndexOf(MatnLCase)
														If tIndex > -1 Then
															sc = @Keywords(KeywordLists.IndexOfObject(pkeywordsAsm)) '@Asm
															OriginalCaseWord = pkeywordsAsm->Item(tIndex)
															bKeyWord = True
														End If
													End If
													TwoDots = CBool(r = 46 AndAlso q = 46)
													OneDot = False
													bWithoutWith = False
													
													'Membership
													If ChangeIdentifiersCase OrElse SyntaxHighlightingIdentifiers Then
														If Not bInAsm Then
															If CBool(tIndex = -1) AndAlso (Not TwoDots) AndAlso (CBool(r = 46) OrElse CBool(q = 45 AndAlso r = 62)) Then
																OneDot = True
																Content.GetLeftArgTypeName(z, j, te, , OldTypeName, , bWithoutWith)
																If bWithoutWith Then
																	TwoDots = True
																	OneDot = False
																ElseIf te > 0 Then
																	tIndex = 0
																	OriginalCaseWord = te->Name
																	If SyntaxHighlightingIdentifiers Then
																		Select Case te->ElementType
																		Case E_EnumItem
																			sc = @ColorEnumMembers
																		Case E_Sub
																			sc = @ColorSubs
																		Case E_Function
																			sc = @ColorGlobalFunctions
																		Case E_Property
																			sc = @ColorProperties
																		Case E_Field, E_Event
																			sc = @ColorFields
																		Case E_Namespace
																			sc = @ColorGlobalNamespaces
																		Case E_Type, E_TypeCopy
																			sc = @ColorGlobalTypes
																		Case E_Enum
																			sc = @ColorGlobalEnums
																		Case E_Define
																			sc = @ColorDefines
																		Case E_Macro
																			sc = @ColorMacros
																		Case Else
																			sc = @ColorLocalVariables
																		End Select
																	End If
																End If
																
																If tIndex = -1 Then
																	tIndex = Content.Defines.IndexOf(MatnLCase)
																	If tIndex <> -1 Then
																		If Cast(TypeElement Ptr, Content.Defines.Object(tIndex))->StartLine > z Then
																			tIndex = -1
																		Else
																			OriginalCaseWord = Content.Defines.Item(tIndex)
																			pkeywords = @Content.Defines
																			te = Content.Defines.Object(tIndex)
																			If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																				sc = @ColorDefines
																			End If
																		End If
																	End If
																End If
																
																If tIndex = -1 Then
																	tIndex = Content.IndexOfInListFiles(pGlobalDefines, MatnLCase, pFiles, pFileLines)
																	If tIndex <> -1 Then
																		te = pGlobalDefines->Object(tIndex)
																		OriginalCaseWord = pGlobalDefines->Item(tIndex)
																		pkeywords = pGlobalDefines
																		If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																			sc = @ColorDefines
																		End If
																	End If
																End If
															End If
														End If
															
														If Not OneDot Then
															If Not bInAsm Then
																If tIndex = -1 AndAlso OldMatnLCase <> "as" Then
																	For i As Integer = 0 To FECLine->Args.Count - 1
																		tIndex = Cast(TypeElement Ptr, FECLine->Args.Item(i))->Elements.IndexOf(MatnLCase)
																		If tIndex <> -1 Then
																			pkeywords = @Cast(TypeElement Ptr, FECLine->Args.Item(i))->Elements
																			OriginalCaseWord = pkeywords->Item(tIndex)
																			te = pkeywords->Object(tIndex)
																			If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																				Select Case te->ElementType
																				Case E_ByRefParameter
																					sc = @ColorByRefParameters
																				Case E_ByValParameter
																					sc = @ColorByValParameters
																				Case E_Field, E_Event
																					sc = @ColorFields
																				Case Else
																					sc = @ColorLocalVariables
																				End Select
																			End If
																			Exit For
																		End If
																	Next
																End If
															End If
																
															'Procedure
															If (Not TwoDots) AndAlso (tIndex = -1) AndAlso (FECLine->InConstructionBlock > 0) AndAlso ((OldMatnLCase <> "as") OrElse WithOldSymbol) Then
																te = GetFromConstructionBlock(FECLine->InConstructionBlock, MatnLCaseWithoutOldSymbol, z)
																If te > 0 Then
																	tIndex = 0
																	pkeywords = @Cast(ConstructionBlock Ptr, FECLine->InConstructionBlock)->Elements
																	OriginalCaseWord = te->Name
																	If SyntaxHighlightingIdentifiers Then
																		te->Used = (te->StartLine < z) OrElse MatnBoshi > te->StartChar
																		Select Case te->ElementType
																		Case E_Sub
																			sc = @ColorSubs
																		Case E_Function
																			sc = @ColorGlobalFunctions
																		Case E_Property
																			sc = @ColorProperties
																		Case E_ByRefParameter
																			sc = @ColorByRefParameters
																		Case E_ByValParameter
																			sc = @ColorByValParameters
																		Case E_Field, E_Event
																			sc = @ColorFields
																		Case E_EnumItem
																			sc = @ColorEnumMembers
																		Case E_LineLabel
																			sc = @ColorLineLabels
																		Case E_Define, E_Macro
																			sc = @ColorDefines
																		Case E_Macro
																			sc = @ColorMacros
																		Case Else
																			sc = @ColorLocalVariables
																		End Select
																	End If
																End If
															End If
																
															If (Not TwoDots) AndAlso tIndex = -1 AndAlso FECLine->InConstruction > 0 AndAlso ((OldMatnLCase <> "as") OrElse WithOldSymbol) Then
																tIndex = Cast(TypeElement Ptr, FECLine->InConstruction)->Elements.IndexOf(MatnLCaseWithoutOldSymbol)
																If tIndex <> -1 Then
																	If Cast(TypeElement Ptr, Cast(TypeElement Ptr, FECLine->InConstruction)->Elements.Object(tIndex))->StartLine > z AndAlso Cast(TypeElement Ptr, Cast(TypeElement Ptr, FECLine->InConstruction)->Elements.Object(tIndex))->ElementType <> E_LineLabel Then
																		tIndex = -1
																	Else
																		pkeywords = @Cast(TypeElement Ptr, FECLine->InConstruction)->Elements
																		OriginalCaseWord = pkeywords->Item(tIndex)
																		te = pkeywords->Object(tIndex)
																		If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																			Select Case te->ElementType
																			Case E_Sub
																				sc = @ColorSubs
																			Case E_Function
																				sc = @ColorGlobalFunctions
																			Case E_Property
																				sc = @ColorProperties
																			Case E_ByRefParameter
																				sc = @ColorByRefParameters
																			Case E_ByValParameter
																				sc = @ColorByValParameters
																			Case E_Field, E_Event
																				sc = @ColorFields
																			Case E_EnumItem
																				sc = @ColorEnumMembers
																			Case E_LineLabel
																				sc = @ColorLineLabels
																			Case Else
																				sc = @ColorLocalVariables
																			End Select
																		End If
																	End If
																End If
																
																If tIndex = -1 Then
																	te = FECLine->InConstruction
																	TypeName = te->OwnerTypeName
																	'Pos1 = InStr(TypeName, ".")
																	'If (CBool(Pos1 > 0) OrElse EndsWith(te->DisplayName, "[Constructor]") OrElse EndsWith(te->DisplayName, "[Destructor]")) AndAlso (CBool(FECLine->InConstruction->StartLine <> z) OrElse FECLine->InConstruction->Declaration) Then
																	If Len(TypeName) > 0 Then
																		'If Pos1 > 0 Then
																		'	TypeName = ..Left(TypeName, Pos1 - 1)
																		'Else
																		'	TypeName = te->Name
																		'End If
																		te = 0
																		If Content.ContainsIn(TypeName, MatnLCaseWithoutOldSymbol, @Content.Types, pFiles, pFileLines, True, , , te, z) Then
																		ElseIf Content.ContainsIn(TypeName, MatnLCaseWithoutOldSymbol, @Content.Enums, pFiles, pFileLines, True, , , te, z) Then
																		ElseIf Content.ContainsIn(TypeName, MatnLCaseWithoutOldSymbol, pComps, pFiles, pFileLines, True, , , te) Then
																		ElseIf Content.ContainsIn(TypeName, MatnLCaseWithoutOldSymbol, pGlobalTypes, pFiles, pFileLines, True, , , te) Then
																		ElseIf Content.ContainsIn(TypeName, MatnLCaseWithoutOldSymbol, pGlobalEnums, pFiles, pFileLines, True, , , te) Then
																		End If
																		If te > 0 Then
																			OriginalCaseWord = te->Name
																			tIndex = 0
																			If SyntaxHighlightingIdentifiers Then
																				Select Case te->ElementType
																				Case E_Sub
																					sc = @ColorSubs
																				Case E_Function
																					sc = @ColorGlobalFunctions
																				Case E_Property
																					sc = @ColorProperties
																				Case E_Field, E_Event
																					sc = @ColorFields
																				Case Else
																					sc = @ColorLocalVariables
																				End Select
																			End If
																		End If
																	End If
																End If
															End If
														End If
													End If
													
													If Not bInAsm Then
														If Not OneDot Then
															' Keywords
															If tIndex = -1 Then
																For k As Integer = 1 To KeywordLists.Count - 1
																	pkeywords = KeywordLists.Object(k)
																	tIndex = pkeywords->IndexOf(MatnLCase)
																	If tIndex > -1 Then
																		OriginalCaseWord = pkeywords->Item(tIndex)
																		sc = @Keywords(k)
																		bKeyWord = True
																		Exit For
																	End If
																	pkeywords = 0
																	tIndex = -1
																Next
															End If
														End If
													End If
														
													If WithOldSymbol AndAlso Not bKeyWord Then MatnLCase = MatnLCaseWithoutOldSymbol
													
													If ChangeIdentifiersCase OrElse SyntaxHighlightingIdentifiers Then
														If Not OneDot Then
															'Module
															If tIndex = -1 AndAlso ((OldMatnLCase <> "as") OrElse WithOldSymbol) Then
																tIndex = Content.Args.IndexOf(MatnLCase)
																If tIndex <> -1 Then
																	If Cast(TypeElement Ptr, Content.Args.Object(tIndex))->StartLine > z Then
																		tIndex = -1
																	Else
																		OriginalCaseWord = Content.Args.Item(tIndex)
																		pkeywords = @Content.Args
																		te = Content.Args.Object(tIndex)
																		If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																			Select Case te->ElementType
																			Case E_EnumItem
																				sc = @ColorEnumMembers
																			Case E_CommonVariable
																				sc = @ColorCommonVariables
																			Case E_Constant
																				sc = @ColorConstants
																			Case E_SharedVariable
																				sc = @ColorSharedVariables
																			Case Else
																				sc = @ColorLocalVariables
																			End Select
																		End If
																	End If
																End If
															End If
															
															If Not bInAsm Then
																If tIndex = -1 Then
																	tIndex = Content.Procedures.IndexOf(MatnLCase)
																	If tIndex <> -1 Then
																		If Cast(TypeElement Ptr, Content.Procedures.Object(tIndex))->StartLine > z Then
																			tIndex = -1
																		Else
																			OriginalCaseWord = Content.Procedures.Item(tIndex)
																			pkeywords = @Content.Procedures
																			te = Content.Procedures.Object(tIndex)
																			If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																				Select Case te->ElementType
																				Case E_Constructor, E_Destructor
																					sc = @ColorGlobalTypes
																				Case E_Function
																					sc = @ColorGlobalFunctions
																				Case E_Sub
																					sc = @ColorSubs
																				Case E_Define
																					sc = @ColorDefines
																				Case E_Macro
																					sc = @ColorMacros
																				Case E_Property
																					sc = @ColorProperties
																				End Select
																			End If
																		End If
																	End If
																End If
																
																If tIndex = -1 Then
																	tIndex = Content.Types.IndexOf(MatnLCase)
																	If tIndex <> -1 Then
																		If (Not bTypeAs) AndAlso Cast(TypeElement Ptr, Content.Types.Object(tIndex))->StartLine > z Then
																			tIndex = -1
																		Else
																			If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalTypes
																			OriginalCaseWord = Content.Types.Item(tIndex)
																			pkeywords = @Content.Types
																		End If
																	End If
																End If
																
																If tIndex = -1 Then
																	tIndex = Content.Enums.IndexOf(MatnLCase)
																	If tIndex <> -1 Then
																		If (Not bTypeAs) AndAlso Cast(TypeElement Ptr, Content.Enums.Object(tIndex))->StartLine > z Then
																			tIndex = -1
																		Else
																			If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalEnums
																			OriginalCaseWord = Content.Enums.Item(tIndex)
																			pkeywords = @Content.Enums
																		End If
																	End If
																End If
																
																If tIndex = -1 Then
																	tIndex = Content.Namespaces.IndexOf(MatnLCase)
																	If tIndex <> -1 Then
																		If Cast(TypeElement Ptr, Content.Namespaces.Object(tIndex))->StartLine > z Then
																			tIndex = -1
																		Else
																			If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalNamespaces
																			OriginalCaseWord = Content.Namespaces.Item(tIndex)
																			pkeywords = @Content.Namespaces
																		End If
																	End If
																End If
																
																'Global
																If tIndex = -1 Then
																	If bTypeAs Then
																		tIndex = pComps->IndexOf(MatnLCase)
																	Else
																		tIndex = Content.IndexOfInListFiles(pComps, MatnLCase, pFiles, pFileLines)
																	End If
																	If tIndex <> -1 Then
																		If SyntaxHighlightingIdentifiers Then sc = @ColorComps
																		OriginalCaseWord = pComps->Item(tIndex)
																		pkeywords = pComps
																	End If
																End If
																
																If tIndex = -1 Then
																	If bTypeAs Then
																		tIndex = pGlobalTypes->IndexOf(MatnLCase)
																	Else
																		tIndex = Content.IndexOfInListFiles(pGlobalTypes, MatnLCase, pFiles, pFileLines)
																	End If
																	If tIndex <> -1 Then
																		If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalTypes
																		OriginalCaseWord = pGlobalTypes->Item(tIndex)
																		pkeywords = pGlobalTypes
																	End If
																End If
																
																If tIndex = -1 Then
																	If bTypeAs Then
																		tIndex = pGlobalEnums->IndexOf(MatnLCase)
																	Else
																		tIndex = Content.IndexOfInListFiles(pGlobalEnums, MatnLCase, pFiles, pFileLines)
																	End If
																	If tIndex <> -1 Then
																		If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalEnums
																		OriginalCaseWord = pGlobalEnums->Item(tIndex)
																		pkeywords = pGlobalEnums
																	End If
																End If
															End If
															
															If tIndex = -1 AndAlso OldMatnLCase <> "as" Then
																tIndex = Content.IndexOfInListFiles(pGlobalArgs, MatnLCase, pFiles, pFileLines)
																If tIndex <> -1 Then
																	te = pGlobalArgs->Object(tIndex)
																	OriginalCaseWord = pGlobalArgs->Item(tIndex)
																	pkeywords = pGlobalArgs
																	If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																		Select Case te->ElementType
																		Case E_EnumItem
																			sc = @ColorEnumMembers
																		Case E_CommonVariable
																			sc = @ColorCommonVariables
																		Case E_Constant
																			sc = @ColorConstants
																		Case E_SharedVariable
																			sc = @ColorSharedVariables
																		Case Else
																			sc = @ColorLocalVariables
																		End Select
																	End If
																End If
															End If
															
															If Not bInAsm Then
																If tIndex = -1 Then
																	tIndex = Content.IndexOfInListFiles(pGlobalFunctions, MatnLCase, pFiles, pFileLines)
																	If tIndex <> -1 Then
																		te = pGlobalFunctions->Object(tIndex)
																		OriginalCaseWord = pGlobalFunctions->Item(tIndex)
																		pkeywords = pGlobalFunctions
																		If te > 0 AndAlso SyntaxHighlightingIdentifiers Then
																			Select Case te->ElementType
																			Case E_Constructor, E_Destructor
																				sc = @ColorGlobalTypes
																			Case E_Keyword
																				sc = @ColorGlobalFunctions
																			Case E_Function
																				sc = @ColorGlobalFunctions
																			Case E_Sub
																				sc = @ColorSubs
																			Case E_Define
																				sc = @ColorDefines
																			Case E_Macro
																				sc = @ColorMacros
																			Case E_Property
																				sc = @ColorProperties
																			End Select
																		End If
																	End If
																End If
																
																If tIndex = -1 Then
																	tIndex = Content.IndexOfInListFiles(pGlobalNamespaces, MatnLCase, pFiles, pFileLines)
																	If tIndex <> -1 Then
																		If SyntaxHighlightingIdentifiers Then sc = @ColorGlobalNamespaces
																		OriginalCaseWord = pGlobalNamespaces->Item(tIndex)
																		pkeywords = pGlobalNamespaces
																	End If
																End If
															End If
																
															If tIndex = -1 Then
																tIndex = Content.LineLabels.IndexOf(MatnLCase)
																If tIndex <> -1 Then
																	If SyntaxHighlightingIdentifiers Then sc = @ColorLineLabels
																	OriginalCaseWord = Content.LineLabels.Item(tIndex)
																	pkeywords = @Content.LineLabels
																End If
															End If
														End If
													End If
													If bKeyWord AndAlso ChangeKeyWordsCase AndAlso MatnLCase = LCase(OriginalCaseWord) AndAlso FSelEndLine <> z Then
														KeyWord = GetKeyWordCase(Matn, 0, OriginalCaseWord)
														If KeyWord <> Matn Then
															Mid(*FECLine->Text, MatnBoshi, j - MatnBoshi + 1) = KeyWord
														End If
													ElseIf (Not bKeyWord) AndAlso ChangeIdentifiersCase AndAlso MatnLCase = LCase(OriginalCaseWord) AndAlso tIndex <> -1 AndAlso FSelEndLine <> z Then
														If MatnWithoutOldSymbol <> OriginalCaseWord Then
															Mid(*FECLine->Text, MatnBoshi + IIf(WithOldSymbol, 1, 0), j - MatnBoshi + 1) = OriginalCaseWord
														End If
													ElseIf tIndex = -1 Then
														If isNumeric(Matn) OrElse isNumeric(MatnWithoutOldSymbol) Then
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
												OldMatnLCase = MatnLCase: Oldte = te
												If (Not bKeyWord) AndAlso WithOldSymbol Then
													PaintText zz, i, *s, MatnBoshi - 1, MatnBoshi, NormalText
													PaintText zz, i, *s, MatnBoshi, j, *sc
												Else
													PaintText zz, i, *s, MatnBoshi - 1, j, *sc
												End If
												'End If
												MatnBoshi = 0
											End If
										ElseIf IIf(Content.CStyle, Mid(*s, j, 2) = "//", IIf(FECLine->InAsm, Chr(t) = "#" OrElse Chr(t) = "'", Chr(t) = "'")) Then
											PaintText zz, i, *s, j - 1, l, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
											'txtCode.SetSel ss + j - 1, ss + l
											'txtCode.SelColor = clGreen
											Exit Do
										ElseIf CharType(Mid(*s, j, 1)) = 2 Then
											PaintText zz, i, *s, j - 1, j, ColorOperators
										ElseIf Chr(t) <> " " Then
											PaintText zz, i, *s, j - 1, j, NormalText
										End If
									End If
								End If
								j = j + 1
							Loop
							If iC > 0 Then
								PaintText zz, i, *s, Max(0, IzohBoshi - 1), l, Comments, , Comments.Bold, Comments.Italic, Comments.Underline
								'txtCode.SetSel IzohBoshi - 1, ss + l
								'txtCode.SelColor = clGreen
								'If i = EndLine Then k = txtCode.LinesCount
							ElseIf bQ Then
								'						If StringsBold Then Canvas.Font.Bold = True
								'						If StringsItalic Then Canvas.Font.Italic = True
								'						If StringsUnderline OrElse bInIncludeFileRect AndAlso iCursorLine = z Then Canvas.Font.Underline = True: SelectObject(bufDC, This.Canvas.Font.Handle)
								PaintText zz, i, *s, QavsBoshi - 1, j, Strings, , Strings.Bold, Strings.Italic, Strings.Underline Or bInIncludeFileRect And CBool(iCursorLine = z)
							End If
							If CurExecutedLine <> i AndAlso OldExecutedLine <> i Then FECLine->EndsCompleted = True
						End If
					End If
					If zz = ActiveCodePane AndAlso CInt(HighlightCurrentLine) AndAlso CInt(CInt(z = FSelEndLine + 1) OrElse CInt(z = FSelEndLine)) Then ' AndAlso z = Content.Lines.Count - 1
						Dim As ..Rect rec
						If z = FSelEndLine + 1 Then
							rec = Type(ScaleX(Max(-1, LeftMargin + -HScrollPos * dwCharX) + CodePaneX), ScaleY((i - VScrollPos - 1) * dwCharY + dwCharY + 1 + CodePaneY), ScaleX(IIf(bDividedX AndAlso zz = 0, iDividedX, This.Width)), ScaleY((i - VScrollPos - 1) * dwCharY + dwCharY + 1 + CodePaneY))
							#ifdef __USE_GTK__
								cairo_set_source_rgb(cr, CurrentLine.FrameRed, CurrentLine.FrameGreen, CurrentLine.FrameBlue)
								cairo_rectangle (cr, rec.Left, rec.Top, rec.Right, rec.Bottom, True)
								cairo_stroke(cr)
							#else
								This.Canvas.Pen.Color = CurrentLine.Frame
								'SelectObject bufDC, This.Canvas.Pen.Handle
								MoveToEx bufDC, rec.Left, rec.Top - 1, 0
								LineTo bufDC, rec.Right, rec.Top - 1
							#endif
						Else
							rec = Type(ScaleX(Max(-1, LeftMargin + -HScrollPos * dwCharX) + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + CodePaneY), ScaleX(IIf(bDividedX AndAlso zz = 0, iDividedX, This.Width)), ScaleY((i - VScrollPos) * dwCharY + dwCharY + 1 + CodePaneY))
							#ifdef __USE_GTK__
								cairo_set_source_rgb(cr, CurrentLine.FrameRed, CurrentLine.FrameGreen, CurrentLine.FrameBlue)
								cairo_rectangle (cr, rec.Left, rec.Top, rec.Right, rec.Bottom, True)
								cairo_stroke(cr)
							#else
								This.Canvas.Brush.Color = CurrentLine.Frame
								FrameRect bufDC, @rec, This.Canvas.Brush.Handle
							#endif
						End If
					End If
					If zz = ActiveCodePane AndAlso (FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar) Then
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
							PaintText zz, i, *s, IIf(iSelStartLine = z, iSelStartChar, 0), IIf(iSelEndLine = z, iSelEndChar, Len(*s)), Selection, IIf(z <> iSelEndLine, " ", "")
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
							Dim As ..Rect rec = Type(ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsStart))) * (dwCharX) + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 1 + CodePaneY), ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsStart))) * (dwCharX) + dwCharX + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + dwCharY + CodePaneY))
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
							Dim As ..Rect rec = Type(ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsEnd))) * (dwCharX) + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 1 + CodePaneY), ScaleX(LeftMargin + -HScrollPos * dwCharX + Len(GetTabbedText(..Left(*s, BracketsEnd))) * (dwCharX) + dwCharX + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + dwCharY + CodePaneY))
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
							'SelectObject(bufDC, This.Canvas.Pen.Handle)
						#endif
						'WLet FLineLeft, GetTabbedText(*s, 0, True)
						jj = 1
						jPos = 0
						lLen = Len(*s)
						Do While jj <= lLen
							sChar = Mid(*s, jj, 1)
							If sChar = " " Then
								jPos += 1
								If LeftMargin + -HScrollPos * dwCharX + (jPos - 1) * (dwCharX) + dwCharX / 2 > 0 Then
									'WLet FLineLeft, GetTabbedText(Left(*s, jj - 1))
									#ifdef __USE_GTK__
										.cairo_rectangle(cr, LeftMargin + -HScrollPos * dwCharX + (jPos - 1) * (dwCharX) + dwCharX / 2 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 + CodePaneY, 1, 1)
										cairo_fill(cr)
									#else
										'GetTextExtentPoint32(bufDC, @Wstr(Left(*FLineLeft, jj - 1)), jj - 1, @Sz) 'Len(*FLineLeft)
										'SetPixel bufDC, LeftMargin + -HScrollPos * dwCharX + IIF(jPos = 0, 0, Sz.cx) + dwCharX / 2, (i - VScrollPos) * dwCharY + dwCharY / 2, clBtnShadow
										SetPixel bufDC, ScaleX(LeftMargin + -HScrollPos * dwCharX + (jPos - 1) * (dwCharX) + dwCharX / 2 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) + CodePaneY), SpaceIdentifiers.Foreground
									#endif
								End If
							ElseIf sChar = !"\t" Then
								jPP = TabWidth - (jPos + TabWidth) Mod TabWidth
								If LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX > 0 Then
									'WLet FLineLeft, GetTabbedText(Left(*s, jj - 1))
									#ifdef __USE_GTK__
										cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + 2 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5 + CodePaneY)
										cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 3 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5 + CodePaneY)
										cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 7 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 3 - 0.5 + CodePaneY)
										cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5 + CodePaneY)
										cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 7 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 + 3 - 0.5 + CodePaneY)
										cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5 + CodePaneY)
										cairo_stroke (cr)
									#else
										'GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @Sz)
										MoveToEx bufDC,   ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + 2 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) + CodePaneY), 0
										LineTo bufDC,     ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 3 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) + CodePaneY)
										MoveToEx bufDC,   ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 7 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) - 3 + CodePaneY), 0
										LineTo bufDC,     ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) + CodePaneY)
										MoveToEx bufDC,   ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 7 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) + 3 + CodePaneY), 0
										LineTo bufDC,     ScaleX(LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 4 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + Int(dwCharY / 2) + CodePaneY)
									#endif
								End If
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
					cairo_rectangle (cr, CodePaneX, (i - VScrollPos) * dwCharY + CodePaneY, LeftMargin - 25 + CodePaneX, (i - VScrollPos + 1) * dwCharY + CodePaneY, True)
					cairo_set_source_rgb(cr, LineNumbers.BackgroundRed, LineNumbers.BackgroundGreen, LineNumbers.BackgroundBlue)
					cairo_fill (cr)
					WLet(FLineLeft, WStr(z + 1))
					'Dim extend As cairo_text_extents_t
					'cairo_text_extents (cr, *FLineLeft, @extend)
					cairo_move_to(cr, LeftMargin - 30 - TextWidth(ToUtf8(*FLineLeft)) + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY - 5 + CodePaneY)
					cairo_set_source_rgb(cr, LineNumbers.ForegroundRed, LineNumbers.ForegroundGreen, LineNumbers.ForegroundBlue)
					pango_layout_set_text(layout, ToUtf8(*FLineLeft), Len(ToUtf8(*FLineLeft)))
					pango_cairo_update_layout(cr, layout)
					#ifdef pango_version
						Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
					#else
						Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
					#endif
					pango_cairo_show_layout_line(cr, pl)
					'cairo_show_text(cr, *FLineLeft)
				#else
					'SelectObject(bufDC, This.Canvas.Font.Handle)
					This.Canvas.Brush.Color = LineNumbers.Background
					SetRect(@rc, ScaleX(CodePaneX), ScaleY((i - VScrollPos) * dwCharY + CodePaneY), ScaleX(LeftMargin - 25 + CodePaneX), ScaleY((i - VScrollPos + 1) * dwCharY + CodePaneY))
					'SelectObject(bufDC, This.Canvas.Brush.Handle)
					FillRect bufDC, @rc, This.Canvas.Brush.Handle
					SetBkMode(bufDC, TRANSPARENT)
					WLet(FLineLeft, WStr(z + 1))
					GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @sz)
					SetTextColor(bufDC, LineNumbers.Foreground)
					TextOut(bufDC, ScaleX(LeftMargin - 25 + CodePaneX) - sz.cx, ScaleY((i - VScrollPos) * dwCharY + CodePaneY), FLineLeft, Len(*FLineLeft))
					SetBkMode(bufDC, OPAQUE)
				#endif
				This.Canvas.Brush.Color = NormalText.Background
				#ifdef __USE_GTK__
					cairo_rectangle(cr, LeftMargin - 25 + CodePaneX, (i - VScrollPos) * dwCharY + CodePaneY, LeftMargin + CodePaneX, (i - VScrollPos + 1) * dwCharY + CodePaneY, True)
					cairo_set_source_rgb(cr, NormalText.BackgroundRed, NormalText.BackgroundGreen, NormalText.BackgroundBlue)
					cairo_fill (cr)
				#else
					SetRect(@rc, ScaleX(LeftMargin - 25 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + CodePaneY), ScaleX(LeftMargin + CodePaneX), ScaleY(Min(IIf(bDividedY AndAlso zz = 0, iDividedY, (i - VScrollPos + 1) * dwCharY), (i - VScrollPos + 1) * dwCharY) + CodePaneY))
					FillRect bufDC, @rc, This.Canvas.Brush.Handle
				#endif
				If FECLine->Breakpoint Then
					This.Canvas.Pen.Color = IndicatorLines.Foreground
					This.Canvas.Brush.Color = Breakpoints.Indicator
					#ifdef __USE_GTK__
						cairo_set_source_rgb(cr, IndicatorLines.ForegroundRed, IndicatorLines.ForegroundGreen, IndicatorLines.ForegroundBlue)
						cairo_arc(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 8 - 0.5 + CodePaneY, 5, 0, 2 * G_PI)
						cairo_fill_preserve(cr)
						cairo_set_source_rgb(cr, Breakpoints.IndicatorRed, Breakpoints.IndicatorGreen, Breakpoints.IndicatorBlue)
						cairo_stroke(cr)
					#else
						SelectObject(bufDC, This.Canvas.Brush.Handle)
						SelectObject(bufDC, This.Canvas.Pen.Handle)
						Ellipse bufDC, ScaleX(2 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 2 + CodePaneY), ScaleX(dwCharY - 2 + CodePaneX), ScaleY((i - VScrollPos + 1) * dwCharY - 2 + CodePaneY)
					#endif
				End If
				If FECLine->Bookmark Then
					This.Canvas.Pen.Color = IndicatorLines.Foreground
					This.Canvas.Brush.Color = Bookmarks.Indicator
					#ifdef __USE_GTK__
						Var x = LeftMargin - 18, y = (i - VScrollPos) * dwCharY + 3
						Var width1 = 14, height1 = 10, radius = 2
						cairo_set_source_rgb(cr, Bookmarks.IndicatorRed, Bookmarks.IndicatorGreen, Bookmarks.IndicatorBlue)
						cairo_move_to cr, x - 0.5 + CodePaneX, y + radius - 0.5 + CodePaneY
						cairo_arc (cr, x + radius - 0.5 + CodePaneX, y + radius - 0.5 + CodePaneY, radius, G_PI, -G_PI / 2)
						cairo_line_to (cr, x + width1 - radius - 0.5 + CodePaneX, y - 0.5 + CodePaneY)
						cairo_arc (cr, x + width1 - radius - 0.5 + CodePaneX, y + radius - 0.5 + CodePaneY, radius, -G_PI / 2, 0)
						cairo_line_to (cr, x + width1 - 0.5 + CodePaneX, y + height1 - radius - 0.5 + CodePaneY)
						cairo_arc (cr, x + width1 - radius - 0.5 + CodePaneX, y + height1 - radius - 0.5 + CodePaneY, radius, 0, G_PI / 2)
						cairo_line_to (cr, x + radius - 0.5 + CodePaneX, y + height1 - 0.5 + CodePaneY)
						cairo_arc (cr, x + radius - 0.5 + CodePaneX, y + height1 - radius - 0.5 + CodePaneY, radius, G_PI / 2, G_PI)
						cairo_close_path cr
						cairo_fill_preserve(cr)
						cairo_set_source_rgb(cr, IndicatorLines.ForegroundRed, IndicatorLines.ForegroundGreen, IndicatorLines.ForegroundBlue)
						cairo_stroke(cr)
					#else
						'					SelectObject(bufDC, This.Canvas.Brush.Handle)
						'					SelectObject(bufDC, This.Canvas.Pen.Handle)
						RoundRect bufDC, ScaleX(2 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 4 + CodePaneY), ScaleX(dwCharY - 2 + CodePaneX), ScaleY((i - VScrollPos + 1) * dwCharY - 4 + CodePaneY), ScaleX(5), ScaleY(5)
					#endif
				End If
				#ifdef __USE_GTK__
					cairo_set_source_rgb(cr, FoldLines.ForegroundRed, FoldLines.ForegroundGreen, FoldLines.ForegroundBlue)
				#endif
				If SyntaxEdit AndAlso Not Content.CStyle Then
					If ShowHorizontalSeparatorLines AndAlso CBool(FECLineNext <> 0) AndAlso FECLineNext->Visible Then
						For ii As Integer = 0 To FECLineNext->Statements.Count - 1
							FECStatement = FECLineNext->Statements.Items[ii]
							If (FECStatement->ConstructionIndex >= C_P_Region) AndAlso (FECStatement->ConstructionPart = 0) Then
								#ifdef __USE_GTK__
									cairo_move_to(cr, LeftMargin - 0.5 + CodePaneX, (i + 1 - VScrollPos) * dwCharY - 0.5 + CodePaneY)
									cairo_line_to(cr, IIf(bDividedX AndAlso zz = 0, iDividedX, dwClientX) - 0.5, (i + 1 - VScrollPos) * dwCharY - 0.5 + CodePaneY)
									cairo_stroke (cr)
								#else
									This.Canvas.Pen.Color = FoldLines.Foreground
									MoveToEx bufDC, ScaleX(LeftMargin + CodePaneX), ScaleY((i + 1 - VScrollPos) * dwCharY + CodePaneY), 0
									LineTo bufDC, ScaleX(IIf(bDividedX AndAlso zz = 0, iDividedX, dwClientX)), ScaleY((i + 1 - VScrollPos) * dwCharY + CodePaneY)
								#endif
								Exit For
							End If
						Next ii
					End If
					If FECLine->Collapsible Then
						#ifdef __USE_GTK__
							'cairo_set_source_rgb(cr, abs(GetRed(clGray) / 255.0), abs(GetGreen(clGray) / 255.0), abs(GetBlue(clGray) / 255.0))
							cairo_rectangle(cr, LeftMargin - 15 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 4 - 0.5 + CodePaneY, LeftMargin - 7 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 12 - 0.5 + CodePaneY, True)
							cairo_move_to(cr, LeftMargin - 13 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 8 - 0.5 + CodePaneY)
							cairo_line_to(cr, LeftMargin - 9 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 8 - 0.5 + CodePaneY)
							If ShowHorizontalSeparatorLines Then
								For ii As Integer = 0 To FECLine->Statements.Count - 1
									FECStatement = FECLine->Statements.Items[ii]
									If (FECStatement->ConstructionIndex >= C_P_Region) AndAlso (FECStatement->ConstructionPart = 0) Then
										cairo_move_to(cr, LeftMargin - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY - 0.5 + CodePaneY)
										cairo_line_to(cr, dwClientX - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY - 0.5 + CodePaneY)
										Exit For
									End If
								Next ii
							End If
							cairo_stroke (cr)
						#else
							This.Canvas.Pen.Color = FoldLines.Foreground
							This.Canvas.Brush.Color = NormalText.Background
							'						SelectObject(bufDC, This.Canvas.Brush.Handle)
							'						SelectObject(bufDC, This.Canvas.Pen.Handle)
							Rectangle bufDC, ScaleX(LeftMargin - 15 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 3 + CodePaneY), ScaleX(LeftMargin - 6 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 12 + CodePaneY)
							MoveToEx bufDC, ScaleX(LeftMargin - 13 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 7 + CodePaneY), 0
							LineTo bufDC, ScaleX(LeftMargin - 8 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 7 + CodePaneY)
							If ShowHorizontalSeparatorLines Then
								For ii As Integer = 0 To FECLine->Statements.Count - 1
									FECStatement = FECLine->Statements.Items[ii]
									If (FECStatement->ConstructionIndex >= C_P_Region) AndAlso (FECStatement->ConstructionPart = 0) Then
										MoveToEx bufDC, ScaleX(LeftMargin + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + CodePaneY), 0
										LineTo bufDC, ScaleX(IIf(bDividedX AndAlso zz = 0, iDividedX, dwClientX)), ScaleY((i - VScrollPos) * dwCharY + CodePaneY)
										Exit For
									End If
								Next ii
							End If
						#endif
						If OldCollapseIndex > 0 Then
							#ifdef __USE_GTK__
								cairo_move_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 0 - 0.5 + CodePaneY)
								cairo_line_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 4 - 0.5 + CodePaneY)
								cairo_stroke (cr)
							#else
								MoveToEx bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 0 + CodePaneY), 0
								LineTo bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 3 + CodePaneY)
							#endif
						End If
						If FECLine->Collapsed Then
							#ifdef __USE_GTK__
								cairo_move_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 6 - 0.5 + CodePaneY)
								cairo_line_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 10 - 0.5 + CodePaneY)
								cairo_stroke (cr)
							#else
								MoveToEx bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 5 + CodePaneY), 0
								LineTo bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 10 + CodePaneY)
							#endif
						End If
						For ii As Integer = 0 To FECLine->Statements.IndexOf(FECLine->MainStatement) - 1
							FECStatement = FECLine->Statements.Items[ii]
							If FECStatement->ConstructionIndex >= 0 AndAlso Constructions(FECStatement->ConstructionIndex).Collapsible Then
								If FECStatement->ConstructionPart = 0 Then
									OldCollapseIndex += 1
								ElseIf FECStatement->ConstructionPart = 1 Then
									OldCollapseIndex -= FECStatement->ConstructionPart
								ElseIf FECStatement->ConstructionPart = 2 Then
									OldCollapseIndex = Max(0, OldCollapseIndex - 1 - FECStatement->ConstructionPart)
								End If
							End If
						Next ii
						If ((Not FECLine->Collapsed) AndAlso CBool(CollapseIndex > 0)) OrElse (FECLine->Collapsed AndAlso (CBool(OldCollapseIndex > 0) OrElse Not FECLine->CollapsedFully)) Then 'CBool(OldCollapseIndex = 0) AndAlso 
							#ifdef __USE_GTK__
								cairo_move_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 12 - 0.5 + CodePaneY)
								cairo_line_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY - 0.5 + CodePaneY)
								cairo_stroke (cr)
							#else
								MoveToEx bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 12 + CodePaneY), 0
								LineTo bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + dwCharY + CodePaneY)
							#endif
						End If
					ElseIf OldCollapseIndex > 0 Then
						#ifdef __USE_GTK__
							cairo_set_source_rgb(cr, FoldLines.ForegroundRed, FoldLines.ForegroundGreen, FoldLines.ForegroundBlue)
							cairo_move_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + 0 - 0.5 + CodePaneY)
						#else
							This.Canvas.Pen.Color = FoldLines.Foreground
							This.Canvas.Brush.Color = NormalText.Background
							'						SelectObject(bufDC, This.Canvas.Brush.Handle)
							'						SelectObject(bufDC, This.Canvas.Pen.Handle)
							MoveToEx bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + 0 + CodePaneY), 0
						#endif
						If CollapseIndex = 0 Then
							#ifdef __USE_GTK__
								cairo_line_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5 + CodePaneY)
								cairo_stroke (cr)
							#else
								LineTo bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + dwCharY / 2 + CodePaneY)
							#endif
						Else
							#ifdef __USE_GTK__
								cairo_line_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY - 0.5 + CodePaneY)
								cairo_stroke (cr)
							#else
								LineTo bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + dwCharY + CodePaneY)
							#endif
						End If
						If FECLine->ConstructionIndex >= 0 AndAlso CInt(Constructions(FECLine->ConstructionIndex).Collapsible) And CInt(FECLine->ConstructionPart = 2) Then
							#ifdef __USE_GTK__
								cairo_move_to(cr, LeftMargin - 11 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5 + CodePaneY)
								cairo_line_to(cr, LeftMargin - 6 - 0.5 + CodePaneX, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5 + CodePaneY)
								cairo_stroke (cr)
							#else
								MoveToEx bufDC, ScaleX(LeftMargin - 11 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + dwCharY / 2 + CodePaneY), 0
								LineTo bufDC, ScaleX(LeftMargin - 6 + CodePaneX), ScaleY((i - VScrollPos) * dwCharY + dwCharY / 2 + CodePaneY)
							#endif
						End If
					End If
				End If
				'If i - VScrollPos > vlc1 Then Exit For 'AndAlso Not ChangeCase
				OldCollapseIndex = CollapseIndex
			Next z
			#ifdef __USE_GTK__
				cairo_rectangle (cr, CodePaneX, Min(IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY), (OldI - VScrollPos + 1) * dwCharY + CodePaneY), LeftMargin - 25 + CodePaneX, IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY), True)
				cairo_set_source_rgb(cr, LineNumbers.BackgroundRed, LineNumbers.BackgroundGreen, LineNumbers.BackgroundBlue)
				cairo_fill (cr)
				cairo_rectangle (cr, LeftMargin - 25 + CodePaneX, Min(IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY), (Max(0, OldI - VScrollPos + 1)) * dwCharY + CodePaneY), LeftMargin + CodePaneX, IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY), True)
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
				SetRect(@rc, ScaleX(CodePaneX), ScaleY(Min(IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY), (Max(0, OldI - VScrollPos + 1)) * dwCharY + CodePaneY)), ScaleX(LeftMargin - 25 + CodePaneX), ScaleY(IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY)))
				This.Canvas.Brush.Color = LineNumbers.Background
				FillRect bufDC, @rc, This.Canvas.Brush.Handle
				SetRect(@rc, ScaleX(LeftMargin - 25 + CodePaneX), ScaleY(Min(IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY), (Max(0, OldI - VScrollPos + 1)) * dwCharY + CodePaneY)), ScaleX(LeftMargin + CodePaneX), ScaleY(IIf(bDividedY AndAlso zz = 0, iDividedY, dwClientY)))
				This.Canvas.Brush.Color = NormalText.Background
				FillRect bufDC, @rc, This.Canvas.Brush.Handle
			#endif
			OldPaintedVScrollPos(zz) = VScrollPos
			OldPaintedHScrollPos(zz) = HScrollPos
		Next zz
		If Not bDividedX Then
			#ifdef __USE_GTK__
				cairo_rectangle(cr, 0, dwClientY - horizontalScrollBarHeight, 7, dwClientY, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, Abs(GetRed(darkBkColor) / 255.0), Abs(GetGreen(darkBkColor) / 255.0), Abs(GetBlue(darkBkColor) / 255.0))
				Else
					cairo_set_source_rgb(cr, Abs(GetRed(clBtnFace) / 255.0), Abs(GetGreen(clBtnFace) / 255.0), Abs(GetBlue(clBtnFace) / 255.0))
				End If
				cairo_fill (cr)
				cairo_rectangle(cr, 0 + 0.5, dwClientY - horizontalScrollBarHeight + 0.5, 7 - 0.5, dwClientY - 0.5, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, 23 / 255.0, 23 / 255.0, 23 / 255.0)
				Else
					cairo_set_source_rgb(cr, 217 / 255.0, 217 / 255.0, 217 / 255.0)
				End If
				cairo_stroke (cr)
			#else
				SetRect(@rc, 0, ScaleY(dwClientY - 17), ScaleX(7), ScaleY(dwClientY))
				If g_darkModeEnabled Then
					This.Canvas.Pen.Color = BGR(23, 23, 23)
					This.Canvas.Brush.Color = darkBkColor
				Else
					This.Canvas.Pen.Color = BGR(217, 217, 217)
					This.Canvas.Brush.Color = clBtnFace
				End If
				Rectangle bufDC, rc.Left, rc.Top, rc.Right, rc.Bottom
			#endif
		End If
		If Not bDividedY Then
			#ifdef __USE_GTK__
				cairo_rectangle(cr, dwClientX - verticalScrollBarWidth, 0, dwClientX, 7, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, Abs(GetRed(darkBkColor) / 255.0), Abs(GetGreen(darkBkColor) / 255.0), Abs(GetBlue(darkBkColor) / 255.0))
				Else
					cairo_set_source_rgb(cr, Abs(GetRed(clBtnFace) / 255.0), Abs(GetGreen(clBtnFace) / 255.0), Abs(GetBlue(clBtnFace) / 255.0))
				End If
				cairo_fill (cr)
				cairo_rectangle(cr, dwClientX - verticalScrollBarWidth + 0.5, 0 + 0.5, dwClientX - 0.5, 7 - 0.5, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, 23 / 255.0, 23 / 255.0, 23 / 255.0)
				Else
					cairo_set_source_rgb(cr, 217 / 255.0, 217 / 255.0, 217 / 255.0)
				End If
				cairo_stroke (cr)
			#else
				SetRect(@rc, ScaleX(dwClientX - 17), 0, ScaleX(dwClientX), ScaleY(7))
				If g_darkModeEnabled Then
					This.Canvas.Pen.Color = BGR(23, 23, 23)
					This.Canvas.Brush.Color = darkBkColor
				Else
					This.Canvas.Pen.Color = BGR(217, 217, 217)
					This.Canvas.Brush.Color = clBtnFace
				End If
				Rectangle bufDC, rc.Left, rc.Top, rc.Right, rc.Bottom
			#endif
		End If
		#ifdef __USE_GTK__
			cairo_rectangle(cr, dwClientX - verticalScrollBarWidth, dwClientY - horizontalScrollBarHeight, dwClientX, dwClientY, True)
			If g_darkModeEnabled Then
				cairo_set_source_rgb(cr, 23 / 255.0, 23 / 255.0, 23 / 255.0)
			Else
				cairo_set_source_rgb(cr, 217 / 255.0, 217 / 255.0, 217 / 255.0)
			End If
			cairo_fill (cr)
		#else
			'FillRect bufDC, @rc, This.Canvas.Brush.Handle
			SetRect(@rc, ScaleX(dwClientX - 17), ScaleY(dwClientY - 17), ScaleX(dwClientX), ScaleY(dwClientY))
			FillRect bufDC, @rc, This.Canvas.Brush.Handle
		#endif
		If bDividedX Then
			#ifdef __USE_GTK__
				cairo_rectangle(cr, iDividedX - verticalScrollBarWidth, dwClientY - horizontalScrollBarHeight, iDividedX, dwClientY, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, 23 / 255.0, 23 / 255.0, 23 / 255.0)
				Else
					cairo_set_source_rgb(cr, 217 / 255.0, 217 / 255.0, 217 / 255.0)
				End If
				cairo_fill (cr)
			#else
				SetRect(@rc, ScaleX(iDividedX - 17), ScaleY(dwClientY - 17), ScaleX(iDividedX), ScaleY(dwClientY))
				FillRect bufDC, @rc, This.Canvas.Brush.Handle
			#endif
		End If
		#ifdef __USE_WINAPI__
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
					'					SelectObject(bufDC, This.Canvas.Pen.Handle)
					'					SelectObject(bufDC, This.Canvas.Brush.Handle)
					Ellipse bufDC, ScaleX(MButtonX + 10), ScaleY(MButtonY + 10), ScaleX(MButtonX + 14), ScaleY(MButtonY + 14)
					Dim pPoint1(3) As ..Point = {(ScaleX(MButtonX + 11), ScaleY(MButtonY + 1)), (ScaleX(MButtonX + 7), ScaleY(MButtonY + 5)), (ScaleX(MButtonX + 16), ScaleY(MButtonY + 5)), (ScaleX(MButtonX + 12), ScaleY(MButtonY + 1))}
					Polygon(bufDC, @pPoint1(0), 4)
					Dim pPoint2(3) As ..Point = {(ScaleX(MButtonX + 11), ScaleY(MButtonY + 22)), (ScaleX(MButtonX + 7), ScaleY(MButtonY + 18)), (ScaleX(MButtonX + 16), ScaleY(MButtonY + 18)), (ScaleX(MButtonX + 12), ScaleY(MButtonY + 22))}
					Polygon(bufDC, @pPoint2(0), 4)
					Dim pPoint3(3) As ..Point = {(ScaleX(MButtonX + 1), ScaleY(MButtonY + 11)), (ScaleX(MButtonX + 5), ScaleY(MButtonY + 7)), (ScaleX(MButtonX + 5), ScaleY(MButtonY + 16)), (ScaleX(MButtonX + 1), ScaleY(MButtonY + 12))}
					Polygon(bufDC, @pPoint3(0), 4)
					Dim pPoint4(3) As ..Point = {(ScaleX(MButtonX + 22), ScaleY(MButtonY + 11)), (ScaleX(MButtonX + 18), ScaleY(MButtonY + 7)), (ScaleX(MButtonX + 18), ScaleY(MButtonY + 16)), (ScaleX(MButtonX + 22), ScaleY(MButtonY + 12))}
					Polygon(bufDC, @pPoint4(0), 4)
				#endif
			End If
		#endif
		If bDividedX Then
			#ifdef __USE_GTK__
				cairo_rectangle(cr, iDividedX, -1, iDividedX + 7, dwClientY + 1, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, Abs(GetRed(darkBkColor) / 255.0), Abs(GetGreen(darkBkColor) / 255.0), Abs(GetBlue(darkBkColor) / 255.0))
				Else
					cairo_set_source_rgb(cr, Abs(GetRed(clBtnFace) / 255.0), Abs(GetGreen(clBtnFace) / 255.0), Abs(GetBlue(clBtnFace) / 255.0))
				End If
				cairo_fill (cr)
				cairo_rectangle(cr, iDividedX + 0.5, -1 + 0.5, iDividedX + 7 - 0.5, dwClientY + 1 - 0.5, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, 23 / 255.0, 23 / 255.0, 23 / 255.0)
				Else
					cairo_set_source_rgb(cr, 217 / 255.0, 217 / 255.0, 217 / 255.0)
				End If
				cairo_stroke (cr)
			#else
				SetRect(@rc, ScaleX(iDividedX), -1, ScaleX(iDividedX + 7), ScaleY(dwClientY) + 1)
				If g_darkModeEnabled Then
					This.Canvas.Pen.Color = BGR(130, 135, 144)
					This.Canvas.Brush.Color = darkBkColor
				Else
					This.Canvas.Pen.Color = BGR(217, 217, 217)
					This.Canvas.Brush.Color = clBtnFace
				End If
				Rectangle bufDC, rc.Left, rc.Top, rc.Right, rc.Bottom
			#endif
		ElseIf bDividedY Then
			#ifdef __USE_GTK__
				cairo_rectangle(cr, -1, iDividedY, dwClientX + 1, iDividedY + 7, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, Abs(GetRed(darkBkColor) / 255.0), Abs(GetGreen(darkBkColor) / 255.0), Abs(GetBlue(darkBkColor) / 255.0))
				Else
					cairo_set_source_rgb(cr, Abs(GetRed(clBtnFace) / 255.0), Abs(GetGreen(clBtnFace) / 255.0), Abs(GetBlue(clBtnFace) / 255.0))
				End If
				cairo_fill (cr)
				cairo_rectangle(cr, -1 + 0.5, iDividedY + 0.5, dwClientX + 1 - 0.5, iDividedY + 7 - 0.5, True)
				If g_darkModeEnabled Then
					cairo_set_source_rgb(cr, 23 / 255.0, 23 / 255.0, 23 / 255.0)
				Else
					cairo_set_source_rgb(cr, 217 / 255.0, 217 / 255.0, 217 / 255.0)
				End If
				cairo_stroke (cr)
			#else
				SetRect(@rc, -1, ScaleY(iDividedY), ScaleX(dwClientX) + 1, ScaleY(iDividedY + 7))
				If g_darkModeEnabled Then
					This.Canvas.Pen.Color = BGR(130, 135, 144)
					This.Canvas.Brush.Color = darkBkColor
				Else
					This.Canvas.Pen.Color = BGR(217, 217, 217)
					This.Canvas.Brush.Color = clBtnFace
				End If
				Rectangle bufDC, rc.Left, rc.Top, rc.Right, rc.Bottom
			#endif
		End If
		If bInDivideX Then
			#ifdef __USE_GTK__
				cairo_rectangle(cr, iDivideX, 0, iDivideX + 5, dwClientY, True)
				cairo_set_source_rgb (cr, 1.0, 1.0, 1.0)
				cairo_set_operator (cr, CAIRO_OPERATOR_DIFFERENCE)
				cairo_fill(cr)
			#else
				SetRect(@rc, ScaleX(iDivideX), 0, ScaleX(iDivideX + 5), ScaleY(dwClientY))
				InvertRect bufDC, @rc
			#endif
		ElseIf bInDivideY Then
			#ifdef __USE_GTK__
				cairo_rectangle(cr, 0, iDivideY, dwClientX, iDivideY + 5, True)
				cairo_set_source_rgb (cr, 1.0, 1.0, 1.0)
				cairo_set_operator (cr, CAIRO_OPERATOR_DIFFERENCE)
				cairo_fill(cr)
			#else
				SetRect(@rc, 0, ScaleY(iDivideY), ScaleX(dwClientX), ScaleY(iDivideY + 5))
				InvertRect bufDC, @rc
			#endif
		End If
		#ifdef __USE_WINAPI__
			BitBlt(hd, 0, 0, ScaleX(dwClientX), ScaleY(dwClientY), bufDC, 0, 0, SRCCOPY)
			'DeleteDC bufDC
			'DeleteObject bufBMP
			ReleaseDC FHandle, hd
			ShowCaret(FHandle)
		#endif
		This.Canvas.HandleSetted = False
		OlddwClientX = dwClientX
		OlddwClientY = dwClientY
		iOldSelStartLine = iSelStartLine
		iOldSelEndLine = iSelEndLine
		OldBracketsStartLine = BracketsStartLine
		OldBracketsEndLine = BracketsEndLine
		OldExecutedLine = CurExecutedLine
		OldCurWord = CurWord
		iOldDivideY = iDivideY
		iOldDividedY = iDividedY
		iOldDivideX = iDivideX
		iOldDividedX = iDividedX
		bOldDividedX = bDividedX
		bOldDividedY = bDividedY
		Exit Sub
		ErrHandler:
		?ErrDescription(Err) & " (" & Err & ") " & _
		"in function " & ZGet(Erfn()) & " " & _
		"in module " & ZGet(Ermn())  & " " & _
		"in line " & Erl()
	End Sub
	
	Sub EditControl.PaintControl(bFull As Boolean = False)
		#ifdef __USE_GTK__
			'PaintControlPriv
			bChanged = True
			If GTK_IS_WIDGET(widget) Then gtk_widget_queue_draw(widget)
		#else
			PaintControlPriv(bFull)
		#endif
	End Sub
	
	Sub EditControl.Undo
		If curHistory <= 0 Then Exit Sub
		If OnUndoing Then OnUndoing(This)
		curHistory = curHistory - 1
		_LoadFromHistory FHistory.Items[curHistory], True, FHistory.Items[curHistory + 1], True
		If OnUndo Then OnUndo(This)
		ScrollToCaret
	End Sub
	
	Sub EditControl.Redo
		If curHistory >= FHistory.Count - 1 Then Exit Sub
		If OnRedoing Then OnRedoing(This)
		curHistory = curHistory + 1
		_LoadFromHistory FHistory.Item(curHistory), False, FHistory.Item(curHistory - 1), True
		If OnRedo Then OnRedo(This)
		ScrollToCaret
	End Sub
	
	Function EditControl.CharType(ByRef ch As WString) As Integer
		If ch = " " Then: Return 0
		ElseIf ch = Chr(13) Or ch = "" Then: Return 1
		ElseIf InStr(Symbols, ch) > 0 Then: Return 2
		Else: Return 3
		End If
	End Function
	
	Sub EditControl.WordLeft()
		Dim f As Integer
		Var item = Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))
		If FSelEndChar = 0 Then
			f = 1
		Else
			f = CharType(Mid(*item->Text, FSelEndChar - 1 + 1, 1))
		End If
		Dim c As Integer, i As Integer, j As Integer, k As Integer
		For i = FSelEndLine To 0 Step -1
			item = Cast(EditControlLine Ptr, Content.Lines.Item(i))
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
	
	Sub EditControl.WordRight()
		Dim f As Integer
		Var item = Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))
		If FSelEndChar = Len(*item->Text) Then
			f = 1
		Else
			f = CharType(Mid(*item->Text, FSelEndChar + 1, 1))
		End If
		Dim c As Integer, i As Integer, j As Integer, k As Integer
		For i = FSelEndLine To Content.Lines.Count - 1
			item = Cast(EditControlLine Ptr, Content.Lines.Item(i))
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
		Var CodePaneX = IIf(bDividedX AndAlso X > iDividedX, iDividedX + 7, 0)
		Return CInt(X >= LeftMargin - 15 + CodePaneX AndAlso X <= LeftMargin - 6 + CodePaneX) AndAlso _
		CInt(Cast(EditControlLine Ptr, Content.Lines.Items[i])->Collapsible)
		'Y >= (i - VScrollPos) * dwCharY + 3 AndAlso Y <= (i - VScrollPos) * dwCharY + 12) AndAlso _
	End Function
	
	Function EditControl.InStartOfLine(i As Integer, X As Integer, Y As Integer) As Boolean
		Var CodePaneX = IIf(bDividedX AndAlso X > iDividedX, iDividedX + 7, 0)
		Return CInt(X > CodePaneX AndAlso X <= dwCharY + CodePaneX)
	End Function
	
	Function EditControl.InIncludeFileRect(i As Integer, X As Integer, Y As Integer) As Boolean
		Dim As WString Ptr ECText = Cast(EditControlLine Ptr, Content.Lines.Items[i])->Text
		Dim As Integer CodePane = IIf((bDividedX AndAlso X < iDividedX) OrElse (bDividedY AndAlso Y < iDividedY), 0, 1)
		If StartsWith(LTrim(LCase(*ECText), Any !"\t "), "#include ") Then
			Var CharIdx = CharIndexFromPoint(X, Y, CodePane)
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
		Var iEnd = IIf(iTo <= 0, 0, Content.Lines.Count - 1)
		For i As Integer = Index To iEnd Step iStep
			If Cast(EditControlLine Ptr, Content.Lines.Items[i])->Visible Then
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
		Var HCaretPos = LeftMargin + nCaretPosX - IIf(bDividedX AndAlso ActiveCodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX + IIf(bDividedX AndAlso ActiveCodePane = 1, iDividedX + 7, 0)
		Var VCaretPos = (nCaretPosY - IIf(ActiveCodePane = 0, VScrollPosTop, VScrollPosBottom) + 1) * dwCharY + IIf(bDividedY AndAlso ActiveCodePane = 1, iDividedY + 7, 0)
		If DropDownShowed Then CloseDropDown
		DropDownChar = iSelEndChar
		DropDownShowed = True
		#ifdef __USE_GTK__
			Dim As gint x, y
			gdk_window_get_origin(gtk_widget_get_window(widget), @x, @y)
			gtk_window_move(GTK_WINDOW(winIntellisense), HCaretPos + x, VCaretPos + y)
			gtk_widget_show_all(winIntellisense)
			ShowDropDownToolTipAt HCaretPos + 250 + x, VCaretPos + y
		#else
			pnlIntellisense.SetBounds HCaretPos, VCaretPos, 250, 0
			cboIntellisense.ShowDropDown True
			If LastItemIndex = -1 Then cboIntellisense.ItemIndex = -1
			ShowDropDownToolTipAt HCaretPos + 250, VCaretPos
		#endif
		If OnShowDropDown Then OnShowDropDown(This)
	End Sub
	
	#ifdef __USE_WINAPI__
		Private Sub EditControl.SetDark(Value As Boolean)
			Base.SetDark Value
			If Value Then
				SetWindowTheme(hwndTT, "DarkMode_Explorer", nullptr)
				SetWindowTheme(sbScrollBarvTop, "DarkMode_Explorer", nullptr)
				SetWindowTheme(sbScrollBarvBottom, "DarkMode_Explorer", nullptr)
				SetWindowTheme(sbScrollBarhLeft, "DarkMode_Explorer", nullptr)
				SetWindowTheme(sbScrollBarhRight, "DarkMode_Explorer", nullptr)
			Else
				SetWindowTheme(hwndTT, NULL, NULL)
				SetWindowTheme(sbScrollBarvTop, NULL, NULL)
				SetWindowTheme(sbScrollBarvBottom, NULL, NULL)
				SetWindowTheme(sbScrollBarhLeft, NULL, NULL)
				SetWindowTheme(sbScrollBarhRight, NULL, NULL)
			End If
			'SendMessage FHandle, WM_THEMECHANGED, 0, 0
		End Sub
	#endif
	
	Sub EditControl.ShowDropDownToolTipAt(X As Integer, Y As Integer)
		#ifdef __USE_GTK__
			DropDownToolTipItemIndex = lvIntellisense.SelectedItemIndex
		#else
			DropDownToolTipItemIndex = cboIntellisense.ItemIndex
		#endif
		DropDownToolTipShowed = True
		If *FHintDropDown = "" Then WLet(FHintDropDown, " ")
		#ifdef __USE_GTK__
			gtk_label_set_markup(GTK_LABEL(lblDropDownTooltip), ToUtf8(Replace(*FHintDropDown, "<=", "\u003c=")))
			gtk_window_move(GTK_WINDOW(winDropDownTooltip), X, Y)
			gtk_window_resize(GTK_WINDOW(winDropDownTooltip), 100, 25)
			gtk_widget_show_all(winDropDownTooltip)
		#else
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = FHandle
			'ti.uId    = Cast(UINT, FHandle)
			
			If hwndTTDropDown = 0 Then
				TTDropDown.CreateWnd
				hwndTTDropDown = TTDropDown.Handle 'CreateWindowW(TOOLTIPS_CLASS, "", WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, Cast(HMENU, NULL), GetModuleHandle(NULL), NULL)
				If g_darkModeEnabled Then
					SetWindowTheme(hwndTTDropDown, "DarkMode_Explorer", nullptr)
				End If
				ti.uFlags = TTF_IDISHWND Or TTF_TRACK Or TTF_ABSOLUTE Or TTF_PARSELINKS Or TTF_TRANSPARENT
				ti.hinst  = GetModuleHandle(NULL)
				ti.lpszText  = FHintDropDown
				
				SendMessage(hwndTTDropDown, TTM_ADDTOOL, 0, Cast(LPARAM, @ti))
			Else
				SendMessage(hwndTTDropDown, TTM_GETTOOLINFO, 0, CInt(@ti))
				
				ti.lpszText = FHintDropDown
				
				SendMessage(hwndTTDropDown, TTM_UPDATETIPTEXT, 0, CInt(@ti))
			End If
			
			SendMessage(hwndTTDropDown, TTM_SETMAXTIPWIDTH, 0, 1000)
			SendMessage(hwndTTDropDown, TTM_TRACKACTIVATE, True, Cast(LPARAM, @ti))
			
			Var Result = SendMessage(hwndTTDropDown, TTM_GETBUBBLESIZE, 0, Cast(LPARAM, @ti))
			
			Dim As ..Rect rc, rc2
			GetWindowRect(FHandle, @rc)
			SendMessage(hwndTTDropDown, TTM_TRACKPOSITION, 0, MAKELPARAM(rc.Left + ScaleX(X), rc.Top + ScaleY(Y)))
		#endif
		This.SetFocus
	End Sub
	
	Sub EditControl.ShowToolTipAt(iSelEndLine As Integer, iSelEndChar As Integer)
		Var nCaretPosY = GetCaretPosY(iSelEndLine)
		Var nCaretPosX = TextWidth(GetTabbedText(..Left(Lines(iSelEndLine), iSelEndChar)))
		Var HCaretPos = LeftMargin + nCaretPosX - IIf(bDividedX AndAlso ActiveCodePane = 0, HScrollPosLeft, HScrollPosRight) * dwCharX + IIf(bDividedX AndAlso ActiveCodePane = 1, iDividedX + 7, 0)
		Var VCaretPos = (nCaretPosY - IIf(ActiveCodePane = 0, VScrollPosTop, VScrollPosBottom) + 1) * dwCharY + IIf(bDividedY AndAlso ActiveCodePane = 1, iDividedY + 7, 0)
		ToolTipChar = iSelEndChar
		ToolTipShowed = True
		#ifdef __USE_GTK__
			Dim As gint x, y
			gtk_label_set_markup(GTK_LABEL(lblTooltip), ToUtf8(Replace(*FHint, "<=", "\u003c=")))
			gdk_window_get_origin(gtk_widget_get_window(widget), @x, @y)
			gtk_window_move(GTK_WINDOW(winTooltip), HCaretPos + x, VCaretPos + y)
			gtk_window_resize(GTK_WINDOW(winTooltip), 100, 25)
			gtk_widget_show_all(winTooltip)
		#else
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = FHandle
			'ti.uId    = Cast(UINT, FHandle)
			
			If hwndTT = 0 Then
				TT.CreateWnd
				hwndTT = TT.Handle 'CreateWindowW(TOOLTIPS_CLASS, "", WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, Cast(HMENU, NULL), GetModuleHandle(NULL), NULL)
				If g_darkModeEnabled Then
					SetWindowTheme(hwndTT, "DarkMode_Explorer", nullptr)
				End If
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
			
			Var Result = SendMessage(hwndTT, TTM_GETBUBBLESIZE, 0, Cast(LPARAM, @ti))
			
			Dim As ..Rect rc, rc2
			GetWindowRect(FHandle, @rc)
			SendMessage(hwndTT, TTM_TRACKPOSITION, 0, MAKELPARAM(rc.Left + ScaleX(HCaretPos), rc.Top + IIf(ShowTooltipsAtTheTop, ScaleY(VCaretPos - dwCharY) - HiWord(Result), ScaleY(VCaretPos + 5))))
		#endif
	End Sub
	
	Sub EditControl.UpdateDropDownToolTip()
		#ifdef __USE_GTK__
			gtk_label_set_markup(GTK_LABEL(lblDropDownTooltip), ToUtf8(Replace(*FHintDropDown, "<=", "\u003c=")))
		#else
			If hwndTTDropDown <> 0 Then
				Dim As TOOLINFO    ti
				ZeroMemory(@ti, SizeOf(ti))
				
				ti.cbSize = SizeOf(ti)
				ti.hwnd   = FHandle
				
				SendMessage(hwndTTDropDown, TTM_GETTOOLINFO, 0, CInt(@ti))
				
				If *FHintDropDown = "" Then WLet(FHintDropDown, " ")
				
				ti.lpszText = FHintDropDown
				
				SendMessage(hwndTTDropDown, TTM_UPDATETIPTEXT, 0, CInt(@ti))
			End If
		#endif
	End Sub
	
	Sub EditControl.UpdateToolTip()
		#ifdef __USE_GTK__
			gtk_label_set_markup(GTK_LABEL(lblTooltip), ToUtf8(Replace(*FHint, "<=", "\u003c=")))
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
			gtk_widget_hide(GTK_WIDGET(winIntellisense))
		#else
			cboIntellisense.ShowDropDown False
		#endif
		CloseDropDownToolTip
		If OnDropDownCloseUp Then OnDropDownCloseUp(This)
	End Sub
	
	Sub EditControl.CloseDropDownToolTip()
		DropDownToolTipShowed = False
		#ifdef __USE_GTK__
			gtk_widget_hide(GTK_WIDGET(winDropDownTooltip))
		#else
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = FHandle
			'ti.uId    = Cast(UINT, FHandle)
			
			SendMessage(hwndTTDropDown, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
		#endif
	End Sub
	
	Sub EditControl.CloseToolTip()
		ToolTipShowed = False
		#ifdef __USE_GTK__
			gtk_widget_hide(GTK_WIDGET(winTooltip))
		#else
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = FHandle
			'ti.uId    = Cast(UINT, FHandle)
			
			SendMessage(hwndTT, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
		#endif
	End Sub
	
	Function GetKeyWordCase(ByRef KeyWord As String, KeyWordsList As WStringOrStringList Ptr = 0, OriginalCaseWord As String = "") As String
		If ChangeKeyWordsCase Then
			Select Case ChoosedKeyWordsCase
			Case KeyWordsCase.OriginalCase
				If OriginalCaseWord <> "" Then Return OriginalCaseWord
				If KeyWordsList <> 0 Then
					Var Idx = KeyWordsList->IndexOf(LCase(KeyWord))
					If Idx <> -1 Then Return KeyWordsList->Item(Idx)
					If StartsWith(KeyWord, "..") Then
						Idx = KeyWordsList->IndexOf(LCase(Mid(KeyWord, 3)))
						If Idx <> -1 Then Return ".." & KeyWordsList->Item(Idx)
					End If
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
		'?GetMessageName(msg.msg)
		Static bShifted As Boolean
		Static bCtrl As Boolean
		Static scrStyle As Integer, scrDirection As Integer
		#ifdef __USE_GTK__
			bShifted = msg.Event->button.state And GDK_SHIFT_MASK
			bCtrl = msg.Event->button.state And GDK_CONTROL_MASK
		#else
			bShifted = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
		#endif
		'Base.ProcessMessage(msg)
		#ifdef __USE_GTK__
			Dim As GdkEvent Ptr e = msg.Event
			Select Case msg.Event->type
		#else
			Select Case msg.Msg
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
				Var dDividedX = iDividedX / dwClientX
				Var dDividedY = iDividedY / dwClientY
				dwClientX = UnScaleX(LoWord(msg.lParam))
				dwClientY = UnScaleY(HiWord(msg.lParam))
				If Not bDividedX Then
					MoveWindow sbScrollBarhRight, ScaleX(7), ScaleY(dwClientY - 17), ScaleX(dwClientX - 17 - 7), ScaleY(17), False
				Else
					iDividedX = dwClientX * dDividedX
					iDivideX = iDividedX
					MoveWindow sbScrollBarvTop, ScaleX(iDividedX - 17), 0, ScaleX(17), ScaleY(dwClientY - 17), False
					MoveWindow sbScrollBarhLeft, 0, ScaleY(dwClientY - 17), ScaleX(iDivideX - 17), ScaleY(17), False
					MoveWindow sbScrollBarhRight, ScaleX(iDivideX + 7), ScaleY(dwClientY - 17), ScaleX(dwClientX - iDivideX - 7 - 17), ScaleY(17), False
					RedrawWindow sbScrollBarhLeft, 0, 0, RDW_INVALIDATE
				End If
				If Not bDividedY Then
					MoveWindow sbScrollBarvBottom, ScaleX(dwClientX - 17), ScaleY(7), ScaleX(17), ScaleY(dwClientY - 17 - 7), False
				Else
					iDividedY = dwClientY * dDividedY
					iDivideY = iDividedY
					MoveWindow sbScrollBarvTop, ScaleX(dwClientX - 17), 0, ScaleX(17), ScaleY(iDivideY), False
					MoveWindow sbScrollBarvBottom, ScaleX(dwClientX - 17), ScaleY(iDivideY + 7), ScaleX(17), ScaleY(dwClientY - iDivideY - 7 - 17), False
					RedrawWindow sbScrollBarvTop, 0, 0, RDW_INVALIDATE
				End If
				RedrawWindow sbScrollBarhRight, 0, 0, RDW_INVALIDATE
				RedrawWindow sbScrollBarvBottom, 0, 0, RDW_INVALIDATE
			#endif
			SetScrollsInfo
			#ifdef __USE_GTK__
			Case GDK_SCROLL
			#else
			Case WM_MOUSEWHEEL
			#endif
			bInMiddleScroll = False
			Dim As Integer VScrollMax
			Dim As Integer Ptr pVScrollPos, pHScrollPos
			#ifdef __USE_WINAPI__
				Dim As HWND sbScrollBarV, sbScrollBarH
			#else
				Dim As GtkAdjustment Ptr adjustmentv, adjustmenth
			#endif
			If bShifted Then
				VScrollMax = IIf(ActiveCodePane = 0, HScrollMaxLeft, HScrollMaxRight)
				If ActiveCodePane = 0 Then
					pHScrollPos = @HScrollPosLeft
				Else
					pHScrollPos = @HScrollPosRight
				End If
				#ifdef __USE_GTK__
					adjustmenth = IIf(ActiveCodePane = 0, adjustmenthLeft, adjustmenthRight)
					OldPos = gtk_adjustment_get_value(adjustmenth)
					#ifdef __USE_GTK3__
						scrDirection = e->scroll.delta_y
					#else
						scrDirection = IIf(e->scroll.direction = GDK_SCROLL_UP, -1, 1)
					#endif
				#else
					sbScrollBarH = IIf(ActiveCodePane = 0, sbScrollBarhLeft, sbScrollBarhRight)
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
					GetScrollInfo (sbScrollBarH, SB_CTL, @si)
					'GetScrollInfo (FHandle, SB_VERT, @si)
					OldPos = si.nPos
				#endif
			Else
				VScrollMax = IIf(ActiveCodePane = 0, VScrollMaxTop, VScrollMaxBottom)
				If ActiveCodePane = 0 Then
					pVScrollPos = @VScrollPosTop
				Else
					pVScrollPos = @VScrollPosBottom
				End If
				#ifdef __USE_GTK__
					adjustmentv = IIf(ActiveCodePane = 0, adjustmentvTop, adjustmentvBottom)
					OldPos = gtk_adjustment_get_value(adjustmentv)
					#ifdef __USE_GTK3__
						scrDirection = e->scroll.delta_y
					#else
						scrDirection = IIf(e->scroll.direction = GDK_SCROLL_UP, -1, 1)
					#endif
				#else
					sbScrollBarV = IIf(ActiveCodePane = 0, sbScrollBarvTop, sbScrollBarvBottom)
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
					GetScrollInfo (sbScrollBarV, SB_CTL, @si)
					'GetScrollInfo (FHandle, SB_VERT, @si)
					OldPos = si.nPos
				#endif
			End If
			If bCtrl Then
				EditorFontSize = Max(1, EditorFontSize + scrDirection)
				PaintControl
			ElseIf VScrollMax <> 0 Then
				If bShifted Then
					#ifdef __USE_GTK__
						If scrDirection = 1 Then
							gtk_adjustment_set_value(adjustmenth, Min(OldPos + 3, gtk_adjustment_get_upper(adjustmenth)))
						ElseIf scrDirection = -1 Then
							gtk_adjustment_set_value(adjustmenth, Max(OldPos - 3, gtk_adjustment_get_lower(adjustmenth)))
						End If
						'If Not gtk_adjustment_get_value(adjustmentv) = OldPos Then
						*pHScrollPos = gtk_adjustment_get_value(adjustmenth)
						ShowCaretPos False
						'PaintControl
						If GTK_IS_WIDGET(widget) Then gtk_widget_queue_draw(widget)
						'End If
					#else
						If scrDirection = -1 Then
							si.nPos = Min(si.nPos + 3, si.nMax)
						Else
							si.nPos = Max(si.nPos - 3, si.nMin)
						End If
						si.fMask = SIF_POS
						SetScrollInfo(sbScrollBarH, SB_CTL, @si, True)
						'SetScrollInfo(FHandle, SB_HORZ, @si, True)
						GetScrollInfo(sbScrollBarH, SB_CTL, @si)
						'GetScrollInfo(FHandle, SB_HORZ, @si)
						If (Not si.nPos = OldPos) Then
							*pHScrollPos = si.nPos
							ShowCaretPos False
							If DownButton = 0 Then
								#ifdef __USE_GTK__
									FSelEndLine = LineIndexFromPoint(IIf(e->button.x > 60000, 0, e->button.x), IIf(e->button.y > 60000, 0, e->button.y))
									FSelEndChar = CharIndexFromPoint(IIf(e->button.x > 60000, 0, e->button.x), IIf(e->button.y > 60000, 0, e->button.y))
									If e->button.x < LeftMargin Then
								#else
									dwTemp = GetMessagePos
									psPoints = MAKEPOINTS(dwTemp)
									poPoint.X = psPoints.x
									poPoint.Y = psPoints.y
									..ScreenToClient(Handle, @poPoint)
									FSelEndLine = LineIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
									FSelEndChar = CharIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
									If poPoint.X < LeftMargin Then
								#endif
								End If
							End If
							PaintControl
						End If
					#endif
				Else
					#ifdef __USE_GTK__
						If scrDirection = 1 Then
							gtk_adjustment_set_value(adjustmentv, Min(OldPos + 3, gtk_adjustment_get_upper(adjustmentv)))
						ElseIf scrDirection = -1 Then
							gtk_adjustment_set_value(adjustmentv, Max(OldPos - 3, gtk_adjustment_get_lower(adjustmentv)))
						End If
						'If Not gtk_adjustment_get_value(adjustmentv) = OldPos Then
						*pVScrollPos = gtk_adjustment_get_value(adjustmentv)
						ShowCaretPos False
						'PaintControl
						If GTK_IS_WIDGET(widget) Then gtk_widget_queue_draw(widget)
						'End If
					#else
						If scrDirection = -1 Then
							si.nPos = Min(si.nPos + 3, si.nMax)
						Else
							si.nPos = Max(si.nPos - 3, si.nMin)
						End If
						si.fMask = SIF_POS
						SetScrollInfo(sbScrollBarV, SB_CTL, @si, True)
						'SetScrollInfo(FHandle, SB_VERT, @si, True)
						GetScrollInfo(sbScrollBarV, SB_CTL, @si)
						'GetScrollInfo(FHandle, SB_VERT, @si)
						If (Not si.nPos = OldPos) Then
							*pVScrollPos = si.nPos
							ShowCaretPos False
							If DownButton = 0 Then
								#ifdef __USE_GTK__
									FSelEndLine = LineIndexFromPoint(IIf(e->button.x > 60000, 0, e->button.x), IIf(e->button.y > 60000, 0, e->button.y))
									FSelEndChar = CharIndexFromPoint(IIf(e->button.x > 60000, 0, e->button.x), IIf(e->button.y > 60000, 0, e->button.y))
									If e->button.x < LeftMargin Then
								#else
									dwTemp = GetMessagePos
									psPoints = MAKEPOINTS(dwTemp)
									poPoint.X = psPoints.x
									poPoint.Y = psPoints.y
									..ScreenToClient(Handle, @poPoint)
									FSelEndLine = LineIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
									FSelEndChar = CharIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
									If poPoint.X < LeftMargin Then
								#endif
									If FSelEndLine < FSelStartLine Then
										'FSelStart = LineFromCharIndex(FSelStart)
										'FSelStart = CharIndexFromLine(FSelStart) + LineLength(FSelStart)
										FSelStartChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelStartLine))->Text)
									Else
										FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
									End If
								End If
							End If
							PaintControl
						End If
					#endif
				End If
				
			End If
			#ifndef __USE_GTK__
			Case WM_NOTIFY
				Dim As LPNMHDR lp = Cast(LPNMHDR, msg.lParam)
				Select Case lp->code
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
				poPoint.X = psPoints.x
				poPoint.Y = psPoints.y
				..ScreenToClient(Handle, @poPoint)
				iCursorLine = LineIndexFromPoint(UnScaleX(poPoint.X), UnScaleY(poPoint.Y), IIf((bDividedY AndAlso UnScaleY(poPoint.Y) <= iDividedY) OrElse (bDividedX AndAlso UnScaleX(poPoint.X) <= iDividedX), 0, 1))
				'If Cast(EditControlLine Ptr, Content.Lines.Items[i])->Collapsible Then
				'If p.X < LeftMargin AndAlso p.X > LeftMargin - 15 Then
				If bDividedX AndAlso UnScaleX(poPoint.X) >= iDividedX AndAlso UnScaleX(poPoint.X) <= iDividedX + 7 Then
					msg.Result = Cast(LRESULT, SetCursor(LoadCursor(NULL, IDC_SIZEWE)))
					Return
				ElseIf bDividedY AndAlso UnScaleY(poPoint.Y) >= iDividedY AndAlso UnScaleY(poPoint.Y) <= iDividedY + 7 Then
					msg.Result = Cast(LRESULT, SetCursor(LoadCursor(NULL, IDC_SIZENS)))
					Return
				ElseIf bDividedX AndAlso UnScaleX(poPoint.X) >= iDividedX - 17 AndAlso UnScaleX(poPoint.X) <= iDividedX Then
					msg.Result = Cast(LRESULT, SetCursor(LoadCursor(NULL, IDC_ARROW)))
					Return
				ElseIf UnScaleX(poPoint.X) > dwClientX - 17 OrElse UnScaleY(poPoint.Y) > dwClientY - 17 Then
					If UnScaleX(poPoint.X) < 7 AndAlso Not bDividedX Then
						msg.Result = Cast(LRESULT, SetCursor(LoadCursor(NULL, IDC_SIZEWE)))
					ElseIf UnScaleY(poPoint.Y) < 7 AndAlso Not bDividedY Then
						msg.Result = Cast(LRESULT, SetCursor(LoadCursor(NULL, IDC_SIZENS)))
					Else
						msg.Result = Cast(LRESULT, SetCursor(LoadCursor(NULL, IDC_ARROW)))
					End If
					Return
				ElseIf bInMiddleScroll Then
					If Abs(UnScaleX(poPoint.X) - MButtonX) < 12 AndAlso Abs(UnScaleY(poPoint.Y) - MButtonY) < 12 Then
						msg.Result = Cast(LRESULT, SetCursor(crScroll.Handle))
					ElseIf UnScaleX(poPoint.X) < MButtonX AndAlso Abs(UnScaleY(poPoint.Y) - MButtonY) <= Abs(UnScaleX(poPoint.X) - MButtonX) Then
						msg.Result = Cast(LRESULT, SetCursor(crScrollLeft.Handle))
					ElseIf UnScaleX(poPoint.X) > MButtonX AndAlso Abs(UnScaleY(poPoint.Y) - MButtonY) <= Abs(UnScaleX(poPoint.X) - MButtonX) Then
						msg.Result = Cast(LRESULT, SetCursor(crScrollRight.Handle))
					ElseIf UnScaleY(poPoint.Y) < MButtonY AndAlso Abs(UnScaleX(poPoint.X) - MButtonX) <= Abs(UnScaleY(poPoint.Y) - MButtonY) Then
						msg.Result = Cast(LRESULT, SetCursor(crScrollUp.Handle))
					ElseIf UnScaleY(poPoint.Y) > MButtonY AndAlso Abs(UnScaleX(poPoint.X) - MButtonX) <= Abs(UnScaleY(poPoint.Y) - MButtonY) Then
						msg.Result = Cast(LRESULT, SetCursor(crScrollDown.Handle))
					End If
					If bScrollStarted Then
						bScrollStarted = False
						PaintControl
					End If
					Return
				ElseIf InStartOfLine(iCursorLine, UnScaleX(poPoint.X), UnScaleY(poPoint.Y)) Then
					msg.Result = Cast(LRESULT, SetCursor(crHand_.Handle))
					Return
				ElseIf InCollapseRect(iCursorLine, UnScaleX(poPoint.X), UnScaleY(poPoint.Y)) Then
					msg.Result = Cast(LRESULT, SetCursor(crHand_.Handle))
					Return
				Else
					bInIncludeFileRect = bCtrl AndAlso InIncludeFileRect(iCursorLine, UnScaleX(poPoint.X), UnScaleY(poPoint.Y))
					If bInIncludeFileRectOld <> bInIncludeFileRect OrElse iCursorLineOld <> iCursorLine Then PaintControl
					iCursorLineOld = iCursorLine
					bInIncludeFileRectOld = bInIncludeFileRect
					If bInIncludeFileRect Then
						msg.Result = Cast(LRESULT, SetCursor(crHand_.Handle))
						Return
					End If
				End If
				'End If
				'If LoWord(msg.lParam) = HTCLIENT Then
				'    'msg.Result = Cast(LResult, SetCursor(crHand_.Handle))
				'    SetCursor(crHand_.Handle)
				'    Return
				'End If
			Case WM_HSCROLL, WM_VSCROLL
				Dim As HWND ScrollBarHandle
				Dim As Integer Ptr pVScrollPos, pHScrollPos
				If msg.Msg = WM_HSCROLL Then
					scrStyle = SB_HORZ
					If bDividedX Then
						Dim As Point pt
						GetCursorPos @pt
						..ScreenToClient FHandle, @pt
						If pt.X <= iDividedX Then
							pHScrollPos = @HScrollPosLeft
							ScrollBarHandle = sbScrollBarhLeft
						Else
							pHScrollPos = @HScrollPosRight
							ScrollBarHandle = sbScrollBarhRight
						End If
					Else
						pHScrollPos = @HScrollPosRight
						ScrollBarHandle = sbScrollBarhRight
					End If
				Else
					scrStyle = SB_VERT
					If bDividedY OrElse bDividedX Then
						Dim As Point pt
						GetCursorPos @pt
						..ScreenToClient FHandle, @pt
						If (bDividedY AndAlso pt.Y <= iDividedY) OrElse (bDividedX AndAlso pt.X <= iDividedX + (dwClientX - iDividedX) / 2) Then
							pVScrollPos = @VScrollPosTop
							ScrollBarHandle = sbScrollBarvTop
						Else
							pVScrollPos = @VScrollPosBottom
							ScrollBarHandle = sbScrollBarvBottom
						End If
					Else
						pVScrollPos = @VScrollPosBottom
						ScrollBarHandle = sbScrollBarvBottom
					End If
				End If
				si.cbSize = SizeOf (si)
				si.fMask  = SIF_ALL
				GetScrollInfo(ScrollBarHandle, SB_CTL, @si)
				'GetScrollInfo(FHandle, scrStyle, @si)
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
				Case SB_ENDSCROLL
					'si.nPos = si.nTrackPos
				Case SB_THUMBPOSITION
					si.nPos = si.nTrackPos
				Case SB_THUMBTRACK
					si.nPos = si.nTrackPos
				End Select
				si.fMask = SIF_POS Or SIF_TRACKPOS
				si.nPos = Min(Max(si.nPos, si.nMin), si.nMax)
				'si.nTrackPos = si.nTrackPos
				'If msg.wParamLo <> SB_THUMBTRACK Then
				'?msg.wParamLo
				'SetScrollInfo(ScrollBarHandle, SB_CTL, @si, True)
				'End If
				'SetScrollInfo(FHandle, scrStyle, @si, True)
				'GetScrollInfo(ScrollBarHandle, SB_CTL, @si)
				'GetScrollInfo(FHandle, scrStyle, @si)
				If (Not si.nPos = OldPos) Then
					'SetScrollPos ScrollBarHandle, SB_CTL, si.nPos, False
					SetScrollInfo(ScrollBarHandle, SB_CTL, @si, False)
					If scrStyle = SB_HORZ Then
						*pHScrollPos = si.nPos
					Else
						*pVScrollPos = si.nPos
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
				bCtrl = msg.Event->key.state And GDK_CONTROL_MASK
				bShifted = msg.Event->key.state And GDK_SHIFT_MASK
				Select Case e->key.keyval
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
				Dim As WString Ptr sTmpLine = Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text '
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
				Case GDK_KEY_End
				#else
				Case VK_END
				#endif
				If bCtrl Then FSelEndLine = Content.Lines.Count - 1
				FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
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
					If FSelEndLine = Content.Lines.Count - 1 And FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(Content.Lines.Count - 1))->Text) And FSelStartLine = FSelEndLine And FSelStartChar = FSelEndChar Then
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
								If CInt(FSelEndLine > 0) AndAlso CInt(Not Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine - 1])->Visible) Then
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
				Case GDK_KEY_Right
					msg.Result = True
				#else
				Case VK_RIGHT
				#endif
				If CInt(FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar) And CInt(Not bShifted) Then
					ChangeSelPos False
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
				ElseIf FSelEndChar < Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text) Or (FSelEndLine < Content.Lines.Count - 1) Then
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
				Case GDK_KEY_Up
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
						With *Cast(EditControlLine Ptr, Content.Lines.Item(i - 1))
							If .ConstructionIndex > C_Enum AndAlso .ConstructionPart = 0 Then
								FSelEndLine = i
								'FSelEndChar = Len(*(.Text))
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
						Var LengthOf = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
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
					For i As Integer = FSelEndLine + 1 To GetLineIndex(Content.Lines.Count - 1) - 1
						With *Cast(EditControlLine Ptr, Content.Lines.Item(i))
							If .ConstructionIndex > C_Enum AndAlso .ConstructionPart = 0 Then
								FSelEndLine = i + 1
								'FSelEndChar = Len(*(.Text))
								bFind = True
								Exit For
							End If
						End With
					Next
					If Not bFind Then
						FSelEndLine = GetLineIndex(Content.Lines.Count - 1)
						'FSelEndChar = 0
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					This.TopLine = FSelEndLine - 1
					ScrollToCaret
				ElseIf FSelEndLine = GetLineIndex(Content.Lines.Count - 1) Then
					If bShifted Then
						Var LengthOf = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
						FSelEndChar = LengthOf
						ScrollToCaret
					ElseIf FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar Then
						ChangeSelPos False
						ScrollToCaret
					End If
				Else
					If FSelEndLine < GetLineIndex(Content.Lines.Count - 1) Then
						FSelEndLine = GetLineIndex(FSelEndLine, +1)
						FSelEndChar = GetCharIndexFromOld
						Var LengthOf = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
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
						With *Cast(EditControlLine Ptr, Content.Lines.Item(i))
							If .ConstructionIndex > C_Enum AndAlso .ConstructionPart = 0 Then
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
					For i As Integer = FSelEndLine + 1 To GetLineIndex(Content.Lines.Count - 1)
						With *Cast(EditControlLine Ptr, Content.Lines.Item(i))
							If .ConstructionIndex > C_Enum AndAlso .ConstructionPart = 0 Then
								FSelEndLine = i
								bFind = True
								Exit For
							End If
						End With
					Next
					If Not bFind Then
						FSelEndLine = GetLineIndex(Content.Lines.Count - 1)
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					This.TopLine = FSelEndLine
					ScrollToCaret
				ElseIf FSelEndLine > GetLineIndex(Content.Lines.Count - 1, -VisibleLinesCount) Then
					FSelEndLine = GetLineIndex(Content.Lines.Count - 1)
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
					msg.Result = True
				#endif
				#ifdef __USE_GTK__
				Case Else
					
					Select Case (Asc(*e->key.string))
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
							If CInt(FSelEndLine > 0) AndAlso CInt(Not Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine - 1])->Visible) Then
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
						ChangeText *e->key.string
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
				If CInt(FSelEndLine = FSelStartLine) AndAlso CInt(FSelEndChar = FSelStartChar) AndAlso CInt(FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text)) Then
					Var iEndLine = GetLineIndex(FSelEndLine, 1)
					If iEndLine = FSelEndLine Then FSelEndLine = Content.Lines.Count - 1 Else FSelEndLine = iEndLine - 1
					FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text)
					FSelStartLine = FSelEndLine
					FSelStartChar = FSelEndChar
				End If
				WLet(FLine, ..Left(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text, FSelEndChar))
				If FSelEndLine > 0 AndAlso EndsWith(RTrim(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine - 1])->Text), " _") Then
					WLetEx(FLine, *Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine - 1])->Text & *FLine)
				End If
				WLet(FLineLeft, "")
				WLet(FLineRight, "")
				WLet(FLineTemp, "")
				Dim j As Integer = 0
				Dim i As Integer = Content.GetConstruction(RTrim(*FLine, Any !"\t "), j, IIf(FSelEndLine <= 0, 0, Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine - 1])->CommentIndex), Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->InAsm)
				Var d = Len(*FLine) - Len(LTrim(*FLine, Any !"\t "))
				WLet(FLineSpace, ..Left(*FLine, d))
				Var k = 0
				Var p = 0
				Var z = 0
				If CInt(AutoIndentation) AndAlso ((InStr(*FLine, ":") = 0) OrElse (i = C_Class)) AndAlso CInt(i > -1) Then
					If j > 0 Then
						Dim y As Integer
						For o As Integer = FSelEndLine - 1 To 0 Step -1
							With *Cast(EditControlLine Ptr, Content.Lines.Items[o])
								If .ConstructionIndex = i OrElse (j = 1 AndAlso i = C_Class AndAlso .ConstructionIndex = C_Type) Then
									If .ConstructionPart = 2 Then
										y = y + 1
									ElseIf .ConstructionPart = 0 Then
										If y = 0 Then
											Var ltt0 = Len(GetTabbedText(* (.Text)))
											Var ltt1 = Len(GetTabbedText(*FLine))
											If ltt0 <> ltt1 Then
												d = Len(* (.Text)) - Len(LTrim(* (.Text), Any !"\t "))
												FSelEndChar = FSelEndChar - (Len(*FLineSpace) - d)
												FSelStartChar = FSelEndChar
												WLet(FLineSpace, ..Left(*(.Text), d))
												WLet(Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text, *FLineSpace & LTrim(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text, Any !"\t "))
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
							If FSelEndLine < Content.Lines.Count - 1 Then WLetEx(FLineTemp, GetTabbedText(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine + 1])->Text), True)
							Dim n As Integer
							Dim m As Integer = Content.GetConstruction(*FLineTemp, n, IIf(FSelEndLine <= 0, 0, Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine - 1])->CommentIndex), Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->InAsm)
							Var e = Len(*FLineTemp) - Len(LTrim(*FLineTemp, Any !"\t "))
							WLetEx(FLineTemp, GetTabbedText(*FLine), True)
							Var r = Len(*FLineTemp) - Len(LTrim(*FLineTemp, Any !"\t "))
							If e > r OrElse (e = r And m = i And n > 0) Then
							Else
								WLet(FLineTemp,  Mid(*Cast(EditControlLine Ptr, Content.Lines.Items[FSelEndLine])->Text, FSelEndChar + 1))
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
				'If l1 + 1 < Content.Lines.Count Then
				'    WLet FLineRight, *Cast(EditControlLine Ptr, Content.Lines.Item(l1 + 1))->Text
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
					If CInt(Not bCtrl) AndAlso CInt(*e->key.string <> "") Then
				#else
					If GetKeyState(VK_CONTROL) >= 0 OrElse GetKeyState(VK_RMENU) < 0 Then
				#endif
					'#ifdef __USE_GTK__
					'	If *e->key.string = " " Then
					'#else
					'	If msg.wParam = Asc(" ") Then
					'#endif
					'	If DropDownShowed Then
					'		CloseDropDown()
					'		#ifdef __USE_GTK__
					'			If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
					'		#else
					'			If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
					'		#endif
					'	End If
					'End If
					bAddText = True
					#ifdef __USE_GTK__
						ChangeText *e->key.string
					#else
						ChangeText WChr(msg.wParam)
					#endif
					#ifdef __USE_GTK__
					ElseIf Asc(*e->key.string) = 26 Then
					#else
					ElseIf msg.wParam = 26 Then
					#endif
					Undo
					#ifdef __USE_GTK__
					ElseIf Asc(*e->key.string) = 25 Then
					#else
					ElseIf msg.wParam = 25 Then
					#endif
					Redo
					#ifdef __USE_GTK__
					ElseIf Asc(*e->key.string) = 24 Then
					#else
					ElseIf msg.wParam = 24 Then
					#endif
					CutToClipboard
					#ifdef __USE_GTK__
					ElseIf Asc(*e->key.string) = 3 Then
					#else
					ElseIf msg.wParam = 3 Then
					#endif
					CopyToClipboard
					#ifdef __USE_GTK__
					ElseIf Asc(*e->key.string) = 22 Then
					#else
					ElseIf msg.wParam = 22 Then
					#endif
					PasteFromClipboard
					#ifdef __USE_GTK__
					ElseIf Asc(*e->key.string) = 127 Then
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
			bCtrl = msg.Event->key.state And GDK_CONTROL_MASK
			bShifted = msg.Event->key.state And GDK_SHIFT_MASK
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
				Var X = e->button.x, y = e->button.y
			#else
				Var X = UnScaleX(msg.lParamLo), y = UnScaleY(msg.lParamHi)
			#endif
			FSelEndLine = LineIndexFromPoint(X, y)
			If bDividedX AndAlso X >= iDividedX AndAlso X <= iDividedX + 7 Then
				SplittedVertically = False
			ElseIf bDividedY AndAlso y >= iDividedY AndAlso y <= iDividedY + 7 Then
				SplittedHorizontally = False
			ElseIf (Not bDividedX) AndAlso y >= dwClientY - 17 AndAlso X <= 7 Then
				SplittedVertically = True
			ElseIf (Not bDividedY) AndAlso X >= dwClientX - 17 AndAlso y <= 7 Then
				SplittedHorizontally = True
			ElseIf InCollapseRect(FSelEndLine, X, y) Then
			Else
				FSelEndChar = CharIndexFromPoint(X, y)
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
				Var X = e->button.x, y = e->button.y
			#else
				Var X = UnScaleX(msg.lParamLo), y = UnScaleY(msg.lParamHi)
			#endif
			If (X > dwClientX - 17 AndAlso y < 7) OrElse (bDividedY AndAlso y >= iDividedY AndAlso y <= iDividedY + 7) Then
				bInDivideY = True
				#ifndef __USE_GTK__
					SetCapture FHandle
				#endif
			ElseIf (y > dwClientY - 17 AndAlso X < 7) OrElse (bDividedX AndAlso X >= iDividedX AndAlso X <= iDividedX + 7) Then
				bInDivideX = True
				#ifndef __USE_GTK__
					SetCapture FHandle
				#endif
			Else
				If bDividedX Then
					ActiveCodePane = IIf(X <= iDividedX, 0, 1)
				ElseIf bDividedY Then
					ActiveCodePane = IIf(y <= iDividedY, 0, 1)
				Else
					ActiveCodePane = 1
				End If
				FSelEndLine = LineIndexFromPoint(X, y)
				If InCollapseRect(FSelEndLine, X, y) Then
					FSelStartLine = FSelEndLine
					FSelEndLine = FSelEndLine
					FSelStartChar = 0
					FSelEndChar = 0
					FECLine = Content.Lines.Items[FSelEndLine]
					ChangeCollapseState FSelEndLine, Not FECLine->Collapsed
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
				Else
					FSelEndChar = CharIndexFromPoint(X, y)
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					If X < LeftMargin Then
						FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
					End If
					If Not Focused Then This.SetFocus
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
					#ifndef __USE_GTK__
						SetCapture FHandle
					#endif
				End If
			End If
			#ifdef __USE_GTK__
			Case GDK_BUTTON_RELEASE
			#else
			Case WM_LBUTTONUP
				ReleaseCapture
			#endif
			#ifdef __USE_GTK__
				Var X = e->button.x, y = e->button.y
			#else
				Var X = UnScaleX(msg.lParamLo), y = UnScaleY(msg.lParamHi)
			#endif
			If bInDivideY Then
				bInDivideY = False
				iDividedY = iDivideY
				If iDivideY <= 7 OrElse iDivideY > (dwClientY - 17 - 7) Then
					SplittedHorizontally = False
				Else
					SplittedHorizontally = True
				End If
				PaintControl
			ElseIf bInDivideX Then
				bInDivideX = False
				iDividedX = iDivideX
				If iDivideX <= 7 OrElse iDivideX > (dwClientX - 17 - 7) Then
					SplittedVertically = False
				Else
					SplittedVertically = True
				End If
				PaintControl
			End If
			If DownButton <> -1 Then
				If bInIncludeFileRect Then
					FECLine = Content.Lines.Items[FSelEndLine]
					Var Pos1 = InStr(*FECLine->Text, """")
					If Pos1 > 0 Then
						Var Pos2 = InStr(Pos1 + 1, *FECLine->Text, """")
						If Pos2 > 0 Then
							If OnLinkClicked Then OnLinkClicked(This, Mid(*FECLine->Text, Pos1 + 1, Pos2 - Pos1 - 1))
						End If
					End If
				ElseIf InStartOfLine(FSelEndLine, X, y) AndAlso FSelEndLine = FSelStartLine Then
					Breakpoint
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
				If bDividedY Then
					MiddleScrollIndexY = IIf(MButtonY < iDividedY, 0, 1)
				ElseIf bDividedX Then
					MiddleScrollIndexX = IIf(MButtonX < iDividedX, 0, 1)
				Else
					MiddleScrollIndexX = 1
					MiddleScrollIndexY = 1
				End If
				GetCursorPos @m_tP
				SetTimer Handle, 1, 25, @EC_TimerProc
			#endif
			#ifdef __USE_GTK__
			Case GDK_MOTION_NOTIFY
			#else
			Case WM_MOUSEMOVE
			#endif
			#ifdef __USE_GTK__
				iCursorLine = LineIndexFromPoint(e->button.x, e->button.y, IIf((bDividedY AndAlso e->button.y <= iDividedY) OrElse (bDividedX AndAlso e->button.x <= iDividedX), 0, 1))
				If bDividedX AndAlso e->button.x >= iDividedX AndAlso e->button.x <= iDividedX + 7 Then
					gdk_window_set_cursor(win, gdkCursorSIZEWE)
				ElseIf bDividedY AndAlso e->button.y >= iDividedY AndAlso e->button.y <= iDividedY + 7 Then
					gdk_window_set_cursor(win, gdkCursorSIZENS)
				ElseIf bDividedX AndAlso e->button.x >= iDividedX - verticalScrollBarWidth AndAlso e->button.x <= iDividedX Then
					gdk_window_set_cursor(win, gdkCursorARROW)
				ElseIf e->button.x > dwClientX - verticalScrollBarWidth OrElse e->button.y > dwClientY - horizontalScrollBarHeight Then
					If e->button.x < 7 AndAlso Not bDividedX Then
						gdk_window_set_cursor(win, gdkCursorSIZEWE)
					ElseIf e->button.y < 7 AndAlso Not bDividedY Then
						gdk_window_set_cursor(win, gdkCursorSIZENS)
					Else
						gdk_window_set_cursor(win, gdkCursorARROW)
					End If
				ElseIf InCollapseRect(iCursorLine, e->button.x, e->button.y) Then
					gdk_window_set_cursor(win, gdkCursorHand)
				Else
					bInIncludeFileRect = bCtrl AndAlso InIncludeFileRect(iCursorLine, e->button.x, e->button.y)
					If bInIncludeFileRectOld <> bInIncludeFileRect OrElse iCursorLineOld <> iCursorLine Then PaintControl
					iCursorLineOld = iCursorLine
					bInIncludeFileRectOld = bInIncludeFileRect
					If bInIncludeFileRect Then
						gdk_window_set_cursor(win, gdkCursorHand)
					Else
						gdk_window_set_cursor(win, gdkCursorIBeam)
					End If
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
				If bInDivideX Then
					iDivideX = UnScaleX(lParamLo)
					PaintControl
				ElseIf bInDivideY Then
					iDivideY = UnScaleY(lParamHi)
					PaintControl
				Else
					FSelEndLine = LineIndexFromPoint(UnScaleX(lParamLo), UnScaleY(lParamHi), ActiveCodePane)
					FSelEndChar = CharIndexFromPoint(UnScaleX(lParamLo), UnScaleY(lParamHi), ActiveCodePane)
					If lParamLo < LeftMargin Then
						If FSelEndLine < FSelStartLine Then
							FSelStartChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelStartLine))->Text)
						Else
							FSelEndChar = Len(*Cast(EditControlLine Ptr, Content.Lines.Item(FSelEndLine))->Text)
						End If
					End If
					ScrollToCaret
				End If
			End If
			#ifndef __USE_GTK__
			Case WM_CTLCOLORSCROLLBAR: Return
			Case WM_CTLCOLORMSGBOX To WM_CTLCOLORSTATIC: PaintControl ': Message.Result = -1
			Case WM_ERASEBKGND
				PaintControl
				ShowCaretPos False: msg.Result = -1
			#endif
			#ifdef __USE_GTK__
			Case GDK_EXPOSE
			#else
			Case WM_PAINT
				If g_darkModeSupported AndAlso g_darkModeEnabled Then
					If Not FDarkMode Then
						SetDark True
						'						FDarkMode = True
						'						SetWindowTheme(FHandle, "DarkMode_Explorer", nullptr)
						'						This.Brush.Handle = hbrBkgnd
						'						SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
						'						_AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
						Repaint
					End If
				Else
					If FDarkMode Then
						SetDark False
						'						FDarkMode = False
						'						SetWindowTheme(FHandle, NULL, NULL)
						'						If FBackColor = -1 Then
						'							This.Brush.Handle = 0
						'						Else
						'							This.Brush.Color = FBackColor
						'						End If
						'						SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
						'						_AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
						Repaint
					End If
				End If
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
					.sbScrollBarvTop = CreateWindowEx(0, "ScrollBar", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN Or SB_VERT, 0, 0, ScaleX(17), ScaleY(Sender.Height - 5), Sender.Handle, 0, Instance, 0)
					.sbScrollBarvBottom = CreateWindowEx(0, "ScrollBar", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN Or SB_VERT, ScaleX(Sender.ClientWidth - 17), 5, ScaleX(17), ScaleY(Sender.Height - 5), Sender.Handle, 0, Instance, 0)
					.sbScrollBarhLeft = CreateWindowEx(0, "ScrollBar", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN Or SB_HORZ, 0, ScaleY(Sender.ClientHeight - 17), ScaleX(Sender.ClientWidth - 17), ScaleY(17), Sender.Handle, 0, Instance, 0)
					.sbScrollBarhRight = CreateWindowEx(0, "ScrollBar", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN Or SB_HORZ, 0, ScaleY(Sender.ClientHeight - 17), ScaleX(Sender.ClientWidth - 17), ScaleY(17), Sender.Handle, 0, Instance, 0)
					ShowWindow .sbScrollBarvTop, SW_HIDE
					ShowWindow .sbScrollBarvBottom, SW_SHOW
					ShowWindow .sbScrollBarhLeft, SW_HIDE
					ShowWindow .sbScrollBarhRight, SW_SHOW
					If g_darkModeEnabled Then
						SetWindowTheme(.sbScrollBarvTop, "DarkMode_Explorer", nullptr)
						SetWindowTheme(.sbScrollBarvBottom, "DarkMode_Explorer", nullptr)
						SetWindowTheme(.sbScrollBarhLeft, "DarkMode_Explorer", nullptr)
						SetWindowTheme(.sbScrollBarhRight, "DarkMode_Explorer", nullptr)
						'						.FDarkMode = True
						'						SetWindowTheme(.FHandle, "DarkMode_Explorer", nullptr)
						'						SendMessageW(.FHandle, WM_THEMECHANGED, 0, 0)
						'						AllowDarkModeForWindow(.FHandle, g_darkModeEnabled)
						'						UpdateWindow(.FHandle)
					End If
				#endif
				'Var s1Pos = 100, s1Min = 1, s1Max = 100
				'SetScrollRange(.FHandle, SB_CTL, s1Min, s1Max, TRUE)
				'SetScrollPos(.FHandle, SB_CTL, s1Pos, TRUE)
			End With
		End If
	End Sub
	
	#ifdef __USE_GTK__
		Function EditControl.EditControl_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
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
				pango_layout_set_text(ec->layout, ToUtf8("|"), 1)
				pango_cairo_update_layout(cr, ec->layout)
				#ifdef pango_version
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(ec->layout, 0)
				#else
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(ec->layout, 0)
				#endif
				pango_layout_line_get_pixel_extents(pl, NULL, @extend)
				ec->dwCharX = extend.width
				ec->dwCharY = extend.height
				
				'Dim extend As cairo_text_extents_t
				'cairo_text_extents (cr, "|", @extend)
				
				ec->CalculateLeftMargin
				
				ec->pdisplay = gtk_widget_get_display(widget)
				ec->gdkCursorIBeam = gdk_cursor_new_for_display(ec->pdisplay, GDK_XTERM)
				ec->gdkCursorHand = gdk_cursor_new_from_name(ec->pdisplay, "pointer")
				ec->gdkCursorSIZENS = gdk_cursor_new_from_name(ec->pdisplay, crSizeNS)
				ec->gdkCursorSIZEWE = gdk_cursor_new_from_name(ec->pdisplay, crSizeWE)
				ec->gdkCursorARROW = gdk_cursor_new_from_name(ec->pdisplay, crArrow)
				#ifdef __USE_GTK3__
					ec->win = gtk_layout_get_bin_window(GTK_LAYOUT(widget))
				#endif
				gdk_window_set_cursor(ec->win, ec->gdkCursorIBeam)
				
				ec->ShowCaretPos False
				ec->HScrollPosRight = 0
				If ec->VScrollPosBottom <> 0 Then
					ec->ShowCaretPos True
				End If
				'ec->VScrollPos = 0
				
				gtk_window_set_transient_for(GTK_WINDOW(ec->winIntellisense), GTK_WINDOW(pfrmMain->Handle))
				gtk_window_set_transient_for(GTK_WINDOW(ec->winTooltip), GTK_WINDOW(pfrmMain->Handle))
				gtk_window_set_transient_for(GTK_WINDOW(ec->winDropDownTooltip), GTK_WINDOW(pfrmMain->Handle))
				
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
				Var dDividedX = ec->iDividedX / ec->dwClientX
				Var dDividedY = ec->iDividedY / ec->dwClientY
				
				ec->dwClientX = AllocatedWidth
				ec->dwClientY = AllocatedHeight
				
				Var iOffset = 0
				#ifdef __USE_GTK2__
					iOffset = 2
				#endif
				If Not ec->bDividedX Then
					gtk_layout_move(GTK_LAYOUT(ec->FHandle), ec->scrollbarhRight, 7, ec->dwClientY - ec->horizontalScrollBarHeight + iOffset)
					gtk_widget_set_size_request(ec->scrollbarhRight, ec->dwClientX - ec->verticalScrollBarWidth - 7, ec->horizontalScrollBarHeight)
				Else
					ec->iDividedX = ec->dwClientX * dDividedX
					ec->iDivideX = ec->iDividedX
					gtk_layout_move(GTK_LAYOUT(ec->FHandle), ec->scrollbarvTop, ec->iDividedX - ec->verticalScrollBarWidth + iOffset, 0)
					gtk_widget_set_size_request(ec->scrollbarvTop, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
					gtk_layout_move(GTK_LAYOUT(ec->FHandle), ec->scrollbarhLeft, 0, ec->dwClientY - ec->horizontalScrollBarHeight + iOffset)
					gtk_widget_set_size_request(ec->scrollbarhLeft, ec->iDivideX - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
					gtk_layout_move(GTK_LAYOUT(ec->FHandle), ec->scrollbarhRight, ec->iDivideX + 7, ec->dwClientY - ec->horizontalScrollBarHeight + iOffset)
					gtk_widget_set_size_request(ec->scrollbarhRight, ec->dwClientX - ec->iDivideX - 7 - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
				End If
				If Not ec->bDividedY Then
					gtk_layout_move(GTK_LAYOUT(ec->FHandle), ec->scrollbarvBottom, ec->dwClientX - ec->verticalScrollBarWidth + iOffset, 7)
					gtk_widget_set_size_request(ec->scrollbarvBottom, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight - 7)
				Else
					ec->iDividedY = ec->dwClientY * dDividedY
					ec->iDivideY = ec->iDividedY
					gtk_layout_move(GTK_LAYOUT(ec->FHandle), ec->scrollbarvTop, ec->dwClientX - ec->verticalScrollBarWidth + iOffset, 0)
					gtk_widget_set_size_request(ec->scrollbarvTop, ec->verticalScrollBarWidth, ec->iDivideY)
					gtk_layout_move(GTK_LAYOUT(ec->FHandle), ec->scrollbarvBottom, ec->dwClientX - ec->verticalScrollBarWidth + iOffset, ec->iDivideY + 7)
					gtk_widget_set_size_request(ec->scrollbarvBottom, ec->verticalScrollBarWidth, ec->dwClientY - ec->iDivideY - 7 - ec->horizontalScrollBarHeight)
				End If
				
				'Ctrl->RequestAlign AllocatedWidth, AllocatedHeight
				ec->SetScrollsInfo
			End If
			
			ec->PaintControlPriv
			
			Return False
		End Function
		
		Function EditControl.EditControl_OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
			Dim As EditControl Ptr ec = Cast(Any Ptr, data1)
			Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
			ec->win = Event->window
			ec->EditControl_OnDraw widget, cr, data1
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
			Select Case widget
			Case ec->adjustmenthLeft: ec->HScrollPosLeft = gtk_adjustment_get_value(ec->adjustmenthLeft)
			Case ec->adjustmentvTop: ec->VScrollPosTop = gtk_adjustment_get_value(ec->adjustmentvTop)
			Case ec->adjustmenthRight: ec->HScrollPosRight = gtk_adjustment_get_value(ec->adjustmenthRight)
			Case ec->adjustmentvBottom: ec->VScrollPosBottom = gtk_adjustment_get_value(ec->adjustmentvBottom)
			End Select
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
			PCONTEXT = gtk_widget_create_pango_context(widget)
			layout = pango_layout_new(PCONTEXT)
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
			adjustmentvTop = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 201.0, 1.0, 20.0, 20.0))
			#ifdef __USE_GTK3__
				scrollbarvTop = gtk_scrollbar_new(GTK_ORIENTATION_VERTICAL, GTK_ADJUSTMENT(adjustmentvTop))
			#else
				scrollbarvTop = gtk_vscrollbar_new(GTK_ADJUSTMENT(adjustmentvTop))
			#endif
			gtk_widget_set_can_focus(scrollbarvTop, False)
			g_signal_connect(adjustmentvTop, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarv, widget)
			If GTK_IS_WIDGET(scrollbarvTop) Then gtk_layout_put(GTK_LAYOUT(widget), scrollbarvTop, 0, 0)
			'gtk_widget_show(scrollbarvTop)
			gtk_widget_set_no_show_all(scrollbarvTop, True)
			adjustmentvBottom = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 201.0, 1.0, 20.0, 20.0))
			#ifdef __USE_GTK3__
				scrollbarvBottom = gtk_scrollbar_new(GTK_ORIENTATION_VERTICAL, GTK_ADJUSTMENT(adjustmentvBottom))
			#else
				scrollbarvBottom = gtk_vscrollbar_new(GTK_ADJUSTMENT(adjustmentvBottom))
			#endif
			gtk_widget_set_can_focus(scrollbarvBottom, False)
			g_signal_connect(adjustmentvBottom, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarv, widget)
			If GTK_IS_WIDGET(scrollbarvBottom) Then gtk_layout_put(GTK_LAYOUT(widget), scrollbarvBottom, 0, 0)
			gtk_widget_show(scrollbarvBottom)
			adjustmenthLeft = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 20.0, 20.0))
			#ifdef __USE_GTK3__
				scrollbarhLeft = gtk_scrollbar_new(GTK_ORIENTATION_HORIZONTAL, GTK_ADJUSTMENT(adjustmenthLeft))
			#else
				scrollbarhLeft = gtk_hscrollbar_new(GTK_ADJUSTMENT(adjustmenthLeft))
			#endif
			gtk_widget_set_can_focus(scrollbarhLeft, False)
			g_signal_connect(adjustmenthLeft, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarh, widget)
			If GTK_IS_WIDGET(scrollbarhLeft) Then gtk_layout_put(GTK_LAYOUT(widget), scrollbarhLeft, 0, 0)
			'gtk_widget_show(scrollbarhLeft)
			gtk_widget_set_no_show_all(scrollbarhLeft, True)
			adjustmenthRight = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 20.0, 20.0))
			#ifdef __USE_GTK3__
				scrollbarhRight = gtk_scrollbar_new(GTK_ORIENTATION_HORIZONTAL, GTK_ADJUSTMENT(adjustmenthRight))
			#else
				scrollbarhRight = gtk_hscrollbar_new(GTK_ADJUSTMENT(adjustmenthRight))
			#endif
			gtk_widget_set_can_focus(scrollbarhRight, False)
			g_signal_connect(adjustmenthRight, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarh, widget)
			If GTK_IS_WIDGET(scrollbarhRight) Then gtk_layout_put(GTK_LAYOUT(widget), scrollbarhRight, 0, 0)
			gtk_widget_show(scrollbarhRight)
			Dim As GtkRequisition vminimum, hminimum, vrequisition, hrequisition
			#ifdef __USE_GTK3__
				gtk_widget_get_preferred_size(scrollbarvBottom, @vminimum, @vrequisition)
				gtk_widget_get_preferred_size(scrollbarhRight, @hminimum, @hrequisition)
			#else
				gtk_widget_size_request(scrollbarvBottom, @vrequisition)
				gtk_widget_size_request(scrollbarhRight, @hrequisition)
			#endif
			Var minVScrollBarHeight = hminimum.height
			Var minHScrollBarWidth = vminimum.width
			verticalScrollBarWidth = vrequisition.width
			horizontalScrollBarHeight = hrequisition.height
			'layoutwidget = widget
			'gtk_widget_grab_focus(wText)
		#else
			OnHandleIsAllocated = @HandleIsAllocated
			'sbScrollBarvTop.Style = ScrollBarControlStyle.sbVertical
			'sbScrollBarv.Style = ScrollBarControlStyle.sbVertical
			'sbScrollBarh.Style = ScrollBarControlStyle.sbHorizontal
			'sbScrollBarvTop.Visible = False
			'This.Add @sbScrollbarvTop
			'This.Add @sbScrollbarv
			'This.Add @sbScrollbarh
		#endif
		dwCharY = 5
		'MultiLine = True
		'ChildProc   = @WndProc
		#ifndef __USE_GTK__
			ExStyle     = WS_EX_CLIENTEDGE
			Style       = WS_CHILD Or WS_TABSTOP Or ES_WANTRETURN Or CS_DBLCLKS 'Or WS_HSCROLL Or WS_VSCROLL
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
		This.Canvas.Ctrl = @This
		crRArrow.LoadFromResourceName("Select")
		crHand_.LoadFromResourceName("Hand")
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
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(lvIntellisense.scrolledwidget), GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC)
			gtk_container_add(GTK_CONTAINER(winIntellisense), lvIntellisense.scrolledwidget)
			'gtk_window_set_transient_for(gtk_window(winIntellisense), gtk_window(pfrmMain->widget))
			gtk_window_resize(GTK_WINDOW(winIntellisense), 250, 7 * 22)
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
			gtk_container_add(GTK_CONTAINER(winTooltip), lblTooltip)
			'gtk_window_set_transient_for(gtk_window(winTooltip), gtk_window(pfrmMain->widget))
			g_signal_connect(lblTooltip, "activate-link", G_CALLBACK(@ActivateLink), @This)
			'gtk_window_resize(gtk_window(winTooltip), 1000, 21)
			winDropDownTooltip = gtk_window_new(GTK_WINDOW_POPUP)
			lblDropDownTooltip = gtk_label_new(NULL)
			#ifdef __USE_GTK3__
				gtk_widget_set_margin_left(lblDropDownTooltip, 1)
				gtk_widget_set_margin_top(lblDropDownTooltip, 1)
				gtk_widget_set_margin_right(lblDropDownTooltip, 1)
				gtk_widget_set_margin_bottom(lblDropDownTooltip, 1)
			#endif
			gtk_container_add(GTK_CONTAINER(winDropDownTooltip), lblDropDownTooltip)
			g_signal_connect(lblDropDownTooltip, "activate-link", G_CALLBACK(@ActivateLink), @This)
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
		Content.Lines.Add item
		bOldCommented = True
		ChangeText "", 0, "Bo`sh"
		ShowHint = False
		WithHistory = True
		VScrollMaxTop = -1
		VScrollMaxBottom = -1
		HScrollMaxLeft = -1
		HScrollMaxRight = -1
		ActiveCodePane = 1
		'ClearUndo
		'Brush.Color = clWindowColor
	End Constructor
	
	Destructor EditControl
		'If FText Then Deallocate FText
		_ClearHistory
		If CurEC = @This Then CurEC = 0
		For i As Integer = Content.Lines.Count - 1 To 0 Step -1
			Delete_( Cast(EditControlLine Ptr, Content.Lines.Items[i]))
		Next i
		#ifdef __USE_GTK__
			lvIntellisense.ListItems.Clear
		#else
			cboIntellisense.Items.Clear
			If bufDC Then DeleteDC bufDC
			If bufBMP Then DeleteObject bufBMP
		#endif
		WDeAllocate(FLine)
		WDeAllocate(FLineLeft)
		WDeAllocate(FLineRight)
		WDeAllocate(FLineTemp)
		WDeAllocate(FLineTab)
		WDeAllocate(FLineSpace)
		WDeAllocate(FHintWord)
		WDeAllocate(CurrentFontName)
		WDeAllocate(DropDownPath)
	End Destructor
	
	Destructor TypeElement
		Elements.Clear
	End Destructor
End Namespace

Sub LoadKeyWords
	Dim b As String
	Dim As UString file
	Dim As WStringOrStringList Ptr keywordlist
	Dim As Integer k = -1
	file = Dir(ExePath & "/Settings/Keywords/*")
	Do Until file = ""
		k += 1
		ReDim Preserve Keywords(k)
		keywordlist = New_(WStringOrStringList)
		keywordlist->Sorted = True
		KeywordLists.Add file, keywordlist
		If Trim(file) = "Asm" Then
			pkeywordsAsm = keywordlist
		ElseIf Trim(file) = "Preprocessors" Then
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

