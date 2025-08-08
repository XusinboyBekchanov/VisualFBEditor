' Copyright (c) 2025 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDIMain.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/List.bi"
	#include once "mff/ToolBar.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/TimerComponent.bi"
	
	Using My.Sys.Forms
	
	Type MDIMainType Extends Form
		lstDestroied As List
		
		lstMdiChild As List
		actMdiChild As Any Ptr
		mnuWindowCount As Integer = -1
		mnuWindows(Any) As MenuItem Ptr
		
		Declare Sub MDIChildActivate(Child As Any Ptr)
		Declare Sub MDIChildClose(Child As Any Ptr)
		Declare Sub MDIChildCreate(Child As Any Ptr)
		Declare Sub MDIChildDestroy(Child As Any Ptr)
		Declare Sub MDIChildMenuCheck()
		Declare Sub MDIChildMenuUpdate()
		Declare Sub MDIChildNew(FileName As WString)
		Declare Sub MDIChildShow(Child As Any Ptr)
		
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub mnuEdit_Click(ByRef Sender As MenuItem)
		Declare Sub mnuFile_Click(ByRef Sender As MenuItem)
		Declare Sub mnuHelp_Click(ByRef Sender As MenuItem)
		Declare Sub mnuView_Click(ByRef Sender As MenuItem)
		Declare Sub mnuWindow_Click(ByRef Sender As MenuItem)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub ToolBar1_ButtonClick(ByRef Sender As ToolBar, ByRef Button As ToolButton)
		Declare Sub mnuRecent_Click(ByRef Sender As MenuItem)
		Declare Constructor
		
		Dim As MenuItem mnuFile, mnuFileNew, mnuFileOpen, mnuFileBar1, mnuFileSave, mnuFileSaveAs, mnuFileSaveAll, mnuFileBar2, mnuFileRecent, mnuRecentEdit, mnuFileBar3, mnuFileProperties, mnuFileBar4, mnuFilePrintSetup, mnuFilePrintPreview, mnuFilePrint, mnuFileBar5, mnuFileExit
		Dim As MenuItem mnuEdit, mnuEditUndo, mnuRedo, mnuEditCopy, mnuEditCut, mnuEditPaste, mnuEditBar1, mnuEditDelete, mnuEditBar2, mnuEditSelectAll
		Dim As MenuItem mnuView, mnuViewToolbar, mnuViewStatusBar, mnuViewBar1, mnuViewRefresh
		Dim As MenuItem mnuWindow, mnuWindowCascade, mnuWindowTileHorizontal, mnuWindowTileVertical, mnuWindowArrangeIcons, mnuWindowClose, mnuWindowCloseAll, mnuWindowBar1, mnuViewDarkMode
		Dim As MenuItem mnuHelp, mnuHelpAbout, mnuPopRecent
		Dim As ImageList ImageList1, ImageList2
		Dim As StatusBar StatusBar1
		Dim As ToolBar ToolBar1
		Dim As ToolButton tbFileNew, tbFileOpen, tbFileSave, tbFileSaveAll, ToolButton1, tbDarkMode
		Dim As StatusPanel StatusPanel1
		Dim As OpenFileDialog OpenFileDialog1
		Dim As SaveFileDialog SaveFileDialog1
		Dim As TimerComponent TimerComponent1
		Dim As MainMenu MainMenu1
	End Type
	
	Constructor MDIMainType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' MDIMain
		With This
			.Name = "MDIMain"
			.Text = "MDIMain"
			.Designer = @This
			.Menu = @MainMenu1
			.FormStyle = FormStyles.fsMDIForm
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & ".\Resources\VisualFBEditor.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			.Caption = "MDIMain"
			.StartPosition = FormStartPosition.CenterScreen
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.AllowDropFiles = True
			.SetBounds 0, 0, 350, 319
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 10, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.ImageWidth = 16
			.ImageHeight = 16
			.SetBounds 30, 30, 16, 16
			.Designer = @This
			.Add "About", "About"
			.Add "Copy", " Copy"
			.Add "Cut", " Cut"
			.Add "DarkMode", "DarkMode"
			.Add "Exit", "Exit"
			.Add "File", "File"
			.Add "New", "New"
			.Add "Open", "Open"
			.Add "Paste", "Paste"
			.Add "Save", "Save"
			.Add "SaveAll", "SaveAll"
			.Parent = @This
		End With
		' ImageList2
		With ImageList2
			.Name = "ImageList2"
			.SetBounds 50, 30, 16, 16
			.Designer = @This
			.Add "About", "About"
			.Add "Copy", " Copy"
			.Add "Cut", " Cut"
			.Add "DarkMode", "DarkMode"
			.Add "Exit", "Exit"
			.Add "File", "File"
			.Add "New", "New"
			.Add "Open", "Open"
			.Add "Paste", "Paste"
			.Add "SaveD", "Save"
			.Add "SaveAllD", "SaveAll"
			.Parent = @This
		End With
		' mnuFile
		With mnuFile
			.Name = "mnuFile"
			.Designer = @This
			.Caption = ML("&File")
			.Parent = @MainMenu1
		End With
		' mnuFileNew
		With mnuFileNew
			.Name = "mnuFileNew"
			.Designer = @This
			.Caption = ML("&New") & !"\tCtrl+N"
			.ImageKey = "New"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuFileOpen
		With mnuFileOpen
			.Name = "mnuFileOpen"
			.Designer = @This
			.Caption = ML("&Open") & !"\tCtrl+O"
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
			.Caption = ML("Save") & !"\tCtrl+S"
			.ImageKey = "Save"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Enabled = False
			.Parent = @mnuFile
		End With
		' mnuFileSaveAs
		With mnuFileSaveAs
			.Name = "mnuFileSaveAs"
			.Designer = @This
			.Caption = ML("Save &As...")
			.ImageKey = "SaveAs"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Enabled = False
			.Parent = @mnuFile
		End With
		' mnuFileSaveAll
		With mnuFileSaveAll
			.Name = "mnuFileSaveAll"
			.Designer = @This
			.Caption = ML("Save A&ll")
			.ImageKey = "SaveAll"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Enabled = False
			.Parent = @mnuFile
		End With
		' mnuFileBar2
		With mnuFileBar2
			.Name = "mnuFileBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileRecent
		With mnuFileRecent
			.Name = "mnuFileRecent"
			.Designer = @This
			.Caption = "Recent"
			.Owner = @MainMenu1
			.Parent = @mnuFile
		End With
		' mnuRecentEdit
		With mnuRecentEdit
			.Name = "mnuRecentEdit"
			.Designer = @This
			.Caption = "Edit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuRecent_Click)
			.Parent = @mnuFileRecent
		End With
		' mnuFileBar3
		With mnuFileBar3
			.Name = "mnuFileBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileProperties
		With mnuFileProperties
			.Name = "mnuFileProperties"
			.Designer = @This
			.Caption = ML("Propert&ies")
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Enabled = False
			.Parent = @mnuFile
		End With
		' mnuFileBar4
		With mnuFileBar4
			.Name = "mnuFileBar4"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFilePrintSetup
		With mnuFilePrintSetup
			.Name = "mnuFilePrintSetup"
			.Designer = @This
			.Caption = ML("Print Set&up...")
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Enabled = False
			.Parent = @mnuFile
		End With
		' mnuFilePrintPreview
		With mnuFilePrintPreview
			.Name = "mnuFilePrintPreview"
			.Designer = @This
			.Caption = ML("Print Pre&view")
			.MenuIndex = 11
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Enabled = False
			.Parent = @mnuFile
		End With
		' mnuFilePrint
		With mnuFilePrint
			.Name = "mnuFilePrint"
			.Designer = @This
			.Caption = ML("&Print...") & !"\tCtrl+P"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Enabled = False
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
			.Caption = ML("E&xit")
			.ImageKey = "Exit"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.Parent = @mnuFile
		End With
		' mnuEdit
		With mnuEdit
			.Name = "mnuEdit"
			.Designer = @This
			.Caption = ML("&Edit")
			.Enabled = False
			.Parent = @MainMenu1
		End With
		' mnuRedo
		With mnuRedo
			.Name = "mnuRedo"
			.Designer = @This
			.Caption = ML("&Redo")
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditUndo
		With mnuEditUndo
			.Name = "mnuEditUndo"
			.Designer = @This
			.Caption = ML("&Undo") & !"\tCtrl+Z"
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
			.Caption = ML("Cu&t") & !"\tCtrl+X"
			.ImageKey = "Cut"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent =  @mnuEdit
		End With
		' mnuEditCopy
		With mnuEditCopy
			.Name = "mnuEditCopy"
			.Designer = @This
			.Caption = ML("&Copy") & !"\tCtrl+C"
			.ImageKey = "Copy"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditPaste
		With mnuEditPaste
			.Name = "mnuEditPaste"
			.Designer = @This
			.Caption = ML("&Paste") & !"\tCtrl+V"
			.ImageKey = "Paste"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditDelete
		With mnuEditDelete
			.Name = "mnuEditDelete"
			.Designer = @This
			.Caption = ML("Delete") & !"\tDel"
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
			.Caption = ML("Select &All")
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuView
		With mnuView
			.Name = "mnuView"
			.Designer = @This
			.Caption = ML("&View")
			.Parent = @MainMenu1
		End With
		' mnuViewToolbar
		With mnuViewToolbar
			.Name = "mnuViewToolbar"
			.Caption = "&Toolbar"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Checked = True
			.Parent = @mnuView
		End With
		' mnuViewStatusBar
		With mnuViewStatusBar
			.Name = "mnuViewStatusBar"
			.Caption = ML("Status &Bar")
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Checked = True
			.Parent = @mnuView
		End With
		' mnuViewBar1
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
			.Caption = ML("Dark Mode")
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Parent = @mnuView
		End With
		' mnuWindow
		With mnuWindow
			.Name = "mnuWindow"
			.Caption = ML("&Window")
			.Designer = @This
			.Enabled = False
			.Parent = @MainMenu1
		End With
		' mnuWindowTileHorizontal
		With mnuWindowTileHorizontal
			.Name = "mnuWindowTileHorizontal"
			.Caption = ML("Tile &Horizontal")
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' mnuWindowTileVertical
		With mnuWindowTileVertical
			.Name = "mnuWindowTileVertical"
			.Caption = ML("Tile &Vertical")
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' mnuWindowCascade
		With mnuWindowCascade
			.Name = "mnuWindowCascade"
			.Caption = ML("&Cascade")
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		With mnuWindowArrangeIcons
			.Name= "mnuWindowArrangeIcons"
			.Caption = ML("&Arrange Icons")
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' mnuWindowBar1
		With mnuWindowBar1
			.Name = "mnuWindowBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuWindow
		End With
		' mnuWindowClose
		With mnuWindowClose
			.Name = "mnuWindowClose"
			.Designer = @This
			.Caption = ML("Close")
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' mnuWindowCloseAll
		With mnuWindowCloseAll
			.Name = "mnuWindowCloseAll"
			.Designer = @This
			.Caption = ML("Close All")
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.Parent = @mnuWindow
		End With
		' mnuHelp
		With mnuHelp
			.Name = "mnuHelp"
			.Designer = @This
			.Caption = ML("&Help")
			.Parent = @MainMenu1
		End With
		' mnuHelpAbout
		With mnuHelpAbout
			.Name = "mnuHelpAbout"
			.Designer = @This
			.Caption = ML("About")
			.ImageKey = "About"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuHelp_Click)
			.Parent = @mnuHelp
		End With
		' mnuPopRecent
		With mnuPopRecent
			.Name = "mnuPopRecent"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuRecent_Click)
			.Caption = "Recent"
		End With
		' ToolBar1
		With ToolBar1
			.Name = "ToolBar1"
			.Text = "ToolBar1"
			.Align = DockStyle.alTop
			.HotImagesList = @ImageList1
			.ImagesList = @ImageList1
			.DisabledImagesList = @ImageList2
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
			.Hint = ML("New")
			.ShowHint = True
			.Parent = @ToolBar1
		End With
		' tbFileOpen
		With tbFileOpen
			.Name = "tbFileOpen"
			.Designer = @This
			.ImageKey = "Open"
			.Hint = ML("Open")
			.Style = ToolButtonStyle.tbsDropDown
			.Width = 38
			.ShowHint = True
			.Parent = @ToolBar1
			.DropDownMenu.Add @mnuPopRecent
		End With
		' tbFileSave
		With tbFileSave
			.Name = "tbFileSave"
			.Designer = @This
			.ImageKey = "Save"
			.Hint = ML("Save")
			.ShowHint = True
			.Enabled = False
			.Parent = @ToolBar1
		End With
		' tbFileSaveAll
		With tbFileSaveAll
			.Name = "tbFileSaveAll"
			.Designer = @This
			.ImageKey = "SaveAll"
			.Hint = ML("Save All")
			.ShowHint = True
			.Enabled = False
			.Parent = @ToolBar1
		End With
		' ToolButton1
		With ToolButton1
			.Name = "ToolButton1"
			.Designer = @This
			.Style = ToolButtonStyle.tbsSeparator
			.Parent = @ToolBar1
		End With
		' tbDarkMode
		With tbDarkMode
			.Name = "tbDarkMode"
			.Designer = @This
			.ImageKey = "DarkMode"
			.Checked = True
			.Style = ToolButtonStyle.tbsCheck
			.Parent = @ToolBar1
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = ""
			.Align = DockStyle.alBottom
			.SetBounds 0, 239, 334, 22
			.Designer = @This
			.Parent = @This
		End With
		' StatusPanel1
		With StatusPanel1
			.Name = "StatusPanel1"
			.Designer = @This
			.Parent = @StatusBar1
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.Filter = ML("All files") & "(*.*)|*.*"
			.MultiSelect = True
			.SetBounds 80, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' SaveFileDialog1
		With SaveFileDialog1
			.Name = "SaveFileDialog1"
			.SetBounds 100, 30, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 200
			.SetBounds 120, 30, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared MDIMain As MDIMainType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		MDIMain.MainForm = True
		MDIMain.Show
		App.Run
	#endif
