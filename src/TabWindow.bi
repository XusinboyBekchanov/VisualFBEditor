'#########################################################
'#  TabWindow.bi                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "EditControl.bi"
#include once "Designer.bi"
#include once "frmTrek.bi"
#include once "mff/Dictionary.bi"
#include once "mff/ToolPalette.bi"
#include once "mff/TabControl.bi"
#include once "mff/ListView.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/Splitter.bi"
#include once "mff/ProgressBar.bi"
#include once "file.bi"

Common Shared As TreeNode Ptr MainNode

Using My.Sys.Forms

Declare Sub CompleteWord()

Type ProjectElement
	MainFileName As WString Ptr
	ResourceFileName As WString Ptr
	IconResourceFileName As WString Ptr
	ProjectType As Integer
	ProjectName As WString Ptr
	HelpFileName As WString Ptr
	ProjectDescription As WString Ptr
	MajorVersion As Integer
	MinorVersion As Integer
	RevisionVersion As Integer
	BuildVersion As Integer
	AutoIncrementVersion As Boolean
	ApplicationTitle As WString Ptr
	ApplicationIcon As WString Ptr
	CompanyName As WString Ptr
	FileDescription As WString Ptr
	InternalName As WString Ptr
	LegalCopyright As WString Ptr
	LegalTrademarks As WString Ptr
	OriginalFilename As WString Ptr
	ProductName As WString Ptr
	CompileToGCC As Boolean
	OptimizationLevel As Integer
	OptimizationFastCode As Boolean
	OptimizationSmallCode As Boolean
	CompilationArguments32Windows As WString Ptr
	CompilationArguments64Windows As WString Ptr
	CompilationArguments32Linux As WString Ptr
	CompilationArguments64Linux As WString Ptr
	CommandLineArguments As WString Ptr
	CreateDebugInfo As Boolean
	Declare Constructor
	Declare Destructor
End Type

Type ExplorerElement
	FileName As WString Ptr
	Project As ProjectElement Ptr
	Declare Destructor
End Type

Type PTabWindow As TabWindow Ptr

Type FileType
	FileName As UString
	DateChanged As Double
	Namespaces As WStringList
	Types As WStringList
	Enums As WStringList
	Procedures As WStringList
	Args As WStringList
	InProcess As Boolean
End Type

Type TypeElement
	Name As UString
	DisplayName As UString
	EnumTypeName As UString
	TypeName As UString
	Value As UString
	ElementType As UString
	Parameters As UString
	Comment As UString
	FileName As UString
	IncludeFile As UString
	TypeIsPointer As Boolean
	Declaration As Boolean
	Locals As Integer
	StartLine As Integer
	EndLine As Integer
	ControlType As Integer
	Find As Boolean
	TabPtr As PTabWindow
	Elements As WStringList
	Declare Destructor
End Type

Declare Function Err2Description(Code As Integer) ByRef As WString

#ifdef __USE_GTK__
	Type CloseButton Extends Panel
#else
	Type CloseButton Extends Label
#endif
Public:
	OldBackColor As Integer
	OldForeColor As Integer
	MouseIn As Boolean
	tbParent As PTabWindow
	#ifdef __USE_GTK__
		layout As PangoLayout Ptr
	#endif
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
	FLine3 As WString Ptr
	FLine4 As WString Ptr
	FPath As WString Ptr
	tbi As TypeElement Ptr
	tbi2 As TypeElement Ptr
	Dim As Any Ptr Ctrl, CurCtrl, CurCtrlRichedit
	i As Integer
	j As Integer
	lvItem As TreeListViewItem Ptr
	iTemp As Integer
	pTemp As Any Ptr
	te As TypeElement Ptr
	te2 As TypeElement Ptr
	Dim As EditControlLine Ptr ECLine, ECLine2
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
	Dim txtCodeBi As EditControl
	Declare Function SaveTab As Boolean
	Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
