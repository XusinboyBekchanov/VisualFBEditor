' MDIScintilla MDIMain.frm
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#define __MDI__ MDIMain
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDIScintilla.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/List.bi"
	#include once "mff/Menus.bi"
	#include once "mff/PageSetupDialog.bi"
	#include once "mff/PrintDialog.bi"
	#include once "mff/PrintDocument.bi"
	#include once "mff/Printer.bi"
	#include once "mff/PrintPreviewDialog.bi"
	#include once "mff/ReBar.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/ToolBar.bi"
	
	#include once "../MDINotepad/Text.bi"
	#include once "../MDINotepad/TimeMeter.bi"
	
	Using My.Sys.Forms
	
	#include "Scintilla.bi"
	#include "Scilexer.bi"
	
	Type MDIMainType Extends Form
		'hSci As Any Ptr
		timr As TimeMeter
		
		'mdichild
		ActMdiChild As Any Ptr = NULL
		lstMdiChild As List
		CloseResult As ModalResults = ModalResults.Yes
		mCaption As WString Ptr
		
		'mdichild menu
		mnuWindowCount As Integer = -1
		mnuWindows(Any) As MenuItem Ptr
		mnuWindowsAct As Integer = -1
		Declare Function MDIChildCloseConfirm(ByRef Child As Any Ptr) As MessageResult  '子窗口关闭确认Confirmation of child-window closure.
		Declare Function MDIChildFind(ByRef FileName As WString) As Integer             '寻找文件是否存已在经打开的窗口中Check if the file is already open in an existing window.
		Declare Function MDIChildNew(ByRef FileName As WString) As Any Ptr              '创建新子窗口Create a new child-window.
		Declare Sub MDIChildActivate(ByRef Child As Any Ptr)                            '激活的子窗口指针Pointer of activated child-window.
		Declare Sub MDIChildClick()                                                     '更新状态栏信息Update status bar information.
		Declare Sub MDIChildDestroy(ByRef Child As Any Ptr)                             '子窗口销毁Destroy the child-window.
		Declare Sub MDIChildDoubleClick(ByRef Child As Any Ptr)
		Declare Sub MDIChildInsertText(ByRef Child As Any Ptr, ByRef Text As WString)   '在子窗口的光标处插入文字Insert text at the cursor position in the sub-window.
		Declare Sub MDIChildMenuUpdate()                                                '更新窗口菜单Update window menus.
		Declare Sub MenuEnabled(Enabled As Boolean)                                     '窗口菜单可用与否Availability of window menus.
		
		'file
		Declare Function FileSave(ByRef Child As Any Ptr) As MessageResult              '文件保存
		Declare Function FileSaveAs(ByRef Child As Any Ptr) As MessageResult            '文件另存为
		Declare Sub FileInsert(ByRef Child As Any Ptr, ByRef FileName As WString)       '文件插入
		Declare Sub FileOpen(ByRef FileName As WString)                                 '文件打开
		
		fFindBack As Boolean = False
		fMatchCase As Boolean = False
		fFindWarp As Boolean = True
		fRegExp As Boolean = True
		
		Declare Sub Find(ByRef FindStr As Const WString, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal FindForce As Boolean = False)
		Declare Sub GotoLineNo(ByVal LineNumber As Integer)
		Declare Sub Replace(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True)
		Declare Function ReplaceAll(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False) As Integer
		Declare Sub SortLines(SortOrder As SortOrders)
		
		Const CharSetCount As Integer = 21
		CharSetMnu(CharSetCount) As MenuItem Ptr
		CharSetNum(CharSetCount) As Integer => { _
		0, _
		1, _
		186, _
		136, _
		238, _
		134, _
		161, _
		129, _
		77, _
		255, _
		204, _
		866, _
		1251, _
		128, _
		2, _
		162, _
		130, _
		177, _
		178, _
		163, _
		222, _
		1000 _
		}
		CharSetStr(CharSetCount) As String => { _
		"ANSI", _
		"DEFAULT", _
		"BALTIC", _
		"CHINESEBIG5", _
		"EASTEUROPE", _
		"GB2312", _
		"GREEK", _
		"HANGUL", _
		"MAC", _
		"OEM", _
		"RUSSIAN", _
		"OEM866", _
		"CYRILLIC", _
		"SHIFTJIS", _
		"SYMBOL", _
		"TURKISH", _
		"JOHAB", _
		"HEBREW", _
		"ARABIC", _
		"VIETNAMESE", _
		"THAI", _
		"8859_15" _
		}
		
		Const CodePageCount As Long = 6
		CodePageMnu(CharSetCount) As MenuItem Ptr
		CodePageNum(CodePageCount) As Integer => { _
		0, _
		65001, _
		932, _
		936, _
		949, _
		950, _
		1361 _
		}
		CodePageStr(CodePageCount) As String => { _
		"Default", _
		"UTF-8", _
		"Japanese Shift-JIS", _
		"Simplified Chinese GBK", _
		"Korean Unified Hangul Code", _
		"Traditional Chinese Big5", _
		"Korean Johab" _
		}
		
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		
		Declare Sub StatusBar1_PanelClick(ByRef Sender As StatusBar, ByRef stPanel As StatusPanel, MouseButton As Integer, x As Integer, y As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub ToolBar1_ButtonClick(ByRef Sender As ToolBar,ByRef Button As ToolButton)
		
		Declare Sub mnuCharSet_Click(ByRef Sender As MenuItem)
		Declare Sub mnuCodePage_Click(ByRef Sender As MenuItem)
		Declare Sub mnuConvert_Click(ByRef Sender As MenuItem)
		Declare Sub mnuEdit_Click(ByRef Sender As MenuItem)
		Declare Sub mnuFormat_Click(ByRef Sender As MenuItem)
		Declare Sub mnuEOLConvert_Click(ByRef Sender As MenuItem)
		Declare Sub mnuFile_Click(ByRef Sender As MenuItem)
		Declare Sub mnuHelp_Click(ByRef Sender As MenuItem)
		Declare Sub mnuTools_Click(ByRef Sender As MenuItem)
		Declare Sub mnuView_Click(ByRef Sender As MenuItem)
		Declare Sub mnuWindow_Click(ByRef Sender As MenuItem)
		
		Declare Constructor
		
		Dim As MainMenu MainMenu1
		Dim As MenuItem mnuFile, mnuFileNew, mnuFileOpen, mnuFileBar1, mnuFileSave, mnuFileSaveAs, mnuFileSaveAll, mnuFileBar2, mnuFileBrowse, mnuFileBar3, mnuFilePageSetup, mnuFilePrintPreview, mnuFilePrint, mnuFileBar4, mnuFileExit
		Dim As MenuItem mnuEdit, mnuEditRedo, mnuEditUndo, mnuEditBar1, mnuEditCut, mnuEditCopy, mnuEditPaste, mnuEditDelete, mnuEditBar2, mnuEditFileInsert, mnuEditBar3, mnuEditFind, mnuEditFindNext, mnuEditFindBack, mnuEditReplace, mnuEditGoto, mnuEditBar4, mnuEditSortA, mnuEditSortD, mnuEditBar5, mnuEditDSelectAll, mnuEditDateTime
		Dim As MenuItem mnuView, mnuViewToolbar, mnuViewStatusBar, mnuViewBar1, mnuViewDarkMode, mnuViewBar2, mnuViewWhitespace, mnuViewEOL, mnuViewLN, mnuViewCaretLine, mnuViewFold, mnuViewBar3, mnuViewWordWarps, mnuViewFont, mnuViewAllFont, mnuViewBackColor, mnuViewAllBackColor
		Dim As MenuItem mnuFormat, mnuEncodingPlainText, mnuEncodingUtf8, mnuEncodingUtf8BOM, mnuEncodingUtf16BOM, mnuEncodingUtf32BOM, mnuEncodingBar1, mnuEOLCRLF, mnuEOLLF, mnuEOLCR
		Dim As MenuItem mnuScintilla
		Dim As MenuItem mnuCharSet, mnuCharSet00, mnuCharSet01, mnuCharSet02, mnuCharSet03, mnuCharSet04, mnuCharSet05, mnuCharSet06, mnuCharSet07, mnuCharSet08, mnuCharSet09, mnuCharSet10, mnuCharSet11, mnuCharSet12, mnuCharSet13, mnuCharSet14, mnuCharSet15, mnuCharSet16, mnuCharSet17, mnuCharSet18, mnuCharSet19, mnuCharSet20, mnuCharSet21
		Dim As MenuItem mnuCodePage, mnuCodePage00, mnuCodePage01, mnuCodePage02, mnuCodePage03, mnuCodePage04, mnuCodePage05, mnuCodePage06
		Dim As MenuItem mnuConvert, mnuConvertTraditional, mnuConvertSimplified, mnuConvertBar1, mnuConvertFullWidth, mnuConvertHalfWidth, mnuConvertLowerCase, mnuConvertUpperCase, mnuConvertTitleCase, mnuConvertBar2, mnuConvertBIG5ToGB, mnuConvertGBToBIG5
		Dim As MenuItem mnuTools, mnuToolsFileSearch, mnuToolsFileSync, mnuToolsHash
		Dim As MenuItem mnuWindow, mnuWindowTileHorizontal, mnuWindowTileVertical, mnuWindowCascade, mnuWindowArrangeIcons, mnuWindowBar1, mnuWindowClose, mnuWindowCloseAll
		Dim As MenuItem mnuHelp, mnuHelpAbout
		Dim As MenuItem pmEncodingPT, pmEncodingUTF8, pmEncodingUTF8BOM, pmEncodingUTF16BOM, pmEncodingUTF32BOM, pmEOLCRLF, pmEOLLF, pmEOLCR
		Dim As ToolBar ToolBar1
		Dim As ToolButton tbFileNew, tbFileOpen, tbFileSave, tbFileSaveAll
		Dim As ToolButton ToolButton1, tbEditRedo, tbEditUndo, tbEditCut, tbEditCopy, tbEditPaste
		Dim As ToolButton ToolButton2, tbEditFind, tbEditFindNext, tbEditFindBack, tbEditReplace
		Dim As ToolButton ToolButton3, tbViewFont, tbViewBColor, tbViewDarkMode
		Dim As ToolButton ToolButton4, tbToolFileSearch, tbToolFileSync, tbToolHash
		Dim As ToolButton ToolButton5, tbWindowHorizontal, tbWindowVertical, tbWindowCascade, tbWindowIcon, tbWindowClose, tbWindowCloseAll
		Dim As StatusBar StatusBar1
		Dim As StatusPanel spFileName, spSpeed, spSpace, spLocation, spEncode, spEOL
		Dim As ImageList ImageList1, ImageList2
		Dim As ColorDialog ColorDialog1
		Dim As FontDialog FontDialog1
		Dim As OpenFileDialog OpenFileDialog1
		Dim As SaveFileDialog SaveFileDialog1
		Dim As TimerComponent TimerComponent1
		Dim As PrintDialog PrintDialog1
		Dim As PrintPreviewDialog PrintPreviewDialog1
		Dim As PageSetupDialog PageSetupDialog1
		Dim As PrintDocument PrintDocument1
		Dim As PopupMenu pmEncode, pmEOL
	End Type
	
	Constructor MDIMainType
		' MDIMain
		With This
			.Name = "MDIMain"
			.Text = "VFBE MDI Scintilla"
			.Designer = @This
			.Menu = @MainMenu1
			.FormStyle = FormStyles.fsMDIForm
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "MDIScintilla.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			.StartPosition = FormStartPosition.CenterScreen
			.AllowDrop = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.ContextMenu = @pmEncode
			.SetBounds 0, 0, 1024, 720
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.ImageWidth = 16
			.ImageHeight = 16
			.SetBounds 30, 30, 16, 16
			.Designer = @This
			.Add "About", "About"
			.Add "Add", "Add"
			.Add "Browser", "Browser"
			.Add "Cascade", "Cascade"
			.Add "Close", "Close"
			.Add "CloseAll", "CloseAll"
			.Add "Color", "Color"
			.Add "Copy", "Copy"
			.Add "Cut", "Cut"
			.Add "DarkMode", "DarkMode"
			.Add "Deleted", "Deleted"
			.Add "Exit", "Exit"
			.Add "File", "File"
			.Add "Find", "Find"
			.Add "FindBack", "FindBack"
			.Add "FindNext", "FindNext"
			.Add "Fonts", "Fonts"
			.Add "Horizontal", "Horizontal"
			.Add "Icons", "Icons"
			.Add "New", "New"
			.Add "Open", "Open"
			.Add "Paste", "Paste"
			.Add "Print", "Print"
			.Add "PrintPreview", "PrintPreview"
			.Add "PrintSetup", "PrintSetup"
			.Add "Redo", "Redo"
			.Add "Replace", "Replace"
			.Add "ReplaceAll", "ReplaceAll"
			.Add "ReplaceFile", "ReplaceFile"
			.Add "Save", "Save"
			.Add "SaveAll", "SaveAll"
			.Add "SaveAs", "SaveAs"
			.Add "StatusBar", "StatusBar"
			.Add "ToolBar", "ToolBar"
			.Add "Undo", "Undo"
			.Add "Vertical", "Vertical"
			.Add "FileSearch", "FileSearch"
			.Add "FileSync", "FileSync"
			.Add "Hash", "Hash"
			.Parent = @This
		End With
		' ImageList2
		With ImageList2
			.Name = "ImageList2"
			.SetBounds 50, 30, 16, 16
			.Designer = @This
			.Add "About", "About"
			.Add "Add", "Add"
			.Add "Browser", "Browser"
			.Add "CascadeD", "Cascade"
			.Add "CloseD", "Close"
			.Add "CloseAllD", "CloseAll"
			.Add "ColorD", "Color"
			.Add "CopyD", "Copy"
			.Add "CutD", "Cut"
			.Add "DarkModeD", "DarkMode"
			.Add "Deleted", "Deleted"
			.Add "Exit", "Exit"
			.Add "File", "File"
			.Add "FindD", "Find"
			.Add "FindBackD", "FindBack"
			.Add "FindNextD", "FindNext"
			.Add "FontsD", "Fonts"
			.Add "HorizontalD", "Horizontal"
			.Add "IconsD", "Icons"
			.Add "NewD", "New"
			.Add "OpenD", "Open"
			.Add "PasteD", "Paste"
			.Add "Print", "Print"
			.Add "PrintPreview", "PrintPreview"
			.Add "PrintSetup", "PrintSetup"
			.Add "RedoD", "Redo"
			.Add "ReplaceD", "Replace"
			.Add "ReplaceAll", "ReplaceAll"
			.Add "ReplaceFile", "ReplaceFile"
			.Add "SaveD", "Save"
			.Add "SaveAllD", "SaveAll"
			.Add "SaveAs", "SaveAs"
			.Add "StatusBar", "StatusBar"
			.Add "ToolBar", "ToolBar"
			.Add "UndoD", "Undo"
			.Add "VerticalD", "Vertical"
			.Add "FileSearch", "FileSearch"
			.Add "FileSync", "FileSync"
			.Add "Hash", "Hash"
			.Parent = @This
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.MultiSelect = True
			.Filter = "All Files (*.*)|*.*"
			.SetBounds 10, 50, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' SaveFileDialog1
		With SaveFileDialog1
			.Name = "SaveFileDialog1"
			.Filter = "All Files (*.*)|*.*"
			.SetBounds 30, 50, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' ColorDialog1
		With ColorDialog1
			.Name = "ColorDialog1"
			.SetBounds 50, 50, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' FontDialog1
		With FontDialog1
			.Name = "FontDialog1"
			.SetBounds 70, 50, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' PrintDialog1
		With PrintDialog1
			.Name = "PrintDialog1"
			.SetBounds 10, 70, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' PrintPreviewDialog1
		With PrintPreviewDialog1
			.Name = "PrintPreviewDialog1"
			.SetBounds 30, 70, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' PageSetupDialog1
		With PageSetupDialog1
			.Name = "PageSetupDialog1"
			.SetBounds 50, 70, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' ToolBar1
		With ToolBar1
			.Name = "ToolBar1"
			.Text = "ToolBar1"
			.Align = DockStyle.alTop
			.ImagesList = @ImageList1
			.HotImagesList = @ImageList1
			.DisabledImagesList = @ImageList2
			.Controls = 0
			.BorderStyle = BorderStyles.bsNone
			.SetBounds 0, 0, 1008, 26
			.Designer = @This
			.OnButtonClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ToolBar, ByRef Button As ToolButton), @ToolBar1_ButtonClick)
			.Parent = @This
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.ContextMenu = @pmEOL
			.SetBounds 0, 239, 334, 22
			.OnPanelClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As StatusBar, ByRef stPanel As StatusPanel, MouseButton As Integer, x As Integer, y As Integer), @StatusBar1_PanelClick)
			.Designer = @This
			.Parent = @This
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 10, 29, 16, 16
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
		' mnuEncodingPlainText
		With mnuEncodingPlainText
			.Name = "mnuEncodingPlainText"
			.Designer = @This
			.Caption = "Plain Text"
			.RadioItem = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuEncodingUtf8
		With mnuEncodingUtf8
			.Name = "mnuEncodingUtf8"
			.Designer = @This
			.Caption = "UTF-8"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuEncodingUtf8BOM
		With mnuEncodingUtf8BOM
			.Name = "mnuEncodingUtf8BOM"
			.Designer = @This
			.Caption = "UTF-8 (BOM)"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuEncodingUtf16BOM
		With mnuEncodingUtf16BOM
			.Name = "mnuEncodingUtf16BOM"
			.Designer = @This
			.Caption = "UTF-16 (BOM)"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuEncodingUtf32BOM
		With mnuEncodingUtf32BOM
			.Name = "mnuEncodingUtf32BOM"
			.Designer = @This
			.Caption = "UTF-32 (BOM)"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuEncodingBar1
		With mnuEncodingBar1
			.Name = "mnuEncodingBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFormat
		End With
		' mnuEOLCRLF
		With mnuEOLCRLF
			.Name = "mnuEOLCRLF"
			.Designer = @This
			.Caption = !"Windows (CRLF)"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuEOLLF
		With mnuEOLLF
			.Name = "mnuEOLLF"
			.Designer = @This
			.Caption = !"Linux (LF)"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuEOLCR
		With mnuEOLCR
			.Name = "mnuEOLCR"
			.Designer = @This
			.Caption = !"Macintosh (CR)"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFormat
		End With
		' mnuFileBrowse
		With mnuFileBrowse
			.Name = "mnuFileBrowse"
			.Designer = @This
			.Caption = "Browse"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.ImageKey = "Browse"
			.Parent = @mnuFile
		End With
		' mnuFormat
		With mnuFormat
			.Name = "mnuFormat"
			.Designer = @This
			.Caption = "Format"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @mnuFile
		End With
		' mnuFileBar3
		With mnuFileBar3
			.Name = "mnuFileBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFilePageSetup
		With mnuFilePageSetup
			.Name = "mnuFilePageSetup"
			.Designer = @This
			.Caption = "Print Set&up..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.ImageKey = "PrintSetup"
			.Parent = @mnuFile
		End With
		' mnuFilePrintPreview
		With mnuFilePrintPreview
			.Name = "mnuFilePrintPreview"
			.Designer = @This
			.Caption = "Print Pre&view"
			.MenuIndex = 11
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.ImageKey = "PrintPreview"
			.Parent = @mnuFile
		End With
		' mnuFilePrint
		With mnuFilePrint
			.Name = "mnuFilePrint"
			.Designer = @This
			.Caption = !"&Print...\tCtrl+P"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFile_Click)
			.ImageKey = "Print"
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
			.ImageKey = ""
			.Parent = @MainMenu1
		End With
		' mnuEditUndo
		With mnuEditUndo
			.Name = "mnuEditUndo"
			.Designer = @This
			.Caption = !"&Undo\tCtrl+Z"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "Undo"
			.Parent = @mnuEdit
		End With
		' mnuEditRedo
		With mnuEditRedo
			.Name = "mnuEditRedo"
			.Designer = @This
			.Caption = "&Redo"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "Redo"
			.Parent = @mnuEdit
		End With
		' mnuEditBar1
		With mnuEditBar1
			.Name = "mnuEditBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditCut
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
			.ImageKey = "Delete"
			.Parent = @mnuEdit
		End With
		' mnuEditBar2
		With mnuEditBar2
			.Name = "mnuEditBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditFileInsert
		With mnuEditFileInsert
			.Name = "mnuEditFileInsert"
			.Designer = @This
			.Caption = "File Insert..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "Add"
			.Parent = @mnuEdit
		End With
		' mnuEditBar3
		With mnuEditBar3
			.Name = "mnuEditBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditFind
		With mnuEditFind
			.Name = "mnuEditFind"
			.Designer = @This
			.Caption = !"Find...\tCtrl+F"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "Find"
			.Parent = @mnuEdit
		End With
		' mnuEditFindNext
		With mnuEditFindNext
			.Name = "mnuEditFindNext"
			.Designer = @This
			.Caption = !"Find Next\tF3"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "FindNext"
			.Parent = @mnuEdit
		End With
		' mnuEditFindBack
		With mnuEditFindBack
			.Name = "mnuEditFindBack"
			.Designer = @This
			.Caption = !"Find Back\tShift+F3"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "FindBack"
			.Parent = @mnuEdit
		End With
		' mnuEditReplace
		With mnuEditReplace
			.Name = "mnuEditReplace"
			.Designer = @This
			.Caption = !"Replace...\tCtrl+H"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "Replace"
			.Parent = @mnuEdit
		End With
		' mnuEditGoto
		With mnuEditGoto
			.Name = "mnuEditGoto"
			.Designer = @This
			.Caption = !"Goto...\tCtrl+G"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.ImageKey = "Goto"
			.Parent = @mnuEdit
		End With
		' mnuEditBar4
		With mnuEditBar4
			.Name = "mnuEditBar4"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditSortA
		With mnuEditSortA
			.Name = "mnuEditSortA"
			.Designer = @This
			.Caption = "Sort Lines Ascending"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditSortD
		With mnuEditSortD
			.Name = "mnuEditSortD"
			.Designer = @This
			.Caption = "Sort Lines Descending"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditBar5
		With mnuEditBar5
			.Name = "mnuEditBar5"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditDSelectAll
		With mnuEditDSelectAll
			.Name = "mnuEditDSelectAll"
			.Designer = @This
			.Caption = !"Select &All\tCtrl+A"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuEditDateTime
		With mnuEditDateTime
			.Name = "mnuEditDateTime"
			.Designer = @This
			.Caption = !"Date Time\tF5"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuEdit_Click)
			.Parent = @mnuEdit
		End With
		' mnuScintilla
		With mnuScintilla
			.Name = "mnuScintilla"
			.Designer = @This
			.Caption = "Scintilla"
			.Parent = @MainMenu1
		End With
		'mnuCharSet
		With mnuCharSet
			.Name = "mnuCharSet"
			.Designer = @This
			.Caption = "Char Set"
			.Parent = @mnuScintilla
		End With
		' mnuCharSet00
		With mnuCharSet00
			.Name = "mnuCharSet00"
			.Designer = @This
			.Tag = Cast(Any Ptr, 00)
			.Caption = "ANSI"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet01
		With mnuCharSet01
			.Name = "mnuCharSet01"
			.Designer = @This
			.Tag = Cast(Any Ptr, 01)
			.Caption = "DEFAULT"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet02
		With mnuCharSet02
			.Name = "mnuCharSet02"
			.Designer = @This
			.Tag = Cast(Any Ptr, 02)
			.Caption = "BALTIC"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet03
		With mnuCharSet03
			.Name = "mnuCharSet03"
			.Designer = @This
			.Tag = Cast(Any Ptr, 03)
			.Caption = "CHINESEBIG5"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet04
		With mnuCharSet04
			.Name = "mnuCharSet04"
			.Designer = @This
			.Tag = Cast(Any Ptr, 04)
			.Caption = "EASTEUROPE"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet05
		With mnuCharSet05
			.Name = "mnuCharSet05"
			.Designer = @This
			.Tag = Cast(Any Ptr, 05)
			.Caption = "GB2312"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet06
		With mnuCharSet06
			.Name = "mnuCharSet06"
			.Designer = @This
			.Tag = Cast(Any Ptr, 06)
			.Caption = "GREEK"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet07
		With mnuCharSet07
			.Name = "mnuCharSet07"
			.Designer = @This
			.Tag = Cast(Any Ptr, 07)
			.Caption = "HANGUL"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet08
		With mnuCharSet08
			.Name = "mnuCharSet08"
			.Designer = @This
			.Tag = Cast(Any Ptr, 08)
			.Caption = "MAC"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet09
		With mnuCharSet09
			.Name = "mnuCharSet09"
			.Designer = @This
			.Tag = Cast(Any Ptr, 09)
			.Caption = "OEM"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet10
		With mnuCharSet10
			.Name = "mnuCharSet10"
			.Designer = @This
			.Tag = Cast(Any Ptr, 10)
			.Caption = "RUSSIAN"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet11
		With mnuCharSet11
			.Name = "mnuCharSet11"
			.Designer = @This
			.Tag = Cast(Any Ptr, 11)
			.Caption = "OEM866"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet12
		With mnuCharSet12
			.Name = "mnuCharSet12"
			.Designer = @This
			.Tag = Cast(Any Ptr, 12)
			.Caption = "CYRILLIC"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet13
		With mnuCharSet13
			.Name = "mnuCharSet13"
			.Designer = @This
			.Tag = Cast(Any Ptr, 13)
			.Caption = "SHIFTJIS"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet14
		With mnuCharSet14
			.Name = "mnuCharSet14"
			.Designer = @This
			.Tag = Cast(Any Ptr, 14)
			.Caption = "SYMBOL"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet15
		With mnuCharSet15
			.Name = "mnuCharSet15"
			.Designer = @This
			.Tag = Cast(Any Ptr, 15)
			.Caption = "TURKISH"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet16
		With mnuCharSet16
			.Name = "mnuCharSet16"
			.Designer = @This
			.Tag = Cast(Any Ptr, 16)
			.Caption = "JOHAB"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet17
		With mnuCharSet17
			.Name = "mnuCharSet17"
			.Designer = @This
			.Tag = Cast(Any Ptr, 17)
			.Caption = "HEBREW"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet18
		With mnuCharSet18
			.Name = "mnuCharSet18"
			.Designer = @This
			.Tag = Cast(Any Ptr, 18)
			.Caption = "ARABIC"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet19
		With mnuCharSet19
			.Name = "mnuCharSet19"
			.Designer = @This
			.Tag = Cast(Any Ptr, 19)
			.Caption = "VIETNAMESE"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet20
		With mnuCharSet20
			.Name = "mnuCharSet20"
			.Designer = @This
			.Tag = Cast(Any Ptr, 20)
			.Caption = "THAI"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCharSet21
		With mnuCharSet21
			.Name = "mnuCharSet21"
			.Designer = @This
			.Tag = Cast(Any Ptr, 21)
			.Caption = "8859_15"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCharSet_Click)
			.Parent = @mnuCharSet
		End With
		' mnuCodePage
		With mnuCodePage
			.Name = "mnuCodePage"
			.Designer = @This
			.Caption = "Code Page"
			.Parent = @mnuScintilla
		End With
		' mnuCodePage00
		With mnuCodePage00
			.Name = "mnuCodePage00"
			.Designer = @This
			.Caption = "Default"
			.Tag = Cast(Any Ptr, 00)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCodePage_Click)
			.Parent = @mnuCodePage
		End With
		' mnuCodePage01
		With mnuCodePage01
			.Name = "mnuCodePage01"
			.Designer = @This
			.Caption = "UTF-8"
			.Tag = Cast(Any Ptr, 01)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCodePage_Click)
			.Parent = @mnuCodePage
		End With
		' mnuCodePage02
		With mnuCodePage02
			.Name = "mnuCodePage02"
			.Designer = @This
			.Caption = "Japanese Shift-JIS"
			.Tag = Cast(Any Ptr, 02)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCodePage_Click)
			.Parent = @mnuCodePage
		End With
		' mnuCodePage03
		With mnuCodePage03
			.Name = "mnuCodePage03"
			.Designer = @This
			.Caption = "Simplified Chinese GBK"
			.Tag = Cast(Any Ptr, 03)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCodePage_Click)
			.Parent = @mnuCodePage
		End With
		' mnuCodePage04
		With mnuCodePage04
			.Name = "mnuCodePage04"
			.Designer = @This
			.Caption = "Korean Unified Hangul Code"
			.Tag = Cast(Any Ptr, 04)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCodePage_Click)
			.Parent = @mnuCodePage
		End With
		' mnuCodePage05
		With mnuCodePage05
			.Name = "mnuCodePage05"
			.Designer = @This
			.Caption = "Traditional Chinese Big5"
			.Tag = Cast(Any Ptr, 05)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCodePage_Click)
			.Parent = @mnuCodePage
		End With
		' mnuCodePage06
		With mnuCodePage06
			.Name = "mnuCodePage06"
			.Designer = @This
			.Caption = "Korean Johab"
			.Tag = Cast(Any Ptr, 06)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuCodePage_Click)
			.Parent = @mnuCodePage
		End With
		' mnuView
		With mnuView
			.Name = "mnuView"
			.Designer = @This
			.Caption = "&View"
			.Parent = @MainMenu1
		End With
		' mnuViewToolbar
		With mnuViewToolbar
			.Name = "mnuViewToolbar"
			.Caption = "&Toolbar"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Checked = True
			.ImageKey = "ToolBar"
			.Parent = @mnuView
		End With
		' mnuViewStatusBar
		With mnuViewStatusBar
			.Name = "mnuViewStatusBar"
			.Caption = "Status &Bar"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Checked = True
			.ImageKey = "StatusBar"
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
			.Caption = "Dark Mode"
			.Checked = True
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.ImageKey = "DarkMode"
			.Parent = @mnuView
		End With
		' mnuViewBar2
		With mnuViewBar2
			.Name = "mnuViewBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuView
		End With
		' mnuViewWhitespace
		With mnuViewWhitespace
			.Name = "mnuViewWhitespace"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Caption = "White space"
			.Parent = @mnuView
		End With
		' mnuViewEOL
		With mnuViewEOL
			.Name = "mnuViewEOL"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Caption = "End of line"
			.Parent = @mnuView
		End With
		' mnuViewLN
		With mnuViewLN
			.Name = "mnuViewLN"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Caption = "Line number"
			.Parent = @mnuView
		End With
		' mnuViewCaretLine
		With mnuViewCaretLine
			.Name = "mnuViewCaretLine"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Caption = "Caret line"
			.Parent = @mnuView
		End With
		' mnuViewFold
		With mnuViewFold
			.Name = "mnuViewFold"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Caption = "Fold"
			.Checked = True
			.Parent = @mnuView
		End With
		' mnuViewBar3
		With mnuViewBar3
			.Name = "mnuViewBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuView
		End With
		' mnuViewWordWarps
		With mnuViewWordWarps
			.Name = "mnuViewWordWarps"
			.Designer = @This
			.Caption = "Word Warps"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.ImageKey = "WorkWarps"
			.Parent = @mnuView
		End With
		' mnuViewFont
		With mnuViewFont
			.Name = "mnuViewFont"
			.Caption = "Font..."
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.ImageKey = "Fonts"
			.Parent = @mnuView
		End With
		' mnuViewBackColor
		With mnuViewBackColor
			.Name = "mnuViewBackColor"
			.Designer = @This
			.Caption = "Back Color..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.ImageKey = "Color"
			.Parent = @mnuView
		End With
		' mnuViewAllFont
		With mnuViewAllFont
			.Name = "mnuViewAllFont"
			.Designer = @This
			.Caption = "All Font..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Parent = @mnuView
		End With
		' mnuViewAllBackColor
		With mnuViewAllBackColor
			.Name = "mnuViewAllBackColor"
			.Designer = @This
			.Caption = "All Back Color..."
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuView_Click)
			.Parent = @mnuView
		End With
		' mnuConvert
		With mnuConvert
			.Name = "mnuConvert"
			.Designer = @This
			.Caption = "Convert"
			.MenuIndex = 6
			.Parent =  @MainMenu1
		End With
		' mnuConvertTraditional
		With mnuConvertTraditional
			.Name = "mnuConvertTraditional"
			.Designer = @This
			.Caption = "Traditional"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertSimplified
		With mnuConvertSimplified
			.Name = "mnuConvertSimplified"
			.Designer = @This
			.Caption = "Simplified"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertBar1
		With mnuConvertBar1
			.Name = "mnuConvertBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuConvert
		End With
		' mnuConvertFullWidth
		With mnuConvertFullWidth
			.Name = "mnuConvertFullWidth"
			.Designer = @This
			.Caption = "Full Width"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertHalfWidth
		With mnuConvertHalfWidth
			.Name = "mnuConvertHalfWidth"
			.Designer = @This
			.Caption = "Half Width"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertLowerCase
		With mnuConvertLowerCase
			.Name = "mnuConvertLowerCase"
			.Designer = @This
			.Caption = "Lower Case"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertUpperCase
		With mnuConvertUpperCase
			.Name = "mnuConvertUpperCase"
			.Designer = @This
			.Caption = "Upper Case"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertTitleCase
		With mnuConvertTitleCase
			.Name = "mnuConvertTitleCase"
			.Designer = @This
			.Caption = "Title Case"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertBar2
		With mnuConvertBar2
			.Name = "mnuConvertBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuConvert
		End With
		' mnuConvertBIG5ToGB
		With mnuConvertBIG5ToGB
			.Name = "mnuConvertBIG5ToGB"
			.Designer = @This
			.Caption = "BIG5 to GB"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuConvertGBToBIG5
		With mnuConvertGBToBIG5
			.Name = "mnuConvertGBToBIG5"
			.Designer = @This
			.Caption = "GB to BIG5"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuConvert_Click)
			.Parent = @mnuConvert
		End With
		' mnuTools
		With mnuTools
			.Name = "mnuTools"
			.Caption = "Tools"
			.Designer = @This
			.Enabled = True
			.Parent = @MainMenu1
		End With
		' mnuToolsFileSearch
		With mnuToolsFileSearch
			.Name = "mnuToolsFileSearch"
			.Caption = "File Search"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuTools_Click)
			.ImageKey = "FileSearch"
			.Parent = @mnuTools
		End With
		' mnuToolsFileSync
		With mnuToolsFileSync
			.Name = "mnuToolsFileSync"
			.Caption = "File Sync"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuTools_Click)
			.ImageKey = "FileSync"
			.Parent = @mnuTools
		End With
		' mnuToolsHash
		With mnuToolsHash
			.Name = "mnuToolsHash"
			.Caption = "Hash"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuTools_Click)
			.ImageKey = "Hash"
			.Parent = @mnuTools
		End With
		' mnuWindow
		With mnuWindow
			.Name = "mnuWindow"
			.Caption = "&Window"
			.Designer = @This
			.Enabled = True
			.Parent = @MainMenu1
		End With
		' mnuWindowTileHorizontal
		With mnuWindowTileHorizontal
			.Name = "mnuWindowTileHorizontal"
			.Caption = "Tile &Horizontal"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.ImageKey = "Horizontal"
			.Parent = @mnuWindow
		End With
		' mnuWindowTileVertical
		With mnuWindowTileVertical
			.Name = "mnuWindowTileVertical"
			.Caption = "Tile &Vertical"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.ImageKey = "Vertical"
			.Parent = @mnuWindow
		End With
		' mnuWindowCascade
		With mnuWindowCascade
			.Name = "mnuWindowCascade"
			.Caption = "&Cascade"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.ImageKey = "Cascade"
			.Parent = @mnuWindow
		End With
		' mnuWindowArrangeIcons
		With mnuWindowArrangeIcons
			.Name= "mnuWindowArrangeIcons"
			.Caption = "&Arrange Icons"
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.ImageKey = "Icons"
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
			.Caption = "Close"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.ImageKey = "Close"
			.Parent = @mnuWindow
		End With
		' mnuWindowCloseAll
		With mnuWindowCloseAll
			.Name = "mnuWindowCloseAll"
			.Designer = @This
			.Caption = "Close All"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			.ImageKey = "CloseAll"
			.Parent = @mnuWindow
		End With
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
		' tbFileNew
		With tbFileNew
			.Name = "tbFileNew"
			.Designer = @This
			.ImageKey = "New"
			.Hint = "New text window"
			.Parent = @ToolBar1
		End With
		' tbFileOpen
		With tbFileOpen
			.Name = "tbFileOpen"
			.Designer = @This
			.ImageKey = "Open"
			.Hint = "Open text file"
			.Parent = @ToolBar1
		End With
		' tbFileSave
		With tbFileSave
			.Name = "tbFileSave"
			.Designer = @This
			.ImageKey = "Save"
			.Hint = "Save text file"
			.Parent = @ToolBar1
		End With
		' tbFileSaveAll
		With tbFileSaveAll
			.Name = "tbFileSaveAll"
			.Designer = @This
			.ImageKey = "SaveAll"
			.Hint = "Save all text file"
			.Parent = @ToolBar1
		End With
		' ToolButton1
		With ToolButton1
			.Name = "ToolButton1"
			.Designer = @This
			.Style = ToolButtonStyle.tbsSeparator
			.Width = -1
			.Parent = @ToolBar1
		End With
		' tbEditUndo
		With tbEditUndo
			.Name = "tbEditUndo"
			.Designer = @This
			.Hint = "Undo"
			.ImageKey = "Undo"
			.Parent = @ToolBar1
		End With
		' tbEditRedo
		With tbEditRedo
			.Name = "tbEditRedo"
			.Designer = @This
			.Hint = "Redo"
			.ImageKey = "Redo"
			.Parent = @ToolBar1
		End With
		' tbEditCut
		With tbEditCut
			.Name = "tbEditCut"
			.Designer = @This
			.ImageKey = "Cut"
			.Hint = "Cut"
			.Parent = @ToolBar1
		End With
		' tbEditCopy
		With tbEditCopy
			.Name = "tbEditCopy"
			.Designer = @This
			.ImageKey = "Copy"
			.Hint = "Copy"
			.Parent = @ToolBar1
		End With
		' tbEditPaste
		With tbEditPaste
			.Name = "tbEditPaste"
			.Designer = @This
			.ImageKey = "Paste"
			.Hint = "Paste"
			.Parent = @ToolBar1
		End With
		' ToolButton2
		With ToolButton2
			.Name = "ToolButton2"
			.Designer = @This
			.Style = ToolButtonStyle.tbsSeparator
			.Width = -1
			.Parent = @ToolBar1
		End With
		' tbEditFind
		With tbEditFind
			.Name = "tbEditFind"
			.Designer = @This
			.ImageKey = "Find"
			.Hint = "Find..."
			.Parent = @ToolBar1
		End With
		' tbEditFindNext
		With tbEditFindNext
			.Name = "tbEditFindNext"
			.Designer = @This
			.ImageKey = "FindNext"
			.Hint = "Find Next"
			.Parent = @ToolBar1
		End With
		' tbEditFindBack
		With tbEditFindBack
			.Name = "tbEditFindBack"
			.Designer = @This
			.ImageKey = "FindBack"
			.Hint = "Find Back"
			.Parent = @ToolBar1
		End With
		' tbEditReplace
		With tbEditReplace
			.Name = "tbEditReplace"
			.Designer = @This
			.ImageKey = "Replace"
			.Hint = "Replace"
			.Parent = @ToolBar1
		End With
		' ToolButton3
		With ToolButton3
			.Name = "ToolButton3"
			.Designer = @This
			.Style = ToolButtonStyle.tbsSeparator
			.Width = -1
			.Parent = @ToolBar1
		End With
		' tbViewFont
		With tbViewFont
			.Name = "tbViewFont"
			.Designer = @This
			.ImageKey = "Fonts"
			.Hint = "Font..."
			.Parent = @ToolBar1
		End With
		' tbViewBColor
		With tbViewBColor
			.Name = "tbViewBColor"
			.Designer = @This
			.ImageKey = "Color"
			.Hint = "Back Color..."
			.Parent = @ToolBar1
		End With
		' tbViewDarkMode
		With tbViewDarkMode
			.Name = "tbViewDarkMode"
			.Designer = @This
			.ImageKey = "DarkMode"
			.Hint = "Dark Mode"
			.Checked = True
			.Parent = @ToolBar1
		End With
		' ToolButton4
		With ToolButton4
			.Name = "ToolButton4"
			.Designer = @This
			.Style = ToolButtonStyle.tbsSeparator
			.Width = -1
			.Parent = @ToolBar1
		End With
		' tbToolFileSearch
		With tbToolFileSearch
			.Name = "tbToolFileSearch"
			.Designer = @This
			.ImageKey = "FileSearch"
			.Hint = "File Search"
			.Parent = @ToolBar1
		End With
		' tbToolFileSync
		With tbToolFileSync
			.Name = "tbToolFileSync"
			.Designer = @This
			.ImageKey = "FileSync"
			.Hint = "File Sync"
			.Parent = @ToolBar1
		End With
		' tbToolHash
		With tbToolHash
			.Name = "tbToolHash"
			.Designer = @This
			.ImageKey = "Hash"
			.Hint = "Hash"
			.Parent = @ToolBar1
		End With
		' ToolButton5
		With ToolButton5
			.Name = "ToolButton5"
			.Designer = @This
			.Style = ToolButtonStyle.tbsSeparator
			.Width = -1
			.Parent = @ToolBar1
		End With
		' tbWindowHorizontal
		With tbWindowHorizontal
			.Name = "tbWindowHorizontal"
			.Designer = @This
			.ImageKey = "Horizontal"
			.Hint = "Window Horizontal"
			.Parent = @ToolBar1
		End With
		' tbWindowVertical
		With tbWindowVertical
			.Name = "tbWindowVertical"
			.Designer = @This
			.ImageKey = "Vertical"
			.Hint = "Window Vertical"
			.Parent = @ToolBar1
		End With
		' tbWindowCascade
		With tbWindowCascade
			.Name = "tbWindowCascade"
			.Designer = @This
			.ImageKey = "Cascade"
			.Hint = "Window Cascade"
			.Parent = @ToolBar1
		End With
		' tbWindowIcon
		With tbWindowIcon
			.Name = "tbWindowIcon"
			.Designer = @This
			.ImageKey = "Icons"
			.Hint = "Window Icon"
			.Parent = @ToolBar1
		End With
		' tbWindowClose
		With tbWindowClose
			.Name = "tbWindowClose"
			.Designer = @This
			.ButtonIndex = 16
			.ImageKey = "Close"
			.Hint = "Window Close"
			.Parent = @ToolBar1
		End With
		' tbWindowCloseAll
		With tbWindowCloseAll
			.Name = "tbWindowCloseAll"
			.Designer = @This
			.ImageKey = "CloseAll"
			.Hint = "Window Close All"
			.Parent = @ToolBar1
		End With
		' spFileName
		With spFileName
			.Name = "spFileName"
			.Designer = @This
			.Width = 200
			.Parent = @StatusBar1
		End With
		' spSpeed
		With spSpeed
			.Name = "spSpeed"
			.Designer = @This
			.Width = 100
			.Parent = @StatusBar1
		End With
		' spSpace
		With spSpace
			.Name = "spSpace"
			.Designer = @This
			.Width = 200
			.Parent = @StatusBar1
		End With
		' spLocation
		With spLocation
			.Name = "spLocation"
			.Designer = @This
			.Width = 200
			.Parent = @StatusBar1
		End With
		' spEOL
		With spEOL
			.Name = "spEOL"
			.Designer = @This
			.Width = 120
			.Parent = @StatusBar1
		End With
		' spEncode
		With spEncode
			.Name = "spEncode"
			.Designer = @This
			.Width = 130
			.Parent = @StatusBar1
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 200
			.SetBounds 70, 30, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' PrintDocument1
		With PrintDocument1
			.Name = "PrintDocument1"
			.SetBounds 70, 70, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' pmEncode
		With pmEncode
			.Name = "pmEncode"
			.SetBounds 10, 100, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' pmEOL
		With pmEOL
			.Name = "pmEOL"
			.SetBounds 30, 100, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' pmEncodingPT
		With pmEncodingPT
			.Name = "pmEncodingPT"
			.Designer = @This
			.Caption = mnuEncodingPlainText.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEncode
		End With
		' pmEncodingUTF8
		With pmEncodingUTF8
			.Name = "pmEncodingUTF8"
			.Designer = @This
			.Caption = mnuEncodingUtf8.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEncode
		End With
		' pmEncodingUTF8BOM
		With pmEncodingUTF8BOM
			.Name = "pmEncodingUTF8BOM"
			.Designer = @This
			.Caption = mnuEncodingUtf8BOM.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEncode
		End With
		' pmEncodingUTF16BOM
		With pmEncodingUTF16BOM
			.Name = "pmEncodingUTF16BOM"
			.Designer = @This
			.Caption = mnuEncodingUtf16BOM.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEncode
		End With
		' pmEncodingUTF32BOM
		With pmEncodingUTF32BOM
			.Name = "pmEncodingUTF32BOM"
			.Designer = @This
			.Caption = mnuEncodingUtf32BOM.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEncode
		End With
		' pmEOLCRLF
		With pmEOLCRLF
			.Name = "pmEOLCRLF"
			.Designer = @This
			.Caption = mnuEOLCRLF.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEOL
		End With
		' pmEOLLF
		With pmEOLLF
			.Name = "pmEOLLF"
			.Designer = @This
			.Caption = mnuEOLLF.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEOL
		End With
		' pmEOLCR
		With pmEOLCR
			.Name = "pmEOLCR"
			.Designer = @This
			.Caption = mnuEOLCR.Caption
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuFormat_Click)
			.Parent = @pmEOL
		End With
	End Constructor
	
	#ifdef __FB_64BIT__
		' Load the Scintilla code editing dll
		Dim As Any Ptr pLibLexilla = DyLibLoad("Lexilla64.dll")
		Dim As Any Ptr pLibScintilla = DyLibLoad("Scintilla64.dll")
	#else
		' Load the Scintilla code editing dll
		Dim As Any Ptr pLibLexilla = DyLibLoad("Lexilla32.dll")
		Dim As Any Ptr pLibScintilla = DyLibLoad("Scintilla32.dll")
	#endif
	Dim Shared pfnCreateLexerfn As CreateLexerFn
	pfnCreateLexerfn = Cast(CreateLexerFn , GetProcAddress(pLibLexilla, "CreateLexer"))
	
	Dim Shared MDIMain As MDIMainType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		MDIMain.MainForm = True
		MDIMain.Show
		App.Run
	#endif
	
	DyLibFree(pLibLexilla)
	DyLibFree(pLibScintilla)
