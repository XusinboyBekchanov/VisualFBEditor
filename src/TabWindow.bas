#Include Once "EditControl.bi"
#Include Once "mff/Dictionary.bi"
#Include Once "mff/ToolPalette.bi"
Dim Shared As WStringList mlKeys, mlTexts
Dim Shared As WStringList Comps
     
Using My.Sys.Forms

Dim Shared As Toolbar tbStandard, tbExplorer, tbForm, tbProperties, tbEvents
Dim Shared As ToolPalette tbToolBox
Dim Shared As TabControl tabLeft, tabRight, tabDebug
Dim Shared As TreeView tvExplorer, tvVar, tvPrc, tvThd, tvWch
Dim Shared As TextBox txtOutput
Dim Shared As TabControl tabCode, tabBottom
Dim Shared As ListView lvErrors, lvSearch, lvProperties, lvEvents
Dim Shared As ImageList imgList, imgListTools, imgListStates
Dim Shared As ToolButton Ptr SelectedTool
Dim Shared As PopupMenu mnuForm, mnuVars, mnuExplorer

Declare Sub tabBottom_SelChange(ByRef Sender As Control, NewIndex As Integer)
Declare Sub CompleteWord()

Function ML(ByRef V As WString) ByRef As Wstring
    If mlKeys.Contains(V) Then
        If mlTexts.Item(mlKeys.IndexOf(V)) <> "" Then
            Return mlTexts.Item(mlKeys.IndexOf(V))
        End If
    End If
    Return V
End Function

Type ExplorerElement
    FileName As WString Ptr
    MainFileName As WString Ptr
    Declare Destructor
End Type

Destructor ExplorerElement
    If FileName Then Deallocate FileName
    If MainFileName Then Deallocate MainFileName
End Destructor

Type TypeElement
    Private:
        _typeName As WString Ptr
    Public:
        Name As String * 50
        EnumTypeName As String * 50
        ElementType As String * 50
        Locals As Integer
        Parameters As WString Ptr
        Comment As WString Ptr
        StartLine As Integer
        EndLine As Integer
        Find As Boolean
        Declare Destructor
        Declare Property TypeName ByRef As WString
        Declare Property TypeName(ByRef Value As WString)
End Type

Property TypeElement.TypeName ByRef As WString
    Return WGet(_typeName)
End Property

Property TypeElement.TypeName(ByRef Value As WString)
    WLet _typeName, Value
End Property

Destructor TypeElement
    WDeAllocate _typeName
    WDeAllocate Parameters
    WDeAllocate Comment
End Destructor

Type ToolBoxItem Extends TypeElement
    BaseName As String * 50
    LibraryName As WString Ptr
    LibraryFile As WString Ptr
    IncludeFile As WString Ptr
    ControlType As Integer
    Elements As WStringList
    Declare Destructor
End Type

Destructor ToolBoxItem
    WDeAllocate LibraryName
    WDeAllocate LibraryFile
    WDeAllocate IncludeFile
End Destructor

Type PTabWindow As TabWindow Ptr

#IfDef __USE_GTK__
Type CloseButton Extends Panel
#Else
Type CloseButton Extends Label
#EndIf
    Public:
        OldBackColor As Integer
        OldForeColor As Integer
        MouseIn As Boolean
        tbParent As PTabWindow
        #IfDef __USE_GTK__
			layout As PangoLayout Ptr 
        #EndIf
        Declare Constructor
        Declare Destructor
End Type

Type TabWindow Extends TabPage
    Private:
        FCaptionNew As WString Ptr
        FFileName As WString Ptr
        FLine As WString Ptr
        FLine1 As WString Ptr
        FLine2 As WString Ptr
        tbi As ToolBoxItem Ptr
        tbi2 As ToolBoxItem Ptr
        Dim As Any Ptr Ctrl, CurCtrl
        i As Integer
        j As Integer
        lvItem As ListViewItem Ptr
        iTemp As Integer
        pTemp As Any Ptr
        te As TypeElement Ptr
        te2 As TypeElement Ptr
        Dim As EditControlLine Ptr ECLine
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Dim frmName As String
        Dim As Boolean b, t, c
        Dim As Integer Pos1, Pos2, l, p, p1
        Dim As Integer lvPropertyCount, lvEventCount
        Dim As String ArgName, PropertyName, FLin
        Dim sText As String
        Dim TypeName As String
        Dim As ComboBoxItem Ptr CBItem
        Dim bTemp As Boolean
        Dim As Integer lLeft, lTop, lWidth, lHeight
        Dim PropertyCtrl As Any Ptr
        Declare Sub SaveTab
        Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
    Public:
        Declare Sub FillProperties(ByRef ClassName As WString)
        Declare Sub FillIntellisense(ByRef ClassName As WString)
        Functions As WStringList
        mnuCode As PopupMenu
        Dim bNotDesign As Boolean
        tn As TreeNode Ptr
        DownLine As Integer
        DownLineSelStart As Integer
        DownLineSelEnd As Integer
        lblPlusMinus As label
        pnlTop As Panel
        pnlTopCombo As Panel
        pnlCode As Panel
        pnlEdit As Panel
        pnlLeft As Panel
        lblLeft As Label
        splCodeForm As Splitter
        splFormList As Splitter
        pnlForm As Panel
        lvComponentsList As ListView
        tbrLeft As ToolBar
        tbrTop As ToolBar
        pnlToolbar As Panel
        txtCode As EditControl
        cboClass As ComboBoxEx
        cboFunction As ComboBoxEx
        btnClose As CloseButton
        Des As My.Sys.Forms.Designer Ptr
        splForm As Splitter
        #IfDef __USE_GTK__
        	overlay As GtkWidget Ptr
			layout As GtkWidget Ptr
        #EndIf
        Declare Property FileName ByRef As WString
        Declare Property FileName(ByRef Value As WString)
        Declare Property Modified As Boolean
        Declare Property Modified(Value As Boolean)
        Declare Property Caption ByRef As WString
        Declare Property Caption(ByRef Value As WString)
        Declare Operator Cast As TabPage Ptr
        Declare Function GetLine(lLine As Long, ByRef strLine As WString = "", lUpLine As Long = 0, lDwLine As Long = 0, sc As Long = 0) ByRef As WString
        Declare Function CloseTab As Boolean
        Declare Sub FillAllProperties
        Declare Sub ChangeName(ByRef OldName As String, ByRef NewName As String)
        Declare Function ReadObjProperty(ByRef Ctrl As Any Ptr, ByRef PropertyName As String) ByRef As WString
        Declare Function WriteObjProperty(ByRef Ctrl As Any Ptr, ByRef PropertyName As String, ByRef Value As WString) As Boolean
        Declare Function GetFormattedPropertyValue(ByRef Cpnt As Any Ptr, ByRef PropertyName As String) ByRef As WString
        Declare Sub SetErrorHandling(StartLine As String, EndLine As String)
        Declare Sub RemoveErrorHandling
        Declare Sub Versioning
        Declare Sub Save
        Declare Sub SaveAs
        Declare Sub NumberOn
        Declare Sub NumberOff
        Declare Sub ProcedureNumberOn
        Declare Sub ProcedureNumberOff
        Declare Sub Comment
        Declare Sub UnComment
        Declare Sub Indent
        Declare Sub Outdent
        Declare Sub Define
        Declare Sub FormDesign(NotForms As Boolean = False)
        Declare Sub FormatBlock
        Declare Constructor(ByRef wFileName As WString = "", bNewForm As Boolean = False, TreeN As TreeNode Ptr = 0)
        Declare Destructor
End Type

Dim Shared As PopupMenu mnuCode

Public Sub MoveCloseButtons()
    Dim As Rect RR
    For i As Integer = 0 To TabCode.TabCount - 1
        Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, TabCode.Tabs[i])
        If tb = 0 Then Continue For
        #IfNDef __USE_GTK__
			TabCode.Perform(TCM_GETITEMRECT, tb->Index, CInt(@RR))
			MoveWindow tb->btnClose.Handle, RR.Right - 18, 4, 14, 14, True
        #EndIf
        'DeAllocate tb
    Next i
End Sub

Sub PopupClick(ByRef Sender As My.Sys.Object)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 OrElse tb->Des = 0 Then Exit Sub
    Select Case Sender.ToString
    Case "Delete": tb->Des->DeleteControl(tb->Des->SelectedControl)
    Case "Copy":         
    Case "Cut":         
    Case "Paste":         
    Case "SendToBack":         
    Case "Properties":         
   	End Select
End Sub

