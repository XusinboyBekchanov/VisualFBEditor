/'
EditControl.
(c)2018-2019 Xusinboy Bekchanov
bxusinboy@mail.ru
'/

#include once "mff/Panel.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/Canvas.bi"
#include once "mff/WStringList.bi"
#include once "mff/Clipboard.bi"
#include once "mff/Application.bi"
#include once "mff/ListView.bi"
#include once "Main.bi"

Enum KeyWordsCase
	OriginalCase
	LowerCase
	UpperCase
End Enum

Common Shared As Boolean AutoIndentation
Common Shared As Boolean ShowSpaces
Common Shared As Integer TabWidth
Common Shared As Integer HistoryLimit
Common Shared As Integer TabAsSpaces
Common Shared As KeyWordsCase ChoosedKeyWordsCase
Common Shared As Integer ChoosedTabStyle
Common Shared As Boolean ChangeKeyWordsCase
Common Shared As WStringList Ptr pkeywords0, pkeywords1, pkeywords2, pkeywords3

Common Shared As Integer BookmarksForeground, BookmarksForegroundOption, BookmarksBackground, BookmarksBackgroundOption, BookmarksIndicator, BookmarksIndicatorOption, BookmarksBold, BookmarksItalic, BookmarksUnderline
Common Shared As Integer BreakpointsForeground, BreakpointsForegroundOption, BreakpointsBackground, BreakpointsBackgroundOption, BreakpointsIndicator, BreakpointsIndicatorOption, BreakpointsBold, BreakpointsItalic, BreakpointsUnderline
Common Shared As Integer CommentsForeground, CommentsForegroundOption, CommentsBackground, CommentsBackgroundOption, CommentsBold, CommentsItalic, CommentsUnderline
Common Shared As Integer CurrentLineForeground, CurrentLineForegroundOption, CurrentLineBackground, CurrentLineBackgroundOption
Common Shared As Integer ExecutionLineForeground, ExecutionLineForegroundOption, ExecutionLineBackground, ExecutionLineBackgroundOption, ExecutionLineIndicator, ExecutionLineIndicatorOption
Common Shared As Integer FoldLinesForeground, FoldLinesForegroundOption
Common Shared As Integer IndicatorLinesForeground, IndicatorLinesForegroundOption
Common Shared As Integer KeywordsForeground, KeywordsForegroundOption, KeywordsBackground, KeywordsBackgroundOption, KeywordsBold, KeywordsItalic, KeywordsUnderline
Common Shared As Integer LineNumbersForeground, LineNumbersForegroundOption, LineNumbersBackground, LineNumbersBackgroundOption, LineNumbersBold, LineNumbersItalic, LineNumbersUnderline
Common Shared As Integer NormalTextForeground, NormalTextForegroundOption, NormalTextBackground, NormalTextBackgroundOption, NormalTextBold, NormalTextItalic, NormalTextUnderline
Common Shared As Integer PreprocessorsForeground, PreprocessorsForegroundOption, PreprocessorsBackground, PreprocessorsBackgroundOption, PreprocessorsBold, PreprocessorsItalic, PreprocessorsUnderline
Common Shared As Integer SelectionForeground, SelectionForegroundOption, SelectionBackground, SelectionBackgroundOption
Common Shared As Integer SpaceIdentifiersForeground, SpaceIdentifiersForegroundOption
Common Shared As Integer StringsForeground, StringsForegroundOption, StringsBackground, StringsBackgroundOption, StringsBold, StringsItalic, StringsUnderline
Common Shared As Integer EditorFontSize
Common Shared As WString Ptr EditorFontName
Common Shared As WString Ptr CurrentTheme
	
