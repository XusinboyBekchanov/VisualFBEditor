#include once "mff\Form.bi"
#Include Once "mff\Clipboard.bi"

Dim Shared SelectedClass As String
Dim Shared SelectedType As Integer
Dim Shared As PopupMenu mnuDesigner

Namespace My.Sys.Forms

type PDesigner as Designer ptr
#DEFINE QDesigner(__Ptr__) *Cast(Designer Ptr,__Ptr__)

type WindowList
	Count  as integer
	Ctrl  as Any ptr
	#IfNDef __USE_GTK__
		Child  as HWND ptr
	#EndIf
end type

#IfDef __USE_GTK__
	Dim Shared As GtkWidget Ptr designer_menu
#EndIf

type Designer extends My.Sys.Object
	private:
		#IfDef __USE_GTK__
			Declare Static Function HookChildProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
			Declare Static Function HookDialogProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
			Declare Static Function HookDialogParentProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
			Declare Static Function DotWndProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
		#Else
			declare static function HookChildProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
			declare static function HookDialogProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
			declare static function HookDialogParentProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
			declare static function DotWndProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
			FPopupMenu     as HMENU
		#EndIf
		FActive        as Boolean
		FStepX         as integer
		FStepY         as integer
		FShowGrid      as Boolean
		FChilds        as WindowList
		#IfDef __USE_GTK__
			FDialog        as GtkWidget Ptr
			FDialogParent  as GtkWidget Ptr
		#Else
			FDialog        as HWND
			FDialogParent  as HWND
		#EndIf
		FClass         as string
		FClassName     as Wstring Ptr
		#IfNDef __USE_GTK__
			FGridBrush     as HBRUSH
		#EndIf
		FDotColor      as integer
		#IfNDef __USE_GTK__
			FDotBrush      as HBRUSH
		#EndIf
		FSnapToGrid    as Boolean
		FDown          as Boolean
		FCanInsert     as Boolean
		FCanMove       as Boolean
		FCanSize       as Boolean
		FBeginX        as integer
		FBeginY        as integer
		FOldX          As Integer
		FOldY          As Integer
		FNewX          as integer
		FNewY          as integer
		FEndX          as integer
		FEndY          as integer
		FLeft          as integer
		FTop           as integer
		FWidth         as integer
		FHeight        as integer
		FLeftNew       as integer
		FTopNew        as integer
		FWidthNew      as integer
		FHeightNew     as integer
		FDotIndex      as integer
		#IfDef __USE_GTK__
			FDots(7)       as GtkWidget Ptr
		#Else
			FDots(7)       as HWND
		#EndIf
		FName          As String
		FStyleEx       as integer
		FStyle         as integer
		FID            as integer
		#IfDef __USE_GTK__
			
		#Else
			FHDC        As HDC
			FPoint As Point
		#EndIf
		Dim Ctrl As Any Ptr
		#IfNDef __USE_GTK__
			Brush         as HBRUSH
			PrevBrush     as HBRUSH
		#EndIf
    protected:
		Declare Sub ProcessMessage(BYREF Message As Message)
		#IfDef __USE_GTK__
			declare        function IsDot(hDlg as GtkWidget Ptr) as integer
		#Else
			Declare Static Sub HandleIsAllocated(BYREF Sender As Control)
			declare static function EnumChildsProc(hDlg as HWND, lParam as LPARAM) as Boolean
			declare        function IsDot(hDlg as HWND) as integer
		#EndIf
		Declare Function GetContainerControl(Ctrl As Any Ptr) As Any Ptr
		declare        sub HookParent
		declare        sub UnHookParent
		declare        sub RegisterDotClass(Byref clsName As WString)
		declare        sub CreateDots(Parent as Control Ptr)
		declare        sub DestroyDots
		#IfDef __USE_GTK__
			declare        function ControlAt(Parent as Any Ptr, X as integer, Y as integer) as Any Ptr
		#Else
			declare        function ControlAt(Parent as HWND,X as integer,Y as integer) as HWND
		#EndIf
		#IfNDef __USE_GTK__
			declare        sub GetChilds(Parent as HWND = 0)
		#EndIf
		declare        sub UpdateGrid
		declare        sub PaintGrid
		#IfNDef __USE_GTK__
			declare        sub ClipCursor(hDlg as HWND)
		#EndIf
		declare        sub DrawBox(R as RECT)
		declare        sub DrawBoxs(R() as RECT)
		declare        sub Clear
		declare        function GetClassAcceptControls(AClassName as string) as Boolean
		declare        sub DblClick(X as integer, Y as Integer, Shift as integer)
		declare        sub MouseDown(X as integer, Y as Integer, Shift as integer)
		declare        sub MouseUp(X as integer, Y as Integer, Shift as integer)
		declare        sub MouseMove(X as integer, Y as Integer, Shift as integer)
		declare        sub KeyDown(Key as Integer, Shift as integer)
	public:
		CreateControlFunc As Function(ByRef ClassName As String, ByRef Name As WString, ByRef Text As WString, lLeft As Integer, lTop As Integer, lWidth As Integer, lHeight As Integer, Parent As Any Ptr) As Any Ptr
  		DeleteComponentFunc As Function(Cpnt As Any Ptr) As Boolean
        ReadPropertyFunc As Function(Cpnt As Any Ptr, ByRef PropertyName As String) As Any Ptr
        WritePropertyFunc As Function(Cpnt As Any Ptr, ByRef PropertyName As String, Value As Any Ptr) As Boolean
        RemoveControlSub As Sub(Parent As Any Ptr, Ctrl As Any Ptr)
        ControlByIndexFunc As Function(Parent As Any Ptr, Index As Integer) As Any Ptr
        ControlGetBoundsSub As Sub(Ctrl As Any Ptr, ALeft As Integer Ptr, ATop As Integer Ptr, AWidth As Integer Ptr, AHeight As Integer Ptr)
        ControlSetBoundsSub As Sub(Ctrl As Any Ptr, ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
        ControlIsContainerFunc As Function(Ctrl As Any Ptr) As Boolean
        IsControlFunc As Function(Ctrl As Any Ptr) As Boolean
        ControlSetFocusSub As Sub(Ctrl As Any Ptr)
        ControlFreeWndSub As Sub(Ctrl As Any Ptr)
        ToStringFunc As Function(Obj As Any Ptr) ByRef As WString
        FLibs          as WStringList
		Dim MFF As Any Ptr
		#IfDef __USE_GTK__
			FOverControl   as GtkWidget Ptr
		#Else
			FOverControl   as HWND
		#EndIf
		declare        sub Hook
		declare        sub UnHook
		declare        sub HideDots
		declare        sub PaintControl()
		declare        sub CopyControl()
		declare        sub CutControl()
		declare        sub PasteControl()
		declare        sub DeleteControl(Ctrl as Any Ptr)
		DesignControl As Any Ptr
		SelectedControl As Any Ptr
		#IfDef __USE_GTK__
			cr As cairo_t Ptr
			layoutwidget As GtkWidget Ptr
			FSelControl    as GtkWidget Ptr
		#Else
			FSelControl    as HWND
		#EndIf
		declare        sub DrawGrid() 'DC as HDC, R as RECT)
		#IfDef __USE_GTK__
			Declare Function GetControl(CtrlHandle As GtkWidget Ptr) As Any Ptr
			declare        sub MoveDots(Control as GtkWidget Ptr, bSetFocus As Boolean = True, Left1 As Integer = -1, Top As Integer = -1, Width1 As Integer = -1, Height As Integer = -1)
		#Else
			Declare Function GetControl(CtrlHandle As HWND) As Any Ptr
			declare        sub MoveDots(Control as HWND, bSetFocus As Boolean = True)
		#EndIf
		declare        Function CreateControl(AClassName as string, AName as string, ByRef AText As WString, AParent as Any Ptr, x as integer,y as integer, cx as integer, cy as integer, bNotHook As Boolean = False) As Any Ptr
		declare        Function CreateComponent(AClassName as string, AName as string) As Any Ptr
		OnChangeSelection  as sub(ByRef Sender as Designer, Control as Any Ptr, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1)
		OnDeleteControl    as sub(ByRef Sender as Designer, Control as Any Ptr)
		OnModified         as sub(ByRef Sender as Designer, Control as Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
		OnInsertControl    as sub(ByRef Sender as Designer, ByRef ClassName as string, Ctrl as Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
		OnInsertComponent  as sub(ByRef Sender as Designer, ByRef ClassName as string, Cpnt as Any Ptr)
		OnInsertingControl as sub(ByRef Sender as Designer, ByRef ClassName as string, ByRef sName as string)
		OnMouseMove        as sub(ByRef Sender as Designer, X as integer, Y as integer, ByRef Over as Any Ptr)
		OnDblClickControl  as sub(ByRef Sender as Designer, Control as Any Ptr)
		OnClickProperties  as sub(ByRef Sender as Designer, Control as Any Ptr)
		declare            function ClassExists() as Boolean
		'declare static     function GetClassName(hDlg as HWND) as string
		#IfDef __USE_GTK__
			declare property Dialog as GtkWidget Ptr
			declare property Dialog(value as GtkWidget Ptr)
			declare            sub HookControl(Control as GtkWidget Ptr)
			declare            sub UnHookControl(Control as GtkWidget Ptr)
		#Else
			declare            sub HookControl(Control as HWND)
			declare            sub UnHookControl(Control as HWND)
			declare property Dialog as HWND
			declare property Dialog(value as HWND)
		#EndIf
		declare property Active as Boolean
		declare property Active(value as Boolean)
		declare property ChildCount as integer
		declare property ChildCount(value as integer)
		#IfNDef __USE_GTK__
			declare property Child(index as integer) as HWND
			declare property Child(index as integer,value as HWND)
		#EndIf
		declare property StepX as integer
		declare property StepX(value as integer)
		declare property StepY as integer
		declare property StepY(value as integer)
		declare property DotColor as integer
		declare property DotColor(value as integer)
		declare property SnapToGrid as Boolean
		declare property SnapToGrid(value as Boolean)
		declare property ShowGrid as Boolean
		declare property ShowGrid(value as Boolean)
		declare property ClassName as string
		declare property ClassName(value as string)
		declare operator cast as any ptr
		Declare Operator Cast As Control Ptr
		declare constructor(ParentControl As Control Ptr)
		declare destructor
end type

#IfDef __USE_GTK__
	Function Designer.GetControl(CtrlHandle As GtkWidget Ptr) As Any Ptr
		'Return Cast(Any Ptr, GetWindowLongPtr(CtrlHandle, GWLP_USERDATA))
		Return SelectedControl
	End Function
#Else
	Function Designer.GetControl(CtrlHandle As HWND) As Any Ptr
		Return Cast(Any Ptr, GetWindowLongPtr(CtrlHandle, GWLP_USERDATA))
	End Function
#EndIf

'Operator Designer.Cast As Control Ptr
'   Return @This
'End Operator

Sub Designer.ProcessMessage(BYREF message As Message)
    
    'message.Result = -1    

End Sub

'Sub Designer.HandleIsAllocated(BYREF Sender As Control)
'    With QDesigner(@Sender)
'        .CreateDots(GetParent(Sender.Handle))
'        .Dialog = Sender.Handle
'            'dim as RECT R
'            'GetClientRect(Sender.Handle, @R)
'            'if .FShowGrid then
'              '.DrawGrid(GetDC(Sender.Handle), R)
'            'else
'              'FillRect(GetDC(Sender.Handle), @R, cast(HBRUSH, 16))
'            'end if 
'    End With
'End Sub

#IfNDef __USE_GTK__    
	function Designer.EnumChildsProc(hDlg as HWND, lParam as LPARAM) as Boolean
		if lParam then
			with *cast(WindowList ptr, lParam)
				.Count = .Count + 1
				.Child = reallocate(.Child, .Count * sizeof(HWND))
				.Child[.Count-1] = hDlg
			end with
		end if   
		return true
	end function
#EndIf

#IfNDef __USE_GTK__
	sub Designer.GetChilds(Parent as HWND = 0)
		FChilds.Count = 0
		FChilds.Child = callocate(0)
		EnumChildWindows(iif(Parent, Parent, FDialog), cast(WNDENUMPROC, @EnumChildsProc), cint(@FChilds))
	end sub
#EndIf

#IfNDef __USE_GTK__
	sub Designer.ClipCursor(hDlg as HWND)
		 dim as RECT R
		 if IsWindow(hDlg) then
			 GetClientRect(hDlg, @R)
			 MapWindowPoints(hDlg, 0,cast(POINT ptr, @R), 2)
			 .ClipCursor(@R)
		 else
			 .ClipCursor(0)
		 end if
	end sub
#EndIf

sub Designer.DrawBox(R as RECT)
	#IfNDef __USE_GTK__
		 FHDc = GetDCEx(FDialog, 0, DCX_PARENTCLIP or DCX_CACHE or DCX_CLIPSIBLINGS)
		 Brush = GetStockObject(NULL_BRUSH)
		 PrevBrush = SelectObject(FHDc, Brush)
		 SetROP2(FHDc, R2_NOT)
		 Rectangle(FHDc, R.Left, R.Top, R.Right, R.Bottom)
		 SelectObject(FHDc, PrevBrush)
		 ReleaseDc(FDialog, FHDc)
	#EndIf
end sub

sub Designer.DrawBoxs(R() as RECT)
    '''for future implementation of multiselect suport
    for i as integer = 0 to ubound(R)
        DrawBox(R(i))
    next   
end sub

function Designer.GetClassAcceptControls(AClassName as string) as Boolean
    '''for future implementation of classbag struct
    return false
end function

sub Designer.Clear
	#IfNDef __USE_GTK__
		GetChilds
		for i as integer = FChilds.Count -1 to 0 step -1
			DestroyWindow(FChilds.Child[i])
		next
    #EndIf
    HideDots
end sub

function Designer.ClassExists() as Boolean
    'FClass = SelectedClass
    #IfNDef __USE_GTK__
		dim as WNDCLASSEX wcls
		wcls.cbSize = sizeof(wcls)
	#EndIf
    return SelectedClass <> "" 'and (GetClassInfoEx(0, FClass, @wcls) or GetClassInfoEx(instance, FClass, @wcls))
end function

'function Designer.GetClassName(hDlg as HWND) as string
    'dim as Wstring Ptr s
    'WReallocate s, 256
    '*s = space(255)
    'dim as integer L = .GetClassName(hDlg, s, Len(*s))
    'return trim(Left(*s, L))
'end function   
'
#IfDef __USE_GTK__
	function Designer.ControlAt(Parent as Any Ptr, X as integer,Y as integer) as Any Ptr
#Else
	function Designer.ControlAt(Parent as HWND,X as integer,Y as integer) as HWND
#EndIf
	#IfDEf __USE_GTK__
		If Parent = 0 Then Return Parent
		Dim As Integer ALeft, ATop, AWidth, AHeight
		Dim As Any Ptr Ctrl
		For i As Integer = iGet(ReadPropertyFunc(Parent, "ControlCount")) - 1 To 0 Step -1
			Ctrl = ControlByIndexFunc(Parent, i)
			If Ctrl Then
				ControlGetBoundsSub(Ctrl, @ALeft, @ATop, @AWidth, @AHeight)
				If (X > ALeft and X < ALeft + AWidth) and (Y > ATop and Y < ATop + AHeight) Then
					Return ControlAt(Ctrl, X - ALeft, Y - ATop)
				End If
			End If
		Next i
		Return Parent
	#Else
		Dim Result As Hwnd = ChildWindowFromPoint(Parent, Type<Point>(X, Y))
		If Result = 0 Or Result = Parent Then
			Return Parent
		Else
			Dim As Rect R
			GetWindowRect Result, @R
			MapWindowPoints 0, Parent, Cast(Point Ptr, @R), 2
			Return ControlAt(Result, X - R.Left, Y - R.Top)
		End if
		dim as RECT R
		GetChilds(Parent)
		for i as integer = 0 to FChilds.Count -1
			if IsWindowVisible(FChilds.Child[i]) then
			   GetWindowRect(FChilds.Child[i], @R)
			   MapWindowPoints(0, Parent, cast(POINT ptr, @R) ,2)
			   if (X > R.Left and X < R.Right) and (Y > R.Top and Y < R.Bottom) then
				  return FChilds.Child[i]
			   end If
			end if
		next i
		#EndIf
    return Parent
end function

#IfDef __USE_GTK__
	Function Dot_Draw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
		cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
		cairo_rectangle(cr, 0, 0, 6, 6)
	    cairo_fill(cr)
		Return False
	End Function
	
	Function Dot_ExposeEvent(widget As GtkWidget Ptr, event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
		Dim As cairo_t Ptr cr = gdk_cairo_create(event->window)
		Dot_Draw(widget, cr, data1)
		cairo_destroy(cr)
		Return False
	End Function
#EndIf

sub Designer.CreateDots(ParentCtrl As Control Ptr)
	#IfDef __USE_GTK__
		Dim As GdkDisplay Ptr pdisplay
		Dim As GdkCursor Ptr gcurs
	#EndIf
	For i As Integer = 0 to 7
		#IfDef __USE_GTK__
			FDots(i) = gtk_layout_new(NULL, NULL)
			'g_object_ref(FDots(i))
			gtk_layout_put(gtk_layout(ParentCtrl->layoutwidget), FDots(i), 0, 0)
			gtk_widget_set_size_request(FDots(i), 6, 6)
			#IfDef __USE_GTK3__
				g_signal_connect(FDots(i), "draw", G_CALLBACK(@Dot_Draw), @This)
			#Else
				g_signal_connect(FDots(i), "expose-event", G_CALLBACK(@Dot_ExposeEvent), @This)
			#EndIf
			gtk_widget_realize(FDots(i))
			pdisplay = gtk_widget_get_display(FDots(i))
			Select Case i
			case 0, 4 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNWSE)
			case 1, 5 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNS)
			case 2, 6 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNESW)
			case 3, 7 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeWE)
			End Select
			#IfDef __USE_GTK3__
				gdk_window_set_cursor(gtk_widget_get_window(FDots(i)), gcurs)
			#Else
				gdk_window_set_cursor(gtk_layout_get_bin_window(gtk_layout(FDots(i))), gcurs)
			#EndIf
		#Else
			FDots(i) = CreateWindowEx(0, "DOT", "", WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN, 0, 0, 6, 6, ParentCtrl->Handle, 0, instance, 0)
			If IsWindow(FDots(i)) Then 
				SetWindowLong(FDots(i), 0, CInt(@This))
			End If
		#EndIf
	Next i
