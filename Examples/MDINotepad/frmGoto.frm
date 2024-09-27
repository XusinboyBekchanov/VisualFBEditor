﻿' MDINotepad frmGoto.frm
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
	#include once "mff/Label.bi"
	
	Using My.Sys.Forms
	
	Type frmGotoType Extends Form
		Declare Sub btnGoto_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TextBox txtLineNo
		Dim As CommandButton btnGoto
		Dim As Label lblMsg
	End Type
	
	Constructor frmGotoType
		' frmGoto
		With This
			.Name = "frmGoto"
			.Text = "Go To a Line"
			.Designer = @This
			.Caption = "Go To a Line"
			.BorderStyle = FormBorderStyle.FixedDialog
			.MinimizeBox = False
			.MaximizeBox = False
			.StartPosition = FormStartPosition.CenterParent
			.DefaultButton = @btnGoto
			.SetBounds 0, 0, 226, 120
		End With
		' lblMsg
		With lblMsg
			.Name = "lblMsg"
			.Text = "Line nubmer ():"
			.TabIndex = 0
			.Caption = "Line nubmer ():"
			.SetBounds 10, 10, 200, 20
			.Designer = @This
			.Parent = @This
		End With
		' txtLineNo
		With txtLineNo
			.Name = "txtLineNo"
			.Text = ""
			.TabIndex = 1
			.NumbersOnly = True
			.HideSelection = False
			.SetBounds 10, 30, 200, 20
			.Designer = @This
			.Parent = @This
		End With
		' btnGoto
		With btnGoto
			.Name = "btnGoto"
			.Text = "Goto"
			.TabIndex = 2
			.Caption = "Goto"
			.SetBounds 120, 60, 90, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @btnGoto_Click)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmGoto As frmGotoType
	
	#if _MAIN_FILE_ = __FILE__
		frmGoto.MainForm = True
		frmGoto.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmGotoType.btnGoto_Click(ByRef Sender As Control)
	MDIMain.GotoLineNo(CInt(txtLineNo.Text))
	'CloseForm
End Sub
