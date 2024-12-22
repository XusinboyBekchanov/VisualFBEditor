'frmDeviceExplorer.frm
' Copyright (c) 2024 CM.Wang
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
	#include once "mff/TreeView.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ImageList.bi"
	
	#include once "DeviceExplorer.bi"
	
	Using My.Sys.Forms
	
	Type frmDeviceExplorerType Extends Form
		Declare Sub CommandButton_Enabled(e As Boolean)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub CheckBox_Click(ByRef Sender As CheckBox)
		Declare Sub TreeView1_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub TreeView1_DblClick(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TreeView TreeView1
		Dim As TextBox TextBox1
		Dim As Splitter Splitter1
		Dim As Panel Panel1, Panel2
		Dim As CommandButton cmdRefresh, cmdEnabled, cmdDisabled, cmdRemoved, cmdEject, cmdUninstall, cmdUpdate
		Dim As StatusBar StatusBar1
		Dim As StatusPanel StatusPanel1
		Dim As CheckBox chkShowHidden, chkDarkmode, chkShowCategories
		Dim As ImageList ImageList1
	End Type
	
	Constructor frmDeviceExplorerType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmDeviceExplorer
		With This
			.Name = "frmDeviceExplorer"
			.Text = ML("Devices Explorer")
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "DeviceExplorer.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 750, 500
		End With
		' TreeView1
		With TreeView1
			.Name = "TreeView1"
			.Text = "TreeView1"
			.TabIndex = 0
			.Align = DockStyle.alLeft
			.HideSelection = False
			.ExtraMargins.Left = 10
			.ExtraMargins.Top = 10
			.ExtraMargins.Bottom = 10
			.Sorted = True
			.SelectedImages = @ImageList1
			.Images = @ImageList1
			.SetBounds 10, 10, 380, 419
			.Designer = @This
			.OnSelChanged = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode), @TreeView1_SelChanged)
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TreeView1_DblClick)
			.Parent = @This
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.SetBounds 210, 0, 10, 261
			.Designer = @This
			.Parent = @This
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 1
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 204, 0, 250, 261
			.Designer = @This
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 2
			.Align = DockStyle.alBottom
			.SetBounds 0, 339, 324, 80
			.Designer = @This
			.Parent = @Panel1
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 3
			.Multiline = True
			.ID = 1004
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.ControlIndex = 1
			.Font.Name = "Consolas"
			.SetBounds 0, 0, 324, 329
			.Designer = @This
			.Parent = @Panel1
		End With
		' chkShowCategories
		With chkShowCategories
			.Name = "chkShowCategories"
			.Text = ML("Show all categories")
			.TabIndex = 4
			.SetBounds 0, 10, 140, 18
			.Designer = @This
			.Parent = @Panel2
		End With
		' chkShowHidden
		With chkShowHidden
			.Name = "chkShowHidden"
			.Text = ML("Show hidden")
			.TabIndex = 5
			.SetBounds 140, 10, 140, 18
			.Designer = @This
			.Parent = @Panel2
		End With
		' chkDarkmode
		With chkDarkmode
			.Name = "chkDarkmode"
			.Text = ML("Dark mode")
			.TabIndex = 6
			.Checked = True
			.SetBounds 250, 10, 70, 18
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox_Click)
			.Parent = @Panel2
		End With
		' cmdRefresh
		With cmdRefresh
			.Name = "cmdRefresh"
			.Text = ML("Refresh")
			.TabIndex = 7
			.SetBounds 250, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdEnabled
		With cmdEnabled
			.Name = "cmdEnabled"
			.Text = ML("Enabled")
			.TabIndex = 8
			.SetBounds 0, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdDisabled
		With cmdDisabled
			.Name = "cmdDisabled"
			.Text = ML("Disabled")
			.TabIndex = 9
			.SetBounds 70, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdRemoved
		With cmdRemoved
			.Name = "cmdRemoved"
			.Text = ML("Removed")
			.TabIndex = 10
			.SetBounds 140, 40, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdEject
		With cmdEject
			.Name = "cmdEject"
			.Text = ML("Eject")
			.TabIndex = 11
			.SetBounds 0, 59, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdUninstall
		With cmdUninstall
			.Name = "cmdUninstall"
			.Text = ML("Uninstall")
			.TabIndex = 12
			.SetBounds 70, 60, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdUpdate
		With cmdUpdate
			.Name = "cmdUpdate"
			.Text = ML("Update")
			.TabIndex = 13
			.SetBounds 140, 60, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.SetBounds 0, 459, 764, 22
			.Designer = @This
			.Parent = @This
		End With
		' StatusPanel1
		With StatusPanel1
			.Name = "StatusPanel1"
			.Designer = @This
			.Parent = @StatusBar1
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmDeviceExplorer As frmDeviceExplorerType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmDeviceExplorer.MainForm = True
		frmDeviceExplorer.Show
		App.Run
	#endif
'#End Region

Private Sub frmDeviceExplorerType.CheckBox_Click(ByRef Sender As CheckBox)
	App.DarkMode= Sender.Checked
	InvalidateRect(0, 0, True)
End Sub

