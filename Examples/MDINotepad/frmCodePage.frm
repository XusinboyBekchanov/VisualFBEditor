﻿' MDINotepad frmCodePage.frm
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDINotepad.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/ListControl.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/Dialogs.bi"
	#include once "mff/Splitter.bi"
	#include once "mff/StatusBar.bi"
	
	Using My.Sys.Forms
	
	Type frmCodePageType Extends Form
		ShowMode As Integer = 0
		CodePage As Integer = -1
		'https://docs.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
		
		Const CodePageCount As Long = 152
		CodePageNum(CodePageCount) As Integer => { _
		37, _
		437, _
		500, _
		708, _
		709, _
		710, _
		720, _
		737, _
		775, _
		850, _
		852, _
		855, _
		857, _
		858, _
		860, _
		861, _
		862, _
		863, _
		864, _
		865, _
		866, _
		869, _
		870, _
		874, _
		875, _
		932, _
		936, _
		949, _
		950, _
		1026, _
		1047, _
		1140, _
		1141, _
		1142, _
		1143, _
		1144, _
		1145, _
		1146, _
		1147, _
		1148, _
		1149, _
		1200, _
		1201, _
		1250, _
		1251, _
		1252, _
		1253, _
		1254, _
		1255, _
		1256, _
		1257, _
		1258, _
		1361, _
		10000, _
		10001, _
		10002, _
		10003, _
		10004, _
		10005, _
		10006, _
		10007, _
		10008, _
		10010, _
		10017, _
		10021, _
		10029, _
		10079, _
		10081, _
		10082, _
		12000, _
		12001, _
		20000, _
		20001, _
		20002, _
		20003, _
		20004, _
		20005, _
		20105, _
		20106, _
		20107, _
		20108, _
		20127, _
		20261, _
		20269, _
		20273, _
		20277, _
		20278, _
		20280, _
		20284, _
		20285, _
		20290, _
		20297, _
		20420, _
		20423, _
		20424, _
		20833, _
		20838, _
		20866, _
		20871, _
		20880, _
		20905, _
		20924, _
		20932, _
		20936, _
		20949, _
		21025, _
		21027, _
		21866, _
		28591, _
		28592, _
		28593, _
		28594, _
		28595, _
		28596, _
		28597, _
		28598, _
		28599, _
		28603, _
		28605, _
		29001, _
		38598, _
		50220, _
		50221, _
		50222, _
		50225, _
		50227, _
		50229, _
		50930, _
		50931, _
		50933, _
		50935, _
		50936, _
		50937, _
		50939, _
		51932, _
		51936, _
		51949, _
		51950, _
		52936, _
		54936, _
		57002, _
		57003, _
		57004, _
		57005, _
		57006, _
		57007, _
		57008, _
		57009, _
		57010, _
		57011, _
		65000, _
		65001}
		
		CodePageStr(CodePageCount) As String = { _
		"037 - IBM037 - IBM EBCDIC US-Canada", _
		"437 - IBM437 - OEM United States", _
		"500 - IBM500 - IBM EBCDIC International", _
		"708 - ASMO-708 - Arabic (ASMO 708)", _
		"709 -  - Arabic (ASMO-449+, BCON V4)", _
		"710 -  - Arabic - Transparent Arabic", _
		"720 - DOS-720 - Arabic (Transparent ASMO); Arabic (DOS)", _
		"737 - ibm737 - OEM Greek (formerly 437G); Greek (DOS)", _
		"775 - ibm775 - OEM Baltic; Baltic (DOS)", _
		"850 - ibm850 - OEM Multilingual Latin 1; Western European (DOS)", _
		"852 - ibm852 - OEM Latin 2; Central European (DOS)", _
		"855 - IBM855 - OEM Cyrillic (primarily Russian)", _
		"857 - ibm857 - OEM Turkish; Turkish (DOS)", _
		"858 - IBM00858 - OEM Multilingual Latin 1 + Euro symbol", _
		"860 - IBM860 - OEM Portuguese; Portuguese (DOS)", _
		"861 - ibm861 - OEM Icelandic; Icelandic (DOS)", _
		"862 - DOS-862 - OEM Hebrew; Hebrew (DOS)", _
		"863 - IBM863 - OEM French Canadian; French Canadian (DOS)", _
		"864 - IBM864 - OEM Arabic; Arabic (864)", _
		"865 - IBM865 - OEM Nordic; Nordic (DOS)", _
		"866 - cp866 - OEM Russian; Cyrillic (DOS)", _
		"869 - ibm869 - OEM Modern Greek; Greek, Modern (DOS)", _
		"870 - IBM870 - IBM EBCDIC Multilingual/ROECE (Latin 2); IBM EBCDIC Multilingual Latin 2", _
		"874 - windows-874 - Thai (Windows)", _
		"875 - cp875 - IBM EBCDIC Greek Modern", _
		"932 - shift_jis - ANSI/OEM Japanese; Japanese (Shift-JIS)", _
		"936 - gb2312 - ANSI/OEM Simplified Chinese (PRC, Singapore); Chinese Simplified (GB2312)", _
		"949 - ks_c_5601-1987 - ANSI/OEM Korean (Unified Hangul Code)", _
		"950 - big5 - ANSI/OEM Traditional Chinese (Taiwan; Hong Kong SAR, PRC); Chinese Traditional (Big5)", _
		"1026 - IBM1026 - IBM EBCDIC Turkish (Latin 5)", _
		"1047 - IBM01047 - IBM EBCDIC Latin 1/Open System", _
		"1140 - IBM01140 - IBM EBCDIC US-Canada (037 + Euro symbol); IBM EBCDIC (US-Canada-Euro)", _
		"1141 - IBM01141 - IBM EBCDIC Germany (20273 + Euro symbol); IBM EBCDIC (Germany-Euro)", _
		"1142 - IBM01142 - IBM EBCDIC Denmark-Norway (20277 + Euro symbol); IBM EBCDIC (Denmark-Norway-Euro)", _
		"1143 - IBM01143 - IBM EBCDIC Finland-Sweden (20278 + Euro symbol); IBM EBCDIC (Finland-Sweden-Euro)", _
		"1144 - IBM01144 - IBM EBCDIC Italy (20280 + Euro symbol); IBM EBCDIC (Italy-Euro)", _
		"1145 - IBM01145 - IBM EBCDIC Latin America-Spain (20284 + Euro symbol); IBM EBCDIC (Spain-Euro)", _
		"1146 - IBM01146 - IBM EBCDIC United Kingdom (20285 + Euro symbol); IBM EBCDIC (UK-Euro)", _
		"1147 - IBM01147 - IBM EBCDIC France (20297 + Euro symbol); IBM EBCDIC (France-Euro)", _
		"1148 - IBM01148 - IBM EBCDIC International (500 + Euro symbol); IBM EBCDIC (International-Euro)", _
		"1149 - IBM01149 - IBM EBCDIC Icelandic (20871 + Euro symbol); IBM EBCDIC (Icelandic-Euro)", _
		"1200 - utf-16 - Unicode UTF-16, little endian byte order (BMP of ISO 10646); available only to managed applications", _
		"1201 - unicodeFFFE - Unicode UTF-16, big endian byte order; available only to managed applications", _
		"1250 - windows-1250 - ANSI Central European; Central European (Windows)", _
		"1251 - windows-1251 - ANSI Cyrillic; Cyrillic (Windows)", _
		"1252 - windows-1252 - ANSI Latin 1; Western European (Windows)", _
		"1253 - windows-1253 - ANSI Greek; Greek (Windows)", _
		"1254 - windows-1254 - ANSI Turkish; Turkish (Windows)", _
		"1255 - windows-1255 - ANSI Hebrew; Hebrew (Windows)", _
		"1256 - windows-1256 - ANSI Arabic; Arabic (Windows)", _
		"1257 - windows-1257 - ANSI Baltic; Baltic (Windows)", _
		"1258 - windows-1258 - ANSI/OEM Vietnamese; Vietnamese (Windows)", _
		"1361 - Johab - Korean (Johab)", _
		"10000 - macintosh - MAC Roman; Western European (Mac)", _
		"10001 - x-mac-japanese - Japanese (Mac)", _
		"10002 - x-mac-chinesetrad - MAC Traditional Chinese (Big5); Chinese Traditional (Mac)", _
		"10003 - x-mac-korean - Korean (Mac)", _
		"10004 - x-mac-arabic - Arabic (Mac)", _
		"10005 - x-mac-hebrew - Hebrew (Mac)", _
		"10006 - x-mac-greek - Greek (Mac)", _
		"10007 - x-mac-cyrillic - Cyrillic (Mac)", _
		"10008 - x-mac-chinesesimp - MAC Simplified Chinese (GB 2312); Chinese Simplified (Mac)", _
		"10010 - x-mac-romanian - Romanian (Mac)", _
		"10017 - x-mac-ukrainian - Ukrainian (Mac)", _
		"10021 - x-mac-thai - Thai (Mac)", _
		"10029 - x-mac-ce - MAC Latin 2; Central European (Mac)", _
		"10079 - x-mac-icelandic - Icelandic (Mac)", _
		"10081 - x-mac-turkish - Turkish (Mac)", _
		"10082 - x-mac-croatian - Croatian (Mac)", _
		"12000 - utf-32 - Unicode UTF-32, little endian byte order; available only to managed applications", _
		"12001 - utf-32BE - Unicode UTF-32, big endian byte order; available only to managed applications", _
		"20000 - x-Chinese_CNS - CNS Taiwan; Chinese Traditional (CNS)", _
		"20001 - x-cp20001 - TCA Taiwan", _
		"20002 - x_Chinese-Eten - Eten Taiwan; Chinese Traditional (Eten)", _
		"20003 - x-cp20003 - IBM5550 Taiwan", _
		"20004 - x-cp20004 - TeleText Taiwan", _
		"20005 - x-cp20005 - Wang Taiwan", _
		"20105 - x-IA5 - IA5 (IRV International Alphabet No. 5, 7-bit); Western European (IA5)", _
		"20106 - x-IA5-German - IA5 German (7-bit)", _
		"20107 - x-IA5-Swedish - IA5 Swedish (7-bit)", _
		"20108 - x-IA5-Norwegian - IA5 Norwegian (7-bit)", _
		"20127 - us-ascii - US-ASCII (7-bit)", _
		"20261 - x-cp20261 - T.61", _
		"20269 - x-cp20269 - ISO 6937 Non-Spacing Accent", _
		"20273 - IBM273 - IBM EBCDIC Germany", _
		"20277 - IBM277 - IBM EBCDIC Denmark-Norway", _
		"20278 - IBM278 - IBM EBCDIC Finland-Sweden", _
		"20280 - IBM280 - IBM EBCDIC Italy", _
		"20284 - IBM284 - IBM EBCDIC Latin America-Spain", _
		"20285 - IBM285 - IBM EBCDIC United Kingdom", _
		"20290 - IBM290 - IBM EBCDIC Japanese Katakana Extended", _
		"20297 - IBM297 - IBM EBCDIC France", _
		"20420 - IBM420 - IBM EBCDIC Arabic", _
		"20423 - IBM423 - IBM EBCDIC Greek", _
		"20424 - IBM424 - IBM EBCDIC Hebrew", _
		"20833 - x-EBCDIC-KoreanExtended - IBM EBCDIC Korean Extended", _
		"20838 - IBM-Thai - IBM EBCDIC Thai", _
		"20866 - koi8-r - Russian (KOI8-R); Cyrillic (KOI8-R)", _
		"20871 - IBM871 - IBM EBCDIC Icelandic", _
		"20880 - IBM880 - IBM EBCDIC Cyrillic Russian", _
		"20905 - IBM905 - IBM EBCDIC Turkish", _
		"20924 - IBM00924 - IBM EBCDIC Latin 1/Open System (1047 + Euro symbol)", _
		"20932 - EUC-JP - Japanese (JIS 0208-1990 and 0212-1990)", _
		"20936 - x-cp20936 - Simplified Chinese (GB2312); Chinese Simplified (GB2312-80)", _
		"20949 - x-cp20949 - Korean Wansung", _
		"21025 - cp1025 - IBM EBCDIC Cyrillic Serbian-Bulgarian", _
		"21027 -  - (deprecated)", _
		"21866 - koi8-u - Ukrainian (KOI8-U); Cyrillic (KOI8-U)", _
		"28591 - iso-8859-1 - ISO 8859-1 Latin 1; Western European (ISO)", _
		"28592 - iso-8859-2 - ISO 8859-2 Central European; Central European (ISO)", _
		"28593 - iso-8859-3 - ISO 8859-3 Latin 3", _
		"28594 - iso-8859-4 - ISO 8859-4 Baltic", _
		"28595 - iso-8859-5 - ISO 8859-5 Cyrillic", _
		"28596 - iso-8859-6 - ISO 8859-6 Arabic", _
		"28597 - iso-8859-7 - ISO 8859-7 Greek", _
		"28598 - iso-8859-8 - ISO 8859-8 Hebrew; Hebrew (ISO-Visual)", _
		"28599 - iso-8859-9 - ISO 8859-9 Turkish", _
		"28603 - iso-8859-13 - ISO 8859-13 Estonian", _
		"28605 - iso-8859-15 - ISO 8859-15 Latin 9", _
		"29001 - x-Europa - Europa 3", _
		"38598 - iso-8859-8-i - ISO 8859-8 Hebrew; Hebrew (ISO-Logical)", _
		"50220 - iso-2022-jp - ISO 2022 Japanese with no halfwidth Katakana; Japanese (JIS)", _
		"50221 - csISO2022JP - ISO 2022 Japanese with halfwidth Katakana; Japanese (JIS-Allow 1 byte Kana)", _
		"50222 - iso-2022-jp - ISO 2022 Japanese JIS X 0201-1989; Japanese (JIS-Allow 1 byte Kana - SO/SI)", _
		"50225 - iso-2022-kr - ISO 2022 Korean", _
		"50227 - x-cp50227 - ISO 2022 Simplified Chinese; Chinese Simplified (ISO 2022)", _
		"50229 -  - ISO 2022 Traditional Chinese", _
		"50930 -  - EBCDIC Japanese (Katakana) Extended", _
		"50931 -  - EBCDIC US-Canada and Japanese", _
		"50933 -  - EBCDIC Korean Extended and Korean", _
		"50935 -  - EBCDIC Simplified Chinese Extended and Simplified Chinese", _
		"50936 -  - EBCDIC Simplified Chinese", _
		"50937 -  - EBCDIC US-Canada and Traditional Chinese", _
		"50939 -  - EBCDIC Japanese (Latin) Extended and Japanese", _
		"51932 - euc-jp - EUC Japanese", _
		"51936 - EUC-CN - EUC Simplified Chinese; Chinese Simplified (EUC)", _
		"51949 - euc-kr - EUC Korean", _
		"51950 -  - EUC Traditional Chinese", _
		"52936 - hz-gb-2312 - HZ-GB2312 Simplified Chinese; Chinese Simplified (HZ)", _
		"54936 - GB18030 - Windows XP and later: GB18030 Simplified Chinese (4 byte); Chinese Simplified (GB18030)", _
		"57002 - x-iscii-de - ISCII Devanagari", _
		"57003 - x-iscii-be - ISCII Bangla", _
		"57004 - x-iscii-ta - ISCII Tamil", _
		"57005 - x-iscii-te - ISCII Telugu", _
		"57006 - x-iscii-as - ISCII Assamese", _
		"57007 - x-iscii-or - ISCII Odia", _
		"57008 - x-iscii-ka - ISCII Kannada", _
		"57009 - x-iscii-ma - ISCII Malayalam", _
		"57010 - x-iscii-gu - ISCII Gujarati", _
		"57011 - x-iscii-pa - ISCII Punjabi", _
		"65000 - utf-7 - Unicode (UTF-7)", _
		"65001 - utf-8 - Unicode (UTF-8)" }
		
		Declare Sub SetMode(ModeNo As Integer)
		Declare Sub SetCodePage(CP As Integer)
		
		Declare Sub chkPreview_Click(ByRef Sender As CheckBox)
		Declare Sub chkSystemCP_Click(ByRef Sender As CheckBox)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Sub cobEncod_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub lstCodePage_Click(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Constructor
		
		Dim As ListControl lstCodePage
		Dim As CheckBox chkPreview, chkSystemCP
		Dim As TextBox txtPreview, txtPreviewSize
		Dim As ComboBoxEdit cobEncod
		Dim As CommandButton cmdOK, cmdSelect
		Dim As OpenFileDialog OpenFileDialog1
		Dim As Panel Panel1, Panel2
		Dim As Splitter Splitter1
		Dim As StatusBar StatusBar1
		Dim As StatusPanel spCodePage, spFileName
	End Type
	
	Constructor frmCodePageType
		' frmCodePage
		With This
			.Name = "frmCodePage"
			.Text = "Select Code Page"
			.Designer = @This
			.Caption = "Select Code Page"
			.BorderStyle = FormBorderStyle.Sizable
			.MaximizeBox = True
			.MinimizeBox = False
			.StartPosition = FormStartPosition.CenterParent
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Show)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.SetBounds 0, 0, 660, 460
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 9
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 654, 40
			.Designer = @This
			.Parent = @This
		End With
		' cobEncod
		With cobEncod
			.Name = "cobEncod"
			.Text = "ComboBoxEdit1"
			.TabIndex = 0
			.SetBounds 10, 10, 150, 21
			.Designer = @This
			.OnSelected = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit, ItemIndex As Integer), @cobEncod_Selected)
			.Parent = @Panel1
			.AddItem("Plain Text")
			.AddItem("Utf8")
			.AddItem("Utf8 (BOM)")
			.AddItem("Utf16 (BOM)")
			.AddItem("Utf32 (BOM)")
			.ItemIndex = 0
		End With
		' chkSystemCP
		With chkSystemCP
			.Name = "chkSystemCP"
			.Text = "System"
			.TabIndex = 1
			.ControlIndex = 0
			.Caption = "System"
			.Checked = True
			.SetBounds 174, 10, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @chkSystemCP_Click)
			.Parent = @Panel1
		End With
		' chkPreview
		With chkPreview
			.Name = "chkPreview"
			.Text = "Preview"
			.TabIndex = 2
			.Caption = "Preview"
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Top = 10
			.ExtraMargins.Bottom = 10
			.ControlIndex = 0
			.Checked = True
			.SetBounds 264, 10, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @chkPreview_Click)
			.Parent = @Panel1
		End With
		' txtPreviewSize
		With txtPreviewSize
			.Name = "txtPreviewSize"
			.Text = "1000"
			.TabIndex = 3
			.Hint = "Preview file size"
			.SetBounds 350, 10, 80, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' cmdSelect
		With cmdSelect
			.Name = "cmdSelect"
			.Text = "Select file"
			.TabIndex = 4
			.Caption = "Select file"
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 470, 10, 80, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdOK_Click)
			.Parent = @Panel1
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = "OK"
			.TabIndex = 5
			.Caption = "OK"
			.ControlIndex = 8
			.Default = True
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 554, 10, 80, 21
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdOK_Click)
			.Parent = @Panel1
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 10
			.Align = DockStyle.alTop
			.SetBounds 0, 40, 644, 190
			.Designer = @This
			.Parent = @This
		End With
		' lstCodePage
		With lstCodePage
			.Name = "lstCodePage"
			.Text = "ListControl1"
			.TabIndex = 6
			.Align = DockStyle.alClient
			Dim As Integer i
			For i = 0 To CodePageCount
				.AddItem(CodePageStr(i), Cast(Any Ptr, CodePageNum(i)))
			Next
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.SetBounds 10, 0, 624, 186
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @lstCodePage_Click)
			.Parent = @Panel2
		End With
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.Align = SplitterAlignmentConstants.alTop
			.SetBounds 0, 230, 644, 5
			.Designer = @This
			.Parent = @This
		End With
		' txtPreview
		With txtPreview
			.Name = "txtPreview"
			.Text = ""
			.TabIndex = 8
			.Align = DockStyle.alClient
			.Multiline = True
			.HideSelection = False
			.ScrollBars = ScrollBarsType.Both
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.SetBounds 10, 240, 624, 160
			.Designer = @This
			.Parent = @This
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.ExtraMargins.Top = 10
			.SetBounds 0, 399, 644, 22
			.Designer = @This
			.Parent = @This
		End With
		' spCodePage
		With spCodePage
			.Name = "spCodePage"
			.Designer = @This
			.Width = 200
			.Parent = @StatusBar1
		End With
		' spFileName
		With spFileName
			.Name = "spFileName"
			.Designer = @This
			.Parent = @StatusBar1
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.Filter = "All files(*.*)|*.*"
			.SetBounds 200, 20, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmCodePage As frmCodePageType
	
	#if _MAIN_FILE_ = __FILE__
		frmCodePage.MainForm = True
		frmCodePage.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmCodePageType.cmdOK_Click(ByRef Sender As Control)
	Select Case Sender.Name
	Case "cmdOK"
		ModalResult = ModalResults.OK
		CloseForm
	Case "cmdSelect"
		OpenFileDialog1.FileName = spFileName.Caption
		If OpenFileDialog1.Execute() Then
			spFileName.Caption = OpenFileDialog1.FileName
			chkSystemCP_Click(chkSystemCP)
		End If
	End Select
