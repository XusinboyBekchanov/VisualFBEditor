'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "Hash.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/TabControl.bi"
	#include once "mff/ListView.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/Dialogs.bi"
	
	#include once "FileAct.bi"
	#include once "TimeMeter.bi"
	
	Using My.Sys.Forms
	
	Type frmHashType Extends Form
		Dim timr As TimeMeter
		Declare Sub HashFile()
		Declare Sub HashText()
		
		Declare Static Sub _cmdFile_Click(ByRef Sender As Control)
		Declare Sub cmdFile_Click(ByRef Sender As Control)
		Declare Static Sub _cmdHash_Click(ByRef Sender As Control)
		Declare Sub cmdHash_Click(ByRef Sender As Control)
		Declare Static Sub _lvFiles_DropFile(ByRef Sender As Control, ByRef FileName As WString)
		Declare Sub lvFiles_DropFile(ByRef Sender As Control, ByRef FileName As WString)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TabControl TabControl1
		Dim As TabPage tabFile, tabText
		Dim As Panel Panel1, Panel2, Panel3, Panel4, Panel5, Panel6
		Dim As CommandButton cmdFileAdd, cmdFileDelete, cmdFileClear, cmdHashClear, cmdHashAct
		#ifdef __MDI__
			Dim As CommandButton cmdHashInsert
		#endif
		Dim As CheckBox chkTextLine, chkHash1, chkHash2, chkHash3, chkHash4, chkHash5, chkHash6
		Dim As ListView lvFiles
		Dim As TextBox txtText, txtHash
		Dim As ImageList ImageList1
		Dim As OpenFileDialog OpenFileDialog1
	End Type
	
	Constructor frmHashType
		' frmHash
		With This
			.Name = "frmHash"
			.Text = "Hash"
			.Designer = @This
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "Hash.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = "VFBE Hash64"
			#else
				'...instructions for other OSes
				.Caption = "VFBE Hash32"
			#endif
			.StartPosition = FormStartPosition.CenterParent
			.BorderStyle = FormBorderStyle.Sizable
			.MaximizeBox = True
			.MinimizeBox = False
			.OnCreate = @_Form_Create
			.SetBounds 0, 0, 640, 480
		End With
		' TabControl1
		With TabControl1
			.Name = "TabControl1"
			.Text = "TabControl1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SelectedTabIndex = 0
			.ExtraMargins.Right = 8
			.ExtraMargins.Left = 8
			.ExtraMargins.Top = 10
			.SetBounds 10, 10, 594, 191
			.Designer = @This
			.Parent = @This
		End With
		' tabFile
		With tabFile
			.Name = "tabFile"
			.Text = "File"
			.TabIndex = 1
			.Caption = "File"
			.SetBounds 2, 22, 598, 156
			.Designer = @This
			.Parent = @TabControl1
		End With
		' tabText
		With tabText
			.Name = "tabText"
			.Text = "Text"
			.TabIndex = 2
			.Caption = "Text"
			.SetBounds 2, 22, 598, 156
			.Designer = @This
			.Parent = @TabControl1
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 3
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 592, 40
			.Designer = @This
			.Parent = @tabFile
		End With
		' cmdFileAdd
		With cmdFileAdd
			.Name = "cmdFileAdd"
			.Text = "Add"
			.TabIndex = 4
			.Caption = "Add"
			.SetBounds 10, 10, 100, 20
			.Designer = @This
			.OnClick = @_cmdFile_Click
			.Parent = @Panel1
		End With
		' cmdFileDelete
		With cmdFileDelete
			.Name = "cmdFileDelete"
			.Text = "Delete"
			.TabIndex = 5
			.Caption = "Delete"
			.SetBounds 120, 10, 100, 20
			.Designer = @This
			.OnClick = @_cmdFile_Click
			.Parent = @Panel1
		End With
		' cmdFileClear
		With cmdFileClear
			.Name = "cmdFileClear"
			.Text = "Clear"
			.TabIndex = 6
			.Caption = "Clear"
			.SetBounds 230, 10, 100, 20
			.Designer = @This
			.OnClick = @_cmdFile_Click
			.Parent = @Panel1
		End With
		' lvFiles
		With lvFiles
			.Name = "lvFiles"
			.Text = "lvFiles"
			.TabIndex = 7
			.Align = DockStyle.alClient
			.ColumnHeaderHidden = True
			.AllowDrop = True
			.Images = @ImageList1
			.SmallImages = @ImageList1
			.SetBounds 0, 40, 602, 126
			.Designer = @This
			.OnDropFile = @_lvFiles_DropFile
			.Parent = @tabFile
			.Columns.Add("Filename",,570)
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 8
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 592, 40
			.Designer = @This
			.Parent = @tabText
		End With
		' chkTextLine
		With chkTextLine
			.Name = "chkTextLine"
			.Text = "Treat each line as a separate text"
			.TabIndex = 9
			.ControlIndex = 0
			.Caption = "Treat each line as a separate text"
			.Checked = True
			.SetBounds 10, 10, 220, 20
			.Designer = @This
			.Parent = @Panel2
		End With
		' txtText
		With txtText
			.Name = "txtText"
			.Text = "The quick brown fox jumps over the lazy dog"
			.TabIndex = 10
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.HideSelection = False
			.SetBounds 0, 40, 592, 126
			.Designer = @This
			.Parent = @tabText
		End With
		' Panel3
		With Panel3
			.Name = "Panel3"
			.Text = "Panel3"
			.TabIndex = 11
			.Align = DockStyle.alClient
			.SetBounds 0, 201, 604, 210
			.Designer = @This
			.Parent = @This
		End With
		' Panel4
		With Panel4
			.Name = "Panel4"
			.Text = "Panel4"
			.TabIndex = 12
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 594, 40
			.Designer = @This
			.Parent = @Panel3
		End With
		' chkHash1
		With chkHash1
			.Name = "chkHash1"
			.Text = "MD2"
			.TabIndex = 13
			.Caption = "MD2"
			.SetBounds 10, 10, 60, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' chkHash2
		With chkHash2
			.Name = "chkHash2"
			.Text = "MD4"
			.TabIndex = 14
			.Caption = "MD4"
			.SetBounds 70, 10, 60, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' chkHash3
		With chkHash3
			.Name = "chkHash3"
			.Text = "MD5"
			.TabIndex = 15
			.Caption = "MD5"
			.Checked = True
			.SetBounds 130, 10, 60, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' chkHash4
		With chkHash4
			.Name = "chkHash4"
			.Text = "SHA1"
			.TabIndex = 16
			.Caption = "SHA1"
			.Checked = True
			.SetBounds 190, 10, 60, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' chkHash5
		With chkHash5
			.Name = "chkHash5"
			.Text = "SHA256"
			.TabIndex = 17
			.Caption = "SHA256"
			.SetBounds 250, 10, 60, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' chkHash6
		With chkHash6
			.Name = "chkHash6"
			.Text = "SHA512"
			.TabIndex = 18
			.Caption = "SHA512"
			.SetBounds 320, 10, 60, 20
			.Designer = @This
			.Parent = @Panel4
		End With
		' txtHash
		With txtHash
			.Name = "txtHash"
			.Text = ""
			.TabIndex = 19
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.SetBounds 0, 30, 594, 140
			.Designer = @This
			.Parent = @Panel3
		End With
		' Panel5
		With Panel5
			.Name = "Panel5"
			.Text = "Panel5"
			.TabIndex = 20
			.Align = DockStyle.alBottom
			.SetBounds 0, 160, 594, 40
			.Designer = @This
			.Parent = @Panel3
		End With
		' Panel6
		With Panel6
			.Name = "Panel6"
			.Text = "Panel6"
			.TabIndex = 21
			.Align = DockStyle.alRight
			.SetBounds 264, 0, 340, 30
			.Designer = @This
			.Parent = @Panel5
		End With
		#ifdef __MDI__
			' cmdHashInsert
			With cmdHashInsert
				.Name = "cmdHashInsert"
				.Text = "Insert"
				.TabIndex = 22
				.Caption = "Insert"
				.SetBounds 10, 10, 100, 20
				.Designer = @This
				.OnClick = @_cmdHash_Click
				.Parent = @Panel6
			End With
		#endif
		' cmdHashClear
		With cmdHashClear
			.Name = "cmdHashClear"
			.Text = "Clear"
			.TabIndex = 23
			.Caption = "Clear"
			.SetBounds 120, 10, 100, 20
			.Designer = @This
			.OnClick = @_cmdHash_Click
			.Parent = @Panel6
		End With
		' cmdHashAct
		With cmdHashAct
			.Name = "cmdHashAct"
			.Text = "Hash"
			.TabIndex = 24
			.Caption = "Hash"
			.SetBounds 230, 10, 100, 20
			.Designer = @This
			.OnClick = @_cmdHash_Click
			.Parent = @Panel6
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.SetBounds 340, 10, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.MultiSelect = True
			.SetBounds 360, 10, 16, 16
			.Designer = @This
			.Parent = @Panel1
		End With
	End Constructor
	
	Private Sub frmHashType._Form_Create(ByRef Sender As Control)
		*Cast(frmHashType Ptr, Sender.Designer).Form_Create(Sender)
	End Sub
	
	Private Sub frmHashType._lvFiles_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		*Cast(frmHashType Ptr, Sender.Designer).lvFiles_DropFile(Sender, Filename)
	End Sub
	
	Private Sub frmHashType._cmdHash_Click(ByRef Sender As Control)
		*Cast(frmHashType Ptr, Sender.Designer).cmdHash_Click(Sender)
	End Sub
	
	Private Sub frmHashType._cmdFile_Click(ByRef Sender As Control)
		*Cast(frmHashType Ptr, Sender.Designer).cmdFile_Click(Sender)
	End Sub
	
	Dim Shared frmHash As frmHashType
	
	#if _MAIN_FILE_ = __FILE__
		frmHash.MainForm = True
		frmHash.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmHashType.Form_Create(ByRef Sender As Control)
	lvFiles.ListItems.Clear
	
	'加载文件图标到imagelist1
	Dim FileInfo As SHFILEINFO
	ImageList1.Handle = Cast(Any Ptr, SHGetFileInfo("", 0, @FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX Or SHGFI_ICON Or SHGFI_SMALLICON Or SHGFI_LARGEICON Or SHGFI_PIDL Or SHGFI_DISPLAYNAME Or SHGFI_TYPENAME Or SHGFI_ATTRIBUTES))
	SendMessage lvFiles.Handle, LVM_SETIMAGELIST, LVSIL_SMALL, Cast(LPARAM, ImageList1.Handle)
	
	TabControl1.SelectedTab = TabControl1.Tab(0)
