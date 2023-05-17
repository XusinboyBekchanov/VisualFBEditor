' Radar 窗口探测
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmRadar.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ImageBox.bi"
	#include once "mff/TextBox.bi"
	
	#include once "win/winuser.bi"
	#include once "win/wingdi.bi"
	
	Using My.Sys.Forms
	
	Type frmRadarType Extends Form
		mhWnd As HWND = 0 '当前控件句柄
		phWnd As HWND = 0 '前一控件句柄
		
		Declare Sub HighlighthWnd(hWnd As HWND)
		
		Declare Static Sub _ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Static Sub _ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
		Dim As ImageBox ImageBox1, ImageBox2
		Dim As TextBox TextBox1, TextBox2, TextBox3, TextBox4, TextBox5
	End Type
	
	Constructor frmRadarType
		'Form1
		With This
			.Name = "frmRadar"
			.Text = "Radar32"
			.Designer = @This
			.StartPosition = FormStartPosition.CenterScreen
			#ifdef __FB_64BIT__
				.Caption = "Radar64"
			#else
				.Caption = "Radar32"
			#endif
			.Size = Type<My.Sys.Drawing.Size>(340, 170)
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = True
			.Location = Type<My.Sys.Drawing.Point>(0, 0)
			.SetBounds 0, 0, 350, 370
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
		' ImageBox2
		With ImageBox2
			.Name = "ImageBox2"
			.Text = "ImageBox2"
			.BackColor = 12632256
			.SetBounds 10, 140, 320, 190
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

'获取控件位置大小
Private Function ObjectRect2Str(hWnd As HWND) As String
	Dim lRT As Rect
	GetWindowRect(hWnd, @lRT)
	Return lRT.Left & ", " & lRT.Right & ", " & lRT.Top & ", " & lRT.Bottom
End Function

'控件截图
Private Sub ObjectScreenShot(hWndObj As HWND, hWndImg As HWND)
	Dim hDC As HDC
	hDC = GetWindowDC(hWndImg)
	PrintWindow(hWndObj, hDC, PW_CLIENTONLY)
	ReleaseDC(hWndImg, hDC)
End Sub

'控件高亮
Private Sub ObjectHighlight(hWnd As HWND, mColor As Long)
	Dim lhDC As HDC
	Dim lPen As HPEN
	Dim lRT As Rect
	
	'获取控件矩形
	GetWindowRect(hWnd, @lRT)
	'获取控件DC
	lhDC = GetWindowDC(hWnd)
	
	SetROP2 lhDC, R2_NOT                             '设置DC的颜色，备以后移去时使用
	
	'建立画笔
	lPen = CreatePen(0, 5 * GetSystemMetrics(SM_CXBORDER), &Hff000000 + mColor)
	
	'增亮控件边框
	SaveDC(lhDC)                                     '保存画笔和刷子
	SelectObject(lhDC, lPen)                         '设置新笔
	SelectObject(lhDC, GetStockObject(NULL_BRUSH))   '设备空刷子，背景不能修改
	
	'画控件边框
	Rectangle lhDC, 0, 0, lRT.Right - lRT.Left, lRT.Bottom - lRT.Top
	
	'恢复DC
	RestoreDC(lhDC, -1)                              '-1时恢复以前的内容
	
	'释放
	ReleaseDC hWnd, lhDC
	DeleteObject lPen
End Sub

Private Sub frmRadarType.HighlighthWnd(hWnd As HWND)
	If phWnd <> 0 Then
		'恢复上一个控件
		ObjectHighlight(phWnd, RGB(&h80, &h80, &h80))
	End If
	If hWnd <> 0 Then
		'高亮当前控件
		ObjectHighlight(hWnd, RGB(&h80, &h80, &h80))
	End If
	
	'If phWnd = hWnd Then
	'	phWnd = 0
	'Else
		phWnd = hWnd
	'End If
End Sub

Private Sub frmRadarType.ImageBox1_MouseDown(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	SetCapture(ImageBox1.Handle)
	ImageBox1.BackColor = &h0000ff
	ImageBox1_MouseMove(Sender, MouseButton, x, y, Shift)
End Sub

Private Sub frmRadarType.ImageBox1_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If GetCapture() = 0 Then Exit Sub
	Dim hWnd As HWND = 0
	Dim p As tagPOINT
	Dim s As WString Ptr
	Dim l As Long = 255
	
	'取得鼠标坐标
	GetCursorPos(@p)
	TextBox2.Text = p.x & ", " & p.y
	
	'取得坐标控件句柄
	hWnd = WindowFromPoint(p)
	
	'如果控件未变退出处理
	If hWnd = mhWnd Or hWnd = 0 Then Exit Sub
	
	'高亮显示控件
	HighlighthWnd(hWnd)
	
	'显示控件句柄
	TextBox1.Text = hWnd & " (&H" &  Hex(hWnd) & ")"
	'显示控件位置大小
	TextBox3.Text = ObjectRect2Str(hWnd)
	
	'显示控件类型
	s = CAllocate(l * 2 + 2)
	GetClassName(hWnd, s, l)
	TextBox4.Text = *s
	
	'显示控件文字
	l = GetWindowTextLength(hWnd) + 1
	s = Reallocate(s, l * 2 + 2)
	GetWindowText(hWnd, s, l)
	TextBox5.Text = *s
	Deallocate(s)
	
	'显示控件截图
	ObjectScreenShot(hWnd, ImageBox2.Handle)
	
	mhWnd = hWnd
End Sub

Private Sub frmRadarType.ImageBox1_MouseUp(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If GetCapture() = 0 Then Exit Sub
	HighlighthWnd(0)
	ImageBox1.BackColor = &h808080
	ReleaseCapture()
	'InvalidateRect(0, 0, True)
End Sub
