#ifdef __FB_WIN32__
	'#Compile -exx "Form1.rc"
#else
	'#Compile -exx
#endif
'#Region "Form"
	#include once "frmImageManager.bi"
	
	Constructor frmImageManager
		' frmImageManager
		With This
			.Name = "frmImageManager"
			.Text = ML("Image Manager")
			.SetBounds 0, 0, 557, 470
		End With
		' ToolBar1
		With ToolBar1
			.Name = "ToolBar1"
			.Text = "ToolBar1"
			.SetBounds 0, 0, 524, 26
			.Align = DockStyle.alTop
			.Parent = @This
		End With
		' ListView1
		With ListView1
			.Name = "ListView1"
			.Text = "ListView1"
			.TabIndex = 0
			.SetBounds 10, 36, 220, 385
			.Parent = @This
		End With
		' GroupBox1
		With GroupBox1
			.Name = "GroupBox1"
			.Text = ML("Image Preview")
			.TabIndex = 1
			.SetBounds 240, 30, 290, 260
			.Caption = ML("Image Preview")
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fImageManager As frmImageManager
	pfImageManager = @fImageManager
	
'#End Region
