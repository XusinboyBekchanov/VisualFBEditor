'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Picture.bi"
	#include once "mff/Menus.bi"
	#include once "Designer.bi"
	
	Type TabWindowPtr As TabWindow Ptr
	
	Using My.Sys.Forms
	
	Type frmMenuEditor Extends Form
		Declare Static Sub Form_Paint_(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub Form_MouseDown_(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub txtActive_Change_(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
		Declare Sub txtActive_Change(ByRef Sender As TextBox)
		Declare Sub GetDropdowns(mi As Any Ptr)
		Declare Sub SelectRect(Index As Integer)
		Declare Sub EditRect(i As Integer, NewObject As Boolean = False)
		Declare Static Sub Form_KeyDown_(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub Form_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub Form_KeyPress_(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		Declare Sub Form_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Static Sub txtActive_KeyDown_(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub txtActive_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub _Form_MouseUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _mnuDelete_Click(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem)
		Declare Sub mnuDelete_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuInsert_Click(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem)
		Declare Sub mnuInsert_Click(ByRef Sender As MenuItem)
		Declare Sub InsertNewMenuItem
		Declare Sub DeleteMenuItem
		Declare Sub MoveUpMenuItem
		Declare Sub MoveDownMenuItem
		Declare Static Sub mnuMoveUp_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem)
		Declare Sub mnuMoveUp_Click(ByRef Sender As MenuItem)
		Declare Static Sub mnuMoveDown_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem)
		Declare Sub mnuMoveDown_Click(ByRef Sender As MenuItem)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As Picture picActive
		Dim As TextBox txtActive
		Dim As ImageList imgList
		Dim CurrentMenu As Any Ptr
		Dim CurrentToolBar As Any Ptr
		Dim CurrentStatusBar As Any Ptr
		Dim tb As TabWindowPtr
		Dim Des As My.Sys.Forms.Designer Ptr
		Dim Rects(Any) As My.Sys.Drawing.Rect
		Dim Ctrls(Any) As Any Ptr
		Dim Parents(Any) As Any Ptr
		Dim Indexes(Any) As Integer
		Dim RectsCount As Integer
		Dim TopCount As Integer
		Dim ActiveRect As Integer
		Dim ActiveCtrl As Any Ptr
		Dim ParentRect As Integer
		Dim Dropdowns(Any) As Any Ptr
		Dim DropdownsCount As Integer
		Dim As PopupMenu PopupMenu1
		Dim As MenuItem mnuInsert, mnuDelete, MenuItem3, mnuMoveUp, mnuMoveDown
	End Type
	
	Common Shared pfMenuEditor As frmMenuEditor Ptr
'#End Region

Declare Function ChangeControl(ByRef Sender As Designer, Cpnt As Any Ptr, ByRef PropertyName As WString = "", BeforeControl As Any Ptr = 0, AfterControl As Any Ptr = 0, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1) As Integer

Declare Sub TabWindowFormDesign

#ifndef __USE_MAKE__
	#include once "frmMenuEditor.frm"
#endif