Public:
	Types As WStringList
	Enums As WStringList
	Procedures As WStringList
	Functions As WStringList
	Args As WStringList
	Declare Sub FillProperties(ByRef ClassName As WString)
	Declare Function FillIntellisense(ByRef ClassName As WString, pComps As WStringList Ptr, bLocal As Boolean = False, bAll As Boolean = False) As Boolean
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
	pnlForm As Panel
	tbrLeft As ToolBar
	tbrTop As ToolBar
	pnlToolbar As Panel
	txtCode As EditControl
	cboClass As ComboBoxEx
	cboFunction As ComboBoxEx
	btnClose As CloseButton
	Des As My.Sys.Forms.Designer Ptr
	splForm As Splitter
	#ifdef __USE_GTK__
		overlay As GtkWidget Ptr
		layout As GtkWidget Ptr
	#endif
	Declare Property FileName ByRef As WString
	Declare Property FileName(ByRef Value As WString)
	Declare Property Modified As Boolean
	Declare Property Modified(Value As Boolean)
	Declare Property Caption ByRef As WString
	Declare Property Caption(ByRef Value As WString)
	Declare Operator Cast As TabPage Ptr
	Declare Function GetLine(lLine As Long, ByRef strLine As WString = "", lUpLine As Long = 0, lDwLine As Long = 0, sc As Long = 0) ByRef As WString
	Declare Function CloseTab As Boolean
	Declare Function Save As Boolean
	Declare Function SaveAs As Boolean
	Declare Sub FillAllProperties
	Declare Sub ChangeName(ByRef OldName As WString, ByRef NewName As WString)
	Declare Function ReadObjProperty(ByRef Ctrl As Any Ptr, ByRef PropertyName As String) ByRef As WString
	Declare Function WriteObjProperty(ByRef Ctrl As Any Ptr, ByRef PropertyName As String, ByRef Value As WString) As Boolean
	Declare Function GetFormattedPropertyValue(ByRef Cpnt As Any Ptr, ByRef PropertyName As String) ByRef As WString
	Declare Sub SetErrorHandling(StartLine As String, EndLine As String)
	Declare Sub RemoveErrorHandling
	Declare Sub NumberOn(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Declare Sub NumberOff(ByVal StartLine As Integer = -1, ByVal EndLine As Integer = -1)
	Declare Sub ProcedureNumberOn
	Declare Sub ProcedureNumberOff
	Declare Sub PreprocessorNumberOn
	Declare Sub PreprocessorNumberOff
	Declare Sub Comment
	Declare Sub UnComment
	Declare Sub Indent
	Declare Sub Outdent
	Declare Sub Define
	Declare Sub FormDesign(NotForms As Boolean = False)
	Declare Constructor(ByRef wFileName As WString = "", bNewForm As Boolean = False, TreeN As TreeNode Ptr = 0)
	Declare Destructor
End Type

Dim Shared As PopupMenu mnuCode

Declare Sub MoveCloseButtons()

Declare Function FileNameExists(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr

Declare Function GetTab(ByRef FileName As WString) As TabWindow Ptr

Declare Function AddTab(ByRef FileName As WString = "", bNew As Boolean = False, TreeN As TreeNode Ptr = 0, bNoActivate As Boolean = False) As TabWindow Ptr

Const SingleConstructions = "else,#else,next,do,loop,wend"

Declare Sub ClearMessages() '...'

Declare Sub ShowMessages(ByRef msg As WString, ChangeTab As Boolean = True)

Declare Sub m(ByRef msg As WString) '...'

Common Shared TextChanged As Boolean
Declare Sub OnChangeEdit(ByRef Sender As Control)

Declare Sub OnMouseDownEdit(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)

Declare Function IsLabel(ByRef LeftA As WString) As Boolean

Declare Sub CloseButton_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)

Declare Sub CloseButton_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)

Declare Sub CloseButton_MouseLeave(ByRef Sender As Control)

#ifdef __USE_GTK__
	Declare Function CloseButton_OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
	
	Declare Function CloseButton_OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
#endif

Declare Function WithoutPtr(TypeName As String) As String

Declare Function GetPropertyType(ClassName As String, PropertyName As String) As TypeElement Ptr

Declare Function IsBase(ByRef TypeName As String, ByRef BaseName As String) As Boolean

Common Shared bNotFunctionChange As Boolean
Declare Sub DesignerChangeSelection(ByRef Sender As Designer, Ctrl As Any Ptr, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1)

Declare Sub GetControls(Des As Designer Ptr, ByRef lst As List, Ctrl As Any Ptr)

Declare Sub DesignerDeleteControl(ByRef Sender As Designer, Ctrl As Any Ptr)

Declare Function ChangeControl(Cpnt As Any Ptr, ByRef PropertyName As WString = "", iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1) As Integer

Declare Function GetItemText(ByRef Item As TreeListViewItem Ptr) As String

Declare Sub PropertyChanged(ByRef Sender As Control, ByRef Sender_Text As WString, IsCombo As Boolean)

Declare Sub lvProperties_CellEditing(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr)

Declare Sub lvProperties_CellEdited(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString)

Declare Sub txtPropertyValue_LostFocus(ByRef Sender As Control)

Declare Sub cboPropertyValue_Change(ByRef Sender As Control)

Declare Sub DesignerModified(ByRef Sender As Designer, Ctrl As Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)

Declare Sub ToolGroupsToCursor()

Declare Sub DesignerInsertControl(ByRef Sender As Designer, ByRef ClassName As String, Ctrl As Any Ptr, iLeft2 As Integer, iTop2 As Integer, iWidth2 As Integer, iHeight2 As Integer)

