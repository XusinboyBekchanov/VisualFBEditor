' MDINotepad frmFindReplace.frm
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDINotepad.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Label.bi"
	
	Using My.Sys.Forms
	
	Type frmFindReplaceType Extends Form
		Declare Sub cmd_Click(ByRef Sender As Control)
		Declare Sub chk_Click(ByRef Sender As CheckBox)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub txtFind_Change(ByRef Sender As TextBox)
		Declare Constructor
		
		Dim As TextBox txtFind, txtReplace
		Dim As CommandButton cmdFindNext, cmdFindBack, cmdShowHide, cmdReplace, cmdReplaceAll
		Dim As CheckBox chkCase, chkWarp
		Dim As Label lblStatus
	End Type
	
	Constructor frmFindReplaceType
		' frmFindReplace
		With This
			.Name = "frmFindReplace"
			.Text = "Find and Replace"
			.Designer = @This
			.Caption = "Find and Replace"
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.StartPosition = FormStartPosition.CenterParent
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.SetBounds 0, 0, 386, 220
		End With
		' lblStatus
		With lblStatus
			.Name = "lblStatus"
			.Text = ""
			.TabIndex = 0
			.Caption = ""
			.SetBounds 10, 10, 360, 16
			.Designer = @This
			.Parent = @This
		End With
		' txtFind
		With txtFind
			.Name = "txtFind"
			.Text = ""
			.TabIndex = 1
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.MaxLength = -1
			.SetBounds 10, 30, 260, 60
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox), @txtFind_Change)
			.Parent = @This
		End With
		' chkCase
		With chkCase
			.Name = "chkCase"
			.Text = "Case sensitive"
			.TabIndex = 2
			.Caption = "Case sensitive"
			.SetBounds 10, 90, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @chk_Click)
			.Parent = @This
		End With
		' chkWarp
		With chkWarp
			.Name = "chkWarp"
			.Text = "Wrap around"
			.TabIndex = 3
			.Caption = "Wrap around"
			.Checked = True
			.SetBounds 110, 90, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @chk_Click)
			.Parent = @This
		End With
		' txtReplace
		With txtReplace
			.Name = "txtReplace"
			.Text = ""
			.TabIndex = 4
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.MaxLength = -1
			.SetBounds 10, 120, 260, 60
			.Designer = @This
			.Parent = @This
		End With
		' cmdFindNext
		With cmdFindNext
			.Name = "cmdFindNext"
			.Text = "Find Next"
			.TabIndex = 5
			.Caption = "Find Next"
			.Default = True
			.SetBounds 280, 30, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmd_Click)
			.Parent = @This
		End With
		' cmdFindBack
		With cmdFindBack
			.Name = "cmdFindBack"
			.Text = "Find Back"
			.TabIndex = 6
			.Caption = "Find Back"
			.SetBounds 280, 50, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmd_Click)
			.Parent = @This
		End With
		' cmdShowHide
		With cmdShowHide
			.Name = "cmdShowHide"
			.Text = "Hide Replace"
			.TabIndex = 7
			.Caption = "Hide Replace"
			.SetBounds 280, 90, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmd_Click)
			.Parent = @This
		End With
		' cmdReplace
		With cmdReplace
			.Name = "cmdReplace"
			.Text = "Replace"
			.TabIndex = 8
			.Caption = "Replace"
			.SetBounds 280, 140, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmd_Click)
			.Parent = @This
		End With
		' cmdReplaceAll
		With cmdReplaceAll
			.Name = "cmdReplaceAll"
			.Text = "Replace All"
			.TabIndex = 9
			.Caption = "Replace All"
			.SetBounds 280, 160, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmd_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmFindReplace As frmFindReplaceType
	
	#if _MAIN_FILE_ = __FILE__
		frmFindReplace.MainForm = True
		frmFindReplace.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmFindReplaceType.cmd_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdFindNext"
		cmdFindNext.Default = True
		cmdFindBack.Default = False
		MDIMain.Find(txtFind.Text, chkCase.Checked, chkWarp.Checked, False)
	Case "cmdFindBack"
		cmdFindNext.Default = False
		cmdFindBack.Default = True
		MDIMain.Find(txtFind.Text, chkCase.Checked, chkWarp.Checked, True)
	Case "cmdShowHide"
		If txtReplace.Visible = True Then
			cmdShowHide.Text = "Show Replace"
			txtReplace.Visible = False
			cmdReplace.Visible = False
			cmdReplaceAll.Visible = False
		Else
			cmdShowHide.Text = "Hide Replace"
			txtReplace.Visible = True
			cmdReplace.Visible = True
			cmdReplaceAll.Visible = True
		End If
		Form_Resize(Me, 0, 0)
	Case "cmdReplace"
		MDIMain.Replace(txtFind.Text, txtReplace.Text, chkCase.Checked, chkWarp.Checked)
	Case "cmdReplaceAll"
		MDIMain.ReplaceAll(txtFind.Text, txtReplace.Text, chkCase.Checked)
	End Select
End Sub

Private Sub frmFindReplaceType.chk_Click(ByRef Sender As CheckBox)
	Select Case Sender.Name
	Case "chkCase"
		txtFind_Change(txtFind)
	Case "chkWarp"
	End Select
End Sub

Private Sub frmFindReplaceType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If txtReplace.Visible= True Then
		Height = txtReplace.Top + txtReplace.Height + lblStatus.Top + Height - ClientHeight
	Else
		Height = txtReplace.Top + Height - ClientHeight
	End If
End Sub

Private Sub frmFindReplaceType.Form_Show(ByRef Sender As Form)
	If MDIMain.mFindCount < 0 Or MDIMain.mFindIndex < 0 Then
		lblStatus.Text = "Find..."
	Else
		lblStatus.Text = "Find: " & Format(MDIMain.mFindIndex + 1, "#,#0") & " of " & Format(MDIMain.mFindCount, "#,#0")
	End If
End Sub

Private Sub frmFindReplaceType.txtFind_Change(ByRef Sender As TextBox)
	MDIMain.mFindLength = -1
	Form_Show(Me)
End Sub
