'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Label.bi"
	
	Using My.Sys.Forms
	
	Type frmFindReplaceType Extends Form
		Declare Static Sub _cmdFindReplace_Click(ByRef Sender As Control)
		Declare Sub cmdFindReplace_Click(ByRef Sender As Control)
		Declare Static Sub _chkFindReplace_Click(ByRef Sender As CheckBox)
		Declare Sub chkFindReplace_Click(ByRef Sender As CheckBox)
		Declare Constructor
		
		Dim As TextBox txtFind, txtReplace
		Dim As CommandButton cmdFindNext, cmdFindBack, cmdShowHide, cmdReplace, cmdReplaceAll
		Dim As CheckBox chkCase, chkWarp
		Dim As Label lblMsg
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
			.SetBounds 0, 0, 386, 220
		End With
		' lblMsg
		With lblMsg
			.Name = "lblMsg"
			.Text = ""
			.TabIndex = 0
			.Caption = ""
			.SetBounds 10, 10, 360, 20
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
			.SetBounds 10, 30, 260, 60
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
			.OnClick = @_chkFindReplace_Click
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
			.OnClick = @_chkFindReplace_Click
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
			.SetBounds 280, 30, 90, 20
			.Designer = @This
			.OnClick = @_cmdFindReplace_Click
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
			.OnClick = @_cmdFindReplace_Click
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
			.OnClick = @_cmdFindReplace_Click
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
			.OnClick = @_cmdFindReplace_Click
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
			.OnClick = @_cmdFindReplace_Click
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmFindReplaceType._chkFindReplace_Click(ByRef Sender As CheckBox)
		(*Cast(frmFindReplaceType Ptr, Sender.Designer)).chkFindReplace_Click(Sender)
	End Sub
	
	Private Sub frmFindReplaceType._cmdFindReplace_Click(ByRef Sender As Control)
		(*Cast(frmFindReplaceType Ptr, Sender.Designer)).cmdFindReplace_Click(Sender)
	End Sub
	
	Dim Shared frmFindReplace As frmFindReplaceType
	
	#if _MAIN_FILE_ = __FILE__
		frmFindReplace.MainForm = True
		frmFindReplace.Show
		App.Run
	#endif
'#End Region

Private Sub frmFindReplaceType.cmdFindReplace_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdFindNext"
		MDIMain.fFindBack = False
		MDIMain.Find(txtFind.Text, chkCase.Checked, chkWarp.Checked, False)
	Case "cmdFindBack"
		MDIMain.fFindBack = True
		MDIMain.Find(txtFind.Text, chkCase.Checked, chkWarp.Checked, True)
	Case "cmdShowHide"
		If txtReplace.Visible= True Then
			Sender.Text = "Show Replace"
			Height = 150
			txtReplace.Visible= False
			cmdReplace.Visible= False
			cmdReplaceAll.Visible= False
		Else
			Sender.Text = "Hide Replace"
			Height = 220
			txtReplace.Visible= True
			cmdReplace.Visible= True
			cmdReplaceAll.Visible= True
		End If
	Case "cmdReplace"
		MDIMain.Replace(txtFind.Text, txtReplace.Text, chkCase.Checked, chkWarp.Checked)
	Case "cmdReplaceAll"
		Dim i As Integer = MDIMain.ReplaceAll(txtFind.Text, txtReplace.Text, chkCase.Checked)
		If i >-1 Then MDIMain.Find(txtFind.Text, chkCase.Checked, chkWarp.Checked, False, True)
		lblMsg.Text = "Replace count: " & i + 1
		Exit Sub
	End Select
	
	Dim a As MDIChildType Ptr = MDIMain.ActMdiChild
	If a = NULL Then Exit Sub
	If a->Sci.FindCount < 0 Then
		lblMsg.Text = "Nothing found."
	Else
		lblMsg.Text = "Found " & a->Sci.FindIndex + 1 & " of " & a->Sci.FindCount + 1
	End If
End Sub

Private Sub frmFindReplaceType.chkFindReplace_Click(ByRef Sender As CheckBox)
	Select Case Sender.Name
	Case "chkCase"
		MDIMain.fMatchCase= chkCase.Checked 
	Case "chkWarp"
		MDIMain.fFindWarp = chkWarp.Checked 
	End Select
End Sub

