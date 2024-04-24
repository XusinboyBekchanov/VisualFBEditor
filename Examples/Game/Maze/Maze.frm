'################################################################################
'#  Maze.frm                                                              #
'#  This file is an examples of MyFBFramework.                                  #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'################################################################################

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/Picture.bi"
	#include once "mff/Label.bi"
	#include once "mff/ScrollControl.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TrackBar.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/NumericUpDown.bi"
	#include once "mff/UpDown.bi"
	#include once "maze.bi"
	Using My.Sys.Forms

	Dim Shared As Maze aMaze
	Dim Shared As Integer MazeX, MazeY
	Dim Shared As Boolean Ending, Playing = True
	' Adjust speed here
	Dim Shared As Long speed = 160 ' Frames Per Second
	' Adjust speed here
	Dim Shared As Long fps
	
	Type Form1Type Extends Form
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub PanelRender_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub cmdPlay_Click(ByRef Sender As Control)
		Declare Sub cmdRefresh_Click(ByRef Sender As Control)
		Declare Sub TrackBarFPS_Change(ByRef Sender As TrackBar, Position As Integer)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub PanelRender_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub TimerFPS_Timer(ByRef Sender As TimerComponent)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub NumUpDnWallSize_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Sub NumUpDnMazeSize_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Constructor
		
		Dim As Picture PanelRender
		Dim As ScrollControl ScrollMaze
		Dim As Label lblFPS, lblLanguage, lblMazeSize, lblWallSize ', lblPosition
		Dim As CommandButton cmdRefresh, cmdPlay
		Dim As TrackBar TrackBarFPS
		Dim As TimerComponent TimerFPS
		Dim As NumericUpDown NumUpDnMazeSize, NumUpDnWallSize
		
	End Type
	
	Constructor Form1Type
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/"
				.CurLanguage = .Language  '"Chinese (Simplified)"
			End With
		#endif
		' Form1
		With This
			.Name = "Form1"
			.Text = "VisualFBEditor-Maze"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Form_Paint)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.SetBounds 0, 0, 620, 450
		End With
		
		' PanelRender
		With PanelRender
			.Name = "PanelRender"
			.Text = "PanelRender"
			.TabIndex = 2
			.BackColor = 8421376
			.DoubleBuffered = True
			'.Anchor.Top = AnchorStyle.asAnchor
			'.Anchor.Right = AnchorStyle.asAnchor
			'.Anchor.Left = AnchorStyle.asAnchor
			'.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 0, 10, 310, 240
			.Designer = @This
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @PanelRender_Resize)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @PanelRender_Paint)
			.Parent = @ScrollMaze
		End With
		' lblFPS
		With lblFPS
			.Name = "lblFPS"
			.Text = "FPS："
			.TabIndex = 1
			.SetBounds 10, 40, 70, 20
			.Designer = @This
			.Parent = @This
		End With
		' cmdRefresh
		With cmdRefresh
			.Name = "cmdRefresh"
			.Text = ML("Refresh")
			.TabIndex = 2
			.SetBounds 20, 70, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdRefresh_Click)
			.Parent = @This
		End With
		' cmdPlay
		With cmdPlay
			.Name = "cmdPlay"
			.Text = ML("Play")
			.TabIndex = 3
			.ControlIndex = 2
			.Visible = False
			.SetBounds 20, 100, 60, 20
			.Enabled = False
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdPlay_Click)
			.Parent = @This
		End With
		' TrackBarFPS
		With TrackBarFPS
			.Name = "TrackBarFPS"
			.Text = "TrackBarFPS"
			.TabIndex = 4
			.ControlIndex = 4
			.Hint = ML("change the FPS")
			.MaxValue = 255
			.MinValue = 10
			.Position = speed
			.SetBounds 8, 55, 77, 10
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer), @TrackBarFPS_Change)
			.Parent = @This
		End With
		' lblLanguage
		With lblLanguage
			.Name = "lblLanguage"
			.Text = ML("Language:") & App.CurLanguage
			.TabIndex = 5
			.ControlIndex = 1
			.SetBounds 10, 0, 100, 40
			.Designer = @This
			.Parent = @This
		End With
		
		' TimerFPS
		With TimerFPS
			.Name = "TimerFPS"
			.Interval = 50
			.Enabled = True
			.SetBounds 20, 200, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerFPS_Timer)
			.Parent = @This
		End With
		' lblMazeSize
		With lblMazeSize
			.Name = "lblMazeSize"
			.Text = ML("Maze Size:")
			.TabIndex = 6
			.SetBounds 10, 130, 60, 20
			.Designer = @This
			.Parent = @This
		End With
		' NumUpDnMazeSize
		With NumUpDnMazeSize
			.Name = "NumUpDnMazeSize"
			.Text = "20"
			.TabIndex = 8
			.MaxValue = 10
			.MinValue = 100
			.SetBounds 70, 130, 40, 20
			.Designer = @This
			.OnKeyPress = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer), @NumUpDnMazeSize_KeyPress)
			.Parent = @This
		End With
		' lblWallSize
		With lblWallSize
			.Name = "lblWallSize"
			.Text = ML("Wall Size:")
			.TabIndex = 9
			.ControlIndex = 6
			.SetBounds 10, 160, 60, 20
			.Designer = @This
			.Parent = @This
		End With
		' NumUpDnWallSize
		With NumUpDnWallSize
			.Name = "NumUpDnWallSize"
			.Text = "0"
			.TabIndex = 11
			.ControlIndex = 8
			.MaxValue = 10
			.MinValue = 100
			.SetBounds 70, 160, 40, 20
			.Designer = @This
			.OnKeyPress = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer), @NumUpDnWallSize_KeyPress)
			.Parent = @This
		End With
		
			' ScrollMaze
		With ScrollMaze
			.Name = "ScrollMaze"
			.Text = "ScrollMaze"
			.TabIndex = 14
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 120, 10, 479, 390
			.Designer = @This
			.Parent = @This
		End With
	'
	'	' lblPosition
	'	With lblPosition
	'		.Name = "lblPosition"
	'		.Text = "VisualFBEditor"
	'		.TabIndex = 13
	'		.SetBounds 360, 380, 260, 120
	'		.Designer = @This
	'		.Parent = @ScrollMaze
	'	End With
	End Constructor
	
	Dim Shared Form1 As Form1Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form1.MainForm = True
		Form1.Show
		App.Run
	#endif