End Sub

sub Designer.DestroyDots
    for i as integer = 7 to 0 step -1
		#IfDef __USE_GTK__
			gtk_widget_destroy(FDots(i))
		#Else
			DestroyWindow(FDots(i))
		#EndIf
    next i
end sub

sub Designer.HideDots
    for i as integer = 0 to 7
		#IfDef __USE_GTK__
			If gtk_is_widget(FDots(i)) Then gtk_widget_set_visible(FDots(i), False)
		#Else
			ShowWindow(FDots(i), SW_HIDE)
		#EndIf
    next i
end sub

#IfDef __USE_GTK__
	Sub ScreenToClient(widget As GtkWidget Ptr, P As Point Ptr)
		Dim As gint x, y
        gdk_window_get_origin(gtk_widget_get_window(widget), @x, @y)
        P->x = P->x - x
        P->y = P->y - y
	End Sub
#EndIf

#IfDef __USE_GTK__
	Sub GetPosToClient(widget As GtkWidget Ptr, Client As GtkWidget Ptr, x As Integer Ptr, y As Integer Ptr, x1 As Integer = -1, y1 As Integer = -1)
		If widget = 0 Or widget = Client Then Return
		Dim allocation As GtkAllocation
		gtk_widget_get_allocation(widget, @allocation)
		*x = *x + allocation.x
		*y = *y + allocation.y
		If x1 <> -1 Then *x = x1
		If y1 <> -1 Then *y = y1
		GetPosToClient gtk_widget_get_parent(widget), Client, x, y
	End Sub
	
	sub Designer.MoveDots(Control as GtkWidget Ptr, bSetFocus As Boolean = True, Left1 As Integer = -1, Top1 As Integer = -1, Width1 As Integer = -1, Height1 As Integer = -1)
#Else
	sub Designer.MoveDots(Control as HWND, bSetFocus As Boolean = True)
#EndIf
		dim as RECT R
		dim as POINT P
		dim as integer iWidth, iHeight
		#IfDef __USE_GTK__
		if gtk_is_widget(Control) Then
		#Else
		if IsWindow(Control) Then
		#EndIf
			FSelControl = Control
			'if Control <> FDialog then
			#IfDef __USE_GTK__
			Dim As Integer x, y ', x1, y1
