'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__ __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type MDIChildType Extends Form
		Dim As HWND hSci
		
		Declare Static Sub _Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Static Sub _Form_Activate(ByRef Sender As Form)
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Constructor
		
	End Type
	
	Constructor MDIChildType
		'MDIChild
		With This
			.Name = "MDIChild"
			.Text = "MDIChild"
			.Designer = @This
			.FormStyle = FormStyles.fsMDIChild
			.Caption = "MDIChild"
			.OnDestroy = @_Form_Destroy
			.OnActivate = @_Form_Activate
			.OnCreate = @_Form_Create
			.OnResize = @_Form_Resize
			.SetBounds 0, 0, 260, 190
		End With
	End Constructor
	
	Private Sub MDIChildType._Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Resize(Sender, NewWidth, NewHeight)
	End Sub
	
	Private Sub MDIChildType._Form_Create(ByRef Sender As Control)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Create(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_Activate(ByRef Sender As Form)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Activate(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_Destroy(ByRef Sender As Control)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Destroy(Sender)
	End Sub
	
	Dim Shared MDIChild As MDIChildType
	
	#if __MAIN_FILE__ = __FILE__
		MDIChild.Show
		
		App.Run
	#endif
'#End Region

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_Create(ByRef Sender As Control)
	Dim As Integer i, rx, ry, rw, rh, ext, sci_style, sciID
	rx = 180: ry = 84 : rw = 598 : rh = 390 : ext = &h200 : sciID = 400
	hSci = CreateWindowEx(ext, "Scintilla", "", WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or WS_CLIPCHILDREN, rx, ry, rw, rh, Handle, NULL, 0, 0)
	SendMessage(hSci, SCI_STYLECLEARALL, 0, 1)

	Form_Resize(Sender, 0, 0)
End Sub

Private Sub MDIChildType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim rt As Rect
	GetClientRect(Handle, @rt)
	MoveWindow(hSci, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, True)
End Sub
