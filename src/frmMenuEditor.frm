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
			.Designer = @This
			.OnChange = @txtActive_Change_
			.Parent = @picActive
		End With
	End Constructor
	
	Dim Shared fMenuEditor As frmMenuEditor
	pfMenuEditor = @fMenuEditor
'#End Region

#ifdef __USE_GTK__
	#define BGR(r, g, b) RGB(r, g, b)
#endif

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
				
				For j As Integer = 0 To QInteger(Des->ReadPropertyFunc(Ctrls(RectsCount), "Count")) - 1
					
				Next
			End If
			.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")), BGR(0, 0, 0), -1
		Next i
		RectsCount += 1
		ReDim Preserve Ctrls(RectsCount)
		ReDim Preserve Rects(RectsCount)
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
						Des->WritePropertyFunc(Obj, "ParentMenu", CurrentMenu)
						Des->WritePropertyFunc(Obj, "Caption", FCaption.vptr)
						ChangeControl Obj, "ParentMenu"
						ChangeControl Obj, "Caption"
						If Des->OnInsertObject Then Des->OnInsertObject(*Des, "MenuItem", Obj)
						Ctrls(i) = Obj
						txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
						picActive.Width = This.Canvas.TextWidth(txtActive.Text) + 5
					Else
						txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
						picActive.Width = This.Canvas.TextWidth(txtActive.Text) + 5
					End If
					picActive.Height = .Bottom - .Top - 3
					picActive.Visible = True
					Repaint
				Else
					ActiveRect = i
					If Ctrls(i) = 0 Then
						txtActive.Text = ML("Type here")
					Else
						txtActive.Text = QWString(Des->ReadPropertyFunc(Ctrls(i), "Caption"))
					End If
					Repaint
				End If
				Exit Sub
			End If
		End With
	Next i
End Sub

Private Sub frmMenuEditor.txtActive_Change_(ByRef Sender As TextBox)
	*Cast(frmMenuEditor Ptr, Sender.Designer).txtActive_Change(Sender)
End Sub
Private Sub frmMenuEditor.txtActive_Change(ByRef Sender As TextBox)
	picActive.Width = This.Canvas.TextWidth(txtActive.Text) + 5
	If ActiveRect <> 0 AndAlso Ctrls(ActiveRect) <> 0 AndAlso QWString(Des->ReadPropertyFunc(Ctrls(ActiveRect), "Caption")) <> txtActive.Text Then
		Des->WritePropertyFunc(Ctrls(ActiveRect), "Caption", @txtActive.Text)
		ChangeControl Ctrls(ActiveRect), "Caption"
	End If
	Repaint
End Sub
