﻿'五子棋的人工智能试验小程序
' vbnet实现五子棋的人工智能  http://www.west999.com/www/info/24067-1.htm
' 实现五子棋的人工智能五子棋的AI构想 https://blog.csdn.net/elizabethxxy/article/details/103150370?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_title~default-8.pc_relevant_default&spm=1001.2101.3001.4242.5&utm_relevant_index=11
' 由阿凡达翻译到freeBasic. 本程序需要MyFbFramework框架支持，并由VisualFBEditor进行可视化窗体设计
' 你可以拷贝，分发，修改，本程序中的任意代码, 期待你加入局域网对战功能
'
'修改历史：
'2022年4月12日 阿凡达增加棋盘大小可以动态修改，修复棋盘从10X0放大到19X19后算法不准，电脑乱走。
'2022年4月13日 阿凡达增加可换棋盘颜色, 调整搜索范围，改变游戏难易程度
#ifdef __FB_WIN32__
	#cmdline "FiveInARow.rc"
#endif

Dim Shared As Single MouseX, MouseY
Dim Shared As Integer mSteps, ChessR = 30, ChessSize, WinStepSum '棋子大小，棋盘大小 WinStepSum, 19->354, 10-> 192
'　　定义虚拟桌面：
Dim Shared As Integer Table(Any, Any) ' =0, 无子， 1 黑子， 2 白子
'　  定义当前玩家桌面空格的分数：
Dim Shared pScore(Any, Any) As Integer
'　　定义当前电脑桌面空格的分数：
Dim Shared cScore(Any, Any) As Integer
'　　定义玩家的获胜组合：
Dim Shared  PersonWin(Any, Any, Any) As Boolean
'　　定义电脑的获胜组合：
Dim Shared  ComputerWin(Any, Any, Any) As Boolean
'　　定义玩家的获胜组合标志：
Dim Shared  PersonFlag(Any) As Boolean
'　　定义电脑的获胜组合标志：
Dim Shared ComputerFlag(Any) As Boolean
'　 定义游戏有效标志
Dim Shared PlayingFlag As Boolean
Dim Shared As Integer zhX, zhY, zhXOld, zhYOld
Dim Shared As Integer colorPerson, ColorComputer, ColorLastStep, ColorChessBK, ColorChessGrid

