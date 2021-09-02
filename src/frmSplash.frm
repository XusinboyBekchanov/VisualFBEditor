'#########################################################
'#  frmSplash.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2020)              #
'#########################################################

#include once "frmSplash.bi"
#include once "mff/Application.bi"

Using My.Sys.Forms

'#Region "Form"
	Constructor frmSplash
		This.Text = "Visual FB Editor"
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#endif
		This.BackColor = 0
		This.SetBounds 0, 0, 370, 346
		This.BorderStyle = 0
		This.StartPosition = FormStartPosition.CenterScreen
		
		' lblImage
		lblImage.Name = "lblImage"
		'lblImage.Graphic.Bitmap.LoadFromResourceName("Logo")
		#ifdef __USE_GTK__
			lblImage.Graphic.Bitmap.LoadFromFile(ExePath & "/Resources/Logo.png")
		#else
			lblImage.Graphic.Bitmap = "Logo"
		#endif
		lblImage.CenterImage = True
		lblImage.SetBounds 12, 24, 343, 270
		lblImage.Designer = @This
		lblImage.OnClick = @lblImage_Click_
		lblImage.BackColor = 0
		lblImage.Parent = @This
		' lblSplash
		lblSplash.SetBounds 14, 6, 342, 36
		#ifdef __USE_GTK__
			lblSplash.Text = "Visual FB Editor " & VERSION
		#else
			lblSplash.Text = "Visual FB Editor " & pApp->GetVerInfo("ProductVersion")
		#endif
		lblSplash.Font.Name = "Times New Roman"
		lblSplash.Font.Size = 20
		lblSplash.Font.Bold = True
		lblSplash.Font.Italic = True
		lblSplash.BackColor = 0
		lblSplash.Font.Color = 16777215
		lblSplash.Parent = @This
		
		'lblIcon.Graphic.Icon = 100
		' lblInfo
		lblInfo.Name = "lblInfo"
		lblInfo.Text = "2018-2021"
		lblInfo.SetBounds 18, 282, 282, 18
		lblInfo.BackColor = 0
		lblInfo.Font.Color = 16777215
		lblInfo.Font.Size = 8
		lblInfo.Parent = @This
		' lblProcess
		With lblProcess
			.Name = "lblProcess"
			.Text = ""
			.SetBounds 18, 306, 330, 34
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

Private Sub frmSplash.lblImage_Click_(ByRef Sender As Control)
	*Cast(frmSplash Ptr, Sender.Designer).lblImage_Click(Sender)
End Sub
Private Sub frmSplash.lblImage_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub
