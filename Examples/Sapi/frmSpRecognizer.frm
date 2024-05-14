'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmSpRecognizer.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Label.bi"
	
	#include once "Speech.bi"
	
	Using My.Sys.Forms
	Using Speech
	
	Type frmSpRecognizerType Extends Form
		ClassID As GUID
		RIid As GUID
		pSpRecognizer As ISpRecognizer Ptr
		pSpRecoContext As ISpRecoContext Ptr
		pSpRecoGrammar As ISpRecoGrammar Ptr
		pWaveFormat As WaveFormatEx Ptr = Allocate(SizeOf(WaveFormatEx))
		mCancel As Boolean
		
		Declare Sub ProcessRecognition()
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ComboBoxEdit ComboBoxEdit1, ComboBoxEdit2
		Dim As CommandButton CommandButton1, CommandButton2
		Dim As TextBox TextBox1
		Dim As Label Label1, Label2, Label3
	End Type
	
	Constructor frmSpRecognizerType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = .Language
			End With
		#endif
		' frmSpRecognizer
		With This
			.Name = "frmSpRecognizer"
			.Text = "SAPI Speech-Recognizer"
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.Caption = "SAPI Speech-Recognizer"
			.StartPosition = FormStartPosition.CenterScreen
			.BorderStyle = FormBorderStyle.FixedSingle
			.MaximizeBox = False
			.SetBounds 0, 0, 420, 290
		End With
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Audio input device"
			.TabIndex = 0
			.Caption = "Audio input device"
			.SetBounds 10, 10, 180, 20
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit1
		With ComboBoxEdit1
			.Name = "ComboBoxEdit1"
			.Text = "ComboBoxEdit1"
			.TabIndex = 1
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 30, 390, 21
			.Designer = @This
			.Parent = @This
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "Recognizer select"
			.TabIndex = 2
			.Caption = "Recognizer select"
			.SetBounds 10, 60, 180, 20
			.Designer = @This
			.Parent = @This
		End With
		' ComboBoxEdit2
		With ComboBoxEdit2
			.Name = "ComboBoxEdit2"
			.Text = "ComboBoxEdit2"
			.TabIndex = 3
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 80, 388, 21
			.Designer = @This
			.Parent = @This
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = "Recognize result"
			.TabIndex = 4
			.Caption = "Recognize result"
			.SetBounds 10, 130, 180, 20
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Start"
			.TabIndex = 5
			.Caption = "Start"
			.SetBounds 190, 130, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Stop"
			.TabIndex = 6
			.Caption = "Stop"
			.Enabled = False
			.SetBounds 300, 130, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @This
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 7
			.HideSelection = False
			.Multiline = True
			.ID = 1025
			.ScrollBars = ScrollBarsType.Both
			.SetBounds 10, 160, 390, 90
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmSpRecognizer As frmSpRecognizerType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmSpRecognizer.MainForm = True
		frmSpRecognizer.Show
		App.Run
	#endif
'#End Region

Private Sub frmSpRecognizerType.ProcessRecognition()
	Dim As SPEVENT sEvent
	Dim As ULong fetched
	
	If pSpRecoContext = NULL Then Exit Sub
	Dim As HRESULT hr = pSpRecoContext->GetEvents(1, @sEvent, @fetched)
	If (SUCCEEDED(hr)) Then
		Select Case sEvent.eEventId
		Case 0
		Case SPEI_RECOGNITION
			Dim As ISpRecoResult Ptr pSpRecoResult
			#ifdef __FB_64BIT__
				pSpRecoResult = Cast(ISpRecoResult Ptr, CULngInt(sEvent.lParam))
			#else
				'Todo: fb32 will crash
				pSpRecoResult = Cast(ISpRecoResult Ptr, CUInt(sEvent.lParam))
			#endif
			Debug.Print "pSpRecoResult  " & pSpRecoResult
			Dim As WString Ptr pwszText
			pSpRecoResult->GetText(SP_GETWHOLEPHRASE, SP_GETWHOLEPHRASE, True, @pwszText, nullptr)
			TextBox1.AddLine *pwszText
			CoTaskMemFree(pwszText)
		Case Else
			Debug.Print sEvent.eEventId
		End Select
	End If
End Sub

Private Sub frmSpRecognizerType.Form_Create(ByRef Sender As Control)
	Debug.Clear
	
	'init COM lib
	CoInitialize(NULL)
	
	'init a recognizer list
	TokenCategory2Cob(SPCAT_AUDIOIN, ComboBoxEdit1)
	
	'init a input list
	TokenCategory2Cob(SPCAT_RECOGNIZERS, ComboBoxEdit2)
End Sub