'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/sys.bi"
	#include once "mff/Picture.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/Label.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	#include once "mff/RadioButton.bi"
	#include once "mff/UpDown.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/LinkLabel.bi"
	Using My.Sys.Forms
	
	
	Type frmWuziqiType Extends Form
		Declare Sub cmdStart_Click(ByRef Sender As Control)
		Declare Sub GameButton_Move(ByRef Sender As Control)
		Declare Sub InitPlayEnvironment()
		Declare Sub CheckWhoWin(ByVal BlackOrWhite As Integer)
		Declare Sub ComputerAI
		Declare Function WinStepsTotal(ByVal n As Long) As Long
		Declare Sub DrawCompter(ByVal x As Integer, ByVal y As Integer)
		
		Declare Function WhoWin() As Integer
		Declare Sub Form_Show(ByRef Sender As Form)
		
		Declare Sub Picture1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Picture1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Picture1_Click(ByRef Sender As Picture)
		Declare Sub UpDown1_Changing(ByRef Sender As UpDown, Value As Integer, Direction As Integer)
		Declare Sub cmdChangBK_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Picture Picture1
		Dim As GroupBox GroupBox1
		Dim As CommandButton cmdStart, cmdChangBK(1)
		Dim As RadioButton optComputer(1)
		Dim As Label lblInfomation, Label2, lblChessText(1), lblColorBK(1)
		Dim As UpDown UpDown1
		Dim As TextBox txtChessSize
		Dim As CheckBox chkComputerFirst
		Dim As LinkLabel LinkLblAbout
		'Dim As TextBox LinkLblAbout
		Dim As ColorDialog ColorDialog1
	End Type
	
	Constructor frmWuziqiType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmWuziqi
		With This
			.Name = "frmWuziqi"
			.Text = ML("Wuziqi")  '"五子棋"
			.Designer = @This
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.StartPosition = FormStartPosition.CenterScreen
			'.Cursor = crWait
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Show)
			.Graphic.Icon.LoadFromResourceID(1, , 48, 48)
			.BorderStyle = FormBorderStyle.FixedSingle
			.SetBounds 0, 0, 811, 667
			.Designer = @This
		End With
		' Picture1
		With Picture1
			.Name = "Picture1"
			.Text = "Picture1"
			.TabIndex = 0
			.Cursor = crHand
			.BackColor = 8421376
			.ForeColor = 255
			.SetBounds 6, 8, 625, 625
			.Designer = @This
			.OnMouseDown = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture1_MouseDown)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Picture1_MouseMove)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Picture1_Click)
			.Parent = @This
		End With
		
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = ML("Setting") '"设置"
			.TabIndex = 3
			.SetBounds 638, 13, 159, 242
			.Designer = @This
			.Parent = @This
		End With
		' cmdStart
		With cmdStart
			.Name = "cmdStart"
			.Text = ML("Restart")  '"重新开始"
			.TabIndex = 5
			.SetBounds 13, 198, 135, 35
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdStart_Click)
			.Parent = @GroupBox1
		End With
		' optComputer3
		With optComputer(0)
			.Name = "optComputer(0)"
			.Text = ML("Man-Computer Playing")
			.TabIndex = 5
			.Checked = True
			.SetBounds 16, 46, 129, 22
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' optComputer4
		With optComputer(1)
			.Name = "optComputer(1)"
			.Text = ML("Man-Man Playing")
			.TabIndex = 6
			.SetBounds 15, 23, 127, 24
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' lblInfomation
		With lblInfomation
			.Name = "lblInfomation"
			.Text = "lblInfomation"
			.TabIndex = 8
			.BackColor = 255
			.SetBounds 17, 166, 135, 26
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = ML("Chess Board Size") '"棋盘大小:"
			.TabIndex = 8
			.SetBounds 19, 97, 67, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' UpDown1
		With UpDown1
			.Name = "UpDown1"
			.Text = "UpDown1"
			.TabIndex = 9
			.SetBounds 120, 93, 17, 25
			.Designer = @This
			.OnChanging = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Value As Integer, Direction As Integer), @UpDown1_Changing)
			.Parent = @GroupBox1
		End With
		' txtChessSize
		With txtChessSize
			.Name = "txtChessSize"
			.Text = "19"
			.TabIndex = 10
			.SetBounds 84, 98, 31, 17
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' chkComputerFirst
		With chkComputerFirst
			.Name = "chkComputerFirst"
			.Text = ML("Computer first") '"电脑先下"
			.TabIndex = 9
			.Checked = True
			.SetBounds 18, 74, 117, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' LinkLblAbout
		With LinkLblAbout
			.Name = "LinkLblAbout"
			.Text = !"Wuziqi(also known as 'Five in a Row', Gomoku, GoLang) is a two-player abstract strategy game generally played with Go pieces on a 19x19 Go board.\r\rRuler：\r" & _
			!"The objective of the game is to be the first player to create a sequence of five same-colored pieces vertically, horizontally, or diagonally." & _
			!"Pieces are never taken off the board, and once the whole board is filled, the game draws.\r" & _
			!"This APP made by Avata with <a href=""https://www.freebasic.net/"">freeBasic</a>\r" & _
			!"Compile the source code need the <a href=""https://github.com/XusinboyBekchanov/MyFbFramework"">MyFbFramework</a> frame," & _
			!"Edited by freeBasic IDE <a href=""https://github.com/XusinboyBekchanov/VisualFBEditor"">VisualFBEditor</a> Visual design\r\r" & _
			!"Download address:<a href=""https://gitee.com/avata/MyFbFramework"">https://gitee.com/avata/MyFbFramework</a>\r " & _
			!"VisualFBEditor: <a href=""https://gitee.com/avata/VisualFBEditor""> https://gitee.com/avata/VisualFBEditor</a>"
			
			'			.Text = "五子棋是一款双人抽象策略游戏。" & Chr(13, 10) &  Chr(13, 10) & "规则：" & Chr(13, 10)  & _
			'					"每个玩家轮流放置自己的棋子，游戏的目标是成为第一个垂直，水平或对角线创建五个相同颜色棋子序列的玩家。" & _
			'					"棋子永远不会从棋盘上取下，一旦整个棋盘被填满，游戏平局。" & Chr(13, 10) & Chr(13, 10) & _
			'					"本程序是阿凡达用freeBasic语言编写并开源, " & _
			'					"源程序编译需要MyFbFramework框架支持，" & _
			'					"并由VisualFBEditor进行可视化窗体设计。" & Chr(13, 10) & Chr(13, 10) & _
			'					"GitHub, 码云下载地址:" & Chr(13, 10) & "MyFbFramework框架: https://gitee.com/avata/MyFbFramework" & _
			'					Chr(13, 10) & "   VisualFBEditor: https://gitee.com/avata/VisualFBEditor"
			.TabIndex = 10
			'.Multiline = True
			'.WordWraps = True
			.SetBounds 639, 264, 159, 367
			.Designer = @This
			.Parent = @This
		End With
		' lblChessText
		With lblChessText(0)
			.Name = "lblChessText(0)"
			.Text = ML("Chess Background:")  '"Change Background" '"棋盘背景:"
			.TabIndex = 11
			.SetBounds 20, 120, 70, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		
		With lblChessText(1)
			.Name = "lblChessText(1)"
			.Text = ML("Grid Color:")  '"Grid Color" '"网格颜色:"
			.TabIndex = 11
			.SetBounds 20, 141, 70, 16
			.Designer = @This
			.Parent = @GroupBox1
		End With
		
		' lblColorBK
		With lblColorBK(0)
			.Name = "lblColorBK(0)"
			.Text = ""
			.TabIndex = 12
			.Caption = ""
			.SetBounds 82, 121, 35, 14
			.Designer = @This
			.Parent = @GroupBox1
		End With
		' lblColorBK
		With lblColorBK(1)
			.Name = "lblColorBK(1)"
			.Text = ""
			.TabIndex = 12
			.Caption = ""
			.SetBounds 83, 141, 35, 14
			.Designer = @This
			.Parent = @GroupBox1
		End With
		
		' cmdChangBK
		With cmdChangBK(0)
			.Name = "cmdChangBK(0)"
			.Text = "..."
			.TabIndex = 13
			.Caption = "..."
			.SetBounds 120, 123, 27, 17
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdChangBK_Click)
			.Parent = @GroupBox1
		End With
		
		With cmdChangBK(1)
			.Name = "cmdChangBK(1)"
			.Text = "..."
			.TabIndex = 13
			.Caption = "..."
			.SetBounds 120, 141, 27, 17
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdChangBK_Click)
			.Parent = @GroupBox1
		End With
		
		' ColorDialog1
		With ColorDialog1
			.Name = "ColorDialog1"
			.SetBounds 692, 1, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmWuziqi As frmWuziqiType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		App.DarkMode = True
		frmWuziqi.MainForm = True
		frmWuziqi.Show
		App.Run
	#endif
