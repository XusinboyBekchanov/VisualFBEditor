'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	
	#include once "gdipMonth.bi"
	#include once "gdipDay.bi"
	
	Using My.Sys.Forms
	
	Type frmMonthType Extends Form
		
		mDate As Double
		
		'initial gdip token
		Token As gdipToken
		'form trans
		frmTrans As gdipForm
		'form display device
		frmDC As gdipDC
		'memory display device
		memDC As gdipDC
		'form canvas
		frmGraphic As gdipGraphics
		
		'draw analog coloc
		mMonth As gdipMonth
		mOpacity As UINT = &HFF
		
		Declare Sub DateChange(sDate As Double)
		Declare Sub Transparent(v As Boolean)
		Declare Sub PaintMonth()
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_MouseLeave(ByRef Sender As Control)
		Declare Constructor
		
		Dim As PopupMenu PopupMenu1
	End Type
	
	Constructor frmMonthType
		' frmMonth
		With This
			.Name = "frmMonth"
			.Text = "frmMonth"
			.Designer = @This
			.Caption = "frmMonth"
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Form_Paint)
			.Hint = "Month"
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.OnMouseLeave = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_MouseLeave)
			.ContextMenu = @PopupMenu1
			.ShowCaption = false
			.SetBounds 0, 0, 240, 200
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmMonth As frmMonthType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmMonth.MainForm = True
		frmMonth.Show
		App.Run
	#endif
'#End Region

Private Sub frmMonthType.Form_Click(ByRef Sender As Control)
	Select Case mMonth.mMouseLocate
	Case 0 'day
		DateChange(mMonth.XY2Date(mMonth.mMouseX, mMonth.mMouseY))
	Case 4 'today
		DateChange(Now())
	Case 5 'year dec
		DateChange(mMonth.DateCalculate("yyyy", -1))
	Case 6 'year inc
		DateChange(mMonth.DateCalculate("yyyy", 1))
	Case 7 'month dec
		DateChange(mMonth.DateCalculate("m", -1))
	Case 8 'month inc
		DateChange(mMonth.DateCalculate("m", 1))
	Case 1 'show weeks/control
		mMonth.mShowWeeks = Not mMonth.mShowWeeks
		mMonth.mShowControls = Not mMonth.mShowControls
		mMonth.mForceUpdate= True
		PaintMonth()
	Case 2 'hide weeks
		mMonth.mShowWeeks = False
		mMonth.mForceUpdate= True
		PaintMonth()
	Case 3 'hide control
		mMonth.mShowControls = False
		mMonth.mForceUpdate= True
		PaintMonth()
	End Select
End Sub

Private Sub frmMonthType.Form_Create(ByRef Sender As Control)
	'CoInitialize(NULL)
	
	mDate = DateSerial(Year(Now()), Month(Now()), Day(Now()))
	Caption = Format(mDate, "yyyy/mm/dd")
	PopupMenu1.Add @frmClock.mnuMonthSetting
	If frmClock.mnuLocateSticky.Checked Then 
		frmClock.Form_Move(frmClock)
	Else
		frmMonth.Move(frmClock.mRectMonth.Left, frmClock.mRectMonth.Top, frmClock.mRectMonth.Right, frmClock.mRectMonth.Bottom)
	End If
End Sub

Private Sub frmMonthType.Form_Show(ByRef Sender As Form)
	SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) And Not WS_CAPTION)
	SetWindowPos(Handle, NULL, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE Or SWP_NOZORDER Or SWP_FRAMECHANGED)
	
	Transparent(frmClock.mnuTransparent.Checked)
End Sub

Private Sub frmMonthType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	'CoUninitialize()
	frmClock.ProfileFrmMonth()
	frmClock.mnuMonthEnabled.Checked = False
End Sub

Private Sub frmMonthType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	PaintMonth()
End Sub

Private Sub frmMonthType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	mMonth.mForceUpdate= True
	If frmClock.mnuTransparent.Checked Then
		mMonth.Background(Width*xdpi, Height*ydpi, mDate)
	Else
		mMonth.Background(ClientWidth*xdpi, ClientHeight*ydpi, mDate)
	End If
	PaintMonth()
	frmClock.Profile2Interface()
End Sub

Private Sub frmMonthType.DateChange(sDate As Double)
	mDate = DateSerial(Year(sDate), Month(sDate), Day(sDate))
	Caption = Format(mDate, "yyyy/mm/dd")
	Form_Resize(This, Width, Height)
	frmDay.DateChange(sDate)
End Sub

Private Sub frmMonthType.Transparent(v As Boolean)
	frmTrans.Enabled = v
	Form_Resize(This, Width, Height)
End Sub

Private Sub frmMonthType.PaintMonth()
	If frmClock.mnuTransparent.Checked Then
		frmTrans.Create(Handle, mMonth.ImageUpdate(mDate))
		frmTrans.Transform(frmClock.mOpacity)
	Else
		frmDC.Initial(Handle)
		memDC.Initial(0, ClientWidth*xdpi, ClientHeight*ydpi)
		frmGraphic.Initial(memDC.DC, True)
		frmGraphic.DrawImage(mMonth.ImageUpdate(mDate))
		BitBlt(frmDC.DC, 0, 0, ClientWidth*xdpi, ClientHeight*ydpi, memDC.DC, 0, 0, SRCCOPY)
	End If
End Sub

Private Sub frmMonthType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Static sX As Integer
	Static sY As Integer
	If CBool(sX = x) And CBool(sY = y) Then Exit Sub
	sX = x
	sY = y
	
	If MouseButton = 0 Then
		ReleaseCapture()
		SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	End If
	
	mMonth.mMouseX = x * xdpi
	mMonth.mMouseY = y * ydpi
	PaintMonth()
	Select Case mMonth.mMouseLocate
	Case 0 'day
		Hint = Format(mMonth.XY2Date(x*xdpi, y*ydpi), "yyyy/mm/dd")
	Case 4 'today
		Hint = "Show today"
	Case 5 'year dec
		Hint = "Year -1"
	Case 6 'year inc
		Hint = "Year +1"
	Case 7 'month dec
		Hint = "Month -1"
	Case 8 'month inc
		Hint = "Month +1"
	Case 1 'show weeks/control
		Hint = "Show/hide weeks/controls"
	Case 2 'hide weeks
		Hint = "Hide weeks"
	Case 3 'hide control
		Hint = "Hide controls"
	End Select
End Sub

Private Sub frmMonthType.Form_MouseLeave(ByRef Sender As Control)
	Form_MouseMove(This, -1, -1, -1, 0)
End Sub
