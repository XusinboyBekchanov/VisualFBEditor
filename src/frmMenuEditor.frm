#include once "frmMenuEditor.bi"

'#Region "Form"
	Constructor frmMenuEditor
		' frmMenuEditor
		With This
			.Name = "frmMenuEditor"
			.Text = ML("Menu Editor")
			.Name = "frmMenuEditor"
			.Caption = ML("Menu Editor")
			.Designer = @This
			.OnPaint = @Form_Paint_
			.Canvas.Font.Name = "Tahoma"
			.Canvas.Font.Size = 8
			.OnMouseDown = @Form_MouseDown_
			.OnKeyDown = @Form_KeyDown_
			.OnKeyPress = @Form_KeyPress_
			.SetBounds 0, 0, 850, 460
		End With
		' picActive
		With picActive
			.Name = "picActive"
			.Text = "Picture1"
			.TabIndex = 1
			.SetBounds 4, 3, 800, 20
			.Visible = False
			.Parent = @This
		End With
		' txtActive
		With txtActive
			.Name = "txtActive"
			.Text = "Active"
			.TabIndex = 2
			.SetBounds -2, -2, 780, 24
			.BackColor = 16242606
			.Visible = True
			.WantTab = True
			.Designer = @This
			.OnChange = @txtActive_Change_
			.OnKeyDown = @txtActive_KeyDown_
			.Parent = @picActive
		End With
	End Constructor
	
	Dim Shared fMenuEditor As frmMenuEditor
	pfMenuEditor = @fMenuEditor
'#End Region

#ifdef __USE_GTK__
	#define BGR(r, g, b) RGB(r, g, b)
#endif

Sub frmMenuEditor.GetDropdowns(mi As Any Ptr)
	Dim As Any Ptr miParent = Des->ReadPropertyFunc(mi, "Parent")
	If miParent <> 0 Then
		DropdownsCount += 1
		ReDim Preserve Dropdowns(DropdownsCount)
		Dropdowns(DropdownsCount) = miParent
		GetDropdowns miParent
	End If
End Sub

Private Sub frmMenuEditor.Form_Paint_(ByRef Sender As Control, Canvas As My.Sys.Drawing.Canvas)
	*Cast(frmMenuEditor Ptr, Sender.Designer).Form_Paint(Sender, Canvas)
