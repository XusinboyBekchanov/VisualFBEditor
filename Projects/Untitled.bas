#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ToolBar.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ImageList.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Static Sub MenuItem9_Click_(ByRef Sender As MenuItem)
		Declare Sub MenuItem9_Click(ByRef Sender As MenuItem)
		Declare Static Sub MenuItem10_Click_(ByRef Sender As MenuItem)
		Declare Sub MenuItem10_Click(ByRef Sender As MenuItem)
		Declare Constructor
		
		Dim As ToolBar ToolBar1
		Dim As ToolButton ToolButton2, ToolButton3, ToolButton4, ToolButton1
		Dim As MenuItem MenuItem1, MenuItem2, MenuItem3, MenuItem4, MenuItem5, MenuItem6, MenuItem7, MenuItem8, MenuItem9, MenuItem10, MenuItem11, MenuItem12, MenuItem13
		Dim As MainMenu MainMenu1
		Dim As PopupMenu PopupMenu1
		Dim As ImageList ImageList1
	End Type
	
	Constructor Form1
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Menu = @MainMenu1
			.SetBounds 0, 0, 350, 300
		End With
		' ToolBar1
		With ToolBar1
			.Name = "ToolBar1"
			.Text = "ToolBar1"
			.SetBounds 0, 0, 334, 16
			.Align = DockStyle.alTop
			.List = True
			.Divider = True
			.Parent = @This
		End With
		' ToolButton2
		With ToolButton2
			.Name = "ToolButton2"
			.Caption = "dd"
			.Style = ToolButtonStyle.tbsAutosize
			.Width = 43
			.Parent = @ToolBar1
		End With
		' ToolButton3
		With ToolButton3
			.Name = "ToolButton3"
			.Style = ToolButtonStyle.tbsDropDown
			.Width = 38
			.Caption = "fdsfdfdfdffff"
			.Parent = @ToolBar1
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Caption = "MenuItem1"
			.ParentMenu = @ToolButton3.DropDownMenu
		End With
		' ToolButton4
		With ToolButton4
			.Name = "ToolButton4"
			.Caption = "dsdsdff"
			.Style = ToolButtonStyle.tbsWholeDropdown
			.Left = 152
			.Width = 58
			.Parent = @ToolBar1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Caption = "fdfdf"
			.ParentMenu = @ToolButton3.DropDownMenu
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Caption = "MenuItem3"
			.Parent = @MenuItem1
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Caption = "sdssd"
			.ParentMenu = @ToolButton4.DropDownMenu
		End With
		' MenuItem5
		With MenuItem5
			.Name = "MenuItem5"
			.Caption = "4545"
			.ParentMenu = @ToolButton4.DropDownMenu
		End With
		' MenuItem6
		With MenuItem6
			.Name = "MenuItem6"
			.Caption = "MenuItem6"
			.Parent = @MenuItem1
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 90, 120, 16, 16
			.Parent = @This
		End With
		' MenuItem7
		With MenuItem7
			.Name = "MenuItem7"
			.Caption = "MenuItem7"
			.ParentMenu = @MainMenu1
		End With
		' MenuItem8
		With MenuItem8
			.Name = "MenuItem8"
			.Caption = "MenuItem8"
			.ParentMenu = @MainMenu1
		End With
		' MenuItem9
		With MenuItem9
			.Name = "MenuItem9"
			.Caption = "MenuItem9"
			.Designer = @This
			.OnClick = @MenuItem9_Click_
			.Parent = @MenuItem8
		End With
		' MenuItem10
		With MenuItem10
			.Name = "MenuItem10"
			.Caption = "MenuItem10"
			.Designer = @This
			.OnClick = @MenuItem10_Click_
			.Parent = @MenuItem7
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 100, 150, 16, 16
			.Parent = @This
		End With
		' MenuItem11
		With MenuItem11
			.Name = "MenuItem11"
			.Caption = "MenuItem11"
			.ParentMenu = @PopupMenu1
		End With
		' MenuItem12
		With MenuItem12
			.Name = "MenuItem12"
			.Caption = "MenuItem12"
			.ParentMenu = @PopupMenu1
		End With
		' MenuItem13
		With MenuItem13
			.Name = "MenuItem13"
			.Caption = "MenuItem13"
			.Parent = @MenuItem12
		End With
		' ToolButton1
		With ToolButton1
			.Name = "ToolButton1"
			.Caption = "154545"
			.Parent = @ToolBar1
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 170, 100, 16, 16
			.Items = "Start	Start" & NewLine & _
			"Key	Key" & Chr(10) & _
			
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1.MenuItem9_Click_(ByRef Sender As MenuItem)
	*Cast(Form1 Ptr, Sender.Designer).MenuItem9_Click(Sender)
End Sub
Private Sub Form1.MenuItem9_Click(ByRef Sender As MenuItem)
	
End Sub

Private Sub Form1.MenuItem10_Click_(ByRef Sender As MenuItem)
	*Cast(Form1 Ptr, Sender.Designer).MenuItem10_Click(Sender)
End Sub
Private Sub Form1.MenuItem10_Click(ByRef Sender As MenuItem)
	
End Sub
