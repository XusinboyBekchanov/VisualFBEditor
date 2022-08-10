'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CheckedListBox.bi"
	#include once "mff/TabControl.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/CheckBox.bi"
	
	Using My.Sys.Forms
	
	Type frmComponentsType Extends Form
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
	End Type
	
	Constructor frmComponentsType
		' frmComponents
		With This
			.Name = "frmComponents"
			.Text = "Components"
			.Designer = @This
			.Caption = "Components"
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
			.SetBounds 344, 10, 90, 20
			.Designer = @This
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
			.SetBounds 259, 0, 90, 30
			.Designer = @This
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
			.SetBounds 349, 5, 90, 20
			.Designer = @This
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
			.UseVisualStyleBackColor = true
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
			.Parent = @tbpControls
		End With
		' lblLocation
		With lblLocation
			.Name = "lblLocation"
			.Text = "Location: "
			.TabIndex = 9
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 20
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.Caption = "Location: "
			.SetBounds 10, 20, 388, 30
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
	
	Dim Shared frmComponents As frmComponentsType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		frmComponents.Show
		
		App.Run
	#endif
'#End Region
