'frmAnimate金鱼
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmAnimate.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Menus.bi"
	#include once "mff/HotKey.bi"
	
	#include once "../MDINotepad/Text.bi"
	#include once "../gdipClock/gdip.bi"
	#include once "../gdipClock/gdipAnimate.bi"
	
	Using My.Sys.Forms
	
	Type frmAnimateType Extends Form
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
		'animate
		mAnimate As gdipAnimate
		mPlay As Boolean = True
		
		Declare Sub PaintFish(ByVal sInc As Integer = 1)
		Declare Sub OpenFile(ByRef sFileName As WString, ByVal sFrameWidth As Integer = 0, ByVal sFrameHeight As Integer = 0, ByVal sFrameCount As Integer = -1)
		
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub MenuItem_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuTransparent, MenuItem1, mnuExit, MenuItem2, mnuRotate0, mnuRotate1, mnuRotate2, mnuRotate3, mnuRotate4, mnuRotate5, mnuRotate6, mnuRotate7, mnuAnimate, mnuNext, mnuBack, MenuItem3, mnuRotate, mnuImage, mnuImage1, mnuImage2, mnuImage3, mnuImage4, mnuImage5, mnuImage6, mnuImage7, mnuImage8, mnuImage9, mnuImage10, mnuImage11, mnuImage12
	End Type
	
	Constructor frmAnimateType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = "english"
			End With
		#endif
		' frmAnimate
		With This
			.Name = "frmAnimate"
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
			.Menu = 0
			.AllowDrop = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.SetBounds 0, 0, 350, 300
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 50
			.Enabled = True
			.SetBounds 0, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 20, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuAnimate
		With mnuAnimate
			.Name = "mnuAnimate"
			.Designer = @This
			.Caption = !"Animate\tCtrl+A"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = !"Transparent\tCtrl+T"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Checked = True
			.Parent = @PopupMenu1
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuBack
		With mnuBack
			.Name = "mnuBack"
			.Designer = @This
			.Caption = !"Back frame\tCtrl+B"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' mnuNext
		With mnuNext
			.Name = "mnuNext"
			.Designer = @This
			.Caption = !"Next frame\tCtrl+N"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuImage
		With mnuImage
			.Name = "mnuImage"
			.Designer = @This
			.Caption = "Image"
			.Parent = @PopupMenu1
		End With
		' mnuImage1
		With mnuImage1
			.Name = "mnuImage1"
			.Designer = @This
			.Caption = "Fight.png"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage2
		With mnuImage2
			.Name = "mnuImage2"
			.Designer = @This
			.Caption = "GoldFish.png"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage3
		With mnuImage3
			.Name = "mnuImage3"
			.Designer = @This
			.Caption = "Walk.png"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage4
		With mnuImage4
			.Name = "mnuImage4"
			.Designer = @This
			.Caption = "Fairy.png"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage5
		With mnuImage5
			.Name = "mnuImage5"
			.Designer = @This
			.Caption = "Run.png"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage6
		With mnuImage6
			.Name = "mnuImage6"
			.Designer = @This
			.Caption = "Heart.gif"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage7
		With mnuImage7
			.Name = "mnuImage7"
			.Designer = @This
			.Caption = "Fly.gif"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage8
		With mnuImage8
			.Name = "mnuImage8"
			.Designer = @This
			.Caption = "Mario.gif"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage9
		With mnuImage9
			.Name = "mnuImage9"
			.Designer = @This
			.Caption = "Panda1.gif"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage10
		With mnuImage10
			.Name = "mnuImage10"
			.Designer = @This
			.Caption = "Panda2.gif"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage11
		With mnuImage11
			.Name = "mnuImage11"
			.Designer = @This
			.Caption = "Panda3.gif"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuImage12
		With mnuImage12
			.Name = "mnuImage12"
			.Designer = @This
			.Caption = "Panda4.gif"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Parent = @mnuImage
		End With
		' mnuRotate
		With mnuRotate
			.Name = "mnuRotate"
			.Designer = @This
			.Caption = "Rotate"
			.Parent = @PopupMenu1
		End With
		' mnuRotate0
		With mnuRotate0
			.Name = "mnuRotate0"
			.Designer = @This
			.Caption = !"RotateNone FlipNone\tCtrl+0"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"0"
			.Parent = @mnuRotate
		End With
		' mnuRotate1
		With mnuRotate1
			.Name = "mnuRotate1"
			.Designer = @This
			.Caption = !"Rotate90 FlipNone\tCtrl+1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"1"
			.Parent = @mnuRotate
		End With
		' mnuRotate2
		With mnuRotate2
			.Name = "mnuRotate2"
			.Designer = @This
			.Caption = !"Rotate180 FlipNone\tCtrl+2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"2"
			.Parent = @mnuRotate
		End With
		' mnuRotate3
		With mnuRotate3
			.Name = "mnuRotate3"
			.Designer = @This
			.Caption = !"Rotate270 FlipNone\tCtrl+3"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"3"
			.Parent = @mnuRotate
		End With
		' mnuRotate4
		With mnuRotate4
			.Name = "mnuRotate4"
			.Designer = @This
			.Caption = !"RotateNone FlipX\tCtrl+4"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"4"
			.Parent = @mnuRotate
		End With
		' mnuRotate5
		With mnuRotate5
			.Name = "mnuRotate5"
			.Designer = @This
			.Caption = !"Rotate90 FlipX\tCtrl+5"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"5"
			.Parent = @mnuRotate
		End With
		' mnuRotate6
		With mnuRotate6
			.Name = "mnuRotate6"
			.Designer = @This
			.Caption = !"Rotate180 FlipX\tCtrl+6"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"6"
			.Parent = @mnuRotate
		End With
		' mnuRotate7
		With mnuRotate7
			.Name = "mnuRotate7"
			.Designer = @This
			.Caption = !"Rotate270 FlipX\tCtrl+7"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuItem_Click)
			.Tag = @"7"
			.Parent = @mnuRotate
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
	
	Dim Shared frmAnimate As frmAnimateType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmAnimate.MainForm = True
		frmAnimate.Show
		App.Run
	#endif