Function FileNameExists(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
    If tn = 0 Then Return 0
    Dim As ExplorerElement Ptr ee = tn->Tag
    If ee <> 0 Then
        If Replace(LCase(*ee->FileName), "\", "/") = Replace(LCase(FileName), "\", "/", , , 1) Then
            Return tn
        End If
    End If
    Dim tn2 As TreeNode Ptr
    For i As Integer = 0 To tn->Nodes.Count - 1
        tn2 = FileNameExists(tn->Nodes.Item(i), FileName)
        If tn2 <> 0 Then Return tn2
    Next i
    Return 0
End Function
        
Function AddTab(ByRef FileName As WString = "", bNew As Boolean = False, TreeN As TreeNode Ptr = 0) As TabWindow Ptr
    On Error Goto ErrorHandler
    Dim bFind As Boolean
    Dim FileName_ As WString Ptr
    Dim FileName_1 As WString Ptr
    WLet FileName_, Replace(FileName, "\", "/")
    If EndsWith(*FileName_, ":") Then *FileName_ = Left(*FileName_, Len(*FileName_) - 1)
    WLet FileName_1, Replace(*FileName_, "/", "\")
    Dim As TabWindow Ptr tb
    If FileName <> "" Then
        For i As Integer = 0 To tabCode.TabCount - 1
            If LCase(Cast(TabWindow Ptr, tabCode.Tabs[i])->FileName) = LCase(*FileName_) OrElse LCase(Cast(TabWindow Ptr, tabCode.Tabs[i])->FileName) = LCase(*FileName_1) Then
                bFind = True
                tb = Cast(TabWindow Ptr, tabCode.Tabs[i])
                tb->SelectTab
                Exit For
            End If
        Next i
        If Not bFind Then
            Dim tn2 As TreeNode Ptr
            For i As Integer = 0 To tvExplorer.Nodes.Count - 1
                tn2 = FileNameExists(tvExplorer.Nodes.Item(i), *FileName_)
                If tn2 <> 0 Then
                    TreeN = tn2
                    Exit For
                End If
            Next i
        End If
    End If
    tabCode.UpdateLock
    If Not bFind Then
        tb = New TabWindow(*FileName_, bNew, TreeN)
        With *tb
            '.txtCode.ContextMenu = @mnuCode
            tabCode.AddTab(Cast(TabPage Ptr, tb))
            #IfDef __USE_GTK__
				'.layout = gtk_layout_new(NULL, NULL)
				'gtk_widget_set_size_request(.layout, 16, 16)
				'gtk_layout_put(gtk_layout(.layout), .btnClose.widget, 0, 0)
				gtk_box_pack_end (GTK_BOX (._box), .btnClose.widget, false, false, 0)
				gtk_widget_show_all(._box)
            #Else
				tabCode.Add(@.btnClose)
            #EndIf
            .SelectTab
            .tbrTop.Buttons.Item(1)->Checked = True
            If FileName <> "" Then
                .txtCode.LoadFromFile(*FileName_)
                .Modified = bNew
            End If
            .FormDesign
        End With
        MoveCloseButtons
    End If
    tb->txtCode.SetFocus
    tabCode.UpdateUnLock
    WDeallocate FileName_
    WDeallocate FileName_1
    Return tb
    Exit Function
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Function

Const SingleConstructions = "else,#else,next,do,loop,wend"

Sub ClearMessages() '...'
    txtOutput.Text = ""
    txtOutput.Update
End Sub

Sub ShowMessages(ByRef msg As WString)
    tabBottom_SelChange(tabBottom, 0)
    txtOutput.SetSel txtOutput.GetTextLength, txtOutput.GetTextLength
    txtOutput.SelText = msg & wchr(13) & wchr(10)
    tabBottom.TabIndex = 0
    tabBottom.Update
    txtOutput.Update
    frmMain.Update
    #IfDef __USE_GTK__
		While gtk_events_pending()
			gtk_main_iteration()
		Wend
    #EndIf
'    txtOutput.ScrollToCaret
End Sub

Sub m(ByRef msg As WString) '...'
    ShowMessages msg
End Sub

Dim Shared TextChanged As Boolean
Sub OnChangeEdit(BYREF Sender As Control)
    Static CurLine As Integer, bChanged As Boolean
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    tb->Modified = True
    TextChanged = True
'    'Exit Sub
'    With tb->txtCode
'        If Not .Focused Then Exit Sub
'        tb->FormDesign tb->tbrTop.Buttons.Item(1)->Checked
'    End With    
End Sub

Sub OnMouseDownEdit(BYREF Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
    If MouseButton = 0 And Shift = 9 Then
        
    End If
End Sub

Function IsLabel(ByRef LeftA As WString) As Boolean
    If Right(RTrim(LeftA, " "), 1) = ":" Then
        Dim strLeftA As String
        strLeftA = LCase(Left(LeftA, Len(LeftA) - 1))
        For i As Integer = 1 To Len(LeftA)
            If InStr(SingleConstructions, Mid(LeftA, i, 1)) > 0 Then Return False
        Next
        Return True
    Else
        Return False
    End If  
End Function

Function GetTextByLine(ByRef subject As WString, lLine As Integer) ByRef As WString
    Dim AS Integer Pos1 = Instr(subject, !"\r"), l = Len(!"\r"), c = 0, p = 1
    Dim As WString Ptr FLin: WReallocate FLin, Len(subject): *FLin = ""
    While Pos1 > 0
        c = c + 1
        If lLine = c Then *FLin = Mid(subject, p, Pos1 - p): Return *FLin
        p = Pos1 + l
        Pos1 = Instr(p, subject, !"\r")
    Wend
    If lLine = c + 1 Then *Flin = Mid(subject, p, Len(subject) - p + 1)
    Return *FLin
End Function

'Function TabWindow.GetLine(lLine As Long, ByRef strLine As WString = "", lUpLine As Long = 0, lDwLine As Long = 0, sc As Long = 0) ByRef As WString
    'Dim b As WString Ptr, c As Long, d As Long, k As Long, LeftA As String, P As Long, Pos As Long
    'WReAllocate FLine, txtCode.GetTextLength
    'Do While lLine - c - 1 > 0
        'b = @txtCode.Lines(lLine - c - 1)
        'If Right(*b, 2) <> " _" Then Exit Do
        '*FLine = *b & !"\r" & *FLine: c = c + 1
    'Loop
    'b = @txtCode.Lines(lLine)
    'If sc <> 0 Then
        '*b = Left(*b, sc - 1)
    'End If
    '*FLine = *FLine & *b
    'Do While Right(*b, 2) = " _"
        'b = @txtCode.Lines(lLine + d + 1)
        '*FLine = *FLine & !"\r" & *b: d = d + 1
    'Loop
    'Redim As String m()
    'Split(*FLine, m, """")
    'WReAllocate b, Len(*FLine)
    '*b = "": If UBound(m) > -1 Then *b = m(0)
    'For k = 2 To UBound(m) Step 2
        '*b = *b & """" & Space(Len(m(k - 1))) & """" & m(k)
    'Next k
    'Pos = InStr(*b, "'")
    'If Pos > 0 Then *b = Left(*b, Pos - 1)
    'Pos = InStr(*b & " ", " ")
    'If Pos > 1 Then
        'LeftA = Left(*FLine, Pos - 1)
        'If IsNumeric(LeftA) Or IsLabel(LeftA) Then *b = String(" ", Pos) & Mid(*b, Pos + 1)
    'End If
    'strLine = b
    'lUpLine = c
    'lDwLine = d
    'Return *FLine
'End Function

'Sub TabWindow.HandleIsAllocated(ByRef Sender As Control)
'    With *Cast(TabWindow Ptr, @Sender)
'        If .frmForm Then
'            'If .pnlForm.Handle = 0 Then .pnlForm.CreateWnd
'            '.frmForm->Parent = .pnlForm
'            '.frmForm->Visible = True
'        End IF
'    End With
'End Sub

Function GetFolderName(ByRef FileName As WString) ByRef As WString
    Dim Pos1 As Long = InstrRev(FileName, "\")
    Dim Pos2 As Long = InstrRev(FileName, "/")
    If Pos1 = 0 OrElse Pos2 > Pos1 Then Pos1 = Pos2
    Dim s  As WString Ptr ' = CAllocate((Pos1 + 1) * SizeOf(WString))
    If Pos1 > 0 then
        WLet s, Left(FileName, Pos1)
        Return *s
    End If
    Return ""
End Function

Function GetFileName(ByRef FileName As WString) ByRef As WString
    Dim Pos1 As Long = InstrRev(FileName, "\")
    Dim Pos2 As Long = InstrRev(FileName, "/")
    If Pos1 = 0 OrElse Pos2 > Pos1 Then Pos1 = Pos2
    Dim s As WString Ptr '= CAllocate((Len(FileName) + 1) * SizeOf(WString))
    If Pos1 > 0 Then
        WLet s, Mid(FileName, Pos1 + 1)
        Return *s
    End If
    Return FileName
End Function

Function GetBakFileName(ByRef FileName As WString) ByRef As WString
    Dim Pos1 As Long = InstrRev(FileName, ".")
    Dim s As WString Ptr '= CAllocate((Len(FileName) + 4 + 1) * SizeOf(WString))
    If Pos1 = 0 Then Pos1 = Len(FileName)
    If Pos1 > 0 Then
        WLet s, Left(FileName, Pos1 - 1) & "_bak" & Mid(FileName, Pos1)
        Return *s
    End If
End Function

Function GetFirstCompileLine(ByRef FileName As WString) ByRef As WString
    If Open(FileName For Input Encoding "utf-8" As #1) = 0 Then
		Dim sLine As WString Ptr
	    Dim As Integer i, n, l = 0
	    Dim As Boolean k(10)
	    k(l) = True
		WReallocate sLine, LOF(1)
	    Do Until EOF(1)
	        Line Input #1, *sLine
	        If StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifdef __fb_win32__") Then
				l = l + 1
				#IfDef __FB_Win32__
					k(l) = True
				#Else
					k(l) = False
				#EndIf
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifndef __fb_win32__") Then
				l = l + 1
				#IfNDef __FB_Win32__
					k(l) = True
				#Else
					k(l) = False
				#EndIf
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifdef __fb_64bit__") Then
				l = l + 1
				k(l) = tbStandard.Buttons.Item("B64")->Checked
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#ifndef __fb_64bit__") Then
				l = l + 1
				k(l) = Not tbStandard.Buttons.Item("B64")->Checked
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#else") Then
				k(l) = Not k(l)
			ElseIf StartsWith(LTrim(LCase(*sLine), Any !"\t "), "#endif") Then
				l = l - 1
				If l < 0 Then 
					Close #1
					Return ""
				End If
			Else
				For i = 0 To l
					If k(i) = False Then Exit For
				Next
				If i > l Then
						Close #1
						Return *sLine
					End If
			End If
			If l >= 10 Then
				Close #1
				Return ""
			End If
	    Loop
	    Close #1
	End If
    Return ""
End Function

Function GetExeFileName(ByRef FileName As WString, ByRef sLine As WString) ByRef As WString
    Dim As WString Ptr CompileWith: Wlet CompileWith, LTrim(sLine)
    Dim As WString Ptr pFileName:    Wlet pFileName, FileName
    Dim As WString Ptr ExeFileName
    Dim As String SearchChar
    Dim s As WString Ptr 
    Dim As Long Pos1, Pos2
    If Left(LCase(LTrim(*CompileWith, Any !"\t ")), 10) = "'#compile " Then
        Pos1 = Instr(*CompileWith, " -x ")
        If Pos1 > 0 Then
            If Mid(*CompileWith, Pos1 + 4, 1) = """" Then
                SearchChar = """"
            Else
                SearchChar = " "
            End If
            Pos2 = Instr(Pos1 + 5, *CompileWith, SearchChar)
            If Pos2 > 0 Then
                Wlet ExeFileName, Mid(*CompileWith, Pos1 + 5, Pos2 - Pos1 - 5)
                If CInt(Instr(*ExeFileName, ":") = 0) AndAlso CInt(Not StartsWith(*ExeFileName, "/")) Then
                    Wlet s, GetFolderName(*pFileName) + *ExeFileName
                    Return *s
                Else
                    Return *ExeFileName
                End If    
            End If
        End If
    End If
    Pos1 = InstrRev(*pFileName, ".")
    If Pos1 = 0 Then Pos1 = Len(*pFileName) + 1
    If Pos1 > 0 then
		#IfDef __USE_GTK__
			Wlet s, Left(*pFileName, Pos1 - 1) & IIF(Instr(*CompileWith, "-dll"), ".so", "")
        #Else
			Wlet s, Left(*pFileName, Pos1 - 1) & IIF(Instr(*CompileWith, "-dll"), ".dll", ".exe")
        #EndIf
        Return *s
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
        End if
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
Sub CloseButton_MouseUp(BYREF Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
    Dim tb As TabWindow Ptr = Cast(CloseButton Ptr, @Sender)->tbParent
    If tb = 0 Then Exit Sub
    tb->CloseTab
    Delete tb
End Sub
            
Sub CloseButton_MouseMove(BYREF Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
    Dim btn As CloseButton Ptr = Cast(CloseButton Ptr, @Sender)
    If btn->BackColor = clRed Then Exit Sub
    #IfNDef __USE_GTK__
		btn->BackColor = clRed
		btn->Font.Color = clWhite
    #EndIf
    btn->MouseIn = True
    'DeAllocate btn
End Sub

Sub CloseButton_MouseLeave(BYREF Sender As Control)
    Dim btn As CloseButton Ptr = Cast(CloseButton Ptr, @Sender)
    #IfNDef __USE_GTK__
		btn->BackColor = btn->OldBackColor
		btn->Font.Color = btn->OldForeColor
    #EndIf
    btn->MouseIn = False
End Sub

#IfDef __USE_GTK__
	Function CloseButton_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
		Dim As CloseButton Ptr cb = Cast(Any Ptr, data1)
		
		cairo_select_font_face(cr, "Noto Mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
		cairo_set_font_size(cr, 11)
		
		#IfDef __USE_GTK3__
			Var width1 = gtk_widget_get_allocated_width (widget)
			Var height1 = gtk_widget_get_allocated_height (widget)
		#Else
			Var width1 = widget->allocation.width
			Var height1 = widget->allocation.height
		#EndIf
		
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
		return FALSE
	End Function
	
	Function CloseButton_OnExposeEvent(widget As GtkWidget Ptr, event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
		Dim As cairo_t Ptr cr = gdk_cairo_create(event->window)
		CloseButton_OnDraw(widget, cr, data1)
		cairo_destroy(cr)
		return FALSE
	End Function
#EndIf

Constructor CloseButton
    Base.OnMouseUp = @CloseButton_MouseUp
    OnMouseMove = @CloseButton_MouseMove
    OnMouseLeave = @CloseButton_MouseLeave
    OldBackColor = This.BackColor
    OldForeColor = This.Font.Color
    #IfDef __USE_GTK__
    	#IfDef __USE_GTK3__
			g_signal_connect(widget, "draw", G_CALLBACK(@CloseButton_OnDraw), @This)
		#Else
			g_signal_connect(widget, "expose-event", G_CALLBACK(@CloseButton_OnExposeEvent), @This)
		#EndIf
		This.Width = 20
		This.Height = 20
		Dim As PangoContext Ptr pcontext
		pcontext = gtk_widget_create_pango_context(widget)
		layout = pango_layout_new(pcontext)
		Dim As PangoFontDescription Ptr desc
		desc = pango_font_description_from_string ("Noto Mono 11")
		pango_layout_set_font_description (layout, desc)
		pango_font_description_free (desc)
    #Else
		This.Alignment = taCenter
		Caption = "×"
    #EndIf
    'SubClass = True
End Constructor

Destructor CloseButton
    
End Destructor

Property TabWindow.Caption ByRef As WString
    Return WGet(FCaptionNew)
End Property

Property TabWindow.Caption(ByRef Value As WString)
    FCaptionNew = ReAllocate(FCaptionNew, (Len(Value) + 1) * SizeOf(WString))
    *FCaptionNew = Value
    #IfDef __USE_GTK__
		Base.Caption = Value
    #Else
		Base.Caption = Value + Space(5)
    #EndIf
End Property

Property TabWindow.FileName ByRef As WString
    Return WGet(FFileName)
End Property

Property TabWindow.FileName(ByRef Value As WString) '...'
    FFileName = Cast(WString Ptr, ReAllocate(FFileName, (Len(Value) + 1) * SizeOf(WString)))
    *FFileName = Value
End Property

Operator TabWindow.Cast As TabPage ptr '...'
    Return Cast(TabPage Ptr, @This)
End Operator

Sub TabWindow.SaveTab '...'
    'FileCopy FileName, GetBakFileName(FileName)
    txtCode.SaveToFile(FileName) ', False
    Modified = False
End Sub

Sub TabWindow.SaveAs
    SaveD.Filter = ML("Module FreeBasic") & " (*.bas)|*.bas|" & ML("Include File FreeBasic") & " (*.bi)|*.bi|" & ML("All Files") & "|*.*|"
    If SaveD.Execute Then
        If FileExists(SaveD.Filename) Then
			Select Case MsgBox(ML("Want to replace the file") & " """ & SaveD.Filename & """?", "Visual FB Editor", mtWarning, btYesNoCancel)
			Case mrYES: SaveTab
			Case mrNO: SaveAs: Return
			End Select
        End If
        Caption = GetFileName(SaveD.Filename)
        tn->Text = Caption
        FileName = SaveD.Filename
        SaveTab
    End If
End Sub

Sub TabWindow.Save '...'
    If FileName <> "" Then SaveTab Else SaveAs
End Sub

Function TabWindow.CloseTab As Boolean
    If txtCode.Modified Then
		Select Case MsgBox(ML("Want to save the file") & " """ & Caption & """?", "Visual FB Editor", mtWarning, btYesNoCancel)
		Case mrYes: Save
		Case mrNo:
		Case mrCancel: Return False
		End Select
    End If
    tabCode.Remove(@btnClose)
    btnClose.FreeWnd
    tabCode.DeleteTab(This.Index)
    If tn <> 0 Then
        If tvExplorer.Nodes.IndexOf(tn) <> -1 Then
            tvExplorer.Nodes.Remove tvExplorer.Nodes.IndexOf(tn)
            If MainNode = tn Then MainNode = 0
        End If
	End If
    MoveCloseButtons
	FreeWnd
    Return True
End Function

'Sub TabWindow.FindProceduresAndTypes
    
'End Sub

Dim Shared FPropertyItems As WStringList
Dim Shared FListItems As WStringList
Sub TabWindow.FillProperties(ByRef ClassName As WString)
    If Comps.Contains(ClassName) Then
        tbi = Comps.Object(Comps.IndexOf(ClassName))
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
            FillProperties tbi->BaseName
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
    Dim tbi As ToolBoxItem Ptr
    Dim te As TypeElement Ptr
    Dim TypeN As String = WithoutPtr(ClassName)
    If Instr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InstrRev(TypeN, ".") + 1)
    If Comps.Contains(TypeN) Then
        tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(TypeN)))
        If tbi Then
            Pos2 = Instr(PropertyName, ".")
            If Pos2 > 0 Then
                te = GetPropertyType(TypeN, Left(PropertyName, Pos2 - 1))
                If te <> 0 Then Return GetPropertyType(te->TypeName, Mid(PropertyName, Pos2 + 1))
            Else
                iIndex = tbi->Elements.IndexOf(PropertyName)
                If iIndex <> -1 Then
                    Return Cast(TypeElement Ptr, tbi->Elements.Object(iIndex))
                ElseIf tbi->BaseName <> "" Then
                    Return GetPropertyType(tbi->BaseName, PropertyName)
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
    Dim tbi As ToolBoxItem Ptr
    Dim TypeN As String = WithoutPtr(TypeName)
    If Instr(TypeN, ".") AndAlso TypeN <> "My.Sys.Object" Then TypeN = Mid(TypeN, InstrRev(TypeN, ".") + 1)
    If Comps.Contains(TypeN) Then
        tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(TypeN)))
        If tbi Then
            If tbi->BaseName = BaseName Then
                Return True
            ElseIf tbi->BaseName <> "" Then
                Return IsBase(tbi->BaseName, BaseName)
            Else
                Return False
            End If
        End If
    End If
    Return False
End Function

Function TabWindow.ReadObjProperty(ByRef Obj As Any Ptr, ByRef PropertyName As String) ByRef As WString
    On Error Goto ErrorHandler
    WLet FLine, ""
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
                    WLet FLine, Dict->Item(PropertyName)->Text
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
                Case "wstring", "wstring ptr": WLet FLine, QWString(pTemp)
                Case "string", "zstring": WLet FLine, QZString(pTemp)
                Case "control ptr", "control": WLet FLine, QControl(pTemp).Name
                Case "integer": iTemp = QInteger(pTemp)
                    WLet FLine, WStr(iTemp)
                    If (te->EnumTypeName <> "") AndAlso CInt(Comps.Contains(te->EnumTypeName)) Then
                        tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(te->EnumTypeName)))
                        If tbi AndAlso iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet FLine, WStr(iTemp) & " - " & tbi->Elements.Item(iTemp)
                    End If
                Case "boolean": WLet FLine, WStr(QBoolean(pTemp))
                Case "any ptr", "any": WLet FLine, WStr("")
                Case Else: If CInt(IsBase(.TypeName, "My.Sys.Object")) AndAlso CInt(Des->ToStringFunc <> 0) Then WLet FLine, Des->ToStringFunc(pTemp)
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
    WLet FLine, ""
    If Cpnt = 0 Then Return *FLine
    If Des = 0 OrElse Des->ReadPropertyFunc = 0 Then Return *FLine
    Pos1 = InStr(PropertyName, ".")
    pTemp = Des->ReadPropertyFunc(Cpnt, PropertyName)
    If pTemp <> 0 Then
        te = GetPropertyType(WGet(Des->ReadPropertyFunc(Cpnt, "ClassName")), PropertyName)
        If te = 0 Then Return *FLine
        With *te
            Select Case LCase(.TypeName)
            Case "wstring", "string", "zstring": WLet FLine, """" & QWString(pTemp) & """"
            Case "icon", "bitmaptype", "cursor": If Des->ToStringFunc <> 0 Then WLet FLine, """" & Des->ToStringFunc(pTemp) & """"
            Case "integer": iTemp = QInteger(pTemp)
                WLet FLine, WStr(iTemp)
                If (te->EnumTypeName <> "") AndAlso CInt(Comps.Contains(te->EnumTypeName)) Then
                    tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(te->EnumTypeName)))
                    If tbi AndAlso iTemp >= 0 AndAlso iTemp <= tbi->Elements.Count - 1 Then WLet FLine, te->EnumTypeName & "." & tbi->Elements.Item(iTemp)
                End If
            Case "boolean": WLet FLine, WStr(QBoolean(pTemp))
            Case "any ptr", "any": WLet FLine, WStr("")
            Case Else
                If CInt(IsBase(.TypeName, "Component")) Then
                    Dim As String pTempName = WGet(Des->ReadPropertyFunc(pTemp, "Name"))
                    If pTempName <> "" Then
	                    If cboClass.Items.Contains(pTempName) Then
	                        WLet FLine, "@" & pTempName
	                        If cboClass.Items.IndexOf(pTempName) = 1 Then
	                            WLet FLine, "@This"
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
        WLet FLine2, Value
        #IfNDef __USE_GTK__
			Dim hwnd1 As HWND
			Dim hTemp As Any Ptr
			If Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 Then hTemp = Des->ReadPropertyFunc(Cpnt, "Handle")
			If hTemp Then hwnd1 = *Cast(HWND Ptr, hTemp)
		#EndIf
        Select Case te->ElementType
        Case "Event"
            If Des->ReadPropertyFunc(Cpnt, "Tag") = 0 Then Des->WritePropertyFunc(Cpnt, "Tag", New Dictionary)
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
                If StartsWith(*FLine2, """") Then WLet FLine2, Mid(*FLine2, 2)
                If EndsWith(*FLine2, """") Then WLet FLine2, Left(*FLine2, Len(*FLine2) - 1)
                WLet FLine2, Replace(*FLine2, """""", """")
                '?"VFE3:" & *FLine
                If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
                	Result = Des->WritePropertyFunc(Cpnt, PropertyName, Cast(Any Ptr, FLine2))
				End If
'            Case "control ptr", "control pointer"
'                If LCase(*FLine2) = "this" Then
'                    Result = Cpnt->WriteProperty(PropertyName, frmForm)
'                ElseIf cboClass.Items.Contains(*FLine2) Then
'                    PropertyCtrl = Cast(Any Ptr, cboClass.Items.Item(cboClass.Items.IndexOf(*FLine2))->Object)
'                    Result = Cpnt->WriteProperty(PropertyName, PropertyCtrl)
'                End If
            Case "integer"
                iTemp = Val(*FLine2)
                If (te->EnumTypeName <> "") AndAlso CInt(Comps.Contains(te->EnumTypeName)) Then
                    tbi = Cast(ToolBoxItem Ptr, Comps.Object(Comps.IndexOf(te->EnumTypeName)))
                    If tbi Then
                        If tbi->Elements.Contains(*FLine2) Then
                            iTemp = tbi->Elements.IndexOf(*FLine2)
                        ElseIf StartsWith(*FLine2, te->EnumTypeName & ".") AndAlso tbi->Elements.Contains(Mid(*FLine2, Len(Trim(te->EnumTypeName)) + 2)) Then
                            iTemp = tbi->Elements.IndexOf(Mid(*FLine2, Len(Trim(te->EnumTypeName)) + 2))
                        End If
                    End If
                End If
                If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
                	Result = Des->WritePropertyFunc(Cpnt, PropertyName, Cast(Any Ptr, @iTemp))
            	End If
            Case "boolean"
                bTemp = Cast(Boolean, Trim(*FLine2))
            	If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
                	Result = Des->WritePropertyFunc(Cpnt, PropertyName, Cast(Any Ptr, @bTemp))
            	End If
            Case Else:
                If Des AndAlso LCase(*FLine2) = "this" Then
					Dim hTemp As Any Ptr
					If Des->ReadPropertyFunc <> 0 Then hTemp = Des->ReadPropertyFunc(Des->DesignControl, "Name")
					If hTemp <> 0 Then WLet *FLine2, QWString(hTemp)
				End If
				If *FLine2 <> "" AndAlso CInt(cboClass.Items.Contains(Trim(*FLine2))) Then
                    PropertyCtrl = Cast(Any Ptr, cboClass.Items.Item(cboClass.Items.IndexOf(Trim(*FLine2)))->Object)
             		If Des <> 0 AndAlso Des->WritePropertyFunc <> 0 Then
             			Result = Des->WritePropertyFunc(Cpnt, PropertyName, PropertyCtrl)
                	End If
                End If
            End Select
        End Select
        #IfNDef __USE_GTK__
			Dim hwnd2 As HWND
			If hTemp Then hwnd2 = *Cast(HWND Ptr, hTemp)
			If hwnd1 <> hwnd2 Then
				If Des AndAlso hwnd1 = Des->Dialog Then
					Des->Dialog = hwnd2
				End If
			End If
		#EndIf
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
    tabRight.Tag = @This
    tabRight.UpdateLock
    cboFunction.Items.Clear
    cboFunction.Items.Add "(" & ML("Events") & ")", , "Run", "Run"
    cboFunction.ItemIndex = 0
    lvProperties.ListItems.Clear
    lvEvents.ListItems.Clear
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
            If Cint(LCase(.Name) <> "handle") AndAlso Cint(LCase(.TypeName) <> "hwnd") AndAlso Cint(LCase(.TypeName) <> "gtkwidget ptr") AndAlso Cint(.ElementType = "Property") Then
                If lvProperties.ListItems.Count <= lvPropertyCount Then
                    lvItem = lvProperties.ListItems.Add(FPropertyItems.Item(lvPropertyCount), 2, IIF(Comps.Contains(.TypeName), 1, 0))
                Else
                    lvItem = lvProperties.ListItems.Item(lvPropertyCount)
                    lvItem->Text(0) = FPropertyItems.Item(lvPropertyCount)
                    lvItem->Text(1) = ""
                End If
                lvItem->Text(1) = ReadObjProperty(Des->SelectedControl, FPropertyItems.Item(lvPropertyCount))
            ElseIf .ElementType = "Event" Then
                cboFunction.Items.Add .Name, , "Run", "Run"
                lvItem = lvEvents.ListItems.Add(.Name, 3)
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
    tabRight.UpdateUnlock
End Sub

Dim Shared bNotFunctionChange As Boolean
Sub DesignerChangeSelection(ByRef Sender As Designer, Ctrl As Any Ptr, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1)
    Static SelectedCtrl As Any Ptr
    If Ctrl = 0 Then Exit Sub
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    If tb->Des = 0 Then Exit Sub
    If SelectedCtrl = Ctrl AndAlso tb->cboClass.ItemIndex <> 0 Then Exit Sub
    'tb->Des->SelectedControl = Ctrl
    SelectedCtrl = Ctrl
    bNotFunctionChange = True
    If tb->Des->ReadPropertyFunc <> 0 Then tb->cboClass.ItemIndex = tb->cboClass.Items.IndexOf(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name")))
    tb->FillAllProperties
    bNotFunctionChange = False
End Sub

Sub GetControls(Des As Designer Ptr, ByRef lst As List, Ctrl As Any Ptr)
    lst.Add Ctrl
    Dim j As Integer Ptr = Des->ReadPropertyFunc(Ctrl, "ControlCount")
    If j <> 0 Then
	    For i As Integer = 0 To *j - 1
	        GetControls Des, lst, Des->ControlByIndexFunc(Ctrl, i)
	    Next
    End If
End Sub

Sub DesignerDeleteControl(ByRef Sender as Designer, Ctrl as Any Ptr)
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    If tb->Des = 0 Then Exit Sub
    If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
    If tb->Des->DesignControl = 0 Then Exit Sub
    If tb->Des->ControlByIndexFunc = 0 Then Exit Sub
    If Ctrl = 0 Then Exit Sub
    Dim lst As List
    Dim As String frmName
    If tb->Des->ReadPropertyFunc <> 0 Then
    	frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
    End If
    Dim ECLine As EditControlLine Ptr
    GetControls tb->Des, lst, Ctrl
    'frmName = tb->Des->DesignControl->Name
    With tb->txtCode
        Var b = False
        Var s = 0
        .Changing "Unsurni o`chirish"
        For i As Integer = 0 To .LinesCount - 1
            If Not b AndAlso StartsWith(Trim(LCase(.Lines(i))), "type " & LCase(frmName) & " ") Then
                b = True
            ElseIf b AndAlso StartsWith(LTrim(LCase(.Lines(i))) & " ", "end type ") Then
                s = i
                Exit For
            ElseIf b AndAlso StartsWith(LTrim(LCase(.Lines(i))), "dim as ") Then
                For k As Integer = 0 To lst.Count - 1
                    Ctrl = Cast(Control Ptr, lst.Items[k])
                    If StartsWith(LTrim(LCase(.Lines(i))), "dim as " & LCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "ClassName"))) & " ") Then
                        Var p = Instr(LCase(.Lines(i)) & ",", " " & lCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))) & ",")
                        If Trim(Left(LCase(.Lines(i)), p)) = "dim as " & LCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "ClassName"))) AndAlso Trim(Mid(.Lines(i), p + Len(lCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name")))) + 1)) = "" Then
                            .DeleteLine i
                        ElseIf Instr(LCase(.Lines(i)), " " & lCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))) & ",") Then
                            .ReplaceLine i, Left(.Lines(i), p - 1) & Mid(.Lines(i), p + Len(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))) + 2)
                        Else
                            .ReplaceLine i, Left(.Lines(i), p - 2) & Mid(.Lines(i), p + Len(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))) + 1)
                        End If
                        If WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name")) <> frmName Then tb->cboClass.Items.Remove tb->cboClass.Items.IndexOf(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name")))
                    End If
                Next
            End If
        Next
        b = False
        Var i = s + 1
        Do While i < .LinesCount - 1
            If Not b AndAlso StartsWith(Trim(LCase(.Lines(i))) & " ", "constructor " & Lcase(frmName) & " ") Then
                b = True
            ElseIf b AndAlso StartsWith(Trim(LCase(.Lines(i))) & " ", "end constructor ") Then
                Exit Do
            ElseIf b Then
                For k As Integer = 0 To lst.Count - 1
                    Ctrl = Cast(Control Ptr, lst.Items[k])
                    If StartsWith(Trim(LCase(.Lines(i))) & " ", "' " & lCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))) & " ") Then
                        .DeleteLine i
                        i = i - 1
                    ElseIf StartsWith(Trim(LCase(.Lines(i))), LCase(WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))) & ".") Then
                        .DeleteLine i
                        i = i - 1
                    End If
                Next
            End If
            i = i + 1
        Loop
        .Changed "Unsurni o`chirish"
    End With
