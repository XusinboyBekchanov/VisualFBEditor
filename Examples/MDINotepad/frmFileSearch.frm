'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "FileSearch.rc"
		#endif
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
	
	#include once "TimeMeter.bi"
	#include once "FileAct.bi"
	#include once "ITL3.bi"
	#include once "Text.bi"
	
	Using My.Sys.Forms
	
	Type frmFileSearchType Extends Form
		Dim timr As TimeMeter
		Dim ffs As FilesFind
		Dim it3 As ITL3
		
		Declare Function zFile2ComboEx Overload (ByRef Sender As ComboBoxEx, Path As Const WString, File As Const WString) As Integer
		Declare Function zFile2ComboEx Overload (ByRef Sender As ComboBoxEx, Path As Const WString) As Integer
		Declare Static Sub zOnFindDone(Owner As Any Ptr, ByRef PathCount As Integer, ByRef FileCount As Integer, ByRef FileSize As LongInt)
		
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _cmbexPath_DblClick(ByRef Sender As Control)
		Declare Sub cmbexPath_DblClick(ByRef Sender As Control)
		Declare Static Sub _cmdSearch_Click(ByRef Sender As Control)
		Declare Sub cmdSearch_Click(ByRef Sender As Control)
		Declare Static Sub _cmdFile_Click(ByRef Sender As Control)
		Declare Sub cmdFile_Click(ByRef Sender As Control)
		Declare Static Sub _TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Static Sub _txtFile_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub txtFile_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub _txtFile_Click(ByRef Sender As Control)
		Declare Sub txtFile_Click(ByRef Sender As Control)
		Declare Static Sub _txtSearch_Change(ByRef Sender As TextBox)
		Declare Sub txtSearch_Change(ByRef Sender As TextBox)
		Declare Static Sub _txtFile_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub txtFile_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Static Sub _txtFile_DblClick(ByRef Sender As Control)
		Declare Sub txtFile_DblClick(ByRef Sender As Control)
		Declare Static Sub _Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Panel Panel1, Panel3, Panel5, Panel2, Panel4
		Dim As CommandButton cmdSearch, cmdFileOpen, cmdFileFolder, cmdFileNotepad, cmdFileDelete
		#ifdef __MDI__
			Dim As CommandButton cmdFileNew, cmdFileInstAll, cmdFileInstSel
		#endif
		Dim As ComboBoxEx cmbexPath, cmbexExt
		Dim As TextBox txtFile, txtSelect, txtSearch
		Dim As FolderBrowserDialog FolderBrowserDialog1
		Dim As ImageList ImageList1
		Dim As TimerComponent TimerComponent1, TimerComponent2
		Dim As StatusBar StatusBar1
		Dim As OpenFileDialog OpenFileDialog1
	End Type
	
	Constructor frmFileSearchType
		' frmFileSearch
		With This
			.Name = "frmFileSearch"
			.Text = "File Search"
			.Designer = @This
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "FileSearch.ico")
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
			.MinimizeBox = False
			.StartPosition = FormStartPosition.CenterParent
			.OnCreate = @_Form_Create
			.OnClose = @_Form_Close
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
			.OnClick = @_cmdSearch_Click
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
			.SetBounds 110, 0, 244, 22
			.Designer = @This
			.OnDblClick = @_cmbexPath_DblClick
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
			.SetBounds 364, 0, 130, 22
			.Designer = @This
			.Parent = @Panel1
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 4
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.SetBounds 0, 42, 504, 139
			.Designer = @This
			.Parent = @This
		End With
		' txtFile
		With txtFile
			.Name = "txtFile"
			.Text = ""
			.TabIndex = 6
			.Align = DockStyle.alClient
			.Multiline = True
			.ID = 1003
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.ControlIndex = 0
			.AllowDrop = True
			.SetBounds 0, 0, 604, 169
			.Designer = @This
			.OnKeyUp = @_txtFile_KeyUp
			.OnClick = @_txtFile_Click
			.OnDropFile = @_txtFile_DropFile
			.OnDblClick = @_txtFile_DblClick
			.Parent = @Panel2
		End With
		' Panel3
		With Panel3
			.Name = "Panel3"
			.Text = "Panel3"
			.TabIndex = 7
			.Align = DockStyle.alBottom
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
			.SetBounds 10, 0, 500, 20
			.Designer = @This
			.OnChange = @_txtSearch_Change
			.Parent = @Panel4
		End With
		' txtSelect
		With txtSelect
			.Name = "txtSelect"
			.Text = ""
			.TabIndex = 8
			.Align = DockStyle.alClient
			.Multiline = True
			.ID = 1002
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.ControlIndex = 1
			.ExtraMargins.Top = 10
			.SetBounds 10, 20, 500, 168
			.Designer = @This
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
			.OnClick = @_cmdFile_Click
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
			.OnClick = @_cmdFile_Click
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
			.OnClick = @_cmdFile_Click
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
			.OnClick = @_cmdFile_Click
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
				.SetBounds 0, 110, 100, 20
				.Designer = @This
				.OnClick = @_cmdFile_Click
				.Parent = @Panel5
			End With
			' cmdFileInstAll
			With cmdFileInstAll
				.Name = "cmdFileInstAll"
				.Text = "Insert All"
				.TabIndex = 15
				.Caption = "Insert All"
				.SetBounds 0, 149, 100, 20
				.Designer = @This
				.OnClick = @_cmdFile_Click
				.Parent = @Panel5
			End With
			' cmdFileInstSel
			With cmdFileInstSel
				.Name = "cmdFileInstSel"
				.Text = "Insert Select"
				.TabIndex = 16
				.Caption = "Insert Select"
				.SetBounds 0, 169, 100, 20
				.Designer = @This
				.OnClick = @_cmdFile_Click
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
		' FolderBrowserDialog1
		With FolderBrowserDialog1
			.Name = "FolderBrowserDialog1"
			.SetBounds 70, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 100, 0, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 1000
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
			.Parent = @Panel1
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.Interval = 999
			.SetBounds 20, 9, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent1_Timer
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
	
	Private Sub frmFileSearchType._Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		*Cast(frmFileSearchType Ptr, Sender.Designer).Form_Close(Sender, Action)
	End Sub
	
	Private Sub frmFileSearchType._txtFile_DblClick(ByRef Sender As Control)
		*Cast(frmFileSearchType Ptr, Sender.Designer).txtFile_DblClick(Sender)
	End Sub
	
	Private Sub frmFileSearchType._txtFile_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		*Cast(frmFileSearchType Ptr, Sender.Designer).txtFile_DropFile(Sender, Filename)
	End Sub
	
	Private Sub frmFileSearchType._txtSearch_Change(ByRef Sender As TextBox)
		*Cast(frmFileSearchType Ptr, Sender.Designer).txtSearch_Change(Sender)
	End Sub
	
	Private Sub frmFileSearchType._txtFile_Click(ByRef Sender As Control)
		*Cast(frmFileSearchType Ptr, Sender.Designer).txtFile_Click(Sender)
	End Sub
	
	Private Sub frmFileSearchType._txtFile_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		*Cast(frmFileSearchType Ptr, Sender.Designer).txtFile_KeyUp(Sender, Key, Shift)
	End Sub
	
	Private Sub frmFileSearchType._TimerComponent1_Timer(ByRef Sender As TimerComponent)
		*Cast(frmFileSearchType Ptr, Sender.Designer).TimerComponent1_Timer(Sender)
	End Sub
	
	Private Sub frmFileSearchType._cmdFile_Click(ByRef Sender As Control)
		*Cast(frmFileSearchType Ptr, Sender.Designer).cmdFile_Click(Sender)
	End Sub
	
	Private Sub frmFileSearchType._cmdSearch_Click(ByRef Sender As Control)
		*Cast(frmFileSearchType Ptr, Sender.Designer).cmdSearch_Click(Sender)
	End Sub
	
	Private Sub frmFileSearchType._cmbexPath_DblClick(ByRef Sender As Control)
		*Cast(frmFileSearchType Ptr, Sender.Designer).cmbexPath_DblClick(Sender)
	End Sub
	
	Private Sub frmFileSearchType._Form_Create(ByRef Sender As Control)
		*Cast(frmFileSearchType Ptr, Sender.Designer).Form_Create(Sender)
	End Sub
	
	Dim Shared frmFileSearch As frmFileSearchType
	
	#if _MAIN_FILE_ = __FILE__
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

