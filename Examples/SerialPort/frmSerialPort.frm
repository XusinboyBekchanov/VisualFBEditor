' frmSerialPort
' Copyright (c) 2022 CM.Wang
' Freeware. Use at your own risk.

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
		
		Declare Sub ComboBoxEdit_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub CommandButton_Click(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub CheckBox_Click(ByRef Sender As CheckBox)
		Declare Sub TextBox_Change(ByRef Sender As TextBox)
		Declare Sub TimerComponent_Timer(ByRef Sender As TimerComponent)
		Declare Sub chkDark_Click(ByRef Sender As CheckBox)
		Declare Constructor
		
		Dim As Panel Panel1, Panel4, Panel5, Panel6, Panel7
		Dim As CommandButton CommandButton1, CommandButton2, cmdSend, cmdClearRec
		Dim As ComboBoxEdit cbePortName, cbeBaudRate, cbeByteSize, cbeStopBits, cbeParity, cbefDtrControl, cbefRtsControl
		Dim As CheckBox chkfBinary, chkfParity, chkfOutxCtsFlow, chkfOutxDsrFlow, chkfDsrSensitivity, chkfTXContinueOnXoff, chkfOutX, chkfInX, chkfErrorChar, chkfNull, chkfAbortOnError, chkCTS, chkDSR, chkRING, chkRLSD, chkHexRec, chkHexSend, chkDark
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
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "\SerialPort.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif

			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
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
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "Refresh"
			.TabIndex = 1
			.Caption = "Refresh"
			.SetBounds 10, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' CommandButton2
		With CommandButton2
			.Name = "CommandButton2"
			.Text = "Open"
			.TabIndex = 2
			.Caption = "Open"
			.Enabled = False
			.SetBounds 90, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel1
		End With
		' cbePortName
		With cbePortName
			.Name = "cbePortName"
			.Text = "cbePortName"
			.TabIndex = 3
			.Hint = "Serial Port List"
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 10, 50, 150, 21
			.Designer = @This
			.Parent = @Panel1
		End With
		' cbeBaudRate
		With cbeBaudRate
			.Name = "cbeBaudRate"
			.Text = "cbeBaudRate"
			.TabIndex = 4
			.Hint = "Baud Rate"
			.Style = ComboBoxEditStyle.cbDropDown
			.SetBounds 10, 80, 70, 21
			.Designer = @This
			.Parent = @Panel1
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
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
		End With
		' cbeByteSize
		With cbeByteSize
			.Name = "cbeByteSize"
			.Text = "cbeByteSize"
			.TabIndex = 5
			.Hint = "Byte Size: The number of bits in the bytes transmitted and received."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 80, 70, 21
			.Designer = @This
			.Parent = @Panel1
			.AddItem "5"
			.AddItem "6"
			.AddItem "7"
			.AddItem "8"
			.ItemData(0) = Cast(Any Ptr, 0)
			.ItemData(1) = Cast(Any Ptr, 1)
			.ItemData(2) = Cast(Any Ptr, 2)
			.ItemData(3) = Cast(Any Ptr, 3)
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
		End With
		' cbeStopBits
		With cbeStopBits
			.Name = "cbeStopBits"
			.Text = "cbeStopBits"
			.TabIndex = 6
			.Hint = "Stop Bits: The number of stop bits to be used. This member can be one of the following values."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 10, 110, 70, 21
			.Designer = @This
			.Parent = @Panel1
			.AddItem "1"
			.AddItem "1.5"
			.AddItem "2"
			.ItemData(0) = Cast(Any Ptr, &h1)
			.ItemData(1) = Cast(Any Ptr, &h2)
			.ItemData(2) = Cast(Any Ptr, &h4)
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
		End With
		' cbeParity
		With cbeParity
			.Name = "cbeParity"
			.Text = "cbeParity"
			.TabIndex = 7
			.Hint = "Parity: The parity scheme to be used. This member can be one of the following values."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 110, 70, 21
			.Designer = @This
			.Parent = @Panel1
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
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
		End With
		' lblDTR
		With lblDTR
			.Name = "lblDTR"
			.Text = "Pin(4) DTR"
			.TabIndex = 8
			.Caption = "Pin(4) DTR"
			.Hint = "fDtrControl: The DTR (data-terminal-ready) flow control. This member can be one of the following values."
			.ForeColor = 255
			.SetBounds 10, 153, 70, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' cbefDtrControl
		With cbefDtrControl
			.Name = "cbefDtrControl"
			.Text = "fDtrControl"
			.TabIndex = 9
			.Hint = "fDtrControl: The DTR (data-terminal-ready) flow control. This member can be one of the following values."
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 150, 70, 21
			.Designer = @This
			.Parent = @Panel1
			.AddItem("Disable")
			.AddItem("Enable")
			.AddItem("Hand Shake")
			.AddItem("Unuse")
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
		End With
		' lblRTS
		With lblRTS
			.Name = "lblRTS"
			.Text = "Pin(7) RTS"
			.TabIndex = 10
			.Caption = "Pin(7) RTS"
			.Hint = "fRtsControl: The RTS (request-to-send) flow control. This member can be one of the following values."
			.ForeColor = 255
			.SetBounds 10, 183, 70, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' cbefRtsControl
		With cbefRtsControl
			.Name = "cbefRtsControl"
			.Text = "fRtsControl"
			.TabIndex = 11
			.Hint = "fRtsControl: The RTS (request-to-send) flow control. This member can be one of the following values."
			.ForeColor = 0
			.Style = ComboBoxEditStyle.cbDropDownList
			.SetBounds 90, 180, 70, 21
			.Designer = @This
			.Parent = @Panel1
			.AddItem("Disable")
			.AddItem("Enable")
			.AddItem("Hand Shake")
			.AddItem("Toggle")
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @ComboBoxEdit_Selected)
		End With
		' chkfBinary
		With chkfBinary
			.Name = "chkfBinary"
			.Text = "fBinary"
			.TabIndex = 12
			.Hint = "If this member is TRUE, binary mode is enabled. Windows does not support nonbinary mode transfers, so this member must be TRUE."
			.Caption = "fBinary"
			.SetBounds 10, 210, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfParity
		With chkfParity
			.Name = "chkfParity"
			.Text = "fParity"
			.TabIndex = 13
			.Caption = "fParity"
			.Hint = "If this member is TRUE, parity checking is performed and errors are reported."
			.SetBounds 10, 230, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfOutxCtsFlow
		With chkfOutxCtsFlow
			.Name = "chkfOutxCtsFlow"
			.Text = "fOutxCtsFlow"
			.TabIndex = 14
			.Caption = "fOutxCtsFlow"
			.Hint = "If this member is TRUE, the CTS (clear-to-send) signal is monitored for output flow control. If this member is TRUE and CTS is turned off, output is suspended until CTS is sent again."
			.ForeColor = 0
			.SetBounds 10, 250, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfOutxDsrFlow
		With chkfOutxDsrFlow
			.Name = "chkfOutxDsrFlow"
			.Text = "fOutxDsrFlow"
			.TabIndex = 15
			.Caption = "fOutxDsrFlow"
			.Hint = "If this member is TRUE, the DSR (data-set-ready) signal is monitored for output flow control. If this member is TRUE and DSR is turned off, output is suspended until DSR is sent again."
			.ForeColor = 0
			.SetBounds 10, 270, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfDsrSensitivity
		With chkfDsrSensitivity
			.Name = "chkfDsrSensitivity"
			.Text = "fDsrSensitivity"
			.TabIndex = 16
			.Caption = "fDsrSensitivity"
			.Hint = "If this member is TRUE, the communications driver is sensitive to the state of the DSR signal. The driver ignores any bytes received, unless the DSR modem input line is high."
			.SetBounds 10, 290, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfTXContinueOnXoff
		With chkfTXContinueOnXoff
			.Name = "chkfTXContinueOnXoff"
			.Text = "fTXContinueOnXoff"
			.TabIndex = 17
			.Caption = "fTXContinueOnXoff"
			.Hint = "If this member is TRUE, transmission continues after the input buffer has come within XoffLim bytes of being full and the driver has transmitted the XoffChar character to stop receiving bytes. If this member is FALSE, transmission does not continue until the input buffer is within XonLim bytes of being empty and the driver has transmitted the XonChar character to resume reception."
			.SetBounds 10, 310, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfOutX
		With chkfOutX
			.Name = "chkfOutX"
			.Text = "fOutX"
			.TabIndex = 18
			.Caption = "fOutX"
			.Hint = "Indicates whether XON/XOFF flow control is used during transmission. If this member is TRUE, transmission stops when the XoffChar character is received and starts again when the XonChar character is received."
			.SetBounds 10, 330, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfInX
		With chkfInX
			.Name = "chkfInX"
			.Text = "fInX"
			.TabIndex = 19
			.Caption = "fInX"
			.Hint = "Indicates whether XON/XOFF flow control is used during reception. If this member is TRUE, the XoffChar character is sent when the input buffer comes within XoffLim bytes of being full, and the XonChar character is sent when the input buffer comes within XonLim bytes of being empty."
			.SetBounds 10, 350, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfErrorChar
		With chkfErrorChar
			.Name = "chkfErrorChar"
			.Text = "fErrorChar"
			.TabIndex = 20
			.Caption = "fErrorChar"
			.Hint = "Indicates whether bytes received with parity errors are replaced with the character specified by the ErrorChar member. If this member is TRUE and the fParity member is TRUE, replacement occurs."
			.SetBounds 10, 370, 150, 16
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfNull
		With chkfNull
			.Name = "chkfNull"
			.Text = "fNull"
			.TabIndex = 21
			.Caption = "fNull"
			.Hint = "If this member is TRUE, null bytes are discarded when received."
			.SetBounds 10, 390, 150, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' chkfAbortOnError
		With chkfAbortOnError
			.Name = "chkfAbortOnError"
			.Text = "fAbortOnError"
			.TabIndex = 22
			.Caption = "fAbortOnError"
			.Hint = "If this member is TRUE, the driver terminates all read and write operations with an error status if an error occurs. The driver will not accept any further communications operations until the application has acknowledged the error by calling the ClearCommError function."
			.ControlIndex = 37
			.SetBounds 10, 410, 150, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox_Click)
			.Parent = @Panel1
		End With
		' txtfDummy2
		With txtfDummy2
			.Name = "txtfDummy2"
			.Text = "fDummy2"
			.TabIndex = 23
			.Hint = "fDummy2: Reserved; do not use."
			.SetBounds 10, 440, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtwReserved
		With txtwReserved
			.Name = "txtwReserved"
			.Text = "wReserved"
			.TabIndex = 24
			.Hint = "wReserved: Reserved; must be zero."
			.SetBounds 90, 440, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtXonLim
		With txtXonLim
			.Name = "txtXonLim"
			.Text = "XonLim"
			.TabIndex = 25
			.Hint = "XonLim: The minimum number of bytes in use allowed in the input buffer before flow control is activated to allow transmission by the sender. This assumes that either XON/XOFF, RTS, or DTR input flow control is specified in the fInX, fRtsControl, or fDtrControl members."
			.SetBounds 10, 460, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtXoffLim
		With txtXoffLim
			.Name = "txtXoffLim"
			.Text = "XoffLim"
			.TabIndex = 26
			.Hint = "XoffLim: The minimum number of free bytes allowed in the input buffer before flow control is activated to inhibit the sender. Note that the sender may transmit characters after the flow control signal has been activated, so this value should never be zero. This assumes that either XON/XOFF, RTS, or DTR input flow control is specified in the fInX, fRtsControl, or fDtrControl members. The maximum number of bytes in use allowed is calculated by subtracting this value from the size, in bytes, of the input buffer."
			.ControlIndex = 28
			.SetBounds 90, 460, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtXonChar
		With txtXonChar
			.Name = "txtXonChar"
			.Text = "XonChar"
			.TabIndex = 27
			.Hint = "XonChar: The value of the XON character for both transmission and reception."
			.SetBounds 10, 480, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtXoffChar
		With txtXoffChar
			.Name = "txtXoffChar"
			.Text = "XoffChar"
			.TabIndex = 28
			.Hint = "XoffChar: The value of the XOFF character for both transmission and reception."
			.SetBounds 90, 480, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtErrorChar
		With txtErrorChar
			.Name = "txtErrorChar"
			.Text = "ErrorChar"
			.TabIndex = 29
			.Hint = "ErrorChar: The value of the character used to replace bytes received with a parity error."
			.SetBounds 10, 500, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtEofChar
		With txtEofChar
			.Name = "txtEofChar"
			.Text = "EofChar"
			.TabIndex = 30
			.Hint = "EofChar: The value of the character used to signal the end of data."
			.SetBounds 90, 500, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtEvtChar
		With txtEvtChar
			.Name = "txtEvtChar"
			.Text = "EvtChar"
			.TabIndex = 31
			.Hint = "EvtChar: The value of the character used to signal an event."
			.SetBounds 10, 520, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' txtwReserved1
		With txtwReserved1
			.Name = "txtwReserved1"
			.Text = "wReserved1"
			.TabIndex = 32
			.Hint = "wReserved1: Reserved; do not use."
			.SetBounds 90, 520, 70, 20
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox_Change)
			.Parent = @Panel1
		End With
		' chkCTS
		With chkCTS
			.Name = "chkCTS"
			.Text = "Pin(8) CTS"
			.TabIndex = 33
			.Hint = "The CTS (clear-to-send) signal is on."
			.Caption = "Pin(8) CTS"
			.ForeColor = 32768
			.SetBounds 10, 550, 150, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' chkDSR
		With chkDSR
			.Name = "chkDSR"
			.Text = "Pin(6) DSR"
			.TabIndex = 34
			.Hint = "The DSR (data-set-ready) signal is on."
			.Caption = "Pin(6) DSR"
			.ForeColor = 32768
			.SetBounds 10, 570, 150, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' chkRING
		With chkRING
			.Name = "chkRING"
			.Text = "Pin(9) RING"
			.TabIndex = 35
			.Hint = "The ring indicator signal is on."
			.Caption = "Pin(9) RING"
			.ForeColor = 32768
			.SetBounds 10, 590, 150, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' chkRLSD
		With chkRLSD
			.Name = "chkRLSD"
			.Text = "Pin(1) RLSD"
			.TabIndex = 36
			.Hint = "The RLSD (receive-line-signal-detect) signal is on."
			.Caption = "Pin(1) RLSD"
			.ForeColor = 32768
			.SetBounds 10, 610, 150, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' Panel4
		With Panel4
			.Name = "Panel4"
			.Text = "Panel4"
			.TabIndex = 37
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
			.TabIndex = 38
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 624, 40
			.Designer = @This
			.Parent = @Panel4
		End With
		' Panel6
		With Panel6
			.Name = "Panel6"
			.Text = "Panel6"
			.TabIndex = 40
			.Align = DockStyle.alBottom
			.SetBounds 0, 551, 634, 140
			.Designer = @This
			.Parent = @Panel4
		End With
		' Panel7
		With Panel7
			.Name = "Panel7"
			.Text = "Panel7"
			.TabIndex = 41
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 624, 40
			.Designer = @This
			.Parent = @Panel6
		End With
		' chkHexRec
		With chkHexRec
			.Name = "chkHexRec"
			.Text = "Hex"
			.TabIndex = 42
			.Caption = "Hex"
			.Visible = False
			.SetBounds 0, 10, 70, 20
			.Designer = @This
			.Parent = @Panel5
		End With
		' cmdClearRec
		With cmdClearRec
			.Name = "cmdClearRec"
			.Text = "Clear"
			.TabIndex = 43
			.Caption = "Clear"
			.ControlIndex = 2
			.SetBounds 0, 9, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel5
		End With
		' txtRec
		With txtRec
			.Name = "txtRec"
			.Text = ""
			.TabIndex = 44
			.Align = DockStyle.alClient
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.HideSelection = False
			.SetBounds 0, 40, 624, 451
			.Designer = @This
			.Parent = @Panel4
		End With
		' chkHexSend
		With chkHexSend
			.Name = "chkHexSend"
			.Text = "Hex"
			.TabIndex = 45
			.Visible = False
			.SetBounds 0, 10, 70, 20
			.Designer = @This
			.Parent = @Panel7
		End With
		' cmdSend
		With cmdSend
			.Name = "cmdSend"
			.Text = "Send"
			.TabIndex = 46
			.Caption = "Send"
			.ControlIndex = 2
			.SetBounds 0, 9, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton_Click)
			.Parent = @Panel7
		End With
		' txtSend
		With txtSend
			.Name = "txtSend"
			.Text = ""
			.TabIndex = 47
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
		' chkDark
		With chkDark
			.Name = "chkDark"
			.Text = "Dark"
			.TabIndex = 48
			.Caption = "Dark"
			.Anchor.Right = AnchorStyle.asAnchorProportional
			.Checked = True
			.SetBounds 550, 10, 70, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkDark_Click)
			.Parent = @Panel5
		End With
		' tmrGetStatus
		With tmrGetStatus
			.Name = "tmrGetStatus"
			.Interval = 1000
			.SetBounds 120, 140, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent_Timer)
			.Parent = @Panel1
		End With
		' tmrSetStatus
		With tmrSetStatus
			.Name = "tmrSetStatus"
			.Interval = 100
			.SetBounds 140, 140, 16, 16
			.Designer = @This
			.OnTimer = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent), @TimerComponent_Timer)
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared frmSerialPort As frmSerialPortType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
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
		Dim i As Integer = -1
		Dim s As ZString Ptr
		TextToAnsi(txtSend.Text, s, i)
		ncom.Write(s, Len(*s))
		Deallocate(s)
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
		txtXonLim.Text = txtXonLim.Name
		txtXoffLim.Text = txtXoffLim.Name
		txtXonChar.Text = txtXonChar.Name
		txtXoffChar.Text = txtXoffChar.Name
		txtErrorChar.Text = txtErrorChar.Name
		txtEofChar.Text = txtEofChar.Name
		txtEvtChar.Text = txtEvtChar.Name
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

Private Sub frmSerialPortType.chkDark_Click(ByRef Sender As CheckBox)
	App.DarkMode = chkDark.Checked
	InvalidateRect(Handle, NULL, False)
End Sub