End Sub

Private Sub frmCodePageType.lstCodePage_Click(ByRef Sender As Control)
	CodePage = Cast(Integer, lstCodePage.ItemData(lstCodePage.ItemIndex))
	spCodePage.Caption = "Select Code Page: " & CodePage
	Caption = spCodePage.Caption
	chkPreview_Click(chkPreview)
End Sub

Private Sub frmCodePageType.cobEncod_Selected(ByRef Sender As ComboBoxEdit, ItemIndex As Integer)
	Dim As Boolean b = IIf(cobEncod.ItemIndex = 0, True, False)
	
	chkSystemCP.Enabled = b
	If b Then
		chkSystemCP_Click(chkSystemCP)
		lstCodePage_Click(lstCodePage)
	Else
		lstCodePage.Enabled = b
		spCodePage.Caption = "Select Encoding: " & cobEncod.Item(cobEncod.ItemIndex)
		Caption = spCodePage.Caption
	End If
	chkPreview_Click(chkPreview)
End Sub

Private Sub frmCodePageType.chkSystemCP_Click(ByRef Sender As CheckBox)
	If chkSystemCP.Checked Then
		SetCodePage(-1)
		lstCodePage.Enabled = False
	Else
		lstCodePage.Enabled = True
	End If
	chkPreview_Click(chkPreview)
