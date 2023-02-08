'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		Const _MAIN_FILE_ = __FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmRadar.rc"
		#endif
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/TextBox.bi"
	
	#include once "win/winuser.bi"
	#include once "win/wingdi.bi"
	
	Using My.Sys.Forms
	
	Type frmRadarType Extends Form
		mhWnd As HWND = 0
		phWnd As HWND = 0
		
		Declare Sub HighlighthWnd(hWnd As HWND)
		
		Declare Static Sub _ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As ImageBox ImageBox1
		Dim As TextBox TextBox1, TextBox2, TextBox3, TextBox4, TextBox5
	End Type
	
	Constructor frmRadarType
		'Form1
		With This
			.Name = "frmRadar"
			.Text = "Radar"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			.Caption = "Radar"
			.Size = Type<My.Sys.Drawing.Size>(340, 170)
			.SetBounds 0, 0, 360, 180
		End With
		'ImageBox1
		With ImageBox1
			.Name = "ImageBox1"
			.Text = "ImageBox1"
			.BorderStyle = BorderStyles.bsNone
			.Hint = "Drag me to a control"
			.BackColor = 8421504
			.SetBounds 10, 10, 40, 40
			.Designer = @This
			.OnMouseDown = @_ImageBox1_MouseDown
			.OnMouseMove= @_ImageBox1_MouseMove
			.OnMouseUp = @_ImageBox1_MouseUp
			.Parent = @This
		End With
		'TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 0
			.Hint = "Handle"
			.SetBounds 60, 10, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = ""
			.TabIndex = 1
			.Hint = "Mouse position"
			.SetBounds 200, 10, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox3
		With TextBox3
			.Name = "TextBox3"
			.Text = ""
			.TabIndex = 2
			.Hint = "Window RECT"
			.SetBounds 60, 40, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox4
		With TextBox4
			.Name = "TextBox4"
			.Text = ""
			.TabIndex = 3
			.Hint = "Class name"
			.SetBounds 200, 40, 130, 20
			.Designer = @This
			.Parent = @This
		End With
		'TextBox5
		With TextBox5
			.Name = "TextBox5"
			.Text = ""
			.TabIndex = 4
			.Hint = "Window text"
			.Multiline = True
			.ID = 1214
			.ScrollBars = ScrollBarsType.Vertical
			.SetBounds 10, 70, 320, 60
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Private Sub frmRadarType._ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmRadarType Ptr, Sender.Designer)).ImageBox1_MouseUp(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmRadarType._ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmRadarType Ptr, Sender.Designer)).ImageBox1_MouseMove(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Private Sub frmRadarType._ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		(*Cast(frmRadarType Ptr, Sender.Designer)).ImageBox1_MouseDown(Sender, MouseButton, x, y, Shift)
	End Sub
	
	Dim Shared frmRadar As frmRadarType
	
	#if _MAIN_FILE_ = __FILE__
		frmRadar.MainForm = True
		frmRadar.Show
		App.Run
	#endif
'#End Region

Private Function GetRectStr(hWnd As HWND) As String
    Dim lu_RECT         As Rect
    GetWindowRect(hWnd, @lu_RECT)
    Return lu_RECT.Left & ", " & lu_RECT.Right & ", " & lu_RECT.Top & ", " & lu_RECT.Bottom
End Function

'高亮窗口
Private Sub HighlightWindow(hWnd As HWND, C As Long)
	Dim ll_hDC          As HDC
	Dim ll_Pen          As HPEN
	Dim lu_RECT         As Rect
	
	'给出窗口矩形
	GetWindowRect(hWnd, @lu_RECT)
	'给出窗口的设备名 DC
	ll_hDC = GetWindowDC(hWnd)
	
	SetROP2 ll_hDC, R2_NOT                             '设置DC的颜色，备以后移去时使用
	
	'建立画笔
	ll_Pen = CreatePen(0, 5 * GetSystemMetrics(SM_CXBORDER), &HFF000000 + C)
	
	'开始增亮窗口边框
	SaveDC(ll_hDC)                                     '保存画笔和刷子
	SelectObject(ll_hDC, ll_Pen)                       '设置新笔
	SelectObject(ll_hDC, GetStockObject(NULL_BRUSH))   '设备空刷子，背景不能修改
	
	'画窗口边框
	Rectangle ll_hDC, 0, 0, lu_RECT.Right - lu_RECT.Left, lu_RECT.Bottom - lu_RECT.Top
	
	'恢复DC设备
	RestoreDC(ll_hDC, -1)                              '-1时恢复以前的内容
	
	'释放
	ReleaseDC hWnd, ll_hDC
	DeleteObject ll_Pen
End Sub

Private Sub frmRadarType.HighlighthWnd(hWnd As HWND)
	If hWnd Then
		'高亮当前窗口
		HighlightWindow hWnd, 0
	End If
	If phWnd Then
		'不高亮最后一个窗口
		HighlightWindow phWnd, 0
	End If
	phWnd = hWnd
End Sub

Private Sub frmRadarType.ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	ImageBox1.BackColor = &h0000ff
	phWnd = 0
	mhWnd = 0
	SetCapture(ImageBox1.Handle)
End Sub

Private Sub frmRadarType.ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Dim hWnd As HWND = 0
	If GetCapture() Then
		Dim p As tagPOINT
		GetCursorPos(@p)
		hWnd = WindowFromPoint(p)
		
		If hWnd = mhWnd Then Exit Sub
		
		TextBox1.Text = hWnd & " (&H" &  Hex(hWnd) & ")"
		TextBox2.Text = p.x & ", " & p.y
		
		TextBox3.Text = GetRectStr(hWnd)
		
		Dim s As WString Ptr
		Dim l As Long = 255
		
		s = CAllocate(l * 2 + 2)
		
		GetClassName(hWnd, s, l)
		TextBox4.Text = *s
		
		l = GetWindowTextLength(hWnd) + 1
		
		s = Reallocate(s, l * 2 + 2)
		GetWindowText(hWnd, s, l)
		TextBox5.Text = *s
		
		Dim hDC As HDC
		hDC = GetWindowDC(This.Handle)
		PrintWindow (mhWnd, hDC, PW_CLIENTONLY)
		ReleaseDC(This.Handle, hDC)
		
		HighlighthWnd(hWnd)
		
		Deallocate(s)
		mhWnd = hWnd
	End If
End Sub

Private Sub frmRadarType.ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	ReleaseCapture()
	ImageBox1.BackColor = &h808080
	InvalidateRect(0, 0, True)
End Sub
