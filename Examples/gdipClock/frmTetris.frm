'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	
	#include once "gdip.bi"
	#include once "gdipText.bi"
	
	#include once "gdipTetris.bi"
	
	Using My.Sys.Forms
	
	Type frmTetrisType Extends Form
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
		
		mImg As gdipImage
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Constructor
		
	End Type
	
	Constructor frmTetrisType
		' frmTetris
		With This
			.Name = "frmTetris"
			.Text = "Tetris"
			.Designer = @This
			.Caption = "Tetris"
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Form_Paint)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.SetBounds 0, 0, 350, 300
		End With
	End Constructor
	
	Dim Shared frmTetris As frmTetrisType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmTetris.MainForm = True
		frmTetris.Show
		App.Run
	#endif
'#End Region

Private Sub frmTetrisType.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)
	mImg.FromFile(WStr("F:\OfficePC_Update\!FB\Examples\gdipClock\TextFlower.png"))
End Sub

Private Sub frmTetrisType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	CoUninitialize()
End Sub

Private Sub frmTetrisType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	frmDC.Initial(Handle)
	
	memDC.Initial(0, ClientWidth, ClientHeight)
	
	frmGraphic.Initial(memDC.DC, True)
	
	frmGraphic.DrawImage(mImg.Image, 0, 0)
	BitBlt(frmDC.DC, 0, 0, ClientWidth, ClientHeight, memDC.DC, 0, 0, SRCCOPY)
End Sub

Private Sub frmTetrisType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 0 Then Exit Sub
	ReleaseCapture()
	SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
End Sub
