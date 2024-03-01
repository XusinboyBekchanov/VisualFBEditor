' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDIMain.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type MDIChildType Extends Form
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TextBox TextBox1
	End Type
	
	Constructor MDIChildType
		'MDIChild
		With This
			.Name = "MDIChild"
			.Text = "Initial..."
			.Designer = @This
			.FormStyle = FormStyles.fsMDIChild
			.Caption = "Initial..."
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.OnActivate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Activate)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.SetBounds 0, 0, 260, 190
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 0
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 244, 151
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared MDIChild As MDIChildType
	
	#if _MAIN_FILE_ = __FILE__
		MDIChild.MainForm = True
		MDIChild.Show
		App.Run
	#endif
'#End Region

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	Debug.Print "1. Form_Activate " & Hex(@This) & " " & Caption
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_Create(ByRef Sender As Control)
	Debug.Print "2. Form_Create   " & Hex(@This) & " " & Caption
	MDIMain.MDIChildCreate(@This)
End Sub

Private Sub MDIChildType.Form_Show(ByRef Sender As Form)
	Debug.Print "3. Form_Show     " & Hex(@This) & " " & Caption
	MDIMain.MDIChildShow(@This)
End Sub

Private Sub MDIChildType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	Debug.Print "4. Form_Close    " & Hex(@This) & " " & Caption
	MDIMain.MDIChildClose(@This)
End Sub

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	Debug.Print "5. Form_Destroy  " & Hex(@This) & " " & Caption
	MDIMain.MDIChildDestroy(@This)
End Sub

