'#########################################################
'#  DebugView.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'The same Tree and List views of Locals, Globals, Procedures, Threads and Watches for all debuggers.
'Every debugger fills only its own controls, as before: the Integrated IDE Debugger the tree views
'(tvVar, tvPrc, tvThd, tvWch), the others (GDB and LLDB with CLI, MI, DAP) the list views with columns
'(lvLocals, lvGlobals, lvThreads, lvWatches). The other kind is a copy of them, made only when it is on
'the screen and its data has changed (after a stop), and only of the expanded nodes: the children are copied
'when a node is expanded. When the view of the debugger is chosen, nothing is copied.

#if Not (defined(__USE_WASM__) OrElse defined(__USE_JNI__) OrElse defined(__USE_APPLE__))
	#define __DBGVIEW_INTEGRATED__
#endif

Enum DbgViewPanel
	dpLocals
	dpGlobals
	dpProcedures
	dpThreads
	dpWatches
End Enum
#define DBGVIEW_PANELS 4

Dim Shared As Boolean DbgViewIntegrated 'The tree views are filled by the Integrated IDE Debugger
Dim Shared As Boolean DbgViewListIntegrated = False, DbgViewListExternal = True 'The choice of the view for each kind of debugger
Dim Shared As Boolean DbgViewDirty(DBGVIEW_PANELS), DbgViewBuilt(DBGVIEW_PANELS), DbgViewUsed(DBGVIEW_PANELS)
Dim Shared As Boolean DbgViewBuilding, DbgViewApplying
Dim Shared As Boolean DbgViewStopped 'the program of the Integrated IDE Debugger is stopped: its tree views do not change
Dim Shared As Any Ptr DbgViewExpands(Any)
Dim Shared As Any Ptr DbgViewMenuItem 'the line of the data of the line of Show/Expand Variable of its menu (0: Locals, Globals, Watches)
Dim Shared As Integer DbgViewMenuPanel, DbgViewShowExpandPanel
Dim Shared As Integer DbgViewExpandsCount

Dim Shared As Any Ptr DbgViewWatchItems(Any)
Dim Shared As UString DbgViewWatchNames(Any)
Dim Shared As Integer DbgViewWatchCount

'The name typed for the watch of the line hItem of the Integrated IDE Debugger (it shows its own name)
Function DbgViewWatchName(hItem As Any Ptr) As UString
	For i As Integer = 0 To DbgViewWatchCount - 1
		If DbgViewWatchItems(i) = hItem Then Return DbgViewWatchNames(i)
	Next
	Return ""
End Function

'An empty name removes the name of the line
Sub DbgViewSetWatchName(hItem As Any Ptr, ByRef sName As WString)
	For i As Integer = 0 To DbgViewWatchCount - 1
		If DbgViewWatchItems(i) = hItem Then
			If sName = "" Then
				DbgViewWatchCount -= 1
				DbgViewWatchItems(i) = DbgViewWatchItems(DbgViewWatchCount)
				DbgViewWatchNames(i) = DbgViewWatchNames(DbgViewWatchCount)
			Else
				DbgViewWatchNames(i) = sName
			End If
			Exit Sub
		End If
	Next
	If sName = "" Then Exit Sub
	If DbgViewWatchCount > UBound(DbgViewWatchItems) Then
		ReDim Preserve DbgViewWatchItems(DbgViewWatchCount * 2 + 7)
		ReDim Preserve DbgViewWatchNames(DbgViewWatchCount * 2 + 7)
	End If
	DbgViewWatchItems(DbgViewWatchCount) = hItem
	DbgViewWatchNames(DbgViewWatchCount) = sName
	DbgViewWatchCount += 1
End Sub

Function DbgViewList() As Boolean
	Return IIf(DbgViewIntegrated, DbgViewListIntegrated, DbgViewListExternal)
End Function

Function DbgViewPanelTab(p As Integer) As TabPage Ptr
	Select Case p
	Case dpLocals: Return tpLocals
	Case dpGlobals: Return tpGlobals
	Case dpProcedures: Return tpProcedures
	Case dpThreads: Return tpThreads
	Case Else: Return tpWatches
	End Select
End Function

Function DbgViewPanelTree(p As Integer) As TreeView Ptr
	Select Case p
	Case dpLocals: Return @tvVar
	Case dpGlobals: Return @tvGlb
	Case dpProcedures: Return @tvPrc
	Case dpThreads: Return @tvThd
	Case Else: Return @tvWch
	End Select
End Function

Function DbgViewPanelList(p As Integer) As TreeListView Ptr
	Select Case p
	Case dpLocals: Return @lvLocals
	Case dpGlobals: Return @lvGlobals
	Case dpProcedures: Return @lvProcedures
	Case dpThreads: Return @lvThreads
	Case Else: Return @lvWatches
	End Select
End Function

'The tree of the Integrated IDE Debugger with the data of the panel (the globals are in the tree of the locals)
Function DbgViewSourceTree(p As Integer) As TreeView Ptr
	If p = dpGlobals Then Return @tvVar
	Return DbgViewPanelTree(p)
End Function

Function DbgViewPanelOfList(lv As TreeListView Ptr) As Integer
	For p As Integer = 0 To DBGVIEW_PANELS
		If DbgViewPanelList(p) = lv Then Return p
	Next
	Return -1
End Function

Function DbgViewPanelOfTree(tv As TreeView Ptr) As Integer
	For p As Integer = 0 To DBGVIEW_PANELS
		If DbgViewPanelTree(p) = tv Then Return p
	Next
	Return -1
End Function

'The panel shows a copy (not the controls filled by the debugger)
Function DbgViewIsCopy(p As Integer) As Boolean
	If DbgViewIntegrated Then
		If p = dpGlobals Then Return True 'the globals are in the tree of the locals
		Return DbgViewListIntegrated
	Else
		If p = dpProcedures Then Return False 'only the Integrated IDE Debugger shows the procedures
		Return Not DbgViewListExternal
	End If
End Function

'The nodes of the copy can be used: the data of the debugger is the same as when the copy was made
Function DbgViewCopyValid(p As Integer) As Boolean
	If p < 0 Then Return False
	If DbgViewBuilding OrElse DbgViewDirty(p) OrElse CBool(Not DbgViewIsCopy(p)) Then Return False
	#ifdef __DBGVIEW_INTEGRATED__
		If DbgViewIntegrated AndAlso CBool(Not DbgViewStopped) Then Return False
	#endif
	Return True
End Function

'==================== The data of the debugger ====================

Function DbgViewSourceText(p As Integer, h As Any Ptr) As UString
	#ifdef __USE_WINAPI__
		Dim As WString * 1024 buf
		Dim tvi As TVITEM
		tvi.mask = TVIF_TEXT
		tvi.hItem = Cast(HTREEITEM, h)
		tvi.pszText = @buf
		tvi.cchTextMax = 1023
		TreeView_GetItem(DbgViewSourceTree(p)->Handle, @tvi)
		Return buf
	#else
		Return Cast(TreeNode Ptr, h)->Text
	#endif
End Function

'The children of the node h of the data (0: the root)
Function DbgViewSourceChildren(p As Integer, h As Any Ptr, Items() As Any Ptr) As Integer
	Dim As Integer n
	If DbgViewIntegrated Then
		Dim As TreeView Ptr tv = DbgViewSourceTree(p)
		#ifdef __USE_WINAPI__
			Dim As HTREEITEM hi
			If h = 0 Then hi = TreeView_GetRoot(tv->Handle) Else hi = TreeView_GetChild(tv->Handle, Cast(HTREEITEM, h))
			While hi <> 0
				If n > UBound(Items) Then ReDim Preserve Items(n * 2 + 15)
				Items(n) = hi
				n += 1
				hi = TreeView_GetNextSibling(tv->Handle, hi)
			Wend
		#else
			Dim As TreeNodeCollection Ptr nc
			If h = 0 Then nc = @tv->Nodes Else nc = @Cast(TreeNode Ptr, h)->Nodes
			n = nc->Count
			If n > 0 Then ReDim Items(n - 1)
			For i As Integer = 0 To n - 1
				Items(i) = nc->Item(i)
			Next
		#endif
	Else
		Dim As TreeListViewItems Ptr nc
		Dim As TreeListView Ptr lv = DbgViewPanelList(p)
		If h = 0 Then nc = @lv->Nodes Else nc = @Cast(TreeListViewItem Ptr, h)->Nodes
		n = nc->Count
		If n > 0 Then ReDim Items(n - 1)
		For i As Integer = 0 To n - 1
			Items(i) = nc->Item(i)
		Next
	End If
	Return n
End Function

Function DbgViewSourceHasChildren(p As Integer, h As Any Ptr) As Boolean
	If DbgViewIntegrated Then
		#ifdef __USE_WINAPI__
			If TreeView_GetChild(DbgViewSourceTree(p)->Handle, Cast(HTREEITEM, h)) <> 0 Then Return True
			'The components of a variable: their lines are added when it is expanded (var_kids)
			Dim tvi As TVITEM
			tvi.mask = TVIF_CHILDREN
			tvi.hItem = Cast(HTREEITEM, h)
			TreeView_GetItem(DbgViewSourceTree(p)->Handle, @tvi)
			Return tvi.cChildren = 1
		#else
			Return Cast(TreeNode Ptr, h)->Nodes.Count > 0
		#endif
	Else
		Return Cast(TreeListViewItem Ptr, h)->Nodes.Count > 0
	End If
End Function

Function DbgViewSourceExpanded(p As Integer, h As Any Ptr) As Boolean
	If DbgViewIntegrated Then
		#ifdef __USE_WINAPI__
			Return (TreeView_GetItemState(DbgViewSourceTree(p)->Handle, Cast(HTREEITEM, h), TVIS_EXPANDED) And TVIS_EXPANDED) <> 0
		#else
			Return Cast(TreeNode Ptr, h)->IsExpanded
		#endif
	Else
		Return Cast(TreeListViewItem Ptr, h)->IsExpanded
	End If
End Function

'Before its children are copied: the debugger fills them (the Integrated IDE Debugger fills the expanded nodes,
'GDB adds the fields of a structure when it is expanded)
Sub DbgViewSourceExpand(p As Integer, h As Any Ptr)
	If DbgViewIntegrated Then
		#ifdef __USE_WINAPI__
			Dim As HWND hTV = DbgViewSourceTree(p)->Handle
			If (TreeView_GetItemState(hTV, Cast(HTREEITEM, h), TVIS_EXPANDED) And TVIS_EXPANDED) = 0 Then
				'The lines of the components are added when it is expanded
				If p = dpLocals OrElse p = dpGlobals Then var_kids(h)
				TreeView_Expand(hTV, Cast(HTREEITEM, h), TVE_EXPAND)
				'TVM_EXPAND does not send TVN_ITEMEXPANDING
				If p = dpLocals OrElse p = dpGlobals Then UpdateItems(TreeView_GetChild(hTV, Cast(HTREEITEM, h)))
			End If
		#else
			If Not Cast(TreeNode Ptr, h)->IsExpanded Then
				If p = dpLocals OrElse p = dpGlobals Then
					var_kids(h) 'the lines of the components
					#ifdef __USE_GTK__
						arr_elements_sh(Cast(Integer, Cast(TreeNode Ptr, h)->Tag), h, True, False)
					#endif
				End If
				Cast(TreeNode Ptr, h)->Expand
			End If
		#endif
	Else
		Dim As TreeListViewItem Ptr Item = h
		Dim As TreeListView Ptr lv = DbgViewPanelList(p)
		If Item->Nodes.Count > 0 AndAlso Item->Nodes.Item(0)->Text(0) = "" AndAlso lv->OnItemExpanding <> 0 Then
			lv->OnItemExpanding(*lv->Designer, *lv, Item)
		End If
	End If
