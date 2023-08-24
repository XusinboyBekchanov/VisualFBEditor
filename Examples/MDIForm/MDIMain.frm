'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/List.bi"
	#include once "mff/ToolBar.bi"
	
	Using My.Sys.Forms
	
	Type MDIMainType Extends Form
		Dim lstMdiChild As List
		Dim actMdiChild As Any Ptr
		'Dim actMidChildIdx As Integer
		
		Dim mnuWindowCount As Integer = -1
		Dim mnuWindows(Any) As MenuItem Ptr
		
		Declare Sub MDIChildNew()
		Declare Sub MDIChildActivate(Child As Any Ptr)
		Declare Sub MDIChildDestroy(Child As Any Ptr)
		Declare Sub MDIChildMenuUpdate()
		
		Declare Sub mnuEdit_Click(ByRef Sender As MenuItem)
		Declare Sub mnuFile_Click(ByRef Sender As MenuItem)
		Declare Sub mnuWindow_Click(ByRef Sender As MenuItem)
		Declare Sub mnuView_Click(ByRef Sender As MenuItem)
		Declare Sub mnuHelp_Click(ByRef Sender As MenuItem)
		Declare Sub ToolBar1_ButtonClick(ByRef Sender As ToolBar, ByRef Button As ToolButton)
		Declare Constructor
		
		Dim As MainMenu MainMenu1
		Dim As MenuItem mnuFile, mnuFileNew, mnuFileOpen, mnuFileSave, mnuFileSaveAs, mnuFileBar1, mnuFileBar2, mnuFileSaveAll, mnuFileBar3, mnuFileProperties, mnuFilePrintSetup, mnuFilePrintPreview, mnuFilePrint, mnuFileBar4, mnuFileExit
		Dim As MenuItem mnuEdit, mnuEditUndo, mnuRedo, mnuEditCopy, mnuEditCut, mnuEditPaste, mnuEditBar1, mnuEditDelete, mnuEditBar2, mnuEditSelectAll
		Dim As MenuItem mnuView, mnuViewToolbar, mnuViewStatusBar, mnuViewBar1, mnuViewRefresh
		Dim As MenuItem mnuHelp, mnuHelpAbout
		Dim As MenuItem mnuWindow, mnuWindowCascade, mnuWindowTileHorizontal, mnuWindowTileVertical, mnuWindowArrangeIcons, mnuWindowClose, mnuWindowCloseAll, MenuItem3, mnuViewDarkMode
		Dim As ImageList ImageList1
		Dim As StatusBar StatusBar1
		Dim As ToolBar ToolBar1
		Dim As ToolButton tbFileNew, tbFileOpen, tbFileSave, tbFileSaveAll
	End Type
	
	Constructor MDIMainType
		' MDIMain
		With This
			.Name = "MDIMain"
			.Text = "MDIMain"
			.Designer = @This
			.Menu = @MainMenu1
			.FormStyle = FormStyles.fsMDIForm
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "VisualFBEditor.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			'.WindowState = WindowStates.wsMaximized
			.Caption = "MDIMain"
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 350, 319
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.ImageWidth = 16
			.ImageHeight = 16
			.SetBounds 116, 70, 16, 16
			.Designer = @This
			.Add "New", "New"
			.Add "About", "About"
			.Add "Cut", " Cut"
			.Add "Exit", "Exit"
			.Add "File", "File"
			.Add "Open", "Open"
			.Add "Paste", "Paste"
			.Add "Save", "Save"
			.Add "SaveAll", "SaveAll"
			.Parent = @This
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 81, 69, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuFile
		With mnuFile
			.Name = "mnuFile"
			.Designer = @This
			.Caption = "&File"
			.Parent = @MainMenu1
		End With
		' mnuFileNew
		With mnuFileNew
			.Name = "mnuFileNew"
			.Designer = @This
			.Caption = !"&New\tCtrl+N"
			.ImageKey = "New"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileOpen
		With mnuFileOpen
			.Name = "mnuFileOpen"
			.Designer = @This
			.Caption = !"&Open\tCtrl+O"
			.ImageKey = "Open"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileBar1
		With mnuFileBar1
			.Name = "mnuFileBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileSave
		With mnuFileSave
			.Name = "mnuFileSave"
			.Designer = @This
			.Caption = !"Save\tCtrl+S"
			.ImageKey = "Save"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileSaveAs
		With mnuFileSaveAs
			.Name = "mnuFileSaveAs"
			.Designer = @This
			.Caption = "Save &As..."
			.ImageKey = "SaveAs"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileSaveAll
		With mnuFileSaveAll
			.Name = "mnuFileSaveAll"
			.Designer = @This
			.Caption = "Save A&ll"
			.ImageKey = "SaveAll"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileBar2
		With mnuFileBar2
			.Name = "mnuFileBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileProperties
		With mnuFileProperties
			.Name = "mnuFileProperties"
			.Designer = @This
			.Caption = "Propert&ies"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileBar3
		With mnuFileBar3
			.Name = "mnuFileBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFilePrintSetup
		With mnuFilePrintSetup
			.Name = "mnuFilePrintSetup"
			.Designer = @This
			.Caption = "Print Set&up..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFilePrintPreview
		With mnuFilePrintPreview
			.Name = "mnuFilePrintPreview"
			.Designer = @This
			.Caption = "Print Pre&view"
			.MenuIndex = 11
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFilePrint
		With mnuFilePrint
			.Name = "mnuFilePrint"
			.Designer = @This
			.Caption = !"&Print...\tCtrl+P"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileBar4
		With mnuFileBar4
			.Name = "mnuFileBar4"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileExit
		With mnuFileExit
			.Name = "mnuFileExit"
			.Designer = @This
			.Caption = "E&xit"
			.ImageKey = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuEdit
		With mnuEdit
			.Name = "mnuEdit"
			.Designer = @This
			.Caption = "&Edit"
			.Parent = @MainMenu1
		End With
		' mnuRedo
		With mnuRedo
			.Name = "mnuRedo"
			.Designer = @This
			.Caption = "&Redo"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditUndo
		With mnuEditUndo
			.Name = "mnuEditUndo"
			.Designer = @This
			.Caption = !"&Undo\tCtrl+Z"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditBar1
		With mnuEditBar1
			.Name = "mnuEditBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		With mnuEditCut
			.Name = "mnuEditCut"
			.Designer = @This
			.Caption = !"Cu&t\tCtrl+X"
			.ImageKey = "Cut"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent =  @mnuEdit
		End With
		' mnuEditCopy
		With mnuEditCopy
			.Name = "mnuEditCopy"
			.Designer = @This
			.Caption = !"&Copy\tCtrl+C"
			.ImageKey = "Copy"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditPaste
		With mnuEditPaste
			.Name = "mnuEditPaste"
			.Designer = @This
			.Caption = !"&Paste\tCtrl+V"
			.ImageKey = "Paste"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditDelete
		With mnuEditDelete
			.Name = "mnuEditDelete"
			.Designer = @This
			.Caption = !"Delete\tDel"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditBar2
		With mnuEditBar2
			.Name = "mnuEditBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditSelectAll
		With mnuEditSelectAll
			.Name = "mnuEditSelectAll"
			.Designer = @This
			.Caption = "Select &All"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuView
		With mnuView
			.Name = "mnuView"
			.Designer = @This
			.Caption = "&View"
			.Parent = @MainMenu1
		End With
		With mnuViewToolbar
			.Name = "mnuViewToolbar"
			.Caption = "&Toolbar"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Checked = True
			.Parent = @mnuView
		End With
		With mnuViewStatusBar
			.Name = "mnuViewStatusBar"
			.Caption = "Status &Bar"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Checked = True
			.Parent = @mnuView
		End With
		With mnuViewBar1
			.Name = "mnuViewBar1"
			.Caption = "-"
			.Designer = @This
			.Parent = @mnuView
		End With
		' mnuViewDarkMode
		With mnuViewDarkMode
			.Name = "mnuViewDarkMode"
			.Designer = @This
			.Caption = "Dark Mode"
			.Checked = False
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Parent = @mnuView
		End With
		
		With mnuWindow
			.Name = "mnuWindow"
			.Caption = "&Window"
			.Designer = @This
			.Enabled = False
			.Parent = @MainMenu1
		End With
		With mnuWindowTileHorizontal
			.Name = "mnuWindowTileHorizontal"
			.Caption = "Tile &Horizontal"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		With mnuWindowTileVertical
			.Name = "mnuWindowTileVertical"
			.Caption = "Tile &Vertical"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		With mnuWindowCascade
			.Name = "mnuWindowCascade"
			.Caption = "&Cascade"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		With mnuWindowArrangeIcons
			.Name= "mnuWindowArrangeIcons"
			.Caption = "&Arrange Icons"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuWindow
		End With
		' mnuWindowClose
		With mnuWindowClose
			.Name = "mnuWindowClose"
			.Designer = @This
			.Caption = "Close"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' mnuWindowCloseAll
		With mnuWindowCloseAll
			.Name = "mnuWindowCloseAll"
			.Designer = @This
			.Caption = "Close All"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' mnuHelp
		With mnuHelp
			.Name = "mnuHelp"
			.Designer = @This
			.Caption = "&Help"
			.Parent = @MainMenu1
		End With
		' mnuHelpAbout
		With mnuHelpAbout
			.Name = "mnuHelpAbout"
			.Designer = @This
			.Caption = "About"
			.ImageKey = "About"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuHelp_Click)
			.Parent = @mnuHelp
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.SetBounds 0, 239, 334, 22
			.Designer = @This
			.Parent = @This
		End With
		' ToolBar1
		With ToolBar1
			.Name = "ToolBar1"
			.Text = "ToolBar1"
			.Align = DockStyle.alTop
			.HotImagesList = @ImageList1
			.ImagesList = @ImageList1
			.DisabledImagesList = @ImageList1
			.SetBounds 0, 0, 334, 26
			.Designer = @This
			.OnButtonClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ToolBar, ByRef Button As ToolButton), @ToolBar1_ButtonClick)
			.Parent = @This
		End With
		' tbFileNew
		With tbFileNew
			.Name = "tbFileNew"
			.Designer = @This
			.ImageKey = "New"
			.Parent = @ToolBar1
		End With
		' tbFileOpen
		With tbFileOpen
			.Name = "tbFileOpen"
			.Designer = @This
			.ImageKey = "Open"
			.Parent = @ToolBar1
		End With
		' tbFileSave
		With tbFileSave
			.Name = "tbFileSave"
			.Designer = @This
			.ImageKey = "Save"
			.Parent = @ToolBar1
		End With
		' tbFileSaveAll
		With tbFileSaveAll
			.Name = "tbFileSaveAll"
			.Designer = @This
			.ImageKey = "SaveAll"
			.Parent = @ToolBar1
		End With
	End Constructor
	
	Dim Shared MDIMain As MDIMainType
	
	#if _MAIN_FILE_ = __FILE__
		MDIMain.MainForm = True
		MDIMain.Show
		App.Run
	#endif
