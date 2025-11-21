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
	
	#include once "mfplay.bi"
	
	Using My.Sys.Forms
	
	Type frmMFPMediaPlayerType Extends Form
		g_pPlayer As IMFPMediaPlayer Ptr
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Constructor
		
		Dim As Panel Panel1, Panel2
		Dim As TextBox TextBox1
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4
	End Type
	
	Constructor frmMFPMediaPlayerType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmMFPMediaPlayer
		With This
			.Name = "frmMFPMediaPlayer"
			.Text = "MFPMediaPlayer"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.Caption = "MFPMediaPlayer"
			.AllowDropFiles = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.SetBounds 0, 0, 350, 300
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 334, 50
			.Designer = @This
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alClient
			.SetBounds 0, 60, 334, 201
			.Designer = @This
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "F:\OfficePC_Update\!Media\632734Y0314.mp4"
			.TabIndex = 2
			.SetBounds 10, 0, 310, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Open"
			.TabIndex = 3
			.Caption = "Open"
			.SetBounds 10, 30, 60, 20
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
			.SetBounds 80, 30, 60, 20
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
			.SetBounds 150, 30, 60, 20
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
			.SetBounds 220, 30, 60, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared frmMFPMediaPlayer As frmMFPMediaPlayerType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmMFPMediaPlayer.MainForm = True
		frmMFPMediaPlayer.Show
		App.Run
	#endif
'#End Region


Private Sub frmMFPMediaPlayerType.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)
End Sub

Private Sub frmMFPMediaPlayerType.Form_Destroy(ByRef Sender As Control)
	If g_pPlayer Then
		g_pPlayer->lpVtbl->Shutdown(g_pPlayer)
		g_pPlayer->lpVtbl->Release(g_pPlayer)
		g_pPlayer = NULL
	End If
	CoUninitialize()
End Sub

Private Sub frmMFPMediaPlayerType.CommandButton1_Click(ByRef Sender As Control)
	Select Case Sender.Text
	Case "Open"
		
		If g_pPlayer Then
			g_pPlayer->lpVtbl->Shutdown(g_pPlayer)
			g_pPlayer->lpVtbl->Release(g_pPlayer)
			g_pPlayer = NULL
		End If
		
		MFPCreateMediaPlayer( _
		TextBox1.Text, _          ' 文件路径
		True, _           ' 不自动播放
		0, _               ' 播放选项
		NULL, _            ' 回调
		Panel2.Handle, _            ' 渲染窗口
		g_pPlayer _         ' 输出
		)
	Case "Play"
		If g_pPlayer Then g_pPlayer->lpVtbl->Play(g_pPlayer)
	Case "Pause"
		If g_pPlayer Then g_pPlayer->lpVtbl->Pause(g_pPlayer)
	Case "Stop"
		If g_pPlayer Then g_pPlayer->lpVtbl->Stop(g_pPlayer)
	End Select
End Sub

Private Sub frmMFPMediaPlayerType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	TextBox1.Text = Filename
End Sub