'#End Region

Private Sub frmWuziqiType.cmdStart_Click(ByRef Sender As Control)
	InitPlayEnvironment
End Sub

Private Sub frmWuziqiType.InitPlayEnvironment()
	'player.filename = ".\music\zhyu01.mid"
	'player.play()
	If ChessSize<> Val(txtChessSize.Text) Then
		ChessSize= Max(10, Min(19, Val(txtChessSize.Text)))
		txtChessSize.Text = Str(ChessSize)
		
		WinStepSum = max(WinStepsTotal(Val(txtChessSize.Text)), 192)
		ReDim As Integer Table(ChessSize+ 1, ChessSize+ 1) ' =0, 无子， 1 黑子， 2 白子
		'　　定义虚拟桌面：
		ReDim Table(ChessSize, ChessSize) As Integer
		'　  定义当前玩家桌面空格的分数：
		ReDim pScore(ChessSize, ChessSize) As Integer
		'　　定义当前电脑桌面空格的分数：
		ReDim cScore(ChessSize, ChessSize) As Integer
		'　　定义玩家的获胜组合：
		ReDim  PersonWin(ChessSize, ChessSize, WinStepSum) As Boolean
		'　　定义电脑的获胜组合：
		ReDim  ComputerWin(ChessSize, ChessSize, WinStepSum) As Boolean
		'　　定义玩家的获胜组合标志：
		ReDim  PersonFlag(WinStepSum) As Boolean
		'　　定义电脑的获胜组合标志：
		ReDim ComputerFlag(WinStepSum) As Boolean
	End If
	With Picture1.Canvas
		.Pen.Color = ColorChessBK
		.CreateDoubleBuffer
		.Cls
		For i As Integer = 1 To ChessSize     ''''''画游戏棋盘ChessSize 19*19
			.Line i * ChessR + ChessR / 2, ChessR + ChessR / 2, i * ChessR + ChessR / 2, ChessSize * ChessR + ChessR / 2
			.TextOut i * ChessR + ChessR / 3, ChessR / 3, Str(i), clBlack
			.Line ChessR + ChessR / 2 , ChessR *i + ChessR / 2, ChessSize * ChessR + ChessR / 2, ChessR *i + ChessR / 2
			.TextOut  ChessR / 3 , ChessR *i + ChessR / 3 , Chr(i + 64), clBlack
		Next
		.DeleteDoubleBuffer
	End With
	
	PlayingFlag = True           '游戏有效
	lblInfomation.visible = True       '游戏状态标签显示
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.text = ML("Player Turn......" )  '"等待玩家落子......"
	Dim  As Integer i, j, m, n
	
	'桌面初始化
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 1
			Table(i, j) = 0
		Next
	Next
	
	'获胜标志初始化
	For i = 0 To WinStepSum
		PersonFlag(i) = True
		ComputerFlag(i) = True
	Next
	
	'******** 初始化获胜组合 ********
	n = 0
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			For m = 0 To 4
				PersonWin(j + m, i, n) = True
				ComputerWin(j + m, i, n) = True
			Next
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			For m = 0 To 4
				PersonWin(i, j + m, n) = True
				ComputerWin(i, j + m, n) = True
			Next
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = 0 To ChessSize - 5
			For m = 0 To 4
				PersonWin(j + m, i + m, n) = True
				ComputerWin(j + m, i + m, n) = True
			Next
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = ChessSize - 1 To 4 Step -1
			For m = 0 To 4
				PersonWin(j - m, i + m, n) = True
				ComputerWin(j - m, i + m, n) = True
			Next
			n = n + 1
		Next
	Next
	
	''由于我们设定电脑先手，并下在了坐标ChessSize*ChessR / 2, 调用绘图函数绘制当前电脑先走的位置
	If chkComputerFirst.Checked = True Then
		zhX = ChessSize / 2 : zhY = ChessSize/ 2
		zhXOld = -2: zhYOld = -2
		DrawCompter((zhX + 1)*ChessR + ChessR / 2 , (zhY + 1)*ChessR + ChessR / 2 )
		Table(zhX , zhY) = 1              '由于我们设定电脑先手，并下了ChessSize / 2，ChessSize / 2位所以将其值设为1
		'由于电脑已下了ChessSize/ 2，ChessSize/ 2位所以我们需要重新设定玩家的获胜标志
		For i = 0 To WinStepSum
			If PersonWin(zhX,  zhY, i) = True Then
				PersonFlag(i) = False
			End If
		Next
	Else
		zhXOld = -2: zhYOld = -2
	End If
	
	'******** 初始化获胜组合结束 ********
	