'#End Region

#include once "MDIChild.frm"
#include once "frmFindReplace.frm"
#include once "../MDINotepad/frmCodePage.frm"
#include once "../MDINotepad/frmFileSearch.frm"
#include once "../MDINotepad/frmFileSync.frm"
#include once "../MDINotepad/frmGoto.frm"
#include once "../MDINotepad/frmHash.frm"
#include once "../MDINotepad/MDIList.frm"

Private Sub MDIMainType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	mnuWindow_Click(mnuWindowCloseAll)
	If CloseResult = ModalResults.Cancel Then
		Action = False
	Else
		Deallocate(mCaption)
	End If
End Sub

Private Sub MDIMainType.Form_Create(ByRef Sender As Control)
	CharSetMnu(0) = @mnuCharSet00
	CharSetMnu(1) = @mnuCharSet01
	CharSetMnu(2) = @mnuCharSet02
	CharSetMnu(3) = @mnuCharSet03
	CharSetMnu(4) = @mnuCharSet04
	CharSetMnu(5) = @mnuCharSet05
	CharSetMnu(6) = @mnuCharSet06
	CharSetMnu(7) = @mnuCharSet07
	CharSetMnu(8) = @mnuCharSet08
	CharSetMnu(9) = @mnuCharSet09
	CharSetMnu(10) = @mnuCharSet10
	CharSetMnu(11) = @mnuCharSet11
	CharSetMnu(12) = @mnuCharSet12
	CharSetMnu(13) = @mnuCharSet13
	CharSetMnu(14) = @mnuCharSet14
	CharSetMnu(15) = @mnuCharSet15
	CharSetMnu(16) = @mnuCharSet16
	CharSetMnu(17) = @mnuCharSet17
	CharSetMnu(18) = @mnuCharSet18
	CharSetMnu(19) = @mnuCharSet19
	CharSetMnu(20) = @mnuCharSet20
	CharSetMnu(21) = @mnuCharSet21
	
	CodePageMnu(00) = @mnuCodePage00
	CodePageMnu(01) = @mnuCodePage01
	CodePageMnu(02) = @mnuCodePage02
	CodePageMnu(03) = @mnuCodePage03
	CodePageMnu(04) = @mnuCodePage04
	CodePageMnu(05) = @mnuCodePage05
	CodePageMnu(06) = @mnuCodePage06
	
	#ifdef __FB_64BIT__
		'...instructions for 64bit OSes...
		WLet(mCaption, "VFBE MDI Scintilla64" & fbcVer)
	#else
		'...instructions for other OSes
		WLet(mCaption, "VFBE MDI Scintilla32" & fbcVer)
	#endif
	Caption = *mCaption
	
	MenuEnabled(False)
	
	'Command line 命令行
	Dim As Integer i = 1
	Do
		If Len(Command(i)) = 0 Then Exit Do
		FileOpen(Command(i))
		i += 1
	Loop
