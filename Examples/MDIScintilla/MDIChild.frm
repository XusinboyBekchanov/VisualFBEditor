'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
		
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
		Declare Static Sub _Form_Message(ByRef Sender As Control, ByRef MSG As Message)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef MSG As Message)
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
			.OnMessage = @_Form_Message
			.SetBounds 0, 0, 260, 190
		End With
	End Constructor
	
	Private Sub MDIChildType._Form_Message(ByRef Sender As Control, ByRef MSG As Message)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Message(Sender, MSG)
	End Sub
	
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
	
	#if _MAIN_FILE_ = __FILE__
		MDIChild.MainForm = True
		MDIChild.Show
		App.Run
	#endif
'#End Region

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	If hSci Then DestroyWindow(hSci)
	hSci = NULL
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_Create(ByRef Sender As Control)
	' Creates a Scintilla editing window
	Dim rt As Rect
	GetClientRect(Handle, @rt)
	Dim As Integer lExStyle = 0
	Dim As Integer lStyle = WS_CHILD Or WS_VISIBLE Or WS_TABSTOP Or WS_BORDER
	hSci = CreateWindowEx(lExStyle, "Scintilla", 0, lStyle, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, Handle, NULL, 0, 0)
	SendMessage(hSci, SCI_STYLECLEARALL, 0, 0)
End Sub

Private Sub MDIChildType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim rt As Rect
	GetClientRect(Handle, @rt)
	MoveWindow(hSci, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, True)
End Sub

Private Sub MDIChildType.Form_Message(ByRef Sender As Control, ByRef MSG As Message)
	Dim scMsg As SCNotification
	Select Case MSG.Msg
	Case WM_NOTIFY
		CopyMemory(@scMsg, Cast(Any Ptr, MSG.lParam), Len(scMsg))
		If (scMsg.hdr.hwndFrom = hSci) Then
			'Scintilla has given some information. Let's see what it is
			'and route it to the proper place.
			'Any commented with TODO have not been implimented yet.
			Select Case scMsg.hdr.code
			Case SCN_MODIFIED
				Debug.Print "SCN_MODIFIED"
			Case SCN_HOTSPOTCLICK
				Debug.Print "SCN_HOTSPOTCLICK"
			Case SCN_DOUBLECLICK
				Debug.Print "SCN_DOUBLECLICK"
			Case SCN_UPDATEUI
				Debug.Print "SCN_UPDATEUI"
			Case SCN_AUTOCSELECTIONCHANGE
				Debug.Print "SCN_AUTOCSELECTIONCHANGE"
			Case SCN_KEY
				Debug.Print "SCN_KEY"
			Case SCN_PAINTED
				Debug.Print "SCN_PAINTED"
			End Select
		End If
	End Select
End Sub
