#ifdef __FB_WIN32__
	#ifdef __FB_64BIT__
		'#Compile -dll -x "../../AddIns/My Add-In (x64).dll" "My Add-In.rc"
	#else
		'#Compile -dll -x "../../AddIns/My Add-In (x32).dll" "My Add-In.rc"
	#endif
#else
	#ifdef __FB_64BIT__
		'#Compile -dll -x "../../AddIns/MyAddInx64.so"
	#else
		'#Compile -dll -x "../../AddIns/MyAddInx32.so"
	#endif
#endif

Enum MessageType '...'
	mtInfo
	mtWarning
	mtQuestion
	mtError
	mtOther
End Enum

Enum ButtonsTypes '...'
	btNone
	btOK
	btYesNo
	btYesNoCancel
	btOkCancel
End Enum

Enum MessageResult '...'
	mrAbort
	mrCancel
	mrIgnore
	mrNo
	mrOK
	mrRetry
	mrYes
End Enum

Type MFFLib
	MsgBox As Function(ByRef MsgStr As WString, ByRef Caption As WString = "", MsgType As Integer = 0, ButtonsType As Integer = 1) As Integer
	ReadProperty As Function(Obj As Any Ptr, ByRef PropertyName As String) As Any Ptr
	ApplicationMainForm As Function(App As Any Ptr) As Any Ptr
	ControlByName As Function(Ctrl As Any Ptr, CtrlName As String) As Any Ptr
	ToolBarAddButtonWithImageKey As Function(tb As Any Ptr, FStyle As Integer = 16, ByRef FImageKey As WString = "", Index As Integer = -1, FClick As Any Ptr = 0, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As Integer = 4) As Any Ptr
	ToolBarRemoveButton As Sub(tb As Any Ptr, Index As Integer)
	ToolBarIndexOfButton As Function(tb As Any Ptr, btn As Any Ptr) As Integer
	MenuItemAdd As Function(ParentMenuItem As Any Ptr, ByRef sCaption As WString, ByRef sImageKey As WString, sKey As String = "", eClick As Any Ptr = 0, Index As Integer = -1) As Any Ptr
	MenuItemIndexOfKey As Function(ParentMenuItem As Any Ptr, ByRef Key As WString) As Integer
	MenuItemRemove As Sub(ParentMenuItem As Any Ptr, PMenuItem As Any Ptr)
	MenuFindByName As Function(PMenu As Any Ptr, ByRef FName As WString) As Any Ptr
	ObjectDelete As Function(Obj As Any Ptr) As Boolean
End Type

Dim Shared mff As MFFLib
Dim Shared VFBEditorLib As Any Ptr
Dim Shared VFBEditorApp As Any Ptr

Sub LoadMFFProcs()
	mff.MsgBox = DyLibSymbol(VFBEditorLib, "MsgBox")
	mff.ReadProperty = DyLibSymbol(VFBEditorLib, "ReadProperty")
	mff.ApplicationMainForm = DyLibSymbol(VFBEditorLib, "ApplicationMainForm")
	mff.ControlByName = DyLibSymbol(VFBEditorLib, "ControlByName")
	mff.ToolBarAddButtonWithImageKey = DyLibSymbol(VFBEditorLib, "ToolBarAddButtonWithImageKey")
	mff.ToolBarRemoveButton = DyLibSymbol(VFBEditorLib, "ToolBarRemoveButton")
	mff.ToolBarIndexOfButton = DyLibSymbol(VFBEditorLib, "ToolBarIndexOfButton")
	mff.MenuItemAdd = DyLibSymbol(VFBEditorLib, "MenuItemAdd")
	mff.MenuItemIndexOfKey = DyLibSymbol(VFBEditorLib, "MenuItemIndexOfKey")
	mff.MenuItemRemove = DyLibSymbol(VFBEditorLib, "MenuItemRemove")
	mff.MenuFindByName = DyLibSymbol(VFBEditorLib, "MenuFindByName")
	mff.ObjectDelete = DyLibSymbol(VFBEditorLib, "ObjectDelete")
End Sub

Dim Shared As Any Ptr MainForm, MainReBar
Dim Shared As Any Ptr tbStandard, tbMyAddin, tbMyAddinSeparator
Dim Shared As Any Ptr mnuService, mnuMyAddin, mnuMyAddinSeparator