'			gtk_widget_set_has_window(Control, True)
'			gtk_widget_set_has_window(FDialogParent, True)
'  	      	gtk_widget_realize(Control)
'  	      	gtk_widget_realize(FDialogParent)
'  	      	gdk_window_get_origin(gtk_widget_get_window(Control), @x, @y)
'  	      	gdk_window_get_origin(gtk_widget_get_window(FDialogParent), @x1, @y1)
  	      	gtk_widget_realize(Control)
  	      	#IfDef __USE_GTK3__
	  	      	iWidth = gtk_widget_get_allocated_width(Control)
	  	      	iHeight = gtk_widget_get_allocated_height(Control)
	  	    #Else
	  	    	iWidth = Control->allocation.width
	  	      	iHeight = Control->allocation.height
  	      	#EndIf
  	      	If Width1 <> -1 Then iWidth = Width1
  	      	If Height1 <> -1 Then iHeight = Height1
		   	GetPosToClient Control, FDialogParent, @x, @y, Left1, Top1
		   	P.x     = x
			P.y     = y
			Dim As GdkDisplay Ptr pdisplay
			Dim As GdkCursor Ptr gcurs
			for i as integer = 0 to 7
				gtk_container_remove(gtk_container(FDialogParent), FDots(i))
				FDots(i) = gtk_layout_new(NULL, NULL)
				gtk_widget_set_size_request(FDots(i), 6, 6)
				gtk_widget_set_events(FDots(i), _
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
				g_signal_connect(FDots(i), "event", G_CALLBACK(@DotWndProc), @This)
				#IfDef __USE_GTK3__
					g_signal_connect(FDots(i), "draw", G_CALLBACK(@Dot_Draw), @This)
				#Else
					g_signal_connect(FDots(i), "expose-event", G_CALLBACK(@Dot_ExposeEvent), @This)
				#EndIf
				Select Case i
				Case 0: gtk_layout_put(gtk_layout(FDialogParent), FDots(0), P.X-6, P.Y-6)
				Case 1: gtk_layout_put(gtk_layout(FDialogParent), FDots(1), P.X+iWidth/2-3, P.Y-6)
				Case 2: gtk_layout_put(gtk_layout(FDialogParent), FDots(2), P.X+iWidth, P.Y-6)
				Case 3: gtk_layout_put(gtk_layout(FDialogParent), FDots(3), P.X+iWidth, P.Y + iHeight/2-3)
				Case 4: gtk_layout_put(gtk_layout(FDialogParent), FDots(4), P.X+iWidth, P.Y + iHeight)
				Case 5: gtk_layout_put(gtk_layout(FDialogParent), FDots(5), P.X+iWidth/2-3, P.Y + iHeight)
				Case 6: gtk_layout_put(gtk_layout(FDialogParent), FDots(6), P.X-6, P.Y + iHeight)
				Case 7: gtk_layout_put(gtk_layout(FDialogParent), FDots(7), P.X-6, P.Y + iHeight/2-3)
				End Select
				gtk_widget_realize(FDots(i))
				pdisplay = gtk_widget_get_display(FDots(i))
				Select Case i
				case 0, 4 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNWSE)
				case 1, 5 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNS)
				case 2, 6 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNESW)
				case 3, 7 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeWE)
				End Select
				#IfDef __USE_GTK3__
					gdk_window_set_cursor(gtk_widget_get_window(FDots(i)), gcurs)
				#Else
					gdk_window_set_cursor(gtk_layout_get_bin_window(gtk_layout(FDots(i))), gcurs)
				#EndIf
				g_object_set_data(G_OBJECT(FDots(i)), "@@@Control", Control)
				g_object_set_data(G_OBJECT(FDots(i)), "@@@Control2", SelectedControl)
				'SetParent(FDots(i), GetParent(Control))
				'SetProp(FDots(i),"@@@Control", Control)
				'BringWindowToTop FDots(i)
				'gdk_window_raise(gtk_widget_get_window(FDots(i)))
				gtk_widget_show(FDots(i))
			next i
		   #Else
			GetWindowRect(Control, @R)
			iWidth  = R.Right  - R.Left
			iHeight = R.Bottom - R.Top
			P.x     = R.Left
			P.y     = R.Top
			ScreenToClient(GetParent(FDialog), @P)
			'SetWindowPos(FDots(0), HWND_TOP, P.X-3, P.Y-3, 0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			'SetWindowPos(FDots(1), HWND_TOP, P.X+iWidth/2-3, P.Y-3, 0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			'SetWindowPos(FDots(2), HWND_TOP, P.X+iWidth-3, P.Y-3, 0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			'SetWindowPos(FDots(3), HWND_TOP, P.X+iWidth-3, P.Y + iHeight/2-3, 0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			'SetWindowPos(FDots(4), HWND_TOP, P.X+iWidth-3, P.Y + iHeight-3, 0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			'SetWindowPos(FDots(5), HWND_TOP, P.X+iWidth/2-3, P.Y + iHeight-3,0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			'SetWindowPos(FDots(6), HWND_TOP, P.X-3, P.Y + iHeight-3, 0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			'SetWindowPos(FDots(7), HWND_TOP, P.X-3, P.Y + iHeight/2-3, 0, 0, SWP_NOSIZE OR SWP_SHOWWINDOW)
			MoveWindow FDots(0), P.X-6, P.Y-6, 6, 6, True
			MoveWindow FDots(1), P.X+iWidth/2-3, P.Y-6, 6, 6, True
			MoveWindow FDots(2), P.X+iWidth, P.Y-6, 6, 6, True
			MoveWindow FDots(3), P.X+iWidth, P.Y + iHeight/2-3, 6, 6, True
			MoveWindow FDots(4), P.X+iWidth, P.Y + iHeight, 6, 6, True
			MoveWindow FDots(5), P.X+iWidth/2-3, P.Y + iHeight, 6, 6, True
			MoveWindow FDots(6), P.X-6, P.Y + iHeight, 6, 6, True
			MoveWindow FDots(7), P.X-6, P.Y + iHeight/2-3, 6, 6, True
			for i as integer = 0 to 7
				'SetParent(FDots(i), GetParent(Control))
				SetProp(FDots(i),"@@@Control", Control)
				BringWindowToTop FDots(i)
				ShowWindow(FDots(i), SW_SHOW)
			next i
			#EndIf
			If bSetFocus Then
				#IfDef __USE_GTK__
					gtk_widget_grab_focus(layoutwidget)
				#Else
					SetFocus(Dialog)
				#EndIf
				'else
				'   HideDots
				'end If
				if OnChangeSelection then OnChangeSelection(this, GetControl(FSelControl), p.x, p.y, iWidth, iHeight)
			End If
		else
		   HideDots
		end if
	end sub

#IfDef __USE_GTK__
	function Designer.IsDot(hDlg as GtkWidget Ptr) as integer
		 dim as string s
		 'if UCase(s) = "DOT" then
			for i as integer = 0 to 7
			   if FDots(i) = hDlg then return i
			next i
		return -1
	end function
#Else
	function Designer.IsDot(hDlg as HWND) as integer
		 dim as string s
		 If GetWindowLong(hDlg, 0) = Cint(@This) Then
		 'if UCase(s) = "DOT" then
			for i as integer = 0 to 7
			   if FDots(i) = hDlg then return i
			next i
		end If
		return -1
	end function
#EndIf

sub Designer.DblClick(X as integer, Y as Integer, Shift as integer)
    #IfDef __USE_GTK__
    	SelectedControl = ControlAt(DesignControl, X, Y)
		If OnDblClickControl Then OnDblClickControl(This, SelectedControl)
    #Else
	    FSelControl = ControlAt(FDialog, X, Y)
		If OnDblClickControl Then OnDblClickControl(This, GetControl(FSelControl))
	#EndIf
End Sub

sub Designer.MouseDown(X as integer, Y as Integer, Shift as integer)
    dim as POINT P
    dim as RECT R
    FDown   = true
    FBeginX = iif(FSnapToGrid,(X\FStepX)*FStepX,X)
    FBeginy = iif(FSnapToGrid,(Y\FStepY)*FStepY,y)
    FEndX   = FBeginX
    FEndY   = FBeginY
    FNewX   = FBeginX
    FNewY   = FBeginY
    HideDots
    #IfDef __USE_GTK__
    	SelectedControl = ControlAt(DesignControl, X, Y)
    	FSelControl = ReadPropertyFunc(SelectedControl, "Widget")
    #Else
    	ClipCursor(GetParent(FDialog))
		FSelControl = ControlAt(FDialog, X, Y)
		SelectedControl = GetControl(FSelControl)
    #EndIf
    FDotIndex   = IsDot(FOverControl)
    if FDotIndex <> -1 then
        FCanInsert  = false
        FCanMove    = false
        FCanSize    = true
        #IfDef __USE_GTK__
        	FSelControl = g_object_get_data(G_OBJECT(FDots(FDotIndex)), "@@@Control")
        	SelectedControl = g_object_get_data(G_OBJECT(FDots(FDotIndex)), "@@@Control2")
        #Else
			if not IsWindow(FSelControl) then
				FSelControl = GetProp(FDots(FDotIndex),"@@@Control")
				SelectedControl = GetControl(FSelControl)
			end if
		#EndIf   
        'BringWindowToTop(FSelControl)
        #IfDef __USE_GTK__
        	ControlGetBoundsSub(SelectedControl, @FLeft, @FTop, @FWidth, @FHeight)
        #Else
   			GetWindowRect(FSelControl, @R)
			P.X     = R.Left
	        P.Y     = R.Top
	        FWidth  = R.Right - R.Left
	        FHeight = R.Bottom - R.Top
        	ScreenToClient(GetParent(FSelControl), @P) 
	        FLeft   = P.X
	        FTop    = P.Y
        #EndIf
        #IfNDef __USE_GTK__
			select case FDotIndex
			case 0: SetCursor(crSizeNWSE)
			case 1: SetCursor(crSizeNS)
			case 2: SetCursor(crSizeNESW)
			case 3: SetCursor(crSizeWE)
			case 4: SetCursor(crSizeNWSE)
			case 5: SetCursor(crSizeNS)
			case 6: SetCursor(crSizeNESW)
			case 7: SetCursor(crSizeWE)
			end select
			SetCapture(FDialog)
		#EndIf
   else
		if FSelControl <> FDialog then
		   'BringWindowToTop(FSelControl)
		   if ClassExists then
			   FCanInsert = true
			   FCanMove   = false
			   FCanSize   = false
			   #IfDef __USE_GTK__
			   		gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crCross))
			   #Else
			   		SetCursor(crCross)
			   #EndIf
		   else
			   FCanInsert = false
			   FCanMove   = true
			   FCanSize   = false
			   #IfDef __USE_GTK__
			   		gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crSize))
			   #Else
			   		SetCursor(crSize) :SetCapture(FDialog)
			   #EndIf
			   if OnChangeSelection then OnChangeSelection(this, SelectedControl)
			   #IfDef __USE_GTK__
			   		ControlGetBoundsSub(SelectedControl, @FLeft, @FTop, @FWidth, @FHeight)
			   #Else
				   GetWindowRect(FSelControl, @R)
				   P.X     = R.Left
				   P.Y     = R.Top
				   FWidth  = R.Right - R.Left
				   FHeight = R.Bottom - R.Top
				   ScreenToClient(GetParent(FSelControl), @P)
				   FLeft   = P.X
				   FTop    = P.Y
			   #EndIf
		   end if
		else
		   HideDots
		   FCanInsert = iif(ClassExists, true, false)
		   FCanMove   = 0
		   FCanSize   = False
		   if FCanInsert then
		   		#IfDef __USE_GTK__
		   			gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crCross))
		   		#Else
			   		SetCursor(crCross)
			   #EndIf
		   else
			  if OnChangeSelection then OnChangeSelection(this, SelectedControl)
		   end if
		   If Not FCanInsert And Not FCanMove Then
		   		#IfNDef __USE_GTK__
				FHDC = GetDC(FDialog)
				'SetROP2(hdc, R2_NOTXORPEN)
				DrawFocusRect(Fhdc, @type<RECT>(FBeginX, FBeginY, FNewX, FNewY))
				FOldX = FNewX
				FOldY = FNewY
				ReleaseDC(FDialog, Fhdc)
				#EndIf
			End If
		end if
    end if   
end sub