End Sub

Function ChangeControl(Cpnt As Any Ptr, ByRef PropertyName As WString = "", iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1) As Integer
    On Error Goto ErrorHandler
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Return 0
    If tb->Des = 0 Then Return 0
    If tb->Des->ReadPropertyFunc = 0 Then Return 0
    If Cpnt = 0 Then Return 0
    If tb->Des->DesignControl = 0 Then Return 0
    Dim CtrlName As String
    'Dim As Integer iLeft, iTop, iWidth, iHeight
    Dim As String frmName
    frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
    If WGet(tb->Des->ReadPropertyFunc(Cpnt, "Name")) = frmName Then CtrlName = "This" Else CtrlName = WGet(tb->Des->ReadPropertyFunc(Cpnt, "Name"))
    '= tb->Des->DesignControl->Name
    Dim InsLineCount As Integer
    Dim FLine As WString Ptr
    With tb->txtCode
        Var b = False, t = False
        Var d = False, sl = 0, tp = 0, ep = 0, j = 0
        Dim As Integer iLeft1, iTop1, iWidth1, iHeight1
        For i As Integer = 0 To .LinesCount - 1
            If StartsWith(Trim(LCase(.Lines(i)), Any !"\t "), "type " & LCase(frmName) & " ") Then
                sl = Len(.Lines(i)) - Len(LTrim(.Lines(i)))
                tp = i
                b = True
            ElseIf b Then
                If StartsWith(LTrim(LCase(.Lines(i)), Any !"\t ") & " ", "end type ") Then
                    j = i
                    Exit For
                ElseIf StartsWith(LTrim(LCase(.Lines(i)), Any !"\t "), "dim as " & LCase(WGet(tb->Des->ReadPropertyFunc(Cpnt, "ClassName"))) & " ") Then
                    d = True
                    If Instr(RTrim(LCase(.Lines(i))) & ",", " " & LCase(CtrlName) & ",") Then
                        t = True
                    End If
                    j = i + 1
                    Exit For
                End If
            End If
        Next
        If Not t Then
            If tb->Des->DesignControl <> Cpnt Then
                If d Then
                    .ReplaceLine j - 1, RTrim(.Lines(j - 1)) & ", " & CtrlName
                Else
                    .InsertLine j, Space(sl + 4) & "Dim As " & WGet(tb->Des->ReadPropertyFunc(Cpnt, "ClassName")) & " " & CtrlName
                    InsLineCount += 1
                End If
            End If
        End If
        t = False: b = False
        For i As Integer = tp + 1 To .LinesCount - 1
            If StartsWith(LTrim(LCase(.Lines(i)), Any !"\t ") & " ", "declare constructor ") Then
                t = True
            ElseIf StartsWith(LTrim(LCase(.Lines(i)), Any !"\t ") & " ", "end type ") Then
                ep = i
                Exit For
            End If
        Next
        If Not t Then
            .InsertLine tp + 1, Space(sl + 4) & "Declare Constructor"
            InsLineCount += 1
        End If
        Var sc = 0, se = 0
        j = 0
        t = False
        For i As Integer = ep + 1 To .LinesCount - 1
            If StartsWith(Trim(LCase(.Lines(i)), Any !"\t ") & " ", "constructor " & Lcase(frmName) & " ") Then
                sc = i
                b = True
            ElseIf b Then
                If StartsWith(Trim(LCase(.Lines(i))) & " ", "end constructor ") Then
                    se = i
                    Exit For
                ElseIf StartsWith(Trim(LCase(.Lines(i)), Any !"\t "), LCase(CtrlName) & ".") Then
                    j = i
                    If StartsWith(Trim(LCase(.Lines(i)), Any !"\t "), LCase(CtrlName) & ".setbounds ") Then
                        Var p = Instr(LCase(.Lines(i)), LCase(CtrlName) & ".setbounds ")
                        If p Then
                        	If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
                        		iLeft1 = iLeft
                        		iTop1 = iTop
                        		iHeight1 = iHeight
                        		iWidth1 = iWidth
                        	ElseIf tb->Des->ControlGetBoundsSub <> 0 Then
							    tb->Des->ControlGetBoundsSub(Cpnt, @iLeft1, @iTop1, @iWidth1, @iHeight1)
							End If
							.ReplaceLine i, Left(.Lines(i), p + Len(LCase(CtrlName)) + 10) & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
                            'Ctrl2 = Cast(Control Ptr, Cpnt)
                            '.ReplaceLine i, Left(.Lines(i), p + Len(LCase(CtrlName)) + 10) & Ctrl2->Left & ", " & Ctrl2->Top & ", " & Ctrl2->Width & ", " & Ctrl2->Height
                            If LCase(PropertyName) = "left" OrElse LCase(PropertyName) = "top" OrElse LCase(PropertyName) = "width" OrElse LCase(PropertyName) = "height" Then t = True
                        End If
                    ElseIf CInt(PropertyName <> "") AndAlso CInt(StartsWith(Trim(LCase(.Lines(i)), Any !"\t "), LCase(CtrlName) & "." & LCase(PropertyName) & " ") OrElse StartsWith(Trim(LCase(.Lines(i)), Any !"\t "), LCase(CtrlName) & "." & LCase(PropertyName) & "=")) Then
                        Var p = Instr(LCase(.Lines(i)), "=")
                        If p Then
                            .ReplaceLine i, Left(.Lines(i), p) & " " & tb->GetFormattedPropertyValue(Cpnt, PropertyName)
                            t = True
                        End If
                    End If
                End If
            End If
        Next
        Dim q As Integer = 0
        If sc = 0 Then
            .InsertLine ep + 2, Space(sl)
            .InsertLine ep + 3, Space(sl) & "Constructor " & frmName
            .InsertLine ep + 4, Space(sl + 4) & "' " & frmName
            .InsertLine ep + 5, Space(sl + 4) & "This.Name = """ & frmName & """"
            If tb->Des->ReadPropertyFunc <> 0 Then
            	.InsertLine ep + 6, Space(sl + 4) & "This.Text = """ & WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Text")) & """"
            End If
            If PropertyName <> "" AndAlso PropertyName <> "Text" Then
                WLet FLine, tb->GetFormattedPropertyValue(tb->Des->DesignControl, PropertyName)
                If *FLine <> "" Then .InsertLine ep + 7, Space(sl + 4) & "This." & PropertyName & " = " & *FLine: q = 1
            End If
            If tb->Des->ControlGetBoundsSub <> 0 Then tb->Des->ControlGetBoundsSub(tb->Des->DesignControl, @iLeft1, @iTop1, @iWidth1, @iHeight1)
            .InsertLine ep + q + 7, Space(sl + 4) & "This.SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
            .InsertLine ep + q + 8, Space(sl) & "End Constructor"
            InsLineCount += q + 7
            If Cpnt = tb->Des->DesignControl Then j = ep + q + 8: t = True
            se = ep + q + 8
        ElseIf se = 0 Then
            'Var l = .CharIndexFromLine(sc + 1)
            '.ChangeText Left(.Text, l) & Space(sl) & "End Constructor" & Chr(13) & Mid(.Text, l + 1), "Tugatuvchi konstruktor qo`shildi", .SelStart, , False
            se = sc + 1
        End If
        If j = 0 Then
        	If Cpnt <> 0 AndAlso tb->Des->IsControlFunc <> 0 AndAlso CInt(tb->Des->IsControlFunc(Cpnt)) Then
                If tb->Des->ReadPropertyFunc(Cpnt, "Parent") Then
                    Dim ParentName As String
                    If tb->Des->ReadPropertyFunc(Cpnt, "Parent") = tb->Des->DesignControl Then ParentName = "This" Else ParentName = WGet(tb->Des->ReadPropertyFunc(tb->Des->ReadPropertyFunc(Cpnt, "Parent"), "Name"))
                    .InsertLine se, Space(sl + 4) & "' " & CtrlName
                    .InsertLine se + 1, Space(sl + 4) & CtrlName & ".Name = """ & CtrlName & """"
                    InsLineCount += 2
                    q = 0
                    If WGet(tb->Des->ReadPropertyFunc(Cpnt, "Text")) <> "" Then
                        WLet FLine, CtrlName
                        If tb->Des->WritePropertyFunc <> 0 Then tb->Des->WritePropertyFunc(Cpnt, "Text", FLine)
                        .InsertLine se + 2, Space(sl + 4) & CtrlName & ".Text = """ & WGet(tb->Des->ReadPropertyFunc(Cpnt, "Text")) & """"
                        InsLineCount += 1
                        q = 1
                    End If
                    If PropertyName <> "" AndAlso PropertyName <> "Text" Then
                        WLet FLine, tb->GetFormattedPropertyValue(Cpnt, PropertyName)
                        If *FLine <> "" Then .InsertLine se + q + 2, Space(sl + 4) & CtrlName & "." & PropertyName & " = " & *FLine: q += 1
                    End If
                    If iLeft <> -1 AndAlso iTop <> -1 AndAlso iWidth <> -1 AndAlso iHeight <> - 1 Then
                		iLeft1 = iLeft
                		iTop1 = iTop
                		iWidth1 = iWidth
                		iHeight1 = iHeight
                    ElseIf tb->Des->ControlGetBoundsSub <> 0 Then
						tb->Des->ControlGetBoundsSub(Cpnt, @iLeft1, @iTop1, @iWidth1, @iHeight1)
                    End If
                    .InsertLine se + q + 2, Space(sl + 4) & CtrlName & ".SetBounds " & iLeft1 & ", " & iTop1 & ", " & iWidth1 & ", " & iHeight1
                    InsLineCount += 1
                    If Cpnt <> tb->Des->DesignControl Then .InsertLine se + q + 3, Space(sl + 4) & CtrlName & ".Parent = @" & ParentName: InsLineCount += 1
                End If
            Else
                q = 0
                .InsertLine se, Space(sl + 4) & "' " & CtrlName
                .InsertLine se + 1, Space(sl + 4) & CtrlName & ".Name = """ & CtrlName & """"
                If PropertyName <> "" AndAlso PropertyName <> "Name" Then .InsertLine se + 2, Space(sl + 4) & CtrlName & "." & PropertyName & " = " & tb->GetFormattedPropertyValue(Cpnt, PropertyName): q += 1
                InsLineCount += q + 1
            End If
        ElseIf Not t Then
            If PropertyName <> "" Then
                WLet FLine, tb->GetFormattedPropertyValue(Cpnt, PropertyName)
                If *FLine <> "" Then .InsertLine j, Space(sl + 4) & CtrlName & "." & PropertyName & " = " & *FLine: q += 1
            End If
            InsLineCount += q
        End If
    End With
    Return InsLineCount
    Exit Function
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Function

Sub TabWindow.ChangeName(ByRef OldName As String, ByRef NewName As String)
    Dim iIndex As Integer = cboClass.Items.IndexOf(OldName)
    If Des = 0 Then Exit Sub
    If Des->DesignControl = 0 Then Exit Sub
    Dim frmName As String
    If Des->ReadPropertyFunc <> 0 Then
    	frmName = WGet(Des->ReadPropertyFunc(Des->DesignControl, "Name"))
    End If
    If iIndex = 1 AndAlso Des->WritePropertyFunc <> 0 Then Des->WritePropertyFunc(Des->DesignControl, "Name", @NewName)
    With txtCode
        Dim As Boolean b, c
        If iIndex > 0 Then cboClass.Items.Item(iIndex)->Text = NewName
        For i As Integer = 0 To .LinesCount - 1
            If StartsWith(LCase(LTrim(.Lines(i), Any !"\t ")), "type " & LCase(frmName) & " ") Then
                c = True
                If iIndex = 1 Then
                    .ReplaceLine i, Space(Len(.Lines(i)) - Len(LTrim(.Lines(i)))) & Left(LTrim(.Lines(i), " "), 5) & NewName & Mid(LTrim(.Lines(i), " "), Len(frmName) + 6)
                End If
            ElseIf c Then
                If StartsWith(LCase(LTrim(.Lines(i), Any !"\t ")) & " ", "end type ") Then
                    c = False
                ElseIf StartsWith(LCase(LTrim(.Lines(i), Any !"\t ")), "dim as ") Then
                    Var Pos1 = InStr(LCase(RTrim(.Lines(i))) & ",", " " & LCase(OldName) & ",")
                    If Pos1 > 0 Then
                        .ReplaceLine i, Left(.Lines(i), Pos1) & NewName & Mid(.Lines(i), Len(OldName) + Pos1 + 1)
                    End If
                End If
            ElseIf StartsWith(LCase(LTrim(.Lines(i), Any !"\t ")) & " ", "constructor " & LCase(frmName) & " ") Then
                If iIndex = 1 Then
                    .ReplaceLine i, Space(Len(.Lines(i)) - Len(LTrim(.Lines(i)))) & Left(LTrim(.Lines(i), " "), 12) & NewName & Mid(LTrim(.Lines(i), " "), Len(frmName) + 13)
                End If
                b = True
            ElseIf b Then
                If StartsWith(LTrim(LCase(.Lines(i)) & " ", Any !"\t "), "end constructor ") Then
                    b = False
                ElseIf StartsWith(LCase(LTrim(.Lines(i), Any !"\t ")) & " ", "' " & LCase(OldName) & " ") Then
                    .ReplaceLine i, Space(Len(.Lines(i)) - Len(LTrim(.Lines(i)))) & Left(LTrim(.Lines(i), Any !"\t "), 2) & NewName & Mid(LTrim(.Lines(i), Any !"\t "), Len(OldName) + 3)
                ElseIf StartsWith(LTrim(LCase(.Lines(i)), Any !"\t "), LCase(OldName) & ".") Then
                    .ReplaceLine i, Space(Len(.Lines(i)) - Len(LTrim(.Lines(i), Any !"\t "))) & NewName & Mid(LTrim(.Lines(i), Any !"\t "), Len(OldName) + 1)
                ElseIf EndsWith(RTrim(LCase(.Lines(i)), " "), "@" & LCase(OldName)) Then
                    .ReplaceLine i, Left(.Lines(i), Len(.Lines(i)) - Len(OldName)) & NewName
                End If
            ElseIf iIndex = 1 Then    
                If StartsWith(LTrim(LCase(.Lines(i)), Any !"\t "), "private sub " & LCase(OldName) & ".") Then
                    .ReplaceLine i, Space(Len(.Lines(i)) - Len(LTrim(.Lines(i)))) & Left(LTrim(.Lines(i), " "), 12) & NewName & Mid(LTrim(.Lines(i), " "), Len(OldName) + 13)
                ElseIf StartsWith(LTrim(LCase(.Lines(i)), Any !"\t "), "public sub " & LCase(OldName) & ".") Then
                    .ReplaceLine i, Space(Len(.Lines(i)) - Len(LTrim(.Lines(i)))) & Left(LTrim(.Lines(i), " "), 11) & NewName & Mid(LTrim(.Lines(i), " "), Len(OldName) + 12)
                End If
            End If
            If iIndex = 1 Then
                If EndsWith(RTrim(LCase(.Lines(i))), " as " & LCase(OldName)) Then
                    .ReplaceLine i, Left(.Lines(i), Len(.Lines(i)) - Len(OldName)) & NewName
                End If
            End If
        Next
    End With
End Sub

Function GetItemText(ByRef Item As ListViewItem Ptr) As String
    Dim As String PropertyName = Item->Text(0)
    If Item->Indent = 0 Then
        Return PropertyName
    Else
        For i As Integer = Item->Index - 1 To 0 Step -1
            If lvProperties.ListItems.Item(i)->Indent < Item->Indent Then
                Return GetItemText(lvProperties.ListItems.Item(i)) & "." & PropertyName
            End If
        Next
    End If
End Function

Dim Shared TempWS As WString Ptr
Sub txtPropertyValue_LostFocus(ByRef Sender As Control)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    If tb->Des = 0 Then Exit Sub
    If tb->Des->SelectedControl = 0 Then Exit Sub
    If lvProperties.SelectedItem = 0 Then Exit Sub
    Dim As String PropertyName = GetItemText(lvProperties.SelectedItem)
    'Var te = GetPropertyType(tb->SelectedControl->ClassName, PropertyName)
    'If te = 0 Then Exit Sub
    Dim FLine As WString Ptr
    Dim SenderText As WString Ptr
    WLet SenderText, IIF(Sender.ClassName = "ComboBoxEdit", Mid(Sender.Text, 2), Sender.Text)
    With tb->txtCode
        If *SenderText <> tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName) Then
            If CInt(PropertyName = "Name") AndAlso CInt(tb->cboClass.Items.Contains(*SenderText)) Then
                MsgBox ML("This name is exists!"), "VisualFBEditor", mtWarning
                Sender.Text = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
                Exit Sub
            End If
            frmMain.UpdateLock
            .Changing "Unsurni o`zgartirish"
            If PropertyName = "Name" Then tb->ChangeName tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName), *SenderText
            tb->WriteObjProperty(tb->Des->SelectedControl, PropertyName, Sender.Text)
            Sender.Text = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
            ChangeControl(tb->Des->SelectedControl, PropertyName)
            'If tb->frmForm Then tb->frmForm->MoveDots Cast(Control Ptr, tb->SelectedControl)->Handle, False
            For i As Integer = 0 To lvProperties.ListItems.Count - 1
                PropertyName = GetItemText(lvProperties.ListItems.Item(i))
                WLet TempWS, tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
                If *TempWS <> lvProperties.ListItems.Item(i)->Text(1) Then
                    lvProperties.ListItems.Item(i)->Text(1) = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
                    ChangeControl(tb->Des->SelectedControl, PropertyName)
                End If
            Next i
            .Changed "Unsurni o`zgartirish"
            frmMain.UpdateUnLock
        End If
    End With
End Sub

Sub cboPropertyValue_Change(ByRef Sender As Control)
    txtPropertyValue_LostFocus Sender
End Sub

Sub DesignerModified(ByRef Sender as Designer, Ctrl As Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    With tb->txtCode
        frmMain.UpdateLock
        Dim PropertyName As String
        For i As Integer = 0 To lvProperties.ListItems.Count - 1
            PropertyName = GetItemText(lvProperties.ListItems.Item(i))
            WLet TempWS, tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
            If *TempWS <> lvProperties.ListItems.Item(i)->Text(1) Then
                lvProperties.ListItems.Item(i)->Text(1) = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName)
            	If CInt(lvProperties.ListItems.Item(i) = lvProperties.SelectedItem) AndAlso CInt(txtPropertyValue.Visible) Then
            		txtPropertyValue.Text = lvProperties.ListItems.Item(i)->Text(1)
            	End If
            End If
        Next i
        .Changing "Unsurni o`zgartirish"
        ChangeControl(Ctrl, , iLeft, iTop, iWidth, iHeight)
        .Changed "Unsurni o`zgartirish"
        tb->FormDesign True
        frmMain.UpdateUnLock
    End With
End Sub

Sub ToolGroupsToCursor()
	tbToolBox.Groups.Item(0)->Buttons.Item(0)->Checked = True 
	tbToolBox.Groups.Item(1)->Buttons.Item(0)->Checked = True
	tbToolBox.Groups.Item(2)->Buttons.Item(0)->Checked = True
	tbToolBox.Groups.Item(3)->Buttons.Item(0)->Checked = True
End Sub

Sub DesignerInsertControl(ByRef Sender as Designer, ByRef ClassName as string, Ctrl As Any Ptr, iLeft2 As Integer, iTop2 As Integer, iWidth2 As Integer, iHeight2 As Integer)
    On Error Goto ErrorHandler
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    If tb->Des = 0 Then Exit Sub
    If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
    If tb->Des->DesignControl = 0 Then Exit Sub
    If Ctrl = 0 Then Exit Sub
    Dim As String NewName = WGet(tb->Des->ReadPropertyFunc(Ctrl, "Name"))
    tb->cboClass.Items.Add NewName, Ctrl, ClassName, ClassName, , 1
    If tb->Des->IsControlFunc <> 0 AndAlso CInt(tb->Des->IsControlFunc(Ctrl) = False) Then
    	tb->lvComponentsList.ListItems.Add NewName, ClassName
    End If
    With tb->txtCode
		If SelectedTool <> 0 Then
	        SelectedTool->Checked = False
	        Var tbi = Cast(ToolBoxItem Ptr, SelectedTool->Tag)
	        Dim As String frmName
	        If tb->Des->ReadPropertyFunc <> 0 Then
	        	frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	        End If
            Var t = False, b = False
            Var j = 0
            .Changing "Unsur qo`shish"
            For i As Integer = 0 To .LinesCount - 1
                If StartsWith(Trim(LCase(.Lines(i)), Any !"\t "), "#include ") Then
                    b = True
                    If Instr(LCase(.Lines(i)), """" & lCase(*tbi->IncludeFile & """")) Then
                        t = True
                        Exit For
                    End If
                ElseIf b Then
                    j = i
                    Exit For
                End If
            Next
            Var InsLineCount = 0
            If Not t Then
                .InsertLine j, "#Include Once """ & *tbi->IncludeFile & """"
                InsLineCount += 1
            End If
		End If
        ChangeControl(Ctrl, , iLeft2, iTop2, iWidth2, iHeight2)
        If tb->Des->ControlSetFocusSub <> 0 Then tb->Des->ControlSetFocusSub(tb->Des->DesignControl)
        .Changed "Unsur qo`shish"
        tb->FormDesign True
    End With
    ToolGroupsToCursor
    Exit Sub
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Sub

Sub DesignerInsertComponent(ByRef Sender as Designer, ByRef ClassName as string, Cpnt As Any Ptr)
    DesignerInsertControl(Sender, ClassName, Cpnt, -1, -1, -1, -1)
End Sub

Sub DesignerInsertingControl(ByRef Sender as Designer, ByRef ClassName as string, ByRef AName as String)
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    Dim PrevName As String = AName
    Dim NewName As String
    If CInt(PrevName <> ClassName) AndAlso CInt(PrevName <> "") AndAlso CInt(Not tb->cboClass.Items.Contains(PrevName)) Then
        NewName = PrevName
    Else
        Var n = 0
        Do
            n = n + 1
            NewName = AName & Str(n)
        Loop While tb->cboClass.Items.Contains(NewName)
    End If
    AName = NewName
End Sub

Sub cboClass_Change(ByRef Sender as ComboBoxEdit, ItemIndex As Integer)
    Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
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
                .Items.Add te->Name, te, imgKey, imgKey
            Next
        End With
    Else
        Dim Ctrl As Any Ptr = Cast(ComboBoxEx Ptr, @Sender)->Items.Item(Sender.ItemIndex)->Object
        If Ctrl = 0 Then Exit Sub
        'If Not Sender.Focused Then Exit Sub
        If tb->Des = 0 Then Exit Sub
        If tb->Des->ReadPropertyFunc <> 0 Then
        #IfDef __USE_GTK__
        	'tb->Des->SelectedControl = Ctrl
        	'tb->Des->MoveDots(tb->Des->ReadPropertyFunc(Ctrl, "Widget"))
        #Else
        	tb->Des->SelectedControl = Ctrl
        	Dim As HWND Ptr hw = tb->Des->ReadPropertyFunc(Ctrl, "Handle")
			If hw <> 0 Then tb->Des->MoveDots(*hw) Else tb->Des->MoveDots(0): DesignerChangeSelection *tb->Des, Ctrl
		#EndIf
		End If
    End If
End Sub

Dim Shared bNotDesignForms As Boolean
Sub OnLineChangeEdit(ByRef Sender As Control, ByVal CurrentLine As Integer)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    bNotFunctionChange = True
    If TextChanged Then
    	With tb->txtCode
        If Not .Focused Then bNotFunctionChange = False: Exit Sub
        	tb->FormDesign bNotDesignForms Or tb->tbrTop.Buttons.Item(1)->Checked Or Not EndsWith(tb->cboFunction.Text, " [Constructor]")
    	End With
    	TextChanged = False
    End If
'    If tb->cboClass.ItemIndex <> 0 Then
'        tb->cboClass.ItemIndex = 0
'        cboClass_Change tb->cboClass, 0
'    End If
    Dim As TypeElement Ptr te1, te2
    Dim t As Boolean
    For i As Integer = 0 To tb->Functions.Count - 1
        te2 = tb->Functions.Object(i)
        If te2 = 0 Then Continue For
        If te2->StartLine <= CurrentLine And te2->EndLine >= CurrentLine Then
            For j As Integer = 1 To tb->cboFunction.Items.Count - 1
                te1 = tb->cboFunction.Items.Item(j)->Object
                If te1 = 0 Then Continue For
                If te1->StartLine = te2->StartLine Then
                    tb->cboFunction.ItemIndex = j
                    t = True
                    bNotFunctionChange = False
                    Exit Sub
                End If
            Next
        End If
    Next
    If tb->cboClass.ItemIndex <> 0 Then
        tb->cboClass.ItemIndex = 0
        cboClass_Change tb->cboClass, 0
    End If
    tb->cboFunction.ItemIndex = 0
    bNotFunctionChange = False
End Sub

Sub FindEvent(Cpnt As Any Ptr, EventName As String)
    On Error Goto ErrorHandler
    Dim As TabWindow Ptr tb = tabRight.Tag
    If tb = 0 Then Exit Sub
    If tb->Des = 0 Then Exit Sub
    If tb->Des->DesignControl = 0 Then Exit Sub
    If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
    Dim frmName As String
    frmName = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
    If Cpnt = 0 Then Exit Sub
    Dim CtrlName As String = WGet(tb->Des->ReadPropertyFunc(Cpnt, "Name"))
    If Cpnt = tb->Des->DesignControl Then CtrlName = "This"
    Dim EventNameStatic As String = EventName
    If EndsWith(EventNameStatic, "NS") Then EventNameStatic = Left(EventNameStatic, Len(EventNameStatic) - 2)
    Dim As String CtrlName2 = CtrlName
    If CtrlName = "This" Then CtrlName2 = "Form"
    Var EventName2 = Mid(EventName, IIF(StartsWith(LCase(EventName), "on"), 3, 1))
    If EndsWith(EventName2, "NS") Then EventName2 = Left(EventName2, Len(EventName2) - 2)
    Dim As String SubName = CtrlName2 & "_" & EventName2
    Dim As String SubNameNS = CtrlName2 & "_" & EventName2 & "NS"
    Var ii = tb->cboClass.ItemIndex
    Var jj = tb->cboFunction.ItemIndex
    If ii < 0 Then Exit Sub
    With tb->txtCode
        .Changing "Hodisa qo`shish"
        ChangeControl Cpnt
        Dim As Boolean b, c, e, f, t, td, tdns, tt
        Dim As Integer i, j, k, l
        For i = 0 To .LinesCount - 1
            If (Not b) AndAlso StartsWith(Trim(LCase(.Lines(i))), "type " & LCase(frmName) & " ") Then
                b = True
            ElseIf b Then
                If Not e Then
                    If StartsWith(LTrim(LCase(.Lines(i))) & " ", "end type ") Then
                        e = True
                    ElseIf StartsWith(LTrim(LCase(.Lines(i))), "declare constructor") Then
                        j = i
                    ElseIf StartsWith(LTrim(LCase(.Lines(i))), "declare static") Then
                        l = i
                        If StartsWith(LTrim(LCase(.Lines(i))), "declare static sub " & Lcase(SubName)) Then
                            td = True
                        End If
                    ElseIf StartsWith(LTrim(LCase(.Lines(i))), "declare sub " & Lcase(SubNameNS)) Then
                        tdns = True
                    End If
                ElseIf e Then
                    If (Not c) AndAlso StartsWith(LCase(LTrim(.Lines(i))) & " ", "constructor " & LCase(frmName) & " ") Then
                        c = True
                    ElseIf c Then
                        If Not f Then
                            If StartsWith(LCase(LTrim(.Lines(i))), LCase(CtrlName & ".")) Then
                                k = i
                                If StartsWith(LCase(LTrim(.Lines(i))), LCase(CtrlName & "." & EventNameStatic & "=")) OrElse _
                                    StartsWith(LCase(LTrim(.Lines(i))), LCase(CtrlName & "." & EventNameStatic & " ")) Then
                                    Var Pos1 = InStr(.Lines(i), "=")
                                    If Pos1 > 0 Then
                                        SubName = Trim(Mid(.Lines(i), Pos1 + 1))
                                        tt = True
                                        If StartsWith(SubName, "@") Then SubName = Mid(SubName, 2)
                                    End If
                                End If
                            ElseIf StartsWith(LCase(LTrim(.Lines(i))), "end constructor") Then
                                f = True
                            End If
                        ElseIf f Then
                            If StartsWith(LCase(LTrim(.Lines(i))), LCase("Public Sub " & frmName & "." & SubName)) OrElse _
                                StartsWith(LCase(LTrim(.Lines(i))), LCase("Private Sub " & frmName & "." & SubName)) OrElse _
                                StartsWith(LCase(LTrim(.Lines(i))), LCase("Sub " & frmName & "." & SubName)) Then
                                Var n = Len(.Lines(i)) - Len(LTrim(.Lines(i)))
                                .SetSelection i + 1, i + 1, n + 4, n + 4
                                .TopLine = i
                                .SetFocus
                                OnLineChangeEdit tb->txtCode, i + 1
                                t = True
                                Exit Sub
                            End If
                        End If
                    End If
                End If
            End If
        Next i
        If Not t Then
            Dim As TypeElement Ptr te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(Cpnt, "ClassName")), EventName)
            Dim q As Integer
            If te = 0 Then Exit Sub
            If Not td Then
                Var n = Len(.Lines(j)) - Len(LTrim(.Lines(j)))
                .InsertLine j, Space(n) & "Declare Static Sub " & SubName & Mid(te->TypeName, 4)
                q = 1
            End If
            If Not tt Then
                Var n = Len(.Lines(k + q)) - Len(LTrim(.Lines(k + q)))
                .InsertLine k + q, Space(n) & CtrlName & "." & EventName & " = @" & SubName
                q += 1
            End If
            .InsertLine i + q, ""
            .InsertLine i + q + 1, "Private Sub " & frmName & "." & SubName & Mid(te->TypeName, 4)
            .InsertLine i + q + 2, Space(4)
            .InsertLine i + q + 3, "End Sub"
            bNotDesignForms = True
            .SetSelection i + q + 2, i + q + 2, 4, 4
            .TopLine = i + q + 1
            .Changed "Hodisa qo`shish"
            .SetFocus
            If lvEvents.ListItems.Contains(EventName) Then
                lvEvents.ListItems.Item(lvEvents.ListItems.IndexOf(EventName))->Text(1) = SubName
            End If
            OnLineChangeEdit tb->txtCode, i + q + 2
            If tb->tbrTop.Buttons.Item(2)->Checked Then
                tb->tbrTop.Buttons.Item(1)->Checked = True
            End If
            bNotDesignForms = False
        End If
    End With
    Exit Sub
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Sub

Sub cboFunction_Change(ByRef Sender as ComboBoxEdit, ItemIndex As Integer)
	If bNotFunctionChange Then Exit Sub
    Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
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
                    .SetSelection i + 1, i + 1, n + 4, n + 4
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

Sub DesignerDblClickControl(ByRef Sender as Designer, Ctrl As Any Ptr)
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    If tb->cboFunction.Items.Count > 1 Then
       FindEvent tb->cboClass.Items.Item(tb->cboClass.ItemIndex)->Object, tb->cboFunction.Items.Item(1)->Text
       'tb->cboFunction.ItemIndex = 1
       'cboFunction_Change tb->cboFunction
       If tb->tbrTop.Buttons.Item(2)->Checked Then
          tb->tbrTop.Buttons.Item(1)->Checked = True
       End If
    End If
'    With tb->txtCode
'        frmMain.UpdateLock
'        .Changing "Unsurni o`zgartirish"
'        ChangeControl Ctrl
'        .Changed "Unsurni o`zgartirish"
'        frmMain.UpdateUnLock
'    End With
End Sub

Sub DesignerClickProperties(ByRef Sender as Designer, Ctrl As Any Ptr)
    Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    tabRight.Tab(0)->SelectTab
End Sub

Dim Shared As Integer SelLinePos, SelCharPos
#IfDef __USE_GTK__
	Sub lvIntellisense_ItemActivate(ByRef Sender as ListView, ByRef Item As ListViewItem)
	    Dim As Integer ItemIndex = Item.Index
	    Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
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
	            #IfDef __USE_GTK__
	            	tb->txtCode.CloseDropDown
	            #EndIf
	'        End If
	    End WIth
	End Sub
#Else
	Sub cboIntellisense_Selected(ByRef Sender as ComboBoxEdit, ItemIndex As Integer)
	    If ItemIndex < 0 OrElse ItemIndex > Cast(ComboBoxEx Ptr, @Sender)->Items.Count - 1 Then Exit Sub
	    Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
	    If tb = 0 Then Exit Sub
	    Dim sLine As WString Ptr = @tb->txtCode.Lines(SelLinePos)
	    Dim i As Integer = GetNextCharIndex(*sLine, SelCharPos)
	'    Dim sTempRight As WString Ptr
	'    WLet sTempRight, Mid(*sLine, SelCharPos + 1, i - SelCharPos)
	'    ?"""" & *sTempRight & """"
	    With tb->txtCode.cboIntellisense
	'        If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.Items.Item(.ItemIndex)->Text), LCase(*sTempRight))) Then
	'        Else    
	            tb->txtCode.ReplaceLine SelLinePos, Left(*sLine, SelCharPos) & .Items.Item(ItemIndex)->Text & Mid(*sLine, i + 1)
	            i = SelCharPos + Len(.Items.Item(ItemIndex)->Text)
	            tb->txtCode.SetSelection SelLinePos, SelLinePos, i, i
	            tb->txtCode.SetFocus
	'        End If
	    End WIth
	End Sub
#EndIf

Sub OnKeyDownEdit(ByRef Sender As Control, Key As Integer, Shift As Integer)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    #IfDef __USE_GTK__
	    If Key = GDK_KEY_SPACE AndAlso (Shift And GDK_Control_MASK) Then
	    	CompleteWord
	    End If
    #EndIf
'    If Key = 13 Then
'        If tb->txtCode.DropDownShowed Then
'            tb->txtCode.cboIntellisense.ShowDropDown False
'            cboIntellisense_Selected tb->txtCode.cboIntellisense
'            Key = 0
'        End If
'    End If
End Sub

Sub FillAllIntellisenses()
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    FListItems.Clear
    For i As Integer = 0 To KeyWords0.Count - 1
        FListItems.Add KeyWords0.Item(i)
    Next
    For i As Integer = 0 To KeyWords1.Count - 1
        FListItems.Add KeyWords1.Item(i)
    Next
    For i As Integer = 0 To KeyWords2.Count - 1
        FListItems.Add KeyWords2.Item(i)
    Next
    For i As Integer = 0 To KeyWords3.Count - 1
        FListItems.Add KeyWords3.Item(i)
    Next
    For i As Integer = 0 To Comps.Count - 1
        FListItems.Add Comps.Item(i), Comps.Object(i)
    Next
    For i As Integer = 0 To tb->Functions.Count - 1
        If EndsWith(tb->Functions.Item(i), "]") Then
            If EndsWith(tb->Functions.Item(i), " [Type]") OrElse EndsWith(tb->Functions.Item(i), " [Enum]") Then
                FListItems.Add Left(tb->Functions.Item(i), Len(tb->Functions.Item(i)) - 7), tb->Functions.Object(i)
            ElseIf EndsWith(tb->Functions.Item(i), " [Get]") OrElse EndsWith(tb->Functions.Item(i), " [Let]") Then
                FListItems.Add Left(tb->Functions.Item(i), Len(tb->Functions.Item(i)) - 6), tb->Functions.Object(i)
            End If
        Else
            FListItems.Add tb->Functions.Item(i), tb->Functions.Object(i)
        End If
    Next
    FListItems.Sort
    #IfDef __USE_GTK__
    	tb->txtCode.lvIntellisense.ListItems.Clear
    #Else
    	tb->txtCode.cboIntellisense.Items.Clear
    #EndIf
    For i As Integer = 0 To FListItems.Count - 1
        Dim As String imgKey = "CompileAndRun"
        Dim tbi As TypeElement Ptr = FListItems.Object(i)
        If tbi = 0 Then
            imgKey = "StandartTypes"
        ElseIf tbi->ElementType = "Enum" Then
            imgKey = "Enum"
        End If
        #IfDef __USE_GTK__
        	tb->txtCode.lvIntellisense.ListItems.Add FListItems.Item(i), imgKey
        #Else
        	tb->txtCode.cboIntellisense.Items.Add FListItems.Item(i), tbi, imgKey, imgKey
    	#EndIf
    Next i
End Sub

Sub FillTypeIntellisenses()
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    FListItems.Clear
    For i As Integer = 0 To KeyWords1.Count - 1
        FListItems.Add KeyWords1.Item(i)
    Next
    FListItems.Add "Const"
    FListItems.Add "TypeOf"
    FListItems.Add "Sub"
    FListItems.Add "Function"
    For i As Integer = 0 To Comps.Count - 1
        FListItems.Add Comps.Item(i), Comps.Object(i)
    Next
    For i As Integer = 0 To tb->Functions.Count - 1
        If EndsWith(tb->Functions.Item(i), " [Type]") OrElse EndsWith(tb->Functions.Item(i), " [Enum]") Then
            FListItems.Add Left(tb->Functions.Item(i), Len(tb->Functions.Item(i)) - 7), tb->Functions.Object(i)
        End If
    Next
    FListItems.Sort
    #IfDef __USE_GTK__
    	tb->txtCode.lvIntellisense.ListItems.Clear
    #Else
    	tb->txtCode.cboIntellisense.Items.Clear
    #EndIf
    For i As Integer = 0 To FListItems.Count - 1
        Dim As String imgKey = "CompileAndRun"
        Dim tbi As TypeElement Ptr = FListItems.Object(i)
        If tbi = 0 Then
            imgKey = "StandartTypes"
        ElseIf tbi->ElementType = "Enum" Then
            imgKey = "Enum"
        End If
        #IfDef __USE_GTK__
        	tb->txtCode.lvIntellisense.ListItems.Add FListItems.Item(i), imgKey
        #Else
        	tb->txtCode.cboIntellisense.Items.Add FListItems.Item(i), tbi, imgKey, imgKey
        #EndIf
    Next i
End Sub

Sub TabWindow.FillIntellisense(ByRef ClassName As WString)
    If Comps.Contains(ClassName) Then
        tbi = Comps.Object(Comps.IndexOf(ClassName))
        If tbi Then
            i = 0
            Do While i <= tbi->Elements.Count - 1
                te = tbi->Elements.Object(i)
                If te Then
                    With *te
                        If .Locals = 0 Then
                            If Not FListItems.Contains(.Name) Then
                                FListItems.Add .Name, te
                            End If
                        End If
                    End With
                End If
                i += 1
            Loop
            FillIntellisense tbi->BaseName
        End If
    End If
End Sub

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
        If CInt(IsArg(Asc(Mid(sLine, i, 1)))) OrElse CInt(Mid(sLine, i, 1) = "#") Then WLet sTempRight, *sTempRight & Mid(sLine, i, 1) Else Exit For
    Next
    #IfDef __USE_GTK__
    	With tb->txtCode.lvIntellisense
    #Else
    	With tb->txtCode.cboIntellisense
    #EndIf
        	Dim As Integer Ekv, EkvOld, iPos, i
        #IfDef __USE_GTK__
        	For i = 0 To .ListItems.Count - 1
        		Ekv = Ekvivalent(.ListItems.Item(i)->Text(0), *sTempRight)
        #Else
        	For i = 0 To .Items.Count - 1
            	Ekv = Ekvivalent(.Items.Item(i)->Text, *sTempRight)
        #EndIf
            If Ekv < EkvOld Then
                Exit For
            ElseIf Ekv > EkvOld Then
                iPos = i
            End If
            EkvOld = Ekv
        Next
        #IfDef __USE_GTK__
        	.SelectedItemIndex = iPos
        #Else
        	.ItemIndex = iPos
        #EndIf
        tb->txtCode.LastItemIndex = iPos
        tb->txtCode.FocusedItemIndex = iPos
        #IfDef __USE_GTK__
        	If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.ListItems.Item(i - 1)->Text(0)), LCase(*sTempRight))) Then
        #Else
        	If CInt(*sTempRight = "") OrElse CInt(Not StartsWith(LCase(.Items.Item(i - 1)->Text), LCase(*sTempRight))) Then
        #EndIf
            tb->txtCode.LastItemIndex = -1
        End If
    End With
End Sub

Sub FillIntellisenseByName(sTemp2 As String)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    If tb->Des AndAlso tb->Des->ReadPropertyFunc <> 0 Then
	    If CInt(LCase(sTemp2) = "this") AndAlso CInt(tb->Des) AndAlso CInt(tb->Des->DesignControl) AndAlso CInt(StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & " ") OrElse StartsWith(tb->cboFunction.Text, WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name")) & ".")) Then
	        sTemp2 = WGet(tb->Des->ReadPropertyFunc(tb->Des->DesignControl, "Name"))
	    End If
    End If
    FListItems.Clear
    #IfDef __USE_GTK__
    	tb->txtCode.lvIntellisense.ListItems.Clear
	    tb->txtCode.lvIntellisense.Sort = ssSortAscending
    #Else
	    tb->txtCode.cboIntellisense.Items.Clear
	    tb->txtCode.cboIntellisense.Sort = True
    #EndIf
    If tb->cboClass.Items.Contains(sTemp2) Then
        Dim Obj As Any Ptr = tb->cboClass.Items.Item(tb->cboClass.Items.IndexOf(sTemp2))->Object
        If Obj = 0 Then Exit Sub
        If tb->Des AndAlso tb->Des->ReadPropertyFunc <> 0 Then
        	tb->FillIntellisense WGet(tb->Des->ReadPropertyFunc(Obj, "ClassName"))
        End If
    ElseIf Comps.Contains(sTemp2) Then
        tb->FillIntellisense sTemp2
    Else
        Exit Sub
    End If
    FListItems.Sort
    For i As Integer = 0 To FListItems.Count - 1
        Dim As String imgKey = "Sub"
        Dim te As TypeElement Ptr = FListItems.Object(i)
        If te = 0 Then Continue For
        If te->ElementType = "Property" Then
            imgKey = "Property"
        ElseIf te->ElementType = "Function" Then
            imgKey = "Function"
        ElseIf te->ElementType = "Event" Then
            imgKey = "Run"
        End If
        #IfDef __USE_GTK__
        	tb->txtCode.lvIntellisense.ListItems.Add te->Name, imgKey
        #Else
        	tb->txtCode.cboIntellisense.Items.Add te->Name, te, imgKey, imgKey
    	#EndIf
    Next i
End Sub

Sub CompleteWord
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
    tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
    SelLinePos = iSelEndLine
    Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
    Dim As String s, sTemp, sTemp2
    Dim As Boolean b, c, d, f
    For i As Integer = iSelEndChar To 1 Step -1
        s = Mid(*sLine, i, 1)
        If CInt(IsArg(Asc(s))) OrElse CInt(s = "#") Then
            If b Or f Then
                sTemp2 = s & sTemp2
            Else
                sTemp = s & sTemp
            End If
            If f Then d = True
        ElseIf CInt(s = " ") AndAlso CInt(Not d) AndAlso CInt(Not b) Then
            If Not f Then SelCharPos = i
            f = True
        ElseIf s = "." Then
            b = True
            SelCharPos = i
        ElseIf s = ">" Then
            c = True
            SelCharPos = i
        ElseIf CInt(c) AndAlso CInt(s = "-") Then
            b = True
        Else
            Exit For
        End If
    Next
    If sTemp2 = "" Then
        FillAllIntellisenses
    ElseIf Lcase(sTemp2) = "as" Then
        FillTypeIntellisenses
    ElseIf Not f Then
        FillIntellisenseByName sTemp2
    End If
    #IfDef __USE_GTK__
    	If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then Exit Sub
	    With tb->txtCode.lvIntellisense
    #Else
	    If tb->txtCode.cboIntellisense.Items.Count = 0 Then Exit Sub
	    With tb->txtCode.cboIntellisense
    #EndIf
        FindComboIndex(tb, *sLine, SelCharPos)
        If tb->txtCode.LastItemIndex <> -1 AndAlso tb->txtCode.LastItemIndex < tb->txtCode.LinesCount - 1 Then
            #IfDef __USE_GTK__
            	If Not StartsWith(LCase(.ListItems.Item(tb->txtCode.LastItemIndex + 1)->Text(0)), LCase(sTemp)) Then
            #Else
            	If Not StartsWith(LCase(.Items.Item(tb->txtCode.LastItemIndex + 1)->Text), LCase(sTemp)) Then
            #EndIf
                Dim i As Integer = GetNextCharIndex(*sLine, SelCharPos)
                #IfDef __USE_GTK__
                	If tb->txtCode.lvIntellisense.SelectedItem Then
                		tb->txtCode.ReplaceLine iSelEndLine, Left(*sLine, SelCharPos) & .SelectedItem->Text(0) & Mid(*sLine, i + 1)
	                	i = SelCharPos + Len(.SelectedItem->Text(0))
                	End If
                #Else
	                tb->txtCode.ReplaceLine iSelEndLine, Left(*sLine, SelCharPos) & .Text & Mid(*sLine, i + 1)
	                i = SelCharPos + Len(.Text)
                #EndIf
                tb->txtCode.SetSelection SelLinePos, SelLinePos, i, i
                Exit Sub
            End If
        End If
        tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
    End With
End Sub

Sub OnKeyPressEdit(ByRef Sender As Control, Key As Byte)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
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
        Dim As String sTemp
        Dim j As Integer
        For i As Integer = iSelEndChar - k To 1 Step -1
            If IsArg(Asc(Mid(*sLine, i, 1))) Then sTemp = Mid(*sLine, i, 1) & sTemp Else Exit For
        Next
        FillIntellisenseByName sTemp
        #IfDef __USE_GTK__
        	If tb->txtCode.lvIntellisense.ListItems.Count = 0 Then Exit Sub
        #Else
        	If tb->txtCode.cboIntellisense.Items.Count = 0 Then Exit Sub
        #EndIf
        SelLinePos = iSelEndLine
        SelCharPos = iSelEndChar
        FindComboIndex tb, *sLine, iSelEndChar
        tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
    ElseIf CInt(Key = Asc(" ")) Then
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
        tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
        If EndsWith(RTrim(LCase(Left(*sLine, iSelEndChar))), " as") Then
            FillTypeIntellisenses
            SelLinePos = iSelEndLine
            SelCharPos = iSelEndChar
            FindComboIndex tb, *sLine, iSelEndChar
            #IfDef __USE_GTK__
 		    	If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
	    	#EndIf
            tb->txtCode.ShowDropDownAt SelLinePos, SelCharPos
        End If
    ElseIf tb->txtCode.DropDownShowed Then
    	#IfDef __USE_GTK__
    		If Key = GDK_KEY_Home OrElse Key = GDK_KEY_End OrElse Key = GDK_KEY_Left OrElse Key = GDK_KEY_Right OrElse _
    		Key = GDK_KEY_Escape OrElse Key = GDK_KEY_Escape OrElse Key = GDK_KEY_UP OrElse Key = GDK_KEY_DOWN OrElse _
    		Key = GDK_KEY_Page_Up OrElse Key = GDK_KEY_Page_Down Then
    			Exit Sub
    		End If
    	#EndIf
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar, k
        tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Dim sLine As WString Ptr = @tb->txtCode.Lines(iSelEndLine)
        FindComboIndex tb, *sLine, tb->txtCode.DropDownChar
        #IfDef __USE_GTK__
        	If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.lvIntellisense.SelectedItemIndex = -1
    	#Else
    		If tb->txtCode.LastItemIndex = -1 Then tb->txtCode.cboIntellisense.ItemIndex = -1
    	#EndIf
    End If
End Sub

Sub TabWindow.FormDesign(NotForms As Boolean = False)
    On Error Goto ErrorHandler
    frmMain.UpdateLock
    bNotDesign = True
    Dim SelControlName As String
    Dim bSelControlFind As Boolean
    If CInt(NotForms = False) AndAlso CInt(Des) Then
        With *Des
'        	If .FLibs.Contains(*MFFDll) Then
'                'DyLibFree(frmForm->FLibs.Object(frmForm->FLibs.IndexOf("mff/mff.dll")))
'                i = .FLibs.IndexOf(*MFFDll)
'                MFF = .FLibs.Object(i)
'                'DyLibFree(MFF)
'                'MFF = DyLibLoad("mff/mff.dll")
'                'frmForm->FLibs.Object(i) = MFF
'                'MFF = DyLibLoad("mff/mff.dll")        
'                'frmForm->FLibs.Add "mff/mff.dll", MFF
'            Else
'                MFF = DyLibLoad(*MFFDll)
'                .FLibs.Add *MFFDll, MFF
'            End If
            'DeleteComponentFunc = DylibSymbol(MFF, "DeleteComponent")
            'ReadPropertyFunc = DylibSymbol(MFF, "ReadProperty")
            'WritePropertyFunc = DylibSymbol(MFF, "WriteProperty")
            'RemoveControlSub = DylibSymbol(MFF, "RemoveControl")
            'ControlByIndexFunc = DylibSymbol(MFF, "ControlByIndex")
            If .SelectedControl <> 0 Then SelControlName = WGet(.ReadPropertyFunc(.SelectedControl, "Name"))
            If .SelectedControl = .DesignControl Then bSelControlFind = True
            If .DesignControl AndAlso iGet(.ReadPropertyFunc(.DesignControl, "ControlCount")) > 0 Then
                .UnHook
                For i As Integer = iGet(.ReadPropertyFunc(.DesignControl, "ControlCount")) - 1 To 0 Step -1
                    'If .DesignControl->Controls[i]->Handle Then .UnHookControl .DesignControl->Controls[i]->Handle
                    '.DesignControl->Remove .DesignControl->Controls[i]
                    If .RemoveControlSub AndAlso .ControlByIndexFunc Then .RemoveControlSub(.DesignControl, .ControlByIndexFunc(.DesignControl, i))
                Next i
                'If .DesignControl->Handle Then .UnHookControl .DesignControl->Handle
                '.DesignControl = 0
                'frmForm->HideDots
                
                For i As Integer = 2 To cboClass.Items.Count - 1
                    CurCtrl = 0
                    CBItem = cboClass.Items.Item(i)
                    If CBItem <> 0 Then CurCtrl = CBItem->Object
                    If CurCtrl <> 0 Then
                        .DeleteComponentFunc(CurCtrl)
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
        lvComponentsList.ListItems.Clear
    End If
    'cboFunction.Items.Clear
    'cboFunction.Items.Add "(" & ML("Declarations") & ")" & Chr(0), , "Sub", "Sub"
    'cboFunction.ItemIndex = 0
'    For i As Integer = 0 To Functions.Count - 1
'        Delete Cast(TypeElement Ptr, Functions.Object(i))
'    Next
    Functions.Clear
    'If Instr(LCase(txtCode.Text), " extends form") Then
        With txtCode
            t = False
            b = False
            c = False
            .GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            For i As Integer = 0 To .LinesCount - 1
                ECLine = .FLines.Items[i]
                WLet FLine, *ECLine->Text
'                If StartsWith(Trim(LCase(.Lines(i))), "#include ") Then
'                    Var p1 = 0
'                    Var p = Instr(.Lines(i), """")
'                    If p > 0 Then
'                        p1 = Instr(p + 1, .Lines(i), """")
'                        If p1 > 0 Then
'                            WLet FLine, Mid(.Lines(i), p + 1, p1 - p - 1)
'                            
'                        End If
'                    End If
                If ECLine->ConstructionIndex >= 10 Then
                    If ECLine->ConstructionPart = 0 Then
                        Pos1 = 0
                        Pos2 = 0
                        l = 0
                        Pos1 = Instr(" " & LTrim(LCase(*FLine), Any !"\t "), " " & LCase(Constructions(ECLine->ConstructionIndex).Name0) & " ")
                        If Pos1 > 0 Then
                            l = Len(Trim(Constructions(ECLine->ConstructionIndex).Name0)) + 1
                            Pos2 = Instr(Pos1 + l, LTrim(LCase(*FLine), Any !"\t "), "(")
                            If Pos2 = 0 Then Pos2 = Instr(Pos1 + l, LTrim(LCase(*FLine), Any !"\t "), " ")
                            te = New TypeElement
                            If Pos2 > 0 Then
                                te->Name = Trim(Mid(LTrim(*FLine, Any !"\t "), Pos1 + l, Pos2 - Pos1 - l))
                            Else
                                te->Name = Trim(Mid(LTrim(*FLine, Any !"\t "), Pos1 + l))
                            End If
                            If ECLine->ConstructionIndex > 15 Then
                                te->Name &= " [" & Trim(Constructions(ECLine->ConstructionIndex).Name0) & "]"
                            ElseIf ECLine->ConstructionIndex = 10 Then
                                te->Name &= " [Enum]"
                            ElseIf ECLine->ConstructionIndex = 11 Then
                                te->Name &= " [Type]"
                            ElseIf ECLine->ConstructionIndex = 14 Then
                                If EndsWith(RTrim(*FLine, Any !"\t "), ")") Then
                                    te->Name &= " [Let]"
                                Else
                                    te->Name &= " [Get]"
                                End If
                            End If
                            te->ElementType = Trim(Constructions(ECLine->ConstructionIndex).Name0)
                            WLet te->Parameters, *FLine
                            te->StartLine = i
                            Functions.Add te->Name, te
                        End If
                    ElseIf ECLine->ConstructionPart = 2 Then
                        If Functions.Count > 0 Then Cast(TypeElement Ptr, Functions.Object(Functions.Count - 1))->EndLine = i
                    End If
                End If
                If CInt(NotForms = False) AndAlso CInt(Not b) AndAlso CInt(ECLine->ConstructionIndex = 11) AndAlso CInt((EndsWith(Trim(LCase(*FLine), Any !"\t "), " extends form") OrElse (EndsWith(Trim(LCase(*FLine),  Any !"\t "), " extends form '...'")))) Then
                    If Des = 0 Then
                        Visible = True
                        pnlForm.Visible = True
                        splForm.Visible = True
                        If Not tbrTop.Buttons.Item(3)->Checked Then tbrTop.Buttons.Item(3)->Checked = True
                        #IfNDef __USE_GTK__
							If pnlForm.Handle = 0 Then pnlForm.CreateWnd
                        #EndIf
                        
							Des = New My.Sys.Forms.Designer(pnlForm)
							If Des = 0 Then bNotDesign = False: frmMain.UpdateUnLock: Exit Sub
							Des->OnInsertingControl = @DesignerInsertingControl
							Des->OnInsertControl = @DesignerInsertControl
							Des->OnInsertComponent = @DesignerInsertComponent
							Des->OnChangeSelection = @DesignerChangeSelection
							Des->OnDeleteControl = @DesignerDeleteControl
							Des->OnDblClickControl = @DesignerDblClickControl
							Des->OnClickProperties = @DesignerClickProperties
							Des->OnModified = @DesignerModified
       						Des->MFF = DyLibLoad(*MFFDll)
       						Des->CreateControlFunc = DylibSymbol(Des->MFF, "CreateControl")
					        Des->ReadPropertyFunc = DylibSymbol(Des->MFF, "ReadProperty")
					        Des->WritePropertyFunc = DylibSymbol(Des->MFF, "WriteProperty")
					        Des->DeleteComponentFunc = DylibSymbol(Des->MFF, "DeleteComponent")
					        Des->RemoveControlSub = DylibSymbol(Des->MFF, "RemoveControl")
					        Des->ControlByIndexFunc = DylibSymbol(Des->MFF, "ControlByIndex")
					        Des->ControlGetBoundsSub = DylibSymbol(Des->MFF, "ControlGetBounds") 
					        Des->ControlSetBoundsSub = DylibSymbol(Des->MFF, "ControlSetBounds")
					        Des->ControlIsContainerFunc = DylibSymbol(Des->MFF, "ControlIsContainer")
					        Des->IsControlFunc = DylibSymbol(Des->MFF, "IsControl")
					        Des->ControlSetFocusSub = DylibSymbol(Des->MFF, "ControlSetFocus")
					        Des->ControlFreeWndSub = DylibSymbol(Des->MFF, "ControlFreeWnd")
					        Des->ToStringFunc = DylibSymbol(Des->MFF, "ToString")
                        'Des->ContextMenu = @mnuForm
                    End If
                    Pos1 = Instr(Trim(LCase(*FLine), Any !"\t "), " extends ")
                    frmName = Mid(Trim(*FLine, Any !"\t "), 6, Pos1 - 6)
                    If Des AndAlso Des->DesignControl = 0 Then
                        With *Des
                            .DesignControl = .CreateControl("Form", frmName, frmName, 0, 0, 0, 350, 300, True)
                            If .DesignControl = 0 Then bNotDesign = False: frmMain.UpdateUnLock: Exit Sub
							'MFF = DyLibLoad(*MFFDll)
							'.FLibs.Add *MFFDll, MFF
							'ReadPropertyFunc = DylibSymbol(MFF, "ReadProperty")
							'WritePropertyFunc = DylibSymbol(MFF, "WriteProperty")
							If .WritePropertyFunc <> 0 Then
								Dim As Boolean bTrue = True
								.WritePropertyFunc(.DesignControl, "IsChild", @bTrue)
								#IfDef __USE_GTK__
									.WritePropertyFunc(.DesignControl, "ParentWidget", pnlForm.Widget)
								#Else
									Dim As HWND pnlFormHandle = pnlForm.Handle
									.WritePropertyFunc(.DesignControl, "ParentHandle", @pnlFormHandle)
								#EndIf
								.WritePropertyFunc(.DesignControl, "Visible", @bTrue)
								'.DesignControl->Parent = @pnlForm
							End If
                            If .ReadPropertyFunc <> 0 Then
                            	#IfDef __USE_GTK__
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
								#Else
									Dim As HWND Ptr DCHandle = .ReadPropertyFunc(.DesignControl, "Handle")
									If DCHandle <> 0 Then
										SetParent *DCHandle, pnlForm.Handle
										.Dialog = *DCHandle
									End If
								#EndIf
                            End If
                            RequestAlign
                        End With
                    End If
                    cboClass.Items.Add(frmName, Des->DesignControl, "Form", "Form")
                    b = True
                ElseIf b Then
                    If Trim(LCase(.Lines(i)), Any !"\t ") = "end type" Then
                        t = True
                    ElseIf Not t Then
                        If StartsWith(Trim(LCase(.Lines(i)), Any !"\t "), "dim as ") Then
                            sText = Trim(Mid(Trim(.Lines(i), Any !"\t "), 8), Any !"\t ")
                            p = Instr(sText, " ")
                            If p Then
                                TypeName = Trim(Left(sText, p), Any !"\t ")
                                sText = Trim(Mid(Trim(sText, Any !"\t "), p))
                                If StartsWith(LCase(sText), "ptr ") OrElse StartsWith(LCase(sText), "pointer ") Then
                                    Continue For
                                    p = Instr(sText, " ")
                                    If p Then sText = Trim(Mid(Trim(sText), p), " ")
                                End If
                                ArgName = ""
                                p = Instr(sText, ",")
                                Do While p > 0
                                    ArgName = Trim(Left(sText, p - 1), Any !"\t ")
                                    Ctrl = Des->CreateControl(TypeName, ArgName, ArgName, 0, 0, 0, 0, 0)
                                    If Ctrl = 0 Then
                                    	lvComponentsList.ListItems.Add ArgName, TypeName
                                    End If
                                    cboClass.Items.Add ArgName, Ctrl, TypeName, TypeName, , 1
                                    sText = Trim(Mid(sText, p + 1), Any !"\t ")
                                    p = Instr(sText, ",")
                                Loop
                                Ctrl = Des->CreateControl(TypeName, sText, sText, 0, 0, 0, 0, 0)
                                If Ctrl = 0 Then
                                	lvComponentsList.ListItems.Add sText, TypeName
                                End If
                                cboClass.Items.Add sText, Ctrl, TypeName, TypeName, , 1
                            End If
                        End If
                    ElseIf CInt(Not c) AndAlso CInt(StartsWith(LTrim(LCase(.Lines(i)), Any !"\t ") & " ", "constructor " & LCase(frmName) & " ")) Then
                        c = True
                    ElseIf CInt(c) AndAlso Trim(LCase(.Lines(i)), Any !"\t ") = "end constructor" Then
                        c = False
                        'Exit For
                    ElseIf c Then
                        ArgName = ""
                        p = Instr(.Lines(i), ".")
                        p1 = Instr(.Lines(i), "=")
                        'If p > p1 Then p = 0
                        If p > 0 Then
                            ArgName = Trim(Left(.Lines(i), p - 1), Any !"\t ")
                            If lCase(ArgName) = "this" Then ArgName = frmName
                        ElseIf p1 AndAlso (Instr(.Lines(i), "->") = 0) Then
                            ArgName = frmName
                        End If
                        Ctrl = 0
                        If cboClass.Items.Contains(ArgName) Then
                            CBItem = cboClass.Items.Item(cboClass.Items.IndexOf(ArgName))
                            If CBItem <> 0 Then Ctrl = Cast(Any Ptr, CBItem->Object)
                        End If
                        If Ctrl Then
                            If p1 Then
                                PropertyName = Trim(Mid(.Lines(i), p + 1, p1 - p - 1), Any !"\t ")
                                FLin = Mid(.Lines(i), p1 + 1)
                                FLin = Trim(FLin, Any !"\t ")
                                If Len(FLin) <> 0 Then
                                    WLet FLine, Trim(Mid(.Lines(i), p1 + 1), Any !"\t ")
                                    If StartsWith(*FLine, "@") Then WLet FLine, Trim(Mid(*FLine, 2), Any !"\t ")
                                    If WriteObjProperty(Ctrl, PropertyName, *FLine) Then
                                        #IfDef __USE_GTK__
                                        	If LCase(PropertyName) = "parent" AndAlso Des->ReadPropertyFunc(Ctrl, "Widget") Then
												Des->HookControl(Des->ReadPropertyFunc(Ctrl, "Widget"))
												If SelControlName = QWString(Des->ReadPropertyFunc(Ctrl, "Name")) Then
													Des->SelectedControl = Ctrl
													Des->MoveDots Des->ReadPropertyFunc(Ctrl, "Widget"), False
													bSelControlFind = True
												End If
											End If
											gtk_widget_show(Des->ReadPropertyFunc(Ctrl, "Widget"))
                                        #Else
                                        	Dim hwnd1 As HWND Ptr = Des->ReadPropertyFunc(Ctrl, "Handle")
											If LCase(PropertyName) = "parent" AndAlso hwnd1 AndAlso *hwnd1 Then
												Des->HookControl(*hwnd1)
												If SelControlName = WGet(Des->ReadPropertyFunc(Ctrl, "Name")) Then
													Des->SelectedControl = Ctrl
													Des->MoveDots *hwnd1, False
													bSelControlFind = True
												End If
											End If
										#EndIF
                                    End If
                                End If
                            ElseIf LCase(Mid(.Lines(i), p + 1, 10)) = "setbounds " Then
                                lLeft = 0: lTop = 0: lWidth = 0: lHeight = 0
                                sText = Mid(.Lines(i), p + 10)
                                p1 = Instr(sText, ",")
                                If p1 > 0 Then
                                    lLeft = Val(Left(sText, p1 - 1))
                                    sText = Mid(sText, p1 + 1)
                                    p1 = Instr(sText, ",")
                                    If p1 > 0 Then
                                        lTop = Val(Left(sText, p1 - 1))
                                        sText = Mid(sText, p1 + 1)
                                        p1 = Instr(sText, ",")
                                        If p1 > 0 Then
                                            lWidth = Val(Left(sText, p1 - 1))
                                            lHeight = Val(Mid(sText, p1 + 1))
                                        End If
                                    End If
                                End If
                                If Des->ControlSetBoundsSub <> 0 Then
                                	Des->ControlSetBoundsSub(Ctrl, lLeft, lTop, lWidth, lHeight)
                                End If
                            End If
                        End If
                    End If
                End If
            Next
            If CInt(NotForms = False) AndAlso CInt(Des) AndAlso CInt(Des->DesignControl) AndAlso CInt(Not bSelControlFind) Then
                Des->SelectedControl = Des->DesignControl
                #IfDef __USE_GTK__
					Dim As GtkWidget Ptr Widget
					If Des->ReadPropertyFunc <> 0 Then Widget = Des->ReadPropertyFunc(Des->SelectedControl, "Widget")
					If Widget <> 0 Then gtk_widget_show_all(widget)
                #Else
                	Dim As HWND Ptr DesCtrlHandle
     				If Des->ReadPropertyFunc <> 0 Then DesCtrlHandle = Des->ReadPropertyFunc(Des->DesignControl, "Handle")
					Des->MoveDots *DesCtrlHandle, False
                #EndIf
                'FillAllProperties
            End If
            Functions.Sort
            If cboClass.ItemIndex = 0 Then
                Dim As TypeElement Ptr te1, te2
                Dim t As Boolean
                For i As Integer = cboFunction.Items.Count - 1 To 1 Step -1
                    te1 = cboFunction.Items.Item(i)->Object
                    t = False
                    If te1 = 0 Then Continue For
                    For j As Integer = 0 To Functions.Count - 1
                        te2 = Functions.Object(j)
                        If te2 = 0 Then Continue For
                        If CInt(*te1->Parameters = *te2->Parameters) Then 'CInt(Not te1->Find) AndAlso 
                            te1->StartLine = te2->StartLine
                            te1->EndLine = te2->EndLine
                            'te1->Find = True
                            te2->Find = True
                            t = True
                            Exit For
                        End If
                    Next j
                    If Not t Then
                        Delete te1
                        cboFunction.Items.Remove i
                    End If
                Next i
                For j As Integer = 0 To Functions.Count - 1
                    te2 = Functions.Object(j)
                    If Not te2->Find Then
                        Dim As String imgKey = "Sub"
                        If te2->ElementType = "Property" Then
                            imgKey = "Property"
                        ElseIf te2->ElementType = "Function" Then
                            imgKey = "Function"
                        End If
                        cboFunction.Items.Add te2->Name, te2, imgKey, imgKey
                    End If
                Next
                'cboClass_Change cboClass
                'OnLineChangeEdit txtCode, iSelEndLine
            End If
        End With
    'End If
    bNotDesign = False
    frmMain.UpdateUnLock
    Exit Sub
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Sub