End Sub

Private Sub frmWuziqiType.Form_Show(ByRef Sender As Form)
	'Picture1.Style = 16
	colorPerson = clWhite: ColorComputer = clBlack: ColorLastStep = clPurple: ColorChessBK = 8421376: ColorChessGrid = &HF00f0000
	lblColorBK(0).BackColor = ColorChessBK
	lblColorBK(1).BackColor = ColorChessGrid  
	InitPlayEnvironment
End Sub

Private Sub frmWuziqiType.Picture1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If PlayingFlag = False Then Exit Sub '检查游戏状态是否有效
	If x > ChessR  And y > ChessR  And x < ChessSize * ChessR + ChessR  And y < ChessSize * ChessR + ChessR Then
		Dim As Integer i, j, k
		k = mSteps Mod 2
		zhX =  Int(X / ChessR) - 1
		zhY =  Int(Y / ChessR) - 1
		Print Int(x / ChessR), Int(y / ChessR)
		'检查当前鼠标点击的格子是否有效
		For i = 0 To ChessSize - 1
			For j = 0 To ChessSize - 1
				If Table(zhX, zhY) > 0 Then
					Exit Sub
				End If
			Next
		Next
		
		Dim myColor As Integer
		'绘制玩家的棋子
		If ZhXOld > -1 Then
			Picture1.Canvas.Pen.Color = ColorComputer
			Picture1.Canvas.Brush.Color = ColorComputer
			Picture1.Canvas.Circle((zhXOld + 1) * ChessR + ChessR / 2, (zhYOld + 1) * ChessR + ChessR / 2, ChessR - 2, ColorComputer)
		End If
		Picture1.Canvas.Pen.Color = ColorLastStep
		Picture1.Canvas.Circle((zhX + 1) * ChessR + ChessR / 2, (zhY + 1) * ChessR + ChessR / 2, ChessR - 2, colorPerson)
		zhXOld = zhX:  zhYOld = zhY
		Table(zhX, zhY) = 2
		For i = 0 To WinStepSum
			If ComputerWin(zhX, zhY, i) = True Then
				ComputerFlag(i) = False
			End If
		Next
		
		'重设电脑的获胜标志
		CheckWhoWin(1)               '检查当前玩家是否获胜
		ComputerAI()                '调用电脑算法
	EndIf
	