End Sub

Private Sub MDIMainType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	FileOpen(Filename)
End Sub

Private Sub MDIMainType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	spFileName.Width = NewWidth - (spEOL.Width + spEncode.Width + spLocation.Width + spSpace.Width + spSpeed.Width)
End Sub

Private Sub MDIMainType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	TimerComponent1.Enabled = False
	
	Dim As Boolean b = False
	Dim As MDIChildType Ptr MDIChild
	For i As Integer = lstMdiChild.Count - 1 To 0 Step -1
		MDIChild = lstMdiChild.Item(i)
		If MDIChild->Destroied Then
			lstMdiChild.Remove(i)
			Delete MDIChild
			b = True
		End If
	Next
	'如果有窗口delete, 更新窗口菜单
	If b Then MDIChildMenuUpdate()
	'更新窗口菜单上的激活窗口
	If lstMdiChild.Count > 0 Then
		MDIChildActivate(ActMdiChild)
	Else
		MDIChildActivate(NULL)
	End If
End Sub

Private Sub MDIMainType.StatusBar1_PanelClick(ByRef Sender As StatusBar, ByRef stPanel As StatusPanel, MouseButton As Integer, x As Integer, y As Integer)
	Select Case stPanel.Name
	Case "spEncode"
		pmEncode.Popup(Left + StatusBar1.Left + x, Top + StatusBar1.Top + y)
	Case "spEOL"
		pmEOL.Popup(Left + StatusBar1.Left + x, Top + StatusBar1.Top + y)
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
		mnuFile_Click(mnuFileSaveAll)
		
	Case "tbEditUndo"
		mnuEdit_Click(mnuEditUndo)
	Case "tbEditRedo"
		mnuEdit_Click(mnuEditRedo)
	Case "tbEditCut"
		mnuEdit_Click(mnuEditCut)
	Case "tbEditCopy"
		mnuEdit_Click(mnuEditCopy)
	Case "tbEditPaste"
		mnuEdit_Click(mnuEditPaste)
		
	Case "tbEditFind"
		mnuEdit_Click(mnuEditFind)
	Case "tbEditFindNext"
		mnuEdit_Click(mnuEditFindNext)
	Case "tbEditFindBack"
		mnuEdit_Click(mnuEditFindBack)
	Case "tbEditReplace"
		mnuEdit_Click(mnuEditReplace)
		
	Case "tbViewFont"
		mnuView_Click(mnuViewFont)
	Case "tbViewBColor"
		mnuView_Click(mnuViewBackColor)
	Case "tbViewDarkMode"
		mnuView_Click(mnuViewDarkMode)
		
	Case "tbToolFileSearch"
		mnuTools_Click(mnuToolsFileSearch)
	Case "tbToolFileSync"
		mnuTools_Click(mnuToolsFileSync)
	Case "tbToolHash"
		mnuTools_Click(mnuToolsHash)
		
	Case "tbWindowHorizontal"
		mnuWindow_Click(mnuWindowTileHorizontal)
	Case "tbWindowVertical"
		mnuWindow_Click(mnuWindowTileVertical)
	Case "tbWindowCascade"
		mnuWindow_Click(mnuWindowCascade)
	Case "tbWindowIcon"
		mnuWindow_Click(mnuWindowArrangeIcons)
	Case "tbWindowClose"
		mnuWindow_Click(mnuWindowClose)
	Case "tbWindowCloseAll"
		mnuWindow_Click(mnuWindowCloseAll)
	Case Else
		MsgBox Button.Name & !"\r\nThis function is under construction", "ToolBar"
	End Select
