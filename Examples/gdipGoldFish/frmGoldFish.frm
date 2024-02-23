'frmGoldFish金鱼
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmGoldFish.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Menus.bi"
	
	#include once "../MDINotepad/Text.bi"
	#include once "../gdipClock/gdip.bi"
	#include once "../gdipClock/gdipAnimate.bi"
	
	Using My.Sys.Forms
	
	Type frmGoldFishType Extends Form
		'initial gdip token
		Token As gdipToken
		'form trans
		frmTrans As gdipForm
		'form display device
		frmDC As gdipDC
		'memory display device
		memDC As gdipDC
		'form canvas
		frmGraphic As gdipGraphics
		mGoldFish As gdipAnimate
		
		Declare Sub PaintFish(ByVal sInc As Integer = 1)
		
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub MenuItem_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuTransparent, MenuItem1, mnuExit, MenuItem2, mnuRotate0, mnuRotate1, mnuRotate2, mnuRotate3, mnuRotate4, mnuRotate5, mnuRotate6, mnuRotate7, mnuAnimate
	End Type
	
	Constructor frmGoldFishType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = "english"
			End With
		#endif
		' frmGoldFish
		With This
			.Name = "frmGoldFish"
			.Text = "GoldFish"
			.Designer = @This
			.Caption = "GoldFish"
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Form_Paint)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.ContextMenu = @PopupMenu1
			.ShowCaption = False
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 350, 300
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 50
			.Enabled = True
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 40, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuAnimate
		With mnuAnimate
			.Name = "mnuAnimate"
			.Designer = @This
			.Caption = "Animate"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = "Transparent"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Checked = True
			.Parent = @PopupMenu1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuRotate0
		With mnuRotate0
			.Name = "mnuRotate0"
			.Designer = @This
			.Caption = "0"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuRotate1
		With mnuRotate1
			.Name = "mnuRotate1"
			.Designer = @This
			.Caption = "1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuRotate2
		With mnuRotate2
			.Name = "mnuRotate2"
			.Designer = @This
			.Caption = "2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuRotate3
		With mnuRotate3
			.Name = "mnuRotate3"
			.Designer = @This
			.Caption = "3"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuRotate4
		With mnuRotate4
			.Name = "mnuRotate4"
			.Designer = @This
			.Caption = "4"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuRotate5
		With mnuRotate5
			.Name = "mnuRotate5"
			.Designer = @This
			.Caption = "5"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuRotate6
		With mnuRotate6
			.Name = "mnuRotate6"
			.Designer = @This
			.Caption = "6"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuRotate7
		With mnuRotate7
			.Name = "mnuRotate7"
			.Designer = @This
			.Caption = "7"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuExit
		With mnuExit
			.Name = "mnuExit"
			.Designer = @This
			.Caption = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
	End Constructor
	
	Dim Shared frmGoldFish As frmGoldFishType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmGoldFish.MainForm = True
		frmGoldFish.Show
		App.Run
	#endif
'#End Region

Private Sub frmGoldFishType.PaintFish(ByVal sInc As Integer = 1)
	If mnuTransparent.Checked Then
		frmTrans.Create(Handle, mGoldFish.Animate(sInc))
		frmTrans.Transform(&Hff)
	Else
		frmDC.Initial(Handle)
		memDC.Initial(0, ClientWidth*xdpi, ClientHeight*ydpi)
		frmGraphic.Initial(memDC.DC, True)
		frmGraphic.DrawImage(mGoldFish.Animate(sInc))
		BitBlt(frmDC.DC, 0, 0, ClientWidth*xdpi, ClientHeight*ydpi, memDC.DC, 0, 0, SRCCOPY)
	End If
End Sub

Private Sub frmGoldFishType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	PaintFish(0)
End Sub

Private Sub frmGoldFishType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	PaintFish(1)
End Sub

Private Sub frmGoldFishType.MenuItem_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuAnimate"
		Sender.Checked = Not Sender.Checked
		TimerComponent1.Enabled = Sender.Checked
	Case "mnuTransparent"
		Sender.Checked = Not Sender.Checked
		frmTrans.Enabled = Sender.Checked
	Case "mnuExit"
		CloseForm
	Case Else
		mGoldFish.mRotate = CInt(Sender.Caption)
	End Select
	PaintFish(0)
End Sub

Private Sub frmGoldFishType.Form_Create(ByRef Sender As Control)
	mGoldFish.Initial(FullName2Path(App.FileName) & "\GoldFish.png", 84, 84)
	'mGoldFish.Initial(FullName2Path(App.FileName) & "\Run.png", 300, 372)
	'mGoldFish.Initial(FullName2Path(App.FileName) & "\Fight.png", 199, 302)
	'mGoldFish.Initial(FullName2Path(App.FileName) & "\Jump.png", 147, 224)
	'mGoldFish.Initial(FullName2Path(App.FileName) & "\Walk.png", 218, 325)
	MenuItem_Click(mnuTransparent)
End Sub

Private Sub frmGoldFishType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	PaintFish(0)
End Sub

Private Sub frmGoldFishType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton = 0 Then
		ReleaseCapture()
		SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	End If
End Sub
