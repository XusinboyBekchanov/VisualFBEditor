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
		Dim Index As Integer = -1
		Dim CodePage As Integer = GetACP()
		Dim Encode As FileEncodings = -1 
		Dim NewLine As NewLineTypes = -1 
		Dim mFile As WString Ptr = NULL
		Dim mChanged As Boolean = False
		
		Declare Property Changed(Val As Boolean)
		Declare Property Changed As Boolean
		
		Declare Sub SetFile(ByRef FileName As Const WString)
		
		Declare Static Sub _Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Static Sub _Form_Activate(ByRef Sender As Form)
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Static Sub _Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Static Sub _TextBox1_Change(ByRef Sender As TextBox)
		Declare Sub TextBox1_Change(ByRef Sender As TextBox)
		Declare Static Sub _Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub _TextBox1_Click(ByRef Sender As Control)
		Declare Sub TextBox1_Click(ByRef Sender As Control)
		Declare Static Sub _TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Sub TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Static Sub _TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As TextBox TextBox1
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
			.AllowDrop = True
			.OnDropFile = @_Form_DropFile
			.OnClose = @_Form_Close
			.SetBounds 0, 0, 640, 480
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 0
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.HideSelection = False
			.MaxLength = -1
			.WantTab = true
			.SetBounds 0, 0, 624, 441
			.Designer = @This
			.OnChange = @_TextBox1_Change
			.OnClick = @_TextBox1_Click
			.OnKeyPress = @_TextBox1_KeyPress
			.OnKeyUp = @_TextBox1_KeyUp
			.Parent = @This
		End With
	End Constructor
	
	Private Sub MDIChildType._TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		*Cast(MDIChildType Ptr, Sender.Designer).TextBox1_KeyUp(Sender, Key, Shift)
	End Sub
	
	Private Sub MDIChildType._TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
		*Cast(MDIChildType Ptr, Sender.Designer).TextBox1_KeyPress(Sender, Key)
	End Sub
	
	Private Sub MDIChildType._TextBox1_Click(ByRef Sender As Control)
		*Cast(MDIChildType Ptr, Sender.Designer).TextBox1_Click(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Close(Sender, Action)
	End Sub
	
	Private Sub MDIChildType._TextBox1_Change(ByRef Sender As TextBox)
		*Cast(MDIChildType Ptr, Sender.Designer).TextBox1_Change(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_DropFile(Sender, Filename)
	End Sub
	
	Private Sub MDIChildType._Form_Activate(ByRef Sender As Form)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Activate(Sender)
	End Sub
	
	Private Sub MDIChildType._Form_Destroy(ByRef Sender As Control)
		*Cast(MDIChildType Ptr, Sender.Designer).Form_Destroy(Sender)
	End Sub
	
	'Dim Shared MDIChild As MDIChildType
	'
	'#if __MAIN_FILE__ = __FILE__
	'	MDIChild.Show
	'	
	'	App.Run
	'#endif
'#End Region

Private Sub MDIChildType.SetFile(ByRef FileName As Const WString)
	Text = FullName2File("" + FileName)
	WStr2Ptr("" + FileName, mFile)
End Sub

Private Property MDIChildType.Changed(val As Boolean)
	'If mChanged = val Then Exit Property
	mChanged = val
	
	Dim sHead As WString Ptr
	If mChanged Then
		sHead = @WStr("* ")
	Else
		sHead = @WStr("")
	End If
	If *mFile = "" Then
		Text = *sHead & WStr("Untitled - ") & Index
	Else
		Text = *sHead & FullName2File(*mFile)
	End If
	MDIMain.spFileName.Caption = Text
End Property

Private Property MDIChildType.Changed() As Boolean
	Return mChanged
End Property

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	If Encode < 0 Then Encode = FileEncodings.Utf8
	If NewLine< 0 Then NewLine = NewLineTypes.WindowsCRLF
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	MDIMain.FileInsert(Filename, @This)
End Sub

Private Sub MDIChildType.TextBox1_Change(ByRef Sender As TextBox)
	Changed = True
End Sub

Private Sub MDIChildType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If MDIMain.MDIChildClose(@This) = MessageResult.mrCancel Then 
		Action = False
	End If
End Sub

Private Sub MDIChildType.TextBox1_Click(ByRef Sender As Control)
	MDIMain.MDIChildClick(@This)
End Sub

Private Sub MDIChildType.TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
	TextBox1_Click(Sender)
End Sub

Private Sub MDIChildType.TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	TextBox1_Click(Sender)
End Sub