End Sub

Sub DbgViewSourceSelect(p As Integer, h As Any Ptr)
	If h = 0 Then Exit Sub
	If DbgViewIntegrated Then
		#ifdef __USE_WINAPI__
			TreeView_SelectItem(DbgViewSourceTree(p)->Handle, Cast(HTREEITEM, h))
		#else
			Cast(TreeNode Ptr, h)->SelectItem
		#endif
	Else
		Cast(TreeListViewItem Ptr, h)->SelectItem
	End If
End Sub

'"Name [array] <Type>=Value" of the Integrated IDE Debugger in three columns
Sub DbgViewSplitLabel(ByRef sText As UString, ByRef sName As UString, ByRef sValue As UString, ByRef sType As UString)
	'The type is after the first "<" (an array: "FBOLDS [ 0-2:0 ]<Integer>=0" has no space before it)
	Dim As Integer Pos1 = InStr(sText, "<"), Pos2, Pos3
	sValue = "": sType = ""
	If Pos1 = 0 Then
		'A procedure: "NAME:Type" (not "Globals ... in : main")
		Pos2 = InStrRev(sText, ":")
		If Pos2 > 1 AndAlso Pos2 < Len(sText) AndAlso Mid(sText, Pos2 + 1, 1) <> " " Then
			sName = RTrim(Left(sText, Pos2 - 1))
			sType = Mid(sText, Pos2 + 1)
		Else
			sName = sText
		End If
		Exit Sub
	End If
	sName = RTrim(Left(sText, Pos1 - 1))
	Pos2 = InStr(Pos1 + 1, sText, ">")
	If Pos2 = 0 Then sType = Mid(sText, Pos1 + 1): Exit Sub
	sType = Mid(sText, Pos1 + 1, Pos2 - Pos1 - 1)
	Pos3 = InStr(Pos2 + 1, sText, "=")
	If Pos3 = 0 Then
		sValue = Trim(Mid(sText, Pos2 + 1))
	Else
		If Trim(Mid(sText, Pos2 + 1, Pos3 - Pos2 - 1)) <> "" Then sType &= " " & Trim(Mid(sText, Pos2 + 1, Pos3 - Pos2 - 1))
		sValue = Mid(sText, Pos3 + 1)
	End If
End Sub

'"NAME:Type   in : file.bas <E> " of proc_sh in four columns: procedure, type, file, followed (E) or not (D)
Sub DbgViewSplitProcedure(ByRef sText As UString, ByRef sName As UString, ByRef sType As UString, ByRef sFile As UString, ByRef sState As UString)
	Dim As Integer Pos1 = InStr(sText, "   in : "), Pos2
	sType = "": sFile = "": sState = ""
	If Pos1 = 0 Then sName = sText: Exit Sub
	sName = Left(sText, Pos1 - 1)
	Pos2 = InStrRev(sName, ":")
	If Pos2 > 0 Then sType = Mid(sName, Pos2 + 1): sName = Left(sName, Pos2 - 1)
	sFile = Mid(sText, Pos1 + 8)
	Pos2 = InStr(sFile, " <")
	If Pos2 > 0 Then
		sState = Mid(sFile, Pos2 + 2, 1)
		If sState = "E" Then
			sState = ML("Yes")
		ElseIf sState = "D" Then
			sState = ML("No")
		Else
			sState = ""
		End If
		sFile = Left(sFile, Pos2 - 1)
	End If
End Sub

Sub DbgViewSourceColumns(p As Integer, h As Any Ptr, ByRef c0 As UString, ByRef c1 As UString, ByRef c2 As UString, ByRef c3 As UString)
	c3 = ""
	If DbgViewIntegrated Then
		Dim As UString sText = DbgViewSourceText(p, h)
		If p = dpProcedures Then
			DbgViewSplitProcedure sText, c0, c1, c2, c3
		ElseIf p = dpThreads Then
			c0 = sText: c1 = "": c2 = ""
		Else
			DbgViewSplitLabel sText, c0, c1, c2
		End If
	Else
		Dim As TreeListViewItem Ptr Item = h
		c0 = Item->Text(0)
		c1 = Item->Text(1)
		If DbgViewPanelList(p)->Columns.Count > 2 Then c2 = Item->Text(2) Else c2 = ""
		If DbgViewPanelList(p)->Columns.Count > 3 Then c3 = Item->Text(3)
	End If
End Sub

'The text of a node of the tree for the columns of a list
Function DbgViewTreeLabel(p As Integer, ByRef c0 As UString, ByRef c1 As UString, ByRef c2 As UString) As UString
	Dim As UString Result = c0
	If p = dpThreads Then
		If c2 <> "" AndAlso c1 <> "" Then
			Result &= "  (" & c2 & ":" & c1 & ")"
		ElseIf c2 <> "" Then
			Result &= "  (" & c2 & ")"
		End If
	Else
		If c2 <> "" Then Result &= " <" & c2 & ">"
		If c1 <> "" Then Result &= "=" & c1
	End If
	Return Result
End Function

'==================== The copy ====================

'The expanded nodes of the copy (by the names from the root): they stay expanded after the next stop
Sub DbgViewCollectExpanded(p As Integer, ByVal Parent As Any Ptr, ByRef sPath As UString, ByRef sKeys As UString)
	Dim As UString sKey
	If DbgViewList Then
		Dim As TreeListViewItems Ptr nc
		Dim As TreeListView Ptr lv = DbgViewPanelList(p)
		If Parent = 0 Then nc = @lv->Nodes Else nc = @Cast(TreeListViewItem Ptr, Parent)->Nodes
		For i As Integer = 0 To nc->Count - 1
			Dim As TreeListViewItem Ptr Item = nc->Item(i)
			If Item->Tag = 0 OrElse Item->Nodes.Count = 0 OrElse CInt(Not Item->IsExpanded) Then Continue For
			sKey = sPath & WChr(2) & Item->Text(0)
			sKeys &= sKey & WChr(1)
			DbgViewCollectExpanded p, Item, sKey, sKeys
		Next
	Else
		Dim As TreeNodeCollection Ptr nc
		Dim As TreeView Ptr tv = DbgViewPanelTree(p)
		If Parent = 0 Then nc = @tv->Nodes Else nc = @Cast(TreeNode Ptr, Parent)->Nodes
		For i As Integer = 0 To nc->Count - 1
			Dim As TreeNode Ptr tn = nc->Item(i)
			If tn->Tag = 0 OrElse tn->Nodes.Count = 0 OrElse CInt(Not tn->IsExpanded) Then Continue For
			sKey = sPath & WChr(2) & tn->Name
			sKeys &= sKey & WChr(1)
			DbgViewCollectExpanded p, tn, sKey, sKeys
		Next
	End If
End Sub

'Copies the children of the node h of the data to the node Parent of the copy (0: the roots).
'bMirror: the first copy, the nodes expanded in the data are expanded
Sub DbgViewFill(p As Integer, h As Any Ptr, Parent As Any Ptr, ByRef sPath As UString, ByRef sKeys As UString, bMirror As Boolean)
	Dim As Any Ptr Items(Any)
	Dim As Integer n = DbgViewSourceChildren(p, h, Items())
	Dim As UString c0, c1, c2, c3, sKey
	Dim As Boolean bList = DbgViewList, bHas, bExpand
	For i As Integer = 0 To n - 1
		Dim As Any Ptr s = Items(i)
		DbgViewSourceColumns p, s, c0, c1, c2, c3
		'The roots of the globals of the Integrated IDE Debugger are in the tree of the locals
		'(the Locals show them too, like the tree)
		If DbgViewIntegrated AndAlso h = 0 AndAlso p = dpGlobals AndAlso CInt(Not StartsWith(c0, "Globals")) Then Continue For
		If h = 0 AndAlso p = dpWatches AndAlso Trim(c0) = "" Then Continue For 'the empty line for a new watch
		'The watches of the Integrated IDE Debugger: the typed name stays
		If DbgViewIntegrated AndAlso h = 0 AndAlso p = dpWatches Then
			If DbgViewWatchName(s) <> "" Then c0 = DbgViewWatchName(s)
		End If
		sKey = sPath & WChr(2) & c0
		bHas = DbgViewSourceHasChildren(p, s)
		bExpand = bHas AndAlso (CBool(InStr(sKeys, WChr(1) & sKey & WChr(1)) > 0) OrElse (bMirror AndAlso DbgViewSourceExpanded(p, s)))
		If bExpand Then DbgViewSourceExpand p, s: bHas = DbgViewSourceHasChildren(p, s)
		If bList Then
			Dim As TreeListViewItem Ptr Item
			'All the columns in Add (Chr(9) between them): Text(i) of an added item looks for its line in the
			'whole list (GetItemIndex), thousands of procedures were slow
			Dim As UString sCells = Replace(c0, WChr(9), " ") & WChr(9) & Replace(c1, WChr(9), " ") & WChr(9) & Replace(c2, WChr(9), " ") & WChr(9) & Replace(c3, WChr(9), " ")
			If Parent = 0 Then Item = DbgViewPanelList(p)->Nodes.Add(sCells) Else Item = Cast(TreeListViewItem Ptr, Parent)->Nodes.Add(sCells)
			Item->Tag = s
			If bHas Then
				If bExpand Then
					If DbgViewExpandsCount > UBound(DbgViewExpands) Then ReDim Preserve DbgViewExpands(DbgViewExpandsCount * 2 + 15)
					DbgViewExpands(DbgViewExpandsCount) = Item: DbgViewExpandsCount += 1
					DbgViewFill p, s, Item, sKey, sKeys, bMirror
				Else
					Item->Nodes.Add 'the children are copied when it is expanded
				End If
			End If
		Else
			Dim As TreeNode Ptr tn
			Dim As UString sLabel
			If DbgViewIntegrated Then sLabel = DbgViewSourceText(p, s) Else sLabel = DbgViewTreeLabel(p, c0, c1, c2)
			If Parent = 0 Then tn = DbgViewPanelTree(p)->Nodes.Add(sLabel) Else tn = Cast(TreeNode Ptr, Parent)->Nodes.Add(sLabel)
			tn->Name = c0
			tn->Tag = s
			If bHas Then
				If bExpand Then
					If DbgViewExpandsCount > UBound(DbgViewExpands) Then ReDim Preserve DbgViewExpands(DbgViewExpandsCount * 2 + 15)
					DbgViewExpands(DbgViewExpandsCount) = tn: DbgViewExpandsCount += 1
					DbgViewFill p, s, tn, sKey, sKeys, bMirror
				Else
					tn->Nodes.Add 'the children are copied when it is expanded
				End If
			End If
		End If
	Next
