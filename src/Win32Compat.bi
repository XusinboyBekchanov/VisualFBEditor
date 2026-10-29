'#########################################################
'#  Win32Compat.bi                                       #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'Web (WASM) and Android (JNI): EditControl and the designer keep their Windows code (__USE_WIN32_COMPAT__).
'This file gives that code the part of the Windows API it uses, on top of MyFbFramework:
' - an HWND is the Handle of a control (Win32CompatControl finds the control). A window can be subclassed
'   (SetWindowLongPtr GWLP_WNDPROC): its messages go to the procedure first (ControlMessageHook), CallWindowProc with
'   the old procedure gives the message back to the control. HTTRANSPARENT of WM_NCHITTEST passes the mouse to the parent;
' - the windows of a registered class (RegisterClassEx) are Win32CompatWindow controls, the ones of "ScrollBar" are
'   ScrollBarControls; the screen is the page (Android: the activity), GetWindowRect adds the positions of the parents;
' - an HDC is the canvas view of a window (its Canvas.Handle) or a memory DC, which records its drawing for BitBlt and
'   the pattern brushes; the GDI functions draw with the Canvas* functions of MyFbFramework. A pen / brush / font is a
'   GDI object of CreatePen / CreateSolidBrush / ... or the Pen / Brush of a Canvas (Brush.Handle returns the brush);
' - the drawing which Windows inverts (DrawFocusRect, R2_NOT) outside WM_PAINT is an overlay drawn after WM_PAINT;
' - the caret is drawn after WM_PAINT, the timers are TimerComponents, TrackPopupMenu shows the PopupMenu modal;
' - Win32CompatDispatch turns the CM_* messages of MyFbFramework into the WM_* messages of Windows.
'Direct2D is not started there (pRenderTarget stays 0): its types at the end only let the Direct2D branches compile.

#include once "mff/Canvas.bi"
#include once "mff/Menus.bi"
#include once "mff/ScrollBarControl.bi"
#include once "mff/TimerComponent.bi"
#ifdef __USE_WASM__
	'The elements of the report items in the designer (ReportHost: GetProp "MFFControl" gives the item)
	#include once "mff/Report.bi"
#endif