sub Designer.MouseMove(X as integer, Y as Integer, Shift as integer)
    dim as POINT P
    FNewX = iif(FSnapToGrid,(X\FStepX)*FStepX,X)
    FNewY = iif(FSnapToGrid,(Y\FStepY)*FStepY,Y)
    'dim hdc As HDC = GetDC(FHandle)
    if FDown then
       if FCanInsert then
			#IfDef __USE_GTK__
				gtk_widget_queue_draw(layoutwidget)
			#Else
				SetCursor(crCross)
			#EndIf
           DrawBox(type<RECT>(FBeginX, FBeginY, FNewX, FNewY))
           DrawBox(type<RECT>(FBeginX, FBeginY, FEndX, FEndY))    
       end if
       if FCanSize then
			FLeftNew = FLeft
			FTopNew = FTop
			FWidthNew = FWidth
			FHeightNew = FHeight
			#IfDef __USE_GTK__
				select case FDotIndex
				case 0: FLeftNew = FLeft + (FNewX - FBeginX): FTopNew = FTop + (FNewY - FBeginY): FWidthNew = FWidth - (FNewX - FBeginX): FHeightNew = FHeight - (FNewY - FBeginY)
				case 1: FTopNew = FTop + (FNewY - FBeginY): FHeightNew = FHeight - (FNewY - FBeginY)
				case 2: FTopNew = FTop + (FNewY - FBeginY): FWIdthNew = FWidth + (FNewX - FBeginX): FHeightNew = FHeight - (FNewY - FBeginY)
				case 3: FWidthNew = FWidth + (FNewX - FBeginX)
				case 4: FWidthNew = FWidth + (FNewX - FBeginX): FHeightNew = FHeight + (FNewY - FBeginY)
				case 5: FHeightNew = FHeight + (FNewY - FBeginY)
				case 6: FLeftNew = FLeft + (FNewX - FBeginX): FWidthNew = FWidth - (FNewX - FBeginX): FHeightNew = FHeight + (FNewY - FBeginY)
				case 7: FLeftNew = FLeft - (FBeginX - FNewX): FWidthNew = FWidth + (FBeginX - FNewX)
				end Select
				ControlSetBoundsSub(SelectedControl, FLeftNew, FTopNew, FWidthNew, FHeightNew)
			#Else
				select case FDotIndex
				case 0: FLeftNew = FLeft + (FNewX - FBeginX): FTopNew = FTop + (FNewY - FBeginY): FWidthNew = FWidth - (FNewX - FBeginX): FHeightNew = FHeight - (FNewY - FBeginY)
				case 1: FTopNew = FTop + (FNewY - FBeginY): FHeightNew = FHeight - (FNewY - FBeginY)
				case 2: FTopNew = FTop + (FNewY - FBeginY): FWIdthNew = FWidth + (FNewX - FBeginX): FHeightNew = FHeight - (FNewY - FBeginY)
				case 3: FWidthNew = FWidth + (FNewX - FBeginX)
				case 4: FWidthNew = FWidth + (FNewX - FBeginX): FHeightNew = FHeight + (FNewY - FBeginY)
				case 5: FHeightNew = FHeight + (FNewY - FBeginY)
				case 6: FLeftNew = FLeft + (FNewX - FBeginX): FWidthNew = FWidth - (FNewX - FBeginX): FHeightNew = FHeight + (FNewY - FBeginY)
				case 7: FLeftNew = FLeft - (FBeginX - FNewX): FWidthNew = FWidth + (FBeginX - FNewX)
				end Select
				'ControlSetBoundsSub(SelectedControl, FLeftNew, FTopNew, FWidthNew, FHeightNew)
				MoveWindow(FSelControl, FLeftNew, FTopNew, FWidthNew, FHeightNew, true)
			#EndIf
       end If
       if FCanMove then
          if FBeginX <> FEndX Or FBeginY <> FEndY then
			#IfDef __USE_GTK__
				ControlSetBoundsSub(SelectedControl, FLeft + (FNewX - FBeginX), FTop + (FNewY - FBeginY), FWidth, FHeight)
			#Else
                MoveWindow(FSelControl, FLeft + (FNewX - FBeginX), FTop + (FNewY - FBeginY), FWidth, FHeight, true)
			#EndIf
          end if
       end if
        If Not FCanInsert And Not FCanMove Then 'And Not FCanSize
			#IfDef __USE_GTK__
				gtk_widget_queue_draw(layoutwidget)
			#Else
				FHDC = GetDC(FDialog)
				'SetROP2(hdc, R2_NOTXORPEN)
				DrawFocusRect(Fhdc, @type<RECT>(FBeginX, FBeginY, FOldX, FOldY))
				DrawFocusRect(Fhdc, @type<RECT>(FBeginX, FBeginY, FNewX, FNewY))
			#EndIf
            FOldX = FNewX
            FOldY = FNewY
            #IfNDef __USE_GTK__
				ReleaseDC(FDialog, Fhdc)
			#EndIf
        End If
    else
       P = type(X, Y)
       #IfDef __USE_GTK__
       		
       #Else
		   ClientToScreen(FDialog, @P)
		   ScreenToClient(GetParent(FDialog), @P)
		   FOverControl = ChildWindowFromPoint(GetParent(FDialog), P)
			if OnMouseMove then OnMouseMove(this, X, Y, GetControl(FOverControl))
		   dim as integer Id = IsDot(FOverControl)
		   if Id <> -1 then
			  select case Id
			  case 0 : SetCursor(crSizeNWSE)
			  case 1 : SetCursor(crSizeNS)
			  case 2 : SetCursor(crSizeNESW)
			  case 3 : SetCursor(crSizeWE)
			  case 4 : SetCursor(crSizeNWSE)
			  case 5 : SetCursor(crSizeNS)
			  case 6 : SetCursor(crSizeNESW)
			  case 7 : SetCursor(crSizeWE)
			  end select
		   else
			  if GetAncestor(FOverControl,GA_ROOTOWNER) <> FDialog then
				  ReleaseCapture
			  end if   
			  SetCursor(crArrow)
			  ClipCursor(0)
		   end if
       #EndIF
    end if
    FEndX = FNewX
    FEndY = FNewY
end sub

Function Designer.GetContainerControl(Ctrl As Any Ptr) As Any Ptr
	If ControlIsContainerFunc <> 0 Then
		If Ctrl Then
			If ControlIsContainerFunc(Ctrl) Then
				Return Ctrl
			ElseIf ReadPropertyFunc <> 0 AndAlso ReadPropertyFunc(Ctrl, "Parent") Then
				Return GetContainerControl(ReadPropertyFunc(Ctrl, "Parent"))
			End If
		End If
	End If
	Return Ctrl
End Function

sub Designer.MouseUp(X as integer, Y as Integer, Shift as integer)
    dim as RECT R
    if FDown then
        FDown = false
        if Not FCanMove And Not FCanInsert And Not FCanSize Then
			#IfDef __USE_GTK__
				gtk_widget_queue_draw(layoutwidget)
				Dim As Integer ALeft, ATop, AWidth, AHeight
				Dim As Any Ptr Ctrl
				SelectedControl = DesignControl
				FSelControl = FDialog
				For i As Integer = 0 To iGet(ReadPropertyFunc(DesignControl, "ControlCount")) - 1
					Ctrl = ControlByIndexFunc(DesignControl, i)
					If Ctrl Then
						ControlGetBoundsSub(Ctrl, @ALeft, @ATop, @AWidth, @AHeight)
						If (ALeft > FBeginX and ALeft + AWidth < FEndX) and (ATop > FBeginY and ATop + AHeight < FEndY) Then
							SelectedControl = Ctrl
							FSelControl = ReadPropertyFunc(SelectedControl, "Widget")
							Exit For
						End If
					End If
				Next i
				MoveDots(FSelControl)
			#Else
				FHDC = GetDC(FDialog)
				DrawFocusRect(Fhdc, @type<RECT>(FBeginX, FBeginY, FNewX, FNewY))
				ReleaseDC(FDialog, Fhdc)
				SelectedControl = DesignControl
				FSelControl = FDialog
				dim as RECT R
				GetChilds()
				for i as integer = 0 to FChilds.Count -1
					if IsWindowVisible(FChilds.Child[i]) then
						GetWindowRect(FChilds.Child[i], @R)
						MapWindowPoints(0, FDialog, cast(POINT ptr, @R) ,2)
						if (R.Left > FBeginX And R.Right < FEndX) and (R.Top > FBeginY and R.Bottom < FEndY) then
							FSelControl = FChilds.Child[i]
							SelectedControl = GetControl(FSelControl)
							Exit For
						end If
					end if
				next i
				MoveDots(FSelControl)
			#EndIf
        end if
        if FCanInsert then
           if (FBeginX > FEndX and FBeginY > FEndY) then
               swap FBeginX, FNewX
               swap FBeginY, FNewY
           end if
           if (FBeginX > FEndX and FBeginY < FEndY) then
               swap FBeginX, FNewX
           end if
           if (FBeginX < FEndX and FBeginY > FEndY) then
               swap FBeginY, FNewY
           end if
           DrawBox(Type<RECT>(FBeginX, FBeginY, FNewX, FNewY))
           #IfDef __USE_GTK__
           		gtk_widget_queue_draw(layoutwidget)
           #EndIf
           'if GetClassAcceptControls(GetClassName(FSelControl)) Then
               'R.Left   = FBeginX
               'R.Top    = FBeginY
               'R.Right  = FNewX
               'R.Bottom = FNewY
               'MapWindowPoints(FDialog, FSelControl, cast(POINT ptr, @R), 2)
               'if OnInsertingControl then
                   'OnInsertingControl(this, FClass, FStyleEx, FStyle, FID)
               'end if   
               'CreateControl(FClass, "", "", FSelControl, R.Left, R.Top, R.Right -R.Left, R.Bottom -R.Top)
           'else
            FClass = SelectedClass
            if OnInsertingControl then
                FName = SelectedClass
                OnInsertingControl(this, SelectedClass, FName)
            end if
            If SelectedType = 3 Or SelectedType = 4 Then
                Dim cpnt As Any Ptr = CreateComponent(SelectedClass, FName)
                if OnInsertComponent then OnInsertComponent(this, FClass, cpnt)
            Else
				SelectedControl = GetContainerControl(SelectedControl)
					Dim As Rect R
					If SelectedControl <> DesignControl Then
						#IfNDef __USE_GTK__
						GetWindowRect FSelControl, @R
						MapWindowPoints 0, FDialog, Cast(Point Ptr, @R), 2
						#EndIf
					End If
					Dim ctr As Any Ptr
					'#IfDef __USE_GTK__
						ctr = SelectedControl
					'#Else
					'	ctr = Cast(Any Ptr, GetWindowLongPtr(FSelControl, GWLP_USERDATA))
					'#EndIf
					CreateControl(SelectedClass, FName, FName, ctr, FBeginX - R.Left, FBeginY - R.Top, FNewX -FBeginX, FNewY -FBeginY)
					if FSelControl then
						#IfDef __USE_GTK__
						Dim bTrue As Boolean = True
						WritePropertyFunc(SelectedControl, "Visible", @bTrue)
						#Else
						LockWindowUpdate(FSelControl)
						BringWindowToTop(FSelControl)
						#EndIf
						if OnInsertControl then OnInsertControl(this, FClass, SelectedControl, FBeginX - R.Left, FBeginY - R.Top, FNewX -FBeginX, FNewY -FBeginY)
						#IfDef __USE_GTK__
							MoveDots(FSelControl, , FBeginX - R.Left, FBeginY - R.Top, FNewX -FBeginX, FNewY -FBeginY)
						#Else
							MoveDots(FSelControl)
						#EndIf
						#IfNDef __USE_GTK__
						LockWindowUpdate(0)
						#EndIf
					end if
           end If
           FCanInsert = false
        end if
        if FCanSize then
			MoveDots(FSelControl)
			FCanSize = false
            If FBeginX <> FNewX OrElse FBeginY <> FNewY Then
				if OnModified then OnModified(this, GetControl(FSelControl), FLeftNew, FTopNew, FWidthNew, FHeightNew)
            End If
        end If
        if FCanMove then
			MoveDots(FSelControl)
			FCanMove = false
            If FBeginX <> FNewX OrElse FBeginY <> FNewY Then
                if OnModified then OnModified(this, GetControl(FSelControl), FLeft + (FNewX - FBeginX), FTop + (FNewY - FBeginY), FWidth, FHeight)
            End If
        end if
        FBeginX = FEndX
        FBeginY = FEndY
        FNewX   = FBeginX
        FNewY   = FBeginY
        #IfDef __USE_GTK__
        	gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crArrow))
        #Else
			ClipCursor(0)
			ReleaseCapture
		#EndIf
    else
		#IfDef __USE_GTK__
			gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crArrow))
		#Else
			ClipCursor(0)
		#EndIf
    end if
