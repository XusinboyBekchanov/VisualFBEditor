' MDINotepad frmFileSearch.frm
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "FileSearch.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/ComboBoxEx.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/Label.bi"
	#include once "mff/Splitter.bi"
	
	#include once "TimeMeter.bi"
	#include once "FileSearch.bi"
	#include once "ITL3.bi"
	#include once "Text.bi"
	
	Using My.Sys.Forms
	
	Type frmFileSearchType Extends Form
		Dim ffs As FilesSearch
		Dim it3 As ITL3
		Dim tmrFind As TimeMeter
		Dim tmrSearch As TimeMeter
		Dim tmrOther As TimeMeter
		
		Declare Function zFile2ComboEx Overload (ByRef Sender As ComboBoxEx, Path As Const WString, File As Const WString) As Integer
		Declare Function zFile2ComboEx Overload (ByRef Sender As ComboBoxEx, Path As Const WString) As Integer
		Declare Sub zOnFindDone(Owner As Any Ptr)
		
		Declare Sub cmbexPath_DblClick(ByRef Sender As Control)
		Declare Sub cmdFile_Click(ByRef Sender As Control)
		Declare Sub cmdSearch_Click(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub txtFile_Click(ByRef Sender As Control)
		Declare Sub txtFile_DblClick(ByRef Sender As Control)
		Declare Sub txtFile_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub txtFile_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub txtSearch_Change(ByRef Sender As TextBox)
		Declare Constructor
		
		Dim As Panel Panel1, Panel3, Panel5, Panel4
		Dim As CommandButton cmdSearch, cmdFileOpen, cmdFileFolder, cmdFileNotepad, cmdFileDelete
		#ifdef __MDI__
			Dim As CommandButton cmdFileNew, cmdFileInstAll, cmdFileInstSel, cmdFileInstrCur
		#endif
		Dim As ComboBoxEx cmbexPath, cmbexExt
		Dim As TextBox txtFile, txtSelect, txtSearch
		Dim As StatusBar StatusBar1
		Dim As StatusPanel StatusPanel1
		Dim As FolderBrowserDialog FolderBrowserDialog1
		Dim As ImageList ImageList1
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As OpenFileDialog OpenFileDialog1
		Dim As Splitter Splitter1
	End Type
	
	Constructor frmFileSearchType
		' frmFileSearch
		With This
			.Name = "frmFileSearch"
			.Text = "File Search"
			.Designer = @This
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "\FileSearch.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = "VFBE File Search64"
			#else
				'...instructions for other OSes
				.Caption = "VFBE File Search32"
			#endif
			.StartPosition = FormStartPosition.CenterParent
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 640, 480
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.SetBounds 0, 0, 514, 22
			.Designer = @This
			.Parent = @This
		End With
		' cmdSearch
		With cmdSearch
			.Name = "cmdSearch"
			.Text = "Search"
			.TabIndex = 1
			.Align = DockStyle.alLeft
			.Caption = "Search"
			.SetBounds 0, 0, 100, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdSearch_Click)
			.Parent = @Panel1
		End With
		' cmbexPath
		With cmbexPath
			.Name = "cmbexPath"
			.Text = ""
			.TabIndex = 2
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.Style = ComboBoxEditStyle.cbDropDown
			.ImagesList = @ImageList1
			.ControlIndex = 1
			.SetBounds 110, 0, 354, 22
			.Designer = @This
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmbexPath_DblClick)
			.Parent = @Panel1
		End With
		' cmbexExt
		With cmbexExt
			.Name = "cmbexExt"
			.Text = ""
			.TabIndex = 3
			.Align = DockStyle.alRight
			.Style = ComboBoxEditStyle.cbDropDown
			.ImagesList = @ImageList1
			.ControlIndex = 2
			.SetBounds 474, 0, 130, 22
			.Designer = @This
			.Parent = @Panel1
		End With
		' txtFile
		With txtFile
			.Name = "txtFile"
			.Text = ""
			.TabIndex = 6
			.Align = DockStyle.alTop
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.ControlIndex = 3
			.AllowDrop = True
			.MaxLength = -1
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.SetBounds 10, 42, 604, 166
			.Designer = @This
			.OnKeyUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer), @txtFile_KeyUp)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @txtFile_Click)
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @txtFile_DropFile)
			.OnDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @txtFile_DblClick)
			.Parent = @This
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.Align = SplitterAlignmentConstants.alTop
			.SetBounds 0, 32, 624, 3
			.Designer = @This
			.Parent = @This
		End With
		' Panel3
		With Panel3
			.Name = "Panel3"
			.Text = "Panel3"
			.TabIndex = 7
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.SetBounds 0, 221, 624, 220
			.Designer = @This
			.Parent = @This
		End With
		' Panel4
		With Panel4
			.Name = "Panel4"
			.Text = "Panel4"
			.TabIndex = 16
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 520, 198
			.Designer = @This
			.Parent = @Panel3
		End With
		' txtSearch
		With txtSearch
			.Name = "txtSearch"
			.Text = ""
			.TabIndex = 17
			.Align = DockStyle.alTop
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.Hint = "Search"
			.SetBounds 10, 0, 494, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @txtSearch_Change)
			.Parent = @Panel4
		End With
		' txtSelect
		With txtSelect
			.Name = "txtSelect"
			.Text = ""
			.TabIndex = 8
			.Align = DockStyle.alClient
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.ControlIndex = 1
			.ExtraMargins.Top = 10
			.MaxLength = -1
			.SetBounds 10, 30, 494, 158
			.Designer = @This
			.OnKeyUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer), @txtFile_KeyUp)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @txtFile_Click)
			.Parent = @Panel4
		End With
		' Panel5
		With Panel5
			.Name = "Panel5"
			.Text = "Panel4"
			.TabIndex = 9
			.Align = DockStyle.alRight
			.ExtraMargins.Right = 10
			.SetBounds 520, 0, 100, 198
			.Designer = @This
			.Parent = @Panel3
		End With
		' cmdFileOpen
		With cmdFileOpen
			.Name = "cmdFileOpen"
			.Text = "Open"
			.TabIndex = 10
			.Caption = "Open"
			.SetBounds 0, -1, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
			.Parent = @Panel5
		End With
		' cmdFileFolder
		With cmdFileFolder
			.Name = "cmdFileFolder"
			.Text = "Folder"
			.TabIndex = 11
			.Caption = "Folder"
			.SetBounds 0, 19, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
			.Parent = @Panel5
		End With
		' cmdFileNotepad
		With cmdFileNotepad
			.Name = "cmdFileNotepad"
			.Text = "Notepad"
			.TabIndex = 12
			.Caption = "Notepad"
			.SetBounds 0, 39, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
			.Parent = @Panel5
		End With
		' cmdFileDelete
		With cmdFileDelete
			.Name = "cmdFileDelete"
			.Text = "Delete"
			.TabIndex = 13
			.Caption = "Delete"
			.SetBounds 0, 59, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
			.Parent = @Panel5
		End With
		#ifdef __MDI__
			' cmdFileNew
			With cmdFileNew
				.Name = "cmdFileNew"
				.Text = "New Open"
				.TabIndex = 14
				.Caption = "New Open"
				.Enabled = True
				.SetBounds 0, 100, 100, 20
				.Designer = @This
				.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
				.Parent = @Panel5
			End With
			' cmdFileInstAll
			With cmdFileInstAll
				.Name = "cmdFileInstAll"
				.Text = "Insert All"
				.TabIndex = 15
				.Caption = "Insert All"
				.Location = Type<My.Sys.Drawing.Point>(0, 130)
				.SetBounds 0, 130, 100, 20
				.Designer = @This
				.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
				.Parent = @Panel5
			End With
			' cmdFileInstSel
			With cmdFileInstSel
				.Name = "cmdFileInstSel"
				.Text = "Insert Select"
				.TabIndex = 16
				.Caption = "Insert Select"
				.Location = Type<My.Sys.Drawing.Point>(0, 150)
				.SetBounds 0, 150, 100, 20
				.Designer = @This
				.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
				.Parent = @Panel5
			End With
			' cmdFileInstrCur
			With cmdFileInstrCur
				.Name = "cmdFileInstrCur"
				.Text = "Insert Current"
				.TabIndex = 18
				.Location = Type<My.Sys.Drawing.Point>(0, 170)
				.Caption = "Insert Current"
				.SetBounds 0, 170, 100, 20
				.Designer = @This
				.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdFile_Click)
				.Parent = @Panel5
			End With
		#endif
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = ""
			.Align = DockStyle.alBottom
			.SetBounds 0, 158, 624, 22
			.Designer = @This
			.Parent = @Panel3
		End With
		' StatusPanel1
		With StatusPanel1
			.Name = "StatusPanel1"
			.Designer = @This
			.Caption = "Status"
			.Parent = @StatusBar1
		End With
		' FolderBrowserDialog1
		With FolderBrowserDialog1
			.Name = "FolderBrowserDialog1"
			.SetBounds 40, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 60, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 999
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @Panel1
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.Interval = 999
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @Panel4
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.Filter = "All Files (*.*)|*.*"
			.SetBounds 20, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared frmFileSearch As frmFileSearchType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmFileSearch.MainForm = True
		frmFileSearch.Show
		App.Run
	#endif