Sub tbrTop_ButtonClick(ByRef Sender As My.Sys.Object)
    Var tb = Cast(TabWindow Ptr, Cast(ToolButton Ptr, @Sender)->Ctrl->Parent->Parent)
    With *tb
        Select Case Sender.ToString
        Case "Code"
            .pnlCode.Visible = True
            .pnlForm.Visible = False
            .splForm.Visible = False
        Case "Form"
            .pnlCode.Visible = False
            .pnlForm.Align = 5
            .pnlForm.Visible = True
            .splForm.Visible = False
            If .bNotDesign = False Then .FormDesign
        Case "CodeAndForm"
            .pnlForm.Align = 2
            .pnlForm.Width = 350
            .pnlForm.Visible = True
            .splForm.Visible = True
            .pnlCode.Visible = True
            If .bNotDesign = False Then .FormDesign
        End Select
        .RequestAlign
    End With
End Sub

Sub cboIntellisense_DropDown(ByRef Sender as ComboBoxEdit)
    Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    tb->txtCode.DropDownShowed = True
End Sub

Sub cboIntellisense_CloseUp(ByRef Sender as ComboBoxEdit)
    Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    tb->txtCode.DropDownShowed = False
End Sub

Sub TabWindow_Destroy(ByRef Sender As Control)
	App.DoEvents
	'Delete Cast(TabWindow Ptr, @Sender)