end sub

Sub Designer.DeleteControl(Ctrl As Any Ptr)
	if Ctrl then
		if Ctrl <> DesignControl then
		   if OnDeleteControl then OnDeleteControl(this, Ctrl)
		   If RemoveControlSub Then RemoveControlSub(DesignControl, Ctrl)
		   If DeleteComponentFunc Then DeleteComponentFunc(Ctrl)
		   'if OnModified then OnModified(this, Ctrl, -1, -1, -1, -1)
		   FSelControl = FDialog
		   SelectedControl = DesignControl
		   MoveDots FSelControl
	   end if
	End if
End Sub
'sub Designer.DeleteControl(hDlg as HWND)
'	if IsWindow(hDlg) then
'		if hDlg <> FDialog then
'		   if OnDeleteControl then OnDeleteControl(this, GetControl(hDlg))
'		   DestroyWindow(hDlg)
'		   if OnModified then OnModified(this, GetControl(hDlg))
'		   FSelControl = FDialog
'		   MoveDots FSelControl
'	   end if
'	end if
'end sub

sub Designer.CopyControl()
	#IfNDef __USE_GTK__
		if IsWindow(FSelControl) then
			if FSelControl <> FDialog then
				'помещаем данные в буфер обмена
				Dim As UINTeger fformat = RegisterClipboardFormat("VFEFormat") 'регистрируем наш формат данных
				
					If (OpenClipboard(NULL)) Then 'для работы с буфером обмена его нужно открыть
							
				   'заполним нашу структуру данными
							
				   Dim As HGLOBAL hgBuffer
							
				   EmptyClipboard()  'очищаем буфер
							
				   hgBuffer = GlobalAlloc(GMEM_DDESHARE, sizeof(UInteger)) 'выделим память
							
				   Dim As UInteger Ptr buffer = Cast(UInteger Ptr, GlobalLock(hgBuffer))
							
				   'запишем данные в память
							
				   *buffer = Cast(UInteger, GetControl(FSelControl))
							
				   'поместим данные в буфер обмена
							
				   GlobalUnlock(hgBuffer)
							
				   SetClipboardData(fformat, hgBuffer) 'помещаем данные в буфер обмена
							
				   CloseClipboard() 'после работы с буфером, его нужно закрыть
				End If
				
		   end if
		end if
	#EndIf
end sub

sub Designer.CutControl()
	#IfNDef __USE_GTK__
		if IsWindow(FSelControl) then
			if FSelControl <> FDialog then
			   CopyControl
			   if OnDeleteControl then OnDeleteControl(this, GetControl(FSelControl))
			   If ControlFreeWndSub Then ControlFreeWndSub(GetControl(FSelControl))
			   'if OnModified then OnModified(this, GetControl(FSelControl))
			   FSelControl = FDialog
			   MoveDots FSelControl
		   end if
		end if
	#EndIf
end sub

sub Designer.PasteControl()
	#IfNDef __USE_GTK__
		if IsWindow(FSelControl) then
			'прочитаем наши данные из буфера обмена
			'вызываем второй раз, чтобы просто получить формат
			
			Dim As UINTeger fformat = RegisterClipboardFormat("VFEFormat")
					
			Dim ParentCtrl As Any Ptr = GetControl(FSelControl)
			If ControlIsContainerFunc <> 0 AndAlso ReadPropertyFunc <> 0 Then
				If Not ControlIsContainerFunc(ParentCtrl) Then ParentCtrl = ReadPropertyFunc(ParentCtrl, "Parent")
			End If
			If ClipBoard.HasFormat(fformat) Then
				if ( OpenClipboard(NULL) ) Then
							
					'извлекаем данные из буфера
							
					Dim As HANDLE hData = GetClipboardData(fformat)
							
					Dim As UInteger Ptr buffer = Cast(UInteger Ptr, GlobalLock( hData ))
									
					GlobalUnlock( hData )
							
					CloseClipboard()
					Dim As Any Ptr Value = Cast(Any Ptr, *buffer)
					If ReadPropertyFunc <> 0 AndAlso ControlGetBoundsSub <> 0 Then
						if OnInsertingControl then
							FName = WGet(ReadPropertyFunc(Value, "Name"))
							OnInsertingControl(this, WGet(ReadPropertyFunc(Value, "ClassName")), FName)
						end if
						ControlGetBoundsSub(Value, @FLeft, @FTop, @FWidth, @FHeight)
						CreateControl(WGet(ReadPropertyFunc(Value, "ClassName")), FName, WGet(ReadPropertyFunc(Value, "Text")), ParentCtrl, FLeft + 10, FTop + 10, FWidth, FHeight)
						if FSelControl then
							LockWindowUpdate(FSelControl)
							BringWindowToTop(FSelControl)
							if OnInsertControl then OnInsertControl(this, WGet(ReadPropertyFunc(Value, "ClassName")), GetControl(FSelControl), FLeft + 10, FTop + 10, FWidth, FHeight)
							MoveDots(FSelControl)
							LockWindowUpdate(0)
						end if
					End If
				End If
			End If
				'if OnModified then OnModified(this, GetControl(hDlg))
				'FSelControl = FDialog
		end if
	#EndIf
end sub

#IfNDef __USE_GTK__
	sub Designer.UnHookControl(Control as HWND)
		if IsWindow(Control) then
			if GetWindowLongPtr(Control, GWLP_WNDPROC) = @HookChildProc then
				SetWindowLongPtr(Control, GWLP_WNDPROC, cint(GetProp(Control, "@@@Proc")))
				RemoveProp(Control, "@@@Proc")
			end if
		end if   
	end sub
#EndIf

#IfDef __USE_GTK__
	sub Designer.HookControl(Control as GtkWidget Ptr)
#Else
	sub Designer.HookControl(Control as HWND)
#EndIf
	#IfDef __USE_GTK__
		If gtk_is_widget(Control) Then
			g_signal_connect(Control, "event", G_CALLBACK(@HookChildProc), @This)
		End If
	#Else
		if IsWindow(Control) then
			if GetWindowLongPtr(Control, GWLP_WNDPROC) <> @HookChildProc then
			  SetProp(Control, "@@@Proc", cast(WNDPROC, SetWindowLongPtr(Control, GWLP_WNDPROC, cint(@HookChildProc))))
			end if
		end if   
	#EndIf
End Sub

Function Designer.CreateControl(AClassName as string, AName as string, ByRef AText As WString, AParent as Any Ptr, x as integer, y as integer, cx as integer, cy as integer, bNotHook As Boolean = False) As Any Ptr
    On Error Goto ErrorHandler
    If FLibs.Contains(*MFFDll) Then
        MFF = FLibs.Object(FLibs.IndexOf(*MFFDll))
    Else
        MFF = DyLibLoad(*MFFDll)        
        FLibs.Add *MFFDll, MFF
    End If
    Ctrl = 0
    FSelControl = 0
	If MFF Then
        If CreateControlFunc <> 0 Then
            Ctrl = CreateControlFunc(AClassName, _
                                 AName, _
                                 AText, _
                                 x, _
                                 y, _
                                 iif(cx, cx, 50),_
                                 iif(cy, cy, 50),_
                                 AParent)
            If Ctrl Then
            	SelectedControl = Ctrl
				If ReadPropertyFunc Then
					#IfDef __USE_GTK__
						'g_signal_connect(layoutwidget, "event", G_CALLBACK(@HookChildProc), Ctrl)
						Dim As GtkWidget Ptr hHandle = ReadPropertyFunc(Ctrl, "Widget")
						If hHandle <> 0 Then FSelControl = hHandle
					#Else
						Dim As HWND Ptr hHandle = ReadPropertyFunc(Ctrl, "Handle")
						If hHandle <> 0 Then FSelControl = *hHandle
					#EndIf
				End If
				If WritePropertyFunc Then
					Dim As Boolean bTrue = True
					WritePropertyFunc(Ctrl, "DesignMode", @bTrue)
					WritePropertyFunc(Ctrl, "ControlDesigner", @This)
					#IfDef __USE_GTK__
						
					#Else
						
					#EndIf
                End If
            Else
                
            End If
        End If
    End If
    SelectedClass = ""
    /'FSelControl = CreateWindowEx(FStyleEx,_
                                 AClassName,_
                                 AText,_
                                 FStyle or WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,_
                                 x,_
                                 y,_
                                 iif(cx, cx, 50),_
                                 iif(cy, cy, 50),_
                                 AParent,_
                                 cast(HMENU, FID),_
                                 instance,_
                                 0)
    '/
    #IfDef __USE_GTK__
    	If gtk_is_widget(FSelControl) then
			If Not bNotHook Then
				HookControl(FSelControl)
				'AName = iif(AName="", AName = AClassName & ...)
				'SetProp(Control, "Name", ...)
				'possibly using in propertylist inspector
			End If
		End If
    #Else
		If IsWindow(FSelControl) then
			If Not bNotHook Then
				HookControl(FSelControl)
				'AName = iif(AName="", AName = AClassName & ...)
				'SetProp(Control, "Name", ...)
				'possibly using in propertylist inspector
			End If
		End If
	#EndIf
    'DyLibFree(MFF)
    Return Ctrl
    Exit Function
ErrorHandler:
    MsgBox ErrDescription(Err) & " (" & Err & ") " & _
        "in line " & Erl() & " " & _
        "in function " & ZGet(Erfn()) & " " & _
        "in module " & ZGet(Ermn())
End Function

Function Designer.CreateComponent(AClassName as string, AName as string) As Any Ptr
    Dim CreateComponentFunc As Function(ClassName As String, ByRef Name As WString) As Any Ptr
    Dim MFF As Any Ptr
    If FLibs.Contains(*MFFDll) Then
        MFF = FLibs.Object(FLibs.IndexOf(*MFFDll))
    Else
        MFF = DyLibLoad(*MFFDll)        
        FLibs.Add *MFFDll, MFF
    End If
    Dim As Any Ptr Cpnt
    #IfNDef __USE_GTK__
		FSelControl = 0
	#EndIf
    If MFF Then
        CreateComponentFunc = DylibSymbol(MFF, "CreateComponent")
        If CreateComponentFunc <> 0 Then
            Cpnt = CreateComponentFunc(AClassName, AName)
            If Cpnt Then
            	If WritePropertyFunc Then
					Dim As Boolean bTrue = True
					WritePropertyFunc(Cpnt, "DesignMode", @bTrue)
				End If
            End If
        End If
    End If
    SelectedClass = ""
    Return Cpnt
End Function

sub Designer.UpdateGrid
	#IfNDef __USE_GTK__
		InvalidateRect(FDialog, 0, true)
	#EndIf
end sub

