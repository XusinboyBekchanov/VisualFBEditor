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
		Dim Sci As Scintilla
		
		Dim Index As Integer = -1
		Dim CodePage As Integer = GetACP()
		Dim Encode As FileEncodings = -1
		Dim mFile As WString Ptr = NULL
		Dim mChanged As Boolean = False
		
		Declare Property Changed(Val As Boolean)
		Declare Property Changed As Boolean
		Declare Property File(ByRef FileName As Const WString)
		Declare Property File ByRef As WString
		Declare Property Title(ByRef TitleName As Const WString)
		
		Declare Property NewLine As NewLineTypes
		Declare Property NewLine(val As NewLineTypes)
		
		Declare Static Sub _Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Static Sub _Form_Activate(ByRef Sender As Form)
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Static Sub _Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Static Sub _Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
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
			.Text = "Initial..."
			.Designer = @This
			.FormStyle = FormStyles.fsMDIChild
			.Caption = "Initial..."
			.OnDestroy = @_Form_Destroy
			.OnActivate = @_Form_Activate
			.AllowDrop = True
			.OnDropFile = @_Form_DropFile
			.OnClose = @_Form_Close
			.OnCreate = @_Form_Create
			.OnResize = @_Form_Resize
			.OnMessage = @_Form_Message
			.SubClass = False
			.SetBounds 0, 0, 640, 480
		End With
	End Constructor
	
	Private Sub MDIChildType._Form_Message(ByRef Sender As Control, ByRef MSG As Message)
		(*Cast(MDIChildType Ptr, Sender.Designer)).Form_Message(Sender, MSG)
	End Sub
	
	Private Sub MDIChildType._Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		(*Cast(MDIChildType Ptr, Sender.Designer)).Form_Resize(Sender, NewWidth, NewHeight)
	End Sub
	
	Private Sub MDIChildType._Form_Create(ByRef Sender As Control)
		(*Cast(MDIChildType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		(*Cast(MDIChildType Ptr, Sender.Designer)).Form_Close(Sender, Action)
	End Sub
	
	Private Sub MDIChildType._Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		(*Cast(MDIChildType Ptr, Sender.Designer)).Form_DropFile(Sender, Filename)
	End Sub
	
	Private Sub MDIChildType._Form_Activate(ByRef Sender As Form)
		(*Cast(MDIChildType Ptr, Sender.Designer)).Form_Activate(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_Destroy(ByRef Sender As Control)
		(*Cast(MDIChildType Ptr, Sender.Designer)).Form_Destroy(Sender)
	End Sub
	
	Dim Shared MDIChild As MDIChildType
	
	#if _MAIN_FILE_ = __FILE__
		MDIChild.MainForm = True
		MDIChild.Show
		App.Run
	#endif
'#End Region

Private Property MDIChildType.Changed(val As Boolean)
	mChanged = val
	
	Dim sHead As WString Ptr
	If mChanged Then
		sHead = @WStr("* ")
	Else
		sHead = @WStr("")
	End If
	If *mFile = "" Then
		Title = *sHead & WStr("Untitled - ") & Index
	Else
		Title = *sHead & FullName2File(*mFile)
	End If
End Property

Private Property MDIChildType.Changed As Boolean
	Return mChanged
End Property

Private Property MDIChildType.Title(ByRef TitleName As Const WString)
	If Text = TitleName Then Exit Property
	Text = "" + TitleName
	MDIMain.MDIChildActivate(@This)
End Property

Private Property MDIChildType.File(ByRef FileName As Const WString)
	WStr2Ptr(FileName, mFile)
	Changed = mChanged
	Dim FileInfo As SHFILEINFO
	Dim h As Any Ptr = Cast(Any Ptr, SHGetFileInfo(*mFile, 0, @FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX))
	SendMessage(Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(h, FileInfo.iIcon, 0)))
End Property

Private Property MDIChildType.File ByRef As WString
	Return *mFile
End Property

Private Property MDIChildType.NewLine As NewLineTypes
	Select Case Sci.EOLMode
	Case SC_EOL_LF
		Return NewLineTypes.LinuxLF
	Case SC_EOL_CR
		Return NewLineTypes.MacOSCR
	Case Else
		Return NewLineTypes.WindowsCRLF
	End Select
End Property

Private Property MDIChildType.NewLine(val As NewLineTypes)
	Select Case val
	Case NewLineTypes.LinuxLF
		Sci.EOLMode= SC_EOL_LF
	Case NewLineTypes.MacOSCR
		Sci.EOLMode= SC_EOL_CR
	Case Else
		Sci.EOLMode= SC_EOL_CRLF
	End Select
End Property

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	'If Encode < 0 Then Encode = FileEncodings.Utf8
	'If NewLine < 0 Then NewLine = NewLineTypes.WindowsCRLF
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	MDIMain.FileInsert(Filename, @This)
End Sub

Private Sub MDIChildType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If MDIMain.MDIChildClose(@This) = MessageResult.mrCancel Then
		Action = False
	Else
		If mFile Then Deallocate mFile
	End If
End Sub

Private Sub MDIChildType.Form_Create(ByRef Sender As Control)
	Sci.Create(Handle)
	
	' Load the lexer from Lexilla and feed it into Scintilla
	Dim As Any Ptr pLexer = pfnCreateLexerfn("MDIChild")
	SendMessage(Sci.Handle, SCI_SETILEXER, 0, Cast(LPARAM, pLexer))
	
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim rt As Rect
	GetClientRect(Handle, @rt)
	MoveWindow(Sci.Handle, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, True)
End Sub

Private Sub MDIChildType.Form_Message(ByRef Sender As Control, ByRef MSG As Message)
	Dim scMsg As SCNotification
	Select Case MSG.Msg
	Case WM_NOTIFY
		CopyMemory(@scMsg, Cast(Any Ptr, MSG.lParam), Len(scMsg))
		If (scMsg.hdr.hwndFrom = Sci.Handle) Then
			'Scintilla has given some information. Let's see what it is
			'and route it to the proper place.
			'Any commented with TODO have not been implimented yet.
			Select Case scMsg.hdr.code
			Case SCN_MODIFIED
				'Debug.Print "SCN_MODIFIED"
				'Debug.Print "modificationType=" & scMsg.modificationType
				Changed = True
			Case SCN_HOTSPOTCLICK
				'Debug.Print "SCN_HOTSPOTCLICK"
			Case SCN_DOUBLECLICK
				'Debug.Print "SCN_DOUBLECLICK"
				MDIMain.MDIChildDoubleClick(@This)
			Case SCN_UPDATEUI
				'Debug.Print "SCN_UPDATEUI"
				'Debug.Print  "updated=" & scMsg.updated
				Select Case scMsg.updated
				Case SC_UPDATE_NONE
				Case SC_UPDATE_CONTENT
					MDIMain.MDIChildClick(@This)
				Case SC_UPDATE_SELECTION
					MDIMain.MDIChildClick(@This)
				Case SC_UPDATE_V_SCROLL
					'line number margin auto width
					If Sci.MarginWidth(0) <> 0 Then
						Dim s As String = Format(SendMessage(Sci.Handle, SCI_GETFIRSTVISIBLELINE, 0, 0) + SendMessage(Sci.Handle, SCI_LINESONSCREEN, 0, 0), "#0")
						Sci.MarginWidth(0) = SendMessage(Sci.Handle, SCI_TEXTWIDTH, STYLE_DEFAULT, Cast(LPARAM, StrPtr(s))) + 5
					End If
				Case SC_UPDATE_H_SCROLL
				End Select
			Case SCN_AUTOCSELECTIONCHANGE
				'Debug.Print "SCN_AUTOCSELECTIONCHANGE"
			Case SCN_KEY
				'Debug.Print "SCN_KEY"
			Case SCN_PAINTED
				'Debug.Print "SCN_PAINTED"
			End Select
		End If
	End Select
End Sub