'#End Region

Function regulate(ByVal myfps As Long, ByRef fps As Long) As Long
	Static As Double timervalue, _lastsleeptime, t3, frames
	frames += 1
	If (Timer - t3) >= 1 Then t3 = Timer : fps = frames : frames = 0
	Var sleeptime = _lastsleeptime + ((1 / myfps) - Timer + timervalue) * 1000
	If sleeptime < 1 Then sleeptime = 1
	_lastsleeptime = sleeptime
	timervalue = Timer
	Return sleeptime
End Function

'the main rendering code.  渲染代码主过程。
Sub RenderProj(Param As Any Ptr)
	
End Sub

Private Sub Form1Type.Form_Create(ByRef Sender As Control)
	
End Sub

Private Sub Form1Type.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	
End Sub


Private Sub Form1Type.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	Ending = True
End Sub

Private Sub Form1Type.PanelRender_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	
End Sub

Private Sub Form1Type.cmdPlay_Click(ByRef Sender As Control)
	Playing = True
	cmdPlay.Enabled = Not Playing
	cmdRefresh.Enabled = Playing
	If Playing Then RenderProj(0)
	TimerFPS.Enabled = Playing
	'aMaze.Show(Val(NumUpDnWallSize.Text))
	
End Sub

Private Sub Form1Type.cmdRefresh_Click(ByRef Sender As Control)
	'Playing = False
	'cmdPlay.Enabled = Not Playing
	'cmdRefresh.Enabled = Playing
	'If Playing Then RenderProj(0)
	cmdRefresh.Enabled = False
	PanelRender.Width = (Val(NumUpDnMazeSize.Text) + 1) * Val(NumUpDnWallSize.Text): PanelRender.Height = PanelRender.Width
	'lblPosition.Left = PanelRender.Width + 20 : lblPosition.Top = PanelRender.Height + 20
	TimerFPS.Enabled = Playing
	MazeX = 0 : MazeY = 0
	aMaze.Init(Val(NumUpDnMazeSize.Text), Val(NumUpDnWallSize.Text))
	PanelRender.Repaint
	cmdRefresh.Enabled = True
End Sub

Private Sub Form1Type.TrackBarFPS_Change(ByRef Sender As TrackBar, Position As Integer)
	If Sender.Position < 10 Then Sender.Position = 10
	speed = Sender.Position
	lblFPS.Text = "FPS:" & speed