sub Designer.DrawGrid()
    if FShowGrid = False then Exit Sub
    #IfDef __USE_GTK__
    	#IfDef __USE_GTK3__
	    	Dim As Integer iWidth = gtk_widget_get_allocated_width(layoutwidget)
	    	Dim As Integer iHeight = gtk_widget_get_allocated_height(layoutwidget)
    	#Else
    		Dim As Integer iWidth = layoutwidget->allocation.width
	    	Dim As Integer iHeight = layoutwidget->allocation.height
    	#EndIf
    	cairo_set_source_rgb(cr, 0, 0, 0)
    	For i As Integer = 1 To iWidth Step 6
    		For j As Integer = 1 To iHeight Step 6
    			cairo_rectangle(cr, i, j, 1, 1)
    			cairo_fill(cr)
    		Next j
    	Next i
    #Else
		dim as HDC mDc
		dim as HBITMAP mBMP, pBMP
		dim as RECT R, BrushRect = type(0, 0, FStepX, FStepY)
		Dim As PAINTSTRUCT Ps
		FHDc = BeginPaint(FDialog,@Ps)
		GetClientRect(FDialog, @R)
		if FGridBrush then
			DeleteObject(FGridBrush)
		end if   
		mDc   = CreateCompatibleDc(FHDC)
		mBMP  = CreateCompatibleBitmap(FHDC, FStepX, FStepY)
		pBMP  = SelectObject(mDc, mBMP)
		FillRect(mDc, @BrushRect, cast(HBRUSH, 16))
		SetPixel(mDc, 1, 1, 0)
		'for lines use MoveTo and LineTo or Rectangle function or whatever...
		FGridBrush = CreatePatternBrush(mBMP)
		FillRect(FHDC, @R, FGridBrush)
		SelectObject(mDc, pBMP)
		DeleteObject(mBMP)
		DeleteDc(mDc)
		EndPaint FDialog,@Ps
	#EndIf
end sub

#IfDef __USE_GTK__
	Function Designer.HookChildProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
#Else
	Function Designer.HookChildProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
#EndIf
	#IfDef __USE_GTK__
		Static As My.Sys.Forms.Designer Ptr Des
		Des = user_data
		if Des then
			with *Des
				Select Case event->Type
				Case GDK_2BUTTON_PRESS ', GDK_DOUBLE_BUTTON_PRESS
					Dim As Integer x, y
					GetPosToClient widget, .layoutwidget, @x, @y
					.DblClick(event->Motion.x + x, event->Motion.y + y, event->Motion.state)
					Return True
				Case GDK_BUTTON_PRESS
					Dim As Integer x, y
					GetPosToClient widget, .layoutwidget, @x, @y
					.MouseDown(event->button.x + x, event->button.y + y, event->button.state)
					Return True
				Case GDK_BUTTON_RELEASE
					Dim As Integer x, y
					GetPosToClient widget, .layoutwidget, @x, @y
					.MouseUp(event->button.x + x, event->button.y + y, event->button.state)
					If event->button.button = 3 Then
						mnuDesigner.Popup(event->button.x, event->button.y, @Type<Message>(Des, widget, event, False))
					End If
					Return True
				Case GDK_MOTION_NOTIFY
					Dim As Integer x, y
					GetPosToClient widget, .layoutwidget, @x, @y
					.FOverControl = Widget
					.MouseMove(event->button.x + x, event->button.y + y, event->button.state)
					Return True
				Case GDK_KEY_PRESS
					.KeyDown(event->Key.keyval, event->Key.state)
					'Select Case event->Key.keyval
'					Case Keys.DeleteKey
'						If Des->FSelControl <> Des->FDialog Then Des->DeleteControl(Des->SelectedControl)
'					Case Keys.Left, Keys.Right, Keys.Up, Keys.Down
'						Dim As Integer FLeft, FTop, FWidth, FHeight
'						Dim As Integer FStepX = Des->FStepX
'						Dim As Integer FStepY = Des->FStepY
'						If bCtrl Then FStepX = 1: FStepY = 1
'						#IfDef __USE_GTK__
'						#Else
'							Dim As POINT P
'							Dim As RECT R
'							GetWindowRect(Des->FSelControl, @R)
'							P.X     = R.Left
'							P.Y     = R.Top
'							FWidth  = R.Right - R.Left
'							FHeight = R.Bottom - R.Top
'							ScreenToClient(GetParent(Des->FSelControl), @P) 
'							FLeft   = P.X
'							FTop    = P.Y
'							If bShift Then
'								Select Case wParam
'								Case Keys.Left: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth - FStepX, FHeight, True)
'								Case Keys.Right: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth + FStepX, FHeight, True)
'								Case Keys.Up: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight - FStepY, True)
'								Case Keys.Down: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight + FStepY, True)
'								End Select
'							ElseIf Des->FSelControl <> Des->Dialog Then
'								Select Case wParam
'								Case Keys.Left: MoveWindow(Des->FSelControl, FLeft - FStepX, FTop, FWidth, FHeight, True)
'								Case Keys.Right: MoveWindow(Des->FSelControl, FLeft + FStepX, FTop, FWidth, FHeight, True)
'								Case Keys.Up: MoveWindow(Des->FSelControl, FLeft, FTop - FStepY, FWidth, FHeight, True)
'								Case Keys.Down: MoveWindow(Des->FSelControl, FLeft, FTop + FStepY, FWidth, FHeight, True)
'								End Select
'							End If
'							Des->MoveDots(Des->FSelControl)
'							If Des->OnModified Then Des->OnModified(*Des, GetControl(Des->FSelControl))
'						#EndIf
'					End Select
				end select
		   end with
		end if
		Return True
	#Else
		Select Case uMsg
		case WM_MOUSEFIRST to WM_MOUSELAST
			return true
		case WM_NCHITTEST
			return HTTRANSPARENT
		case WM_KEYFIRST to WM_KEYLAST
			return 0
		end select
		return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
	#EndIf
	End Function
				  
	#IfDef __USE_GTK__
		Function Designer.HookDialogProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
	#Else
		Function Designer.HookDialogProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
	#EndIf
		Static As Boolean bCtrl, bShift
		Static As Any Ptr Ctrl
		Static As My.Sys.Forms.Designer Ptr Des
		#IfDef __USE_GTK__
			bShift = event->Key.state And GDK_Shift_MASK
			bCtrl = event->Key.state And GDK_Control_MASK
			Des = user_data
			'If ReadPropertyFunc Then Des = ReadPropertyFunc(Ctrl, "ControlDesigner")
		#Else
			bShift = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
			Des = GetProp(hDlg, "@@@Designer")
		#EndIf
		if Des then
			with *Des
				#IfDef __USE_GTK__
					Select Case event->Type
				#Else
					select case uMsg
			  	#EndIf
				#IfNDef __USE_GTK__
					'case WM_PAINT
				  	case WM_PAINT, WM_ERASEBKGND
					  'dim as RECT R
					  'GetClientRect(hDlg, @R)
					  'if .FShowGrid then
						  .DrawGrid()'GetDC(hDlg), R)
					  'else
						'  FillRect(GetDC(hDlg), @R, cast(HBRUSH, 16))
					  'end if   
						return 1
					Case WM_NCHitTest
					Case WM_SYSCOMMAND
						Return 0
					Case WM_SETCURSOR
						Return 0
					Case WM_GETDLGCODE: Return DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTTAB
				#EndIf
				#IfDef __USE_GTK__
					Case GDK_2BUTTON_PRESS ', GDK_DOUBLE_BUTTON_PRESS
						.DblClick(event->Motion.x, event->Motion.y, event->Motion.state)
						Return True
				#Else
					Case WM_LBUTTONDBLCLK
						.DblClick(loWord(lParam), hiWord(lParam),wParam and &HFFFF)
						Return 0
				#EndIf
				#IfDef __USE_GTK__
					Case GDK_BUTTON_PRESS
						.MouseDown(event->button.x, event->button.y, event->button.state)
						Return True
				#Else
					Case WM_LBUTTONDOWN
						.MouseDown(loWord(lParam), hiWord(lParam),wParam and &HFFFF )
						Return 0
				#EndIf
				#IfDef __USE_GTK__
					Case GDK_BUTTON_RELEASE
						.MouseUp(event->button.x, event->button.y, event->button.state)
						If event->button.button = 3 Then
							mnuDesigner.Popup(event->button.x, event->button.y, @Type<Message>(Des, widget, event, False))
						End If
						Return True
				#Else
					Case WM_LBUTTONUP
						.MouseUp(loWord(lParam), hiWord(lParam),wParam and &HFFFF )
						Return 0
				#EndIf
				#IfDef __USE_GTK__
					Case GDK_MOTION_NOTIFY
						.FOverControl = Widget
						.MouseMove(event->button.x, event->button.y, event->button.state)
						Return True
				#Else
					Case WM_MOUSEMOVE
						.MouseMove(loword(lParam), hiword(lParam),wParam and &HFFFF )
						Return 0
				#EndIf
				#IfNDef __USE_GTK__
					Case WM_RBUTTONUP
						'if .FSelControl <> .FDialog then
							dim as POINT P
							P.x = loWord(lParam)
							P.y = hiWord(lParam)
							ClientToScreen(hDlg, @P)
							TrackPopupMenu(.FPopupMenu, 0, P.x, P.y, 0, hDlg, 0)
						'end if
						return 0
				#EndIf
				#IfDef __USE_GTK__
					Case GDK_KEY_PRESS
						.KeyDown(event->Key.keyval, event->Key.state)
						Return True
						'Select Case event->Key.keyval
				#Else
					Case WM_KEYDOWN
						.KeyDown(wParam, 0)
						'Select Case wParam
				#EndIf
'					Case Keys.DeleteKey
'						If Des->FSelControl <> Des->FDialog Then Des->DeleteControl(Des->SelectedControl)
'					Case Keys.Left, Keys.Right, Keys.Up, Keys.Down
'						Dim As Integer FLeft, FTop, FWidth, FHeight
'						Dim As Integer FStepX = Des->FStepX
'						Dim As Integer FStepY = Des->FStepY
'						If bCtrl Then FStepX = 1: FStepY = 1
'						#IfDef __USE_GTK__
'						#Else
'							Dim As POINT P
'							Dim As RECT R
'							GetWindowRect(Des->FSelControl, @R)
'							P.X     = R.Left
'							P.Y     = R.Top
'							FWidth  = R.Right - R.Left
'							FHeight = R.Bottom - R.Top
'							ScreenToClient(GetParent(Des->FSelControl), @P) 
'							FLeft   = P.X
'							FTop    = P.Y
'							If bShift Then
'								Select Case wParam
'								Case Keys.Left: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth - FStepX, FHeight, True)
'								Case Keys.Right: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth + FStepX, FHeight, True)
'								Case Keys.Up: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight - FStepY, True)
'								Case Keys.Down: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight + FStepY, True)
'								End Select
'							ElseIf Des->FSelControl <> Des->Dialog Then
'								Select Case wParam
'								Case Keys.Left: MoveWindow(Des->FSelControl, FLeft - FStepX, FTop, FWidth, FHeight, True)
'								Case Keys.Right: MoveWindow(Des->FSelControl, FLeft + FStepX, FTop, FWidth, FHeight, True)
'								Case Keys.Up: MoveWindow(Des->FSelControl, FLeft, FTop - FStepY, FWidth, FHeight, True)
'								Case Keys.Down: MoveWindow(Des->FSelControl, FLeft, FTop + FStepY, FWidth, FHeight, True)
'								End Select
'							End If
'							Des->MoveDots(Des->FSelControl)
'							If Des->OnModified Then Des->OnModified(*Des, GetControl(Des->FSelControl))
'						#EndIf
'					End Select
				#IfNDef __USE_GTK__
			  case WM_COMMAND
				  if IsWindow(cast(HWND, lParam)) then
				  else
					 if hiWord(wParam) = 0 then
						 select case loWord(wParam)
						 case 10: If .FSelControl <> .FDialog Then .DeleteControl(.SelectedControl)
						 case 11: 'MessageBox(.FDialog, "Not implemented yet.","Designer", 0)
						 case 12: .CopyControl()
						 case 13: .CutControl()
						 case 14: .PasteControl()
						 case 16: SetWindowPos .FSelControl, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
						 case 18: If Des->OnClickProperties Then Des->OnClickProperties(*Des, .GetControl(.FSelControl))
						 end select
					 end if
				  end if '
				  ''''Call and execute the based commands of dialogue.
				  return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
				  '''if don't want to call
				  'return 0
				#EndIf
			  end select
		   end with
		end if
		#IfDef __USE_GTK__
			Return False
		#Else
			return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		#EndIf
	end function

