'#########################################################
'#  EditControl.bi                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Panel.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/Canvas.bi"
#include once "mff/WStringList.bi"
#include once "mff/Clipboard.bi"
#include once "mff/Application.bi"
#include once "mff/ListView.bi"
#include once "mff/ToolTips.bi"
'#include once "Main.bi"

Enum KeyWordsCase
	OriginalCase
	LowerCase
	UpperCase
End Enum

Common Shared As Boolean AutoIndentation
Common Shared As Boolean ShowSpaces
Common Shared As Integer TabWidth
Common Shared As Integer HistoryLimit
Common Shared As Integer IntellisenseLimit
Common Shared As Integer TabAsSpaces
Common Shared As KeyWordsCase ChoosedKeyWordsCase
Common Shared As Integer ChoosedTabStyle
Common Shared As Boolean SyntaxHighlightingIdentifiers
Common Shared As Boolean ChangeIdentifiersCase
Common Shared As Boolean ChangeKeyWordsCase
Common Shared As Boolean AddSpacesToOperators
Common Shared As WStringOrStringList Ptr pkeywordsAsm, pkeywords0, pkeywords1, pkeywords2 ', pkeywords3

Type ECColorScheme
	As Long ForegroundOption, BackgroundOption, FrameOption, IndicatorOption
	As Long Foreground, Background, Frame, Indicator
	As Double ForegroundRed, ForegroundGreen, ForegroundBlue, BackgroundRed, BackgroundGreen, BackgroundBlue, FrameRed, FrameGreen, FrameBlue, IndicatorRed, IndicatorGreen, IndicatorBlue
	As Boolean Bold, Italic, Underline
End Type

Common Shared As ECColorScheme Bookmarks, Breakpoints, Comments, CurrentBrackets, CurrentLine, CurrentWord, ExecutionLine, FoldLines, Identifiers, IndicatorLines, Keywords(Any), LineNumbers, NormalText, Numbers, RealNumbers, Selection, SpaceIdentifiers, Strings
Common Shared As ECColorScheme ColorOperators, ColorProperties, ColorComps, ColorGlobalNamespaces, ColorGlobalTypes, ColorGlobalEnums, ColorEnumMembers, ColorConstants, ColorGlobalFunctions, ColorLineLabels, ColorLocalVariables, ColorSharedVariables, ColorCommonVariables, ColorByRefParameters, ColorByValParameters, ColorFields, ColorDefines, ColorMacros, ColorSubs
Common Shared As Integer EditorFontSize
Common Shared As WString Ptr EditorFontName
Common Shared As WString Ptr CurrentTheme

Type Construction
	Name0 As String * 50
	Name01 As String * 50
	Name02 As String * 50
	Name03 As String * 50
	Name04 As String * 50
	Name05 As String * 50
	Name06 As String * 50
	Name07 As String * 50
	Name08 As String * 50
	Name1 As String * 50
	Name2 As String * 50
	Name3 As String * 50
	EndName As String * 50
	Exception As String * 50
	Collapsible As Boolean
	Accessible As Boolean
End Type

