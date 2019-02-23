#Include Once "mff/Panel.bi"
#Include Once "mff/ComboBoxEx.bi"
#Include Once "mff/Canvas.bi"
#Include Once "mff/WStringList.bi"
#Include Once "mff/Clipboard.bi"

'declare sub gtk_widget_set_focus_on_click(byval widget as GtkWidget ptr, byval focus_on_click as gboolean)

Namespace My.Sys.Forms
    #DEFINE QEditControl(__Ptr__) *Cast(EditControl Ptr,__Ptr__)

    Type EditControlHistory
        Comment As WString Ptr
        Lines As List
        OldSelStartLine As Integer
        OldSelEndLine As Integer
        OldSelStartChar As Integer
        OldSelEndChar As Integer
        SelStartLine As Integer
        SelEndLine As Integer
        SelStartChar As Integer
        SelEndChar As Integer
        Declare Destructor
    End Type
    
    Type EditControlLine
        Text As WString Ptr
        CommentIndex As Integer
        Breakpoint As Boolean
        Bookmark As Boolean
        ConstructionIndex As Integer
        ConstructionPart As Integer
        Collapsible As Boolean
        Collapsed As Boolean
        InCollapse As Boolean
        Visible As Boolean
        Declare Constructor
        Declare Destructor
    End Type
    
    Destructor EditControlHistory
        If Comment Then Deallocate Comment
        For i As Integer = Lines.Count - 1 To 0 Step -1
            Delete Cast(EditControlLine Ptr, Lines.Items[i])
        Next i
        Lines.Clear
    End Destructor

    Constructor EditControlLine
        Visible = True
    End Constructor

    Destructor EditControlLine
        If Text Then Deallocate Text
    End Destructor

    Type EditControl Extends Control
        Private:
            Dim FHistory As List
            Dim FVisibleLinesCount As Integer
            Dim FECLine As EditControlLine Ptr
            Dim bAddText As Boolean
            Dim bOldCommented As Boolean
            Dim curHistory As Integer
            Dim crRArrow As My.Sys.Drawing.Cursor
            Dim crHand As My.Sys.Drawing.Cursor
            Dim FLine As WString Ptr
            Dim FLineLeft As WString Ptr
            Dim FLineRight As WString Ptr
            Dim FLineTemp As WString Ptr
            Dim FLineSpace As WString Ptr
            Dim HScrollMax As Integer
            Dim VScrollMax As Integer
            Dim nCaretPosX As Integer = 0 ' горизонтальная координата каретки
            Dim nCaretPosY As Integer = 0 ' вертикальная координата каретки
            Dim iPos As Integer
            Dim iPP As Integer = 0
            Dim jPos As Integer
            Dim jPP As Integer = 0
            Dim iPPos As Integer
            Dim FCurLine As Integer = 0
            Dim FSelStartLine As Integer = 0
            Dim FSelEndLine As Integer = 0
            Dim FSelStartChar As Integer = 0
            Dim FSelEndChar As Integer = 0
            Dim FOldSelStartLine As Integer = 0
            Dim FOldSelEndLine As Integer = 0
            Dim FOldSelStartChar As Integer = 0
            Dim FOldSelEndChar As Integer = 0
            Dim vlc1 As Integer
            Dim sChar As WString * 2
            'Dim FSelStart As Integer
            'Dim FSelLength As Integer
            'Dim FSelEnd As Integer = 0   ' номер текущего символа
            Dim FCurLineCharIdx As Integer = 0   ' номер текущего символа
            Dim OldnCaretPosX As Integer
            Dim OldCharIndex As Integer
            Dim OldLine As Integer
            Dim As Integer dwLineHeight   ' высота строки 
            Dim As Integer HCaretPos, VCaretPos
			#IfDef __USE_GTK__
				
            #Else
				Dim As HDC hd
				Dim As HDC bufDC
				Dim As HBITMAP bufBMP
				Dim As TEXTMETRIC tm
	        #EndIf
            Dim As RECT rc
            #IfNDef __USE_GTK__
				Dim sz As Size
				Dim As SCROLLINFO si
            #EndIf
            Dim As String Symbols = "!@#$~`'%^&*+-=()/\?<>.,;:[]{}""" & Chr(13) & Chr(10) & Chr(9) 
            Dim As Integer iMin
            Dim As Integer iMax
            Dim As Integer iLineIndex
            Dim iC As Integer
            Dim i As Integer
            Dim j As Integer
            Dim k As Integer
            Dim l As Integer
            Dim s As WString Ptr
            Dim t As Integer
            Dim u As Integer
            Dim z As Integer
            Dim ii As Integer
            Dim jj As Integer
            Dim sc As Integer
            Dim ss As Integer
            Dim p1 As Integer
            Dim MaxWidth As Integer
            Dim lText As Integer
            Dim lLen As Integer
            Dim bQ As Boolean
            Dim vlc As Integer
            Dim As Integer IzohBoshi, QavsBoshi, MatnBoshi
            Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            Dim Matn As String
            Dim LinePrinted As Boolean
            Dim CollapseIndex As Integer
            Dim OldCollapseIndex As Integer
            Declare Function CharType(ByRef ch As WString) As Integer
            Declare Function MaxLineWidth() As Integer
            Declare Sub PaintText(iLine As Integer, ByRef s As WString, iStart As Integer, iEnd As Integer, BKColor As Integer = -1, TextColor As Integer = clBlack, ByRef addit As WString = "")
            Declare Function GetLineIndex(Index As Integer, iTo As Integer = 0) As Integer
            Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
            Declare Sub SplitLines
            Declare Sub WordLeft
            Declare Sub WordRight
        Protected:
        	Declare Function GetOldCharIndex() As Integer
         	Declare Function GetCharIndexFromOld() As Integer
            Declare Sub ChangeCollapsibility(LineIndex As Integer)
            Declare Sub _FillHistory(ByRef item As EditControlHistory Ptr, ByRef Comment As WString)
            Declare Sub _LoadFromHistory(ByRef item As EditControlHistory Ptr, bToBack As Boolean, ByRef oldItem As EditControlHistory Ptr)
            Declare Sub _ClearHistory(Index As Integer = 0)
            Declare Sub ChangeSelPos(bLeft As Boolean)
            Declare Sub ChangePos(CharTo As Integer)
            Declare Function InCollapseRect(i As Integer, X As Integer, Y As Integer) As Boolean
            Declare Sub ProcessMessage(ByRef msg As Message)    
        Public:
			#IfDef __USE_GTK__
				Dim As cairo_t Ptr cr
				Dim As GtkWidget Ptr wText
				Dim As PangoContext Ptr pcontext
				Dim As PangoLayout Ptr layout
				Dim As GdkDisplay Ptr pdisplay
				Dim AS GdkCursor Ptr gdkCursorIBeam
				Dim AS GdkCursor Ptr gdkCursorHand
				#IfDef __USE_GTK3__
					Dim As GtkStyleContext Ptr scontext
				#EndIf
				Dim As GtkWidget Ptr scrollbarv
				Dim As GtkWidget Ptr scrollbarh
				Dim As GtkAdjustment Ptr adjustmentv
				Dim As GtkAdjustment Ptr adjustmenth
				Dim As GdkWindow Ptr win
				Dim As GtkWidget Ptr winIntellisense
				Dim As GtkWidget Ptr scrollwinIntellisense
				Dim As Integer verticalScrollBarWidth
				Dim As Integer horizontalScrollBarHeight
				Dim As Boolean CaretOn
				Dim As Integer BlinkTime
				Dim As Boolean InFocus
				Dim As Boolean bChanged
			#EndIf
            Dim As Integer dwClientX    ' ширина клиентской области
            Dim As Integer dwClientY    ' Высота клиентской области
			Canvas As My.Sys.Drawing.Canvas
            Modified As Boolean
            FLines As List
            CurExecutedLine As Integer = -1
            FocusedItemIndex As Integer
            LastItemIndex As Integer
            Dim As Integer dwCharX
            Dim As Integer dwCharY
            Dim LeftMargin As Integer
            Dim HScrollPos As Integer
            Dim VScrollPos As Integer
            #IfDef __USE_GTK__
            	lvIntellisense As ListView
            #Else
	            cboIntellisense As ComboBoxEx
	            pnlIntellisense As Panel
            #EndIf
            DropDownShowed As Boolean
            DropDownChar As Integer
            Declare Sub SetScrollsInfo()
            Declare Sub ShowCaretPos(Scroll As Boolean = False)
            Declare Function TextWidth(ByRef sText As WString) As Integer
            Declare Sub ShowDropDownAt(iSelEndLine As Integer, iSelEndChar As Integer)
            Declare Sub CloseDropDown()
            Declare Function GetTabbedText(ByRef SourceText As WString, ByRef PosText As Integer = 0, ForPrint As Boolean = False) ByRef As WString
            Declare Sub PaintControl()
            Declare Sub PaintControlPriv()
            Declare Function GetWordAtCursor() As String
            Declare Function GetCaretPosY(LineIndex As Integer) As Integer
            Declare Function CharIndexFromPoint(X As Integer, Y As Integer) As Integer
            Declare Function LineIndexFromPoint(X As Integer, Y As Integer) As Integer
            Declare Function LinesCount As Integer
            Declare Function VisibleLinesCount As Integer
            Declare Function Lines(Index As Integer) ByRef As WString
            Declare Function LineLength(Index As Integer) As Integer
            Declare Property Text ByRef As WString
            Declare Property Text(ByRef Value As WString)
            Declare Property SelText ByRef As WString
            Declare Property SelText(ByRef Value As WString)
            Declare Property TopLine As Integer
            Declare Property TopLine(Value As Integer)
            Declare Sub ChangeCollapseState(LineIndex As Integer, Value As Boolean)
            Declare Sub InsertLine(Index As Integer, ByRef sLine As WString)
            Declare Sub ReplaceLine(Index As Integer, ByRef sLine As WString)
            Declare Sub DeleteLine(Index As Integer)
            Declare Sub ShowLine(Index As Integer)
            Declare Sub GetSelection(ByRef iSelStartLine As Integer, ByRef iSelEndLine As Integer, ByRef iSelStartChar As Integer, ByRef iSelEndChar As Integer)
            Declare Sub SetSelection(iSelStartLine As Integer, iSelEndLine As Integer, iSelStartChar As Integer, iSelEndChar As Integer)
            Declare Sub ChangeText(ByRef Value As WString, CharTo As Integer = 0, ByRef Comment As WString = "", SelStartLine As Integer = -1, SelStartChar As Integer = -1)
            Declare Sub Changing(ByRef Comment As WString = "")
            Declare Sub Changed(ByRef Comment As WString = "")
            Declare Sub Clear
            Declare Sub ClearUndo
            Declare Sub Undo
            Declare Sub Redo
            Declare Sub PasteFromClipboard
            Declare Sub CopyToClipboard
            Declare Sub CutToClipboard
            Declare Sub Breakpoint
            Declare Sub Bookmark
            Declare Sub CollapseAll
            Declare Sub UnCollapseAll
            Declare Sub ClearAllBookmarks
            Declare Sub SelectAll
            Declare Sub ScrollToCaret
            Declare Sub LoadFromFile(ByRef File As WString)
            Declare Sub SaveToFile(ByRef File As WString)
            Declare Sub Indent
            Declare Sub Outdent
            Declare Sub CommentSingle
            Declare Sub CommentBlock
            Declare Sub UnComment
            Declare Constructor
            Declare Destructor
            OnChange As Sub(ByRef Sender As EditControl)
            OnAutoComplete As Sub(ByRef Sender As EditControl)
            OnValidate As Sub(ByRef Sender As EditControl)
            OnLineChange As Sub(ByRef Sender As EditControl, ByVal CurrentLine As Integer, ByVal OldLine As Integer)
    End Type
    
    Dim As EditControl Ptr CurEC
End Namespace

Dim Shared As WStringList keywords0, keywords1, keywords2, keywords3

Type Construction
    Name0 As String * 50
    Name1 As String * 50
    Name2 As String * 50
    EndName As String * 50
    Exception As String * 50
    Collapsible As Boolean
    Accessible As Boolean
End Type

Dim Shared Constructions(17) As Construction
    
Constructions(0) =  Type<Construction>("If",          "ElseIf",   "Else",     "End If",           " Then ", False, False)
Constructions(1) =  Type<Construction>("#If",         "#ElseIf",  "#Else",    "#EndIf",           "",       False, False)
Constructions(2) =  Type<Construction>("Select Case", "Case",     "",         "End Select",       "",       False, False)
Constructions(3) =  Type<Construction>("For",         "",         "",         "Next",             "",       False, False)
Constructions(4) =  Type<Construction>("Do",          "",         "",         "Loop",             "",       False, False)
Constructions(5) =  Type<Construction>("While",       "",         "",         "Wend",             "",       False, False)
Constructions(6) =  Type<Construction>("With",        "",         "",         "End With",         "",       False, False)
Constructions(7) =  Type<Construction>("Scope",       "",         "",         "End Scope",        "",       False, False)
Constructions(8) =  Type<Construction>("'#Region",    "",         "",         "'#End Region",     "",       True,  False)
Constructions(9) =  Type<Construction>("Namespace",   "",         "",         "End Namespace",    "",       True,  False)
Constructions(10) = Type<Construction>("Enum",        "",         "",         "End Enum",         " As ",   True,  True)
Constructions(11) = Type<Construction>("Type",        "",         "",         "End Type",         " As ",   True,  True)
Constructions(12) = Type<Construction>("Sub",         "",         "",         "End Sub",          "",       True,  True)
Constructions(13) = Type<Construction>("Function",    "",         "",         "End Function",     "",       True,  True)
Constructions(14) = Type<Construction>("Property",    "",         "",         "End Property",     "",       True,  True)
Constructions(15) = Type<Construction>("Operator",    "",         "",         "End Operator",     "",       True,  True)
Constructions(16) = Type<Construction>("Constructor", "",         "",         "End Constructor",  "",       True,  True)
Constructions(17) = Type<Construction>("Destructor",  "",         "",         "End Destructor",   "",       True,  True)

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


/'
''
'' Test application
''

'gtk_init(@__FB_ARGC__, @__FB_ARGV__)

gtk_init(NULL, NULL)

'' Main window
var win = gtk_window_new(GTK_WINDOW_TOPLEVEL)
gtk_window_set_title(GTK_WINDOW(win), "test")
gtk_widget_set_size_request(win, 600, 400)
g_signal_connect(win, "destroy", G_CALLBACK(@gtk_main_quit), NULL)

'' Add our custom widget to it
var mycustomwidget = mycustomwidget_new()
gtk_container_add(GTK_CONTAINER(win), mycustomwidget)

gtk_widget_show_all(win)
gtk_main()
'/

#IfDef __USE_GTK__
	Function Blink_cb(user_data As gpointer) As gboolean
		Dim As EditControl Ptr ec = Cast(Any Ptr, user_data)
		If ec->InFocus Then
			ec->CaretOn = Not ec->CaretOn
			#IfDef __USE_GTK3__
				gtk_widget_queue_draw(ec->widget)
			#Else
				gtk_widget_queue_draw(ec->widget)
			#EndIf
			gdk_threads_add_timeout(ec->BlinkTime, @Blink_cb, ec)
		Else
			ec->CaretOn = False
			#IfDef __USE_GTK3__
				gtk_widget_queue_draw(ec->widget)
			#Else
				gtk_widget_queue_draw(ec->widget)
			#EndIf
		End If
		Return False
	End Function
#EndIf
	