#IfDef __USE_GTK__
	Function Designer.HookDialogParentProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
#Else
	Function Designer.HookDialogParentProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
#EndIf
		Static as Designer Ptr Des
		#IfDef __USE_GTK__
			Des = user_data
		#Else
			Des = GetProp(hDlg, "@@@Designer")
		#EndIf
		if Des then
			with *Des
				Dim As Point P
			#IfDef __USE_GTK__
				Select Case event->Type
			#Else
				select case uMsg
				Case WM_NCHitTest
				Case WM_GETDLGCODE: Return DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTTAB
			#EndIf
			#IfDef __USE_GTK__
			Case GDK_BUTTON_PRESS
			#Else
			case WM_LBUTTONDOWN
			#EndIf
				#IfDef __USE_GTK__
					Dim As Integer x, y
					GetPosToClient(.layoutwidget, widget, @x, @y)
					.MouseDown(event->button.x - x, event->button.y - y, event->button.state)
					return True
				#Else
				  P = Type<Point>(loWord(lParam), hiWord(lParam))
				  ClientToScreen(hDlg, @P)
				  ScreenToClient(.FDialog, @P)
				  .MouseDown(P.X, P.Y, wParam and &HFFFF )
				  return 0
				#EndIf
			#IfDef __USE_GTK__
				Case GDK_BUTTON_RELEASE
			#Else
				case WM_LBUTTONUP
			#EndIf
				#IfDef __USE_GTK__
					Dim As Integer x, y
					GetPosToClient(.layoutwidget, widget, @x, @y)
					.MouseUp(event->button.x - x, event->button.y - y, event->button.state)
					return True
				#Else
				  P = Type<Point>(loWord(lParam), hiWord(lParam))
				  ClientToScreen(hDlg, @P)
				  ScreenToClient(.FDialog, @P)
				  .MouseUp(P.X, P.Y, wParam and &HFFFF )
				  return 0
				#EndIf
			#IfDef __USE_GTK__
				Case GDK_MOTION_NOTIFY
					'.FOverControl = Widget
			#Else
				case WM_MOUSEMOVE
			#EndIf
				#IfDef __USE_GTK__
					Dim As Integer x, y
					GetPosToClient(.layoutwidget, widget, @x, @y)
					.MouseMove(event->Motion.x - x, event->Motion.y - y, event->Motion.state)
					return True
				#Else
				  P = Type<Point>(loWord(lParam), hiWord(lParam))
				  ClientToScreen(hDlg, @P)
				  ScreenToClient(.FDialog, @P)
				  .MouseMove(P.X, P.Y, wParam and &HFFFF )
				  return 0
				#EndIf
			#IfNDef __USE_GTK__
				case WM_COMMAND
				  
				  ''''Call and execute the based commands of dialogue.
				  return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
				  '''if don't want to call
				  'return 0
			#EndIf
				end select
		   end with
		end if
		#IfDef __USE_GTK__
		Return False
		#Else
		return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		#EndIf
	end function

sub Designer.Hook
    #IfDef __USE_GTK__
    	If gtk_is_widget(FDialog) Then
    #Else
    	if IsWindow(FDialog) then
    #EndIf
    	#IfDef __USE_GTK__
			g_signal_connect(layoutwidget, "event", G_CALLBACK(@HookDialogProc), @This)
		#Else
			SetProp(FDialog, "@@@Designer", @this)
			if GetWindowLongPtr(FDialog, GWLP_WNDPROC) <> @HookDialogProc then
			   SetProp(FDialog, "@@@Proc", cast(any ptr, SetWindowLongPtr(FDialog, GWLP_WNDPROC, cint(@HookDialogProc))))
			end if
		#EndIf
		HookParent
		'GetChilds
		'for i as integer = 0 to FChilds.Count-1
		'	HookControl(FChilds.Child[i])
		'next
	end if
end sub

sub Designer.UnHook
	#IfNDef __USE_GTK__
		SetWindowLongPtr(FDialog, GWLP_WNDPROC, cint(GetProp(FDialog, "@@@Proc")))
		RemoveProp(FDialog, "@@@Designer")
		RemoveProp(FDialog, "@@@Proc")
		UnHookParent
		GetChilds
		for i as integer = 0 to FChilds.Count-1
			UnHookControl(FChilds.Child[i])
		next
	#EndIf
end sub

sub Designer.HookParent
	#IfDef __USE_GTK__
		If gtk_is_widget(FDialogParent) Then
			g_signal_connect(FDialogParent, "event", G_CALLBACK(@HookDialogParentProc), @This)
		End If
	#Else
		if IsWindow(FDialog) then
			SetProp(GetParent(FDialog), "@@@Designer", this)
			if GetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC) <> @HookDialogParentProc then
			   SetProp(GetParent(FDialog), "@@@Proc", cast(any ptr, SetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC, cint(@HookDialogParentProc))))
			end if
		end if
	#EndIf
end sub

sub Designer.UnHookParent
	#IfNDef __USE_GTK__
		SetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC, cint(GetProp(GetParent(FDialog), "@@@Proc")))
		RemoveProp(FDialog, "@@@Designer")
		RemoveProp(FDialog, "@@@Proc")
	#EndIf
end sub

Sub Designer.KeyDown(KeyCode As Integer, Shift As Integer)
	Static bShift As Boolean
	Static bCtrl As Boolean
	#IfDef __USE_GTK__
		bShift = Shift And GDK_Shift_MASK
		bCtrl = Shift And GDK_Control_MASK
	#Else
		bShift = GetKeyState(VK_SHIFT) And 8000
		bCtrl = GetKeyState(VK_CONTROL) And 8000
	#EndIf
	Select Case KeyCode
	Case Keys.DeleteKey
		If FSelControl <> FDialog Then DeleteControl(SelectedControl)
	Case Keys.Left, Keys.Right, Keys.Up, Keys.Down
		Dim As Integer FStepX1 = FStepX
		Dim As Integer FStepY1 = FStepY
		Dim As Integer FLeft, FTop, FWidth, FHeight
		If bCtrl Then FStepX1 = 1: FStepY1 = 1
		#IfDef __USE_GTK__
			If SelectedControl <> 0 Then
				ControlGetBoundsSub(SelectedControl, @FLeft, @FTop, @FWidth, @FHeight)
				If bShift Then
					Select Case KeyCode
					Case Keys.Left: FWidth = FWidth - FStepX1
					Case Keys.Right: FWidth = FWidth + FStepX1
					Case Keys.Up: FHeight = FHeight - FStepY1
					Case Keys.Down: FHeight = FHeight + FStepY1
					End Select
				ElseIf FSelControl <> Dialog Then
					Select Case KeyCode
					Case Keys.Left: FLeft = FLeft - FStepX1
					Case Keys.Right: FLeft = FLeft + FStepX1
					Case Keys.Up: FTop = FTop - FStepY1
					Case Keys.Down: FTop = FTop + FStepY1
					End Select
				End If
				ControlSetBoundsSub(SelectedControl, FLeft, FTop, FWidth, FHeight)
				MoveDots(FSelControl, , FLeft, FTop, FWidth, FHeight)
			EndIf
		#Else
			Dim As POINT P
			Dim As RECT R
			GetWindowRect(FSelControl, @R)
			P.X     = R.Left
			P.Y     = R.Top
			FWidth  = R.Right - R.Left
			FHeight = R.Bottom - R.Top
			ScreenToClient(GetParent(FSelControl), @P) 
			FLeft   = P.X
			FTop    = P.Y
			If bShift Then
				Select Case KeyCode
				Case Keys.Left: FWidth = FWidth - FStepX1
				Case Keys.Right: FWidth = FWidth + FStepX1
				Case Keys.Up: FHeight = FHeight - FStepY1
				Case Keys.Down: FHeight = FHeight + FStepY1
				End Select
			ElseIf FSelControl <> Dialog Then
				Select Case KeyCode
				Case Keys.Left: FLeft = FLeft - FStepX1
				Case Keys.Right: FLeft = FLeft + FStepX1
				Case Keys.Up: FTop = FTop - FStepY1
				Case Keys.Down: FTop = FTop + FStepY1
				End Select
			End If
			MoveWindow(FSelControl, FLeft, FTop, FWidth, FHeight, True)
			MoveDots(FSelControl)
		#EndIf
		If OnModified Then OnModified(This, SelectedControl, FLeft, FTop, FWidth, FHeight)
	End Select
End Sub

