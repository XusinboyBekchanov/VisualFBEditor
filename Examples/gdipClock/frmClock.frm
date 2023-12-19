'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "gdipClock.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Menus.bi"
	#include once "mff/Dialogs.bi"
	
	#include once "gdip.bi"
	#include once "gdipAnalogClock.bi"
	#include once "gdipTextClock.bi"
	
	Using My.Sys.Forms
	
	Type frmClockType Extends Form
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
		
		'draw analog coloc
		Dim mAnalogClock As AnalogClock
		
		'draw text coloc
		Dim mTextClock As TextClock
		
		Dim mAlpha As UINT = &HC8
		Dim mOpacity As UINT = &H80
		
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub mnuMenu_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		Dim As TimerComponent TimerComponent1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuAnalog, mnuAnalogSetting, mnuBackgroundAnalog, mnuDrawTray, mnuDrawScale, MenuItem1, mnuText, mnuTextSetting, mnuShadow, mnuBlack, mnuRed, mnuGreen, mnuGradient, mnuShowSecond, mnuBlinkColon, MenuItem10, mnuAnalogText, mnuHand, mnuWhite, mnuBlue, MenuItem2, mnuBackgroundText, MenuItem3, MenuItem4, mnuExit, MenuItem6, mnuTransparent, mnuOpacity, mnuAspectRatio, mnuBroder, MenuItem9, mnuAbout, MenuItem7
		Dim As OpenFileDialog OpenFileDialog1
	End Type
	
	Constructor frmClockType
		' frmClock
		With This
			.Name = "frmClock"
			.Text = "GDIP Clock Demo"
			.Designer = @This
			.Caption = "GDIP Clock Demo"
			.ContextMenu = @PopupMenu1
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.SetBounds 0, 0, 240, 200
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 200
			.Enabled = True
			.SetBounds 70, 30, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 40, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuAnalog
		With mnuAnalog
			.Name = "mnuAnalog"
			.Designer = @This
			.Caption = "Analog"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuAnalogSetting
		With mnuAnalogSetting
			.Name = "mnuAnalogSetting"
			.Designer = @This
			.Caption = "Setting"
			.Parent = @PopupMenu1
		End With
		' mnuBackgroundAnalog
		With mnuBackgroundAnalog
			.Name = "mnuBackgroundAnalog"
			.Designer = @This
			.Caption = "Background..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAspectRatio
		With mnuAspectRatio
			.Name = "mnuAspectRatio"
			.Designer = @This
			.Caption = "Aspect ratio"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Checked = True
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuAnalogSetting
		End With
		' mnuDrawTray
		With mnuDrawTray
			.Name = "mnuDrawTray"
			.Designer = @This
			.Caption = "Draw tray"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuDrawScale
		With mnuDrawScale
			.Name = "mnuDrawScale"
			.Designer = @This
			.Caption = "Draw scale"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuText
		With mnuText
			.Name = "mnuText"
			.Designer = @This
			.Caption = "Text"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuTextSetting
		With mnuTextSetting
			.Name = "mnuTextSetting"
			.Designer = @This
			.Caption = "Setting"
			.Enabled = False
			.Parent = @PopupMenu1
		End With
		' mnuBackgroundText
		With mnuBackgroundText
			.Name = "mnuBackgroundText"
			.Designer = @This
			.Caption = "Background..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuShowSecond
		With mnuShowSecond
			.Name = "mnuShowSecond"
			.Designer = @This
			.Caption = "Show Second"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuBlinkColon
		With mnuBlinkColon
			.Name = "mnuBlinkColon"
			.Designer = @This
			.Caption = "Blink colon"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem9
		With MenuItem9
			.Name = "MenuItem9"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuBroder
		With mnuBroder
			.Name = "mnuBroder"
			.Designer = @This
			.Caption = "Broder"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuShadow
		With mnuShadow
			.Name = "mnuShadow"
			.Designer = @This
			.Caption = "Shadow"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' MenuItem10
		With MenuItem10
			.Name = "MenuItem10"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuTextSetting
		End With
		' mnuBlack
		With mnuBlack
			.Name = "mnuBlack"
			.Designer = @This
			.Caption = "Black"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuWhite
		With mnuWhite
			.Name = "mnuWhite"
			.Designer = @This
			.Caption = "White"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuRed
		With mnuRed
			.Name = "mnuRed"
			.Designer = @This
			.Caption = "Red"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuGreen
		With mnuGreen
			.Name = "mnuGreen"
			.Designer = @This
			.Caption = "Green"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuBlue
		With mnuBlue
			.Name = "mnuBlue"
			.Designer = @This
			.Caption = "Blue"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuGradient
		With mnuGradient
			.Name = "mnuGradient"
			.Designer = @This
			.Caption = "Gradient"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuTextSetting
		End With
		' mnuHand
		With mnuHand
			.Name = "mnuHand"
			.Designer = @This
			.Caption = "Hand"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' mnuAnalogText
		With mnuAnalogText
			.Name = "mnuAnalogText"
			.Designer = @This
			.Caption = "Text"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @mnuAnalogSetting
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuTransparent
		With mnuTransparent
			.Name = "mnuTransparent"
			.Designer = @This
			.Caption = "Transparent"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' mnuOpacity
		With mnuOpacity
			.Name = "mnuOpacity"
			.Designer = @This
			.Caption = "Opacity"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem7
		With MenuItem7
			.Name = "MenuItem7"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuAbout
		With mnuAbout
			.Name = "mnuAbout"
			.Designer = @This
			.Caption = "About"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem6
		With MenuItem6
			.Name = "MenuItem6"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' mnuExit
		With mnuExit
			.Name = "mnuExit"
			.Designer = @This
			.Caption = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuMenu_Click)
			.Parent = @PopupMenu1
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.SetBounds 10, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmClock As frmClockType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmClock.MainForm = True
		frmClock.Show
		App.Run
	#endif
