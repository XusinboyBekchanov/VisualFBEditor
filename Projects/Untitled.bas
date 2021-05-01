#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ToolBar.bi"
	#include once "mff/ImageList.bi"
	
	Using My.Sys.Forms
	
	Type Form1 Extends Form
		Declare Static Sub MenuItem2_Click_(ByRef Sender As MenuItem)
		Declare Sub MenuItem2_Click(ByRef Sender As MenuItem)
		Declare Static Sub MenuItem1_Click_(ByRef Sender As MenuItem)
		Declare Sub MenuItem1_Click(ByRef Sender As MenuItem)
		Declare Static Sub MenuItem3_Click_(ByRef Sender As MenuItem)
		Declare Sub MenuItem3_Click(ByRef Sender As MenuItem)
		Declare Constructor
		
		Dim As MainMenu MainMenu1
		Dim As MenuItem MenuItem1, MenuItem2, MenuItem3, MenuItem4, MenuItem5, MenuItem6, MenuItem7, MenuItem8, MenuItem9, MenuItem10, MenuItem11
		Dim As PopupMenu PopupMenu1
		Dim As ToolBar ToolBar1
		Dim As ToolButton ToolButton3, ToolButton5, ToolButton1, ToolButton2
		Dim As ImageList ImageList1
	End Type
	
	Constructor Form1
		' Form1
		With This
			.Name = "Form1"
			.Text = "Form1"
			.Menu = @MainMenu1
			.ContextMenu = @PopupMenu1
			.SetBounds 0, 0, 350, 300
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 110, 70, 16, 16
			.Parent = @This
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Caption = "fdfdf"
			.Designer = @This
			.OnClick = @MenuItem1_Click_
			.ParentMenu = @MainMenu1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Caption = "-"
			.Designer = @This
			.OnClick = @MenuItem2_Click_
			.ParentMenu = @MainMenu1
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Caption = "fdfdfdf"
			.Designer = @This
			.OnClick = @MenuItem3_Click_
			.ParentMenu = @MainMenu1
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 100, 110, 16, 16
			.Parent = @This
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Caption = "trtrrtr"
			.ParentMenu = @PopupMenu1
		End With
		' MenuItem5
		With MenuItem5
			.Name = "MenuItem5"
			.Caption = "rrtr"
			.ParentMenu = @PopupMenu1
		End With
		' MenuItem6
		With MenuItem6
			.Name = "MenuItem6"
			.Caption = "-"
			.ParentMenu = @PopupMenu1
		End With
		' MenuItem7
		With MenuItem7
			.Name = "MenuItem7"
			.Caption = "dsds"
			.Image = "Bookmark"
			.Parent = @MenuItem1
		End With
		' MenuItem8
		With MenuItem8
			.Name = "MenuItem8"
			.Caption = "sdsd"
			.Parent = @MenuItem3
		End With
		' MenuItem9
		With MenuItem9
			.Name = "MenuItem9"
			.Caption = "fdfdf"
			.Parent = @MenuItem4
		End With
		' MenuItem10
		With MenuItem10
			.Name = "MenuItem10"
			.Caption = "MenuItem10"
			.ParentMenu = @PopupMenu1
		End With
		' MenuItem11
		With MenuItem11
			.Name = "MenuItem11"
			.Caption = "MenuItem11"
			.ParentMenu = @PopupMenu1
		End With
		' ToolBar1
		With ToolBar1
			.Name = "ToolBar1"
			.Text = "ToolBar1"
			.SetBounds 0, 0, 334, 76
			.Align = DockStyle.alTop
			.Flat = True
			.Parent = @This
		End With
		' ToolButton3
		With ToolButton3
			.Name = "ToolButton3"
			.Caption = "New"
			.Parent = @ToolBar1
		End With
		' ToolButton5
		With ToolButton5
			.Name = "ToolButton5"
			.Caption = "Open"
			.Style = ToolButtonStyle.tbsSeparator
			.Left = 86
			.Width = 8
			.Height = 96
			.Parent = @ToolBar1
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 100, 160, 16, 16
			.Parent = @This
		End With
		' ToolButton1
		With ToolButton1
			.Name = "ToolButton1"
			.Caption = "ToolButton1"
			.Style = ToolButtonStyle.tbsSeparator
			.Height = 116
			.Left = 73
			.Width = 8
			.Parent = @ToolBar1
		End With
		' ToolButton2
		With ToolButton2
			.Name = "ToolButton2"
			.Caption = "ToolButton2"
			.Parent = @ToolBar1
		End With
	End Constructor
	
	Dim Shared fForm1 As Form1
	
	#ifndef _NOT_AUTORUN_FORMS_
		fForm1.Show
		
		App.Run
	#endif
'#End Region

Private Sub Form1.MenuItem2_Click_(ByRef Sender As MenuItem)
	*Cast(Form1 Ptr, Sender.Designer).MenuItem2_Click(Sender)
End Sub
Private Sub Form1.MenuItem2_Click(ByRef Sender As MenuItem)

End Sub

Private Sub Form1.MenuItem1_Click_(ByRef Sender As MenuItem)
	*Cast(Form1 Ptr, Sender.Designer).MenuItem1_Click(Sender)
End Sub
Private Sub Form1.MenuItem1_Click(ByRef Sender As MenuItem)

End Sub

Private Sub Form1.MenuItem3_Click_(ByRef Sender As MenuItem)
	*Cast(Form1 Ptr, Sender.Designer).MenuItem3_Click(Sender)
End Sub
Private Sub Form1.MenuItem3_Click(ByRef Sender As MenuItem)

End Sub
