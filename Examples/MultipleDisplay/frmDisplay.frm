'MultipleMonitor多显示器
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmDisplay.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ListControl.bi"
	#include once "mff/Splitter.bi"
	
	#include once "Monitor.bi"
	
	Using My.Sys.Forms
	
	Type frmDisplayType Extends Form
		Dim mtr As Monitor
		
		Declare Sub ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub ListControl2_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Panel Panel1
		Dim As TextBox TextBox1
		Dim As CommandButton CommandButton1, CommandButton2, CommandButton3, CommandButton4, CommandButton5, CommandButton6
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2, ComboBoxEdit3, ComboBoxEdit5, ComboBoxEdit4
		Dim As ListControl ListControl1, ListControl2
		Dim As Splitter Splitter1
	End Type
	
	Constructor frmDisplayType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmDisplay
		With This
			.Name = "frmDisplay"
			.StartPosition = FormStartPosition.CenterScreen
			.Designer = @This
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = ML("VisualFBEditor Multiple Display64")
			#else
				'...instructions for other OSes
				.Caption = ML("VisualFBEditor Multiple Display32")
			#endif
			.SetBounds 0, 0, 800, 610
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 10, 10, 230, 551
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 1
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 0, 230, 21
			.Parent = @Panel1
			.AddItem ML("QDC_ALL_PATHS")
			.AddItem ML("QDC_ONLY_ACTIVE_PATHS")
			.AddItem ML("QDC_DATABASE_CURRENT")
			.ItemIndex = 0
		End With
		' ListControl1
		With ListControl1
			.Name = "ListControl1"
			.Text = "ListControl1"
			.TabIndex = 2
			.SelectionMode = SelectionModes.smMultiExtended
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 22, 230, 95
			.Parent = @Panel1
			.AddItem ML("QDC_VIRTUAL_MODE_AWARE")
			.AddItem ML("QDC_INCLUDE_HMD")
			.AddItem ML("QDC_VIRTUAL_REFRESH_RATE_AWARE")
			.AddItem ML("NONE")
			.ItemIndex = 0
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = ML("Query Display Config")
			.TabIndex = 3
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 120, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 4
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 160, 110, 21
			.Parent = @Panel1
			.AddItem ML("Clone")
			.AddItem ML("Extended")
			.AddItem ML("Internal")
			.AddItem ML("External")
			.ItemIndex = 0
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = ML("Set Display Config")
			.TabIndex = 5
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 120, 160, 110, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' CommandButton3
		With CommandButton3
			.Name = "CommandButton3"
			.Text = ML("Enum Display Monitors")
			.TabIndex = 6
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 200, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' CommandButton4
		With CommandButton4
			.Name = "CommandButton4"
			.Text = ML("Enum Display Devices")
			.TabIndex = 7
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 240, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' ComboBoxEdit3
		With ComboBoxEdit3
			.Name = "ComboBoxEdit3"
			.Text = "ComboBoxEdit3"
			.TabIndex = 8
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 260, 230, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.Parent = @Panel1
		End With
		' CommandButton5
		With CommandButton5
			.Name = "CommandButton5"
			.Text = ML("Enum Display Settings")
			.TabIndex = 9
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 300, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' ComboBoxEdit4
		With ComboBoxEdit4
			.Name = "ComboBoxEdit4"
			.Text = "ComboBoxEdit4"
			.TabIndex = 10
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 0, 320, 230, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
			.Parent = @Panel1
			.AddItem ML("EDS RAWMODE")
			.AddItem ML("EDS ROTATEDMODE")
			.ItemIndex = 0
		End With
		' ListControl2
		With ListControl2
			.Name = "ListControl2"
			.Text = "ListControl2"
			.TabIndex = 11
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Top = AnchorStyle.asAnchor
			.SetBounds 0, 350, 230, 154
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ListControl2_Click)
			.Parent = @Panel1
		End With
		' ComboBoxEdit5
		With ComboBoxEdit5
			.Name = "ComboBoxEdit5"
			.Text = "ComboBoxEdit5"
			.TabIndex = 12
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.ControlIndex = 3
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 0, 500, 230, 21
			.Parent = @Panel1
			.AddItem "0"
			.AddItem ML("CDS FULLSCREEN")
			.AddItem ML("CDS GLOBAL")
			.AddItem ML("CDS NORESET")
			.AddItem ML("CDS RESET")
			.AddItem ML("CDS SET PRIMARY")
			.AddItem ML("CDS TEST")
			.AddItem ML("CDS UPDATEREGISTRY")
			.AddItem ML("CDS VIDEOPARAMETERS")
			.AddItem ML("CDS ENABLE UNSAFE MODES")
			.AddItem ML("CDS DISABLE UNSAFE MODES")
			.ItemIndex = 7
		End With
		' CommandButton6
		With CommandButton6
			.Name = "CommandButton6"
			.Text = ML("Change Display Settings")
			.TabIndex = 13
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.ControlIndex = 4
			.Anchor.Bottom = AnchorStyle.asAnchor
			.SetBounds 0, 530, 230, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.SetBounds 240, 10, 10, 110
			.Designer = @This
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ML("Hello!") & WChr(55357, 56832)
			.TabIndex = 15
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.Font.Name = "Consolas"
			.ControlIndex = 3
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 10
			.SetBounds 250, 0, 534, 561
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmDisplay As frmDisplayType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmDisplay.MainForm = True
		frmDisplay.Show
		App.Run
	#endif
'#End Region

'Query Display Config
Private Sub frmDisplayType.CommandButton_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "CommandButton1"
		mtr.QueryDisplayConfigs(@ComboBoxEdit1, @ListControl1, @TextBox1)
	Case "CommandButton2"
		mtr.SetDisplayConfigs(@ComboBoxEdit2, @TextBox1)
		ComboBoxEdit3.Clear
		ListControl2.Clear
	Case "CommandButton3"
		mtr.EnumDisplayMonitor(@TextBox1)
	Case "CommandButton4"
		mtr.EnumDisplayDevice(EDSEdwFlags(ComboBoxEdit4.ItemIndex), @ComboBoxEdit3, @ListControl2, @TextBox1)
	Case "CommandButton5"
		mtr.EnumDisplayMode(ComboBoxEdit3.Item(ComboBoxEdit3.ItemIndex), EDSEdwFlags(ComboBoxEdit4.ItemIndex), @ListControl2, @TextBox1)
	Case "CommandButton6"
		mtr.ChangeDisplaySettings(ComboBoxEdit3.Item(ComboBoxEdit3.ItemIndex), ListControl2.ItemIndex, EDSEdwFlags(ComboBoxEdit4.ItemIndex), CDSdwFlags(ComboBoxEdit5.ItemIndex), @TextBox1)
	End Select
End Sub

'Enum Display Mode
Private Sub frmDisplayType.ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	mtr.EnumDisplayMode(ComboBoxEdit3.Item(ComboBoxEdit3.ItemIndex), EDSEdwFlags(ComboBoxEdit4.ItemIndex), @ListControl2, @TextBox1)
End Sub

Private Sub frmDisplayType.ListControl2_Click(ByRef Sender As Control)
	mtr.GetDisplayMode(ComboBoxEdit3.Item(ComboBoxEdit3.ItemIndex), ComboBoxEdit4.ItemIndex, ListControl2.ItemIndex, @ListControl2, @TextBox1)
End Sub