'#End Region

Private Function frmFileSearchType.zFile2ComboEx(ByRef Sender As ComboBoxEx, Path As Const WString) As Integer
	Dim i As Integer = Sender.IndexOf("" + Path)
	If i < 0 Then
		Dim FileInfo As SHFILEINFO
		SHGetFileInfo(Path, FILE_ATTRIBUTE_NORMAL Or FILE_ATTRIBUTE_DEVICE Or FILE_ATTRIBUTE_DIRECTORY, @FileInfo, SizeOf(FileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX)
		Sender.Items.Add("" + Path, , FileInfo.iIcon, FileInfo.iIcon, FileInfo.iIcon)
		i = Sender.IndexOf(""+Path)
	End If
	Return i
End Function

Private Function frmFileSearchType.zFile2ComboEx(ByRef Sender As ComboBoxEx, Path As Const WString, File As Const WString) As Integer
	Dim i As Integer = Sender.IndexOf("" + File)
	If i < 0 Then
		Dim FileInfo As SHFILEINFO
		If Path = "" Then
			SHGetFileInfo("" + File, FILE_ATTRIBUTE_NORMAL, @FileInfo, SizeOf(FileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX)
		Else
			SHGetFileInfo(Path + "\" + File, FILE_ATTRIBUTE_NORMAL, @FileInfo, SizeOf(FileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX)
		End If
		Sender.Items.Add("" + File, , FileInfo.iIcon, FileInfo.iIcon, FileInfo.iIcon)
		i = Sender.IndexOf("" + File)
	End If
	Return i
End Function

Private Sub frmFileSearchType.zOnFindDone(Owner As Any Ptr)
	txtFile.Text = ffs.Files(vbCrLf)
	it3.SetState(TBPF_NOPROGRESS)
	TimerComponent1.Enabled = False
	cmdSearch.Text = "Search"
	
	TimerComponent1_Timer(TimerComponent1)
	TimerComponent1_Timer(TimerComponent2)
End Sub

Private Sub frmFileSearchType.Form_Create(ByRef Sender As Control)
	'初始化ITaskbarList3
	it3.Initial Handle
	
	'加载文件图标到imagelist1
	Dim FileInfo As SHFILEINFO
	ImageList1.Handle = Cast(Any Ptr, SHGetFileInfo("", 0, @FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX Or SHGFI_ICON Or SHGFI_SMALLICON Or SHGFI_LARGEICON Or SHGFI_PIDL Or SHGFI_DISPLAYNAME Or SHGFI_TYPENAME Or SHGFI_ATTRIBUTES))
	
	Dim i As Integer
	Dim d As String * MAX_PATH
	Dim n As WString * MAX_PATH
	Dim lpVolumeNameBuffer As WString * MAX_PATH
	Dim lpVolumeSerialNumber As DWORD
	Dim lpFileSystemNameBuffer As WString * MAX_PATH
	
	cmbexPath.Clear
	GetLogicalDriveStrings MAX_PATH, Cast(WString Ptr, @d)
	For i = 65 To 90
		If InStr(d ,Chr(i)) Then
			n = Chr(i) & ":"
			GetVolumeInformation @n, @lpVolumeNameBuffer, MAX_PATH, @lpVolumeSerialNumber, 0, 0, @lpFileSystemNameBuffer, MAX_PATH
			SHGetFileInfo(Chr(i) + ":", FILE_ATTRIBUTE_NORMAL, @FileInfo, SizeOf(FileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX)
			zFile2ComboEx(cmbexPath, Chr(i) + ":")
			'ComboBoxEx9.Items.Add(Chr(i) + ":", , FileInfo.iIcon, FileInfo.iIcon, FileInfo.iIcon)
			'lpVolumeNameBuffer & "|"  & lpVolumeSerialNumber & "|"  & lpFileSystemNameBuffer
		End If
	Next
	
	Dim aa() As WString Ptr
	ReDim aa(cmbexPath.ItemCount - 1)
	For i = 0 To cmbexPath.ItemCount - 1
		WLet(aa(i), cmbexPath.Item(i))
	Next
	Dim p As WString Ptr
	JoinWStr(aa(), ";", p)
	zFile2ComboEx(cmbexPath, *p)
	zFile2ComboEx(cmbexPath, ExePath)
	cmbexPath.ItemIndex = cmbexPath.ItemCount - 1
	
	cmbexExt.Clear
	Dim a As String = ".txt|.ini|.log|.txt;.ini;.log|.bas|.bi|.frm|.cls|.vbp|.bas;.bi;.frm;.cls;.vbp|.bat|.cmd|.vbs|.bat;.cmd;.vbs|.c|.cpp|.h|.c;.cpp;.h|.*"
	Dim j As Integer = SplitWStr(a, "|", aa())
	For i = 0 To j
		zFile2ComboEx(cmbexExt, "", *aa(i))
	Next
	cmbexExt.ItemIndex = j
	ArrayDeallocate(aa())
	If p Then Deallocate(p)
	StatusPanel1.Caption = Format(Now(), "yyyy/mm/dd hh:mm:ss")
End Sub

Private Sub frmFileSearchType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Dim st As String
	Select Case Sender.Name
	Case "TimerComponent1"
		st = "File count " & Format(ffs.FileCount + 1, "#,#0") & ", File size " & Bytes2Str(ffs.FileSize) & " (" & Format(ffs.FileSize, "#,#0") & ")"
		StatusPanel1.Caption = st & ", Take (" & Format(tmrSearch.Passed, "#,#0.000") & " sec.) " & Sec2Time(tmrSearch.Passed, , , "#00.000")
	Case "TimerComponent2"
		tmrFind.Start
		TimerComponent2.Enabled = False
		If txtSearch.Text = "" Then Exit Sub
		Dim srs As WString Ptr
		Dim As Integer fc = FindLinesWStr(txtFile.Text, txtSearch.Text, srs, False)
		If fc < 0 Then
			txtSelect.Text = ""
			st = "[" & txtSearch.Text & "] Not found."
		Else
			txtSelect.Text = *srs
			st = "[" & txtSearch.Text & "] Found: " & fc + 1 & " of " & txtFile.LinesCount
		End If
		Deallocate(srs)
		StatusPanel1.Caption = st & ", Take (" & Format(tmrFind.Passed, "#,#0.000") & " sec.) " & Sec2Time(tmrFind.Passed, , , "#00.000")
	End Select
End Sub

Private Sub frmFileSearchType.cmdSearch_Click(ByRef Sender As Control)
	Select Case Sender.Text
	Case "Search"
		tmrSearch.Start
		it3.SetState(TBPF_INDETERMINATE)
		Dim a As WString Ptr
		'ReplaceWStr(cmbexExt.Text, a, ".", "*.")
		
		WLet(a, .Replace(cmbexExt.Text, ".", "*."))
		TimerComponent1.Enabled = True
		ffs.OnFindDone = Cast(Sub(Owner As Any Ptr), @zOnFindDone)
		ffs.FindFile(@This, cmbexPath.Text, *a, True)
		If a Then Deallocate(a)
		Sender.Text = "Cancel"
	Case "Cancel"
		ffs.Cancel = True
	End Select
End Sub

Private Sub frmFileSearchType.cmbexPath_DblClick(ByRef Sender As Control)
	Dim p As WString Ptr
	Dim i As Integer
	
	If FolderBrowserDialog1.Execute Then
		WLet(p, FolderBrowserDialog1.Directory)
		If ..Mid(*p, Len(*p), 1) = WStr("\") Then
			i = zFile2ComboEx(cmbexPath, ..Left(*p, Len(*p) - 1))
		Else
			i = zFile2ComboEx(cmbexPath, *p)
		End If
		cmbexPath.ItemIndex = i
		Deallocate(p)
	End If
End Sub

Private Sub frmFileSearchType.cmdFile_Click(ByRef Sender As Control)
	
	tmrOther.Start
	Dim As Integer sx, sy, ex, ey
	txtSelect.GetSel(sy, sx, ey, ex)
	
	Dim st As String = Sender.Name
	Select Case st
	Case "cmdFileOpen"
		st = "Open = " & ShellExecute (Handle, "open", txtSelect.Lines(sy), "", "", 1)
	Case "cmdFileFolder"
		st = "Folder = " & Exec ("c:\windows\explorer.exe" , "/select," & txtSelect.Lines(sy))
	Case "cmdFileNotepad"
		st = "Notepad = " & Exec ("c:\windows\notepad.exe" , txtSelect.Lines(sy))
	Case "cmdFileDelete"
		If MsgBox("Delete file?" + vbCrLf + txtSelect.Lines(sy), "Delete File Confirm", mtInfo, btYesNo) = mrYes Then
			If PathFileExists(txtSelect.Lines(sy)) Then
				SetFileAttributes(txtSelect.Lines(sy), FILE_ATTRIBUTE_NORMAL)
				DeleteFile(txtSelect.Lines(sy))
				st = "Delete: " & txtSelect.Lines(sy)
			Else
				st = "Delete not found: " & txtSelect.Lines(sy)
			End If
		Else
			st = "Cancel delete: " & txtSelect.Lines(sy)
		End If
		#ifdef __MDI__
		Case "cmdFileNew"
			If PathFileExists(txtSelect.Lines(sy)) Then
				MDIMain.FileOpen(txtSelect.Lines(sy))
				st = "New: " & txtSelect.Lines(sy)
			Else
				st = "New not found: " & txtSelect.Lines(sy)
			End If
		Case "cmdFileInstAll"
			If MDIMain.actMdiChild Then
				st = "Insert all count: " & txtFile.LinesCount
				MDIMain.MDIChildInsertText(MDIMain.actMdiChild, txtFile.Text)
			Else
				st = "Insert all: NA"
			End If
		Case "cmdFileInstSel"
			If MDIMain.actMdiChild Then
				st = "Insert all count: " & txtSelect.LinesCount
				MDIMain.MDIChildInsertText(MDIMain.actMdiChild, txtSelect.Text)
			Else
				st = "Insert all: NA"
			End If
		Case "cmdFileInstrCur"
			If MDIMain.actMdiChild Then
				st = "Insert Select: " & txtSelect.Lines(sy)
				MDIMain.MDIChildInsertText(MDIMain.actMdiChild, txtSelect.Lines(sy))
			Else
				st = "Insert Select: NA"
			End If
		#endif
	End Select
	StatusPanel1.Caption = st  & ", Take (" & Format(tmrOther.Passed, "#,#0.000") & " sec.) " & Sec2Time(tmrOther.Passed, , , "#00.000")
End Sub

Private Sub frmFileSearchType.txtFile_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim As Integer sx, sy, ex, ey
	Dim As Integer s, e
	Dim As String st
	
	Dim txtbox As TextBox Ptr = Cast(TextBox Ptr, VarPtr(Sender))
	txtbox->GetSel(sy, sx, ey, ex)
	txtbox->GetSel(s, e)
	
	If s <> e Then
		Dim i As Integer
		Dim a() As WString Ptr
		Dim c As WString Ptr
		Dim j As Integer = ey - sy
		ReDim a(j)
		For i = sy To ey
			WLet(a(i - sy), txtbox->Lines(i))
		Next
		JoinWStr(a(), vbCrLf, c)
		If txtbox->Name = "txtFile" Then txtSelect.Text = *c
		ArrayDeallocate(a())
		If c Then Deallocate(c)
		st = "Selected lines: " & ey - sy + 1 & " of " & txtbox->LinesCount
	Else
		If txtbox->Name = "txtFile" Then txtSelect.Text = txtbox->Lines(sy)
		st = "Selected file: " & txtbox->Lines(sy) & ", " & sy + 1 & " of " & txtbox->LinesCount
	End If
	StatusPanel1.Caption = st
End Sub

Private Sub frmFileSearchType.txtFile_Click(ByRef Sender As Control)
	txtFile_KeyUp(Sender, 0, 0)
End Sub

Private Sub frmFileSearchType.txtSearch_Change(ByRef Sender As TextBox)
	TimerComponent2.Enabled = False
	If txtSearch.Text = "" Then Exit Sub
	TimerComponent2.Enabled = True
End Sub

Private Sub frmFileSearchType.txtFile_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	Dim As Integer fe= -1, nl = -1, cp = -1
	Dim p As WString Ptr
	TextFromFile(Filename, p, fe, nl, cp)
	txtFile.Text = *p
	If p Then Deallocate(p)
	StatusPanel1.Caption = Filename & ", Encode: " & fe & ", EOL: " & nl & ", CP: " & cp
End Sub

Private Sub frmFileSearchType.txtFile_DblClick(ByRef Sender As Control)
	If OpenFileDialog1.Execute Then
		txtFile_DropFile(Sender, OpenFileDialog1.FileName)
	End If
End Sub

Private Sub frmFileSearchType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	StatusPanel1.Width = ClientWidth
End Sub

Private Sub frmFileSearchType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	txtFile.Text = ""
	txtSelect.Text = ""
	If ffs.mDone Or ffs.mThread = NULL Then Exit Sub
	ffs.Cancel = True
	Action = False
End Sub
