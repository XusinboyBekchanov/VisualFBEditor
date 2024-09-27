' MDIScintilla MDIChild.frm
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDIScintilla.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type MDIChildType Extends Form
		Editor As Scintilla
		CodePage As Integer = GetACP()
		Destroied As Boolean
		Encode As FileEncodings = FileEncodings.Utf8BOM
		FileInfo As SHFILEINFO
		IconHandle As Any Ptr
		Index As Integer = -1
		mChanged As Boolean = False
		mFile As WString Ptr = NULL
		mTitle As WString Ptr = NULL
		mTitleTmp As WString Ptr = NULL
		
		'NewLine As NewLineTypes = NewLineTypes.WindowsCRLF
		Declare Property NewLine As NewLineTypes
		Declare Property NewLine(val As NewLineTypes)
		
		Declare Property Changed(Val As Boolean)
		Declare Property Changed As Boolean
		Declare Property File(FileName As WString)
		Declare Property File ByRef As WString
		Declare Property Title() ByRef As WString
		Declare Property TitleFileName() ByRef As WString
		Declare Property TitleFullName() ByRef As WString
		
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Message(ByRef Sender As Control, ByRef MSG As Message)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
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
			.AllowDrop = True
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.OnActivate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Activate)
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnMessage = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message), @Form_Message)
			.SetBounds 0, 0, 640, 480
		End With
	End Constructor
	
	Dim Shared MDIChild As MDIChildType
	
	#if _MAIN_FILE_ = __FILE__
		MDIChild.MainForm = True
		MDIChild.Show
		App.Run
	#endif
'#End Region

Private Property MDIChildType.Changed(val As Boolean)
	mChanged = val
	Text = IIf(mChanged, "* " , "" ) & Title
	MDIMain.MDIChildClick()
End Property

Private Property MDIChildType.Changed As Boolean
	Return mChanged
End Property

Private Property MDIChildType.File(FileName As WString)
	WLet(mFile, FileName)
	Text = IIf(mChanged, "* " , "" ) & Title
	If FileName= "" Then
	Else
		IconHandle = Cast(Any Ptr, SHGetFileInfo(*mFile, 0, @FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX))
		SendMessage(Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(IconHandle, FileInfo.iIcon, 0)))
	End If
End Property

Private Property MDIChildType.File ByRef As WString
	Return *mFile
End Property

Private Property MDIChildType.Title() ByRef As WString
	If *mFile = "" Then
		WLet(mTitle, "Untitled - " & Index)
	Else
		WLet(mTitle, FullName2File(*mFile))
	End If
	Return *mTitle
End Property

Private Property MDIChildType.TitleFileName() ByRef As WString
	WLet(mTitleTmp, IIf(mChanged, "* " , "" ) & Title)
	Return *mTitleTmp
End Property

Private Property MDIChildType.TitleFullName() ByRef As WString
	If *mFile= "" Then
		WLet(mTitleTmp, IIf(mChanged, "* " , "" ) & Title)
	Else
		WLet(mTitleTmp, IIf(mChanged, "* " , "" ) & *mFile)
	End If
	Return *mTitleTmp
End Property

Private Property MDIChildType.NewLine As NewLineTypes
	Select Case Editor.EOLMode
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
		Editor.EOLMode= SC_EOL_LF
	Case NewLineTypes.MacOSCR
		Editor.EOLMode= SC_EOL_CR
	Case Else
		Editor.EOLMode= SC_EOL_CRLF
	End Select
End Property

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	If Encode < 0 Then Encode = FileEncodings.Utf8
	If NewLine < 0 Then NewLine = NewLineTypes.WindowsCRLF
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If MDIMain.MDIChildCloseConfirm(@This) = MessageResult.mrCancel Then Action = False
End Sub

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	If mFile Then Deallocate(mFile)
	If mTitle Then Deallocate(mTitle)
	If mTitleTmp Then Deallocate(mTitleTmp)
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	MDIMain.FileInsert(@This, Filename)
End Sub

Private Sub MDIChildType.Form_Create(ByRef Sender As Control)
	Editor.Create(Handle)
	
	' Load the lexer from Lexilla and feed it into Scintilla
	Dim As Any Ptr pLexer = pfnCreateLexerfn("MDIChild")
	SendMessage(Editor.Handle, SCI_SETILEXER, 0, Cast(LPARAM, pLexer))
	
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_Message(ByRef Sender As Control, ByRef MSG As Message)
	Dim scMsg As SCNotification
	Select Case MSG.Msg
	Case WM_NOTIFY
		CopyMemory(@scMsg, Cast(Any Ptr, MSG.lParam), Len(scMsg))
		If (scMsg.hdr.hwndFrom = Editor.Handle) Then
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
				'MDIMain.MDIChildDoubleClick(@This)
			Case SCN_UPDATEUI
				'Debug.Print "SCN_UPDATEUI"
				'Debug.Print  "updated=" & scMsg.updated
				Select Case scMsg.updated
				Case SC_UPDATE_NONE
				Case SC_UPDATE_CONTENT
					MDIMain.MDIChildClick()
				Case SC_UPDATE_SELECTION
					MDIMain.MDIChildClick()
				Case SC_UPDATE_V_SCROLL
					'line number margin auto width
					If Editor.MarginWidth(0) <> 0 Then
						Dim s As String = Format(SendMessage(Editor.Handle, SCI_GETFIRSTVISIBLELINE, 0, 0) + SendMessage(Editor.Handle, SCI_LINESONSCREEN, 0, 0), "#0")
						Editor.MarginWidth(0) = SendMessage(Editor.Handle, SCI_TEXTWIDTH, STYLE_DEFAULT, Cast(LPARAM, StrPtr(s))) + 5
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

Private Sub MDIChildType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim rt As Rect
	GetClientRect(Handle, @rt)
	MoveWindow(Editor.Handle, 0, 0, rt.Right - rt.Left, rt.Bottom - rt.Top, True)
End Sub