'#End Region

#include once "MDIChild.frm"
#include once "MDIList.frm"

Private Sub MDIMainType.mnuFile_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuFileNew"
		MDIChildNew()
	Case "mnuFileExit"
		ModalResult = ModalResults.OK
		CloseForm
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "File"
	End Select
End Sub

Private Sub MDIMainType.mnuEdit_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Sub MDIMainType.mnuView_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuViewToolbar"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		ToolBar1.Visible = Sender.Checked = True
	Case "mnuViewStatusBar"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		StatusBar1.Visible = Sender.Checked = True
	Case "mnuViewDarkMode"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		App.DarkMode = Sender.Checked
		SetDarkMode(Sender.Checked, Sender.Checked)
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "View"
	End Select
	RequestAlign
	InvalidateRect(Handle, NULL, False)
	UpdateWindow(Handle)
End Sub

Private Sub MDIMainType.mnuWindow_Click(ByRef Sender As MenuItem)
	Dim h As HWND
	
	Select Case Sender.Name
	Case "mnuWindowClose"
		h = Cast(HWND, SendMessage(FClient, WM_MDIGETACTIVE, 0, 0))
		If h Then SendMessage(h, WM_CLOSE, 0, 0)
	Case "mnuWindowCloseAll"
		Do
			h = Cast(HWND, SendMessage(FClient, WM_MDIGETACTIVE, 0, 0))
			If h Then SendMessage(h, WM_CLOSE, 0, 0)
		Loop While (h)
	Case "mnuWindowCascade"
		SendMessage FClient, WM_MDICASCADE, 0, 0
	Case "mnuWindowArrangeIcons"
		SendMessage FClient, WM_MDIICONARRANGE, 0, 0
	Case "mnuWindowTileHorizontal"
		SendMessage FClient, WM_MDITILE, MDITILE_HORIZONTAL, 0
	Case "mnuWindowTileVertical"
		SendMessage FClient, WM_MDITILE, MDITILE_VERTICAL, 0
	Case "mnuWindowMore"
		MDIList.ShowModal(MDIMain)
		If MDIList.ModalResult = ModalResults.OK Then
			If MDIList.Tag = 0 Then Exit Sub
			Cast(MDIChildType Ptr, MDIList.Tag)->SetFocus()
		End If
	Case Else
		Cast(MDIChildType Ptr, Sender.Tag)->SetFocus()
	End Select
