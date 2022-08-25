#ifdef __FB_WIN32__
	#cmdline "Form1.rc"
#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ReBar.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/List.bi"
	
	Using My.Sys.Forms
	
	Using My.Sys.Forms
	#ifdef __USE_WINAPI__
		InitDarkMode
	#endif
	
	Type MDIMainType Extends Form
		Dim lstMdiChild As List
		Dim actMidChildIdx As Integer
		
		Dim mnuWindowCount As Integer = -1
		Dim mnuWindows(Any) As MenuItem Ptr

		Declare Sub MDIChildNew()
		Declare Sub MDIChildActivate(Child As Any Ptr)
		Declare Sub MDIChildDestroy(Child As Any Ptr)
		Declare Sub MDIChildMenuUpdate()
		
		Declare Static Sub _mnuEdit_Click(ByRef Sender As MenuItem)
		Declare Sub mnuEdit_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuFile_Click(ByRef Sender As MenuItem)
		Declare Sub mnuFile_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuWindow_Click(ByRef Sender As MenuItem)
		Declare Sub mnuWindow_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuView_Click(ByRef Sender As MenuItem)
		Declare Sub mnuView_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuHelp_Click(ByRef Sender As MenuItem)
		Declare Sub mnuHelp_Click(ByRef Sender As MenuItem)
		Declare Constructor
		
		Dim As MainMenu MainMenu1
		Dim As MenuItem mnuFile, mnuFileNew, mnuFileOpen, mnuFileSave, mnuFileSaveAs, mnuFileBar1, mnuFileBar2, mnuFileClose, mnuFileSaveAll, mnuFileBar3, mnuFileProperties, mnuFilePrintSetup, mnuFilePrintPreview, mnuFilePrint, mnuFileBar4, mnuFileSend, mnuFileBar5, mnuFileExit
		Dim As MenuItem mnuEdit, mnuEditUndo, mnuRedo, mnuEditCopy, mnuEditCut, mnuEditPaste, mnuEditBar1, mnuEditPasteSpecial, mnuEditBar2, mnuEditDSelectAll, mnuEditInvertSelection
		Dim As MenuItem mnuView, mnuViewToolbar, mnuViewStatusBar, mnuViewBar1, mnuViewLargeIcons, mnuViewSmallIcons, mnuViewList, mnuViewDetails, mnuViewBar2, mnuViewArrangeIcons, mnuVAIByName, mnuVAIByType, mnuVAIBySize, mnuVAIByDate, mnuViewLineUpIcons, mnuViewBar3, mnuViewRefresh , mnuViewOptions
		Dim As MenuItem mnuHelp, mnuHelpContent, mnuHelpAbout, mnuHelpSearch, mnuHelpBar1
		Dim As MenuItem mnuWindow, mnuWindowCascade, mnuWindowTileHorizontal, mnuWindowTileVertical, mnuWindowArrangeIcons, MenuItem1, MenuItem2, MenuItem3, MenuItem4
		Dim As ReBar ReBar1
		Dim As ImageList ImageList1
		Dim As StatusBar StatusBar1
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
			.Add "New ", "New"
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
			.Caption = "&New" & !"\tCtrl+N"
			.ImageKey = "New"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileOpen
		With mnuFileOpen
			.Name = "mnuFileOpen"
			.Designer = @This
			.Caption = "&Open" & !"\tCtrl+O"
			.ImageKey = "Open"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileClose
		With mnuFileClose
			.Name = "mnuFileClose"
			.Designer = @This
			.Caption = "&Close"
			.OnClick = @_mnuFile_Click
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
			.Caption = "Save"  & !"\tCtrl+S"
			.ImageKey = "Save"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileSaveAs
		With mnuFileSaveAs
			.Name = "mnuFileSaveAs"
			.Designer = @This
			.Caption = "Save &As..."
			.ImageKey = "SaveAs"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileSaveAll
		With mnuFileSaveAll
			.Name = "mnuFileSaveAll"
			.Designer = @This
			.Caption = "Save A&ll"
			.ImageKey = "SaveAll"
			.OnClick = @_mnuFile_Click
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
			.OnClick = @_mnuFile_Click
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
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFilePrintPreview
		With mnuFilePrintPreview
			.Name = "mnuFilePrintPreview"
			.Designer = @This
			.Caption = "Print Pre&view"
			.MenuIndex = 11
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFilePrint
		With mnuFilePrint
			.Name = "mnuFilePrint"
			.Designer = @This
			.Caption = "&Print..." & !"\tCtrl+P"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileBar4
		With mnuFileBar4
			.Name = "mnuFileBar4"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileSend
		With mnuFileSend
			.Name = "mnuFileSend"
			.Designer = @This
			.Caption = "Sen&d..."
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileBar5
		With mnuFileBar5
			.Name = "mnuFileBar5"
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
			.OnClick = @_mnuFile_Click
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
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditUndo
		With mnuEditUndo
			.Name = "mnuEditUndo"
			.Designer = @This
			.Caption = "&Undo"
			.OnClick = @_mnuEdit_Click
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
			.Caption = "Cu&t"
			.ImageKey = "Cut"
			.OnClick = @_mnuEdit_Click
			.Parent =  @mnuEdit
		End With
		' mnuEditCopy
		With mnuEditCopy
			.Name = "mnuEditCopy"
			.Designer = @This
			.Caption = "&Copy"
			.ImageKey = "Copy"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditPaste
		With mnuEditPaste
			.Name = "mnuEditPaste"
			.Designer = @This
			.Caption = "&Paste"
			.ImageKey = "Paste"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditPasteSpecial
		With mnuEditPasteSpecial
			.Name = "mnuEditPasteSpecial"
			.Designer = @This
			.Caption = "Paste &Special..."
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditBar2
		With mnuEditBar2
			.Name = "mnuEditBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditDSelectAll
		With mnuEditDSelectAll
			.Name = "mnuEditDSelectAll"
			.Designer = @This
			.Caption = "Select &All"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditInvertSelection
		With mnuEditInvertSelection
			.Name = "mnuEditInvertSelection"
			.Designer = @This
			.Caption = "&Invert Selection"
			.OnClick = @_mnuEdit_Click
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
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		With mnuViewStatusBar
			.Name = "mnuViewStatusBar"
			.Caption = "Status &Bar"
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Checked = true
			.Parent = @mnuView
		End With
		With mnuViewBar1
			.Name = "mnuViewBar1"
			.Caption = "-"
			.Designer = @This
			.Parent = @mnuView
		End With
		' MenuItem4
		With MenuItem4
			.Name = "MenuItem4"
			.Designer = @This
			.Caption = "Dark Mode"
			.Checked = False
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		With mnuViewLargeIcons
			.Name = "mnuViewLargeIcons"
			.Caption = "Lar&ge Icons"
			.Designer = @This
			.Parent = @mnuView
		End With
		With mnuViewSmallIcons
			.Name = "mnuViewSmallIcons"
			.Caption = "S&mall Icons"
			.Designer = @This
			.Parent = @mnuView
		End With
		With mnuViewList
			.Name = "mnuViewList"
			.Caption = "&List"
			.Designer = @This
			.Parent = @mnuView
		End With
		With mnuViewDetails
			.Name = "mnuViewDetails"
			.Caption = "&Details"
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		With mnuViewBar2
			.Name = "mnuViewBar2"
			.Caption = "-"
			.Designer = @This
			.Parent = @mnuView
		End With
		With mnuViewArrangeIcons
			.Name = "mnuViewArrangeIcons"
			.Caption = "Arrange &Icons"
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		With mnuVAIByName
			.Name = "mnuVAIByName"
			.Caption = "by &Name"
			.Designer = @This
			.Parent = @mnuViewArrangeIcons
		End With
		With mnuVAIByType
			.Name = "mnuVAIByType"
			.Caption = "by &Type"
			.Designer = @This
			.Parent = @mnuViewArrangeIcons
		End With
		With mnuVAIBySize
			.Name = "mnuVAIBySize"
			.Caption = "by Si&ze"
			.Designer = @This
			.Parent = @mnuViewArrangeIcons
		End With
		With mnuVAIByDate
			.Name = "mnuVAIByDate"
			.Caption = "by &Date"
			.Designer = @This
			.Parent = @mnuViewArrangeIcons
		End With
		With mnuViewLineUpIcons
			.Name = "mnuViewLineUpIcons"
			.Caption = "Li&ne Up Icons"
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		With mnuViewBar3
			.Name = "mnuViewBar3"
			.Caption = "-"
			.Designer = @This
			.Parent = @mnuView
		End With
		With mnuViewRefresh
			.Name = "mnuViewRefresh"
			.Caption = "&Refresh"
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		With mnuViewOptions
			.Name = "mnuViewOptions"
			.Caption = "&Options..."
			.Designer = @This
			.OnClick = @_mnuView_Click
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
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		With mnuWindowTileVertical
			.Name = "mnuWindowTileVertical"
			.Caption = "Tile &Vertical"
			.Designer = @This
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		With mnuWindowCascade
			.Name = "mnuWindowCascade"
			.Caption = "&Cascade"
			.Designer = @This
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		With mnuWindowArrangeIcons
			.Name= "mnuWindowArrangeIcons"
			.Caption = "&Arrange Icons"
			.Designer = @This
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' MenuItem3
		With MenuItem3
			.Name = "MenuItem3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuWindow
		End With
		' MenuItem1
		With MenuItem1
			.Name = "MenuItem1"
			.Designer = @This
			.Caption = "Close"
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' MenuItem2
		With MenuItem2
			.Name = "MenuItem2"
			.Designer = @This
			.Caption = "Close All"
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' mnuHelp
		With mnuHelp
			.Name = "mnuHelp"
			.Designer = @This
			.Caption = "&Help"
			.Parent = @MainMenu1
		End With
		' mnuHelpContent
		With mnuHelpContent
			.Name = "mnuHelpContent"
			.Designer = @This
			.Caption = "&Contents"
			.OnClick = @_mnuHelp_Click
			.Parent = @mnuHelp
		End With
		' mnuHelpSearch
		With mnuHelpSearch
			.Name = "mnuHelpSearch"
			.Designer = @This
			.Caption = "&Search For Help On..."
			.OnClick = @_mnuHelp_Click
			.Parent = @mnuHelp
		End With
		' mnuHelpBar1
		With mnuHelpBar1
			.Name = "mnuHelpBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuHelp
		End With
		' mnuHelpAbout
		With mnuHelpAbout
			.Name = "mnuHelpAbout"
			.Designer = @This
			.Caption = "About"
			.ImageKey = "About"
			.OnClick = @_mnuHelp_Click
			.Parent = @mnuHelp
		End With
		' ReBar1
		With ReBar1
			.Name = "ReBar1"
			.Text = "ReBar1"
			.SetBounds 0, 0, 334, 30
			.Designer = @This
			.Parent = @This
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
	End Constructor

	Private Sub MDIMainType._mnuFile_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuFile_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuEdit_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuEdit_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuView_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuView_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuWindow_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuWindow_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuHelp_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuHelp_Click(Sender)
	End Sub
	
	Dim Shared MDIMain As MDIMainType
	
	#ifndef _NOT_AUTORUN_FORMS_
		#define _NOT_AUTORUN_FORMS_
		
		MDIMain.Show
		
		App.Run
	#endif
