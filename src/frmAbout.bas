'#########################################################
'#  frmAbout.bas                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "frmAbout.bi"

'#Region "Form"
	Constructor frmAbout
		On Error Goto ErrorHandler
		This.Name = "frmAbout"
		This.Text = ML("About")
		This.SetBounds 0, 0, 456, 418
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.MaximizeBox = False
		This.MinimizeBox = False
		#ifndef __USE_GTK__
			This.DefaultButton = @CommandButton1
			This.CancelButton = @CommandButton1
		#endif
		This.StartPosition = FormStartPosition.CenterScreen
		Label1.Name = "Label1"
		Label1.Text = "Visual FB Editor " & pApp->Version
		Label1.Font.Name = "Times New Roman"
		Label1.Font.Bold = True
		Label1.Font.Size = 15
		Label1.SetBounds 84, 12, 252, 24
		Label1.Parent = @This
		CommandButton1.Name = "CommandButton1"
		CommandButton1.Text = "OK"
		#ifndef __USE_GTK__
			CommandButton1.Default = True
		#endif
		CommandButton1.SetBounds 340, 349, 92, 26
		CommandButton1.OnClick = @CommandButton1_Click
		CommandButton1.Parent = @This
		' Label2                                
		Label2.Name = "Label2"
		Label2.Text = ML("Authors") & !":\r" & _
		!"Xusinboy Bekchanov\r" & _
		!"e-mail: <a href=""mailto:bxusinboy@mail.ru"">bxusinboy@mail.ru</a>\r" & _
		ML("For donation") & !": Patreon: <a href=""https://www.patreon.com/xusinboy"">patreon.com/xusinboy</a>, WebMoney: <a href=""https://www.webmoney.ru"">WMZ: Z884195021874</a>\r\r" & _
		!"Liu ZiQI\r" & _
		!"e-mail: <a href=""mailto:liuziqi.hk@hotmail.com"">liuziqi.hk@hotmail.com</a>\r\r" & _
		ML("Thanks to") & !" Nastase Eodor for codes of FreeBasic Windows GUI ToolKit and Simple Designer\r\r" & _
		ML("Thanks to") & !" Aloberoger for codes of GUITK-S Windows GUI FB Wrapper Library\r\r" & _
		ML("Thanks to") & !" Laurent GRAS for codes of FBDebugger\r\r" & _
		ML("Thanks to") & !" José Roca for codes of Afx\r\r" & _
		ML("Language files by") & !":\r" & _
		!"Xusinboy Bekchanov (russian, uzbekcyril, uzbeklatin)\r" & _
		!"skyfish4tb (chinese)"
		Label2.BorderStyle = 0
		Label2.SetBounds 22, 66, 408, 266
		Label2.Parent = @This
		' lblIcon
		lblIcon.Name = "lblIcon"
		lblIcon.Text = "lblIcon"
		'lblIcon.RealSizeImage = false
		#ifdef __USE_GTK__
			lblIcon.Graphic.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico", 48, 48)
		#else
			lblIcon.Graphic.Icon.LoadFromResourceID(1, 48, 48)
		#endif
		lblIcon.SetBounds 18, 10, 48, 48
		lblIcon.Parent = @This
		' lblInfo
		lblInfo.Name = "lblInfo"
		lblInfo.Text = ML("IDE for FreeBasic")
		lblInfo.SetBounds 90, 36, 246, 18
		lblInfo.Font.Name = "Times New Roman"
		lblInfo.Font.Bold = True
		lblInfo.Font.Size = 10
		lblInfo.Parent = @This
		Exit Constructor
		ErrorHandler:
		MsgBox ErrDescription(Err) & " (" & Err & ") " & _
		"in line " & Erl() & " " & _
		"in function " & ZGet(Erfn()) & " " & _
		"in module " & ZGet(Ermn())
	End Constructor
	
	Dim Shared As frmAbout fAbout
	pfAbout = @fAbout
	#ifndef _NOT_AUTORUN_FORMS_
		frm.Show
		
		App.Run
	#endif
'#End Region

Private Sub frmAbout.CommandButton1_Click(ByRef Sender As Control)
	Cast(Form Ptr, Sender.Parent)->CloseForm
End Sub