#IfDef __USE_GTK__
	function Designer.DotWndProc(widget As GtkWidget Ptr, event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
#Else
	function Designer.DotWndProc(hDlg as HWND, uMsg as UINT, wParam as WPARAM, lParam as LPARAM) as LRESULT
#EndIf
		dim as Designer Ptr Des 
		#IfDef __USE_GTK__
			Des = user_data
		#Else
			Des = cast(Designer Ptr, GetWindowLongPtr(hDlg, 0))
		#EndIf
		With *Des
		#IfDef __USE_GTK__
		Select case event->Type
		#Else
		Select case uMsg
		Case WM_PAINT
			dim as PAINTSTRUCT Ps
			Dim as HDC FHDc = BeginPaint(hDlg, @Ps)
			FillRect(FHDc, @Ps.rcPaint, iif(Des, Des->FDotBrush, cast(HBRUSH, GetStockObject(BLACK_BRUSH))))
			EndPaint(hDlg, @Ps)
			return 0
			'or use WM_ERASEBKGND message
		#EndIf
		#IfDef __USE_GTK__
		Case GDK_MOTION_NOTIFY
			.FOverControl = Widget
		#Else
		Case WM_MOUSEMOVE
			'.MouseMove(loWord(lParam), hiWord(lParam),wParam and &HFFFF )
			Select Case .IsDot(hDlg)
			case 0 : SetCursor(crSizeNWSE)
			case 1 : SetCursor(crSizeNS)
			case 2 : SetCursor(crSizeNESW)
			case 3 : SetCursor(crSizeWE)
			case 4 : SetCursor(crSizeNWSE)
			case 5 : SetCursor(crSizeNS)
			case 6 : SetCursor(crSizeNESW)
			case 7 : SetCursor(crSizeWE)
			End Select
			.FOverControl = hDlg
		#EndIf
		#IfDef __USE_GTK__
		Case GDK_BUTTON_PRESS
		#Else
		case WM_LBUTTONDOWN
		#EndIf
			#IfDef __USE_GTK__
				Dim As Integer x, y, x1, y1
				GetPosToClient(widget, .FDialogParent, @x, @y)
				GetPosToClient(.layoutwidget, .FDialogParent, @x1, @y1)
				.MouseDown(event->button.x + x - x1, event->button.y + y - y1, event->button.state)
				return True
			#Else
				Dim P As Point
				P.X = loWord(lParam)
				P.Y = hiWord(lParam)
				ScreenToClient .FDialog, @P
				.MouseDown(P.X, P.Y, wParam and &HFFFF )
				return 0
			#EndIf
		#IfDef __USE_GTK__
		Case GDK_BUTTON_RELEASE
		#Else
		case WM_LBUTTONUP
		#EndIf
			#IfDef __USE_GTK__
				Dim As Integer x, y, x1, y1
				GetPosToClient(widget, .FDialogParent, @x, @y)
				GetPosToClient(.layoutwidget, .FDialogParent, @x1, @y1)
				.MouseUp(event->button.x + x - x1, event->button.y + y - y1, event->button.state)
				return True
			#Else
			.MouseUp(loWord(lParam), hiWord(lParam),wParam and &HFFFF )
			return 0
			
		case WM_NCHITTEST
			return HTTRANSPARENT
		case WM_KEYUP
		#EndIf
		#IfDef __USE_GTK__
		Case GDK_KEY_PRESS
		#Else
		case WM_KEYDOWN
		#EndIf
			#IfDef __USE_GTK__
			.KeyDown(event->Key.keyval, event->Key.state)
			#Else
			.KeyDown(wParam, wParam and &HFFFF)
			#EndIf
'			Select Case wParam
'			Case VK_DELETE: If Des->FSelControl<> Des->FDialog then Des->DeleteControl(Des->FSelControl)    
'			Case VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN
'				Dim As POINT P
'				Dim As RECT R
'				Dim As Integer FLeft, FTop, FWidth, FHeight
'				Dim As Integer FStepX = Des->FStepX
'				Dim As Integer FStepY = Des->FStepY
'				If bCtrl Then FStepX = 1: FStepY = 1
'				GetWindowRect(Des->FSelControl, @R)
'				P.X     = R.Left
'				P.Y     = R.Top
'				FWidth  = R.Right - R.Left
'				FHeight = R.Bottom - R.Top
'				ScreenToClient(GetParent(Des->FSelControl), @P) 
'				FLeft   = P.X
'				FTop    = P.Y
'				If bShift Then
'					Select Case wParam
'					Case VK_LEFT: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth - FStepX, FHeight, True)
'					Case VK_RIGHT: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth + FStepX, FHeight, True)
'					Case VK_UP: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight - FStepY, True)
'					Case VK_DOWN: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight + FStepY, True)
'					End Select
'				Else
'					Select Case wParam
'					Case VK_LEFT: MoveWindow(Des->FSelControl, FLeft - FStepX, FTop, FWidth, FHeight, True)
'					Case VK_RIGHT: MoveWindow(Des->FSelControl, FLeft + FStepX, FTop, FWidth, FHeight, True)
'					Case VK_UP: MoveWindow(Des->FSelControl, FLeft, FTop - FStepY, FWidth, FHeight, True)
'					Case VK_DOWN: MoveWindow(Des->FSelControl, FLeft, FTop + FStepY, FWidth, FHeight, True)
'					End Select
'				End If
'				Des->MoveDots(Des->FSelControl)
'				If Des->OnModified Then Des->OnModified(*Des, GetControl(Des->FSelControl))
'			End Select
		#IfNDef __USE_GTK__
		Case WM_DESTROY
			RemoveProp(hDlg,"@@@Control")
			Return 0
		#EndIf
		end select
	End With
	#IfNDef __USE_GTK__
		Return DefWindowProc(hDlg, uMsg, wParam, lParam)
	#EndIf
End function     

sub Designer.RegisterDotClass(ByRef clsName As WString)
   #IfNDef __USE_GTK__
	   dim as WNDCLASSEX wcls
	   wcls.cbSize        = sizeof(wcls)
	   wcls.lpszClassName = @clsName
	   wcls.lpfnWndProc   = @DotWndProc
	   wcls.cbWndExtra   += 4
	   wcls.hInstance     = instance
	   RegisterClassEx(@wcls)
	#EndIf
end sub

#IfDef __USE_GTK__
	property Designer.Dialog as GtkWidget Ptr
		return FDialog
	end property
#Else
	property Designer.Dialog as HWND
		return FDialog
	end property
#EndIf

Sub Designer.PaintControl()
	If FDown AndAlso ((FCanInsert) OrElse (FCanMove = false AndAlso FCanSize = False)) Then
		#IfDef __USE_GTK__
			cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
			cairo_rectangle(cr, FBeginX, FBeginY, FNewX - FBeginX, FNewY - FBeginY)
		    cairo_stroke(cr)
		#EndIf
	End If
    'cairo_fill(cr)
End Sub

#IfDef __USE_GTK__
	Function Dialog_Draw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
		Dim As Designer Ptr Des = data1
		Des->cr = cr
		Des->DrawGrid
		Des->PaintControl
		Return False
	End Function
	
	Function Dialog_ExposeEvent(widget As GtkWidget Ptr, event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
		Dim As cairo_t Ptr cr = gdk_cairo_create(event->window)
		Dialog_Draw(widget, cr, data1)
		cairo_destroy(cr)
		Return False
	End Function
	
	property Designer.Dialog(value as GtkWidget Ptr)
		if value <> FDialog then
			UnHook
			FDialog = value
			If value <> 0 Then
				gtk_widget_set_can_focus(layoutwidget, true)
				'CreateDots(gtk_widget_get_parent(FDialog))
				gtk_widget_set_events(layoutwidget, _
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
				#IfDef __USE_GTK3__
					g_signal_connect(layoutwidget, "draw", G_CALLBACK(@Dialog_Draw), @This)
				#Else
					g_signal_connect(layoutwidget, "expose-event", G_CALLBACK(@Dialog_ExposeEvent), @This)
				#EndIf
'				Dim As GdkDisplay Ptr display = gdk_display_get_default ()
'				Dim As GdkDeviceManager Ptr device_manager = gdk_display_get_device_manager (display)
'				Dim As GdkDevice Ptr device = gdk_device_manager_get_client_pointer (device_manager)
'				gtk_widget_set_device_enabled(layoutwidget, device, false)
				if FActive then Hook
				'InvalidateRect(FDialog, 0, true)
			End If
		end if   
	end property
#Else
	property Designer.Dialog(value as HWND)
		if value <> FDialog then
			UnHook
			FDialog = value
			If value <> 0 Then
				'CreateDots(GetParent(FDialog))
				if FActive then Hook
				InvalidateRect(FDialog, 0, true)
			End If
		end if   
	end property
#EndIf

property Designer.Active as Boolean
    return FActive
end property

property Designer.Active(value as Boolean)
    if value <> FActive then
        FActive = value
        if value then
           Hook
        else
           UnHook
           HideDots
        end if
        #IfNDef __USE_GTK__
			InvalidateRect(FDialog, 0, true)
		#EndIf
    end if
end property

property Designer.ChildCount as integer
    #IfNDef __USE_GTK__
		GetChilds
	#EndIf
    return FChilds.Count
end property

property Designer.ChildCount(value as integer)
end property

#IfNDef __USE_GTK__
	property Designer.Child(index as integer) as HWND
		if index > -1 and index < FChilds.Count then
			return FChilds.Child[index]
		end if
		return 0
	end property
#EndIf

#IfNDef __USE_GTK__
	property Designer.Child(index as integer,value as HWND)
	end property
#EndIf

property Designer.StepX as integer
    return FStepX
end property

property Designer.StepX(value as integer)
    if value <> FStepX then
       FStepX = value
       UpdateGrid
    end if   
end property

property Designer.StepY as integer
    return FStepY
end property

property Designer.StepY(value as integer)
    if value <> FStepY then
       FStepY = value
       UpdateGrid
   end if
end property

property Designer.DotColor as integer
    #IfNDef __USE_GTK__
		dim as LOGBRUSH LB
		if GetObject(FDotBrush, sizeof(LB), @LB) then
			FDotColor = LB.lbColor
		end if
	#EndIf
    return FDotColor
end property

property Designer.DotColor(value as integer)
    if value <> FDotColor then
        FDotColor = value
        #IfNDef __USE_GTK__
			if FDotBrush then DeleteObject(FDotBrush)
			FDotBrush = CreateSolidBrush(FDotColor)
			for i as integer = 0 to ubound(FDots)'-1
				InvalidateRect(FDots(i), 0, true)
			next
		#EndIf
    end if
end property

property Designer.SnapToGrid as Boolean
    return FSnapToGrid
end property

property Designer.SnapToGrid(value as Boolean)
    FSnapToGrid = value
end property

property Designer.ShowGrid as Boolean
    return FShowGrid
end property

property Designer.ShowGrid(value as Boolean)
    FShowGrid = value
    #IfNDef __USE_GTK__
		if IsWindow(FDialog) then InvalidateRect(FDialog, 0, true)
	#EndIf
end property

property Designer.ClassName as string
    return FClass
end property

property Designer.ClassName(value as string)
    FClass = value
end property

operator Designer.cast as any ptr
    return @this
end operator

constructor Designer(ParentControl As Control Ptr)
	FStepX      = 6
	FStepY      = 6
	FShowGrid   = true
	FActive     = true
	FSnapToGrid = 1
	#IfDef __USE_GTK__
		FDialogParent = ParentControl->Widget
	#Else
		FDialogParent = ParentControl->Handle
		FDotBrush   = CreateSolidBrush(FDotColor)
	#EndIf
	'FIsChild = True
	RegisterDotClass "DOT"
	WLet FClassName, "Designer"
	'OnHandleIsAllocated = @HandleIsAllocated
	'ChangeStyle WS_CHILD, True
	'FDesignMode = True
	'Base.Child             = Cast(Control Ptr, @This)
	CreateDots(ParentControl)
	#IfDef __USE_GTK__
		
	#Else
		FPopupMenu  = CreatePopupMenu
		AppendMenu(FPopupMenu, MF_STRING, 10, @"Delete")
		AppendMenu(FPopupMenu, MF_SEPARATOR, -1, @"-")
		AppendMenu(FPopupMenu, MF_STRING, 12, @"Copy")
		AppendMenu(FPopupMenu, MF_STRING, 13, @"Cut")
		AppendMenu(FPopupMenu, MF_STRING, 14, @"Paste")
		AppendMenu(FPopupMenu, MF_SEPARATOR, -1, @"-")
		AppendMenu(FPopupMenu, MF_STRING, 16, @"Send To Back")
		AppendMenu(FPopupMenu, MF_SEPARATOR, -1, @"-")
		AppendMenu(FPopupMenu, MF_STRING, 18, @"Properties")
	#EndIf
end constructor

'mnuDesigner.ImagesList = @imgList '<m>
mnuDesigner.Add(ML("Delete"), "", "Delete", @PopupClick)
mnuDesigner.Add("-")
mnuDesigner.Add(ML("Copy"), "Copy", "Copy", @PopupClick)
mnuDesigner.Add(ML("Cut"), "Cut", "Cut", @PopupClick)
mnuDesigner.Add(ML("Paste"), "Paste", "Paste", @PopupClick)
mnuDesigner.Add("-")
mnuDesigner.Add(ML("Send To Back"), "", "SendToBack", @PopupClick)
mnuDesigner.Add("-")
mnuDesigner.Add(ML("Properties"), "", "Properties", @PopupClick)

destructor Designer
    UnHook
    #IfNDef __USE_GTK__
		DeleteObject(FDotBrush)
		DeleteObject(FGridBrush)
		DestroyMenu(FPopupMenu)
	#EndIf
    DestroyDots
    'Delete DesignControl
    #IfNDef __USE_GTK__
		UnregisterClass("DOT", instance)
	#EndIf
    For i As Integer = 0 To FLibs.Count - 1
        DyLibFree(FLibs.Object(i))
    Next
end destructor
End Namespace