End Sub

Private Sub MDIMainType.mnuHelp_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuHelpAbout"
		MsgBox(!"Visual FB Editor MDI Demo\r\nBy Cm Wang", "MDI Demo")
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Sub MDIMainType.ToolBar1_ButtonClick(ByRef Sender As ToolBar, ByRef Button As ToolButton)
	Select Case Button.Name
	Case "tbFileNew"
		mnuFile_Click(mnuFileNew)
	Case "tbFileOpen"
		mnuFile_Click(mnuFileOpen)
	Case "tbFileSave"
		mnuFile_Click(mnuFileSave)
	Case "tbFileSaveAll"
		mnuFile_Click(mnuFileSaveAs)
	End Select
End Sub

Private Sub MDIMainType.MDIChildMenuUpdate()
	Dim mMax As Integer = 5
	Dim i As Integer
	Dim j As Integer
	
	'delete and release menu
	For i = mnuWindowCount To 0 Step -1
		mnuWindow.Remove(mnuWindows(i))
		Delete mnuWindows(i)
	Next
	Erase mnuWindows
	
	mnuWindowCount = lstMdiChild.Count
	If mnuWindowCount = 0 Then
		mnuWindowCount = -1
		mnuWindow.Enabled = False
		Exit Sub
	End If
	mnuWindow.Enabled = True
	
	
	If mnuWindowCount > mMax Then
		j = mMax
		mnuWindowCount = mMax + 1
	Else
		j = mnuWindowCount
	End If
	
	ReDim mnuWindows(mnuWindowCount)
	
	'create a split bar menu
	i = 0
	mnuWindows(i) = New MenuItem
	mnuWindows(i)->Caption = "-"
	mnuWindow.Add mnuWindows(i)
	
	'create child list menu
	For i = 1 To j
		mnuWindows(i) = New MenuItem
		mnuWindows(i)->Name = "mnuWindow" & i - 1
		mnuWindows(i)->Tag = lstMdiChild.Item(i - 1)
		mnuWindows(i)->Caption = Cast(MDIChildType Ptr, lstMdiChild.Item(i - 1))->Text
		mnuWindows(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
		mnuWindow.Add mnuWindows(i)
	Next
	
	'create a list... menu
	If j < mnuWindowCount Then
		i = mnuWindowCount
		mnuWindows(i) = New MenuItem
		mnuWindows(i)->Name = "mnuWindowMore"
		mnuWindows(i)->Caption = "More Windows..."
		mnuWindows(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
		mnuWindow.Add mnuWindows(i)
	End If
End Sub

Private Sub MDIMainType.MDIChildNew()
	Static ChildIdx As Integer = 0
	Dim frm As MDIChildType Ptr
	
	ChildIdx += 1
	frm = New MDIChildType
	frm->Text = "Untitled - " & ChildIdx
	lstMdiChild.Add frm
	MDIChildMenuUpdate()
	frm->Show(MDIMain)
End Sub

Private Sub MDIMainType.MDIChildActivate(Child As Any Ptr)
	actMdiChild = Child
	Dim i As Integer
	For i = 0 To mnuWindowCount
		If mnuWindows(i)->Tag = Child Then
			mnuWindows(i)->Checked = True
		Else
			mnuWindows(i)->Checked = False
		End If
	Next
	StatusBar1.Text = Cast(MDIChildType Ptr, Child)->Text
End Sub

Private Sub MDIMainType.MDIChildDestroy(Child As Any Ptr)
	lstMdiChild.Remove(lstMdiChild.IndexOf(Child))
	If lstMdiChild.Count < 1 Then
		actMdiChild = null
		StatusBar1.Text = ""
	End If
	MDIChildMenuUpdate()
	Delete Cast(MDIChildType Ptr, Child)
End Sub

