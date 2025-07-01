' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	
	#include once "../MDINotepad/Text.bi"
	#include once "WMI.bi"
	
	Using My.Sys.Forms
	
	Type frmWMIType Extends Form
		namespaces(Any) As WString Ptr
		wmiclasses(Any) As WString Ptr
		properties(Any) As WString Ptr
		values(Any) As WString Ptr
		
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Panel Panel1
		Dim As ComboBoxEdit comboNamespace, comboClasses, comboPropreties
		Dim As CommandButton cmdNameSpace, cmdWMIClasses, cmdPropreties, cmdPropretyValue, cmdClear
		Dim As TextBox txtInfo
	End Type
	
	Constructor frmWMIType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmWMI
		With This
			.Name = "frmWMI"
			.Text = "WMI"
			.Designer = @This
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.Caption = "WMI"
			.StartPosition = FormStartPosition.CenterScreen
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 805, 600
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 794, 70
			.Designer = @This
			.Parent = @This
		End With
		' comboNamespace
		With comboNamespace
			.Name = "comboNamespace"
			.Text = ""
			.TabIndex = 1
			.Style = ComboBoxEditStyle.cbDropDown
			.DropDownCount = 40
			.Hint = "Name space"
			.Sort = True
			.SetBounds 10, 10, 250, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.Parent = @Panel1
		End With
		' comboClasses
		With comboClasses
			.Name = "comboClasses"
			.Text = ""
			.TabIndex = 2
			.Style = ComboBoxEditStyle.cbDropDown
			.DropDownCount = 40
			.Hint = "Class"
			.Sort = True
			.SetBounds 270, 10, 250, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.Parent = @Panel1
		End With
		' comboPropreties
		With comboPropreties
			.Name = "comboPropreties"
			.Text = ""
			.TabIndex = 3
			.Style = ComboBoxEditStyle.cbDropDown
			.DropDownCount = 40
			.Hint = "Proprety"
			.Sort = True
			.SetBounds 530, 10, 250, 21
			.Designer = @This
			.Parent = @Panel1
		End With
		' cmdNameSpace
		With cmdNameSpace
			.Name = "cmdNameSpace"
			.Text = "Enum Namespace"
			.TabIndex = 4
			.Caption = "Enum Namespace"
			.SetBounds 10, 40, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' cmdWMIClasses
		With cmdWMIClasses
			.Name = "cmdWMIClasses"
			.Text = "Enum Classes"
			.TabIndex = 5
			.Caption = "Enum Classes"
			.SetBounds 140, 40, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' cmdPropreties
		With cmdPropreties
			.Name = "cmdPropreties"
			.Text = "Enum Propreties"
			.TabIndex = 6
			.Caption = "Enum Propreties"
			.SetBounds 270, 40, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' cmdPropretyValue
		With cmdPropretyValue
			.Name = "cmdPropretyValue"
			.Text = "Enum All Propreties"
			.TabIndex = 7
			.Caption = "Enum All Propreties"
			.SetBounds 400, 40, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' cmdClear
		With cmdClear
			.Name = "cmdClear"
			.Text = "Clear"
			.TabIndex = 8
			.Caption = "Clear"
			.SetBounds 530, 40, 120, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' txtInfo
		With txtInfo
			.Name = "txtInfo"
			.Text = ""
			.TabIndex = 9
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Font.Name = "Consolas"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 10, 70, 769, 481
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmWMI As frmWMIType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmWMI.MainForm = True
		frmWMI.Show
		App.Run
	#endif
'#End Region

Private Sub frmWMIType.Form_Show(ByRef Sender As Form)
	SendMessage(txtInfo.Handle, EM_LIMITTEXT, -1, 0)
	CommandButton_Click(cmdNameSpace)
	
	comboNamespace.Text = "ROOT\CIMV2"
	
	comboClasses.AddItem "Win32_BIOS"
	comboClasses.AddItem "Win32_DiskDrive"
	comboClasses.AddItem "Win32_DiskPartition"
	comboClasses.AddItem "Win32_LogicalDisk"
	comboClasses.AddItem "Win32_MemoryDevice"
	comboClasses.AddItem "Win32_NetworkAdapter"
	comboClasses.AddItem "Win32_PhysicalMemory"
	comboClasses.AddItem "Win32_PnPEntity"
	comboClasses.AddItem "Win32_PnPDevice"
	comboClasses.AddItem "Win32_USBController"
	comboClasses.AddItem "Win32_USBControllerDevice"
	comboClasses.AddItem "Win32_USBHub"
	comboClasses.AddItem "Win32_Processor"
	comboClasses.Text = "Win32_BIOS"
End Sub

Private Sub frmWMIType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	ArrayDeallocate(namespaces())
	ArrayDeallocate(wmiclasses())
	ArrayDeallocate(properties())
	ArrayDeallocate(values())
End Sub

Private Sub frmWMIType.CommandButton_Click(ByRef Sender As Control)
	Dim As WString Ptr txt = NULL
	Dim i As Integer
	Select Case Sender.Name
	Case cmdNameSpace.Name
		EnumNameSpace("ROOT", "SELECT * FROM __NAMESPACE", namespaces())
		comboNamespace.Clear
		For i = 0 To UBound(namespaces)
			comboNamespace.AddItem *namespaces(i)
		Next
		JoinWStr(namespaces(), vbCrLf, txt)
		txtInfo.Text = *txt
	Case cmdWMIClasses.Name
		ComboBoxEdit_Selected(comboNamespace, 0)
	Case cmdPropreties.Name
		ComboBoxEdit_Selected(comboClasses, 0)
	Case cmdPropretyValue.Name
		EnumPropretiesValues(comboNamespace.Text, comboClasses.Text, txt)
		If txt Then txtInfo.Text = *txt
	Case cmdClear.Name
		txtInfo.Clear
	End Select
	If txt Then Deallocate(txt)
End Sub

Private Sub frmWMIType.ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim As WString Ptr txt
	Select Case Sender.Name
	Case comboClasses.Name
		EnumPropreties(comboNamespace.Text, comboClasses.Text, properties())
		Dim i As Integer
		comboPropreties.Clear
		For i = 0 To UBound(properties)
			comboPropreties.AddItem *properties(i)
		Next
		JoinWStr(properties(), vbCrLf, txt)
		txtInfo.Text = *txt
	Case comboNamespace.Name
		EnumClasses(comboNamespace.Text, "SELECT * FROM META_CLASS", wmiclasses())
		Dim i As Integer
		comboClasses.Clear
		For i = 0 To UBound(wmiclasses)
			comboClasses.AddItem *wmiclasses(i)
		Next
		JoinWStr(wmiclasses(), vbCrLf, txt)
		txtInfo.Text = *txt
	Case comboPropreties.Name
	End Select
	If txt Then Deallocate(txt)
End Sub