End Sub

Private Sub MDIMainType.mnuFile_Click(ByRef Sender As MenuItem)
	Dim i As Integer
	Select Case Sender.Name
	Case "mnuFileNew"
		MDIChildNew("")
	Case "mnuFileSave"
		FileSave(ActMdiChild)
	Case "mnuFileSaveAs"
		FileSaveAs(ActMdiChild)
	Case "mnuFileSaveAll"
		For i = 0 To lstMdiChild.Count - 1
			FileSave(lstMdiChild.Item(i))
		Next
	Case "mnuFileOpen"
		If OpenFileDialog1.Execute() Then
			For i = 0 To OpenFileDialog1.FileNames.Count - 1
				FileOpen(OpenFileDialog1.FileNames.Item(i))
				App.DoEvents()
			Next
		End If
	Case "mnuFileBrowse"
		Exec ("c:\windows\explorer.exe" , "/select," & Cast(MDIChildType Ptr, ActMdiChild)->File)
	Case "mnuFilePageSetup"
		'Todo: PageSetupDialog1.Execute
		PageSetupDialog1.Execute
	Case "mnuFilePrintPreview"
		'Todo: PrintPreviewDialog1.Execute
		PrintPreviewDialog1.Execute
	Case "mnuFilePrint"
		'Todo: PrintDialog1.Execute
		PrintDialog1.Execute
	Case "mnuFileExit"
		ModalResult = ModalResults.OK
		CloseForm
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "File"
	End Select
