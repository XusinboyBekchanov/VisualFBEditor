'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "FileBrowser.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEx.bi"
	#include once "mff/TreeView.bi"
	#include once "mff/ListView.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/Menus.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	
	#include once "../MDINotepad/FileAct.bi"
	#include once "win/shlobj.bi"
	
	Using My.Sys.Forms
	
	Type frmBrowserType Extends Form
		mImageList As ULong
		mRootNode As TreeNode Ptr
		mSelectPath As WString Ptr
		mClosing As Boolean
		mListing As Boolean
		
		Declare Function RootInit() As PTreeNode
		Declare Sub RootList()
		Declare Function FindNode(Path As WString) As TreeNode Ptr
		Declare Sub FileList(ByRef Item As TreeNode, ByVal LV As Boolean = True)
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub TreeView1_NodeClick(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub TreeView1_Click(ByRef Sender As Control)
		Declare Sub TreeView1_NodeDblClick(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub TreeView1_NodeActivate(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub TreeView1_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Sub TreeView1_SelChanging(ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef Cancel As Boolean)
		Declare Sub MenuView_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub ListView1_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub ListView1_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub ListView1_Click(ByRef Sender As Control)
		Declare Sub ListView1_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub MenuFile_Click(ByRef Sender As MenuItem)
		Declare Sub ListView1_ItemDblClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub ComboBoxEx1_KeyPress(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
		Declare Sub ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ComboBoxEx ComboBoxEx1
		Dim As TreeView TreeView1
		Dim As ListView ListView1
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem MenuItem1, MenuItem2, MenuItem3, MenuItem4, MenuItem5, MenuItem6, MenuOpen, MenuBrowser, MenuItem9, MenuNotepad
		Dim As StatusBar StatusBar1
		Dim As StatusPanel StatusPanel1
		Dim As Splitter Splitter1
		Dim As Panel Panel1
		Dim As CommandButton CommandButton1
	End Type
	
	Constructor frmBrowserType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = "english"
			End With
		#endif
		' frmBrowser
		With This
			.Name = "frmBrowser"
			.Text = "File Browser"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.Caption = "File Browser"
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 900, 700
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 3
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 884, 30
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEx1
		With ComboBoxEx1
			.Name = "ComboBoxEx1"
			.Text = ""
			.TabIndex = 0
			.Style = ComboBoxEditStyle.cbDropDown
			.ControlIndex = 0
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.SetBounds 75, 5, 804, 22
			.Designer = @This
			.OnKeyPress = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer), @ComboBoxEx1_KeyPress)
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEx1_Selected)
			.Parent = @Panel1
		End With
		' TreeView1
		With TreeView1
			.Name = "TreeView1"
			.Text = "TreeView1"
			.TabIndex = 1
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 5
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 5
			.ExtraMargins.Bottom = 5
			.SetBounds 5, 32, 200, 602
			.Designer = @This
			'.OnNodeClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode), @TreeView1_NodeClick)
			'.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TreeView1_Click)
			'.OnNodeDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode), @TreeView1_NodeDblClick)
			'.OnNodeActivate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode), @TreeView1_NodeActivate)
			.OnSelChanged = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode), @TreeView1_SelChanged)
			'.OnSelChanging = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef Cancel As Boolean), @TreeView1_SelChanging)
			.Parent = @This
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.SetBounds 195, 27, 5, 612
			.Designer = @This
			.Parent = @This
		End With
		' ListView1
		With ListView1
			.Name = "ListView1"
			.Text = "ListView1"
			.TabIndex = 2
			.Align = DockStyle.alClient
			.MultiSelect = True
			.ExtraMargins.Top = 5
			.ExtraMargins.Right = 5
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 5
			.GridLines = False
			.ContextMenu = @PopupMenu1
			.Anchor.Top = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Bottom = AnchorStyle.asAnchor
			.Sort = SortStyle.ssNone
			.SetBounds 210, 32, 669, 602
			.Designer = @This
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @ListView1_Resize)
			.OnSelectedItemChanged = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer), @ListView1_SelectedItemChanged)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ListView1_Click)
			.OnItemClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer), @ListView1_ItemClick)
			.OnItemDblClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer), @ListView1_ItemDblClick)
			.Parent = @This
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.SetBounds 0, 419, 704, 22
			.Designer = @This
			.Parent = @This
		End With
		' StatusPanel1
		With StatusPanel1
			.Name = "StatusPanel1"
			.Designer = @This
			.Parent = @StatusBar1
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 0, 0, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' MenuOpen
		With MenuOpen
			.Name = "MenuOpen"
			.Designer = @This
			.Caption = "Open"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuFile_Click)
			.Parent = @PopupMenu1
		End With
		' MenuNotepad
		With MenuNotepad
			.Name = "MenuNotepad"
			.Designer = @This
			.Caption = "Notepad"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuFile_Click)
			.Parent = @PopupMenu1
		End With
		' MenuBrowser
		With MenuBrowser
			.Name = "MenuBrowser"
			.Designer = @This
			.Caption = "Browser"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuFile_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem9
		With MenuItem9
			.Name = "MenuItem9"
			.Designer = @This
			.Caption = "-"
			.Parent = @PopupMenu1
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "Icon"
			.Tag = @"0"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuView_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "Detials"
			.Tag = @"1"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuView_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "Small Icon"
			.Tag = @"2"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuView_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Designer = @This
			.Caption = "List"
			.Tag = @"3"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuView_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem5
		With MenuItem5
			.Name = "MenuItem5"
			.Designer = @This
			.Caption = "Title"
			.Tag = @"4"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuView_Click)
			.Parent = @PopupMenu1
		End With
		' MenuItem6
		With MenuItem6
			.Name = "MenuItem6"
			.Designer = @This
			.Caption = "Max"
			.Tag = @"5"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @MenuView_Click)
			.Parent = @PopupMenu1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Up"
			.TabIndex = 4
			.Caption = "Up"
			.SetBounds 5, 5, 60, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared frmBrowser As frmBrowserType
	Debug.Clear
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmBrowser.MainForm = True
		frmBrowser.Show
		App.Run
	#endif