End Sub

'*****************************************************************************
'** 模块名称: 获胜检查算法。 CheckWhoWin
'* *
'* * 描述: 此模块执行以下功能:
'* * 1. 检查是否和棋。
'* * 2. 检查电脑是否获胜。
'* * 3. 检查玩家是否获胜。
'**
'*****************************************************************************

Sub frmWuziqiType.CheckWhoWin(ByVal BlackOrWhite As Integer)
	Dim  As Integer i, j, k, m, n
	Dim ca As Integer
	Dim pa As Integer
	Dim ComputerNormal As Integer = 0
	Picture1.Cursor = crHand '14 - 手型
	For i = 0 To WinStepSum
		If ComputerFlag(i) = False Then ComputerNormal = ComputerNormal + 1
	Next
	
	'设定和棋规则
	If ComputerNormal = WinStepSum  - 1 Then
		lblInfomation.visible = True
		lblInfomation.BackColor = clBLue
		lblInfomation.text = ML("Noone Win.") '"和棋，请重新开始！"
		PlayingFlag = False
		Exit Sub
	End If
	
	Dim As Integer Xmin, XMax, YMin, YMax
	Xmin = 0: XMax = ChessSize-1
	YMin = 0: YMax = ChessSize-1
	'检查电脑是否获胜
	For i = 0 To WinStepSum
		If ComputerFlag(i) = True Then
			ca = 0
			For j = Xmin To XMax
				For k = Ymin To YMax
					If Table(j, k) = 1 Then
						If ComputerWin(j, k, i) = True Then
							ca = ca + 1
						End If
					End If
				Next
			Next
			
			If ca = 5 Then
				lblInfomation.visible = True
				lblInfomation.BackColor = clGreen
				lblInfomation.text = ML("Computer win.")  '"电脑获胜,请重新开始"
				PlayingFlag = False
				Exit Sub
			End If
		End If
	Next
	
	'检查玩家是否获胜
	For i = 0 To WinStepSum
		If PersonFlag(i) = True Then
			pa = 0
			For j = Xmin To XMax
				For k = Ymin To YMax
					If Table(j, k) = 2 Then
						If PersonWin(j, k, i) = True Then
							pa = pa + 1
						End If
					End If
				Next
			Next
			
			If pa = 5 Then
				lblInfomation.visible = True
				lblInfomation.BackColor = clRed
				lblInfomation.text = ML("Player Win.")  '"玩家获胜,请重新开始"
				PlayingFlag = False
				Exit Sub
			End If
		End If
	Next
	