End Sub

Constructor TabWindow(ByRef wFileName As WString = "", bNew As Boolean = False, TreeN As TreeNode Ptr = 0)
    'FCaption = CAllocate(0)
    'FFileName = CAllocate(0)
    txtCode.Font.Name = "Courier New"
    txtCode.Font.Size = 10
    txtCode.Align = 5
    txtCode.OnChange = @OnChangeEdit
    txtCode.OnLineChange = @OnLineChangeEdit
    txtCode.OnKeyDown = @OnKeyDownEdit
    txtCode.OnKeyPress = @OnKeyPressEdit
    'OnPaste = @OnPasteEdit
    txtCode.OnMouseDown = @OnMouseDownEdit
    'txtCode.tbParent = @This
    This.Width = 180
    This.OnDestroy = @TabWindow_Destroy
    btnClose.tbParent = @This
    #IfDef __USE_GTK__
    	pnlTop.Height = 33
    #Else
		pnlTop.Height = 25
    #EndIf
    pnlTop.Align = 3
    #IfDef __USE_GTK__
		pnlTopCombo.Height = 33
    #Else
		pnlTopCombo.Height = 25
    #EndIf
    mnuCode.ImagesList = @imgList '<m>
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
	txtCode.ContextMenu = @mnuCode
    pnlTopCombo.Align = 5
    pnlTopCombo.Width = 101
    pnlForm.Name = "Designer"
    pnlForm.Width = 360
    pnlForm.Align = 2    
    pnlCode.Align = 5
    pnlEdit.Align = 5
    lvComponentsList.Height = 30
    lvComponentsList.Align = 4
    lvComponentsList.ColumnHeaderHidden = True
    lvComponentsList.Columns.Add "Component", , 200
    'lvComponentsList.Images = @imgListTools
    'lvComponentsList.StateImages = @imgListTools
	'lvComponentsList.SmallImages = @imgListTools
	'lvComponentsList.View = vsIcon
    splFormList.Align = 4
    'Dim As My.Sys.Drawing.Cursor crRArrow, crHand
    'crRArrow.LoadFromResourceName("Select")
    'crHand.LoadFromResourceName("Hand")
    splForm.Align = 2
    cboClass.ImagesList = @imgListTools
    'cboClass.ItemIndex = 0
    'cboClass.SetBounds 0, 2, 60, 20
    tbrTop.ImagesList = @imgList
    #IfDef __USE_GTK__
		tbrTop.Width = 100
	#Else
		tbrTop.Width = 75
    #EndIf
    tbrTop.Align = 2
    tbrTop.Buttons.Add tbsSeparator
    tbrTop.Buttons.Add tbsCheckGroup, "Code", , @tbrTop_ButtonClick, "Code", , ML("Show Code")
    tbrTop.Buttons.Add tbsCheckGroup, "Form", , @tbrTop_ButtonClick, "Form", , ML("Show Form")
    tbrTop.Buttons.Add tbsCheckGroup, "CodeAndForm", , @tbrTop_ButtonClick, "CodeAndForm", , ML("Show Code And Form")
    tbrTop.Flat = True
    cboClass.Width = 50
    #IfDEF __USE_GTK__
		cboClass.Top = 0
		#IfDef __USE_GTK3__
			cboClass.Height = 20
		#Else
			cboClass.Height = 30
		#EndIf
    #Else
		cboClass.Top = 2
		cboClass.Height = 30 * 22
    #EndIf
    cboClass.Anchor.Left = asAnchor
    cboClass.Anchor.Right = asAnchorProportional
    cboClass.OnSelected = @cboClass_Change
    cboClass.ImagesList = @imgListTools
    cboFunction.ImagesList = @imgList
    cboFunction.Left = 50 + 0 + 1
    cboFunction.Width = 50
    #IfDEF __USE_GTK__
		cboFunction.Top = 0
		#IfDef __USE_GTK3__
			cboFunction.Height = 20
		#Else
			cboFunction.Height = 30
		#EndIf
    #Else
		cboFunction.Top = 2
		cboFunction.Height = 30 * 22
    #EndIf
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
    If CInt(wFileName <> "") And CInt(bNew = False) Then
        FileName = wFileName
        'txtCode.LoadFromFile(wFileName, False)
        This.Caption = GetFileName(wFileName)
    Else
        This.Caption = ML("Untitled") & "*"
    End if
    pnlForm.Top = -500
    pnlForm.Add @lvComponentsList
    pnlForm.Add @splFormList
    pnlCode.Add @txtCode
    This.Add @pnlTop
    This.Add @pnlForm
    This.Add @splForm
    This.Add @pnlCode
    #IfDef __USE_GTK__
    	txtCode.lvIntellisense.OnItemActivate = @lvIntellisense_ItemActivate
    #Else
	    txtCode.cboIntellisense.ImagesList = @imgList
	    txtCode.cboIntellisense.OnDropDown = @cboIntellisense_DropDown
	    txtCode.cboIntellisense.OnCloseUp = @cboIntellisense_CloseUp
	    txtCode.cboIntellisense.OnSelected = @cboIntellisense_Selected
    #EndIf
    'cboIntellisense.Style = cbDropDown
    This.ImageIndex = imgList.IndexOf("File")
    This.ImageKey = "File"