End Sub

Private Sub MDIMainType.mnuFormat_Click(ByRef Sender As MenuItem)
	Dim As MDIChildType Ptr a = ActMdiChild
	
	Select Case Sender.Name
	Case "mnuEncodingPlainText", "pmEncodingPT"
		If SelectCodePage("", a->Encode, a->CodePage, 1) = False Then Exit Sub
	Case "mnuEncodingUtf8", "pmEncodingUTF8"
		a->Encode = FileEncodings.Utf8
	Case "mnuEncodingUtf8BOM", "pmEncodingUTF8BOM"
		a->Encode = FileEncodings.Utf8BOM
	Case "mnuEncodingUtf16BOM", "pmEncodingUTF16BOM"
		a->Encode = FileEncodings.Utf16BOM
	Case "mnuEncodingUtf32BOM", "pmEncodingUTF32BOM"
		a->Encode = FileEncodings.Utf32BOM
	Case "mnuEncodingCRLF", "pmEOLCRLF"
		a->NewLine = NewLineTypes.WindowsCRLF
	Case "mnuEncodingLF", "pmEOLLF"
		a->NewLine = NewLineTypes.LinuxLF
	Case "mnuEncodingCR", "pmEOLCR"
		a->NewLine = NewLineTypes.MacOSCR
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Format"
	End Select
	
	a->Changed = True
	MDIChildActivate(a)
End Sub