Private Sub frmDeviceExplorerType.TreeView1_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	Dim i As Integer
	Dim j As Integer = -1
	Dim wtmp As WString Ptr
	Dim wtmp2 As WString Ptr
	
	TextBox1.Clear
	Select Case Item.Hint
	Case "Categories"
		i = CInt(Item.Name)
		StatusPanel1.Caption = ML(Item.Hint) & ": " & i
	Case Else
		j = CInt(Item.Name)
		i = devicesIndexCategories(j)
		StatusPanel1.Caption = ML(Item.Hint) & ": " & j
	End Select
	devicesSelected = j
	
	TextBox1.AddLine ML("Categories") + ": " & i
'	TextBox1.AddLine "HDEVINFO) + ": " & categoriesHSet(i)
	TextBox1.AddLine ML("Categories Description") + ": " & *categoriesDescription(i)
	TextBox1.AddLine ML("Categories Name") + ": " & *categoriesName(i)
	StringFromCLSID(@categoriesGuid(i), @wtmp)
	TextBox1.AddLine ML("Categories GUID") + ": " & *wtmp
	
	If j < 0 Then
	Else
		TextBox1.AddLine ""
		TextBox1.AddLine ML("Devices") + ": " & j
		TextBox1.AddLine ML("Devices Friendly Name") + ": " & *devicesFriendlyName(j)
		TextBox1.AddLine ML("Devices Description") + ": " & *devicesDescription(j)
		TextBox1.AddLine ML("Devices Hardware Id") + ": " & *devicesHardwareId(j)
		TextBox1.AddLine ML("Devices Instance Id") + ": " & *devicesInstanceId(j)
		TextBox1.AddLine ML("Devices Enabled") + ": " & devicesEnabled(j)
		TextBox1.AddLine ML("Devices Present") + ": " & devicesPresent(j)
		StringFromCLSID(devicesGUID(j), @wtmp)
		TextBox1.AddLine ML("Devices GUID") + ": " & *wtmp
		TextBox1.AddLine ""
		TextBox1.AddLine ML("Devices Capabilities") + ": " + "(&H" & Hex(devicesCapabilities(j), 8) & ")"
		TextBox1.AddLine Capabilities2Str(devicesCapabilities(j))
		TextBox1.AddLine ML("Devices Problem") + ": " + "(&H" & Hex(devicesProblem(j), 8) & ")"
		TextBox1.AddLine Problems2Str(devicesProblem(j))
		TextBox1.AddLine ML("Devices Status") + ": " + "(&H" & Hex(devicesStatus(j), 8) & ")"
		TextBox1.AddLine NodeStatus2Str(devicesStatus(j))
		TextBox1.AddLine ML("Devices Driver") + ": " & *devicesDriver(j)
		GetDriverAllInformation(*devicesDriver(j), wtmp2)
		TextBox1.AddLine *wtmp2
	End If
	CommandButton_Enabled(IIf(j < 0, False, True))
	'If wtmp Then Deallocate(wtmp)
	If wtmp2 Then Deallocate(wtmp2)
End Sub

Private Sub frmDeviceExplorerType.CommandButton_Enabled(e As Boolean)
	cmdDisabled.Enabled = e
	cmdEject.Enabled = e
	cmdEnabled.Enabled = e
	cmdRemoved.Enabled = e
	cmdUninstall.Enabled = e
	cmdUpdate.Enabled = e
End Sub

Private Sub frmDeviceExplorerType.Form_Show(ByRef Sender As Form)
	pvInit()
	
	CommandButton_Enabled(False)
	App.DoEvents()
	
	CommandButton_Click(cmdRefresh)
End Sub

Private Sub frmDeviceExplorerType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	pvRelase()
End Sub

Private Sub frmDeviceExplorerType.TreeView1_DblClick(ByRef Sender As Control)
	If devicesSelected < 0 Then Exit Sub
	Print pvShowPropPage(Handle, devicesSelected)
End Sub

Private Sub frmDeviceExplorerType.CommandButton_Click(ByRef Sender As Control)
	If Sender.Name= "cmdRefresh" Then
		pvInitIcon(@TreeView1)
		pvEnumClasses(Handle, @TreeView1, chkShowCategories.Checked, chkShowHidden.Checked)
		StatusPanel1.Caption = ML("Total") + ": " & EnumCCount & EnumDCount & ", " & ML("Categories") + ": " & EnumCCount & ", " + ML("Devices") + ": " &  EnumDCount
	Else
		If devicesSelected < 0 Then Exit Sub
		Select Case Sender.Name
		Case "cmdEnabled"
			Print pvEnableDevice(Handle, devicesSelected, True, chkShowHidden.Checked)
		Case "cmdDisabled"
			Print pvEnableDevice(Handle, devicesSelected, False, chkShowHidden.Checked)
		Case "cmdRemoved"
			Print pvRemoveDevice(Handle, devicesSelected, chkShowHidden.Checked)
		Case "cmdEject"
			Print pvEjectDevice(Handle, devicesSelected)
		Case "cmdUninstall"
			Print pvUninstallDevice(Handle, devicesSelected, chkShowHidden.Checked)
		Case "cmdUpdate"
			Print pvUpdateDevice(Handle, devicesSelected, chkShowHidden.Checked)
		End Select
	End If
End Sub


