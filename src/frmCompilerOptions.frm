'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		'#define __MAIN_FILE__
		'#ifdef __FB_WIN32__
		'#cmdline "Form1.rc"
		'#endif
		'Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmCompilerOptionsType Extends Form
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Constructor
		
		Dim As ListView lvCompilerOptions
		Dim As CommandButton cmdOK, cmdCancel
		Dim As Panel Panel1
	End Type
	
	Constructor frmCompilerOptionsType
		' frmCompilerOptions
		With This
			.Name = "frmCompilerOptions"
			.Text = ML("Compiler Options")
			.Designer = @This
			.ShowCaption = True
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			'.Caption = ML("Compiler Options")
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.SetBounds 0, 0, 350, 420
		End With
		' lvCompilerOptions
		With lvCompilerOptions
			.Name = "lvCompilerOptions"
			.Text = "lvCompilerOptions"
			.TabIndex = 0
			.Align = DockStyle.alClient
			.BorderStyle = BorderStyles.bsClient
			.ColumnHeaderHidden = True
			.GridLines = False
			.CheckBoxes = True
			.SetBounds 0, 0, 334, 361
			.Designer = @This
			.Parent = @This
			.Columns.Add "Option", , 150
			.Columns.Add "Description", , 400
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = "Cancel"
			.TabIndex = 2
			.ControlIndex = 0
			.Caption = "Cancel"
			.Align = DockStyle.alRight
			.SetBounds 256, 0, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdCancel_Click)
			.Parent = @Panel1
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = "OK"
			.TabIndex = 1
			.Caption = "OK"
			.Align = DockStyle.alRight
			.SetBounds 176, 0, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdOK_Click)
			.Parent = @Panel1
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 3
			.Align = DockStyle.alBottom
			.SetBounds 0, 386, 336, 20
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmCompilerOptions As frmCompilerOptionsType
	
	#if _MAIN_FILE_ = __FILE__
		'App.DarkMode = True
		'frmCompilerOptions.MainForm = True
		'frmCompilerOptions.Show
		'App.Run
	#endif
'#End Region

Private Sub frmCompilerOptionsType.Form_Create(ByRef Sender As Control)
	Dim As Integer Fn = FreeFile_
	Dim As WString * 1024 CompilerOptionsFile = ExePath & "\Settings\Others\Compiler options." & App.CurLanguage & ".txt"
	If Dir(CompilerOptionsFile ) = "" Then CompilerOptionsFile = ExePath & "\Settings\Others\Compiler options.txt"
	If Open(CompilerOptionsFile For Input Encoding "utf8" As #Fn) = 0 Then
		Dim As WString * 1024 Buff
		Dim As Integer Pos1
		lvCompilerOptions.ListItems.Clear
		Do Until EOF(Fn)
			Line Input #Fn, Buff
			Buff = Trim(Buff)
			Pos1 = InStr(Buff, "  ")
			lvCompilerOptions.ListItems.Add .Left(Buff, Pos1 - 1)
			lvCompilerOptions.ListItems.Item(lvCompilerOptions.ListItems.Count - 1)->Text(1) = ML(Trim(Mid(Buff, Pos1)))
		Loop
	Else
		MsgBox ML("Open file failure!") & Chr(13, 10) & CompilerOptionsFile
	End If
	CloseFile_(Fn)
End Sub

Private Sub frmCompilerOptionsType.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmCompilerOptionsType.cmdOK_Click(ByRef Sender As Control)
	ModalResult = ModalResults.OK
	Me.Hide
End Sub

Private Sub frmCompilerOptionsType.Form_Show(ByRef Sender As Form)
	For i As Integer = 0 To lvCompilerOptions.ListItems.Count - 1
		If lvCompilerOptions.ListItems.Item(i)->Checked Then
			lvCompilerOptions.ListItems.Item(i)->Checked = False
		End If
	Next
End Sub