Type Construction
	Name0 As String * 50
	Name1 As String * 50
	Name2 As String * 50
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
	
	Type EditControlLine
		Text As WString Ptr
		CommentIndex As Integer
		Breakpoint As Boolean
		Bookmark As Boolean
		ConstructionIndex As Integer
		ConstructionPart As Integer
		Multiline As Boolean
		Collapsible As Boolean
		Collapsed As Boolean
		InCollapse As Boolean
		Visible As Boolean
		Declare Constructor
		Declare Destructor
	End Type
	
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
		Dim FHintWord As WString Ptr
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
		#ifdef __USE_GTK__
			
		#else
			Dim As HDC hd
			Dim As HDC bufDC
			Dim As HBITMAP bufBMP
			Dim As TEXTMETRIC tm
			Dim hwndTT As HWND
		#endif
		Dim As RECT rc
		#ifndef __USE_GTK__
			Dim sz As Size
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
		Dim As Integer CurrentFontSize
		Dim As WString Ptr CurrentFontName
		Dim As Boolean bInIncludeFileRect
		Dim As Boolean bInIncludeFileRectOld
		Dim As Integer iCursorLine
		Dim As Integer iCursorLineOld
		Dim As Integer IzohBoshi, QavsBoshi, MatnBoshi
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		Dim As String KeyWord, Matn
		Dim pkeywords As WStringList Ptr
		Dim LinePrinted As Boolean
		'Dim As Boolean ChangeCase
		Dim CollapseIndex As Integer
		Dim OldCollapseIndex As Integer
		Declare Sub FontSettings
		Declare Function CharType(ByRef ch As WString) As Integer
		Declare Function MaxLineWidth() As Integer
		Declare Sub PaintText(iLine As Integer, ByRef s As WString, iStart As Integer, iEnd As Integer, BKColor As Integer = -1, TextColor As Integer = clBlack, ByRef addit As WString = "", Bold As Boolean = False, Italic As Boolean = False, Underline As Boolean = False)
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
		Declare Function InIncludeFileRect(i As Integer, X As Integer, Y As Integer) As Boolean
		Declare Sub ProcessMessage(ByRef msg As Message)    
		Public:
		#ifdef __USE_GTK__
			Dim As cairo_t Ptr cr
			Dim As GtkWidget Ptr wText
			Dim As PangoContext Ptr pcontext
			Dim As PangoLayout Ptr layout
			Dim As GdkDisplay Ptr pdisplay
			Dim As GdkCursor Ptr gdkCursorIBeam
			Dim As GdkCursor Ptr gdkCursorHand
			#ifdef __USE_GTK3__
				Dim As GtkStyleContext Ptr scontext
			#endif
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
		#endif
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
		Dim As Boolean SyntaxEdit
		Dim As Boolean CStyle
		Dim LeftMargin As Integer
		Dim HScrollPos As Integer
		Dim VScrollPos As Integer
		#ifdef __USE_GTK__
			lvIntellisense As ListView
		#else
			cboIntellisense As ComboBoxEx
			pnlIntellisense As Panel
		#endif
		DropDownShowed As Boolean
		DropDownChar As Integer
		ToolTipShowed As Boolean
		ToolTipChar As Integer
		Declare Function GetConstruction(ByRef sLine As WString, ByRef iType As Integer = 0, OldCommentIndex As Integer = 0) As Integer
		Declare Sub SetScrollsInfo()
		Declare Sub ShowCaretPos(Scroll As Boolean = False)
		Declare Function TextWidth(ByRef sText As WString) As Integer
		Declare Sub ShowDropDownAt(iSelEndLine As Integer, iSelEndChar As Integer)
		Declare Sub ShowToolTipAt(iSelEndLine As Integer, iSelEndChar As Integer)
		Declare Sub CloseDropDown()
		Declare Sub CloseToolTip()
		Declare Sub FormatCode()
		Declare Sub UnformatCode()
		Declare Function GetTabbedText(ByRef SourceText As WString, ByRef PosText As Integer = 0, ForPrint As Boolean = False) ByRef As WString
		Declare Sub PaintControl()
		Declare Sub PaintControlPriv()
		Declare Function GetWordAt(LineIndex As Integer, CharIndex As Integer) As String
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
		Declare Property HintWord ByRef As WString
		Declare Property HintWord(ByRef Value As WString)
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
		OnLinkClicked As Sub(ByRef Sender As EditControl, ByRef Link As WString)
	End Type
	
	Common Constructions() As Construction
	Common As EditControl Ptr CurEC
End Namespace

Declare Sub LoadKeyWords

#ifdef __USE_GTK__
	Declare Function Blink_cb(user_data As gpointer) As gboolean
#endif

Namespace My.Sys.Forms
	Declare Function IsArg(j As Integer) As Boolean
	
	Declare Function FindCommentIndex(ByRef Value As WString, ByRef iC As Integer) As Integer
	
	Declare Function IsArg2(ByRef sLine As WString) As Boolean
	
	Declare Function GetNextCharIndex(ByRef sLine As WString, iEndChar As Integer) As Integer
	
	Declare Sub GetColor(iColor As Integer, ByRef iRed As Double, ByRef iGreen As Double, ByRef iBlue As Double)
	
	#ifdef __USE_GTK__
		Declare Sub cairo_rectangle(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As Boolean)
		Declare Sub cairo_rectangle_(cr As cairo_t Ptr, x As Double, y As Double, x1 As Double, y1 As Double, z As Boolean)
	#endif
	
	Declare Function GetKeyWordCase(ByRef KeyWord As String, KeyWordsList As WStringList Ptr = 0) As String
	
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
