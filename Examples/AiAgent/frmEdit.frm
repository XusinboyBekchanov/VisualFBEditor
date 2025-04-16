'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	
	Using My.Sys.Forms
	
	Type frmEditType Extends Form
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Constructor
		
		Dim As TextBox TextBox1
		Dim As CommandButton cmdCancel, cmdOk
	End Type
	
	Constructor frmEditType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmEdit
		With This
			.Name = "frmEdit"
			.Text = "Form1"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterParent
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.SetBounds 0, 0, 400, 300
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = "TextBox1"
			.TabIndex = 0
			.Multiline = True
			.ID = 1053
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 10
			.ExtraMargins.Bottom = 40
			.SetBounds 0, 0, 334, 261
			.Designer = @This
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = "Cancel"
			.TabIndex = 1
			.Caption = "Cancel"
			.Cancel = True
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 180, 230, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' cmdOk
		With cmdOk
			.Name = "cmdOk"
			.Text = "Ok"
			.TabIndex = 2
			.Caption = "Ok"
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 280, 230, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmEdit As frmEditType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmEdit.MainForm = True
		frmEdit.Show
		App.Run
	#endif
'#End Region

Private Sub frmEditType.CommandButton_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Select Case Sender.Name
	Case "cmdOk"
		ModalResult = ModalResults.OK
	End Select
	Hide
End Sub

Private Sub frmEditType.Form_Show(ByRef Sender As Form)
	Tag = NULL
End Sub