End Sub

Private Sub Form1Type.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	
End Sub

Private Sub Form1Type.PanelRender_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Dim As Integer x, y, xx, yy, ws
	ws = aMaze.WallSize / 2
	Debug.Print "aMaze.WallSize=" & aMaze.WallSize
	Debug.Print "aMaze.MazeSize=" & aMaze.MazeSize
	'Canvas.Scale(0, 0, (aMaze.MazeSize+ 1) * aMaze.WallSize / 2, (aMaze.MazeSize+ 1) * aMaze.WallSize/ 2)
	Canvas.Cls
	For x = 0 To aMaze.MazeSize -1
		For y = 0 To aMaze.MazeSize -1
			xx = x*aMaze.WallSize + aMaze.WallSize
			yy = y*aMaze.WallSize + aMaze.WallSize
			If aMaze.rooms(x, y).getStatus() And (Gen Or Visited) Then
				'Canvas.Line(xx - ws, yy - ws, xx + ws, yy + ws, RGB(0, 32, 0), "bf")
				If aMaze.rooms(x, y).getStatus() And Gen Then Canvas.Circle(xx, yy, ws / 2, RGB(255, 128, 0))
				If aMaze.rooms(x, y).isWall(North) And WALL Then Canvas.Line (xx - ws, yy - ws, xx + ws, yy - ws, RGB(0, 255, 0))
				If aMaze.rooms(x, y).isWall(West)  And WALL Then Canvas.Line (xx - ws, yy - ws, xx - ws, yy + ws, RGB(0, 255, 0))
				If aMaze.rooms(x, y).isWall(South) And WALL Then Canvas.Line (xx - ws, yy + ws, xx + ws, yy + ws, RGB(0, 255, 0))
				If aMaze.rooms(x, y).isWall(East)  And WALL Then Canvas.Line (xx + ws, yy - ws, xx + ws, yy + ws, RGB(0, 255, 0))
			End If
		Next
	Next
	'Draw entry
	x = 0: y = 0
    xx = x*aMaze.WallSize + aMaze.WallSize
	yy = y*aMaze.WallSize + aMaze.WallSize
	'Canvas.Line(xx - ws * 1.1, yy - ws * 0.7, xx - ws *.9, yy + ws *.8, PanelRender.BackColor) ', "bf")
	Canvas.Line (xx - ws, yy - ws, xx - ws, yy + ws, PanelRender.BackColor)
	Canvas.TextOut(xx - ws *.8, yy - ws *.8, "->")
	
	'Draw Exit
	x = aMaze.MazeSize -1: y = aMaze.MazeSize -1
    xx = x*aMaze.WallSize + aMaze.WallSize
	yy = y*aMaze.WallSize + aMaze.WallSize
	'Canvas.Line(xx + ws *.9, yy - ws * 0.7, xx + ws * 1.1, yy + ws *.8, PanelRender.BackColor) ', "bf")
	Canvas.Line (xx + ws, yy - ws, xx + ws, yy + ws, PanelRender.BackColor)
	Canvas.TextOut(xx - ws * 0.2, yy - ws *.8, "->")
	'
	'Exit Sub
	'For x = 0 To aMaze.MazeSize -1
	'	For y = 0 To aMaze.MazeSize -1
	'		xx = x * aMaze.WallSize + aMaze.WallSize
	'		yy = y * aMaze.WallSize + aMaze.WallSize
	'		If aMaze.rooms(x,y).getStatus() And (Gen Or Visited) Then
	'		Else
	'			Canvas.Line(xx - ws, yy - ws, xx + ws, yy + ws, RGB(0, 64, 0), "bf")
	'		End If
	'	Next
	'Next
End Sub

Private Sub Form1Type.TimerFPS_Timer(ByRef Sender As TimerComponent)
	
	'App.DoEvents
	If MazeY > aMaze.MazeSize- 1 Then
		MazeX += 1
		MazeY = 0
	End If
	'PanelRender.Repaint
	MazeY += 1
	Sleep regulate(speed, fps), 1
	
End Sub

Private Sub Form1Type.Form_Show(ByRef Sender As Form)
	cmdRefresh_Click(Sender)
End Sub

Private Sub Form1Type.NumUpDnWallSize_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then cmdRefresh_Click(Sender)
End Sub

Private Sub Form1Type.NumUpDnMazeSize_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then cmdRefresh_Click(Sender)
End Sub