Private Sub MDIMainType.mnuEdit_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = ActMdiChild
	Select Case Sender.Name
	Case "mnuEditRedo"
		a->Editor.Redo
	Case "mnuEditUndo"
		a->Editor.Undo
	Case "mnuEditCut"
		a->Editor.Cut
	Case "mnuEditCopy"
		a->Editor.Copy
	Case "mnuEditPaste"
		a->Editor.Paste
	Case "mnuEditDelete"
		a->Editor.Clear
	Case "mnuEditSelectAll"
		a->Editor.SelectAll
	Case "mnuEditFind"
		If a->Editor.SelText <> "" Then frmFindReplace.txtFind.Text = a->Editor.SelText
		frmFindReplace.txtReplace.Visible= True
		frmFindReplace.cmd_Click(frmFindReplace.cmdShowHide)
		frmFindReplace.Show(MDIMain)
		frmFindReplace.txtFind.Text = a->Editor.SelText
	Case "mnuEditFindNext"
		If frmFindReplace.Handle= NULL AndAlso frmFindReplace.txtFind.Text = "" Then
			mnuEdit_Click(mnuEditFind)
		Else
			frmFindReplace.cmd_Click(frmFindReplace.cmdFindNext)
		End If
	Case "mnuEditFindBack"
		If frmFindReplace.Handle= NULL AndAlso frmFindReplace.txtFind.Text = "" Then
			mnuEdit_Click(mnuEditFind)
		Else
			frmFindReplace.cmd_Click(frmFindReplace.cmdFindNext)
		End If
	Case "mnuEditReplace"
		Dim i As Integer = a->Editor.SelLength
		frmFindReplace.txtReplace.Visible = False
		frmFindReplace.cmd_Click(frmFindReplace.cmdShowHide)
		frmFindReplace.Show(MDIMain)
		frmFindReplace.Show(MDIMain)
		frmFindReplace.txtFind.Text = a->Editor.SelText
	Case "mnuEditFileInsert"
		If OpenFileDialog1.Execute() Then
			FileInsert(a, OpenFileDialog1.FileName)
		End If
	Case "mnuEditSortA"
		SortLines(SortOrders.Ascending)
	Case "mnuEditSortD"
		SortLines(SortOrders.Descending)
	Case "mnuEditGoto"
		frmGoto.Show(MDIMain)
		MDIChildClick()
	Case "mnuEditDSelectAll"
		a->Editor.SelectAll
	Case "mnuEditDateTime"
		a->Editor.SelText = Format(Now, "yyyy-mm-dd hh:mm:ss")
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Sub MDIMainType.mnuEOLConvert_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = ActMdiChild
	Select Case Sender.Name
	Case "mnuConvertCRLF"
		a->Editor.EOLMode = SC_EOL_CRLF
		MDIChildActivate(ActMdiChild)
	Case "mnuConvertLF"
		a->Editor.EOLMode = SC_EOL_LF
		MDIChildActivate(ActMdiChild)
	Case "mnuConvertCR"
		a->Editor.EOLMode = SC_EOL_CR
		MDIChildActivate(ActMdiChild)
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Sub MDIMainType.mnuView_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = ActMdiChild
	Dim i As Integer
	
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
		tbViewDarkMode.Checked = Sender.Checked
		For i = 0 To lstMdiChild.Count - 1
			a = lstMdiChild.Item(i)
			a->Editor.DarkMode = Sender.Checked
		Next
		App.DarkMode = Sender.Checked
		InvalidateRect(0, 0, True)
	Case "mnuViewWhitespace"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		a->Editor.ViewWhiteSpace= Sender.Checked
	Case "mnuViewEOL"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		a->Editor.ViewEOL = Sender.Checked
	Case "mnuViewLN"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		a->Editor.ViewLineNo = IIf(Sender.Checked, 35, 0)
	Case "mnuViewCaretLine"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		a->Editor.ViewCaretLine = Sender.Checked
	Case "mnuViewFold"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		a->Editor.ViewFold = IIf(Sender.Checked, 20, 0)
	Case "mnuViewWordWarps"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		a->Editor.WordWraps = Sender.Checked
	Case "mnuViewFont"
		Dim a As MDIChildType Ptr = ActMdiChild
		FontDialog1.Font.Name = a->Editor.FontName(STYLE_DEFAULT)
		FontDialog1.Font.Size = a->Editor.FontSize(STYLE_DEFAULT)
		FontDialog1.Font.Bold = a->Editor.Bold(STYLE_DEFAULT)
		FontDialog1.Font.Italic = a->Editor.Italic(STYLE_DEFAULT)
		FontDialog1.Font.Underline = a->Editor.Underline(STYLE_DEFAULT)
		FontDialog1.Font.Color = a->Editor.ForeColor(STYLE_DEFAULT)
		If FontDialog1.Execute Then
			a->Editor.FontName(STYLE_DEFAULT) = FontDialog1.Font.Name
			a->Editor.FontSize(STYLE_DEFAULT) = FontDialog1.Font.Size
			a->Editor.Bold(STYLE_DEFAULT) = FontDialog1.Font.Bold
			a->Editor.Italic(STYLE_DEFAULT) = FontDialog1.Font.Italic
			a->Editor.Underline(STYLE_DEFAULT) = FontDialog1.Font.Underline
			a->Editor.ForeColor(STYLE_DEFAULT) = FontDialog1.Font.Color
		End If
		a->Editor.DarkMode = mnuViewDarkMode.Checked
	Case "mnuViewBackColor"
		Dim a As MDIChildType Ptr = ActMdiChild
		ColorDialog1.Color = a->Editor.BackColor(STYLE_DEFAULT)
		If ColorDialog1.Execute Then
			a->Editor.BackColor(STYLE_DEFAULT) = ColorDialog1.Color
		End If
	Case "mnuViewAllFont"
		Dim a As MDIChildType Ptr = ActMdiChild
		FontDialog1.Font.Name = a->Editor.FontName(STYLE_DEFAULT)
		FontDialog1.Font.Size = a->Editor.FontSize(STYLE_DEFAULT)
		FontDialog1.Font.Color = a->Editor.ForeColor(STYLE_DEFAULT)
		FontDialog1.Font.Bold = a->Editor.Bold(STYLE_DEFAULT)
		FontDialog1.Font.Italic = a->Editor.Italic(STYLE_DEFAULT)
		FontDialog1.Font.Underline = a->Editor.Underline(STYLE_DEFAULT)
		If FontDialog1.Execute Then
			For i = 0 To lstMdiChild.Count - 1
				a = lstMdiChild.Item(i)
				a->Editor.FontName(STYLE_DEFAULT) = FontDialog1.Font.Name
				a->Editor.FontSize(STYLE_DEFAULT) = FontDialog1.Font.Size
				a->Editor.ForeColor(STYLE_DEFAULT) = FontDialog1.Font.Color
				a->Editor.Bold(STYLE_DEFAULT) = FontDialog1.Font.Bold
				a->Editor.Italic(STYLE_DEFAULT) = FontDialog1.Font.Italic
				a->Editor.Underline(STYLE_DEFAULT) = FontDialog1.Font.Underline
			Next
		End If
	Case "mnuViewAllBackColor"
		Dim a As MDIChildType Ptr = ActMdiChild
		ColorDialog1.Color = a->Editor.BackColor(STYLE_DEFAULT)
		If ColorDialog1.Execute Then
			For i = 0 To lstMdiChild.Count - 1
				a = lstMdiChild.Item(i)
				a->Editor.BackColor(STYLE_DEFAULT) = ColorDialog1.Color
			Next
		End If
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "View"
	End Select
	RequestAlign
	InvalidateRect(Handle, NULL, False)
	UpdateWindow(Handle)
End Sub

Private Sub MDIMainType.mnuCharSet_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = ActMdiChild
	
	a->Editor.CharSet(STYLE_DEFAULT) = CharSetNum(Cast(Integer, Sender.Tag))
	MDIChildActivate(ActMdiChild)
End Sub

Private Sub MDIMainType.mnuCodePage_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = ActMdiChild
	
	a->Editor.CodePage = CodePageNum(Cast(Integer, Sender.Tag))
	MDIChildActivate(ActMdiChild)
End Sub

Private Sub MDIMainType.mnuConvert_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = ActMdiChild
	Dim t As WString Ptr
	
	Dim s As LongInt = a->Editor.SelStart
	Dim l As LongInt = a->Editor.SelLength
	
	If l Then
		t = StrPtr(a->Editor.SelText)
	Else
		t = StrPtr(a->Editor.Text)
	End If
	Dim k As LongInt = Len(*t) * 2 + 2
	Dim c As WString Ptr
	
	Select Case Sender.Name
	Case "mnuConvertTraditional"
		TextConvert(*t, c, LCMAP_TRADITIONAL_CHINESE)
	Case "mnuConvertSimplified"
		TextConvert(*t, c, LCMAP_SIMPLIFIED_CHINESE)
	Case "mnuConvertFullWidth"
		TextConvert(*t, c, LCMAP_FULLWIDTH)
	Case "mnuConvertHalfWidth"
		TextConvert(*t, c, LCMAP_HALFWIDTH)
	Case "mnuConvertLowerCase"
		TextConvert(*t, c, LCMAP_LOWERCASE)
	Case "mnuConvertUpperCase"
		TextConvert(*t, c, LCMAP_UPPERCASE)
	Case "mnuConvertTitleCase"
		TextConvert(*t, c, &h00000300) 'LCMAP_TITLECASE
	Case "mnuConvertBIG5ToGB"
		Dim As ZString Ptr b
		TextToAnsi(*t, b, CodePage_GB2312)
		Dim d As WString Ptr
		TextFromAnsi(*b, d, CodePage_BIG5)
		TextConvert(*d, c, LCMAP_SIMPLIFIED_CHINESE)
		If b Then Deallocate(b)
		If d Then Deallocate(d)
	Case "mnuConvertGBToBIG5"
		Dim d As WString Ptr
		TextConvert(*t, d, LCMAP_TRADITIONAL_CHINESE)
		Dim As ZString Ptr b
		TextToAnsi(*d, b, CodePage_BIG5)
		TextFromAnsi(*b, c, CodePage_GB2312)
		If d Then Deallocate(d)
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Convert"
	End Select
	
	If l Then
		a->Editor.SelText = *c
		a->Editor.SelStart = s
		a->Editor.SelLength = l
	Else
		a->Editor.Text = *c
		a->Editor.SelStart = s
	End If
	
	a->Changed = True
	If c Then Deallocate(c)
End Sub

Private Sub MDIMainType.mnuTools_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuToolsFileSearch"
		frmFileSearch.Show(MDIMain)
	Case "mnuToolsFileSync"
		frmFileSync.Show(MDIMain)
	Case "mnuToolsHash"
		frmHash.Show(MDIMain)
	End Select
End Sub

Private Sub MDIMainType.mnuWindow_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuWindowClose"
		Cast(MDIChildType Ptr, ActMdiChild)->CloseForm
	Case "mnuWindowCloseAll"
		Dim a As MDIChildType Ptr
		For i As Integer = lstMdiChild.Count - 1 To 0 Step -1
			a = lstMdiChild.Item(i)
			a->CloseForm
		Next
	Case "mnuWindowCascade"
		SendMessage FClient, WM_MDICASCADE, 0, 0
	Case "mnuWindowArrangeIcons"
		SendMessage FClient, WM_MDIICONARRANGE, 0, 0
	Case "mnuWindowTileHorizontal"
		SendMessage FClient, WM_MDITILE, MDITILE_HORIZONTAL, 0
	Case "mnuWindowTileVertical"
		SendMessage FClient, WM_MDITILE, MDITILE_VERTICAL, 0
	Case "mnuWindowMore"
		With MDIList
			.ShowModal(MDIMain)
			If .ModalResult = ModalResults.OK Then
				If .Tag = 0 Then Exit Sub
				Cast(MDIChildType Ptr, .Tag)->SetFocus()
			End If
		End With
	Case Else
		Cast(MDIChildType Ptr, Sender.Tag)->SetFocus()
	End Select
