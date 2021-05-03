'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Picture.bi"
	#include once "mff/Menus.bi"
	#include once "Designer.bi"
	
	Using My.Sys.Forms
	
	Type frmMenuEditor Extends Form
		Declare Static Sub Form_Paint_(ByRef Sender As Control, Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Paint(ByRef Sender As Control, Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub Form_MouseDown_(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub txtActive_Change_(ByRef Sender As TextBox)
		Declare Sub txtActive_Change(ByRef Sender As TextBox)
		Declare Sub GetDropdowns(mi As Any Ptr)
		Declare Sub SelectRect(Index As Integer)
		Declare Sub EditRect(i As Integer)
		Declare Static Sub Form_KeyDown_(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub Form_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub Form_KeyPress_(ByRef Sender As Control, Key As Byte)
		Declare Sub Form_KeyPress(ByRef Sender As Control, Key As Byte)
		Declare Static Sub txtActive_KeyDown_(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub txtActive_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As Picture picActive
		Dim As TextBox txtActive
		Dim CurrentMenu As Any Ptr
		Dim CurrentToolBar As Any Ptr
		Dim Des As My.Sys.Forms.Designer Ptr
		Dim Rects(Any) As Rect
		Dim Ctrls(Any) As Any Ptr
		Dim Parents(Any) As Any Ptr
		Dim RectsCount As Integer
		Dim TopCount As Integer
		Dim ActiveRect As Integer
		Dim ActiveCtrl As Any Ptr
		Dim ParentRect As Integer
		Dim Dropdowns(Any) As Any Ptr
		Dim DropdownsCount As Integer
	End Type
	
	Common Shared pfMenuEditor As frmMenuEditor Ptr
'#End Region

Declare Function ChangeControl(Cpnt As Any Ptr, ByRef PropertyName As WString = "", iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1) As Integer

#ifndef __USE_MAKE__
	#include once "frmMenuEditor.frm"
#endif
