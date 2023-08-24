'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ListControl.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	
	Using My.Sys.Forms
	
	Type MDIListType Extends Form
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub ListControl1_DblClick(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ListControl ListControl1
	End Type
	
	Constructor MDIListType
		' MDIList
		With This
			.Name = "MDIList"
			.Text = "Select Window"
			.Designer = @This
			.Caption = "Select Window"
			.StartPosition = FormStartPosition.CenterParent
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.BorderStyle = FormBorderStyle.Sizable
			.SetBounds 0, 0, 350, 300
		End With
		' ListControl1
		With ListControl1
			.Name = "ListControl1"
			.Text = "ListControl1"
			.TabIndex = 0
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 10, 10, 314, 238
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ListControl1_DblClick)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared MDIList As MDIListType
	
	#if _MAIN_FILE_ = __FILE__
		MDIList.MainForm = True
		MDIList.Show
		
		App.Run
	#endif
'#End Region

Private Sub MDIListType.Form_Create(ByRef Sender As Control)
	ListControl1.Clear
	With MDIMain
		If .lstMdiChild.Count < 1 Then Exit Sub
		Dim i As Integer
		For i = 0 To .lstMdiChild.Count - 1
			ListControl1.AddItem (Cast(MDIChildType Ptr, .lstMdiChild.Item(i))->Text)
			If .actMdiChild = .lstMdiChild.Item(i) Then ListControl1.ItemIndex = i
		Next
	End With
End Sub

Private Sub MDIListType.ListControl1_DblClick(ByRef Sender As Control)
	If ListControl1.ItemIndex < 0 Then Exit Sub
	ModalResult = ModalResults.OK
	Tag = MDIMain.lstMdiChild.Item(ListControl1.ItemIndex)
	CloseForm
End Sub