End Sub


'*****************************************************************************
'* * 模块名称: 电脑算法 ComputerAI

'** 描述: 此程序主要执行以下功能：
'** 1. 初始化赋值系统。
'** 2. 赋值加强算法。
'** 3. 计算电脑和玩家的最佳攻击位。
'** 4. 比较电脑和玩家的最佳攻击位并决定电脑的最佳策略。
'** 5. 执行检查获胜函数。
'*****************************************************************************

Sub frmWuziqiType.ComputerAI()
	Dim  As Integer i, j, k, m, n
	Dim dc As Integer
	Dim cab As Integer
	Dim pab As Integer
	If PlayingFlag = False Then Exit Sub
	lblInfomation.visible = True
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.text = "Computer Searching......"    ' "电脑思考中......"
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 1
			pScore(i, j) = 0
			cScore(i, j) = 0
		Next
	Next
	
	'调整搜索范围，改变游戏难易程度
	Dim As Integer Xmin, XMax, YMin, YMax
	'Xmin = Max(0, zhX - 8): XMax = Min(ChessSize-1, zhX + 8)
	'YMin = Max(0, zhY - 8): YMax = Min(ChessSize-1, zhY + 8)
	
	Xmin = 0: XMax = ChessSize-1
	YMin = 0: YMax = ChessSize-1
	'Print Xmin, XMax, Ymin, YMax
	Picture1.Cursor = crWait
	'初始化赋值数组
	'* * * * * * * * 电脑加强算法 * * * * * * * *
	For i = 0 To WinStepSum
		If ComputerFlag(i) = True Then
			cab = 0
			For j = Xmin To XMax
				For k = Ymin To YMax
					If Table(j, k) = 1 Then
						If ComputerWin(j, k, i) = True Then
							cab = cab + 1
						End If
					End If
				Next
			Next
			
			Select Case cab
			Case 3
				For m = Xmin To XMax
					For n = Ymin To YMax
						If Table(m, n) = 0 Then
							If ComputerWin(m, n, i) = True Then
								cScore(m, n) = cScore(m, n) + 5
							End If
						End If
					Next
				Next
			Case 4
				For m = Xmin To XMax
					For n = Ymin To YMax
						If Table(m, n) = 0 Then
							If ComputerWin(m, n, i) = True Then
								DrawCompter((m + 1) * ChessR + ChessR / 2, (n + 1) * ChessR + ChessR / 2)
								Table(m, n) = 1
								For dc = 0 To WinStepSum
									If PersonWin(m, n, dc) = True Then
										PersonFlag(dc) = False
										CheckWhoWin(1)
										Exit Sub
									End If
								Next
							End If
						End If
					Next
				Next
			End Select
		End If
	Next
	
	For i = 0 To WinStepSum
		If PersonFlag(i) = True Then
			pab = 0
			For j = Xmin To XMax
				For k = Ymin To YMax
					If Table(j, k) = 2 Then
						If PersonWin(j, k, i) = True Then
							pab = pab + 1
						End If
					End If
				Next
			Next
			
			Select Case pab
			Case 3
				For m = Xmin To XMax
					For n = Ymin To YMax
						If Table(m, n) = 0 Then
							If PersonWin(m, n, i) = True Then
								pScore(m, n) = pScore(m, n) + ChessR
							End If
						End If
					Next
				Next
			Case 4
				For m = Xmin To XMax
					For n = Ymin To YMax
						If Table(m, n) = 0 Then
							If PersonWin(m, n, i) = True Then
								DrawCompter((m + 1) * ChessR + ChessR / 2, (n + 1) * ChessR + ChessR / 2)
								Table(m, n) = 1
								For dc = 0 To WinStepSum
									If PersonWin(m, n, dc) = True Then
										PersonFlag(dc) = False
										CheckWhoWin(0)
										Exit Sub
									End If
								Next
							End If
						End If
					Next
				Next
			End Select
		End If
	Next
	
	'******** 电脑加强算法结束 ********
	
	'******** 赋值系统 ********
	For i = 0 To WinStepSum
		If ComputerFlag(i) = True Then
			For j = Xmin To XMax
				For k = Ymin To YMax
					If Table(j, k) = 0 Then
						If ComputerWin(j, k, i) = True Then
							For m = Xmin To XMax
								For n = Ymin To YMax
									If Table(m, n) = 1 Then
										If ComputerWin(m, n, i) = True Then
											cScore(j, k) = cScore(j, k) + 1
										End If
									End If
								Next
							Next
						End If
					End If
				Next
			Next
		End If
	Next
	
	For i = 0 To WinStepSum
		If PersonFlag(i) = True Then
			For j = Xmin To XMax
				For k = Ymin To YMax
					If Table(j, k) = 0 Then
						If PersonWin(j, k, i) = True Then
							For m = Xmin To XMax
								For n = Ymin To YMax
									If Table(m, n) = 2 Then
										If PersonWin(m, n, i) = True Then
											pScore(j, k) = pScore(j, k) + 1
										End If
									End If
								Next
							Next
						End If
					End If
				Next
			Next
		End If
	Next
	
	'******** 赋值系统结束 ********
	
	'* * * * * * * * 分值比较算法 * * * * * * * *
	Dim As Integer a, b, c, d
	Dim cs As Integer = 0
	Dim ps As Integer = 0
	For i = Xmin To XMax
		For j = Ymin To YMax
			If cScore(i, j) > cs Then
				cs = cScore(i, j)
				a = i
				b = j
			End If
		Next
		
	Next
	
	For i = Xmin To XMax
		For j = Ymin To YMax
			If pScore(i, j) > ps Then
				ps = pScore(i, j)
				c = i
				d = j
			End If
		Next
	Next
	
	If cs > ps Then
		DrawCompter((a + 1) * ChessR + ChessR / 2, (b + 1) * ChessR + ChessR / 2)
		Table(a, b) = 1
		For i = 0 To WinStepSum
			If PersonWin(a, b, i) = True Then
				PersonFlag(i) = False
			End If
		Next
	Else
		DrawCompter((c + 1) * ChessR + ChessR / 2, (d + 1) * ChessR + ChessR / 2)
		Table(c, d) = 1
		For i = 0 To WinStepSum
			If PersonWin(c, d, i) = True Then
				PersonFlag(i) = False
			End If
		Next
	End If
	lblInfomation.visible = True
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.text = "Player Turn......"  '"等待玩家落子......"
	'******** 分值比较算法结束 ********
	CheckWhoWin(0)
