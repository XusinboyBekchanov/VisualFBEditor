' MDIScintilla frmFindReplace.frm
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDIScintilla.rc"
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
		Declare Constructor
		
		Dim As TextBox txtFind, txtReplace
		Dim As CommandButton cmdFindNext, cmdFindBack, cmdShowHide, cmdReplace, cmdReplaceAll
		Dim As CheckBox chkCase, chkWarp, chkRegExp
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
			.SetBounds 0, 0, 396, 220
		End With
		' lblStatus
		With lblStatus
			.Name = "lblStatus"
			.Text = ""
			.TabIndex = 0
			.Caption = ""
			.SetBounds 10, 10, 370, 20
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
			.HideSelection = True
			.SetBounds 10, 30, 270, 60
			.Designer = @This
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
			.SetBounds 100, 90, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @chk_Click)
			.Parent = @This
		End With
		' chkRegExp
		With chkRegExp
			.Name = "chkRegExp"
			.Text = "Regular Exp."
			.TabIndex = 3
			.Caption = "Regular Exp."
			.Checked = True
			.SetBounds 190, 90, 90, 20
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
			.HideSelection = True
			.SetBounds 10, 120, 270, 60
			.Designer = @This
			.Parent = @This
		End With
		' cmdFindNext
		With cmdFindNext
			.Name = "cmdFindNext"
			.Text = "Find Next"
			.TabIndex = 5
			.Caption = "Find Next"
			.SetBounds 290, 30, 90, 20
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
			.SetBounds 290, 50, 90, 20
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
			.SetBounds 290, 90, 90, 20
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
			.SetBounds 290, 140, 90, 20
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
			.SetBounds 290, 160, 90, 20
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
		MDIMain.Find(txtFind.Text, chkRegExp.Checked, chkCase.Checked, chkWarp.Checked, False, True)
	Case "cmdFindBack"
		MDIMain.Find(txtFind.Text, chkRegExp.Checked, chkCase.Checked, chkWarp.Checked, True, True)
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
		MDIMain.Replace(txtFind.Text, txtReplace.Text, chkRegExp.Checked, chkCase.Checked, chkWarp.Checked)
	Case "cmdReplaceAll"
		Dim i As Integer = MDIMain.ReplaceAll(txtFind.Text, txtReplace.Text, chkRegExp.Checked, chkCase.Checked)
		If i >-1 Then MDIMain.Find(txtFind.Text, chkRegExp.Checked, chkCase.Checked, chkWarp.Checked, False, True)
		lblStatus.Text = "Replace count: " & i + 1
		Exit Sub
	End Select
	
	Dim a As MDIChildType Ptr = MDIMain.ActMdiChild
	If a = NULL Then Exit Sub
	If a->Editor.FindCount < 0 Then
		lblStatus.Text = "Nothing found."
	Else
		lblStatus.Text = "Found " & a->Editor.FindIndex + 1 & " of " & a->Editor.FindCount + 1
	End If
End Sub

Private Sub frmFindReplaceType.chk_Click(ByRef Sender As CheckBox)
	Select Case Sender.Name
	Case "chkCase"
		MDIMain.fMatchCase = Sender.Checked
	Case "chkWarp"
		MDIMain.fFindWarp = Sender.Checked
	Case "chkRegExp"
		MDIMain.fRegExp = Sender.Checked
	End Select
End Sub

Private Sub frmFindReplaceType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If txtReplace.Visible= True Then
		Height = txtReplace.Top + txtReplace.Height + lblStatus.Top + Height - ClientHeight
	Else
		Height = txtReplace.Top + Height - ClientHeight
	End If
End Sub
