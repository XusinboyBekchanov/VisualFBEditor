'#########################################################
'#  DesignerStatic.bi                                    #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'Web and Android: the designer has no library of MyFbFramework to load. The procedures which it takes from the library
'(Designer.Symbols) are the ones of the program: mff.bi and the units with __EXPORT_PROCS__

Function DesignerSymbol(ByVal Handle As Any Ptr, ByRef SymbolName As String) As Any Ptr
	Select Case SymbolName
	Case "CreateControl": Return @CreateControl
	Case "CreateReportControl": Return @CreateReportControl
	Case "CreateComponent": Return @CreateComponent
	Case "ReadProperty": Return @ReadProperty
	Case "WriteProperty": Return @WriteProperty
	Case "DeleteComponent": Return @DeleteComponent
	Case "DeleteAllObjects": Return @DeleteAllObjects
	Case "RemoveControl": Return @RemoveControl
	Case "ControlByIndex": Return @ControlByIndex
	Case "Q_Component": Return @Q_Component
	Case "ComponentGetBounds": Return @ComponentGetBounds
	Case "ComponentSetBounds": Return @ComponentSetBounds
	Case "ControlIsContainer": Return @ControlIsContainer
	Case "IsControl": Return @IsControl
	Case "IsReportControl": Return @IsReportControl
	Case "IsComponent": Return @IsComponent
	Case "ControlSetFocus": Return @ControlSetFocus
	Case "ControlFreeWnd": Return @ControlFreeWnd
	Case "ControlRepaint": Return @ControlRepaint
	Case "ToString": Return @ToString
	Case "CreateObject": Return @CreateObject
	Case "ObjectDelete": Return @ObjectDelete
	Case "MenuByIndex": Return @MenuByIndex
	Case "MenuItemByIndex": Return @MenuItemByIndex
	Case "MenuFindByCommand": Return @MenuFindByCommand
	Case "MenuRemove": Return @MenuRemove
	Case "MenuItemRemove": Return @MenuItemRemove
	Case "ToolBarButtonByIndex": Return @ToolBarButtonByIndex
	Case "ToolBarRemoveButton": Return @ToolBarRemoveButton
	Case "StatusBarPanelByIndex": Return @StatusBarPanelByIndex
	Case "StatusBarRemovePanel": Return @StatusBarRemovePanel
	Case "RemoveReportBand": Return @RemoveReportBand
	Case "ReportBandByIndex": Return @ReportBandByIndex
	Case "GraphicTypeLoadFromFile": Return @GraphicTypeLoadFromFile
	Case "BitmapTypeLoadFromFile": Return @BitmapTypeLoadFromFile
	Case "IconLoadFromFile": Return @IconLoadFromFile
	Case "CursorLoadFromFile": Return @CursorLoadFromFile
	Case "ImageListAddFromFile": Return @ImageListAddFromFile
	Case "ImageListIndexOf": Return @ImageListIndexOf
	Case "ImageListClear": Return @ImageListClear
	End Select
	Return 0
End Function