'#End Region

#include once "MDIChild.frm"
#include once "MDIList.frm"

Private Sub MDIMainType.mnuFile_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case mnuFileNew.Name
		MDIChildNew("")
	Case mnuFileOpen.Name
		If OpenFileDialog1.Execute() Then
			Dim j As Integer = OpenFileDialog1.FileNames.Count - 1
			For i As Integer = 0 To j
				MDIChildNew(OpenFileDialog1.FileNames.Item(i))
			Next
		End If
	Case mnuFileExit.Name
		ModalResult = ModalResults.OK
		CloseForm
	Case Else
		MsgBox Sender.Name & !"\r\n" & ML("This function is under construction "), " FILE "
	End Select
End Sub

Private Sub MDIMainType.mnuRecent_Click(ByRef Sender As MenuItem)
	MsgBox Sender.Name & !"\r\n" & ML("This function is under construction "), "Recent"
End Sub

Private Sub MDIMainType.mnuEdit_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = actMdiChild
	Select Case Sender.Name
	Case mnuEditUndo.Name
		a->TextBox1.Undo
	Case mnuEditCut.Name
		a->TextBox1.CutToClipboard
	Case mnuEditCopy.Name
		a->TextBox1.CopyToClipboard
	Case mnuEditPaste.Name
		a->TextBox1.PasteFromClipboard
	Case mnuEditDelete.Name
		a->TextBox1.ClearUndo
	Case Else
		MsgBox Sender.Name & !"\r\n" & ML("This function is under construction "), " Edit "
	End Select