'#End Region

Private Sub frmClockType.mnuMenu_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuAnalog"
		Sender.Checked = True
		mnuText.Checked = False
		Form_Resize(This, Width, Height)
	Case "mnuText"
		Sender.Checked = True
		mnuAnalog.Checked = False
		Form_Resize(This, Width, Height)
	Case "mnuTransparent"
		Sender.Checked = Not Sender.Checked
		If Sender.Checked Then
			If frmTrans.Enabled = Sender.Checked Then frmTrans.Enabled = Not Sender.Checked
		End If
		'GDI透明
		frmTrans.Enabled = Sender.Checked
		Form_Resize(This, Width, Height)
		If Sender.Checked Then Exit Sub
		'窗口透明
		If frmTrans.Enabled = False Then frmTrans.Enabled = True 
		Opacity = IIf(mnuOpacity.Checked, mOpacity, &HFF)
	Case "mnuOpacity"
		Sender.Checked = Not Sender.Checked
		If mnuTransparent.Checked Then
		Else
			'窗口透明
			If frmTrans.Enabled = False Then frmTrans.Enabled = True 
			Opacity = IIf(mnuOpacity.Checked, mOpacity, &HFF)
		End If
	Case "mnuBackgroundAnalog"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			OpenFileDialog1.FileName = mAnalogClock.FileName
			If OpenFileDialog1.Execute Then
				mAnalogClock.FileName= OpenFileDialog1.FileName
				Sender.Checked = True
			End If
		End If
		mAnalogClock.mBackground = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuAspectRatio"
		Sender.Checked = Not Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuHand"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mHand = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuDrawTray"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mTray = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuDrawScale"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mScale = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuAnalogText"
		Sender.Checked = Not Sender.Checked
		mAnalogClock.mText = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuBackgroundText"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			OpenFileDialog1.FileName = mTextClock.FileName
			If OpenFileDialog1.Execute Then
				mTextClock.FileName= OpenFileDialog1.FileName
				Sender.Checked = True
			End If
		End If
		mTextClock.mBackground = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuShowSecond"
		Sender.Checked = Not Sender.Checked
		mTextClock.mShowSecond = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuBlinkColon"
		Sender.Checked = Not Sender.Checked
		mTextClock.mBlinkColon = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuBroder"
		Sender.Checked = Not Sender.Checked
		mTextClock.mShowBorder = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuShadow"
		Sender.Checked = Not Sender.Checked
		mTextClock.mShowShadow = Sender.Checked
		Form_Resize(This, Width, Height)
	Case "mnuBlack"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFF000000, &HFF000000)
		Sender.Checked = True
	Case "mnuWhite"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFFFFFFFF, &HFFFFFFFF)
		Sender.Checked = True
	Case "mnuRed"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFFFF0000, &HFFFF0000)
		Sender.Checked = True
	Case "mnuGreen"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFF00FF00, &HFF00FF00)
		Sender.Checked = True
	Case "mnuBlue"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFF0000FF, &HFF0000FF)
		Sender.Checked = True
	Case "mnuGradient"
		mnuBlack.Checked = False
		mnuWhite.Checked = False
		mnuRed.Checked = False
		mnuGreen.Checked = False
		mnuBlue.Checked = False
		mnuGradient.Checked = False
		mTextClock.TextColor(&HFFFF00FF, &HFF00FF00)
		Sender.Checked = True
	Case "mnuAbout"
		MsgBox(!"Visual FB Editor\r\nGDIP Clock Demo\r\nBy Cm Wang", "GDIP Clock Demo")
	Case "mnuExit"
		CloseForm
	End Select
	
	mnuAnalogSetting.Enabled = mnuAnalog.Checked
	mnuTextSetting.Enabled = mnuText.Checked
	'Print "mnuMenu_Click"