End Sub

Private Sub frmCodePageType.Form_Show(ByRef Sender As Form)
	ModalResult = ModalResults.Cancel
	cmdSelect.Visible = False
	Select Case ShowMode
	Case 0
		chkPreview.Checked = True
		txtPreviewSize.Visible= True
	Case 1
		chkPreview.Checked = False
		chkPreview.Visible= False
		txtPreviewSize.Visible= False
	Case Else
		cmdSelect.Visible = True
		cmdOK.Caption = "Close"
	End Select
	SetCodePage(CodePage)
	chkPreview_Click(chkPreview)
End Sub

Private Sub frmCodePageType.chkPreview_Click(ByRef Sender As CheckBox)
	If Visible = False Or Handle = NULL Then Exit Sub
	
	If Splitter1.Visible <> chkPreview.Checked Then
		txtPreviewSize.Enabled = chkPreview.Checked
		txtPreview.Visible = chkPreview.Checked
		'StatusBar1.Visible = chkPreview.Checked
		Splitter1.Visible = chkPreview.Checked
		If chkPreview.Checked = False Then
			Form_Resize(This, 0, 0)
			Exit Sub
		Else
			Panel2.Height = Panel2.Height / 2
			Splitter1.Top = Panel2.Top + Panel2.Height
			StatusBar1.Top = ClientHeight - StatusBar1.Height
			txtPreview.Move txtPreview.Left, Splitter1.Top + Splitter1.Height, txtPreview.Width, ClientHeight - StatusBar1.Height - StatusBar1.ExtraMargins.Top - Splitter1.Top - Splitter1.Height
		End If
	End If
	
	Dim As NewLineTypes NewLine = -1
	Dim As FileEncodings Encode = cobEncod.ItemIndex
	Dim As WString Ptr p
	TextFromFile(spFileName.Caption, p, Encode, NewLine, CodePage, CLng(txtPreviewSize.Text))
	txtPreview.Text = *p
	If p Then Deallocate(p)