'    OnHandleIsAllocated = @HandleIsAllocated
    If TreeN <> 0 Then
        tn = TreeN
    Else
        Dim As ExplorerElement Ptr ee
        For i As Integer = 0 To tvExplorer.Nodes.Count - 1
            ee = tvExplorer.Nodes.Item(i)->Tag
            If ee <> 0 Then
                If *ee->FileName = FileName Then
                    tn = tvExplorer.Nodes.Item(i)
                    Exit For
                End If
            End If
            For j As Integer = 0 To tvExplorer.Nodes.Item(i)->Nodes.Count - 1
                ee = tvExplorer.Nodes.Item(i)->Nodes.Item(j)->Tag
                If ee <> 0 Then
                    If *ee->FileName = FileName Then
                        tn = tvExplorer.Nodes.Item(i)->Nodes.Item(j)
                        Exit For
                    End If
                End If
            Next
            If tn <> 0 Then Exit For
        Next i
        If tn = 0 Then
            tn = tvExplorer.Nodes.Add(This.Caption, , , "File", "File")
        End If
    End If
End Constructor

Destructor TabWindow
    If FCaptionNew Then DeAllocate FCaptionNew
    If FFileName Then DeAllocate FFileName
    If FLine Then DeAllocate FLine
    If FLine1 Then DeAllocate FLine1
    If FLine2 Then DeAllocate FLine2
    If Des <> 0 Then
