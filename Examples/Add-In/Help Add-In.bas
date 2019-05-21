#IfDef __FB_Win32__
	#IfDef __FB_64bit__
	    '#Compile -dll -x "../../AddIns/Help Add-In (x64).dll" "Help Add-In.rc"
	#Else
	    '#Compile -dll -x "../../AddIns/Help Add-In (x32).dll" "Help Add-In.rc"
	#EndIf
#Else
	#IfDef __FB_64bit__
	    '#Compile -dll -x "../../AddIns/HelpAdd-Inx64.so"
	#Else
	    '#Compile -dll -x "../../AddIns/HelpAdd-Inx32.so"
	#EndIf
#EndIf

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
    mff.MenuItemRemove = DyLibSymbol(VFBEditorLib, "MenuItemRemove")
    mff.MenuFindByName = DyLibSymbol(VFBEditorLib, "MenuFindByName")
    mff.ObjectDelete = DyLibSymbol(VFBEditorLib, "ObjectDelete")
End Sub

Dim Shared As Any Ptr MainForm
Dim Shared As Any Ptr tbStandard, tbHelp, tbHelpSeparator
Dim Shared As Any Ptr mnuService, mnuHelp, mnuHelpSeparator

Dim Shared s As WString Ptr
Function GetFolderPath(ByRef FileName As WString) ByRef As WString
    Dim Pos1 As Long = InstrRev(FileName, "\")
    Dim Pos2 As Long = InstrRev(FileName, "/")
    If Pos1 = 0 OrElse Pos2 > Pos1 Then Pos1 = Pos2
    If Pos1 > 0 then
    	s = Cast(WString Ptr, Reallocate(s, Pos1 * SizeOf(Wstring)))
        *s = Left(FileName, Pos1)
        Return *s
    End If
    Return ""
End Function

Sub OnHelpButtonClick(ByRef Sender As Object)
	If mff.MsgBox <> 0 Then
		mff.MsgBox("Help")
	End If
End Sub

Sub OnConnection Alias "OnConnection"(VisualFBEditorApp As Any Ptr, ByRef AppPath As WString) Export
    VFBEditorApp = VisualFBEditorApp
    
	#IfDef __FB_Win32__
		#IfDef __FB_64Bit__
    		VFBEditorLib = DyLibLoad(GetFolderPath(AppPath) & "/MyFbFramework/mff64.dll")
    	#Else
    		VFBEditorLib = DyLibLoad(GetFolderPath(AppPath) & "/MyFbFramework/mff32.dll")
    	#EndIf
    #Else
    	VFBEditorLib = DyLibLoad(GetFolderPath(AppPath) & "/MyFbFramework/libmff" & Right(AppPath, 7) & ".so")
    #EndIf
    If s <> 0 Then Deallocate s
    If VFBEditorLib = 0 Then Exit Sub
    
    LoadMFFProcs
    
    If mff.ApplicationMainForm <> 0 Then
		MainForm = mff.ApplicationMainForm(VisualFBEditorApp)
		If MainForm <> 0 Then
			If mff.ControlByName <> 0 Then
				tbStandard = mff.ControlByName(MainForm, "Standard")
				If tbStandard <> 0 AndAlso mff.ToolBarAddButtonWithImageKey <> 0 Then
					tbHelpSeparator = mff.ToolBarAddButtonWithImageKey(tbStandard, 1, "HelpSeparator")
					tbHelp = mff.ToolBarAddButtonWithImageKey(tbStandard, , "Help", , @OnHelpButtonClick, "Help", , "Help", True)
				End If
			End If
			If mff.ReadProperty <> 0 AndAlso mff.MenuFindByName <> 0 Then
				Dim As Any Ptr mnuMenu = mff.ReadProperty(MainForm, "Menu")
				mnuService = mff.MenuFindByName(mnuMenu, "Service")
				If mnuService <> 0 AndAlso mff.MenuItemAdd <> 0 Then
					mnuHelpSeparator = mff.MenuItemAdd(mnuService, "-", "", "", , 1)
					mnuHelp = mff.MenuItemAdd(mnuService, "Help Add-In", "Help", , @OnHelpButtonClick, 2)
				End If
			End If
		End If
    End If
    
End Sub

Sub OnDisconnection Alias "OnDisconnection"(VisualFBEditorApp As Any Ptr) Export
	If tbStandard <> 0 AndAlso mff.ToolBarRemoveButton <> 0 AndAlso mff.ToolBarIndexOfButton <> 0 Then
		If tbHelpSeparator <> 0 Then
			mff.ToolBarRemoveButton(tbStandard, mff.ToolBarIndexOfButton(tbStandard, tbHelpSeparator))
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(tbHelpSeparator)
		End If
		If tbHelp <> 0 Then 
			mff.ToolBarRemoveButton(tbStandard, mff.ToolBarIndexOfButton(tbStandard, tbHelp))
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(tbHelp)
		End If
	End If
	If mnuService <> 0 AndAlso mff.MenuItemRemove <> 0 Then
		If mnuHelpSeparator <> 0 Then 
			mff.MenuItemRemove(mnuService, mnuHelpSeparator)
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(mnuHelpSeparator)
		End If
		If mnuHelp <> 0 Then 
			mff.MenuItemRemove(mnuService, mnuHelp)
			If mff.ObjectDelete <> 0 Then mff.ObjectDelete(mnuHelp)
		End If
	End If
	If VFBEditorLib <> 0 Then
		DyLibFree(VFBEditorLib)
	End If
End Sub