'#End Region

Private Sub frmBrowserType.Form_Show(ByRef Sender As Form)
	'Debug.Print "Form_Show"
End Sub

Private Sub frmBrowserType.TreeView1_NodeDblClick(ByRef Sender As TreeView, ByRef Item As TreeNode)
	'Debug.Print "TreeView1_NodeDblClick"
End Sub

Private Sub frmBrowserType.TreeView1_Click(ByRef Sender As Control)
	'Debug.Print "TreeView1_Click"
End Sub

Private Sub frmBrowserType.TreeView1_NodeClick(ByRef Sender As TreeView, ByRef Item As TreeNode)
	'Debug.Print "TreeView1_NodeClick"
End Sub

Private Sub frmBrowserType.TreeView1_NodeActivate(ByRef Sender As TreeView, ByRef Item As TreeNode)
	'Debug.Print "TreeView1_NodeActivate"
End Sub

Private Sub frmBrowserType.TreeView1_SelChanging(ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef Cancel As Boolean)
	'Debug.Print "TreeView1_SelChanging"
End Sub

Private Sub frmBrowserType.ListView1_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	'Debug.Print "ListView1_Resize"
End Sub

Private Sub frmBrowserType.ListView1_Click(ByRef Sender As Control)
	'Debug.Print "ListView1_Click"
End Sub

Private Sub frmBrowserType.ListView1_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	'Debug.Print "ListView1_SelectedItemChanged" & ItemIndex
End Sub

Private Sub frmBrowserType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	'Debug.Print "Form_Resize"
	With ListView1
		.Columns.Column(0)->Width = .Width - 20 - .Columns.Column(1)->Width - .Columns.Column(2)->Width - .Columns.Column(3)->Width - .Columns.Column(4)->Width
	End With
	StatusPanel1.Width = StatusBar1.Width - 6
End Sub

Private Sub frmBrowserType.Form_Create(ByRef Sender As Control)
	'Debug.Print "Form_Create"
	'init combobox
	ComboBoxEx1.AddItem("F:\OfficePC_Update\VB_FileAction\VB_FileBack4")
	ComboBoxEx1.AddItem("F:\OfficePC_Update\!FB\Examples\FileBrowser")
	ComboBoxEx1.AddItem("F:\OfficePC_Update\!FB\Examples\FileBrowser\FileBrowser.vfp")
	
	'init imagelist
	Dim pFileInfo As SHFILEINFO
	mImageList = SHGetFileInfo("", 0, @pFileInfo, SizeOf(pFileInfo), SHGFI_SYSICONINDEX Or SHGFI_ICON Or SHGFI_SMALLICON Or SHGFI_LARGEICON Or SHGFI_PIDL Or SHGFI_DISPLAYNAME Or SHGFI_TYPENAME Or SHGFI_ATTRIBUTES)
	SendMessage(TreeView1.Handle, TVM_SETIMAGELIST, TVSIL_NORMAL, Cast(LPARAM, mImageList))
	SendMessage(ListView1.Handle, LVM_SETIMAGELIST, LVSIL_NORMAL, Cast(LPARAM, mImageList))
	SendMessage(ListView1.Handle, LVM_SETIMAGELIST, LVSIL_SMALL, Cast(LPARAM, mImageList))
	
	'init columns of listview
	ListView1.Columns.Add("Name", , 150)
	ListView1.Columns.Add("Size", , 100, cfRight)
	ListView1.Columns.Add("Write", , 120)
	ListView1.Columns.Add("Creation", , 120)
	ListView1.Columns.Add("Access", , 120)
	
	'init root of treeview
	mRootNode = RootInit()
	RootList()
	mRootNode->Expand()
