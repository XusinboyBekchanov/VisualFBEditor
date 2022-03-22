#ifdef __FB_WIN32__
	''#Compile "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Picture.bi"
	#include once "mff/Textbox.bi"
	
	Using My.Sys.Forms
	
	Type Form1Type Extends Form
		Declare Static Sub CommandButton1_Click_(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub Picture1_Paint_(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub Form_Resize_(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Constructor
		
		Dim As CommandButton CommandButton1
		Dim As Picture Picture1
		Dim As TextBox Text1(1), Text2(1), Text3(1), Text4(1), Text5(1)
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.OnResize = @Form_Resize_
			.SetBounds 0, 0, 350, 300
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Start Draw" '"开始绘画"
			.TabIndex = 1
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 30, 230, 280, 30
			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @This
		End With
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = "Picture1"
			.TabIndex = 1
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.BackColor = 197379
			.SetBounds 12, 56, 310, 170
			.Designer = @This
			.OnPaint = @Picture1_Paint_
			.Parent = @This
		End With
		' Text1(0)
		With Text1(0)
			.Name = "Text1(0)"
			.Text = "1"
			.TabIndex = 2
			.SetBounds 20, 0, 40, 20
			.Parent = @This
		End With
		' Text2(0)
		With Text2(0)
			.Name = "Text2(0)"
			.Text = "2"
			.TabIndex = 3
			.SetBounds 80, 0, 40, 20
			.Parent = @This
		End With
		' Text3(0)
		With Text3(0)
			.Name = "Text3(0)"
			.Text = "4"
			.TabIndex = 4
			.SetBounds 150, 0, 40, 20
			.Parent = @This
		End With
		' Text4(0)
		With Text4(0)
			.Name = "Text4(0)"
			.Text = "12"
			.TabIndex = 5
			.SetBounds 210, 0, 40, 20
			.Parent = @This
		End With
		' Text5(0)
		With Text5(0)
			.Name = "Text5(0)"
			.Text = "5"
			.TabIndex = 6
			.SetBounds 280, 0, 40, 20
			.Parent = @This
		End With
		' Text1(1)
		With Text1(1)
			.Name = "Text1(1)"
			.Text = "1"
			.TabIndex = 7
			.SetBounds 20, 30, 40, 20
			.Parent = @This
		End With
		' Text2(1)
		With Text2(1)
			.Name = "Text2(1)"
			.Text = "2"
			.TabIndex = 8
			.SetBounds 80, 30, 40, 20
			.Parent = @This
		End With
		' Text3(1)
		With Text3(1)
			.Name = "Text3(1)"
			.Text = "4"
			.TabIndex = 9
			.SetBounds 150, 30, 40, 20
			.Parent = @This
		End With
		' Text4(1)
		With Text4(1)
			.Name = "Text4(1)"
			.Text = "12"
			.TabIndex = 10
			.SetBounds 210, 30, 40, 20
			.Parent = @This
		End With
		' Text5(1)
		With Text5(1)
			.Name = "Text5(1)"
			.Text = "5"
			.TabIndex = 11
			.SetBounds 280, 30, 40, 20
			.Parent = @This
		End With
	End Constructor
	
	Private Sub Form1Type.Form_Resize_(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		*Cast(Form1Type Ptr, Sender.Designer).Form_Resize(Sender, NewWidth, NewHeight)
	End Sub
	
	Private Sub Form1Type.Picture1_Paint_(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		*Cast(Form1Type Ptr, Sender.Designer).Picture1_Paint(Sender, Canvas)
	End Sub
	
	Private Sub Form1Type.CommandButton1_Click_(ByRef Sender As Control)
		*Cast(Form1Type Ptr, Sender.Designer).CommandButton1_Click(Sender)
	End Sub
	
	Dim Shared Form1 As Form1Type
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		Form1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1Type.CommandButton1_Click(ByRef Sender As Control)
    Dim As Double A(1), B(1), C(1), D(1), E(1), X, Y
    Dim T As Long = GetTickCount
    Picture1.Style= 16
    
    ' Coordination  坐标系统
    'Me.Cls
    'Picture1.Canvas.Pen.Color = clBlack 
    'Picture1.BackColor = clBlack  
    CommandButton1.Caption = "Waiting......Drawing"  '"稍等，正在绘画"     '"Waiting......Drawing" '
    'Picture1.Visible = False
    'Picture1.Canvas.GetDevice
    Picture1.Canvas.CreateDoubleBuffer
    
    Picture1.Canvas.Scale(-10, -10, 10, 10)
    'Picture1.Canvas.Scale(0, 0, 310, 170)
    Picture1.Canvas.Pen.Color = clGreen 
    ' draw across  画十字线条
    Picture1.Canvas.Line -10 , 0 , 10 , 00 
    Picture1.Canvas.Line 0 , -10 , 0 , 10 
    Picture1.Canvas.TextOut 10 , 0, "1", clGreen , -1
    Picture1.Canvas.TextOut 10, 20 - 2, "2", clGreen , -1
    Picture1.Canvas.TextOut 000 , 10, "3", clGreen , -1
    Picture1.Canvas.TextOut 20 - 3 , 1000, "4", clGreen , -1
    Picture1.Canvas.TextOut 1 , 1, "0", clGreen , -1
    
    ' drawing arrow  化箭头
'    Picture1.Canvas.Line 0 , 1000 , -125 , 950 
'    Picture1.Canvas.Line 0 , 1000 , 125 , 950 
'    Picture1.Canvas.Line 1000 , 0 , 950 , 125 
'    Picture1.Canvas.Line 1000 , 0 , 950 , -125 
    '
    A(0) = Val(Text1(0).Text): A(1) = Val(Text1(1).Text)
    B(0) = Val(Text2(0).Text): B(1) = Val(Text2(1).Text)
    C(0) = Val(Text3(0).Text): C(1) = Val(Text3(1).Text)
    D(0) = Val(Text4(0).Text): D(1) = Val(Text4(1).Text)
    E(0) = Val(Text5(0).Text): E(1) = Val(Text5(1).Text)
    '
    If A(0) < 1 Then A(0) = 1: If A(1) < 1 Then A(1) = 1
    If D(0) < 1 Then D(0) = 1: If D(1) < 1 Then D(1) = 1
    If E(0) < 1 Then E(0) = 1: If E(1) < 1 Then E(1) = 1

    For i As Long = -72000 To 72000 'Step  0.1
        x = (Sin(i * A(0)) * (Exp(Cos(i)) - B(0) * Cos(C(0) * i) - Sin(i / D(0)) ^ E(0))) 
        y = (Cos(i * A(1)) * (Exp(Cos(i)) - B(1) * Cos(C(1) * i) - Sin(i / D(1)) ^ E(1))) 
        Picture1.Canvas.SetPixel x, y, clRed
        'Picture1.Canvas.TextOut 20, 20, Str(i), clYellow, -1
    Next
    Picture1.Canvas.TextOut - 9, -9, "Elapsed Time: " & GetTickCount - t & "ms", clGreen , -1 '"用时 " & GetTickCount - t & "毫秒", clGreen , -1  
    'Picture1.Visible = True
    Picture1.Canvas.TransferDoubleBuffer
    Picture1.Canvas.DeleteDoubleBuffer
    'Picture1.Canvas.ReleaseDevice
    
    
    CommandButton1.Caption = "Start Draw" '"开始绘画"    '"Start Draw" '

	
	'
End Sub

Private Sub Form1Type.Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	'CommandButton1_Click(sender)
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Picture1.BackColor = clBlack
End Sub
