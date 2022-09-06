'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__ __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/CheckBox.bi"
	
	Using My.Sys.Forms
	
	Type frmFindReplaceType Extends Form
		Declare Static Sub _btnFindReplace_Click(ByRef Sender As Control)
		Declare Sub btnFindReplace_Click(ByRef Sender As Control)
		Declare Static Sub _chkFindReplace_Click(ByRef Sender As CheckBox)
		Declare Sub chkFindReplace_Click(ByRef Sender As CheckBox)
		Declare Constructor
		
		Dim As TextBox txtFind, txtReplace
		Dim As CommandButton btnFindNext, btnFindBack, btnShowHide, btnReplace, btnReplaceAll
		Dim As CheckBox chkCase, chkWarp
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
			.SetBounds 0, 0, 386, 200
		End With
		' txtFind
		With txtFind
			.Name = "txtFind"
			.Text = ""
			.TabIndex = 0
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = True
			.ID = 1009
			.SetBounds 10, 10, 260, 60
			.Designer = @This
			.Parent = @This
		End With
		' chkCase
		With chkCase
			.Name = "chkCase"
			.Text = "Case sensitive"
			.TabIndex = 1
			.Caption = "Case sensitive"
			.SetBounds 10, 70, 90, 20
			.Designer = @This
			.OnClick = @_chkFindReplace_Click
			.Parent = @This
		End With
		' chkWarp
		With chkWarp
			.Name = "chkWarp"
			.Text = "Wrap around"
			.TabIndex = 2
			.Caption = "Wrap around"
			.SetBounds 110, 70, 90, 20
			.Designer = @This
			.OnClick = @_chkFindReplace_Click
			.Parent = @This
		End With
		' txtReplace
		With txtReplace
			.Name = "txtReplace"
			.Text = ""
			.TabIndex = 3
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.ID = 1008
			.HideSelection = True
			.SetBounds 10, 100, 260, 60
			.Designer = @This
			.Parent = @This
		End With
		' btnFindNext
		With btnFindNext
			.Name = "btnFindNext"
			.Text = "Find Next"
			.TabIndex = 4
			.Caption = "Find Next"
			.SetBounds 280, 10, 90, 20
			.Designer = @This
			.OnClick = @_btnFindReplace_Click
			.Parent = @This
		End With
		' btnFindBack
		With btnFindBack
			.Name = "btnFindBack"
			.Text = "Find Back"
			.TabIndex = 5
			.Caption = "Find Back"
			.SetBounds 280, 30, 90, 20
			.Designer = @This
			.OnClick = @_btnFindReplace_Click
			.Parent = @This
		End With
		' btnShowHide
		With btnShowHide
			.Name = "btnShowHide"
			.Text = "Hide Replace"
			.TabIndex = 6
			.Caption = "Hide Replace"
			.SetBounds 280, 70, 90, 20
			.Designer = @This
			.OnClick = @_btnFindReplace_Click
			.Parent = @This
		End With
		' btnReplace
		With btnReplace
			.Name = "btnReplace"
			.Text = "Replace"
			.TabIndex = 7
			.Caption = "Replace"
			.SetBounds 280, 120, 90, 20
			.Designer = @This
			.OnClick = @_btnFindReplace_Click
			.Parent = @This
		End With
		' btnReplaceAll
		With btnReplaceAll
			.Name = "btnReplaceAll"
			.Text = "Replace All"
			.TabIndex = 8
			.Caption = "Replace All"
			.SetBounds 280, 140, 90, 20
			.Designer = @This
			.OnClick = @_btnFindReplace_Click
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmFindReplaceType._chkFindReplace_Click(ByRef Sender As CheckBox)
		*Cast(frmFindReplaceType Ptr, Sender.Designer).chkFindReplace_Click(Sender)
	End Sub
	
	Private Sub frmFindReplaceType._btnFindReplace_Click(ByRef Sender As Control)
		*Cast(frmFindReplaceType Ptr, Sender.Designer).btnFindReplace_Click(Sender)
	End Sub
	
	Dim Shared frmFindReplace As frmFindReplaceType
	
	#if __MAIN_FILE__ = __FILE__
		frmFindReplace.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmFindReplaceType.btnFindReplace_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "btnFindNext"
		MDIMain.Find(txtFind.Text, chkCase.Checked, chkWarp.Checked, False)
	Case "btnFindBack"
		MDIMain.Find(txtFind.Text, chkCase.Checked, chkWarp.Checked, True)
	Case "btnShowHide"
		If txtReplace.Visible= True Then
			Sender.Text = "Show Replace"
			Height = 130
			txtReplace.Visible= False 
			btnReplace.Visible= False 
			btnReplaceAll.Visible= False 
		Else
			Sender.Text = "Hide Replace"
			Height = 200
			txtReplace.Visible= True
			btnReplace.Visible= True
			btnReplaceAll.Visible= True
		End If
	Case "btnReplace"
		MDIMain.Replace(txtFind.Text, txtReplace.Text, chkCase.Checked, chkWarp.Checked)
	Case "btnReplaceAll"
		MDIMain.ReplaceAll(txtFind.Text, txtReplace.Text, chkCase.Checked)
	End Select
End Sub

Private Sub frmFindReplaceType.chkFindReplace_Click(ByRef Sender As CheckBox)
	Select Case Sender.Name
	Case "chkCase"
	Case "chkWarp"
	End Select
End Sub