'	    If Des->DeleteComponentFunc <> 0 Then
'		    For i As Integer = 2 To cboClass.Items.Count - 1
'		    	CurCtrl = 0
'		    	CBItem = cboClass.Items.Item(i)
'		    	If CBItem <> 0 Then CurCtrl = CBItem->Object
'		     	If CurCtrl <> 0 Then
'		      		Des->DeleteComponentFunc(CurCtrl)
'		      	End If
'		    Next i
'		    Des->DeleteComponentFunc(Des->DesignControl)
'		End If
		'Delete Des
	End If
	'Functions.Clear
    If tabRight.Tag = @This Then tabRight.Tag = 0
    'If tn <> 0 Then tvExplorer.RemoveRoot tvExplorer.IndexOfRoot(tn)
End Destructor

Public Function STATEIMAGEMASKTOINDEX(iState As Integer) As Integer

  STATEIMAGEMASKTOINDEX = iState / (2 ^ 12)
End Function

#IfNDef __USE_GTK__
	Public Function Listview_GetItemStateEx(hwndLV As HWND, iItem As Integer, ByRef iIndent As Integer) As Integer
		Dim lvi As LVITEM

	  
		lvi.mask = LVIF_STATE Or LVIF_INDENT
		lvi.iItem = iItem
		lvi.stateMask = LVIS_STATEIMAGEMASK

	  
		If ListView_GetItem(hwndLV, @lvi) Then
			iIndent = lvi.iIndent
			Return STATEIMAGEMASKTOINDEX(lvi.state And LVIS_STATEIMAGEMASK)
		End If

	  
	End Function
#EndIf

#IfNDef __USE_GTK__
	Public Function Listview_SetItemStateEx(hwndLV As HWND, iItem As Integer, iIndent As Integer, dwState As Integer) As Boolean
		Dim lvi As LVITEM
		lvi.mask = LVIF_STATE Or LVIF_INDENT
		lvi.iItem = iItem
		lvi.iIndent = iIndent
		lvi.state = INDEXTOSTATEIMAGEMASK(dwState)
		lvi.stateMask = LVIS_STATEIMAGEMASK
		Return ListView_SetItem(hwndLV, @lvi)
	End Function
#EndIF

Sub AddChildItems(iParentItem As Integer, iParentIndent As Integer)
    If (iParentItem <> -1) Then
		#IfNDef __USE_GTK__
			Listview_SetItemStateEx(lvProperties.Handle, iParentItem, iParentIndent, 2)
        #EndIf
        Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, tabRight.Tag)
        If tb = 0 Then Exit Sub
        If tb->Des = 0 Then Exit Sub
        If tb->Des->ReadPropertyFunc = 0 Then Exit Sub
        If tb->Des->SelectedControl = 0 Then Exit Sub
        Dim PropertyName As String = GetItemText(lvProperties.ListItems.Item(iParentItem))
        Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), PropertyName)
        If te = 0 Then Exit Sub
        tabRight.UpdateLock
        Dim lvItem As ListViewItem Ptr
        FPropertyItems.Clear
        tb->FillProperties te->TypeName
        FPropertyItems.Sort
        For lvPropertyCount As Integer = FPropertyItems.Count - 1 To 0 Step -1
            te = FPropertyItems.Object(lvPropertyCount)
            If te = 0 Then Continue For
            With *te
                If Cint(LCase(.Name) <> "handle") AndAlso Cint(LCase(.TypeName) <> "hwnd") AndAlso Cint(.ElementType = "Property") Then
                    lvItem = lvProperties.ListItems.Insert(iParentItem + 1, FPropertyItems.Item(lvPropertyCount), 2, IIF(Comps.Contains(.TypeName), 1, 0), iParentIndent + 1)
                    lvItem->Text(1) = tb->ReadObjProperty(tb->Des->SelectedControl, PropertyName & "." & FPropertyItems.Item(lvPropertyCount))
                End If
            End With
        Next
        tabRight.UpdateUnlock
    End If
End Sub

Sub RemoveChildItems(iParentItem As Integer, iParentIndent As Integer)
    #IfNDef __USE_GTK__
		Listview_SetItemStateEx(lvProperties.Handle, iParentItem, iParentIndent, 1)
    #EndIf
    Var nItems = lvProperties.ListItems.Count
    Dim iChildIndent As Integer
    Do
		#IfNDef __USE_GTK__
			Listview_GetItemStateEx(lvProperties.Handle, iParentItem + 1, iChildIndent)
        #EndIf
        If (iChildIndent > iParentIndent) Then
            
            ' Remove the item directly below the collapsing parent (VB ListItems are one-based)
            lvProperties.ListItems.Remove (iParentItem + 1)
            
            ' Keep a count of ListView items so we don't try to remove more
            ' items than are in the ListView (when collapsing the last parent).

           nItems = nItems - 1
        End If

  Loop While (iChildIndent > iParentIndent) And (iParentItem + 1 < nItems)
End Sub

Sub ClickProperty(Item As Integer)
    Dim dwState As Integer
    Dim iIndent As Integer
    #IfNDef __USE_GTK__
		Dim lvi As LVITEM
		lvi.mask = LVIF_STATE Or LVIF_INDENT
		lvi.iItem = Item
		lvi.stateMask = LVIS_STATEIMAGEMASK
		If ListView_GetItem(lvProperties.Handle, @lvi) Then
			iIndent = lvi.iIndent
			dwState = STATEIMAGEMASKTOINDEX(lvi.state And LVIS_STATEIMAGEMASK)
			If dwState > 0 Then
				If (dwState = 1) Then
					AddChildItems(Item, iIndent)            
				Else
					RemoveChildItems(Item, iIndent)
				End If
			End If
		End If
	#EndIf
End Sub