End Sub

Private Sub MDIMainType.mnuView_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case mnuViewToolbar.Name
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		ToolBar1.Visible = Sender.Checked
		RequestAlign
	Case mnuViewStatusBar.Name
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		StatusBar1.Visible = Sender.Checked
		RequestAlign
	Case mnuViewDarkMode.Name
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		App.DarkMode = Sender.Checked
		SetDarkMode(Sender.Checked, Sender.Checked)
		InvalidateRect(Handle, NULL, False)
		UpdateWindow(Handle)
	Case Else
		MsgBox Sender.Name & !"\r\n" & ML("This function is under construction "), "View"
	End Select
End Sub

Private Sub MDIMainType.mnuWindow_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case mnuWindowClose.Name
		If actMdiChild Then Cast(MDIChildType Ptr, actMdiChild)->CloseForm
	Case mnuWindowCloseAll.Name
		For i As Integer = lstMdiChild.Count - 1 To 0 Step -1
			Cast(MDIChildType Ptr, lstMdiChild.Item(i))->CloseForm
		Next
	Case mnuWindowCascade.Name
		#ifdef __USE_WINAPI__
			SendMessage FClient, WM_MDICASCADE, 0, 0
		#endif
	Case mnuWindowArrangeIcons.Name
		#ifdef __USE_WINAPI__
			SendMessage FClient, WM_MDIICONARRANGE, 0, 0
		#endif
	Case mnuWindowTileHorizontal.Name
		#ifdef __USE_WINAPI__
			SendMessage FClient, WM_MDITILE, MDITILE_HORIZONTAL, 0
		#endif
	Case mnuWindowTileVertical.Name
		#ifdef __USE_WINAPI__
			SendMessage FClient, WM_MDITILE, MDITILE_VERTICAL, 0
		#endif
	Case "mnuWindowMore"
		Dim MdiList As MDIListType Ptr = New MDIListType
		MdiList->ShowModal(MDIMain)
		If MdiList->Tag = NULL Then Exit Sub
		Cast(MDIChildType Ptr, MdiList->Tag)->SetFocus()
		Delete MdiList
	Case Else
		Cast(MDIChildType Ptr, Sender.Tag)->SetFocus()
	End Select