Private Sub frmFileSearchType.zOnFindDone(Owner As Any Ptr, ByRef PathCount As Integer, ByRef FileCount As Integer, ByRef FileSize As LongInt)
	Dim a As frmFileSearchType Ptr = Cast(frmFileSearchType Ptr, Owner)
	a->txtFile.Text = a->ffs.Files(vbCrLf)
	a->it3.SetState(TBPF_NOPROGRESS)
	a->TimerComponent1.Enabled = False
	a->cmdSearch.Text = "Search"
	
	a->TimerComponent1_Timer(a->TimerComponent1)
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
		WStr2Ptr(cmbexPath.Item(i), aa(i))
	Next
	Dim p As WString Ptr
	JoinWStr(aa(), ";", p)
	zFile2ComboEx(cmbexPath, *p)
	zFile2ComboEx(cmbexPath, FullName2Path(App.FileName))
	cmbexPath.ItemIndex = cmbexPath.ItemCount - 1
	
	cmbexExt.Clear
	Dim a As String = ".txt|.ini|.log|.txt;.ini;.log|.bas|.bi|.frm|.cls|.vbp|.bas;.bi;.frm;.cls;.vbp|.bat|.cmd|.vbs|.bat;.cmd;.vbs|.c|.cpp|.h|.c;.cpp;.h|.*"
	Dim j As Integer = SplitWStr(a, "|", aa())
	For i = 0 To j
		zFile2ComboEx(cmbexExt, "", *aa(i))
	Next
	cmbexExt.ItemIndex = j
	ArrayDeallocate(aa())
	StatusBar1.Text = Format(Now(), "yyyy/mm/dd hh:mm:ss")