End Sub

Private Sub MDIMainType.mnuHelp_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuHelpAbout"
		MsgBox(!"Visual FB Editor\r\n\r\nMDI Scintilla Example\r\nBy Cm Wang\r\n2024", "MDI Scintilla Example")
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Function MDIMainType.MDIChildCloseConfirm(ByRef Child As Any Ptr) As MessageResult
	Dim a As MDIChildType Ptr = Child
	Dim msr As MessageResult = mrYes
	
	If a->Changed Then
		CloseResult = ModalResults.OK
		msr = MsgBox(!"Do you want to save the changes to?\r\n" & a->Text, "Confirm Close", mtQuestion, btYesNoCancel)
		Select Case msr
		Case mrYes
			msr = FileSave(Child)
		Case mrCancel
			CloseResult = ModalResults.Cancel
		End Select
	End If
	Return msr
End Function

Private Function MDIMainType.MDIChildFind(ByRef FileName As WString) As Integer
	Dim i As Integer
	Dim a As MDIChildType Ptr
	For i = 0 To lstMdiChild.Count - 1
		a = lstMdiChild.Item(i)
		If FileName = a->File Then
			Return i
		End If
	Next
	Return -1
End Function

Private Function MDIMainType.MDIChildNew(ByRef FileName As WString) As Any Ptr
	Dim Encode As FileEncodings = -1
	Dim CodePage As Integer = -1
	Dim NewLine As NewLineTypes = -1
	
	If FileName<> "" Then
		TextFileGetFormat(FileName, Encode, NewLine)
		If Encode = FileEncodings.PlainText Then
			If SelectCodePage(FileName, Encode, CodePage, 0) = False Then Return NULL
		End If
	Else
		Encode = FileEncodings.Utf8BOM
		CodePage = GetACP()
		NewLine = NewLineTypes.WindowsCRLF
	End If
	
	Static ChildIdx As Integer = 0
	Dim a As MDIChildType Ptr = New MDIChildType
	lstMdiChild.Add a
	ChildIdx += 1
	a->Index = ChildIdx
	a->Show(MDIMain)
	a->Editor.DarkMode = mnuViewDarkMode.Checked
	
	If FileName<> "" Then
		timr.Start
		a->Caption = "Loading [" & FullName2File(FileName) & "] ..."
		spFileName.Caption = a->Caption
		Dim p As WString Ptr
		TextFromFile(FileName, p, Encode, NewLine, CodePage)
		spSpeed.Caption = "Open " & Format(timr.Passed, "#,#0.000") & " sec."
		a->Editor.Text = *p
		SendMessage(a->Editor.Handle, SCI_EMPTYUNDOBUFFER, 0, 0)
		a->File = FileName
		If p Then Deallocate(p)
		spSpeed.Caption = "Load " & Format(timr.Passed, "#,#0.000") & " sec."
	End If
	a->Encode = Encode
	'a->NewLine = NewLine
	a->CodePage = CodePage
	a->Changed = False
	MDIChildMenuUpdate()
	MDIChildActivate(a)
	Return a
End Function

Private Sub MDIMainType.MDIChildActivate(ByRef Child As Any Ptr)
	ActMdiChild = Child
	Dim a As MDIChildType Ptr = ActMdiChild
	
	Dim i As Integer
	Dim j As Integer
	If a Then
		mnuViewWordWarps.Checked = a->Editor.WordWraps
		mnuEncodingPlainText.Caption = !"Plain Text (CP: " & IIf(a->CodePage < 0, GetACP(), a->CodePage) & ")"
		mnuEncodingPlainText.Checked = IIf(a->Encode = FileEncodings.PlainText, True, False)
		mnuEncodingUtf8.Checked = IIf(a->Encode = FileEncodings.Utf8, True, False)
		mnuEncodingUtf8BOM.Checked = IIf(a->Encode = FileEncodings.Utf8BOM, True, False)
		mnuEncodingUtf16BOM.Checked = IIf(a->Encode = FileEncodings.Utf16BOM, True, False)
		mnuEncodingUtf32BOM.Checked = IIf(a->Encode = FileEncodings.Utf32BOM, True, False)
		If a->NewLine < 0 Then a->NewLine= NewLineTypes.WindowsCRLF
		mnuEOLCRLF.Checked = IIf(a->NewLine = NewLineTypes.WindowsCRLF, True, False)
		mnuEOLLF.Checked = IIf(a->NewLine = NewLineTypes.LinuxLF, True, False)
		mnuEOLCR.Checked = IIf(a->NewLine = NewLineTypes.MacOSCR, True, False)
		
		Select Case a->Encode
		Case FileEncodings.Utf8
			spEncode.Caption = mnuEncodingUtf8.Caption
		Case FileEncodings.Utf8BOM
			spEncode.Caption = mnuEncodingUtf8BOM.Caption
		Case FileEncodings.Utf16BOM
			spEncode.Caption = mnuEncodingUtf16BOM.Caption
		Case FileEncodings.Utf32BOM
			spEncode.Caption = mnuEncodingUtf32BOM.Caption
		Case Else
			spEncode.Caption = mnuEncodingPlainText.Caption
		End Select
		
		Select Case a->NewLine
		Case NewLineTypes.LinuxLF
			spEOL.Caption = mnuEOLLF.Caption
		Case NewLineTypes.MacOSCR
			spEOL.Caption = mnuEOLCR.Caption
		Case Else
			spEOL.Caption = mnuEOLCRLF.Caption
		End Select
		
		If *a->mFile= "" Then
			SendMessage(Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(NULL, NULL, 0)))
		Else
			SendMessage(Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(a->IconHandle, a->FileInfo.iIcon, 0)))
		End If
		
		spFileName.Caption = a->TitleFileName
		Text = *mCaption & " - " & a->TitleFullName
		MenuEnabled(True)
		
		mnuViewWhitespace.Checked = a->Editor.ViewWhiteSpace
		mnuViewEOL.Checked = a->Editor.ViewEOL
		mnuViewLN.Checked = a->Editor.ViewLineNo
		mnuViewCaretLine.Checked = a->Editor.ViewCaretLine
		mnuViewFold.Checked = a->Editor.ViewFold
		
		j = a->Editor.CharSet(STYLE_DEFAULT)
		For i = 0 To CharSetCount
			If CharSetNum(i) = j Then
				CharSetMnu(i)->Checked = True
			Else
				CharSetMnu(i)->Checked = False
			End If
		Next
		
		j = a->Editor.CodePage
		For i = 0 To CodePageCount
			If CodePageNum(i) = j Then
				CodePageMnu(i)->Checked = True
			Else
				CodePageMnu(i)->Checked = False
			End If
		Next
		
		pmEncodingPT.Caption = mnuEncodingPlainText.Caption
		
		pmEncodingPT.Checked = mnuEncodingPlainText.Checked
		pmEncodingUTF8.Checked = mnuEncodingUtf8.Checked
		pmEncodingUTF8BOM.Checked = mnuEncodingUtf8BOM.Checked
		pmEncodingUTF16BOM.Checked = mnuEncodingUtf16BOM.Checked
		pmEncodingUTF32BOM.Checked = mnuEncodingUtf32BOM.Checked
		pmEOLCRLF.Checked = mnuEOLCRLF.Checked
		pmEOLLF.Checked = mnuEOLLF.Checked
		pmEOLCR.Checked = mnuEOLCR.Checked
	Else
		spFileName.Caption = ""
		spSpeed.Caption = ""
		spSpace.Caption = ""
		spLocation.Caption = ""
		spEncode.Caption = ""
		spEOL.Caption = ""
		SendMessage(Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(NULL, NULL, 0)))
		Text = *mCaption
		MenuEnabled(False)
	End If
	
	mnuWindowsAct = -1
	For i = 0 To mnuWindowCount
		If mnuWindows(i)->Tag = ActMdiChild Then
			mnuWindows(i)->Checked = True
			mnuWindowsAct = i
		Else
			mnuWindows(i)->Checked = False
		End If
	Next
End Sub

Private Sub MDIMainType.MDIChildClick()
	If ActMdiChild = NULL Then Exit Sub
	Dim As MDIChildType Ptr a = ActMdiChild
	Dim As Integer sx, sy, ex, ey
	Dim As Integer s, e
	
	s = a->Editor.SelStart
	e = a->Editor.SelEnd
	sy = a->Editor.GetPosY(s)
	sx = a->Editor.GetPosX(s)
	
	Text = *mCaption & " - " & a->TitleFullName
	spFileName.Caption = a->TitleFileName
	If mnuWindowsAct >= 1 Then mnuWindows(mnuWindowsAct)->Caption = a->TitleFileName
	
	spSpace.Caption = "Length: " & Format(a->Editor.Length, "#,#0") & "  Lines: " & Format(a->Editor.LineCount, "#,#0")
	
	If s = e Then
		spLocation.Caption = "Ln: " & Format(sy + 1, "#,#0") & "  Col: " & Format(sx + 1, "#,#0") & "  Pos: " & Format(s + 1, "#,#0")
		'spSpeed.Caption = "Zoom " & a->Editor.Zoom
	Else
		ey = a->Editor.GetPosY(e)
		ex = a->Editor.GetPosX(e)
		
		spLocation.Caption = "Ln: " & Format(sy + 1, "#,#0") & "  Col: " & Format(sx + 1, "#,#0") & "  Sel: " & Format(Abs(e - s), "#,#0") & "|" & Format(Abs(ey - sy + 1), "#,#0")
	End If
	
	If frmGoto.Handle Then
		frmGoto.lblMsg.Text = "Line number (1 -" & a->Editor.LineCount & ")"
		frmGoto.txtLineNo.Text = "" & sy + 1
	End If
End Sub

Private Sub MDIMainType.MDIChildDestroy(ByRef Child As Any Ptr)
	Cast(MDIChildType Ptr, Child)->Destroied = True
	TimerComponent1.Enabled = False
	TimerComponent1.Enabled = True
End Sub

Private Sub MDIMainType.MDIChildDoubleClick(ByRef Child As Any Ptr)
	Dim a As MDIChildType Ptr = Child
	frmFindReplace.txtFind.Text = a->Editor.SelText
	a->Editor.Find(a->Editor.SelTxtData, fRegExp, fMatchCase, fFindWarp, fFindBack)
	If frmFindReplace.Handle Then
		frmFindReplace.lblStatus.Text = "Found " & a->Editor.FindIndex + 1 & " of " & a->Editor.FindCount + 1
	Else
		spSpeed.Caption = "Found " & a->Editor.FindIndex + 1 & " of " & a->Editor.FindCount + 1
	End If
End Sub

Private Sub MDIMainType.MDIChildInsertText(ByRef Child As Any Ptr, ByRef Text As WString)
	Dim a As MDIChildType Ptr = Child
	Dim i As Long = a->Editor.SelStart
	a->Editor.SelText = Text
	a->Editor.SelStart = i
	Dim t As ZString Ptr
	TextToSciData(Text, t, a->Editor.CodePage)
	a->Editor.SelLength = Len(*t)
	If t Then Deallocate(t)
