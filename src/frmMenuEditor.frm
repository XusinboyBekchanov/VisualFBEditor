#include once "frmMenuEditor.bi"

'#Region "Form"
	Constructor frmMenuEditor
		' frmMenuEditor
		With This
			.Name = "frmMenuEditor"
			.Caption = ML("Menu Editor")
			.Designer = @This
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
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

Sub frmMenuEditor.GetDropdowns(mi As Any Ptr)
	Dim As Any Ptr miParent = Des->ReadPropertyFunc(mi, "Parent")
	If miParent <> 0 Then
		DropdownsCount += 1
		ReDim Preserve Dropdowns(DropdownsCount)
		Dropdowns(DropdownsCount) = miParent
		GetDropdowns miParent
	End If
End Sub

Private Sub frmMenuEditor.Form_Paint_(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	*Cast(frmMenuEditor Ptr, Sender.Designer).Form_Paint(Sender, Canvas)
End Sub
Private Sub frmMenuEditor.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	RectsCount = 0
	Dim As Integer i, BitmapWidth, BitmapHeight
	Dim As Boolean IsPopup, IsToolBarList
	Dim As Any Ptr ImagesList
	Dim As Any Ptr ImagesListHandle
	With Canvas
		If CurrentMenu <> 0 AndAlso QWString(Des->ReadPropertyFunc(CurrentMenu, "ClassName")) = "PopupMenu" Then IsPopup = True
		If IsPopup AndAlso CurrentToolBar = 0 Then
			.Pen.Color = BGR(255, 255, 255)
			.Brush.Color = BGR(255, 255, 255)
			.Rectangle 0, 0, Canvas.Width, Canvas.Height
		Else
			.Pen.Color = BGR(255, 255, 255)
			.Brush.Color = BGR(255, 255, 255)
			If CurrentToolBar Then
				ImagesList = Des->ReadPropertyFunc(CurrentToolBar, "ImagesList")
				If ImagesList <> 0 Then ImagesListHandle = Des->ReadPropertyFunc(ImagesList, "ImageListHandle")
				BitmapWidth = QInteger(Des->ReadPropertyFunc(CurrentToolBar, "BitmapWidth"))
				BitmapHeight = QInteger(Des->ReadPropertyFunc(CurrentToolBar, "BitmapHeight"))
				IsToolBarList = QBoolean(Des->ReadPropertyFunc(CurrentToolBar, "List"))
				.Rectangle 0, QInteger(Des->ReadPropertyFunc(CurrentToolBar, "ButtonHeight")), Canvas.Width, Canvas.Height
			ElseIf CurrentStatusBar Then
				.Rectangle 0, QInteger(Des->ReadPropertyFunc(CurrentStatusBar, "Height")), Canvas.Width, Canvas.Height
				.Pen.Color = BGR(215, 215, 215)
				.Line 0, 0, Canvas.Width, 0
			Else
				.Rectangle 0, .TextHeight("A") + 9, Canvas.Width, Canvas.Height
			End If
			For i = 0 To QInteger(IIf(CurrentToolBar, Des->ReadPropertyFunc(CurrentToolBar, "ButtonsCount"), IIf(CurrentStatusBar, Des->ReadPropertyFunc(CurrentStatusBar, "Count"), Des->ReadPropertyFunc(CurrentMenu, "Count")))) - 1
				RectsCount += 1
				ReDim Preserve Ctrls(RectsCount)
				ReDim Preserve Rects(RectsCount)
				ReDim Preserve Parents(RectsCount)
				If CurrentToolBar Then
					Ctrls(RectsCount) = Des->ToolBarButtonByIndexFunc(CurrentToolBar, i)
				ElseIf CurrentStatusBar Then
					Ctrls(RectsCount) = Des->StatusBarPanelByIndexFunc(CurrentStatusBar, i)
				Else
					Ctrls(RectsCount) = Des->MenuByIndexFunc(CurrentMenu, i)
				End If
				If RectsCount = 1 Then
					Rects(RectsCount).Left = 1
				Else
					Rects(RectsCount).Left = Rects(RectsCount - 1).Right + 2
				End If
				Rects(RectsCount).Top = 1
				If CurrentToolBar Then
					Rects(RectsCount).Right = Rects(RectsCount).Left + QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Width"))
					Rects(RectsCount).Bottom = Rects(RectsCount).Top + QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Height")) - 1
				ElseIf CurrentStatusBar Then
					Rects(RectsCount).Right = Rects(RectsCount).Left + IIf(QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "RealWidth")) = 0, 3, QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "RealWidth")))
					Rects(RectsCount).Bottom = Rects(RectsCount).Top + QInteger(Des->ReadPropertyFunc(CurrentStatusBar, "Height")) - 1
				Else
					Rects(RectsCount).Right = Rects(RectsCount).Left + .TextWidth(QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption"))) + 10
					Rects(RectsCount).Bottom = Rects(RectsCount).Top + .TextHeight("A") + 6
				End If
				If RectsCount = ActiveRect Then
					.Pen.Color = BGR(0, 120, 215)
					.Brush.Color = BGR(174, 215, 247)
					.Rectangle Rects(RectsCount)
				End If
				If CurrentToolBar Then
					If RectsCount = ActiveRect AndAlso QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsDropDown Then
						.Pen.Color = BGR(0, 120, 215)
						.Line Rects(RectsCount).Right - 16, Rects(RectsCount).Top, Rects(RectsCount).Right - 16, Rects(RectsCount).Bottom
					End If
					Select Case QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Style"))
					Case ToolButtonStyle.tbsDropDown, ToolButtonStyle.tbsWholeDropdown
						.Pen.Color = BGR(0, 0, 0)
						.Brush.Color = BGR(0, 0, 0)
						.Line Rects(RectsCount).Right - 11, Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) - 1, Rects(RectsCount).Right - 5, Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) - 1
						.Line Rects(RectsCount).Right - 5, Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) - 1, Rects(RectsCount).Right - 8, Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) + 2
						.Line Rects(RectsCount).Right - 8, Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) + 2, Rects(RectsCount).Right - 11, Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) - 1
						.FloodFill Rects(RectsCount).Right - 8, Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2), 0, fsBorder
					End Select
					If ImagesListHandle <> 0 Then
						Dim As Any Ptr Image
						Dim As UString ImageKey = WGet(Des->ReadPropertyFunc(Ctrls(RectsCount), "ImageKey"))
						Dim As Integer ImageIndex = QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "ImageIndex"))
						If ImageKey <> "" Then ImageIndex = Des->ImageListIndexOfFunc(ImagesList, ImageKey)
						If ImageIndex > -1 Then
							#ifdef __USE_GTK__
								
							#else
								ImageList_Draw(ImagesListHandle, ImageIndex, .Handle, Rects(RectsCount).Left + IIf(IsToolBarList, 3, (Rects(RectsCount).Right - Rects(RectsCount).Left - BitmapWidth - IIf(QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsDropDown, 15, 0) - IIf(QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsWholeDropdown, 10, 0)) / 2), Rects(RectsCount).Top + IIf(Rects(RectsCount).Bottom - Rects(RectsCount).Top - 6 < BitmapHeight, 3, 3), ILD_TRANSPARENT)
							#endif
						End If
					End If
					If QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsSeparator Then
						.Pen.Color = BGR(0, 0, 0)
						.Line Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2, Rects(RectsCount).Top + 5, Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2, Rects(RectsCount).Bottom - 5
						.Pen.Color = BGR(255, 255, 255)
						.Line Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2 + 1, Rects(RectsCount).Top + 5, Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2 + 1, Rects(RectsCount).Bottom - 5
					Else
						.TextOut Rects(RectsCount).Left + IIf(IsToolBarList, BitmapWidth + 7, (Rects(RectsCount).Right - Rects(RectsCount).Left - .TextWidth(QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption"))) - IIf(QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsDropDown, 15, 0)) / 2), _
							IIf(IsToolBarList, Rects(RectsCount).Top + (Rects(RectsCount).Bottom - Rects(RectsCount).Top - .TextHeight("A")) / 2, Rects(RectsCount).Bottom - .TextHeight("A") - 6), QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")), BGR(0, 0, 0), -1
					End If
				ElseIf CurrentStatusBar Then
					If i > 0 Then
						.Pen.Color = BGR(215, 215, 215)
						.Line Rects(RectsCount).Left - 1, 2, Rects(RectsCount).Left - 1, Rects(RectsCount).Bottom - 1
					End If
					Dim As Any Ptr Icon = Des->ReadPropertyFunc(Ctrls(RectsCount), "Icon")
					Dim As Any Ptr IconHandle
					#ifndef __USE_GTK__
						If Icon <> 0 Then
							IconHandle = Des->ReadPropertyFunc(Icon, "Handle")
							If IconHandle Then IconHandle = *Cast(HICON Ptr, IconHandle)
							If IconHandle Then
								DrawIconEx .Handle, Rects(RectsCount).Left + 3, 3, IconHandle, 16, 16, 0, 0, DI_NORMAL
							End If
						End If
					#endif
					.TextOut Rects(RectsCount).Left + 5 + IIf(IconHandle, 16 + 2, 0), Rects(RectsCount).Top + 3, QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")), BGR(0, 0, 0), -1
				Else
					If QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")) = "-" Then
						.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, "|", BGR(0, 0, 0), -1
					Else
						.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")), BGR(0, 0, 0), -1
					End If
				End If
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
			Ctrls(RectsCount) = 0
			Rects(RectsCount).Top = 1
			Parents(RectsCount) = 0
			If RectsCount = ActiveRect Then
				.Pen.Color = BGR(0, 120, 215)
				.Brush.Color = BGR(174, 215, 247)
			Else
				.Pen.Color = BGR(109, 109, 109)
				.Brush.Color = BGR(255, 255, 255)
			End If
			If CurrentToolBar Then
				Rects(RectsCount).Right = Rects(RectsCount).Left + QInteger(Des->ReadPropertyFunc(CurrentToolBar, "ButtonWidth"))
				Rects(RectsCount).Bottom = Rects(RectsCount).Top + QInteger(Des->ReadPropertyFunc(CurrentToolBar, "ButtonHeight"))
			ElseIf CurrentStatusBar Then
				Rects(RectsCount).Right = Rects(RectsCount).Left + .TextWidth(ML("Type here")) + 10
				Rects(RectsCount).Bottom = Rects(RectsCount).Top + QInteger(Des->ReadPropertyFunc(CurrentStatusBar, "Height")) - 1
			Else
				Rects(RectsCount).Right = Rects(RectsCount).Left + .TextWidth(ML("Type here")) + 10
				Rects(RectsCount).Bottom = Rects(RectsCount).Top + .TextHeight(ML("Type here")) + 6
			End If
			.Rectangle Rects(RectsCount)
			If CurrentToolBar Then
				Dim As BitmapType AddButton
				AddButton.LoadFromResourceName("UserControl")
				#ifdef __USE_GTK__
					
				#else
					.DrawTransparent Rects(RectsCount).Left + IIf(IsToolBarList, 3, (Rects(RectsCount).Right - Rects(RectsCount).Left - BitmapWidth) / 2), Rects(RectsCount).Top + IIf(Rects(RectsCount).Bottom - Rects(RectsCount).Top - 6 < BitmapHeight, 3, 3), AddButton.Handle
				#endif
			Else
				.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, ML("Type here"), BGR(109, 109, 109), -1
			End If
			If CurrentStatusBar Then
				.Pen.Color = BGR(191, 191, 191)
				.Brush.Color = BGR(191, 191, 191)
				.Rectangle This.ClientWidth - 4, Rects(RectsCount).Bottom - 4, This.ClientWidth - 2, Rects(RectsCount).Bottom - 2
				.Rectangle This.ClientWidth - 7, Rects(RectsCount).Bottom - 4, This.ClientWidth - 5, Rects(RectsCount).Bottom - 2
				.Rectangle This.ClientWidth - 10, Rects(RectsCount).Bottom - 4, This.ClientWidth - 8, Rects(RectsCount).Bottom - 2
				.Rectangle This.ClientWidth - 4, Rects(RectsCount).Bottom - 7, This.ClientWidth - 2, Rects(RectsCount).Bottom - 5
				.Rectangle This.ClientWidth - 4, Rects(RectsCount).Bottom - 10, This.ClientWidth - 2, Rects(RectsCount).Bottom - 8
				.Rectangle This.ClientWidth - 7, Rects(RectsCount).Bottom - 7, This.ClientWidth - 5, Rects(RectsCount).Bottom - 5
			End If
		End If
		TopCount = RectsCount
		If CurrentStatusBar = 0 AndAlso (ActiveCtrl <> 0 OrElse IsPopup) Then
			DropdownsCount = 0
			ReDim Dropdowns(DropdownsCount)
			If ActiveCtrl <> 0 AndAlso QWString(Des->ReadPropertyFunc(ActiveCtrl, "ClassName")) = "ToolButton" Then
				Dropdowns(DropdownsCount) = 0
			Else
				Dropdowns(DropdownsCount) = ActiveCtrl
				If ActiveCtrl <> 0 Then GetDropdowns Dropdowns(DropdownsCount)
				If IsPopup AndAlso ActiveCtrl <> 0 Then
					DropdownsCount += 1
					ReDim Preserve Dropdowns(DropdownsCount)
					Dropdowns(DropdownsCount) = 0
				End If
			End If
			For j As Integer = DropdownsCount To 0 Step -1
				Dim As Any Ptr mi, CurrentMenuItem = Dropdowns(j)
				Dim As Integer CurRect, iSubMenuHeight = .TextHeight("A") + 6 + 4, MaxWidth = 100, CurWidth
				If CurrentMenuItem <> 0 Then
					If QWString(Des->ReadPropertyFunc(CurrentMenuItem, "Caption")) = "-" Then Exit For
					For i As Integer = 1 To RectsCount
						If Ctrls(i) = CurrentMenuItem Then
							CurRect = i
							Exit For
						End If
					Next
				End If
				If CurRect <> 0 OrElse IsPopup Then
					For i As Integer = 0 To QInteger(Des->ReadPropertyFunc(IIf(CurrentMenuItem = 0, CurrentMenu, CurrentMenuItem), "Count")) - 1
						If CurrentMenuItem = 0 Then
							mi = Des->MenuByIndexFunc(CurrentMenu, i)
						Else
							mi = Des->MenuItemByIndexFunc(CurrentMenuItem, i)
						End If
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
					Dim As My.Sys.Drawing.Rect rct
					If CurrentMenuItem = 0 Then
						If ParentRect = 0 Then
							rct.Left = 1
							rct.Top = 0
						Else
							rct.Left = Rects(ParentRect).Left
							rct.Top = Rects(ParentRect).Bottom
						End If
					Else
						If Des->ReadPropertyFunc(CurrentMenuItem, "Parent") = 0 AndAlso Not IsPopup Then
							rct.Left = Rects(CurRect).Left
							rct.Top = Rects(CurRect).Bottom
						Else
							rct.Left = Rects(CurRect).Right + 1
							rct.Top = Rects(CurRect).Top - 2
						End If
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
					For i As Integer = 0 To QInteger(Des->ReadPropertyFunc(IIf(CurrentMenuItem = 0, CurrentMenu, CurrentMenuItem), "Count")) - 1
						If CurrentMenuItem = 0 Then
							mi = Des->MenuByIndexFunc(CurrentMenu, i)
						Else
							mi = Des->MenuItemByIndexFunc(CurrentMenuItem, i)
						End If
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
								Dim As Any Ptr pBitmap = Des->ReadPropertyFunc(Ctrls(RectsCount), "Image")
								Dim As Any Ptr BitmapHandle
								If pBitmap <> 0 Then
									BitmapHandle = Des->ReadPropertyFunc(pBitmap, "Handle")
									If BitmapHandle <> 0 Then
										#ifdef __USE_GTK__
											
										#else
											.DrawTransparent Rects(RectsCount).Left - 25 + 3, Rects(RectsCount).Top + 2, *Cast(HBitmap Ptr, BitmapHandle)
										#endif
									End If
								End If
								Dim As WString Ptr pCaption = Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")
								Dim As Integer Pos1 = InStr(*pCaption, !"\t")
								If Pos1 > 0 Then
									.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, ..Left(*pCaption, Pos1 - 1), BGR(0, 0, 0), -1
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
					Ctrls(RectsCount) = 0
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
		If CurrentToolBar <> 0 AndAlso ActiveRect <= TopCount Then
			If QBoolean(Des->ReadPropertyFunc(CurrentToolBar, "List")) Then
				Dim As Integer BitmapWidth = QInteger(Des->ReadPropertyFunc(CurrentToolBar, "BitmapWidth"))
				picActive.Left = .Left + 1 + BitmapWidth
				picActive.Top = .Top + (.Bottom - .Top - This.Canvas.TextHeight("A")) / 2 - 1
			Else
				picActive.Left = .Left + 1
				picActive.Top = .Bottom - This.Canvas.TextHeight("A") - 6
			End If
			If Ctrls(i) = 0 Then
				Dim As String FName = "ToolButton"
				If Des->OnInsertingControl Then
					Des->OnInsertingControl(*Des, FName, FName)
				End If
				Dim As UString FCaption = FName
				Dim Obj As Any Ptr = Des->CreateObjectFunc("ToolButton")
				Des->WritePropertyFunc(Obj, "Name", FCaption.vptr)
				Des->WritePropertyFunc(Obj, "Parent", CurrentToolBar)
				ChangeControl *Des, Obj, "Parent"
				If Des->OnInsertObject Then Des->OnInsertObject(*Des, "ToolButton", Obj, 0)
				Ctrls(i) = Obj
				ActiveCtrl = Obj
				txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
				'Des->TopMenu->Repaint
			Else
				txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
			End If
			picActive.Height = This.Canvas.TextHeight("A")
		ElseIf CurrentStatusBar <> 0 AndAlso ActiveRect <= TopCount Then
			picActive.Left = .Left + 1
			picActive.Top = .Top + 2
			If Ctrls(i) = 0 Then
				Dim As String FName = "StatusPanel"
				If Des->OnInsertingControl Then
					Des->OnInsertingControl(*Des, FName, FName)
				End If
				Dim As UString FCaption = FName
				Dim Obj As Any Ptr = Des->CreateObjectFunc("StatusPanel")
				Des->WritePropertyFunc(Obj, "Name", FCaption.vptr)
				Des->WritePropertyFunc(Obj, "Parent", CurrentStatusBar)
				ChangeControl *Des, Obj, "Parent"
				If Des->OnInsertObject Then Des->OnInsertObject(*Des, "StatusPanel", Obj, 0)
				Ctrls(i) = Obj
				ActiveCtrl = Obj
				txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
			Else
				txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
			End If
			picActive.Height = This.Canvas.TextHeight("A")
		Else
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
					ChangeControl *Des, Obj, "ParentMenu"
				Else
					ChangeControl *Des, Obj, "Parent"
				End If
				ChangeControl *Des, Obj, "Caption"
				If Des->OnInsertObject Then Des->OnInsertObject(*Des, "MenuItem", Obj, 0)
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
		End If
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
			ChangeControl *Des, Ctrls(ActiveRect), "Caption"
			If Parents(ActiveRect) = 0 Then Des->TopMenu->Repaint
		End If
		Repaint
		If CBool(CurrentToolBar <> 0) AndAlso CBool(ActiveRect < TopCount) AndAlso QBoolean(Des->ReadPropertyFunc(CurrentToolBar, "List")) Then
			Dim As Integer BitmapWidth = QInteger(Des->ReadPropertyFunc(CurrentToolBar, "BitmapWidth"))
			picActive.Left = Rects(ActiveRect).Left + 3 + BitmapWidth
			If ActiveCtrl <> 0 AndAlso QInteger(Des->ReadPropertyFunc(ActiveCtrl, "Style")) = ToolButtonStyle.tbsDropDown OrElse QInteger(Des->ReadPropertyFunc(ActiveCtrl, "Style")) = ToolButtonStyle.tbsWholeDropdown Then
				picActive.Width = Rects(ActiveRect).Right - Rects(ActiveRect).Left - 2 - 15 - BitmapWidth - 3
			Else
				picActive.Width = Rects(ActiveRect).Right - Rects(ActiveRect).Left - 2 - BitmapWidth - 3
			End If
		Else
			picActive.Left = Rects(ActiveRect).Left + 1
			If CurrentToolBar AndAlso ActiveRect < TopCount AndAlso ActiveCtrl <> 0 AndAlso (QInteger(Des->ReadPropertyFunc(ActiveCtrl, "Style")) = ToolButtonStyle.tbsDropDown OrElse QInteger(Des->ReadPropertyFunc(ActiveCtrl, "Style")) = ToolButtonStyle.tbsWholeDropdown) Then
				picActive.Width = Rects(ActiveRect).Right - Rects(ActiveRect).Left - 2 - 15
			Else
				picActive.Width = Rects(ActiveRect).Right - Rects(ActiveRect).Left - 2
			End If
		End If
	End If
End Sub

Sub frmMenuEditor.SelectRect(Index As Integer)
	ActiveRect = Index
	If Ctrls(Index) = 0 Then
		ActiveCtrl = Parents(Index)
		txtActive.Text = ML("Type here")
		If CurrentToolBar AndAlso Index = TopCount Then CurrentMenu = 0
	Else
		ActiveCtrl = Ctrls(Index)
		txtActive.Text = QWString(Des->ReadPropertyFunc(ActiveCtrl, "Caption"))
		If CurrentToolBar AndAlso QWString(Des->ReadPropertyFunc(ActiveCtrl, "ClassName")) = "ToolButton" Then
			Dim As Integer ButStyle
			ButStyle = QInteger(Des->ReadPropertyFunc(ActiveCtrl, "Style"))
			If ButStyle = ToolButtonStyle.tbsDropDown OrElse ButStyle = ToolButtonStyle.tbsWholeDropdown Then
				CurrentMenu = Des->ReadPropertyFunc(ActiveCtrl, "DropDownMenu")
				ParentRect = Index
			Else
				CurrentMenu = 0
				ParentRect = 0
			End If
		End If
		Des->SelectedControl = ActiveCtrl
		If Des->OnChangeSelection Then Des->OnChangeSelection(*Des, ActiveCtrl)
	End If
	If picActive.Visible Then picActive.Visible = False 
	This.SetFocus
	Repaint
End Sub

Private Sub frmMenuEditor.Form_KeyDown_(ByRef Sender As Control, Key As Integer, Shift As Integer)
	*Cast(frmMenuEditor Ptr, Sender.Designer).Form_KeyDown(Sender, Key, Shift)
End Sub
Private Sub frmMenuEditor.Form_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim As Boolean IsPopup
	If CurrentMenu <> 0 AndAlso QWString(Des->ReadPropertyFunc(CurrentMenu, "ClassName")) = "PopupMenu" Then IsPopup = True
	Select Case Key
	Case Keys.F2
		If ActiveRect <> 0 Then EditRect ActiveRect
	Case Keys.Key_Left
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
	Case Keys.Key_Right
		If Parents(ActiveRect) = 0 AndAlso (CurrentToolBar <> 0 AndAlso ActiveRect <= TopCount OrElse CInt(Not IsPopup)) Then
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
		ElseIf Ctrls(ActiveRect) = 0 Then
			Dim j As Integer = ActiveRect
			Do While Parents(j) <> 0
				For i As Integer = 1 To RectsCount
					If Ctrls(i) = Parents(j) Then
						j = i
						Continue Do
					End If
				Next
				Exit Do
			Loop
			SelectRect j
		Else
			For i As Integer = 1 To RectsCount
				If Parents(i) = Ctrls(ActiveRect) Then
					SelectRect i
					Exit For
				End If
			Next
		End If
	Case Keys.Key_Down
		If Parents(ActiveRect) = 0 AndAlso (CurrentToolBar AndAlso ActiveRect <= TopCount OrElse CInt(Not IsPopup)) Then
			If RectsCount > TopCount Then SelectRect TopCount + 1
'			For i As Integer = 1 To RectsCount
'				If Parents(i) = Ctrls(ActiveRect) Then
'					SelectRect i
'					Exit For
'				End If
'			Next
		Else
			Dim As Integer First, Last
			For i As Integer = 1 To RectsCount
				If Parents(i) = Parents(ActiveRect) Then
					If First = 0 Then First = i
					Last = i
				End If
			Next
			If ActiveRect = Last Then
				If Parents(ActiveRect) = 0 Then
					SelectRect TopCount + 1
				Else
					SelectRect First
				End If
			Else
				SelectRect ActiveRect + 1
			End If
		End If
	Case Keys.Key_Up
		If Parents(ActiveRect) <> 0 OrElse IsPopup Then
			Dim As Integer First, Last
			For i As Integer = IIf(CurrentToolBar, TopCount + 1, 1) To RectsCount
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
	Case Keys.Key_Delete
		If ActiveRect > 0 AndAlso Ctrls(ActiveRect) <> 0 Then
			Dim As Any Ptr ParentMenu = Des->ReadPropertyFunc(Ctrls(ActiveRect), "Parent")
			If CurrentToolBar Then
				'Des->DeleteMenuItems(Des->ReadPropertyFunc(Ctrls(ActiveRect), "DropdownMenu"))
				If Des->OnDeleteControl Then Des->OnDeleteControl(*Des, Ctrls(ActiveRect))
				Des->ToolBarRemoveButtonSub(CurrentToolBar, ActiveRect - 1)
				Des->DeleteComponentFunc(Ctrls(ActiveRect))
			ElseIf CurrentStatusBar Then
				If Des->OnDeleteControl Then Des->OnDeleteControl(*Des, Ctrls(ActiveRect))
				Des->StatusBarRemovePanelSub(CurrentStatusBar, ActiveRect - 1)
				Des->DeleteComponentFunc(Ctrls(ActiveRect))
			Else
				Des->DeleteMenuItems(CurrentMenu, Ctrls(ActiveRect))
			End If
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

Private Sub frmMenuEditor.Form_KeyPress_(ByRef Sender As Control, Key As Integer)
	*Cast(frmMenuEditor Ptr, Sender.Designer).Form_KeyPress(Sender, Key)
End Sub
Private Sub frmMenuEditor.Form_KeyPress(ByRef Sender As Control, Key As Integer)
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
	If Key = Keys.Key_Enter Then
		SelectRect ActiveRect
	End If
End Sub