End Sub

Private Sub frmBrowserType.TreeView1_SelChanged(ByRef Sender As TreeView, ByRef Item As TreeNode)
	'Debug.Print "TreeView1_SelChanged"
	If mClosing Then Exit Sub
	If mListing Then Exit Sub
	
	mListing = True
	'TreeView1.Enabled = False
	
	WLet(mSelectPath, Item.Name)
	ComboBoxEx1.Text = *mSelectPath
	Item.Nodes.Clear
	ListView1.ListItems.Clear
	
	App.DoEvents()
	
	If *mSelectPath = "" Then
		RootList()
		mRootNode->Expand()
	Else
		FileList(Item)
		Item.Expand()
	End If
	mListing = False
	'TreeView1.Enabled = True
End Sub

Private Function frmBrowserType.RootInit() As PTreeNode
	'Debug.Print "RootInit"
	'my computer
	Dim pIIDL As ITEMIDLIST Ptr
	Dim pFileInfo As SHFILEINFO
	
	Dim pPath As WString * MAX_PATH
	SHGetSpecialFolderLocation(NULL, CSIDL_DRIVES, @pIIDL)
	SHGetPathFromIDList(pIIDL, @pPath)
	SHGetFileInfo(Cast(LPCTSTR, pIIDL), 0, @pFileInfo, Len(pFileInfo), SHGFI_PIDL Or SHGFI_DISPLAYNAME Or SHGFI_SYSICONINDEX Or SHGFI_SMALLICON)
	Return TreeView1.Nodes.Add(pFileInfo.szDisplayName, pPath, pPath, pFileInfo.iIcon, pFileInfo.iIcon)
End Function

