'################################################################################
'#  CanvasDraw.bas                                                              #
'#  This file is an examples of MyFBFramework.                                  #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'################################################################################

#ifdef __FB_WIN32__
	''#Compile "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Picture.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Pen.bi"
	#include once "mff/ListControl.bi"
	Using My.Sys.Forms
	Using My.Sys.Drawing

	Type Form1Type Extends Form
		Declare Static Sub _CommandButton1_Click(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub _Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub _Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Static Sub _cmdGDIDraw_Click(ByRef Sender As Control)
		Declare Sub cmdGDIDraw_Click(ByRef Sender As Control)
		Declare Static Sub _cmdGDICls_Click(ByRef Sender As Control)
		Declare Sub cmdGDICls_Click(ByRef Sender As Control)
		Declare Static Sub _CommandButton2_Click(ByRef Sender As Control)
		Declare Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Static Sub _cmdGDIDraw1_Click(ByRef Sender As Control)
		Declare Sub cmdGDIDraw1_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As CommandButton CommandButton1, cmdGDIDraw, cmdGDICls
		Dim As Picture Picture1
		Dim As TextBox Text1(1), Text2(1), Text3(1), Text4(1), Text5(1)
	End Type
	
	Constructor Form1Type
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Designer = @This
			.OnResize = @_Form_Resize
			.SetBounds 0, 0, 350, 300
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Start Draw"  '"开始绘画"
			.TabIndex = 1
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asNone
			.SetBounds 13, 230, 71, 30
			.Designer = @This
			.OnClick = @_CommandButton1_Click
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
			.BackColor = 8388736
			.SetBounds 12, 56, 310, 160
			.Designer = @This
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
		' cmdGDIDraw
		With cmdGDIDraw
			.Name = "cmdGDIDraw"
			.Text = "Scale"
			.TabIndex = 12
			.Anchor.Top = AnchorStyle.asNone
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asNone
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 86, 231, 79, 30
			.Designer = @This
			.OnClick = @_cmdGDIDraw_Click
			.Parent = @This
		End With
		' cmdGDICls
		With cmdGDICls
			.Name = "cmdGDICls"
			.Text = "Cls"
			.TabIndex = 13
			.Caption = "Cls"
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 170, 232, 79, 30
			.Designer = @This
			.OnClick = @_cmdGDICls_Click
			.Parent = @This
		End With
	End Constructor
	
	Private Sub Form1Type._CommandButton2_Click(ByRef Sender As Control)
		(*Cast(Form1Type Ptr, Sender.Designer)).CommandButton2_Click(Sender)
	End Sub
	
	Private Sub Form1Type._cmdGDICls_Click(ByRef Sender As Control)
		(*Cast(Form1Type Ptr, Sender.Designer)).cmdGDICls_Click(Sender)
	End Sub
	
	Private Sub Form1Type._cmdGDIDraw_Click(ByRef Sender As Control)
		(*Cast(Form1Type Ptr, Sender.Designer)).cmdGDIDraw_Click(Sender)
	End Sub
	
	Private Sub Form1Type._Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		(*Cast(Form1Type Ptr, Sender.Designer)).Form_Resize(Sender, NewWidth, NewHeight)
	End Sub
	
	Private Sub Form1Type._CommandButton1_Click(ByRef Sender As Control)
		(*Cast(Form1Type Ptr, Sender.Designer)).CommandButton1_Click(Sender)
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
	Dim T As Double = Timer
	' Coordination  坐标系统
	CommandButton1.Caption = "Waiting......Drawing"  '"稍等，正在绘画"     '"Waiting......Drawing" '
	'Picture1.Visible = False
	'Picture1.Style = 16
	With Picture1.Canvas
		.CreateDoubleBuffer
		.Cls
		.Scale(-10, -10, 10, 10)
		.Pen.Color = clGreen
		.Pen.Size = 2
		.Pen.Style = 3 'PenStyle.psDashDot
		'.Pen.Mode = PenMode.pmMerge
		' draw across  画十字线条
		'.FillMode = BrushFillMode.bmOpaque
		'.Brush.Style = BrushStyles.bsSolid
		'.Rectangle -10 , -10 , 10 , 10
		'.Line -10 , -10 , 10 , 10, clblue, "BF"
		.Line -10 , 0 , 10 , 00
		.Line 0 , -10 , 0 , 10
		.TextOut 10 , 0, "1", clGreen , -1
		.TextOut 10, 20 - 2, "2", clGreen , -1
		.TextOut 00 , 10, "3", clGreen , -1
		.TextOut 20 - 3 , 1000, "4", clGreen , -1
		.TextOut 1 , 1, "0", clGreen , -1
		
		' drawing arrow  化箭头
		'    .Line 0 , 1000 , -125 , 950
		'    .Line 0 , 1000 , 125 , 950
		'    .Line 1000 , 0 , 950 , 125
		'    .Line 1000 , 0 , 950 , -125
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
			X = (Sin(i * A(0)) * (Exp(Cos(i)) - B(0) * Cos(C(0) * i) - Sin(i / D(0)) ^ E(0)))
			Y = (Cos(i * A(1)) * (Exp(Cos(i)) - B(1) * Cos(C(1) * i) - Sin(i / D(1)) ^ E(1)))
			.SetPixel X, Y, clRed
			'.TextOut 20, 20, Str(i), clYellow, -1
		Next
		.TextOut - 9, -9, "Elapsed Time: " & Timer - T & "ms", clGreen , -1 '"用时 " & GetTickCount - t & "毫秒", clGreen , -1
		.TransferDoubleBuffer
	End With
	
	CommandButton1.Caption = "Start Draw" '"开始绘画"    '"Start Draw"
	'
End Sub

Private Sub Form1Type.Picture1_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	'CommandButton1_Click(Sender)
	'Debug.Print "NewWidth=" & NewWidth & " NewHeight=" & NewHeight
	
End Sub

Private Sub Form1Type.cmdGDIDraw_Click(ByRef Sender As Control)
	'Picture1.Style = 16
	With Picture1.Canvas
		.CreateDoubleBuffer
		.Cls
		.Scale(-100, 100, 100, -100)
		.Pen.Color = clGreen
		.Pen.Size = 1
		.Pen.Style = 3 'PenStyle.psDashDot
		'Print Picture1.BackColor
		.FillMode = BrushFillMode.bmTransparent
		.Line (-100, 0, 100, 0) '画X轴
		.Line (0, 100, 0, -100) '画Y轴
		
		.Brush.Style = BrushStyles.bsSolid
		.Circle (0, 0, 5) '绘制红色圆心
		.Brush.Style = BrushStyles.bsClear
		
		.TextOut 0,  0, "(0,0)" , clGreen, -1 '原点坐标
		.TextOut 90, 10, "X", clGreen, -1    '标记X轴
		.TextOut 5, 95,  "Y", clGreen, -1     '标记Y轴
		
		For i As Integer = 10 To 50 Step 4
			.SetPixel(i, 10, clRed) '绘制像素点
		Next
		
		'绘制不同模式的直线
		.DrawWidth = 1 '设置画笔宽度
		.Pen.Style = PenStyle.psSolid
		.Line(-10, -10, -100, -10)
		
		.Pen.Style = PenStyle.psDash
		.Line(-10, -20, -100, -20)
		
		.Pen.Style = PenStyle.psDashDot
		.Line -10, -30, -100, -30
		
		.Pen.Style = PenStyle.psDashDotDot
		.Line -10, -40, -100, -40
		
		.Brush.Style = BrushStyles.bsSolid
		.Line 40, 20, 80, 40, , "F"
		.Line 40, 70, 80, 90, clBlue, "F"
		
		.DrawWidth = 2 '设置画笔宽度
		.Pen.Style = 0
		'绘制弧线、弦割线、饼图
		.Arc(30, 50, 70, 80, 70, 60, 30, 60)
		.Chord(10, 60, 40, 80, 40, 60, 10, 70)
		.Pie(20, 70, 40, 50, 60, 80, 40, 60)
		
		Dim As My.Sys.Drawing.Point pt(4) = {(-60, + 20), (-90, + 110), (-10, 0), (-30, 70)}
		'{{90, 130}, {60, 40}, {140, 150}, {160, 80}}
		'//绘制椭圆、矩形
		.Ellipse(pt(0).X, pt(0).Y, pt(1).X, pt(0).Y)
		.Rectangle(pt(2).X, pt(2).Y, pt(3).X, pt(3).Y)
		
		'绘制贝塞尔曲线
		.Pen.Color = clRed
		.DrawWidth = 2  'DrawWidth
		'.PolyBeizer(pt(), 4)
		'标出贝塞尔曲线的四个锚点
		.Circle(pt(0).X, pt(0).Y, 4)
		.Circle(pt(1).X, pt(1).Y, 4)
		.Circle(pt(2).X, pt(2).Y, 4)
		.Circle(pt(3).x, pt(3).y, 4)
		
		'绘制圆
		.Circle(50, 40, 30, clYellow)
		
		'绘制不同填充模式的矩形
		.Pen.Size = 1
		.Pen.Color = clGreen
		.Brush.Color = clRed
		.Brush.Style = BrushStyles.bsClear
		.FillColor = clBlue
		.Rectangle(20, -20, 60, -30) ' HS_BDIAGONAL, RGB(255, 0, 0))
		.Brush.Color = clRed
		.Brush.Style = BrushStyles.bsHatch
		.Brush.HatchStyle = HatchStyles.hsCross
		.Rectangle(20, -40, 60, -50) ' HS_CROSS, RGB(0, 255, 0));
		.Pen.Color = clGreen
		.FillColor = clYellow
		.Brush.HatchStyle = HatchStyles.hsDiagCross
		.FillColor = clYellow
		.Rectangle(20, -60, 60, -70) ' HS_DIAGCROSS, RGB(0, 0, 255))
		.Pen.Color = clYellow
		.Brush.HatchStyle = HatchStyles.hsVertical
		.FillColor = clGray
		.Rectangle(20, -80, 60, -90) ' HS_VERTICAL, RGB(0, 0, 0))
		
		'Draw Image   绘制位图
		'StretchDraw(10, 140, 180, 100, TEXT("chenggong.bmp"))
		
		'绘制文本
		'TextOut(20, 220, TEXT("GDI画图输出测试程序"), 11);
		.TransferDoubleBuffer
	End With
End Sub

Private Sub Form1Type.cmdGDICls_Click(ByRef Sender As Control)
	With Picture1.Canvas
		.Cls(50, -20, 60, -40)
		Sleep(300)
		.Cls
	End With
End Sub

