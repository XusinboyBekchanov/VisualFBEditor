'#########################################################
'#  TabWindow.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "TabWindow.bi"
#include once "vbcompat.bi"  ' for could using format function
#define TabSpace IIf(TabAsSpaces AndAlso ChoosedTabStyle = 0, WSpace(TabWidth), !"\t")

Dim Shared FPropertyItems As WStringList
Dim Shared FListItems As WStringList
Dim Shared txtCodeBi As EditControl
txtCodeBi.WithHistory = False

Destructor ExplorerElement
	If FileName Then Deallocate_( FileName)
	If TemplateFileName Then Deallocate_( TemplateFileName)
End Destructor

Constructor ProjectElement
	WLet(FileDescription, "{ProjectDescription}")
	WLet(ProductName, "{ProjectName}")
End Constructor

Destructor ProjectElement
	WDeallocate MainFileName
	WDeallocate ResourceFileName
	WDeallocate IconResourceFileName
	WDeallocate ProjectName
	WDeallocate HelpFileName
	WDeallocate ProjectDescription
	WDeallocate ApplicationTitle
	WDeallocate ApplicationIcon
	WDeallocate CompanyName
	WDeallocate FileDescription
	WDeallocate InternalName
	WDeallocate LegalCopyright
	WDeallocate LegalTrademarks
	WDeallocate OriginalFilename
	WDeallocate ProductName
	WDeallocate CompilationArguments32Windows
	WDeallocate CompilationArguments64Windows
	WDeallocate CompilationArguments32Linux
	WDeallocate CompilationArguments64Linux
	WDeallocate CommandLineArguments
	Files.Clear
End Destructor

Destructor TypeElement
	Elements.Clear
End Destructor

Public Sub MoveCloseButtons()
	Dim As Rect RR
	For i As Integer = 0 To pTabCode->TabCount - 1
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->Tabs[i])
		If tb = 0 Then Continue For
		#ifndef __USE_GTK__
			pTabCode->Perform(TCM_GETITEMRECT, tb->Index, CInt(@RR))
			MoveWindow tb->btnClose.Handle, RR.Right - 18, 4, 14, 14, True
		#endif
	Next i
End Sub

Sub PopupClick(ByRef Sender As My.Sys.Object)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 Then Exit Sub
	Select Case Sender.ToString
	Case "Default":         DesignerDblClickControl(*tb->Des, tb->Des->GetControl(tb->Des->FSelControl))
	Case "Copy":            tb->Des->CopyControl()
	Case "Cut":             tb->Des->CutControl()
	Case "Paste":           tb->Des->PasteControl()
	Case "Delete":          tb->Des->DeleteControl()
	Case "BringToFront":    tb->Des->BringToFront()
	Case "SendToBack":      tb->Des->SendToBack()
	Case "Properties":      If tb->Des->OnClickProperties Then tb->Des->OnClickProperties(*tb->Des, tb->Des->GetControl(tb->Des->FSelControl))
	End Select
End Sub

' Could not find in the child node
Function FileNameInTreeNode(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
	If tn = 0 Then Return 0
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr FindNode
	Dim tParent As Boolean
	If tn->Tag <> 0 Then
		ee = tn->Tag
		If EqualPaths(*ee->FileName, FileName) Then Return tn
	End If
	If tn->Nodes.Count > 0 Then
		For i As Integer = 0 To tn->Nodes.Count - 1
			FindNode = FileNameInTreeNode(tn->Nodes.Item(i), FileName)
			If FindNode <> 0 Then Return FindNode
		Next
	End If
	Return 0
End Function

Sub FormatProject(UnFormat As Any Ptr)
	Dim As TreeNode Ptr tn, tn1, tn2 = ptvExplorer->SelectedNode
	Dim As ExplorerElement Ptr ee
	Dim As EditControl txt
	Dim As EditControl Ptr ptxt
	Dim As TabWindow Ptr tb, tbCurrent = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim FileEncoding As FileEncodings, NewLineType As NewLineTypes
	If tn2 <> 0 Then tn2 = GetParentNode(tn2)
	If tn2 = 0 OrElse tn2->ImageKey <> "Project" Then Exit Sub
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateLock
	pfrmMain->Enabled = False
	StartProgress
	For i As Integer = 0 To tn2->Nodes.Count - 1
		tn = tn2->Nodes.Item(i)
		ee = tn->Tag
		If ee = 0 Then
			For j As Integer = 0 To tn->Nodes.Count - 1
				tn1 = tn->Nodes.Item(j)
				If tn1 <> 0 Then
					ee = tn1->Tag
					If ee <> 0 AndAlso (EndsWith(*ee->FileName, ".bas") OrElse EndsWith(*ee->FileName, ".bi") OrElse EndsWith(*ee->FileName, ".inc")) Then
						tb = GetTab(*ee->FileName)
						If tb = 0 Then
							txt.LoadFromFile(*ee->FileName, FileEncoding, NewLineType)
							ptxt = @txt
						Else
							ptxt = @tb->txtCode
						End If
						If UnFormat Then ptxt->UnFormatCode(True) Else ptxt->FormatCode(True)
						If tb = 0 Then ptxt->SaveToFile(*ee->FileName, FileEncoding, NewLineType)
					End If
				End If
			Next
		ElseIf (EndsWith(*ee->FileName, ".bas") OrElse EndsWith(*ee->FileName, ".bi") OrElse EndsWith(*ee->FileName, ".inc")) Then
			tb = GetTab(*ee->FileName)
			If tb = 0 Then
				txt.LoadFromFile(*ee->FileName, FileEncoding, NewLineType)
				ptxt = @txt
			Else
				ptxt = @tb->txtCode
			End If
			If UnFormat Then ptxt->UnFormatCode(True) Else ptxt->FormatCode(True)
			If tb = 0 Then ptxt->SaveToFile(*ee->FileName, FileEncoding, NewLineType)
		End If
	Next
	StopProgress
	pfrmMain->Enabled = True
	If tbCurrent <> 0 Then tbCurrent->txtCode.UpdateUnLock
	MsgBox ML("Done") & "!"
End Sub

Function GetTab(ByRef FileName As WString) As TabWindow Ptr
	Dim As TabWindow Ptr tb
	For i As Integer = 0 To pTabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, pTabCode->Tabs[i])
		If EqualPaths(tb->FileName, FileName) Then Return tb
	Next i
	Return 0
End Function

Function GetTabFromTn(tn As TreeNode Ptr) As TabWindow Ptr
	Dim As TabWindow Ptr tb
	For i As Integer = 0 To pTabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, pTabCode->Tabs[i])
		If tb->tn = tn Then Return tb
	Next i
	Return 0
End Function

Function AddTab(ByRef FileName As WString = "", bNew As Boolean = False, TreeN As TreeNode Ptr = 0, bNoActivate As Boolean = False) As TabWindow Ptr
	On Error Goto ErrorHandler
	Dim bFind As Boolean
	Dim As UString FileNameNew
	Dim As TabWindow Ptr tb
	FileNameNew = FileName
	If EndsWith(FileNameNew, ":") Then FileNameNew = Left(FileNameNew, Len(FileNameNew) - 1)
	If FileName <> "" Then
		For i As Integer = 0 To pTabCode->TabCount - 1
			If EqualPaths(Cast(TabWindow Ptr, pTabCode->Tabs[i])->FileName, FileNameNew) Then
				bFind = True
				tb = Cast(TabWindow Ptr, pTabCode->Tabs[i])
				If Not bNoActivate Then tb->SelectTab
				Return tb
			End If
		Next i
		If Not bFind Then
			Dim tn2 As TreeNode Ptr
			For i As Integer = 0 To ptvExplorer->Nodes.Count - 1
				tn2 = FileNameInTreeNode(ptvExplorer->Nodes.Item(i), FileNameNew)
				If tn2 <> 0 Then
					TreeN = tn2
					Exit For
				End If
			Next i
		End If
	End If
	pTabCode->UpdateLock
	If Not bFind Then
		tb = New_( TabWindow(FileNameNew, bNew, TreeN))
		With *tb
			If FileName <> "" Then
				#ifndef __USE_GTK__
					.DateFileTime = GetFileLastWriteTime(FileNameNew)
				#endif
			End If
			tb->UseVisualStyleBackColor = True
			tb->txtCode.CStyle = CInt(EndsWith(LCase(FileName), ".rc")) OrElse CInt(EndsWith(LCase(FileName), ".c")) OrElse CInt(EndsWith(LCase(FileName), ".cpp")) OrElse CInt(EndsWith(LCase(FileName), ".h")) OrElse CInt(EndsWith(LCase(FileName), ".xml"))
			tb->txtCode.SyntaxEdit = tb->txtCode.CStyle OrElse CInt(FileName = "") OrElse CInt(EndsWith(LCase(FileName), ".bas")) OrElse CInt(EndsWith(LCase(FileName), ".frm")) OrElse CInt(EndsWith(LCase(FileName), ".bi")) OrElse CInt(EndsWith(LCase(FileName), ".inc"))
			'.txtCode.ContextMenu = @mnuCode
			pTabCode->AddTab(Cast(TabPage Ptr, tb))
			#ifdef __USE_GTK__
				'.layout = gtk_layout_new(NULL, NULL)
				'gtk_widget_set_size_request(.layout, 16, 16)
				'gtk_layout_put(gtk_layout(.layout), .btnClose.widget, 0, 0)
				gtk_box_pack_end (GTK_BOX (._box), .btnClose.widget, False, False, 0)
				gtk_widget_show_all(._box)
			#else
				pTabCode->Add(@.btnClose)
			#endif
			If Not bNoActivate Then .SelectTab Else .Visible = True: pTabCode->RequestAlign: .Visible = False
			.tbrTop.Buttons.Item(1)->Checked = True
			If FileName <> "" Then
				.txtCode.LoadFromFile(FileNameNew, tb->FileEncoding, tb->NewLineType)
				.txtCode.ClearUndo
				.Modified = bNew
			Else
				#ifdef __FB_WIN32__
					tb->NewLineType = NewLineTypes.WindowsCRLF
				#else
					tb->NewLineType = NewLineTypes.LinuxLF
				#endif
				tb->FileEncoding = FileEncodings.Utf8
			End If
			ChangeFileEncoding tb->FileEncoding
			ChangeNewLineType tb->NewLineType
			.FormDesign(bNoActivate)
		End With
		MoveCloseButtons
	End If
	tb->txtCode.SetFocus
	pTabCode->UpdateUnLock
	Return tb
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Sub m(ByRef msg As WString, Debug As Boolean = False)
	If Debug AndAlso Not DisplayWarningsInDebug Then Exit Sub
	ShowMessages msg
End Sub

Sub OnChangeEdit(ByRef Sender As Control)
	Static CurLine As Integer, bChanged As Boolean
	Var tb = Cast(TabWindow Ptr, Sender.Tag)
	If tb = 0 Then Exit Sub
	tb->Modified = True
	TextChanged = True
	'    'Exit Sub
	'    With tb->txtCode
	'        If Not .Focused Then Exit Sub
	'        tb->FormDesign tb->tbrTop.Buttons.Item(1)->Checked
	'    End With
End Sub

Declare Function get_var_value(VarName As String, LineIndex As Integer) As String