End Sub

'Clears the copy of the panel
Sub DbgViewClearCopy(p As Integer, bList As Boolean)
	If bList Then
		DbgViewPanelList(p)->Nodes.Clear
	Else
		DbgViewPanelTree(p)->Nodes.Clear
		#ifdef __USE_WINAPI__
			'The nodes of the Integrated IDE Debugger are not in Nodes
			If DbgViewPanelTree(p)->Handle Then SendMessage(DbgViewPanelTree(p)->Handle, TVM_DELETEITEM, 0, Cast(LPARAM, TVI_ROOT))
		#endif
	End If
End Sub

Function DbgViewFindCopy(p As Integer, ByVal Parent As Any Ptr, h As Any Ptr) As Any Ptr
	Dim As Any Ptr Result
	If DbgViewList Then
		Dim As TreeListViewItems Ptr nc
		Dim As TreeListView Ptr lv = DbgViewPanelList(p)
		If Parent = 0 Then nc = @lv->Nodes Else nc = @Cast(TreeListViewItem Ptr, Parent)->Nodes
		For i As Integer = 0 To nc->Count - 1
			If nc->Item(i)->Tag = h Then Return nc->Item(i)
			Result = DbgViewFindCopy(p, nc->Item(i), h)
			If Result Then Return Result
		Next
	Else
		Dim As TreeNodeCollection Ptr nc
		Dim As TreeView Ptr tv = DbgViewPanelTree(p)
		If Parent = 0 Then nc = @tv->Nodes Else nc = @Cast(TreeNode Ptr, Parent)->Nodes
		For i As Integer = 0 To nc->Count - 1
			If nc->Item(i)->Tag = h Then Return nc->Item(i)
			Result = DbgViewFindCopy(p, nc->Item(i), h)
			If Result Then Return Result
		Next
	End If
	Return 0
End Function

'The selected line of the data is selected in the copy (after a stop and after the change of the view)
Sub DbgViewSelectCopy(p As Integer)
	Dim As Any Ptr h, Item
	If DbgViewIntegrated Then
		#ifdef __USE_WINAPI__
			h = TreeView_GetSelection(DbgViewSourceTree(p)->Handle)
		#else
			h = DbgViewSourceTree(p)->SelectedNode
		#endif
	Else
		h = DbgViewPanelList(p)->SelectedItem
	End If
	If h = 0 Then Exit Sub
	Item = DbgViewFindCopy(p, 0, h)
	If Item = 0 Then Exit Sub
	If DbgViewList Then Cast(TreeListViewItem Ptr, Item)->SelectItem Else Cast(TreeNode Ptr, Item)->SelectItem
End Sub

Sub DbgViewBuild(p As Integer)
	If DbgViewBuilding OrElse Not DbgViewIsCopy(p) Then Exit Sub
	If Not DbgViewDirty(p) AndAlso DbgViewBuilt(p) Then Exit Sub
	#ifdef __DBGVIEW_INTEGRATED__
		'While the program runs the tree changes: the last copy stays until the next stop
		If DbgViewIntegrated AndAlso DbgViewBuilt(p) AndAlso CBool(Not DbgViewStopped) Then Exit Sub
	#endif
	Dim As Boolean bList = DbgViewList
	Dim As Control Ptr Ctrl = IIf(bList, Cast(Control Ptr, DbgViewPanelList(p)), Cast(Control Ptr, DbgViewPanelTree(p)))
	Dim As UString sKeys = WChr(1)
	DbgViewBuilding = True
	If DbgViewBuilt(p) Then DbgViewCollectExpanded p, 0, "", sKeys
	Ctrl->UpdateLock
	DbgViewClearCopy p, bList
	DbgViewUsed(p) = True
	DbgViewExpandsCount = 0
	DbgViewFill p, 0, 0, "", sKeys, Not DbgViewBuilt(p)
	'From the root: an item of the list is not expanded when its parent is not expanded
	For i As Integer = 0 To DbgViewExpandsCount - 1
		If bList Then Cast(TreeListViewItem Ptr, DbgViewExpands(i))->Expand Else Cast(TreeNode Ptr, DbgViewExpands(i))->Expand
	Next
	'The empty line for a new watch (its Tag is 0)
	If p = dpWatches Then
		If bList Then DbgViewPanelList(p)->Nodes.Add Else DbgViewPanelTree(p)->Nodes.Add
	End If
	DbgViewSelectCopy p
	Ctrl->UpdateUnLock
	DbgViewBuilding = False
	DbgViewDirty(p) = False
	DbgViewBuilt(p) = True
End Sub

'==================== Interface ====================

'The data of the debugger has changed: the copy on the screen is made again, the others when they are shown
Sub DbgViewDataChanging()
	'The debugger clears its data: the nodes of the copies are not used until they are made again
	For p As Integer = 0 To DBGVIEW_PANELS
		DbgViewDirty(p) = True
	Next
End Sub

Sub DbgViewInvalidate()
	For p As Integer = 0 To DBGVIEW_PANELS
		DbgViewDirty(p) = True
		If DbgViewIsCopy(p) AndAlso CBool(DbgViewPanelTab(p) <> 0) AndAlso DbgViewPanelTab(p)->IsSelected Then DbgViewBuild p
	Next
End Sub

'A panel is shown (selection of its tab)
Sub DbgViewShowTab(tp As TabPage Ptr)
	For p As Integer = 0 To DBGVIEW_PANELS
		If DbgViewPanelTab(p) = tp Then DbgViewBuild p: Exit Sub
	Next
End Sub

Function DbgViewIsPanelTab(tp As TabPage Ptr) As Boolean
	For p As Integer = 0 To DBGVIEW_PANELS
		If tp <> 0 AndAlso DbgViewPanelTab(p) = tp Then Return True
	Next
	Return False
End Function

'Shows the tree or the list view of every panel
Sub DbgViewApply()
	Dim As Boolean bList = DbgViewList
	For p As Integer = 0 To DBGVIEW_PANELS
		DbgViewPanelTree(p)->Visible = Not bList
		DbgViewPanelList(p)->Visible = bList
		DbgViewBuilt(p) = False 'the nodes expanded by the debugger are expanded in the new copy
	Next
	'Checked raises OnClick (mClick, DbgViewSetList)
	DbgViewApplying = True
	If tbBottom.Buttons.IndexOf("DebugListView") >= 0 AndAlso tbBottom.Buttons.Item("DebugListView")->Checked <> bList Then tbBottom.Buttons.Item("DebugListView")->Checked = bList
	DbgViewApplying = False
	DbgViewInvalidate
End Sub

'The Integrated IDE Debugger stops (dsp_change) or resumes (thread_resume, thread_rsm)
Sub DbgViewIntegratedStopped(bStopped As Boolean)
	DbgViewStopped = bStopped
	If bStopped Then DbgViewInvalidate
End Sub

'bIntegrated: the Integrated IDE Debugger starts, otherwise GDB or LLDB with CLI, MI or DAP
Sub DbgViewSetDebugger(bIntegrated As Boolean)
	If bIntegrated Then DbgViewStopped = False
	If DbgViewIntegrated <> bIntegrated Then
		'The copies made for the other debugger are the controls of this one
		For p As Integer = 0 To DBGVIEW_PANELS
			If DbgViewUsed(p) Then
				If bIntegrated Then
					If p <> dpProcedures Then DbgViewClearCopy p, False
					If p = dpWatches Then tvWch.Nodes.Add 'the line for a new watch
				Else
					DbgViewClearCopy p, True
					If p = dpWatches Then lvWatches.Nodes.Add 'the line for a new watch
				End If
				DbgViewUsed(p) = False
			End If
		Next
		DbgViewIntegrated = bIntegrated
	End If
	DbgViewApply
End Sub

'The button of tbBottom
Sub DbgViewSetList(bList As Boolean)
	If DbgViewApplying Then Exit Sub
	If DbgViewIntegrated Then DbgViewListIntegrated = bList Else DbgViewListExternal = bList
	DbgViewApply
End Sub

'==================== Events of the copies ====================

'Expanding a node of the copy: its children are copied. Returns True when the list is a copy
Function DbgViewListExpanding(ByRef Sender As TreeListView, ByVal Item As TreeListViewItem Ptr) As Boolean
	Dim As Integer p = DbgViewPanelOfList(@Sender)
	If p < 0 Then Return False
	If CBool(Not DbgViewIsCopy(p)) OrElse CBool(Not DbgViewList) Then Return False
	If Not DbgViewCopyValid(p) OrElse Item = 0 OrElse Item->Tag = 0 Then Return True
	If Item->Nodes.Count = 1 AndAlso Item->Nodes.Item(0)->Tag = 0 Then
		DbgViewBuilding = True
		Item->Nodes.Clear
		DbgViewSourceExpand p, Item->Tag
		DbgViewFill p, Item->Tag, Item, "", "", False
		DbgViewBuilding = False
	End If
	Return True
End Function

Sub DbgViewList_ItemExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	DbgViewListExpanding Sender, Item 'Threads and Procedures (Locals, Globals, Watches: lvVar_ItemExpanding)
End Sub

Sub DbgViewTree_NodeExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef Cancel As Boolean)
	Dim As Integer p = DbgViewPanelOfTree(@Sender)
	#ifndef __USE_WINAPI__
		'The tree of the variables of the Integrated IDE Debugger: the lines of the components are added
		'(on Windows: TVN_ITEMEXPANDING of tvVar_Message)
		If DbgViewIntegrated AndAlso @Item <> 0 AndAlso @Sender = DbgViewSourceTree(dpLocals) Then
			var_kids(@Item)
			#ifdef __USE_GTK__
				arr_elements_sh(Cast(Integer, Item.Tag), @Item, True, False) 'the values of the elements of an array
			#endif
		End If
	#endif
	'(Item is 0 for a node of the Integrated IDE Debugger, it is not in Nodes)
	If @Item = 0 OrElse CInt(Not DbgViewCopyValid(p)) OrElse CInt(DbgViewList) OrElse Item.Tag = 0 Then Exit Sub
	If Item.Nodes.Count = 1 AndAlso Item.Nodes.Item(0)->Tag = 0 Then
		DbgViewBuilding = True
		Item.Nodes.Clear
		DbgViewSourceExpand p, Item.Tag
		DbgViewFill p, Item.Tag, @Item, "", "", False
		DbgViewBuilding = False
	End If