End Sub

Private Sub frmFileSearchType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	Dim st As String
	Select Case Sender.Name
	Case "TimerComponent1"
		st = "File count " & Format(ffs.FileCount, "#,#0") & ", File size " & Number2Str(ffs.FileSize) & " (" & Format(ffs.FileSize, "#,#0") & "), Take (" & Format(timr.Passed, "#,#0.000") & " Sec.) " & Sec2Time(timr.Passed, , , "#00.000")
	Case "TimerComponent2"
		TimerComponent2.Enabled = False
		Dim srs As WString Ptr
		Dim As Integer fc = FindLinesWStr(txtFile.Text, txtSearch.Text, srs)
		If fc Then
			txtSelect.Text = *srs
			st = "[" & txtSearch.Text & "] Found: " & fc
		Else
			txtSelect.Text = ""
			st = "[" & txtSearch.Text & "] Not found."
		End If
	End Select
	StatusBar1.Text = st
End Sub

Private Sub frmFileSearchType.cmdSearch_Click(ByRef Sender As Control)
	Select Case Sender.Text
	Case "Search"
		timr.Start
		ffs.OnFindDone = Cast(Any Ptr, @zOnFindDone)
		it3.SetState(TBPF_INDETERMINATE)
		Dim a As WString Ptr
		ReplaceWStr(cmbexExt.Text, ".", "*.", a)
		TimerComponent1.Enabled = True
		ffs.FindFile(@This, cmbexPath.Text, *a, True)
		If a Then Deallocate(a)
		Sender.Text = "Cancel"
	Case "Cancel"
		ffs.Cancel = True
		Sender.Text = "Search"
	End Select
End Sub

Private Sub frmFileSearchType.cmbexPath_DblClick(ByRef Sender As Control)
	If FolderBrowserDialog1.Execute Then
		Dim i As Integer = zFile2ComboEx(cmbexPath, FolderBrowserDialog1.Directory)
		cmbexPath.ItemIndex = i
	End If
End Sub

Private Sub frmFileSearchType.cmdFile_Click(ByRef Sender As Control)
	
	timr.Start
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
			If MDIMain.ActMdiChild Then
				st = "Insert all count: " & txtSelect.LinesCount
				MDIMain.MDIChildInsertText(MDIMain.ActMdiChild, txtSelect.Text)
			Else
				st = "Insert all: NA"
			End If
		Case "cmdFileInstSel"
			If MDIMain.ActMdiChild Then
				st = "Insert Select: " & txtSelect.Lines(sy)
				MDIMain.MDIChildInsertText(MDIMain.ActMdiChild, txtSelect.Lines(sy))
			Else
				st = "Insert Select: NA"
			End If
		#endif
	End Select
	StatusBar1.Text = st
End Sub

Private Sub frmFileSearchType.txtFile_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim As Integer sx, sy, ex, ey
	Dim As Integer s, e
	Dim As String st
	
	txtFile.GetSel(sy, sx, ey, ex)
	txtFile.GetSel(s, e)
	
	If s <> e Then
		Dim i As Integer
		Dim a() As WString Ptr
		Dim c As WString Ptr
		Dim j As Integer = ey - sy
		ReDim a(j)
		For i = sy To ey
			WStr2Ptr(txtFile.Lines(i), a(i - sy))
		Next
		JoinWStr(a(), vbCrLf, c)
		txtSelect.Text = *c
		ArrayDeallocate(a())
		If c Then Deallocate(c)
		st = "Lines: " & ey - sy
	Else
		txtSelect.Text = txtFile.Lines(sy)
		st = "File: " & txtFile.Lines(sy)
	End If
	StatusBar1.Text = st
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
	txtFile.Text = TextFromFile(Filename, fe, nl, cp)
	StatusBar1.Text = Filename & ", Encode: " & fe & ", EOL: " & nl & ", CP: " & cp
End Sub

Private Sub frmFileSearchType.txtFile_DblClick(ByRef Sender As Control)
	If OpenFileDialog1.Execute Then
		txtFile_DropFile(Sender, OpenFileDialog1.FileName)
	End If
End Sub

Private Sub frmFileSearchType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	txtFile.Text = ""
	txtSelect.Text = ""
End Sub