Sub OnMouseMoveEdit(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
'	Var tb = Cast(TabWindow Ptr, Sender.Tag)
'	If tb = 0 Then Exit Sub
'	#ifndef __USE_GTK__
'		Dim ByRef As HWND hwndTT = tb->txtCode.ToolTipHandle
'		If hwndTT <> 0 Then
'			Dim As TOOLINFO    ti
'			ZeroMemory(@ti, SizeOf(ti))
'			ti.cbSize = SizeOf(ti)
'			ti.hwnd   = tb->txtCode.Handle
'			SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
'			SendMessage(hwndTT, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
'		End If
'	#endif
End Sub

Sub OnMouseHoverEdit(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		If Not InDebug Then Exit Sub
		Var tb = Cast(TabWindow Ptr, Sender.Tag)
		If tb = 0 Then Exit Sub
		Dim As String Word = tb->txtCode.GetWordAtPoint(X, Y, True)
		If Word <> "" Then
			Dim As UString Value
			Value = get_var_value(Word, tb->txtCode.LineIndexFromPoint(X, Y))
			If Value <> "" Then
				Dim ByRef As HWND hwndTT = tb->txtCode.ToolTipHandle
				Dim As TOOLINFO    ti
				ZeroMemory(@ti, SizeOf(ti))
				ti.cbSize = SizeOf(ti)
				ti.hwnd   = tb->txtCode.Handle
				'ti.uId    = Cast(UINT, FHandle)
				If hwndTT = 0 Then
					hwndTT = CreateWindow(TOOLTIPS_CLASS, "", WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, Cast(HMENU, NULL), GetModuleHandle(NULL), NULL)
					
					ti.uFlags = TTF_IDISHWND Or TTF_TRACK Or TTF_ABSOLUTE Or TTF_PARSELINKS Or TTF_TRANSPARENT
					ti.hinst  = GetModuleHandle(NULL)
					ti.lpszText  = Value.vptr
					'SendMessage(hwndTT, TTM_SETDELAYTIME, TTDT_INITIAL, 100)
					SendMessage(hwndTT, TTM_ADDTOOL, 0, Cast(LPARAM, @ti))
				Else
					SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
					
					ti.lpszText = Value.vptr
					
					SendMessage(hwndTT, TTM_UPDATETIPTEXT, 0, CInt(@ti))
				End If
				Dim As Point Pt
				Pt.X = X
				Pt.Y = Y
				ClientToScreen tb->txtCode.Handle, @Pt
				SendMessage(hwndTT, TTM_TRACKPOSITION, 0, MAKELPARAM(Pt.X, Pt.Y + 10))
				SendMessage(hwndTT, TTM_SETMAXTIPWIDTH, 0, 1000)
				SendMessage(hwndTT, TTM_TRACKACTIVATE, True, Cast(LPARAM, @ti))
				tb->txtCode.ToolTipHandle = hwndTT
				'tb->txtCode.ShowHint = True
				Exit Sub
			End If
		End If
		Dim ByRef As HWND hwndTT = tb->txtCode.ToolTipHandle
		If hwndTT <> 0 Then
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = tb->txtCode.Handle
			SendMessage(hwndTT, TTM_GETTOOLINFO, 0, CInt(@ti))
			SendMessage(hwndTT, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
		End If
	#endif
End Sub

Function IsLabel(ByRef LeftA As WString) As Boolean
	Dim strLeftA As String = Trim(LeftA, Any !"\t ")
	If EndsWith(strLeftA, ":") Then
		strLeftA = LCase(Left(strLeftA, Len(strLeftA) - 1))
		Dim t As Integer
		If InStr("," & SingleConstructions & ",", "," & strLeftA & ",") > 0 Then Return False
		For i As Integer = 1 To Len(strLeftA)
			t = Asc(Mid(strLeftA, i, 1))
			If t >= 48 And t <= 57 Or t >= 65 And t <= 90 Or t >= 97 And t <= 122 Or t = Asc("_") Then
			Else: Return False
			End If
		Next
		Return True
	Else
		Return False
	End If
End Function

Property TabWindow.Modified As Boolean
	Return txtCode.Modified
End Property

Property TabWindow.Modified(Value As Boolean)
	If Value Then
		If Not EndsWith(Caption, "*") Then
			Caption = Caption + "*"
			MoveCloseButtons
		End If
	Else
		If EndsWith(Caption, "*") Then
			Caption = Left(Caption, Len(Caption) - 1)
		End If
	End If
	txtCode.Modified = Value
End Property

'Function Likes(a As String, ContructionPart As String) As Boolean
'  Dim m As Variant, k As Long
'  m = Split(ContructionPart, ",")
'  For k = 0 To UBound(m)
'    If LCase(Trim(a)) Like LCase(m(k)) Then
'      Likes = True
'      Exit Function
'    End If
'  Next k
'End Function
'
'Function GetLikeConstruction(a As String, Optional k As Integer = 0, Optional e As Integer = 0) As Long
'  Dim i As Long
'  GetLikeConstruction = -1
'  If a = "" Then Exit Function
'  For i = 0 To 12
'    If Likes(a, Constructions(i, 0)) And Not Likes(a, Constructions(i, 3)) And k >= 0 Then
'      GetLikeConstruction = i: e = 1
'      Exit Function
'    ElseIf Likes(a, Constructions(i, 1)) And k <= 0 Then
'      GetLikeConstruction = i: e = 2
'      Exit Function
'    ElseIf Likes(a, Constructions(i, 2)) And k <= 1 Then
'      GetLikeConstruction = i: e = 3
'      Exit Function
'    End If
'  Next i
'End Function
'
Sub CloseButton_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim tb As TabWindow Ptr = Cast(CloseButton Ptr, @Sender)->tbParent
	If tb = 0 Then Exit Sub
	CloseTab(tb)
End Sub

Sub CloseButton_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim btn As CloseButton Ptr = Cast(CloseButton Ptr, @Sender)
	If btn->BackColor = clRed Then Exit Sub
	#ifndef __USE_GTK__
		btn->BackColor = clRed
		btn->Font.Color = clWhite
	#endif
	btn->MouseIn = True
	'DeAllocate btn
End Sub

Sub CloseButton_MouseLeave(ByRef Sender As Control)
	Dim btn As CloseButton Ptr = Cast(CloseButton Ptr, @Sender)
	#ifndef __USE_GTK__
		btn->BackColor = btn->OldBackColor
		btn->Font.Color = btn->OldForeColor
	#endif
	btn->MouseIn = False
End Sub

#ifdef __USE_GTK__
	Function CloseButton_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
		Dim As CloseButton Ptr cb = Cast(Any Ptr, data1)
		
		cairo_select_font_face(cr, "Noto Mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
		cairo_set_font_size(cr, 11)
		
		#ifdef __USE_GTK3__
			Var width1 = gtk_widget_get_allocated_width (widget)
			Var height1 = gtk_widget_get_allocated_height (widget)
		#else
			Var width1 = widget->allocation.width
			Var height1 = widget->allocation.height
		#endif
		
		If cb->MouseIn Then
			cairo_rectangle(cr, width1 - 16, (height1 - 16) / 2, 16, 16)
			cairo_set_source_rgb(cr, 1.0, 0.0, 0.0)
			cairo_fill (cr)
			cairo_set_source_rgb(cr, 1.0, 1.0, 1.0)
		Else
			cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
		End If
		Dim As PangoRectangle extend
		pango_layout_set_text(cb->layout, ToUTF8("×"), Len(ToUTF8("×")))
		pango_cairo_update_layout(cr, cb->layout)
		#ifdef PANGO_VERSION
			Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(cb->layout, 0)
		#else
			Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(cb->layout, 0)
		#endif
		pango_layout_line_get_pixel_extents(pl, NULL, @extend)
		cairo_move_to(cr, width1 - 16 + (16 - extend.width) / 2, (height1 - extend.height) / 2 + extend.height - 3)
		pango_cairo_show_layout_line(cr, pl)
		Return False
	End Function
	
	Function CloseButton_OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
		Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
		CloseButton_OnDraw(widget, cr, data1)
		cairo_destroy(cr)
		Return False
	End Function
#endif

Constructor CloseButton
	Base.OnMouseUp = @CloseButton_MouseUp
	OnMouseMove = @CloseButton_MouseMove
	OnMouseLeave = @CloseButton_MouseLeave
	OldBackColor = This.BackColor
	OldForeColor = This.Font.Color
	#ifdef __USE_GTK__
		#ifdef __USE_GTK3__
			g_signal_connect(widget, "draw", G_CALLBACK(@CloseButton_OnDraw), @This)
		#else
			g_signal_connect(widget, "expose-event", G_CALLBACK(@CloseButton_OnExposeEvent), @This)
		#endif
		This.Width = 20
		This.Height = 20
		Dim As PangoContext Ptr pcontext
		pcontext = gtk_widget_create_pango_context(widget)
		layout = pango_layout_new(pcontext)
		Dim As PangoFontDescription Ptr desc
		desc = pango_font_description_from_string ("Noto Mono 11")
		pango_layout_set_font_description (layout, desc)
		pango_font_description_free (desc)
	#else
		This.Alignment = taCenter
		Caption = "×"
	#endif
	'SubClass = True
End Constructor

Destructor CloseButton
	
End Destructor

Property TabWindow.Caption ByRef As WString
	Return WGet(FCaptionNew)
End Property

Property TabWindow.Caption(ByRef Value As WString)
	FCaptionNew = Reallocate_(FCaptionNew, (Len(Value) + 1) * SizeOf(WString))
	*FCaptionNew = Value
	#ifdef __USE_GTK__
		Base.Caption = Value
	#else
		Base.Caption = Value + Space(5)
	#endif
End Property

Property TabWindow.FileName ByRef As WString
	If WGet(FFileName) = "" Then
		Return ML("Untitled")
	Else
		Return WGet(FFileName)
	End If
End Property

Property TabWindow.FileName(ByRef Value As WString)
	wLet(FFileName,  Value)
End Property

Operator TabWindow.Cast As TabPage Ptr
	Return Cast(TabPage Ptr, @This)
End Operator

Function TabWindow.SaveTab As Boolean
	'  It is important to creat a backup file by time.
	'If txtCode.Modified = True Then
	If AutoCreateBakFiles Then
		FileCopy *FFileName, Str(GetBakFileName(*FFileName)) '
	End If
	txtCode.SaveToFile(*FFileName, FileEncoding, NewLineType) ', False
	Modified = False
	#ifndef __USE_GTK__
		DateFileTime = GetFileLastWriteTime(*FFileName)
	#endif
	Var FileIndex = IncludeFiles.IndexOf(FileName)
	If FileIndex <> 0 Then
		MutexLock tlockSave
		Dim As TypeElement Ptr te, te1
		For i As Integer = pGlobalNamespaces->Count - 1 To 0 Step -1
			te = pGlobalNamespaces->Object(i)
			For j As Integer = te->Elements.Count - 1 To 0 Step -1
				te1 = te->Elements.Object(j)
				If te1->FileName = *FFileName Then 
					te->Elements.Remove j
				End If
			Next
		Next
		For i As Integer = pGlobalNamespaces->Count - 1 To 0 Step -1
			te = pGlobalNamespaces->Object(i)
			If te->FileName = FileName Then
				te->Elements.Clear
				Delete_(Cast(TypeElement Ptr, pGlobalNamespaces->Object(i)))
				pGlobalNamespaces->Remove i
			End If
		Next
		For i As Integer = pGlobalTypes->Count - 1 To 0 Step -1
			te = pGlobalTypes->Object(i)
			If te->FileName = FileName Then
				For j As Integer = te->Elements.Count - 1 To 0 Step -1
					Delete_(Cast(TypeElement Ptr, te->Elements.Object(j)))
				Next
				te->Elements.Clear
				Delete_(Cast(TypeElement Ptr, pGlobalTypes->Object(i)))
				pGlobalTypes->Remove i
			Else
				For j As Integer = te->Elements.Count - 1 To 0 Step -1
					te1 = te->Elements.Object(j)
					If te1->FileName = FileName Then 
						Delete_(Cast(TypeElement Ptr, te->Elements.Object(j)))
						te->Elements.Remove j
					End If
				Next
			End If
		Next
		For i As Integer = pComps->Count - 1 To 0 Step -1
			te = pComps->Object(i)
			If te->FileName = FileName Then
				For j As Integer = te->Elements.Count - 1 To 0 Step -1
					Delete_(Cast(TypeElement Ptr, te->Elements.Object(j)))
				Next
				te->Elements.Clear
				Delete_(Cast(TypeElement Ptr, pComps->Object(i)))
				pComps->Remove i
			Else
				For j As Integer = te->Elements.Count - 1 To 0 Step -1
					te1 = te->Elements.Object(j)
					If te1->FileName = FileName Then 
						Delete_(Cast(TypeElement Ptr, te->Elements.Object(j)))
						te->Elements.Remove j
					End If
				Next
			End If
		Next
		For i As Integer = pGlobalEnums->Count - 1 To 0 Step -1
			te = pGlobalEnums->Object(i)
			If te->FileName = FileName Then
				For j As Integer = te->Elements.Count - 1 To 0 Step -1
					Delete_(Cast(TypeElement Ptr, te->Elements.Object(j)))
				Next
				te->Elements.Clear
				Delete_(Cast(TypeElement Ptr, pGlobalEnums->Object(i)))
				pGlobalEnums->Remove i
			End If
		Next
		For i As Integer = pGlobalFunctions->Count - 1 To 0 Step -1
			te = pGlobalFunctions->Object(i)
			If te->FileName = FileName Then
				Delete_(Cast(TypeElement Ptr, pGlobalFunctions->Object(i)))
				pGlobalFunctions->Remove i
			End If
		Next
		For i As Integer = pGlobalArgs->Count - 1 To 0 Step -1
			te = pGlobalArgs->Object(i)
			If te->FileName = FileName Then
				Delete_(Cast(TypeElement Ptr, pGlobalArgs->Object(i)))
				pGlobalArgs->Remove i
			End If
		Next
		If Not pLoadPaths->Contains(FileName) Then
			pLoadPaths->Add FileName
		End If
		'LoadFunctions FileName, LoadParam.OnlyFilePathOverwrite, GlobalTypes, GlobalEnums, GlobalFunctions, GlobalArgs
		MutexUnlock tlockSave
		ThreadCreate(@LoadOnlyFilePathOverwrite, @pLoadPaths->Item(pLoadPaths->IndexOf(FileName)))
	End If
	Return True
End Function

Function TabWindow.SaveAs As Boolean
	SetSaveDialogParameters(FileName)
	If pSaveD->Execute Then
		WLet(LastOpenPath, GetFolderName(pSaveD->FileName))
		If FileExists(pSaveD->FileName) Then
			Select Case MsgBox(ML("Want to replace the file") & " """ & pSaveD->Filename & """?", pApp->Title, mtWarning, btYesNoCancel)
			Case mrCANCEL: Return False
			Case mrNO: Return SaveAs
			End Select
		End If
		Caption = GetFileName(pSaveD->Filename)
		tn->Text = Caption
		WLet(FFileName, pSaveD->Filename)
		Dim As ExplorerElement Ptr ee = tn->Tag
		Dim As TreeNode Ptr ptn = GetParentNode(tn)
		If ee = 0 Then
			ee = New_( ExplorerElement)
			tn->Tag = ee
		End If
		If ptn <> 0 AndAlso ptn->ImageKey = "Project" Then
			Dim As ProjectElement Ptr pee = ptn->Tag
			If pee <> 0 Then
				If WGet(pee->MainFileName) = WGet(ee->FileName) Then WLet(pee->MainFileName, pSaveD->Filename)
				If WGet(pee->ResourceFileName) = WGet(ee->FileName) Then WLet(pee->ResourceFileName, pSaveD->Filename)
				If WGet(pee->IconResourceFileName) = WGet(ee->FileName) Then WLet(pee->IconResourceFileName, pSaveD->Filename)
				If Not EndsWith(ptn->Text, "*") Then ptn->Text & = "*"
			End If
		End If
		WLet(ee->FileName, pSaveD->Filename)
		AddMRUFile pSaveD->Filename
		Return SaveTab
	End If
	Return False
End Function

Function TabWindow.Save As Boolean
	If InStr(*FFileName, "/") > 0 OrElse InStr(*FFileName, "\") > 0 Then Return SaveTab Else Return SaveAs
End Function

Function CloseTab(ByRef tb As TabWindow Ptr) As Boolean
	If tb <> 0 AndAlso tb->CloseTab Then Delete_(tb): Return True Else Return False
End Function

Function TabWindow.CloseTab As Boolean
	If txtCode.Modified Then
		Select Case MsgBox(ML("Want to save the file") & " """ & Caption & """?", "Visual FB Editor", mtWarning, btYesNoCancel)
		Case mrYes: Save
		Case mrNo:
		Case mrCancel: Return False
		End Select
	End If
	pTabCode->Remove(@btnClose)
	btnClose.FreeWnd
	pTabCode->DeleteTab(This.Index)
	If tn <> 0 AndAlso tn->ImageKey <> "Project" Then ', Will remove all project from tree
		If ptvExplorer->Nodes.IndexOf(tn) <> -1 Then
			If tn->Tag <> 0 Then Delete_(Cast(ExplorerElement Ptr, tn->Tag))
			ptvExplorer->Nodes.Remove ptvExplorer->Nodes.IndexOf(tn)
			If MainNode = tn Then
				MainNode = 0
				SetMainNode 0
			End If
		End If
	End If
	If ptabCode->TabCount = 0 Then pfrmMain->Caption = pApp->Title
	MoveCloseButtons
	FreeWnd
	Return True
End Function

'Sub TabWindow.FindProceduresAndTypes

'End Sub

Sub TabWindow.FillProperties(ByRef ClassName As WString)
	If ClassName = "" Then Exit Sub
	If pComps->Contains(ClassName) Then
		tbi = pComps->Object(pComps->IndexOf(ClassName))
		If tbi Then
			i = 0
			Do While i <= tbi->Elements.Count - 1
				te = tbi->Elements.Object(i)
				If te Then
					With *te
						If .Locals = 0 Then
							If Not FPropertyItems.Contains(.Name) Then
								FPropertyItems.Add .Name, te
							End If
						End If
					End With
				End If
				i += 1
			Loop
			FillProperties tbi->TypeName
		End If
	End If
End Sub

Function WithoutPtr(TypeName As String) As String
	If EndsWith(LCase(TypeName), " ptr") Then
		Return Left(TypeName, Len(TypeName) - 4)
	ElseIf EndsWith(LCase(TypeName), " pointer") Then
		Return Left(TypeName, Len(TypeName) - 8)
	Else
		Return TypeName
	End If
End Function

Function GetPropertyType(ClassName As String, PropertyName As String) As TypeElement Ptr
	Dim iIndex As Integer
	Dim Pos2 As Integer
	Dim tbi As TypeElement Ptr
	Dim te As TypeElement Ptr
	Dim TypeN As String = WithoutPtr(ClassName)
	If InStr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InStrRev(TypeN, ".") + 1)
	If pComps->Contains(TypeN) Then
		tbi = pComps->Object(pComps->IndexOf(TypeN))
		If tbi Then
			Pos2 = InStr(PropertyName, ".")
			If Pos2 > 0 Then
				te = GetPropertyType(TypeN, Left(PropertyName, Pos2 - 1))
				If te <> 0 Then Return GetPropertyType(te->TypeName, Mid(PropertyName, Pos2 + 1))
			Else
				iIndex = tbi->Elements.IndexOf(PropertyName)
				If iIndex <> -1 Then
					Return Cast(TypeElement Ptr, tbi->Elements.Object(iIndex))
				ElseIf tbi->TypeName <> "" Then
					Return GetPropertyType(tbi->TypeName, PropertyName)
				Else
					Return 0
				End If
			End If
		End If
	End If
	Return 0
End Function

Function IsBase(ByRef TypeName As String, ByRef BaseName As String) As Boolean
	Dim iIndex As Integer
	Dim tbi As TypeElement Ptr
	Dim TypeN As String = WithoutPtr(TypeName)
	If InStr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InStrRev(TypeN, ".") + 1)
	If pComps->Contains(TypeN) Then
		tbi = pComps->Object(pComps->IndexOf(TypeN))
		If tbi Then
			If tbi->TypeName = BaseName Then
				Return True
			ElseIf tbi->TypeName <> "" Then
				Return IsBase(tbi->TypeName, BaseName)
			Else
				Return False
			End If
		End If
	End If
	Return False
End Function

Function TabWindow.ReadObjProperty(ByRef Obj As Any Ptr, ByRef PropertyName As String) ByRef As WString
	On Error Goto ErrorHandler
	WLet(FLine, "")
	If Des = 0 OrElse Des->ReadPropertyFunc = 0 Then Return ""
	Dim Cpnt As Any Ptr = Obj
	If Cpnt = 0 Then Return *FLine
	te = GetPropertyType(WGet(Des->ReadPropertyFunc(Cpnt, "ClassName")), PropertyName)
	If te = 0 Then Return *FLine
	With *te
		Select Case te->ElementType
		Case "Event"
			Dim As Dictionary Ptr Dict = Des->ReadPropertyFunc(Cpnt, "Tag")
			If Dict <> 0 Then
				If Dict->ContainsKey(PropertyName) Then
					WLet(FLine, Dict->Item(PropertyName)->Text)
				End If
			End If
		Case "Property"
			Var Pos1 = InStr(PropertyName, ".")
			If Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 Then
				pTemp = Des->ReadPropertyFunc(Cpnt, PropertyName)
			Else
				pTemp = 0
			End If
			If pTemp <> 0 Then
				Select Case LCase(.TypeName)
				Case "wstring", "wstring ptr": WLet(FLine, QWString(pTemp))
				Case "string", "zstring": WLet(FLine, QZString(pTemp))
				Case "control ptr", "control": WLet(FLine, QWString(Des->ReadPropertyFunc(pTemp, "Name")))
				Case "integer": iTemp = QInteger(pTemp)
					WLet(FLine, WStr(iTemp))
					If (te->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(te->EnumTypeName)) Then
						tbi = pGlobalEnums->Object(pGlobalEnums->IndexOf(te->EnumTypeName))
						If tbi AndAlso iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, WStr(iTemp) & " - " & tbi->Elements.Item(iTemp))
					End If
				Case "long": iTemp = QLong(pTemp): WLet(FLine, WStr(iTemp))
				Case "ulong": iTemp = QULong(pTemp): WLet(FLine, WStr(iTemp))
				Case "single": iTemp = QSingle(pTemp): WLet(FLine, WStr(iTemp))
				Case "double": iTemp = QDouble(pTemp): WLet(FLine, WStr(iTemp))
				Case "boolean": WLet(FLine, WStr(QBoolean(pTemp)))
				Case "any ptr", "any": WLet(FLine, WStr(""))
				Case Else: 
					If CInt(IsBase(.TypeName, "My.Sys.Object")) AndAlso CInt(Des->ToStringFunc <> 0) Then 
						WLet(FLine, Des->ToStringFunc(pTemp))
					ElseIf pGlobalEnums->Contains(.TypeName) Then
						iTemp = QInteger(pTemp)
						tbi = pGlobalEnums->Object(pGlobalEnums->IndexOf(.TypeName))
						If tbi AndAlso iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, WStr(iTemp) & " - " & tbi->Elements.Item(iTemp))
					End If
				End Select
			ElseIf Pos1 > 0 Then
				te = GetPropertyType(WGet(Des->ReadPropertyFunc(Cpnt, "ClassName")), Left(PropertyName, Pos1 - 1))
				If te = 0 Then Return *FLine
				If IsBase(te->TypeName, "My.Sys.Object") Then
					If Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 Then
						Return ReadObjProperty(Des->ReadPropertyFunc(Cpnt, Left(PropertyName, Pos1 - 1)), Mid(PropertyName, Pos1 + 1))
					End If
				End If
			End If
		End Select
	End With
	Return *FLine
	'End If
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Function TabWindow.GetFormattedPropertyValue(ByRef Cpnt As Any Ptr, ByRef PropertyName As String) ByRef As WString
	On Error Goto ErrorHandler
	WLet(FLine, "")
	If Cpnt = 0 Then Return *FLine
	If Des = 0 OrElse Des->ReadPropertyFunc = 0 Then Return *FLine
	Pos1 = InStr(PropertyName, ".")
	pTemp = Des->ReadPropertyFunc(Cpnt, PropertyName)
	If pTemp <> 0 Then
		te = GetPropertyType(WGet(Des->ReadPropertyFunc(Cpnt, "ClassName")), PropertyName)
		If te = 0 Then Return *FLine
		With *te
			Select Case LCase(.TypeName)
			Case "wstring", "string", "zstring": WLet(FLine, QWString(pTemp)): If InStr(*FLine, """") = 0 Then WLetEx FLine, """" & *FLine & """", True
			Case "icon", "bitmaptype", "cursor": If Des->ToStringFunc <> 0 Then WLet(FLine, """" & Des->ToStringFunc(pTemp) & """")
			Case "integer": iTemp = QInteger(pTemp)
				WLet(FLine, WStr(iTemp))
				If (te->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(te->EnumTypeName)) Then
					tbi = pGlobalEnums->Object(pGlobalEnums->IndexOf(te->EnumTypeName))
					If tbi AndAlso iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, te->EnumTypeName & "." & tbi->Elements.Item(iTemp))
				End If
			Case "long": iTemp = QLong(pTemp): WLet(FLine, WStr(iTemp))
			Case "ulong": iTemp = QULong(pTemp): WLet(FLine, WStr(iTemp))
			Case "single": iTemp = QSingle(pTemp): WLet(FLine, WStr(iTemp))
			Case "double": iTemp = QDouble(pTemp): WLet(FLine, WStr(iTemp))
			Case "boolean": WLet(FLine, WStr(QBoolean(pTemp)))
			Case "any ptr", "any": WLet(FLine, WStr(""))
			Case Else
				If pGlobalEnums->Contains(.TypeName) Then
					tbi = pGlobalEnums->Object(pGlobalEnums->IndexOf(te->TypeName))
					iTemp = QInteger(pTemp)
					If tbi AndAlso iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet(FLine, te->TypeName & "." & tbi->Elements.Item(iTemp))
				ElseIf CInt(IsBase(.TypeName, "Component")) Then
					Dim As String pTempName = WGet(Des->ReadPropertyFunc(pTemp, "Name"))
					If pTempName <> "" Then
						If cboClass.Items.Contains(pTempName) Then
							WLet(FLine, "@" & pTempName)
							If cboClass.Items.IndexOf(pTempName) = 1 Then
								WLet(FLine, "@This")
							End If
						End If
					End If
				End If
			End Select
		End With
	ElseIf Pos1 > 0 Then
		te = GetPropertyType(WGet(Des->ReadPropertyFunc(Cpnt, "ClassName")), Left(PropertyName, Pos1 - 1))
		If te = 0 Then Return *FLine
		If IsBase(te->TypeName, "My.Sys.Object") Then
			If Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 Then
				Return GetFormattedPropertyValue(Des->ReadPropertyFunc(Cpnt, Left(PropertyName, Pos1 - 1)), Mid(PropertyName, Pos1 + 1))
			End If
		End If
	End If
	Return *FLine
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Function TabWindow.WriteObjProperty(ByRef Cpnt As Any Ptr, ByRef PropertyName As String, ByRef Value As WString) As Boolean
	If Cpnt = 0 Then Return False
	If Des = 0 OrElse Des->ReadPropertyFunc = 0 Then Return False
	Dim Result As Boolean
	Pos1 = InStr(PropertyName, ".")
	te = GetPropertyType(WGet(Des->ReadPropertyFunc(Cpnt, "ClassName")), PropertyName)
	If te <> 0 Then
		'?"VFE1:" & Value
		WLet(FLine3, Value)
		#ifndef __USE_GTK__
			Dim hwnd1 As HWND
			Dim hTemp As Any Ptr
			If Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 Then hTemp = Des->ReadPropertyFunc(Cpnt, "Handle")
			If hTemp Then hwnd1 = *Cast(HWND Ptr, hTemp)
		#endif
		Select Case te->ElementType
		Case "Event"
			If Des->ReadPropertyFunc(Cpnt, "Tag") = 0 Then Des->WritePropertyFunc(Cpnt, "Tag", New_( Dictionary))
			Dim As Dictionary Ptr Dict = Des->ReadPropertyFunc(Cpnt, "Tag")
			If Dict->ContainsKey(PropertyName) Then
				Dict->Item(PropertyName)->Text = Value
			Else
				Dict->Add PropertyName, Value
			End If
		Case "Property"
			Select Case LCase(te->TypeName)
			Case "wstring", "string", "zstring", "icon", "cursor", "bitmaptype"
				'?"VFE2:" & *FLine
				If StartsWith(*FLine3, """") Then WLet(FLine4, Mid(*FLine3, 2)): WLet(FLine3, *FLine4)
				If EndsWith(*FLine3, """") Then WLet(FLine4, Left(*FLine3, Len(*FLine3) - 1)): WLet(FLine3, *FLine4)
				WLetEx FLine4, Replace(*FLine3, """""", """"), True
				'?"VFE3:" & *FLine
				If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
					Result = Des->WritePropertyFunc(Cpnt, PropertyName, Cast(Any Ptr, FLine4))
				End If
				'            Case "control ptr", "control pointer"
				'                If LCase(*FLine2) = "this" Then
				'                    Result = Cpnt->WriteProperty(PropertyName, frmForm)
				'                ElseIf cboClass.Items.Contains(*FLine2) Then
				'                    PropertyCtrl = Cast(Any Ptr, cboClass.Items.Item(cboClass.Items.IndexOf(*FLine2))->Object)
				'                    Result = Cpnt->WriteProperty(PropertyName, PropertyCtrl)
				'                End If
			Case "integer", "long", "ulong", "single", "double"
				iTemp = Val(*FLine3)
				If (te->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(te->EnumTypeName)) Then
					tbi = pGlobalEnums->Object(pGlobalEnums->IndexOf(te->EnumTypeName))
					If tbi Then
						If tbi->Elements.Contains(*FLine3) Then
							iTemp = tbi->Elements.IndexOf(*FLine3)
						ElseIf StartsWith(*FLine3, te->EnumTypeName & ".") AndAlso tbi->Elements.Contains(Mid(*FLine3, Len(Trim(te->EnumTypeName)) + 2)) Then
							iTemp = tbi->Elements.IndexOf(Mid(*FLine3, Len(Trim(te->EnumTypeName)) + 2))
						End If
					End If
				End If
				If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
					Result = Des->WritePropertyFunc(Cpnt, PropertyName, Cast(Any Ptr, @iTemp))
				End If
			Case "boolean"
				bTemp = Cast(Boolean, Trim(*FLine3))
				If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
					Result = Des->WritePropertyFunc(Cpnt, PropertyName, Cast(Any Ptr, @bTemp))
				End If
			Case Else:
				If pGlobalEnums->Contains(te->TypeName) Then
					tbi = pGlobalEnums->Object(pGlobalEnums->IndexOf(te->TypeName))
					If tbi Then
						iTemp = Val(*FLine3)
						If tbi->Elements.Contains(*FLine3) Then
							iTemp = tbi->Elements.IndexOf(*FLine3)
						ElseIf StartsWith(*FLine3, te->TypeName & ".") AndAlso tbi->Elements.Contains(Mid(*FLine3, Len(Trim(te->TypeName)) + 2)) Then
							iTemp = tbi->Elements.IndexOf(Mid(*FLine3, Len(Trim(te->TypeName)) + 2))
						End If
						If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 AndAlso iTemp > -1 Then
							Result = Des->WritePropertyFunc(Cpnt, PropertyName, Cast(Any Ptr, @iTemp))
						End If
					End If
				Else
					If Des AndAlso LCase(*FLine3) = "this" Then
						Dim hTemp As Any Ptr
						If Des->ReadPropertyFunc <> 0 Then hTemp = Des->ReadPropertyFunc(Des->DesignControl, "Name")
						If hTemp <> 0 Then WLet(FLine3, QWString(hTemp))
					End If
					If *FLine3 <> "" AndAlso CInt(cboClass.Items.Contains(Trim(*FLine3))) Then
						PropertyCtrl = Cast(Any Ptr, cboClass.Items.Item(cboClass.Items.IndexOf(Trim(*FLine3)))->Object)
						If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
							Result = Des->WritePropertyFunc(Cpnt, PropertyName, PropertyCtrl)
						End If
					End If
				End If
			End Select
		End Select
		#ifndef __USE_GTK__
			Dim hwnd2 As HWND
			If hTemp Then hwnd2 = *Cast(HWND Ptr, hTemp)
			If hwnd1 <> hwnd2 Then
				If Des AndAlso hwnd1 = Des->Dialog Then
					Des->Dialog = hwnd2
				End If
			End If
		#endif
	End If
	If CInt(Pos1 > 0) AndAlso CInt(Result = False) Then
		te = GetPropertyType(WGet(Des->ReadPropertyFunc(Cpnt, "ClassName")), Left(PropertyName, Pos1 - 1))
		If te = 0 Then Return False
		If IsBase(te->TypeName, "My.Sys.Object") Then
			If Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 Then
				Return WriteObjProperty(Des->ReadPropertyFunc(Cpnt, Left(PropertyName, Pos1 - 1)), Mid(PropertyName, Pos1 + 1), Value)
			End If
		Else
			Return False
		End If
	End If
	Return Result
End Function

Sub TabWindow.FillAllProperties()
	If Des = 0 OrElse Des->SelectedControl = 0 Then Exit Sub
	ptabRight->Tag = @This
	ptabRight->UpdateLock
	cboFunction.Items.Clear
	cboFunction.Items.Add "(" & ML("Events") & ")", , "Event", "Event"
	cboFunction.ItemIndex = 0
	plvProperties->ListItems.Clear
	plvEvents->ListItems.Clear
	FPropertyItems.Clear
	If Des->ReadPropertyFunc <> 0 Then
		FillProperties WGet(Des->ReadPropertyFunc(Des->SelectedControl, "ClassName"))
	End If
	FPropertyItems.Sort
	For lvPropertyCount As Integer = 0 To FPropertyItems.Count - 1
		'If Instr(FPropertyItems.Item(lvPropertyCount), ".") Then Continue For
		te = FPropertyItems.Object(lvPropertyCount)
		If te = 0 Then Continue For
		With *te
			If CInt(LCase(.Name) <> "handle") AndAlso CInt(LCase(.TypeName) <> "hwnd") AndAlso CInt(LCase(.TypeName) <> "gtkwidget") AndAlso CInt(.ElementType = "Property") Then
				If plvProperties->ListItems.Count <= lvPropertyCount Then
					lvItem = plvProperties->ListItems.Add(FPropertyItems.Item(lvPropertyCount), 2, IIf(.TypeIsPointer = False AndAlso pComps->Contains(.TypeName), 1, 0))
					If .TypeIsPointer = False AndAlso pComps->Contains(.TypeName) Then lvItem->Items.Add
				Else
					lvItem = plvProperties->ListItems.Item(lvPropertyCount)
					lvItem->Text(0) = FPropertyItems.Item(lvPropertyCount)
					lvItem->Text(1) = ""
				End If
				lvItem->Text(1) = ReadObjProperty(Des->SelectedControl, FPropertyItems.Item(lvPropertyCount))
			ElseIf .ElementType = "Event" Then
				cboFunction.Items.Add .Name, , "Event", "Event"
				lvItem = plvEvents->ListItems.Add(.Name, 3)
				lvItem->Text(1) = ReadObjProperty(Des->SelectedControl, .Name)
				'If *Ctrl Is Control Then
				'    cboFunction.Items.Add .Name & "NS", , "Sub", "Sub", , 1
				'End If
			End If
		End With
	Next
	'cboFunction.Items.Sort
	'lvProperties.ListItems.Sort
	'lvEvents.ListItems.Sort
	ptabRight->UpdateUnlock
End Sub

Sub DesignerChangeSelection(ByRef Sender As Designer, Ctrl As Any Ptr, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1)
	Static SelectedCtrl As Any Ptr
	If Ctrl = 0 Then Exit Sub
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If SelectedCtrl = Ctrl AndAlso tb->cboClass.ItemIndex <> 0 Then Exit Sub
	'tb->Des->SelectedControl = Ctrl
	SelectedCtrl = Ctrl
	bNotFunctionChange = True
'	#ifndef __USE_GTK__
'		If tb->Des->ControlSetFocusSub <> 0 AndAlso tb->Des->DesignControl <> 0 Then tb->Des->ControlSetFocusSub(tb->Des->DesignControl)
'	#endif
	If tb->Des->ReadPropertyFunc <> 0 Then tb->cboClass.ItemIndex = tb->cboClass.Items.IndexOf(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name")))
	tb->FillAllProperties
	bNotFunctionChange = False
End Sub

Sub GetControls(Des As Designer Ptr, ByRef lst As List, Ctrl As Any Ptr)
	lst.Add Ctrl
	If Des->Controls.Contains(Ctrl) Then
		Dim j As Integer Ptr = Des->ReadPropertyFunc(Ctrl, "ControlCount")
		If j <> 0 Then
			For i As Integer = 0 To *j - 1
				GetControls Des, lst, Des->ControlByIndexFunc(Ctrl, i)
			Next
		End If
	End If
End Sub

Sub CheckBi(ByRef ptxtCode As EditControl Ptr, ByRef txtCodeBi As EditControl, ByRef ptxtCodeBi As EditControl Ptr, tb As TabWindow Ptr)
	If ptxtCode = @txtCodeBi Then
		Var tb1 = AddTab(Left(tb->FileName, Len(tb->FileName) - 4) & ".bi", , , True)
		tb->SelectTab
		ptxtCode = @tb1->txtCode
		ptxtCodeBi = ptxtCode
		ptxtCodeBi->Changing "Unsur qo`shish"
	End If
End Sub

Sub GetBiFile(ByRef ptxtCode As EditControl Ptr, ByRef txtCodeBi As EditControl, ByRef ptxtCodeBi As EditControl Ptr, tb As TabWindow Ptr, IsBas As Boolean, ByRef bFind As Boolean, i As Integer, ByRef iStart As Integer, ByRef iEnd As Integer)
	If CInt(IsBas) AndAlso CInt(Not bFind) AndAlso CInt(StartsWith(Trim(LCase(tb->txtCode.Lines(i)), Any !"\t "), "#include once """ & LCase(GetFileName(Left(tb->FileName, Len(tb->FileName) - 4) & ".bi")) & """")) Then
		Var tbBi = GetTab(Left(tb->FileName, Len(tb->FileName) - 4) & ".bi")
		Dim FileEncoding As FileEncodings, NewLineType As NewLineTypes
		bFind = True
		If tbBi Then
			ptxtCode = @tbBi->txtCode
			ptxtCodeBi = ptxtCode
		Else
			txtCodeBi.LoadFromFile(Left(tb->FileName, Len(tb->FileName) - 4) & ".bi", FileEncoding, NewLineType)
			ptxtCode = @txtCodeBi
		End If
		iStart = 0
		iEnd = ptxtCode->LinesCount - 1
	Else
		ptxtCode = @tb->txtCode
		iStart = i
		iEnd = i
	End If
End Sub

Sub DesignerDeleteControl(ByRef Sender As Designer, Ctrl As Any Ptr)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
	If tb->Des->DesignControl = 0 Then Exit Sub
	If tb->Des->ControlByIndexFunc = 0 Then Exit Sub
	If Ctrl = 0 Then Exit Sub
	' 
	Dim FLine As WString Ptr
	Dim frmName As WString * 100
	Dim CtrlName As WString * 100
	Dim CtrlNameNew As WString * 100
	If tb->Des->ReadPropertyFunc <> 0 Then
		frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
		CtrlName = WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))
	End If
	Dim ECLine As EditControlLine Ptr
	Var b = False
	Var w = False
	Var s = 0
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As EditControl txtCodeBi
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	Dim As Integer iStart, iEnd, i = 0, k
	tb->txtCode.Changing "Unsurni o`chirish"
	Do While i < tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		k = iStart
		Do While k <= iEnd
			wLet(FLine, Trim(LCase(ptxtCode->Lines(k)), Any !"\t "))
			If Not b AndAlso StartsWith(*FLine, "type " & LCase(frmName) & " ") Then
				b = True
			ElseIf b AndAlso StartsWith(*FLine & " ", "end type ") Then
				s = k
				Exit Do, Do
			ElseIf b AndAlso StartsWith(*FLine, "dim as ") Then
				If StartsWith(*FLine, "dim as " & LCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "ClassName"))) & " ") Then
					Var p = InStr(LCase(RTrim(ptxtCode->Lines(k), Any !"\t ")) & ",", " " & LCase(CtrlName) & ",")
					' ,  No Space after ","
					If p = 0 Then p = InStr(LCase(RTrim(ptxtCode->Lines(k), Any !"\t ")) & ",", "," & LCase(CtrlName) & ",")
					If p > 0 Then '
						If InStr(CtrlName,"(")>0 AndAlso InStr(CtrlName,"(0)")<1 Then ' it is Control Array
							Dim As WString Ptr Temp
							CtrlNameNew = StringExtract(CtrlName,"(")
							', Change the ubound only
							CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
							CtrlNameNew = CtrlNameNew & "(" & WStr(Val(StringExtract(CtrlName,"(",")"))-1) & ")"
							ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p) & " " & CtrlNameNew &  Mid(ptxtCode->Lines(k), p + Len(CtrlName) + 1)
							WDeallocate Temp
						Else
							If Trim(Left(LCase(ptxtCode->Lines(k)), p), Any !"\t ") = "dim as " & LCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "ClassName"))) AndAlso Trim(Mid(ptxtCode->Lines(k), p + Len(LCase(CtrlName)) + 1), Any !"\t ") = "" Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->DeleteLine k
								k = k - 1
							ElseIf InStr(*FLine & ",", " " & LCase(CtrlName) & ",") Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								If EndsWith(*FLine, " " & LCase(CtrlName)) Then
									ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p - 2)
								Else
									ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p - 1) & Mid(ptxtCode->Lines(k), p + Len(CtrlName) + 2)
								End If
								' for No Space after ","
							ElseIf InStr(*FLine & ",", "," & LCase(CtrlName) & ",") Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p - 1) & Mid(ptxtCode->Lines(k), p + Len(CtrlName) + 1)
							End If
						End If
					End If
					If CtrlName <> frmName Then tb->cboClass.Items.Remove tb->cboClass.Items.IndexOf(CtrlName)
				End If
			End If
			k = k + 1
		Loop
		i = i + 1
	Loop
	b = False
	w = False
	Do While i < tb->txtCode.LinesCount - 1
		k = iStart
		Do While k <= IIf(ptxtCode = @tb->txtCode, i, ptxtCode->LinesCount - 1)
			wLet(FLine, Trim(LCase(ptxtCode->Lines(k)), Any !"\t "))
			If Not b AndAlso StartsWith(*FLine & " ", "constructor " & LCase(frmName) & " ") Then
				b = True
			ElseIf b AndAlso StartsWith(*FLine & " ", "end constructor ") Then
				Exit Do, Do
			ElseIf b Then
				If StartsWith(*FLine & " ", "' " & LCase(CtrlName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					k = k - 1
				ElseIf StartsWith(*FLine & " ", "with " & LCase(CtrlName) & " ") Then
					w = True
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					k = k - 1
				ElseIf w AndAlso StartsWith(*FLine & " ", "end with ") Then
					w = False
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					k = k - 1
				ElseIf w AndAlso StartsWith(*FLine, ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					k = k - 1
				ElseIf StartsWith(*FLine, LCase(CtrlName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->DeleteLine k
					k = k - 1
				End If
				
			End If
			k = k + 1
		Loop
		i = i + 1
		ptxtCode = @tb->txtCode
		iStart = i
		iEnd = i
	Loop
	WDeallocate FLine
	ptxtCode->Changed "Unsurni o`chirish"
	If ptxtCodeBi <> 0 Then ptxtCodeBi->Changed "Unsurni o`chirish"
End Sub

Function ChangeControl(Cpnt As Any Ptr, ByRef PropertyName As WString = "", iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1) As Integer
	On Error Goto ErrorHandler
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Return 0
	If tb->Des = 0 Then Return 0
	If tb->Des->ReadPropertyFunc = 0 Then Return 0
	If Cpnt = 0 Then Return 0
	If tb->Des->DesignControl = 0 Then Return 0
	'Dim As Integer iLeft, iTop, iWidth, iHeight
	Dim frmName As WString * 100
	Dim CtrlName As WString * 100
	Dim CtrlNameBase As WString * 100
	frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	CtrlName = WGet(tb->Des->ReadPropertyFunc(Cpnt, "Name"))
	If CtrlName = frmName Then CtrlName = "This"
	Dim InsLineCount As Integer
	Dim As WStringList WithArgs
	Dim As WString Ptr FLine, FLine1,FLine2
	Var b = False, t = False
	Var d = False, sl = 0, tp = 0, ep = 0, j = 0
	Dim As Integer iLeft1, iTop1, iWidth1, iHeight1
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As EditControl txtCodeBi
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	Dim As Integer iStart, iEnd, i, k, dj
	WLet(FLine1, "")
	For i = 0 To tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		For k As Integer = iStart To iEnd
			If ptxtCode->Lines(k) = "" Then Continue For
			' for Muilt line for the same control, sometimes No Space after ","
			WLet(FLine2, Trim(LCase(ptxtCode->Lines(k)), Any !"\t "))
			If StartsWith(*FLine2, "type " & LCase(frmName) & " ") Then
				sl = Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))
				WLet(FLine1, Left(ptxtCode->Lines(k), sl))
				tp = k
				b = True
			ElseIf b Then
				If StartsWith(*FLine2 & " ", "end type ") Then
					j = k
					Exit For, For
					' Ctrl Array
				ElseIf StartsWith(*FLine2, "dim as " & LCase(WGet(tb->Des->ReadPropertyFunc(Cpnt, "ClassName"))) & " ") Then
					d = True
					If InStr(CtrlName, "(")  Then
						CtrlNameBase = Trim(StringExtract(CtrlName, "("))
					Else
						CtrlNameBase = Trim(CtrlName)
					End If
					j = k + 1
					dj = j
					If InStr(CtrlName,"(") < 1 AndAlso (InStr(*FLine2 & ",", " " & LCase(CtrlName) & ",") _
						OrElse InStr(*FLine2 & ",", "," & LCase(CtrlName) & ",")) Then
						t = True
						Exit For, For
					ElseIf InStr(CtrlName,"(") > 0 AndAlso (InStr(*FLine2, " " & LCase(CtrlNameBase) & "(") _ 'Ctrl Array
						Or InStr(*FLine2, "," & LCase(CtrlNameBase) & "(")) Then 'Ctrl Array
						Dim As String CtrlArrayOld = StringExtract(ptxtCode->Lines(k), CtrlNameBase & "(" ,")")
						Dim As String CtrlArrayNew = StringExtract(CtrlName, CtrlNameBase & "(" ,")")
						If Val(CtrlArrayNew) > Val(CtrlArrayOld) Then
							ptxtCode->ReplaceLine k, Replace(ptxtCode->Lines(k), CtrlNameBase & "("  & CtrlArrayOld & ")",CtrlNameBase & "(" & CtrlArrayNew & ")")
						End If
						t = True
						Exit For, For
					End If
				End If
			End If
		Next
	Next
	If Not t Then
		If tb->Des->DesignControl <> Cpnt Then
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			If d Then
				ptxtCode->ReplaceLine dj - 1, RTrim(ptxtCode->Lines(dj - 1)) & ", " & CtrlName
			Else
				ptxtCode->InsertLine j, *FLine1 & TabSpace & "Dim As " & WGet(tb->Des->ReadPropertyFunc(Cpnt, "ClassName")) & " " & CtrlName
				InsLineCount += 1
			End If
		End If
	End If
	t = False: b = False
	For l As Integer = tp + 1 To ptxtCode->LinesCount - 1
		If StartsWith(LTrim(LCase(ptxtCode->Lines(l)), Any !"\t ") & " ", "declare constructor ") Then
			t = True
		ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(l)), Any !"\t ") & " ", "end type ") Then
			ep = l
			Exit For
		End If
	Next
	If Not t Then
		CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
		ptxtCode->InsertLine tp + 1, *FLine1 & TabSpace & "Declare Constructor"
		InsLineCount += 1
	End If
	Var sc = 0, se = 0
	Var bWith = False
	j = 0
	t = False
	For i = i To tb->txtCode.LinesCount - 1
		For k = iStart To IIf(ptxtCode = @tb->txtCode, i, ptxtCode->LinesCount - 1)
			If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "constructor " & LCase(frmName) & " ") Then
				sc = k
				b = True
			ElseIf b Then
				If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end constructor ") Then
					se = k
					Exit For, For
				ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "with ") Then
					WithArgs.Add Trim(Mid(Trim(ptxtCode->Lines(k), Any !"\t "), 5), Any !"\t ")
				ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "end with") Then
					If WithArgs.Count > 0 Then WithArgs.Remove WithArgs.Count - 1
				ElseIf CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(CtrlName) & ".")) OrElse CInt(CInt(WithArgs.Count > 0) AndAlso CInt(WithArgs.Item(WithArgs.Count - 1) = CtrlName) AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "."))) Then
					j = k
					bWith = WithArgs.Count > 0 AndAlso WithArgs.Item(WithArgs.Count - 1) = CtrlName
					Var p = InStr(ptxtCode->Lines(k), ".")
					If p Then
						If StartsWith(Trim(LCase(Mid(ptxtCode->Lines(k), p + 1)), Any !"\t "), "setbounds ") Then
							If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
								iLeft1 = iLeft
								iTop1 = iTop
								iHeight1 = iHeight
								iWidth1 = iWidth
							ElseIf tb->Des->ComponentGetBoundsSub <> 0 Then
								tb->Des->ComponentGetBoundsSub(tb->Des->Q_ComponentFunc(Cpnt), @iLeft1, @iTop1, @iWidth1, @iHeight1)
							End If
							CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
							ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p + 10) & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
							'Ctrl2 = Cast(Control Ptr, Cpnt)
							'.ReplaceLine i, Left(.Lines(i), p + Len(LCase(CtrlName)) + 10) & Ctrl2->Left & ", " & Ctrl2->Top & ", " & Ctrl2->Width & ", " & Ctrl2->Height
							If LCase(PropertyName) = "left" OrElse LCase(PropertyName) = "top" OrElse LCase(PropertyName) = "width" OrElse LCase(PropertyName) = "height" Then t = True
						ElseIf StartsWith(Trim(LCase(Mid(ptxtCode->Lines(k), p + 1)), Any !"\t "), "left ") Then
							Var p1 = InStr(LCase(ptxtCode->Lines(k)), "=")
							If p1 Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p1) & " " & tb->GetFormattedPropertyValue(Cpnt, "Left")
								If LCase(PropertyName) = "left" Then t = True
							End If
						ElseIf StartsWith(Trim(LCase(Mid(ptxtCode->Lines(k), p + 1)), Any !"\t "), "top ") Then
							Var p1 = InStr(LCase(ptxtCode->Lines(k)), "=")
							If p1 Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p1) & " " & tb->GetFormattedPropertyValue(Cpnt, "Top")
								If LCase(PropertyName) = "top" Then t = True
							End If
						ElseIf CInt(PropertyName <> "") AndAlso CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p + 1), LCase(PropertyName) & " ") OrElse StartsWith(Mid(LCase(ptxtCode->Lines(k)), p + 1), LCase(PropertyName) & "=")) Then
							Var p1 = InStr(LCase(ptxtCode->Lines(k)), "=")
							If p1 Then
								CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
								ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), p1) & " " & tb->GetFormattedPropertyValue(Cpnt, PropertyName)
								t = True
							End If
						End If
					End If
				End If
			End If
		Next
		ptxtCode = @tb->txtCode
		iStart = i + 1
		iEnd = i + 1
	Next
	Dim q As Integer = 0
	If sc = 0 Then
		CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
		ptxtCode->InsertLine ep + 2, *FLine1
		ptxtCode->InsertLine ep + 3, *FLine1 & "Constructor " & frmName
		ptxtCode->InsertLine ep + 4, *FLine1 & TabSpace & "' " & frmName
		ptxtCode->InsertLine ep + 5, *FLine1 & TabSpace & "With This"
		ptxtCode->InsertLine ep + 6, *FLine1 & TabSpace & TabSpace & ".Name = """ & frmName & """"
		If tb->Des->ReadPropertyFunc <> 0 Then
			ptxtCode->InsertLine ep + 7, *FLine1 & TabSpace & TabSpace & ".Text = """ & WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Text")) & """"
		End If
		If PropertyName <> "" AndAlso PropertyName <> "Text" Then
			WLet(FLine, tb->GetFormattedPropertyValue(tb->Des->DesignControl, PropertyName))
			If *FLine <> "" Then ptxtCode->InsertLine ep + 8, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & *FLine: q = 1
		End If
		If tb->Des->ComponentGetBoundsSub <> 0 Then tb->Des->ComponentGetBoundsSub(tb->Des->Q_ComponentFunc(tb->Des->DesignControl), @iLeft1, @iTop1, @iWidth1, @iHeight1)
		ptxtCode->InsertLine ep + q + 8, *FLine1 & TabSpace & TabSpace & ".SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
		ptxtCode->InsertLine ep + q + 9, *FLine1 & TabSpace & "End With"
		ptxtCode->InsertLine ep + q + 10, *FLine1 & "End Constructor"
		InsLineCount += q + 9
		If Cpnt = tb->Des->DesignControl Then j = ep + q + 10: t = True
		se = ep + q + 10
	ElseIf se = 0 Then
		'Var l = .CharIndexFromLine(sc + 1)
		'.ChangeText Left(.Text, l) & Space(sl) & "End Constructor" & Chr(13) & Mid(.Text, l + 1), "Tugatuvchi konstruktor qo`shildi", .SelStart, , False
		se = sc + 1
	End If
	If j = 0 Then
		CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
		Dim ParentName As String
		If Cpnt <> 0 Then
			If tb->Des->ReadPropertyFunc(Cpnt, "Parent") Then
				If tb->Des->ReadPropertyFunc(Cpnt, "Parent") = tb->Des->DesignControl Then ParentName = "This" Else ParentName = WGet(tb->Des->ReadPropertyFunc(tb->Des->ReadPropertyFunc(Cpnt, "Parent"), "Name"))
			End If
		End If
		If tb->Des->IsControlFunc <> 0 AndAlso CInt(tb->Des->IsControlFunc(Cpnt)) Then
			ptxtCode->InsertLine se, *FLine1 & TabSpace & "' " & CtrlName
			ptxtCode->InsertLine se + 1, *FLine1 & TabSpace & "With " & CtrlName
			ptxtCode->InsertLine se + 2, *FLine1 & TabSpace & TabSpace & ".Name = """ & CtrlName & """"
			InsLineCount += 3
			q = 0
			If WGet(tb->Des->ReadPropertyFunc(Cpnt, "Text")) <> "" Then
'				WLet FLine, CtrlName
'				If tb->Des->WritePropertyFunc <> 0 Then tb->Des->WritePropertyFunc(Cpnt, "Text", FLine)
				ptxtCode->InsertLine se + 3, *FLine1 & TabSpace & TabSpace & ".Text = """ & WGet(tb->Des->ReadPropertyFunc(Cpnt, "Text")) & """"
				InsLineCount += 1
				q = 1
			End If
			If tb->Des->ReadPropertyFunc(Cpnt, "TabIndex") <> 0 Then
				ptxtCode->InsertLine se + q + 3, *FLine1 & TabSpace & TabSpace & ".TabIndex = " & QInteger(tb->Des->ReadPropertyFunc(Cpnt, "TabIndex"))
				InsLineCount += 1
				q += 1
			End If
			If PropertyName <> "" AndAlso PropertyName <> "Text" AndAlso PropertyName <> "TabIndex" Then
				WLet(FLine, tb->GetFormattedPropertyValue(Cpnt, PropertyName))
				'  Confuse the formatcode function
				If *FLine <> "" Then
					ptxtCode->InsertLine se + q + 3, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & *FLine: q += 1
				End If
			End If
			If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
				iLeft1 = iLeft
				iTop1 = iTop
				iWidth1 = iWidth
				iHeight1 = iHeight
			ElseIf tb->Des->ComponentGetBoundsSub <> 0 Then
				tb->Des->ComponentGetBoundsSub(tb->Des->Q_ComponentFunc(Cpnt), @iLeft1, @iTop1, @iWidth1, @iHeight1)
			End If
			ptxtCode->InsertLine se + q + 3, *FLine1 & TabSpace & TabSpace & ".SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
			InsLineCount += 1
			If Cpnt <> tb->Des->DesignControl Then ptxtCode->InsertLine se + q + 4, *FLine1 & TabSpace & TabSpace & ".Parent = @" & ParentName: InsLineCount += 1: q += 1
			ptxtCode->InsertLine se + q + 4, *FLine1 & TabSpace & "End With": InsLineCount += 1
		Else
			q = 0
			If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
				iLeft1 = iLeft
				iTop1 = iTop
				iWidth1 = iWidth
				iHeight1 = iHeight
			ElseIf tb->Des->ComponentGetBoundsSub <> 0 Then
				tb->Des->ComponentGetBoundsSub(tb->Des->Q_ComponentFunc(Cpnt), @iLeft1, @iTop1, @iWidth1, @iHeight1)
			End If
			ptxtCode->InsertLine se, *FLine1 & TabSpace & "' " & CtrlName
			ptxtCode->InsertLine se + 1, *FLine1 & TabSpace & "With " & CtrlName
			ptxtCode->InsertLine se + 2, *FLine1 & TabSpace & TabSpace & ".Name = """ & CtrlName & """"
			ptxtCode->InsertLine se + 3, *FLine1 & TabSpace & TabSpace & ".SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
			ptxtCode->InsertLine se + 4, *FLine1 & TabSpace & TabSpace & ".Parent = @" & ParentName
			'  Confuse the formatcode function
			If PropertyName <> "" AndAlso PropertyName <> "Name" Then
				ptxtCode->InsertLine se + 5, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & tb->GetFormattedPropertyValue(Cpnt, PropertyName): q += 1
			End If
			ptxtCode->InsertLine se + q + 5, *FLine1 & TabSpace & "End With"
			InsLineCount += q + 5
		End If
	ElseIf Not t Then
		If PropertyName <> "" Then
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			WLet(FLine, tb->GetFormattedPropertyValue(Cpnt, PropertyName))
			If *FLine <> "" Then
				If bWith Then
					ptxtCode->InsertLine j, *FLine1 & TabSpace & TabSpace & "." & PropertyName & " = " & *FLine: q += 1
				Else
					ptxtCode->InsertLine j, *FLine1 & TabSpace & CtrlName & "." & PropertyName & " = " & *FLine: q += 1
				End If
			End If
		End If
		InsLineCount += q
	End If
	ptxtCode->Changed ""
	If ptxtCodeBi <> 0 Then ptxtCodeBi->Changed ""
	WDeallocate FLine
	WDeallocate FLine1
	WDeallocate FLine2 '
	Return InsLineCount
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Sub TabWindow.ChangeName(ByRef OldName As WString, ByRef NewName As WString)
	Dim iIndex As Integer = cboClass.Items.IndexOf(OldName)
	If Des = 0 Then Exit Sub
	If Des->DesignControl = 0 Then Exit Sub
	Dim frmName As String
	If Des->ReadPropertyFunc <> 0 Then
		frmName = WGet(Des->ReadPropertyFunc(Des->DesignControl, "Name"))
	End If
	If iIndex = 1 AndAlso Des->WritePropertyFunc <> 0 Then Des->WritePropertyFunc(Des->DesignControl, "Name", @NewName)
	Dim As Boolean b, c
	If iIndex > 0 Then cboClass.Items.Item(iIndex)->Text = NewName
	Dim As TabWindow Ptr tb = @This
	Dim As EditControl txtCodeBi
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As Integer iStart, iEnd
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	For i As Integer = 0 To tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		For k As Integer = iStart To iEnd
			If StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "type " & LCase(frmName) & " ") Then
				c = True
				If iIndex = 1 Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 5) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(frmName) + 6)
				End If
			ElseIf c Then
				If StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "end type ") Then
					c = False
				ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "dim as ") Then
					Var Pos1 = InStr(LCase(RTrim(ptxtCode->Lines(k))) & ",", " " & LCase(OldName) & ",")
					' for Ctrl Array
					If Pos1=0 Then Pos1 = InStr(LCase(RTrim(ptxtCode->Lines(k))) & ",", "," & LCase(OldName) & ",")
					If Pos1 > 0 Then
						CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
						ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Pos1) & NewName & Mid(ptxtCode->Lines(k), Len(OldName) + Pos1 + 1)
					End If
				End If
			ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "constructor " & LCase(frmName) & " ") Then
				If iIndex = 1 Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 12) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(frmName) + 13)
				End If
				b = True
			ElseIf b Then
				If StartsWith(LTrim(LCase(ptxtCode->Lines(k)) & " ", Any !"\t "), "end constructor ") Then
					b = False
				ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "with " & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 5) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 6)
				ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")) & " ", "' " & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 2) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 3)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), LCase(OldName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 1)
				ElseIf EndsWith(RTrim(LCase(ptxtCode->Lines(k)), " "), "@" & LCase(OldName)) Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName)) & NewName
				End If
			ElseIf iIndex = 1 Then
				If StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "private sub " & LCase(OldName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 12) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 13)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "public sub " & LCase(OldName) & ".") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 11) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 12)
				ElseIf StartsWith(LTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), "*cast(" & LCase(OldName) & " ") Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))) & Left(LTrim(ptxtCode->Lines(k), Any !"\t "), 6) & NewName & Mid(LTrim(ptxtCode->Lines(k), Any !"\t "), Len(OldName) + 7)
				End If
			End If
			If iIndex = 1 Then
				If EndsWith(RTrim(LCase(ptxtCode->Lines(k)), Any !"\t "), " as " & LCase(OldName)) Then
					CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
					ptxtCode->ReplaceLine k, Left(ptxtCode->Lines(k), Len(ptxtCode->Lines(k)) - Len(OldName)) & NewName
				End If
			End If
		Next
	Next
End Sub

Function GetItemText(ByRef Item As TreeListViewItem Ptr) As String
	Dim As String PropertyName = Item->Text(0)
	If Item->ParentItem = 0 Then
		Return PropertyName
	Else
		Return GetItemText(Item->ParentItem) & "." & PropertyName
	End If
End Function

Sub PropertyChanged(ByRef Sender As Control, ByRef Sender_Text As WString, IsCombo As Boolean)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->SelectedControl = 0 Then Exit Sub
	If plvProperties->SelectedItem = 0 Then Exit Sub
	Dim As String PropertyName = GetItemText(plvProperties->SelectedItem)
	'Var te = GetPropertyType(tb->SelectedControl->ClassName, PropertyName)
	'If te = 0 Then Exit Sub
	Dim FLine As WString Ptr
	Dim SenderText As UString
	SenderText = IIf(IsCombo, Mid(Sender_Text, 2), Sender_Text)
	With tb->txtCode
		If SenderText <> tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName) Then
			If CInt(PropertyName = "Name") AndAlso CInt(tb->cboClass.Items.Contains(SenderText)) Then
				MsgBox ML("This name is exists!"), "VisualFBEditor", mtWarning
				#ifndef __USE_GTK__
					Sender.Text = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
				#endif
				Exit Sub
			End If
			pfrmMain->UpdateLock
			.Changing "Unsurni o`zgartirish"
			If PropertyName = "Name" Then tb->ChangeName tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName), SenderText
			tb->WriteObjProperty(tb->Des->SelectedControl, PropertyName, Sender_Text)
			#ifndef __USE_GTK__
				'Sender.Text = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
				plvProperties->SelectedItem->Text(1) = SenderText
			#endif
			If PropertyName = "TabIndex" Then
				For i As Integer = 2 To tb->cboClass.ItemCount - 1
					ChangeControl(tb->cboClass.Items.Item(i)->Object, "TabIndex")
				Next
			Else
				ChangeControl(tb->Des->SelectedControl, PropertyName)
			End If
			'If tb->frmForm Then tb->frmForm->MoveDots Cast(Control Ptr, tb->SelectedControl)->Handle, False
			For i As Integer = 0 To plvProperties->ListItems.Count - 1
				PropertyName = GetItemText(plvProperties->ListItems.Item(i))
				Dim TempWS As UString
				TempWS = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
				If TempWS <> plvProperties->ListItems.Item(i)->Text(1) Then
					plvProperties->ListItems.Item(i)->Text(1) = TempWS
					ChangeControl(tb->Des->SelectedControl, PropertyName)
				End If
			Next i
			.Changed "Unsurni o`zgartirish"
			pfrmMain->UpdateUnLock
		End If
	End With
End Sub

Sub DesignerModified(ByRef Sender As Designer, Ctrl As Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		pfrmMain->UpdateLock
		Dim PropertyName As String
		Dim TempWS As UString
		For i As Integer = 0 To plvProperties->ListItems.Count - 1
			PropertyName = GetItemText(plvProperties->ListItems.Item(i))
			If PropertyName = "Left" OrElse PropertyName = "Top" OrElse PropertyName = "Width" OrElse PropertyName = "Height" Then
				TempWS = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
				If TempWS <> plvProperties->ListItems.Item(i)->Text(1) Then
					plvProperties->ListItems.Item(i)->Text(1) = TempWS
					If CInt(plvProperties->ListItems.Item(i) = plvProperties->SelectedItem) AndAlso CInt(ptxtPropertyValue->Visible) Then
						ptxtPropertyValue->Text = plvProperties->ListItems.Item(i)->Text(1)
					End If
				End If
			End If
		Next i
		.Changing "Unsurni o`zgartirish"
		ChangeControl(Ctrl, , iLeft, iTop, iWidth, iHeight)
		.Changed "Unsurni o`zgartirish"
		tb->FormDesign True
		pfrmMain->UpdateUnLock
	End With
End Sub

Sub DesignerInsertControl(ByRef Sender As Designer, ByRef ClassName As String, Ctrl As Any Ptr, iLeft2 As Integer, iTop2 As Integer, iWidth2 As Integer, iHeight2 As Integer)
	On Error Goto ErrorHandler
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
	If tb->Des->DesignControl = 0 Then Exit Sub
	If Ctrl = 0 Then Exit Sub
	Dim NewName As String = WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))
	tb->cboClass.Items.Add NewName, Ctrl, ClassName, ClassName, , 1
	Dim As EditControl txtCodeBi
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi
	Dim As Integer iStart, iEnd, j
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	If SelectedTool <> 0 Then
		SelectedTool->Checked = False
		Var tbi = Cast(TypeElement Ptr, SelectedTool->Tag)
		Dim As String frmName
		If tb->Des->ReadPropertyFunc <> 0 Then
			frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
		End If
		Var t = False, b = False
		Var k = 0
		tb->txtCode.Changing "Unsur qo`shish"
		For i As Integer = 0 To tb->txtCode.LinesCount - 1
			GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
			For k As Integer = iStart To iEnd
				If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "#include ") Then
					b = True
					If InStr(LCase(ptxtCode->Lines(k)), """" & LCase(tbi->IncludeFile & """")) Then
						t = True
						Exit For, For
					End If
				ElseIf b Then
					j = k
					Exit For, For
				End If
			Next
		Next
		Var InsLineCount = 0
		If Not t Then
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			ptxtCode->InsertLine j, Left(ptxtCode->Lines(j - 1), Len(ptxtCode->Lines(j - 1)) - Len(LTrim(ptxtCode->Lines(j - 1), Any !"\t "))) & "#include once """ & tbi->IncludeFile & """"
			InsLineCount += 1
		End If
	End If
	ChangeControl(Ctrl, , iLeft2, iTop2, iWidth2, iHeight2)
	If tb->Des->ControlSetFocusSub <> 0 Then tb->Des->ControlSetFocusSub(tb->Des->DesignControl)
	tb->txtCode.Changed "Unsur qo`shish"
	If ptxtCodeBi <> 0 Then ptxtCodeBi->Changed "Unsur qo`shish"
	tb->FormDesign True
	ToolGroupsToCursor
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

Sub DesignerInsertComponent(ByRef Sender As Designer, ByRef ClassName As String, Cpnt As Any Ptr, iLeft2 As Integer, iTop2 As Integer)
	DesignerInsertControl(Sender, ClassName, Cpnt, iLeft2, iTop2, 16, 16)
End Sub

Sub DesignerInsertingControl(ByRef Sender As Designer, ByRef ClassName As String, ByRef AName As String)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim PrevName As String = AName
	Dim NewName As String
	If CInt(PrevName <> ClassName) AndAlso CInt(PrevName <> "") AndAlso CInt(Not tb->cboClass.Items.Contains(PrevName)) Then
		NewName = PrevName
	Else
		'  for Control Array
		Dim As Integer CtrlArrayNum = -1
		If InStr(PrevName,"(") < 1 Then
			Var n = 0
			Do
				n = n + 1
				NewName = AName & Str(n)
			Loop While (tb->cboClass.Items.Contains(NewName) OrElse tb->cboClass.Items.Contains(NewName & "(0)")) ' Ctrl Array
		Else
			Var n = 0
			AName = StringExtract(PrevName, "(")
			Do
				n = n + 1
				NewName = AName & "(" & Str(n) & ")"
			Loop While tb->cboClass.Items.Contains(NewName)
		End If
	End If
	AName = NewName
End Sub

Sub cboClass_Change(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Var ii = Sender.ItemIndex
	If ii = -1 Then Exit Sub
	If ii = 0 Then
		With tb->cboFunction
			.Items.Clear
			.Items.Add WStr("(") & ML("Declarations") & ")" & WChr(0), , "Sub", "Sub"
			.ItemIndex = 0
			Dim As String imgKey = "Sub"
			For i As Integer = 0 To tb->Functions.Count - 1
				Var te = Cast(TypeElement Ptr, tb->Functions.Object(i))
				If te->ElementType = "Property" Then imgKey = "Property" Else imgKey = "Sub"
				.Items.Add te->DisplayName, te, imgKey, imgKey
			Next
		End With
	Else
		Dim Ctrl As Any Ptr = Cast(ComboBoxEx Ptr, @Sender)->Items.Item(Sender.ItemIndex)->Object
		If Ctrl = 0 Then Exit Sub
		'If Not Sender.Focused Then Exit Sub
		If tb->Des = 0 Then Exit Sub
		If tb->Des->ReadPropertyFunc <> 0 Then
			#ifdef __USE_GTK__
				'tb->Des->SelectedControl = Ctrl
				'tb->Des->MoveDots(tb->Des->ReadPropertyFunc(Ctrl, "Widget"))
			#else
				tb->Des->SelectedControls.Clear
				tb->Des->SelectedControl = Ctrl
				Dim As HWND Ptr hw = tb->Des->ReadPropertyFunc(Ctrl, "Handle")
				If hw <> 0 Then tb->Des->MoveDots(Ctrl, False) Else tb->Des->MoveDots(0, False): DesignerChangeSelection *tb->Des, Ctrl
			#endif
		End If
	End If
End Sub

Sub OnLinkClickedEdit(ByRef Sender As Control, ByRef Link1 As WString)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	AddTab GetRelativePath(Link1, tb->FileName)
End Sub

Sub OnToolTipLinkClickedEdit(ByRef Sender As Control, ByRef Link1 As WString)
	Dim As UString res(Any)
	Split(Link1, "#", res())
	If UBound(res) <= 2 Then SelectSearchResult res(0), Val(res(1)) + 1, , , , res(2)
End Sub

Function GetCorrectParam(ByVal Param As String) As String
	Param = Trim(Param)
	If EndsWith(Param, """""") Then Param = Trim(Left(Param, Len(Param) - 2))
	If EndsWith(Param, "=") Then Param = Trim(Left(Param, Len(Param) - 1))
	Return Param
End Function

Sub OnLineChangeEdit(ByRef Sender As Control, ByVal CurrentLine As Integer, ByVal OldLine As Integer)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	bNotFunctionChange = True
	If TextChanged Then
		With tb->txtCode
			If Not .Focused Then bNotFunctionChange = False: Exit Sub
			If OldLine < .FLines.Count Then
				Dim As EditControlLine Ptr ecl = Cast(EditControlLine Ptr, .FLines.Items[OldLine])
				If CInt(ecl->CommentIndex = 0) Then
					If CInt(EndsWith(RTrim(*ecl->Text), "++") OrElse EndsWith(RTrim(*ecl->Text), "--")) AndAlso CInt(IsArg2(Trim(Left(*ecl->Text, Len(RTrim(*ecl->Text)) - 2), Any !"\t "))) Then
						WLet(ecl->Text, RTrim(Left(*ecl->Text, Len(RTrim(*ecl->Text)) - 2)) & " " & Right(RTrim(*ecl->Text), 1) & "= 1")
					End If
					If ChangeKeyWordsCase Then
						
					End If
				End If
			End If
			tb->FormDesign bNotDesignForms Or tb->tbrTop.Buttons.Item(1)->Checked Or Not EndsWith(tb->cboFunction.Text, " [Constructor]")
		End With
		TextChanged = False
	End If
	'    If tb->cboClass.ItemIndex <> 0 Then
	'        tb->cboClass.ItemIndex = 0
	'        cboClass_Change tb->cboClass, 0
	'    End If
	If tb->cboClass.ItemIndex <> 0 Then
		tb->cboClass.ItemIndex = 0
		cboClass_Change tb->cboClass, 0
	End If
	Dim As TypeElement Ptr te1, te2
	Dim t As Boolean
	For i As Integer = 0 To tb->Functions.Count - 1
		te2 = tb->Functions.Object(i)
		If te2 = 0 Then Continue For
		If te2->StartLine <= CurrentLine And te2->EndLine >= CurrentLine Then
			If tb->cboFunction.ItemIndex <> i + 1 Then tb->cboFunction.ItemIndex = i + 1
			t = True
			bNotFunctionChange = False
			Exit Sub
			'For j As Integer = 1 To tb->cboFunction.Items.Count - 1
			'                If te2 = tb->cboFunction.Items.Item(j)->Object Then
			'                	tb->cboFunction.ItemIndex = j
			'                    t = True
			'                    bNotFunctionChange = False
			'                    Exit Sub
			'                End If
			'            Next
		End If
	Next
	tb->cboFunction.ItemIndex = 0
	bNotFunctionChange = False
End Sub

Function GetOnlyArguments(ArgumentsLine As String) As String
	Dim As UString res(Any)
	Dim As Integer Pos1
	Dim As String Result
	Split(Mid(Left(ArgumentsLine, Len(ArgumentsLine) - 1), 2), ",", res())
	For i As Integer = 0 To UBound(res)
		If StartsWith(LTrim(LCase(res(i))), "byref ") OrElse StartsWith(LTrim(LCase(res(i))), "byval ") Then
			res(i) = Mid(res(i), 7)
		End If
		Pos1 = InStr(LCase(res(i)), " as ")
		If Pos1 > 0 Then
			res(i) = Left(res(i), Pos1 - 1)
		End If
		If Result = "" Then
			Result = Trim(res(i))
		Else
			Result &= ", " & Trim(res(i))
		End If
	Next
	Return "(" & Result & ")"
End Function

Sub FindEvent(Cpnt As Any Ptr, EventName As String)
	On Error Goto ErrorHandler
	Dim As TabWindow Ptr tb = ptabRight->Tag
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	If tb->Des->DesignControl = 0 Then Exit Sub
	If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
	Dim frmName As String
	frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	If Cpnt = 0 Then Exit Sub
	Dim CtrlName As String = WGet(tb->Des->ReadPropertyFunc(Cpnt, "Name"))
	If Cpnt = tb->Des->DesignControl Then CtrlName = "This"
	Dim As String CtrlName2 = CtrlName
	If InStr(CtrlName, "(") Then
		CtrlName2 = StringExtract(CtrlName2, "(")
	ElseIf CtrlName = "This" Then
		CtrlName2 = "Form"
	End If
	Var EventName2 = Mid(EventName, IIf(StartsWith(LCase(EventName), "on"), 3, 1))
	Dim As String SubName = CtrlName2 & "_" & EventName2
	Var ii = tb->cboClass.ItemIndex
	Var jj = tb->cboFunction.ItemIndex
	If ii < 0 Then Exit Sub
	Dim As EditControl Ptr ptxtCode, ptxtCodeBi, ptxtCodeType, ptxtCodeConstructor
	Dim As EditControl txtCodeBi
	Dim As Boolean bFind, IsBas = EndsWith(LCase(tb->FileName), ".bas") OrElse EndsWith(LCase(tb->FileName), ".frm")
	Dim As Integer iStart, iEnd, i, k
	Dim As WString Ptr FLine1
	Dim As WStringList WithArgs
	Dim As String WithCtrlName
	Var bWith = False
	WLet(FLine1, "")
	tb->txtCode.Changing "Hodisa qo`shish"
	ChangeControl Cpnt
	Dim As Boolean b, c, e, f, t, td, tdns, tt, tdes
	Dim As Integer j, l, p
	For i = 0 To tb->txtCode.LinesCount - 1
		GetBiFile(ptxtCode, txtCodeBi, ptxtCodeBi, tb, IsBas, bFind, i, iStart, iEnd)
		For k As Integer = iStart To iEnd
			If (Not b) AndAlso StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "type " & LCase(frmName) & " ") Then
				b = True
				ptxtCodeType = ptxtCode
			ElseIf b Then
				If Not e Then
					If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t ") & " ", "end type ") Then
						e = True
					ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "declare constructor") Then
						j = k
					ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "declare static") Then
						l = k
						If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "declare static sub " & LCase(SubName)) Then
							td = True
						End If
					End If
				ElseIf e Then
					If (Not c) AndAlso StartsWith(LCase(Trim(ptxtCode->Lines(k), Any !"\t ")) & " ", "constructor " & LCase(frmName) & " ") Then
						c = True
						ptxtCodeConstructor = ptxtCode
					ElseIf c Then
						If Not f Then
							If StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "with ") Then
								WithArgs.Add Trim(Mid(Trim(ptxtCode->Lines(k), Any !"\t "), 5), Any !"\t ")
							ElseIf StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "end with") Then
								If WithArgs.Count > 0 Then WithArgs.Remove WithArgs.Count - 1
							ElseIf CInt(StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase(CtrlName & "."))) OrElse CInt(CInt(WithArgs.Count > 0) AndAlso CInt(WithArgs.Item(WithArgs.Count - 1) = CtrlName) AndAlso CInt(StartsWith(Trim(LCase(ptxtCode->Lines(k)), Any !"\t "), "."))) Then
								p = k
								bWith = WithArgs.Count > 0 AndAlso WithArgs.Item(WithArgs.Count - 1) = CtrlName
								Var p1 = InStr(ptxtCode->Lines(k), ".")
								If p1 Then
									If CInt(EventName <> "") AndAlso CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), LCase(EventName & "="))) OrElse _
										CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), LCase(EventName & " "))) Then
										Var Pos1 = InStr(ptxtCode->Lines(k), "=")
										If Pos1 > 0 Then
											SubName = Trim(Mid(ptxtCode->Lines(k), Pos1 + 1))
											tt = True
											If StartsWith(SubName, "@") Then SubName = Mid(SubName, 2)
										End If
									ElseIf CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), "designer=")) OrElse _
										CInt(StartsWith(Mid(LCase(ptxtCode->Lines(k)), p1 + 1), "designer ")) Then
										tdes = True
									End If
								End If
							ElseIf StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), "end constructor") Then
								f = True
							End If
						ElseIf f Then
							If StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Public Sub " & frmName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Private Sub " & frmName & "." & SubName)) OrElse _
								StartsWith(LCase(LTrim(ptxtCode->Lines(k), Any !"\t ")), LCase("Sub " & frmName & "." & SubName)) Then
								Var n = Len(ptxtCode->Lines(k)) - Len(LTrim(ptxtCode->Lines(k), Any !"\t "))
								ptxtCode->SetSelection k + 1, k + 1, n + Len(TabSpace), n + Len(TabSpace)
								ptxtCode->TopLine = k
								ptxtCode->SetFocus
								OnLineChangeEdit tb->txtCode, i + 1, i + 1
								If tb->tbrTop.Buttons.Item(2)->Checked Then tb->tbrTop.Buttons.Item(1)->Checked = True
								t = True
								Exit Sub
							End If
						End If
					End If
				End If
			End If
		Next k
		ptxtCode = @tb->txtCode
		iStart = i + 1
		iEnd = i + 1
	Next i
	If Not t Then
		Dim As TypeElement Ptr te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(Cpnt, "ClassName")), EventName)
		Dim As Integer q1, q2, q
		If te = 0 Then Exit Sub
		If Not td Then
			ptxtCode = ptxtCodeType
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			If CreateNonStaticEventHandlers Then
				ptxtCode->InsertLine j, Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare Static Sub " & SubName & "_" & Mid(te->TypeName, 4)
				ptxtCode->InsertLine j + 1, Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare Sub " & SubName & Mid(te->TypeName, 4)
				If ptxtCode = @tb->txtCode Then q1 = 1 Else q2 = 1
			Else
				ptxtCode->InsertLine j, Left(ptxtCode->Lines(j), Len(ptxtCode->Lines(j)) - Len(LTrim(ptxtCode->Lines(j), Any !"\t "))) & "Declare Static Sub " & SubName & Mid(te->TypeName, 4)
			End If
			If ptxtCode = @tb->txtCode Then q1 += 1 Else q2 += 1
		End If
		If Not tt Then
			ptxtCode = ptxtCodeConstructor
			CheckBi(ptxtCode, txtCodeBi, ptxtCodeBi, tb)
			q = IIf(ptxtCode = @tb->txtCode, q1, q2)
			If bWith Then WithCtrlName = "" Else WithCtrlName = CtrlName
			If CreateNonStaticEventHandlers AndAlso Not tdes Then ptxtCode->InsertLine p + q, Left(ptxtCode->Lines(p + q), Len(ptxtCode->Lines(p + q)) - Len(LTrim(ptxtCode->Lines(p + q), Any !"\t "))) & WithCtrlName & ".Designer = @This": q += 1: If ptxtCode = @tb->txtCode Then q1 += 1 Else q2 += 1
			ptxtCode->InsertLine p + q, Left(ptxtCode->Lines(p + q), Len(ptxtCode->Lines(p + q)) - Len(LTrim(ptxtCode->Lines(p + q), Any !"\t "))) & WithCtrlName & "." & EventName & " = @" & SubName & IIf(CreateNonStaticEventHandlers, "_", "")
			If ptxtCode = @tb->txtCode Then q1 += 1 Else q2 += 1
		End If
		ptxtCode = @tb->txtCode
		q = q1
		ptxtCode->InsertLine i + q, ""
		If CreateNonStaticEventHandlers Then
			ptxtCode->InsertLine i + q + 1, "Private Sub " & frmName & "." & SubName & "_" & Mid(te->TypeName, 4)
			ptxtCode->InsertLine i + q + 2, TabSpace & "*Cast(" & frmName & " Ptr, Sender.Designer)." & SubName & GetOnlyArguments(Mid(te->TypeName, 4))
			ptxtCode->InsertLine i + q + 3, "End Sub"
			q += 3
		End If
		ptxtCode->InsertLine i + q + 1, "Private Sub " & frmName & "." & SubName & Mid(te->TypeName, 4)
		ptxtCode->InsertLine i + q + 2, TabSpace
		ptxtCode->InsertLine i + q + 3, "End Sub"
		bNotDesignForms = True
		ptxtCode->SetSelection i + q + 2, i + q + 2, Len(TabSpace), Len(TabSpace)
		ptxtCode->TopLine = i + q + 1
		ptxtCode->Changed "Hodisa qo`shish"
		ptxtCode->SetFocus
		If plvEvents->ListItems.Contains(EventName) Then
			plvEvents->ListItems.Item(plvEvents->ListItems.IndexOf(EventName))->Text(1) = SubName
		End If
		OnLineChangeEdit tb->txtCode, i + q + 2, i + q + 2
		If tb->tbrTop.Buttons.Item(2)->Checked Then tb->tbrTop.Buttons.Item(1)->Checked = True
		bNotDesignForms = False
	End If
	WDeallocate FLine1
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

Sub cboFunction_Change(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	If bNotFunctionChange Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	'If frmMain.ActiveControl AndAlso frmMain.ActiveControl->ClassName = "EditControl" Then Exit Sub
	Dim frmName As String
	If tb->Des <> 0 AndAlso tb->Des->ReadPropertyFunc <> 0 AndAlso tb->Des->DesignControl <> 0 Then frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	Var ii = tb->cboClass.ItemIndex
	Var jj = tb->cboFunction.ItemIndex
	If ii < 0 Then Exit Sub
	Dim As Boolean b, c, e, f, t, td, tdns, tt, ttns
	Dim As Integer i, j, k, l
	With tb->txtCode
		If ii = 0 Then
			If jj = 0 Then
				.SetFocus
				.SetSelection 0, 0, 0, 0
				t = True
			ElseIf jj > 0 Then
				Dim te As TypeElement Ptr
				Dim i As Integer
				te = tb->cboFunction.Items.Item(jj)->Object
				If te <> 0 Then
					i = te->StartLine
					Var n = Len(.Lines(i)) - Len(LTrim(.Lines(i)))
					If te->Declaration Then
						.SetSelection i, i, n, n
					Else
						.SetSelection i + 1, i + 1, n, n
					End If
					.TopLine = i
					.SetFocus
					t = True
				End If
				If tb->tbrTop.Buttons.Item(2)->Checked Then
					tb->tbrTop.Buttons.Item(1)->Checked = True
				End If
			End If
			Exit Sub
		ElseIf ii = 1 And jj = 0 Then
			For i = 0 To .LinesCount - 1
				If StartsWith(Trim(LCase(.Lines(i))), "type " & LCase(frmName) & " ") Then
					Var n = Len(.Lines(i)) - Len(LTrim(.Lines(i)))
					.TopLine = i
					.SetSelection i + 1, i + 1, n + 4, n + 4
					.SetFocus
					t = True
					Exit Sub
				End If
			Next i
		ElseIf Sender.ItemIndex <> -1 Then
			FindEvent tb->cboClass.Items.Item(tb->cboClass.ItemIndex)->Object, tb->cboFunction.Items.Item(Sender.ItemIndex)->Text
		End If
	End With
End Sub

Sub DesignerDblClickControl(ByRef Sender As Designer, Ctrl As Any Ptr)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Select Case QWString(tb->Des->ReadPropertyFunc(Ctrl, "ClassName"))
	Case "MainMenu", "PopupMenu"
		pfMenuEditor->Show *pfrmMain
	Case Else
		If tb->cboFunction.Items.Count > 1 Then
			FindEvent tb->cboClass.Items.Item(tb->cboClass.ItemIndex)->Object, tb->cboFunction.Items.Item(1)->Text
			'tb->cboFunction.ItemIndex = 1
			'cboFunction_Change tb->cboFunction
			If tb->tbrTop.Buttons.Item(2)->Checked Then
				tb->tbrTop.Buttons.Item(1)->Checked = True
			End If
		End If
	End Select
	'    With tb->txtCode
	'        frmMain.UpdateLock
	'        .Changing "Unsurni o`zgartirish"
	'        ChangeControl Ctrl
	'        .Changed "Unsurni o`zgartirish"
	'        frmMain.UpdateUnLock
	'    End With
End Sub

Sub DesignerClickProperties(ByRef Sender As Designer, Ctrl As Any Ptr)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	ptabRight->Tab(0)->SelectTab
End Sub

#ifdef __USE_GTK__
	Sub lvIntellisense_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Dim sLine As WString Ptr = @tb->txtCode.Lines(SelLinePos)
		Dim i As Integer = GetNextCharIndex(*sLine, SelCharPos)
		'    Dim sTempRight As WString Ptr
		'    WLet sTempRight, Mid(*sLine, SelCharPos + 1, i - SelCharPos)
		'    ?"""" & *sTempRight & """"
		With tb->txtCode.lvIntellisense
			'        If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.Items.Item(.ItemIndex)->Text), LCase(*sTempRight))) Then
			'        Else
			tb->txtCode.ReplaceLine SelLinePos, Left(*sLine, SelCharPos) & .ListItems.Item(ItemIndex)->Text(0) & Mid(*sLine, i + 1)
			i = SelCharPos + Len(.ListItems.Item(ItemIndex)->Text(0))
			tb->txtCode.SetSelection SelLinePos, SelLinePos, i, i
			tb->txtCode.SetFocus
			#ifdef __USE_GTK__
				tb->txtCode.CloseDropDown
			#endif
			'        End If
		End With
	End Sub
#else
	Sub cboIntellisense_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		If ItemIndex < 0 OrElse ItemIndex > Cast(ComboBoxEx Ptr, @Sender)->Items.Count - 1 Then Exit Sub
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Dim sLine As WString Ptr = @tb->txtCode.Lines(SelLinePos)
		Dim i As Integer = GetNextCharIndex(*sLine, SelCharPos, True)
		With tb->txtCode.cboIntellisense
			tb->txtCode.ReplaceLine SelLinePos, Left(*sLine, SelCharPos) & .Items.Item(ItemIndex)->Text & Mid(*sLine, i + 1)
			i = SelCharPos + Len(.Items.Item(ItemIndex)->Text)
			tb->txtCode.SetSelection SelLinePos, SelLinePos, i, i
			tb->txtCode.SetFocus
		End With
	End Sub
#endif

Sub OnKeyDownEdit(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	#ifdef __USE_GTK__
		If Key = GDK_KEY_SPACE AndAlso (Shift And GDK_Control_MASK) Then
			CompleteWord
		End If
	#endif
	'    If Key = 13 Then
	'        If tb->txtCode.DropDownShowed Then
	'            tb->txtCode.cboIntellisense.ShowDropDown False
	'            cboIntellisense_Selected tb->txtCode.cboIntellisense
	'            Key = 0
	'        End If
	'    End If
End Sub

Function AddSorted(tb As TabWindow Ptr, ByRef Text As WString, te As TypeElement Ptr = 0, ByRef Starts As WString = "", ByRef c As Integer = 0, ByRef imgKey As String = "Type") As Boolean
    On Error Goto ErrorHandler
	If Not StartsWith(LCase(Text), LCase(Starts)) Then Return True
	c += 1
	If c > 100 Then Return False
	If te = 0 Then
		imgKey = "StandartTypes"
	End If
	#ifdef __USE_GTK__
		Dim iIndex As Integer = -1
		With tb->txtCode.lvIntellisense.ListItems
			For i As Integer = 0 To .Count - 1
				If LCase(.Item(i)->Text(0)) = LCase(Text) Then
					Return True
				ElseIf LCase(.Item(i)->Text(0)) > LCase(Text) Then
					iIndex = i: Exit For
				End If
			Next i
			.Add Text, imgKey, , , iIndex
		End With
	#else
		Dim iIndex As Integer = -1
		With tb->txtCode.cboIntellisense.Items
			For i As Integer = 0 To .Count - 1
				If LCase(.Item(i)->Text) = LCase(Text) Then
					Return True
				ElseIf LCase(.Item(i)->Text) > LCase(Text) Then
					iIndex = i: Exit For
				End If
			Next i
			.Add Text, te, imgKey, imgKey, , , iIndex
		End With
	#endif
	Return True
    Exit Function
ErrorHandler:
    MsgBox Text & " " & ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
        "in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
        "in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
End Function

Sub FillAllIntellisenses(ByRef Starts As WString = "")
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	#ifdef __USE_GTK__
		tb->txtCode.lvIntellisense.ListItems.Clear
	#else
		tb->txtCode.cboIntellisense.Items.Clear
	#endif
	Dim c As Integer
	For i As Integer = 0 To pKeyWords0->Count - 1
		If Not AddSorted(tb, GetKeyWordCase(pKeyWords0->Item(i)), , Starts) Then Exit Sub
	Next
	For i As Integer = 0 To pKeyWords1->Count - 1
		If Not AddSorted(tb, GetKeyWordCase(pKeyWords1->Item(i)), , Starts) Then Exit Sub
	Next
	For i As Integer = 0 To pKeyWords2->Count - 1
		If Not AddSorted(tb, GetKeyWordCase(pKeyWords2->Item(i)), , Starts) Then Exit Sub
	Next
	For i As Integer = 0 To pKeyWords3->Count - 1
		If Not AddSorted(tb, GetKeyWordCase(pKeyWords3->Item(i)), , Starts) Then Exit Sub
	Next
	For i As Integer = 0 To tb->Types.Count - 1
		If Not AddSorted(tb, tb->Types.Item(i), tb->Types.Object(i), Starts) Then Exit Sub
	Next
	For i As Integer = 0 To tb->Enums.Count - 1
		If Not AddSorted(tb, tb->Enums.Item(i), tb->Enums.Object(i), Starts) Then Exit Sub
	Next
	For i As Integer = 0 To tb->Procedures.Count - 1
		If Not AddSorted(tb, tb->Procedures.Item(i), tb->Procedures.Object(i), Starts) Then Exit Sub
	Next
	For i As Integer = 0 To tb->Args.Count - 1
		If Not AddSorted(tb, tb->Args.Item(i), tb->Args.Object(i), Starts) Then Exit Sub
	Next
	Dim As Integer Pos1
	Dim As String TypeName
	Dim As TypeElement Ptr te, te1
	Dim As String FuncName = tb->cboFunction.Text
	If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
	Pos1 = InStr(tb->cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(Left(tb->cboFunction.Text, Pos1 - 1)): TypeName = FuncName
	Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(Left(FuncName, Pos1 - 1))
	If TypeName <> "" Then FillIntellisenseByName TypeName, Starts, True, True, True
	If te1 <> 0 Then
		For i As Integer = 0 To te1->Elements.Count - 1
			te = te1->Elements.Object(i)
			If te <> 0 Then
				If Not AddSorted(tb, te->Name, te, Starts, c) Then Exit Sub
			End If
		Next
	End If
	For i As Integer = 0 To pGlobalNamespaces->Count - 1
		If Not AddSorted(tb, pGlobalNamespaces->Item(i), pGlobalNamespaces->Object(i), Starts, c) Then Exit Sub
	Next
	'If Len(Starts) < 3 Then Exit Sub
	For i As Integer = 0 To pComps->Count - 1
		If Not AddSorted(tb, pComps->Item(i), pComps->Object(i), Starts, c) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalTypes->Count - 1
		If Not AddSorted(tb, pGlobalTypes->Item(i), pGlobalTypes->Object(i), Starts, c) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalEnums->Count - 1
		If Not AddSorted(tb, pGlobalEnums->Item(i), pGlobalEnums->Object(i), Starts, c) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalFunctions->Count - 1
		If Not AddSorted(tb, pGlobalFunctions->Item(i), pGlobalFunctions->Object(i), Starts, c) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalArgs->Count - 1
		If Not AddSorted(tb, pGlobalArgs->Item(i), pGlobalArgs->Object(i), Starts, c) Then Exit Sub
	Next
End Sub

Sub FillTypeIntellisenses(ByRef Starts As WString = "")
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	#ifdef __USE_GTK__
		tb->txtCode.lvIntellisense.ListItems.Clear
	#else
		tb->txtCode.cboIntellisense.Items.Clear
	#endif
	Dim c As Integer
	For i As Integer = 0 To pKeyWords1->Count - 1
		AddSorted tb, GetKeyWordCase(pKeyWords1->Item(i)), , Starts
	Next
	AddSorted tb, GetKeyWordCase("Const"), , Starts
	AddSorted tb, GetKeyWordCase("TypeOf"), , Starts
	AddSorted tb, GetKeyWordCase("Sub"), , Starts
	AddSorted tb, GetKeyWordCase("Function"), , Starts
	For i As Integer = 0 To tb->Types.Count - 1
		If Not AddSorted(tb, tb->Types.Item(i), tb->Types.Object(i), Starts) Then Exit Sub
	Next
	For i As Integer = 0 To tb->Enums.Count - 1
		If Not AddSorted(tb, tb->Enums.Item(i), tb->Enums.Object(i), Starts, , "Enum") Then Exit Sub
	Next
	'If Len(Starts) < 3 Then Exit Sub
	For i As Integer = 0 To pComps->Count - 1
		If Not AddSorted(tb, pComps->Item(i), pComps->Object(i), Starts, c) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalTypes->Count - 1
		If Not AddSorted(tb, pGlobalTypes->Item(i), pGlobalTypes->Object(i), Starts, c) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalEnums->Count - 1
		If Not AddSorted(tb, pGlobalEnums->Item(i), pGlobalEnums->Object(i), Starts, c) Then Exit Sub
	Next
	For i As Integer = 0 To pGlobalNamespaces->Count - 1
		If Not AddSorted(tb, pGlobalNamespaces->Item(i), pGlobalNamespaces->Object(i), Starts, c) Then Exit Sub
	Next
End Sub

Function TabWindow.FillIntellisense(ByRef ClassName As WString, pList As WStringList Ptr, bLocal As Boolean = False, bAll As Boolean = False) As Boolean
	If ClassName = "" Then Return False
	Var Index = pList->IndexOf(ClassName)
	If Index = -1 Then Return False
	tbi = pList->Object(Index)
	If tbi Then
		i = 0
		Do While i <= tbi->Elements.Count - 1
			te = tbi->Elements.Object(i)
			If te Then
				With *te
					If bLocal OrElse .Locals = 0 Then
						If bAll OrElse Not FListItems.Contains(.Name) Then
							FListItems.Add tbi->Elements.Item(i), te
						End If
					End If
				End With
			End If
			i += 1
		Loop
		If FillIntellisense(tbi->TypeName, pList, bLocal, bAll) Then
		ElseIf FillIntellisense(tbi->TypeName, @Types, bLocal, bAll) Then
		ElseIf FillIntellisense(tbi->TypeName, @Enums, bLocal, bAll) Then
		ElseIf FillIntellisense(tbi->TypeName, pComps, bLocal, bAll) Then
		ElseIf FillIntellisense(tbi->TypeName, pGlobalTypes, bLocal, bAll) Then
		ElseIf FillIntellisense(tbi->TypeName, pGlobalEnums, bLocal, bAll) Then
		ElseIf FillIntellisense(tbi->TypeName, pGlobalNamespaces, bLocal, bAll) Then
		End If
	End If
	Return True
End Function

Function Ekvivalent(ByRef a As WString, ByRef b As WString) As Integer
	Dim i As Integer
	For i = 1 To Len(b)
		If LCase(Mid(a, i, 1)) <> LCase(Mid(b, i, 1)) Then Return i - 1
	Next
	Return i - 1
End Function

Sub FindComboIndex(tb As TabWindow Ptr, ByRef sLine As WString, iEndChar As Integer)
	Dim As WString Ptr sTempRight
	For i As Integer = iEndChar + 1 To Len(sLine)
		If CInt(IsArg(Asc(Mid(sLine, i, 1)))) OrElse CInt(Mid(sLine, i, 1) = "#") Then WLetEx(sTempRight, *sTempRight & Mid(sLine, i, 1), True) Else Exit For
	Next
	#ifdef __USE_GTK__
		With tb->txtCode.lvIntellisense
	#else
		With tb->txtCode.cboIntellisense
	#endif
		Dim As Integer Ekv, EkvOld, iPos = -1, i
		#ifdef __USE_GTK__
			For i = 0 To .ListItems.Count - 1
				Ekv = Ekvivalent(.ListItems.Item(i)->Text(0), *sTempRight)
		#else
			For i = 0 To .Items.Count - 1
				Ekv = Ekvivalent(.Items.Item(i)->Text, *sTempRight)
		#endif
			If Ekv < EkvOld Then
				Exit For
			ElseIf Ekv > EkvOld Then
				iPos = i
			End If
			EkvOld = Ekv
		Next
		#ifdef __USE_GTK__
			.SelectedItemIndex = iPos
		#else
			.ItemIndex = iPos
		#endif
		tb->txtCode.LastItemIndex = iPos
		tb->txtCode.FocusedItemIndex = iPos
		If iPos > 0 Then
			#ifdef __USE_GTK__
				If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.ListItems.Item(i - 1)->Text(0)), LCase(*sTempRight))) Then
			#else
				If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.Items.Item(i - 1)->Text), LCase(*sTempRight))) Then
			#endif
				tb->txtCode.LastItemIndex = -1
			End If
		End If
	End With
	WDeallocate sTempRight
End Sub

Sub FillIntellisenseByName(Value As String, Starts As String = "", bLocal As Boolean = False, bAll As Boolean = False, NotClear As Boolean = False)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As String sTemp2 = Value
	If tb->Des AndAlso tb->Des->ReadPropertyFunc <> 0 Then
		If CInt(LCase(sTemp2) = "this") AndAlso CInt(tb->Des) AndAlso CInt(tb->Des->DesignControl) AndAlso CInt(StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & " ") OrElse StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & ".")) Then
			sTemp2 = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
		End If
	End If
	FListItems.Clear
	If Not NotClear Then
		#ifdef __USE_GTK__
			tb->txtCode.lvIntellisense.ListItems.Clear
			tb->txtCode.lvIntellisense.Sort = ssSortAscending
		#else
			tb->txtCode.cboIntellisense.Items.Clear
			tb->txtCode.cboIntellisense.Sort = True
		#endif
	End If
	Dim As TypeElement Ptr te, te1
	Dim As Integer Pos1
	'Dim As String TypeName, FuncName = tb->cboFunction.Text
	'	If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
	'	Pos1 = InStr(tb->cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(Left(tb->cboFunction.Text, Pos1 - 1)): TypeName = FuncName
	'	Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(Left(FuncName, Pos1 - 1))
	'	If te1 <> 0 AndAlso te1->Elements.Contains(sTemp2) Then
	'		te = te1->Elements.Object(te1->Elements.IndexOf(sTemp2))
	'	ElseIf tb->Procedures.Contains(sTemp2) Then
	'		te = tb->Procedures.Object(tb->Procedures.IndexOf(sTemp2))
	'	ElseIf tb->Args.Contains(sTemp2) Then
	'		te = tb->Args.Object(tb->Args.IndexOf(sTemp2))
	'	ElseIf pGlobalFunctions->Contains(sTemp2) Then
	'		te = pGlobalFunctions->Object(pGlobalFunctions->IndexOf(sTemp2))
	'	ElseIf pGlobalArgs->Contains(sTemp2) Then
	'		te = pGlobalArgs->Object(pGlobalArgs->IndexOf(sTemp2))
	'	ElseIf TypeName <> "" Then
	'		If tb->Types.Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, @tb->Types, True
	'		ElseIf tb->Enums.Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, @tb->Enums, True
	'		ElseIf pComps->Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, pComps, True
	'		ElseIf pGlobalTypes->Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, pGlobalTypes, True
	'		ElseIf pGlobalEnums->Contains(TypeName) Then
	'			tb->FillIntellisense TypeName, pGlobalEnums, True
	'		End If
	'		If FListItems.Contains(sTemp2) Then
	'			te = FListItems.Object(FListItems.IndexOf(sTemp2))
	'		End If
	'		FListItems.Clear
	'	End If
	'	If te <> 0 Then sTemp2 = te->TypeName
	If tb->Types.Contains(sTemp2) Then
		tb->FillIntellisense sTemp2, @tb->Types, bLocal, bAll
	ElseIf tb->Enums.Contains(sTemp2) Then
		tb->FillIntellisense sTemp2, @tb->Enums, bLocal, bAll
	ElseIf pComps->Contains(sTemp2) Then
		tb->FillIntellisense sTemp2, pComps, bLocal, bAll
	ElseIf pGlobalTypes->Contains(sTemp2) Then
		tb->FillIntellisense sTemp2, pGlobalTypes, bLocal, bAll
	ElseIf pGlobalEnums->Contains(sTemp2) Then
		tb->FillIntellisense sTemp2, pGlobalEnums, bLocal, bAll
	ElseIf pGlobalNamespaces->Contains(sTemp2) Then
		tb->FillIntellisense sTemp2, pGlobalNamespaces, bLocal, bAll
	Else
		Exit Sub
	End If
	FListItems.Sort
	For i As Integer = 0 To FListItems.Count - 1
		Dim As String imgKey = "Sub"
		te = FListItems.Object(i)
		If te = 0 Then Continue For
		If te->ElementType = "Property" Then
			imgKey = "Property"
		ElseIf te->ElementType = "Function" Then
			imgKey = "Function"
		ElseIf te->ElementType = "Event" Then
			imgKey = "Event"
		ElseIf te->ElementType = "Enum" Then
			imgKey = "Enum"
		ElseIf te->ElementType = "Type" OrElse te->ElementType = "TypeCopy" OrElse te->ElementType = "Union" Then
			imgKey = "Type"
		End If
		If NotClear Then
			If Not AddSorted(tb, FListItems.Item(i), te, Starts) Then Exit Sub
		Else
			#ifdef __USE_GTK__
				tb->txtCode.lvIntellisense.ListItems.Add FListItems.Item(i), imgKey
			#else
				tb->txtCode.cboIntellisense.Items.Add FListItems.Item(i), te, imgKey, imgKey
			#endif
		End If
	Next i
End Sub

Sub CompleteWord
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	SelLinePos = iSelEndLine
	Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
	Dim As String s, sTemp, sTemp2, TypeName, OldTypeName
	Dim As TypeElement Ptr te, te1, teOld
	Dim As Boolean b, c, d, f
	SelCharPos = 0
	For i As Integer = iSelEndChar To 1 Step -1
		s = Mid(*sLine, i, 1)
		If CInt(IsArg(Asc(s))) OrElse CInt(s = "#") Then
			If b Or f Then
				sTemp2 = s & sTemp2
			Else
				sTemp = s & sTemp
			End If
			If f Then d = True
		ElseIf CInt(s = " " OrElse s = !"\t") AndAlso CInt(Not d) AndAlso CInt(Not b) Then
			If Not f Then SelCharPos = i
			f = True
		ElseIf s = "." Then
			b = True
			GetLeftArgTypeName tb, iSelEndLine, i - 1, te, teOld
			SelCharPos = i
			Exit For
		ElseIf s = ">" Then
			c = True
			SelCharPos = i
		ElseIf CInt(c) AndAlso CInt(s = "-") Then
			GetLeftArgTypeName tb, iSelEndLine, i - 1, te, teOld, OldTypeName
			b = True
			Exit For
		Else
			Exit For
		End If
	Next
	If teOld <> 0 OrElse OldTypeName <> "" Then
		If OldTypeName <> "" Then
			TypeName = OldTypeName
		Else
			TypeName = teOld->TypeName
		End If
		If TypeName = "" AndAlso teOld <> 0 AndAlso teOld->Value <> "" Then
			TypeName = GetTypeFromValue(tb, teOld->Value)
		End If
		FillIntellisenseByName TypeName
	Else
		If LCase(sTemp2) = "as" Then
			FillTypeIntellisenses sTemp
		Else
			FillAllIntellisenses sTemp
		End If
	End If
	#ifdef __USE_GTK__
		If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then Exit Sub
		With tb->txtCode.lvIntellisense
	#else
		If tb->txtCode.cboIntellisense.Items.Count = 0 Then Exit Sub
		With tb->txtCode.cboIntellisense
	#endif
		FindComboIndex(tb, *sLine, SelCharPos)
		#ifdef __USE_GTK__
			If CInt(tb->txtCode.LastItemIndex <> -1 AndAlso tb->txtCode.LastItemIndex < .ListItems.Count) AndAlso _
				CInt(Not StartsWith(LCase(.ListItems.Item(tb->txtCode.LastItemIndex)->Text(0)), LCase(sTemp))) Then
		#else
			If CInt(tb->txtCode.LastItemIndex <> -1 AndAlso tb->txtCode.LastItemIndex < .Items.Count) AndAlso _
				CInt(Not StartsWith(LCase(.Items.Item(tb->txtCode.LastItemIndex)->Text), LCase(sTemp))) Then
		#endif
			Dim i As Integer = GetNextCharIndex(*sLine, SelCharPos)
			#ifdef __USE_GTK__
				If tb->txtCode.lvIntellisense.SelectedItem Then
					tb->txtCode.ReplaceLine iSelEndLine, Left(*sLine, SelCharPos) & .SelectedItem->Text(0) & Mid(*sLine, i + 1)
					i = SelCharPos + Len(.SelectedItem->Text(0))
				End If
			#else
				tb->txtCode.ReplaceLine iSelEndLine, Left(*sLine, SelCharPos) & .Text & Mid(*sLine, i + 1)
				i = SelCharPos + Len(.Text)
			#endif
			tb->txtCode.SetSelection SelLinePos, SelLinePos, i, i
			Exit Sub
		End If
		tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
	End With
End Sub

Function GetLeftArg(tb As TabWindow Ptr, iSelEndLine As Integer, iSelEndChar As Integer) As String
	Dim As String sTemp
	Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
	Dim j As Integer
	For i As Integer = iSelEndChar To 1 Step -1
		If IsArg(Asc(Mid(*sLine, i, 1))) Then sTemp = Mid(*sLine, i, 1) & sTemp Else Exit For
	Next
	If sTemp = "" Then
		Var WithCount = 1
		Dim As EditControlLine Ptr ECLine
		For i As Integer = iSelEndLine To 0 Step -1
			ECLine = tb->txtCode.FLines.Items[i]
			If ECLine->ConstructionIndex > 12 Then
				Return ""
			ElseIf ECLine->ConstructionIndex = 10 Then
				If ECLine->ConstructionPart = 2 Then
					WithCount += 1
				ElseIf ECLine->ConstructionPart = 0 Then
					WithCount -= 1
					If WithCount < 0 Then
						Return ""
					ElseIf WithCount = 0 Then
						sTemp = Trim(Mid(Trim(*ECLine->Text, Any !"\t "), 5), Any !"\t ")
						Exit For
					End If
				End If
			End If
		Next
	End If
	Return sTemp
End Function

Function GetChangedCommas(Value As String) As String
	Dim As String ch, Text
	Dim As Boolean b
	Dim As Integer iCount
	For i As Integer = 1 To Len(Value)
		ch = Mid(Value, i, 1)
		If ch = "(" Then
			iCount += 1
			b = True
		ElseIf b AndAlso ch = ")" Then
			iCount -= 1
			If iCount = 0 Then b = False
		ElseIf b AndAlso ch = "," Then
			Text &= ";"
			Continue For
		End If
		Text &= ch
	Next
	Return Text
End Function

Function GetTypeFromValue(tb As TabWindow Ptr, Value As String) As String
	Dim As String sTemp
	If StartsWith(LCase(Value), "cast(") OrElse StartsWith(LCase(Value), "*cast(") Then
		Var Pos1 = InStr(Value, "(")
		Var Pos2 = InStr(Value, ",")
		If Pos2 > 0 Then
			sTemp = WithoutPointers(Trim(Mid(Value, Pos1 + 1, Pos2 - Pos1 - 1)))
		End If
	Else
		Dim As String TypeName
		Dim As Integer j, iCount
		Dim As String ch
		Dim As Boolean b
		For i As Integer = Len(Value) To 1 Step -1
			ch = Mid(Value, i, 1)
			If ch = ")" Then
				iCount += 1
				b = True
			ElseIf b AndAlso ch = "(" Then
				iCount -= 1
				If iCount = 0 Then b = False
			ElseIf Not b Then
				If IsArg(Asc(ch)) Then
					sTemp = ch & sTemp
				ElseIf sTemp <> "" Then
					If ch = "." Then
						TypeName = GetTypeFromValue(tb, Left(Value, i - 1))
					ElseIf ch = ">" AndAlso i > 0 AndAlso Mid(Value, i - 1, 1) = "-" Then
						TypeName = GetTypeFromValue(tb, Left(Value, i - 2))
					End If
					Exit For
				Else
					Exit For
				End If
			End If
		Next
		If tb->Des AndAlso tb->Des->ReadPropertyFunc <> 0 Then
			If CInt(LCase(sTemp) = "this") AndAlso CInt(tb->Des) AndAlso CInt(tb->Des->DesignControl) AndAlso CInt(StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & " ") OrElse StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & ".")) Then
				sTemp = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
			End If
		End If
		Dim As TypeElement Ptr te, te1
		Dim As Integer Pos1
		Dim As String FuncName = tb->cboFunction.Text
		If TypeName <> "" Then
			If tb->Types.Contains(TypeName) Then
				tb->FillIntellisense TypeName, @tb->Types, True
			ElseIf tb->Enums.Contains(TypeName) Then
				tb->FillIntellisense TypeName, @tb->Enums, True
			ElseIf pComps->Contains(TypeName) Then
				tb->FillIntellisense TypeName, pComps, True
			ElseIf pGlobalTypes->Contains(TypeName) Then
				tb->FillIntellisense TypeName, pGlobalTypes, True
			ElseIf pGlobalEnums->Contains(TypeName) Then
				tb->FillIntellisense TypeName, pGlobalEnums, True
			End If
			If FListItems.Contains(sTemp) Then
				te = FListItems.Object(FListItems.IndexOf(sTemp))
			End If
			FListItems.Clear
		Else
			If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
			Pos1 = InStr(tb->cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(Left(tb->cboFunction.Text, Pos1 - 1)): TypeName = FuncName
			Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(Left(FuncName, Pos1 - 1))
			If te1 <> 0 AndAlso te1->Elements.Contains(sTemp) Then
				te = te1->Elements.Object(te1->Elements.IndexOf(sTemp))
			ElseIf tb->Procedures.Contains(sTemp) Then
				te = tb->Procedures.Object(tb->Procedures.IndexOf(sTemp))
			ElseIf tb->Args.Contains(sTemp) Then
				te = tb->Args.Object(tb->Args.IndexOf(sTemp))
			ElseIf pGlobalFunctions->Contains(sTemp) Then
				te = pGlobalFunctions->Object(pGlobalFunctions->IndexOf(sTemp))
			ElseIf pGlobalArgs->Contains(sTemp) Then
				te = pGlobalArgs->Object(pGlobalArgs->IndexOf(sTemp))
			ElseIf TypeName <> "" Then
				If tb->Types.Contains(TypeName) Then
					'teEnumOld = tb->Types.Object(tb->Types.IndexOf(TypeName))
					tb->FillIntellisense TypeName, @tb->Types, True
				ElseIf tb->Enums.Contains(TypeName) Then
					tb->FillIntellisense TypeName, @tb->Enums, True
				ElseIf pComps->Contains(TypeName) Then
					tb->FillIntellisense TypeName, pComps, True
				ElseIf pGlobalTypes->Contains(TypeName) Then
					tb->FillIntellisense TypeName, pGlobalTypes, True
				ElseIf pGlobalEnums->Contains(TypeName) Then
					tb->FillIntellisense TypeName, pGlobalEnums, True
				End If
				If FListItems.Contains(sTemp) Then
					te = FListItems.Object(FListItems.IndexOf(sTemp))
				End If
				FListItems.Clear
			End If
		End If
		If te <> 0 Then
			sTemp = te->TypeName
			If sTemp = "" AndAlso te->Value <> "" Then
				sTemp = GetTypeFromValue(tb, te->Value)
			End If
		End If
	End If
	Return sTemp
End Function

Function GetLeftArgTypeName(tb As TabWindow Ptr, iSelEndLine As Integer, iSelEndChar As Integer, ByRef teEnum As TypeElement Ptr = 0, ByRef teEnumOld As TypeElement Ptr = 0, ByRef OldTypeName As String = "") As String
	Dim As String sTemp, sTemp2, TypeName
	Dim sLine As WString Ptr
	Dim As Integer j, iCount, Pos1
	Dim As String ch
	Dim As Boolean b
	For j = iSelEndLine To 0 Step -1
		sLine = @tb->txtCode.Lines(j)
		If j < iSelEndLine AndAlso Not EndsWith(RTrim(*sLine), " _") Then Exit For
		For i As Integer = IIf(j = iSelEndLine, iSelEndChar, Len(*sLine)) To 1 Step -1
			ch = Mid(*sLine, i, 1)
			If ch = ")" Then
				iCount += 1
				b = True
			ElseIf b AndAlso ch = "(" Then
				iCount -= 1
				If iCount = 0 Then b = False
			ElseIf Not b Then
				If IsArg(Asc(ch)) Then
					sTemp = ch & sTemp
				ElseIf sTemp <> "" Then
					If ch = "." Then
						TypeName = GetLeftArgTypeName(tb, j, i - 1, teEnumOld)
					ElseIf ch = ">" AndAlso i > 0 AndAlso Mid(*sLine, i - 1, 1) = "-" Then
						TypeName = GetLeftArgTypeName(tb, j, i - 2, teEnumOld)
					End If
					Exit For, For
				Else
					Exit For, For
				End If
			End If
			sTemp2 = ch & sTemp2
		Next
	Next
	If StartsWith(LCase(sTemp2), "cast") Then
		Return GetTypeFromValue(tb, sTemp2)
	End If
	If sTemp = "" Then
		Var WithCount = 1
		Dim As EditControlLine Ptr ECLine
		For i As Integer = j - 1 To 0 Step -1
			ECLine = tb->txtCode.FLines.Items[i]
			If ECLine->ConstructionIndex > 12 Then
				Return ""
			ElseIf ECLine->ConstructionIndex = 10 Then
				If ECLine->ConstructionPart = 2 Then
					WithCount += 1
				ElseIf ECLine->ConstructionPart = 0 Then
					WithCount -= 1
					If WithCount < 0 Then
						Return ""
					ElseIf WithCount = 0 Then
						TypeName = GetLeftArgTypeName(tb, i, Len(*ECLine->Text), teEnumOld)
						teEnum = teEnumOld
						Return TypeName
					End If
				End If
			End If
		Next
	End If
	If tb->Des AndAlso tb->Des->ReadPropertyFunc <> 0 Then
		If CInt(LCase(sTemp) = "this") AndAlso CInt(tb->Des) AndAlso CInt(tb->Des->DesignControl) AndAlso CInt(StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & " ") OrElse StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & ".")) Then
			sTemp = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
		End If
	End If
	Dim As TypeElement Ptr te, te1
	If TypeName <> "" Then
		If tb->Types.Contains(TypeName) Then
			tb->FillIntellisense TypeName, @tb->Types, True
		ElseIf tb->Enums.Contains(TypeName) Then
			tb->FillIntellisense TypeName, @tb->Enums, True
		ElseIf pComps->Contains(TypeName) Then
			tb->FillIntellisense TypeName, pComps, True
		ElseIf pGlobalTypes->Contains(TypeName) Then
			tb->FillIntellisense TypeName, pGlobalTypes, True
		ElseIf pGlobalEnums->Contains(TypeName) Then
			tb->FillIntellisense TypeName, pGlobalEnums, True
		ElseIf pGlobalNamespaces->Contains(TypeName) Then
			tb->FillIntellisense TypeName, pGlobalNamespaces, True
		End If
		If FListItems.Contains(sTemp) Then
			te = FListItems.Object(FListItems.IndexOf(sTemp))
			OldTypeName = TypeName
		End If
		FListItems.Clear
	Else
		Dim As String FuncName = tb->cboFunction.Text
		If tb->cboFunction.ItemIndex > -1 Then te1 = tb->cboFunction.Items.Item(tb->cboFunction.ItemIndex)->Object
		Pos1 = InStr(tb->cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(Left(tb->cboFunction.Text, Pos1 - 1)): TypeName = FuncName
		Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(Left(FuncName, Pos1 - 1))
		If LCase(sTemp) = "this" Then Return TypeName
		If te1 <> 0 AndAlso te1->Elements.Contains(sTemp) Then
			te = te1->Elements.Object(te1->Elements.IndexOf(sTemp))
		ElseIf tb->Procedures.Contains(sTemp) Then
			te = tb->Procedures.Object(tb->Procedures.IndexOf(sTemp))
		ElseIf tb->Args.Contains(sTemp) Then
			te = tb->Args.Object(tb->Args.IndexOf(sTemp))
		ElseIf pGlobalFunctions->Contains(sTemp) Then
			te = pGlobalFunctions->Object(pGlobalFunctions->IndexOf(sTemp))
		ElseIf pGlobalArgs->Contains(sTemp) Then
			te = pGlobalArgs->Object(pGlobalArgs->IndexOf(sTemp))
		ElseIf pGlobalTypes->Contains(sTemp) Then
			te = pGlobalTypes->Object(pGlobalTypes->IndexOf(sTemp))
		ElseIf pGlobalNamespaces->Contains(sTemp) Then
			te = pGlobalNamespaces->Object(pGlobalNamespaces->IndexOf(sTemp))
		ElseIf TypeName <> "" Then
			If tb->Types.Contains(TypeName) Then
				'teEnumOld = tb->Types.Object(tb->Types.IndexOf(TypeName))
				tb->FillIntellisense TypeName, @tb->Types, True
			ElseIf tb->Enums.Contains(TypeName) Then
				tb->FillIntellisense TypeName, @tb->Enums, True
			ElseIf pComps->Contains(TypeName) Then
				tb->FillIntellisense TypeName, pComps, True
			ElseIf pGlobalTypes->Contains(TypeName) Then
				tb->FillIntellisense TypeName, pGlobalTypes, True
			ElseIf pGlobalEnums->Contains(TypeName) Then
				tb->FillIntellisense TypeName, pGlobalEnums, True
			ElseIf pGlobalNamespaces->Contains(TypeName) Then
				tb->FillIntellisense TypeName, pGlobalNamespaces, True
			End If
			If FListItems.Contains(sTemp) Then
				te = FListItems.Object(FListItems.IndexOf(sTemp))
				OldTypeName = TypeName
			End If
			FListItems.Clear
		End If
	End If
	If te <> 0 Then
		sTemp = te->TypeName
		If te->ElementType = "Namespace" OrElse te->ElementType = "Type" OrElse te->ElementType = "TypeCopy" OrElse te->ElementType = "Union" OrElse te->ElementType = "Enum" Then
			sTemp = te->Name
		Else
			Pos1 = InStrRev(sTemp, ".")
			If Pos1 > 0 Then sTemp = Mid(sTemp, Pos1 + 1)
		End If
		If sTemp = "" AndAlso te->Value <> "" Then
			sTemp = GetTypeFromValue(tb, te->Value)
		End If
	End If
	teEnum = te
	Return sTemp
End Function

Sub OnSelChangeEdit(ByRef Sender As Control, ByVal CurrentLine As Integer, ByVal CurrentCharIndex As Integer)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
	tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	pstBar->Panels[1]->Caption = ML("Row") + " " + WStr(iSelEndLine + 1) + " : " + WStr(tb->txtCode.LinesCount) + WSpace(2) + _
		ML("Column") + " " + WStr(iSelEndChar) + " : " + WStr(Len(tb->txtCode.Lines(iSelEndLine))) + WSpace(2) + _
		ML("Selection") + " " + WStr(Len(tb->txtCode.SelText))
	If Not tb->txtCode.ToolTipShowed Then Exit Sub
	Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
	Dim As WStringList ParametersList
	Dim As String sWord, Symb, FuncName, Parameters, Parameter, Link1, Param
	Dim As UString Lines(Any), Params(Any), LinkParse(Any)
	Dim As Integer iCount, iPos, iPos1, iPos2, n, iParamCount, iSelEndCharFunc
	Dim As Boolean bStarted, bQuotation
	Parameters = tb->txtCode.Hint
	Split Parameters, !"\r", Lines()
	iSelEndCharFunc = iSelEndChar
	For i As Integer = iSelEndChar To 1 Step -1
		Symb = Mid(*sLine, i, 1)
		If Symb = "(" Then
			If iCount = 0 Then
				iSelEndCharFunc = i - 1
				Exit For
			Else
				iCount -= 1
				bStarted = False
			End If
		ElseIf Symb = ")" Then
			iCount += 1
			bStarted = False
		ElseIf Symb = """" Then
			bQuotation = Not bQuotation
		ElseIf Not bQuotation AndAlso iCount = 0 Then
			If Symb = " " OrElse Symb = !"\t" Then
				bStarted = True
			ElseIf Symb = "," Then
				iParamCount += 1
				bStarted = False
			ElseIf Not IsArg(Asc(Symb)) Then
				bStarted = False
			ElseIf i > 4 AndAlso (LCase(Mid(*sLine, i - 5, 6)) = " byval" OrElse LCase(Mid(*sLine, i - 5, 6)) = " byref") Then
				bStarted = False
			ElseIf bStarted Then
				iSelEndCharFunc = i
				Exit For
			End If
		End If
	Next
	sWord = tb->txtCode.HintWord
	If tb->txtCode.GetWordAt(iSelEndLine, iSelEndCharFunc - 2) <> sWord Then Exit Sub
	For i As Integer = 0 To UBound(Lines)
		iPos = InStr(Lines(i), "<a href=""")
		iPos1 = InStr(Lines(i), """>")
		iPos2 = InStr(Lines(i), "</a>")
		Link1 = Mid(Lines(i), iPos + 9, iPos1 - iPos - 9)
		Split Link1, "#", LinkParse()
		If UBound(LinkParse) < 2 Then Continue For
		Lines(i) = Left(Lines(i), iPos - 1) & LinkParse(2) & Mid(Lines(i), iPos2 + 4)
		Split Lines(i), ",", Params()
		For j As Integer = 0 To UBound(Params)
			iPos = InStr(Params(j), "(")
			iPos1 = InStr(Params(j), ")")
			If j = 0 AndAlso ((iSelEndChar = iSelEndCharFunc AndAlso iParamCount = 0) OrElse (iPos = 0 AndAlso UBound(Params) = 0) OrElse (iParamCount - 1 >= UBound(Params))) Then
				iPos = InStr(LCase(Params(j)), LCase(sWord))
				If iPos > 0 Then
					sWord = Mid(Params(j), iPos, Len(sWord))
					Params(j) = Left(Params(j), iPos - 1) & "<a href=""" & LinkParse(0) & "#" & LinkParse(1) & "#" & sWord & """>" & sWord & "</a>" & Mid(Params(j), iPos + Len(sWord))
				End If
			ElseIf iParamCount = j Then
				n = Len(Params(j)) - Len(LTrim(Params(j)))
				If iPos1 = 0 Then iPos1 = Len(Params(j)) + 1
				If j = 0 AndAlso iPos > 0 Then
					Param = Mid(Params(j), iPos + 1, iPos1 - iPos - 1)
					Params(j) = Left(Params(j), iPos) & "<a href=""" & LinkParse(0) & "#" & LinkParse(1) & "#" & GetCorrectParam(Param) & """>" &  Param & "</a>" & Mid(Params(j), iPos1)
				ElseIf iParamCount = UBound(Params) Then
					If iPos1 = 0 Then iPos1 = Len(Params(j)) + 1
					Param = Left(Params(j), iPos1 - 1)
					Params(j) = WString(n, " ") & "<a href=""" & LinkParse(0) & "#" & LinkParse(1) & "#" & GetCorrectParam(Param) & """>" & LTrim(Param) & "</a>" & Mid(Params(j), iPos1)
				ElseIf iParamCount < UBound(Params) Then
					Params(j) = WString(n, " ") & "<a href=""" & LinkParse(0) & "#" & LinkParse(1) & "#" & GetCorrectParam(Params(j)) & """>" &  LTrim(Params(j)) & "</a>"
				End If
			End If
		Next
		Lines(i) = Join(Params(), ",")
	Next
	Dim As UString JoinedHint = Join(Lines(), !"\r")
	If JoinedHint <> tb->txtCode.Hint Then
		tb->txtCode.Hint = JoinedHint
		tb->txtCode.UpdateToolTip
	End If
End Sub

Sub OnKeyPressEdit(ByRef Sender As Control, Key As Byte)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If CInt(Key = Asc(".")) OrElse CInt(Key = Asc(">")) Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		k = 1
		If Key = Asc(">") Then
			If Mid(*sLine, iSelEndChar - 1, 1) <> "-" Then Exit Sub
			k = 2
		End If
		Dim As String TypeName = GetLeftArgTypeName(tb, iSelEndLine, iSelEndChar - k)
		FillIntellisenseByName TypeName
		#ifdef __USE_GTK__
			If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then Exit Sub
		#else
			If tb->txtCode.cboIntellisense.Items.Count = 0 Then Exit Sub
		#endif
		SelLinePos = iSelEndLine
		SelCharPos = iSelEndChar
		FindComboIndex tb, *sLine, iSelEndChar
		tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
	ElseIf CInt(Key = Asc("=")) Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		Dim As TypeElement Ptr teEnum
		Dim As String TypeName = GetLeftArgTypeName(tb, iSelEndLine, Len(RTrim(Left(*sLine, iSelEndChar - 1))), teEnum)
		#ifdef __USE_GTK__
			tb->txtCode.lvIntellisense.ListItems.Clear
		#else
			tb->txtCode.cboIntellisense.Items.Clear
		#endif
		Dim As TypeElement Ptr te
		If TypeName = "" Then
			Exit Sub
		ElseIf TypeName = "Boolean" Then
			AddSorted tb, GetKeyWordCase("False")
			AddSorted tb, GetKeyWordCase("True")
		ElseIf tb->Enums.Contains(TypeName) Then
			te = tb->Enums.Object(tb->Enums.IndexOf(TypeName))
			If te <> 0 Then
				For i As Integer = 0 To te->Elements.Count - 1
					AddSorted tb, IIf(te->Name = "", "", te->Name & ".") & te->Elements.Item(i), te->Elements.Object(i)
				Next
			End If
		ElseIf pGlobalEnums->Contains(TypeName) Then
			te = pGlobalEnums->Object(pGlobalEnums->IndexOf(TypeName))
			If te <> 0 Then
				For i As Integer = 0 To te->Elements.Count - 1
					AddSorted tb, IIf(te->Name = "", "", te->Name & ".") & te->Elements.Item(i), te->Elements.Object(i)
				Next
			End If
		ElseIf CInt(teEnum <> 0) AndAlso CInt(teEnum->EnumTypeName <> "") AndAlso CInt(pGlobalEnums->Contains(teEnum->EnumTypeName)) Then
			te = pGlobalEnums->Object(pGlobalEnums->IndexOf(teEnum->EnumTypeName))
			If te <> 0 Then
				For i As Integer = 0 To te->Elements.Count - 1
					AddSorted tb, IIf(te->Name = "", "", te->Name & ".") & te->Elements.Item(i), te->Elements.Object(i)
				Next
			End If
		Else
			Exit Sub
		End If
		If iSelEndChar = Len(*sLine) Then tb->txtCode.ReplaceLine iSelEndLine, *sLine & " "
		SelLinePos = iSelEndLine
		SelCharPos = iSelEndChar + 1
		FindComboIndex tb, *sLine, iSelEndChar + 1
		#ifdef __USE_GTK__
			If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
		#endif
		tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
	ElseIf CInt(Key = Asc(" ")) OrElse CInt(Key = Asc("(")) OrElse CInt(Key = Asc(",")) Then
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		If CInt(Key = Asc(" ")) AndAlso (CInt(EndsWith(RTrim(LCase(Left(*sLine, iSelEndChar))), " as")) OrElse _
				CInt(EndsWith(RTrim(LCase(Left(*sLine, iSelEndChar))), !"\tas"))OrElse _
				CInt(RTrim(LCase(Left(*sLine, iSelEndChar))) = "as")) Then
			FillTypeIntellisenses
			SelLinePos = iSelEndLine
			SelCharPos = iSelEndChar
			FindComboIndex tb, *sLine, iSelEndChar
			#ifdef __USE_GTK__
				If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
			#endif
			tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
		Else
			Dim As WStringList ParametersList
			Dim As String sWord, Symb, FuncName, Parameters, Parameter, Link1
			Dim As UString Comments
			Dim As Integer iCount, iPos
			Dim As Boolean bStarted, bQuotation
			If Key = Asc(",") Then
				If tb->txtCode.ToolTipShowed Then Exit Sub
				For i As Integer = iSelEndChar To 1 Step -1
					Symb = Mid(*sLine, i, 1)
					If Symb = "(" Then
						If iCount = 0 Then
							iSelEndChar = i + 1
							Exit For
						Else
							iCount -= 1
							bStarted = False
						End If
					ElseIf Symb = ")" Then
						iCount += 1
						bStarted = False
					ElseIf Symb = """" Then
						bQuotation = Not bQuotation
					ElseIf Not bQuotation AndAlso iCount = 0 Then
						If Symb = " " OrElse Symb = !"\t" Then
							bStarted = True
						ElseIf Not IsArg(Asc(Symb)) Then
							bStarted = False
						ElseIf i > 4 AndAlso (LCase(Mid(*sLine, i - 5, 6)) = " byval" OrElse LCase(Mid(*sLine, i - 5, 6)) = " byref") Then
							bStarted = False
						ElseIf bStarted Then
							iSelEndChar = i + 1
							Exit For
						End If
					End If
				Next
			End If
			sWord = tb->txtCode.GetWordAt(iSelEndLine, iSelEndChar - 2)
			Dim As TypeElement Ptr te, teOld
			Dim As Integer Index
			Dim As String TypeName
			If sWord = "" Then Exit Sub
			TypeName = GetLeftArgTypeName(tb, iSelEndLine, iSelEndChar - 1, te, teOld)
			If teOld <> 0 AndAlso teOld->TypeName <> "" Then
				TypeName = teOld->TypeName
				FListItems.Clear
				If tb->Types.Contains(TypeName) Then
					tb->FillIntellisense TypeName, @tb->Types, True, True
				ElseIf tb->Enums.Contains(TypeName) Then
					tb->FillIntellisense TypeName, @tb->Enums, True, True
				ElseIf pComps->Contains(TypeName) Then
					tb->FillIntellisense TypeName, pComps, True, True
				ElseIf pGlobalTypes->Contains(TypeName) Then
					tb->FillIntellisense TypeName, pGlobalTypes, True, True
				ElseIf pGlobalEnums->Contains(TypeName) Then
					tb->FillIntellisense TypeName, pGlobalEnums, True, True
				End If
				Index = FListItems.IndexOf(sWord)
				If Index > -1 Then
					For i As Integer = Index To FListItems.Count - 1
						te = FListItems.Object(i)
						If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
							Parameter = te->Parameters
							iPos = InStr(LCase(Parameter), LCase(sWord))
							FuncName = Mid(Parameter, iPos, Len(sWord))
							Link1 = te->FileName & "#" & te->StartLine & "#" & FuncName
							ParametersList.Add te->Parameters
							Parameters &= IIf(Parameters = "", "", !"\r") & Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
							If te->Comment <> "" Then Comments &= te->Comment
						End If
					Next
				End If
			Else
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
					Parameter = te->Parameters
					iPos = InStr(LCase(Parameter), LCase(sWord))
					FuncName = Mid(Parameter, iPos, Len(sWord))
					Link1 = te->FileName & "#" & te->StartLine & "#" & FuncName
					ParametersList.Add te->Parameters
					Parameters &= Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
					If te->Comment <> "" Then Comments &= te->Comment
				End If
				Index = tb->Functions.IndexOf(sWord)
				If Index > -1 Then
					For i As Integer = Index To tb->Procedures.Count - 1
						te = tb->Procedures.Object(i)
						If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
							Parameter = te->Parameters
							iPos = InStr(LCase(Parameter), LCase(sWord))
							FuncName = Mid(Parameter, iPos, Len(sWord))
							Link1 = te->FileName & "#" & te->StartLine & "#" & FuncName
							ParametersList.Add te->Parameters
							Parameters &= IIf(Parameters = "", "", !"\r") & Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & FuncName & "</a>" & Mid(Parameter, iPos + Len(sWord))
							If te->Comment <> "" Then Comments &= te->Comment
						End If
					Next
				End If
				Index = pGlobalFunctions->IndexOf(sWord)
				If Index > -1 Then
					For i As Integer = Index To pGlobalFunctions->Count - 1
						te = pGlobalFunctions->Object(i)
						If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) AndAlso CInt(Not ParametersList.Contains(te->Parameters)) Then
							Parameter = te->Parameters
							iPos = InStr(LCase(Parameter), LCase(sWord))
							FuncName = Mid(Parameter, iPos, Len(sWord))
							Link1 = te->FileName & "#" & te->StartLine & "#" & FuncName
							ParametersList.Add te->Parameters
							Parameters &= IIf(Parameters = "", "", !"\r") & Left(Parameter, iPos - 1) & "<a href=""" & Link1 & """>" & Mid(Parameter, iPos, Len(sWord)) & "</a>" & Mid(Parameter, iPos + Len(sWord))
							If te->Comment <> "" Then Comments &= te->Comment
						End If
					Next
				End If
			End If
			If Parameters <> "" Then
				tb->txtCode.HintWord = sWord
				tb->txtCode.Hint = Parameters & IIf(Comments <> "", !"\r_________________\r" & Comments, "")
				tb->txtCode.ShowToolTipAt(iSelEndLine, iSelEndChar - Len(sWord) - 1)
				OnSelChangeEdit(Sender, iSelEndLine, iSelEndChar)
			End If
		End If
	ElseIf tb->txtCode.DropDownShowed Then
		#ifdef __USE_GTK__
			If Key = GDK_KEY_Home OrElse Key = GDK_KEY_End OrElse Key = GDK_KEY_Left OrElse Key = GDK_KEY_Right OrElse _
				Key = GDK_KEY_Escape OrElse Key = GDK_KEY_Escape OrElse Key = GDK_KEY_UP OrElse Key = GDK_KEY_DOWN OrElse _
				Key = GDK_KEY_Page_Up OrElse Key = GDK_KEY_Page_Down Then
				Exit Sub
			End If
		#endif
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
		If EndsWith(RTrim(Left(LCase(*sLine), tb->txtCode.DropDownChar)), " as") Then
			FillTypeIntellisenses Mid(*sLine, tb->txtCode.DropDownChar + 1)
		ElseIf EndsWith(Left(*sLine, tb->txtCode.DropDownChar), ".") Then
			'FillIntellisenseByName GetLeftArg(tb, iSelEndLine, tb->txtCode.DropDownChar - 1)
		ElseIf EndsWith(Left(*sLine, tb->txtCode.DropDownChar), "->") Then
			'FillIntellisenseByName GetLeftArg(tb, iSelEndLine, tb->txtCode.DropDownChar - 2)
		Else
			FillAllIntellisenses Mid(*sLine, tb->txtCode.DropDownChar + 1)
		End If
		FindComboIndex tb, *sLine, tb->txtCode.DropDownChar
		#ifdef __USE_GTK__
			If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
		#else
			If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.cboIntellisense.ItemIndex = -1
		#endif
	End If
End Sub

Sub TabWindow.FormDesign(NotForms As Boolean = False)
	On Error Goto ErrorHandler
	pfrmMain->UpdateLock
	bNotDesign = True
	Dim SelControlName As String
	Dim SelControlNames As WStringList
	Dim bSelControlFind As Boolean
	If CInt(NotForms = False) AndAlso CInt(Des) Then
		With *Des
			If .SelectedControl <> 0 Then SelControlName = WGet(.ReadPropertyFunc(.SelectedControl, "Name"))
			For j As Integer = 0 To .SelectedControls.Count - 1
				If .SelectedControls.Items[j] <> 0 Then SelControlNames.Add WGet(.ReadPropertyFunc(.SelectedControls.Items[j], "Name"))
			Next
			.SelectedControls.Clear
			.Objects.Clear
			.Controls.Clear
			If .SelectedControl = .DesignControl Then bSelControlFind = True
			If .DesignControl Then
				.UnHook
				If iGet(.ReadPropertyFunc(.DesignControl, "ControlCount")) > 0 Then
					For i As Integer = iGet(.ReadPropertyFunc(.DesignControl, "ControlCount")) - 1 To 0 Step -1
						If .RemoveControlSub AndAlso .ControlByIndexFunc Then .RemoveControlSub(.DesignControl, .ControlByIndexFunc(.DesignControl, i))
					Next i
				End If
				For i As Integer = 2 To cboClass.Items.Count - 1
					CurCtrl = 0
					CBItem = cboClass.Items.Item(i)
					If CBItem <> 0 Then CurCtrl = CBItem->Object
					If CurCtrl <> 0 Then
						'TODO Hange here with ctrl RichEdit
							If WGet(.ReadPropertyFunc(CurCtrl, "ClassName"))<>"RichTextBox" Then
								If .ReadPropertyFunc(CurCtrl, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, .ReadPropertyFunc(CurCtrl, "Tag")))
								.DeleteComponentFunc(CurCtrl)
							Else
								''Delete the last one not current one. But still one more remain exist
								If CurCtrlRichedit <> 0 Then 
									If .ReadPropertyFunc(CurCtrlRichedit, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, .ReadPropertyFunc(CurCtrlRichedit, "Tag")))
									.DeleteComponentFunc(CurCtrlRichedit) 
								End If
								CurCtrlRichedit = CurCtrl
							End If
					End If
				Next i
				.Hook
			End If
		End With
	End If
	If CInt(NotForms = False) Then
		cboClass.Items.Clear
		cboClass.Items.Add "(" & ML("General") & ")" & Chr(0), , "DropDown", "DropDown"
		cboClass.ItemIndex = 0
	End If
	Dim As TypeElement Ptr te, func
	For i As Integer = Functions.Count - 1 To 0 Step -1
		te = Functions.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			Delete_( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		Delete_( Cast(TypeElement Ptr, Functions.Object(i)))
	Next
	For i As Integer = FunctionsOthers.Count - 1 To 0 Step -1
		Delete_( Cast(TypeElement Ptr, FunctionsOthers.Object(i)))
	Next
	For i As Integer = Args.Count - 1 To 0 Step -1
		Delete_( Cast(TypeElement Ptr, Args.Object(i)))
	Next
	Functions.Clear
	FunctionsOthers.Clear
	Types.Clear
	Procedures.Clear
	Args.Clear
	'ThreadCreate(@LoadFromTabWindow, @This)
	'LoadFunctions FileName, OnlyFilePath, Types, Procedures, Args, @txtCode
	t = False
	Var bT = False
	c = False
	txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As Integer iStart, iEnd, CtrlArrayNum, Pos1, Pos2, Pos3, Pos4, Pos5, n, inPubPriPro = 0, ConstructionIndex = -1, ConstructionPart
	Dim ptxtCode As EditControl Ptr = 0
	Dim As Boolean bFind, bTrue = True
	Dim WithArgs As WStringList
	Dim ConstructionBlocks As List
	Dim As UString Comments, b, bTrim, bTrimLCase
	Dim As Boolean IsBas = EndsWith(LCase(FileName), ".bas") OrElse EndsWith(LCase(FileName), ".frm"), inFunc
	Dim FileEncoding As FileEncodings, NewLineType As NewLineTypes
	If IsBas Then
		WLet(FLine1, Left(FileName, Len(FileName) - 4) & ".bi")
		WLetEx FLine2, GetFileName(*FLine1), True
	Else
		WLet(FLine1, "")
		WLet(FLine2, "")
	End If
	For j As Integer = 0 To txtCode.LinesCount - 1
		If Not bFind AndAlso NotForms = False AndAlso IsBas AndAlso StartsWith(LTrim(LCase(txtCode.Lines(j)), Any !"\t "), "#include once """ & LCase(*FLine2) & """") Then
			Var tb = GetTab(*FLine1)
			If tb = 0 Then
				txtCodeBi.LoadFromFile *FLine1, FileEncoding, NewLineType
				ptxtCode = @txtCodeBi
			Else
				ptxtCode = @tb->txtCode
			End If
			bFind = True
			iStart = 0
			iEnd = ptxtCode->LinesCount - 1
		Else
			ptxtCode = @txtCode
			iStart = j
			iEnd = j
		End If
		For i As Integer = iStart To iEnd
			ECLine = ptxtCode->FLines.Items[i]
			WLet(FLine, *ECLine->Text)
			b = *ECLine->Text
			bTrim = Trim(b, Any !"\t ")
			bTrimLCase = LCase(bTrim)
'			ECLine->InConstructionIndex = ConstructionIndex
'			ECLine->InConstructionPart = ConstructionPart
'			If ECLine->ConstructionIndex > 0 AndAlso ECLine->ConstructionIndex <> 1 AndAlso ECLine->ConstructionIndex <> 2 AndAlso ECLine->ConstructionIndex <> 3 Then
'				If ECLine->ConstructionPart = 0 Then
'					ConstructionIndex = ECLine->ConstructionIndex
'					ConstructionBlocks.Add ECLine
'				ElseIf ECLine->ConstructionPart = 1 Then
'					ConstructionPart = ECLine->ConstructionPart
'				ElseIf ECLine->ConstructionPart = 2 Then
'					If ConstructionBlocks.Count > 0 Then
'						ECLIne2 = ConstructionBlocks.Items[ConstructionBlocks.Count - 1]
'						If ECLine2->ConstructionIndex <> ECLine->ConstructionIndex AndAlso ECLine2->ConstructionIndex <> 3 AndAlso ECLine2->ConstructionIndex <> 2 Then
'							' Does not match construction blocks
'						Else
'							ConstructionBlocks.Remove ConstructionBlocks.Count - 1
'							If ConstructionBlocks.Count > 0 Then
'								ECLIne2 = ConstructionBlocks.Items[ConstructionBlocks.Count - 1]
'								ConstructionIndex = ECLIne2->ConstructionIndex
'								ConstructionPart = 0
'							Else
'								ConstructionIndex = -1
'								ConstructionPart = 0
'							End If
'						End If
'					Else
'						' Do not found construction index
'					End If
'				End If
'			End If
			If StartsWith(Trim(bTrim), "'") Then
				Comments &= Mid(Trim(bTrim), 2) & Chr(13) & Chr(10)
				Continue For
			ElseIf Trim(bTrim) = "" Then
				Comments = ""
				Continue For
			End If
			If StartsWith(bTrimLCase, "#include ") Then
				#ifndef __USE_GTK__
					Pos1 = InStr(b, """")
					If Pos1 > 0 Then
						Pos2 = InStr(Pos1 + 1, b, """")
						WLetEx FPath, GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), FileName), True
						If Not pLoadPaths->Contains(*FPath) Then
							pLoadPaths->Add *FPath
							ThreadCreate(@LoadFunctionsSub, @pLoadPaths->Item(pLoadPaths->Count - 1))
						End If
					End If
				#endif
			ElseIf ECLine->ConstructionIndex >=0 AndAlso Constructions(ECLine->ConstructionIndex).Accessible Then
				If ECLine->ConstructionPart = 0 Then
					Pos1 = 0
					Pos2 = 0
					l = 0
					inPubPriPro = 0
					inFunc = True
					Pos1 = InStr(" " & bTrimLCase, " " & LCase(Constructions(ECLine->ConstructionIndex).Name0) & " ")
					If Pos1 > 0 Then
						l = Len(Trim(Constructions(ECLine->ConstructionIndex).Name0)) + 1
						Pos4 = Pos1 + l
						Pos2 = InStr(Pos1 + l, bTrim, "(")
						Pos5 = Pos2
						If Pos2 = 0 Then Pos2 = InStr(Pos1 + l, bTrim, " ")
						te = New_( TypeElement)
						If Pos2 > 0 Then
							te->Name = Trim(Mid(bTrim, Pos1 + l, Pos2 - Pos1 - l))
						Else
							te->Name = Trim(Mid(bTrim, Pos1 + l))
						End If
						If ECLine->ConstructionIndex = 19 Then
							If EndsWith(bTrim, ")") Then
								te->DisplayName = te->Name & " [Let]"
							Else
								te->DisplayName = te->Name & " [Get]"
							End If
						ElseIf CInt(ECLine->ConstructionIndex >= 14 AndAlso ECLine->ConstructionIndex <= 16) OrElse CInt(ECLine->ConstructionIndex >= 20 AndAlso ECLine->ConstructionIndex <= 22) Then
							te->DisplayName = te->Name & " [" & Trim(Constructions(ECLine->ConstructionIndex).Name0) & "]"
						Else
							te->DisplayName = te->Name
						End If
						Pos1 = InStr(te->Name, ".")
						If Pos1 > 0 Then te->Name = Mid(te->Name, Pos1 + 1)
						Pos2 = InStr(bTrim, ")")
						If ECLine->ConstructionIndex = 21 OrElse ECLine->ConstructionIndex = 22 Then
							te->TypeName = te->Name
							te->Parameters = te->Name & IIf(Pos5 > 0, Mid(bTrim, Pos5), "()")
						Else
							te->Parameters = Mid(bTrim, Pos4 + Pos1)
							Pos3 = InStr(Pos2, bTrimLCase, ")as ")
							If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
							If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " extends "): If Pos3 > 0 Then Pos3 += 5
							If Pos3 = 0 Then Pos3 = Len(b)
							te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
							Pos4 = InStr(te->TypeName, "'")
							If Pos4 > 0 Then
								te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
							End If
							te->TypeName = WithoutPointers(te->TypeName)
						End If
						te->ElementType = Trim(Constructions(ECLine->ConstructionIndex).Name0)
						te->StartLine = i
						te->TabPtr = @This
						te->FileName = FileName
						If Comments <> "" Then te->Comment = Comments: Comments = ""
						Functions.Add te->DisplayName, te
						If ECLine->ConstructionIndex = 14 Then
							Enums.Add te->Name, te
						ElseIf ECLine->ConstructionIndex = 15 OrElse ECLine->ConstructionIndex = 16 Then
							Types.Add te->Name, te
						Else
							Procedures.Add te->Name, te
						End If
						func = te
						If Pos2 > 0 AndAlso Pos5 > 0 Then
							Dim As UString CurType, res1(Any), ElementValue
							Split GetChangedCommas(Mid(bTrim, Pos5 + 1, Pos2 - Pos5 - 1)), ",", res1()
							For n As Integer = 0 To UBound(res1)
								res1(n) = Replace(res1(n), ";", ",")
								Pos1 = InStr(res1(n), "=")
								If Pos1 > 0 Then
									ElementValue = Trim(Mid(res1(n), Pos1 + 1))
								Else
									ElementValue = ""
								End If
								If Pos1 > 0 Then res1(n) = Trim(Left(res1(n), Pos1 - 1))
								Pos1 = InStr(LCase(res1(n)), " as ")
								If Pos1 > 0 Then
									CurType = Trim(Mid(res1(n), Pos1 + 4))
									res1(n) = Trim(Left(res1(n), Pos1 - 1))
								End If
								If res1(n).ToLower.StartsWith("byref") OrElse res1(n).ToLower.StartsWith("byval") Then
									res1(n) = Trim(Mid(res1(n), 6))
								End If
								Pos1 = InStr(res1(n), "(")
								If Pos1 > 0 Then
									res1(n) = Trim(Left(res1(n), Pos1 - 1))
								End If
								res1(n) = res1(n).TrimAll
								Pos1 = InStrRev(CurType, ".")
								If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
								Var te = New_( TypeElement)
								te->Name = res1(n)
								te->DisplayName = res1(n)
								te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
								te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
								te->TypeName = CurType
								te->TypeName = WithoutPointers(te->TypeName)
								te->Value = ElementValue
								te->Locals = 0
								te->StartLine = i
								te->EndLine = i
								te->Parameters = res1(n) & " As " & CurType
								te->FileName = FileName
								func->Elements.Add te->Name, te
							Next
						End If
					End If
				ElseIf ECLine->ConstructionPart = 2 Then
					If Functions.Count > 0 Then Cast(TypeElement Ptr, Functions.Object(Functions.Count - 1))->EndLine = i: inFunc = False
				End If
			ElseIf StartsWith(bTrimLCase & " ", "public: ") Then
				inPubPriPro = 0
			ElseIf StartsWith(bTrimLCase & " ", "private: ") Then
				inPubPriPro = 1
			ElseIf StartsWith(bTrimLCase & " ", "protected: ") Then
				inPubPriPro = 2
			ElseIf StartsWith(bTrimLCase & " ", "#define ") Then
				Pos1 = InStr(9, bTrim, " ")
				Pos2 = InStr(9, bTrim, "(")
				If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
				te = New_( TypeElement)
				If Pos1 = 0 Then
					te->Name = Trim(Mid(bTrim, 9))
				Else
					te->Name = Trim(Mid(bTrim, 9, Pos1 - 9))
				End If
				te->DisplayName = te->Name
				te->ElementType = "#Define"
				te->Parameters = bTrim
				Pos4 = InStr(te->Parameters, "'")
				If Pos4 > 0 Then
					te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
				End If
				te->StartLine = i
				te->EndLine = i
				If Comments <> "" Then te->Comment = Comments: Comments = ""
				te->FileName = FileName
				FunctionsOthers.Add te->DisplayName, te
				Procedures.Add te->Name, te
			ElseIf StartsWith(bTrimLCase, "declare ") Then
				Pos1 = InStr(9, bTrim, " ")
				Pos3 = InStr(9, bTrim, "(")
				'n = Len(Trim(*FLine)) - Len(Trim(Mid(Trim(*FLine), Pos1)))
				If StartsWith(Trim(Mid(bTrimLCase, 9), Any !"\t "), "static ") Then
					Pos1 = InStr(Pos1 + 1, bTrim, " ")
				End If
				Pos4 = InStr(Pos1 + 1, bTrim, " ")
				If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
				Pos4 = InStr(bTrim, "(")
				If Pos4 > 0 AndAlso (Pos4 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos4
				te = New_( TypeElement)
				te->Declaration = True
				If Pos1 = 0 Then
					te->ElementType = Trim(Mid(bTrim, 9))
				Else
					te->ElementType = Trim(Mid(bTrim, 9, Pos1 - 9))
				End If
				If inFunc AndAlso func <> 0 AndAlso (LCase(te->ElementType) = "constructor" OrElse LCase(te->ElementType) = "destructor") Then
					te->Name = func->Name
					te->DisplayName = func->Name & " [" & te->ElementType & "] [Declare]"
					te->TypeName = func->Name
					te->Parameters = te->Name & IIf(Pos4 > 0, Mid(bTrim, Pos4), "()")
				Else
					If Pos3 = 0 Then
						te->Name = Trim(Mid(bTrim, Pos1))
					Else
						te->Name = Trim(Mid(bTrim, Pos1, Pos3 - Pos1))
					End If
					If LCase(te->ElementType) = "property" Then
						If EndsWith(bTrim, ")") Then
							te->DisplayName = te->Name & " [Let] [Declare]"
						Else
							te->DisplayName = te->Name & " [Get] [Declare]"
						End If
					Else
						te->DisplayName = te->Name & " [Declare]"
					End If
					te->Parameters = Trim(Mid(bTrim, Pos1))
					If inFunc AndAlso func <> 0 Then te->DisplayName = func->Name & "." & te->DisplayName
					Pos2 = InStr(bTrim, ")")
					Pos3 = InStr(Pos2, bTrimLCase, ")as ")
					If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
					If Pos3 = 0 Then
						te->TypeName = ""
					Else
						te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
					End If
					Pos4 = InStr(te->TypeName, "'")
					If Pos4 > 0 Then
						te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
					End If
					te->TypeName = WithoutPointers(te->TypeName)
				End If
				te->StartLine = i
				te->EndLine = i
				te->TabPtr = @This
				te->FileName = FileName
				If Comments <> "" Then te->Comment = Comments: Comments = ""
				If inFunc AndAlso func <> 0 AndAlso LCase(te->ElementType) <> "constructor" AndAlso LCase(te->ElementType) <> "destructor" Then
					func->Elements.Add te->Name, te
				Else
					FunctionsOthers.Add te->DisplayName, te
					Procedures.Add te->Name, te
				End If
			Else
				If CInt(StartsWith(bTrimLCase, "as ")) OrElse _
					CInt(InStr(bTrimLCase, " as ")) OrElse _
					CInt(StartsWith(bTrimLCase, "const ")) OrElse _
					CInt(StartsWith(bTrimLCase, "var ")) Then
					Dim As UString b2 = bTrim
					If b2.ToLower.StartsWith("dim ") OrElse b2.ToLower.StartsWith("static ") OrElse b2.ToLower.StartsWith("var ") OrElse b2.ToLower.StartsWith("const ") OrElse b2.ToLower.StartsWith("common ") Then
						b2 = Trim(Mid(bTrim, InStr(bTrim, " ")))
					End If
					Dim As UString CurType, ElementValue
					Dim As UString res1(Any)
					Dim As Boolean bShared
					Pos1 = InStr(b2, "'")
					If Pos1 > 0 Then b2 = Trim(Left(b2, Pos1 - 1))
					If b2.ToLower.StartsWith("shared ") Then bShared = True: b2 = Trim(Mid(b2, 7))
					If b2.ToLower.StartsWith("as ") Then
						CurType = Trim(Mid(b2, 4))
						Pos1 = InStr(CurType, " ")
						Pos2 = InStr(CurType, " Ptr ")
						Pos3 = InStr(CurType, " Pointer ")
						If Pos2 > 0 Then
							Pos1 = Pos2 + 4
						ElseIf Pos3 > 0 Then
							Pos1 = Pos2 + 8
						End If
						If Pos1 > 0 Then
							Split GetChangedCommas(Mid(CurType, Pos1 + 1)), ",", res1()
							CurType = Left(CurType, Pos1 - 1)
						End If
					Else
						Split GetChangedCommas(b2), ",", res1()
					End If
					For n As Integer = 0 To UBound(res1)
						res1(n) = Replace(res1(n), ";", ",")
						Pos1 = InStr(res1(n), "=")
						If Pos1 > 0 Then
							ElementValue = Trim(Mid(res1(n), Pos1 + 1))
						Else
							ElementValue = ""
						End If
						If Pos1 > 0 Then res1(n) = Trim(Left(res1(n), Pos1 - 1))
						Pos1 = InStr(LCase(res1(n)), " as ")
						If Pos1 > 0 Then
							CurType = Trim(Mid(res1(n), Pos1 + 4))
							res1(n) = Trim(Left(res1(n), Pos1 - 1))
						End If
						If res1(n).ToLower.StartsWith("byref") OrElse res1(n).ToLower.StartsWith("byval") Then
							res1(n) = Trim(Mid(res1(n), 6))
						End If
						Pos1 = InStr(res1(n), "(")
						If Pos1 > 0 Then
							res1(n) = Trim(Left(res1(n), Pos1 - 1))
						End If
						res1(n) = res1(n).TrimAll
						Pos1 = InStrRev(CurType, ".")
						If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
						Var te = New_( TypeElement)
						te->Name = res1(n)
						te->DisplayName = res1(n)
						te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
						te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
						te->TypeName = CurType
						te->TypeName = WithoutPointers(te->TypeName)
						te->Value = ElementValue
						If inFunc Then
							te->Locals = inPubPriPro
						Else
							te->Locals = IIf(bShared, 0, 1)
						End If
						te->StartLine = i
						te->EndLine = i
						te->Parameters = res1(n) & " As " & CurType
						te->FileName = FileName
						te->TabPtr = @This
						If inFunc AndAlso func <> 0 Then func->Elements.Add te->Name, te Else Args.Add te->Name, te
					Next
				End If
			End If
			If CInt(NotForms = False) AndAlso CInt(Not b) AndAlso CInt(ECLine->ConstructionIndex = 15) AndAlso _
				CInt((EndsWith(Trim(LCase(*FLine), Any !"\t "), " extends form") OrElse (EndsWith(Trim(LCase(*FLine),  Any !"\t "), " extends form '...'")))) OrElse _
				CInt((EndsWith(Trim(LCase(*FLine), Any !"\t "), " extends usercontrol") OrElse (EndsWith(Trim(LCase(*FLine),  Any !"\t "), " extends usercontrol '...'")))) Then
				If Des = 0 Then
					Visible = True
					pnlForm.Visible = True
					splForm.Visible = True
					If Not tbrTop.Buttons.Item(3)->Checked Then tbrTop.Buttons.Item(3)->Checked = True
					#ifndef __USE_GTK__
						If pnlForm.Handle = 0 Then pnlForm.CreateWnd
					#endif
					
					Des = New_( My.Sys.Forms.Designer(pnlForm))
					If Des = 0 Then bNotDesign = False: pfrmMain->UpdateUnLock: Exit Sub
					Des->OnInsertingControl = @DesignerInsertingControl
					Des->OnInsertControl = @DesignerInsertControl
					Des->OnInsertComponent = @DesignerInsertComponent
					Des->OnChangeSelection = @DesignerChangeSelection
					Des->OnDeleteControl = @DesignerDeleteControl
					Des->OnDblClickControl = @DesignerDblClickControl
					Des->OnClickProperties = @DesignerClickProperties
					Des->OnModified = @DesignerModified
					Des->MFF = DyLibLoad(*MFFDll)
					Des->CreateControlFunc = DyLibSymbol(Des->MFF, "CreateControl")
					Des->CreateComponentFunc = DyLibSymbol(Des->MFF, "CreateComponent")
					Des->ReadPropertyFunc = DyLibSymbol(Des->MFF, "ReadProperty")
					Des->WritePropertyFunc = DyLibSymbol(Des->MFF, "WriteProperty")
					Des->DeleteComponentFunc = DyLibSymbol(Des->MFF, "DeleteComponent")
					Des->DeleteAllObjectsFunc = DyLibSymbol(Des->MFF, "DeleteAllObjects")
					Des->RemoveControlSub = DyLibSymbol(Des->MFF, "RemoveControl")
					Des->ControlByIndexFunc = DyLibSymbol(Des->MFF, "ControlByIndex")
					Des->Q_ComponentFunc = DyLibSymbol(Des->MFF, "Q_Component")
					Des->ComponentGetBoundsSub = DyLibSymbol(Des->MFF, "ComponentGetBounds")
					Des->ComponentSetBoundsSub = DyLibSymbol(Des->MFF, "ComponentSetBounds")
					Des->ControlIsContainerFunc = DyLibSymbol(Des->MFF, "ControlIsContainer")
					Des->IsControlFunc = DyLibSymbol(Des->MFF, "IsControl")
					Des->ControlSetFocusSub = DyLibSymbol(Des->MFF, "ControlSetFocus")
					Des->ControlFreeWndSub = DyLibSymbol(Des->MFF, "ControlFreeWnd")
					Des->ToStringFunc = DyLibSymbol(Des->MFF, "ToString")
					'Des->ContextMenu = @mnuForm
				End If
				Pos1 = InStr(Trim(LCase(*FLine), Any !"\t "), " extends ")
				frmName = Mid(Trim(*FLine, Any !"\t "), 6, Pos1 - 6)
				If Des AndAlso Des->DesignControl = 0 Then
					With *Des
						If EndsWith(Trim(LCase(*FLine), Any !"\t "), " usercontrol") Then
							.DesignControl = .CreateControl("UserControl", frmName, frmName, 0, 0, 0, 350, 300, True)
						Else
							.DesignControl = .CreateControl("Form", frmName, frmName, 0, 0, 0, 350, 300, True)
						End If
						If .DesignControl = 0 Then bNotDesign = False: pfrmMain->UpdateUnLock: Exit Sub
						'MFF = DyLibLoad(*MFFDll)
						'.FLibs.Add *MFFDll, MFF
						'ReadPropertyFunc = DylibSymbol(MFF, "ReadProperty")
						'WritePropertyFunc = DylibSymbol(MFF, "WriteProperty")
						If .WritePropertyFunc <> 0 Then
							.WritePropertyFunc(.DesignControl, "IsChild", @bTrue)
							#ifdef __USE_GTK__
								.WritePropertyFunc(.DesignControl, "ParentWidget", pnlForm.Widget)
							#else
								Dim As HWND pnlFormHandle = pnlForm.Handle
								.WritePropertyFunc(.DesignControl, "ParentHandle", @pnlFormHandle)
							#endif
							.WritePropertyFunc(.DesignControl, "DesignMode", @bTrue)
							.WritePropertyFunc(.DesignControl, "Visible", @bTrue)
							'.DesignControl->Parent = @pnlForm
						End If
						If .ReadPropertyFunc <> 0 Then
							#ifdef __USE_GTK__
								Dim As GtkWidget Ptr DCLayoutWidget = .ReadPropertyFunc(.DesignControl, "LayoutWidget")
								If DCLayoutWidget <> 0 Then
									.layoutwidget = DCLayoutWidget
									gtk_widget_set_can_focus(.layoutwidget, True)
								End If
								Dim As GtkWidget Ptr DCWidget = .ReadPropertyFunc(.DesignControl, "Widget")
								If DCWidget <> 0 Then
									'										Dim As GtkStyleContext Ptr context
									'										context = gtk_widget_get_style_context(DCWidget)
									'										gtk_style_context_add_class(context,"design_control")
									.Dialog = DCWidget
									'gtk_widget_set_can_focus(DCWidget, True)
								End If
							#else
								Dim As HWND Ptr DCHandle = .ReadPropertyFunc(.DesignControl, "Handle")
								If DCHandle <> 0 Then
									SetParent *DCHandle, pnlForm.Handle
									.Dialog = *DCHandle
								End If
							#endif
						End If
						RequestAlign
					End With
				End If
				cboClass.Items.Add(frmName, Des->DesignControl, "Form", "Form")
				bT = True
			ElseIf bT Then
				If Trim(LCase(*FLine), Any !"\t ") = "end type" Then
					t = True
				ElseIf Not t Then
					If StartsWith(Trim(LCase(*FLine), Any !"\t "), "dim as ") Then
						sText = Trim(Mid(Trim(*FLine, Any !"\t "), 8), Any !"\t ")
						p = InStr(sText, " ")
						If p Then
							TypeName = Trim(Left(sText, p), Any !"\t ")
							sText = Trim(Mid(Trim(sText, Any !"\t "), p))
							If StartsWith(LCase(sText), "ptr ") OrElse StartsWith(LCase(sText), "pointer ") Then
								Continue For
								p = InStr(sText, " ")
								If p Then sText = Trim(Mid(Trim(sText), p), " ")
							End If
							ArgName = ""
							p = InStr(sText, ",")
							Do While p > 0
								ArgName = Trim(Left(sText, p - 1), Any !"\t ")
								If InStr(ArgName,"(") > 0 Then  ' It is Ctrl Array Then
									CtrlArrayNum = Val(StringExtract(ArgName,"(",")"))
									Dim As String tCtrlName = StringExtract(ArgName,"(")
									For i As Integer =0 To CtrlArrayNum
										ArgName=tCtrlName & "(" & Str(i) & ")"
										Ctrl = Des->CreateControl(TypeName, ArgName, ArgName, 0, 0, 0, 0, 0)
										If Ctrl = 0 Then
											Ctrl = Des->CreateComponent(TypeName, ArgName, 0, 0, 0)
										End If
										cboClass.Items.Add ArgName, Ctrl, TypeName, TypeName, , 1
									Next
								Else
									Ctrl = Des->CreateControl(TypeName, ArgName, ArgName, 0, 0, 0, 0, 0)
									If Ctrl = 0 Then
										Ctrl = Des->CreateComponent(TypeName, ArgName, 0, 0, 0)
									End If
									cboClass.Items.Add ArgName, Ctrl, TypeName, TypeName, , 1
								End If
								sText = Trim(Mid(sText, p + 1), Any !"\t ")
								p = InStr(sText, ",")
							Loop
							If InStr(sText,"(") > 0 Then  ' It is Ctrl Array
								CtrlArrayNum = Val(StringExtract(sText,"(",")"))
								Dim As String tCtrlName = StringExtract(sText,"(")
								For i As Integer =0 To CtrlArrayNum
									Ctrl = Des->CreateControl(TypeName, tCtrlName & "(" & Str(i) & ")", tCtrlName & "(" & Str(i) & ")", 0, 0, 0, 0, 0)
									If Ctrl = 0 Then
										Ctrl = Des->CreateComponent(TypeName, tCtrlName & "(" & Str(i) & ")", 0, 0, 0)
									End If
									cboClass.Items.Add tCtrlName & "(" & Str(i) & ")", Ctrl, TypeName, TypeName,, 1
								Next
							Else
								Ctrl = Des->CreateControl(TypeName, sText, sText, 0, 0, 0, 0, 0)
								If Ctrl = 0 Then
									Ctrl = Des->CreateComponent(TypeName, sText, 0, 0, 0)
								End If
								cboClass.Items.Add sText, Ctrl, TypeName, TypeName, , 1
							End If
						End If
					End If
				ElseIf CInt(Not c) AndAlso CInt(StartsWith(LTrim(LCase(*FLine), Any !"\t ") & " ", "constructor " & LCase(frmName) & " ")) Then
					c = True
				ElseIf CInt(c) AndAlso Trim(LCase(*FLine), Any !"\t ") = "end constructor" Then
					c = False
					'Exit For
				ElseIf c Then
					ArgName = ""
					If StartsWith(LTrim(LCase(*FLine), Any !"\t "), "with ") Then
						WithArgs.Add Trim(Mid(LTrim(*FLine, Any !"\t "), 5), Any !"\t ")
					ElseIf StartsWith(LTrim(LCase(*FLine), Any !"\t "), "end with") Then
						If WithArgs.Count > 0 Then WithArgs.Remove WithArgs.Count - 1
					Else
						p = InStr(*FLine, ".")
						p1 = InStr(*FLine, "=")
						'If p > p1 Then p = 0
						If p > 0 Then
							ArgName = Trim(Left(*FLine, p - 1), Any !"\t ")
							If ArgName = "" AndAlso WithArgs.Count > 0 Then ArgName = WithArgs.Item(WithArgs.Count - 1)
							If LCase(ArgName) = "this" Then ArgName = frmName
						ElseIf p1 AndAlso (InStr(*FLine, "->") = 0) Then
							ArgName = frmName
						End If
						Ctrl = 0
						If cboClass.Items.Contains(ArgName) Then
							CBItem = cboClass.Items.Item(cboClass.Items.IndexOf(ArgName))
							If CBItem <> 0 Then Ctrl = Cast(Any Ptr, CBItem->Object)
						End If
						If Ctrl Then
							If p1 Then
								PropertyName = Trim(Mid(*FLine, p + 1, p1 - p - 1), Any !"\t ")
								FLin = Mid(*FLine, p1 + 1)
								FLin = Trim(FLin, Any !"\t ")
								If Len(FLin) <> 0 Then
									WLet(FLine2, Trim(Mid(*FLine, p1 + 1), Any !"\t "))
									If StartsWith(*FLine2, "@") Then WLet(FLine3, Trim(Mid(*FLine2, 2), Any !"\t ")): WLet(FLine2, *FLine3)
									If WriteObjProperty(Ctrl, PropertyName, *FLine2) Then
										#ifdef __USE_GTK__
											If LCase(PropertyName) = "parent" AndAlso Des->ReadPropertyFunc(Ctrl, "Widget") Then
												Des->HookControl(Des->ReadPropertyFunc(Ctrl, "Widget"))
												If SelControlNames.Contains(QWString(Des->ReadPropertyFunc(Ctrl, "Name"))) Then
													Des->SelectedControls.Add Ctrl
												End If
												If SelControlName = QWString(Des->ReadPropertyFunc(Ctrl, "Name")) Then
													Des->SelectedControl = Ctrl
													Des->MoveDots Des->SelectedControl, False
													bSelControlFind = True
												End If
											End If
											gtk_widget_show(Des->ReadPropertyFunc(Ctrl, "Widget"))
										#else
											Dim hwnd1 As HWND Ptr = Des->ReadPropertyFunc(Ctrl, "Handle")
											If LCase(PropertyName) = "parent" AndAlso hwnd1 AndAlso *hwnd1 Then
												Des->HookControl(*hwnd1)
												If SelControlNames.Contains(QWString(Des->ReadPropertyFunc(Ctrl, "Name"))) Then
													Des->SelectedControls.Add Ctrl
												End If
												If SelControlName = WGet(Des->ReadPropertyFunc(Ctrl, "Name")) Then
													Des->SelectedControl = Ctrl
													Des->MoveDots Des->SelectedControl, False
													bSelControlFind = True
												End If
											End If
										#endif
									End If
								End If
							ElseIf LCase(Mid(*FLine, p + 1, 10)) = "setbounds " Then
								lLeft = 0: lTop = 0: lWidth = 0: lHeight = 0
								sText = Mid(*FLine, p + 10)
								p1 = InStr(sText, ",")
								If p1 > 0 Then
									lLeft = Val(Left(sText, p1 - 1))
									sText = Mid(sText, p1 + 1)
									p1 = InStr(sText, ",")
									If p1 > 0 Then
										lTop = Val(Left(sText, p1 - 1))
										sText = Mid(sText, p1 + 1)
										p1 = InStr(sText, ",")
										If p1 > 0 Then
											lWidth = Val(Left(sText, p1 - 1))
											lHeight = Val(Mid(sText, p1 + 1))
										End If
									End If
								End If
								If Des->ComponentSetBoundsSub <> 0 Then
									Des->ComponentSetBoundsSub(Des->Q_ComponentFunc(Ctrl), lLeft, lTop, lWidth, lHeight)
								End If
							End If
						End If
					End If
				End If
			End If
		Next
	Next
	If CInt(NotForms = False) AndAlso CInt(Des) AndAlso CInt(Des->DesignControl) AndAlso CInt(Not bSelControlFind) Then
		Des->SelectedControl = Des->DesignControl
		#ifdef __USE_GTK__
			Dim As GtkWidget Ptr Widget
			If Des->ReadPropertyFunc <> 0 Then Widget = Des->ReadPropertyFunc(Des->SelectedControl, "Widget")
			If Widget <> 0 Then gtk_widget_show_all(widget)
		#else
			Dim As HWND Ptr DesCtrlHandle
			If Des->ReadPropertyFunc <> 0 Then DesCtrlHandle = Des->ReadPropertyFunc(Des->DesignControl, "Handle")
			Des->MoveDots Des->DesignControl, False
		#endif
		If Des->SelectedControls.Count > 1 Then Des->MoveDots Des->SelectedControl, False
		'FillAllProperties
	End If
	Functions.Sort
	If cboClass.ItemIndex = 0 Then
		Dim As TypeElement Ptr te2
		Dim t As Boolean
		For i As Integer = cboFunction.Items.Count - 1 To 1 Step -1
			t = False
			For j As Integer = Functions.Count - 1 To 0 Step -1
				te2 = Functions.Object(j)
				If te2 = 0 Then Continue For
				'If te2->TabPtr = @This Then
				If CInt(Not te2->Find) AndAlso CInt(te2->DisplayName = cboFunction.Items.Item(i)->Text) Then 'CInt(Not te1->Find) AndAlso
					te2->Find = True
					cboFunction.Items.Item(i)->Object = te2
					t = True
					Exit For
				End If
				'End If
			Next j
			If Not t Then
				cboFunction.Items.Remove i
			End If
		Next i
		For j As Integer = 0 To Functions.Count - 1
			te2 = Functions.Object(j)
			'If te2->TabPtr = @This Then
			If Not te2->Find Then
				Dim As String imgKey = "Sub"
				If te2->ElementType = "Property" Then
					imgKey = "Property"
				ElseIf te2->ElementType = "Function" Then
					imgKey = "Function"
				End If
				t = False
				For i As Integer = 1 To cboFunction.Items.Count - 1
					If LCase(cboFunction.Items.Item(i)->Text) > LCase(te2->DisplayName) Then
						cboFunction.Items.Add te2->DisplayName, te2, imgKey, imgKey, , , i
						t = True
						Exit For
					End If
				Next i
				If Not t Then cboFunction.Items.Add te2->DisplayName, te2, imgKey, imgKey
			End If
			'End If
		Next
		'cboClass_Change cboClass
		'OnLineChangeEdit txtCode, iSelEndLine
	End If
	WithArgs.Clear
	ConstructionBlocks.Clear
	SelControlNames.Clear
	bNotDesign = False
	pfrmMain->UpdateUnLock
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

'Sub tbrTop_ButtonClick(ByRef Sender As My.Sys.Object)
'	Var tb = Cast(TabWindow Ptr, Cast(ToolButton Ptr, @Sender)->Ctrl->Parent->Parent)
'	With *tb
'		Select Case Sender.ToString
'		Case "Code"
'			.pnlCode.Visible = True
'			.pnlForm.Visible = False
'			.splForm.Visible = False
'			ptabLeft->SelectedTabIndex = 0
'		Case "Form"
'			.pnlCode.Visible = False
'			.pnlForm.Align = 5
'			.pnlForm.Visible = True
'			.splForm.Visible = False
'			If .bNotDesign = False Then .FormDesign
'			ptabLeft->SelectedTabIndex = 1
'		Case "CodeAndForm"
'			.pnlForm.Align = 2
'			.pnlForm.Width = 350
'			.pnlForm.Visible = True
'			.splForm.Visible = True
'			.pnlCode.Visible = True
'			If .bNotDesign = False Then .FormDesign
'			ptabLeft->SelectedTabIndex = 1
'		End Select
'		.RequestAlign
'	End With
'End Sub

Sub cboIntellisense_DropDown(ByRef Sender As ComboBoxEdit)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	tb->txtCode.DropDownShowed = True
End Sub

Sub cboIntellisense_CloseUp(ByRef Sender As ComboBoxEdit)
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	tb->txtCode.DropDownShowed = False
End Sub

Sub TabWindow_Destroy(ByRef Sender As Control)
	pApp->DoEvents
End Sub

Constructor TabWindow(ByRef wFileName As WString = "", bNew As Boolean = False, TreeN As TreeNode Ptr = 0)
	WLEt(FCaption, "")
	WLet(FFileName, "")
	txtCode.Font.Name = *EditorFontName
	txtCode.Font.Size = EditorFontSize
	txtCode.Align = 5
	txtCode.OnChange = @OnChangeEdit
	txtCode.OnLineChange = @OnLineChangeEdit
	txtCode.OnSelChange = @OnSelChangeEdit
	txtCode.OnLinkClicked = @OnLinkClickedEdit
	txtCode.OnToolTipLinkClicked = @OnToolTipLinkClickedEdit
	txtCode.OnKeyDown = @OnKeyDownEdit
	txtCode.OnKeyPress = @OnKeyPressEdit
	txtCode.Tag = @This
	'OnPaste = @OnPasteEdit
	txtCode.OnMouseMove = @OnMouseMoveEdit
	txtCode.OnMouseHover = @OnMouseHoverEdit
	'txtCode.tbParent = @This
	This.Width = 180
	This.OnDestroy = @TabWindow_Destroy
	
	btnClose.tbParent = @This
	#ifdef __USE_GTK__
		pnlTop.Height = 33
	#else
		pnlTop.Height = 25
	#endif
	pnlTop.Align = 3
	#ifdef __USE_GTK__
		pnlTopCombo.Height = 33
	#else
		pnlTopCombo.Height = 25
	#endif
	'mnuCode.ImagesList = pimgList '<m>
	mnuCode.Add(ML("Cut"), "Cut", "Cut", @mclick)
	mnuCode.Add(ML("Copy"), "Copy", "Copy", @mclick)
	mnuCode.Add(ML("Paste"), "Paste", "Paste", @mclick)
	mnuCode.Add("-")
	Var miToogle = mnuCode.Add(ML("Toggle"), "", "Toggle")
	miToogle->Add(ML("Breakpoint"), "Breakpoint", "Breakpoint", @mclick)
	miToogle->Add(ML("Bookmark"), "Bookmark", "ToggleBookmark", @mclick)
	mnuCode.Add("-")
	mnuCode.Add(ML("Add Watch"), "", "AddWatch", @mclick)
	mnuCode.Add(ML("Run To Cursor"), "", "RunToCursor", @mclick)
	mnuCode.Add(ML("Set Next Statement"), "", "SetNextStatement", @mclick)
	mnuCode.Add("-")
	mnuCode.Add(ML("Define"), "", "Define", @mclick)
	mnuCode.Add("-")
	mnuCode.Add(ML("Sort Lines"), "", "SortLines", @mclick)
	txtCode.ContextMenu = @mnuCode
	pnlTopCombo.Align = 5
	pnlTopCombo.Width = 101
	pnlForm.Name = "Designer"
	pnlForm.Width = 360
	pnlForm.Align = 2
	pnlCode.Align = 5
	pnlEdit.Align = 5
	'lvComponentsList.Images = @imgListTools
	'lvComponentsList.StateImages = @imgListTools
	'lvComponentsList.SmallImages = @imgListTools
	'lvComponentsList.View = vsIcon
	'Dim As My.Sys.Drawing.Cursor crRArrow, crHand
	'crRArrow.LoadFromResourceName("Select")
	'crHand.LoadFromResourceName("Hand")
	splForm.Align = 2
	cboClass.ImagesList = pimgListTools
	'cboClass.ItemIndex = 0
	'cboClass.SetBounds 0, 2, 60, 20
	tbrTop.ImagesList = pimgList
	#ifdef __USE_GTK__
		tbrTop.Width = 100
	#else
		tbrTop.Width = 75
	#endif
	tbrTop.Align = 2
	tbrTop.Buttons.Add tbsSeparator
	tbrTop.Buttons.Add tbsCheckGroup, "Code", , @mClick, "Code", , ML("Show Code"), True ' Show the toollips
	tbrTop.Buttons.Add tbsCheckGroup, "Form", , @mClick, "Form", , ML("Show Form"), True ' Show the toollips
	tbrTop.Buttons.Add tbsCheckGroup, "CodeAndForm", , @mClick, "CodeAndForm", , ML("Show Code And Form"), True '
	tbrTop.Flat = True
	cboClass.Width = 50
	#ifdef __USE_GTK__
		cboClass.Top = 0
		#ifdef __USE_GTK3__
			cboClass.Height = 20
		#else
			cboClass.Height = 30
		#endif
	#else
		cboClass.Top = 2
		cboClass.Height = 30 * 22
	#endif
	cboClass.Anchor.Left = asAnchor
	cboClass.Anchor.Right = asAnchorProportional
	cboClass.OnSelected = @cboClass_Change
	cboClass.ImagesList = pimgListTools
	cboFunction.ImagesList = pimgList
	cboFunction.Left = 50 + 0 + 1
	cboFunction.Width = 50
	#ifdef __USE_GTK__
		cboFunction.Top = 0
		#ifdef __USE_GTK3__
			cboFunction.Height = 20
		#else
			cboFunction.Height = 30
		#endif
	#else
		cboFunction.Top = 2
		cboFunction.Height = 30 * 22
	#endif
	cboFunction.Anchor.Left = asAnchorProportional
	cboFunction.Anchor.Right = asAnchor
	cboFunction.OnSelected = @cboFunction_Change
	cboFunction.Sort = True
	cboFunction.Items.Add WStr("(") & ML("Declarations") & ")" & WChr(0), , "Sub"
	cboFunction.ItemIndex = 0
	pnlForm.Visible = False
	splForm.Visible = False
	pnlTop.Add @tbrTop
	pnlTop.Add @pnlTopCombo
	pnlTopCombo.Add @cboClass
	pnlTopCombo.Add @cboFunction
	If CInt(wFileName <> "") And CInt(bNew = False OrElse TreeN <> 0) Then
		If bNew Then
			FileName = TreeN->Text
			If EndsWith(FileName, "*") Then FileName = Left(FileName, Len(FileName) - 1)
		Else
			FileName = wFileName
		End If
		'txtCode.LoadFromFile(wFileName, False)
		This.Caption = GetFileName(FileName)
	Else
		This.Caption = ML("Untitled") & "*"
	End If
	pnlForm.Top = -500
	pnlCode.Add @txtCode
	This.Add @pnlTop
	This.Add @pnlForm
	This.Add @splForm
	This.Add @pnlCode
	#ifdef __USE_GTK__
		txtCode.lvIntellisense.OnItemActivate = @lvIntellisense_ItemActivate
	#else
		txtCode.cboIntellisense.ImagesList = pimgList
		txtCode.cboIntellisense.OnDropDown = @cboIntellisense_DropDown
		txtCode.cboIntellisense.OnCloseUp = @cboIntellisense_CloseUp
		txtCode.cboIntellisense.OnSelected = @cboIntellisense_Selected
	#endif
	'cboIntellisense.Style = cbDropDown
	This.ImageIndex = pimgList->IndexOf("File")
	This.ImageKey = "File"
	'    OnHandleIsAllocated = @HandleIsAllocated
	If TreeN <> 0 Then
		tn = TreeN
	Else
		Dim As ExplorerElement Ptr ee
		For i As Integer = 0 To ptvExplorer->Nodes.Count - 1
			ee = ptvExplorer->Nodes.Item(i)->Tag
			If ee <> 0 Then
				If *ee->FileName = FileName Then
					tn = ptvExplorer->Nodes.Item(i)
					Exit For
				End If
			End If
			For j As Integer = 0 To ptvExplorer->Nodes.Item(i)->Nodes.Count - 1
				ee = ptvExplorer->Nodes.Item(i)->Nodes.Item(j)->Tag
				If ee <> 0 Then
					If *ee->FileName = FileName Then
						tn = ptvExplorer->Nodes.Item(i)->Nodes.Item(j)
						Exit For
					End If
				End If
			Next
			If tn <> 0 Then Exit For
		Next i
		If tn = 0 Then
			tn = ptvExplorer->Nodes.Add(This.Caption, , , "File", "File")
		End If
	End If
End Constructor

Destructor TabWindow
	If FCaptionNew Then Deallocate_( FCaptionNew)
	If FFileName Then Deallocate_( FFileName)
	If FLine Then Deallocate_( FLine)
	If FLine1 Then Deallocate_( FLine1)
	If FLine2 Then Deallocate_( FLine2)
	If FLine3 Then Deallocate_( FLine3)
	If FLine4 Then Deallocate_( FLine4)
	If FPath Then Deallocate_( FPath)
	If Des <> 0 Then 
		For i As Integer = cboClass.Items.Count - 1 To 1 Step -1
			CurCtrl = 0
			CBItem = cboClass.Items.Item(i)
			If CBItem <> 0 Then CurCtrl = CBItem->Object
			If CurCtrl <> 0 Then
				#ifndef __USE_GTK__
					If Des->ReadPropertyFunc(CurCtrl, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, Des->ReadPropertyFunc(CurCtrl, "Tag")))
					Des->DeleteComponentFunc(CurCtrl)
				#endif
			End If
		Next i
		Delete_( Des)
	End If
	cboClass.Items.Clear
	cboFunction.Items.Clear
	Dim As TypeElement Ptr te
	For i As Integer = Functions.Count - 1 To 0 Step -1
		te = Functions.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			Delete_( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		Delete_( Cast(TypeElement Ptr, Functions.Object(i)))
	Next
	For i As Integer = FunctionsOthers.Count - 1 To 0 Step -1
		Delete_( Cast(TypeElement Ptr, FunctionsOthers.Object(i)))
	Next
	For i As Integer = Args.Count - 1 To 0 Step -1
		Delete_( Cast(TypeElement Ptr, Args.Object(i)))
	Next
	Functions.Clear
	FunctionsOthers.Clear
	Types.Clear
	Procedures.Clear
	Args.Clear
	If ptabRight->Tag = @This Then ptabRight->Tag = 0
	'If tn <> 0 Then ptvExplorer->RemoveRoot ptvExplorer->IndexOfRoot(tn)
End Destructor

'Public Function STATEIMAGEMASKTOINDEX(iState As Integer) As Integer
'
'  STATEIMAGEMASKTOINDEX = iState / (2 ^ 12)
'End Function
'
'#IfNDef __USE_GTK__
'	Public Function Listview_GetItemStateEx(hwndLV As HWND, iItem As Integer, ByRef iIndent As Integer) As Integer
'		Dim lvi As LVITEM
'
'
'		lvi.mask = LVIF_STATE Or LVIF_INDENT
'		lvi.iItem = iItem
'		lvi.stateMask = LVIS_STATEIMAGEMASK
'
'
'		If ListView_GetItem(hwndLV, @lvi) Then
'			iIndent = lvi.iIndent
'			Return STATEIMAGEMASKTOINDEX(lvi.state And LVIS_STATEIMAGEMASK)
'		End If
'
'
'	End Function
'#EndIf
'
'#IfNDef __USE_GTK__
'	Public Function Listview_SetItemStateEx(hwndLV As HWND, iItem As Integer, iIndent As Integer, dwState As Integer) As Boolean
'		Dim lvi As LVITEM
'		lvi.mask = LVIF_STATE Or LVIF_INDENT
'		lvi.iItem = iItem
'		lvi.iIndent = iIndent
'		lvi.state = INDEXTOSTATEIMAGEMASK(dwState)
'		lvi.stateMask = LVIS_STATEIMAGEMASK
'		Return ListView_SetItem(hwndLV, @lvi)
'	End Function
'#EndIF

'Sub AddChildItems(iParentItem As Integer, iParentIndent As Integer)
'    If (iParentItem <> -1) Then
'		#IfNDef __USE_GTK__
'			Listview_SetItemStateEx(lvProperties.Handle, iParentItem, iParentIndent, 2)
'        #EndIf
'        Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabRight.Tag)
'        If tb = 0 Then Exit Sub
'        If tb->Des = 0 Then Exit Sub
'        If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
'        If tb->Des->SelectedControl = 0 Then Exit Sub
'        Dim PropertyName As String = GetItemText(lvProperties.ListItems.Item(iParentItem))
'        Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), PropertyName)
'        If te = 0 Then Exit Sub
'        tabRight.UpdateLock
'        Dim lvItem As TreeListViewItem Ptr
'        FPropertyItems.Clear
'        tb->FillProperties te->TypeName
'        FPropertyItems.Sort
'        For lvPropertyCount As Integer = FPropertyItems.Count - 1 To 0 Step -1
'            te = FPropertyItems.Object(lvPropertyCount)
'            If te = 0 Then Continue For
'            With *te
'                If Cint(LCase(.Name) <> "handle") AndAlso Cint(LCase(.TypeName) <> "hwnd") AndAlso Cint(.ElementType = "Property") Then
'                    lvItem = lvProperties.ListItems.Insert(iParentItem + 1, FPropertyItems.Item(lvPropertyCount), 2, IIF(Comps.Contains(.TypeName), 1, 0), iParentIndent + 1)
'                    lvItem->Text(1) = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName & "." & FPropertyItems.Item(lvPropertyCount))
'                End If
'            End With
'        Next
'        tabRight.UpdateUnlock
'    End If
'End Sub
'
'Sub RemoveChildItems(iParentItem As Integer, iParentIndent As Integer)
'    #IfNDef __USE_GTK__
'		Listview_SetItemStateEx(lvProperties.Handle, iParentItem, iParentIndent, 1)
'    #EndIf
'    Var nItems = lvProperties.ListItems.Count
'    Dim iChildIndent As Integer
'    Do
'		#IfNDef __USE_GTK__
'			Listview_GetItemStateEx(lvProperties.Handle, iParentItem + 1, iChildIndent)
'        #EndIf
'        If (iChildIndent > iParentIndent) Then
'
'            ' Remove the item directly below the collapsing parent (VB ListItems are one-based)
'            lvProperties.ListItems.Remove (iParentItem + 1)
'
'            ' Keep a count of ListView items so we don't try to remove more
'            ' items than are in the ListView (when collapsing the last parent).
'
'           nItems = nItems - 1
'        End If
'
'  Loop While (iChildIndent > iParentIndent) And (iParentItem + 1 < nItems)
'End Sub
'
'Sub ClickProperty(Item As Integer)
'    Dim dwState As Integer
'    Dim iIndent As Integer
'    #IfNDef __USE_GTK__
'		Dim lvi As LVITEM
'		lvi.mask = LVIF_STATE Or LVIF_INDENT
'		lvi.iItem = Item
'		lvi.stateMask = LVIS_STATEIMAGEMASK
'		If ListView_GetItem(lvProperties.Handle, @lvi) Then
'			iIndent = lvi.iIndent
'			dwState = STATEIMAGEMASKTOINDEX(lvi.state And LVIS_STATEIMAGEMASK)
'			If dwState > 0 Then
'				If (dwState = 1) Then
'					AddChildItems(Item, iIndent)
'				Else
'					RemoveChildItems(Item, iIndent)
'				End If
'			End If
'		End If
'	#EndIf
'End Sub
'
'Sub lvProperties_MouseDown(BYREF Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
'    #IfNDef __USE_GTK__
'		Dim lvhti As LVHITTESTINFO
'		If MouseButton = 0 Then
'			lvhti.pt.x = x
'			lvhti.pt.y = y
'			If (ListView_HitTest(Sender.Handle, @lvhti) <> -1) Then
'				If (lvhti.flags = LVHT_ONITEMSTATEICON) Then
'					ClickProperty lvhti.iItem
'				End If
'			End If
'		End If
'	#EndIf
'End Sub

Sub lvProperties_ItemExpanding(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item AndAlso Item->Items.Count > 0 AndAlso Item->Items.Item(0)->Text(0) = "" Then
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabRight->Tag)
		If tb = 0 Then Exit Sub
		If tb->Des = 0 Then Exit Sub
		If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
		If tb->Des->SelectedControl = 0 Then Exit Sub
		Dim PropertyName As String = GetItemText(Item)
		Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), PropertyName)
		If te = 0 Then Exit Sub
		ptabRight->UpdateLock
		Dim lvItem As TreeListViewItem Ptr
		FPropertyItems.Clear
		tb->FillProperties te->TypeName
		FPropertyItems.Sort
		For lvPropertyCount As Integer = FPropertyItems.Count - 1 To 0 Step -1
			te = FPropertyItems.Object(lvPropertyCount)
			If te = 0 Then Continue For
			With *te
				If CInt(LCase(.Name) <> "handle") AndAlso CInt(LCase(.TypeName) <> "hwnd") AndAlso CInt(.ElementType = "Property") Then
					lvItem = Item->Items.Add(FPropertyItems.Item(lvPropertyCount), 2, IIf(pComps->Contains(.TypeName), 1, 0))
					lvItem->Text(1) = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName & "." & FPropertyItems.Item(lvPropertyCount))
					If pComps->Contains(.TypeName) Then
						lvItem->Items.Add
					End If
				End If
			End With
		Next
		Item->Items.Remove 0
		ptabRight->UpdateUnlock
	End If
End Sub

Sub SplitError(ByRef sLine As WString, ByRef ErrFileName As WString Ptr, ByRef ErrTitle As WString Ptr, ByRef ErrorLine As Integer)
	Dim As Integer Pos1, Pos2
	Dim As Boolean bFlag
	WLet(ErrFileName, "")
	WLet(ErrTitle, sLine)
	ErrorLine = 0
	Pos1 = InStr(sLine, ") error ")
	If Pos1 = 0 Then Pos1 = InStr(sLine, ") warning ")
	If Pos1 = 0 Then
		Pos1 = InStr(3, sLine, ":")
		If Pos1 = 0 Then Return
		Pos2 = InStr(Pos1 + 1, sLine, ":")
		If Pos2 = 0 Then Return
		If Not IsNumeric(Mid(sLine, Pos1 + 1, Pos2 - Pos1 - 1)) Then Return
		Swap Pos1, Pos2
		bFlag = True
	Else
		Pos2 = InStrRev(sLine, "(", Pos1)
		If Pos2 = 0 Then Return
	End If
	ErrorLine = Val(Mid(sLine, Pos2 + 1, Pos1 - Pos2 - 1))
	If ErrorLine = 0 Then Return
	WLet(ErrFileName, Left(sLine, Pos2 - 1))
	WLet(ErrTitle, Mid(sLine, Pos1 + 1))
	'If bFlag AndAlso  Then
End Sub

Function Err2Description(Code As Integer) ByRef As WString
	Select Case Code
	Case 0: Return ML("No error")
	Case 1: Return ML("Illegal function call")
	Case 2: Return ML("File not found signal")
	Case 3: Return ML("File I/O error")
	Case 4: Return ML("Out of memory")
	Case 5: Return ML("Illegal resume")
	Case 6: Return ML("Out of bounds array access")
	Case 7: Return ML("Null Pointer Access")
	Case 8: Return ML("No privileges")
	Case 9: Return ML("Interrupted signal")
	Case 10: Return ML("Illegal instruction signal")
	Case 11: Return ML("Floating point error signal")
	Case 12: Return ML("Segmentation violation signal")
	Case 13: Return ML("Termination request signal")
	Case 14: Return ML("Abnormal termination signal")
	Case 15: Return ML("Quit request signal")
	Case 16: Return ML("Return without gosub")
	Case 17: Return ML("End of file")
	Case Else: Return WStr("")
	End Select
End Function

Sub PipeCmd(ByRef file As WString, ByRef cmd As WString)
	Dim As WString Ptr fileW, cmdW
	'WLet fileW, file
	'WLet cmdW, cmd
	#ifdef __USE_GTK__
		Shell cmd
		'Dim As gint i_retcode = 0, i_exitcode = 0
		'i_retcode = g_spawn_command_line_sync(ToUTF8(cmd), NULL, NULL, @i_exitcode, NULL)
	#else
		WLet(cmdW, "cmd /c """ + cmd + """|clip")
		Dim PI As PROCESS_INFORMATION
		Dim SI As STARTUPINFO
		SI.wShowWindow = SW_HIDE
		SI.cb = SizeOf(STARTUPINFO)
		SI.dwFlags = STARTF_USESHOWWINDOW
		
		
		CreateProcess(0, cmdW, 0, 0, 1, NORMAL_PRIORITY_CLASS, 0, 0, @SI, @PI)
		WaitForSingleObject(PI.hProcess, INFINITE)
		CloseHandle(PI.hProcess)
		CloseHandle(PI.hThread)
	#endif
End Sub

#ifdef __USE_GTK__
	Function build_create_shellscript(ByRef working_dir As WString, ByRef cmd As WString, autoclose As Boolean, debug As Boolean = False, ByRef Arguments As WString = "") As String
		'?Replace(cmd, "\", "/")
		'?!"#!/bin/sh\n\nrm $0\n\ncd " & Replace(working_dir, "\", "/") & !"\n\n" & Replace(cmd, "\", "/") & !"\n\necho ""\n\n------------------\n(program exited with code: $?)"" \n\n" & IIF(autoclose, "", !"\necho ""Press return to continue""\n#to be more compatible with shells like ""dash\ndummy_var=""""\nread dummy_var") & !"\n"
		Dim As Boolean Bit32 = tbStandard.Buttons.Item("B32")->Checked
		Dim As WString Ptr DebuggerPath = IIf(Bit32, Debugger32Path, Debugger64Path)
		Dim As String ScriptPath
		Dim As Integer Fn = FreeFile
		ScriptPath = *g_get_tmp_dir() & "/vfb_run_script.sh"
		Open ScriptPath For Output As #Fn
		Print #Fn, "#!/bin/sh"
		Print #Fn, ""
		Print #Fn, "rm $0"
		Print #Fn, ""
		Print #Fn, "cd " & Replace(working_dir, "\", "/")
		Print #Fn, ""
		Print #Fn, IIf(debug, """" & WGet(DebuggerPath) & """" & " ", "") & Replace(cmd, "\", "/") & " " & Arguments
		Print #Fn, ""
		Print #Fn, !"echo ""\n\n------------------\n(program exited with code: $?)"" \n\n" & IIf(autoclose, "", !"\necho ""Press return to continue""\n#to be more compatible with shells like ""dash\ndummy_var=""""\nread dummy_var") & !"\n"
		Close #Fn
		ScriptPath = "sh " & ScriptPath
		Return ScriptPath
	End Function
#endif

'#IfDef __USE_GTK__
'Type VteInfo
'	Dim As gboolean load_vte			'/* this is the preference, NOT the current instance VTE state */
'	Dim As gboolean load_vte_cmdline	'/* this is the command line option */
'	Dim As gboolean have_vte			'/* use this field to check if the current instance has VTE */
'	Dim As gchar Ptr lib_vte
'	Dim As gchar Ptr dir
'End Type
'Dim Shared As VteInfo vte_info
'
'Type VteConfig
'	Dim As GtkWidget Ptr vte
'	Dim As GtkWidget Ptr menu
'	Dim As GtkWidget Ptr im_submenu
'	Dim As gboolean scroll_on_key
'	Dim As gboolean scroll_on_out
'	Dim As gboolean ignore_menu_bar_accel
'	Dim As gboolean follow_path
'	Dim As gboolean run_in_vte
'	Dim As gboolean skip_run_script
'	Dim As gboolean enable_bash_keys
'	Dim As gboolean cursor_blinks
'	Dim As gboolean send_selection_unsafe
'	Dim As gint scrollback_lines
'	Dim As gchar Ptr shell
'	Dim As gchar Ptr font
'	Dim As gchar Ptr send_cmd_prefix
'	Dim As GdkColor colour_fore
'	Dim As GdkColor colour_back
'End Type
'Dim Shared As VteConfig Ptr vc
'
'Enum VteTerminalCursorBlinkMode
'	VTE_CURSOR_BLINK_SYSTEM,
'	VTE_CURSOR_BLINK_ON,
'	VTE_CURSOR_BLINK_OFF
'End Enum
'
'Enum VtePtyFlags
'	/' we don't care for the other possible values '/
'	VTE_PTY_DEFAULT = 0
'End Enum
'
'/ Incomplete VteTerminal struct from vte/vte.h. '/
'Type VteTerminal As _VteTerminal
'Type _VteTerminal
'	Dim As GtkWidget Ptr widget
'	Dim As GtkAdjustment Ptr adjustment
'End Type
'
'#define VTE_TERMINAL(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), VTE_TYPE_TERMINAL, VteTerminal))
'#define VTE_TYPE_TERMINAL (vf->vte_terminal_get_type())
'
'/' Holds function pointers we need to access the VTE API. '/
'Type VteFunctions
'	vte_get_major_version As Function() As guint
'	vte_get_minor_version As Function() As guint
'	vte_terminal_new As Function() As GtkWidget Ptr
'	vte_terminal_fork_command As Function (terminal As VteTerminal Ptr, command1 As const gchar Ptr, argv As gchar Ptr Ptr, _
'										envv As gchar Ptr Ptr, directory As const gchar Ptr, lastlog As gboolean, _
'										utmp As gboolean, wtmp As gboolean) As pid_t
'	vte_terminal_spawn_sync As Function(terminal As VteTerminal Ptr, pty_flags As VtePtyFlags, _
'										 working_directory As const gchar Ptr, argv As gchar Ptr Ptr, envv As gchar Ptr Ptr, _
'										 spawn_flags As GSpawnFlags, child_setup As GSpawnChildSetupFunc, _
'										 child_setup_data As gpointer, child_pid As GPid Ptr, _
'										 cancellable As GCancellable Ptr, error As GError Ptr Ptr) As gboolean
''	void (*vte_terminal_set_size) (VteTerminal *terminal, glong columns, glong rows);
''	void (*vte_terminal_set_word_chars) (VteTerminal *terminal, const char *spec);
''	void (*vte_terminal_set_word_char_exceptions) (VteTerminal *terminal, const char *exceptions);
''	void (*vte_terminal_set_mouse_autohide) (VteTerminal *terminal, gboolean setting);
''	void (*vte_terminal_reset) (VteTerminal *terminal, gboolean full, gboolean clear_history);
'	vte_terminal_get_type As Function() As GType
''	void (*vte_terminal_set_scroll_on_output) (VteTerminal *terminal, gboolean scroll);
''	void (*vte_terminal_set_scroll_on_keystroke) (VteTerminal *terminal, gboolean scroll);
''	void (*vte_terminal_set_font) (VteTerminal *terminal, const PangoFontDescription *font_desc);
''	void (*vte_terminal_set_scrollback_lines) (VteTerminal *terminal, glong lines);
'	vte_terminal_get_has_selection As Function(terminal As VteTerminal Ptr) As gboolean
'	vte_terminal_copy_clipboard As Sub(terminal As VteTerminal Ptr)
'	vte_terminal_paste_clipboard As Sub(terminal As VteTerminal Ptr)
''	void (*vte_terminal_set_color_foreground) (VteTerminal *terminal, const GdkColor *foreground);
''	void (*vte_terminal_set_color_bold) (VteTerminal *terminal, const GdkColor *foreground);
''	void (*vte_terminal_set_color_background) (VteTerminal *terminal, const GdkColor *background);
''	void (*vte_terminal_feed_child) (VteTerminal *terminal, const char *data, glong length);
''	void (*vte_terminal_im_append_menuitems) (VteTerminal *terminal, GtkMenuShell *menushell);
''	void (*vte_terminal_set_cursor_blink_mode) (VteTerminal *terminal,
''												VteTerminalCursorBlinkMode mode);
''	void (*vte_terminal_set_cursor_blinks) (VteTerminal *terminal, gboolean blink);
''	void (*vte_terminal_select_all) (VteTerminal *terminal);
''	void (*vte_terminal_set_audible_bell) (VteTerminal *terminal, gboolean is_audible);
''	GtkAdjustment* (*vte_terminal_get_adjustment) (VteTerminal *terminal);
''#if GTK_CHECK_VERSION(3, 0, 0)
''	/* hack for the VTE 2.91 API using GdkRGBA: we wrap the API to keep using GdkColor on our side */
''	void (*vte_terminal_set_color_foreground_rgba) (VteTerminal *terminal, const GdkRGBA *foreground);
''	void (*vte_terminal_set_color_bold_rgba) (VteTerminal *terminal, const GdkRGBA *foreground);
''	void (*vte_terminal_set_color_background_rgba) (VteTerminal *terminal, const GdkRGBA *background);
''#endif
'End Type
'
''#Inclib "vte-2.91"
'
''Declare Function vte_terminal_new() As GtkWidget Ptr
'	'pid_t (*vte_terminal_fork_command) (VteTerminal *terminal, const char *command, char **argv,
'	'									char **envv, const char *directory, gboolean lastlog,
'	'									gboolean utmp, gboolean wtmp);
'	'gboolean (*vte_terminal_spawn_sync) (VteTerminal *terminal, VtePtyFlags pty_flags,
'	'									 const char *working_directory, char **argv, char **envv,
''										 GSpawnFlags spawn_flags, GSpawnChildSetupFunc child_setup,
'	'									 gpointer child_setup_data, GPid *child_pid,
'	'									 GCancellable *cancellable, GError **error);
'	'
'
'Dim Shared As GModule Ptr module = NULL
'Dim Shared As VteFunctions Ptr vf
'Dim Shared As GtkWidget Ptr vte
'Dim Shared As GtkWidget Ptr win
'
'Sub create_vte()
'	'Dim As GtkWidget Ptr vte, scrollbar, hbox
'	vte = vf->vte_terminal_new()
'	win = gtk_window_new(GTK_WINDOW_TOPLEVEL)
'	gtk_container_add(gtk_container(win), vte)
'
'	'vte = vf->vte_terminal_new()
'	'vc->vte = vte
'	'scrollbar = gtk_vscrollbar_new(vf->vte_terminal_get_adjustment(VTE_TERMINAL(vte)));
'	'gtk_widget_set_can_focus(scrollbar, FALSE);
'
'	'/* create menu now so copy/paste shortcuts work */
'	'vc->menu = vte_create_popup_menu();
'	'g_object_ref_sink(vc->menu);
'
'	'hbox = gtk_hbox_new(FALSE, 0);
'	'gtk_box_pack_start(GTK_BOX(hbox), vte, TRUE, TRUE, 0);
'	'gtk_box_pack_start(GTK_BOX(hbox), scrollbar, FALSE, FALSE, 0);
'
'	'/* set the default widget size first to prevent VTE expanding too much,
'	' * sometimes causing the hscrollbar to be too big or out of view. */
'	'gtk_widget_set_size_request(GTK_WIDGET(vte), 10, 10);
'	'vf->vte_terminal_set_size(VTE_TERMINAL(vte), 30, 1);
'
'	'vf->vte_terminal_set_mouse_autohide(VTE_TERMINAL(vte), TRUE);
'	'if (vf->vte_terminal_set_word_chars)
'	'	vf->vte_terminal_set_word_chars(VTE_TERMINAL(vte), VTE_WORDCHARS);
'	'else if (vf->vte_terminal_set_word_char_exceptions)
'	'	vf->vte_terminal_set_word_char_exceptions(VTE_TERMINAL(vte), VTE_ADDITIONAL_WORDCHARS);
'
'	'gtk_drag_dest_set(vte, GTK_DEST_DEFAULT_ALL,
'	'	dnd_targets, G_N_ELEMENTS(dnd_targets), GDK_ACTION_COPY);
'
'	'g_signal_connect(vte, "child-exited", G_CALLBACK(vte_start), NULL);
'	'g_signal_connect(vte, "button-press-event", G_CALLBACK(vte_button_pressed), NULL);
'	'g_signal_connect(vte, "event", G_CALLBACK(vte_keypress_cb), NULL);
'	'g_signal_connect(vte, "key-release-event", G_CALLBACK(vte_keyrelease_cb), NULL);
'	'g_signal_connect(vte, "commit", G_CALLBACK(vte_commit_cb), NULL);
'	'g_signal_connect(vte, "motion-notify-event", G_CALLBACK(on_motion_event), NULL);
'	'g_signal_connect(vte, "drag-data-received", G_CALLBACK(vte_drag_data_received), NULL);
'
'	'/* start shell on idle otherwise the initial prompt can get corrupted */
'	'g_idle_add(vte_start_idle, NULL);
'
'	'gtk_widget_show_all(hbox);
'	'terminal_label = gtk_label_new(_("Terminal"));
'	'gtk_notebook_insert_page(GTK_NOTEBOOK(msgwindow.notebook), hbox, terminal_label, MSG_VTE);
'
'	'g_signal_connect_after(vte, "realize", G_CALLBACK(on_vte_realize), NULL);
'End Sub
'
'
'Sub vte_close()
'	g_free(vf)
'	/' free the vte widget before unloading vte module
'	 * this prevents a segfault on X close window if the message window is hidden '/
'	gtk_widget_destroy(vc->vte)
'	gtk_widget_destroy(vc->menu)
'	g_object_unref(vc->menu)
'	g_free(vc->shell)
'	g_free(vc->font)
'	g_free(vc->send_cmd_prefix)
'	g_free(vc)
'	'g_free(gtk_menu_key_accel)
'	/' Don't unload the module explicitly because it causes a segfault on FreeBSD. The segfault
'	 * happens when the app really exits, not directly on g_module_close(). This still needs to
'	 * be investigated. '/
'	/'g_module_close(module); '/
'End Sub
'
'Function vte_register_symbols(mod1 As GModule Ptr) As gboolean
'	g_module_symbol(mod1, "vte_get_major_version", @vf->vte_get_major_version)
'	g_module_symbol(mod1, "vte_get_minor_version", @vf->vte_get_minor_version)
'	If Not g_module_symbol(mod1, "vte_terminal_new", @vf->vte_terminal_new) Then
'		'MsgBox "Not loaded vte_terminal_new"
'	End If
'	g_module_symbol(mod1, "vte_terminal_spawn_sync", @vf->vte_terminal_spawn_sync)
'	g_module_symbol(mod1, "vte_terminal_get_type", @vf->vte_terminal_get_type)
'	g_module_symbol(mod1, "vte_terminal_get_has_selection", @vf->vte_terminal_get_has_selection)
'	g_module_symbol(mod1, "vte_terminal_copy_clipboard", @vf->vte_terminal_copy_clipboard)
'	g_module_symbol(mod1, "vte_terminal_paste_clipboard", @vf->vte_terminal_paste_clipboard)
'	return TRUE
'End Function
'
'Sub vte_init()
'	'module = g_module_open(vte_info.lib_vte, G_MODULE_BIND_LAZY)
'	'if (module = NULL) Then
'		Dim As Integer i = 0
'		Dim As Const String sonames(15) = {"libvte-2.91.so", "libvte-2.91.so.0", "libvte2_90.so", "libvte2_90.so.9", "libvte.so", "libvte.so.9", "libvte.so.8", "libvte.so.4", ""}
'		Do While sonames(i) <> "" AndAlso module = NULL
'			module = g_module_open(toutf8(sonames(i)), G_MODULE_BIND_LAZY)
'			i = i + 1
'		Loop
'	'End If
'
'	if (module = NULL) Then
'		vte_info.have_vte = FALSE
'		MsgBox "Could not load libvte.so, embedded terminal support disabled"
'		return
'	else
'		vf = g_new0(VteFunctions, 1)
'		if (vte_register_symbols(module)) Then
'			vte_info.have_vte = TRUE
'		else
'			vte_info.have_vte = FALSE
'			g_free(vf)
'			/' FIXME: is closing the module safe? see vte_close() and test on FreeBSD */
'			/*g_module_close(module);'/
'			module = NULL
'			return
'		End If
'	End If
'
'	create_vte()
'
'End Sub
'
'vte_init
'
'Sub run_exit_cb(child_pid As GPid, status As gint, user_data As gpointer)
'
'	If child_pid > 0 Then g_spawn_close_pid(child_pid)
'	child_pid = 0
'	ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & status & " - " & Err2Description(status))
'	#IfDef __USE_GTK3__
'		gtk_window_close(gtk_window(user_data))
'	#Else
'		gtk_widget_destroy(gtk_widget(user_data))
'	#EndIf
'
'End Sub
'
'Enum
'	POPUP_COPY
'	POPUP_PASTE
'End Enum
'
'Sub vte_popup_menu_clicked(menuitem As GtkMenuItem Ptr, user_data As gpointer)
'	Select Case (GPOINTER_TO_INT(user_data))
'		case POPUP_COPY:
'			if (vf->vte_terminal_get_has_selection(VTE_TERMINAL(vte))) Then
'				vf->vte_terminal_copy_clipboard(VTE_TERMINAL(vte))
'			End If
'		case POPUP_PASTE:
'			vf->vte_terminal_paste_clipboard(VTE_TERMINAL(vte))
'	End Select
'End Sub
'
'Function vte_create_popup_menu() As GtkWidget Ptr
'	Dim As GtkWidget Ptr menu, item
'
'	menu = gtk_menu_new()
'
'	item = gtk_menu_item_new_with_label(ToUTF8(ML("Copy")))
'	gtk_widget_show(item)
'	gtk_container_add(GTK_CONTAINER(menu), item)
'	g_signal_connect(item, "activate", G_CALLBACK(@vte_popup_menu_clicked), GINT_TO_POINTER(POPUP_COPY))
'
'	item = gtk_menu_item_new_with_label(ToUTF8(ML("Paste")))
'	gtk_widget_show(item)
'	gtk_container_add(GTK_CONTAINER(menu), item)
'	g_signal_connect(item, "activate", G_CALLBACK(@vte_popup_menu_clicked), GINT_TO_POINTER(POPUP_PASTE))
'
'	return menu
'End Function
'
'Dim Shared As GtkWidget Ptr vte_menu
'vte_menu = vte_create_popup_menu()
'
'Function vte_button_pressed(widget As GtkWidget Ptr, event1 As GdkEventButton Ptr, user_data As gpointer) As gboolean
'	if (event1->button = 3) Then
'		gtk_widget_grab_focus(widget)
'		vte = widget
'		gtk_menu_popup(gtk_menu(vte_menu), NULL, NULL, NULL, NULL, event1->button, event1->time)
'		return TRUE
'	elseif (event1->button = 2) Then
'		gtk_widget_grab_focus(widget)
'	End If
'	return FALSE
'End Function
'#EndIf

Function GetMainFile(bSaveTab As Boolean = False, ByRef Project As ProjectElement Ptr = 0, ByRef ProjectNode As TreeNode Ptr = 0) As UString
	Dim As TabWindow Ptr tb
	If MainNode Then
		Dim ee As ExplorerElement Ptr
		ee = MainNode->Tag
		If MainNode->ImageKey = "Project" OrElse ee AndAlso *ee Is ProjectElement Then
			ProjectNode = MainNode
			If ee Then Project = Cast(ProjectElement Ptr, ee)
			If ee AndAlso Project AndAlso WGet(Project->MainFileName) <> "" Then
				Return WGet(Project->MainFileName)
			Else
				MsgBox ML("Project Main File don't set")
			End If
		ElseIf ee = 0 OrElse ee->FileName = 0 OrElse *ee->FileName = "" Then
			For i As Integer = 0 To pTabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, pTabCode->Tabs[i])
				If tb AndAlso tb->tn = MainNode Then
					If bSaveTab Then
						If tb->Modified Then tb->Save
					End If
					Return tb->FileName
				End If
			Next i
		Else
			Return *ee->FileName
		End If
	Else
		tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
		If tb = 0 OrElse tb->tn = 0 Then Return ""
		If bSaveTab Then
			If tb->Modified Then tb->Save
		End If
		Var tn = GetParentNode(tb->tn)
		If tn->ImageKey = "Project" OrElse tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement Then
			ProjectNode = tn
			Dim As ExplorerElement Ptr ee = tn->Tag
			If ee Then Project = Cast(ProjectElement Ptr, ee)
			If ee AndAlso Project AndAlso Project->MainFileName <> 0 AndAlso *Project->MainFileName <> "" Then Return *Project->MainFileName
		End If
		Return tb->FileName
	End If
	Return ""
End Function

Sub Versioning(ByRef FileName As WString, ByRef sFirstLine As WString, ByRef Project As ProjectElement Ptr = 0, ByRef ProjectNode As TreeNode Ptr = 0)
	'If StartsWith(LTrim(LCase(sFirstLine), Any !"\t "), "'#compile ") Then
	Dim As WString Ptr Buff, File, sLine, sLines
	Var bAutoIncrement = CInt(AutoIncrement) OrElse CInt(Project AndAlso CInt(Project->AutoIncrementVersion))
	If Project <> 0 AndAlso bAutoIncrement Then
		Project->BuildVersion += 1
		If AutoSaveBeforeCompiling AndAlso ProjectNode <> 0 Then
			If AutoSaveBeforeCompiling = 1 Then
				If ProjectNode->ImageKey <> "Opened" Then SaveProject ProjectNode
			ElseIf AutoSaveBeforeCompiling = 2 Then
				SaveAll
			End If
		End If
	End If
	WLet(Buff, LTrim(sFirstLine, Any !"\t "))
	Var Pos1 = InStr(*Buff, """"), Pos2 = 1
	Dim QavsBoshi As Boolean
	Do While Pos1 > 0
		QavsBoshi = Not QavsBoshi
		If QavsBoshi Then
			Pos2 = Pos1
		Else
			WLet(File, Mid(*Buff, Pos2 + 1, Pos1 - Pos2 - 1))
			If EndsWith(LCase(*File), ".rc") Then
				WLet(File, GetFolderName(FileName) & *File)
				If Not FileExists(*File) Then
					If AutoCreateRC Then
						#ifndef __USE_GTK__
							FileCopy ExePath & "/Templates/Files/Resource.rc", *File
							If Not FileExists(GetFolderName(FileName) & "Manifest.xml") Then
								FileCopy ExePath & "/Templates/Files/Manifest.xml", *GetFolderName(FileName).vptr & "Manifest.xml"
							End If
						#endif
					End If
				End If
					Var Fn = FreeFile
				If Open(*File For Input Encoding "utf-8" As #Fn) = 0 Then
					Var n = 0
					Var bFinded = False, bChanged = False
					Dim As String NewLine = ""
					Dim As WString * 1024 sLine
					Do Until EOF(Fn)
						Line Input #Fn, sLine
						n += 1
						bChanged = False
						If CInt(bAutoIncrement) AndAlso CInt(StartsWith(LCase(sLine), "#define ver_fileversion ")) Then
							If Project Then
								Var Pos3 = InStrRev(sLine, " ")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Project->MajorVersion & "," & Project->MinorVersion & "," & Project->RevisionVersion & "," & Project->BuildVersion)
									bChanged = True
									'									ThreadsEnter()
									'									If CInt(ProjectNode) AndAlso CInt(Not EndsWith(ProjectNode->Text, "*")) Then ProjectNode->Text &= "*"
									'									ThreadsLeave()
								End If
							Else
								Var Pos3 = InStrRev(sLine, ",")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Val(Mid(sLine, Pos3 + 1)) + 1)
									bChanged = True
								End If
							End If
						ElseIf CInt(bAutoIncrement) AndAlso CInt(StartsWith(LCase(sLine), "#define ver_fileversion_str ")) Then
							If Project Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Project->MajorVersion & "." & Project->MinorVersion & "." & Project->RevisionVersion & "." & Project->BuildVersion & "\0""")
									bChanged = True
								End If
							Else
								Var Pos3 = InStrRev(sLine, ".")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Val(Mid(sLine, Pos3 + 1, Len(sLine) - Pos3 - 3)) + 1 & "\0""")
									bChanged = True
								End If
							End If
						ElseIf Project Then
							If StartsWith(LCase(sLine), "#define ver_companyname_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & WGet(Project->CompanyName) & "\0""")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_filedescription_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Replace(WGet(Project->FileDescription), "{ProjectDescription}", WGet(Project->ProjectDescription)) & "\0""")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_internalname_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & WGet(Project->InternalName) & "\0""")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_legalcopyright_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & WGet(Project->LegalCopyright) & "\0""")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_legaltrademarks_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & WGet(Project->LegalTrademarks) & "\0""")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_originalfilename_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & WGet(Project->OriginalFileName) & "\0""")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_productname_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Replace(WGet(Project->ProductName), "{ProjectName}", WGet(Project->ProjectName)) & "\0""")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_productversion ") Then
								Var Pos3 = InStrRev(sLine, " ")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Project->MajorVersion & "," & Project->MinorVersion & "," & Project->RevisionVersion & ",0")
									bChanged = True
								End If
							ElseIf StartsWith(LCase(sLine), "#define ver_productversion_str ") Then
								Var Pos3 = InStr(sLine, """")
								If Pos3 > 0 Then
									WLet(sLines, *sLines & NewLine & Left(sLine, Pos3) & Project->MajorVersion & "." & Project->MinorVersion & "." & Project->RevisionVersion & "\0""")
									bChanged = True
								End If
							End If
						End If
						If bChanged Then
							bFinded = True
						Else
							WLet(sLines, *sLines & NewLine & sLine)
						End If
						If n = 1 Then NewLine = WChr(13) & WChr(10)
					Loop
					Close #Fn
					If bFinded Then
						Var Fn2 = FreeFile
						If Open(*File For Output Encoding "utf-8" As #Fn2) = 0 Then
							Print #Fn2, *sLines;
							Close #Fn2
						End If
					End If
					Exit Do
				End If
			End If
		End If
		Pos1 = InStr(Pos1 + 1, *Buff, """")
	Loop
	If Buff Then Deallocate_( Buff)
	If File Then Deallocate_( File)
	If sLines Then Deallocate_( sLines)
	'End If
End Sub

Function GetFirstCompileLine(ByRef FileName As WString, ByRef Project As ProjectElement Ptr) As UString
	Dim As Boolean Bit32 = ptbStandard->Buttons.Item("B32")->Checked
	Dim As UString Result
	Result = IIf(Bit32, *Compiler32Arguments, *Compiler64Arguments)
	If Project Then
		#ifdef __USE_GTK__
			Result += " " & IIf(Bit32, *Project->CompilationArguments32Linux, WGet(Project->CompilationArguments64Linux))
		#else
			Result += " " & IIf(Bit32, *Project->CompilationArguments32Windows, WGet(Project->CompilationArguments64Windows))
		#endif
		#ifdef __FB_WIN32__
			If WGet(Project->ResourceFileName) <> "" Then Result += " """ & GetShortFileName(WGet(Project->ResourceFileName), FileName) & """"
		#else
			If WGet(Project->IconResourceFileName) <> "" Then Result += " """ & GetShortFileName(WGet(Project->IconResourceFileName), FileName) & """"
		#endif
		Select Case Project->ProjectType
		Case 0
		Case 1: Result += " -dll"
		Case 2: Result += " -lib"
		End Select
	End If
	Dim As Integer Fn = FreeFile
	Var FileOpenResult = Open(FileName For Input Encoding "utf-8" As #Fn)
	If FileOpenResult <> 0 Then FileOpenResult = Open(FileName For Input As #Fn)
	If FileOpenResult = 0 Then
		Dim As WString * 1024 sLine
		Dim As Integer i, n, l = 0
		Dim As Boolean k(10)
		k(l) = True
		Do Until EOF(Fn)
			Line Input #Fn, sLine
			If StartsWith(LTrim(LCase(sLine), Any !"\t "), "#ifdef __fb_win32__") Then
				l = l + 1
				#ifdef __FB_WIN32__
					k(l) = True
				#else
					k(l) = False
				#endif
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#ifndef __fb_win32__") Then
				l = l + 1
				#ifndef __FB_WIN32__
					k(l) = True
				#else
					k(l) = False
				#endif
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#ifdef __fb_64bit__") Then
				l = l + 1
				k(l) = ptbStandard->Buttons.Item("B64")->Checked
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#ifndef __fb_64bit__") Then
				l = l + 1
				k(l) = Not ptbStandard->Buttons.Item("B64")->Checked
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#else") Then
				k(l) = Not k(l)
			ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t "), "#endif") Then
				l = l - 1
				If l < 0 Then
					Close #Fn
					Return Result
				End If
			Else
				For i = 0 To l
					If k(i) = False Then Exit For
				Next
				If i > l Then
					Close #Fn
					If StartsWith(LTrim(LCase(sLine), Any !"\t "), "'#compile ") Then
						Result = Result & " " & Mid(LTrim(sLine, Any !"\t "), 11)
					End If
					Return Result
				End If
			End If
			If l >= 10 Then
				Close #Fn
				Return Result
			End If
		Loop
		Close #Fn
	End If
	Return Result
End Function

Sub RunPr(Debugger As String = "")
	On Error Goto ErrorHandler
	Dim Result As Integer
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim MainFile As UString = GetMainFile(, Project, ProjectNode)
	Dim FirstLine As UString = GetFirstCompileLine(MainFile, Project)
	Dim ExeFileName As WString Ptr
	WLet(ExeFileName, (GetExeFileName(MainFile, FirstLine)))
	#ifdef __USE_GTK__
		Dim As GPid pid = 0
		'		Dim As GtkWidget Ptr win, vte
		'		win = gtk_window_new(gtk_window_toplevel)
		'		If vf->vte_terminal_new <> 0 Then
		'			vte = vf->vte_terminal_new()
		'			g_signal_connect(vte, "button-press-event", G_CALLBACK(@vte_button_pressed), NULL)
		'			gtk_container_add(gtk_container(win), vte)
		'			'Dim As gint i_retcode = 0, i_exitcode = 0
		'			Dim As gchar Ptr Ptr argv = g_strsplit(ToUTF8(build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)), " ", -1)
		'			gtk_widget_show_all(win)
		'			Dim As GError Ptr error1
		'			vf->vte_terminal_spawn_sync(vte_terminal(vte), VTE_PTY_DEFAULT, ToUTF8(GetFolderName(*ExeFileName)), argv, NULL, G_SPAWN_SEARCH_PATH Or G_SPAWN_DO_NOT_REAP_CHILD, NULL, NULL, @pid, NULL, @error1)
		'	    	If pid > 0 Then
		'	    		g_child_watch_add(pid, @run_exit_cb, win)
		'	    	Else
		'				m *error1->message
		'	    		run_exit_cb(pid, 0, win)
		'	    	End If
		'	    Else
		Dim As WString Ptr Arguments
		WLet(Arguments, *RunArguments)
		If Project Then WLet(Arguments, *Arguments & " " & WGet(Project->CommandLineArguments))
		If 0 Then
			Result = Shell("""" & WGet(TerminalPath) & """ --wait -- """ & build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False, , *Arguments) & """")
		Else
			ChDir(GetFolderName(*ExeFileName))
			Dim As UString CommandLine
			Dim As ToolType Tool
			Dim As Integer Idx = pTerminals->IndexOfKey(*CurrentTerminal)
			If Idx <> - 1 Then
				Tool = pTerminals->Item(Idx)->Object
				CommandLine = Tool->GetCommand("""" & Trim(Replace(*ExeFileName, "\", "/") & IIf(*Arguments = "", "", " " & *Arguments)) & """")
				If Tool->Parameters = "" Then CommandLine &= " --wait -- "
			Else
				CommandLine &= """" & Trim(Replace(*ExeFileName, "\", "/") & IIf(*Arguments = "", "", " " & *Arguments)) & """"
			End If
			ThreadsEnter()
			ShowMessages(Time & ": " & ML("Run") & ": " & CommandLine + " ...")
			ThreadsLeave()
			Result = Shell(CommandLine)
		End If
		WDeallocate Arguments
		ThreadsEnter()
		ShowMessages(Time & ": " & ML("The application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
		ThreadsLeave()
		'EndIf
		'i_retcode = g_spawn_command_line_sync(ToUTF8(build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)), NULL, NULL, @i_exitcode, NULL)
		'?build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)
		'Shell "sh " & build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)
	#else
		Dim As Integer pClass
		Dim As WString Ptr Workdir, CmdL
		Dim As Unsigned Long ExitCode
		WLet(CmdL, """" & GetFileName(*ExeFileName) & """ " & *RunArguments)
		If Project Then WLetEx CmdL, *CmdL & " " & WGet(Project->CommandLineArguments), True
		WLet(ExeFileName, Replace(*ExeFileName, "/", "\"))
		Var Pos1 = 0
		While InStr(Pos1 + 1, *ExeFileName, "\")
			Pos1 = InStr(Pos1 + 1, *ExeFileName, "\")
		Wend
		If Pos1 = 0 Then Pos1 = Len(*ExeFileName)
		WLet(Workdir, Left(*ExeFileName, Pos1))
		If WGet(TerminalPath) <> "" Then
			Dim As ToolType Ptr Tool
			Dim As Integer Idx = pTerminals->IndexOfKey(*CurrentTerminal)
			If Idx <> - 1 Then
				Tool = pTerminals->Item(Idx)->Object
				WLetEx CmdL, Tool->GetCommand(*ExeFileName) & " " & *RunArguments, True
			End If
			'WLetEx CmdL, " /K ""cd /D """ & *Workdir & """ & " & *CmdL & """", True
			WLet(ExeFileName, Replace(GetFullPathInSystem(WGet(TerminalPath)), "/", "\"))
		End If
			ShowMessages(Time & ": " & ML("Run") & ": " & *CmdL + " ...")
			Dim SInfo As STARTUPINFO
			Dim PInfo As PROCESS_INFORMATION
			SInfo.cb = Len(SInfo)
			SInfo.dwFlags = STARTF_USESHOWWINDOW
			SInfo.wShowWindow = SW_NORMAL
			pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
			If CreateProcessW(ExeFileName, CmdL, ByVal Null, ByVal Null, False, pClass, Null, Workdir, @SInfo, @PInfo) Then
				WaitForSingleObject pinfo.hProcess, INFINITE
				GetExitCodeProcess(pinfo.hProcess, @ExitCode)
				CloseHandle(pinfo.hProcess)
				CloseHandle(pinfo.hThread)
				Result = ExitCode
				'Result = Shell(Debugger & """" & *ExeFileName + """")
				ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
			Else
				Result = GetLastError()
				ShowMessages(Time & ": " & ML("Application do not run. Error code") & ": " & Result & " - " & GetErrorString(Result))
			End If
'		Else
'			WLet CmdL, """" & WGet(TerminalPath) & """ /K ""cd /D """ & *Workdir & """ & " & *CmdL & """", True
'			ShowMessages(Time & ": " & ML("Run") & ": " & *CmdL & " ...")
'			Result = Shell(*CmdL)
'			ShowMessages(Time & ": " & ML("The application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
'		End If
		If WorkDir Then Deallocate_( WorkDir)
		If CmdL Then Deallocate_( CmdL)
	#endif
	If ExeFileName Then Deallocate_( ExeFileName)
	Exit Sub
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
	ThreadsLeave()
End Sub

Sub RunProgram(Param As Any Ptr)
	RunPr
End Sub

For i As Integer = 48 To 57
	symbols(i - 48) = i
Next
For i As Integer = 97 To 102
	symbols(i - 87) = i
Next

Function isNumeric(ByRef subject As Const WString, base_ As Integer = 10) As Boolean
	If subject = "" OrElse subject = "." OrElse subject = "+" OrElse subject = "-" Then Return False
	Err = 0
	
	If base_ < 2 OrElse base_ > 16 Then
		Err = 1000
		Return False
	End If
	
	Dim t As String = LCase(subject)
	
	If (t[0] = plus) OrElse (t[0] = minus) Then
		t = Mid(t, 2)
	End If
	
	If Left(t, 2) = "&h" Then
		If base_ <> 16 Then Return False
		t = Mid(t, 3)
	End If
	
	If Left(t, 2) = "&o" Then
		If base_ <> 8 Then Return False
		t = Mid(t, 3)
	End If
	
	If Left(t, 2) = "&b" Then
		If base_ <> 2 Then Return False
		t = Mid(t, 3)
	End If
	
	If Len(t) = 0 Then Return False
	Dim As Boolean isValid, hasDot = False
	
	For i As Integer = 0 To Len(t) - 1
		isValid = False
		
		For j As Integer = 0 To base_ - 1
			If t[i] = symbols(j) Then
				isValid = True
				Exit For
			End If
			If t[i] = dot Then
				If CInt(Not hasDot) AndAlso (base_ = 10) Then
					hasDot = True
					IsValid = True
					Exit For
				End If
				Return False ' either more than one dot or not base 10
			End If
		Next j
		
		If Not isValid Then Return False
	Next i
	
	Return True
End Function

Function utf16BeByte2wchars( ta() As UByte ) ByRef As WString
	Type mstring
		p As WString Ptr ' pointer to wstring buffer
		l As UInteger ' length of string
	End Type
	Dim a As UInteger = 0
	Dim tal As UInteger = UBound(ta)
	Dim ms As mstring
	
	'this is never deallocated..
	ms.p = Allocate_( 0.25 * (tal + 1) * Len(WString))
	
	' iterate array
	Do While a <= tal
		(*ms.p)[ms.l] = 256 * ta(a) + ta(a + 1)
		a += 2
		ms.l += 1
	Loop
	
	(*ms.p)[ms.l] = 0
	Function = *ms.p
End Function

Sub TabWindow.NumberOn(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1, bMacro As Boolean = False)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("Raqamlash")
		If StartLine = -1 Or EndLine = -1 Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			StartLine = iSelStartLine
			EndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		End If
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n
		Dim As Boolean bNotNumberNext, bNotNumberThis
		For i As Integer = StartLine To EndLine
			FECLine = .FLines.Items[i]
			bNotNumberThis = bNotNumberNext
			bNotNumberNext = False
			If EndsWith(RTrim(*FECLine->Text, Any !"\t "), " _") Then
				bNotNumberNext = True
			End If
			If StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'") OrElse StartsWith(LTrim(*FECLine->Text, Any !"\t "), "#") Then
				Continue For
			ElseIf StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "select case ") Then
				bNotNumberNext = True
			ElseIf FECLine->ConstructionIndex >= 0 AndAlso Constructions(FECLine->ConstructionIndex).Collapsible Then
				Continue For
			End If
			n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
			If StartsWith(LTrim(*FECLine->Text), "?") Then
				Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
				If IsNumeric(Mid(Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
					WLet(FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1))
				End If
			ElseIf StartsWith(LTrim(*FECLine->Text), "_L_") Then
				bNotNumberThis = True
			ElseIf IsLabel(*FECLine->Text) Then
				bNotNumberThis = True
			ElseIf FECLine->InConstructionIndex = 5 OrElse FECLine->InConstructionIndex = 6 AndAlso FECLine->InConstructionPart = 0 OrElse _
				 FECLine->InConstructionIndex >= 13 AndAlso FECLine->InConstructionIndex <= 16 Then
				bNotNumberThis = True
			End If
			If Not bNotNumberThis Then
				If bMacro Then
					WLet(FECLine->Text, "_L_" & IIf(StartsWith(*FECLine->Text, " ") OrElse StartsWith(*FECLine->Text, !"\t"), "", " ") & *FECLine->Text)
				Else
					WLet(FECLine->Text, "?" & WStr(i + 1) & ":" & *FECLine->Text)
				End If
			End If
		Next i
		.Changed("Raqamlash")
		.UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.PreprocessorNumberOn()
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Dim As WString Ptr tempStr
	WLetEx tempStr, GetFileName(tb->Filename), True
	With tb->txtCode
		.UpdateLock
		.Changing("Preprocessor Numbering")
		Dim As EditControlLine Ptr FECLine, FECLineOld
		For i As Integer = .LinesCount - 1 To 0 Step -1
			FECLine = .FLines.Items[i]
			If i > 0 Then
				FECLineOld = .FLines.Items[i - 1]
				If EndsWith(RTrim(*FECLineOld->Text, Any !"\t "), " _") Then Continue For
				If StartsWith(LTrim(LCase(*FECLineOld->Text), Any !"\t "), "#print __line__") Then Continue For
			End If
			If Trim(*FECLine->Text, Any !"\t ") = "" Then Continue For
			If StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "#print __line__") Then Continue For
			If StartsWith(LTrim(*FECLine->Text, Any !"\t "), "'") Then Continue For
			.InsertLine i, "#print __LINE__ - " & *tempStr
		Next i
		.Changed("Preprocessor Numbering")
		.UpdateUnLock
		WDeallocate tempStr
		'.ShowCaretPos True
	End With
End Sub

Sub GetProcedureLines(ByRef ehStart As Integer, ByRef ehEnd As Integer)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, i
		.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As EditControlLine Ptr FECLine
		For i = iSelStartLine To 0 Step -1
			FECLine = .FLines.Items[i]
			If FECLine->ConstructionIndex >= 17  Then
				If FECLine->ConstructionPart = 0 Then
					ehStart = i + 1
					Exit For
				Else
					ehEnd = .FLines.Count - 1
					Exit Sub
				End If
			End If
		Next i
		Dim As Boolean t
		For i = iSelStartLine To .FLines.Count - 1
			FECLine = .FLines.Items[i]
			If FECLine->ConstructionIndex >= 17 Then
				t = True
				ehEnd = i - 1
				Exit For
			End If
		Next i
		If Not t Then ehEnd = i - 1
	End With
End Sub

Sub TabWindow.SetErrorHandling(StartLine As String, EndLine As String)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("Error handling")
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As EditControlLine Ptr FECLine
		Dim As Integer ehStart, ehEnd
		Dim Bosh As Boolean
		Dim n As Integer
		Dim ExitLine As String
		For i As Integer = iSelStartLine To 0 Step -1
			FECLine = .FLines.Items[i]
			If FECLine->ConstructionIndex >= 17  Then
				If FECLine->ConstructionPart = 0 Then
					ehStart = i + 1
					Select Case FECLine->ConstructionIndex
					Case 16: ExitLine = "Exit Sub"
					Case 17: ExitLine = "Exit Function"
					Case 18: ExitLine = "Exit Property"
					Case 19: ExitLine = "Exit Operator"
					Case 20: ExitLine = "Exit Constructor"
					Case 21: ExitLine = "Exit Destructor"
					End Select
					n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text)) + 4
					Exit For
				Else
					Bosh = True
					If StartsWith(.Lines(0), "'#Compile ") Then
						ehStart = 1
					Else
						ehStart = 0
					End If
					ExitLine = "End"
					n = 0
					Exit For
				End If
			End If
		Next i
		If ExitLine <> "" Then
			If CInt(.FLines.Count - 1 >= ehStart) AndAlso CInt(StartsWith(LTrim(.Lines(ehStart), " "), "On Error ")) Then
				If StartLine <> "" Then
					.ReplaceLine ehStart, Space(n) & StartLine
				Else
					.DeleteLine ehStart
					If iSelStartLine > ehStart Then iSelStartLine -= 1
				End If
			ElseIf StartLine <> "" Then
				.InsertLine ehStart, Space(n) & StartLine
				iSelStartLine += 1
			End If
			Dim t As Boolean
			If Bosh Then
				ehEnd = .FLines.Count - 1
			Else
				For i As Integer = iSelStartLine To .FLines.Count - 1
					FECLine = .FLines.Items[i]
					If FECLine->ConstructionIndex >= 17  Then
						If FECLine->ConstructionPart = 2 Then
							t = True
							ehEnd = i - 1
							Exit For
						Else
							t = True
							ehEnd = i - 1
							Exit For
						End If
					End If
				Next i
				If Not t Then
					ehEnd = i
				End If
			End If
			t = False
			Dim p As Integer
			For i As Integer = ehEnd - 1 To ehStart Step -1
				FECLine = .FLines.Items[i]
				If FECLine->ConstructionIndex >= 17 Then
					p = i
					Exit For
				ElseIf StartsWith(.Lines(i), Space(n) & ExitLine) Then
					p = i
					t = True
					Exit For
				End If
			Next i
			If t Then
				FECLine = .FLines.Items[ehEnd]
				If FECLine->ConstructionIndex >= 17 Then
					ehEnd -= 1
				End If
				For j As Integer = ehEnd To p Step -1
					.DeleteLine j
					ehEnd -= 1
				Next j
			End If
			If StartLine <> "" And StartLine <> "On Error Resume Next" Then
				.InsertLine ehEnd + 1, Space(n) & ExitLine
				.InsertLine ehEnd + 2, Space(Max(0, n - 4)) & "ErrorHandler:"
				.InsertLine ehEnd + 3, Space(n) & "MsgBox ErrDescription(Err) & "" ("" & Err & "") "" & _"
				.InsertLine ehEnd + 4, Space(n + 4) & """in line "" & Erl() & "" (Handler line: "" & __LINE__ & "") "" & _"
				.InsertLine ehEnd + 5, Space(n + 4) & """in function "" & ZGet(Erfn()) & "" (Handler function: "" & __FUNCTION__ & "") "" & _"
				.InsertLine ehEnd + 6, Space(n + 4) & """in module "" & ZGet(Ermn()) & "" (Handler file: "" & __FILE__ & "") """
				If EndLine <> "" Then .InsertLine ehEnd + 7, Space(n) & EndLine
			End If
		End If
		.Changed("Error handling")
		.UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.RemoveErrorHandling()
	SetErrorHandling "", ""
End Sub

Sub TabWindow.NumberOff(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("Raqamlarni olish")
		If StartLine = -1 Or EndLine = -1 Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			StartLine = iSelStartLine
			EndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		End If
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n
		For i As Integer = StartLine To EndLine
			FECLine = .FLines.Items[i]
			n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
			If StartsWith(LTrim(*FECLine->Text), "?") Then
				Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
				If IsNumeric(Mid(Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
					WLet(FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1))
				End If
			ElseIf StartsWith(LTrim(*FECLine->Text), "_L_") Then
				WLet(FECLine->Text, Mid(LTrim(*FECLine->Text), 4))
			End If
		Next i
		.Changed("Raqamlarni olish")
		.UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.PreprocessorNumberOff()
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("Remove Preprocessor Numbering")
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n
		For i As Integer = .LinesCount - 1 To 0 Step -1
			FECLine = .FLines.Items[i]
			If StartsWith(LTrim(LCase(*FECLine->Text), Any !"\t "), "#print __line__") Then
				.DeleteLine i
			End If
		Next i
		.Changed("Remove Preprocessor Numbering")
		.UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.SortLines(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Var tb = Cast(TabWindow Ptr, pTabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	With tb->txtCode
		.UpdateLock
		.Changing("Sort Lines")
		If StartLine = -1 Or EndLine = -1 Then
			Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
			StartLine = iSelStartLine
			EndLine = iSelEndLine - IIf(iSelEndChar = 0, 1, 0)
		End If
		Dim As EditControlLine Ptr FECLine
		Dim As Integer n = 0
		Dim As WStringList Lines
		For i As Integer = StartLine To EndLine
			FECLine = .FLines.Items[i]
			Lines.Add *FECLine->Text
		Next i
		Lines.Sort
		For i As Integer = StartLine To EndLine
			FECLine = .FLines.Items[i]
			WLet(FECLine->Text, Lines.Item(n))
			n = n + 1
		Next i
		.Changed("Sort Lines")
		.UpdateUnLock
		'.ShowCaretPos True
	End With
End Sub

Sub TabWindow.ProcedureNumberOn(bMacro As Boolean = False)
	Dim As Integer ehStart, ehEnd
	GetProcedureLines ehStart, ehEnd
	NumberOn ehStart, ehEnd, bMacro
End Sub

Sub TabWindow.ProcedureNumberOff
	Dim As Integer ehStart, ehEnd
	GetProcedureLines ehStart, ehEnd
	NumberOff ehStart, ehEnd
End Sub

Sub TabWindow.Define
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k, Pos1
	txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim sLine As WString Ptr = @txtCode.Lines(iSelEndLine)
	Dim As String FuncName, TypeName, OldTypeName, Parameters, sWord = txtCode.GetWordAt(iSelEndLine, iSelEndChar - 1)
	Dim As TypeElement Ptr te, te1, te2, teOld
	If sWord = "" Then Exit Sub
	With pfTrek->lvTrek.ListItems
		.Clear
		GetLeftArgTypeName(@This, iSelEndLine, GetNextCharIndex(*sLine, iSelEndChar), te2, teOld, OldTypeName)
		If teOld <> 0 OrElse OldTypeName <> "" Then
			If OldTypeName <> "" Then
				TypeName = OldTypeName
			Else
				TypeName = teOld->TypeName
			End If
			If TypeName = "" AndAlso teOld <> 0 AndAlso teOld->Value <> "" Then
				TypeName = GetTypeFromValue(@This, teOld->Value)
			End If
			FListItems.Clear
			If Types.Contains(TypeName) Then
				FillIntellisense TypeName, @Types, True, True
			ElseIf Enums.Contains(TypeName) Then
				FillIntellisense TypeName, @Enums, True, True
			ElseIf pComps->Contains(TypeName) Then
				FillIntellisense TypeName, pComps, True, True
			ElseIf pGlobalTypes->Contains(TypeName) Then
				FillIntellisense TypeName, pGlobalTypes, True, True
			ElseIf pGlobalEnums->Contains(TypeName) Then
				FillIntellisense TypeName, pGlobalEnums, True, True
			End If
			For i As Integer = 0 To FListItems.Count - 1
				te = FListItems.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
		Else
			If te2 <> 0 AndAlso (Not (te2->FileName = FileName AndAlso te2->StartLine = iSelEndLine)) Then
				.Add te2->DisplayName
				.Item(.Count - 1)->Text(1) = te2->Parameters
				.Item(.Count - 1)->Text(2) = WStr(te2->StartLine + 1)
				.Item(.Count - 1)->Text(3) = te2->FileName
				.Item(.Count - 1)->Text(4) = te2->Comment
				.Item(.Count - 1)->Tag = te2->TabPtr
			End If
			If cboFunction.ItemIndex > -1 Then te1 = cboFunction.Items.Item(cboFunction.ItemIndex)->Object
			Pos1 = InStr(cboFunction.Text, "["): If Pos1 > 0 Then FuncName = Trim(Left(cboFunction.Text, Pos1 - 1)): TypeName = FuncName
			Pos1 = InStr(FuncName, "."): If Pos1 > 0 Then TypeName = Trim(Left(FuncName, Pos1 - 1))
			If te1 <> 0 AndAlso te1->Elements.Contains(sWord) Then
				For i As Integer = 0 To te1->Elements.Count - 1
					te = te1->Elements.Object(i)
					If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
						If te->StartLine = iSelEndLine Then Continue For
						If te = te2 Then Continue For
						.Add te->DisplayName
						.Item(.Count - 1)->Text(1) = te->Parameters
						.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
						.Item(.Count - 1)->Text(3) = te->FileName
						.Item(.Count - 1)->Text(4) = te->Comment
						.Item(.Count - 1)->Tag = te->TabPtr
					End If
				Next
			End If
			If TypeName <> "" Then
				If Types.Contains(TypeName) Then
					FillIntellisense TypeName, @Types, True
				ElseIf Enums.Contains(TypeName) Then
					FillIntellisense TypeName, @Enums, True
				ElseIf pComps->Contains(TypeName) Then
					FillIntellisense TypeName, pComps, True
				ElseIf pGlobalTypes->Contains(TypeName) Then
					FillIntellisense TypeName, pGlobalTypes, True
				ElseIf pGlobalEnums->Contains(TypeName) Then
					FillIntellisense TypeName, pGlobalEnums, True
				End If
				If FListItems.Contains(sWord) Then
					For i As Integer = 0 To FListItems.Count - 1
						te = FListItems.Object(i)
						If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
							If te->StartLine = iSelEndLine Then Continue For
							If te = te2 Then Continue For
							.Add te->DisplayName
							.Item(.Count - 1)->Text(1) = te->Parameters
							.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
							.Item(.Count - 1)->Text(3) = te->FileName
							.Item(.Count - 1)->Text(4) = te->Comment
							.Item(.Count - 1)->Tag = te->TabPtr
						End If
					Next
				End If
				FListItems.Clear
			End If
			For i As Integer = 0 To Functions.Count - 1
				te = Functions.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
			For i As Integer = 0 To Args.Count - 1
				te = Args.Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->StartLine = iSelEndLine Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
			For i As Integer = 0 To pGlobalFunctions->Count - 1
				te = pGlobalFunctions->Object(i)
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->FileName = FileName Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
			For i As Integer = 0 To pGlobalArgs->Count - 1
				te = Cast(TypeElement Ptr, pGlobalArgs->Object(i))
				If te <> 0 AndAlso LCase(Trim(te->Name)) = LCase(sWord) Then
					If te->FileName = FileName Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
			For i As Integer = 0 To pComps->Count - 1
				te = pComps->Object(i)
				If te <> 0 AndAlso LCase(Trim(pComps->Item(i))) = LCase(sWord) Then
					If te->FileName = FileName Then Continue For
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
			For i As Integer = 0 To pGlobalTypes->Count - 1
				te = pGlobalTypes->Object(i)
				If te <> 0 AndAlso LCase(Trim(pGlobalTypes->Item(i))) = LCase(sWord) Then
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
			For i As Integer = 0 To pGlobalEnums->Count - 1
				te = pGlobalEnums->Object(i)
				If te <> 0 AndAlso LCase(Trim(pGlobalEnums->Item(i))) = LCase(sWord) Then
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
					For j As Integer = 0 To te->Elements.Count - 1
						te1 = te->Elements.Object(j)
						If te1 <> 0 AndAlso LCase(Trim(te1->Name)) = LCase(sWord) Then
							If te1 = te2 Then Continue For
							.Add te1->DisplayName
							.Item(.Count - 1)->Text(1) = te1->Parameters
							.Item(.Count - 1)->Text(2) = WStr(te1->StartLine + 1)
							.Item(.Count - 1)->Text(3) = te1->FileName
							.Item(.Count - 1)->Text(4) = te1->Comment
							.Item(.Count - 1)->Tag = te1->TabPtr
						End If
					Next
				End If
			Next
			For i As Integer = 0 To pGlobalNamespaces->Count - 1
				te = pGlobalNamespaces->Object(i)
				If te <> 0 AndAlso LCase(Trim(pGlobalNamespaces->Item(i))) = LCase(sWord) Then
					If te = te2 Then Continue For
					.Add te->DisplayName
					.Item(.Count - 1)->Text(1) = te->Parameters
					.Item(.Count - 1)->Text(2) = WStr(te->StartLine + 1)
					.Item(.Count - 1)->Text(3) = te->FileName
					.Item(.Count - 1)->Text(4) = te->Comment
					.Item(.Count - 1)->Tag = te->TabPtr
				End If
			Next
		End If
		If .Count = 0 Then
		ElseIf .Count = 1 Then
			SelectSearchResult .Item(0)->Text(3), Val(.Item(0)->Text(2)), , , .Item(0)->Tag, sWord
		Else
			If pfTrek->ShowModal = ModalResults.OK Then
				Var item = pfTrek->lvTrek.SelectedItem
				If item <> 0 Then
					SelectSearchResult item->Text(3), Val(item->Text(2)), , , item->Tag, sWord
				End If
			End If
		End If
	End With
End Sub
