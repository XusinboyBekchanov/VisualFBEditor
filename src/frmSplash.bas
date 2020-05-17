'#########################################################
'#  frmSplash.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "frmSplash.bi"
#include once "mff/Application.bi"

Using My.Sys.Forms

'#Region "Form"
	Constructor frmSplash
		' lblImage
		lblImage.Name = "lblImage"
		'lblImage.Graphic.Bitmap.LoadFromResourceName("Logo")
		#ifdef __USE_GTK__
			lblImage.Graphic.Bitmap.LoadFromFile(ExePath & "/Resources/Logo.png")
		#else
			lblImage.Graphic.Bitmap = "Logo"
		#endif
		lblImage.SetBounds 12, 24, 334, 262
		lblImage.Parent = @This
		' lblSplash
		lblSplash.SetBounds 14, 6, 294, 36
		lblSplash.Text = "Visual FB Editor " & pApp->GetVerInfo("ProductVersion")
		lblSplash.Font.Name = "Times New Roman"
		lblSplash.Font.Size = 20
		lblSplash.Font.Bold = True
		lblSplash.Font.Italic = True
		lblSplash.BackColor = 0
		lblSplash.Font.Color = 16777215
		lblSplash.Parent = @This
		
		This.Text = "Visual FB Editor"
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#endif
		This.BackColor = 0
		This.SetBounds 0, 0, 370, 346
		This.BorderStyle = 0
		This.StartPosition = FormStartPosition.CenterScreen
		'lblIcon.Graphic.Icon = 100
		' lblInfo
		lblInfo.Name = "lblInfo"
		lblInfo.Text = "2018-2020"
		lblInfo.SetBounds 18, 282, 282, 18
		lblInfo.BackColor = 0
		lblInfo.Font.Color = 16777215
		lblInfo.Font.Size = 8
		lblInfo.Parent = @This
		' lblProcess
		With lblProcess
			.Name = "lblProcess"
			.Text = ""
			.SetBounds 18, 306, 330, 18
			.BackColor = 0
			.Font.Color = 16777215
			.Font.Size = 8
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fSplash As frmSplash
	pfSplash = @fSplash
'#End Region

#ifndef _NOT_AUTORUN_FORMS_
	fSplash.Show
	pApp->Run
#endif