End Sub

Private Sub frmClockType.Form_Create(ByRef Sender As Control)
	If mnuAnalog.Checked Then 
		mAnalogClock.ImageInit(ClientWidth, ClientHeight, mAlpha)
		frmTrans.Create(Handle, mAnalogClock.ImageUpdate(mAlpha))
	End If
	If mnuText.Checked Then 
		mTextClock.ImageInit(ClientWidth, ClientHeight, mAlpha)
		frmTrans.Create(Handle, mTextClock.ImageUpdate(mAlpha))
	End If
	'Print "Form_Create"
End Sub

Private Sub frmClockType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If mnuTransparent.Checked Then
		If mnuAnalog.Checked Then
			If mnuAspectRatio.Checked Then
				'保持宽高比例
				If mnuBackgroundAnalog.Checked Then
					Height = mAnalogClock.mBGScale * Width
				Else
					Height = Width
				End If
			End If
			mAnalogClock.ImageInit(Width, Height, mAlpha)
		End If
		If mnuText.Checked Then mTextClock.ImageInit(Width, Height, mAlpha)
	Else
		If mnuAnalog.Checked Then
			If mnuAspectRatio.Checked Then
				'保持宽高比例
				Dim h As Single = Height - ClientHeight
				If mnuBackgroundAnalog.Checked Then
					Height = h + mAnalogClock.mBGScale * ClientWidth
				Else
					Height = h + ClientWidth
				End If
			End If
			mAnalogClock.ImageInit(ClientWidth, ClientHeight, mAlpha)
		End If
		If mnuText.Checked Then mTextClock.ImageInit(ClientWidth, ClientHeight, mAlpha)
	End If
	TimerComponent1_Timer(TimerComponent1)
	'Print "Form_Resize", Width, Height
End Sub

Private Sub frmClockType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	If mnuTransparent.Checked Then
		If mnuAnalog.Checked Then frmTrans.Create(Handle, mAnalogClock.ImageUpdate(mAlpha))
		If mnuText.Checked Then frmTrans.Create(Handle, mTextClock.ImageUpdate(mAlpha))
		frmTrans.Transform(IIf(mnuOpacity.Checked, mOpacity, &HFF))
	Else
		frmDC.Initial(Handle)
		memDC.Initial(0, ClientWidth, ClientHeight)
		frmGraphic.Initial(memDC.DC, True)
		If mnuAnalog.Checked Then frmGraphic.DrawImage(mAnalogClock.ImageUpdate(mAlpha))
		If mnuText.Checked Then frmGraphic.DrawImage(mTextClock.ImageUpdate(mAlpha))
		BitBlt(frmDC.DC, 0, 0, ClientWidth, ClientHeight, memDC.DC, 0, 0, SRCCOPY)
	End If
	'Print "TimerComponent1_Timer"
End Sub

Private Sub frmClockType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 0 Then Exit Sub
	ReleaseCapture()
	SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
End Sub