End Sub

Private Sub frmHashType.cmdFile_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdFileAdd"
		If OpenFileDialog1.Execute Then
			Dim i As Integer
			For i = 0 To OpenFileDialog1.FileNames.Count - 1
				lvFiles_DropFile(Sender, OpenFileDialog1.FileNames.Item(i))
			Next
		End If
	Case "cmdFileDelete"
		If lvFiles.SelectedItem->Index() < 0 Then Exit Sub
		lvFiles.ListItems.Remove(lvFiles.SelectedItem->Index())
	Case "cmdFileClear"
		lvFiles.ListItems.Clear
	End Select
End Sub

Private Sub frmHashType.cmdHash_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdHashAct"
		If TabControl1.SelectedTabIndex = 0 Then
			HashFile()
		Else
			HashText()
		End If
	Case "cmdHashClear"
		txtHash.Clear
	Case "cmdHashInsert"
		#ifdef __MDI__
			If MDIMain.ActMdiChild Then
				MDIMain.MDIChildInsertText(MDIMain.ActMdiChild, txtHash.Text)
			End If
		#endif
	End Select
End Sub

Private Sub frmHashType.lvFiles_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	Dim FileInfo As SHFILEINFO
	SHGetFileInfo(Filename, FILE_ATTRIBUTE_NORMAL, @FileInfo, SizeOf(FileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX)
	lvFiles.ListItems.Add(Filename, FileInfo.iIcon)
End Sub

Private Sub frmHashType.HashFile()
	Dim a() As WString Ptr
	Dim b() As WString Ptr
	Dim d() As WString Ptr
	Dim c As WString Ptr
	Dim m As Any Ptr
	Dim i As Integer
	Dim j As Integer
	Dim k As Integer
	Dim s As Integer
	Dim chk(5) As BOOL
	Dim chkc As Long = 0
	
	chk(0) = chkHash1.Checked
	chk(1) = chkHash2.Checked
	chk(2) = chkHash3.Checked
	chk(3) = chkHash4.Checked
	chk(4) = chkHash5.Checked
	chk(5) = chkHash6.Checked
	
	j = lvFiles.ListItems.Count - 1
	ReDim a(j) As WString Ptr 'for filename
	ReDim b(j) As WString Ptr
	For i = 0 To j
		WStr2Ptr(lvFiles.ListItems.Item(i)->Text(0), a(i))
	Next
	
	For i = 0 To 5
		If chk(i) Then chkc += 1
	Next
	ReDim d(chkc + 1)
	
	Dim ta As Double= 0
	Dim ts As Double
	For i = 0 To j
		k = 0
		If PathFileExists(a(i)) Then
			s = GetFileData(*a(i), m)
			ts = timr.Passed
			WStr2Ptr(*a(i) & "; Size=" & Format(s, "#,#0") & "; Take=" & Format(ts - ta, "#,#0.000") & " sec.", d(k))
			ta = ts
			Dim l As Long
			For l = 0 To 5
				If chk(l) Then
					k += 1
					WStr2Ptr(GetHash(m, s, l), c)
					ts = timr.Passed
					WStr2Ptr(AlgWStr(l) & "=" & *c & "; ; Take=" & Format(ts - ta, "#,#0.000") & " sec.", d(k))
					ta = ts
				End If
			Next
			JoinWStr(d(), vbCrLf, b(i))
		End If
		App.DoEvents()
	Next i
	If m Then Deallocate(m)
	JoinWStr(b(), vbCrLf, c)
	i = txtHash.SelStart
	txtHash.SelText = *c
	txtHash.SelStart = i
	txtHash.SelLength = Len(*c)
	ArrayDeallocate(b())
	ArrayDeallocate(a())
	ArrayDeallocate(d())
	If c Then Deallocate(c)
End Sub

Private Sub frmHashType.HashText()
	Dim a() As WString Ptr
	Dim b() As WString Ptr
	Dim d() As WString Ptr
	Dim c As WString Ptr
	Dim m As Any Ptr
	Dim i As Integer
	Dim j As Integer
	Dim k As Integer
	Dim s As Integer
	Dim chk(5) As BOOL
	Dim chkc As Long = 0
	
	chk(0) = chkHash1.Checked
	chk(1) = chkHash2.Checked
	chk(2) = chkHash3.Checked
	chk(3) = chkHash4.Checked
	chk(4) = chkHash5.Checked
	chk(5) = chkHash6.Checked
	
	If chkTextLine.Checked Then
		j = SplitWStr(txtText.Text, vbCrLf, a())
	Else
		j = 0
		ReDim a(j)
		WStr2Ptr(txtText.Text, a(0))
	End If
	ReDim b(j)
	
	For i = 0 To 5
		If chk(i) Then chkc += 1
	Next
	ReDim d(chkc + 1)
	
	Dim ta As Double= 0
	Dim ts As Double
	For i = 0 To j
		k = 0
		Dim tmp As String = TextUnicode2Ansi(*a(i))
		m = StrPtr(tmp)
		s = Len(tmp)
		ts = timr.Passed
		WStr2Ptr(*a(i) & "; Size=" & Format(s, "#,#0") & "; Take=" & Format(ts - ta, "#,#0.000") & " sec.", d(k))
		ta = ts
		Dim l As Long
		For l = 0 To 5
			If chk(l) Then
				k += 1
				WStr2Ptr(GetHash(m, s, l), c)
				ts = timr.Passed
				WStr2Ptr(AlgWStr(l) & "=" & *c & "; ; Take=" & Format(ts - ta, "#,#0.000") & " sec.", d(k))
				ta = ts
			End If
		Next
		JoinWStr(d(), vbCrLf, b(i))
		App.DoEvents()
	Next i
	JoinWStr(b(), vbCrLf, c)
	i = txtHash.SelStart
	txtHash.SelText = *c
	txtHash.SelStart = i
	txtHash.SelLength = Len(*c)
	ArrayDeallocate(b())
	ArrayDeallocate(a())
	ArrayDeallocate(d())
	If c Then Deallocate(c)
End Sub