Sub lvProperties_MouseDown(BYREF Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
    #IfNDef __USE_GTK__
		Dim lvhti As LVHITTESTINFO
		If MouseButton = 0 Then
			lvhti.pt.x = x
			lvhti.pt.y = y
			If (ListView_HitTest(Sender.Handle, @lvhti) <> -1) Then
				If (lvhti.flags = LVHT_ONITEMSTATEICON) Then
					ClickProperty lvhti.iItem
				End If
			End If
		End If
	#EndIf
End Sub

Sub SplitError(ByRef sLine As WString, ByRef ErrFileName As WString Ptr, ByRef ErrTitle As WString Ptr, ByRef ErrorLine As Integer)
    Dim As Integer Pos1, Pos2
    WLet ErrTitle, sLine
    Pos1 = Instr(sLine, ") error ")
    If Pos1 = 0 Then Pos1 = Instr(sLine, ") warning ")
    If Pos1 = 0 Then Exit Sub
    Pos2 = instrRev(sLine, "(", Pos1)
    If Pos2 = 0 Then Return
    ErrorLine = Val(Mid(sLine, Pos2 + 1, Pos1 - Pos2 - 1))
    If ErrorLine = 0 Then Return
    WLet ErrFileName, Left(sLine, Pos2 - 1)
    WLet ErrTitle, Mid(sLine, Pos1 + 1)
End Sub

Sub Versioning(ByRef FileName As WString, ByRef sFirstLine As WString)
    If AutoIncrement Then
        If StartsWith(LTrim(LCase(sFirstLine), Any !"\t "), "'#compile ") Then
            Dim As WString Ptr Buff, File, sLine, sLines
            WLet Buff, Mid(LTrim(sFirstLine, Any !"\t "), 11)
            Var Pos1 = Instr(*Buff, """"), Pos2 = 1
            Dim QavsBoshi As Boolean
            Do While Pos1 > 0
                QavsBoshi = Not QavsBoshi
                If QavsBoshi Then
                    Pos2 = Pos1
                Else
                    WLet File, Mid(*Buff, Pos2 + 1, Pos1 - Pos2 - 1)
                    If EndsWith(LCase(*File), ".rc") Then
                        WLet File, GetFolderName(FileName) & *File
                        If Not FileExists(*File) Then
                            If AutoCreateRC Then
								#IfNDef __USE_GTK__
									FileCopy ExePath & "/templates/Resource.rc", *File
									If Not FileExists(GetFolderName(FileName) & "xpmanifest.xml") Then
										FileCopy ExePath & "/templates/xpmanifest.xml", GetFolderName(FileName) & "xpmanifest.xml"
									End If
								#EndIf
                            End If
                        Else
                            If Open(*File For Input Encoding "utf-8" As #1) = 0 Then
                                Var n = 0
                                Var bFinded = False
                                WReallocate sLine, LOF(1)
                                Do Until EOF(1)
                                    Line Input #1, *sLine
                                    n += 1
                                    If StartsWith(LCase(*sLine), "#define ver_fileversion ") Then
                                        Var Pos3 = InstrRev(*sLine, ",")
                                        If Pos3 > 0 Then
                                            WLet sLines, *sLines & IIF(n = 1, "", WChr(13) & WChr(10)) & Left(*sLine, Pos3) & Val(Mid(*sLine, Pos3 + 1)) + 1
                                            bFinded = True
                                        End If
                                    ElseIf StartsWith(LCase(*sLine), "#define ver_fileversion_str ") Then
                                        Var Pos3 = InstrRev(*sLine, ".")
                                        If Pos3 > 0 Then
                                            WLet sLines, *sLines & IIF(n = 1, "", WChr(13) & WChr(10)) & Left(*sLine, Pos3) & Val(Mid(*sLine, Pos3 + 1, Len(*sLine) - Pos3 - 3)) + 1 & "\0"""
                                            bFinded = True
                                        End If
                                    Else
                                        WLet sLines, *sLines & IIF(n = 1, "", WChr(13) & WChr(10)) & *sLine
                                    End If
                                Loop
                                Close #1
                                If bFinded Then
                                    If Open(*File For Output Encoding "utf-8" As #1) = 0 Then
                                        Print #1, *sLines;
                                        Close #1
                                    End If
                                End If
                                Exit Do
                            End If
                        End If
                    End If
                End If
                Pos1 = Instr(Pos1 + 1, *Buff, """")
            Loop
            If Buff Then Deallocate Buff
            If File Then Deallocate File
            If sLine Then Deallocate sLine
            If sLines Then Deallocate sLines
        End If
    End If
End Sub

Sub PipeCmd(ByRef file As WString, ByRef cmd As WString)
    Dim As WString Ptr fileW, cmdW
    'WLet fileW, file
    'WLet cmdW, cmd
    #IfDef __USE_GTK__
    	Shell cmd
    	'Dim As gint i_retcode = 0, i_exitcode = 0
    	'i_retcode = g_spawn_command_line_sync(ToUTF8(cmd), NULL, NULL, @i_exitcode, NULL)
    #Else
		WLet cmdW, "cmd /c """ + cmd + """|clip"
		Dim PI As PROCESS_INFORMATION
		Dim SI As STARTUPINFO
		SI.wShowWindow = SW_HIDE
		SI.cb = SizeOf(STARTUPINFO)
		SI.dwFlags = STARTF_USESHOWWINDOW

	   
		CreateProcess(0, cmdW, 0, 0, 1, NORMAL_PRIORITY_CLASS, 0, 0, @SI, @PI)
		WaitForSingleObject(PI.hProcess, INFINITE)
		CloseHandle(PI.hProcess)
		CloseHandle(PI.hThread)
	#EndIf
End Sub

Function GetParentNode(tn As TreeNode Ptr) As TreeNode Ptr
    If tn->ParentNode = 0 Then
        Return tn
    Else
        Return GetParentNode(tn->ParentNode) 
    End If
End Function

Function GetMainFile(bSaveTab As Boolean = False) ByRef As WString
    Dim As TabWindow Ptr tb
    If MainNode Then
    	Dim ee As ExplorerElement Ptr
    	ee = MainNode->Tag
    	If MainNode->ImageKey = "Project" Then
    		If ee = 0 OrElse WGet(ee->MainFileName) = "" Then
    			MsgBox ML("Project Main File don't set")
    		Else
    			Return *ee->MainFileName
    		End If
    	ElseIf ee = 0 OrElse ee->FileName = 0 OrElse *ee->FileName = "" Then
	        For i As Integer = 0 To tabCode.TabCount - 1
	        	tb = Cast(TabWindow Ptr, tabCode.Tabs[i])
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
        tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
        If tb = 0 OrElse tb->tn = 0 Then Return ""
        If bSaveTab Then
	        If tb->Modified Then tb->Save
		End If
		Var tn = GetParentNode(tb->tn)
		If tn->ImageKey = "Project" Then
    		Dim As ExplorerElement Ptr ee = tn->Tag
    		If ee AndAlso ee->MainFileName <> 0 AndAlso *ee->MainFileName <> "" Then Return *ee->MainFileName
    	End If
        Return tb->FileName
    End If
    Return ""
End Function

Function Compile(Parameter As String = "") As Integer
    On Error Goto ErrorHandler
    Dim MainFile As WString Ptr = @(GetMainFile(AutoSaveCompile))
    Dim FirstLine As WString Ptr = @(GetFirstCompileLine(*MainFile))
    Versioning *MainFile, *FirstLine
    Dim FileOut As Integer
    Dim FbcExe As WString Ptr
    Dim ExeName As WString Ptr = @(GetExeFileName(*MainFile, *FirstLine))
    Dim LogFileName As WString Ptr
    Dim LogFileName2 As WString Ptr
    Dim BatFileName As WString Ptr
    Dim fbcCommand As WString Ptr
    Dim CompileWith As WString Ptr
    Dim MFFPathC As WString Ptr
    Dim As WString Ptr ErrFileName, ErrTitle
    Dim As Integer iLine
    Dim LogText As WString Ptr
    WLet MFFPathC, *MFFPath
    If CInt(Instr(*MFFPathC, ":") = 0) AndAlso CInt(Not StartsWith(*MFFPathC, "/")) Then WLet MFFPathC, ExePath & "/" & *MFFPath
    If tbStandard.Buttons.Item("B32")->Checked Then
        FbcExe = Compilator32
    Else
        FbcExe = Compilator64
    End If
	#IfDef __USE_GTK__
		If g_find_program_in_path(*FbcExe) = NULL Then
			ShowMessages ML("File") & " """ & *FbcExe & """ " & ML("not found") & "!"
		Return 0
		End If
	#Else
	    If Not FileExists(*FbcExe) Then
	        ShowMessages ML("File") & " """ & *FbcExe & """ " & ML("not found") & "!"
	        Return 0
	    End If
	#EndIf
    WLet BatFileName, ExePath + "/debug.bat"
    Dim As Boolean Band, Yaratilmadi
    CHDir(GetFolderName(*MainFile))
    If Parameter = "Check" Then
        WLet ExeName, "chk.dll"
    End If
    ClearMessages
    If *FbcExe <> "" Then
        FileOut = FreeFile
        If Dir(*ExeName) <> "" Then 'delete exe if exist
            If Kill(*ExeName) <> 0 Then
	            'ShowMessages(Str(Time) & ": " & "Exe fayl band.")
	            Band = True
                'Return 0
            End If
        End If
        If StartsWith(LTrim(LCase(*FirstLine), Any !"\t "), "'#compile ") Then
            WLet CompileWith, Mid(LTrim(*FirstLine, Any !"\t "), 10)
        Else
        	WLet CompileWith, ""
        End If
        If CInt(InStr(*CompileWith, " -s ") = 0) AndAlso CInt(tbStandard.Buttons.Item("Form")->Checked) Then
        	WLet CompileWith, *CompileWith & " -s gui"
        End If
        WLet LogFileName, ExePath & "/debug_compil.log"
        WLet LogFileName2, ExePath & "/debug_compil2.log"
        WLet fbcCommand, " -b """ & *MainFile & """ " & *CompileWith & " -i """ & *MFFPathC & """"
        If Parameter <> "" Then
            If Parameter = "Check" Then WLet fbcCommand, *fbcCommand & " -x """ & *ExeName & """" Else WLet fbcCommand, *fbcCommand & " " & Parameter
        End If
        If Parameter <> "Check" Then ShowMessages(Str(Time) + ": " + ML("Compilation") & ": """ & *fbcexe & """ " & *fbcCommand + " ..." + WChr(13) + WChr(10))
        'OPEN *BatFileName For Output As #FileOut
        'Print #FileOut, *fbcCommand  + " > """ + *LogFileName + """" + " 2>""" + *LogFileName2 + """"
        'Close #FileOut
        'Shell("""" + BatFileName + """")
        CHDir(GetFolderName(*MainFile))
        'Shell(*fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """")
        'Open Pipe *fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """" For Input As #1
        'Close #1
        PipeCmd "", """" & *fbcexe & """ " & *fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """"
        #IfDef __USE_GTK__
        	Yaratilmadi = g_find_program_in_path(*ExeName) = NULL
        #Else
        	Yaratilmadi = Dir(*ExeName) = ""
        #EndIf
        lvErrors.ListItems.Clear
        Dim As Long nLen, nLen2
        If Open(*LogFileName For Input As #1) = 0 Then
            nLen = LOF(1) + 1
            Dim Buff As WString Ptr
            WReallocate LogText, nLen * 2 + 2
            *LogText = ""
            WLet Buff, Space(nLen)
            While Not EOF(1)
                Line Input #1, *Buff
                SplitError(*Buff, ErrFileName, ErrTitle, iLine)
                lvErrors.ListItems.Add *ErrTitle, IIF(Instr(*ErrTitle, "warning"), "Warning", "Error")
                lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(1) = WStr(iLine)
                lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(2) = *ErrFileName
                *LogText = *LogText & *Buff & WChr(13) & WChr(10)
            Wend
            WDeallocate Buff
			Close #1
        End If
        
        If Open(*LogFileName2 For Input As #1) = 0 Then
            nLen2 = LOF(1) + 1
            Dim Buff As WString Ptr
            WReallocate LogText, (nLen + nLen2) * 2 + 2
            WLet Buff, Space(nLen2)
            While Not EOF(1)
                Line Input #1, *Buff
                'If Trim(*Buff) <> "" Then lvErrors.ListItems.Add *Buff
                *LogText = *LogText & *Buff & WChr(13) & WChr(10)
            Wend
			Close #1
			WDeallocate Buff
        End If
        
        If lvErrors.ListItems.Count <> 0 Then
            tabBottom.Tabs[1]->Caption = ML("Errors") & " (" & lvErrors.ListItems.Count & " " & ML("Pos") & ")"
        Else
            tabBottom.Tabs[1]->Caption = ML("Errors")
        End If
        ShowMessages(*LogText)
        If LogFileName Then Deallocate LogFileName
        If LogFileName2 Then Deallocate LogFileName2
        If BatFileName Then Deallocate BatFileName
        WDeallocate fbcCommand
        WDeallocate CompileWith
        WDeallocate MFFPathC
        If Yaratilmadi Or Band Then
            If Parameter <> "Check" Then
                ShowMessages(Str(Time) & ": " & ML("Do not build file."))
                If lvErrors.ListItems.Count <> 0 Then tabBottom.Tabs[1]->SelectTab
            ElseIf lvErrors.ListItems.Count <> 0 Then
                ShowMessages(Str(Time) & ": " & ML("Checking ended."))
                tabBottom.Tabs[1]->SelectTab
            Else
                ShowMessages(Str(Time) & ": " & ML("No errors or warnings were found."))
            End If
            WDeallocate LogText
            Return 0
        Else
            If Instr(*LogText, "warning") > 0 Then
                If Parameter <> "Check" Then
                    ShowMessages(Str(Time) & ": " & ML("Layout has been successfully completed, but there are warnings."))
                End If
            Else
                If Parameter <> "Check" Then
                    ShowMessages(Str(Time) & ": " & ML("Layout succeeded!"))
                Else
                    ShowMessages(Str(Time) & ": " & ML("Syntax errors not found!"))
                End If
            End If
            WDeallocate LogText
            return 1
        End If
    Else
		WDeallocate LogText
        Return 0
    End If
    Exit Function
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Function

#IfDef __USE_GTK__
	Function build_create_shellscript(ByRef working_dir As WString, ByRef cmd As WString, autoclose As Boolean, debug As Boolean = False) ByRef As WString
		'?Replace(cmd, "\", "/")
		'?!"#!/bin/sh\n\nrm $0\n\ncd " & Replace(working_dir, "\", "/") & !"\n\n" & Replace(cmd, "\", "/") & !"\n\necho ""\n\n------------------\n(program exited with code: $?)"" \n\n" & IIF(autoclose, "", !"\necho ""Press return to continue""\n#to be more compatible with shells like ""dash\ndummy_var=""""\nread dummy_var") & !"\n"
		Dim As WString Ptr ScriptPath
		WLet ScriptPath, *g_get_tmp_dir() & "/vfb_run_script.sh"
		Open *ScriptPath For Output As #1
		Print #1, "#!/bin/sh"
		Print #1, ""
		Print #1, "rm $0"
		Print #1, ""
		Print #1, "cd " & Replace(working_dir, "\", "/")
		Print #1, ""
		Print #1, IIF(debug, """" & WGet(Debugger) & """" & " ", "") & Replace(cmd, "\", "/")
		Print #1, ""
		Print #1, !"echo ""\n\n------------------\n(program exited with code: $?)"" \n\n" & IIF(autoclose, "", !"\necho ""Press return to continue""\n#to be more compatible with shells like ""dash\ndummy_var=""""\nread dummy_var") & !"\n"
		Close #1
		WLet ScriptPath, "sh " & *ScriptPath
		Return *ScriptPath
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
'/' Incomplete VteTerminal struct from vte/vte.h. '/
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

Sub RunPr(Debugger As String = "")
    On Error Goto ErrorHandler
    Dim Result As Integer
    Dim MainFile As WString Ptr = @(GetMainFile())
    Dim FirstLine As WString Ptr = @(GetFirstCompileLine(*MainFile))
    Dim ExeFileName As WString Ptr = @(GetExeFileName(*MainFile, *FirstLine))
    ShowMessages(Time & ": " & ML("Run") & ": " & *ExeFileName + " ...")
    #IfDef __USE_GTK__
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
	    	Shell """" & WGet(Terminal) & """ -e """ & build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False) & """"
	    'EndIf
    	'i_retcode = g_spawn_command_line_sync(ToUTF8(build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)), NULL, NULL, @i_exitcode, NULL)
    	'?build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)
    	'Shell "sh " & build_create_shellscript(GetFolderName(*ExeFileName), *ExeFileName, False)
    #Else
    	Dim As Integer pClass
    	Dim As WString Ptr Workdir, CmdL
    	Dim As Unsigned Long ExitCode
    	Dim SInfo As STARTUPINFO
		Dim PInfo As PROCESS_INFORMATION
		WLet CmdL, """" & GetFileName(*ExeFileName) & """ "
		WLet ExeFileName, Replace(*ExeFileName, "/", "\") 
		Var Pos1 = 0
	    While InStr(Pos1 + 1, *ExeFileName, "\")
	       Pos1 = InStr(Pos1 + 1, *ExeFileName, "\")
	    Wend
	    If Pos1 = 0 Then Pos1 = Len(*ExeFileName)
	    WLet Workdir, Left(*ExeFileName, Pos1)
    	SInfo.cb = Len(SInfo)
		SInfo.dwFlags = STARTF_USESHOWWINDOW
		SInfo.wShowWindow = SW_NORMAL
    	pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
		If CreateProcessW(ExeFileName, CmdL, ByVal Null, ByVal Null, False, pClass, Null, Workdir, @SInfo, @PInfo) Then
			WaitForSingleObject pinfo.hProcess, INFINITE
			GetExitCodeProcess(pinfo.hProcess, @ExitCode)
			CloseHandle(pinfo.hProcess)
	    	CloseHandle(pinfo.hThread)
	    End If
		If WorkDir Then Deallocate WorkDir
    	If CmdL Then Deallocate CmdL
    	Result = ExitCode
		'Result = Shell(Debugger & """" & *ExeFileName + """")
		ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
    #EndIf
    If ExeFileName Then Deallocate ExeFileName
	Exit Sub
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Sub

Sub RunProgram(Param As Any Ptr)
    RunPr
End Sub

Sub TabWindow.NumberOn
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    With tb->txtCode
        .UpdateLock
        .Changing("Raqamlash")
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        .GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Dim As EditControlLine Ptr FECLine
        Dim As Integer n
        Dim As Boolean bNotNumberNext, bNotNumberThis
        For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
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
            ElseIf FECLine->ConstructionIndex >= 7 Then
                Continue For
            End If
            n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
            If StartsWith(LTrim(*FECLine->Text), "?") Then
                Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
                If IsNumeric(Mid(Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
                    WLet FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1)
                End If
            ElseIf IsLabel(*FECLine->Text) Then
                bNotNumberThis = True
            End If
            If Not bNotNumberThis Then
                WLet FECLine->Text, "?" & WStr(i + 1) & ":" & *FECLine->Text
            End If
        Next i
        .Changed("Raqamlash")
        .UpdateUnLock
        '.ShowCaretPos True
    End With
End Sub

Sub TabWindow.ProcedureNumberOn
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    With tb->txtCode
        .UpdateLock
        .Changing("Raqamlash")
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        .GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Dim As EditControlLine Ptr FECLine
        Dim As Integer n
        Dim As Boolean bNotNumberNext, bNotNumberThis
        For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
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
            ElseIf FECLine->ConstructionIndex >= 7 Then
                Continue For
            End If
            n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
            If StartsWith(LTrim(*FECLine->Text), "?") Then
                Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
                If IsNumeric(Mid(Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
                    WLet FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1)
                End If
            ElseIf IsLabel(*FECLine->Text) Then
                bNotNumberThis = True
            End If
            If Not bNotNumberThis Then
                WLet FECLine->Text, "?" & WStr(i + 1) & ":" & *FECLine->Text
            End If
        Next i
        .Changed("Raqamlash")
        .UpdateUnLock
        '.ShowCaretPos True
    End With
End Sub

Sub TabWindow.SetErrorHandling(StartLine As String, EndLine As String)
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
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
            If FECLine->ConstructionIndex > 11  Then
                If FECLine->ConstructionPart = 0 Then
                    ehStart = i + 1
                    Select Case FECLine->ConstructionIndex
                    Case 12: ExitLine = "Exit Sub"
                    Case 13: ExitLine = "Exit Function"
                    Case 14: ExitLine = "Exit Property"
                    Case 15: ExitLine = "Exit Operator"
                    Case 16: ExitLine = "Exit Constructor"
                    Case 17: ExitLine = "Exit Destructor"
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
                    If FECLine->ConstructionIndex > 11  Then
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
                If Not t then
                    ehEnd = i
                End If
            End If
            t = False
            Dim p As Integer
            For i As Integer = ehEnd - 1 To ehStart Step -1
                FECLine = .FLines.Items[i]
                If FECLine->ConstructionIndex > 11 Then
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
                If FECLine->ConstructionIndex > 11 Then
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
                .InsertLine ehEnd + 4, Space(n + 4) & """in line "" & Erl() & "" "" & _"
                .InsertLine ehEnd + 5, Space(n + 4) & """in function "" & ZGet(Erfn()) & "" "" & _"
                .InsertLine ehEnd + 6, Space(n + 4) & """in module "" & ZGet(Ermn())"
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

Sub TabWindow.FormatBlock
End Sub

Sub TabWindow.NumberOff
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    With tb->txtCode
        .UpdateLock
        .Changing("Raqamlarni olish")
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        .GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Dim As EditControlLine Ptr FECLine
        Dim As Integer n
        For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
            FECLine = .FLines.Items[i]
            n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
            If StartsWith(LTrim(*FECLine->Text), "?") Then
                Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
                If IsNumeric(Mid(Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
                    WLet FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1)
                End If
            End If
        Next i
        .Changed("Raqamlarni olish")
        .UpdateUnLock
        '.ShowCaretPos True
    End With
End Sub

Sub TabWindow.ProcedureNumberOff
    Var tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
    If tb = 0 Then Exit Sub
    With tb->txtCode
        .UpdateLock
        .Changing("Raqamlarni olish")
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        .GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Dim As EditControlLine Ptr FECLine
        Dim As Integer n
        For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
            FECLine = .FLines.Items[i]
            n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
            If StartsWith(LTrim(*FECLine->Text), "?") Then
                Var Pos1 = InStr(LTrim(*FECLine->Text), ":")
                If IsNumeric(Mid(Left(LTrim(*FECLine->Text), Pos1 - 1), 2)) Then
                    WLet FECLine->Text, Space(n) & Mid(LTrim(*FECLine->Text), Pos1 + 1)
                End If
            End If
        Next i
        .Changed("Raqamlarni olish")
        .UpdateUnLock
        '.ShowCaretPos True
    End With
End Sub

Sub TabWindow.Define
    'Dim As Integer sSelStart = txtCode.SelStart
    
End Sub