End Sub
''*****************************************************************************
'* * 模块名称: 绘制棋子  DrawCompter
'** 描述: 此函数主要进行电脑棋子的绘制。
'*****************************************************************************

Sub frmWuziqiType.DrawCompter(ByVal x As Integer, ByVal y As Integer)
	Dim As Integer tX, tY
	tX =  Int(x / ChessR)
	tY =  Int(Y / ChessR)
	lblInfomation.visible = True
	lblInfomation.BackColor = frmWuziqi.BackColor
	lblInfomation.text = ML("Player Turn......" ) '"等待玩家落子......"
	If ZhXOld > -1 Then
		Picture1.Canvas.Pen.Color = colorPerson
		Picture1.Canvas.Brush.Color = colorPerson
		Picture1.Canvas.Circle((ZhXOld + 1) * ChessR + ChessR / 2, (ZhYOld + 1) * ChessR + ChessR / 2, ChessR - 2, colorPerson)
	End If
	Picture1.Canvas.Pen.Color = ColorLastStep
	Picture1.Canvas.Brush.Color = ColorComputer
	Picture1.Canvas.Circle(tX * ChessR + ChessR / 2, tY * ChessR + ChessR / 2, ChessR - 2, ColorComputer)
	ZhXOld = tX - 1: ZhYOld = tY - 1
