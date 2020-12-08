#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "frmTemplates.bi"
	
	Constructor frmTemplates
		' frmTemplates
		With This
			.Name = "frmTemplates"
			.Text = ML("New Project")
			.StartPosition = FormStartPosition.CenterParent
			.Designer = @This
			.OnCreate = @Form_Create_
			.BorderStyle = FormBorderStyle.FixedDialog
			.MinimizeBox = False
			.MaximizeBox = False
			.OnShow = @Form_Show_
			.OnClose = @Form_Close_
			.SetBounds 0, 0, 527, 370
		End With
		' TabControl1
		With TabControl1
			.Name = "TabControl1"
			.Text = "TabControl1"
			.SetBounds 10, 10, 502, 300
			.Parent = @This
		End With
		' tpNew
		With tpNew
			.Name = "tpNew"
			.SetBounds 2, 22, 498, 275
			.Text = ML("New")
			.UseVisualStyleBackColor = True
			.Parent = @TabControl1
		End With
		' tvTemplates
		With tvTemplates
			.Name = "tvTemplates"
			.Text = "TreeView1"
			.SetBounds 8, 8, 180, 260
			.Designer = @This
			.OnSelChanged = @tvTemplates_SelChanged_
			.Parent = @tpNew
		End With
		' lvTemplates
		With lvTemplates
			.Name = "lvTemplates"
			.Text = "ListView1"
			.View = ViewStyle.vsIcon
			.Images = @imgList
			.SetBounds 198, 8, 290, 260
			.Designer = @This
			.OnItemActivate = @lvTemplates_ItemActivate_
			.Parent = @tpNew
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.SetBounds 330, 314, 88, 21
			.Caption = ML("OK")
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.SetBounds 422, 314, 88, 21
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fTemplates As frmTemplates
	pfTemplates = @fTemplates
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmTemplates.cmdCancel_Click_(ByRef Sender As Control)
	*Cast(frmTemplates Ptr, Sender.Designer).cmdCancel_Click(Sender)
End Sub
Private Sub frmTemplates.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmTemplates.cmdOK_Click_(ByRef Sender As Control)
	*Cast(frmTemplates Ptr, Sender.Designer).cmdOK_Click(Sender)
End Sub
Private Sub frmTemplates.cmdOK_Click(ByRef Sender As Control)
	If lvTemplates.SelectedItemIndex > -1 Then
		SelectedTemplate = ExePath & Slash & "Templates" & Slash & Templates.Item(lvTemplates.SelectedItemIndex)
		ModalResult = ModalResults.OK
		Me.CloseForm
	Else
		MsgBox ML("Select template!")
		Me.BringToFront
	End If
End Sub

Private Sub frmTemplates.tvTemplates_SelChanged_(ByRef Sender As TreeView, ByRef Item As TreeNode)
	*Cast(frmTemplates Ptr, Sender.Designer).tvTemplates_SelChanged(Sender, Item)
End Sub
Private Sub frmTemplates.tvTemplates_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	If FormClosing Then Exit Sub
	lvTemplates.ListItems.Clear
	Templates.Clear
	Dim As String f, TemplateName
	If Item.Name = "Projects" Then
		f = Dir(ExePath & "/Templates/Projects/*.vfp")
		While f <> ""
			TemplateName = Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			lvTemplates.ListItems.Add TemplateName, "Project"
			Templates.Add "Projects/" & f
			f = Dir()
		Wend
	Else
		Dim As String IconName
		f = Dir(ExePath & "/Templates/Files/*")
		While f <> ""
			TemplateName = Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			If EndsWith(f, ".frm") Then
				IconName = "Form"
			ElseIf f = "User Control.bas" Then
				IconName = "UserControl"
			ElseIf EndsWith(f, ".bas") Then
				IconName = "Module"
			ElseIf EndsWith(f, ".rc") Then
				IconName = "Resource"
			Else
				IconName = "File"
			End If
			lvTemplates.ListItems.Add TemplateName, IconName
			Templates.Add "Files/" & f
			f = Dir()
		Wend
	End If
End Sub

Private Sub frmTemplates.Form_Create_(ByRef Sender As Control)
	*Cast(frmTemplates Ptr, Sender.Designer).Form_Create(Sender)
End Sub
Private Sub frmTemplates.Form_Create(ByRef Sender As Control)
	
End Sub

Private Sub frmTemplates.lvTemplates_ItemActivate_(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	*Cast(frmTemplates Ptr, Sender.Designer).lvTemplates_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmTemplates.lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmTemplates.Form_Show_(ByRef Sender As Form)
	*Cast(frmTemplates Ptr, Sender.Designer).Form_Show(Sender)
End Sub
Private Sub frmTemplates.Form_Show(ByRef Sender As Form)
	ModalResult = ModalResults.Cancel
	tvTemplates.Nodes.Clear
	If OnlyFiles = False Then
		tvTemplates.Nodes.Add ML("Projects"), "Projects"
	End If
	tvTemplates.Nodes.Add ML("Files"), "Files"
	tvTemplates_SelChanged tvTemplates, *tvTemplates.Nodes.Item(0)
End Sub

Private Sub frmTemplates.Form_Close_(ByRef Sender As Form, ByRef Action As Integer)
	*Cast(frmTemplates Ptr, Sender.Designer).Form_Close(Sender, Action)
End Sub
Private Sub frmTemplates.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	OnlyFiles = False
End Sub