End Sub
Private Sub frmMenuEditor.Form_Paint(ByRef Sender As Control, Canvas As My.Sys.Drawing.Canvas)
	RectsCount = 0
	Dim i As Integer
	With Canvas
		.Pen.Color = BGR(255, 255, 255)
		.Brush.Color = BGR(255, 255, 255)
		.Rectangle 0, .TextHeight("A") + 9, Canvas.Width, Canvas.Height
		For i = 0 To QInteger(Des->ReadPropertyFunc(CurrentMenu, "Count")) - 1
			RectsCount += 1
			ReDim Preserve Ctrls(RectsCount)
			ReDim Preserve Rects(RectsCount)
			ReDim Preserve Parents(RectsCount)
			Ctrls(RectsCount) = Des->MenuByIndexFunc(CurrentMenu, i)
			If RectsCount = 1 Then
				Rects(RectsCount).Left = 1
			Else
				Rects(RectsCount).Left = Rects(RectsCount - 1).Right + 2
			End If
			Rects(RectsCount).Top = 1
			Rects(RectsCount).Right = Rects(RectsCount).Left + .TextWidth(QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption"))) + 10
			Rects(RectsCount).Bottom = Rects(RectsCount).Top + .TextHeight("A") + 6
			If RectsCount = ActiveRect Then
				.Pen.Color = BGR(0, 120, 215)
				.Brush.Color = BGR(174, 215, 247)
				.Rectangle Rects(RectsCount)
			End If
			.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")), BGR(0, 0, 0), -1
		Next i
		RectsCount += 1
		ReDim Preserve Ctrls(RectsCount)
		ReDim Preserve Rects(RectsCount)
		ReDim Preserve Parents(RectsCount)
		If RectsCount = 1 Then
			Rects(RectsCount).Left = 1
		Else
			Rects(RectsCount).Left = Rects(RectsCount - 1).Right + 2
		End If
		Rects(RectsCount).Top = 1
		If RectsCount = ActiveRect Then
			.Pen.Color = BGR(0, 120, 215)
			.Brush.Color = BGR(174, 215, 247)
		Else
			.Pen.Color = BGR(109, 109, 109)
			.Brush.Color = BGR(255, 255, 255)
		End If
		Rects(RectsCount).Right = Rects(RectsCount).Left + .TextWidth(ML("Type here")) + 10
		Rects(RectsCount).Bottom = Rects(RectsCount).Top + .TextHeight(ML("Type here")) + 6
		.Rectangle Rects(RectsCount)
		.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, ML("Type here"), BGR(109, 109, 109), -1
		If ActiveCtrl <> 0 Then
			DropdownsCount = 0
			ReDim Dropdowns(0)
			Dropdowns(0) = ActiveCtrl
			GetDropdowns Dropdowns(0)
			For j As Integer = DropdownsCount To 0 Step -1
				Dim As Any Ptr mi, CurrentMenuItem = Dropdowns(j)
				If QWString(Des->ReadPropertyFunc(CurrentMenuItem, "Caption")) = "-" Then Exit For
				Dim As Integer CurRect, iSubMenuHeight = .TextHeight("A") + 6 + 4, MaxWidth = 100, CurWidth
				For i As Integer = 1 To RectsCount
					If Ctrls(i) = CurrentMenuItem Then
						CurRect = i
						Exit For
					End If
				Next
				If CurRect <> 0 Then
					For i As Integer = 0 To QInteger(Des->ReadPropertyFunc(CurrentMenuItem, "Count")) - 1
						mi = Des->MenuItemByIndexFunc(CurrentMenuItem, i)
						If mi <> 0 Then
							If QWString(Des->ReadPropertyFunc(mi, "Caption")) = "-" Then
								iSubMenuHeight += 5
							Else
								iSubMenuHeight += .TextHeight("A") + 6
							End If
							CurWidth = .TextWidth(Replace(QWString(Des->ReadPropertyFunc(mi, "Caption")), !"\t", Space(6))) + 50
							If CurWidth > MaxWidth Then MaxWidth = CurWidth
						End If
					Next
					Dim As Rect rct
					If Des->ReadPropertyFunc(CurrentMenuItem, "Parent") = 0 Then
						rct.Left = Rects(CurRect).Left
						rct.Top = Rects(CurRect).Bottom
					Else
						rct.Left = Rects(CurRect).Right + 1
						rct.Top = Rects(CurRect).Top - 2
					End If
					rct.Right = rct.Left + 25
					rct.Bottom = rct.Top + iSubMenuHeight
					.Pen.Color = BGR(197, 194, 184)
					.Brush.Color = BGR(241, 241, 241)
					.Rectangle rct
					rct.Left = rct.Left + 24
					rct.Right = rct.Left + MaxWidth
					.Brush.Color = BGR(252, 252, 249)
					.Rectangle rct
					iSubMenuHeight = 2
					Dim As Integer iMenuHeight = .TextHeight("A") + 6
					For i As Integer = 0 To QInteger(Des->ReadPropertyFunc(CurrentMenuItem, "Count")) - 1
						mi = Des->MenuItemByIndexFunc(CurrentMenuItem, i)
						If mi <> 0 Then
							If QWString(Des->ReadPropertyFunc(mi, "Caption")) = "-" Then
								iMenuHeight = 5
							Else
								iMenuHeight = .TextHeight("A") + 6
							End If
							RectsCount += 1
							ReDim Preserve Ctrls(RectsCount)
							ReDim Preserve Rects(RectsCount)
							ReDim Preserve Parents(RectsCount)
							Ctrls(RectsCount) = mi
							Parents(RectsCount) = CurrentMenuItem
							Rects(RectsCount).Left = rct.Left + 2
							Rects(RectsCount).Top = rct.Top + iSubMenuHeight
							Rects(RectsCount).Right = Rects(RectsCount).Left + MaxWidth - 4
							Rects(RectsCount).Bottom = Rects(RectsCount).Top + iMenuHeight
							If RectsCount = ActiveRect Then
								.Pen.Color = BGR(0, 120, 215)
								.Brush.Color = BGR(174, 215, 247)
								.Rectangle Rects(RectsCount)
							End If
							If iMenuHeight = 5 Then
								.Pen.Color = BGR(197, 194, 184)
								.Line Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 2, Rects(RectsCount).Right - 1, Rects(RectsCount).Top + 2
							Else
								Dim As WString Ptr pCaption = Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")
								Dim As Integer Pos1 = InStr(*pCaption, !"\t")
								If Pos1 > 0 Then
									.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, Left(*pCaption, Pos1 - 1), BGR(0, 0, 0), -1
									.TextOut Rects(RectsCount).Right - 10 - 5 - .TextWidth(Mid(*pCaption, Pos1 + 1)), Rects(RectsCount).Top + 3, Mid(*pCaption, Pos1 + 1), BGR(0, 0, 0), -1
								Else
									.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, *pCaption, BGR(0, 0, 0), -1
								End If
							End If
							If QInteger(Des->ReadPropertyFunc(mi, "Count")) > 0 Then
								.Pen.Color = BGR(0, 0, 0)
								.Line Rects(RectsCount).Right - 10, Rects(RectsCount).Top + 6, Rects(RectsCount).Right - 10 + 3, Rects(RectsCount).Top + 6 + 3
								.Line Rects(RectsCount).Right - 10 + 3, Rects(RectsCount).Top + 6 + 3, Rects(RectsCount).Right - 10 - 1, Rects(RectsCount).Top + 6 + 7
							End If
							iSubMenuHeight += iMenuHeight
						End If
					Next
					RectsCount += 1
					ReDim Preserve Ctrls(RectsCount)
					ReDim Preserve Rects(RectsCount)
					ReDim Preserve Parents(RectsCount)
					Parents(RectsCount) = CurrentMenuItem
					Rects(RectsCount).Left = rct.Left + 2
					Rects(RectsCount).Top = rct.Top + iSubMenuHeight
					If RectsCount = ActiveRect Then
						.Pen.Color = BGR(0, 120, 215)
						.Brush.Color = BGR(174, 215, 247)
					Else
						.Pen.Color = BGR(109, 109, 109)
						.Brush.Color = BGR(255, 255, 255)
					End If
					Rects(RectsCount).Right = Rects(RectsCount).Left + MaxWidth - 4
					Rects(RectsCount).Bottom = Rects(RectsCount).Top + .TextHeight("A") + 6
					.Rectangle Rects(RectsCount)
					.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, ML("Type here"), BGR(109, 109, 109), -1
				End If
			Next
		End If
	End With
End Sub

Private Sub frmMenuEditor.Form_MouseDown_(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	*Cast(frmMenuEditor Ptr, Sender.Designer).Form_MouseDown(Sender, MouseButton, x, y, Shift)
End Sub
Private Sub frmMenuEditor.Form_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	picActive.Visible = False
	For i As Integer = 1 To RectsCount
		With Rects(i)
			If X >= .Left And X <= .Right And Y >= .Top And Y <= .Bottom Then
				If i = ActiveRect Then
					EditRect i
					txtActive.SelStart = (X - .Left) / This.Canvas.TextWidth("A")
					txtActive.SelEnd = txtActive.SelStart
				Else
					SelectRect i
				End If
				Exit Sub
			End If
		End With
	Next i
End Sub

Sub frmMenuEditor.EditRect(i As Integer)
	With Rects(i)
		ActiveRect = i
		picActive.Left = .Left + 1
		picActive.Top = .Top + 2
		If Ctrls(i) = 0 Then
			Dim As String FName = "MenuItem"
			If Des->OnInsertingControl Then
				Des->OnInsertingControl(*Des, FName, FName)
			End If
			Dim As UString FCaption = FName
			Dim Obj As Any Ptr = Des->CreateObjectFunc("MenuItem")
			Des->WritePropertyFunc(Obj, "Name", FCaption.vptr)
			If Parents(i) = 0 Then
				Des->WritePropertyFunc(Obj, "ParentMenu", CurrentMenu)
			Else
				Des->WritePropertyFunc(Obj, "Parent", Parents(i))
			End If
			Des->WritePropertyFunc(Obj, "Caption", FCaption.vptr)
			If Parents(i) = 0 Then
				ChangeControl Obj, "ParentMenu"
			Else
				ChangeControl Obj, "Parent"
			End If
			ChangeControl Obj, "Caption"
			If Des->OnInsertObject Then Des->OnInsertObject(*Des, "MenuItem", Obj)
			Ctrls(i) = Obj
			ActiveCtrl = Obj
			txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
			'picActive.Width = Rects(ActiveRect).Right - Rects(ActiveRect).Left
			If i = 1 Then
				Des->CheckTopMenuVisible , False
			Else
				Des->TopMenu->Repaint
			End If
		Else
			txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
			'picActive.Width = Rects(ActiveRect).Right - Rects(ActiveRect).Left
		End If
		picActive.Height = .Bottom - .Top - 3
		picActive.Visible = True
		Repaint
		txtActive.SetFocus
	End With
End Sub

Private Sub frmMenuEditor.txtActive_Change_(ByRef Sender As TextBox)
	*Cast(frmMenuEditor Ptr, Sender.Designer).txtActive_Change(Sender)
End Sub
Private Sub frmMenuEditor.txtActive_Change(ByRef Sender As TextBox)
	If ActiveRect <> 0 Then
		If Ctrls(ActiveRect) <> 0 AndAlso QWString(Des->ReadPropertyFunc(Ctrls(ActiveRect), "Caption")) <> txtActive.Text Then
			Des->WritePropertyFunc(Ctrls(ActiveRect), "Caption", @txtActive.Text)
			ChangeControl Ctrls(ActiveRect), "Caption"
			If Parents(ActiveRect) = 0 Then Des->TopMenu->Repaint
		End If
		Repaint
		picActive.Width = Rects(ActiveRect).Right - Rects(ActiveRect).Left - 2
	End If
End Sub

Sub frmMenuEditor.SelectRect(Index As Integer)
	ActiveRect = Index
	If Ctrls(Index) = 0 Then
		ActiveCtrl = Parents(Index)
		txtActive.Text = ML("Type here")
	Else
		ActiveCtrl = Ctrls(Index)
		txtActive.Text = QWString(Des->ReadPropertyFunc(ActiveCtrl, "Caption"))
		Des->SelectedControl = ActiveCtrl
		If Des->OnChangeSelection Then Des->OnChangeSelection(*Des, ActiveCtrl)
	End If
	If picActive.Visible Then picActive.Visible = False 
	This.SetFocus
End Sub

Private Sub frmMenuEditor.Form_KeyDown_(ByRef Sender As Control, Key As Integer, Shift As Integer)
	*Cast(frmMenuEditor Ptr, Sender.Designer).Form_KeyDown(Sender, Key, Shift)
End Sub
Private Sub frmMenuEditor.Form_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Select Case Key
	Case Keys.F2
		If ActiveRect <> 0 Then EditRect ActiveRect
	Case Keys.Left
		If Parents(ActiveRect) = 0 Then
			If ActiveRect = 1 Then
				Dim As Integer Last
				For i As Integer = 1 To RectsCount
					If Parents(i) = 0 Then
						Last = i
					End If
				Next
				SelectRect Last
			Else
				SelectRect ActiveRect - 1
			End If
		Else
			For i As Integer = 1 To RectsCount
				If Parents(ActiveRect) = Ctrls(i) Then
					SelectRect i
					Exit For
				End If
			Next
		End If
	Case Keys.Right
		If Parents(ActiveRect) = 0 Then
			Dim As Integer Last
			For i As Integer = 1 To RectsCount
				If Parents(i) = 0 Then
					Last = i
				End If
			Next
			If ActiveRect = Last Then
				SelectRect 1
			Else
				SelectRect ActiveRect + 1
			End If
		Else
			For i As Integer = 1 To RectsCount
				If Parents(i) = Ctrls(ActiveRect) Then
					SelectRect i
					Exit For
				End If
			Next
		End If
	Case Keys.Down
		If Parents(ActiveRect) = 0 Then
			For i As Integer = 1 To RectsCount
				If Parents(i) = Ctrls(ActiveRect) Then
					SelectRect i
					Exit For
				End If
			Next
		Else
			Dim As Integer First, Last
			For i As Integer = 1 To RectsCount
				If Parents(i) = Parents(ActiveRect) Then
					If First = 0 Then First = i
					Last = i
				End If
			Next
			If ActiveRect = Last Then
				SelectRect First
			Else
				SelectRect ActiveRect + 1
			End If
		End If
	Case Keys.Up
		If Parents(ActiveRect) <> 0 Then
			Dim As Integer First, Last
			For i As Integer = 1 To RectsCount
				If Parents(i) = Parents(ActiveRect) Then
					If First = 0 Then First = i
					Last = i
				End If
			Next
			If ActiveRect = First Then
				SelectRect Last
			Else
				SelectRect ActiveRect - 1
			End If
		End If
	Case Keys.DeleteKey
		If ActiveRect > 0 AndAlso Ctrls(ActiveRect) <> 0 Then
			Dim As Any Ptr ParentMenu = Des->ReadPropertyFunc(Ctrls(ActiveRect), "Parent")
			Des->DeleteMenuItems(CurrentMenu, Ctrls(ActiveRect))
			Dim As Integer First, Last, ParentRect
			For i As Integer = 1 To RectsCount
				If Parents(i) = Parents(ActiveRect) Then
					If First = 0 Then First = i
					Last = i
				End If
				If Parents(ActiveRect) = Ctrls(i) Then ParentRect = i
			Next
			If ActiveRect <= Last - 1 Then
				Ctrls(ActiveRect) = Ctrls(ActiveRect + 1)
				If Ctrls(ActiveRect) = 0 Then 
					ActiveCtrl = Ctrls(ParentRect)
					Des->SelectedControl = CurrentMenu
					If Des->OnChangeSelection Then Des->OnChangeSelection(*Des, CurrentMenu)
				End If
				SelectRect ActiveRect
			ElseIf ActiveRect > First Then
				SelectRect ActiveRect - 1
			ElseIf Parents(ActiveRect) <> 0 Then
				SelectRect ParentRect
			Else
				ActiveCtrl = 0
				ActiveRect = 0
				Des->SelectedControl = CurrentMenu
				If Des->OnChangeSelection Then Des->OnChangeSelection(*Des, CurrentMenu)
				Repaint
			End If
			If ParentMenu = 0 Then Des->TopMenu->Repaint
		End If
	End Select
End Sub

Private Sub frmMenuEditor.Form_KeyPress_(ByRef Sender As Control, Key As Byte)
	*Cast(frmMenuEditor Ptr, Sender.Designer).Form_KeyPress(Sender, Key)
End Sub
Private Sub frmMenuEditor.Form_KeyPress(ByRef Sender As Control, Key As Byte)
	If ActiveRect <> 0 Then
		EditRect ActiveRect
		txtActive.Text = WChr(Key)
		txtActive.SelStart = 1
		txtActive.SelEnd = 1
	End If
End Sub

Private Sub frmMenuEditor.txtActive_KeyDown_(ByRef Sender As Control, Key As Integer, Shift As Integer)
	*Cast(frmMenuEditor Ptr, Sender.Designer).txtActive_KeyDown(Sender, Key, Shift)
End Sub
Private Sub frmMenuEditor.txtActive_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	If Key = Keys.Enter Then
		SelectRect ActiveRect
	End If
End Sub