Namespace My.Sys.Forms
    Sub EditControl.Breakpoint
        FECLine = FLines.Items[FSelEndLine]
        If CInt(Trim(*FECLine->Text, " ") = "") OrElse CInt(StartsWith(LTrim(*FECLine->Text, " "), "'")) Then
            MsgBox ML("Don't set breakpoint to this line"), "VisualFBEditor", mtWarning
            This.SetFocus
        Else
            FECLine->Breakpoint = Not FECLine->Breakpoint
            PaintControl
        End If
    End Sub
    
    Sub EditControl.Bookmark '...'
        Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Bookmark = Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Bookmark
        PaintControl
    End Sub
    
    Sub EditControl.ClearAllBookmarks
        For i As Integer = 0 To FLines.Count - 1
            FECLine = FLines.Items[i]
            If FECLine->Bookmark Then
               FECLine->Bookmark = False 
            End If
        Next
        PaintControl
    End Sub 
            
    Property EditControl.TopLine As Integer
        Return VScrollPos
    End Property

    Property EditControl.TopLine(Value As Integer)
        VScrollPos = Min(GetCaretPosY(Value), VScrollMax)
        #IfDef __USE_GTK__
			gtk_adjustment_set_value(adjustmentv, VScrollPos)
        #Else
			si.cbSize = sizeof (si)
			si.fMask = SIF_POS
			si.nPos = VScrollPos
			SetScrollInfo(FHandle, SB_VERT, @si, TRUE)
        #EndIf
        PaintControl
    End Property

    Sub EditControl._FillHistory(ByRef item As EditControlHistory Ptr, ByRef Comment As WString)
        WLet item->Comment, Comment
        Dim ecItem As EditControlLine Ptr
        For i As Integer = 0 To FLines.Count - 1
            With *Cast(EditControlLine Ptr, FLines.Items[i])
                FECLine = New EditControlLine
                WLet FECLine->Text, *.Text
                FECLine->Breakpoint = .Breakpoint
                FECLine->Bookmark = .Bookmark
                FECLine->CommentIndex = .CommentIndex
                FECLine->ConstructionIndex = .ConstructionIndex
                FECLine->ConstructionPart = .ConstructionPart
                FECLine->Collapsed = .Collapsed
                FECLine->Collapsible = .Collapsible
                FECLine->Collapsed = .Collapsed
                FECLine->Visible = .Visible
            End With
            item->Lines.Add FECLine
        Next i
    End Sub

    Sub EditControl._ClearHistory(Index As Integer = 0)
        For i As Integer = FHistory.Count - 1 To Index Step -1
            Delete Cast(EditControlHistory Ptr, FHistory.Items[i])
            FHistory.Remove i
        Next i
        If Index = 0 Then FHistory.Clear
    End Sub
    
    Function GetConstruction(ByRef sLine As WString, ByRef iType As Integer = 0) As Integer
        On Error Goto ErrorHandler
        If Trim(sLine, Any !"\t ") = "" Then Return -1
        For i As Integer = 0 To Ubound(Constructions)
            If CInt(CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(Constructions(i).Name0 & " "))) OrElse _
                CInt(CInt(Constructions(i).Accessible) AndAlso _
                CInt(CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", "public " & LCase(Constructions(i).Name0 & " "))) OrElse _
                CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", "private " & LCase(Constructions(i).Name0 & " "))) OrElse _
                CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", "protected " & LCase(Constructions(i).Name0 & " ")))))) AndAlso _ 
                CInt(CInt(Constructions(i).Exception = "") OrElse CInt(Instr(LCase(sLine), LCase(Constructions(i).Exception)) = 0)) AndAlso _
                CInt(Left(LTrim(Mid(LTrim(sLine, Any !"\t "), 9), Any !"\t "), 1) <> "=") Then
                iType = 0
                Return i
            ElseIf CInt(CInt(CInt(Constructions(i).Name1 <> "") AndAlso CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(Constructions(i).Name1 & " ")))) OrElse _
                CInt(CInt(Constructions(i).Name2 <> "") AndAlso CInt(StartsWith(Trim(LCase(sLine), Any !"\t ") & " ", LCase(Constructions(i).Name2 & " "))))) AndAlso _
                CInt(CInt(Constructions(i).Exception = "") OrElse CInt(Instr(LCase(sLine), LCase(Constructions(i).Exception)) = 0)) Then
                iType = 1
                Return i
            ElseIf StartsWith(LTrim(LCase(sLine), Any !"\t ") & " ", LCase(Constructions(i).EndName & " ")) Then
                iType = 2
                Return i
            End If
        Next i
        Return -1
        Exit Function
    ErrorHandler:
        MsgBox ErrDescription(Err) & " (" & Err & ") " & _
            "in line " & Erl() & " " & _
            "in function " & ZGet(Erfn()) & " " & _
            "in module " & ZGet(Ermn())
    End Function

    Function IsArg(j As Integer) As Boolean
        Return j >= Asc("A") And j <= Asc("Z") OrElse _
                     j >= Asc("a") And j <= Asc("z") OrElse _
                     j >= Asc("0") And j <= Asc("9") OrElse _
                     j = Asc("_")
    End Function

    Function FindCommentIndex(ByRef Value As WString, ByRef iC As Integer) As Integer
        Dim As Boolean bQ
        Dim As Integer j = 1, l = Len(Value)
        Do While j <= l
            If iC = 0 AndAlso Mid(Value, j, 1) = """" Then
                bQ = Not bQ
            ElseIf Not bQ Then
                If Mid(Value, j, 2) = "/'" Then
                    iC = iC + 1
                    j = j + 1
                ElseIf iC > 0 AndAlso Mid(Value, j, 2) = "'/" Then
                    iC = iC - 1
                    j = j + 1
                ElseIf iC = 0 AndAlso Mid(Value, j, 1) = "'" Then
                    Exit Do
                End If
            End If
            j = j + 1
        Loop
        Return iC
    End Function

    Sub EditControl.ChangeCollapseState(LineIndex As Integer, Value As Boolean) '...'
        If LineIndex < 0 OrElse LineIndex > FLines.Count - 1 Then Exit Sub
        Dim j As Integer
        Dim FECLine As EditControlLine Ptr = FLines.Items[LineIndex]
        Dim As EditControlLine Ptr FECLine2
        FECLine->Collapsed = Value
        If FECLine->Collapsed Then
            If Not EndsWith(*FECLine->Text, "'...'") Then
                WLet FECLine->Text, *FECLine->Text & " '...'"
            End If
            For i As Integer = LineIndex + 1 To FLines.Count - 1
                FECLine2 = FLines.Items[i]
                FECLine2->Visible = False
                If FECLine2->ConstructionIndex = FECLine->ConstructionIndex Then
                    If FECLine2->ConstructionPart = 2 Then
                        j -= 1
                        If j = -1 Then
                            Exit For
                        End If
                    ElseIf FECLine2->ConstructionPart = 0 Then
                        j += 1
                    End If
                End If
            Next i
        Else
            If EndsWith(*FECLine->Text, "'...'") Then
                WLet FECLine->Text, RTrim(Left(*FECLine->Text, Len(*FECLine->Text) - 5))
            End If
            Dim As EditControlLine Ptr OldCollapsed
            For i As Integer = LineIndex + 1 To FLines.Count - 1
                FECLine2 = FLines.Items[i]
                FECLine2->Visible = True
                If CInt(OldCollapsed = 0) AndAlso CInt(FECLine2->Collapsed) Then
                    OldCollapsed = FECLine2
                    j = 0
                ElseIf OldCollapsed <> 0 Then
                    If FECLine2->ConstructionIndex = OldCollapsed->ConstructionIndex Then
                        If FECLine2->ConstructionPart = 2 Then
                            j -= 1
                            If j = -1 Then
                                OldCollapsed = 0
                            End If
                        ElseIf FECLine2->ConstructionPart = 0 Then
                            j += 1
                        End If
                    End If
                    FECLine2->Visible = False
                End If
            Next i
        End If
    End Sub
    
    Sub EditControl.CollapseAll '...'
        For i As Integer = 0 To FLines.Count - 1
            With *Cast(EditControlLine Ptr, FLines.Items[i])
                If .Collapsible AndAlso Not .Collapsed Then ChangeCollapseState i, True
            End With
        Next
        PaintControl
    End Sub
    
    Sub EditControl.UnCollapseAll '...'
        For i As Integer = 0 To FLines.Count - 1
            With *Cast(EditControlLine Ptr, FLines.Items[i])
                If .Collapsible AndAlso .Collapsed Then ChangeCollapseState i, False
            End With
        Next
        PaintControl
    End Sub
    
    Sub EditControl.ChangeCollapsibility(LineIndex As Integer)
        Dim As Integer i, j, k
        Dim OldCollapsed As Boolean, OldLineIndex AS Integer = LineIndex - 1
        If LineIndex < 0 OrElse LineIndex > FLines.Count - 1 Then Exit Sub
        Dim ecl As EditControlLine Ptr = FLines.Items[LineIndex]
             If ecl = 0 OrElse ecl->Text = 0 Then Exit Sub
        i = GetConstruction(*ecl->Text, j)
        ecl->ConstructionIndex = i
        ecl->ConstructionPart = j
        OldCollapsed = ecl->Collapsed
        If i > -1 And j = 0 Then
            ecl->Collapsible = Constructions(i).Collapsible
            If EndsWith(*ecl->Text, "'...'") Then
                ecl->Collapsed = Constructions(i).Collapsible
            Else
                ecl->Collapsed = False
            End If
        Else
            ecl->Collapsible = False
            ecl->Collapsed = False
        End If
        If OldCollapsed <> ecl->Collapsed Then
            ChangeCollapseState LineIndex, ecl->Collapsed
        End If
        If OldLineIndex > -1 Then
            Dim As EditControlLine Ptr FECLine2, eclOld = FLines.Items[OldLineIndex]
            If Not eclOld->Visible Then
                k = GetLineIndex(OldLineIndex, 0)
                Dim FECLine As EditControlLine Ptr = FLines.Items[k]
                j = 0
                For k = k + 1 To OldLineIndex
                    FECLine2 = FLines.Items[k]
                    If FECLine2->ConstructionIndex = FECLine->ConstructionIndex Then
                        If FECLine2->ConstructionPart = 2 Then
                            j -= 1
                            If j = -1 Then
                                Exit For
                            End If
                        ElseIf FECLine2->ConstructionPart = 0 Then
                            j += 1
                        End If
                    End If  
                Next
                ecl->Visible = j = -1
            ElseIf eclOld->Collapsed Then
                ecl->Visible = False
            End If
        End If
    End Sub

    Sub EditControl.ChangeSelPos(bLeft As Boolean)
        If bLeft Then
            If FSelStartLine < FSelEndLine Then
                FSelEndLine = FSelStartLine
                FSelEndChar = FSelStartChar
            ElseIf FSelStartLine > FSelEndLine Then
                FSelStartLine = FSelEndLine
                FSelStartChar = FSelEndChar
            Else
                FSelStartChar = Min(FSelStartChar, FSelEndChar)
                FSelEndChar = FSelStartChar
            End If
        Else
            If FSelStartLine > FSelEndLine Then
                FSelEndLine = FSelStartLine
                FSelEndChar = FSelStartChar
            ElseIf FSelStartLine < FSelEndLine Then
                FSelStartLine = FSelEndLine
                FSelStartChar = FSelEndChar
            Else
                FSelStartChar = Max(FSelStartChar, FSelEndChar)
                FSelEndChar = FSelStartChar
            End If
        End If
    End Sub
                    
    Sub EditControl.ChangePos(CharTo As Integer = 0)
        Var LengthEndLine = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
        FSelEndChar += CharTo
        If FSelEndChar < 0 Then
            If FSelEndLine > 0 Then
                FSelEndLine = GetLineIndex(FSelEndLine, -1)
                FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
            Else
                FSelEndChar = 0
            End If
        ElseIf FSelEndChar > LengthEndLine Then
            If FSelEndLine < GetLineIndex(FLines.Count - 1) Then
                FSelEndLine = GetLineIndex(FSelEndLine, +1)
                FSelEndChar = 0
            Else
                FSelEndChar = LengthEndLine
            End If
        End If
    End Sub
    
    Sub EditControl.GetSelection(ByRef iSelStartLine As Integer, ByRef iSelEndLine As Integer, ByRef iSelStartChar As Integer, ByRef iSelEndChar As Integer)
        If FSelStartLine < FSelEndLine Then
            iSelStartChar = FSelStartChar
            iSelEndChar = FSelEndChar
            iSelStartLine = FSelStartLine
            iSelEndLine = FSelEndLine
        ElseIf FSelStartLine > FSelEndLine Then
            iSelStartChar = FSelEndChar
            iSelEndChar = FSelStartChar
            iSelStartLine = FSelEndLine
            iSelEndLine = FSelStartLine
        Else
            iSelStartChar = Min(FSelStartChar, FSelEndChar)
            iSelEndChar = Max(FSelStartChar, FSelEndChar)
            iSelStartLine = FSelStartLine
            iSelEndLine = FSelEndLine
        End If
    End Sub
    
    Function EditControl.GetOldCharIndex() As Integer
    	If FSelEndLine >= 0 AndAlso FSelEndLine <= FLines.Count - 1 Then
    		Return Len(GetTabbedText(Left(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text, FSelEndChar)))
    	Else
    		Return FSelEndChar
    	End If
    End Function
    
    Function EditControl.GetCharIndexFromOld() As Integer
    	If FSelEndLine >= 0 AndAlso FSelEndLine <= FLines.Count - 1 Then
    		WLet FLine, *Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text
    		Dim p As Integer
    		For i As Integer = 1 To Len(*FLine)
    			If Mid(*FLine, i, 1) = !"\t" Then
    				p += TabWidth
    			Else
    				p += 1
    			End If
    			If p > OldCharIndex Then Return i - 1
    		Next
    		Return i - 1
    	Else
    		Return OldCharIndex
    	End If
    End Function
    
    Sub EditControl.SetSelection(iSelStartLine As Integer, iSelEndLine As Integer, iSelStartChar As Integer, iSelEndChar As Integer)
        FSelStartChar = Max(0, iSelStartChar)
        FSelEndChar = Max(0, iSelEndChar)
        FSelStartLine = Min(FLines.Count - 1, Max(0, iSelStartLine))
        FSelEndLine = Min(FLines.Count - 1, Max(0, iSelEndLine))
	#IfDef __USE_GTK__
		If cr Then
	#Else
		If Handle Then
	#EndIf
			ScrollToCaret
        End If
        OldnCaretPosX = nCaretPosX
        OldCharIndex = GetOldCharIndex
    End Sub
    
    Sub EditControl.Changing(ByRef Comment As WString = "")
        FOldSelStartLine = FSelStartLine
        FOldSelEndLine = FSelEndLine
        FOldSelStartChar = FSelStartChar
        FOldSelEndChar = FSelEndChar
        Dim As EditControlHistory Ptr item
        If Comment = "" Then
            If bOldCommented Then
                _ClearHistory curHistory + 1
                item = New EditControlHistory
                item->OldSelStartLine = FSelStartLine
                item->OldSelEndLine = FSelEndLine
                item->OldSelStartChar = FSelStartChar
                item->OldSelEndChar = FSelEndChar
                FHistory.Add item
                If HistoryLimit > -1 AndAlso FHistory.Count > HistoryLimit Then
	            	Delete Cast(EditControlHistory Ptr, FHistory.Items[0])
	            	FHistory.Remove 0
	            End If
            	curHistory = FHistory.Count - 1
            End If
        ElseIf CInt(Not bOldCommented) AndAlso CInt(FHistory.Count > 0) Then
            item = FHistory.Items[FHistory.Count - 1]
            _FillHistory item, "Matn kiritildi"
            item->SelStartLine = FSelStartLine
            item->SelEndLine = FSelEndLine
            item->SelStartChar = FSelStartChar
            item->SelEndChar = FSelEndChar
        End If
        bOldCommented = Comment <> ""
    End Sub
    
    Sub EditControl.Changed(ByRef Comment As WString = "")
        OldnCaretPosX = nCaretPosX
        OldCharIndex = GetOldCharIndex
        If Comment <> "" Then
            Var item = New EditControlHistory
            _FillHistory item, Comment
            item->OldSelStartLine = FOldSelStartLine
            item->OldSelEndLine = FOldSelEndLine
            item->OldSelStartChar = FOldSelStartChar
            item->OldSelEndChar = FOldSelEndChar
            item->SelStartLine = FSelStartLine
            item->SelEndLine = FSelEndLine
            item->SelStartChar = FSelStartChar
            item->SelEndChar = FSelEndChar
            _ClearHistory curHistory + 1
            FHistory.Add item
            If HistoryLimit > -1 AndAlso FHistory.Count > HistoryLimit Then
            	Delete Cast(EditControlHistory Ptr, FHistory.Items[0])
            	FHistory.Remove 0
            End If
            curHistory = FHistory.Count - 1
        End If
        If OnChange Then OnChange(This)
        Modified = True
	#IfDef __USE_GTK__
		If widget AndAlso cr Then
	#Else
		If Handle Then
	#EndIf
			ScrollToCaret
		End If
    End Sub
    
    Sub EditControl.ChangeText(ByRef Value As WString, CharTo As Integer = 0, ByRef Comment As WString = "", SelStartLine As Integer = -1, SelStartChar As Integer = -1)
        Changing Comment
        ChangePos CharTo
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Var ecStartLine = Cast(EditControlLine Ptr, FLines.Item(iSelStartLine)), ecEndLine = Cast(EditControlLine Ptr, FLines.Item(iSelEndLine))
        FECLine = ecStartLine
        'If iSelStartLine <> iSelEndLine Or iSelStartChar <> iSelEndChar Then AddHistory
        WLet FLine, Mid(*ecEndLine->Text, iSelEndChar + 1)
        WLet FECLine->Text, Left(*ecStartLine->Text, iSelStartChar)
        For i As Integer = iSelEndLine To iSelStartLine + 1 Step -1
            Delete Cast(EditControlLine Ptr, FLines.Items[i])
            FLines.Remove i
        Next i
        Var iC = 0, OldiC = ecEndLine->CommentIndex, Pos1 = 0, p = 1, c = 0, l = 0
        If iSelStartLine > 0 Then iC = Cast(EditControlLine Ptr, FLines.Item(iSelStartLine - 1))->CommentIndex
        Do
            Pos1 = Instr(p, Value, Chr(13))
            c = c + 1
            If Pos1 = 0 Then
                l = Len(Value) - p + 1
            Else
               l = Pos1 - p
            End If
            If c = 1 Then
                WLet FECLine->Text, *FECLine->Text & Mid(Value, p, l)
                ChangeCollapsibility iSelStartLine
            Else
                FECLine = New EditControlLine
                WLet FECLine->Text, Mid(Value, p, l)
                'ecItem->CharIndex = p - 1
                'ecItem->LineIndex = c - 1
            End If
            'item->Length = Len(*item->Text)
            FECLine->CommentIndex = FindCommentIndex(*FECLine->Text, iC)
            If c > 1 Then
                FLines.Insert iSelStartLine + c - 1, FECLine
                ChangeCollapsibility iSelStartLine + c - 1
            End If
            p = Pos1 + 1
        Loop While Pos1 > 0
        FSelStartLine = iSelStartLine + c - 1
        FSelStartChar = Len(*FECLine->Text)
        WLet Cast(EditControlLine Ptr, FLines.Item(FSelStartLine))->Text, *FECLine->Text & *FLine
        ChangeCollapsibility FSelStartLine
        'item->Length = Len(*item->Text)
        'p = item->CharIndex + item->Length + 1
        If OldiC <> iC Then
            For i As Integer = iSelStartLine + c + 1 To FLines.Count - 1
                FECLine = Cast(EditControlLine Ptr, FLines.Item(i))
                'Item->CharIndex = p - 1
                'Item->LineIndex = i
                FECLine->CommentIndex = FindCommentIndex(*FECLine->Text, iC)
                'p = p + ecItem->Length
            Next i
        End If
        If SelStartLine <> -1 Then FSelStartLine = SelStartLine
        If SelStartChar <> -1 Then FSelStartChar = SelStartChar
        FSelEndLine = FSelStartLine
        FSelEndChar = FSelStartChar
        Changed Comment
    End Sub
    
    Sub EditControl.SelectAll
        FSelStartLine = 0
        FSelStartChar = 0
        FSelEndLine = FLines.Count - 1
        FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
        ShowCaretPos True
    End Sub

    Sub EditControl.CutToClipboard
        CopyToClipboard
        ChangeText "", 0, "Belgilangan matn qirqib olindi"
    End Sub

    Sub EditControl.CopyToClipboard
        Clipboard.SetAsText SelText
    End Sub

    Sub EditControl.PasteFromClipboard
        Dim Value As WString Ptr
        WLet Value, ClipBoard.GetAsText
        If Value Then
        	WLet Value, Replace(*Value, Chr(13) & Chr(10), Chr(13))
        	WLet Value, Replace(*Value, Chr(10), Chr(13))
        	ChangeText *Value, 0, "Xotiradan qo`yildi"
        	WDeallocate Value
        End If
    End Sub

    Sub EditControl.ClearUndo
        On Error Goto A
        For i As Integer = curHistory To 0 Step -1
            Delete Cast(EditControlHistory Ptr, FHistory.Items[i])
            'FHistory.Remove i
        Next i
        FHistory.Clear
        curHistory = 0
        'Changed "Matn almashtirildi"
        If FLines.Count = 0 Then
            FECLine = New EditControlLine
            WLet FECLine->Text, ""
            FLines.Add(FECLine)
        End If
        ChangeText "", 0, "Matn almashtirildi"
        Exit Sub
A:
        MsgBox ErrDescription(Err) & " (" & Err & ") " & _
            "in function " & ZGet(Erfn()) & " " & _
            "in module " & ZGet(Ermn())' & " " & _
            '"in line " & Erl()
    End Sub
    
    Property EditControl.Text ByRef As WString '...'
        Return WStr("")
    End Property

    Property EditControl.Text(ByRef Value As WString) '...'
        'ChangeText Value, "Matn almashtirildi"
    End Property

    Property EditControl.SelText ByRef As WString
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        WLet FLine, ""
        For i As Integer = iSelStartLine To iSelEndLine
            If i = iSelStartLine And i = iSelEndLine Then
                WLet FLine, Mid(Lines(i), iSelStartChar + 1, iSelEndChar - iSelStartChar)
            ElseIf i = iSelStartLine Then
                WLet FLine, Mid(Lines(i), iSelStartChar + 1)
            ElseIf i = iSelEndLine Then
                WLet FLine, *FLine & Chr(13) & Chr(10) & Left(Lines(i), iSelEndChar)
            Else
                WLet FLine, *FLine & Chr(13) & Chr(10) & Lines(i)
            End If
        Next i
        Return *FLine
    End Property

    Property EditControl.SelText(ByRef Value As WString) '...'
        ChangeText Value, 0, "Matn qo`shildi"
    End Property

    Sub EditControl.LoadFromFile(ByRef File As WString)
        Dim Result As Integer, Buff As WString Ptr
        Result = Open(File For Input Encoding "utf-32" As #1)
        If Result <> 0 Then Result = Open(File For Input Encoding "utf-16" As #1)
        If Result <> 0 Then Result = Open(File For Input Encoding "utf-8" As #1)
        If Result <> 0 Then Result = Open(File For Input As #1)
        If Result = 0 Then
            FLines.Clear
            WReallocate Buff, LOF(1) 
            Var iC = 0, OldiC = 0, i = 0
            Do Until EOF(1)
                Line Input #1, *Buff
                FECLine = New EditControlLine
                WLet FECLine->Text, *Buff
                iC = FindCommentIndex(*Buff, OldiC)
                FECLine->CommentIndex = iC
                FLines.Add(FECLine)
                ChangeCollapsibility i
                OldiC = iC
                i += 1
            Loop
            Close #1
            ScrollToCaret
            ClearUndo
            WDeallocate Buff
        End If
    End Sub

    Sub EditControl.SaveToFile(ByRef File As WString)
        If Open(File For Output Encoding "utf-8" As #1) = 0 Then
            For i As Integer = 0 To FLines.Count - 1
                Print #1, *Cast(EditControlLine Ptr, FLines.Item(i))->Text
            Next i
            Close #1
        End If
    End Sub
    
    Sub EditControl.Clear '...'
        ChangeText "", 0, "Matn tozalandi"
    End Sub

    Function EditControl.LinesCount As Integer '...'
        Return FLines.Count
    End Function

    Sub EditControl.InsertLine(Index As Integer, ByRef sLine As WString) '...'
        Var iC = 0, OldiC = 0
        If Index > 0 AndAlso Index < FLines.Count - 1 Then
            OldiC = Cast(EditControlLine Ptr, FLines.Items[Index])->CommentIndex
        End If 
        FECLine = New EditControlLine
        WLet FECLine->Text, sLine
        iC = FindCommentIndex(sLine, OldiC)
        FECLine->CommentIndex = iC
        FLines.Insert Index, FECLine
        ChangeCollapsibility Index
        If Index <= FSelEndLine Then FSelEndLine += 1
        If Index <= FSelStartLine Then FSelStartLine += 1
    End Sub

    Sub EditControl.ReplaceLine(Index As Integer, ByRef sLine As WString)
        Var iC = 0, OldiC = 0
        If Index > 0 AndAlso Index < FLines.Count - 1 Then
            OldiC = Cast(EditControlLine Ptr, FLines.Items[Index])->CommentIndex
        End If 
        FECLine = FLines.Items[Index]
        WLet FECLine->Text, sLine
        iC = FindCommentIndex(sLine, OldiC)
        FECLine->CommentIndex = iC
        ChangeCollapsibility Index
    End Sub

    Sub EditControl.DeleteLine(Index As Integer) '...'
        Delete Cast(EditControlLine Ptr, FLines.Items[Index])
        FLines.Remove Index
    End Sub

    Function EditControl.VisibleLinesCount() As Integer
        Return (dwClientY) / dwCharY
    End Function    

    Function EditControl.CharIndexFromPoint(X As Integer, Y As Integer) As Integer
        WLet FLine, *Cast(EditControlLine Ptr, FLines.Item(LineIndexFromPoint(X, Y)))->Text
        Dim As Integer nCaretPosX = X - LeftMargin + HScrollPos * dwCharX
        Dim As Integer w = TextWidth(GetTabbedText(*FLine))
        Dim As Integer Idx = Len(*FLine)
        If w - 2 > nCaretPosX Then
            Idx = 0
            For i As Integer = 0 To Len(*FLine)
                w = TextWidth(GetTabbedText(Mid(*FLine, 1, i)))
                If w - 2 > nCaretPosX Then Exit For
                Idx = i
            Next i
        End If
        Return Idx
    End Function

    Function EditControl.LineIndexFromPoint(X As Integer, Y As Integer) As Integer
        Return GetLineIndex(0, Max(0, Min(Y \ dwCharY + VScrollPos, LinesCount - 1)))
    End Function

    Function EditControl.Lines(Index As Integer) ByRef As WString '...'
        If Index >= 0 And Index < FLines.Count Then Return *Cast(EditControlLine Ptr, FLines.Item(Index))->Text
    End Function

    Function EditControl.LineLength(Index As Integer) As Integer '...'
        If Index >= 0 And Index < FLines.Count Then Return Len(*Cast(EditControlLine Ptr, FLines.Item(Index))->Text) Else Return 0
    End Function

    Function EditControl.GetCaretPosY(LineIndex As Integer) As Integer
        Static As Integer i, j
        j = 0
        For i = 1 To Min(FLines.Count - 1, LineIndex)
            If Cast(EditControlLine Ptr, FLines.Items[i])->Visible Then j = j + 1
        Next
        Return j
    End Function
    
    Sub EditControl.ShowLine(LineIndex As Integer)
        Do
            ChangeCollapseState GetLineIndex(LineIndex, 0), False
        Loop While Not Cast(EditControlLine Ptr, FLines.Items[LineIndex])->Visible
    End Sub
    
    Function IsArg2(ByRef sLine As WString) As Boolean
        For i As Integer = 1 To Len(sLine)
            If Not IsArg(Asc(Mid(sLine, i, 1))) Then Return False
        Next
        Return True
    End Function
    
    Function GetNextCharIndex(ByRef sLine As WString, iEndChar As Integer) As Integer
        Dim i As Integer
        Dim s As String
        For i = iEndChar + 1 To Len(sLine)
            s = Mid(sLine, i, 1)
            If Not CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(i = iEndChar + 1) AndAlso CInt(s = "#" OrElse s = "$"))) Then Return i - 1
        Next
        Return i - 1
    End Function
    
    Function EditControl.GetWordAtCursor() As String
        Dim As Integer i, j
        Dim As String s, sWord, sLine = Lines(FSelEndLine)
        j = FSelEndChar
        For i = j To 1 Step -1
            s = Mid(sLine, i, 1)
            If CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(s = "#" OrElse s = "$"))) Then sWord = s & sWord Else Exit For
        Next
        For i = j + 1 To Len(sLine)
            s = Mid(sLine, i, 1)
            If CInt(CInt(IsArg(Asc(s))) OrElse CInt(CInt(s = "#" OrElse s = "$"))) Then sWord = sWord & s Else Exit For
        Next
        Return sWord
    End Function
    
    Function EditControl.GetTabbedText(ByRef SourceText As WString, ByRef PosText As Integer = 0, ForPrint As Boolean = False) ByRef As WString
        lText = Len(SourceText)
        WReallocate FLineTemp, lText * TabWidth + 1
        *FLineTemp = ""
        iPos = PosText
        ii = 1
        Do While ii <= lText
            sChar = Mid(SourceText, ii, 1)
            If sChar = !"\t" Then
                iPP = TabWidth - (iPos + TabWidth) Mod TabWidth
                If ForPrint Then
                	*FLineTemp &= String(iPP - 1, 1) & Chr(2)
                Else
                	*FLineTemp &= Space(iPP)
                End If
                iPos += iPP
            Else
                *FLineTemp &= sChar
                iPos += 1
            End If
            ii += 1
        Loop
        PosText = iPos
        Return *FLineTemp
    End Function
    
    Sub EditControl.ShowCaretPos(Scroll As Boolean = False)
        nCaretPosY = GetCaretPosY(FSelEndLine)
        FCurLineCharIdx = FSelEndChar
        nCaretPosX = TextWidth(GetTabbedText(Left(Lines(FSelEndLine), FCurLineCharIdx)))
        If CInt(DropDownShowed) AndAlso CInt(CInt(FSelEndChar < DropDownChar) OrElse CInt(FSelEndChar > GetNextCharIndex(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, DropDownChar))) Then
            ?FSelEndChar, DropDownChar, GetNextCharIndex(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, DropDownChar)
            #IfDef __USE_GTK__
            	CloseDropDown()
            #Else
            	cboIntellisense.ShowDropDown False
        	#EndIf
        End If
        If OldLine <> FSelEndLine Then
            If Not bOldCommented Then Changing "Matn kiritildi"
            If OnLineChange Then OnLineChange(This, FSelEndLine, OldLine)
        End If
        
        If CInt(FSelStartLine > -1) AndAlso CInt(FSelStartLine < FLines.Count) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelStartLine])->Visible) Then
            ShowLine FSelStartLine
        End If    
        If CInt(FSelEndLine > -1) AndAlso CInt(FSelEndLine < FLines.Count) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Visible) Then
            ShowLine FSelEndLine
        End If
            
        SetScrollsInfo
        If Scroll Then
            Var OldHScrollPos = HScrollPos, OldVScrollPos = VScrollPos
            If nCaretPosX < HScrollPos * dwCharX Then
                HScrollPos = nCaretPosX / dwCharX
            ElseIf LeftMargin + nCaretPosX > HScrollPos * dwCharX + (dwClientX - dwCharX) Then
                HScrollPos = (LeftMargin + nCaretPosX - (dwClientX - dwCharX)) / dwCharX
            ElseIf HScrollPos > HScrollMax Then
                HScrollPos = HScrollMax
            End If
            If nCaretPosY < VScrollPos Then
                VScrollPos = nCaretPosY
            ElseIf nCaretPosY > VScrollPos + (VisibleLinesCount - 2) Then
                VScrollPos = nCaretPosY - (VisibleLinesCount - 2)
            ElseIf VScrollPos > VScrollMax Then
                VScrollPos = VScrollMax
            End If
    
            If OldHScrollPos <> HScrollPos Then
				#IfDef __USE_GTK__
					gtk_adjustment_set_value(adjustmenth, HScrollPos)
				#Else
					si.cbSize = sizeof (si)
						si.fMask = SIF_POS
					  si.nPos = HScrollPos
					SetScrollInfo(FHandle, SB_HORZ, @si, TRUE)
				#EndIf
            End If
            If OldVScrollPos <> VScrollPos Then
                #IfDef __USE_GTK__
					gtk_adjustment_set_value(adjustmentv, VScrollPos)
                #Else
					si.cbSize = sizeof (si)
						si.fMask = SIF_POS
					  si.nPos = VScrollPos
					SetScrollInfo(FHandle, SB_VERT, @si, TRUE)
				#EndIf
            End If
            'If OldHScrollPos <> HScrollPos Or OldVScrollPos <> VScrollPos Then PaintControl
            #IfNDef __USE_GTK__
				PaintControl
			#EndIf
        End If

        HCaretPos = LeftMargin + nCaretPosX - HScrollPos * dwCharX
        VCaretPos = (nCaretPosY - VScrollPos) * dwCharY
        If HCaretPos < LeftMargin Or FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then HCaretPos = -1
        #IfDef __USE_GTK__
			If Scroll Then
				CaretOn = True
				PaintControl
			End If
			'gtk_render_insertion_cursor(gtk_widget_get_style_context(widget), cr, 10, 10, layout, 0, PANGO_DIRECTION_LTR)
		#Else
			SetCaretPos(HCaretPos, VCaretPos)
        #EndIf
        OldLine = FSelEndLine
        
    End Sub

    Sub EditControl.Indent
        Dim n As Integer
        If FSelStartLine = FSelEndLine Then
            n = Min(FSelStartChar, FSelEndChar)
            If TabAsSpaces Then
                SelText = Space(TabWidth - (n Mod TabWidth))
            Else
                SelText = !"\t"
            End If
        Else
            UpdateLock
            Changing("Oldga surish")
            Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
            For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
                FECLine = FLines.Items[i]
                If TabAsSpaces Then
                    n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
                    n = TabWidth - (n Mod TabWidth)
                    WLet FECLine->Text, Space(n) & *FECLine->Text
                Else
                    n = 1
                    WLet FECLine->Text, !"\t" & *FECLine->Text
                End If
                If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += n
                If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += n 
            Next i
            Changed("Oldga surish")
            UpdateUnLock
        End If
        ShowCaretPos True
    End Sub

    Sub EditControl.Outdent
        UpdateLock
        Dim n As Integer
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Changing("Ortga surish")
        For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
            FECLine = FLines.Items[i]
            n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text))
            n = Min(n, TabWidth - (n Mod TabWidth))
            If n = 0 AndAlso Left(*FECLine->Text, 1) = !"\t" Then n = 1
            WLet FECLine->Text, Mid(*FECLine->Text, n + 1)
            If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar -= n
            If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar -= n
        Next i
        Changed("Ortga surish")
        UpdateUnLock
        ShowCaretPos True
    End Sub

    Sub EditControl.CommentSingle
        UpdateLock
        Dim n As Integer
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Changing("Izoh qilish")
        For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
            FECLine = FLines.Items[i]
            WLet FECLine->Text, "'" & *FECLine->Text
            If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += 1
            If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += 1
        Next i
        Changed("Izoh qilish")
        UpdateUnLock
        ShowCaretPos True
    End Sub
    
    Sub EditControl.CommentBlock
        UpdateLock
        Dim n As Integer
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Changing("Blokli izoh qilish")
        iSelEndLine = iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
        For i As Integer = iSelStartLine To iSelEndLine
            FECLine = FLines.Items[i]
            If i = iSelStartLine Or i = iSelEndLine Then
                If i = iSelStartLine Then
                    WLet FECLine->Text, "/'" & *FECLine->Text
                    FECLine->CommentIndex += 1
                    If i = FSelEndLine And FSelEndChar <> 0 Then FSelEndChar += 2
                    If i = FSelStartLine And FSelStartChar <> 0 Then FSelStartChar += 2
                ElseIf i = iSelEndLine Then
                    WLet FECLine->Text, *FECLine->Text & "'/"
                End If
            Else
                FECLine->CommentIndex += 1
            End If
        Next i
        Changed("Blokli izoh qilish")
        UpdateUnLock
        ShowCaretPos True
    End Sub
    
    Sub EditControl.UnComment
        UpdateLock
        Dim n As Integer
        Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        Changing("Izohni olish")
        For i As Integer = iSelStartLine To iSelEndLine - IIF(iSelEndChar = 0, 1, 0)
            FECLine = FLines.Items[i]
            If Left(Trim(*FECLine->Text, Any !"\t "), 1) = "'" Then
                n = Len(*FECLine->Text) - Len(LTrim(*FECLine->Text, Any !"\t "))
                WLet FLineTemp, Left(*FECLine->Text, n)
                WLet FECLine->Text, *FLineTemp & Mid(*FECLine->Text, n + 2)
                If i = FSelEndLine And FSelEndChar > n Then FSelEndChar -= 1
                If i = FSelStartLine And FSelStartChar > n Then FSelStartChar -= 1
            End If
        Next i
        Changed("Izohni olish")
        UpdateUnLock
        ShowCaretPos True
    End Sub
    
    Sub EditControl.ScrollToCaret
        ShowCaretPos True
    End Sub

    Function EditControl.MaxLineWidth() As Integer '...'
        Dim As Integer Pos1 = Instr(*FText, Chr(13)), l = Len(Chr(13)), c = 0, p = 1, MaxLW = 0, lw = 0
        While Pos1 > 0
            c = c + 1
            lw = TextWidth(Mid(*FText, p, Pos1 - p))
            If lw > MaxLW Then MaxLW = lw
            p = Pos1 + l
            Pos1 = Instr(p, *FText, Chr(13))
        Wend
        lw = TextWidth(Mid(*FText, p, Len(*FText) - p + 1))
        If lw > MaxLW Then MaxLW = lw
        Return MaxLW
    End Function

    Sub EditControl.SetScrollsInfo()
        
        HScrollMax = 10000 'Max(0, (MaxLineWidth - (dwClientX - LeftMargin - dwCharX))) \ dwCharX
        #IfDef __USE_GTK__
			gtk_adjustment_set_upper(adjustmenth, HScrollMax)
			'gtk_adjustment_configure(adjustmenth, gtk_adjustment_get_value(adjustmenth), 0, HScrollMax, 1, 10, HScrollMax)
        #Else
			si.cbSize = sizeof(si)
			si.fMask  = SIF_RANGE Or SIF_PAGE 
			  si.nMin   = 0
			  si.nMax   = HScrollMax
			  si.nPage  = 10
			  SetScrollInfo(FHandle, SB_HORZ, @si, TRUE)
		#EndIf

        VScrollMax = Max(0, LinesCount - VisibleLinesCount + 1)
		LeftMargin = Len(Str(LinesCount)) * 10 + 30
		
		#IfDef __USE_GTK__
			gtk_adjustment_set_upper(adjustmentv, VScrollMax)
			gtk_adjustment_set_page_size(adjustmentv, 0)
			'gtk_adjustment_configure(adjustmentv, gtk_adjustment_get_value(adjustmentv), 0, VScrollMax, 1, 10, VScrollMax / 10)
		#Else
			si.cbSize = sizeof(si)
			  si.fMask  = SIF_RANGE Or SIF_PAGE
			  si.nMin   = 0
			  si.nMax   = VScrollMax
			  si.nPage  = 1
			SetScrollInfo(FHandle, SB_VERT, @si, TRUE)
        #EndIf
    End Sub

	'Sub PaintGliphs(x As Integer, y As Integer, ByRef utf8 As WString)
	'	Dim As cairo_status_t status
'	'	Dim As cairo_glyph_t Ptr glyphs = NULL
	'	Dim As Integer num_glyphs
	'	Dim As cairo_text_cluster_t Ptr clusters = NULL
	'	Dim As Integer num_clusters
	'	Dim As cairo_text_cluster_flags_t cluster_flags

	'	status = cairo_scaled_font_text_to_glyphs (scaled_font, _
     '                                      x, y, _
      '                                     utf8, utf8_len, _
       '                                    @glyphs, @num_glyphs, _
        ''                                   @clusters, @num_clusters, @cluster_flags)

		'if (status == CAIRO_STATUS_SUCCESS) Then
		'	cairo_show_text_glyphs (cr, _
		'							utf8, utf8_len, _
		'							glyphs, num_glyphs, _
		'							clusters, num_clusters, cluster_flags)
'
'			cairo_glyph_free (glyphs)
'			cairo_text_cluster_free (clusters)
'		End If
'	End Sub
	
	Function EditControl.TextWidth(ByRef sText As WString) As Integer
		#IfDef __USE_GTK__
			pango_layout_set_text(layout, ToUTF8(sText), Len(ToUTF8(sText)))
			If cr Then
				pango_cairo_update_layout(cr, layout)
			End If
			#ifdef PANGO_VERSION
				Dim As PangoLayoutLine Ptr pll = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pll = pango_layout_get_line(layout, 0)
			#endif
			Dim As PangoRectangle extend
			pango_layout_line_get_pixel_extents(pll, NULL, @extend)
			Return extend.width
		#Else
			Return Canvas.TextWidth(sText)
		#EndIf
	End Function
	
	Sub GetColor(iColor As Integer, ByRef iRed As Double, ByRef iGreen As Double, ByRef iBlue As Double)
		Select Case iColor
		Case clBlack:	iRed = 0: iGreen = 0: iBlue = 0
		Case clRed:		iRed = 0.8: iGreen = 0: iBlue = 0
		Case clGreen:	iRed = 0: iGreen = 0.8: iBlue = 0
		Case clBlue:	iRed = 0: iGreen = 0: iBlue = 1
		Case clWhite:	iRed = 1: iGreen = 1: iBlue = 1
		Case clOrange:	iRed = 1: iGreen = 83 / 255.0: iBlue = 0
		Case Else: iRed = Abs(GetRed(iColor) / 255.0): iGreen = Abs(GetGreen(iColor) / 255.0): iBlue = Abs(GetBlue(iColor) / 255.0)
		End Select
	End Sub
	
	#IfDef __USE_GTK__
		Sub cairo_rectangle(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As boolean)
			.cairo_rectangle(cr, x, y, x1 - x, y1 - y)
		End Sub
	#EndIf
	
	#IfDef __USE_GTK__
		Sub cairo_rectangle_(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As boolean)
			'.cairo_rectangle(cr, x, y, x1 - x, y1 - y)
			cairo_move_to (cr, x, y)
			cairo_line_to (cr, x1, y)
			cairo_line_to (cr, x1, y1)
			cairo_line_to (cr, x, y1)
			cairo_line_to (cr, x, y)
		End Sub
	#EndIf
	
	Sub EditControl.PaintText(iLine As Integer, ByRef s As WString, iStart As Integer, iEnd As Integer, BKColor As Integer = -1, TextColor As Integer = 0, ByRef addit As WString = "")
		iPPos = 0
		WLet FLineLeft, GetTabbedText(Left(s, iStart), iPPos)
		WLet FLineRight, GetTabbedText(Mid(s, iStart + 1, iEnd - iStart) & addit, iPPos)
		#IfDef __USE_GTK__
			Dim As PangoRectangle extend, extend2
			Dim As Double iRed, iGreen, iBlue
			extend.width = TextWidth(*FLineLeft)
			pango_layout_set_text(layout, ToUTF8(*FLineRight), Len(ToUTF8(*FLineRight)))
			pango_cairo_update_layout(cr, layout)
			#ifdef PANGO_VERSION
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			If BKColor <> -1 Then
				pango_layout_line_get_pixel_extents(pl, NULL, @extend2)
				GetColor BKColor, iRed, iGreen, iBlue
				cairo_set_source_rgb(cr, iRed, iGreen, iBlue)
				.cairo_rectangle (cr, LeftMargin + -HScrollPos * dwCharX + extend.width, (iLine - VScrollPos) * dwCharY, extend2.width, dwCharY)
				cairo_fill (cr)
			End If
			'?Abs(GetRed(TextColor)), Abs(GetGreen(TextColor)), Abs(GetBlue(TextColor))
			cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + extend.width - 0.5, (iLine - VScrollPos) * dwCharY + dwCharY - 5 - 0.5)
			'?Abs(GetRed(TextColor) / 255.0), Abs(GetGreen(TextColor) / 255.0), Abs(GetBlue(TextColor) / 255.0)
			GetColor TextColor, iRed, iGreen, iBlue
			cairo_set_source_rgb(cr, iRed, iGreen, iBlue)
			pango_cairo_show_layout_line(cr, pl)
			'Dim extend As cairo_text_extents_t 
			'cairo_text_extents (cr, *FLineLeft, @extend)
			'?1218:	cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + extend.width, (iLine - VScrollPos) * dwCharY + dwCharY)
			'?LeftMargin + -HScrollPos * dwCharX, (iLine - VScrollPos) * dwCharY
			'?TextColor, GetRed(TextColor), GetGreen(TextColor), GetBlue(TextColor)
			'?1219:	cairo_set_source_rgb(cr, GetRed(TextColor) / 255.0, GetGreen(TextColor) / 255.0, GetBlue(TextColor) / 255.0)
			'?1220:	cairo_show_text(cr, *FLineRight)
			
		#Else
			If BKColor = -1 Then
				SetBKMode(bufDC, TRANSPARENT)
			Else
				SetBKColor(bufDC, BKColor)
			End If
			SetTextColor(bufDC, TextColor)
			GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @Sz)
			TextOut(bufDC, LeftMargin + -HScrollPos * dwCharX + IIF(iStart = 0, 0, Sz.cx), (iLine - VScrollPos) * dwCharY, FLineRight, Len(*FLineRight))
			If BKColor = -1 Then SetBKMode(bufDC, OPAQUE)
		#EndIf
	End Sub

	Sub EditControl.PaintControl
		#IfDef __USE_GTK__
			'PaintControlPriv
			bChanged = True
			#IfDef __USE_GTK3__
				gtk_widget_queue_draw(widget)
			#Else
				gtk_widget_queue_draw(widget)
			#EndIf
		#Else
			PaintControlPriv
		#EndIf
	End Sub
	
    Sub EditControl.PaintControlPriv
	'	On Error Goto ErrHandler
		#IfDef __USE_GTK__
			If cr = 0 Then Exit Sub
		#Else
			hd = GetDC(FHandle)
			bufDC = CreateCompatibleDC(hD)
			bufBMP = CreateCompatibleBitmap(hD, dwClientX, dwClientY)
        #EndIf
        'iMin = Min(FSelEnd, FSelStart)
        'iMax = Max(FSelEnd, FSelStart)
        'iLineIndex = LineFromCharIndex(iMax)
        GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
        iC = 0
        vlc = Min(LinesCount, VScrollPos + VisibleLinesCount + 2)
        vlc1 = VisibleLinesCount
        IzohBoshi = 0
        QavsBoshi = 0
        MatnBoshi = 0
        Matn = ""
        #IfNDef __USE_GTK__
			SelectObject(bufDC, bufBMP)
			HideCaret(FHandle)
		#EndIf
        This.Canvas.Brush.Color = This.BackColor
        #IfDef __USE_GTK__
			#IfDef __USE_GTK3__
				cairo_rectangle (cr, 0.0, 0.0, gtk_widget_get_allocated_width (widget), gtk_widget_get_allocated_height (widget), true)
			#Else
				cairo_rectangle (cr, 0.0, 0.0, widget->allocation.width, widget->allocation.height, true)
			#EndIf
			cairo_set_source_rgb(cr, 1, 1, 1)
			cairo_fill (cr)
        #Else
			This.Canvas.Pen.Color = clBtnShadow
			SetRect(@rc, LeftMargin, 0, dwClientX, dwClientY)
			SelectObject(bufDC, This.Canvas.Brush.Handle)
			SelectObject(bufDC, This.Canvas.Font.Handle)
			SelectObject(bufDC, This.Canvas.Pen.Handle)
			SetROP2 bufDC, This.Canvas.Pen.Mode
			FillRect bufDC, @rc, This.Canvas.Brush.Handle
        #EndIf
        i = -1
        If VScrollPos > 0 Then iC = Cast(EditControlLine Ptr, FLines.Items[VScrollPos - 1])->CommentIndex
        CollapseIndex = 0
        OldCollapseIndex = 0
        For z As Integer = 0 To FLines.Count - 1
            FECLine = FLines.Items[z]
            If FECLine->ConstructionIndex > 7 Then
                If FECLine->ConstructionPart = 0 Then
                    CollapseIndex += 1
                ElseIf FECLine->ConstructionPart = 2 Then
                    CollapseIndex = Max(0, CollapseIndex - 1)
                End If
            End If
            If Not FECLine->Visible Then OldCollapseIndex = CollapseIndex: Continue For
            i = i + 1
            If i < VScrollPos Then OldCollapseIndex = CollapseIndex: Continue For
            'If FECLine->Visible = False Then Continue For
            'SelectObject(bufDC, This.Canvas.Brush.Handle)
            'Pos1 = Instr(p, *FText, Chr(13))
            'c = c + 1
            'If c <= VScrollPos Then Continue Do
            'i = c - 1
            'ss = FECLine->CharIndex 'p - 1
            'If Pos1 = 0 Then
            '    *FLine = Mid(*FText, p, Len(*FText) - p + 1)
            'Else
            '        *FLine = Mid(*FText, p, Pos1 - p)
            'End If
            s = FECLine->Text 'FLine
            l = Len(*s) 'FECLine->Length 'Len(*s)
            bQ = False
            j = 1
            IzohBoshi = 0
            If i < VScrollPos Then
				Do While j <= l
                    If iC = 0 AndAlso Mid(*s, j, 1) = """" Then
                        bQ = Not bQ
                    ElseIf Not bQ Then
                        If Mid(*s, j, 2) = "/'" Then
                            iC = iC + 1
                            If iC = 1 Then
                                IzohBoshi = j
                            End If
                            j = j + 1
                        ElseIf iC > 0 AndAlso Mid(*s, j, 2) = "'/" Then
                            iC = iC - 1
                            j = j + 1
                        ElseIf iC = 0 AndAlso Mid(*s, j, 1) = "'" Then
                            Exit Do
                        End If
                    End If
                    j = j + 1
                Loop
            Else
				#IfNDef __USE_GTK__
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
                #EndIf
                LinePrinted = False
                If FECLine->BreakPoint Then
                    Canvas.Font.Bold = True
                    #IfDef __USE_GTK__
						'pango_font_description_set_weight()
                    #Else
						SelectObject(bufDC, This.Canvas.Font.Handle)
					#EndIf
					PaintText i, *s, 0, Len(*s), clMaroon, clWhite, ""
                    LinePrinted = True
                End If
                If CurExecutedLine = z AndAlso CurEC <> 0 Then
                    PaintText i, *s, Len(*s) - Len(LTrim(*s)), Len(*s), IIF(CurEC = @This, clYellow, clBtnFace), clBlack, ""
                    LinePrinted = True
                End If
                If Not LinePrinted Then
                    Canvas.Font.Bold = False
                    #IfNDef __USE_GTK__
						SelectObject(bufDC, This.Canvas.Font.Handle)
                    #EndIf
                    Do While j <= l
                        If iC = 0 AndAlso Mid(*s, j, 1) = """" Then
                            bQ = Not bQ
                            If bQ Then
                                QavsBoshi = j
                            Else
                                PaintText i, *s, QavsBoshi - 1, j, , clMaroon
                                'txtCode.SetSel ss + QavsBoshi - 1, ss + j
                                'txtCode.SelColor = clMaroon
                            End If
                        ElseIf Not bQ Then
                            If Mid(*s, j, 2) = "/'" Then
                                iC = iC + 1
                                If iC = 1 Then
                                    IzohBoshi = j
                                End If
                                j = j + 1
                            ElseIf iC > 0 AndAlso Mid(*s, j, 2) = "'/" Then
                                iC = iC - 1
                                j = j + 1
                                If iC = 0 Then
                                    PaintText i, *s, IzohBoshi, j, , clGreen
                                    'txtCode.SetSel IzohBoshi - 1, ss + j
                                    'txtCode.SelColor = clGreen
                                    'If i > EndLine Then Exit Do
                                End If
                            ElseIf iC = 0 Then
                                t = Asc(Mid(*s, j, 1))
                                u = Asc(Mid(*s, j + 1, 1))
                                If t >= 48 And t <= 57 or t >= 65 And t <= 90 or t >= 97 And t <= 122 Or t = Asc("#") Or t = Asc("$") Or t = Asc("_") Then
                                    If MatnBoshi = 0 Then MatnBoshi = j
                                    If Not (u >= 48 And u <= 57 or u >= 65 And u <= 90 or u >= 97 And u <= 122 Or u = Asc("#") Or u = Asc("$") Or u = Asc("_")) Then
                                        Matn = Mid(*s, MatnBoshi, j - MatnBoshi + 1)
                                        sc = 0
                                        If keywords0.Contains(lcase(Matn)) Then
                                            sc = clBlue
                                        ElseIf keywords1.Contains(lcase(Matn)) Then
                                            sc = clBlue
                                        ElseIf keywords2.Contains(lcase(Matn)) Then
                                            sc = clBlue
                                        Elseif keywords3.Contains(lcase(Matn)) Then
                                            sc = clBlue
                                        Else
                                            sc = clBlack
                                       End If
                                        'If sc <> 0 Then
											PaintText i, *s, MatnBoshi - 1, j, , sc
                                            'txtCode.SetSel ss + MatnBoshi - 1, ss + j
                                            'txtCode.SelColor = sc
                                        'End If
                                        MatnBoshi = 0
                                    End If    
                                ElseIf chr(t) = "'" Then
									PaintText i, *s, j - 1, l, , clGreen
                                    'txtCode.SetSel ss + j - 1, ss + l
                                    'txtCode.SelColor = clGreen
                                    Exit Do
                                ElseIf chr(t) <> " " Then
                                    PaintText i, *s, j - 1, j, , clBlack
                                End If
                            End If
                        End If
                        j = j + 1
                    Loop
                    If iC > 0 Then
						PaintText i, *s, Max(0, IzohBoshi - 1 - ss), l, , clGreen
                        'txtCode.SetSel IzohBoshi - 1, ss + l
                        'txtCode.SelColor = clGreen
                        'If i = EndLine Then k = txtCode.LinesCount
                    ElseIf bQ Then
                        PaintText i, *s, QavsBoshi - 1, j, , clMaroon
                    End If
                End If
                If FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
                    'If iMin <> iMax Then
                    If z >= iSelStartLine And z <= iSelEndLine Then
                '    If iMin >= ss And iMin <= ss + l Or iMax >= ss And iMax <= ss + l Or iMin <= ss And iMax >= ss + l Then
                        'iStart = Max(iMin - j, 0)
                        'iEnd = Min(iMax - j, l)
                        #IfDef __USE_GTK__
							'Dim As GdkRGBA colorHighlightText, colorHighlight 
							Dim As Integer colHighlightText, colHighlight
							'gtk_style_context_get_color(scontext, GTK_STATE_FLAG_SELECTED, @colorHighlightText)
							'gtk_style_context_get_background_color(scontext, GTK_STATE_FLAG_SELECTED, @colorHighlight)
							colHighlight = clOrange 'rgb(colorHighlight.red * 255, colorHighlight.green * 255, colorHighlight.blue * 255)
							colHighlightText = clWhite 'clWhite 'rgb(colorHighlightText.red * 255, colorHighlightText.green * 255, colorHighlightText.blue * 255)
							'?clBlue, getred(clBlue), getgreen(clBlue), getblue(clBlue)
							PaintText i, *s, IIF(iSelStartLine = z, iSelStartChar, 0), IIF(iSelEndLine = z, iSelEndChar, Len(*s)), colHighlight, colHighlightText, IIF(z <> iSelEndLine, " ", "")
                        #Else
							PaintText i, *s, IIF(iSelStartLine = z, iSelStartChar, 0), IIF(iSelEndLine = z, iSelEndChar, Len(*s)), clHighlight, clHighlightText, IIF(z <> iSelEndLine, " ", "")
                        #EndIF
                        'WLet n, Left(*s, iStart)
                        'WLet h, Mid(*s, iStart + 1, iEnd - iStart) & IIF(iLineIndex <> i, " ", "")
                        'SetBKColor(bufDC, clHighlight)
                        'SetTextColor(bufDC, clHighlightText)
                        'GetTextExtentPoint32(bufDC, n, Len(*n), @Sz)
                        'TextOut(bufDC, LeftMargin + -HScrollPos * dwCharX + IIF(iStart = 0, 0, Sz.cx), (i - VScrollPos - 1) * dwCharY, h, Len(*h))
                    End If
                End If
                #IfDef __USE_GTK__
					cairo_set_line_width (cr, 1)
                #EndIf
                If ShowSpaces Then
					#IfDef __USE_GTK__
						cairo_set_source_rgb(cr, 192 / 255.0, 192 / 255.0, 192 / 255.0)
					#Else
						This.Canvas.Brush.Color = rgb(192, 192, 192) 'clLtGray
                    #EndIf
                    'WLet FLineLeft, GetTabbedText(*s, 0, True)
                    jj = 1
                    jPos = 0
                    lLen = Len(*s)
                    Do While jj <= lLen
                        sChar = Mid(*s, jj, 1)
                        If sChar = " " Then
                            jPos += 1
                            'WLet FLineLeft, GetTabbedText(Left(*s, jj - 1))
                            #IfDef __USE_GTK__
								.cairo_rectangle(cr, LeftMargin + -HScrollPos * dwCharX + (jPos - 1) * (dwCharX) + dwCharX / 2, (i - VScrollPos) * dwCharY + dwCharY / 2, 1, 1)
								cairo_fill(cr)
                            #Else
								'GetTextExtentPoint32(bufDC, @Wstr(Left(*FLineLeft, jj - 1)), jj - 1, @Sz) 'Len(*FLineLeft)
								'SetPixel bufDC, LeftMargin + -HScrollPos * dwCharX + IIF(jPos = 0, 0, Sz.cx) + dwCharX / 2, (i - VScrollPos) * dwCharY + dwCharY / 2, clBtnShadow
								SetPixel bufDC, LeftMargin + -HScrollPos * dwCharX + (jPos - 1) * (dwCharX + 1) + dwCharX / 2, (i - VScrollPos) * dwCharY + dwCharY / 2, clLtGray
							#EndIf
                        ElseIf sChar = !"\t" Then
                            jPP = TabWidth - (jPos + TabWidth) Mod TabWidth
                            'WLet FLineLeft, GetTabbedText(Left(*s, jj - 1))
                            #IfDef __USE_GTK__
								cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + 2 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 1 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 5 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 3 - 0.5)
								cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 2 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_move_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) +jPP * dwCharX - 5 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 + 3 - 0.5)
								cairo_line_to(cr, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX) + jPP * dwCharX - 2 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
								cairo_stroke (cr)
							#Else
								'GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @Sz)
								MoveToEx bufDC, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX + 1) + 1, (i - VScrollPos) * dwCharY + dwCharY / 2, 0
								LineTo bufDC, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX + 1) + jPP * dwCharX, (i - VScrollPos) * dwCharY + dwCharY / 2
								MoveToEx bufDC, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX + 1) + jPP * dwCharX - 4, (i - VScrollPos) * dwCharY + dwCharY / 2 - 3, 0
								LineTo bufDC, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX + 1) + jPP * dwCharX - 1, (i - VScrollPos) * dwCharY + dwCharY / 2
								MoveToEx bufDC, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX + 1) +jPP * dwCharX - 4, (i - VScrollPos) * dwCharY + dwCharY / 2 + 3, 0
								LineTo bufDC, LeftMargin + -HScrollPos * dwCharX + jPos * (dwCharX + 1) + jPP * dwCharX - 1, (i - VScrollPos) * dwCharY + dwCharY / 2
							#EndIf
                            jPos += jPP
                        Else
                            jPos += 1
                        End If
                        jj += 1
                    Loop
                End If
            End if
            'If c >= vlc Then Exit Do
            'p = Pos1 + 1
        'Loop While Pos1 > 0
            'Canvas.Font.Bold = False
            #IfDef __USE_GTK__
				cairo_rectangle (cr, 0.0, (i - VScrollPos) * dwCharY, LeftMargin - 25, (i - VScrollPos + 1) * dwCharY, true)
				cairo_set_source_rgb(cr, abs(GetRed(clGray) / 255.0), abs(GetGreen(clGray) / 255.0), abs(GetBlue(clGray) / 255.0))
				cairo_fill (cr)
				WLet FLineLeft, WStr(z + 1)
				'Dim extend As cairo_text_extents_t 
				'cairo_text_extents (cr, *FLineLeft, @extend)
				cairo_move_to(cr, LeftMargin - 30 - TextWidth(ToUTF8(*FLineLeft)), (i - VScrollPos) * dwCharY + dwCharY - 5)
				cairo_set_source_rgb(cr, 1.0, 1.0, 1.0)
				pango_layout_set_text(layout, ToUTF8(*FLineLeft), Len(ToUTF8(*FLineLeft)))
				pango_cairo_update_layout(cr, layout)
				#ifdef PANGO_VERSION
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
				#else
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
				#endif
				pango_cairo_show_layout_line(cr, pl)
				'cairo_show_text(cr, *FLineLeft)
            #Else
				SelectObject(bufDC, This.Canvas.Font.Handle)
				This.Canvas.Brush.Color = clBtnFace
				SetRect(@rc, 0, (i - VScrollPos) * dwCharY, LeftMargin - 25, (i - VScrollPos + 1) * dwCharY)
				'SelectObject(bufDC, This.Canvas.Brush.Handle)
				FillRect bufDC, @rc, This.Canvas.Brush.Handle
				SetBKMode(bufDC, TRANSPARENT)
				WLet FLineLeft, WStr(z + 1)
				GetTextExtentPoint32(bufDC, FLineLeft, Len(*FLineLeft), @Sz)
				SetTextColor(bufDC, clBlack)
				TextOut(bufDC, LeftMargin - 30 - Sz.cx, (i - VScrollPos) * dwCharY, FLineLeft, Len(*FLineLeft))
				SetBKMode(bufDC, OPAQUE)
			#EndIf
            This.Canvas.Brush.Color = This.BackColor
            #IfDef __USE_GTK__
				cairo_rectangle(cr, LeftMargin - 25, (i - VScrollPos) * dwCharY, LeftMargin, (i - VScrollPos + 1) * dwCharY, true)
				cairo_set_source_rgb(cr, 1, 1, 1)
				cairo_fill (cr)
            #Else
				SetRect(@rc, LeftMargin - 25, (i - VScrollPos) * dwCharY, LeftMargin, (i - VScrollPos + 1) * dwCharY)
				FillRect bufDC, @rc, This.Canvas.Brush.Handle
            #EndIf
            If FECLine->BreakPoint Then
                This.Canvas.Pen.Color = clBlack
                This.Canvas.Brush.Color = clMaroon
                #IfDef __USE_GTK__
					cairo_set_source_rgb(cr, abs(GetRed(clMaroon) / 255.0), abs(GetGreen(clMaroon) / 255.0), abs(GetBlue(clMaroon) / 255.0))
					cairo_arc(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 8 - 0.5, 5, 0, 2 * G_PI)
					cairo_fill_preserve(cr)
					cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
					cairo_stroke(cr)
                #Else
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
					Ellipse bufDC, LeftMargin - 16, (i - VScrollPos) * dwCharY + 2, LeftMargin - 5, (i - VScrollPos) * dwCharY + 13
				#EndIf
            End If
            If FECLine->Bookmark Then
                This.Canvas.Pen.Color = clBlack
                This.Canvas.Brush.Color = clAqua
                #IfDef __USE_GTK__
					Var x = LeftMargin - 18, y = (i - VScrollPos) * dwCharY + 3
					Var width1 = 14, height1 = 10, radius = 2
					cairo_set_source_rgb(cr, 0.0, 1.0, 1.0)
					cairo_move_to cr, x - 0.5, y + radius - 0.5
					cairo_arc (cr, x + radius - 0.5, y + radius - 0.5, radius, G_PI, -G_PI / 2)
					cairo_line_to (cr, x + width1 - radius - 0.5, y - 0.5)
					cairo_arc (cr, x + width1 - radius - 0.5, y + radius - 0.5, radius, -G_PI / 2, 0)
					cairo_line_to (cr, x + width1 - 0.5, y + height1 - radius - 0.5)
					cairo_arc (cr, x + width1 - radius - 0.5, y + height1 - radius - 0.5, radius, 0, G_PI / 2)
					cairo_line_to (cr, x + radius - 0.5, y + height1 - 0.5)
					cairo_arc (cr, x + radius - 0.5, y + height1 - radius - 0.5, radius, G_PI / 2, G_PI)
					cairo_close_path cr
					cairo_fill_preserve(cr)
					cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
					cairo_stroke(cr)
                #Else
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
					RoundRect bufDC, LeftMargin - 18, (i - VScrollPos) * dwCharY + 2, LeftMargin - 3, (i - VScrollPos) * dwCharY + 13, 5, 5
				#EndIf
            End If
            #IfDef __USE_GTK__
				cairo_set_source_rgb(cr, 192 / 255.0, 192 / 255.0, 192 / 255.0)
            #EndIf
            If FECLine->Collapsible Then
				#IfDef __USE_GTK__
					'cairo_set_source_rgb(cr, abs(GetRed(clGray) / 255.0), abs(GetGreen(clGray) / 255.0), abs(GetBlue(clGray) / 255.0))
					cairo_rectangle(cr, LeftMargin - 15 - 0.5, (i - VScrollPos) * dwCharY + 4 - 0.5, LeftMargin - 7 - 0.5, (i - VScrollPos) * dwCharY + 12 - 0.5, true)
					cairo_move_to(cr, LeftMargin - 13 - 0.5, (i - VScrollPos) * dwCharY + 8 - 0.5)
					cairo_line_to(cr, LeftMargin - 9 - 0.5, (i - VScrollPos) * dwCharY + 8 - 0.5)
					cairo_move_to(cr, LeftMargin - 0.5, (i - VScrollPos) * dwCharY - 0.5)
					cairo_line_to(cr, dwClientX - 0.5, (i - VScrollPos) * dwCharY - 0.5)
					cairo_stroke (cr)
				#Else
					This.Canvas.Pen.Color = clBtnShadow
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
					Rectangle bufDC, LeftMargin - 15, (i - VScrollPos) * dwCharY + 3, LeftMargin - 6, (i - VScrollPos) * dwCharY + 12
					MoveToEx bufDC, LeftMargin - 13, (i - VScrollPos) * dwCharY + 7, 0
					LineTo bufDC, LeftMargin - 8, (i - VScrollPos) * dwCharY + 7
					MoveToEx bufDC, LeftMargin, (i - VScrollPos) * dwCharY, 0
					LineTo bufDC, dwClientX, (i - VScrollPos) * dwCharY
				#EndIf
                If OldCollapseIndex > 0 Then
					#IfDef __USE_GTK__
						cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 0 - 0.5)
						cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 4 - 0.5)
						cairo_stroke (cr)
					#Else
						MoveToEx bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + 0, 0
						LineTo bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + 3
					#EndIf
                End If
                If FECLine->Collapsed Then
					#IfDef __USE_GTK__
						cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 6 - 0.5)
						cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 10 - 0.5)
						cairo_stroke (cr)
					#Else
						MoveToEx bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + 5, 0
						LineTo bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + 10
					#EndIf
                End If
                If CInt(CInt(OldCollapseIndex = 0) And CInt(Not FECLine->Collapsed)) OrElse CInt(OldCollapseIndex > 0) Then
                    #IfDef __USE_GTK__
						cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 12 - 0.5)
						cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + dwCharY - 0.5)
						cairo_stroke (cr)
					#Else
						MoveToEx bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + 12, 0
						LineTo bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + dwCharY
					#EndIf
                End If
            ElseIf OldCollapseIndex > 0 Then
				#IfDef __USE_GTK__
					cairo_set_source_rgb(cr, 192 / 255.0, 192 / 255.0, 192 / 255.0)
					cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + 0 - 0.5)
				#Else
					This.Canvas.Pen.Color = clBtnShadow
					SelectObject(bufDC, This.Canvas.Brush.Handle)
					SelectObject(bufDC, This.Canvas.Pen.Handle)
					MoveToEx bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + 0, 0
                #EndIf
                If CollapseIndex = 0 Then
					#IfDef __USE_GTK__
						cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
						cairo_stroke (cr)
					#Else
						LineTo bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + dwCharY / 2
					#EndIf
                Else
					#IfDef __USE_GTK__
						cairo_line_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos + 1) * dwCharY + dwCharY - 0.5)
						cairo_stroke (cr)
					#Else
						LineTo bufDC, LeftMargin - 11, (i - VScrollPos + 1) * dwCharY + dwCharY
					#EndIf
                End If
                If CInt(FECLine->ConstructionIndex > 7) And CInt(FECLine->ConstructionPart = 2) Then
                    #IfDef __USE_GTK__
						cairo_move_to(cr, LeftMargin - 11 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
						cairo_line_to(cr, LeftMargin - 6 - 0.5, (i - VScrollPos) * dwCharY + dwCharY / 2 - 0.5)
						cairo_stroke (cr)
                    #Else
						MoveToEx bufDC, LeftMargin - 11, (i - VScrollPos) * dwCharY + dwCharY / 2, 0
						LineTo bufDC, LeftMargin - 6, (i - VScrollPos) * dwCharY + dwCharY / 2
					#EndIf
                End If
            End If
            If i - VScrollPos > vlc1 Then Exit For
            OldCollapseIndex = CollapseIndex
        Next z
        #IfDef __USE_GTK__
			cairo_rectangle (cr, 0, (i - VScrollPos + 1) * dwCharY, LeftMargin - 25, dwClientY, true)
			cairo_set_source_rgb(cr, abs(GetRed(clGray) / 255.0), abs(GetGreen(clGray) / 255.0), abs(GetBlue(clGray) / 255.0))
			cairo_fill (cr)
			cairo_rectangle (cr, LeftMargin - 25, (i - VScrollPos + 1) * dwCharY, LeftMargin, dwClientY, true)
			cairo_set_source_rgb(cr, 1, 1, 1)
			cairo_fill (cr)
			If CaretOn Then
				#IfDef __USE_GTK3__
					gtk_render_insertion_cursor(gtk_widget_get_style_context(widget), cr, HCaretPos, VCaretPos, layout, 0, PANGO_DIRECTION_LTR)
				#Else
					cairo_rectangle (cr, HCaretPos, VCaretPos, HCaretPos + 0.5, VCaretPos + dwCharY, true)
					cairo_set_source_rgb(cr, 0, 0, 0)
					cairo_fill (cr)
				#EndIf
			End If
			'cairo_paint(cr)
        #Else
			SetRect(@rc, 0, (i - VScrollPos + 1) * dwCharY, LeftMargin - 25, dwClientY)
			This.Canvas.Brush.Color = clBtnFace
			FillRect bufDC, @rc, This.Canvas.Brush.Handle
			SetRect(@rc, LeftMargin - 25, (i - VScrollPos + 1) * dwCharY, LeftMargin, dwClientY)
			This.Canvas.Brush.Color = This.BackColor
			FillRect bufDC, @rc, This.Canvas.Brush.Handle
			BitBlt(hD, 0, 0, dwClientX, dwClientY, bufDC, 0, 0, SRCCOPY)
			DeleteDc bufDC
			DeleteObject bufBMP
			ReleaseDc FHandle, hd
			ShowCaret(FHandle)
		#EndIf
		
		Exit Sub
	ErrHandler:
		?ErrDescription(Err) & " (" & Err & ") " & _
    "in function " & ZGet(Erfn()) & " " & _
    "in module " & ZGet(Ermn())  & " " & _
    "in line " & Erl()
    End Sub
	
    Sub EditControl._LoadFromHistory(ByRef HistoryItem As EditControlHistory Ptr, bToBack As Boolean, ByRef oldItem As EditControlHistory Ptr)
        For i As Integer = FLines.Count - 1 To 0 Step -1
            Delete Cast(EditControlLine Ptr, FLines.Items[i])
            'FLines.Remove i
        Next i
        FLines.Clear
        For i As Integer = 0 To HistoryItem->Lines.Count - 1
            FECLine = New EditControlLine
            With *Cast(EditControlLine Ptr, HistoryItem->Lines.Item(i))
                WLet FECLine->Text, *.Text
                FECLine->Breakpoint = .Breakpoint
                FECLine->Bookmark = .Bookmark
                FECLine->CommentIndex = .CommentIndex
                FECLine->ConstructionIndex = .ConstructionIndex
                FECLine->ConstructionPart = .ConstructionPart
                FECLine->Collapsible = .Collapsible
                FECLine->Collapsed = .Collapsed
                FECLine->Visible = .Visible
            End With
            FLines.Add FECLine
        Next i
        If FLines.Count = 0 Then
            FECLine = New EditControlLine
            WLet FECLine->Text, ""
            FLines.Add FECLine
        End If
        If bToBack Then
            FSelStartLine = oldItem->OldSelStartLine
            FSelStartChar = oldItem->OldSelStartChar
            FSelEndLine = oldItem->OldSelEndLine
            FSelEndChar = oldItem->OldSelEndChar
        Else
            FSelStartLine = HistoryItem->SelStartLine
            FSelStartChar = HistoryItem->SelStartChar
            FSelEndLine = HistoryItem->SelEndLine
            FSelEndChar = HistoryItem->SelEndChar
        End If
        bOldCommented = True
	#IfDef __USE_GTK__
		If cr Then
	#Else
		If Handle Then
	#EndIf
			ScrollToCaret
		End If
        OldnCaretPosX = nCaretPosX
        OldCharIndex = GetOldCharIndex
        If OnChange Then OnChange(This)
        Modified = True
    End Sub
    
    Sub EditControl.Undo
        If curHistory <= 0 Then Exit Sub
        curHistory = curHistory - 1
        _LoadFromHistory FHistory.Items[curHistory], True, FHistory.Items[curHistory + 1]
    End Sub
    
    Sub EditControl.Redo
        If curHistory >= FHistory.Count - 1 Then Exit Sub
        curHistory = curHistory + 1
        _LoadFromHistory FHistory.Item(curHistory), False, FHistory.Item(curHistory - 1)
    End Sub
    
    Function EditControl.CharType(ByRef ch As WString) As Integer '...'
        If ch = " " Then: Return 0
        ElseIf ch = Chr(13) Or ch = "" Then: Return 1
        ElseIf Instr(Symbols, ch) > 0 Then: Return 2
        Else: Return 3
        End If
    End Function

    Sub EditControl.WordLeft() '...'
        Dim f As Integer
        Var item = Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))
        If FSelEndChar = 0 Then
            f = 1
        Else
            f = CharType(Mid(*item->Text, FSelEndChar - 1 + 1, 1))
        End If
        Dim c As Integer, i As Integer, j As Integer, k As Integer
        For i = FSelEndLine To 0 Step -1
            item = Cast(EditControlLine Ptr, FLines.Item(i))
            If i = FSelEndLine Then k = FSelEndChar Else k = Len(*item->Text)
            For j = k - 1 To -1 Step -1
                If j = -1 Then
                    c = CharType(Chr(13))
                Else
                    c = CharType(Mid(*item->Text, j + 1, 1))
                End If
                If f = 0 Then f = c
                If c <> f Then FSelEndChar = j + 1: FSelEndLine = i: Exit Sub
            Next j
        Next i
        FSelEndChar = 0
        FSelEndLine = 0
    End Sub

    Sub EditControl.WordRight() '...'
        Dim f As Integer
        Var item = Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))
        If FSelEndChar = Len(*item->Text) Then
            f = 1
        Else
            f = CharType(Mid(*item->Text, FSelEndChar + 1, 1))
        End If
        Dim c As Integer, i As Integer, j As Integer, k As Integer
        For i = FSelEndLine To FLines.Count - 1
            item = Cast(EditControlLine Ptr, FLines.Item(i))
            If i = FSelEndLine Then k = FSelEndChar + 1 Else k = -1
            For j = k To Len(*item->Text)
                If j = -1 Then
                    c = CharType(Chr(13))
                Else
                    c = CharType(Mid(*item->Text, j + 1, 1))
                End If
                If c = 0 Then f = 0
                If c <> f Then FSelEndChar = j: FSelEndLine = i: Exit Sub
            Next j
        Next i
        FSelEndChar = Len(*item->Text)
        FSelEndLine = i - 1
    End Sub

    Function GetLeftSpace(ByRef Value As WString) As Integer
        Return Len(Value) - Len(LTrim(Value, " "))
    End Function
    
    Function EditControl.InCollapseRect(i As Integer, X As Integer, Y As Integer) As Boolean '...'
        Return CInt(X >= LeftMargin - 15 AndAlso X <= LeftMargin - 6) AndAlso _
            CInt(Cast(EditControlLine Ptr, FLines.Items[i])->Collapsible)
            'Y >= (i - VScrollPos) * dwCharY + 3 AndAlso Y <= (i - VScrollPos) * dwCharY + 12) AndAlso _
    End Function
    
    Function EditControl.GetLineIndex(Index As Integer, iTo As Integer = 0) As Integer
        Var j = -1, iStep = IIF(iTo <= 0, -1, 1), k = Index
        Var iEnd = IIF(iTo <= 0, 0, FLines.Count - 1)
        For i As Integer = Index To iEnd Step iStep
            If Cast(EditControlLine Ptr, FLines.Items[i])->Visible Then
                j = j + 1
                k = i
                If j = Abs(iTo) Then Return i
            End If
        Next
        Return k
    End Function

    Sub EditControl.ShowDropDownAt(iSelEndLine As Integer, iSelEndChar As Integer)
        Var nCaretPosY = GetCaretPosY(iSelEndLine)
        Var nCaretPosX = TextWidth(GetTabbedText(Left(Lines(iSelEndLine), iSelEndChar)))
        Var HCaretPos = LeftMargin + nCaretPosX - HScrollPos * dwCharX
        Var VCaretPos = (nCaretPosY - VScrollPos + 1) * dwCharY
        DropDownChar = iSelEndChar
        DropDownShowed = True
        #IfDef __USE_GTK__
        	Dim As gint x, y
        	gdk_window_get_origin(gtk_widget_get_window(widget), @x, @y)
        	gtk_window_move(gtk_window(winIntellisense), HCaretPos + x, VCaretPos + y)
        	gtk_widget_show_all(winIntellisense)
        #Else
	        pnlIntellisense.SetBounds HCaretPos, VCaretPos, 250, 0
	        cboIntellisense.ShowDropDown True
	        If LastItemIndex = -1 Then cboIntellisense.ItemIndex = -1
    	#EndIf
    End Sub
    
    Sub EditControl.CloseDropDown()
        DropDownShowed = False
        #IfDef __USE_GTK__
        	gtk_widget_hide(gtk_widget(winIntellisense))
        #Else
        	cboIntellisense.ShowDropDown False
        #EndIf
    End Sub
        
    Sub EditControl.ProcessMessage(ByRef msg As Message)
        Static bShifted As Boolean
        Static bCtrl As Boolean
        Static OldPos As Integer
        Static scrStyle As Integer, scrDirection As Integer
        #IfDef __USE_GTK__
			bShifted = msg.event->Key.state And GDK_Shift_MASK
			bCtrl = msg.event->Key.state And GDK_Control_MASK
        #Else
			bShifted = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
		#EndIf
			'Base.ProcessMessage(msg)
			#IfDef __USE_GTK__
				Dim As GdkEvent Ptr e = msg.event
				Select Case msg.event->Type
			#Else
				Select Case msg.msg
				Case CM_CREATE
						hd = GetDC(FHandle)
						GetTextMetrics(hd, @tm)
						ReleaseDC(FHandle, hd)

						LeftMargin = 50
						
						dwCharX = tm.tmAveCharWidth
						dwCharY = tm.tmHeight
			
						dwClientX = ClientWidth
						dwClientY = ClientHeight
							
						PaintControl
			#EndIf
			#IfDef __USE_GTK__
				Case GDK_CONFIGURE
					dwClientX = ClientWidth
					dwClientY = ClientHeight
					'Msg.result = True
				Case GDK_EXPOSE
					#IfnDef __USE_GTK__
						PaintControl
					#EndIf
			#Else
				Case WM_SIZE
					dwClientX = LOWORD(msg.lParam)
					dwClientY = HIWORD(msg.lParam)
			#EndIf
				
				SetScrollsInfo
			#IfDef __USE_GTK__
			Case GDK_SCROLL
			#Else
			Case WM_MOUSEWHEEL
			#EndIf
				#IfDef __USE_GTK__
					OldPos = gtk_adjustment_get_value(adjustmentv)
					#IfDef __USE_GTK3__
						scrDirection = e->scroll.delta_y
					#Else
						scrDirection = IIF(e->scroll.direction = GDK_SCROLL_UP, -1, 1)
					#EndIf
					If scrDirection = 1 Then
						gtk_adjustment_set_value(adjustmentv, Min(OldPos + 3, gtk_adjustment_get_upper(adjustmentv)))
					ElseIf scrDirection = -1 Then
						gtk_adjustment_set_value(adjustmentv, Max(OldPos - 3, gtk_adjustment_get_lower(adjustmentv)))
					End If
					'If Not gtk_adjustment_get_value(adjustmentv) = OldPos Then
						VScrollPos = gtk_adjustment_get_value(adjustmentv)
						ShowCaretPos False
						'PaintControl
						#IfDef __USE_GTK3__
							gtk_widget_queue_draw(widget)
						#Else
							gtk_widget_queue_draw(widget)
						#EndIf
					'End If
				#Else
					#IfDef __FB_64bit__
						If msg.wParam < 4000000000 Then
							scrDirection = 1
						Else
							scrDirection = -1
						End If
					#Else
						scrDirection = Sgn(msg.wParam)
					#EndIf
					si.cbSize = sizeof (si)
					si.fMask  = SIF_ALL
					GetScrollInfo (FHandle, SB_VERT, @si)
					OldPos = si.nPos
					If scrDirection = -1 Then
						si.nPos = Min(si.nPos + 3, si.nMax)
					Else
						si.nPos = Max(si.nPos - 3, si.nMin)
					End If
					si.fMask = SIF_POS
					SetScrollInfo(FHandle, SB_VERT, @si, TRUE)
					GetScrollInfo(FHandle, SB_VERT, @si)
					If (Not si.nPos = OldPos) Then
						VScrollPos = si.nPos
						ShowCaretPos False
						PaintControl
					End If
				#EndIf
				#IfNDef __USE_GTK__
			Case WM_SETCURSOR
				Var d = GetMessagePos
				Dim As Points ps = MAKEPOINTS(d)
				Dim As Point p
				p.X = ps.X
				p.Y = ps.Y
				ScreenToClient(Handle, @p)
				Dim As Integer i = LineIndexFromPoint(p.X, p.Y)
				'If Cast(EditControlLine Ptr, FLines.Items[i])->Collapsible Then
					'If p.X < LeftMargin AndAlso p.X > LeftMargin - 15 Then
					 If InCollapseRect(i, p.X, p.Y) Then
						msg.Result = Cast(LResult, SetCursor(crHand.Handle))
						Return
					End If
				'End If
				'If LoWord(msg.lParam) = HTCLIENT Then
				'    'msg.Result = Cast(LResult, SetCursor(crHand.Handle))
				'    SetCursor(crHand.Handle)
				'    Return
				'End If
			Case WM_HSCROLL, WM_VSCROLL
				If msg.msg = WM_HSCROLL Then
					scrStyle = SB_HORZ
				Else
					scrStyle = SB_VERT
				End If
				si.cbSize = sizeof (si)
				si.fMask  = SIF_ALL
				GetScrollInfo (FHandle, scrStyle, @si)
				OldPos = si.nPos
				Select Case msg.wParamLo
				Case SB_TOP, SB_LEFT
					si.nPos = si.nMin
				Case SB_BOTTOM, SB_RIGHT
					si.nPos = si.nMax
				Case SB_LINEUP, SB_LINELEFT
					si.nPos -= 1
				Case SB_LINEDOWN, SB_LINERIGHT
					si.nPos += 1
				Case SB_PAGEUP, SB_PAGELEFT
					si.nPos -= si.nPage
				Case SB_PAGEDOWN, SB_PAGERIGHT
					si.nPos += si.nPage
				Case SB_THUMBPOSITION, SB_THUMBTRACK
					si.nPos = si.nTrackPos
				End Select
				si.fMask = SIF_POS
				SetScrollInfo(FHandle, scrStyle, @si, TRUE)
				GetScrollInfo(FHandle, scrStyle, @si)
				If (Not si.nPos = OldPos) Then
					If scrStyle = SB_HORZ Then
						HScrollPos = si.nPos
					Else
						VScrollPos = si.nPos
					End If
					ShowCaretPos False
					PaintControl
				End If
		#EndIf
		#IfDef __USE_GTK__
			Case GDK_FOCUS_CHANGE
				InFocus = Cast(GdkEventFocus Ptr, e)->in
				If InFocus Then
					gdk_threads_add_timeout(This.BlinkTime, @Blink_cb, @This)
				Else
					If DropDownShowed Then CloseDropDown
				End If
		#Else
			Case WM_SETFOCUS
				CreateCaret(FHandle, 0, 0, dwCharY)
				ScrollToCaret
				ShowCaret(FHandle)
			Case WM_KILLFOCUS
				HideCaret(FHandle)
				DestroyCaret()
			Case WM_UNDO
				Undo
			'Case WM_REDO
			Case WM_CUT
				CutToClipboard
			Case WM_COPY
				CopyToClipboard
			Case WM_PASTE
				PasteFromClipboard
			  Case WM_GETDLGCODE: msg.Result = DLGC_HASSETSEL Or DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTMESSAGE Or DLGC_WANTTAB
		#EndIf
		#IfDef __USE_GTK__
			Case GDK_KEY_PRESS
				Select Case e->Key.keyval
		#Else
			Case WM_KEYDOWN
				Select Case msg.wParam
		#EndIf
			#IfDef __USE_GTK__
				Case GDK_KEY_Cut
					CutToClipboard
				Case GDK_KEY_Copy
					CopyToClipboard
				Case GDK_KEY_Paste
					PasteFromClipboard
				Case GDK_KEY_Redo
					Redo
				Case GDK_KEY_Undo
					Undo
			#EndIf
			#IfDef __USE_GTK__
				Case GDK_KEY_Home
			#Else
				Case VK_HOME
			#EndIf
					FSelEndChar = 0
					If bCtrl Then FSelEndLine = 0
					If Not bShifted Then
						FSelStartChar = FSelEndChar
						FSelStartLine = FSelEndLine
					End If
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
			#IfDef __USE_GTK__
				Case GDK_KEY_END
			#Else
				Case VK_END
			#EndIf
					If bCtrl Then FSelEndLine = FLines.Count - 1
					FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					ScrollToCaret
					OldnCaretPosX = nCaretPosX
					OldCharIndex = GetOldCharIndex
			#IfDef __USE_GTK__
				Case GDK_KEY_Escape
					If DropDownShowed Then CloseDropDown()
			#Else
				Case VK_ESCAPE
					If DropDownShowed Then cboIntellisense.ShowDropDown False
			#EndIf
			#IfDef __USE_GTK__
				Case GDK_KEY_Delete
			#Else
				Case VK_DELETE
			#EndIf
					If bShifted Then
						CutToClipboard
					Else
						If FSelEndLine = FLines.Count - 1 And FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FLines.Count - 1))->Text) And FSelStartLine = FSelEndLine And FSelStartChar = FSelEndChar Then
							Return
						ElseIf FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
							ChangeText "", 0, "Belgilangan matnni o`chirish"
						ElseIf bCtrl Then
							WordRight
							ChangeText "", 0, "Olddagi so`zni o`chirish"
						Else    
							ChangeText "", 1, "Olddagi belgini o`chirish"
						End If
					End If
			#IfDef __USE_GTK__
				Case GDK_KEY_BACKSPACE
					If FSelStartLine = 0 And FSelEndLine = 0 And FSelStartChar = 0 And FSelEndChar = 0 Then
						Return
					ElseIf FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
						ChangeText "", 0, "Belgilangan matn o`chirildi"
					ElseIf bCtrl Then
						WordLeft
						ChangeText "", 0, "Ortdagi so`z o`chirildi"
					Else
						WLet FLine, Lines(FSelEndLine)
						Var n = Len(*FLine) - Len(LTrim(*FLine))
						If n > 0 AndAlso n = FSelEndChar AndAlso Mid(*FLine, FSelEndChar + 1, 1) <> " " Then
							Var d = Min(n, TabWidth - (n Mod TabWidth))
							bAddText = True
							ChangeText "", -d
						Else
							If FSelEndChar = 0 And FSelStartChar = 0 And FSelStartLine = FSelEndLine Then
								If CInt(FSelEndLine > 0) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine - 1])->Visible) Then
									ShowLine FSelEndLine - 1
								End If
							End If
							bAddText = True
							ChangeText "", -1
						End If
					End If
			#EndIf
			#IfDef __USE_GTK__
				Case GDK_KEY_Left
					msg.Result = True
			#Else
				Case VK_LEFT
			#EndIf
					If CInt(FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar) AndAlso CInt(Not bShifted) Then
						ChangeSelPos True
						ScrollToCaret
						OldnCaretPosX = nCaretPosX
						OldCharIndex = GetOldCharIndex
					ElseIf FSelEndChar > 0 Or (FSelEndChar = 0 And FSelEndLine > 0) Then
						If Cint(bCtrl) Then
							WordLeft
						Else
							ChangePos -1
						End If
						If Not bShifted Then
							FSelStartLine = FSelEndLine
							FSelStartChar = FSelEndChar
						End If
						ScrollToCaret
						OldnCaretPosX = nCaretPosX
						OldCharIndex = GetOldCharIndex
					End If
			#IfDef __USE_GTK__
				Case GDK_KEY_RIGHT
					msg.Result = True
			#Else
				Case VK_RIGHT
			#EndIf
					If CInt(FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar) And CInt(Not bShifted) Then
						ChangeSelPos False
						ScrollToCaret
						OldnCaretPosX = nCaretPosX
						OldCharIndex = GetOldCharIndex
					ElseIf FSelEndChar < Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text) Or (FSelEndLine < FLines.Count - 1) Then
						If Cint(bCtrl) Then
							WordRight
						Else
							ChangePos 1
						End If
						If Not bShifted Then
							FSelStartLine = FSelEndLine
							FSelStartChar = FSelEndChar
						End If
						ScrollToCaret
						OldnCaretPosX = nCaretPosX
						OldCharIndex = GetOldCharIndex
					End If
			#IfDef __USE_GTK__
				Case GDK_KEY_UP
					msg.Result = True
			#Else
				Case VK_UP
			#EndIf
					If DropDownShowed Then
						#IfDef __USE_GTK__
							If Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex) > 0 Then
								LastItemIndex = Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex) - 1
								FocusedItemIndex = LastItemIndex
								lvIntellisense.SelectedItemIndex = LastItemIndex
							End If
						#Else
							If Max(FocusedItemIndex, cboIntellisense.ItemIndex) > 0 Then
								LastItemIndex = Max(FocusedItemIndex, cboIntellisense.ItemIndex) - 1
								FocusedItemIndex = LastItemIndex
								cboIntellisense.ItemIndex = LastItemIndex
							End If
						#EndIf
					ElseIf FSelEndLine = 0 Then
						If bShifted Then
							FSelEndChar = 0
							ScrollToCaret
						ElseIf FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar Then
							ChangeSelPos True
							ScrollToCaret
						End If    
					Else
						If FSelEndLine > 0 Then
							FSelEndLine = GetLineIndex(FSelEndLine, -1)
							FSelEndChar = GetCharIndexFromOld
							Var LengthOf = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
							If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
						End If
						If Not bShifted Then
							FSelStartLine = FSelEndLine
							FSelStartChar = FSelEndChar
						End If
						ScrollToCaret
					End If
			#IfDef __USE_GTK__
				Case GDK_KEY_Down
					msg.Result = True
			#Else
			   Case VK_DOWN
			#EndIf
					If DropDownShowed Then
						'keybd_event(VK_DOWN, 0, KEYEVENTF_EXTENDEDKEY, 0)
	'                    SendMessage(cboIntellisense.Handle, WM_KEYDOWN, Cast(WPAram, VK_DOWN), 0)
						'Dim As ComboBoxInfo Info
						'Info.cbSize = SizeOf(ComboBoxInfo)
						'If GetComboBoxInfo(cboIntellisense.Handle,  @Info) AndAlso (Info.hwndList <> 0) Then
						'    PostMessage(Info.hwndList, LB_SETCURSEL, cboIntellisense.ItemIndex + 1, 0)
						'End If
						'?Info.hwndList
						#IfDef __USE_GTK__
							If Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex) < lvIntellisense.ListItems.Count - 1 Then
								LastItemIndex = Max(FocusedItemIndex, lvIntellisense.SelectedItemIndex + 1)
								FocusedItemIndex = LastItemIndex
								lvIntellisense.SelectedItemIndex = LastItemIndex
							End If
						#Else
							If Max(FocusedItemIndex, cboIntellisense.ItemIndex) < cboIntellisense.Items.Count - 1 Then
								LastItemIndex = Max(FocusedItemIndex, cboIntellisense.ItemIndex + 1)
								FocusedItemIndex = LastItemIndex
								cboIntellisense.ItemIndex = LastItemIndex
							End If
						#EndIf
					ElseIf FSelEndLine = GetLineIndex(FLines.Count - 1) Then
						If bShifted Then
							Var LengthOf = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
							FSelEndChar = LengthOf
							ScrollToCaret
						ElseIf FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar Then
							ChangeSelPos False
							ScrollToCaret
						End If    
					Else
						If FSelEndLine < GetLineIndex(FLines.Count - 1) Then
							FSelEndLine = GetLineIndex(FSelEndLine, +1)
							FSelEndChar = GetCharIndexFromOld
							Var LengthOf = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
							If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
						End If
						If Not bShifted Then
							FSelStartLine = FSelEndLine
							FSelStartChar = FSelEndChar
						End If
						ScrollToCaret
					End If
			#IfDef __USE_GTK__
				Case GDK_KEY_Page_Up
			#Else
				Case VK_PRIOR
			#EndIf
					If DropDownShowed Then
						#IfDef __USE_GTK__
							If lvIntellisense.SelectedItemIndex > 1 Then LastItemIndex = Max(0, lvIntellisense.SelectedItemIndex - 6): lvIntellisense.SelectedItemIndex = LastItemIndex
						#Else
							If cboIntellisense.ItemIndex > 1 Then LastItemIndex = Max(0, cboIntellisense.ItemIndex - 6): cboIntellisense.ItemIndex = LastItemIndex
						#EndIf
					ElseIf FSelEndLine < GetLineIndex(0, +VisibleLinesCount) Then
						FSelEndLine = 0
						FSelEndChar = 0
					Else
						FSelEndLine = GetLineIndex(FSelEndLine, -VisibleLinesCount)
						FSelEndChar = GetCharIndexFromOld
						Var LengthOf = LineLength(FSelEndLine)
						If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					ScrollToCaret
			#IfDef __USE_GTK__
				Case GDK_KEY_Page_Down
			#Else
				Case VK_NEXT
			#EndIf
					If DropDownShowed Then
						#IfDef __USE_GTK__
							If lvIntellisense.SelectedItemIndex < lvIntellisense.ListItems.Count - 1 Then LastItemIndex = Min(lvIntellisense.SelectedItemIndex + 6, lvIntellisense.ListItems.Count - 1): lvIntellisense.SelectedItemIndex = LastItemIndex
						#Else
							If cboIntellisense.ItemIndex < cboIntellisense.Items.Count - 1 Then LastItemIndex = Min(cboIntellisense.ItemIndex + 6, cboIntellisense.Items.Count - 1): cboIntellisense.ItemIndex = LastItemIndex
						#EndIf
					ElseIf FSelEndLine > GetLineIndex(FLines.Count - 1, -VisibleLinesCount) Then
						FSelEndLine = GetLineIndex(FLines.Count - 1)
						FSelEndChar = LineLength(FSelEndLine)
					Else
						FSelEndLine = GetLineIndex(FSelEndLine, +VisibleLinesCount)
						FSelEndChar = GetCharIndexFromOld
						Var LengthOf = LineLength(FSelEndLine)
						If FSelEndChar > LengthOf Then FSelEndChar = LengthOf
					End If
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
					ScrollToCaret
			#IfDef __USE_GTK__
				Case GDK_KEY_Insert
			#Else
				Case VK_INSERT
			#EndIf
					If bCtrl Then
						CopyToClipboard
					ElseIf bShifted Then
						PasteFromClipboard
					End If
			#IfDef __USE_GTK__
				Case GDK_KEY_F9
			#Else
				Case VK_F9
			#EndIf
					Breakpoint
			#IfDef __USE_GTK__
				Case GDK_KEY_F6
			#Else
				Case VK_F6
			#EndIf
					Bookmark
			#IfDef __USE_GTK__
				Case GDK_KEY_Tab
					If DropDownShowed Then
						#IfDef __USE_GTK__
							CloseDropDown()
							If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
						#Else
							cboIntellisense.ShowDropDown False
							If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
						#EndIf
					End If
					'If TabAsSpaces Then
'                                Var d = 4 - (FSelEndChar Mod 4)
'                                for i As Integer = 0 to d - 1
'                                    SendMessage(FHandle, WM_CHAR, 32, 0)
'                                Next i
'                                Return
					'Else
						bAddText = True
						If FSelStartLine <> FSelEndLine Then
							Indent
						Else
							#IfDef __USE_GTK__
								ChangeText !"\t" '*e->Key.string
							#Else
								ChangeText WChr(msg.wParam)
							#EndIf
						End If
					'End If
					msg.Result = True
				Case GDK_KEY_ISO_Left_Tab ', 65056
					Outdent
					Msg.Result = True
			#EndIf
		#IfDef __USE_GTK__
				Case Else
					
				Select Case (Asc(*e->Key.string))
		#Else
				End Select
			Case WM_CHAR
				Select Case (msg.wParam)
		#EndIf
				Case 8:  ' backspace
						If FSelStartLine = 0 And FSelEndLine = 0 And FSelStartChar = 0 And FSelEndChar = 0 Then
							Return
						ElseIf FSelStartLine <> FSelEndLine Or FSelStartChar <> FSelEndChar Then
							ChangeText "", 0, "Belgilangan matn o`chirildi"
						ElseIf bCtrl Then
							WordLeft
							ChangeText "", 0, "Ortdagi so`z o`chirildi"
						Else
							WLet FLine, Lines(FSelEndLine)
							Var n = Len(*FLine) - Len(LTrim(*FLine))
							If n > 0 AndAlso n = FSelEndChar AndAlso Mid(*FLine, FSelEndChar + 1, 1) <> " " Then
								Var d = Min(n, TabWidth - (n Mod TabWidth))
								bAddText = True
								ChangeText "", -d
							Else
								If FSelEndChar = 0 And FSelStartChar = 0 And FSelStartLine = FSelEndLine Then
									If CInt(FSelEndLine > 0) AndAlso CInt(Not Cast(EditControlLine Ptr, FLines.Items[FSelEndLine - 1])->Visible) Then
										ShowLine FSelEndLine - 1
									End If
								End If
								bAddText = True
								ChangeText "", -1
							End If
						End If
							Case 10:  ' перевод строки
							Case 27:  ' esc
								#IfNDef __USE_GTK__
									MessageBeep(-1)
							   #EndIf
								msg.Result = 0
							Case 9:  ' tab
								If DropDownShowed Then
									#IfDef __USE_GTK__
										CloseDropDown()
										If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
									#Else
										cboIntellisense.ShowDropDown False
										If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
									#EndIf
								End If
								'If TabAsSpaces Then
	'                                Var d = 4 - (FSelEndChar Mod 4)
	'                                for i As Integer = 0 to d - 1
	'                                    SendMessage(FHandle, WM_CHAR, 32, 0)
	'                                Next i
	'                                Return
								'Else
									bAddText = True
									If FSelStartLine <> FSelEndLine Then
										Indent
									Else
										#IfDef __USE_GTK__
											ChangeText *e->Key.string
										#Else
											ChangeText WChr(msg.wParam)
										#EndIf
									End If
								'End If
								msg.Result = True
						Case 13:  ' возврат каретки
							If DropDownShowed Then
								#IfDef __USE_GTK__
									CloseDropDown()
									If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
								#Else
									cboIntellisense.ShowDropDown False
									If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
								#EndIf
							End If
								If CInt(FSelEndLine = FSelStartLine) AndAlso CInt(FSelEndChar = FSelStartChar) AndAlso CInt(FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text)) Then
									Var iEndLine = GetLineIndex(FSelEndLine, 1)
									If iEndLine = FSelEndLine Then FSelEndLine = FLines.Count - 1 Else FSelEndLine = iEndLine - 1
									FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text)
									FSelStartLine = FSelEndLine
									FSelStartChar = FSelEndChar
								End If
								WLet FLine, Left(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, FSelEndChar)
								WLet FLineLeft, ""
								WLet FLineRight, ""
								WLet FLineTemp, ""
								Dim j As Integer = 0
								Dim i As Integer = GetConstruction(RTrim(*FLine, Any !"\t "), j)
								Var d = Len(*FLine) - Len(LTrim(*FLine, Any !"\t "))
								WLet FLineSpace, Left(*FLine, d)
								Var k = 0
								Var p = 0
								Var z = 0
								If CInt(AutoIndentation) And CInt(i > -1) Then
									If j > 0 Then
										Dim y As Integer
										For o As Integer = FSelEndLine - 1 To 0 Step -1
											With *Cast(EditControlLine Ptr, FLines.Items[o])
												If .ConstructionIndex = i Then 
													If .ConstructionPart = 2 Then
														y = y + 1
													ElseIf .ConstructionPart = 0 Then
														If y = 0 Then
															Var ltt0 = Len(GetTabbedText(*.Text))
															Var ltt1 = Len(GetTabbedText(*FLine))
															If ltt0 <> ltt1 Then
																d = Len(*.Text) - Len(LTrim(*.Text, Any !"\t "))
																FSelEndChar = FSelEndChar - (Len(*FLineSpace) - d)
																FSelStartChar = FSelEndChar
																WLet FLineSpace, Left(*.Text, d)
																WLet Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, *FLineSpace & LTrim(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, Any !"\t ")
															End If
															Exit For
														Else
															y = y - 1
														End If
													End If
												End If
											End With
										Next
									End If
									If CInt(j < 2) Then
										If TabAsSpaces Then
											k = TabWidth
										Else
											k = 1
										End If
										If j = 0 Then
											If FSelEndLine < FLines.Count - 1 Then WLet FLineTemp, GetTabbedText(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine + 1])->Text)
											Dim n As Integer
											Dim m As Integer = GetConstruction(*FLineTemp, n)
											Var e = Len(*FLineTemp) - Len(LTrim(*FLineTemp, Any !"\t "))
											WLet FLineTemp, GetTabbedText(*FLine)
											Var r = Len(*FLineTemp) - Len(LTrim(*FLineTemp, Any !"\t "))
												If e > r OrElse (e = r And m = i And n > 0) Then
											Else
												WLet FLineTemp,  Mid(*Cast(EditControlLine Ptr, FLines.Items[FSelEndLine])->Text, FSelEndChar + 1)
												WLet FLineRight, LTrim(*FLineTemp, Any !"\t ") & Chr(13) & *FLineSpace & Constructions(i).EndName
												p = Len(*FLineTemp)
											End If
										End If
										If i = 0 And (j = 0 Or j = 1) Then
											If (StartsWith(LTrim(LCase(*FLine), Any !"\t "), "if ") Or StartsWith(LTrim(LCase(*FLine), Any !"\t "), "elseif ")) And (Not EndsWith(RTrim(LCase(*FLine), Any !"\t "), "then")) And (Not EndsWith(RTrim(LCase(*FLine), Any !"\t "), "_")) Then
												p = Len(RTrim(*FLine, Any !"\t ")) - Len(*FLine)
												WLet FLineLeft, " Then"
											End If
										End If
									End If
								End If
								If CInt(TabAsSpaces) OrElse CInt(k = 0) Then
									WLet FLineSpace, *FLineSpace & WSpace(k)
								Else
									WLet FLineSpace, *FLineSpace & !"\t"
								End If
								ChangeText *FLineLeft & WChr(13) & *FLineSpace & *FLineRight, p, "Enter bosildi", FSelEndLine + 1, d + k
								'Var n = Min(FSelStart, FSelEnd)
								'Var x = Max(FSelStart, FSelEnd)
								'Var l = LineFromCharIndex(n)
								'Var c = CharIndexFromLine(l)
								'Var l1 = LineFromCharIndex(x)
								'If l1 + 1 < FLines.Count Then
								'    WLet FLineRight, *Cast(EditControlLine Ptr, FLines.Item(l1 + 1))->Text
								'Else
								'    WLet FLineRight, ""
								'End If
								'WLet FLine, Mid(*FText, c + 1, n - c + 1)
								'Var d = GetLeftSpace(*FLine)
								'Var k = 0
								'WLet FLineLeft, ""
								'For i As Integer = 0 To Ubound(Constructions)
								'    If Constructions(i).Name0 <> "" AndAlso Instr(" " & LCase(*FLine), " " & LCase(Constructions(i).Name0) & " ") AndAlso _ 
								'    (Constructions(i).Exception = "" OrElse Instr(LCase(*FLine), LCase(Constructions(i).Exception)) = 0) Then
								'        Var e = GetLeftSpace(*FLineRight)
								'        If e > d OrElse (e = d AndAlso ((Constructions(i).Name1 <> "" AndAlso Instr(" " & LCase(*FLineRight) & " ", " " & LCase(Constructions(i).Name1) & " ")) OrElse _
								'           (Constructions(i).Name2 <> "" AndAlso Instr(" " & LCase(*FLineRight) & " ", " " & LCase(Constructions(i).Name2) & " ")) OrElse _
								'           (Constructions(i).EndName <> "" AndAlso Instr(" " & LCase(*FLineRight) & " ", " " & LCase(Constructions(i).EndName) & " "))) AndAlso _
								'           (Constructions(i).Exception = "" OrElse Instr(LCase(*FLineRight), LCase(Constructions(i).Exception)) = 0)) Then
								'            
								'        Else
								'            WLet FLineLeft, Chr(13) & Space(d) & Constructions(i).EndName
								'        End If
								'        k = 4
								'        Exit For
								'    ElseIf ((Constructions(i).Name1 <> "" AndAlso Instr(" " & LCase(*FLine) & " ", " " & LCase(Constructions(i).Name1) & " ")) OrElse _
								'           (Constructions(i).Name2 <> "" AndAlso Instr(" " & LCase(*FLine) & " ", " " & LCase(Constructions(i).Name2) & " "))) AndAlso _
								'           (Constructions(i).Exception = "" OrElse Instr(LCase(*FLine), LCase(Constructions(i).Exception)) = 0) Then
								'        k = 4
								'        Exit For
								'    End If
								'Next i
								'ChangeText Left(*FText, n) & Chr(13) & Space(d) & Space(k) & *FLineLeft & Mid(*FText, x + 1), "Enter bosildi", n + 1 + d + k
								'ChangeText Chr(13), 0, "Enter bosildi", FSelStartLine + 1, 0
							'End If
						Case Else:    ' отображаемые символы
					#IfDef __USE_GTK__
						If Cint(Not bCtrl) AndAlso CInt(*e->Key.string <> "") Then
					#Else
						If GetKeyState(VK_CONTROL) >= 0 Then
					#EndIf
						#IfDef __USE_GTK__
							If *e->Key.string = " " Then
						#Else
							If msg.wParam = Asc(" ") Then
						#EndIf
								If DropDownShowed Then
									#IfDef __USE_GTK__
										CloseDropDown()
										If LastItemIndex <> -1 AndAlso lvIntellisense.OnItemActivate Then lvIntellisense.OnItemActivate(lvIntellisense, LastItemIndex)
									#Else
										cboIntellisense.ShowDropDown False
										If LastItemIndex <> -1 AndAlso cboIntellisense.OnSelected Then cboIntellisense.OnSelected(cboIntellisense, LastItemIndex)
									#EndIf
								End If
							End If
							bAddText = True
							#IfDef __USE_GTK__
								ChangeText *e->Key.string
							#Else
								ChangeText WChr(msg.wParam)
							#EndIf
					#IfDef __USE_GTK__
						ElseIf Asc(*e->Key.string) = 26 Then
					#Else
						ElseIf msg.wParam = 26 Then
					#EndIf
							Undo
					#IfDef __USE_GTK__
						ElseIf Asc(*e->Key.string) = 25 Then
					#Else
						ElseIf msg.wParam = 25 Then
					#EndIf
							Redo
					#IfDef __USE_GTK__
						ElseIf Asc(*e->Key.string) = 24 Then
					#Else
						ElseIf msg.wParam = 24 Then
					#EndIf
							CutToClipBoard
					#IfDef __USE_GTK__
						ElseIf Asc(*e->Key.string) = 3 Then
					#Else
						ElseIf msg.wParam = 3 Then
					#EndIf
							CopyToClipBoard
					#IfDef __USE_GTK__
						ElseIf Asc(*e->Key.string) = 22 Then
					#Else
						ElseIf msg.wParam = 22 Then
					#EndIf
							PasteFromClipBoard
					#IfDef __USE_GTK__
						ElseIf Asc(*e->Key.string) = 127 Then
					#Else
						ElseIf msg.wParam = 127 Then
					#EndIf
							WordLeft
							ChangeText "", 0, "Ortdagi so`z o`chirildi"
						End If
					End Select
		#IfDef __USE_GTK__
				End Select
			Case GDK_KEY_RELEASE
		#Else
			Case WM_KEYUP
		#EndIf
		#IfDef __USE_GTK__
			Case GDK_2BUTTON_PRESS ', GDK_DOUBLE_BUTTON_PRESS
		#Else
			Case WM_LBUTTONDBLCLK
		#EndIf
			#IfDef __USE_GTK__
				FSelEndLine = LineIndexFromPoint(e->button.x, e->button.y)
				If InCollapseRect(FSelEndLine, e->button.x, e->button.y) Then
			#Else
				FSelEndLine = LineIndexFromPoint(msg.lParamLo, msg.lParamHi)
				If InCollapseRect(FSelEndLine, msg.lParamLo, msg.lParamHi) Then
			#EndIf
				Else
				#IfDef __USE_GTK__
					FSelEndChar = CharIndexFromPoint(e->button.x, e->button.y)
				#Else
					FSelEndChar = CharIndexFromPoint(msg.lParamLo, msg.lParamHi)
				#EndIf
					If Cint(Not bShifted) And Cint(FSelEndLine <> FSelStartLine Or FSelEndChar <> FSelStartChar) Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					Else
						If Not bShifted Then
							WordLeft
							FSelStartLine = FSelEndLine
							FSelStartChar = FSelEndChar
							'FSelEndChar = FSelEndChar + 1
							WordRight
						End If
					End If
					ScrollToCaret
				End If
		#IfDef __USE_GTK__
			Case GDK_BUTTON_PRESS
				gtk_widget_grab_focus(widget)
				If e->button.button - 1 <> 0 Then Exit Select
		#Else
			Case WM_LBUTTONDOWN
		#EndIf
				DownButton = 0
			#IfDef __USE_GTK__
				FSelEndLine = LineIndexFromPoint(e->button.x, e->button.y)
				If InCollapseRect(FSelEndLine, e->button.x, e->button.y) Then
			#Else
				FSelEndLine = LineIndexFromPoint(msg.lParamLo, msg.lParamHi)
				If InCollapseRect(FSelEndLine, msg.lParamLo, msg.lParamHi) Then
			#EndIf
					FSelStartLine = FSelEndLine
					FSelEndLine = FSelEndLine
					FSelStartChar = 0
					FSelEndChar = 0
					FECLine = FLines.Items[FSelEndLine]
					ChangeCollapseState FSelEndLine, Not FECLine->Collapsed
					ScrollToCaret
				Else
				#IfDef __USE_GTK__
					FSelEndChar = CharIndexFromPoint(e->button.x, e->button.y)
				#Else
					FSelEndChar = CharIndexFromPoint(msg.lParamLo, msg.lParamHi)
				#EndIf
					If Not bShifted Then
						FSelStartLine = FSelEndLine
						FSelStartChar = FSelEndChar
					End If
				#IfDef __USE_GTK__
					If e->button.x < LeftMargin Then
				#Else
					If msg.lParamLo < LeftMargin Then
				#EndIf
						FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
					End If
					If Not Focused Then This.SetFocus
					ScrollToCaret
				#IfNDef __USE_GTK__
					SetCapture FHandle
				#EndIf
				End If
		#IfDef __USE_GTK__
			Case GDK_KEY_RELEASE
		#Else
			Case WM_LBUTTONUP
				ReleaseCapture
		#EndIf
				DownButton = -1
		#IfDef __USE_GTK__
			Case GDK_MOTION_NOTIFY
		#Else
			Case WM_MOUSEMOVE
		#EndIf
				#IfDef __USE_GTK__
					Dim As Integer i = LineIndexFromPoint(e->button.x, e->button.y)
					If InCollapseRect(i, e->button.x, e->button.y) Then
						gdk_window_set_cursor(win, gdkCursorHand)
					Else
						gdk_window_set_cursor(win, gdkCursorIBeam)
					End If
				#EndIf
				If DownButton = 0 Then
				#IfDef __USE_GTK__
					FSelEndLine = LineIndexFromPoint(IIF(e->button.x > 60000, 0, e->button.x), IIF(e->button.y > 60000, 0, e->button.y))
					FSelEndChar = CharIndexFromPoint(IIF(e->button.x > 60000, 0, e->button.x), IIF(e->button.y > 60000, 0, e->button.y))
					If e->button.x < LeftMargin Then
				#Else
					FSelEndLine = LineIndexFromPoint(IIF(msg.lParamLo > 60000, 0, msg.lParamLo), IIF(msg.lParamHi > 60000, 0, msg.lParamHi))
					FSelEndChar = CharIndexFromPoint(IIF(msg.lParamLo > 60000, 0, msg.lParamLo), IIF(msg.lParamHi > 60000, 0, msg.lParamHi))
					If msg.lParamLo < LeftMargin Then
				#EndIf
						If FSelEndLine < FSelStartLine Then
							'FSelStart = LineFromCharIndex(FSelStart)
							'FSelStart = CharIndexFromLine(FSelStart) + LineLength(FSelStart)
							FSelStartChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelStartLine))->Text)
						Else
							FSelEndChar = Len(*Cast(EditControlLine Ptr, FLines.Item(FSelEndLine))->Text)
						End If
					End If
					ScrollToCaret
				End If
		#IfNDef __USE_GTK__
			Case WM_CTLCOLORMSGBOX To WM_CTLCOLORSTATIC: PaintControl ': Message.Result = -1
			Case WM_ERASEBKGND
				PaintControl
				ShowCaretPos False: msg.Result = -1
		#EndIf
		#IfDef __USE_GTK__
			Case GDK_EXPOSE
		#Else
			Case WM_PAINT
		#EndIf
				PaintControl
				ShowCaretPos False
			Case Else
		End Select
        Base.ProcessMessage(msg)
    End Sub
    
    Sub EditControl.HandleIsAllocated(ByRef Sender As Control) '...'
        If Sender.Child Then
            With QEditControl(Sender.Child)
                .Canvas.Font = .Font
                'Var s1Pos = 100, s1Min = 1, s1Max = 100
                    'SetScrollRange(.FHandle, SB_CTL, s1Min, s1Max, TRUE)
                    'SetScrollPos(.FHandle, SB_CTL, s1Pos, TRUE)
            End With
        End If
    End Sub
    
    #IfDef __USE_GTK__
	    Function EditControl_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
			Dim As EditControl Ptr ec = Cast(Any Ptr, data1)
			If ec->cr = 0 Then
				ec->cr = cr
				cairo_select_font_face(cr, "Noto Mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
				cairo_set_font_size(cr, 11)
				
				Dim As PangoRectangle extend
				pango_layout_set_text(ec->layout, ToUTF8("|"), 1)
				pango_cairo_update_layout(cr, ec->layout)
				#ifdef PANGO_VERSION
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(ec->layout, 0)
				#else
					Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(ec->layout, 0)
				#endif
				pango_layout_line_get_pixel_extents(pl, NULL, @extend)
				ec->dwCharX = extend.width
				ec->dwCharY = extend.height
		
				'Dim extend As cairo_text_extents_t 
				'cairo_text_extents (cr, "|", @extend)
				
				ec->LeftMargin = 50
				
				ec->pdisplay = gtk_widget_get_display(widget)
				ec->gdkCursorIBeam = gdk_cursor_new_for_display(ec->pdisplay, GDK_XTERM)
				ec->gdkCursorHand = gdk_cursor_new_from_name(ec->pdisplay, "pointer")
				#IfDef __USE_GTK3__
					ec->win = gtk_layout_get_bin_window(gtk_layout(widget))
				#EndIf
				gdk_window_set_cursor(ec->win, ec->gdkCursorIBeam)
				
				ec->ShowCaretPos False
				ec->HScrollPos = 0
				ec->VScrollPos = 0
			End If
			#IfDef __USE_GTK3__
			#Else
				ec->cr = cr
			#EndIf
			'If ec->bChanged Then
				'ec->bChanged = False
				#IfDef __USE_GTK3__
					Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
				#Else
					Dim As Integer AllocatedWidth = widget->allocation.width, AllocatedHeight = widget->allocation.height
				#EndIf
					If AllocatedWidth <> ec->dwClientX Or AllocatedHeight <> ec->dwClientY Then
						ec->dwClientX = AllocatedWidth
						ec->dwClientY = AllocatedHeight
												
						#IfDef __USE_GTK3__
							gtk_layout_move(gtk_layout(ec->widget), ec->scrollbarv, ec->dwClientX - ec->verticalScrollBarWidth, 0)
							gtk_widget_set_size_request(ec->scrollbarv, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
							gtk_layout_move(gtk_layout(ec->widget), ec->scrollbarh, 0, ec->dwClientY - ec->horizontalScrollBarHeight)
							gtk_widget_set_size_request(ec->scrollbarh, ec->dwClientX - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
						#Else
							gtk_layout_move(gtk_layout(ec->widget), ec->scrollbarv, ec->dwClientX - ec->verticalScrollBarWidth + 2, 0)
							gtk_widget_set_size_request(ec->scrollbarv, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
							gtk_layout_move(gtk_layout(ec->widget), ec->scrollbarh, 0, ec->dwClientY - ec->horizontalScrollBarHeight + 2)
							gtk_widget_set_size_request(ec->scrollbarh, ec->dwClientX - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
						#EndIf
						'Ctrl->RequestAlign AllocatedWidth, AllocatedHeight
						ec->SetScrollsInfo
					End If
				
				ec->PaintControlPriv
				
			 return FALSE
	    End Function
	    
	    Function EditControl_OnExposeEvent(widget As GtkWidget Ptr, event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
			Dim As EditControl Ptr ec = Cast(Any Ptr, data1)
			Dim As cairo_t Ptr cr = gdk_cairo_create(event->window)
			ec->win = event->window
			EditControl_OnDraw widget, cr, data1
			cairo_destroy(cr)
			return FALSE
	    End Function
	    
	    Sub EditControl_SizeAllocate(widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr)
			Dim As EditControl Ptr ec = Cast(Any Ptr, user_data)
		
		'	ec->PaintControl
		'	'gtk_fixed_move(gtk_fixed(ec->fixedwidget), ec->scrollbarv, ec->dwClientX - ec->verticalScrollBarWidth, 0)
		'	'gtk_widget_set_size_request(ec->scrollbarv, ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
		'	'gtk_fixed_move(gtk_fixed(ec->fixedwidget), ec->scrollbarh, 0, ec->dwClientY - ec->horizontalScrollBarHeight)
		'	'gtk_widget_set_size_request(ec->scrollbarh, ec->dwClientX - ec->verticalScrollBarWidth, ec->horizontalScrollBarHeight)
		'	'gtk_widget_set_size_request(ec->wText, ec->dwClientX - ec->verticalScrollBarWidth, ec->dwClientY - ec->horizontalScrollBarHeight)
		'	'Ctrl->RequestAlign
		'	'?Ctrl->ClassName
		End Sub
		
		Sub EditControl_ScrollValueChanged(widget As GtkAdjustment Ptr, user_data As Any Ptr)
			Dim As EditControl Ptr ec = Cast(Any Ptr, user_data)
			If widget = ec->adjustmentv Then
				ec->VScrollPos = gtk_adjustment_get_value(ec->adjustmentv)
			Else
				ec->HScrollPos = gtk_adjustment_get_value(ec->adjustmenth)
			End If
			#IfDef __USE_GTK3__
				ec->ShowCaretPos False
				ec->PaintControl
			#EndIf
		End Sub
			
	#EndIf
	
	Constructor EditControl
		Child       = @This
		#IfDef __USE_GTK__
			widget = gtk_layout_new(NULL, NULL)
			#IfDef __USE_GTK3__
				scontext = gtk_widget_get_style_context (widget)
			#EndIf
			'gtk_layout_set_size(gtk_layout(widget), 1000, 1000)
			'g_object_set (gtk_widget_get_settings(widget), "gtk-keynav-use-caret", true, NULL)
			'gtk_scrolled_window_set_policy(gtk_scrolled_window(widget), GTK_POLICY_EXTERNAL, GTK_POLICY_EXTERNAL)
			This.RegisterClass "EditControl", @This
			'gtk_container_add(GTK_CONTAINER(widget), fixedwidget)
			'EditControlObject = @This
			'wText = mycustomwidget_new()
			'gtk_widget_set_parent(wText, widget)
			'gtk_fixed_put(gtk_fixed(fixedwidget), wText, 0, 0)
			'gtk_widget_set_size_request(wText, 100, 100)
			'gtk_scrolled_window_set_policy(gtk_scrolled_window(widget), GTK_POLICY_EXTERNAL, GTK_POLICY_EXTERNAL)
			'gtk_widget_show(wText)
			'gtk_widget_set_events(wText, GDK_EXPOSURE_MASK)
			gtk_widget_set_can_focus(widget, True)
			'gtk_widget_set_focus_on_click(widget, True)
			'gtk_widget_set_events(widget, _
	         '            GDK_EXPOSURE_MASK Or _
	         '              GDK_SCROLL_MASK Or _
	          '             GDK_STRUCTURE_MASK Or _
	         '              GDK_KEY_PRESS_MASK Or _
	           '            GDK_KEY_RELEASE_MASK Or _
	         '              GDK_FOCUS_CHANGE_MASK Or _
	         '              GDK_LEAVE_NOTIFY_MASK Or _
	         '              GDK_BUTTON_PRESS_MASK Or _
	         '              GDK_BUTTON_RELEASE_MASK Or _
	         '              GDK_POINTER_MOTION_MASK Or _
	         '              GDK_POINTER_MOTION_HINT_MASK)
			gtk_widget_set_events(widget, _
	                      GDK_EXPOSURE_MASK Or _
	                       GDK_SCROLL_MASK Or _
	                       GDK_STRUCTURE_MASK Or _
	                       GDK_KEY_PRESS_MASK Or _
	                       GDK_KEY_RELEASE_MASK Or _
	                       GDK_FOCUS_CHANGE_MASK Or _
	                       GDK_LEAVE_NOTIFY_MASK Or _
	                       GDK_BUTTON_PRESS_MASK Or _
	                       GDK_BUTTON_RELEASE_MASK Or _
	                       GDK_POINTER_MOTION_MASK Or _
	                       GDK_POINTER_MOTION_HINT_MASK)
			g_signal_connect(widget, "size-allocate", G_CALLBACK(@EditControl_SizeAllocate), @This)
			'g_signal_connect(widget, "event", G_CALLBACK(@EventProc), @This)
			'g_signal_connect(widget, "event-after", G_CALLBACK(@EventAfterProc), @This)
			'g_signal_connect(wText, "draw", G_CALLBACK(@EditControl_OnDraw), @This)
			#IfDef __USE_GTK3__
				g_signal_connect(widget, "draw", G_CALLBACK(@EditControl_OnDraw), @This)
			#Else
				g_signal_connect(widget, "expose-event", G_CALLBACK(@EditControl_OnExposeEvent), @This)
			#EndIf
			pcontext = gtk_widget_create_pango_context(widget)
			layout = pango_layout_new(pcontext)
			Dim As PangoFontDescription Ptr desc
			desc = pango_font_description_from_string ("Noto Mono 11")
			pango_layout_set_font_description (layout, desc)
			pango_font_description_free (desc)

			g_object_get(G_OBJECT(gtk_settings_get_default()), "gtk-cursor-blink-time", @BlinkTime, NULL)		
			BlinkTime = BlinkTime / 1.75
			'gdk_threads_add_timeout(BlinkTime, @Blink_cb, @This)
			adjustmentv = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 201.0, 1.0, 20.0, 20.0))
			#IfDef __USE_GTK3__
				scrollbarv = gtk_scrollbar_new(GTK_ORIENTATION_VERTICAL, GTK_ADJUSTMENT(adjustmentv))
			#Else
				scrollbarv = gtk_vscrollbar_new(GTK_ADJUSTMENT(adjustmentv))
			#EndIf
			gtk_widget_set_can_focus(scrollbarv, FALSE)
			g_signal_connect(adjustmentv, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarv, widget)
			gtk_layout_put(gtk_layout(widget), scrollbarv, 0, 0)
			gtk_widget_show(scrollbarv)
			adjustmenth = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, 0.0, 101.0, 1.0, 20.0, 20.0))
			#IfDef __USE_GTK3__
				scrollbarh = gtk_scrollbar_new(GTK_ORIENTATION_HORIZONTAL, GTK_ADJUSTMENT(adjustmenth))
			#Else
				scrollbarh = gtk_hscrollbar_new(GTK_ADJUSTMENT(adjustmenth))
			#EndIf
			gtk_widget_set_can_focus(scrollbarh, FALSE)
			g_signal_connect(adjustmenth, "value_changed", G_CALLBACK(@EditControl_ScrollValueChanged), @This)
			'gtk_widget_set_parent(scrollbarh, widget)
			gtk_layout_put(gtk_layout(widget), scrollbarh, 0, 0)
			gtk_widget_show(scrollbarh)
			Dim As GtkRequisition vminimum, hminimum, vrequisition, hrequisition
			#IfDef __USE_GTK3__
				gtk_widget_get_preferred_size(scrollbarv, @vminimum, @vrequisition)
				gtk_widget_get_preferred_size(scrollbarh, @hminimum, @hrequisition)
			#Else
				gtk_widget_size_request(scrollbarv, @vrequisition)
				gtk_widget_size_request(scrollbarh, @hrequisition)
			#EndIf
			Var minVScrollBarHeight = hminimum.height
			Var minHScrollBarWidth = vminimum.width
			verticalScrollBarWidth = vrequisition.width
			horizontalScrollBarHeight = hrequisition.height
			'layoutwidget = widget
			'gtk_widget_grab_focus(wText)
		#Else
			OnHandleIsAllocated = @HandleIsAllocated
        #EndIf
        dwCharY = 5
		'MultiLine = True
        'ChildProc   = @WndProc
        #IfNDef __USE_GTK__
			ExStyle     = WS_EX_CLIENTEDGE
			Style       = WS_CHILD Or WS_TABSTOP Or ES_WANTRETURN Or WS_HSCROLL Or WS_VSCROLL Or CS_DBLCLKS
        #EndIf
        This.Width       = 121
        Height          = 121
        #IfNDef __USE_GTK__
			This.Cursor = New My.Sys.Drawing.Cursor
			*This.Cursor = LoadCursor(NULL, IDC_IBEAM)
        #ENdIf
        This.BackColor       = clWhite
        WLet FClassName, "EditControl"
        #IfNDef __USE_GTK__
			This.RegisterClass "EditControl", ""
        #EndIf
        Canvas.Ctrl = @This
        crRArrow.LoadFromResourceName("Select")
        crHand.LoadFromResourceName("Hand")
        'Text = ""
        #IfDef __USE_GTK__
        	winIntellisense = gtk_window_new(GTK_WINDOW_POPUP)
        	gtk_scrolled_window_set_policy(gtk_scrolled_window(lvIntellisense.scrolledwidget), GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC)
        	gtk_container_add(gtk_container(winIntellisense), lvIntellisense.scrolledwidget)
        	gtk_window_set_transient_for(gtk_window(winIntellisense), gtk_window(frmMain.widget))
        	gtk_window_resize(gtk_window(winIntellisense), 250, 7 * 22)
        	lvIntellisense.Columns.Add "AutoComplete"
        	lvIntellisense.ColumnHeaderHidden = True
        	lvIntellisense.SingleClickActivate = True
        	'gtk_widget_show(scrollwinIntellisense)
        	'gtk_widget_show(lvIntellisense.widget)
        	'gtk_widget_show_all(winIntellisense)
        #Else
	        pnlIntellisense.SetBounds 0, -50, 250, 0
	        'cboIntellisense.Visible = False
	        'cboIntellisense.SetBounds 0, -50, 250, 0
	        cboIntellisense.Left = 0
	        cboIntellisense.Top = -22
	        cboIntellisense.Width = 250
	        cboIntellisense.Height = 7 * 22
	        pnlIntellisense.Add @cboIntellisense
	        This.Add @pnlIntellisense
	    #EndIf
        Var item = New EditControlLine
        WLet item->Text, ""
        FLines.Add item
        bOldCommented = True
        ChangeText "", 0, "Bo`sh"
        'ClearUndo
        'Brush.Color = clWindowColor
    End Constructor

    Destructor EditControl
        'If FText Then Deallocate FText
        _ClearHistory
        For i As Integer = FLines.Count - 1 To 0 Step -1
            Delete Cast(EditControlLine Ptr, FLines.Items[i])
        Next i
        #IfDef __USE_GTK__
        	lvIntellisense.ListItems.Clear
        #Else
        	cboIntellisense.Items.Clear
        #EndIf
        WDeallocate FLine
        WDeallocate FLineLeft
        WDeallocate FLineRight
        WDeallocate FLineTemp
        WDeallocate FLineSpace
        #IfNDef __USE_GTK__
			DeleteDc hd
		#EndIf
    End Destructor
End Namespace