Private Sub frmSpRecognizerType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	'release recognizer
	
	If pSpRecoGrammar Then pSpRecoGrammar->Release()
	If pSpRecoContext Then pSpRecoContext->Release()
	If pSpRecognizer Then pSpRecognizer->Release()
	
	'release COM lib
	CoUninitialize()
End Sub

Private Sub frmSpRecognizerType.CommandButton_Click(ByRef Sender As Control)
	Debug.Print Sender.Name & ": Start"
	
	Select Case Sender.Name
	Case "CommandButton1"
		mCancel = False
		
		CommandButton1.Enabled = False
		CommandButton2.Enabled = True
		ComboBoxEdit1.Enabled = CommandButton1.Enabled
		ComboBoxEdit2.Enabled = CommandButton1.Enabled
		TextBox1.Clear
		TextBox1.SetFocus
		
		CLSIDFromString(CLSID_SpInprocRecognizer, @ClassID)
		IIDFromString(IID_ISpRecognizer, @RIid)
		Debug.Print "CoCreateInstance   " & CoCreateInstance(@ClassID, NULL, CLSCTX_ALL, @RIid, @pSpRecognizer)
		
		If pSpRecognizer Then
			Debug.Print "SetRecoState   " & pSpRecognizer->SetRecoState(SPRST_INACTIVE_WITH_PURGE)
			Dim i As Integer
			i = ComboBoxEdit1.ItemIndex
			Debug.Print "ItemIndex      " & i
			Debug.Print "ItemData       " & ComboBoxEdit1.ItemData(i)
			Debug.Print "SetInput       " & pSpRecognizer->SetInput(ComboBoxEdit1.ItemData(i), True)
			i = ComboBoxEdit2.ItemIndex
			Debug.Print "ItemIndex      " & i
			Debug.Print "ItemData       " & ComboBoxEdit2.ItemData(i)
			Debug.Print "SetRecognizer  " & pSpRecognizer->SetRecognizer(ComboBoxEdit2.ItemData(i))
			Debug.Print "SetRecoState   " & pSpRecognizer->SetRecoState(SPRST_ACTIVE_ALWAYS)
			
			Debug.Print "CreateRecoContext  " & pSpRecognizer->CreateRecoContext(@pSpRecoContext)
			
			IIDFromString(SPDFID_WaveFormatEx, @RIid)
			Debug.Print "GetFormat      " & pSpRecognizer->GetFormat(SPWAVEFORMATType.SPWF_INPUT, @RIid, @pWaveFormat)
			Debug.Print "Audio Format:"
			Debug.Print "  Format Tag:              " & pWaveFormat->wFormatTag
			Debug.Print "  Channels:                " & pWaveFormat->nChannels
			Debug.Print "  Samples Per Second:      " & pWaveFormat->nSamplesPerSec
			Debug.Print "  Bits Per Sample:         " & pWaveFormat->wBitsPerSample
			Debug.Print "  Block Align:             " & pWaveFormat->nBlockAlign
			Debug.Print "  Avg Bytes Per Second:    " & pWaveFormat->nAvgBytesPerSec
			Debug.Print "  Extra Size:              " & pWaveFormat->cbSize
		End If
		
		If pSpRecoContext Then
			'设置识别模式为听写（Dictation）
			Debug.Print "CreateGrammar          " & pSpRecoContext->CreateGrammar(0, @pSpRecoGrammar)
			Debug.Print "LoadDictation          " & pSpRecoGrammar->LoadDictation(NULL, SPLO_STATIC)
			
			'开始语音识别
			Debug.Print "SetDictationState      " & pSpRecoGrammar->SetDictationState(SPRS_ACTIVE)
			Debug.Print "SetContextState        " & pSpRecoContext->SetContextState(SPCS_ENABLED)
		End If
		
		Do
			ProcessRecognition
			App.DoEvents
		Loop While mCancel = False
		
	Case "CommandButton2"
		mCancel = True
		CommandButton1.Enabled = True
		CommandButton2.Enabled = False
		ComboBoxEdit1.Enabled = CommandButton1.Enabled
		ComboBoxEdit2.Enabled = CommandButton1.Enabled
		
		If pSpRecoGrammar Then
			pSpRecoGrammar->Release()
			pSpRecoGrammar = NULL
		End If
		If pSpRecoContext Then
			pSpRecoContext->SetContextState(SPCS_DISABLED)
			
			pSpRecoContext->Release()
			pSpRecoContext = NULL
		End If
		If pSpRecognizer Then
			pSpRecognizer->SetRecoState(SPRST_INACTIVE_WITH_PURGE)
			pSpRecognizer->Release()
			pSpRecognizer = NULL
		End If
		
	End Select
	Debug.Print Sender.Name & ": End"
End Sub