End Sub

'The selection of the copy is the selection of the data: the commands of the debugger use it
Sub DbgViewList_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Dim As Integer p = DbgViewPanelOfList(@Sender)
	If Item = 0 OrElse CInt(Not DbgViewCopyValid(p)) OrElse CInt(Not DbgViewList) Then Exit Sub
	DbgViewSourceSelect p, Item->Tag
End Sub

Sub DbgViewTree_SelChanged(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	Dim As Integer p = DbgViewPanelOfTree(@Sender)
	If @Item = 0 OrElse CInt(Not DbgViewCopyValid(p)) OrElse CInt(DbgViewList) Then Exit Sub
	DbgViewSourceSelect p, Item.Tag
End Sub

'Of a copy only the values are edited (Edit Value), while the program is stopped
Sub DbgViewList_CellEditing(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr, ByRef Cancel As Boolean)
	Dim As Integer p = DbgViewPanelOfList(@Sender)
	If p >= 0 AndAlso DbgViewIsCopy(p) Then
		If SubItemIndex <> 1 OrElse Item = 0 OrElse Item->Tag = 0 OrElse CInt(Not DbgViewCopyValid(p)) Then Cancel = True
	End If
End Sub

'==================== Edit Value ====================

Declare Function DbgViewCommandPanel(ByRef sCommand As String) As Integer

Dim Shared As Integer DbgViewValuePanel
Dim Shared As Any Ptr DbgViewValueItem 'the node of the tree of the Integrated IDE Debugger
Dim Shared As UString DbgViewValueText

'The new value of the selected variable: Integrated IDE Debugger (var_set_value), GDB and LLDB (gdb_set_value).
'Returns True if it is written (or the command is sent)
Function DbgViewRunValueEdit() As Boolean
	Dim As Integer p = DbgViewValuePanel
	Dim As String sCommand = IIf(p = dpWatches, "EditValueWatch", "EditValue")
	Dim As Boolean bResult
	If DbgViewIntegrated Then
		#ifdef __USE_WINAPI__
			If Not DbgViewStopped Then ShowMessages ML("Edit Value") & ": " & ML("Stop the program first"): Return False
			If DbgViewValueItem <> 0 Then DbgViewSourceSelect p, DbgViewValueItem
			bResult = var_set_value(IIf(p = dpWatches, Cast(Any Ptr, tviewwch), Cast(Any Ptr, tviewvar)), DbgViewValueText)
		#else
			ShowMessages ML("This command is only for Windows")
		#endif
		DbgViewInvalidate
	Else
		#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
			Dim As TreeListViewItem Ptr Item = mem_selected_item(sCommand)
			bResult = gdb_set_value(sCommand, DbgViewValueText)
			'The value in the list until the next stop
			If bResult AndAlso Item <> 0 Then Item->Text(1) = DbgViewValueText: DbgViewInvalidate
		#endif
	End If
	Return bResult
End Function

#ifdef __USE_WINAPI__
	Sub DbgViewValueEditTimer(hwnd As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
		KillTimer 0, idEvent
		DbgViewRunValueEdit
	End Sub
#endif

'The Value column of a list is edited: the copy of the Integrated IDE Debugger is made again after the edit
Sub DbgViewList_CellEdited(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString, ByRef Cancel As Boolean)
	If Item = 0 OrElse SubItemIndex <> 1 Then Exit Sub
	DbgViewMenuItem = 0
	Dim As Integer p = DbgViewPanelOfList(@Sender)
	If p < 0 Then Exit Sub
	If Trim(NewText) = Trim(Item->Text(1)) Then Exit Sub
	DbgViewValuePanel = p
	DbgViewValueText = NewText
	If DbgViewIntegrated Then
		'(not Cancel: the list keeps the text of the first column, the copy is made again after the write)
		DbgViewValueItem = Item->Tag
		#ifdef __USE_WINAPI__
			SetTimer 0, 0, 10, Cast(TIMERPROC, @DbgViewValueEditTimer)
		#endif
	Else
		DbgViewValueItem = 0
		Item->SelectItem
		Cancel = Not DbgViewRunValueEdit
	End If
End Sub

'The command Edit Value of the menus of the variables and of the watches
Sub DbgViewEditValue(ByRef sCommand As String)
	Dim As Integer p = DbgViewCommandPanel(sCommand)
	Dim As Any Ptr h
	If DbgViewMenuItem <> 0 Then
		h = DbgViewMenuItem
	ElseIf DbgViewIntegrated Then
		If Not DbgViewStopped Then ShowMessages ML("Edit Value") & ": " & ML("Stop the program first"): Exit Sub
		If DbgViewList Then
			If DbgViewPanelList(p)->SelectedItem <> 0 Then h = DbgViewPanelList(p)->SelectedItem->Tag
		Else
			#ifdef __USE_WINAPI__
				h = TreeView_GetSelection(DbgViewSourceTree(p)->Handle)
			#else
				h = DbgViewSourceTree(p)->SelectedNode
			#endif
		End If
	Else
		h = mem_selected_item(sCommand)
	End If
	If h = 0 Then ShowMessages ML("Select a variable"): Exit Sub
	Dim As UString c0, c1, c2, c3
	DbgViewSourceColumns p, h, c0, c1, c2, c3
	Dim As UString sNew
	If Not DbgInputBox(ML("Edit Value"), Trim(c0) & IIf(c2 <> "", " <" & c2 & ">", "") & WChr(10) & ML("New value") & ":", c1, sNew) Then Exit Sub
	If sNew = c1 Then Exit Sub
	DbgViewValuePanel = p
	DbgViewValueItem = IIf(DbgViewIntegrated, h, 0)
	DbgViewValueText = sNew
	DbgViewRunValueEdit
End Sub

Sub DbgViewTree_BeforeLabelEdit(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef NodeLabel As WString, ByRef Cancel As Boolean)
	Dim As Integer p = DbgViewPanelOfTree(@Sender)
	If p < 0 OrElse CInt(Not DbgViewIsCopy(p)) OrElse @Item = 0 Then Exit Sub
	'Only the names of the watches
	If p <> dpWatches OrElse Item.ParentNode <> 0 Then Cancel = True
End Sub

'A new watch typed in the Watches window, in the tree or in the list, for every debugger
Sub DbgViewAddWatch(ByRef sName As WString)
	'(the names typed for the watches of the Integrated IDE Debugger: DbgViewWatchName)
	If Trim(sName) = "" Then Exit Sub
	If DbgViewIntegrated Then
		'"  main/GCOUNT" of the line of the Integrated IDE Debugger: the procedure is not a part of the name
		Dim As String sVar = Trim(sName)
		If InStr(sVar, "/") Then sVar = Trim(Mid(sVar, InStrRev(sVar, "/") + 1))
		#ifdef __USE_WINAPI__
			Dim As Any Ptr hItem = DbgIntegratedAddWatch(sVar)
			If hItem = 0 Then
				ShowMessages ML("Variable not found") & ": " & sVar
			Else
				DbgViewSetWatchName hItem, Trim(sName)
			End If
		#endif
	Else
		'The last line of the list of the debugger is for a new watch
		If lvWatches.Nodes.Count = 0 OrElse lvWatches.Nodes.Item(lvWatches.Nodes.Count - 1)->Text(0) <> "" Then lvWatches.Nodes.Add
		Dim As TreeListViewItem Ptr Item = lvWatches.Nodes.Item(lvWatches.Nodes.Count - 1)
		Dim As Boolean bCancel
		Item->Text(0) = Trim(sName)
		If lvWatches.OnCellEdited Then lvWatches.OnCellEdited(*lvWatches.Designer, lvWatches, Item, 0, Trim(sName), bCancel)
	End If
	DbgViewDirty(dpWatches) = True
	DbgViewInvalidate
End Sub

'Editing of a line of the list of the watches of the Integrated IDE Debugger: the empty line adds a watch,
'another name replaces the watch, an empty name removes it
Dim Shared As Any Ptr DbgViewQueuedDelete 'the line of the watch to remove: HTREEITEM (Integrated IDE Debugger), TreeListViewItem Ptr (lvWatches)
Dim Shared As UString DbgViewQueuedAdd 'the name of the watch to add

'Changes the watches after the edit of a line: the line is not removed while it is edited
Sub DbgViewRunWatchEdit()
	If DbgViewQueuedDelete <> 0 Then
		If DbgViewIntegrated Then
			#ifdef __USE_WINAPI__
				DbgIntegratedDeleteWatch DbgViewQueuedDelete
			#endif
			DbgViewSetWatchName DbgViewQueuedDelete, ""
		ElseIf lvWatches.Nodes.IndexOf(Cast(TreeListViewItem Ptr, DbgViewQueuedDelete)) >= 0 Then
			'An empty name removes the watch (lvWatches_CellEdited)
			Dim As Boolean bCancel
			If lvWatches.OnCellEdited Then lvWatches.OnCellEdited(*lvWatches.Designer, lvWatches, Cast(TreeListViewItem Ptr, DbgViewQueuedDelete), 0, "", bCancel)
		End If
	End If
	If Trim(DbgViewQueuedAdd) <> "" Then DbgViewAddWatch DbgViewQueuedAdd
	DbgViewQueuedDelete = 0
	DbgViewQueuedAdd = ""
	#ifdef __USE_WINAPI__
		'The empty line for a new watch of the Integrated IDE Debugger goes after its watches
		If DbgViewIntegrated Then
			For i As Integer = tvWch.Nodes.Count - 1 To 0 Step -1
				If tvWch.Nodes.Item(i)->Text = "" Then tvWch.Nodes.Remove i
			Next
			tvWch.Nodes.Add
		End If
	#endif
	DbgViewDirty(dpWatches) = True
	DbgViewInvalidate
End Sub

#ifdef __USE_WINAPI__
	Sub DbgViewWatchEditTimer(hwnd As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
		KillTimer 0, idEvent
		DbgViewRunWatchEdit
	End Sub
#endif

Sub DbgViewQueueWatchEdit(hDelete As Any Ptr, ByRef sWatch As WString)
	DbgViewQueuedDelete = hDelete
	DbgViewQueuedAdd = Trim(sWatch)
	#ifdef __USE_WINAPI__
		SetTimer 0, 0, 10, Cast(TIMERPROC, @DbgViewWatchEditTimer)
	#else
		DbgViewRunWatchEdit
	#endif
End Sub

Sub DbgViewEditWatch(Item As TreeListViewItem Ptr, ByRef NewText As WString)
	If Item = 0 OrElse Item->ParentItem <> 0 Then Exit Sub
	If Item->Tag = 0 Then
		If Trim(NewText) <> "" Then DbgViewQueueWatchEdit 0, NewText
	ElseIf Trim(NewText) <> Trim(Item->Text(0)) Then
		DbgViewQueueWatchEdit Item->Tag, NewText
	End If
End Sub

'Double click or Enter on a line of the Watches: its name is edited
Sub DbgViewWatches_ItemDblClick(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item = 0 OrElse Item->ParentItem <> 0 Then Exit Sub
	#ifdef __USE_WINAPI__
		Dim As Integer i = ListView_GetNextItem(Sender.Handle, -1, LVNI_FOCUSED)
		If i >= 0 Then ListView_EditLabel(Sender.Handle, i)
	#endif
End Sub

Sub DbgViewWatches_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	#ifdef __USE_WINAPI__
		If Key = VK_RETURN AndAlso lvWatches.SelectedItem <> 0 Then DbgViewWatches_ItemDblClick Designer, lvWatches, lvWatches.SelectedItem
	#endif
End Sub

'A line of the Watches tree is edited: the empty line adds a watch, another name replaces the watch, an empty name removes it
Sub DbgViewTree_AfterLabelEdit(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef NodeLabel As WString, ByRef Cancel As Boolean)
	If @Sender <> @tvWch Then Exit Sub
	Cancel = True 'the debugger writes the lines
	If @Item <> 0 AndAlso Item.Tag = 0 Then
		'The empty line (a node of Nodes)
		If Trim(NodeLabel) <> "" Then DbgViewQueueWatchEdit 0, NodeLabel
	ElseIf DbgViewIntegrated Then
		'A line of a watch (a node of the Integrated IDE Debugger, not in Nodes, Item is 0): the edited one is selected
		#ifdef __USE_WINAPI__
			Dim As HTREEITEM hItem = TreeView_GetSelection(tvWch.Handle)
			If hItem = 0 OrElse TreeView_GetParent(tvWch.Handle, hItem) <> 0 Then Exit Sub
			Dim As UString sOld = DbgViewSourceText(dpWatches, hItem), sName, sValue, sType
			DbgViewSplitLabel sOld, sName, sValue, sType
			If Trim(NodeLabel) = Trim(sName) OrElse Trim(NodeLabel) = Trim(sOld) OrElse Trim(NodeLabel) = DbgViewWatchName(hItem) Then Exit Sub
			DbgViewQueueWatchEdit hItem, NodeLabel
		#endif
	ElseIf @Item <> 0 AndAlso Item.ParentNode = 0 Then
		'The copy of the list of GDB and LLDB with CLI, MI, DAP
		Dim As TreeListViewItem Ptr lvItem = Item.Tag
		If Trim(NodeLabel) <> Trim(lvItem->Text(0)) Then DbgViewQueueWatchEdit lvItem, NodeLabel
	End If
End Sub

'The button Remove Watch of the Watches window: the selected watch, for every debugger and view
Sub DbgViewRemoveWatch()
	If DbgViewIntegrated Then
		#ifdef __USE_WINAPI__
			Dim As Any Ptr hItem
			If DbgViewList Then
				If lvWatches.SelectedItem <> 0 AndAlso lvWatches.SelectedItem->ParentItem = 0 Then hItem = lvWatches.SelectedItem->Tag
			Else
				hItem = TreeView_GetSelection(tvWch.Handle)
				If hItem <> 0 AndAlso TreeView_GetParent(tvWch.Handle, Cast(HTREEITEM, hItem)) <> 0 Then hItem = 0
			End If
			If hItem = 0 Then Exit Sub
			DbgViewQueuedDelete = hItem
		#endif
	Else
		Dim As TreeListViewItem Ptr lvItem
		If DbgViewList Then
			lvItem = lvWatches.SelectedItem
		ElseIf tvWch.SelectedNode <> 0 Then
			lvItem = tvWch.SelectedNode->Tag
		End If
		If lvItem = 0 OrElse lvItem->ParentItem <> 0 OrElse Trim(lvItem->Text(0)) = "" Then Exit Sub
		DbgViewQueuedDelete = lvItem
	End If
	DbgViewQueuedAdd = ""
	DbgViewRunWatchEdit
End Sub

'Activation of a procedure or a frame of the copy
Sub DbgViewList_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Dim As Integer p = DbgViewPanelOfList(@Sender)
	If Item = 0 OrElse CInt(Not DbgViewCopyValid(p)) Then Exit Sub
	DbgViewSourceSelect p, Item->Tag
	If p = dpProcedures Then proc_loc
End Sub

Sub DbgViewTree_NodeActivate(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	Dim As Integer p = DbgViewPanelOfTree(@Sender)
	If @Item = 0 OrElse CInt(Not DbgViewCopyValid(p)) OrElse Item.Tag = 0 Then Exit Sub
	Dim As TreeListView Ptr lv = DbgViewPanelList(p)
	DbgViewSourceSelect p, Item.Tag
	If lv->OnItemActivate Then lv->OnItemActivate(*lv->Designer, *lv, Cast(TreeListViewItem Ptr, Item.Tag))
End Sub

'==================== Show String, the selected variable (GDB and LLDB with CLI, MI, DAP) ====================

'The selected variable of Locals, Globals or Watches: the lists of GDB and LLDB with CLI, MI, DAP (also in the tree view)
Function DbgViewCommandPanel(ByRef sCommand As String) As Integer
	If DbgViewMenuItem <> 0 Then Return DbgViewMenuPanel
	If EndsWith(sCommand, "Watch") OrElse tpWatches->IsSelected Then Return dpWatches
	If tpGlobals->IsSelected Then Return dpGlobals
	Return dpLocals
End Function

Function mem_selected_item(ByRef sCommand As String) As TreeListViewItem Ptr
	If DbgViewMenuItem <> 0 AndAlso CBool(Not DbgViewIntegrated) Then Return DbgViewMenuItem
	Dim As Integer p = DbgViewCommandPanel(sCommand)
	Dim As TreeListViewItem Ptr Item
	If DbgViewIsCopy(p) AndAlso CBool(Not DbgViewList) Then
		'The tree: its node (the item of a field is not selected in the list while its parent is collapsed)
		Dim As TreeNode Ptr tn = DbgViewPanelTree(p)->SelectedNode
		If tn <> 0 Then Item = tn->Tag
	Else
		Item = DbgViewPanelList(p)->SelectedItem
	End If
	If Item = 0 OrElse Trim(Item->Text(0)) = "" Then Return 0
	Return Item
End Function

'Show String: the text of the value of the selected variable (between its quotes), on every platform
Sub DbgViewShowString(ByRef sCommand As String)
	Dim As TreeListViewItem Ptr Item = mem_selected_item(sCommand)
	If Item = 0 Then ShowMessages ML("Select a variable"): Exit Sub
	'The text of the first quotes of the value (L"..." of a WString of -gen gas: DbgWideCharsValue)
	Dim As String s8 = ToUtf8(Item->Text(1)), sText
	Dim As Integer p1 = InStr(s8, """"), i
	If p1 = 0 Then
		MsgBox ML("Show string error: Select only a string variable")
		Exit Sub
	End If
	i = p1 + 1
	Do While i <= Len(s8)
		Dim As String c = Mid(s8, i, 1)
		If c = """" Then Exit Do
		If c = "\" AndAlso i < Len(s8) Then
			Dim As String e = Mid(s8, i + 1, 1)
			Select Case e
			Case "n": sText &= Chr(10): i += 2
			Case "r": sText &= Chr(13): i += 2
			Case "t": sText &= Chr(9): i += 2
			Case "x"
				sText &= Chr(ValInt("&H" & Mid(s8, i + 2, 2))): i += 4
			Case "0" To "7"
				Dim As Integer Code, k = i + 1
				While k <= Len(s8) AndAlso k <= i + 3 AndAlso Mid(s8, k, 1) >= "0" AndAlso Mid(s8, k, 1) <= "7"
					Code = Code * 8 + Val(Mid(s8, k, 1))
					k += 1
				Wend
				If Code = 0 Then Exit Do 'the end of the text
				sText &= Chr(Code And 255)
				i = k
			Case Else: sText &= e: i += 2
			End Select
		Else
			sText &= c
			i += 1
		End If
	Loop
	'The name of the variable: its path from the root
	Dim As UString sName
	Dim As TreeListViewItem Ptr NameItem = Item
	Do While NameItem
		sName = IIf(sName = "", NameItem->Text(0), NameItem->Text(0) & "." & sName)
		NameItem = NameItem->ParentItem
	Loop
	frmShowString.Text = ML("Show String") & ": " & sName
	txtShowString.Text = DbgText(sText)
	frmShowString.Show *pfrmMain
End Sub

'==================== Show/Expand Variable (GDB and LLDB with CLI, MI, DAP) ====================

Dim Shared As Form frmShowExpand
Dim Shared As TreeListView lvShowExpand

'Copies the node h of the data of the debugger with all its fields (Depth levels): the tree of the Integrated
'IDE Debugger or the list of GDB and LLDB with CLI, MI, DAP. The nodes expanded for their fields are collapsed again.
Sub DbgViewCopyExpanded(p As Integer, h As Any Ptr, Parent As TreeListViewItem Ptr, Depth As Integer)
	Dim As UString c0, c1, c2, c3
	DbgViewSourceColumns p, h, c0, c1, c2, c3
	Dim As UString sCells = Replace(c0, WChr(9), " ") & WChr(9) & Replace(c1, WChr(9), " ") & WChr(9) & Replace(c2, WChr(9), " ")
	Dim As TreeListViewItem Ptr Item
	If Parent = 0 Then Item = lvShowExpand.Nodes.Add(sCells) Else Item = Parent->Nodes.Add(sCells)
	Item->Tag = h
	If Depth <= 0 OrElse CInt(Not DbgViewSourceHasChildren(p, h)) Then Exit Sub
	Dim As Boolean bExpanded = DbgViewSourceExpanded(p, h)
	DbgViewSourceExpand p, h
	Dim As Any Ptr Items(Any)
	Dim As Integer n = DbgViewSourceChildren(p, h, Items())
	For i As Integer = 0 To n - 1
		If DbgViewIntegrated OrElse CBool(Cast(TreeListViewItem Ptr, Items(i))->Text(0) <> "") Then DbgViewCopyExpanded p, Items(i), Item, Depth - 1
	Next
	If DbgViewIntegrated AndAlso CBool(Not bExpanded) Then
		#ifdef __USE_WINAPI__
			TreeView_Expand(DbgViewSourceTree(p)->Handle, Cast(HTREEITEM, h), TVE_COLLAPSE)
		#else
			Cast(TreeNode Ptr, h)->Collapse
		#endif
	End If
End Sub

Sub DbgViewExpandAll(Item As TreeListViewItem Ptr)
	If Item->Nodes.Count = 0 Then Exit Sub
	Item->Expand
	For i As Integer = 0 To Item->Nodes.Count - 1
		DbgViewExpandAll Item->Nodes.Item(i)
	Next
End Sub

'Show/Expand Variable: the selected variable with its fields in a window, for every debugger
Dim Shared As Any Ptr DbgViewShowExpandRoot 'the node of the data shown in Show/Expand Variable

'Show/Expand Variable again after a change (Change Array Index, Edit Value from its menu)
Sub DbgViewShowExpandRefresh()
	If DbgViewShowExpandRoot = 0 Then Exit Sub
	If DbgViewIntegrated AndAlso CBool(Not DbgViewStopped) Then Exit Sub
	lvShowExpand.Nodes.Clear
	DbgViewCopyExpanded DbgViewShowExpandPanel, DbgViewShowExpandRoot, 0, 5
	If lvShowExpand.Nodes.Count > 0 Then DbgViewExpandAll lvShowExpand.Nodes.Item(0)
End Sub

Sub DbgViewShowExpand(ByRef sCommand As String)
	Dim As Integer p = DbgViewCommandPanel(sCommand)
	Dim As Any Ptr h
	If DbgViewMenuItem <> 0 Then
		h = DbgViewMenuItem
	ElseIf DbgViewIntegrated Then
		If Not DbgViewStopped Then Exit Sub
		If DbgViewList Then
			'The copy: its item has the node of the tree
			If DbgViewPanelList(p)->SelectedItem <> 0 Then h = DbgViewPanelList(p)->SelectedItem->Tag
		Else
			#ifdef __USE_WINAPI__
				h = TreeView_GetSelection(DbgViewSourceTree(p)->Handle)
			#else
				h = DbgViewSourceTree(p)->SelectedNode
			#endif
		End If
	Else
		h = mem_selected_item(sCommand)
	End If
	If h = 0 Then ShowMessages ML("Select a variable"): Exit Sub
	If lvShowExpand.Columns.Count = 0 Then
		frmShowExpand.SetBounds 2, 2, 600, 400
		lvShowExpand.Align = DockStyle.alClient
		lvShowExpand.Columns.Add ML("Variable"), , 200
		lvShowExpand.Columns.Add ML("Value"), , 250
		lvShowExpand.Columns.Add ML("Type"), , 120
		lvShowExpand.Images = lvLocals.Images
		lvShowExpand.StateImages = lvLocals.StateImages
		lvShowExpand.ContextMenu = @mnuShowExpand
		frmShowExpand.Add @lvShowExpand
	End If
	Dim As UString c0, c1, c2, c3
	DbgViewSourceColumns p, h, c0, c1, c2, c3
	frmShowExpand.Text = ML("Show/Expand Variable") & ": " & c0
	DbgViewShowExpandPanel = p
	DbgViewShowExpandRoot = h
	frmShowExpand.Show *pfrmMain
	lvShowExpand.Nodes.Clear
	DbgViewCopyExpanded p, h, 0, 5
	#ifdef __DBGVIEW_INTEGRATED__
		'A running function of the Integrated IDE Debugger: its return value
		If DbgViewIntegrated AndAlso p = dpLocals AndAlso lvShowExpand.Nodes.Count > 0 Then
			Dim As String sReturn = proc_return_label(h)
			If sReturn <> "" Then
				DbgViewSplitLabel ML("Return value") & " <" & sReturn, c0, c1, c2
				lvShowExpand.Nodes.Item(0)->Nodes.Add(c0 & WChr(9) & c1 & WChr(9) & c2)
			End If
		End If
	#endif
	If lvShowExpand.Nodes.Count > 0 Then DbgViewExpandAll lvShowExpand.Nodes.Item(0)
End Sub

'==================== The commands of the variables (menus of Locals, Globals, Watches, Show/Expand Variable) ====================

'The menus of Locals, Globals, Watches: their selection
Sub DbgViewVarsMenu_Popup(ByRef Designer As My.Sys.Object, ByRef Sender As PopupMenu)
	DbgViewMenuItem = 0
End Sub

'The menu of Show/Expand Variable: its selected line (the node of the data)
Sub DbgViewShowExpandMenu_Popup(ByRef Designer As My.Sys.Object, ByRef Sender As PopupMenu)
	DbgViewMenuItem = 0
	If lvShowExpand.SelectedItem <> 0 Then DbgViewMenuItem = lvShowExpand.SelectedItem->Tag
	DbgViewMenuPanel = DbgViewShowExpandPanel
	If DbgViewMenuItem = 0 Then Exit Sub
	'The data is not the same as when the window was made (after a step)
	If DbgViewIntegrated Then
		If Not DbgViewStopped Then DbgViewMenuItem = 0
	ElseIf DbgViewPanelList(DbgViewMenuPanel)->Nodes.IndexOf(Cast(TreeListViewItem Ptr, DbgViewMenuItem)) < 0 Then
		'(an item of a field: its root is in the list)
		Dim As TreeListViewItem Ptr Root = DbgViewMenuItem
		While Root->ParentItem <> 0
			Root = Root->ParentItem
		Wend
		If DbgViewPanelList(DbgViewMenuPanel)->Nodes.IndexOf(Root) < 0 Then DbgViewMenuItem = 0
	End If
End Sub

Sub DbgViewVariableCommandRun(ByRef sCommand As String)
	Select Case sCommand
	Case "EditValue", "EditValueWatch"
		DbgViewEditValue sCommand
	Case "BreakOnVariable", "BreakOnVariableValue", "BreakOnVariableCancel", "BreakOnVariableWatch", "BreakOnVariableValueWatch", "BreakOnVariableCancelWatch"
		Dim As Integer iMode = IIf(InStr(sCommand, "Cancel"), 0, IIf(InStr(sCommand, "Value"), 2, 1))
		If DbgViewIntegrated Then
			#ifdef __FB_WIN32__
				If Not DbgViewStopped Then ShowMessages ML("Break on Variable") & ": " & ML("Stop the program first"): Exit Sub
				If iMode <> 0 AndAlso DbgViewMenuItem = 0 Then
					'The selected line of the list is selected in the tree of the Integrated IDE Debugger (var_find2)
					Dim As Integer p = DbgViewCommandPanel(sCommand)
					If DbgViewList AndAlso DbgViewPanelList(p)->SelectedItem <> 0 Then DbgViewSourceSelect p, DbgViewPanelList(p)->SelectedItem->Tag
				End If
				brkv_set_ide IIf(EndsWith(sCommand, "Watch"), Cast(Any Ptr, tviewwch), Cast(Any Ptr, tviewvar)), iMode
			#else
				ShowMessages ML("This command is only for Windows")
			#endif
		Else
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				gdb_break_on_variable sCommand, iMode
			#endif
		End If
	Case "VariableDump", "PointedDataDump", "MemoryDumpWatch", "ShowStringWatch", "ShowExpandVariableWatch", "ShowString", "ShowExpandVariable"
		'The other debuggers: LLDB with CLI, MI, DAP and GDB with MI, DAP in DbgCommand, GDB with CLI here
		If Not DbgViewIntegrated Then
			Select Case sCommand
			Case "VariableDump", "PointedDataDump", "MemoryDumpWatch"
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					gdb_memory_dump sCommand
				#endif
			Case "ShowString", "ShowStringWatch"
				DbgViewShowString sCommand
			Case "ShowExpandVariable", "ShowExpandVariableWatch"
				DbgViewShowExpand sCommand
			Case Else
				ShowMessages ML("This command is only for the Integrated IDE Debugger")
			End Select
			Exit Sub
		End If
		#ifdef __DBGVIEW_INTEGRATED__
			Select Case sCommand
			Case "VariableDump":                var_dump(tviewvar)
			Case "PointedDataDump":             var_dump(tviewvar, 1)
			Case "MemoryDumpWatch":             var_dump(tviewwch)
			Case "ShowExpandVariable", "ShowExpandVariableWatch": DbgViewShowExpand sCommand
			#ifndef __USE_GTK__
			Case "ShowStringWatch":             string_sh(tviewwch)
			Case "ShowString":                  string_sh(tviewvar)
			#endif
			End Select
		#endif
	End Select
End Sub

'A command of the menus of the variables. From the menu of Show/Expand Variable: its line (of Watches: the commands of Watches)
Sub DbgViewVariableCommand(ByRef sCommand As String)
	Dim As String sCmd = sCommand
	If DbgViewMenuItem <> 0 Then
		If DbgViewMenuPanel = dpWatches AndAlso CBool(Not EndsWith(sCmd, "Watch")) Then
			Select Case sCmd
			Case "VariableDump", "PointedDataDump": sCmd = "MemoryDumpWatch"
			Case Else: sCmd &= "Watch"
			End Select
		End If
		'The commands of the Integrated IDE Debugger use the selection of its tree
		If DbgViewIntegrated Then DbgViewSourceSelect DbgViewMenuPanel, DbgViewMenuItem
	End If
	Dim As Boolean bFromShowExpand = DbgViewMenuItem <> 0
	DbgViewVariableCommandRun sCmd
	DbgViewMenuItem = 0
	If bFromShowExpand AndAlso StartsWith(sCmd, "EditValue") AndAlso frmShowExpand.Visible Then DbgViewShowExpandRefresh
End Sub

'==================== Breakpoints, Call Chain, Attach to Process (the commands of the menu Debug) ====================

#include once "mff/CommandButton.bi"
#include once "mff/Panel.bi"
#include once "mff/ListView.bi"
#ifdef __FB_WIN32__
	#include once "win/tlhelp32.bi"
#endif

Dim Shared As MenuItem Ptr miBreakpointHitCount, miBreakpointCondition
Declare Sub DbgListWindow_Message(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message)

'A window with a list and buttons (Breakpoints, Call Chain, Attach to Process)
Type DbgListWindow
	frm As Form
	lv As ListView
	pnl As Panel
	btn(5) As CommandButton
	nButtons As Integer
	SortColumn As Integer = -1 'the list sorted by the column (a click on its header), SortDesc: descending
	SortDesc As Boolean
	Declare Sub Init(ByRef sCaption As WString, Columns() As String, Widths() As Integer, Buttons() As String, eClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control))
End Type

'The lines of the list sorted by the column iCol: numbers as numbers, the texts without the case of the letters
Sub DbgListSort(ByRef lv As ListView, iCol As Integer, bDesc As Boolean)
	Dim As Integer n = lv.ListItems.Count, nc = lv.Columns.Count
	If n < 2 OrElse iCol < 0 OrElse iCol >= nc Then Exit Sub
	Dim As UString Cells(n * nc - 1)
	Dim As Integer Order(n - 1)
	Dim As Boolean bNumbers = True
	For i As Integer = 0 To n - 1
		Order(i) = i
		For c As Integer = 0 To nc - 1
			Cells(i * nc + c) = lv.ListItems.Item(i)->Text(c)
		Next
		Dim As String s = Trim(Cells(i * nc + iCol))
		If s <> "" AndAlso CBool(Str(Val(s)) <> s) Then bNumbers = False
	Next
	'Insertion sort (a few hundred lines)
	For i As Integer = 1 To n - 1
		Dim As Integer k = Order(i), j = i - 1
		Do While j >= 0
			Dim As Integer iCmp
			Dim As UString a = Cells(Order(j) * nc + iCol), b = Cells(k * nc + iCol)
			If bNumbers Then
				iCmp = Sgn(Val(a) - Val(b))
			Else
				iCmp = IIf(LCase(a) > LCase(b), 1, IIf(LCase(a) < LCase(b), -1, 0))
			End If
			If bDesc Then iCmp = -iCmp
			If iCmp <= 0 Then Exit Do
			Order(j + 1) = Order(j)
			j -= 1
		Loop
		Order(j + 1) = k
	Next
	For i As Integer = 0 To n - 1
		For c As Integer = 0 To nc - 1
			lv.ListItems.Item(i)->Text(c) = Cells(Order(i) * nc + c)
		Next
	Next
End Sub

Sub DbgListWindow.Init(ByRef sCaption As WString, Columns() As String, Widths() As Integer, Buttons() As String, eClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control))
	frm.Text = sCaption
	If lv.Columns.Count > 0 Then Exit Sub
	frm.SetBounds 2, 2, 700, 400
	frm.StartPosition = FormStartPosition.CenterParent
	pnl.Align = DockStyle.alBottom
	pnl.Height = 40
	pnl.Parent = @frm
	lv.Align = DockStyle.alClient
	lv.FullRowSelect = True
	lv.GridLines = True
	For i As Integer = 0 To UBound(Columns)
		lv.Columns.Add ML(Columns(i)), , Widths(i)
	Next
	lv.Parent = @frm
	nButtons = UBound(Buttons) + 1
	For i As Integer = 0 To UBound(Buttons)
		btn(i).Text = ML(Buttons(i))
		btn(i).Name = Buttons(i)
		btn(i).SetBounds 8 + i * 112, 7, 104, 26
		btn(i).OnClick = eClick
		btn(i).Parent = @pnl
	Next
End Sub

'==================== Breakpoints ====================

Dim Shared As DbgListWindow DbgBreakpointsWindow

'The breakpoints of the open files: File, Line, Hit Count, Condition, the text of the line
Sub DbgBreakpointsFill()
	With DbgBreakpointsWindow
		.lv.ListItems.Clear
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode_ = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For i As Integer = 0 To ptabCode_->TabCount - 1
				Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode_->Tabs[i])
				For j As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
					Dim As EditControlLine Ptr ECLine = tb->txtCode.Content.Lines.Items[j]
					If Not ECLine->Breakpoint Then Continue For
					Var Item = .lv.ListItems.Add(GetFileName(tb->FileName))
					Item->Text(1) = WStr(j + 1)
					Item->Text(2) = IIf(ECLine->BreakpointCount > 1, WStr(ECLine->BreakpointCount), "")
					Item->Text(3) = ECLine->BreakpointCondition
					Item->Text(4) = Trim(*ECLine->Text, Any !"\t ")
					Item->Text(5) = tb->FileName
				Next
			Next
		Next
	End With
End Sub

'The editor at the breakpoint of the selected line of the list
Function DbgBreakpointsGo() As Boolean
	With DbgBreakpointsWindow
		Dim As Integer i = .lv.SelectedItemIndex
		If i < 0 Then ShowMessages ML("Select a breakpoint"): Return False
		SelectSearchResult .lv.ListItems.Item(i)->Text(5), Val(.lv.ListItems.Item(i)->Text(1))
		Return True
	End With
End Function

Sub DbgBreakpointsButton_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Select Case Sender.Name
	Case "Go To"
		DbgBreakpointsGo
	Case "Delete"
		If DbgBreakpointsGo Then mClick *miToggleBreakpoint, *miToggleBreakpoint
	Case "Delete All"
		With DbgBreakpointsWindow
			For i As Integer = .lv.ListItems.Count - 1 To 0 Step -1
				SelectSearchResult .lv.ListItems.Item(i)->Text(5), Val(.lv.ListItems.Item(i)->Text(1))
				mClick *miToggleBreakpoint, *miToggleBreakpoint
			Next
		End With
	Case "Hit Count"
		If DbgBreakpointsGo AndAlso miBreakpointHitCount <> 0 Then mClick *miBreakpointHitCount, *miBreakpointHitCount
	Case "Condition"
		If DbgBreakpointsGo AndAlso miBreakpointCondition <> 0 Then mClick *miBreakpointCondition, *miBreakpointCondition
	Case "Close"
		DbgBreakpointsWindow.frm.CloseForm
		Exit Sub
	End Select
	DbgBreakpointsFill
End Sub

Sub DbgBreakpointsList_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	DbgBreakpointsGo
End Sub

Sub DbgViewBreakpoints()
	Dim As String Columns(5) = {"File", "Line", "Hit Count", "Condition", "Text", "Path"}
	Dim As Integer Widths(5) = {140, 50, 70, 160, 250, 0}
	Dim As String Buttons(5) = {"Go To", "Delete", "Delete All", "Hit Count", "Condition", "Close"}
	DbgBreakpointsWindow.Init ML("Breakpoints"), Columns(), Widths(), Buttons(), @DbgBreakpointsButton_Click
	DbgBreakpointsWindow.lv.OnItemDblClick = @DbgBreakpointsList_DblClick
	DbgBreakpointsWindow.lv.OnMessage = @DbgListWindow_Message
	DbgBreakpointsWindow.frm.Show *pfrmMain
	DbgBreakpointsFill
End Sub

'==================== Call Chain ====================

Dim Shared As DbgListWindow DbgCallChainWindow

'The path with the case of the letters of the file system (the Integrated IDE Debugger keeps the paths in lower case):
'the open file of the editor, otherwise each part of the path as it is on the disk
Function DbgRealPath(ByRef sPath As WString) As UString
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode_ = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode_->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode_->Tabs[i])
			If EqualPaths(tb->FileName, sPath) Then Return tb->FileName
		Next
	Next
	#ifdef __FB_WIN32__
		Dim As UString sSrc = Replace(sPath, "/", "\"), sOut
		Dim As Integer iStart = 1, iPos
		'The drive: upper case
		If Mid(sSrc, 2, 1) = ":" Then sOut = UCase(Left(sSrc, 2)): iStart = 4
		Do
			iPos = InStr(iStart, sSrc, "\")
			Dim As UString sPart
			If iPos Then sPart = Mid(sSrc, iStart, iPos - iStart) Else sPart = Mid(sSrc, iStart)
			If sPart <> "" Then
				Dim As UString sTry = sOut & "\" & sPart
				Dim fd As WIN32_FIND_DATAW
				Dim As HANDLE hFind = FindFirstFileW(sTry.vptr, @fd)
				If hFind <> INVALID_HANDLE_VALUE Then
					sOut &= "\" & fd.cFileName
					FindClose hFind
				Else
					sOut = sTry
				End If
			End If
			If iPos = 0 Then Exit Do
			iStart = iPos + 1
		Loop
		Return sOut
	#else
		Return sPath
	#endif
End Function

Sub DbgCallChainFill()
	With DbgCallChainWindow
		.lv.ListItems.Clear
		If DbgViewIntegrated Then
			#ifdef __USE_WINAPI__
				If Not DbgViewStopped Then ShowMessages ML("Call Chain") & ": " & ML("Stop the program first"): Exit Sub
				Dim As String Names(Any), Files(Any)
				Dim As Integer Lines(Any)
				Dim As Integer n = call_chain(Names(), Files(), Lines())
				For i As Integer = 0 To n - 1
					Var Item = .lv.ListItems.Add(Names(i))
					Item->Text(1) = WStr(Lines(i))
					Item->Text(2) = DbgRealPath(Files(i))
				Next
			#endif
		Else
			'The frames of GDB and LLDB: the selected thread of Threads (the first one without a selection)
			Dim As TreeListViewItem Ptr Thd = lvThreads.SelectedItem
			If Thd <> 0 Then
				While Thd->ParentItem <> 0
					Thd = Thd->ParentItem
				Wend
			ElseIf lvThreads.Nodes.Count > 0 Then
				Thd = lvThreads.Nodes.Item(0)
			End If
			If Thd = 0 Then Exit Sub
			DbgViewSourceExpand dpThreads, Thd
			For i As Integer = 0 To Thd->Nodes.Count - 1
				Var Frame = Thd->Nodes.Item(i)
				If Frame->Text(0) = "" Then Continue For
				Var Item = .lv.ListItems.Add(Frame->Text(0))
				Item->Text(1) = Frame->Text(1)
				Item->Text(2) = Frame->Text(2)
			Next
		End If
	End With
End Sub

Sub DbgCallChainGo()
	With DbgCallChainWindow
		Dim As Integer i = .lv.SelectedItemIndex
		If i < 0 OrElse Val(.lv.ListItems.Item(i)->Text(1)) = 0 Then Exit Sub
		SelectSearchResult .lv.ListItems.Item(i)->Text(2), Val(.lv.ListItems.Item(i)->Text(1))
	End With
End Sub

Sub DbgCallChainButton_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Select Case Sender.Name
	Case "Go To": DbgCallChainGo
	Case "Refresh": DbgCallChainFill
	Case "Close": DbgCallChainWindow.frm.CloseForm
	End Select
End Sub

Sub DbgCallChainList_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	DbgCallChainGo
End Sub

Sub DbgViewCallChain()
	Dim As String Columns(2) = {"Procedure", "Line", "File"}
	Dim As Integer Widths(2) = {220, 60, 400}
	Dim As String Buttons(2) = {"Go To", "Refresh", "Close"}
	DbgCallChainWindow.Init ML("Call Chain"), Columns(), Widths(), Buttons(), @DbgCallChainButton_Click
	DbgCallChainWindow.lv.OnItemDblClick = @DbgCallChainList_DblClick
	DbgCallChainWindow.lv.OnMessage = @DbgListWindow_Message
	DbgCallChainWindow.frm.Show *pfrmMain
	DbgCallChainFill
End Sub

'==================== Attach to Process ====================

Dim Shared As DbgListWindow DbgProcessesWindow

#ifdef __FB_LINUX__
	Declare Function readlink_ Alias "readlink"(ByVal As Const ZString Ptr, ByVal As ZString Ptr, ByVal As UInteger) As Integer
#endif

'The processes: PID, name, the path of the exe
Sub DbgProcessesFill()
	With DbgProcessesWindow
		.lv.ListItems.Clear
		#ifdef __FB_WIN32__
			'QueryFullProcessImageNameW: Windows Vista and later (the headers declare it only for _WIN32_WINNT >= &h0600)
			Dim QueryImageName As Function(ByVal As HANDLE, ByVal As DWORD, ByVal As LPWSTR, ByVal As PDWORD) As WINBOOL = DyLibSymbol(GetModuleHandle("kernel32.dll"), "QueryFullProcessImageNameW")
			Dim As HANDLE hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
			If hSnap = INVALID_HANDLE_VALUE Then Exit Sub
			Dim pe As PROCESSENTRY32W
			pe.dwSize = SizeOf(PROCESSENTRY32W)
			If Process32FirstW(hSnap, @pe) Then
				Do
					If pe.th32ProcessID <> 0 AndAlso pe.th32ProcessID <> GetCurrentProcessId() Then
						Dim As WString * 1024 wPath
						Dim As DWORD nSize = 1023
						Dim As HANDLE hp = OpenProcess(&h1000, False, pe.th32ProcessID) 'PROCESS_QUERY_LIMITED_INFORMATION
						Dim As String sBits
						If hp Then
							If QueryImageName = 0 OrElse QueryImageName(hp, 0, @wPath, @nSize) = 0 Then wPath = ""
							'A 32-bit process of a 64-bit Windows runs in WOW64
							Dim As WINBOOL bWow64
							If IsWow64Process(hp, @bWow64) Then
								#ifdef __FB_64BIT__
									sBits = IIf(bWow64, "32", "64")
								#else
									Dim As WINBOOL bSelfWow64
									IsWow64Process(GetCurrentProcess(), @bSelfWow64)
									sBits = IIf(bWow64 OrElse bSelfWow64 = 0, "32", "64")
								#endif
							End If
							CloseHandle hp
						End If
						Var Item = .lv.ListItems.Add(WStr(pe.th32ProcessID))
						Item->Text(1) = pe.szExeFile
						Item->Text(2) = sBits
						Item->Text(3) = wPath
					End If
				Loop While Process32NextW(hSnap, @pe)
			End If
			CloseHandle hSnap
		#elseif defined(__FB_LINUX__)
			'The directories of /proc are read-only (dr-xr-xr-x): Dir finds them only with fbReadOnly too
			Dim As String d = Dir("/proc/*", fbDirectory Or fbReadOnly Or fbHidden Or fbSystem Or fbArchive)
			Dim As Integer SelfPid = getpid()
			While d <> ""
				If ValInt(d) > 0 AndAlso ValInt(d) <> SelfPid Then
					Dim As String sName, sBits
					Dim As Integer Fn = FreeFile
					If Open("/proc/" & d & "/comm" For Input As #Fn) = 0 Then
						Line Input #Fn, sName
						Close #Fn
					End If
					'The path of the exe (empty for the processes of other users and for the kernel threads)
					Dim As ZString * 4097 zPath
					Dim As Integer nLen = readlink_("/proc/" & d & "/exe", @zPath, 4096)
					If nLen > 0 Then zPath[nLen] = 0 Else zPath = ""
					'ELF: the byte 4 is 1 for 32-bit, 2 for 64-bit
					Fn = FreeFile
					If zPath <> "" AndAlso Open("/proc/" & d & "/exe" For Binary Access Read As #Fn) = 0 Then
						Dim As UByte ElfClass
						Get #Fn, 5, ElfClass
						Close #Fn
						sBits = IIf(ElfClass = 1, "32", IIf(ElfClass = 2, "64", ""))
					End If
					Var Item = .lv.ListItems.Add(d)
					Item->Text(1) = sName
					Item->Text(2) = sBits
					Item->Text(3) = zPath
				End If
				d = Dir()
			Wend
		#endif
	End With
End Sub

'The list sorted again by its column (after Refresh)
Sub DbgListWindowResort(ByRef w As DbgListWindow)
	If w.SortColumn >= 0 Then DbgListSort w.lv, w.SortColumn, w.SortDesc
End Sub

'A click on the header of a column: the list sorted by it (a second click: descending)
Sub DbgListWindow_Message(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message)
	#ifdef __USE_WINAPI__
		If Msg.Msg <> CM_NOTIFY Then Exit Sub
		Dim As NMLISTVIEW Ptr lvp = Cast(NMLISTVIEW Ptr, Msg.lParam)
		If lvp = 0 OrElse lvp->hdr.code <> LVN_COLUMNCLICK Then Exit Sub
		Dim As DbgListWindow Ptr w
		If @Sender = @DbgProcessesWindow.lv Then
			w = @DbgProcessesWindow
		ElseIf @Sender = @DbgBreakpointsWindow.lv Then
			w = @DbgBreakpointsWindow
		ElseIf @Sender = @DbgCallChainWindow.lv Then
			w = @DbgCallChainWindow
		Else
			Exit Sub
		End If
		If w->SortColumn = lvp->iSubItem Then w->SortDesc = Not w->SortDesc Else w->SortColumn = lvp->iSubItem: w->SortDesc = False
		DbgListSort w->lv, w->SortColumn, w->SortDesc
	#endif
End Sub

Dim Shared As Integer DbgProcessesPid
Dim Shared As UString DbgProcessesExe

Sub DbgProcessesButton_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With DbgProcessesWindow
		Select Case Sender.Name
		Case "Attach"
			Dim As Integer i = .lv.SelectedItemIndex
			If i < 0 Then ShowMessages ML("Select a process"): Exit Sub
			DbgProcessesPid = Val(.lv.ListItems.Item(i)->Text(0))
			DbgProcessesExe = .lv.ListItems.Item(i)->Text(3)
			'The Integrated IDE Debugger debugs the processes of its bitness
			Dim As DebuggerTypes DebuggerType = IIf(tbt32Bit->Checked, CurrentDebuggerType32, CurrentDebuggerType64)
			If DebuggerType = IntegratedIDEDebugger AndAlso .lv.ListItems.Item(i)->Text(2) <> "" Then
				#ifdef __FB_64BIT__
					'The 64-bit IDE debugs the 32-bit (WOW64) and the 64-bit processes
				#else
					If .lv.ListItems.Item(i)->Text(2) <> "32" Then MsgBox ML("The Integrated IDE Debugger of the 32-bit IDE debugs only 32-bit processes (use the 64-bit IDE or GDB)"): Exit Sub
				#endif
			End If
			.frm.ModalResult = ModalResults.OK
			.frm.CloseForm
		Case "Refresh"
			DbgProcessesFill
			DbgListWindowResort DbgProcessesWindow
		Case "Cancel"
			.frm.ModalResult = ModalResults.Cancel
			.frm.CloseForm
		End Select
	End With
End Sub

Sub DbgProcessesList_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	DbgProcessesButton_Click Designer, DbgProcessesWindow.btn(0)
End Sub

'Attach to Process: the chosen process is debugged by the debugger of the IDE (the start of the debugging with AttachPid)
Sub DbgViewAttach()
	If InDebug OrElse Running Then ShowMessages ML("Attach to Process") & ": " & ML("Stop debugging first"): Exit Sub
	#ifdef __USE_EXTERNAL_DEBUGGERS__
		If DbgActive Then ShowMessages ML("Attach to Process") & ": " & ML("Stop debugging first"): Exit Sub
	#endif
	Dim As String Columns(3) = {"PID", "Name", "Bits", "Path"}
	Dim As Integer Widths(3) = {70, 180, 45, 400}
	Dim As String Buttons(2) = {"Attach", "Refresh", "Cancel"}
	DbgProcessesWindow.Init ML("Attach to Process"), Columns(), Widths(), Buttons(), @DbgProcessesButton_Click
	DbgProcessesWindow.lv.OnItemDblClick = @DbgProcessesList_DblClick
	DbgProcessesWindow.lv.OnMessage = @DbgListWindow_Message
	DbgProcessesFill
	DbgListWindowResort DbgProcessesWindow
	DbgProcessesPid = 0
	DbgProcessesWindow.frm.ModalResult = ModalResults.Cancel
	If DbgProcessesWindow.frm.ShowModal(*pfrmMain) <> ModalResults.OK OrElse DbgProcessesPid = 0 Then Exit Sub
	If DbgProcessesExe = "" Then ShowMessages ML("Attach to Process") & ": " & ML("The path of the exe is not known (run the IDE as administrator)"): Exit Sub
	AttachPid = DbgProcessesPid
	AttachExe = DbgProcessesExe
	'The start of the debugger (Start): it attaches to the process
	If Not UseDebugger Then ChangeUseDebugger True
	mClick *mnuStart, *mnuStart
End Sub

'The commands of the menu Debug and of the menus of the variables and of the memory
Sub DbgViewDebugCommand(ByRef sCommand As String)
	Select Case sCommand
	Case "Breakpoints": DbgViewBreakpoints
	Case "CallChain": DbgViewCallChain
	Case "AttachToProcess": DbgViewAttach
	Case "BreakOnMemory"
		Dim As UString sNew = InputBox(ML("Break on Memory Address"), ML("Address and size in bytes (1, 2, 4, 8)") & WChr(10) & "&H4C7020, 4", "&H" & Hex(dumpadr) & ", 4")
		If sNew = "" Then Exit Sub
		Dim As String s = sNew
		Dim As Integer p = InStr(s, ","), nSize = 4
		If p Then nSize = ValInt(Mid(s, p + 1)): s = Left(s, p - 1)
		If nSize <> 1 AndAlso nSize <> 2 AndAlso nSize <> 4 AndAlso nSize <> 8 Then nSize = 4
		Dim As LongInt ad = mem_parse_address(s)
		If ad = 0 Then Exit Sub
		If DbgViewIntegrated Then
			#ifdef __FB_WIN32__
				If Not DbgViewStopped Then ShowMessages ML("Break on Memory Address") & ": " & ML("Stop the program first"): Exit Sub
				brkv_set_memory ad, nSize
			#endif
		Else
			gdb_break_on_memory ad, nSize
		End If
	#ifdef __USE_WINAPI__
	Case "ChangeArrayIndex", "TrackArrayIndex", "StopArrayTracking"
		If Not DbgViewIntegrated Then ShowMessages ML("This command is only for the Integrated IDE Debugger"): Exit Sub
		If Not DbgViewStopped Then ShowMessages ML("Stop the program first"): Exit Sub
		'The line of Show/Expand Variable (its menu) or the selected line of the list in the tree of the Integrated IDE Debugger
		Dim As Integer pp = DbgViewCommandPanel(sCommand)
		If DbgViewMenuItem <> 0 Then
			If DbgViewMenuPanel = dpWatches Then ShowMessages ML("Select an array of Locals or Globals"): DbgViewMenuItem = 0: Exit Sub
			DbgViewSourceSelect DbgViewMenuPanel, DbgViewMenuItem
		ElseIf DbgViewList AndAlso DbgViewPanelList(pp)->SelectedItem <> 0 Then
			DbgViewSourceSelect pp, DbgViewPanelList(pp)->SelectedItem->Tag
		End If
		DbgViewMenuItem = 0
		Select Case sCommand
		Case "ChangeArrayIndex": arr_index_change
		Case "TrackArrayIndex": arr_track
		Case "StopArrayTracking": arr_track_stop
		End Select
		'Show/Expand Variable shows the new element
		If frmShowExpand.Visible Then DbgViewShowExpandRefresh
	#endif
	Case "EditMemory": mem_edit
	Case "GoToAddress": mem_goto
	Case "RefreshMemory": mem_refresh_any
	End Select
End Sub

Sub DbgViewMemory_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	mem_edit
End Sub