Type HDC As Any Ptr
Type HWND As Any Ptr
Type HGDIOBJ As Any Ptr
Type HBRUSH As Any Ptr
Type HPEN As Any Ptr
Type HFONT As Any Ptr
Type HBITMAP As Any Ptr
Type HICON As Any Ptr
Type HCURSOR As Any Ptr
Type HINSTANCE As Any Ptr
Type HMENU As Any Ptr
Type HIMC As Any Ptr
Type HRGN As Any Ptr
Type HGLOBAL As Any Ptr
Type HANDLE As Any Ptr
Type HIMAGELIST As Any Ptr
Type HRESULT As Long
Type BOOL As Long
Type DWORD As ULong
Type UINT As ULong
Type ATOM As UShort
Type UINT_PTR As UInteger
Type LONG_PTR As Integer
Type COLORREF As ULong
Type WPARAM As Integer
Type LPARAM As Integer
Type LRESULT As Integer
Type WNDPROC As Function(ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Type WNDENUMPROC As Function(ByVal hwnd As HWND, ByVal lParam As LPARAM) As BOOL
Type TIMERPROC As Sub(ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal idEvent As UINT_PTR, ByVal dwTime As DWORD)

Type Rect
	Left As Long
	Top As Long
	Right As Long
	Bottom As Long
End Type

Type Point
	X As Long
	Y As Long
End Type

Type Size
	cx As Long
	cy As Long
End Type

Type POINTS
	x As Short
	y As Short
End Type

Type TEXTMETRIC
	tmHeight As Long
	tmAscent As Long
	tmDescent As Long
	tmInternalLeading As Long
	tmExternalLeading As Long
	tmAveCharWidth As Long
	tmMaxCharWidth As Long
	tmWeight As Long
End Type

Type SCROLLINFO
	cbSize As UINT
	fMask As UINT
	nMin As Long
	nMax As Long
	nPage As UINT
	nPos As Long
	nTrackPos As Long
End Type

Type NMHDR
	hwndFrom As HWND
	idFrom As UINT_PTR
	code As UINT
End Type
Type LPNMHDR As NMHDR Ptr

Type PAINTSTRUCT
	hdc As HDC
	fErase As BOOL
	rcPaint As Rect
	fRestore As BOOL
	fIncUpdate As BOOL
	rgbReserved(31) As UByte
End Type

Type WNDCLASSEX
	cbSize As UINT
	style As UINT
	lpfnWndProc As WNDPROC
	cbClsExtra As Long
	cbWndExtra As Long
	hInstance As HINSTANCE
	hIcon As HICON
	hCursor As HCURSOR
	hbrBackground As HBRUSH
	lpszMenuName As Const WString Ptr
	lpszClassName As Const WString Ptr
	hIconSm As HICON
End Type

Type LOGFONT
	lfHeight As Long
	lfWidth As Long
	lfEscapement As Long
	lfOrientation As Long
	lfWeight As Long
	lfItalic As UByte
	lfUnderline As UByte
	lfStrikeOut As UByte
	lfCharSet As UByte
	lfOutPrecision As UByte
	lfClipPrecision As UByte
	lfQuality As UByte
	lfPitchAndFamily As UByte
	lfFaceName As WString * 32
End Type

Type LOGBRUSH
	lbStyle As UINT
	lbColor As COLORREF
	lbHatch As UInteger
End Type

Type BITMAP
	bmType As Long
	bmWidth As Long
	bmHeight As Long
	bmWidthBytes As Long
	bmPlanes As UShort
	bmBitsPixel As UShort
	bmBits As Any Ptr
End Type

Type BLENDFUNCTION
	BlendOp As UByte
	BlendFlags As UByte
	SourceConstantAlpha As UByte
	AlphaFormat As UByte
End Type

Type NONCLIENTMETRICS
	cbSize As UINT
	iBorderWidth As Long
	iScrollWidth As Long
	iScrollHeight As Long
	iCaptionWidth As Long
	iCaptionHeight As Long
	lfCaptionFont As LOGFONT
	iSmCaptionWidth As Long
	iSmCaptionHeight As Long
	lfSmCaptionFont As LOGFONT
	iMenuWidth As Long
	iMenuHeight As Long
	lfMenuFont As LOGFONT
	lfStatusFont As LOGFONT
	lfMessageFont As LOGFONT
End Type

Type WINDOWPOS
	hwnd As HWND
	hwndInsertAfter As HWND
	x As Long
	y As Long
	cx As Long
	cy As Long
	flags As UINT
End Type

Type NCCALCSIZE_PARAMS
	rgrc(2) As Rect
	lppos As WINDOWPOS Ptr
End Type
Type LPNCCALCSIZE_PARAMS As NCCALCSIZE_PARAMS Ptr

Type TRACKMOUSEEVENT
	cbSize As DWORD
	dwFlags As DWORD
	hwndTrack As HWND
	dwHoverTime As DWORD
End Type

Type MSG
	hwnd As HWND
	message As UINT
	wParam As WPARAM
	lParam As LPARAM
	time As DWORD
	pt As Point
End Type

Type SECURITY_ATTRIBUTES
	nLength As DWORD
	lpSecurityDescriptor As Any Ptr
	bInheritHandle As BOOL
End Type

Type STARTUPINFO
	cb As DWORD
	lpReserved As WString Ptr
	lpDesktop As WString Ptr
	lpTitle As WString Ptr
	dwX As DWORD
	dwY As DWORD
	dwXSize As DWORD
	dwYSize As DWORD
	dwXCountChars As DWORD
	dwYCountChars As DWORD
	dwFillAttribute As DWORD
	dwFlags As DWORD
	wShowWindow As UShort
	cbReserved2 As UShort
	lpReserved2 As UByte Ptr
	hStdInput As HANDLE
	hStdOutput As HANDLE
	hStdError As HANDLE
End Type
Type STARTUPINFOW As STARTUPINFO

Type PROCESS_INFORMATION
	hProcess As HANDLE
	hThread As HANDLE
	dwProcessId As DWORD
	dwThreadId As DWORD
End Type

Type COMBOBOXINFO
	cbSize As DWORD
	rcItem As Rect
	rcButton As Rect
	stateButton As DWORD
	hwndCombo As HWND
	hwndItem As HWND
	hwndList As HWND
End Type

Type TVITEM
	mask As UINT
	hItem As Any Ptr
	state As UINT
	stateMask As UINT
	pszText As WString Ptr
	cchTextMax As Long
	iImage As Long
	iSelectedImage As Long
	cChildren As Long
	lParam As LPARAM
End Type

Type NMTREEVIEW
	hdr As NMHDR
	action As UINT
	itemOld As TVITEM
	itemNew As TVITEM
	ptDrag As Point
End Type
Type LPNMTREEVIEW As NMTREEVIEW Ptr
Type DWORD_PTR As UInteger

#ifndef LoWord
	#define LoWord(l) CUShort(CUInt(l) And &hFFFF)
#endif
#ifndef HiWord
	#define HiWord(l) CUShort((CUInt(l) Shr 16) And &hFFFF)
#endif
#define MAKELONG(a, b) CLng((CUInt(a) And &hFFFF) Or ((CUInt(b) And &hFFFF) Shl 16))
#define MAKELPARAM(l, h) MAKELONG(l, h)
#define MAKEWPARAM(l, h) MAKELONG(l, h)
#define GET_X_LPARAM(lp) CShort(LoWord(lp))
#define GET_Y_LPARAM(lp) CShort(HiWord(lp))
#define GET_WHEEL_DELTA_WPARAM(wp) CShort(HiWord(wp))
#define nullptr 0

'Messages
Const WM_CREATE = &h0001, WM_DESTROY = &h0002, WM_MOVE = &h0003, WM_SIZE = &h0005, WM_ACTIVATE = &h0006, WM_SETFOCUS = &h0007, WM_KILLFOCUS = &h0008
Const WM_ENABLE = &h000A, WM_SETREDRAW = &h000B, WM_PAINT = &h000F, WM_CLOSE = &h0010, WM_ERASEBKGND = &h0014, WM_SHOWWINDOW = &h0018
Const WM_ACTIVATEAPP = &h001C, WM_SETCURSOR = &h0020, WM_NOTIFY = &h004E, WM_NCDESTROY = &h0082, WM_NCCALCSIZE = &h0083, WM_NCHITTEST = &h0084
Const WM_NCACTIVATE = &h0086, WM_GETDLGCODE = &h0087, WM_KEYDOWN = &h0100, WM_KEYUP = &h0101, WM_CHAR = &h0102, WM_DEADCHAR = &h0103
Const WM_SYSKEYDOWN = &h0104, WM_SYSKEYUP = &h0105, WM_SYSCHAR = &h0106, WM_IME_STARTCOMPOSITION = &h010D, WM_IME_ENDCOMPOSITION = &h010E
Const WM_IME_COMPOSITION = &h010F, WM_COMMAND = &h0111, WM_SYSCOMMAND = &h0112, WM_TIMER = &h0113, WM_HSCROLL = &h0114, WM_VSCROLL = &h0115
Const WM_CTLCOLORMSGBOX = &h0132, WM_CTLCOLOREDIT = &h0133, WM_CTLCOLORLISTBOX = &h0134, WM_CTLCOLORBTN = &h0135
Const WM_CTLCOLORDLG = &h0136, WM_CTLCOLORSCROLLBAR = &h0137, WM_CTLCOLORSTATIC = &h0138
Const WM_MOUSEMOVE = &h0200, WM_LBUTTONDOWN = &h0201, WM_LBUTTONUP = &h0202, WM_LBUTTONDBLCLK = &h0203, WM_RBUTTONDOWN = &h0204
Const WM_RBUTTONUP = &h0205, WM_RBUTTONDBLCLK = &h0206, WM_MBUTTONDOWN = &h0207, WM_MBUTTONUP = &h0208, WM_MBUTTONDBLCLK = &h0209
Const WM_MOUSEWHEEL = &h020A, WM_MOUSEHWHEEL = &h020E, WM_MOUSEHOVER = &h02A1, WM_MOUSELEAVE = &h02A3, WM_DPICHANGED = &h02E0
Const WM_CUT = &h0300, WM_COPY = &h0301, WM_PASTE = &h0302, WM_CLEAR = &h0303, WM_UNDO = &h0304, WM_USER = &h0400
Const DLGC_WANTALLKEYS = &h0004, DLGC_WANTARROWS = &h0001, DLGC_WANTTAB = &h0002, DLGC_HASSETSEL = &h0008, DLGC_WANTMESSAGE = &h0004, DLGC_WANTCHARS = &h0080
'The messages of MyFbFramework on Windows (never sent on the Web and Android)
Const CM_NOTIFY = 40002, CM_CREATE = 40012
'The messages of the controls of Windows: the controls of MyFbFramework do not know them (SendMessage returns 0)
Const EM_SETMODIFY = &h00B9, EM_GETMODIFY = &h00B8, TCM_GETITEMRECT = &h130A, CBEM_GETCOMBOCONTROL = &h0406
Const TVN_FIRST = -400, TVN_ITEMEXPANDINGW = -454, TVN_ITEMEXPANDING = -454, TVGN_CHILD = 4
Const HTTRANSPARENT = -1, HTNOWHERE = 0, HTCLIENT = 1

'Keys
Const VK_LBUTTON = &h01, VK_RBUTTON = &h02, VK_CANCEL = &h03, VK_MBUTTON = &h04, VK_BACK = &h08, VK_TAB = &h09, VK_CLEAR = &h0C
Const VK_RETURN = &h0D, VK_SHIFT = &h10, VK_CONTROL = &h11, VK_MENU = &h12, VK_PAUSE = &h13, VK_CAPITAL = &h14, VK_ESCAPE = &h1B
Const VK_SPACE = &h20, VK_PRIOR = &h21, VK_NEXT = &h22, VK_END = &h23, VK_HOME = &h24, VK_LEFT = &h25, VK_UP = &h26, VK_RIGHT = &h27
Const VK_DOWN = &h28, VK_SELECT = &h29, VK_PRINT = &h2A, VK_SNAPSHOT = &h2C, VK_INSERT = &h2D, VK_DELETE = &h2E, VK_HELP = &h2F
Const VK_APPS = &h5D, VK_F1 = &h70, VK_F2 = &h71, VK_F3 = &h72, VK_F4 = &h73, VK_F5 = &h74, VK_F6 = &h75, VK_F7 = &h76, VK_F8 = &h77
Const VK_F9 = &h78, VK_F10 = &h79, VK_F11 = &h7A, VK_F12 = &h7B, VK_NUMLOCK = &h90, VK_SCROLL = &h91
Const VK_LSHIFT = &hA0, VK_RSHIFT = &hA1, VK_LCONTROL = &hA2, VK_RCONTROL = &hA3, VK_LMENU = &hA4, VK_RMENU = &hA5
Const VK_OEM_1 = &hBA, VK_OEM_PLUS = &hBB, VK_OEM_COMMA = &hBC, VK_OEM_MINUS = &hBD, VK_OEM_PERIOD = &hBE, VK_OEM_2 = &hBF
Const MK_LBUTTON = &h0001, MK_RBUTTON = &h0002, MK_SHIFT = &h0004, MK_CONTROL = &h0008, MK_MBUTTON = &h0010
Const WHEEL_DELTA = 120

'Scroll bars
Const SB_HORZ = 0, SB_VERT = 1, SB_CTL = 2, SB_BOTH = 3
Const SB_LINEUP = 0, SB_LINELEFT = 0, SB_LINEDOWN = 1, SB_LINERIGHT = 1, SB_PAGEUP = 2, SB_PAGELEFT = 2, SB_PAGEDOWN = 3
Const SB_PAGERIGHT = 3, SB_THUMBPOSITION = 4, SB_THUMBTRACK = 5, SB_TOP = 6, SB_LEFT = 6, SB_BOTTOM = 7, SB_RIGHT = 7, SB_ENDSCROLL = 8
Const SIF_RANGE = &h0001, SIF_PAGE = &h0002, SIF_POS = &h0004, SIF_DISABLENOSCROLL = &h0008, SIF_TRACKPOS = &h0010
Const SIF_ALL = SIF_RANGE Or SIF_PAGE Or SIF_POS Or SIF_TRACKPOS
Const SBS_HORZ = 0, SBS_VERT = 1

'Windows
Const WS_CHILD = &h40000000, WS_VISIBLE = &h10000000, WS_CLIPSIBLINGS = &h04000000, WS_CLIPCHILDREN = &h02000000
Const WS_VSCROLL = &h00200000, WS_HSCROLL = &h00100000, WS_TABSTOP = &h00010000, WS_EX_CLIENTEDGE = &h00000200
Const ES_WANTRETURN = &h1000, CS_DBLCLKS = &h0008, BS_BITMAP = &h0080, BM_SETIMAGE = &h00F7
#ifdef __USE_WASM__
	#define Instance Cast(HINSTANCE, 0)
#endif
Const SW_HIDE = 0, SW_NORMAL = 1, SW_SHOWNORMAL = 1, SW_SHOWNOACTIVATE = 4, SW_SHOW = 5
Const RDW_INVALIDATE = &h0001, RDW_ERASE = &h0004, RDW_UPDATENOW = &h0100, RDW_ALLCHILDREN = &h0080
Const SWP_NOSIZE = &h0001, SWP_NOMOVE = &h0002, SWP_NOZORDER = &h0004, SWP_NOACTIVATE = &h0010
#define HWND_TOP Cast(HWND, 0)
#define HWND_BOTTOM Cast(HWND, 1)
Const SM_CXSCREEN = 0, SM_CYSCREEN = 1, SM_CXVSCROLL = 2, SM_CYHSCROLL = 3
Const GWLP_WNDPROC = -4, GWLP_HINSTANCE = -6, GWLP_ID = -12, GWL_STYLE = -16, GWL_EXSTYLE = -20, GWLP_USERDATA = -21
Const CWP_ALL = 0, CWP_SKIPINVISIBLE = 1, GA_PARENT = 1, GA_ROOT = 2, GA_ROOTOWNER = 3
Const TME_LEAVE = 2, TPM_RETURNCMD = &h0100, SPI_GETNONCLIENTMETRICS = &h0029
Const DCX_WINDOW = &h01, DCX_CACHE = &h02, DCX_CLIPCHILDREN = &h08, DCX_CLIPSIBLINGS = &h10, DCX_PARENTCLIP = &h20
Const GMEM_FIXED = 0, GMEM_MOVEABLE = 2, GMEM_ZEROINIT = &h40, GMEM_DDESHARE = &h2000
Const SW_SCROLLCHILDREN = &h0001, SW_INVALIDATE = &h0002, SW_ERASE = &h0004

'Processes and files
Const STARTF_USESHOWWINDOW = &h0001, STARTF_USESTDHANDLES = &h0100
Const NORMAL_PRIORITY_CLASS = &h0020, CREATE_SUSPENDED = &h0004, CREATE_NEW_CONSOLE = &h0010, CREATE_UNICODE_ENVIRONMENT = &h0400, CREATE_NO_WINDOW = &h08000000
Const INFINITE = &hFFFFFFFF, WAIT_OBJECT_0 = 0, WAIT_TIMEOUT = &h102, WAIT_FAILED = &hFFFFFFFF, HANDLE_FLAG_INHERIT = 1
Const GENERIC_READ = &h80000000, GENERIC_WRITE = &h40000000, FILE_SHARE_READ = 1, FILE_SHARE_WRITE = 2
Const CREATE_ALWAYS = 2, OPEN_EXISTING = 3, FILE_ATTRIBUTE_NORMAL = &h80
Const ERROR_SUCCESS = 0, ERROR_FILE_NOT_FOUND = 2, ERROR_NOT_SUPPORTED = 50, ERROR_BROKEN_PIPE = 109
#define INVALID_HANDLE_VALUE Cast(HANDLE, -1)

'GDI
Const TRANSPARENT = 1, OPAQUE = 2
Const ETO_OPAQUE = &h0002, ETO_CLIPPED = &h0004
Const SRCCOPY = &h00CC0020
Const PS_SOLID = 0, PS_DASH = 1, PS_DOT = 2, PS_NULL = 5, PS_INSIDEFRAME = 6
Const WHITE_BRUSH = 0, BLACK_BRUSH = 4, NULL_BRUSH = 5, WHITE_PEN = 6, BLACK_PEN = 7, NULL_PEN = 8, DC_BRUSH = 18, DC_PEN = 19
Const R2_NOT = 6, R2_COPYPEN = 13
Const DT_LEFT = 0, DT_CENTER = 1, DT_RIGHT = 2, DT_VCENTER = 4, DT_BOTTOM = 8, DT_SINGLELINE = &h20, DT_NOPREFIX = &h800, DT_END_ELLIPSIS = &h8000
Const COLOR_WINDOW = 5, COLOR_WINDOWTEXT = 8, COLOR_HIGHLIGHT = 13, COLOR_HIGHLIGHTTEXT = 14, COLOR_BTNFACE = 15
Const COLOR_BTNSHADOW = 16, COLOR_GRAYTEXT = 17, COLOR_BTNTEXT = 18, COLOR_BTNHIGHLIGHT = 20
Const HALFTONE = 4, AC_SRC_OVER = 0, AC_SRC_ALPHA = 1, DI_NORMAL = 3, ILD_TRANSPARENT = 1, FLOODFILLBORDER = 0
Const MB_OK = 0, MB_ICONERROR = &h10, MB_ICONWARNING = &h30

'Cursors: LoadCursor(0, IDC_*) returns the IDC_* value, SetCursor gives its CSS cursor to the window under the mouse
#define IDC_ARROW Cast(Any Ptr, 32512)
#define IDC_IBEAM Cast(Any Ptr, 32513)
#define IDC_WAIT Cast(Any Ptr, 32514)
#define IDC_CROSS Cast(Any Ptr, 32515)
#define IDC_SIZENWSE Cast(Any Ptr, 32642)
#define IDC_SIZENESW Cast(Any Ptr, 32643)
#define IDC_SIZEWE Cast(Any Ptr, 32644)
#define IDC_SIZENS Cast(Any Ptr, 32645)
#define IDC_SIZEALL Cast(Any Ptr, 32646)
#define IDC_HAND Cast(Any Ptr, 32649)

'The state of the windows: subclassing (Proc), the procedure of the class (ClassProc), the user data and styles,
'the size given with the last WM_SIZE and whether the events of MyFbFramework were switched on for the window
Type Win32CompatWnd
	Wnd As HWND
	Proc As WNDPROC
	ClassProc As WNDPROC
	UserData As LONG_PTR
	Style As LONG_PTR
	ExStyle As LONG_PTR
	LastWidth As Integer = -1
	LastHeight As Integer = -1
	EventsOn As Boolean
End Type

Type Win32CompatProp
	Wnd As HWND
	Name As String
	Value As Any Ptr
End Type

Type Win32CompatClass
	Name As String
	Proc As WNDPROC
End Type

'The rectangles which Windows draws inverted outside WM_PAINT (DrawFocusRect, R2_NOT): drawn again after each WM_PAINT
Type Win32CompatOverlay
	Wnd As HWND
	R As Rect
	Focus As Boolean
End Type

'A drawing operation recorded by a memory DC: 1 - fill, 2 - pixel, 3 - rectangle (fill + frame), 4 - line
Type Win32CompatOp
	Kind As Integer
	X1 As Long
	Y1 As Long
	X2 As Long
	Y2 As Long
	Color1 As Integer
	Color2 As Integer
End Type

'A GDI object: 1 - pen, 2 - brush, 3 - font, 4 - bitmap
Type Win32CompatObject
	Kind As Integer
	Style As Integer
	Width As Integer
	Color As Integer
	Pattern As Any Ptr
	FontName As String
	FontSize As Integer
	Bold As Boolean
	Italic As Boolean
	Underline As Boolean
	'lfEscapement of the font: the angle of the text in tenths of degrees
	Escapement As Integer
	BitmapWidth As Integer
	BitmapHeight As Integer
	Ops(Any) As Win32CompatOp
End Type

'A DC: the canvas view of a window or a memory DC (MemoryDC) which records its drawing into its bitmap
Type Win32CompatDC
	Handle As HDC
	Wnd As HWND
	Canvas As My.Sys.Drawing.Canvas Ptr
	IsMemory As Boolean
	Pen As Win32CompatObject Ptr
	Brush As Win32CompatObject Ptr
	Font As Win32CompatObject Ptr
	Bitmap As Win32CompatObject Ptr
	NullPen As Boolean
	NullBrush As Boolean
	DCBrush As Boolean
	DCBrushColor As Integer = &hFFFFFF
	TextColor As Integer
	BkColor As Integer = &hFFFFFF
	BkMode As Integer = OPAQUE
	Rop2 As Integer = R2_COPYPEN
	PenX As Double
	PenY As Double
	SaveCount As Integer
End Type

'Windows of a registered class: a control whose messages go to the procedure of the class
Type Win32CompatWindow Extends My.Sys.Forms.Control
	Declare Constructor
End Type

Private Constructor Win32CompatWindow
	FMouseEvents = True
	FKeyEvents = True
	Child = @This
	WLet(FClassName, "Win32CompatWindow")
End Constructor

Type Win32CompatTimer Extends My.Sys.Forms.TimerComponent
	Wnd As HWND
	ID As UINT_PTR
	Proc As TIMERPROC
End Type

Dim Shared As Win32CompatWnd Win32CompatWnds(Any)
Dim Shared As Win32CompatProp Win32CompatProps(Any)
Dim Shared As Win32CompatClass Win32CompatClasses(Any)
Dim Shared As Win32CompatOverlay Win32CompatOverlays(Any)
'The scroll information of Windows of a scroll bar (SetScrollInfo): the element (a range) has only the positions
'nMin .. nMax - nPage + 1, nPos is the position of the program, the element has the one of the user (nTrackPos)
Type Win32CompatScrollInfo
	Wnd As HWND
	nMin As Long
	nMax As Long
	nPage As Long
	nPos As Long
End Type
Dim Shared As Win32CompatScrollInfo Win32CompatScrollInfos(Any)
'The windows brought over their siblings (BringWindowToTop, SetWindowPos), the last one is the top one: the order of
'the controls of the parent is the order of their creation, not the z-order of Windows (ChildWindowFromPointEx)
Dim Shared As HWND Win32CompatTopWnds(Any)

Private Sub Win32CompatSetTop(ByVal hwnd As HWND, ByVal bTop As Boolean)
	For i As Integer = 0 To UBound(Win32CompatTopWnds)
		If Win32CompatTopWnds(i) = hwnd Then
			For j As Integer = i To UBound(Win32CompatTopWnds) - 1
				Win32CompatTopWnds(j) = Win32CompatTopWnds(j + 1)
			Next
			If UBound(Win32CompatTopWnds) = 0 Then Erase Win32CompatTopWnds Else ReDim Preserve Win32CompatTopWnds(UBound(Win32CompatTopWnds) - 1)
			Exit For
		End If
	Next
	If bTop Then
		ReDim Preserve Win32CompatTopWnds(UBound(Win32CompatTopWnds) + 1)
		Win32CompatTopWnds(UBound(Win32CompatTopWnds)) = hwnd
	End If
End Sub
Dim Shared As Win32CompatDC Ptr Win32CompatDCs(Any)
Dim Shared As Win32CompatObject Ptr Win32CompatObjects(Any)
'The class windows which were destroyed (IsWindow is False for them)
Dim Shared As HWND Win32CompatDestroyed(Any)
Dim Shared As Win32CompatTimer Ptr Win32CompatTimers(31)
'The keys Shift, Ctrl, Alt and the mouse buttons which are down (GetKeyState)
Dim Shared As Boolean Win32CompatShift, Win32CompatCtrl, Win32CompatAlt, Win32CompatLButton, Win32CompatRButton, Win32CompatMButton
'The last point of the mouse in the pixels of the client area of Win32CompatMouseWnd (GetCursorPos, GetMessagePos)
Dim Shared As HWND Win32CompatMouseWnd, Win32CompatFocusWnd, Win32CompatCaptureWnd, Win32CompatPaintingWnd
Dim Shared As Integer Win32CompatMouseX, Win32CompatMouseY
Dim Shared As Double Win32CompatLastClickTime
Dim Shared As Integer Win32CompatLastClickX, Win32CompatLastClickY
'CallWindowProc gave the message back to the control (Win32CompatDefProc)
Dim Shared As Boolean Win32CompatDefaultCalled
'The error of the last function (GetLastError)
Dim Shared As DWORD Win32CompatLastError
'The background brush of the dark mode of MyFbFramework on Windows
Dim Shared As HBRUSH hbrBkgnd
'The caret (one for the program like on Windows)
Dim Shared As HWND Win32CompatCaretWnd
Dim Shared As Integer Win32CompatCaretX, Win32CompatCaretY, Win32CompatCaretW, Win32CompatCaretH, Win32CompatCaretShowCount
Dim Shared As Boolean Win32CompatCaretOn = True
Dim Shared As My.Sys.Forms.TimerComponent Win32CompatCaretTimer
'The clipboard of the formats which the program registered (RegisterClipboardFormat): it stays in the program
Dim Shared As UINT Win32CompatClipFormats(Any)
Dim Shared As Any Ptr Win32CompatClipData(Any)
Dim Shared As String Win32CompatClipNames(Any)

Declare Function SendMessage(ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
Declare Function Win32CompatHook(ByVal Ctrl As My.Sys.Forms.Control Ptr, ByRef msg As Message) As Boolean

'''' Windows and controls

'The control of a handle: on the Web the handle of a control is the control itself (the id of its element),
'on Android it is its View (or the layout of a Form)
Private Function Win32CompatControl(ByVal hwnd As HWND) As My.Sys.Forms.Control Ptr
	If hwnd = 0 Then Return 0
	#ifdef __USE_WASM__
		Return hwnd
	#else
		For i As Integer = 0 To Handles.Count - 1
			Dim As My.Sys.Forms.Control Ptr Ctrl = Handles.Item(i)
			If Ctrl <> 0 AndAlso (Ctrl->Handle = hwnd OrElse Ctrl->LayoutHandle = hwnd) Then Return Ctrl
		Next
		Return 0
	#endif
End Function

'The view on which the control draws (its canvas): the Android Form draws in its layout
Private Function Win32CompatView(ByVal Ctrl As My.Sys.Forms.Control Ptr) As Any Ptr
	If Ctrl = 0 Then Return 0
	#ifdef __USE_JNI__
		If Ctrl->LayoutHandle Then Return Ctrl->LayoutHandle
	#endif
	Return Ctrl->Handle
End Function

Private Function Win32CompatFindWnd(ByVal hwnd As HWND, ByVal bAdd As Boolean = False) As Win32CompatWnd Ptr
	If hwnd = 0 Then Return 0
	For i As Integer = 0 To UBound(Win32CompatWnds)
		If Win32CompatWnds(i).Wnd = hwnd Then Return @Win32CompatWnds(i)
	Next
	If Not bAdd Then Return 0
	ReDim Preserve Win32CompatWnds(UBound(Win32CompatWnds) + 1)
	Win32CompatWnds(UBound(Win32CompatWnds)).Wnd = hwnd
	Return @Win32CompatWnds(UBound(Win32CompatWnds))
End Function

Private Sub Win32CompatRemoveWnd(ByVal hwnd As HWND)
	For i As Integer = UBound(Win32CompatWnds) To 0 Step -1
		If Win32CompatWnds(i).Wnd = hwnd Then
			For j As Integer = i To UBound(Win32CompatWnds) - 1
				Win32CompatWnds(j) = Win32CompatWnds(j + 1)
			Next
			If UBound(Win32CompatWnds) = 0 Then Erase Win32CompatWnds Else ReDim Preserve Win32CompatWnds(UBound(Win32CompatWnds) - 1)
		End If
	Next
	For i As Integer = UBound(Win32CompatProps) To 0 Step -1
		If Win32CompatProps(i).Wnd = hwnd Then
			For j As Integer = i To UBound(Win32CompatProps) - 1
				Win32CompatProps(j) = Win32CompatProps(j + 1)
			Next
			If UBound(Win32CompatProps) = 0 Then Erase Win32CompatProps Else ReDim Preserve Win32CompatProps(UBound(Win32CompatProps) - 1)
		End If
	Next
End Sub

'The procedure which gets the messages of the window first (subclassing or the class), 0 - none
Private Function Win32CompatWndProc(ByVal hwnd As HWND) As WNDPROC
	Dim As Win32CompatWnd Ptr w = Win32CompatFindWnd(hwnd)
	If w = 0 Then Return 0
	If w->Proc Then Return w->Proc
	Return w->ClassProc
End Function

'The mouse and key events of MyFbFramework for a window which gets a procedure after it was created
Private Sub Win32CompatEnableEvents(ByVal hwnd As HWND)
	Dim As Win32CompatWnd Ptr w = Win32CompatFindWnd(hwnd, True)
	If w->EventsOn Then Exit Sub
	w->EventsOn = True
	ControlMessageHook = @Win32CompatHook
	#ifdef __USE_WASM__
		SetMouseDownEvent(hwnd)
		SetMouseMoveEvent(hwnd)
		SetMouseUpEvent(hwnd)
		SetMouseLeaveEvent(hwnd)
		SetMouseWheelEvent(hwnd)
		SetKeyDownEvent(hwnd)
		SetKeyPressEvent(hwnd)
		SetKeyUpEvent(hwnd)
		SetGotFocusEvent(hwnd)
		SetLostFocusEvent(hwnd)
	#else
		SetTouchEvent(hwnd)
		SetKeyEvent(hwnd, False)
	#endif
End Sub

'The position of the client area of the window on the screen (the page, the Android activity)
#ifdef __USE_WASM__
	'A designed form has its title bar above it in the panel of the designer (Form.GetContent, .mffdesign of mff.html):
	'its client area is lower like the one of a window with a caption on Windows
	Private Function Win32CompatCaptionHeight(ByVal Ctrl As My.Sys.Forms.Control Ptr) As Integer
		If Ctrl->DesignMode AndAlso Ctrl->ClassName = "Form" AndAlso Cast(My.Sys.Forms.Form Ptr, Ctrl)->BorderStyle <> FormBorderStyle.None Then Return Ctrl->ScaleY(28)
		Return 0
	End Function
#elseif defined(__USE_JNI__)
	'Android: the view of the designed form is lower than its place by its title bar (Component.DesignCaptionHeight)
	Private Function Win32CompatCaptionHeight(ByVal Ctrl As My.Sys.Forms.Control Ptr) As Integer
		Return Ctrl->ScaleY(Ctrl->DesignCaptionHeight)
	End Function
#endif

Private Function Win32CompatScreenPos(ByVal Ctrl As My.Sys.Forms.Control Ptr) As Point
	Dim As Point P
	While Ctrl <> 0 AndAlso Ctrl->Parent <> 0
		P.X += Ctrl->ScaleX(Ctrl->Left)
		P.Y += Ctrl->ScaleY(Ctrl->Top)
		#if defined(__USE_WASM__) OrElse defined(__USE_JNI__)
			P.Y += Win32CompatCaptionHeight(Ctrl)
		#endif
		Ctrl = Ctrl->Parent
	Wend
	Return P
End Function

Private Function GetParent(ByVal hwnd As HWND) As HWND
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 OrElse Ctrl->Parent = 0 Then Return 0
	Return Cast(My.Sys.Forms.Control Ptr, Ctrl->Parent)->Handle
End Function

Private Function GetAncestor(ByVal hwnd As HWND, ByVal gaFlags As UINT) As HWND
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	If gaFlags = GA_PARENT Then Return GetParent(hwnd)
	While Ctrl->Parent <> 0
		Ctrl = Ctrl->Parent
	Wend
	Return Ctrl->Handle
End Function

Private Function IsWindow(ByVal hwnd As HWND) As BOOL
	If hwnd = 0 Then Return 0
	For i As Integer = 0 To UBound(Win32CompatDestroyed)
		If Win32CompatDestroyed(i) = hwnd Then Return 0
	Next
	Return Win32CompatControl(hwnd) <> 0
End Function

Private Function IsWindowVisible(ByVal hwnd As HWND) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	Return Ctrl <> 0 AndAlso Ctrl->Visible
End Function

Private Function GetWindowRect(ByVal hwnd As HWND, ByVal lpRect As Rect Ptr) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 OrElse lpRect = 0 Then Return 0
	Dim As Point P = Win32CompatScreenPos(Ctrl)
	lpRect->Left = P.X
	lpRect->Top = P.Y
	lpRect->Right = P.X + Ctrl->ScaleX(Ctrl->Width)
	lpRect->Bottom = P.Y + Ctrl->ScaleY(Ctrl->Height)
	#if defined(__USE_WASM__) OrElse defined(__USE_JNI__)
		'The window has its title bar (its Height is the one of the client area)
		lpRect->Top -= Win32CompatCaptionHeight(Ctrl)
	#endif
	Return 1
End Function

Private Function GetClientRect(ByVal hwnd As HWND, ByVal lpRect As Rect Ptr) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 OrElse lpRect = 0 Then Return 0
	lpRect->Left = 0
	lpRect->Top = 0
	lpRect->Right = Ctrl->ScaleX(Ctrl->ClientWidth)
	lpRect->Bottom = Ctrl->ScaleY(Ctrl->ClientHeight)
	Return 1
End Function

Private Function ScreenToClient(ByVal hwnd As HWND, ByVal lpPoint As Point Ptr) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 OrElse lpPoint = 0 Then Return 0
	Dim As Point P = Win32CompatScreenPos(Ctrl)
	lpPoint->X -= P.X
	lpPoint->Y -= P.Y
	Return 1
End Function

Private Function ClientToScreen(ByVal hwnd As HWND, ByVal lpPoint As Point Ptr) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 OrElse lpPoint = 0 Then Return 0
	Dim As Point P = Win32CompatScreenPos(Ctrl)
	lpPoint->X += P.X
	lpPoint->Y += P.Y
	Return 1
End Function

Private Function MapWindowPoints(ByVal hWndFrom As HWND, ByVal hWndTo As HWND, ByVal lpPoints As Point Ptr, ByVal cPoints As UINT) As Long
	Dim As Point PFrom, PTo
	If hWndFrom Then PFrom = Win32CompatScreenPos(Win32CompatControl(hWndFrom))
	If hWndTo Then PTo = Win32CompatScreenPos(Win32CompatControl(hWndTo))
	For i As Integer = 0 To cPoints - 1
		lpPoints[i].X += PFrom.X - PTo.X
		lpPoints[i].Y += PFrom.Y - PTo.Y
	Next
	Return MAKELONG(PFrom.X - PTo.X, PFrom.Y - PTo.Y)
End Function

'The child (not a grandchild) at the point of the client area of the parent: the last one is over the others
Private Function ChildWindowFromPointEx(ByVal hwndParent As HWND, ByVal pt As Point, ByVal flags As UINT) As HWND
	Dim As My.Sys.Forms.Control Ptr Parent = Win32CompatControl(hwndParent)
	If Parent = 0 Then Return 0
	If pt.X < 0 OrElse pt.Y < 0 OrElse pt.X >= Parent->ScaleX(Parent->Width) OrElse pt.Y >= Parent->ScaleY(Parent->Height) Then Return 0
	'The windows brought to the top first
	For i As Integer = UBound(Win32CompatTopWnds) To 0 Step -1
		'A window is a control on the Web, a view on Android (Win32CompatControl finds its control)
		Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(Win32CompatTopWnds(i))
		If Ctrl = 0 OrElse Ctrl->Parent <> Parent OrElse Ctrl->Handle = 0 Then Continue For
		If CBool(flags And CWP_SKIPINVISIBLE) AndAlso (Not Ctrl->Visible) Then Continue For
		Dim As Long l = Ctrl->ScaleX(Ctrl->Left), t = Ctrl->ScaleY(Ctrl->Top)
		If pt.X >= l AndAlso pt.Y >= t AndAlso pt.X < l + Ctrl->ScaleX(Ctrl->Width) AndAlso pt.Y < t + Ctrl->ScaleY(Ctrl->Height) Then Return Ctrl->Handle
	Next
	For i As Integer = Parent->ControlCount - 1 To 0 Step -1
		Dim As My.Sys.Forms.Control Ptr Ctrl = Parent->Controls[i]
		If Ctrl = 0 OrElse Ctrl->Handle = 0 Then Continue For
		If CBool(flags And CWP_SKIPINVISIBLE) AndAlso (Not Ctrl->Visible) Then Continue For
		Dim As Long l = Ctrl->ScaleX(Ctrl->Left), t = Ctrl->ScaleY(Ctrl->Top)
		If pt.X >= l AndAlso pt.Y >= t AndAlso pt.X < l + Ctrl->ScaleX(Ctrl->Width) AndAlso pt.Y < t + Ctrl->ScaleY(Ctrl->Height) Then Return Ctrl->Handle
	Next
	Return hwndParent
End Function

Private Function ChildWindowFromPoint(ByVal hwndParent As HWND, ByVal pt As Point) As HWND
	Return ChildWindowFromPointEx(hwndParent, pt, CWP_ALL)
End Function

Private Function Win32CompatEnumChilds(ByVal Parent As My.Sys.Forms.Control Ptr, ByVal lpEnumFunc As WNDENUMPROC, ByVal lParam As LPARAM) As Boolean
	For i As Integer = 0 To Parent->ControlCount - 1
		Dim As My.Sys.Forms.Control Ptr Ctrl = Parent->Controls[i]
		If Ctrl = 0 OrElse Ctrl->Handle = 0 Then Continue For
		If lpEnumFunc(Ctrl->Handle, lParam) = 0 Then Return False
		If Not Win32CompatEnumChilds(Ctrl, lpEnumFunc, lParam) Then Return False
	Next
	Return True
End Function

Private Function EnumChildWindows(ByVal hWndParent As HWND, ByVal lpEnumFunc As WNDENUMPROC, ByVal lParam As LPARAM) As BOOL
	Dim As My.Sys.Forms.Control Ptr Parent = Win32CompatControl(hWndParent)
	If Parent = 0 OrElse lpEnumFunc = 0 Then Return 0
	Win32CompatEnumChilds Parent, lpEnumFunc, lParam
	Return 1
End Function

Private Function EnableWindow(ByVal hwnd As HWND, ByVal bEnable As BOOL) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl Then Ctrl->Enabled = bEnable <> 0
	Return 1
End Function

Private Function ShowWindow(ByVal hwnd As HWND, ByVal nCmdShow As Long) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	Function = Ctrl->Visible
	Ctrl->Visible = nCmdShow <> SW_HIDE
	'A window with its own procedure draws itself (WM_PAINT) when it is shown
	If Ctrl->Visible AndAlso Win32CompatWndProc(hwnd) <> 0 Then Ctrl->Repaint
End Function

'The coordinates of Windows are pixels, the ones of the controls are units
Private Function MoveWindow(ByVal hwnd As HWND, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal bRepaint As BOOL) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	#if defined(__USE_WASM__) OrElse defined(__USE_JNI__)
		'The height of the window has its title bar (GetWindowRect)
		nHeight -= Win32CompatCaptionHeight(Ctrl)
	#endif
	Ctrl->SetBounds Ctrl->UnScaleX(X), Ctrl->UnScaleY(Y), Ctrl->UnScaleX(nWidth), Ctrl->UnScaleY(nHeight)
	If CBool(bRepaint) AndAlso Ctrl->Visible AndAlso Win32CompatWndProc(hwnd) <> 0 Then Ctrl->Repaint
	Return 1
End Function

Private Function SetWindowPos(ByVal hwnd As HWND, ByVal hWndInsertAfter As HWND, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal uFlags As UINT) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	If (uFlags And SWP_NOZORDER) = 0 Then
		If hWndInsertAfter = HWND_BOTTOM Then Ctrl->SendToBack Else Ctrl->BringToFront
		Win32CompatSetTop hwnd, hWndInsertAfter <> HWND_BOTTOM
	End If
	If (uFlags And SWP_NOMOVE) = 0 OrElse (uFlags And SWP_NOSIZE) = 0 Then
		Dim As Integer l = Ctrl->Left, t = Ctrl->Top, w = Ctrl->Width, h = Ctrl->Height
		If (uFlags And SWP_NOMOVE) = 0 Then l = Ctrl->UnScaleX(X): t = Ctrl->UnScaleY(Y)
		#if defined(__USE_WASM__) OrElse defined(__USE_JNI__)
			cy -= Win32CompatCaptionHeight(Ctrl)
		#endif
		If (uFlags And SWP_NOSIZE) = 0 Then w = Ctrl->UnScaleX(cx): h = Ctrl->UnScaleY(cy)
		Ctrl->SetBounds l, t, w, h
	End If
	Return 1
End Function

Private Function BringWindowToTop(ByVal hwnd As HWND) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl Then Ctrl->BringToFront: Win32CompatSetTop hwnd, True
	Return 1
End Function

Private Function LockWindowUpdate(ByVal hWndLock As HWND) As BOOL
	Return 1
End Function

Private Function SetParent(ByVal hWndChild As HWND, ByVal hWndNewParent As HWND) As HWND
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hWndChild), NewParent = Win32CompatControl(hWndNewParent)
	If Ctrl = 0 Then Return 0
	Function = GetParent(hWndChild)
	If Ctrl->Parent <> 0 AndAlso Ctrl->Parent <> NewParent Then Cast(My.Sys.Forms.Control Ptr, Ctrl->Parent)->Remove Ctrl
	If NewParent <> 0 AndAlso Ctrl->Parent <> NewParent Then NewParent->Add Ctrl
End Function

Private Function SetForegroundWindow(ByVal hwnd As HWND) As BOOL
	Return 1
End Function

'The children of the window move with the scrolled contents (SW_SCROLLCHILDREN), the window is drawn again
Private Function ScrollWindowEx(ByVal hwnd As HWND, ByVal dx As Long, ByVal dy As Long, ByVal prcScroll As Const Rect Ptr, ByVal prcClip As Const Rect Ptr, ByVal hrgnUpdate As HRGN, ByVal prcUpdate As Rect Ptr, ByVal flags As UINT) As Long
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	If flags And SW_SCROLLCHILDREN Then
		For i As Integer = 0 To Ctrl->ControlCount - 1
			Dim As My.Sys.Forms.Control Ptr Child = Ctrl->Controls[i]
			If Child Then Child->SetBounds Child->Left + Ctrl->UnScaleX(dx), Child->Top + Ctrl->UnScaleY(dy), Child->Width, Child->Height
		Next
	End If
	Ctrl->Repaint
	Return 2
End Function

Private Function DragAcceptFiles(ByVal hwnd As HWND, ByVal fAccept As BOOL) As BOOL
	Return 1
End Function

'''' The message loop of Windows: the browser / Android has its own, GetMessage ends the loops of the program at once
Private Function GetMessage(ByVal lpMsg As MSG Ptr, ByVal hwnd As HWND, ByVal wMsgFilterMin As UINT, ByVal wMsgFilterMax As UINT) As BOOL
	Return 0
End Function

Private Function PeekMessage(ByVal lpMsg As MSG Ptr, ByVal hwnd As HWND, ByVal wMsgFilterMin As UINT, ByVal wMsgFilterMax As UINT, ByVal wRemoveMsg As UINT) As BOOL
	Return 0
End Function

Private Function TranslateMessage(ByVal lpMsg As Const MSG Ptr) As BOOL
	Return 0
End Function

Private Function DispatchMessage(ByVal lpMsg As Const MSG Ptr) As LRESULT
	Return 0
End Function

'''' Processes: the Web and Android programs cannot start other programs (the compiler, the program which was compiled)

Private Function GetLastError() As DWORD
	Return Win32CompatLastError
End Function

Private Sub SetLastError(ByVal dwErrCode As DWORD)
	Win32CompatLastError = dwErrCode
End Sub

Private Function CreatePipe(ByVal hReadPipe As HANDLE Ptr, ByVal hWritePipe As HANDLE Ptr, ByVal lpPipeAttributes As SECURITY_ATTRIBUTES Ptr, ByVal nSize As DWORD) As BOOL
	Win32CompatLastError = ERROR_NOT_SUPPORTED
	Return 0
End Function

Private Function CreateProcess(ByVal lpApplicationName As Const WString Ptr, ByVal lpCommandLine As WString Ptr, ByVal lpProcessAttributes As SECURITY_ATTRIBUTES Ptr, ByVal lpThreadAttributes As SECURITY_ATTRIBUTES Ptr, ByVal bInheritHandles As BOOL, ByVal dwCreationFlags As DWORD, ByVal lpEnvironment As Any Ptr, ByVal lpCurrentDirectory As Const WString Ptr, ByVal lpStartupInfo As STARTUPINFO Ptr, ByVal lpProcessInformation As PROCESS_INFORMATION Ptr) As BOOL
	Win32CompatLastError = ERROR_NOT_SUPPORTED
	Return 0
End Function

Private Function CreateProcessW(ByVal lpApplicationName As Const WString Ptr, ByVal lpCommandLine As WString Ptr, ByVal lpProcessAttributes As SECURITY_ATTRIBUTES Ptr, ByVal lpThreadAttributes As SECURITY_ATTRIBUTES Ptr, ByVal bInheritHandles As BOOL, ByVal dwCreationFlags As DWORD, ByVal lpEnvironment As Any Ptr, ByVal lpCurrentDirectory As Const WString Ptr, ByVal lpStartupInfo As STARTUPINFO Ptr, ByVal lpProcessInformation As PROCESS_INFORMATION Ptr) As BOOL
	Return CreateProcess(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation)
End Function

Private Function CreateJobObject(ByVal lpJobAttributes As SECURITY_ATTRIBUTES Ptr, ByVal lpName As Const WString Ptr) As HANDLE
	Return NULL
End Function

Private Function AssignProcessToJobObject(ByVal hJob As HANDLE, ByVal hProcess As HANDLE) As BOOL
	Return 0
End Function

Private Function TerminateJobObject(ByVal hJob As HANDLE, ByVal uExitCode As UINT) As BOOL
	Return 0
End Function

Private Function ResumeThread(ByVal hThread As HANDLE) As DWORD
	Return &hFFFFFFFF
End Function

Private Function WaitForSingleObject(ByVal hHandle As HANDLE, ByVal dwMilliseconds As DWORD) As DWORD
	Return WAIT_FAILED
End Function

Private Function GetExitCodeProcess(ByVal hProcess As HANDLE, ByVal lpExitCode As DWORD Ptr) As BOOL
	If lpExitCode Then *lpExitCode = 0
	Return 0
End Function

Private Function ReadFile(ByVal hFile As HANDLE, ByVal lpBuffer As Any Ptr, ByVal nNumberOfBytesToRead As DWORD, ByVal lpNumberOfBytesRead As DWORD Ptr, ByVal lpOverlapped As Any Ptr) As BOOL
	If lpNumberOfBytesRead Then *lpNumberOfBytesRead = 0
	Win32CompatLastError = ERROR_BROKEN_PIPE
	Return 0
End Function

Private Function CloseHandle(ByVal hObject As HANDLE) As BOOL
	Return 1
End Function

Private Function SetHandleInformation(ByVal hObject As HANDLE, ByVal dwMask As DWORD, ByVal dwFlags As DWORD) As BOOL
	Return 0
End Function

'Only the files of the program are opened with the file functions of FreeBASIC: CreateFile does not open them
Private Function CreateFile(ByRef lpFileName As WString, ByVal dwDesiredAccess As DWORD, ByVal dwShareMode As DWORD, ByVal lpSecurityAttributes As SECURITY_ATTRIBUTES Ptr, ByVal dwCreationDisposition As DWORD, ByVal dwFlagsAndAttributes As DWORD, ByVal hTemplateFile As HANDLE) As HANDLE
	Win32CompatLastError = ERROR_NOT_SUPPORTED
	Return INVALID_HANDLE_VALUE
End Function

'There are no programs to find on the Web / Android
Private Function SearchPath(ByVal lpPath As Const WString Ptr, ByRef lpFileName As WString, ByVal lpExtension As Const WString Ptr, ByVal nBufferLength As DWORD, ByVal lpBuffer As WString Ptr, ByVal lpFilePart As WString Ptr Ptr) As DWORD
	Win32CompatLastError = ERROR_FILE_NOT_FOUND
	Return 0
End Function

Private Function CopyFileW(ByVal lpExistingFileName As Const WString Ptr, ByVal lpNewFileName As Const WString Ptr, ByVal bFailIfExists As BOOL) As BOOL
	If lpExistingFileName = 0 OrElse lpNewFileName = 0 Then Return 0
	If bFailIfExists <> 0 AndAlso FileExists(*lpNewFileName) Then Return 0
	Dim As Integer FnIn = FreeFile
	If Open(*lpExistingFileName For Binary Access Read As #FnIn) <> 0 Then Win32CompatLastError = ERROR_FILE_NOT_FOUND: Return 0
	Dim As String sData = Space(LOF(FnIn))
	If Len(sData) Then Get #FnIn, , sData
	Close #FnIn
	Dim As Integer FnOut = FreeFile
	If Open(*lpNewFileName For Binary Access Write As #FnOut) <> 0 Then Return 0
	If Len(sData) Then Put #FnOut, , sData
	Close #FnOut
	Return 1
End Function

Private Function ExtractIconEx(ByRef lpszFile As WString, ByVal nIconIndex As Long, ByVal phiconLarge As HICON Ptr, ByVal phiconSmall As HICON Ptr, ByVal nIcons As UINT) As UINT
	Return 0
End Function

Private Function DestroyIcon(ByVal hIcon As HICON) As BOOL
	Return 1
End Function

Private Function GetComboBoxInfo(ByVal hwndCombo As HWND, ByVal pcbi As COMBOBOXINFO Ptr) As BOOL
	Return 0
End Function

Private Function ListView_GetSubItemRect(ByVal hwnd As HWND, ByVal iItem As Long, ByVal iSubItem As Long, ByVal code As Long, ByVal prc As Rect Ptr) As BOOL
	Return 0
End Function

Private Function TreeView_GetNextItem(ByVal hwnd As HWND, ByVal hitem As Any Ptr, ByVal code As UINT) As Any Ptr
	Return 0
End Function

Private Function UpdateWindow(ByVal hwnd As HWND) As BOOL
	Return 1
End Function

Private Function RedrawWindow(ByVal hwnd As HWND, ByVal lprcUpdate As Const Rect Ptr, ByVal hrgnUpdate As HRGN, ByVal flags As UINT) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl Then Ctrl->Repaint
	Return 1
End Function

Private Function InvalidateRect(ByVal hwnd As HWND, ByVal lpRect As Const Rect Ptr, ByVal bErase As BOOL) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl Then Ctrl->Repaint
	Return 1
End Function

'''' Window procedures, properties and classes

'The procedure which a subclassed window had before: CallWindowProc with it gives the message back to the control
Private Function Win32CompatDefProc(ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	If uMsg = WM_NCHITTEST Then Return HTCLIENT
	Win32CompatDefaultCalled = True
	Return 0
End Function

Private Function DefWindowProc(ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	If uMsg = WM_NCHITTEST Then Return HTCLIENT
	'Windows gives the wheel to the parent: the browser scrolls the parents (Win32CompatDispatch)
	If uMsg = WM_MOUSEWHEEL Then Win32CompatDefaultCalled = True
	Return 0
End Function

Private Function CallWindowProc(ByVal lpPrevWndFunc As WNDPROC, ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	If lpPrevWndFunc = 0 OrElse lpPrevWndFunc = @Win32CompatDefProc Then Return Win32CompatDefProc(hwnd, uMsg, wParam, lParam)
	Return lpPrevWndFunc(hwnd, uMsg, wParam, lParam)
End Function

Private Function GetWindowLongPtr(ByVal hwnd As HWND, ByVal nIndex As Long) As LONG_PTR
	Dim As Win32CompatWnd Ptr w = Win32CompatFindWnd(hwnd)
	Select Case nIndex
	Case GWLP_WNDPROC
		If w <> 0 AndAlso w->Proc <> 0 Then Return Cast(LONG_PTR, w->Proc)
		If w <> 0 AndAlso w->ClassProc <> 0 Then Return Cast(LONG_PTR, w->ClassProc)
		Return Cast(LONG_PTR, @Win32CompatDefProc)
	Case GWLP_USERDATA: If w Then Return w->UserData
	Case GWL_STYLE
		Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
		Return IIf(w, w->Style, 0) Or WS_CHILD Or IIf(Ctrl <> 0 AndAlso Ctrl->Visible, WS_VISIBLE, 0)
	Case GWL_EXSTYLE: If w Then Return w->ExStyle
	End Select
	Return 0
End Function

Private Function SetWindowLongPtr(ByVal hwnd As HWND, ByVal nIndex As Long, ByVal dwNewLong As LONG_PTR) As LONG_PTR
	If hwnd = 0 Then Return 0
	Dim As Win32CompatWnd Ptr w = Win32CompatFindWnd(hwnd, True)
	Function = GetWindowLongPtr(hwnd, nIndex)
	Select Case nIndex
	Case GWLP_WNDPROC
		'The old procedure of a control or the procedure of its class: the window is not subclassed any more
		If dwNewLong = Cast(LONG_PTR, @Win32CompatDefProc) OrElse dwNewLong = Cast(LONG_PTR, w->ClassProc) Then
			w->Proc = 0
		Else
			w->Proc = Cast(WNDPROC, dwNewLong)
			Win32CompatEnableEvents hwnd
		End If
	Case GWLP_USERDATA: w->UserData = dwNewLong
	Case GWL_STYLE: w->Style = dwNewLong
	Case GWL_EXSTYLE: w->ExStyle = dwNewLong
	End Select
End Function

'The property "MFFControl" which MyFbFramework gives to its windows on Windows is the control itself
Private Function GetProp(ByVal hwnd As HWND, ByRef lpString As WString) As Any Ptr
	For i As Integer = 0 To UBound(Win32CompatProps)
		If Win32CompatProps(i).Wnd = hwnd AndAlso Win32CompatProps(i).Name = lpString Then Return Win32CompatProps(i).Value
	Next
	If lpString = "MFFControl" Then
		#ifdef __USE_WASM__
			Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
			If Ctrl AndAlso *Ctrl Is My.Sys.Forms.ReportHost Then Return Cast(My.Sys.Forms.ReportHost Ptr, Ctrl)->Owner
		#endif
		Return Win32CompatControl(hwnd)
	End If
	Return 0
End Function

Private Function SetProp(ByVal hwnd As HWND, ByRef lpString As WString, ByVal hData As Any Ptr) As BOOL
	If hwnd = 0 Then Return 0
	For i As Integer = 0 To UBound(Win32CompatProps)
		If Win32CompatProps(i).Wnd = hwnd AndAlso Win32CompatProps(i).Name = lpString Then Win32CompatProps(i).Value = hData: Return 1
	Next
	ReDim Preserve Win32CompatProps(UBound(Win32CompatProps) + 1)
	With Win32CompatProps(UBound(Win32CompatProps))
		.Wnd = hwnd
		.Name = lpString
		.Value = hData
	End With
	Return 1
End Function

Private Function RemoveProp(ByVal hwnd As HWND, ByRef lpString As WString) As Any Ptr
	For i As Integer = 0 To UBound(Win32CompatProps)
		If Win32CompatProps(i).Wnd = hwnd AndAlso Win32CompatProps(i).Name = lpString Then
			Function = Win32CompatProps(i).Value
			For j As Integer = i To UBound(Win32CompatProps) - 1
				Win32CompatProps(j) = Win32CompatProps(j + 1)
			Next
			If UBound(Win32CompatProps) = 0 Then Erase Win32CompatProps Else ReDim Preserve Win32CompatProps(UBound(Win32CompatProps) - 1)
			Exit Function
		End If
	Next
	Return 0
End Function

Private Function RegisterClassEx(ByVal lpwcx As Const WNDCLASSEX Ptr) As ATOM
	If lpwcx = 0 OrElse lpwcx->lpszClassName = 0 Then Return 0
	Dim As String sName = LCase(*lpwcx->lpszClassName)
	For i As Integer = 0 To UBound(Win32CompatClasses)
		If Win32CompatClasses(i).Name = sName Then Win32CompatClasses(i).Proc = lpwcx->lpfnWndProc: Return i + 1
	Next
	ReDim Preserve Win32CompatClasses(UBound(Win32CompatClasses) + 1)
	Win32CompatClasses(UBound(Win32CompatClasses)).Name = sName
	Win32CompatClasses(UBound(Win32CompatClasses)).Proc = lpwcx->lpfnWndProc
	Return UBound(Win32CompatClasses) + 1
End Function

Private Function UnregisterClass(ByRef lpClassName As WString, ByVal hInstance As HINSTANCE) As BOOL
	For i As Integer = 0 To UBound(Win32CompatClasses)
		If Win32CompatClasses(i).Name = LCase(lpClassName) Then Win32CompatClasses(i).Proc = 0: Return 1
	Next
	Return 0
End Function

'''' Messages

'The message goes to the procedure of the window, otherwise to the control (EditControl knows the WM_* messages)
Private Function SendMessage(ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	Dim As WNDPROC Proc = Win32CompatWndProc(hwnd)
	If Proc Then Return Proc(hwnd, uMsg, wParam, lParam)
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	Dim As Message msg
	msg.Sender = Ctrl
	msg.hWnd = hwnd
	msg.Msg = uMsg
	msg.wParam = wParam
	msg.lParam = lParam
	msg.wParamLo = LoWord(wParam): msg.wParamHi = HiWord(wParam)
	msg.lParamLo = LoWord(lParam): msg.lParamHi = HiWord(lParam)
	Ctrl->ProcessMessage(msg)
	Return msg.Result
End Function

Private Function PostMessage(ByVal hwnd As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As BOOL
	SendMessage(hwnd, uMsg, wParam, lParam)
	Return 1
End Function

'''' GDI objects and DCs

Private Function Win32CompatObject(ByVal h As Any Ptr) As Win32CompatObject Ptr
	If h = 0 Then Return 0
	For i As Integer = 0 To UBound(Win32CompatObjects)
		If Win32CompatObjects(i) = h Then Return h
	Next
	Return 0
End Function

Private Function Win32CompatNewObject(ByVal Kind As Integer) As Win32CompatObject Ptr
	Dim As Win32CompatObject Ptr o = New Win32CompatObject
	o->Kind = Kind
	ReDim Preserve Win32CompatObjects(UBound(Win32CompatObjects) + 1)
	Win32CompatObjects(UBound(Win32CompatObjects)) = o
	Return o
End Function

Private Function DeleteObject(ByVal ho As HGDIOBJ) As BOOL
	For i As Integer = 0 To UBound(Win32CompatObjects)
		If Win32CompatObjects(i) = ho Then
			Delete Win32CompatObjects(i)
			For j As Integer = i To UBound(Win32CompatObjects) - 1
				Win32CompatObjects(j) = Win32CompatObjects(j + 1)
			Next
			If UBound(Win32CompatObjects) = 0 Then Erase Win32CompatObjects Else ReDim Preserve Win32CompatObjects(UBound(Win32CompatObjects) - 1)
			Return 1
		End If
	Next
	Return 0
End Function

Private Function CreatePen(ByVal iStyle As Long, ByVal cWidth As Long, ByVal crColor As COLORREF) As HPEN
	Dim As Win32CompatObject Ptr o = Win32CompatNewObject(1)
	o->Style = iStyle
	o->Width = Max(1, cWidth)
	o->Color = crColor
	Return o
End Function

Private Function CreateSolidBrush(ByVal crColor As COLORREF) As HBRUSH
	Dim As Win32CompatObject Ptr o = Win32CompatNewObject(2)
	o->Color = crColor
	Return o
End Function

'A brush which repeats the drawing of a bitmap (CreateCompatibleBitmap, drawn with a memory DC)
Private Function CreatePatternBrush(ByVal hbm As HBITMAP) As HBRUSH
	Dim As Win32CompatObject Ptr o = Win32CompatNewObject(2)
	Dim As Win32CompatObject Ptr b = Win32CompatObject(hbm)
	o->Color = &hFFFFFF
	If b <> 0 AndAlso b->Kind = 4 Then
		o->Pattern = b
		'A copy of the drawing: the bitmap can be deleted after this like on Windows
		Dim As Win32CompatObject Ptr p = Win32CompatNewObject(4)
		p->BitmapWidth = b->BitmapWidth
		p->BitmapHeight = b->BitmapHeight
		If UBound(b->Ops) >= 0 Then
			ReDim p->Ops(UBound(b->Ops))
			For i As Integer = 0 To UBound(b->Ops)
				p->Ops(i) = b->Ops(i)
			Next
		End If
		o->Pattern = p
	End If
	Return o
End Function

Private Function CreateFontIndirect(ByVal lplf As Const LOGFONT Ptr) As HFONT
	Dim As Win32CompatObject Ptr o = Win32CompatNewObject(3)
	If lplf Then
		o->FontName = lplf->lfFaceName
		o->FontSize = Abs(lplf->lfHeight)
		o->Bold = lplf->lfWeight >= 600
		o->Italic = lplf->lfItalic <> 0
		o->Underline = lplf->lfUnderline <> 0
		o->Escapement = lplf->lfEscapement
	End If
	Return o
End Function

Private Function CreateCompatibleBitmap(ByVal hdc As HDC, ByVal cx As Long, ByVal cy As Long) As HBITMAP
	Dim As Win32CompatObject Ptr o = Win32CompatNewObject(4)
	o->BitmapWidth = cx
	o->BitmapHeight = cy
	Return o
End Function

Private Function GetObject(ByVal h As HANDLE, ByVal c As Long, ByVal pv As Any Ptr) As Long
	Dim As Win32CompatObject Ptr o = Win32CompatObject(h)
	If o = 0 OrElse pv = 0 Then Return 0
	Select Case o->Kind
	Case 2
		If c < SizeOf(LOGBRUSH) Then Return 0
		Cast(LOGBRUSH Ptr, pv)->lbStyle = 0
		Cast(LOGBRUSH Ptr, pv)->lbColor = o->Color
		Return SizeOf(LOGBRUSH)
	Case 3
		If c < SizeOf(LOGFONT) Then Return 0
		With *Cast(LOGFONT Ptr, pv)
			.lfHeight = -o->FontSize
			.lfWeight = IIf(o->Bold, 700, 400)
			.lfItalic = IIf(o->Italic, 1, 0)
			.lfUnderline = IIf(o->Underline, 1, 0)
			.lfFaceName = o->FontName
		End With
		Return SizeOf(LOGFONT)
	Case 4
		If c < SizeOf(BITMAP) Then Return 0
		Cast(BITMAP Ptr, pv)->bmWidth = o->BitmapWidth
		Cast(BITMAP Ptr, pv)->bmHeight = o->BitmapHeight
		Cast(BITMAP Ptr, pv)->bmBitsPixel = 32
		Return SizeOf(BITMAP)
	End Select
	Return 0
End Function

'The stock objects: NULL_BRUSH, NULL_PEN and DC_BRUSH are kept by SelectObject as the state of the DC
Private Function GetStockObject(ByVal i As Long) As HGDIOBJ
	Return Cast(HGDIOBJ, CInt(&h7F000000 Or i))
End Function

Private Function Win32CompatFindDC(ByVal hdc As HDC) As Win32CompatDC Ptr
	If hdc = 0 Then Return 0
	For i As Integer = 0 To UBound(Win32CompatDCs)
		If Win32CompatDCs(i)->Handle = hdc Then Return Win32CompatDCs(i)
	Next
	Return 0
End Function

Private Function GetDC(ByVal hwnd As HWND) As HDC
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	Dim As Any Ptr ViewHandle = Win32CompatView(Ctrl)
	If ViewHandle = 0 Then Return 0
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(ViewHandle)
	If dc = 0 Then
		dc = New Win32CompatDC
		dc->Handle = ViewHandle
		ReDim Preserve Win32CompatDCs(UBound(Win32CompatDCs) + 1)
		Win32CompatDCs(UBound(Win32CompatDCs)) = dc
	End If
	dc->Wnd = Ctrl->Handle
	dc->Canvas = @Ctrl->Canvas
	Return ViewHandle
End Function

Private Function GetDCEx(ByVal hwnd As HWND, ByVal hrgnClip As HRGN, ByVal flags As DWORD) As HDC
	Return GetDC(hwnd)
End Function

Private Function ReleaseDC(ByVal hwnd As HWND, ByVal hdc As HDC) As Long
	Return 1
End Function

'A memory DC records the drawing into the bitmap selected into it (BitBlt, StretchBlt and the pattern brushes draw it)
Private Function CreateCompatibleDC(ByVal hdc As HDC) As HDC
	Dim As Win32CompatDC Ptr dc = New Win32CompatDC
	dc->Handle = dc
	dc->IsMemory = True
	Dim As Win32CompatDC Ptr dcFrom = Win32CompatFindDC(hdc)
	If dcFrom Then dc->Canvas = dcFrom->Canvas
	ReDim Preserve Win32CompatDCs(UBound(Win32CompatDCs) + 1)
	Win32CompatDCs(UBound(Win32CompatDCs)) = dc
	Return dc
End Function

Private Function DeleteDC(ByVal hdc As HDC) As BOOL
	For i As Integer = 0 To UBound(Win32CompatDCs)
		If Win32CompatDCs(i)->Handle = hdc AndAlso Win32CompatDCs(i)->IsMemory Then
			Delete Win32CompatDCs(i)
			For j As Integer = i To UBound(Win32CompatDCs) - 1
				Win32CompatDCs(j) = Win32CompatDCs(j + 1)
			Next
			If UBound(Win32CompatDCs) = 0 Then Erase Win32CompatDCs Else ReDim Preserve Win32CompatDCs(UBound(Win32CompatDCs) - 1)
			Return 1
		End If
	Next
	Return 0
End Function

'Returns the object selected before (for a stock object the stock object, the Pen / Brush of the canvas is 0)
Private Function SelectObject(ByVal hdc As HDC, ByVal h As HGDIOBJ) As HGDIOBJ
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse h = 0 Then Return 0
	If (CUInt(h) And &hFF000000) = &h7F000000 Then
		Select Case CInt(h) And &hFF
		Case NULL_BRUSH, WHITE_BRUSH, BLACK_BRUSH, DC_BRUSH
			Function = IIf(dc->NullBrush, GetStockObject(NULL_BRUSH), IIf(dc->DCBrush, GetStockObject(DC_BRUSH), Cast(Any Ptr, dc->Brush)))
			dc->Brush = 0
			dc->NullBrush = (CInt(h) And &hFF) = NULL_BRUSH
			dc->DCBrush = (CInt(h) And &hFF) = DC_BRUSH
			If (CInt(h) And &hFF) = WHITE_BRUSH Then dc->DCBrush = True: dc->DCBrushColor = &hFFFFFF
			If (CInt(h) And &hFF) = BLACK_BRUSH Then dc->DCBrush = True: dc->DCBrushColor = 0
		Case NULL_PEN, WHITE_PEN, BLACK_PEN, DC_PEN
			Function = IIf(dc->NullPen, GetStockObject(NULL_PEN), Cast(Any Ptr, dc->Pen))
			dc->Pen = 0
			dc->NullPen = (CInt(h) And &hFF) = NULL_PEN
		End Select
		Exit Function
	End If
	Dim As Win32CompatObject Ptr o = Win32CompatObject(h)
	If o = 0 Then Return 0
	Select Case o->Kind
	Case 1
		Function = IIf(dc->NullPen, GetStockObject(NULL_PEN), Cast(Any Ptr, dc->Pen))
		dc->Pen = o: dc->NullPen = o->Style = PS_NULL
	Case 2
		Function = IIf(dc->NullBrush, GetStockObject(NULL_BRUSH), IIf(dc->DCBrush, GetStockObject(DC_BRUSH), Cast(Any Ptr, dc->Brush)))
		dc->Brush = o: dc->NullBrush = False: dc->DCBrush = False
	Case 3
		Function = dc->Font
		dc->Font = o
	Case 4
		Function = dc->Bitmap
		dc->Bitmap = o
	End Select
End Function

Private Function SetDCBrushColor(ByVal hdc As HDC, ByVal crColor As COLORREF) As COLORREF
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	Function = dc->DCBrushColor
	dc->DCBrushColor = crColor
End Function

Private Function SetRect(ByVal lprc As Rect Ptr, ByVal xLeft As Long, ByVal yTop As Long, ByVal xRight As Long, ByVal yBottom As Long) As BOOL
	If lprc = 0 Then Return 0
	lprc->Left = xLeft: lprc->Top = yTop: lprc->Right = xRight: lprc->Bottom = yBottom
	Return 1
End Function

Private Function SetTextColor(ByVal hdc As HDC, ByVal crColor As COLORREF) As COLORREF
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	Function = dc->TextColor
	dc->TextColor = crColor
End Function

Private Function SetBkColor(ByVal hdc As HDC, ByVal crColor As COLORREF) As COLORREF
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	Function = dc->BkColor
	dc->BkColor = crColor
End Function

Private Function SetBkMode(ByVal hdc As HDC, ByVal Mode As Long) As Long
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	Function = dc->BkMode
	dc->BkMode = Mode
End Function

Private Function SetROP2(ByVal hdc As HDC, ByVal rop2 As Long) As Long
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	Function = dc->Rop2
	dc->Rop2 = rop2
End Function

Private Function SetBrushOrgEx(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long, ByVal lppt As Point Ptr) As BOOL
	Return 1
End Function

Private Function SetStretchBltMode(ByVal hdc As HDC, ByVal mode As Long) As Long
	Return 0
End Function

Private Function SaveDC(ByVal hdc As HDC) As Long
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory Then Return 0
	CanvasSave(hdc)
	dc->SaveCount += 1
	Return dc->SaveCount
End Function

Private Function RestoreDC(ByVal hdc As HDC, ByVal nSavedDC As Long) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory Then Return 0
	While dc->SaveCount > 0 AndAlso (nSavedDC < 0 OrElse dc->SaveCount >= nSavedDC)
		CanvasRestore(hdc)
		dc->SaveCount -= 1
		If nSavedDC < 0 Then Exit While
	Wend
	Return 1
End Function

Private Function IntersectClipRect(ByVal hdc As HDC, ByVal xLeft As Long, ByVal yTop As Long, ByVal xRight As Long, ByVal yBottom As Long) As Long
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory Then Return 0
	CanvasNewPath(hdc)
	CanvasRectPath(hdc, xLeft, yTop, xRight - xLeft, yBottom - yTop)
	CanvasClip(hdc)
	Return 2
End Function

'The brush of a system color: COLOR_* + 1 like on Windows (the brushes of the GDI functions know it)
Private Function GetSysColorBrush(ByVal nIndex As Long) As HBRUSH
	Return Cast(HBRUSH, CInt(nIndex + 1))
End Function

Private Function GetSysColor(ByVal nIndex As Long) As COLORREF
	Select Case nIndex
	Case COLOR_WINDOW, COLOR_HIGHLIGHTTEXT, COLOR_BTNHIGHLIGHT: Return &hFFFFFF
	Case COLOR_WINDOWTEXT, COLOR_BTNTEXT: Return 0
	Case COLOR_HIGHLIGHT: Return &hD77800
	Case COLOR_BTNFACE: Return &hF0F0F0
	Case COLOR_BTNSHADOW: Return &hA0A0A0
	Case COLOR_GRAYTEXT: Return &h6D6D6D
	End Select
	Return &hF0F0F0
End Function

'The color of a brush: a GDI object, a system color (COLOR_* + 1) or the Brush of a Canvas (Brush.Handle)
Private Function Win32CompatBrushColor(ByVal hbr As HBRUSH) As Integer
	If hbr = 0 Then Return 0
	Dim As Win32CompatObject Ptr o = Win32CompatObject(hbr)
	If o Then Return o->Color
	If CUInt(hbr) <= 31 Then Return GetSysColor(CInt(hbr) - 1)
	If (CUInt(hbr) And &hFF000000) = &h7F000000 Then Return IIf((CInt(hbr) And &hFF) = BLACK_BRUSH, 0, &hFFFFFF)
	Return Cast(My.Sys.Drawing.Brush Ptr, hbr)->Color
End Function

'A memory DC records the operation into its bitmap
Private Sub Win32CompatRecord(ByVal dc As Win32CompatDC Ptr, ByVal Kind As Integer, ByVal X1 As Long, ByVal Y1 As Long, ByVal X2 As Long, ByVal Y2 As Long, ByVal Color1 As Integer, ByVal Color2 As Integer = -1)
	If dc->Bitmap = 0 Then Exit Sub
	With *dc->Bitmap
		ReDim Preserve .Ops(UBound(.Ops) + 1)
		.Ops(UBound(.Ops)).Kind = Kind
		.Ops(UBound(.Ops)).X1 = X1: .Ops(UBound(.Ops)).Y1 = Y1
		.Ops(UBound(.Ops)).X2 = X2: .Ops(UBound(.Ops)).Y2 = Y2
		.Ops(UBound(.Ops)).Color1 = Color1: .Ops(UBound(.Ops)).Color2 = Color2
	End With
End Sub

'The path of a line of LineTo like GDI: a vertical or horizontal line has the whole pixels from the start to the end,
'the end pixel left out (the line of a row of the editor goes on in the next row without a gap, the minus of the box of
'a fold is in its middle), the middle of the pixels (+ 0.5) is only across the line
Private Sub Win32CompatLinePath(ByVal hdc As HDC, ByVal X1 As Double, ByVal Y1 As Double, ByVal X2 As Double, ByVal Y2 As Double)
	If X1 = X2 Then
		CanvasMoveTo(hdc, X1 + 0.5, Y1)
		CanvasLineTo(hdc, X2 + 0.5, Y2)
	ElseIf Y1 = Y2 Then
		CanvasMoveTo(hdc, X1, Y1 + 0.5)
		CanvasLineTo(hdc, X2, Y2 + 0.5)
	Else
		CanvasMoveTo(hdc, X1 + 0.5, Y1 + 0.5)
		CanvasLineTo(hdc, X2 + 0.5, Y2 + 0.5)
	End If
End Sub

'Draws the recorded operations of a bitmap at x, y (scaled sx, sy), only the part in the clip rectangle
Private Sub Win32CompatPlay(ByVal hdc As HDC, ByVal b As Win32CompatObject Ptr, ByVal x As Double, ByVal y As Double, ByVal sx As Double = 1, ByVal sy As Double = 1)
	If b = 0 Then Exit Sub
	For i As Integer = 0 To UBound(b->Ops)
		With b->Ops(i)
			Select Case .Kind
			Case 1, 2: CanvasFillRect(hdc, x + .X1 * sx, y + .Y1 * sy, (.X2 - .X1) * sx, (.Y2 - .Y1) * sy, .Color1, 255)
			Case 3
				If .Color2 >= 0 Then CanvasFillRect(hdc, x + .X1 * sx, y + .Y1 * sy, (.X2 - .X1) * sx, (.Y2 - .Y1) * sy, .Color2, 255)
				If .Color1 >= 0 Then
					CanvasNewPath(hdc)
					CanvasRectPath(hdc, x + .X1 * sx + 0.5, y + .Y1 * sy + 0.5, (.X2 - .X1) * sx - 1, (.Y2 - .Y1) * sy - 1)
					CanvasStroke(hdc, .Color1, 255, 1, "")
					CanvasNewPath(hdc)
				End If
			Case 4
				CanvasNewPath(hdc)
				Win32CompatLinePath(hdc, x + .X1 * sx, y + .Y1 * sy, x + .X2 * sx, y + .Y2 * sy)
				CanvasStroke(hdc, .Color1, 255, 1, "")
				CanvasNewPath(hdc)
			End Select
		End With
	Next
End Sub

Private Function FillRect(ByVal hdc As HDC, ByVal lprc As Const Rect Ptr, ByVal hbr As HBRUSH) As Long
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse lprc = 0 Then Return 0
	Dim As Win32CompatObject Ptr o = Win32CompatObject(hbr)
	If dc->IsMemory Then
		Win32CompatRecord dc, 1, lprc->Left, lprc->Top, lprc->Right, lprc->Bottom, Win32CompatBrushColor(hbr)
	ElseIf o <> 0 AndAlso o->Pattern <> 0 Then
		'The pattern repeats from the point 0, 0 of the window
		Dim As Win32CompatObject Ptr p = o->Pattern
		Dim As Long w = Max(1, p->BitmapWidth), h = Max(1, p->BitmapHeight)
		CanvasSave(hdc)
		CanvasNewPath(hdc)
		CanvasRectPath(hdc, lprc->Left, lprc->Top, lprc->Right - lprc->Left, lprc->Bottom - lprc->Top)
		CanvasClip(hdc)
		For y As Long = (lprc->Top \ h) * h To lprc->Bottom Step h
			For x As Long = (lprc->Left \ w) * w To lprc->Right Step w
				Win32CompatPlay hdc, p, x, y
			Next
		Next
		CanvasRestore(hdc)
	Else
		CanvasFillRect(hdc, lprc->Left, lprc->Top, lprc->Right - lprc->Left, lprc->Bottom - lprc->Top, Win32CompatBrushColor(hbr), 255)
	End If
	Return 1
End Function

Private Function FrameRect(ByVal hdc As HDC, ByVal lprc As Const Rect Ptr, ByVal hbr As HBRUSH) As Long
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse lprc = 0 Then Return 0
	If dc->IsMemory Then
		Win32CompatRecord dc, 3, lprc->Left, lprc->Top, lprc->Right, lprc->Bottom, Win32CompatBrushColor(hbr), -1
		Return 1
	End If
	CanvasNewPath(hdc)
	CanvasRectPath(hdc, lprc->Left + 0.5, lprc->Top + 0.5, lprc->Right - lprc->Left - 1, lprc->Bottom - lprc->Top - 1)
	CanvasStroke(hdc, Win32CompatBrushColor(hbr), 255, 1, "")
	CanvasNewPath(hdc)
	Return 1
End Function

'The whole client area is painted (the canvas is cleared before WM_PAINT)
Private Function BeginPaint(ByVal hwnd As HWND, ByVal lpPaint As PAINTSTRUCT Ptr) As HDC
	Dim As HDC hdc = GetDC(hwnd)
	If lpPaint Then
		lpPaint->hdc = hdc
		lpPaint->fErase = 0
		GetClientRect(hwnd, @lpPaint->rcPaint)
	End If
	Return hdc
End Function

Private Function EndPaint(ByVal hwnd As HWND, ByVal lpPaint As Const PAINTSTRUCT Ptr) As BOOL
	Return 1
End Function

'''' Overlays (the drawing which Windows inverts) and the caret

Private Sub Win32CompatDrawOverlay(ByVal hdc As HDC, ByRef R As Rect, ByVal Focus As Boolean)
	CanvasNewPath(hdc)
	CanvasRectPath(hdc, R.Left + 0.5, R.Top + 0.5, R.Right - R.Left - 1, R.Bottom - R.Top - 1)
	CanvasStroke(hdc, 0, 255, 1, IIf(Focus, "1,1", ""))
	CanvasNewPath(hdc)
End Sub

'Outside WM_PAINT the inverted drawing is toggled like on Windows: drawn once it is shown, drawn twice it is hidden
Private Sub Win32CompatToggleOverlay(ByVal dc As Win32CompatDC Ptr, ByRef R As Rect, ByVal Focus As Boolean)
	Dim As HWND hwnd = dc->Wnd
	For i As Integer = 0 To UBound(Win32CompatOverlays)
		With Win32CompatOverlays(i)
			If .Wnd = hwnd AndAlso .R.Left = R.Left AndAlso .R.Top = R.Top AndAlso .R.Right = R.Right AndAlso .R.Bottom = R.Bottom Then
				For j As Integer = i To UBound(Win32CompatOverlays) - 1
					Win32CompatOverlays(j) = Win32CompatOverlays(j + 1)
				Next
				If UBound(Win32CompatOverlays) = 0 Then Erase Win32CompatOverlays Else ReDim Preserve Win32CompatOverlays(UBound(Win32CompatOverlays) - 1)
				InvalidateRect(hwnd, 0, True)
				Exit Sub
			End If
		End With
	Next
	ReDim Preserve Win32CompatOverlays(UBound(Win32CompatOverlays) + 1)
	With Win32CompatOverlays(UBound(Win32CompatOverlays))
		.Wnd = hwnd
		.R = R
		.Focus = Focus
	End With
	InvalidateRect(hwnd, 0, True)
End Sub

Private Function DrawFocusRect(ByVal hdc As HDC, ByVal lprc As Const Rect Ptr) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If CBool(dc = 0) OrElse CBool(lprc = 0) OrElse dc->IsMemory Then Return 0
	If Win32CompatPaintingWnd <> 0 AndAlso Win32CompatPaintingWnd = dc->Wnd Then
		Win32CompatDrawOverlay hdc, *Cast(Rect Ptr, lprc), True
	Else
		Win32CompatToggleOverlay dc, *Cast(Rect Ptr, lprc), True
	End If
	Return 1
End Function

Private Sub Win32CompatPaintOverlays(ByVal Ctrl As My.Sys.Forms.Control Ptr)
	Dim As HDC hdc = Win32CompatView(Ctrl)
	For i As Integer = 0 To UBound(Win32CompatOverlays)
		If Win32CompatOverlays(i).Wnd = Ctrl->Handle Then Win32CompatDrawOverlay hdc, Win32CompatOverlays(i).R, Win32CompatOverlays(i).Focus
	Next
End Sub

Private Sub Win32CompatCaretTimer_Timer(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Forms.TimerComponent)
	Win32CompatCaretOn = Not Win32CompatCaretOn
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(Win32CompatCaretWnd)
	If Ctrl <> 0 AndAlso Win32CompatCaretShowCount > 0 Then Ctrl->Repaint
End Sub

Private Sub Win32CompatPaintCaret(ByVal Ctrl As My.Sys.Forms.Control Ptr)
	If Ctrl = 0 Then Exit Sub
	If Win32CompatCaretShowCount <= 0 OrElse (Not Win32CompatCaretOn) Then Exit Sub
	If Ctrl->Handle <> Win32CompatCaretWnd OrElse Ctrl->Handle <> Win32CompatFocusWnd Then Exit Sub
	'The caret of Windows inverts the pixels: it is seen on a dark background too
	CanvasInvertRect(Win32CompatView(Ctrl), Win32CompatCaretX, Win32CompatCaretY, IIf(Win32CompatCaretW > 0, Win32CompatCaretW, Ctrl->ScaleX(2)), Win32CompatCaretH)
End Sub

Private Sub Win32CompatRestartCaretBlink()
	Win32CompatCaretOn = True
	Win32CompatCaretTimer.Enabled = False
	Win32CompatCaretTimer.Interval = 530
	Win32CompatCaretTimer.OnTimer = @Win32CompatCaretTimer_Timer
	Win32CompatCaretTimer.Enabled = True
End Sub

Private Function CreateCaret(ByVal hwnd As HWND, ByVal hBitmap As HBITMAP, ByVal nWidth As Long, ByVal nHeight As Long) As BOOL
	Win32CompatCaretWnd = hwnd
	Win32CompatCaretW = nWidth
	Win32CompatCaretH = nHeight
	Win32CompatCaretShowCount = 0
	Return 1
End Function

Private Function DestroyCaret() As BOOL
	Win32CompatCaretWnd = 0
	Win32CompatCaretShowCount = 0
	Win32CompatCaretTimer.Enabled = False
	Return 1
End Function

Private Function ShowCaret(ByVal hwnd As HWND) As BOOL
	If hwnd <> Win32CompatCaretWnd Then Return 0
	Win32CompatCaretShowCount += 1
	'The caret shown again after the drawing of the window (HideCaret ... ShowCaret of WM_PAINT) keeps its blinking: a
	'new start would show it at each drawing, also at the one of the blinking
	If Win32CompatCaretShowCount = 1 AndAlso Win32CompatPaintingWnd <> hwnd Then Win32CompatRestartCaretBlink
	Return 1
End Function

Private Function HideCaret(ByVal hwnd As HWND) As BOOL
	If hwnd <> Win32CompatCaretWnd Then Return 0
	Win32CompatCaretShowCount -= 1
	Return 1
End Function

Private Function SetCaretPos(ByVal X As Long, ByVal Y As Long) As BOOL
	If X <> Win32CompatCaretX OrElse Y <> Win32CompatCaretY Then
		Win32CompatCaretX = X
		Win32CompatCaretY = Y
		Win32CompatCaretOn = True
	End If
	Return 1
End Function

Private Function GetCaretBlinkTime() As UINT
	Return 530
End Function

'''' Drawing

Private Function SetPixel(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long, ByVal crColor As COLORREF) As COLORREF
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return crColor
	If dc->IsMemory Then
		Win32CompatRecord dc, 2, x, y, x + 1, y + 1, crColor
	Else
		CanvasFillRect(hdc, x, y, 1, 1, crColor, 255)
	End If
	Return crColor
End Function

Private Function MoveToEx(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long, ByVal lppt As Point Ptr) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	If lppt Then lppt->X = dc->PenX: lppt->Y = dc->PenY
	dc->PenX = x
	dc->PenY = y
	Return 1
End Function

'The pen of the DC: the selected pen, otherwise the Pen of the canvas; -1 - no pen (NULL_PEN, PS_NULL)
Private Function Win32CompatPenColor(ByVal dc As Win32CompatDC Ptr, ByRef PenWidth As Integer, ByRef Dash As String) As Integer
	PenWidth = 1: Dash = ""
	If dc->NullPen Then Return -1
	If dc->Pen Then
		PenWidth = dc->Pen->Width
		Dash = IIf(dc->Pen->Style = PS_DOT, "1,1", IIf(dc->Pen->Style = PS_DASH, "4,2", ""))
		Return dc->Pen->Color
	End If
	If dc->Canvas Then
		PenWidth = IIf(dc->Canvas->Pen.Size > 0, dc->Canvas->Pen.Size, 1)
		Dash = IIf(dc->Canvas->Pen.Style = PS_DOT, "1,1", IIf(dc->Canvas->Pen.Style = PS_DASH, "4,2", ""))
		Return dc->Canvas->Pen.Color
	End If
	Return 0
End Function

'The brush of the DC: the selected brush, the DC brush, otherwise the Brush of the canvas; -1 - no brush (NULL_BRUSH)
Private Function Win32CompatFillColor(ByVal dc As Win32CompatDC Ptr) As Integer
	If dc->NullBrush Then Return -1
	If dc->DCBrush Then Return dc->DCBrushColor
	If dc->Brush Then Return dc->Brush->Color
	If dc->Canvas Then Return dc->Canvas->Brush.Color
	Return &hFFFFFF
End Function

Private Sub Win32CompatStroke(ByVal dc As Win32CompatDC Ptr)
	Dim As Integer PenWidth
	Dim As String Dash
	Dim As Integer PenColor = Win32CompatPenColor(dc, PenWidth, Dash)
	If PenColor >= 0 Then CanvasStroke(dc->Handle, PenColor, 255, PenWidth, Dash)
	CanvasNewPath(dc->Handle)
End Sub

Private Sub Win32CompatFill(ByVal dc As Win32CompatDC Ptr)
	Dim As Integer FillColor = Win32CompatFillColor(dc)
	If FillColor >= 0 Then CanvasFill(dc->Handle, FillColor, 255)
End Sub

'The lines of GDI cover the pixels: the path goes through their middles
Private Function LineTo(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	If dc->IsMemory Then
		Dim As Integer PenWidth
		Dim As String Dash
		Win32CompatRecord dc, 4, dc->PenX, dc->PenY, x, y, Win32CompatPenColor(dc, PenWidth, Dash)
	Else
		CanvasNewPath(hdc)
		Win32CompatLinePath(hdc, dc->PenX, dc->PenY, x, y)
		Win32CompatStroke dc
	End If
	dc->PenX = x
	dc->PenY = y
	Return 1
End Function

'R2_NOT outside WM_PAINT (the moving frame of the designer) is an overlay
Private Function Rectangle(ByVal hdc As HDC, ByVal xLeft As Long, ByVal yTop As Long, ByVal xRight As Long, ByVal yBottom As Long) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 Then Return 0
	If dc->IsMemory Then
		Dim As Integer PenWidth
		Dim As String Dash
		Win32CompatRecord dc, 3, xLeft, yTop, xRight, yBottom, Win32CompatPenColor(dc, PenWidth, Dash), Win32CompatFillColor(dc)
		Return 1
	End If
	If dc->Rop2 = R2_NOT AndAlso (Win32CompatPaintingWnd = 0 OrElse Win32CompatPaintingWnd <> dc->Wnd) Then
		Win32CompatToggleOverlay dc, Type<Rect>(xLeft, yTop, xRight, yBottom), False
		Return 1
	End If
	CanvasNewPath(hdc)
	CanvasRectPath(hdc, xLeft + 0.5, yTop + 0.5, xRight - xLeft - 1, yBottom - yTop - 1)
	Win32CompatFill dc
	Win32CompatStroke dc
	Return 1
End Function

Private Function RoundRect(ByVal hdc As HDC, ByVal xLeft As Long, ByVal yTop As Long, ByVal xRight As Long, ByVal yBottom As Long, ByVal w As Long, ByVal h As Long) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory Then Return 0
	Dim As Double l = xLeft + 0.5, t = yTop + 0.5, r = xRight - 0.5, b = yBottom - 0.5
	Dim As Double rr = Min(Min(w, h) / 2, Min(r - l, b - t) / 2)
	Const PI = 3.14159265358979
	CanvasNewPath(hdc)
	CanvasMoveTo(hdc, l + rr, t)
	CanvasLineTo(hdc, r - rr, t)
	CanvasArc(hdc, r - rr, t + rr, rr, -PI / 2, 0, 0)
	CanvasLineTo(hdc, r, b - rr)
	CanvasArc(hdc, r - rr, b - rr, rr, 0, PI / 2, 0)
	CanvasLineTo(hdc, l + rr, b)
	CanvasArc(hdc, l + rr, b - rr, rr, PI / 2, PI, 0)
	CanvasLineTo(hdc, l, t + rr)
	CanvasArc(hdc, l + rr, t + rr, rr, PI, PI * 3 / 2, 0)
	CanvasClosePath(hdc)
	Win32CompatFill dc
	Win32CompatStroke dc
	Return 1
End Function

'An ellipse of four Bezier curves (k - the distance of the control points)
Private Function Ellipse(ByVal hdc As HDC, ByVal xLeft As Long, ByVal yTop As Long, ByVal xRight As Long, ByVal yBottom As Long) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory Then Return 0
	Dim As Double cx = (xLeft + xRight) / 2, cy = (yTop + yBottom) / 2, rx = (xRight - xLeft) / 2, ry = (yBottom - yTop) / 2
	Const k = 0.5522847498
	CanvasNewPath(hdc)
	CanvasMoveTo(hdc, cx + rx, cy)
	CanvasCurveTo(hdc, cx + rx, cy + ry * k, cx + rx * k, cy + ry, cx, cy + ry)
	CanvasCurveTo(hdc, cx - rx * k, cy + ry, cx - rx, cy + ry * k, cx - rx, cy)
	CanvasCurveTo(hdc, cx - rx, cy - ry * k, cx - rx * k, cy - ry, cx, cy - ry)
	CanvasCurveTo(hdc, cx + rx * k, cy - ry, cx + rx, cy - ry * k, cx + rx, cy)
	CanvasClosePath(hdc)
	Win32CompatFill dc
	Win32CompatStroke dc
	Return 1
End Function

Private Function Polygon(ByVal hdc As HDC, ByVal apt As Const Point Ptr, ByVal cpt As Long) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory OrElse apt = 0 OrElse cpt < 2 Then Return 0
	CanvasNewPath(hdc)
	CanvasMoveTo(hdc, apt[0].X + 0.5, apt[0].Y + 0.5)
	For i As Integer = 1 To cpt - 1
		CanvasLineTo(hdc, apt[i].X + 0.5, apt[i].Y + 0.5)
	Next
	CanvasClosePath(hdc)
	Win32CompatFill dc
	Win32CompatStroke dc
	Return 1
End Function

'Inverting the pixels is not possible on the canvas: a dark half transparent rectangle marks the place
Private Function InvertRect(ByVal hdc As HDC, ByVal lprc As Const Rect Ptr) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory OrElse lprc = 0 Then Return 0
	CanvasFillRect(hdc, lprc->Left, lprc->Top, lprc->Right - lprc->Left, lprc->Bottom - lprc->Top, 0, 128)
	Return 1
End Function

Private Function ExtFloodFill(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long, ByVal crColor As COLORREF, ByVal nType As UINT) As BOOL
	Return 0
End Function

'The memory DC (the recorded drawing of its bitmap) is drawn on the canvas
Private Function StretchBlt(ByVal hdcDest As HDC, ByVal xDest As Long, ByVal yDest As Long, ByVal wDest As Long, ByVal hDest As Long, ByVal hdcSrc As HDC, ByVal xSrc As Long, ByVal ySrc As Long, ByVal wSrc As Long, ByVal hSrc As Long, ByVal rop As DWORD) As BOOL
	Dim As Win32CompatDC Ptr dcDest = Win32CompatFindDC(hdcDest), dcSrc = Win32CompatFindDC(hdcSrc)
	If dcDest = 0 OrElse dcSrc = 0 Then Return 0
	If dcDest->IsMemory OrElse dcSrc->Bitmap = 0 Then Return 0
	Dim As Double sx = IIf(wSrc = 0, 1, wDest / wSrc), sy = IIf(hSrc = 0, 1, hDest / hSrc)
	CanvasSave(hdcDest)
	CanvasNewPath(hdcDest)
	CanvasRectPath(hdcDest, xDest, yDest, wDest, hDest)
	CanvasClip(hdcDest)
	Win32CompatPlay hdcDest, dcSrc->Bitmap, xDest - xSrc * sx, yDest - ySrc * sy, sx, sy
	CanvasRestore(hdcDest)
	Return 1
End Function

Private Function BitBlt(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long, ByVal cx As Long, ByVal cy As Long, ByVal hdcSrc As HDC, ByVal x1 As Long, ByVal y1 As Long, ByVal rop As DWORD) As BOOL
	Return StretchBlt(hdc, x, y, cx, cy, hdcSrc, x1, y1, cx, cy, rop)
End Function

Private Function AlphaBlend(ByVal hdcDest As HDC, ByVal xoriginDest As Long, ByVal yoriginDest As Long, ByVal wDest As Long, ByVal hDest As Long, ByVal hdcSrc As HDC, ByVal xoriginSrc As Long, ByVal yoriginSrc As Long, ByVal wSrc As Long, ByVal hSrc As Long, ByVal ftn As BLENDFUNCTION) As BOOL
	Return StretchBlt(hdcDest, xoriginDest, yoriginDest, wDest, hDest, hdcSrc, xoriginSrc, yoriginSrc, wSrc, hSrc, SRCCOPY)
End Function

'The pictures of the image lists and icons are not drawn on the Web / Android yet
Private Function DrawIconEx(ByVal hdc As HDC, ByVal xLeft As Long, ByVal yTop As Long, ByVal hIcon As HICON, ByVal cxWidth As Long, ByVal cyWidth As Long, ByVal istepIfAniCur As UINT, ByVal hbrFlickerFreeDraw As HBRUSH, ByVal diFlags As UINT) As BOOL
	Return 0
End Function

Private Function ImageList_Draw(ByVal himl As HIMAGELIST, ByVal i As Long, ByVal hdcDst As HDC, ByVal x As Long, ByVal y As Long, ByVal fStyle As UINT) As BOOL
	Return 0
End Function

'''' Text

'The font of the DC: the selected font, otherwise the Font of the canvas (size in the pixels of the canvas)
Private Sub Win32CompatFont(ByVal dc As Win32CompatDC Ptr, ByRef FontName As String, ByRef FontSize As Double, ByRef Bold As Boolean, ByRef Italic As Boolean, ByRef Underline As Boolean, ByRef StrikeOut As Boolean)
	If dc->Font Then
		FontName = ToUtf8(dc->Font->FontName)
		FontSize = IIf(dc->Font->FontSize > 0, dc->Font->FontSize, 12)
		Bold = dc->Font->Bold: Italic = dc->Font->Italic: Underline = dc->Font->Underline: StrikeOut = False
	ElseIf dc->Canvas Then
		FontName = ToUtf8(dc->Canvas->Font.Name)
		FontSize = dc->Canvas->ScaleY(IIf(dc->Canvas->Font.Size > 0, dc->Canvas->Font.Size, 9) * 96 / 72)
		Bold = dc->Canvas->Font.Bold: Italic = dc->Canvas->Font.Italic: Underline = dc->Canvas->Font.Underline: StrikeOut = dc->Canvas->Font.StrikeOut
	Else
		FontName = "": FontSize = 12
	End If
End Sub

Private Function GetTextExtentPoint32(ByVal hdc As HDC, ByVal lpString As Const WString Ptr, ByVal c As Long, ByVal psizl As Size Ptr) As BOOL
	If psizl = 0 Then Return 0
	psizl->cx = 0: psizl->cy = 0
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse lpString = 0 Then Return 0
	Dim As String FontName
	Dim As Double FontSize
	Dim As Boolean Bold, Italic, Underline, StrikeOut
	Win32CompatFont dc, FontName, FontSize, Bold, Italic, Underline, StrikeOut
	'A memory DC has no canvas of its own: the text is measured on the page
	Dim As HDC hMeasure = IIf(dc->IsMemory, 0, hdc)
	psizl->cx = CanvasTextWidth(hMeasure, ToUtf8(.Left(*lpString, c)), FontName, FontSize, Bold, Italic)
	psizl->cy = CanvasTextHeight(hMeasure, FontName, FontSize, Bold, Italic)
	Return 1
End Function

Private Function GetTextMetrics(ByVal hdc As HDC, ByVal lptm As TEXTMETRIC Ptr) As BOOL
	If lptm = 0 Then Return 0
	Dim As Size sz
	Dim As WString * 2 wChar = "x"
	GetTextExtentPoint32(hdc, @wChar, 1, @sz)
	lptm->tmHeight = sz.cy
	lptm->tmAscent = sz.cy * 0.8
	lptm->tmDescent = sz.cy - lptm->tmAscent
	lptm->tmAveCharWidth = sz.cx
	wChar = "W"
	GetTextExtentPoint32(hdc, @wChar, 1, @sz)
	lptm->tmMaxCharWidth = sz.cx
	lptm->tmWeight = 400
	Return 1
End Function

Private Function ExtTextOut(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long, ByVal options As UINT, ByVal lprect As Const Rect Ptr, ByVal lpString As Const WString Ptr, ByVal c As UINT, ByVal lpDx As Const Long Ptr) As BOOL
	Dim As Win32CompatDC Ptr dc = Win32CompatFindDC(hdc)
	If dc = 0 OrElse dc->IsMemory Then Return 0
	If lprect <> 0 AndAlso (options And ETO_OPAQUE) Then
		CanvasFillRect(hdc, lprect->Left, lprect->Top, lprect->Right - lprect->Left, lprect->Bottom - lprect->Top, dc->BkColor, 255)
	End If
	If lpString = 0 OrElse c = 0 Then Return 1
	Dim As Boolean bClip = lprect <> 0 AndAlso CBool(options And ETO_CLIPPED)
	If bClip Then
		CanvasSave(hdc)
		CanvasNewPath(hdc)
		CanvasRectPath(hdc, lprect->Left, lprect->Top, lprect->Right - lprect->Left, lprect->Bottom - lprect->Top)
		CanvasClip(hdc)
	End If
	Dim As String sText = ToUtf8(.Left(*lpString, c)), FontName
	Dim As Double FontSize
	Dim As Boolean Bold, Italic, Underline, StrikeOut
	Win32CompatFont dc, FontName, FontSize, Bold, Italic, Underline, StrikeOut
	#ifdef __USE_WASM__
		'A font with an escapement turns the text around its beginning (the band names of the report designer)
		Dim As Boolean bRotate = dc->Font <> 0 AndAlso dc->Font->Escapement <> 0
		If bRotate Then
			CanvasSave(hdc)
			CanvasRotate(hdc, x, y, dc->Font->Escapement / 10)
		End If
	#endif
	CanvasText(hdc, x, y, sText, dc->TextColor, IIf(dc->BkMode = OPAQUE, dc->BkColor, -1), FontName, FontSize, Bold, Italic)
	#ifdef __USE_WASM__
		If bRotate Then CanvasRestore(hdc)
	#endif
	If Underline OrElse StrikeOut Then
		Dim As Integer w = CanvasTextWidth(hdc, sText, FontName, FontSize, Bold, Italic)
		Dim As Integer h = CanvasTextHeight(hdc, FontName, FontSize, Bold, Italic)
		CanvasNewPath(hdc)
		If Underline Then CanvasMoveTo(hdc, x, y + h - 1.5): CanvasLineTo(hdc, x + w, y + h - 1.5)
		If StrikeOut Then CanvasMoveTo(hdc, x, y + h / 2 + 0.5): CanvasLineTo(hdc, x + w, y + h / 2 + 0.5)
		CanvasStroke(hdc, dc->TextColor, 255, 1, "")
		CanvasNewPath(hdc)
	End If
	If bClip Then CanvasRestore(hdc)
	Return 1
End Function

Private Function TextOut(ByVal hdc As HDC, ByVal x As Long, ByVal y As Long, ByVal lpString As Const WString Ptr, ByVal c As Long) As BOOL
	Return ExtTextOut(hdc, x, y, 0, 0, lpString, c, 0)
End Function

'One line in the rectangle: DT_CENTER / DT_RIGHT and DT_VCENTER / DT_BOTTOM place it, the text is clipped by the rectangle
Private Function DrawText(ByVal hdc As HDC, ByVal lpchText As Const WString Ptr, ByVal cchText As Long, ByVal lprc As Rect Ptr, ByVal uFormat As UINT) As Long
	If lpchText = 0 OrElse lprc = 0 Then Return 0
	Dim As Long n = IIf(cchText < 0, Len(*lpchText), cchText)
	Dim As Size sz
	GetTextExtentPoint32(hdc, lpchText, n, @sz)
	Dim As Long x = lprc->Left, y = lprc->Top
	If uFormat And DT_CENTER Then
		x = (lprc->Left + lprc->Right - sz.cx) \ 2
	ElseIf uFormat And DT_RIGHT Then
		x = lprc->Right - sz.cx
	End If
	If uFormat And DT_VCENTER Then
		y = (lprc->Top + lprc->Bottom - sz.cy) \ 2
	ElseIf uFormat And DT_BOTTOM Then
		y = lprc->Bottom - sz.cy
	End If
	ExtTextOut(hdc, x, y, ETO_CLIPPED, lprc, lpchText, n, 0)
	Return sz.cy
End Function

Private Function DrawTextW(ByVal hdc As HDC, ByVal lpchText As Const WString Ptr, ByVal cchText As Long, ByVal lprc As Rect Ptr, ByVal uFormat As UINT) As Long
	Return DrawText(hdc, lpchText, cchText, lprc, uFormat)
End Function

'''' Timers

'Timers of SetTimer: a TimerComponent for each window and ID; without a procedure WM_TIMER goes to the window
Private Sub Win32CompatTimer_Timer(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Forms.TimerComponent)
	Dim As Win32CompatTimer Ptr t = Cast(Win32CompatTimer Ptr, @Sender)
	If t->Proc Then
		t->Proc(t->Wnd, WM_TIMER, t->ID, CULng(Timer * 1000))
	ElseIf t->Wnd Then
		SendMessage(t->Wnd, WM_TIMER, t->ID, 0)
	End If
End Sub

Private Function SetTimer(ByVal hwnd As HWND, ByVal nIDEvent As UINT_PTR, ByVal uElapse As UINT, ByVal lpTimerFunc As TIMERPROC) As UINT_PTR
	Dim As Integer iFree = -1
	For i As Integer = 0 To UBound(Win32CompatTimers)
		If Win32CompatTimers(i) = 0 Then
			If iFree = -1 Then iFree = i
		ElseIf Win32CompatTimers(i)->Wnd = hwnd AndAlso Win32CompatTimers(i)->ID = nIDEvent Then
			iFree = i
			Exit For
		End If
	Next
	If iFree = -1 Then Return 0
	If Win32CompatTimers(iFree) = 0 Then
		Win32CompatTimers(iFree) = New Win32CompatTimer
		Win32CompatTimers(iFree)->OnTimer = @Win32CompatTimer_Timer
	End If
	With *Win32CompatTimers(iFree)
		.Enabled = False
		.Wnd = hwnd
		.ID = nIDEvent
		.Proc = lpTimerFunc
		.Interval = Max(1, uElapse)
		.Enabled = True
	End With
	Return nIDEvent
End Function

Private Function KillTimer(ByVal hwnd As HWND, ByVal uIDEvent As UINT_PTR) As BOOL
	For i As Integer = 0 To UBound(Win32CompatTimers)
		If Win32CompatTimers(i) <> 0 AndAlso Win32CompatTimers(i)->Wnd = hwnd AndAlso Win32CompatTimers(i)->ID = uIDEvent Then
			Win32CompatTimers(i)->Enabled = False
			Delete Win32CompatTimers(i)
			Win32CompatTimers(i) = 0
			Return 1
		End If
	Next
	Return 0
End Function

Private Function timeGetTime() As DWORD
	Return CULng(Timer * 1000)
End Function

Private Function GetTickCount() As DWORD
	Return CULng(Timer * 1000)
End Function

'''' The keyboard and the mouse

Private Function GetKeyState(ByVal nVirtKey As Long) As Short
	Dim As Boolean bDown
	Select Case nVirtKey
	Case VK_SHIFT: bDown = Win32CompatShift
	Case VK_CONTROL: bDown = Win32CompatCtrl
	Case VK_MENU: bDown = Win32CompatAlt
	Case VK_LBUTTON: bDown = Win32CompatLButton
	Case VK_RBUTTON: bDown = Win32CompatRButton
	Case VK_MBUTTON: bDown = Win32CompatMButton
	End Select
	'Windows gives &hFF80 for a key which is down (EditControl tests it with And 8000)
	Return IIf(bDown, CShort(&hFF80), 0)
End Function

Private Function GetAsyncKeyState(ByVal vKey As Long) As Short
	Return GetKeyState(vKey)
End Function

Private Function GetCursorPos(ByVal lpPoint As Point Ptr) As BOOL
	If lpPoint = 0 Then Return 0
	lpPoint->X = Win32CompatMouseX
	lpPoint->Y = Win32CompatMouseY
	If Win32CompatMouseWnd Then ClientToScreen(Win32CompatMouseWnd, lpPoint)
	Return 1
End Function

'The point of the last mouse message on the screen
Private Function GetMessagePos() As DWORD
	Dim As Point P
	GetCursorPos(@P)
	Return MAKELONG(P.X, P.Y)
End Function

Private Function MAKEPOINTS(ByVal l As DWORD) As POINTS
	Dim As POINTS pt
	pt.x = CShort(LoWord(l))
	pt.y = CShort(HiWord(l))
	Return pt
End Function

Private Function GetDoubleClickTime() As UINT
	Return 500
End Function

Private Function ClipCursor(ByVal lpRect As Const Rect Ptr) As BOOL
	Return 1
End Function

Private Function SetCapture(ByVal hwnd As HWND) As HWND
	Function = Win32CompatCaptureWnd
	Win32CompatCaptureWnd = hwnd
End Function

Private Function ReleaseCapture() As BOOL
	Win32CompatCaptureWnd = 0
	Return 1
End Function

Private Function GetCapture() As HWND
	Return Win32CompatCaptureWnd
End Function

Private Function GetFocus() As HWND
	Return Win32CompatFocusWnd
End Function

Private Function DragDetect(ByVal hwnd As HWND, ByVal pt As Point) As BOOL
	Return 0
End Function

Private Function TrackMouseEvent(ByVal lpEventTrack As TRACKMOUSEEVENT Ptr) As BOOL
	Return 1
End Function

Private Function MessageBeep(ByVal uType As UINT) As BOOL
	Return 1
End Function

Private Function LoadCursor(ByVal hInstance As HINSTANCE, ByVal lpCursorName As Any Ptr) As HCURSOR
	Return lpCursorName
End Function

Private Sub Win32CompatSetCursorName(ByRef CursorName As String)
	#ifdef __USE_WASM__
		If Win32CompatMouseWnd <> 0 Then SetStyle(Win32CompatMouseWnd, "cursor", CursorName)
	#endif
End Sub

'An IDC_* cursor or the CSS name of a cursor (the cr* names of MyFbFramework on the Web)
Private Function SetCursor OverLoad(ByVal hCursor As HCURSOR) As HCURSOR
	Dim As String sCursor
	Select Case hCursor
	Case IDC_IBEAM: sCursor = "text"
	Case IDC_HAND: sCursor = "pointer"
	Case IDC_SIZEWE: sCursor = "ew-resize"
	Case IDC_SIZENS: sCursor = "ns-resize"
	Case IDC_SIZENWSE: sCursor = "nwse-resize"
	Case IDC_SIZENESW: sCursor = "nesw-resize"
	Case IDC_SIZEALL: sCursor = "move"
	Case IDC_WAIT: sCursor = "wait"
	Case IDC_CROSS: sCursor = "crosshair"
	Case Else: sCursor = "default"
	End Select
	Win32CompatSetCursorName sCursor
	Return hCursor
End Function

Private Function SetCursor(ByRef CursorName As String) As HCURSOR
	Win32CompatSetCursorName CursorName
	Return 0
End Function

Private Function GetSystemMetrics(ByVal nIndex As Long) As Long
	Select Case nIndex
	Case SM_CXVSCROLL, SM_CYHSCROLL: Return 17
	#ifdef __USE_WASM__
		Case SM_CXSCREEN: Return GetDocumentWidth()
		Case SM_CYSCREEN: Return GetDocumentHeight()
	#endif
	End Select
	Return 0
End Function

Private Function SystemParametersInfo(ByVal uiAction As UINT, ByVal uiParam As UINT, ByVal pvParam As Any Ptr, ByVal fWinIni As UINT) As BOOL
	If uiAction = SPI_GETNONCLIENTMETRICS AndAlso pvParam <> 0 Then
		With *Cast(NONCLIENTMETRICS Ptr, pvParam)
			.iBorderWidth = 1
			.iScrollWidth = 17
			.iScrollHeight = 17
			.iCaptionHeight = 23
			.iMenuHeight = 20
		End With
		Return 1
	End If
	Return 0
End Function

'The input method editor of the browser / Android works without these
Private Function ImmGetContext(ByVal hwnd As HWND) As HIMC
	Return 0
End Function

Private Function ImmReleaseContext(ByVal hwnd As HWND, ByVal himc As HIMC) As BOOL
	Return 1
End Function

Private Function ImmSetCompositionWindow(ByVal himc As HIMC, ByVal lpCompForm As Any Ptr) As BOOL
	Return 1
End Function

Private Function ImmSetCandidateWindow(ByVal himc As HIMC, ByVal lpCandidate As Any Ptr) As BOOL
	Return 1
End Function

Private Function GetClassNameOf(ByVal hwnd As HWND) As String
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return ""
	Return Ctrl->ClassName
End Function

Private Function SetWindowTheme(ByVal hwnd As HWND, ByVal pszSubAppName As Const WString Ptr, ByVal pszSubIdList As Const WString Ptr) As HRESULT
	Return 0
End Function

'''' Child windows: the scroll bars and the windows of the registered classes

'A scroll bar of the control sends WM_HSCROLL / WM_VSCROLL to its parent with the new position (SB_THUMBPOSITION).
'The mouse is placed on the scroll bar: the parent finds the scroll bar with GetCursorPos like on Windows
Private Sub Win32CompatScrollBar_Scroll(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Forms.ScrollBarControl, ByRef NewPos As Integer)
	Dim As My.Sys.Forms.Control Ptr pParent = Sender.Parent
	If pParent = 0 Then Exit Sub
	Win32CompatMouseWnd = pParent->Handle
	Win32CompatMouseX = Sender.ScaleX(Sender.Left + Sender.Width / 2)
	Win32CompatMouseY = Sender.ScaleY(Sender.Top + Sender.Height / 2)
	SendMessage(pParent->Handle, IIf(Sender.Style = My.Sys.Forms.ScrollBarControlStyle.sbVertical, WM_VSCROLL, WM_HSCROLL), MAKELONG(SB_THUMBPOSITION, NewPos), Cast(LPARAM, Sender.Handle))
End Sub

Private Function CreateWindowEx(ByVal dwExStyle As DWORD, ByRef ClassName As WString, ByRef WindowName As WString, ByVal dwStyle As DWORD, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hWndParent As HWND, ByVal hMenu As HMENU, ByVal hInstance As HINSTANCE, ByVal lpParam As Any Ptr) As HWND
	Dim As My.Sys.Forms.Control Ptr pParent = Win32CompatControl(hWndParent)
	If pParent = 0 Then Return 0
	Dim As My.Sys.Forms.Control Ptr Ctrl
	Dim As WNDPROC ClassProc
	If LCase(ClassName) = "scrollbar" Then
		Dim As My.Sys.Forms.ScrollBarControl Ptr sb = New My.Sys.Forms.ScrollBarControl
		sb->Style = IIf(dwStyle And SBS_VERT, My.Sys.Forms.ScrollBarControlStyle.sbVertical, My.Sys.Forms.ScrollBarControlStyle.sbHorizontal)
		sb->OnScroll = @Win32CompatScrollBar_Scroll
		Ctrl = sb
	Else
		For i As Integer = 0 To UBound(Win32CompatClasses)
			If Win32CompatClasses(i).Name = LCase(ClassName) Then ClassProc = Win32CompatClasses(i).Proc
		Next
		If ClassProc = 0 Then Return 0
		Ctrl = New Win32CompatWindow
	End If
	Ctrl->SetBounds pParent->UnScaleX(X), pParent->UnScaleY(Y), pParent->UnScaleX(nWidth), pParent->UnScaleY(nHeight)
	Ctrl->Visible = CBool(dwStyle And WS_VISIBLE)
	pParent->Add Ctrl
	'The parent has its window (HandleIsAllocated): the child gets its own now
	If Ctrl->Handle = 0 Then Ctrl->CreateWnd
	If Ctrl->Handle = 0 Then Return 0
	For i As Integer = UBound(Win32CompatDestroyed) To 0 Step -1
		If Win32CompatDestroyed(i) = Ctrl->Handle Then Win32CompatDestroyed(i) = 0
	Next
	If ClassProc Then
		Dim As Win32CompatWnd Ptr w = Win32CompatFindWnd(Ctrl->Handle, True)
		w->ClassProc = ClassProc
		w->Style = dwStyle
		w->ExStyle = dwExStyle
		ControlMessageHook = @Win32CompatHook
		SendMessage(Ctrl->Handle, WM_CREATE, 0, 0)
	End If
	Return Ctrl->Handle
End Function

Private Function CreateWindowExW(ByVal dwExStyle As DWORD, ByVal ClassName As Const WString Ptr, ByVal WindowName As Const WString Ptr, ByVal dwStyle As DWORD, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hWndParent As HWND, ByVal hMenu As HMENU, ByVal hInstance As HINSTANCE, ByVal lpParam As Any Ptr) As HWND
	Dim As UString sClassName, sWindowName
	If ClassName Then sClassName = *ClassName
	If WindowName Then sWindowName = *WindowName
	Return CreateWindowEx(dwExStyle, sClassName, sWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)
End Function

'The scroll bar of a handle (0 for another window)
Private Function Win32CompatScrollBar(ByVal hwnd As HWND) As My.Sys.Forms.ScrollBarControl Ptr
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 OrElse Not (*Ctrl Is My.Sys.Forms.ScrollBarControl) Then Return 0
	Return Cast(My.Sys.Forms.ScrollBarControl Ptr, Ctrl)
End Function

'Only the windows of CreateWindowEx are destroyed (the controls of MyFbFramework are deleted by their owners)
Private Function DestroyWindow(ByVal hwnd As HWND) As BOOL
	Dim As My.Sys.Forms.Control Ptr Ctrl = Win32CompatControl(hwnd)
	If Ctrl = 0 Then Return 0
	If Not (*Ctrl Is My.Sys.Forms.ScrollBarControl) AndAlso Not (*Ctrl Is Win32CompatWindow) Then Return 0
	If Win32CompatWndProc(hwnd) Then SendMessage(hwnd, WM_DESTROY, 0, 0)
	Win32CompatRemoveWnd hwnd
	Win32CompatSetTop hwnd, False
	For i As Integer = UBound(Win32CompatOverlays) To 0 Step -1
		If Win32CompatOverlays(i).Wnd = hwnd Then Win32CompatOverlays(i).Wnd = 0
	Next
	If Ctrl->Parent Then Cast(My.Sys.Forms.Control Ptr, Ctrl->Parent)->Remove Ctrl
	ReDim Preserve Win32CompatDestroyed(UBound(Win32CompatDestroyed) + 1)
	Win32CompatDestroyed(UBound(Win32CompatDestroyed)) = hwnd
	If *Ctrl Is My.Sys.Forms.ScrollBarControl Then Delete Cast(My.Sys.Forms.ScrollBarControl Ptr, Ctrl) Else Delete Cast(Win32CompatWindow Ptr, Ctrl)
	Return 1
End Function

Private Function Win32CompatScrollInfoOf(ByVal sb As My.Sys.Forms.ScrollBarControl Ptr) As Win32CompatScrollInfo Ptr
	For i As Integer = 0 To UBound(Win32CompatScrollInfos)
		If Win32CompatScrollInfos(i).Wnd = sb->Handle Then Return @Win32CompatScrollInfos(i)
	Next
	ReDim Preserve Win32CompatScrollInfos(UBound(Win32CompatScrollInfos) + 1)
	With Win32CompatScrollInfos(UBound(Win32CompatScrollInfos))
		.Wnd = sb->Handle
		.nMin = sb->MinValue
		.nMax = sb->MaxValue
		.nPos = sb->Position
	End With
	Return @Win32CompatScrollInfos(UBound(Win32CompatScrollInfos))
End Function

'Sets the range and the position of the element: the positions nMin .. nMax - nPage + 1 like Windows (the last page
'is not scrolled under the bottom). Without WM_VSCROLL / WM_HSCROLL: SetScrollInfo of Windows does not send them,
'OnScroll (Win32CompatScrollBar_Scroll) is only for the user (a nested WM_VSCROLL would change OldPos of the window
'procedure which called SetScrollInfo)
Private Sub Win32CompatScrollApply(ByVal sb As My.Sys.Forms.ScrollBarControl Ptr, ByVal pInfo As Win32CompatScrollInfo Ptr)
	Dim As Long MaxPos = IIf(pInfo->nPage > 0, Max(pInfo->nMin, pInfo->nMax - pInfo->nPage + 1), pInfo->nMax)
	pInfo->nPos = Max(pInfo->nMin, Min(pInfo->nPos, MaxPos))
	With *sb
		Var OnScrollOld = .OnScroll
		.OnScroll = 0
		If .MinValue <> pInfo->nMin Then .MinValue = pInfo->nMin
		If .MaxValue <> MaxPos Then .MaxValue = MaxPos
		'(the size of the thumb)
		If pInfo->nPage > 0 AndAlso .PageSize <> pInfo->nPage Then .PageSize = pInfo->nPage
		If .Position <> pInfo->nPos Then .Position = pInfo->nPos
		.OnScroll = OnScrollOld
	End With
End Sub

Private Function SetScrollInfo(ByVal hwnd As HWND, ByVal nBar As Long, ByVal lpsi As Const SCROLLINFO Ptr, ByVal redraw As BOOL) As Long
	Dim As My.Sys.Forms.ScrollBarControl Ptr sb = Win32CompatScrollBar(hwnd)
	If sb = 0 OrElse lpsi = 0 Then Return 0
	Dim As Win32CompatScrollInfo Ptr pInfo = Win32CompatScrollInfoOf(sb)
	If lpsi->fMask And SIF_RANGE Then pInfo->nMin = lpsi->nMin: pInfo->nMax = lpsi->nMax
	If lpsi->fMask And SIF_PAGE Then pInfo->nPage = lpsi->nPage
	If lpsi->fMask And SIF_POS Then pInfo->nPos = lpsi->nPos
	Win32CompatScrollApply sb, pInfo
	Return pInfo->nPos
End Function

'nPos is the position of the program (SetScrollInfo), nTrackPos the one of the element (the thumb moved by the user)
Private Function GetScrollInfo(ByVal hwnd As HWND, ByVal nBar As Long, ByVal lpsi As SCROLLINFO Ptr) As BOOL
	Dim As My.Sys.Forms.ScrollBarControl Ptr sb = Win32CompatScrollBar(hwnd)
	If sb = 0 OrElse lpsi = 0 Then Return 0
	Dim As Win32CompatScrollInfo Ptr pInfo = Win32CompatScrollInfoOf(sb)
	lpsi->nMin = pInfo->nMin
	lpsi->nMax = pInfo->nMax
	lpsi->nPage = pInfo->nPage
	lpsi->nPos = pInfo->nPos
	lpsi->nTrackPos = sb->Position
	Return 1
End Function

Private Function SetScrollPos(ByVal hwnd As HWND, ByVal nBar As Long, ByVal nPos As Long, ByVal bRedraw As BOOL) As Long
	Dim As My.Sys.Forms.ScrollBarControl Ptr sb = Win32CompatScrollBar(hwnd)
	If sb = 0 Then Return 0
	Dim As Win32CompatScrollInfo Ptr pInfo = Win32CompatScrollInfoOf(sb)
	Function = pInfo->nPos
	pInfo->nPos = nPos
	Win32CompatScrollApply sb, pInfo
End Function

Private Function GetScrollPos(ByVal hwnd As HWND, ByVal nBar As Long) As Long
	Dim As My.Sys.Forms.ScrollBarControl Ptr sb = Win32CompatScrollBar(hwnd)
	If sb = 0 Then Return 0
	Return Win32CompatScrollInfoOf(sb)->nPos
End Function

'''' Menus: hMenu is the menu itself (Menu.Handle); the choice is the WM_COMMAND of hWnd or the result (TPM_RETURNCMD)
Private Function TrackPopupMenu(ByVal hMenu As HMENU, ByVal uFlags As UINT, ByVal x As Long, ByVal y As Long, ByVal nReserved As Long, ByVal hWnd As HWND, ByVal prcRect As Const Rect Ptr) As BOOL
	If hMenu = 0 Then Return 0
	Dim As My.Sys.Forms.MenuItem Ptr mi = Cast(My.Sys.Forms.PopupMenu Ptr, hMenu)->ShowMenuModal(x, y)
	If mi = 0 Then Return 0
	If uFlags And TPM_RETURNCMD Then Return mi->Command
	SendMessage(hWnd, WM_COMMAND, MAKEWPARAM(mi->Command, 0), 0)
	Return 1
End Function

'''' The clipboard of the formats of the program

Private Function RegisterClipboardFormat(ByRef lpszFormat As WString) As UINT
	For i As Integer = 0 To UBound(Win32CompatClipNames)
		If Win32CompatClipNames(i) = lpszFormat Then Return &hC000 + i
	Next
	ReDim Preserve Win32CompatClipNames(UBound(Win32CompatClipNames) + 1)
	Win32CompatClipNames(UBound(Win32CompatClipNames)) = lpszFormat
	Return &hC000 + UBound(Win32CompatClipNames)
End Function

Private Function OpenClipboard(ByVal hWndNewOwner As HWND) As BOOL
	Return 1
End Function

Private Function CloseClipboard() As BOOL
	Return 1
End Function

Private Function EmptyClipboard() As BOOL
	For i As Integer = 0 To UBound(Win32CompatClipData)
		If Win32CompatClipData(i) Then Deallocate(Win32CompatClipData(i))
	Next
	Erase Win32CompatClipFormats, Win32CompatClipData
	Return 1
End Function

Private Function SetClipboardData(ByVal uFormat As UINT, ByVal hMem As HANDLE) As HANDLE
	For i As Integer = 0 To UBound(Win32CompatClipFormats)
		If Win32CompatClipFormats(i) = uFormat Then
			If Win32CompatClipData(i) Then Deallocate(Win32CompatClipData(i))
			Win32CompatClipData(i) = hMem
			Return hMem
		End If
	Next
	ReDim Preserve Win32CompatClipFormats(UBound(Win32CompatClipFormats) + 1)
	ReDim Preserve Win32CompatClipData(UBound(Win32CompatClipData) + 1)
	Win32CompatClipFormats(UBound(Win32CompatClipFormats)) = uFormat
	Win32CompatClipData(UBound(Win32CompatClipData)) = hMem
	Return hMem
End Function

Private Function GetClipboardData(ByVal uFormat As UINT) As HANDLE
	For i As Integer = 0 To UBound(Win32CompatClipFormats)
		If Win32CompatClipFormats(i) = uFormat Then Return Win32CompatClipData(i)
	Next
	Return 0
End Function

Private Function IsClipboardFormatAvailable(ByVal uFormat As UINT) As BOOL
	Return GetClipboardData(uFormat) <> 0
End Function

Private Function GlobalAlloc(ByVal uFlags As UINT, ByVal dwBytes As UInteger) As HGLOBAL
	Return CAllocate(Max(1, dwBytes))
End Function

Private Function GlobalLock(ByVal hMem As HGLOBAL) As Any Ptr
	Return hMem
End Function

Private Function GlobalUnlock(ByVal hMem As HGLOBAL) As BOOL
	Return 1
End Function

Private Function GlobalFree(ByVal hMem As HGLOBAL) As HGLOBAL
	If hMem Then Deallocate(hMem)
	Return 0
End Function

'''' The messages of MyFbFramework as the messages of Windows

'The window which gets the mouse: the window with the capture, otherwise a window which is transparent
'for the mouse (HTTRANSPARENT of WM_NCHITTEST) passes it to its parent. x, y are in the client area of the window
Private Sub Win32CompatMouseTarget(ByRef hwnd As HWND, ByRef x As Integer, ByRef y As Integer)
	Dim As Point P = Type<Point>(x, y)
	If Win32CompatCaptureWnd <> 0 AndAlso Win32CompatCaptureWnd <> hwnd Then
		ClientToScreen(hwnd, @P)
		ScreenToClient(Win32CompatCaptureWnd, @P)
		hwnd = Win32CompatCaptureWnd
		x = P.X: y = P.Y
		Exit Sub
	End If
	Dim As Boolean bDefaultCalled = Win32CompatDefaultCalled
	Do
		If Win32CompatWndProc(hwnd) = 0 Then Exit Do
		Dim As Point S = P
		ClientToScreen(hwnd, @S)
		If SendMessage(hwnd, WM_NCHITTEST, 0, MAKELONG(S.X, S.Y)) <> HTTRANSPARENT Then Exit Do
		Dim As HWND hParent = GetParent(hwnd)
		If hParent = 0 Then Exit Do
		ScreenToClient(hParent, @S)
		hwnd = hParent
		P = S
	Loop
	Win32CompatDefaultCalled = bDefaultCalled
	x = P.X: y = P.Y
End Sub

'The CM_* messages of MyFbFramework as the WM_* messages of Windows: the window gets them with SendMessage (its procedure
'or the ProcessMessage of the control). Returns True if Msg was such a message (the caller does nothing more with it)
Private Function Win32CompatDispatch(ByVal Ctrl As My.Sys.Forms.Control Ptr, ByRef msg As Message) As Boolean
	Dim As HWND hwnd = Ctrl->Handle
	Dim As Integer MK = IIf(Win32CompatLButton, MK_LBUTTON, 0) Or IIf(Win32CompatRButton, MK_RBUTTON, 0) Or IIf(Win32CompatMButton, MK_MBUTTON, 0) _
		Or IIf(Win32CompatShift, MK_SHIFT, 0) Or IIf(Win32CompatCtrl, MK_CONTROL, 0)
	Select Case msg.Msg
	Case CM_PAINT
		'The canvas got its size or must be drawn again: first WM_SIZE if the size changed, then the overlays and the caret
		Dim As Integer w = Ctrl->ScaleX(Ctrl->ClientWidth), h = Ctrl->ScaleY(Ctrl->ClientHeight)
		Dim As Win32CompatWnd Ptr pw = Win32CompatFindWnd(hwnd, True)
		If w <> pw->LastWidth OrElse h <> pw->LastHeight Then
			pw->LastWidth = w: pw->LastHeight = h
			SendMessage(hwnd, WM_SIZE, 0, MAKELONG(w, h))
		End If
		GetDC(hwnd)
		Dim As HWND hOldPainting = Win32CompatPaintingWnd
		Win32CompatPaintingWnd = hwnd
		SendMessage(hwnd, WM_ERASEBKGND, Cast(WPARAM, Win32CompatView(Ctrl)), 0)
		SendMessage(hwnd, WM_PAINT, 0, 0)
		Win32CompatPaintingWnd = hOldPainting
		Win32CompatPaintOverlays(Ctrl)
		Win32CompatPaintCaret(Ctrl)
		msg.Handled = True
	Case CM_MOUSEDOWN, CM_MOUSEUP, CM_MOUSEMOVE
		Dim As Integer x = MffPointX(msg.lParam), y = MffPointY(msg.lParam), uMsg
		If msg.Msg = CM_MOUSEDOWN Then
			Select Case msg.wParam
			Case 0
				Win32CompatLButton = True
				'The second press near the first one in the time of a double click
				If Timer - Win32CompatLastClickTime < GetDoubleClickTime / 1000 AndAlso Abs(x - Win32CompatLastClickX) < 5 AndAlso Abs(y - Win32CompatLastClickY) < 5 Then
					uMsg = WM_LBUTTONDBLCLK
					Win32CompatLastClickTime = 0
				Else
					uMsg = WM_LBUTTONDOWN
					Win32CompatLastClickTime = Timer
					Win32CompatLastClickX = x
					Win32CompatLastClickY = y
				End If
			Case 1: Win32CompatRButton = True: uMsg = WM_RBUTTONDOWN
			Case Else: Win32CompatMButton = True: uMsg = WM_MBUTTONDOWN
			End Select
			If Win32CompatFocusWnd <> hwnd Then Ctrl->SetFocus
		ElseIf msg.Msg = CM_MOUSEUP Then
			Select Case msg.wParam
			Case 0: Win32CompatLButton = False: uMsg = WM_LBUTTONUP
			Case 1: Win32CompatRButton = False: uMsg = WM_RBUTTONUP
			Case Else: Win32CompatMButton = False: uMsg = WM_MBUTTONUP
			End Select
		Else
			uMsg = WM_MOUSEMOVE
		End If
		Win32CompatMouseTarget hwnd, x, y
		Win32CompatMouseWnd = hwnd
		Win32CompatMouseX = x
		Win32CompatMouseY = y
		If uMsg = WM_MOUSEMOVE Then
			'Like DefWindowProc of Windows: the cursor of the window (crIBeam of EditControl) when the procedure sets none
			'in WM_SETCURSOR, otherwise a hand or an arrow set over the margin or a scroll bar would stay
			Dim As String sCursor = Ctrl->Cursor.ToString
			Win32CompatSetCursorName IIf(sCursor <> "", sCursor, "default")
			SendMessage(hwnd, WM_SETCURSOR, Cast(WPARAM, hwnd), MAKELONG(HTCLIENT, WM_MOUSEMOVE))
		End If
		MK = IIf(Win32CompatLButton, MK_LBUTTON, 0) Or IIf(Win32CompatRButton, MK_RBUTTON, 0) Or IIf(Win32CompatMButton, MK_MBUTTON, 0) _
			Or IIf(Win32CompatShift, MK_SHIFT, 0) Or IIf(Win32CompatCtrl, MK_CONTROL, 0)
		SendMessage(hwnd, uMsg, MK, MAKELONG(x, y))
	Case CM_MOUSELEAVE
		Win32CompatLButton = False: Win32CompatRButton = False: Win32CompatMButton = False
		SendMessage(hwnd, WM_MOUSELEAVE, 0, 0)
	Case CM_MOUSEWHEEL, CM_MOUSEHWHEEL
		Win32CompatMouseWnd = hwnd
		Win32CompatMouseX = MffPointX(msg.lParam)
		Win32CompatMouseY = MffPointY(msg.lParam)
		Dim As Point P = Type<Point>(Win32CompatMouseX, Win32CompatMouseY)
		ClientToScreen(hwnd, @P)
		Win32CompatDefaultCalled = False
		'The horizontal wheel is the wheel with Shift (the windows scroll sideways with it, EditControl)
		Dim As Boolean bOldShift = Win32CompatShift
		If msg.Msg = CM_MOUSEHWHEEL Then Win32CompatShift = True
		MK = IIf(Win32CompatLButton, MK_LBUTTON, 0) Or IIf(Win32CompatRButton, MK_RBUTTON, 0) Or IIf(Win32CompatMButton, MK_MBUTTON, 0) _
			Or IIf(Win32CompatShift, MK_SHIFT, 0) Or IIf(Win32CompatCtrl, MK_CONTROL, 0)
		SendMessage(hwnd, WM_MOUSEWHEEL, MAKELONG(MK, msg.wParam * WHEEL_DELTA), MAKELONG(P.X, P.Y))
		Win32CompatShift = bOldShift
		'A window which does not handle the wheel (its default procedure gets it) leaves it to the browser: the parents
		'scroll like the ones of Windows (the panel of the designer)
		If Not Win32CompatDefaultCalled Then msg.Result = 1
	Case CM_KEYDOWN, CM_KEYUP
		Dim As Boolean bDown = msg.Msg = CM_KEYDOWN
		Win32CompatShift = (msg.lParam And 1) <> 0
		Win32CompatCtrl = (msg.lParam And 2) <> 0
		Win32CompatAlt = (msg.lParam And 4) <> 0
		Select Case msg.wParam
		Case VK_SHIFT: Win32CompatShift = bDown
		Case VK_CONTROL: Win32CompatCtrl = bDown
		Case VK_MENU: Win32CompatAlt = bDown
		End Select
		SendMessage(hwnd, IIf(bDown, WM_KEYDOWN, WM_KEYUP), msg.wParam, 1)
		If bDown Then
			'Windows gives the characters of these keys (TranslateMessage), the browser and Android do not
			'(the browser gives no keypress for a key whose keydown was handled: Enter)
			Select Case msg.wParam
			Case VK_BACK, VK_TAB, VK_ESCAPE, VK_RETURN: SendMessage(hwnd, WM_CHAR, msg.wParam, 1)
			End Select
			Win32CompatRestartCaretBlink
		End If
		'A key which does not give a character is the one of the window, not of the browser (Tab, Backspace, the arrows, Ctrl+S, ...)
		Select Case msg.wParam
		Case Asc("0") To Asc("9"), Asc("A") To Asc("Z"), VK_SPACE, &h60 To &h6F, VK_OEM_1 To &hC0, &hDB To &hDF, &hE2
			msg.Result = IIf(Win32CompatCtrl OrElse Win32CompatAlt, 1, 0)
		Case VK_SHIFT, VK_CONTROL, VK_MENU, VK_CAPITAL, VK_NUMLOCK, VK_SCROLL, VK_F5, VK_F11, VK_F12
			msg.Result = 0
		Case Else
			msg.Result = 1
		End Select
	Case CM_CHAR
		Select Case msg.wParam
		Case VK_BACK, VK_TAB, VK_ESCAPE, VK_RETURN
			'Already sent with the key
		Case Else
			If Not Win32CompatCtrl Then SendMessage(hwnd, WM_CHAR, msg.wParam, 1)
		End Select
		msg.Result = 1
	Case CM_SETFOCUS
		Win32CompatFocusWnd = hwnd
		SendMessage(hwnd, WM_SETFOCUS, 0, 0)
		Ctrl->Repaint
	Case CM_KILLFOCUS
		If Win32CompatFocusWnd = hwnd Then Win32CompatFocusWnd = 0
		Win32CompatShift = False: Win32CompatCtrl = False: Win32CompatAlt = False
		SendMessage(hwnd, WM_KILLFOCUS, 0, 0)
		Ctrl->Repaint
	Case Else
		Return False
	End Select
	Return True
End Function

'ControlMessageHook of MyFbFramework: the messages of a window with a procedure (subclassed, a class window) go to the
'procedure. The control gets the message only if the procedure gave it back (CallWindowProc with the old procedure)
Private Function Win32CompatHook(ByVal Ctrl As My.Sys.Forms.Control Ptr, ByRef msg As Message) As Boolean
	If Ctrl = 0 OrElse Win32CompatWndProc(Ctrl->Handle) = 0 Then Return False
	Dim As Boolean bDefaultCalled = Win32CompatDefaultCalled
	Win32CompatDefaultCalled = False
	Dim As Boolean bHandled
	If Win32CompatDispatch(Ctrl, msg) Then
		bHandled = Not Win32CompatDefaultCalled
	Else
		'The clicks and the changes of the control are not the ones of Windows: the procedure has them already as WM_*
		bHandled = True
	End If
	Win32CompatDefaultCalled = bDefaultCalled
	Return bHandled
End Function

'''' Direct2D / DirectWrite: only the types of the branches which run when pRenderTarget <> 0 (never on the Web and Android)
Type D2D1_COLOR_F
	r As Single
	g As Single
	b As Single
	a As Single
End Type
Type D2D1_POINT_2F
	x As Single
	y As Single
End Type
Type D2D1_RECT_F
	Left As Single
	Top As Single
	Right As Single
	Bottom As Single
End Type
Type D2D1_ROUNDED_RECT
	rect As D2D1_RECT_F
	radiusX As Single
	radiusY As Single
End Type
Type D2D1_ELLIPSE
	point As D2D1_POINT_2F
	radiusX As Single
	radiusY As Single
End Type
Type DWRITE_TEXT_METRICS
	Left As Single
	Top As Single
	width As Single
	widthIncludingTrailingWhitespace As Single
	height As Single
	layoutWidth As Single
	layoutHeight As Single
	maxBidiReorderingDepth As ULong
	lineCount As ULong
End Type
Const D2D1_ANTIALIAS_MODE_PER_PRIMITIVE = 0, D2D1_ANTIALIAS_MODE_ALIASED = 1, D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT = 4
Const FLT_MAX = 3.402823466e+38
Type ID2D1Brush As ID2D1Brush_
Type ID2D1SolidColorBrush As ID2D1SolidColorBrush_
Type IDWriteTextFormat As IDWriteTextFormat_
Type IDWriteTextLayout As IDWriteTextLayout_
Type ID2D1DeviceContext As ID2D1DeviceContext_
Type IDWriteFactory As IDWriteFactory_
Type ID2D1BrushVtbl
	Release As Function(ByVal This As ID2D1Brush Ptr) As ULong
End Type
Type ID2D1Brush_
	lpVtbl As ID2D1BrushVtbl Ptr
End Type
Type ID2D1SolidColorBrushVtbl
	Release As Function(ByVal This As ID2D1SolidColorBrush Ptr) As ULong
	SetColor As Sub(ByVal This As ID2D1SolidColorBrush Ptr, ByVal color As Const D2D1_COLOR_F Ptr)
End Type
Type ID2D1SolidColorBrush_
	lpVtbl As ID2D1SolidColorBrushVtbl Ptr
End Type
Type IDWriteTextFormatVtbl
	Release As Function(ByVal This As IDWriteTextFormat Ptr) As ULong
End Type
Type IDWriteTextFormat_
	lpVtbl As IDWriteTextFormatVtbl Ptr
End Type
Type IDWriteTextLayoutVtbl
	Release As Function(ByVal This As IDWriteTextLayout Ptr) As ULong
	GetMetrics As Function(ByVal This As IDWriteTextLayout Ptr, ByVal textMetrics As DWRITE_TEXT_METRICS Ptr) As HRESULT
End Type
Type IDWriteTextLayout_
	lpVtbl As IDWriteTextLayoutVtbl Ptr
End Type
Type IDWriteFactoryVtbl
	CreateTextLayout As Function(ByVal This As IDWriteFactory Ptr, ByVal s As Const WString Ptr, ByVal stringLength As ULong, ByVal textFormat As IDWriteTextFormat Ptr, ByVal maxWidth As Single, ByVal maxHeight As Single, ByVal textLayout As IDWriteTextLayout Ptr Ptr) As HRESULT
End Type
Type IDWriteFactory_
	lpVtbl As IDWriteFactoryVtbl Ptr
End Type
Type ID2D1DeviceContextVtbl
	Release As Function(ByVal This As ID2D1DeviceContext Ptr) As ULong
	CreateSolidColorBrush As Function(ByVal This As ID2D1DeviceContext Ptr, ByVal color As Const D2D1_COLOR_F Ptr, ByVal brushProperties As Any Ptr, ByVal solidColorBrush As Any Ptr) As HRESULT
	FillRectangle As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal rect As Const D2D1_RECT_F Ptr, ByVal brush As Any Ptr)
	DrawRectangle As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal rect As Const D2D1_RECT_F Ptr, ByVal brush As Any Ptr, ByVal strokeWidth As Single, ByVal strokeStyle As Any Ptr)
	FillRoundedRectangle As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal roundedRect As Const D2D1_ROUNDED_RECT Ptr, ByVal brush As Any Ptr)
	DrawLine As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal point0 As D2D1_POINT_2F, ByVal point1 As D2D1_POINT_2F, ByVal brush As Any Ptr, ByVal strokeWidth As Single = 1, ByVal strokeStyle As Any Ptr = 0)
	FillEllipse As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal ellipse As Const D2D1_ELLIPSE Ptr, ByVal brush As Any Ptr)
	DrawEllipse As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal ellipse As Const D2D1_ELLIPSE Ptr, ByVal brush As Any Ptr, ByVal strokeWidth As Single = 1, ByVal strokeStyle As Any Ptr = 0)
	DrawTextLayout As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal origin As D2D1_POINT_2F, ByVal textLayout As IDWriteTextLayout Ptr, ByVal defaultFillBrush As Any Ptr, ByVal options As Long)
	PushAxisAlignedClip As Sub(ByVal This As ID2D1DeviceContext Ptr, ByVal clipRect As Const D2D1_RECT_F Ptr, ByVal antialiasMode As Long)
	PopAxisAlignedClip As Sub(ByVal This As ID2D1DeviceContext Ptr)
	BeginDraw As Sub(ByVal This As ID2D1DeviceContext Ptr)
	EndDraw As Function(ByVal This As ID2D1DeviceContext Ptr, ByVal tag1 As Any Ptr, ByVal tag2 As Any Ptr) As HRESULT
End Type
Type ID2D1DeviceContext_
	lpVtbl As ID2D1DeviceContextVtbl Ptr
End Type
Dim Shared As IDWriteFactory Ptr pDWriteFactory
Dim Shared As Boolean g_Direct2DEnabled
'Never called (pRenderTarget is 0): the polygons of the Direct2D branches
Private Sub FillPolygon(points() As D2D1_POINT_2F, ByVal pRT As ID2D1DeviceContext Ptr, ByVal brush As ID2D1Brush Ptr)
End Sub