Private Sub frmBrowserType.RootList()
	'Debug.Print "RootList"
	'desktop,document,video,music
	Dim pFileInfo As SHFILEINFO
	Dim pIIDL As ITEMIDLIST Ptr
	Dim pPath As WString * MAX_PATH
	Dim pCSIDL(4) As Long = { _
	CSIDL_DESKTOP, _
	CSIDL_PERSONAL, _
	CSIDL_MYMUSIC, _
	CSIDL_MYPICTURES, _
	CSIDL_MYVIDEO _
	}
	Dim i As Integer
	mRootNode->Nodes.Clear
	For i = 0 To 4
		SHGetSpecialFolderLocation(NULL, pCSIDL(i), @pIIDL)
		SHGetPathFromIDList(pIIDL, @pPath)
		SHGetFileInfo(Cast(LPCTSTR, pIIDL), 0, @pFileInfo, Len(pFileInfo), SHGFI_PIDL Or SHGFI_DISPLAYNAME Or SHGFI_SYSICONINDEX Or SHGFI_SMALLICON)
		mRootNode->Nodes.Add(pFileInfo.szDisplayName, pPath, pPath, pFileInfo.iIcon, pFileInfo.iIcon)
	Next
	
	'disks
	Dim pListDrivers As String * MAX_PATH
	Dim pDriver As WString * MAX_PATH
	Dim lpVolumeNameBuffer As WString * MAX_PATH
	Dim lpVolumeSerialNumber As DWORD
	Dim lpFileSystemNameBuffer As WString * MAX_PATH'Ptr
	GetLogicalDriveStrings(MAX_PATH, Cast(WString Ptr, @pListDrivers))
	For i = 65 To 90
		If InStr(pListDrivers, WChr(i)) Then
			pDriver = WChr(i) & ":"
			GetVolumeInformation(pDriver & "\", @lpVolumeNameBuffer, MAX_PATH, @lpVolumeSerialNumber, 0, 0, @lpFileSystemNameBuffer, MAX_PATH)
			SHGetFileInfo(pDriver, FILE_ATTRIBUTE_NORMAL, @pFileInfo, SizeOf(pFileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX)
			mRootNode->Nodes.Add(lpVolumeNameBuffer & " (" & pDriver & ")", pDriver, pDriver, pFileInfo.iIcon, pFileInfo.iIcon)
		End If
	Next
End Sub

Private Function frmBrowserType.FindNode(Path As WString) As TreeNode Ptr
	Dim pSP() As WString Ptr
	Dim i As Integer
	Dim j As Integer
	Dim k As Integer
	Dim l As Integer
	Dim d As Boolean
	Dim n As TreeNodeCollection Ptr = @TreeView1.Nodes.Item(0)->Nodes
	Dim sPath As WString Ptr = NULL
	
	Split(Path, "\", pSP())
	j = UBound(pSP)
	
	For i = 0 To j
		d = False
		l = n->Count - 1
		WLet(sPath, IIf(sPath = NULL, "", *sPath & "\") & *pSP(i))
		'Debug.Print "i - " & i & " - " & *sPath
		'Debug.Print "l - " & l
		'Debug.Print String(10, Asc("="))
		For k = 0 To l
			'Debug.Print "k - " & k & " - " & n->Item(k)->Name
			If n->Item(k)->Name = *sPath Then
				If i = j Then
					TreeView1.SelectedNode = n->Item(k)
				Else
					FileList(*n->Item(k), False)
				End If
				'n->Item(k)->Expand
				n = @n->Item(k)->Nodes
				d = True
				Exit For
			End If
		Next
		If d = False Then Exit For
	Next
	If sPath Then Deallocate(sPath)
	ArrayDeallocate(pSP())
	'Debug.Print i & "," & k & "," & d
	If d Then
		'TreeView1.SelectedNode = n->Item(k)
		'Debug.Print "FindNode: " & n->Item(k)->Name
		Return n->Item(k)
	Else
		Return NULL
	End If
End Function

Private Sub frmBrowserType.FileList(ByRef Item As TreeNode, ByVal LV As Boolean = True)
	'Debug.Print "FileList: " & Item.Name
	Dim pFileInfo As SHFILEINFO
	Dim pPath As WString * MAX_PATH
	Dim pFullName As WString * MAX_PATH
	Dim pWFD As WIN32_FIND_DATA
	Dim hFind As Any Ptr
	Dim hNext As WINBOOL
	Dim i As Integer
	Dim pAdd As Boolean
	
	Dim pPCount As Integer
	Dim pFCount As Integer
	
	hFind = FindFirstFile(Item.Name & "\*.*", @pWFD)
	If hFind <> INVALID_HANDLE_VALUE Then
		Do
			pAdd = True
			If pWFD.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
				If pWFD.cFileName = "." Or pWFD.cFileName = ".." Then
					pAdd = False
				End If
			End If
			If pAdd Then
				pFullName= Item.Name & "\" & pWFD.cFileName
				SHGetFileInfo(pFullName, pWFD.dwFileAttributes, @pFileInfo, SizeOf(pFileInfo), SHGFI_USEFILEATTRIBUTES Or SHGFI_SMALLICON Or SHGFI_SYSICONINDEX Or SHGFI_ICON Or SHGFI_LARGEICON)
				If LV Then
					ListView1.ListItems.Add(pWFD.cFileName, pFileInfo.iIcon)
					i = ListView1.ListItems.Count - 1
					ListView1.ListItems.Item(i)->Text(1) = Format(WFD2Size(@pWFD), "#,#")
					ListView1.ListItems.Item(i)->Text(2) = WFD2TimeStr(pWFD.ftLastWriteTime)
					ListView1.ListItems.Item(i)->Text(3) = WFD2TimeStr(pWFD.ftCreationTime)
					ListView1.ListItems.Item(i)->Text(4) = WFD2TimeStr(pWFD.ftLastAccessTime)
					If pWFD.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
						ListView1.ListItems.Item(i)->Text(1) = "<Dir>"
						pPCount += 1
					Else
						ListView1.ListItems.Item(i)->Text(1) = Format(WFD2Size(@pWFD), "#,#")
						pFCount += 1
					End If
				End If
				If pWFD.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
					Item.Nodes.Add(pWFD.cFileName, pFullName, pFullName, pFileInfo.iIcon, pFileInfo.iIcon)
					pPCount += 1
				Else
					pFCount += 1
				End If
			End If
			hNext = FindNextFile(hFind , @pWFD)
		Loop While (hNext)
		FindClose(hFind)
	End If
	FindClose(hFind)
	StatusPanel1.Caption = "Path count: " & pPCount & ", File Count: " & pFCount
End Sub

Private Sub frmBrowserType.MenuFile_Click(ByRef Sender As MenuItem)
	'Debug.Print "MenuFile_Click"
	Dim pTxt As String
	Dim pFile As String
	Dim i As Integer
	Dim c As Integer
	Dim p As Boolean
	Dim j As Integer = ListView1.ListItems.Count - 1
	For i = 0 To j
		If ListView1.ListItems.Item(i)->Selected Then
			pFile = *mSelectPath & "\" & ListView1.ListItems.Item(i)->Text(0)
			If ListView1.ListItems.Item(i)->Text(1) = "<Dir>" Then p = True
			c += 1
			Exit For
		End If
	Next
	
	Select Case Sender.Name
	Case "MenuOpen"
		If p Then
			'is path
			j = TreeView1.SelectedNode->Nodes.Count - 1
			For i = 0 To j
				If TreeView1.SelectedNode->Nodes.Item(i)->Name = pFile Then
					TreeView1.SelectedNode = TreeView1.SelectedNode->Nodes.Item(i)
					Exit For
				End If
			Next
		Else
			'is file
			pTxt = "Open(" & pFile & ") = " & ShellExecute (Handle, "open", pFile, "", "", 1)
		End If
	Case "MenuNotepad"
		pTxt = "Notepad(" & pFile & ") = " & Exec ("c:\windows\notepad.exe" , pFile)
	Case "MenuBrowser"
		pTxt = "Browser(" & pFile & ") = " & Exec ("c:\windows\explorer.exe" , "/select," & pFile)
	End Select
	StatusPanel1.Caption = pTxt
End Sub

Private Sub frmBrowserType.MenuView_Click(ByRef Sender As MenuItem)
	'Debug.Print "MenuView_Click"
	MenuItem1.Checked = False
	MenuItem1.Checked = False
	MenuItem2.Checked = False
	MenuItem3.Checked = False
	MenuItem4.Checked = False
	MenuItem5.Checked = False
	MenuItem6.Checked = False
	Sender.Checked = True
	ListView1.View = Cast(ViewStyle, CLng(*Cast(WString Ptr, Sender.Tag)))
End Sub

Private Sub frmBrowserType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	'Debug.Print "Form_Close"
	mClosing = True
	App.DoEvents()
	If mSelectPath Then Deallocate(mSelectPath)
	ListView1.ListItems.Clear
	TreeView1.Nodes.Clear
End Sub

Private Sub frmBrowserType.ListView1_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	'Debug.Print "ListView1_ItemClick" & ItemIndex
	Dim i As Integer
	Dim c As Integer
	Dim j As Integer = ListView1.ListItems.Count - 1
	For i = 0 To j
		If ListView1.ListItems.Item(i)->Selected Then
			c += 1
		End If
	Next
	
	If ItemIndex < 0 Then
		StatusPanel1.Caption = j + 1 & " items, " & c & " selected none"
	Else
		StatusPanel1.Caption = j + 1 & " items, " & c & " selected: " & *mSelectPath & "\" & ListView1.ListItems.Item(ItemIndex)->Text(0)
	End If
End Sub

Private Sub frmBrowserType.ListView1_ItemDblClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	'Debug.Print "ListView1_ItemDblClick" & ItemIndex
	MenuFile_Click(MenuOpen)
End Sub

Private Sub frmBrowserType.ComboBoxEx1_KeyPress(ByRef Sender As ComboBoxEdit, Key As Integer, Shift As Integer)
	'Debug.Print "ComboBoxEx1_KeyPress: " & Key & ComboBoxEx1.Text
	If Key <> 13 Then Exit Sub
	FindNode(ComboBoxEx1.Text)
End Sub

Private Sub frmBrowserType.ComboBoxEx1_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	'Debug.Print "ComboBoxEx1_Selected: " & ComboBoxEx1.Item(ItemIndex)
	FindNode(ComboBoxEx1.Item(ItemIndex))
End Sub

Private Sub frmBrowserType.CommandButton1_Click(ByRef Sender As Control)
	'Debug.Print "CommandButton1_Click: " & TreeView1.SelectedNode->ParentNode
	If TreeView1.SelectedNode->ParentNode = NULL Then Exit Sub
	TreeView1.SelectedNode = TreeView1.SelectedNode->ParentNode
End Sub
