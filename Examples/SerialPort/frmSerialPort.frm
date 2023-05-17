'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "SerialPort.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/TimerComponent.bi"
	#include once "mff/Label.bi"

	#include once "SerialPort.bi"
	#include once "../MDINotepad/Text.bi"

	Using My.Sys.Forms
	
	Type frmSerialPortType Extends Form
		ncom As SerialPort
		getStatus As Boolean = False
		
		Declare Sub PortOpen(e As Boolean)
		Declare Sub GetComState()
		Declare Sub GetComModemState()
		Declare Sub SetComState()
		Declare Static Sub DataArrive(Owner As Any Ptr, ArriveData As ZString Ptr, DataLength As Integer)
		
		Declare Static Sub _ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Static Sub _CommandButton_Click(ByRef Sender As Control)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _CheckBox_Click(ByRef Sender As CheckBox)
		Declare Sub CheckBox_Click(ByRef Sender As CheckBox)
		Declare Static Sub _TextBox_Change(ByRef Sender As TextBox)
		Declare Sub TextBox_Change(ByRef Sender As TextBox)
		Declare Static Sub _TimerComponent_Timer(ByRef Sender As TimerComponent)
		Declare Sub TimerComponent_Timer(ByRef Sender As TimerComponent)
		Declare Constructor
		
		Dim As Panel Panel1, Panel3, Panel2, Panel4, Panel5, Panel6, Panel7, Panel8, Panel9
		Dim As CommandButton CommandButton1, CommandButton2, cmdSend, cmdClearRec
		Dim As ComboBoxEdit cbePortName, cbeBaudRate, cbeByteSize, cbeStopBits, cbeParity, cbefDtrControl, cbefRtsControl
		Dim As CheckBox chkfBinary, chkfParity, chkfOutxCtsFlow, chkfOutxDsrFlow, chkfDsrSensitivity, chkfTXContinueOnXoff, chkfOutX, chkfInX, chkfErrorChar, chkfNull, chkfAbortOnError, chkCTS, chkDSR, chkRING, chkRLSD, chkHexRec, chkHexSend
		Dim As TextBox txtfDummy2, txtwReserved, txtXonLim, txtXoffLim, txtXonChar, txtXoffChar, txtErrorChar, txtEofChar, txtEvtChar, txtwReserved1, txtRec, txtSend
		Dim As TimerComponent tmrGetStatus, tmrSetStatus
		Dim As Label lblDTR, lblRTS
	End Type
	
	Constructor frmSerialPortType
		' frmSerialPort
		With This
			.Name = "frmSerialPort"
			.Text = "VFBE SerialPort"
			.Designer = @This
			.Caption = "VFBE SerialPort"
			#ifdef __FB_64BIT__
				'...instructions for 64bit OSes...
				.Caption = "VFBE SerialPort64"
			#else
				'...instructions for other OSes
				.Caption = "VFBE SerialPort32"
			#endif
			.OnCreate = @_Form_Create
			.StartPosition = FormStartPosition.CenterScreen
			.SetBounds 0, 0, 820, 680
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alLeft
			.SetBounds 0, 0, 170, 691
			.Designer = @This
			.Parent = @This
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 1
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 170, 140
			.Designer = @This
			.Parent = @Panel1
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Refresh"
			.TabIndex = 3
			.Caption = "Refresh"
			.SetBounds 10, 10, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton_Click
			.Parent = @Panel2
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Open"
			.TabIndex = 4
			.Caption = "Open"
			.Enabled = False
			.SetBounds 90, 10, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton_Click
			.Parent = @Panel2
		End With
		' cbePortName
		With cbePortName
			.Name = "cbePortName"
			.Text = "cbePortName"
			.TabIndex = 5
			.Hint = "Serial Port List"
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 10, 50, 150, 21
			.Designer = @This
			.Parent = @Panel2
		End With
		' cbeBaudRate
		With cbeBaudRate
			.Name = "cbeBaudRate"
			.Text = "cbeBaudRate"
			.TabIndex = 6
			.Hint = "Baud Rate"
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 80, 70, 21
			.Designer = @This
			.Parent = @Panel2
			.AddItem "" & CBR_110
			.AddItem "" & CBR_300
			.AddItem "" & CBR_600
			.AddItem "" & CBR_1200
			.AddItem "" & CBR_2400
			.AddItem "" & CBR_4800
			.AddItem "" & CBR_9600
			.AddItem "" & CBR_14400
			.AddItem "" & CBR_19200
			.AddItem "" & CBR_38400
			.AddItem "" & CBR_56000
			.AddItem "" & CBR_115200
			.AddItem "" & CBR_128000
			.AddItem "" & CBR_256000
			.ItemData(0) = Cast(Any Ptr, CBR_110)
			.ItemData(1) = Cast(Any Ptr, CBR_300)
			.ItemData(2) = Cast(Any Ptr, CBR_600)
			.ItemData(3) = Cast(Any Ptr, CBR_1200)
			.ItemData(4) = Cast(Any Ptr, CBR_2400)
			.ItemData(5) = Cast(Any Ptr, CBR_4800)
			.ItemData(6) = Cast(Any Ptr, CBR_9600)
			.ItemData(7) = Cast(Any Ptr, CBR_14400)
			.ItemData(8) = Cast(Any Ptr, CBR_19200)
			.ItemData(9) = Cast(Any Ptr, CBR_38400)
			.ItemData(10) = Cast(Any Ptr, CBR_56000)
			.ItemData(11) = Cast(Any Ptr, CBR_115200)
			.ItemData(12) = Cast(Any Ptr, CBR_128000)
			.ItemData(13) = Cast(Any Ptr, CBR_256000)
			.OnSelected = @_ComboBoxEdit_Selected
		End With
		' cbeByteSize
		With cbeByteSize
			.Name = "cbeByteSize"
			.Text = "cbeByteSize"
			.TabIndex = 7
			.Hint = "Byte Size: The number of bits in the bytes transmitted and received."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 80, 70, 21
			.Designer = @This
			.Parent = @Panel2
			.AddItem "5"
			.AddItem "6"
			.AddItem "7"
			.AddItem "8"
			.ItemData(0) = Cast(Any Ptr, 0)
			.ItemData(1) = Cast(Any Ptr, 1)
			.ItemData(2) = Cast(Any Ptr, 2)
			.ItemData(3) = Cast(Any Ptr, 3)
			.OnSelected = @_ComboBoxEdit_Selected
		End With
		' cbeStopBits
		With cbeStopBits
			.Name = "cbeStopBits"
			.Text = "cbeStopBits"
			.TabIndex = 8
			.Hint = "Stop Bits: The number of stop bits to be used. This member can be one of the following values."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 10, 110, 70, 21
			.Designer = @This
			.Parent = @Panel2
			.AddItem "1"
			.AddItem "1.5"
			.AddItem "2"
			.ItemData(0) = Cast(Any Ptr, &h1)
			.ItemData(1) = Cast(Any Ptr, &h2)
			.ItemData(2) = Cast(Any Ptr, &h4)
			.OnSelected = @_ComboBoxEdit_Selected
		End With
		' cbeParity
		With cbeParity
			.Name = "cbeParity"
			.Text = "cbeParity"
			.TabIndex = 9
			.Hint = "Parity: The parity scheme to be used. This member can be one of the following values."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 110, 70, 21
			.Designer = @This
			.Parent = @Panel2
			.AddItem "None"
			.AddItem "Odd"
			.AddItem "Even"
			.AddItem "Mark"
			.AddItem "Space"
			.ItemData(0) = Cast(Any Ptr, &h100)
			.ItemData(1) = Cast(Any Ptr, &h200)
			.ItemData(2) = Cast(Any Ptr, &h400)
			.ItemData(3) = Cast(Any Ptr, &h800)
			.ItemData(4) = Cast(Any Ptr, &h1000)
			.OnSelected = @_ComboBoxEdit_Selected
		End With
		' lblRTS
		With lblRTS
			.Name = "lblRTS"
			.Text = "Pin(7) RTS"
			.TabIndex = 10
			.Caption = "Pin(7) RTS"
			.Hint = "fRtsControl: The RTS (request-to-send) flow control. This member can be one of the following values."
			.ForeColor = 255
			.SetBounds 10, 383, 70, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' lblDTR
		With lblDTR
			.Name = "lblDTR"
			.Text = "Pin(4) DTR"
			.TabIndex = 11
			.Caption = "Pin(4) DTR"
			.Hint = "fDtrControl: The DTR (data-terminal-ready) flow control. This member can be one of the following values."
			.ForeColor = 255
			.SetBounds 10, 233, 70, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' cbefDtrControl
		With cbefDtrControl
			.Name = "cbefDtrControl"
			.Text = "fDtrControl"
			.TabIndex = 12
			.Hint = "fDtrControl: The DTR (data-terminal-ready) flow control. This member can be one of the following values."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 230, 70, 21
			.Designer = @This
			.Parent = @Panel1
			.AddItem("Disable")
			.AddItem("Enable")
			.AddItem("Hand Shake")
			.AddItem("Unuse")
			.OnSelected = @_ComboBoxEdit_Selected
		End With
		' cbefRtsControl
		With cbefRtsControl
			.Name = "cbefRtsControl"
			.Text = "fRtsControl"
			.TabIndex = 13
			.Hint = "fRtsControl: The RTS (request-to-send) flow control. This member can be one of the following values."
			.ForeColor = 0
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 380, 70, 21
			.Designer = @This
			.Parent = @Panel1
			.AddItem("Disable")
			.AddItem("Enable")
			.AddItem("Hand Shake")
			.AddItem("Toggle")
			.OnSelected = @_ComboBoxEdit_Selected
		End With
		' chkfBinary
		With chkfBinary
			.Name = "chkfBinary"
			.Text = "fBinary"
			.TabIndex = 14
			.Hint = "If this member is TRUE, binary mode is enabled. Windows does not support nonbinary mode transfers, so this member must be TRUE."
			.Caption = "fBinary"
			.SetBounds 10, 150, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfParity
		With chkfParity
			.Name = "chkfParity"
			.Text = "fParity"
			.TabIndex = 15
			.Caption = "fParity"
			.Hint = "If this member is TRUE, parity checking is performed and errors are reported."
			.SetBounds 10, 170, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfOutxCtsFlow
		With chkfOutxCtsFlow
			.Name = "chkfOutxCtsFlow"
			.Text = "fOutxCtsFlow"
			.TabIndex = 16
			.Caption = "fOutxCtsFlow"
			.Hint = "If this member is TRUE, the CTS (clear-to-send) signal is monitored for output flow control. If this member is TRUE and CTS is turned off, output is suspended until CTS is sent again."
			.ForeColor = 0
			.SetBounds 10, 190, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfOutxDsrFlow
		With chkfOutxDsrFlow
			.Name = "chkfOutxDsrFlow"
			.Text = "fOutxDsrFlow"
			.TabIndex = 17
			.Caption = "fOutxDsrFlow"
			.Hint = "If this member is TRUE, the DSR (data-set-ready) signal is monitored for output flow control. If this member is TRUE and DSR is turned off, output is suspended until DSR is sent again."
			.ForeColor = 0
			.SetBounds 10, 210, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfDsrSensitivity
		With chkfDsrSensitivity
			.Name = "chkfDsrSensitivity"
			.Text = "fDsrSensitivity"
			.TabIndex = 18
			.Caption = "fDsrSensitivity"
			.Hint = "If this member is TRUE, the communications driver is sensitive to the state of the DSR signal. The driver ignores any bytes received, unless the DSR modem input line is high."
			.SetBounds 10, 260, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfTXContinueOnXoff
		With chkfTXContinueOnXoff
			.Name = "chkfTXContinueOnXoff"
			.Text = "fTXContinueOnXoff"
			.TabIndex = 19
			.Caption = "fTXContinueOnXoff"
			.Hint = "If this member is TRUE, transmission continues after the input buffer has come within XoffLim bytes of being full and the driver has transmitted the XoffChar character to stop receiving bytes. If this member is FALSE, transmission does not continue until the input buffer is within XonLim bytes of being empty and the driver has transmitted the XonChar character to resume reception."
			.SetBounds 10, 280, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfOutX
		With chkfOutX
			.Name = "chkfOutX"
			.Text = "fOutX"
			.TabIndex = 20
			.Caption = "fOutX"
			.Hint = "Indicates whether XON/XOFF flow control is used during transmission. If this member is TRUE, transmission stops when the XoffChar character is received and starts again when the XonChar character is received."
			.SetBounds 10, 300, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfInX
		With chkfInX
			.Name = "chkfInX"
			.Text = "fInX"
			.TabIndex = 21
			.Caption = "fInX"
			.Hint = "Indicates whether XON/XOFF flow control is used during reception. If this member is TRUE, the XoffChar character is sent when the input buffer comes within XoffLim bytes of being full, and the XonChar character is sent when the input buffer comes within XonLim bytes of being empty."
			.SetBounds 10, 320, 150, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfErrorChar
		With chkfErrorChar
			.Name = "chkfErrorChar"
			.Text = "fErrorChar"
			.TabIndex = 23
			.Caption = "fErrorChar"
			.Hint = "Indicates whether bytes received with parity errors are replaced with the character specified by the ErrorChar member. If this member is TRUE and the fParity member is TRUE, replacement occurs."
			.SetBounds 10, 340, 140, 16
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfNull
		With chkfNull
			.Name = "chkfNull"
			.Text = "fNull"
			.TabIndex = 24
			.Caption = "fNull"
			.Hint = "If this member is TRUE, null bytes are discarded when received."
			.SetBounds 10, 360, 150, 20
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' chkfAbortOnError
		With chkfAbortOnError
			.Name = "chkfAbortOnError"
			.Text = "fAbortOnError"
			.TabIndex = 25
			.Caption = "fAbortOnError"
			.Hint = "If this member is TRUE, the driver terminates all read and write operations with an error status if an error occurs. The driver will not accept any further communications operations until the application has acknowledged the error by calling the ClearCommError function."
			.SetBounds 10, 410, 150, 20
			.Designer = @This
			.OnClick = @_CheckBox_Click
			.Parent = @Panel1
		End With
		' txtfDummy2
		With txtfDummy2
			.Name = "txtfDummy2"
			.Text = "fDummy2"
			.TabIndex = 26
			.Hint = "fDummy2: Reserved; do not use."
			.SetBounds 10, 440, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtwReserved
		With txtwReserved
			.Name = "txtwReserved"
			.Text = "wReserved"
			.TabIndex = 27
			.Hint = "wReserved: Reserved; must be zero."
			.SetBounds 90, 440, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtXonLim
		With txtXonLim
			.Name = "txtXonLim"
			.Text = "XonLim"
			.TabIndex = 28
			.Hint = "XonLim: The minimum number of bytes in use allowed in the input buffer before flow control is activated to allow transmission by the sender. This assumes that either XON/XOFF, RTS, or DTR input flow control is specified in the fInX, fRtsControl, or fDtrControl members."
			.SetBounds 10, 460, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtXoffLim
		With txtXoffLim
			.Name = "txtXoffLim"
			.Text = "XoffLim"
			.TabIndex = 29
			.Hint = "XoffLim: The minimum number of free bytes allowed in the input buffer before flow control is activated to inhibit the sender. Note that the sender may transmit characters after the flow control signal has been activated, so this value should never be zero. This assumes that either XON/XOFF, RTS, or DTR input flow control is specified in the fInX, fRtsControl, or fDtrControl members. The maximum number of bytes in use allowed is calculated by subtracting this value from the size, in bytes, of the input buffer."
			.SetBounds 90, 460, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtXonChar
		With txtXonChar
			.Name = "txtXonChar"
			.Text = "XonChar"
			.TabIndex = 30
			.Hint = "XonChar: The value of the XON character for both transmission and reception."
			.SetBounds 10, 480, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtXoffChar
		With txtXoffChar
			.Name = "txtXoffChar"
			.Text = "XoffChar"
			.TabIndex = 31
			.Hint = "XoffChar: The value of the XOFF character for both transmission and reception."
			.SetBounds 90, 480, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtErrorChar
		With txtErrorChar
			.Name = "txtErrorChar"
			.Text = "ErrorChar"
			.TabIndex = 32
			.Hint = "ErrorChar: The value of the character used to replace bytes received with a parity error."
			.SetBounds 10, 500, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtEofChar
		With txtEofChar
			.Name = "txtEofChar"
			.Text = "EofChar"
			.TabIndex = 33
			.Hint = "EofChar: The value of the character used to signal the end of data."
			.SetBounds 90, 500, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtEvtChar
		With txtEvtChar
			.Name = "txtEvtChar"
			.Text = "EvtChar"
			.TabIndex = 34
			.Hint = "EvtChar: The value of the character used to signal an event."
			.SetBounds 10, 520, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' txtwReserved1
		With txtwReserved1
			.Name = "txtwReserved1"
			.Text = "wReserved1"
			.TabIndex = 35
			.Hint = "wReserved1: Reserved; do not use."
			.SetBounds 90, 520, 70, 20
			.Designer = @This
			.OnChange = @_TextBox_Change
			.Parent = @Panel1
		End With
		' Panel3
		With Panel3
			.Name = "Panel3"
			.Text = "Panel3"
			.TabIndex = 2
			.Align = DockStyle.alBottom
			.Enabled = False
			.SetBounds 0, 591, 170, 100
			.Designer = @This
			.Parent = @Panel1
		End With
		' chkCTS
		With chkCTS
			.Name = "chkCTS"
			.Text = "Pin(8) CTS"
			.TabIndex = 36
			.Hint = "The CTS (clear-to-send) signal is on."
			.Caption = "Pin(8) CTS"
			.ForeColor = 32768
			.SetBounds 10, 10, 150, 20
			.Designer = @This
			.Parent = @Panel3
		End With
		' chkDSR
		With chkDSR
			.Name = "chkDSR"
			.Text = "Pin(6) DSR"
			.TabIndex = 37
			.Hint = "The DSR (data-set-ready) signal is on."
			.Caption = "Pin(6) DSR"
			.ForeColor = 32768
			.SetBounds 10, 30, 150, 20
			.Designer = @This
			.Parent = @Panel3
		End With
		' chkRING
		With chkRING
			.Name = "chkRING"
			.Text = "Pin(9) RING"
			.TabIndex = 38
			.Hint = "The ring indicator signal is on."
			.Caption = "Pin(9) RING"
			.ForeColor = 32768
			.SetBounds 10, 50, 150, 20
			.Designer = @This
			.Parent = @Panel3
		End With
		' chkRLSD
		With chkRLSD
			.Name = "chkRLSD"
			.Text = "Pin(1) RLSD"
			.TabIndex = 39
			.Hint = "The RLSD (receive-line-signal-detect) signal is on."
			.Caption = "Pin(1) RLSD"
			.ForeColor = 32768
			.SetBounds 10, 70, 150, 20
			.Designer = @This
			.Parent = @Panel3
		End With
		' tmrGetStatus
		With tmrGetStatus
			.Name = "tmrGetStatus"
			.Interval = 1000
			.SetBounds 90, 160, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent_Timer
			.Parent = @Panel1
		End With
		' tmrSetStatus
		With tmrSetStatus
			.Name = "tmrSetStatus"
			.Interval = 100
			.SetBounds 110, 160, 16, 16
			.Designer = @This
			.OnTimer = @_TimerComponent_Timer
			.Parent = @Panel1
		End With
		' Panel4
		With Panel4
			.Name = "Panel4"
			.Text = "Panel4"
			.TabIndex = 39
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 170, 0, 624, 691
			.Designer = @This
			.Parent = @This
		End With
		' Panel5
		With Panel5
			.Name = "Panel5"
			.Text = "Panel5"
			.TabIndex = 40
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 624, 40
			.Designer = @This
			.Parent = @Panel4
		End With
		' Panel6
		With Panel6
			.Name = "Panel6"
			.Text = "Panel6"
			.TabIndex = 41
			.Align = DockStyle.alBottom
			.SetBounds 0, 551, 634, 140
			.Designer = @This
			.Parent = @Panel4
		End With
		' Panel7
		With Panel7
			.Name = "Panel7"
			.Text = "Panel7"
			.TabIndex = 44
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 624, 40
			.Designer = @This
			.Parent = @Panel6
		End With
		' Panel9
		With Panel9
			.Name = "Panel9"
			.Text = "Panel9"
			.TabIndex = 50
			.Align = DockStyle.alRight
			.SetBounds 534, 0, 90, 40
			.Designer = @This
			.Parent = @Panel7
		End With
		' txtRec
		With txtRec
			.Name = "txtRec"
			.Text = ""
			.TabIndex = 42
			.Align = DockStyle.alClient
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
		.HideSelection = False
			.SetBounds 0, 40, 624, 451
			.Designer = @This
			.Parent = @Panel4
		End With
		' txtSend
		With txtSend
			.Name = "txtSend"
			.Text = ""
			.TabIndex = 43
			.ControlIndex = 0
			.Align = DockStyle.alClient
			.Multiline = True
			.ID = 1002
			.ScrollBars = ScrollBarsType.Both
		.HideSelection = False
			.SetBounds 0, 40, 624, 100
			.Designer = @This
			.Parent = @Panel6
		End With
		' chkHexRec
		With chkHexRec
			.Name = "chkHexRec"
			.Text = "Hex"
			.TabIndex = 45
			.Caption = "Hex"
		.Visible = False
			.SetBounds 0, 10, 70, 20
			.Designer = @This
			.Parent = @Panel5
		End With
		' Panel8
		With Panel8
			.Name = "Panel8"
			.Text = "Panel8"
			.TabIndex = 49
			.Align = DockStyle.alRight
			.SetBounds 534, 0, 90, 40
			.Designer = @This
			.Parent = @Panel5
		End With
		' chkHexSend
		With chkHexSend
			.Name = "chkHexSend"
			.Text = "Hex"
			.TabIndex = 46
		.Visible = False
			.SetBounds 0, 10, 70, 20
			.Designer = @This
			.Parent = @Panel7
		End With
		' cmdSend
		With cmdSend
			.Name = "cmdSend"
			.Text = "Send"
			.TabIndex = 47
			.Caption = "Send"
			.ControlIndex = 0
			.SetBounds 20, 9, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton_Click
			.Parent = @Panel9
		End With
		' cmdClearRec
		With cmdClearRec
			.Name = "cmdClearRec"
			.Text = "Clear"
			.TabIndex = 48
			.Caption = "Clear"
			.ControlIndex = 0
			.SetBounds 20, 9, 70, 20
			.Designer = @This
			.OnClick = @_CommandButton_Click
			.Parent = @Panel8
		End With
	End Constructor
	
	Private Sub frmSerialPortType._TimerComponent_Timer(ByRef Sender As TimerComponent)
		(*Cast(frmSerialPortType Ptr, Sender.Designer)).TimerComponent_Timer(Sender)
	End Sub
	
	Private Sub frmSerialPortType._TextBox_Change(ByRef Sender As TextBox)
		(*Cast(frmSerialPortType Ptr, Sender.Designer)).TextBox_Change(Sender)
	End Sub
	
	Private Sub frmSerialPortType._CheckBox_Click(ByRef Sender As CheckBox)
		(*Cast(frmSerialPortType Ptr, Sender.Designer)).CheckBox_Click(Sender)
	End Sub
	
	Private Sub frmSerialPortType._Form_Create(ByRef Sender As Control)
		(*Cast(frmSerialPortType Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub frmSerialPortType._CommandButton_Click(ByRef Sender As Control)
		(*Cast(frmSerialPortType Ptr, Sender.Designer)).CommandButton_Click(Sender)
	End Sub
	
	Private Sub frmSerialPortType._ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		(*Cast(frmSerialPortType Ptr, Sender.Designer)).ComboBoxEdit_Selected(Sender, ItemIndex)
	End Sub
	
	Dim Shared frmSerialPort As frmSerialPortType
	
	#if _MAIN_FILE_ = __FILE__
		frmSerialPort.MainForm = True
		frmSerialPort.Show
		App.Run
	#endif
'#End Region

Private Sub frmSerialPortType.ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	'Debug.Print Sender.Name
	If getStatus Then Exit Sub
	tmrSetStatus.Enabled = False
	tmrSetStatus.Enabled = True
End Sub

Private Sub frmSerialPortType.CheckBox_Click(ByRef Sender As CheckBox)
	'Debug.Print Sender.Name
	If getStatus Then Exit Sub
	tmrSetStatus.Enabled = False
	tmrSetStatus.Enabled = True
End Sub

Private Sub frmSerialPortType.TextBox_Change(ByRef Sender As TextBox)
	'Debug.Print Sender.Name
	If getStatus Then Exit Sub
	tmrSetStatus.Enabled = False
	tmrSetStatus.Enabled = True
End Sub

Private Sub frmSerialPortType.CommandButton_Click(ByRef Sender As Control)
	Select Case Sender.Text
	Case "Refresh"
		CommandButton1.Enabled = False
		CommandButton2.Enabled = False
		cbePortName.Clear
		Dim i As Integer
		For i = 0 To ncom.Enumerate()
			cbePortName.AddItem ncom.Name(i)
		Next
		If cbePortName.ItemCount > 0 Then
			cbePortName.ItemIndex = 0
			CommandButton2.Enabled = True
		End If
		CommandButton1.Enabled = True
	Case "Open"
		If ncom.Open(cbePortName.ItemIndex, @This) Then
			PortOpen(True)
			Sender.Text = "Close"
			TimerComponent_Timer(tmrSetStatus)
		End If
	Case "Close"
		ncom.Close()
		PortOpen(False)
		Sender.Text = "Open"
	Case "Clear"
		txtRec.Clear
	Case "Send"
		'ncom.Write(@txtSend.Text, Len(txtSend.Text))
		
		Dim i As Integer = -1
		Dim s As String = TextUnicode2Ansi(txtSend.Text,i)
		ncom.Write(StrPtr(s), Len(s))
	End Select
End Sub

Private Sub frmSerialPortType.GetComModemState()
	Dim st As DWORD
	If GetCommModemStatus(ncom.ComHandle, @st) Then
		chkCTS.Checked = st And MS_CTS_ON
		chkDSR.Checked = st And MS_DSR_ON
		chkRING.Checked = st And MS_RING_ON
		chkRLSD.Checked = st And MS_RLSD_ON
	End If
End Sub

Private Sub frmSerialPortType.GetComState()
	If ncom.ComHandle= NULL Then Exit Sub
	
	Dim d As DCB
	d.DCBlength = SizeOf(DCB)
	GetCommState(ncom.ComHandle, @d)
	Dim i As Integer
	
	i = cbeBaudRate.IndexOf("" & d.BaudRate)
	cbeBaudRate.ItemIndex = i
	If i < 0 Then
		cbeBaudRate.Text = "" & d.BaudRate
	End If
	cbeByteSize.ItemIndex = d.ByteSize - 5
	cbeStopBits.ItemIndex = d.StopBits
	cbeParity.ItemIndex = d.Parity
	cbefDtrControl.ItemIndex = d.fDtrControl
	cbefRtsControl.ItemIndex = d.fRtsControl
	
	chkfBinary.Checked = d.fBinary
	chkfParity.Checked = d.fParity
	chkfOutxCtsFlow.Checked = d.fOutxCtsFlow
	chkfOutxDsrFlow.Checked = d.fOutxDsrFlow
	chkfDsrSensitivity.Checked = d.fDsrSensitivity
	chkfTXContinueOnXoff.Checked = d.fTXContinueOnXoff
	chkfOutX.Checked = d.fOutX
	chkfInX.Checked = d.fInX
	chkfErrorChar.Checked = d.fErrorChar
	chkfNull.Checked = d.fNull
	
	txtfDummy2.Text = "" & d.fDummy2
	txtwReserved.Text = "" & d.wReserved
	txtXonLim.Text = "" & d.XonLim
	txtXoffLim.Text = "" & d.XoffLim
	txtXonChar.Text = "" & d.XonChar
	txtXoffChar.Text = "" & d.XoffChar
	txtErrorChar.Text = "" & d.ErrorChar
	txtEofChar.Text = "" & d.EofChar
	txtEvtChar.Text = "" & d.EvtChar
	txtwReserved1.Text = "" & d.wReserved1
End Sub

Private Sub frmSerialPortType.SetComState()
	If ncom.ComHandle= NULL Then Exit Sub
	
	Dim d As DCB
	d.DCBlength = SizeOf(DCB)
	GetCommState(ncom.ComHandle, @d)
	
	If cbeBaudRate.ItemIndex<0 Then
		d.BaudRate = CULng(cbeBaudRate.Text)
	Else
		d.BaudRate = CULng(cbeBaudRate.Item(cbeBaudRate.ItemIndex))
	End If
	d.ByteSize = cbeByteSize.ItemIndex + 5
	d.StopBits = cbeStopBits.ItemIndex
	d.Parity = cbeParity.ItemIndex
	d.fDtrControl = cbefDtrControl.ItemIndex
	d.fRtsControl = cbefRtsControl.ItemIndex
	
	d.fBinary = chkfBinary.Checked
	d.fParity = chkfParity.Checked
	d.fOutxCtsFlow = chkfOutxCtsFlow.Checked
	d.fOutxDsrFlow = chkfOutxDsrFlow.Checked
	d.fDsrSensitivity = chkfDsrSensitivity.Checked
	d.fTXContinueOnXoff = chkfTXContinueOnXoff.Checked
	d.fOutX = chkfOutX.Checked
	d.fInX = chkfInX.Checked
	d.fErrorChar = chkfErrorChar.Checked
	d.fNull = chkfNull.Checked
	
	d.fDummy2 = CLng(txtfDummy2.Text)
	d.wReserved = CLng(txtwReserved.Text)
	d.XonLim = CLng(txtXonLim.Text)
	d.XoffLim = CLng(txtXoffLim.Text)
	d.XonChar = CLng(txtXonChar.Text)
	d.XoffChar = CLng(txtXoffChar.Text)
	d.ErrorChar = CLng(txtErrorChar.Text)
	d.EofChar = CLng(txtEofChar.Text)
	d.EvtChar = CLng(txtEvtChar.Text)
	d.wReserved1 = CLng(txtwReserved1.Text)
	
	SetCommState(ncom.ComHandle, @d)
End Sub

Private Sub frmSerialPortType.Form_Create(ByRef Sender As Control)
	PortOpen(False)
	ncom.OndDtaArrive= Cast(Any Ptr, @DataArrive)
End Sub

Private Sub frmSerialPortType.PortOpen(e As Boolean)
	Dim ne As Boolean = Not e
	CommandButton1.Enabled = ne
	cbePortName.Enabled = ne
	cbeBaudRate.Enabled = e
	cbeByteSize.Enabled = e
	cbeStopBits.Enabled = e
	cbeParity.Enabled = e
	cbefDtrControl.Enabled = e
	cbefRtsControl.Enabled = e
	
	chkfBinary.Enabled = e
	chkfParity.Enabled = e
	chkfOutxCtsFlow.Enabled = e
	chkfOutxDsrFlow.Enabled = e
	chkfDsrSensitivity.Enabled = e
	chkfTXContinueOnXoff.Enabled = e
	chkfOutX.Enabled = e
	chkfInX.Enabled = e
	chkfErrorChar.Enabled = e
	chkfNull.Enabled = e
	chkfAbortOnError.Enabled = e
	
	chkCTS.Enabled = e
	chkDSR.Enabled = e
	chkRING.Enabled = e
	chkRLSD.Enabled = e
	
	chkHexRec.Enabled = e
	chkHexSend.Enabled = e
	
	txtfDummy2.Enabled = e
	txtwReserved.Enabled = e
	txtXonLim.Enabled = e
	txtXoffLim.Enabled = e
	txtXonChar.Enabled = e
	txtXoffChar.Enabled = e
	txtErrorChar.Enabled = e
	txtEofChar.Enabled = e
	txtEvtChar.Enabled = e
	txtwReserved1.Enabled = e
	txtRec.Enabled = e
	txtSend.Enabled = e
	
	lblDTR.Enabled = e
	lblRTS.Enabled = e
	
	cmdClearRec.Enabled = e
	cmdSend.Enabled = e
	
	If e = False Then
		cbeBaudRate.ItemIndex = -1
		cbeByteSize.ItemIndex = -1
		cbeStopBits.ItemIndex = -1
		cbeParity.ItemIndex = -1
		cbefDtrControl.ItemIndex = -1
		cbefRtsControl.ItemIndex = -1
		
		chkfBinary.Checked = False
		chkfParity.Checked = False
		chkfOutxCtsFlow.Checked = False
		chkfOutxDsrFlow.Checked = False
		chkfDsrSensitivity.Checked = False
		chkfTXContinueOnXoff.Checked = False
		chkfOutX.Checked = False
		chkfInX.Checked = False
		chkfErrorChar.Checked = False
		chkfNull.Checked = False
		chkfAbortOnError.Checked = False
		
		txtfDummy2.Text = txtfDummy2.Name
		txtwReserved.Text = txtwReserved.Name
		txtXonLim.Text =txtXonLim.Name
		txtXoffLim.Text =txtXoffLim.Name
		txtXonChar.Text =txtXonChar.Name
		txtXoffChar.Text =txtXoffChar.Name
		txtErrorChar.Text =txtErrorChar.Name
		txtEofChar.Text =txtEofChar.Name
		txtEvtChar.Text =txtEvtChar.Name
		txtwReserved1.Text = txtwReserved1.Name
	End If
End Sub

Private Sub frmSerialPortType.TimerComponent_Timer(ByRef Sender As TimerComponent)
	'Debug.Print Sender.Name
	Sender.Enabled = False
	
	Select Case Sender.Name
	Case "tmrSetStatus"
		SetComState
		If tmrGetStatus.Enabled = False Then tmrGetStatus.Enabled = True
	Case "tmrGetStatus"
		getStatus = True
		GetComState
		GetComModemState
		getStatus=False
	End Select
End Sub

Private Sub frmSerialPortType.DataArrive(Owner As Any Ptr, ArriveData As ZString Ptr, DataLength As Integer)
	Dim a As frmSerialPortType Ptr = Owner
	Dim c As String
	c = a->txtRec.Text + *ArriveData
	a->txtRec.Text = c
	a->txtRec.SelStart = Len(a->txtRec.Text)
	SendMessage(a->txtRec.Handle, EM_SCROLLCARET, 0, 0)
End Sub