End Sub

Private Sub MDIMainType.MDIChildMenuUpdate()
	Dim As Integer i, j, mMax = 5 'form 0 to mMax
	
	'delete and release menu
	For i = mnuWindowCount To 0 Step -1
		mnuWindow.Remove(mnuWindows(i))
		Delete mnuWindows(i)
	Next
	Erase mnuWindows
	
	'disable/enabled window menu
	mnuWindowCount = lstMdiChild.Count
	If mnuWindowCount = 0 Then
		mnuWindow.Enabled = False
		mnuWindowCount = -1
		If frmFindReplace.Visible Then frmFindReplace.CloseForm
		If frmGoto.Visible Then frmGoto.CloseForm
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
				mnuWindows(i)->Caption = Cast(MDIChildType Ptr, lstMdiChild.Item(i - 1))->TitleFileName
				mnuWindows(i)->Tag = lstMdiChild.Item(i - 1)
				mnuWindows(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
			End If
			mnuWindow.Add mnuWindows(i)
		Next
		
		'create a list... menu
		If j = mnuWindowCount Then Exit Sub
		i = mnuWindowCount
		mnuWindows(i) = New MenuItem
		mnuWindows(i)->Designer = @This
		mnuWindows(i)->Parent = @mnuWindow
		mnuWindows(i)->Name= "mnuWindowMore"
		mnuWindows(i)->Caption = "More Windows..."
		mnuWindows(i)->OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem), @mnuWindow_Click)
		mnuWindow.Add mnuWindows(i)
		
	End If
End Sub

Private Sub MDIMainType.MenuEnabled(Enabled As Boolean)
	'menu
	mnuFileSave.Enabled = Enabled
	mnuFileSaveAs.Enabled = Enabled
	mnuFileSaveAll.Enabled = Enabled
	mnuFileBar2.Enabled = Enabled
	mnuFormat.Enabled = Enabled
	mnuFileBrowse.Enabled = Enabled
	mnuFileBar3.Enabled = Enabled
	mnuFilePageSetup.Enabled = Enabled
	mnuFilePrintPreview.Enabled = Enabled
	mnuFilePrint.Enabled = Enabled
	mnuFileBar4.Enabled = Enabled
	
	mnuEdit.Enabled = Enabled
	
	mnuViewBar2.Enabled = Enabled
	mnuViewWhitespace.Enabled = Enabled
	mnuViewEOL.Enabled = Enabled
	mnuViewLN.Enabled = Enabled
	mnuViewCaretLine.Enabled = Enabled
	mnuViewFold.Enabled = Enabled
	mnuViewBar3.Enabled = Enabled
	mnuViewWordWarps.Enabled = Enabled
	mnuViewFont.Enabled = Enabled
	mnuViewBackColor.Enabled = Enabled
	mnuViewAllFont.Enabled = Enabled
	mnuViewAllBackColor.Enabled = Enabled
	
	mnuCharSet.Enabled = Enabled
	mnuCodePage.Enabled = Enabled
	mnuConvert.Enabled = Enabled
	mnuWindow.Enabled = Enabled
	
	'toolbar
	tbFileSave.Enabled = Enabled
	tbFileSaveAll.Enabled = Enabled
	
	tbEditRedo.Enabled = Enabled
	tbEditUndo.Enabled = Enabled
	tbEditCut.Enabled = Enabled
	tbEditCopy.Enabled = Enabled
	tbEditPaste.Enabled = Enabled
	
	tbEditFind.Enabled = Enabled
	tbEditFindNext.Enabled = Enabled
	tbEditFindBack.Enabled = Enabled
	tbEditReplace.Enabled = Enabled
	
	tbViewFont.Enabled = Enabled
	tbViewBColor.Enabled = Enabled
	
	tbWindowHorizontal.Enabled = Enabled
	tbWindowVertical.Enabled = Enabled
	tbWindowCascade.Enabled = Enabled
	tbWindowIcon.Enabled = Enabled
	tbWindowClose.Enabled = Enabled
	tbWindowCloseAll.Enabled = Enabled
	
	StatusBar1.Enabled = Enabled
	UpdateWindow(Handle)
End Sub

Private Sub MDIMainType.FileInsert(ByRef Child As Any Ptr, ByRef FileName As WString)
	Dim Encode As FileEncodings = -1
	Dim NewLine As NewLineTypes = -1
	Dim CodePage As Integer = -1
	TextFileGetFormat(FileName, Encode, NewLine)
	If Encode = FileEncodings.PlainText Then
		If SelectCodePage(FileName, Encode, CodePage, 0) = False Then Exit Sub
	End If
	timr.Start
	Dim p As WString Ptr
	TextFromFile(FileName, p, Encode, NewLine, CodePage)
	MDIChildInsertText(Child, !"\r\nFile Insert Start Here: " & FileName & !"\r\n" & *p & !"\r\nFile Insert End Here: " & FileName & !"!\r\n")
	If p Then Deallocate(p)
	spSpeed.Caption = "Insert " & Format(timr.Passed, "#,#0.000") & " sec."
End Sub

Private Sub MDIMainType.FileOpen(ByRef FileName As WString)
	Dim a As MDIChildType Ptr
	Dim i As Integer = MDIChildFind(FileName)
	If i < 0 Then
		MDIChildNew(FileName)
	Else
		a = lstMdiChild.Item(i)
		a->SetFocus()
	End If
End Sub

Private Function MDIMainType.FileSave(ByRef Child As Any Ptr) As MessageResult
	Dim msr As MessageResult = MessageResult.mrYes
	Dim a As MDIChildType Ptr = Child
	If a->File= "" Then
		msr = FileSaveAs(a)
		If msr = MessageResult.mrCancel Then CloseResult = ModalResults.Cancel Else CloseResult = ModalResults.OK
	Else
		timr.Start
		TextToFile(a->File, a->Editor.Text, a->Encode, a->NewLine, a->CodePage)
		a->Changed = False
		spSpeed.Caption = "Save " & Format(timr.Passed, "#,#0.000") & " sec."
	End If
	Return msr
End Function

Private Function MDIMainType.FileSaveAs(ByRef Child As Any Ptr) As MessageResult
	Dim a As MDIChildType Ptr = Child
	Dim msr As MessageResult = MessageResult.mrYes
	SaveFileDialog1.Caption = "Save as: " & a->Text
	If SaveFileDialog1.Execute() Then
		If PathFileExists(SaveFileDialog1.FileName) Then
			msr = MsgBox("[" & SaveFileDialog1.FileName & !"] already exists.\r\nDo you want to replace it?", "Confirm Save As", mtInfo, btYesNo)
			If msr = MessageResult.mrYes Then
			Else
				msr = MessageResult.mrCancel
			End If
		End If
		If msr = mrYes Then
			a->File = SaveFileDialog1.FileName
			FileSave(Child)
		End If
	Else
		msr = MessageResult.mrCancel
	End If
	If msr = MessageResult.mrCancel Then CloseResult = ModalResults.Cancel
	Return msr
End Function

Private Sub MDIMainType.Find(ByRef FindStr As Const WString, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False, ByVal FindForce As Boolean = False)
	If FindStr = "" Then Exit Sub
	
	timr.Start
	Dim a As MDIChildType Ptr = ActMdiChild
	Dim p As Integer
	Dim t As ZString Ptr
	TextToSciData(FindStr, t, a->Editor.CodePage)
	
	fRegExp = RegularExp
	fMatchCase= MatchCase
	fFindWarp = FindWarp
	fFindBack = FindBack
	
	a->Editor.Find(*t, fRegExp, fMatchCase, fFindWarp, fFindBack, True, FindForce)
	If a->Editor.FindCount < 0 Then Exit Sub
	
	SendMessage(a->Editor.Handle, SCI_GOTOPOS, a->Editor.FindPoses(a->Editor.FindIndex), 0)
	a->Editor.SelStart = a->Editor.FindPoses(a->Editor.FindIndex)
	a->Editor.SelLength = a->Editor.FindLength
	'SendMessage(a->Editor.Handle, SCI_SCROLLCARET, 0, 0)
	If t Then Deallocate(t)
	spSpeed.Caption = "Find " & Format(timr.Passed, "#,#0.000") & " sec."
End Sub

Private Sub MDIMainType.Replace(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False, ByVal FindWarp As Boolean = True)
	Dim t As TimeMeter
	t.Start
	Dim a As MDIChildType Ptr = ActMdiChild
	If a->Editor.SelText <> "" Then
		a->Editor.SelText = ReplaceStr
		a->Changed = True
	End If
	fRegExp = RegularExp
	fMatchCase= MatchCase
	fFindWarp = FindWarp
	Find(FindStr, fRegExp, fMatchCase, fFindWarp, fFindBack, True)
	MDIChildClick()
	spSpeed.Caption = "Replace " & Format(t.Passed, "#,#0.000") & " sec."
End Sub

Private Function MDIMainType.ReplaceAll(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal RegularExp As Boolean = False, ByVal MatchCase As Boolean = False) As Integer
	timr.Start
	Dim a As MDIChildType Ptr = ActMdiChild
	Dim f As ZString Ptr
	TextToSciData(FindStr, f, a->Editor.CodePage)
	Dim r As ZString Ptr
	TextToSciData(ReplaceStr, r, a->Editor.CodePage)
	fRegExp = RegularExp
	fMatchCase= MatchCase
	Dim i As Integer = a->Editor.ReplaceAll(*f, *r, fRegExp, fMatchCase)
	If f Then Deallocate(f)
	If r Then Deallocate(r)
	MDIChildClick()
	spSpeed.Caption = "Replace All " & Format(timr.Passed, "#,#0.000") & " sec."
	Return i
End Function

'行排序
Private Sub MDIMainType.SortLines(SortOrder As SortOrders)
	timr.Start
	Dim As MDIChildType Ptr a = ActMdiChild
	Dim As WString Ptr wsa(), ws
	Dim As Integer i, iStr, iEnd
	
	iStr = a->Editor.SelStart
	iEnd = a->Editor.SelEnd
	If a->Editor.SelLength < 1 Then
		i = SplitWStr(a->Editor.Text, vbCrLf, wsa())
		If i Then
			If SortArray(wsa(), SortOrder) Then
				JoinWStr(wsa(), vbCrLf, ws)
				a->Editor.Text = *ws
				a->Changed = True
			End If
		End If
	Else
		i = SplitWStr(a->Editor.SelText, vbCrLf, wsa())
		If i Then
			If SortArray(wsa(), SortOrder) Then
				JoinWStr(wsa(), vbCrLf, ws)
				a->Editor.SelText = *ws
				a->Changed = True
			End If
		End If
	End If
	a->Editor.SelStart = iStr
	a->Editor.SelEnd = iEnd
	If ws Then Deallocate(ws)
	ArrayDeallocate(wsa())
	spSpeed.Caption = "Sort " & Format(timr.Passed, "#,#0.000") & " sec."
End Sub

Private Sub MDIMainType.GotoLineNo(ByVal LineNumber As Integer)
	timr.Start
	Dim a As MDIChildType Ptr = ActMdiChild
	a->Editor.GotoLine(LineNumber)
	MDIChildClick()
	spSpeed.Caption = "Goto " & Format(timr.Passed, "#,#0.000") & " sec."
End Sub