Namespace My.Sys.Forms
	#define QEditControl(__Ptr__) *Cast(EditControl Ptr,__Ptr__)
	
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
	
	Type TypeElement
		Name As String
		DisplayName As String
		EnumTypeName As String
		TypeName As String
		Value As UString
		ElementType As String
		Parameters As UString
		Comment As UString
		FileName As UString
		IncludeFile As UString
		TypeIsPointer As Boolean
		TypeProcedure As Boolean
		Declaration As Boolean
		Locals As Integer
		StartLine As Integer
		EndLine As Integer
		StartChar As Integer
		EndChar As Integer
		ControlType As Integer
		Find As Boolean
		Used As Boolean
		Parent As TypeElement Ptr
		Tag As Any Ptr
		Elements As WStringOrStringList
		Declare Destructor
	End Type
	
	Type ConstructionBlock
		Construction As TypeElement Ptr
		ConstructionIndex As Integer
		ConstructionPart As Integer
		InConstructionBlock As ConstructionBlock Ptr
		Elements As WStringOrStringList
	End Type
	
	Type EditControlLine
		Bookmark As Boolean
		Breakpoint As Boolean
		Collapsed As Boolean
		Collapsible As Boolean
		CommentIndex As Integer
		ConstructionIndex As Integer
		ConstructionPart As Integer
		InAsm As Boolean
		InCollapse As Boolean
		InConstruction As TypeElement Ptr
		InConstructionBlock As ConstructionBlock Ptr
		InConstructionIndex As Integer
		InConstructionPart As Integer
		InWithConstruction As Integer
		Multiline As Boolean
		FileList As WStringList Ptr
		FileListLines As IntegerList Ptr
		Text As WString Ptr = 0
		Args As List
		Ends As IntegerList
		EndsCompleted As Boolean
		Visible As Boolean
		Declare Constructor
		Declare Destructor
	End Type
	
	Type GlobalTypeElements
		Namespaces As WStringOrStringList
		Types As WStringOrStringList
		Enums As WStringOrStringList
		Defines As WStringOrStringList
		Functions As WStringOrStringList
		TypeProcedures As WStringOrStringList
		Args As WStringOrStringList
		Declare Constructor
	End Type
	
	Dim Shared Globals As GlobalTypeElements
	
	Type EditControlContent
		Dim WithOldI As Integer = -1
		Dim WithOldTypeName As String
		Dim WithTeEnumOld As TypeElement Ptr
		Dim iPos As Integer
		Dim As Boolean CStyle
		DateChanged As Double
		FileName As UString
		FileLists As List
		FileListsLines As List
		Includes As WStringList
		IncludeLines As IntegerList
		CheckedFiles As WStringList
		ConstructionBlocks As List
		ExternalFiles As WStringList
		ExternalFileLines As IntegerList
		ExternalIncludes As WStringList
		ExternalIncludesLoaded As Boolean
		OldIncludes As WStringList
		OldIncludeLines As IntegerList
		Namespaces As WStringOrStringList
		Types As WStringOrStringList
		Enums As WStringOrStringList
		Defines As WStringOrStringList
		Functions As WStringOrStringList
		Procedures As WStringOrStringList
		TypeProcedures As WStringOrStringList
		Args As WStringOrStringList
		LineLabels As WStringOrStringList
		Globals As GlobalTypeElements Ptr
		Lines As List
		Tag As Any Ptr
		Declare Function ContainsIn(ByRef ClassName As String, ByRef ItemText As String, pList As WStringOrStringList Ptr, pFiles As WStringList Ptr, pFileLines As IntegerList Ptr, bLocal As Boolean = False, bAll As Boolean = False, TypesOnly As Boolean = False, ByRef te As TypeElement Ptr = 0, LineIndex As Integer = -1) As Boolean
		Declare Function IndexOfInListFiles(pList As WStringOrStringList Ptr, ByRef Matn As String, Files As WStringList Ptr, FileLines As IntegerList Ptr) As Integer
		Declare Function ContainsInListFiles(pList As WStringOrStringList Ptr, ByRef Matn As String, ByRef Index As Integer, Files As WStringList Ptr, FileLines As IntegerList Ptr) As Boolean
		Declare Function GetTypeFromValue(Value As String, iSelEndLine As Integer) As String
		Declare Function GetLeftArgTypeName(iSelEndLine As Integer, iSelEndChar As Integer, ByRef teEnum As TypeElement Ptr = 0, ByRef teEnumOld As TypeElement Ptr = 0, ByRef OldTypeName As String = "", ByRef bTypes As Boolean = False, ByRef bWithoutWith As Boolean = False) As String
		Declare Function GetConstruction(ByRef sLine As WString, ByRef iType As Integer = 0, OldCommentIndex As Integer = 0, InAsm As Boolean = False) As Integer
		Declare Constructor
	End Type
	
	Type EditControl Extends Control
	Private:
		Dim FHistory As List
		Dim FVisibleLinesCount As Integer
		Dim FECLine As EditControlLine Ptr
		Dim FECLineNext As EditControlLine Ptr
		Dim bAddText As Boolean
		Dim bOldCommented As Boolean
		Dim curHistory As Integer
		Dim crRArrow As My.Sys.Drawing.Cursor
		Dim crHand_ As My.Sys.Drawing.Cursor
		Dim crScroll As My.Sys.Drawing.Cursor
		Dim crScrollLeft As My.Sys.Drawing.Cursor
		Dim crScrollDown As My.Sys.Drawing.Cursor
		Dim crScrollRight As My.Sys.Drawing.Cursor
		Dim crScrollUp As My.Sys.Drawing.Cursor
		Dim crScrollLeftRight As My.Sys.Drawing.Cursor
		Dim crScrollUpDown As My.Sys.Drawing.Cursor
		Dim FLine As WString Ptr
		Dim FLineLeft As WString Ptr
		Dim FLineRight As WString Ptr
		Dim FLineTemp As WString Ptr
		Dim FLineTab As WString Ptr
		Dim FLineSpace As WString Ptr
		Dim FHintDropDown As WString Ptr
		Dim FHintWord As WString Ptr
		Dim HScrollMaxLeft As Integer
		Dim HScrollMaxRight As Integer
		Dim VScrollMaxTop As Integer
		Dim VScrollMaxBottom As Integer
		Dim HScrollVCLeft As Integer
		Dim HScrollVCRight As Integer
		Dim VScrollVCTop As Integer
		Dim VScrollVCBottom As Integer
		Dim nCaretPosX As Integer = 0 ' горизонтальная координата каретки
		Dim nCaretPosY As Integer = 0 ' вертикальная координата каретки
		Dim WithOldI As Integer = -1
		Dim WithOldTypeName As String
		Dim WithTeEnumOld As TypeElement Ptr
		Dim iPos As Integer
		Dim iPP As Integer = 0
		Dim jPos As Integer
		Dim jPP As Integer = 0
		Dim iPPos As Integer
		Dim As Integer iCount, BracketsStart, BracketsStartLine, BracketsEnd, BracketsEndLine, iStartBS, iStartBE, OldBracketsStartLine, OldBracketsEndLine
		Dim As String BracketsLine, Symb, SymbOpenBrackets, SymbCloseBrackets, OpenBrackets = "([{", CloseBrackets = ")]}"
		Dim As Boolean bFinded
		Dim As String CurWord, OldCurWord
		Dim As Integer iTemp
		Dim As Integer OldPaintedVScrollPos(1), OldPaintedHScrollPos(1)
		#ifndef __USE_GTK__
			Dim As DWORD dwTemp
			Dim As POINTS psPoints
			Dim As ..Point poPoint
		#endif
		'Dim FListItems As WStringList
		Dim As Integer lParamLo, lParamHi
		Dim FCurLine As Integer = 0
		Dim FSelStartLine As Integer = 0
		Dim FSelEndLine As Integer = 0
		Dim FSelStartChar As Integer = 0
		Dim FSelEndChar As Integer = 0
		Dim FOldSelStartLine As Integer = 0
		Dim FOldSelEndLine As Integer = 0
		Dim FOldSelStartChar As Integer = 0
		Dim FOldSelEndChar As Integer = 0
		Dim iOldSelStartLine As Integer = 0
		Dim iOldSelEndLine As Integer = 0
		Dim vlc1 As Integer
		Dim sChar As WString * 2
		'Dim FSelStart As Integer
		'Dim FSelLength As Integer
		'Dim FSelEnd As Integer = 0   ' номер текущего символа
		Dim FCurLineCharIdx As Integer = 0   ' номер текущего символа
		Dim OldnCaretPosX As Integer
		Dim OldCharIndex As Integer
		Dim OldLine As Integer
		Dim OldChar As Integer
		Dim As Integer dwLineHeight   ' высота строки
		Dim As Integer HCaretPos, VCaretPos
		#ifdef __USE_GTK__
			Dim As GtkTooltip Ptr tooltip
		#else
			Dim As HDC hd
			Dim As HDC bufDC
			Dim As HBITMAP bufBMP
			Dim As TEXTMETRIC tm
			Dim As HWND hwndTT, hwndTTDropDown
			Dim As ToolTips TT, TTDropDown
		#endif
		Dim As ..Rect rc
		#ifndef __USE_GTK__
			Dim sz As ..Size
			Dim As SCROLLINFO si
		#endif
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
		Dim r As Integer
		Dim q As Integer
		Dim t As Integer
		Dim u As Integer
		Dim z As Integer
		Dim ii As Integer
		Dim jj As Integer
		Dim sc As ECColorScheme Ptr
		Dim ss As Integer
		Dim p1 As Integer
		Dim MaxWidth As Integer
		Dim lText As Integer
		Dim lLen As Integer
		Dim bQ As Boolean
		Dim vlc As Integer
		Dim As Integer CurrentFontSize
		Dim As WString Ptr CurrentFontName
		Dim As Boolean bInIncludeFileRectOld
		Dim As Boolean bScrollStarted
		Dim As Boolean bInMiddleScroll
		Dim As Integer MButtonX, MButtonY
		Dim As Boolean bInDivideX, bDividedX
		Dim As Boolean bInDivideY, bDividedY
		Dim As Integer iDivideY, iDividedY
		Dim As Integer iDivideX, iDividedX
		Dim As Integer iOldDivideY, iOldDividedY
		Dim As Integer iOldDivideX, iOldDividedX
		Dim As Boolean bOldDividedX, bOldDividedY
		Dim As Integer iCursorLine
		Dim As Integer iCursorLineOld
		Dim As Integer IzohBoshi, QavsBoshi, MatnBoshi
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As String KeyWord, Matn, MatnLCase, OldMatnLCase, MatnLCaseWithoutOldSymbol, MatnWithoutOldSymbol
		Dim As Boolean WithOldSymbol, bTypeAs, bInAsm
		Dim As Integer OldPos, OldLinesCount
		Dim pkeywords As WStringOrStringList Ptr
		Dim LinePrinted As Boolean
		'Dim As Boolean ChangeCase
		Dim CollapseIndex As Integer
		Dim OldCollapseIndex As Integer
		Declare Sub FontSettings
		Declare Function MaxLineWidth() As Integer
		Declare Sub PaintText(CodePane As Integer, iLine As Integer, ByRef s As WString, iStart As Integer, iEnd As Integer, ByRef Colors As ECColorScheme, ByRef addit As WString = "", Bold As Boolean = False, Italic As Boolean = False, Underline As Boolean = False)
		Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
		Declare Sub SplitLines
		Declare Sub WordLeft
		Declare Sub WordRight
	Protected:
		Declare Function GetOldCharIndex() As Integer
		Declare Function GetCharIndexFromOld() As Integer
		Declare Function CountOfVisibleLines() As Integer
		Declare Sub CalculateLeftMargin
		Declare Sub _FillHistory(ByRef item As EditControlHistory Ptr, ByRef Comment As WString)
		Declare Sub _LoadFromHistory(ByRef item As EditControlHistory Ptr, bToBack As Boolean, ByRef oldItem As EditControlHistory Ptr, bWithoutPaint As Boolean = False)
		Declare Sub _ClearHistory(Index As Integer = 0)
		Declare Sub ChangeSelPos(bLeft As Boolean)
		Declare Sub ChangePos(CharTo As Integer)
		Declare Function InStartOfLine(i As Integer, X As Integer, Y As Integer) As Boolean
		Declare Function InCollapseRect(i As Integer, X As Integer, Y As Integer) As Boolean
		Declare Function InIncludeFileRect(i As Integer, X As Integer, Y As Integer) As Boolean
		Declare Sub ProcessMessage(ByRef MSG As Message)
		#ifdef __USE_GTK__
			Declare Static Function Blink_cb(user_data As gpointer) As gboolean
			Declare Static Function EditControl_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
			Declare Static Function EditControl_OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
		#else
			Dim lXOffset As Long
			Dim lYOffset As Long
			Dim tP As ..Point
			Dim lVertOffset As Long
			Dim lHorzOffset As Long
			Dim As ..Point m_tP
			Declare Static Sub EC_TimerProc(HWND As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
			Declare Sub SetDark(Value As Boolean)
		#endif
		Declare Function deltaToScrollAmount(lDelta As Integer) As Integer
		Declare Sub MiddleScroll
	Public:
		Content As EditControlContent
		'FileLists As List
		'FileListsLines As List
		'Includes As WStringList
		'IncludeLines As IntegerList
		'ExternalFiles As WStringList
		'ExternalFileLines As IntegerList
		'ExternalIncludes As WStringList
		'Namespaces As WStringOrStringList
		'Types As WStringOrStringList
		'Enums As WStringOrStringList
		'Functions As WStringOrStringList
		'Procedures As WStringOrStringList
		'FunctionsOthers As WStringOrStringList
		'Args As WStringOrStringList
		'LineLabels As WStringOrStringList
		Dim As Boolean bInIncludeFileRect
		Declare Function CharType(ByRef ch As WString) As Integer
		#ifdef __USE_GTK__
			Declare Static Function ActivateLink(Label As GtkLabel Ptr, uri As gchar Ptr, user_data As gpointer) As Boolean
			Dim As cairo_t Ptr cr
			Dim As GtkWidget Ptr wText
			Dim As PangoContext Ptr PCONTEXT
			Dim As PangoLayout Ptr layout
			Dim As GdkDisplay Ptr pdisplay
			Dim As GdkCursor Ptr gdkCursorIBeam
			Dim As GdkCursor Ptr gdkCursorHand
			Dim As GdkCursor Ptr gdkCursorSIZEWE
			Dim As GdkCursor Ptr gdkCursorSIZENS
			Dim As GdkCursor Ptr gdkCursorARROW
			#ifdef __USE_GTK3__
				Dim As GtkStyleContext Ptr scontext
			#endif
			Dim As GtkWidget Ptr scrollbarvTop
			Dim As GtkWidget Ptr scrollbarvBottom
			Dim As GtkWidget Ptr scrollbarhLeft
			Dim As GtkWidget Ptr scrollbarhRight
			Dim As GtkAdjustment Ptr adjustmentvTop
			Dim As GtkAdjustment Ptr adjustmentvBottom
			Dim As GtkAdjustment Ptr adjustmenthLeft
			Dim As GtkAdjustment Ptr adjustmenthRight
			Dim As GdkWindow Ptr win
			Dim As GtkWidget Ptr winIntellisense
			Dim As GtkWidget Ptr scrollwinIntellisense
			Dim As GtkWidget Ptr winDropDownTooltip
			Dim As GtkWidget Ptr winTooltip
			Dim As Integer verticalScrollBarWidth
			Dim As Integer horizontalScrollBarHeight
			Dim As Boolean CaretOn
			Dim As Integer BlinkTime
			Dim As Boolean InFocus
			Dim As Boolean bChanged
		#else
			Dim As HWND sbScrollBarvTop
			Dim As HWND sbScrollBarvBottom
			Dim As HWND sbScrollBarhLeft
			Dim As HWND sbScrollBarhRight
		#endif
		Dim As TypeElement Ptr DropDownTypeElement
		Dim As Integer ActiveCodePane
		Dim As Integer dwClientX, OlddwClientX    ' ширина клиентской области
		Dim As Integer dwClientY, OlddwClientY    ' Высота клиентской области
		Modified As Boolean
		WithHistory As Boolean
		FileDropDown As Boolean
		'FLines As List
		'VisibleLines As List
		CurExecutedLine As Integer = -1
		OldExecutedLine As Integer = -1
		FocusedItemIndex As Integer
		LastItemIndex As Integer
		Dim As Integer m_lLastVertTime, m_lLastHorzTime
		Dim As Single dwCharX
		Dim As Single dwCharY
		Dim As Boolean SyntaxEdit
		Dim LeftMargin As Integer
		Dim HScrollPosLeft As Integer
		Dim HScrollPosRight As Integer
		Dim VScrollPosTop As Integer
		Dim VScrollPosBottom As Integer
		#ifdef __USE_GTK__
			lvIntellisense As ListView
			lblTooltip As GtkWidget Ptr
			lblDropDownTooltip As GtkWidget Ptr
		#else
			cboIntellisense As ComboBoxEx
			pnlIntellisense As Panel
		#endif
		ChangingStarted As Boolean
		DropDownPath As WString Ptr
		DropDownShowed As Boolean
		DropDownChar As Integer
		DropDownToolTipShowed As Boolean
		DropDownToolTipItemIndex As Integer
		ToolTipShowed As Boolean
		ToolTipChar As Integer
		Declare Sub SetScrollsInfo()
		Declare Sub ShowCaretPos(Scroll As Boolean = False)
		Declare Function TextWidth(ByRef sText As WString) As Integer
		Declare Sub ShowDropDownAt(iSelEndLine As Integer, iSelEndChar As Integer)
		Declare Sub ShowDropDownToolTipAt(X As Integer, Y As Integer)
		Declare Sub ShowToolTipAt(iSelEndLine As Integer, iSelEndChar As Integer)
		Declare Sub UpdateToolTip
		Declare Sub UpdateDropDownToolTip
		Declare Sub CloseDropDownToolTip()
		Declare Sub CloseDropDown()
		Declare Sub CloseToolTip()
		Declare Sub FormatCode(WithoutUpdate As Boolean = False)
		Declare Sub UnformatCode(WithoutUpdate As Boolean = False)
		Declare Function GetTabbedLength(ByRef SourceText As WString) As Integer
		Declare Function GetTabbedText(ByRef SourceText As WString, ByRef PosText As Integer = 0, ForPrint As Boolean = False) ByRef As WString
		Declare Sub PaintControl(bFull As Boolean = False)
		Declare Sub PaintControlPriv(bFull As Boolean = False)
		Declare Function GetWordAt(LineIndex As Integer, CharIndex As Integer, WithDot As Boolean = False, WithQuestion As Boolean = False, ByRef StartChar As Integer = 0) As String
		Declare Function GetWordAtCursor(WithDot As Boolean = False) As String
		Declare Function GetWordAtPoint(X As Integer, Y As Integer, WithDot As Boolean = False) As String
		Declare Function GetCaretPosY(LineIndex As Integer) As Integer
		Declare Function CharIndexFromPoint(X As Integer, Y As Integer, CodePane As Integer = -1) As Integer
		Declare Function LineIndexFromPoint(X As Integer, Y As Integer, CodePane As Integer = -1) As Integer
		Declare Function LinesCount As Integer
		Declare Function VisibleLinesCount(CodePane As Integer = -1) As Integer
		Declare Function Lines(Index As Integer) ByRef As WString
		Declare Function LineLength(Index As Integer) As Integer
		Declare Property Text ByRef As WString
		Declare Property Text(ByRef Value As WString)
		Declare Property HintDropDown ByRef As WString
		Declare Property HintDropDown(ByRef Value As WString)
		Declare Property HintWord ByRef As WString
		Declare Property HintWord(ByRef Value As WString)
		Declare Property SelText ByRef As WString
		Declare Property SelText(ByRef Value As WString)
		Declare Property SplittedHorizontally As Boolean
		Declare Property SplittedHorizontally(Value As Boolean)
		Declare Property SplittedVertically As Boolean
		Declare Property SplittedVertically(Value As Boolean)
		Declare Property TopLine As Integer
		Declare Property TopLine(Value As Integer)
		Declare Sub InsertLine(Index As Integer, ByRef sLine As WString)
		Declare Sub ReplaceLine(Index As Integer, ByRef sLine As WString)
		Declare Sub DeleteLine(Index As Integer = -1)
		Declare Sub DuplicateLine(Index As Integer = -1)
		Declare Sub ShowLine(Index As Integer)
		Declare Sub GetSelection(ByRef iSelStartLine As Integer, ByRef iSelEndLine As Integer, ByRef iSelStartChar As Integer, ByRef iSelEndChar As Integer, iCurrProcedure As Boolean = False)
		Declare Sub SetSelection(iSelStartLine As Integer, iSelEndLine As Integer, iSelStartChar As Integer, iSelEndChar As Integer)
		Declare Sub ChangeText(ByRef Value As WString, CharTo As Integer = 0, ByRef Comment As WString = "", SelStartLine As Integer = -1, SelStartChar As Integer = -1)
		Declare Sub Changing(ByRef Comment As WString = "")
		Declare Sub Changed(ByRef Comment As WString = "")
		Declare Sub ChangeCollapsibility(LineIndex As Integer)
		Declare Sub ChangeCollapseState(LineIndex As Integer, Value As Boolean)
		Declare Sub ChangeInConstruction(LineIndex As Integer, OldConstructionIndex As Integer, OldConstructionPart As Integer)
		Declare Function GetLineIndex(Index As Integer, iTo As Integer = 0) As Integer
		Declare Sub Clear
		Declare Sub ClearUndo
		Declare Sub Undo
		Declare Sub Redo
		Declare Sub PasteFromClipboard
		Declare Sub CopyCurrentLineToClipboard
		Declare Sub CopyToClipboard
		Declare Sub CutCurrentLineToClipboard
		Declare Sub CutToClipboard
		Declare Sub Breakpoint
		Declare Sub Bookmark
		Declare Sub CollapseAll
		Declare Sub UnCollapseAll
		Declare Sub CollapseAllProcedures
		Declare Sub UnCollapseAllProcedures
		Declare Sub CollapseCurrent
		Declare Sub UnCollapseCurrent
		Declare Sub ClearAllBookmarks
		Declare Sub SelectAll
		Declare Sub ScrollToCaret
		Declare Sub LoadFromFile(ByRef FileName As WString, ByRef FileEncoding As FileEncodings, ByRef NewLineType As NewLineTypes, WithoutScroll As Boolean = False)
		Declare Sub SaveToFile(ByRef FileName As WString, FileEncoding As FileEncodings, NewLineType As NewLineTypes)
		Declare Sub Indent
		Declare Sub Outdent
		Declare Sub CommentSingle
		Declare Sub CommentBlock
		Declare Sub UnComment
		Declare Constructor
		Declare Destructor
		OnChange As Sub(ByRef Sender As EditControl)
		OnAutoComplete As Sub(ByRef Sender As EditControl)
		OnShowDropDown As Sub(ByRef Sender As EditControl)
		OnDropDownCloseUp As Sub(ByRef Sender As EditControl)
		OnValidate As Sub(ByRef Sender As EditControl)
		OnSelChange As Sub(ByRef Sender As EditControl, ByVal CurrentLine As Integer, ByVal CurrentCharIndex As Integer)
		OnLineChange As Sub(ByRef Sender As EditControl, ByVal CurrentLine As Integer, ByVal OldLine As Integer)
		OnLineAdding As Sub(ByRef Sender As EditControl, ByVal CurrentLine As Integer)
		OnLineAdded As Sub(ByRef Sender As EditControl, ByVal CurrentLine As Integer)
		OnLineRemoving As Sub(ByRef Sender As EditControl, ByVal CurrentLine As Integer)
		OnLineRemoved As Sub(ByRef Sender As EditControl, ByVal CurrentLine As Integer)
		OnUndoing As Sub(ByRef Sender As EditControl)
		OnUndo As Sub(ByRef Sender As EditControl)
		OnRedoing As Sub(ByRef Sender As EditControl)
		OnRedo As Sub(ByRef Sender As EditControl)
		OnLinkClicked As Sub(ByRef Sender As EditControl, ByRef link As WString)
		OnToolTipLinkClicked As Sub(ByRef Sender As EditControl, ByRef link As WString)
		OnSplitHorizontallyChange As Sub(ByRef Sender As EditControl, Splitted As Boolean)
		OnSplitVerticallyChange As Sub(ByRef Sender As EditControl, Splitted As Boolean)
	End Type
	
	Common Constructions() As Construction
	Common As EditControl Ptr CurEC, ScrEC
	Common As Integer MiddleScrollIndexX, MiddleScrollIndexY
End Namespace

Declare Sub LoadKeyWords

Namespace My.Sys.Forms
	Declare Function IsArg(j As Integer) As Boolean
	
	Declare Function FindCommentIndex(ByRef Value As WString, ByRef iC As Integer) As Integer
	
	Declare Function IsArg2(ByRef sLine As WString) As Boolean
	
	Declare Function GetNextCharIndex(ByRef sLine As WString, iEndChar As Integer, WithDot As Boolean = False) As Integer
	
	Declare Sub GetColor(iColor As Long, ByRef iRed As Double, ByRef iGreen As Double, ByRef iBlue As Double)
	
	#ifdef __USE_GTK__
		Declare Sub cairo_rectangle(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As Boolean)
		Declare Sub cairo_rectangle_(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As Boolean)
	#endif
	
	Declare Function GetKeyWordCase(ByRef KeyWord As String, KeyWordsList As WStringOrStringList Ptr = 0, OriginalCaseWord As String = "") As String
	
	Declare Function TextWithoutQuotesAndComments(subject As String, OldCommentIndex As Integer = 0, WithoutComments As Boolean = True, WithoutBracket As Boolean = False) As String
	
	#ifdef __USE_GTK__
		Declare Function EditControl_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
		
		Declare Function EditControl_OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
		
		Declare Sub EditControl_SizeAllocate(widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr)
		
		Declare Sub EditControl_ScrollValueChanged(widget As GtkAdjustment Ptr, user_data As Any Ptr)
	#endif
End Namespace

#ifndef __USE_MAKE__
	#include once "EditControl.bas"
#endif
