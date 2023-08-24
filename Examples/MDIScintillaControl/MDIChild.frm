'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "ScintillaControl.bi"
	
	Using My.Sys.Forms
	
	Type MDIChildType Extends Form
		'Dim Sci As Scintilla
		
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
		
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Sci_Modify(ByRef Sender As ScintillaControl)
		Declare Sub Sci_Update(ByRef Sender As ScintillaControl)
		Declare Sub Sci_DblClick(ByRef Sender As ScintillaControl)
		Declare Constructor
		
		Dim As ScintillaControl Sci
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
			.SetBounds 0, 0, 640, 480
		End With
		' Sci
		With Sci
			.Name = "Sci"
			.Text = "ScintillaControl1"
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 624, 441
			.Designer = @This
			.OnModify = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Sci_Modify)
			.OnUpdate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Sci_Update)
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Sci_DblClick)
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
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Sci_Modify(ByRef Sender As ScintillaControl)
	Changed = True
End Sub

Private Sub MDIChildType.Sci_Update(ByRef Sender As ScintillaControl)
	MDIMain.MDIChildClick(@This)
End Sub

Private Sub MDIChildType.Sci_DblClick(ByRef Sender As ScintillaControl)
	MDIMain.MDIChildDoubleClick(@This)
End Sub