Dim Shared s As WString Ptr
Function GetFolderPath(ByRef FileName As WString) ByRef As WString
	Dim Pos1 As Long = InStrRev(FileName, "\")
	Dim Pos2 As Long = InStrRev(FileName, "/")
	If Pos1 = 0 OrElse Pos2 > Pos1 Then Pos1 = Pos2
	If Pos1 > 0 Then
		s = Cast(WString Ptr, Reallocate(s, Pos1 * SizeOf(WString)))
		*s = Left(FileName, Pos1)
		Return *s
	End If
	Return ""
End Function

Sub OnMyAddinButtonClick(ByRef Sender As Object)
	If mff.MsgBox <> 0 Then
		mff.MsgBox(*Cast(WString Ptr, mff.ReadProperty(VFBEditorApp, "exefile")))
	End If
End Sub

Sub OnBeforeCompile Alias "OnBeforeCompile" (VisualFBEditorApp As Any Ptr, ByRef CompilingProgramPath As WString) Export
	If mff.MsgBox <> 0 Then
		mff.MsgBox(CompilingProgramPath)
	End If
End Sub

Sub OnConnection Alias "OnConnection"(VisualFBEditorApp As Any Ptr, ByRef AppPath As WString) Export
	VFBEditorApp = VisualFBEditorApp
	
	#ifdef __FB_WIN32__
		#ifdef __FB_64BIT__
			VFBEditorLib = DyLibLoad(GetFolderPath(AppPath) & "/Controls/MyFbFramework/mff64.dll")
		#else
			VFBEditorLib = DyLibLoad(GetFolderPath(AppPath) & "/Controls/MyFbFramework/mff32.dll")
		#endif
	#else
		VFBEditorLib = DyLibLoad(GetFolderPath(AppPath) & "/Controls/MyFbFramework/libmff" & Right(AppPath, 7) & ".so")
	#endif
	If s <> 0 Then Deallocate s
	
	If VFBEditorLib = 0 Then Exit Sub
	
	LoadMFFProcs
	
	If mff.ApplicationMainForm <> 0 Then
		MainForm = mff.ApplicationMainForm(VisualFBEditorApp)
		If MainForm <> 0 Then
			If mff.ControlByName <> 0 Then
				MainReBar = mff.ControlByName(MainForm, "MainReBar")
				If MainReBar <> 0 Then
					tbStandard = mff.ControlByName(MainReBar, "Standard")
					If tbStandard <> 0 AndAlso mff.ToolBarAddButtonWithImageKey <> 0 Then
						tbMyAddinSeparator = mff.ToolBarAddButtonWithImageKey(tbStandard, 1, "MyAddinSeparator")
						tbMyAddin = mff.ToolBarAddButtonWithImageKey(tbStandard, , "About", , @OnMyAddinButtonClick, "MyAddin", , "My Add-In", True)
					End If
				End If
			End If
			If mff.ReadProperty <> 0 AndAlso mff.MenuFindByName <> 0 Then
				Dim As Any Ptr mnuMenu = mff.ReadProperty(MainForm, "Menu")
				mnuService = mff.MenuFindByName(mnuMenu, "Service")
				If mnuService <> 0 AndAlso mff.MenuItemAdd <> 0 Then
					Var IndexOfKey = mff.MenuItemIndexOfKey(mnuService, "AddIns")
					mnuMyAddinSeparator = mff.MenuItemAdd(mnuService, "-", "", "", , IndexOfKey + 1)
					mnuMyAddin = mff.MenuItemAdd(mnuService, "My Add-In", "About", , @OnMyAddinButtonClick, IndexOfKey + 2)
				End If
			End If
		End If
	End If
	
End Sub

Sub OnDisconnection Alias "OnDisconnection"(VisualFBEditorApp As Any Ptr) Export
	If tbStandard <> 0 AndAlso mff.ToolBarRemoveButton <> 0 AndAlso mff.ToolBarIndexOfButton <> 0 Then
		If tbMyAddinSeparator <> 0 Then
			mff.ToolBarRemoveButton(tbStandard, mff.ToolBarIndexOfButton(tbStandard, tbMyAddinSeparator))
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(tbMyAddinSeparator)
		End If
		If tbMyAddin <> 0 Then
			mff.ToolBarRemoveButton(tbStandard, mff.ToolBarIndexOfButton(tbStandard, tbMyAddin))
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(tbMyAddin)
		End If
	End If
	If mnuService <> 0 AndAlso mff.MenuItemRemove <> 0 Then
		If mnuMyAddinSeparator <> 0 Then
			mff.MenuItemRemove(mnuService, mnuMyAddinSeparator)
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(mnuMyAddinSeparator)
		End If
		If mnuMyAddin <> 0 Then
			mff.MenuItemRemove(mnuService, mnuMyAddin)
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(mnuMyAddin)
		End If
	End If
	If VFBEditorLib <> 0 Then
		DyLibFree(VFBEditorLib)
	End If
End Sub
