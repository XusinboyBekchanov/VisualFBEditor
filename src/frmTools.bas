'#########################################################
'#  frmTools.bas                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2020)                   #
'#########################################################

#include once "frmTools.bi"

Dim Shared fTools As frmTools
pfTools = @fTools

'#Region "Form"
	Constructor frmTools
		' frmTools
		This.Name = "frmTools"
		This.Text = ML("Tools")
		This.OnCreate = @Form_Create
		This.OnClose = @Form_Close
		This.OnShow = @Form_Show
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.ControlBox = True
		This.MinimizeBox = False
		This.MaximizeBox = False
		This.StartPosition = FormStartPosition.CenterParent
		This.SetBounds 0, 0, 484, 357
		' lvTools
		lvTools.Name = "lvTools"
		lvTools.Text = "ListView1"
		lvTools.SetBounds 12, 12, 366, 198
		lvTools.OnSelectedItemChanged = @lvAddIns_SelectedItemChanged
		lvTools.OnItemClick = @lvAddIns_ItemClick
		lvTools.Columns.Add ML("Name"), , 150
		lvTools.Columns.Add ML("Path"), , 200
		lvTools.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.SetBounds 390, 12, 78, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 390, 40, 78, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdHelp
		cmdHelp.Name = "cmdHelp"
		cmdHelp.Text = ML("Help")
		cmdHelp.SetBounds 390, 180, 78, 24
		cmdHelp.Parent = @This
	End Constructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fTools.Show
		
		App.Run
	#endif
'#End Region

Destructor frmTools
	
End Destructor

Private Sub frmTools.cmdOK_Click(ByRef Sender As Control)
	fTools.CloseForm
End Sub

Private Sub frmTools.cmdCancel_Click(ByRef Sender As Control)
	fTools.CloseForm
End Sub

Private Sub frmTools.Form_Create(ByRef Sender As Control)
	
End Sub

Private Sub frmTools.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	
End Sub

Private Sub frmTools.lvAddIns_SelectedItemChanged(ByRef Sender As ListView, ItemIndex As Integer)
	
End Sub

Private Sub frmTools.Form_Show(ByRef Sender As Form)
	
End Sub

Private Sub frmTools.lvAddIns_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	fTools.lvAddIns_SelectedItemChanged Sender, ItemIndex
End Sub

Sub ExecuteTool(Param As Any Ptr)
	Shell QWString(Param)
End Sub

Sub ToolType.Execute()
	If WaitComplete Then
		Shell Path
	Else
		ThreadCreate(@ExecuteTool, Path.vptr)
	End If
End Sub
