'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	
	Using My.Sys.Forms
	
	Type Form2Type Extends Form
		Declare Constructor
		
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem MenuItem1, MenuItem2, MenuItem3, MenuItem4, MenuItem5
	End Type
	
	Constructor Form2Type
		' Form2
		With This
			.Name = "Form2"
			.Text = "Form2"
			.Designer = @This
			.SetBounds 0, 0, 350, 300
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 30, 20, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "MenuItem1"
			.Parent = @PopupMenu1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "MenuItem2"
			.Parent = @PopupMenu1
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "MenuItem3"
			.Parent = @PopupMenu1
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Designer = @This
			.Caption = "MenuItem4"
			.Parent = @PopupMenu1
		End With
		' MenuItem5
		With MenuItem5
			.Name = "MenuItem5"
			.Designer = @This
			.Caption = "MenuItem5"
			.Parent = @PopupMenu1
		End With
	End Constructor
	
	Dim Shared Form2 As Form2Type
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		Form2.MainForm = True
		Form2.Show
		App.Run
	#endif
'#End Region
