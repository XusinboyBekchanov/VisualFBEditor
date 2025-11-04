' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

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
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	
	#include once "PlayerGrab.bi"
	
	Using My.Sys.Forms
	
	Type frmPlayerGrabType Extends Form
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub Panel2_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2
		Dim As TextBox TextBox1
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4, CommandButton5
	End Type
	
	Constructor frmPlayerGrabType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmPlayerGrab
		With This
			.Name = "frmPlayerGrab"
			.Text = "Player Grab"
			.Designer = @This
			.Caption = "Player Grab"
			.StartPosition = FormStartPosition.CenterScreen
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.AllowDropFiles = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.SetBounds 0, 0, 360, 300
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 344, 60
			.Designer = @This
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alClient
			.SetBounds 0, 50, 344, 211
			.Designer = @This
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Panel2_Resize)
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "F:\OfficePC_Update\!Media\632734Y0314.mp4"
			.TabIndex = 2
			.SetBounds 0, 0, 340, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Open"
			.TabIndex = 3
			.Caption = "Open"
			.SetBounds 0, 30, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Play"
			.TabIndex = 4
			.Caption = "Play"
			.SetBounds 70, 30, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = "Pause"
			.TabIndex = 5
			.Caption = "Pause"
			.SetBounds 140, 30, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
		' CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = "Stop"
			.TabIndex = 6
			.Caption = "Stop"
			.SetBounds 210, 30, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
		' CommandButton5
		With CommandButton5
			.Name = "CommandButton5"
			.Text = "Capture"
			.TabIndex = 7
			.Caption = "Capture"
			.SetBounds 280, 30, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared frmPlayerGrab As frmPlayerGrabType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmPlayerGrab.MainForm = True
		frmPlayerGrab.Show
		App.Run
	#endif
'#End Region

Private Sub frmPlayerGrabType.CommandButton1_Click(ByRef Sender As Control)
	Select Case Sender.Text
	Case "Open"
		MediaOpen(Panel2.Handle, @TextBox1.Text)
	Case "Play"
		MediaRun()
	Case "Pause"
		MediaPause()
	Case "Stop"
		MediaStop()
	Case "Capture"
		MediaCap()
	End Select
End Sub

Private Sub frmPlayerGrabType.Panel2_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	MediaResize(Panel2.Handle)
End Sub

Private Sub frmPlayerGrabType.Form_Create(ByRef Sender As Control)
	hr = CoInitialize(NULL)
	If FAILED(hr) Then
		? "COM 初始化失败, hr = "; Hex(hr)
		' COM 初始化失败，退出
		' COM initialization failed, exit
		End -1
	End If
End Sub

Private Sub frmPlayerGrabType.Form_Destroy(ByRef Sender As Control)
	CoUninitialize()
End Sub

Private Sub frmPlayerGrabType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	TextBox1.Text = Filename
End Sub