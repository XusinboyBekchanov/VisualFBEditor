'frmUSBView.frm
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
	#include once "mff/TreeView.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ImageList.bi"
	
	#include once "../MDINotepad/Text.bi"
	#include once "USBView.bi"
	
	Using My.Sys.Forms
	
	Type frmUSUViewType Extends Form
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub CheckBox3_Click(ByRef Sender As CheckBox)
		Declare Sub TreeView1_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TreeView TreeView1
		Dim As TextBox TextBox1
		Dim As Splitter Splitter1
		Dim As Panel Panel1, Panel2
		Dim As CommandButton cmdRefresh, cmdEnabled, cmdDisabled, cmdRemoved, cmdEject
		Dim As StatusBar StatusBar1
		Dim As StatusPanel StatusPanel1
		Dim As CheckBox CheckBox1, CheckBox2, CheckBox3
		Dim As ImageList ImageList1
	End Type
	
	Constructor frmUSUViewType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmUSUView
		With This
			.Name = "frmUSUView"
			.Text = ML("USB View")
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "/USBView.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.SetBounds 0, 0, 750, 500
		End With
		' TreeView1
		With TreeView1
			.Name = "TreeView1"
			.Text = "TreeView1"
			.TabIndex = 0
			.Align = DockStyle.alLeft
			.ExtraMargins.Left = 10
			.ExtraMargins.Top = 10
			.ExtraMargins.Bottom = 10
			.Images = @ImageList1
			.SetBounds 10, 10, 300, 419
			.Designer = @This
			.OnSelChanged = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode), @TreeView1_SelChanged)
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
			.TabIndex = 2
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
			.TabIndex = 3
			.Align = DockStyle.alBottom
			.SetBounds 0, 389, 404, 30
			.Designer = @This
			.Parent = @Panel1
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 1
			.Multiline = True
			.ID = 1004
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.ControlIndex = 1
			.Font.Name = "Consolas"
			.SetBounds 0, 0, 404, 389
			.Designer = @This
			.Parent = @Panel1
		End With
		' cmdRefresh
		With cmdRefresh
			.Name = "cmdRefresh"
			.Text = ML("Refresh")
			.TabIndex = 4
			.SetBounds 0, 9, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdEnabled
		With cmdEnabled
			.Name = "cmdEnabled"
			.Text = ML("Enabled")
			.TabIndex = 5
			.Visible = False
			.SetBounds 80, 9, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdDisabled
		With cmdDisabled
			.Name = "cmdDisabled"
			.Text = ML("Disabled")
			.TabIndex = 6
			.Visible = False
			.SetBounds 160, 9, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdRemoved
		With cmdRemoved
			.Name = "cmdRemoved"
			.Text = ML("Removed")
			.TabIndex = 7
			'.Caption = "Removed"
			.Visible = False
			.SetBounds 240, 9, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' cmdEject
		With cmdEject
			.Name = "cmdEject"
			.Text = ML("Eject")
			.TabIndex = 8
			'.Caption = "Eject"
			.Visible = False
			.SetBounds 320, 9, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel2
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.SetBounds 0, 439, 734, 22
			.Designer = @This
			.Parent = @This
		End With
		' StatusPanel1
		With StatusPanel1
			.Name = "StatusPanel1"
			.Designer = @This
			.Parent = @StatusBar1
		End With
		' CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "CheckBox1"
			.TabIndex = 9
			.Visible = False
			.SetBounds 0, 31, 150, 20
			.Designer = @This
			.Parent = @Panel2
		End With
		' CheckBox2
		With CheckBox2
			.Name = "CheckBox2"
			.Text = "CheckBox2"
			.TabIndex = 10
			.Visible = False
			.SetBounds 160, 31, 150, 20
			.Designer = @This
			.Parent = @Panel2
		End With
		' CheckBox3
		With CheckBox3
			.Name = "CheckBox3"
			.Text = ML("Dark mode")
			.TabIndex = 11
			'.Caption = "Dark mode"
			.Checked = True
			.SetBounds 80, 11, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @CheckBox3_Click)
			.Parent = @Panel2
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmUSUView As frmUSUViewType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmUSUView.MainForm = True
		frmUSUView.Show
		App.Run
	#endif
'#End Region

Private Sub frmUSUViewType.CommandButton_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdRefresh"
		usbHostControllerEnum(@TreeView1, @TextBox1)
	Case "cmdEnabled"
	Case "cmdDisabled"
	Case "cmdRemoved"
	Case "cmdEject"
	End Select
End Sub

Private Sub frmUSUViewType.CheckBox3_Click(ByRef Sender As CheckBox)
	App.DarkMode= Sender.Checked
	InvalidateRect(0, 0, True)
End Sub

Private Sub frmUSUViewType.TreeView1_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	If Item.Name="" Then
		TextBox1.Text = Item.Text & vbTab & Item.Name
	Else
		TextBox1.Text = Item.Text & vbTab & Item.Name & vbCrLf & *usbMessage(CInt(Item.Name))
	End If
End Sub

Private Sub frmUSUViewType.Form_Show(ByRef Sender As Form)
	CommandButton_Click(cmdRefresh)
End Sub

Private Sub frmUSUViewType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	usbTextRelease()
End Sub

Private Sub frmUSUViewType.Form_Create(ByRef Sender As Control)
	Dim i As Long
	Dim j As Long
	Dim Icon As HICON
	
	j = ExtractIconEx("C:\Windows\System32\setupapi.dll", -1, 0, 0, 1)
	For i = 0 To j
		ExtractIconEx("C:\Windows\System32\setupapi.dll", i, 0, @Icon, 1)
		ImageList_ReplaceIcon(ImageList1.Handle, -1, Icon)
		DestroyIcon Icon
	Next
End Sub