End Sub

Private Sub frmCodePageType.SetCodePage(CP As Integer)
	CodePage = IIf(CP < 0, GetACP(), CP)
	spCodePage.Caption = "Select Code Page: " & CodePage
	Caption = spCodePage.Caption
	Dim As Integer i
	For i = 0 To lstCodePage.ItemCount - 1
		If lstCodePage.ItemData(i) = CodePage Then
			lstCodePage.ItemIndex = i
			Exit For
		End If
	Next
End Sub

Private Sub frmCodePageType.Form_Destroy(ByRef Sender As Control)
	'Debug.Print "Form_Destroy"
	txtPreview.Text = ""
End Sub

Private Sub frmCodePageType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	If chkPreview.Checked Then Exit Sub
	Panel2.Height = ClientHeight - Panel2.Top - StatusBar1.Height - StatusBar1.ExtraMargins.Top
End Sub

Private Function SelectCodePage(ByRef sFileName As WString, ByRef sEncode As FileEncodings = -1, ByRef sCodePage As NewLineTypes = -1, ByVal sShowMode As Integer = 0) As Boolean
	Dim As Boolean rtn
	Dim As frmCodePageType Ptr frmCodePage
	If frmCodePage = NULL Then frmCodePage = New frmCodePageType
	frmCodePage->ShowMode = sShowMode
	frmCodePage->cobEncod.ItemIndex = 0
	frmCodePage->cobEncod_Selected(frmCodePage->cobEncod, 0)
	frmCodePage->chkSystemCP_Click(frmCodePage->chkSystemCP)
	frmCodePage->SetCodePage(-1)
	frmCodePage->spFileName.Caption = sFileName
	
	frmCodePage->ShowModal(MDIMain)
	If frmCodePage->ModalResult = ModalResults.OK Then
		sEncode = frmCodePage->cobEncod.ItemIndex
		sCodePage = Cast(Integer, frmCodePage->lstCodePage.ItemData(frmCodePage->lstCodePage.ItemIndex))
		rtn = True
	End If
	
	Delete frmCodePage
	frmCodePage = NULL
	Return rtn
End Function