Declare Sub DesignerInsertComponent(ByRef Sender As Designer, ByRef ClassName As String, Cpnt As Any Ptr, iLeft2 As Integer, iTop2 As Integer)

Declare Sub DesignerInsertingControl(ByRef Sender As Designer, ByRef ClassName As String, ByRef AName As String)

Declare Sub cboClass_Change(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)

Common Shared bNotDesignForms As Boolean
Declare Sub OnLineChangeEdit(ByRef Sender As Control, ByVal CurrentLine As Integer, ByVal OldLine As Integer)

Declare Sub FindEvent(Cpnt As Any Ptr, EventName As String)

Declare Sub cboFunction_Change(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)

Declare Sub DesignerDblClickControl(ByRef Sender As Designer, Ctrl As Any Ptr)

Declare Sub DesignerClickProperties(ByRef Sender As Designer, Ctrl As Any Ptr)

Common Shared As Integer SelLinePos, SelCharPos
#ifdef __USE_GTK__
	Declare Sub lvIntellisense_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
#else
	Declare Sub cboIntellisense_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
#endif

Declare Sub OnKeyDownEdit(ByRef Sender As Control, Key As Integer, Shift As Integer)

Declare Sub FillAllIntellisenses(ByRef Starts As WString = "")

Declare Sub FillTypeIntellisenses(ByRef Starts As WString = "")

Declare Function Ekvivalent(ByRef a As WString, ByRef b As WString) As Integer

Declare Sub FindComboIndex(tb As TabWindow Ptr, ByRef sLine As WString, iEndChar As Integer)

Declare Sub FillIntellisenseByName(Value As String, Starts As String = "", bLocal As Boolean = False, bAll As Boolean = False, NotClear As Boolean = False)

Declare Sub OnKeyPressEdit(ByRef Sender As Control, Key As Byte)

Declare Sub tbrTop_ButtonClick(ByRef Sender As My.Sys.Object)

Declare Sub cboIntellisense_DropDown(ByRef Sender As ComboBoxEdit)

Declare Sub cboIntellisense_CloseUp(ByRef Sender As ComboBoxEdit)

Declare Function GetLeftArgTypeName(tb As TabWindow Ptr, iSelEndLine As Integer, iSelEndChar As Integer, ByRef teEnum As TypeElement Ptr = 0, ByRef teEnumOld As TypeElement Ptr = 0, ByRef OldTypeName As String = "") As String

Declare Function GetTypeFromValue(tb As TabWindow Ptr, Value As String) As String

Declare Sub TabWindow_Destroy(ByRef Sender As Control)

Declare Sub lvProperties_ItemExpanding(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)

Declare Sub SplitError(ByRef sLine As WString, ByRef ErrFileName As WString Ptr, ByRef ErrTitle As WString Ptr, ByRef ErrorLine As Integer)
Declare Sub SelectError(ByRef FileName As WString, iLine As Integer, tabw As TabWindow Ptr = 0)

Declare Sub PipeCmd(ByRef file As WString, ByRef cmd As WString)

#ifdef __USE_GTK__
	Declare Function build_create_shellscript(ByRef working_dir As WString, ByRef cmd As WString, autoclose As Boolean, debug As Boolean = False, ByRef Arguments As WString = "") As String
#endif

Declare Function GetFirstCompileLine(ByRef FileName As WString, ByRef Project As ProjectElement Ptr) As UString

Declare Function GetParentNode(tn As TreeNode Ptr) As TreeNode Ptr

Declare Function GetMainFile(bSaveTab As Boolean = False, ByRef Project As ProjectElement Ptr = 0, ByRef ProjectNode As TreeNode Ptr = 0) As UString

Declare Sub Versioning(ByRef FileName As WString, ByRef sFirstLine As WString, ByRef Project As ProjectElement Ptr = 0, ByRef ProjectNode As TreeNode Ptr = 0)

Declare Sub RunPr(Debugger As String = "")

Declare Sub RunProgram(Param As Any Ptr)

Dim Shared symbols(0 To 15) As UByte

Const plus  As UByte = 43
Const minus As UByte = 45
Const dot   As UByte = 46

Declare Function isNumeric(ByRef subject As Const WString, base_ As Integer = 10) As Boolean

Declare Function utf16BeByte2wchars( ta() As UByte ) ByRef As WString

Declare Sub GetProcedureLines(ByRef ehStart As Integer, ByRef ehEnd As Integer)
Declare Sub SelectSearchResult(ByRef FileName As WString, iLine As Integer, ByVal iSelStart As Integer =-1, ByVal iSelLength As Integer =-1, tabw As TabWindow Ptr = 0, ByRef SearchText As WString = "")

#ifndef __USE_MAKE__
	#include once "TabWindow.bas"
#endif
