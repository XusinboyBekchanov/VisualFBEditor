'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CheckedListBox.bi"
	#include once "mff/TabControl.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/Picture.bi"
	
	Using My.Sys.Forms
	
	Type frmComponentsType Extends Form
		Declare Static Sub cmdApply_Click_(ByRef Sender As Control)
		Declare Sub cmdApply_Click(ByRef Sender As Control)
		Declare Static Sub cmdOK_Click_(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create_(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub chlControls_Change_(ByRef Sender As ListControl)
		Declare Sub chlControls_Change(ByRef Sender As ListControl)
		Declare Constructor
		
		Dim As Panel pnlCommands
		Dim As CommandButton cmdApply, cmdCancel, cmdOK, cmdBrowse
		Dim As TabControl tabComponents
		Dim As TabPage tbpControls
		Dim As GroupBox grbInformation
		Dim As CheckedListBox chlControls
		Dim As Picture pnlRight
		Dim As Label lblLocation
		Dim As CheckBox chkSelectedItemsOnly
		Dim As WStringList Paths
	End Type
	
	Constructor frmComponentsType
		' frmComponents
		With This
			.Name = "frmComponents"
			.Text = "Components"
			.Designer = @This
			.Caption = "Components"
			.OnCreate = @Form_Create_
			.ControlBox = True
			.Icon = "1"
			.SetBounds 0, 0, 460, 410
		End With
		' pnlCommands
		With pnlCommands
			.Name = "pnlCommands"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alBottom
			.SetBounds 0, 341, 444, 30
			.Designer = @This
			.Parent = @This
		End With
		' cmdApply
		With cmdApply
			.Name = "cmdApply"
			.Text = "Apply"
			.TabIndex = 1
			.Caption = "Apply"
			.Align = DockStyle.alRight
			.ExtraMargins.Right = 5
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.SetBounds 349, 5, 90, 20
			.Designer = @This
			.OnClick = @cmdApply_Click_
			.Parent = @pnlCommands
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = "Cancel"
			.TabIndex = 2
			.Align = DockStyle.alRight
			.ControlIndex = 0
			.ExtraMargins.Top = 5
			.ExtraMargins.Right = 5
			.ExtraMargins.Bottom = 5
			.Caption = "Cancel"
			.SetBounds 254, 5, 90, 20
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @pnlCommands
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = "OK"
			.TabIndex = 3
			.Align = DockStyle.alRight
			.ControlIndex = 0
			.ExtraMargins.Top = 5
			.ExtraMargins.Right = 5
			.ExtraMargins.Bottom = 5
			.Caption = "OK"
			.SetBounds 159, 5, 90, 20
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlCommands
		End With
		' tabComponents
		With tabComponents
			.Name = "tabComponents"
			.Text = "TabControl1"
			.TabIndex = 4
			.Align = DockStyle.alClient
			.ExtraMargins.Left = 5
			.ExtraMargins.Right = 5
			.ExtraMargins.Top = 5
			.SetBounds 5, 5, 434, 336
			.Designer = @This
			.Parent = @This
		End With
		' tbpControls
		With tbpControls
			.Name = "tbpControls"
			.Text = "Controls"
			.TabIndex = 5
			.Caption = "Controls"
			.UseVisualStyleBackColor = True
			.SetBounds 2, 22, 428, 311
			.Designer = @This
			.Parent = @tabComponents
		End With
		' grbInformation
		With grbInformation
			.Name = "grbInformation"
			.Text = "MyFbFramework"
			.TabIndex = 6
			.Align = DockStyle.alBottom
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.Caption = "MyFbFramework"
			.SetBounds 10, 241, 408, 60
			.Designer = @This
			.Parent = @tbpControls
		End With
		' pnlRight
		With pnlRight
			.Name = "pnlRight"
			.Text = ""
			.TabIndex = 7
			.Align = DockStyle.alRight
			.SetBounds 278, 0, 150, 221
			.Designer = @This
			.Parent = @tbpControls
		End With
		' chlControls
		With chlControls
			.Name = "chlControls"
			.Text = "CheckedListBox1"
			.TabIndex = 8
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 10
			.SetBounds 10, 10, 268, 228
			.Designer = @This
			.OnChange = @chlControls_Change_
			.Parent = @tbpControls
		End With
		' lblLocation
		With lblLocation
			.Name = "lblLocation"
			.Text = "Location: "
			.TabIndex = 9
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 25
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.Caption = "Location: "
			.WordWraps = False
			.SetBounds 10, 30, 388, 20
			.Designer = @This
			.Parent = @grbInformation
		End With
		' cmdBrowse
		With cmdBrowse
			.Name = "cmdBrowse"
			.Text = "Browse..."
			.TabIndex = 10
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.Caption = "Browse..."
			.SetBounds 10, 10, 130, 20
			.Designer = @This
			.Parent = @pnlRight
		End With
		' chkSelectedItemsOnly
		With chkSelectedItemsOnly
			.Name = "chkSelectedItemsOnly"
			.Text = "Selected Items Only"
			.TabIndex = 11
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.Caption = "Selected Items Only"
			.SetBounds 10, 40, 130, 20
			.Designer = @This
			.Parent = @pnlRight
		End With
	End Constructor
	
	Private Sub frmComponentsType.chlControls_Change_(ByRef Sender As ListControl)
		*Cast(frmComponentsType Ptr, Sender.Designer).chlControls_Change(Sender)
	End Sub
	
	Private Sub frmComponentsType.Form_Create_(ByRef Sender As Control)
		*Cast(frmComponentsType Ptr, Sender.Designer).Form_Create(Sender)
	End Sub
	
	Private Sub frmComponentsType.cmdCancel_Click_(ByRef Sender As Control)
		*Cast(frmComponentsType Ptr, Sender.Designer).cmdCancel_Click(Sender)
	End Sub
	
	Private Sub frmComponentsType.cmdOK_Click_(ByRef Sender As Control)
		*Cast(frmComponentsType Ptr, Sender.Designer).cmdOK_Click(Sender)
	End Sub
	
	Private Sub frmComponentsType.cmdApply_Click_(ByRef Sender As Control)
		*Cast(frmComponentsType Ptr, Sender.Designer).cmdApply_Click(Sender)
	End Sub
	
	Dim Shared frmComponents As frmComponentsType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		frmComponents.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmComponentsType.cmdApply_Click(ByRef Sender As Control)
	Dim As Library Ptr CtlLibrary
	Dim bFinded As Boolean
	For i As Integer = 0 To chlControls.ItemCount - 1
		bFinded = False
		For j As Integer = 0 To ControlLibraries.Count - 1
			CtlLibrary = ControlLibraries.Item(j)
			If GetFullPath(CtlLibrary->Path) = Paths.Item(i) Then
				bFinded = True
				CtlLibrary->Enabled = chlControls.Checked(i)
				Exit For
			End If
		Next
		If Not bFinded Then
			If chlControls.Checked(i) Then
				
			End If
		End If
		iniSettings.WriteString("ControlLibraries", "Path_" & Str(i), GetRelative(Paths.Item(i), ExePath))
		iniSettings.WriteBool("ControlLibraries", "Enabled_" & Str(i), chlControls.Checked(i))
	Next
End Sub

Private Sub frmComponentsType.cmdOK_Click(ByRef Sender As Control)
	cmdApply_Click(Sender)
	This.CloseForm
End Sub

Private Sub frmComponentsType.cmdCancel_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub frmComponentsType.Form_Create(ByRef Sender As Control)
	Dim As UInteger Attr
	Dim f As WString * 1024
	f = Dir(ExePath & Slash & "Controls" & Slash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	While f <> ""
		If FormClosing Then Exit Sub
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then
				Dim As IniFile ini
				ini.Load ExePath & Slash & "Controls" & Slash & f & Slash & "Settings.ini"
				Dim LibKey As String = "Lib"
				Dim FileName As UString
				#ifndef __FB_WIN32__
					LibKey &= "X"
				#endif
				#ifdef __FB_64BIT__
					LibKey &= "64"
				#else
					LibKey &= "32"
				#endif
				#ifdef __USE_GTK__
					#ifdef __USE_GTK4__
						LibKey &= "_gtk4"
					#elseif defined(__USE_GTK3__)
						LibKey &= "_gtk3"
					#else
						LibKey &= "_gtk2"
					#endif
				#endif
				FileName = ini.ReadString("Setup", LibKey)
				If FileName = "" Then Continue While
				chlControls.AddItem ini.ReadString("Setup", "Name")
				Paths.Add ExePath & Slash & "Controls" & Slash & f & Slash & FileName
				Dim As Library Ptr CtlLibrary
				For i As Integer = 0 To ControlLibraries.Count - 1
					CtlLibrary = ControlLibraries.Item(i)
					If CtlLibrary->Path = "Controls" & Slash & f & Slash & FileName Then
						If CtlLibrary->Enabled Then chlControls.Checked(chlControls.ItemCount - 1) = True 
						Exit For
					End If
				Next
			End If
		End If
		f = Dir(Attr)
	Wend
	If chlControls.ItemCount > 0 Then chlControls.ItemIndex = 0: chlControls_Change(chlControls)
End Sub

Private Sub frmComponentsType.chlControls_Change(ByRef Sender As ListControl)
	grbInformation.Text = chlControls.Text
	If chlControls.ItemIndex <> -1 Then lblLocation.Text = ML("Location") & ": " & Paths.Item(chlControls.ItemIndex)
End Sub