End Sub

Public Function frmWuziqiType.WinStepsTotal(ByVal tChessSize As Long) As Long
	'根据输入的棋盘布局n*n计算总共有多少种获胜组合
	'假定棋盘为10X10相应的棋盘数组就是Table(9, 9)
	'水平方向每一列获胜组合是6共10列6*10=60
	' 垂直方向每一-行获胜组合是6共10行8*10=60
	'正对角线方向6+(5+4+3+2+1)*2=36
	'反对角线方向 6+(5+4+3+2+1)*2=36
	' 总的获胜组合数为60 + 60 + 36 +36= 192
	Dim As Long i, j, m, n
	'For i = n - 5 To 1 Step -1: n += i: Next
	'Return 2 * (2 * t + n - 4) + 2 * n * (n - 4)
	
	'******** 初始化获胜组合 ********
	n = 0
	n = 0
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 1
		For j = 0 To ChessSize - 5
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = 0 To ChessSize - 5
			n = n + 1
		Next
	Next
	
	For i = 0 To ChessSize - 5
		For j = ChessSize - 1 To 4 Step -1
			n = n + 1
		Next
	Next
	Return n
	
End Function

Private Sub frmWuziqiType.Picture1_MouseMove(ByRef Sender As Control, MouseButton As Integer,x As Integer,y As Integer, Shift As Integer)
	If x > ChessR And y > ChessR And x < ChessR * ChessSize And y < ChessR * ChessSize Then
		frmWuziqi.Cursor = crWait
	Else
		frmWuziqi.Cursor = crHand
	End If
End Sub


Private Sub frmWuziqiType.Picture1_Click(ByRef Sender As Picture)
	
End Sub

Private Sub frmWuziqiType.UpDown1_Changing(ByRef Sender As UpDown,Value As Integer,Direction As Integer)
	'Print "Value As Integer, Direction" & Value & " " & Direction
	If Val(txtChessSize.Text) >= 19 AndAlso Direction = 1 OrElse (Val(txtChessSize.Text) <= 10 AndAlso Direction = -1) Then Exit Sub
	txtChessSize.Text  = Str(Val(txtChessSize.Text) + Direction)
End Sub

Private Sub frmWuziqiType.cmdChangBK_Click(ByRef Sender As Control)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	ColorDialog1.Color = lblColorBK(Index).BackColor
	If ColorDialog1.Execute Then
		lblColorBK(Index).BackColor = ColorChessBK
		If Index = 0 Then
		ColorChessBK = ColorDialog1.Color
		Else
		ColorChessGrid = ColorDialog1.Color
		End If
	End If
End Sub

