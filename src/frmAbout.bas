'#########################################################
'#  frmAbout.bas                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmAbout.bi"

'#Region "Form"
	Constructor frmAbout
		This.Name = "frmAbout"
		This.Text = ML("About")
		This.SetBounds 0, 0, 456, 538
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.MaximizeBox = False
		This.MinimizeBox = False
		This.StartPosition = FormStartPosition.CenterScreen
		#ifndef __USE_GTK__
			This.DefaultButton = @CommandButton1
			This.CancelButton = @CommandButton1
		#endif
		Label1.Name = "Label1"
		Label1.Font.Name = "Times New Roman"
		Label1.Font.Bold = True
		Label1.Font.Size = 15
		Label1.SetBounds 84, 12, 252, 24
		Label1.Parent = @This
		CommandButton1.Name = "CommandButton1"
		CommandButton1.Text = ML("&Close")
		#ifndef __USE_GTK__
			CommandButton1.Default = True
			Label1.Text = "Visual FB Editor " & pApp->Version
		#else
			Label1.Text = "Visual FB Editor " & WStr(VERSION)
		#endif
		CommandButton1.SetBounds 348, 481, 92, 26
		CommandButton1.OnClick = @CommandButton1_Click
		CommandButton1.Parent = @This
		' lblInfo
		lblInfo.Name = "lblInfo"
		lblInfo.Text = ML("IDE for FreeBasic")
		lblInfo.SetBounds 90, 36, 246, 18
		lblInfo.Font.Name = "Times New Roman"
		lblInfo.Font.Bold = True
		lblInfo.Font.Size = 10
		lblInfo.Parent = @This
		' Label2
		Label2.Name = "Label2"
		Label2.Text = ML("Authors") & !":\r" & _
		!"Xusinboy Bekchanov\r" & _
		!"e-mail: <a href=""mailto:bxusinboy@mail.ru"">bxusinboy@mail.ru</a>\r\r" & _
		!"Liu XiaLin\r" & _
		!"e-mail: <a href=""mailto:liuziqi.hk@hotmail.com"">liuziqi.hk@hotmail.com</a>\r" & _
		!"QQ Forums 1032313876 78458582, <a href=""1"">WeChat group QR-code</a>\r\r" & _
		ML("Language files by") & !":\r" & _
		!"Xusinboy Bekchanov (Russian, Uzbekcyril, Uzbeklatin)\r" & _
		!"Liu XiaLin (Chinese, Arabic, Czech, Dutch, French, Ukrainian)\r" & _
		!"Thomas Frank Ludewig (Deutsch)\r\r" & _
		ML("For donation") & !":\rPatreon: <a href=""https://www.patreon.com/xusinboy"">patreon.com/xusinboy</a>, WebMoney: <a href=""https://www.webmoney.ru""> WMZ: Z884195021874</a>\r\r" & _
		ML("Thanks to") & !":\r" & _
		!"Nastase Eodor for codes of FreeBasic Windows GUI ToolKit and Simple Designer\r" & _
		!"Aloberoger for codes of GUITK-S Windows GUI FB Wrapper Library\r" & _
		!"Laurent GRAS for codes of FBDebugger\r" & _
		!"José Roca for codes of Afx"
		Label2.BorderStyle = 0
		Label2.SetBounds 10, 66, 432, 403
		Label2.OnLinkClicked = @Label2_LinkClicked
		Label2.Parent = @This
		' imgIcon
		imgIcon.Name = "lblIcon"
		imgIcon.Text = "lblIcon"
		'imgIcon.RealSizeImage = false
		#ifdef __USE_GTK__
			If Dir(ExePath & "/Resources/VisualFBEditor.ico")<>"" Then imgIcon.Graphic.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico", 48, 48)
		#else
			imgIcon.Graphic.Icon.LoadFromResourceID(1, 48, 48)
		#endif
		imgIcon.SetBounds 18, 10, 48, 48
		imgIcon.Parent = @This
		' imgQRCode
		With imgQRCode
			.Name = "imgQRCode"
			.Text = "imgQRCode"
			.SetBounds 212, 198, 170, 170
			.Graphic.Bitmap = "weChat"
			.Visible = False
			.Parent = @This
		End With
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

Private Sub frmAbout.lblImage_Click(ByRef Sender As ImageBox)
	
End Sub

Private Sub frmAbout.Label2_LinkClicked(ByRef Sender As LinkLabel, ByVal ItemIndex As Integer, ByRef Link1 As WString, ByRef Action As Integer)
	If ItemIndex = 2 Then
		fAbout.imgQRCode.Visible = Not fAbout.imgQRCode.Visible
	End If
End Sub