'#End Region

Private Sub frmAnimateType.PaintFish(ByVal sInc As Integer = 1)
	If mnuTransparent.Checked Then
		frmTrans.Create(Handle, mAnimate.ImageFrame(sInc))
		frmTrans.Transform(&Hff)
	Else
		frmDC.Initial(Handle)
		memDC.Initial(0, ClientWidth*xdpi, ClientHeight*ydpi)
		frmGraphic.Initial(memDC.DC, True)
		frmGraphic.DrawImage(mAnimate.ImageFrame(sInc))
		BitBlt(frmDC.DC, 0, 0, ClientWidth*xdpi, ClientHeight*ydpi, memDC.DC, 0, 0, SRCCOPY)
	End If
End Sub

Private Sub frmAnimateType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	PaintFish(0)
End Sub

Private Sub frmAnimateType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	TimerComponent1.Enabled = False
	PaintFish(1)
	If mAnimate.mIsGif Then TimerComponent1.Interval = mAnimate.mFrameDelays(mAnimate.mFrameIndex)
	TimerComponent1.Enabled = mPlay
End Sub

Private Sub frmAnimateType.MenuItem_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuNext"
		PaintFish(1)
	Case "mnuBack"
		PaintFish(-1)
	Case "mnuAnimate"
		Sender.Checked = Not Sender.Checked
		mPlay = Sender.Checked
		TimerComponent1.Enabled = mPlay
	Case "mnuTransparent"
		Sender.Checked = Not Sender.Checked
		frmTrans.Enabled = Sender.Checked
	Case "mnuExit"
		CloseForm
	Case Else
		If InStr(Sender.Name, "mnuImage") Then
			Select Case Sender.Name
			Case "mnuImage1"
				OpenFile(FullName2Path(App.FileName) & "\" & Sender.Caption, 199, 302, 10)
			Case "mnuImage2"
				OpenFile(FullName2Path(App.FileName) & "\" & Sender.Caption, 84, 84)
			Case "mnuImage3"
				OpenFile(FullName2Path(App.FileName) & "\" & Sender.Caption, 184, 325)
			Case "mnuImage4"
				OpenFile(FullName2Path(App.FileName) & "\" & Sender.Caption, 192, 192, 14)
			Case "mnuImage5"
				OpenFile(FullName2Path(App.FileName) & "\" & Sender.Caption, 123, 105)
			Case Else
				OpenFile(FullName2Path(App.FileName) & "\" & Sender.Caption)
			End Select
			Sender.Checked = True
		End If
		If InStr(Sender.Name, "mnuRotate") Then
			mnuRotate0.Checked = False
			mnuRotate1.Checked = False
			mnuRotate2.Checked = False
			mnuRotate3.Checked = False
			mnuRotate4.Checked = False
			mnuRotate5.Checked = False
			mnuRotate6.Checked = False
			mnuRotate7.Checked = False
			Sender.Checked = True
			mAnimate.mRotate = CInt(*Cast(WString Ptr, Sender.Tag))
		End If
	End Select
	PaintFish(0)
End Sub

Private Sub frmAnimateType.Form_Create(ByRef Sender As Control)
	MenuItem_Click(mnuImage2)
	MenuItem_Click(mnuRotate4)
	MenuItem_Click(mnuTransparent)
End Sub

Private Sub frmAnimateType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	PaintFish(0)
End Sub

Private Sub frmAnimateType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton = 0 Then
		ReleaseCapture()
		SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	End If
End Sub

Private Sub frmAnimateType.OpenFile(ByRef sFileName As WString, ByVal sFrameWidth As Integer = 0, ByVal sFrameHeight As Integer = 0, ByVal sFrameCount As Integer = -1)
	TimerComponent1.Enabled = False
	mnuImage1.Checked = False
	mnuImage2.Checked = False
	mnuImage3.Checked = False
	mnuImage4.Checked = False
	mnuImage5.Checked = False
	mnuImage6.Checked = False
	mnuImage7.Checked = False
	mnuImage8.Checked = False
	mnuImage9.Checked = False
	mnuImage10.Checked = False
	mnuImage11.Checked = False
	mnuImage12.Checked = False
	
	mAnimate.ImageFile(sFileName, sFrameWidth, sFrameHeight, sFrameCount)
	
	If mAnimate.mIsGif Then
		TimerComponent1.Interval = mAnimate.mFrameDelays(mAnimate.mFrameIndex)
	Else
		TimerComponent1.Interval = 50
	End If
	TimerComponent1.Enabled = mPlay
End Sub

Private Sub frmAnimateType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	OpenFile(Filename)
End Sub