End Sub

Private Sub MDIMainType.mnuHelp_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuHelpAbout"
		MsgBox(!"Visual FB Editor MDI Form Demo\r\nBy Cm Wang", "MDI Form Demo")
	Case Else
		MsgBox Sender.Name & !"\r\n" & ML("This function is under construction "), "Edit"
	End Select
End Sub

Private Sub MDIMainType.ToolBar1_ButtonClick(ByRef Sender As ToolBar, ByRef Button As ToolButton)
	? "ToolBar1_ButtonClick"
	
	Select Case Button.Name
	Case tbFileNew.Name
		mnuFile_Click(mnuFileNew)
	Case tbFileOpen.Name
		mnuFile_Click(mnuFileOpen)
	Case tbFileSave.Name
		mnuFile_Click(mnuFileSave)
	Case tbFileSaveAll.Name
		mnuFile_Click(mnuFileSaveAll)
	Case tbDarkMode.Name
		mnuView_Click(mnuViewDarkMode)
	End Select
End Sub

Private Sub MDIMainType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	? "Form_Resize"
	StatusPanel1.Width = Width
End Sub

Private Sub MDIMainType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	? "Form_DropFile", Filename
	MDIChildNew(Filename)
End Sub

Private Sub MDIMainType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	? "Form_Close"
	mlKeys.SaveToFile(ExePath & "\" &  App.Language & ".lng")
	mnuWindow_Click(mnuWindowCloseAll)
End Sub

Private Sub MDIMainType.MDIChildMenuCheck()
	? "MDIChildMenuCheck"
	Dim i As Integer
	For i = 0 To mnuWindowCount
		If mnuWindows(i)->Tag = actMdiChild Then
			mnuWindows(i)->Checked = True
		Else
			mnuWindows(i)->Checked = False
		End If
	Next
End Sub

Private Sub MDIMainType.MDIChildMenuUpdate()
	? "MDIChildMenuUpdate"
	Dim mMax As Integer = 9 'form 0 to mMax
	Dim i As Integer
	Dim j As Integer
	
	'delete and release menu
	For i = mnuWindowCount To 0 Step -1
		mnuWindow.Remove(mnuWindows(i))
		Delete mnuWindows(i)
	Next
	Erase mnuWindows
	
	'disable/enabled window menu
	mnuWindowCount = lstMdiChild.Count
	If mnuWindowCount = 0 Then
		mnuWindowCount = -1
		mnuWindow.Enabled = False
	Else
		mnuWindow.Enabled = True
		
		'count of menu
		If mnuWindowCount > mMax Then
			j = mMax
			mnuWindowCount = mMax + 1
		Else
			j = mnuWindowCount
		End If
		ReDim mnuWindows(mnuWindowCount)
		
		'create menu
		For i = 0 To j
			mnuWindows(i) = New MenuItem
			mnuWindows(i)->Designer = @This
			mnuWindows(i)->Parent = @mnuWindow
			If i = 0 Then
				'create a split bar menu
				mnuWindows(i)->Caption = "-"
				mnuWindows(i)->Name = "mnuWindowBar2"
			Else
				'create child list menu
				mnuWindows(i)->Name = "mnuWindow" & i - 1
				mnuWindows(i)->Caption = Cast(MDIChildType Ptr, lstMdiChild.Item(i - 1))->Text
				mnuWindows(i)->Tag = lstMdiChild.Item(i - 1)
				mnuWindows(i)->Checked = IIf(mnuWindows(i)->Tag = actMdiChild, True, False)
				mnuWindows(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			End If
			mnuWindow.Add mnuWindows(i)
		Next
		
		'create a list... menu
		If j <> mnuWindowCount Then
			i = mnuWindowCount
			mnuWindows(i) = New MenuItem
			mnuWindows(i)->Designer = @This
			mnuWindows(i)->Parent = @mnuWindow
			mnuWindows(i)->Name = "mnuWindowMore"
			mnuWindows(i)->Caption = ML("More Windows...")
			mnuWindows(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			mnuWindow.Add mnuWindows(i)
		End If
	End If
	mnuEdit.Enabled = mnuWindow.Enabled
	mnuFileSave.Enabled = mnuWindow.Enabled
	mnuFileSaveAll.Enabled = mnuWindow.Enabled
	mnuFileSaveAs.Enabled = mnuWindow.Enabled
	mnuFileProperties.Enabled = mnuWindow.Enabled
	mnuFilePrint.Enabled = mnuWindow.Enabled
	mnuFilePrintPreview.Enabled = mnuWindow.Enabled
	mnuFilePrintSetup.Enabled = mnuWindow.Enabled
	tbFileSave.Enabled = mnuWindow.Enabled
	tbFileSaveAll.Enabled = mnuWindow.Enabled
End Sub

Private Sub MDIMainType.MDIChildNew(FileName As WString)
	? "MDIChildNew    " & FileName
	
	Static ChildIdx As Integer = 0
	ChildIdx += 1
	Dim MDIChild As MDIChildType Ptr = New MDIChildType
	lstMdiChild.Add MDIChild
	If FileName= "" Then
		MDIChild->Text = ML("Untitled") & " - " & ChildIdx
	Else
		MDIChild->Text = FileName
	End If
	MDIChildMenuUpdate()
	MDIChild->Show(MDIMain)
End Sub

Private Sub MDIMainType.MDIChildActivate(Child As Any Ptr)
	? "MDIChildActivate " & Hex(Child)
	
	actMdiChild = Child
	If actMdiChild Then
		StatusPanel1.Caption = Cast(MDIChildType Ptr, Child)->Text
		MDIChildMenuCheck()
	Else
		StatusPanel1.Caption = ""
	End If
End Sub

Private Sub MDIMainType.MDIChildCreate(Child As Any Ptr)
	? "MDIChildCreate   " & Hex(Child)
	
End Sub

Private Sub MDIMainType.MDIChildShow(Child As Any Ptr)
	? "MDIChildShow     " & Hex(Child)
	
End Sub

Private Sub MDIMainType.MDIChildClose(Child As Any Ptr)
	? "MDIChildClose    " & Hex(Child)
End Sub

Private Sub MDIMainType.MDIChildDestroy(Child As Any Ptr)
	? "MDIChildDestroy  " & Hex(Child)
	
	'The following type delete code can sometimes cause the application to crash
	'Therefore, I used a timer to delete the type
	
	'lstMdiChild.Remove(lstMdiChild.IndexOf(Child))
	'Delete Cast(MDIChildType Ptr, Child)
	
	TimerComponent1.Enabled = False
	
	'add to destroyed list
	lstDestroied.Add(Child)
	
	'Activate the destruction calculator
	TimerComponent1.Enabled = True
End Sub

Private Sub MDIMainType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	? "TimerComponent1_Timer"
	Sender.Enabled = False
	Dim As Boolean c = False
	
	While lstDestroied.Count
		Dim As Integer i, j = lstMdiChild.Count - 1
		For i = 0 To j
			If lstMdiChild.Item(i) = lstDestroied.Item(0) Then
				Delete Cast(MDIChildType Ptr, lstDestroied.Item(0))
				lstMdiChild.Remove(i)
				c = True
				Exit For
			End If
		Next
		lstDestroied.Remove(0)
	Wend
	
	'如果有MDIChildType窗口delete, 更新窗口菜单
	If c Then
		MDIChildMenuUpdate()
		'更新窗口菜单上的激活窗口
		If lstMdiChild.Count < 1 Then MDIChildActivate(NULL)
	End If
End Sub