'#End Region

#include once "MDIChild.frm"
#include once "MDIList.frm"

Private Sub MDIMainType.mnuFile_Click(ByRef Sender As MenuItem)
	Select Case Sender.Caption
	Case "&New" & !"\tCtrl+N"
		MDIChildNew()
	Case "E&xit"
		ModalResult = ModalResults.OK
		CloseForm
	Case Else
		MsgBox Sender.Caption & !"\r\nThis function is under construction", "File"
	End Select
End Sub

Private Sub MDIMainType.mnuEdit_Click(ByRef Sender As MenuItem)
	Select Case Sender.Caption
	Case Else
		MsgBox Sender.Caption & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Sub MDIMainType.mnuView_Click(ByRef Sender As MenuItem)
	Select Case Sender.Caption
	Case "Dark Mode"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		SetDarkMode(Sender.Checked, Sender.Checked)
	Case "Status &Bar"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		StatusBar1.Visible = Sender.Checked = True
	Case Else
		MsgBox Sender.Caption & !"\r\nThis function is under construction", "View"
	End Select
End Sub

Private Sub MDIMainType.mnuWindow_Click(ByRef Sender As MenuItem)
	Dim h As HWND
	
	Select Case Sender.Caption
	Case "Close"
		h = SendMessage(FClient, WM_MDIGETACTIVE, 0, 0)
		If h Then SendMessage(h, WM_CLOSE, 0, 0)
	Case "Close All"
		Do
			h = SendMessage(FClient, WM_MDIGETACTIVE, 0, 0)
			If h Then SendMessage(h, WM_CLOSE, 0, 0)
		Loop While (h)
	Case "&Cascade"
		SendMessage FClient, WM_MDICASCADE, 0, 0
	Case "&Arrange Icons"
		SendMessage FClient, WM_MDIICONARRANGE, 0, 0
	Case "Tile &Horizontal"
		SendMessage FClient, WM_MDITILE, MDITILE_HORIZONTAL, 0
	Case "Tile &Vertical"
		SendMessage FClient, WM_MDITILE, MDITILE_VERTICAL, 0
	Case "More Windows..."
		Dim frm As MDIListType Ptr
		frm = New MDIListType
		frm->ShowModal(MDIMain)
		If frm->ModalResult = ModalResults.OK Then
			If frm->Tag Then
				Cast(MDIChildType Ptr, frm->Tag)->SetFocus()
			End If
		End If
		Delete frm
	Case Else
		Cast(MDIChildType Ptr, Sender.Tag)->SetFocus()
	End Select
End Sub

Private Sub MDIMainType.mnuHelp_Click(ByRef Sender As MenuItem)
	Select Case Sender.Caption
	Case "About"
		MsgBox(!"Visual FB Editor MDI Demo\r\nBy Cm Wang", "MDI Demo")
	Case Else
		MsgBox Sender.Caption & !"\r\nThis function is under construction", "Edit"
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
		mnuWindows(i)->Tag = lstMdiChild.Item(i - 1)
		mnuWindows(i)->Caption = Cast(MDIChildType Ptr, lstMdiChild.Item(i - 1))->Text
		mnuWindows(i)->OnClick = @_mnuWindow_Click
		mnuWindow.Add mnuWindows(i)
	Next
	
	'create a list... menu
	If j < mnuWindowCount Then
		i = mnuWindowCount
		mnuWindows(i) = New MenuItem
		mnuWindows(i)->Caption = "More Windows..."
		mnuWindows(i)->OnClick = @_mnuWindow_Click
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
	actMidChildIdx = lstMdiChild.IndexOf(Child)
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
		actMidChildIdx = -1
		StatusBar1.Text = ""
	End If
	MDIChildMenuUpdate()
	Delete Child
End Sub
