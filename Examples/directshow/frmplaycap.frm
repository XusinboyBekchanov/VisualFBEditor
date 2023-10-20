'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmplaycap.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/CommandButton.bi"
	
	#include once "playcap.bi"
	
	Using My.Sys.Forms
	
	Type frmplaycapType Extends Form
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub TimerComponent1_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent2_Timer(ByRef Sender As TimerComponent)
		Declare Constructor
		
		Dim As TimerComponent TimerComponent1, TimerComponent2
	End Type
	
	Constructor frmplaycapType
		' frmplaycap
		With This
			.Name = "frmplaycap"
			.Text = "playcap"
			.Designer = @This
			.Caption = "playcap"
			.StartPosition = FormStartPosition.CenterScreen
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.SetBounds 0, 0, 350, 300
		End With
		' TimerComponent1
		With TimerComponent1
			.Name = "TimerComponent1"
			.Interval = 2000
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent1_Timer)
			.Parent = @This
		End With
		' TimerComponent2
		With TimerComponent2
			.Name = "TimerComponent2"
			.Interval = 100
			.SetBounds 40, 10, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent2_Timer)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmplaycap As frmplaycapType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmplaycap.MainForm = True
		frmplaycap.Show
		App.Run
		App.Run
	#endif
'#End Region

Private Sub frmplaycapType.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)
	
	Dim As HRESULT hr = PreviewVideo(Cast(OAHWND, This.Handle))
	If hr <> S_OK Then
		MsgBox(!"No video capture device was detected.\r\n" _
		!"This sample requires a video capture device,\r\n" _
		!"such as a USB WebCam, to be installed and working\r\n" _
		!"properly.", _
		"No Video Capture Hardware")
		Caption = "No Video Capture Hardware"
		Exit Sub
	End If
	
	hr = pMVideo->lpVtbl->BindToObject(pMVideo, 0, 0, @IID_IBaseFilter, @pVCap)
	Dim As WString Ptr displayname
	hr = pMVideo->lpVtbl->GetDisplayName(pMVideo, 0, 0, @displayname)
	Print *displayname
	
	Dim As IPropertyBag Ptr pBag
	pMVideo->lpVtbl->BindToStorage(pMVideo, 0, 0, @IID_IPropertyBag, @pBag)
	Dim As VARIANT pFName, pClsid
	pBag->lpVtbl->Read(pBag, "FriendlyName", @pFName, 0)
	pBag->lpVtbl->Read(pBag, "CLSID", @pClsid, 0)
	Print *Cast(WString Ptr, pFName.bstrVal)
	Print *Cast(WString Ptr, pClsid.bstrVal)
	Caption = Caption & " - " & *Cast(WString Ptr, pFName.bstrVal)
	TimerComponent1.Enabled = True 
End Sub

Private Sub frmplaycapType.Form_Destroy(ByRef Sender As Control)
	CloseInterfaces()
	CoUninitialize()
End Sub

Private Sub frmplaycapType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	ResizeVideoWindow(Cast(OAHWND, This.Handle))
End Sub

Private Sub frmplaycapType.TimerComponent1_Timer(ByRef Sender As TimerComponent)
	TimerComponent1.Enabled = False
	pMC->lpVtbl->Pause(pMC)

	If CaptureBmp(@Str("playcap.bmp")) Then
		TimerComponent1.Enabled = True
	End If
	
	pMC->lpVtbl->run(pMC)
End Sub

Private Sub frmplaycapType.TimerComponent2_Timer(ByRef Sender As TimerComponent)
	
End Sub
