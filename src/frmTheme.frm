'#########################################################
'#  frmTheme.bi                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmTheme.bi"

'#Region "Form"
	Constructor frmTheme
		' frmTheme
		This.Name = "frmTheme"
		This.Text = ML("New Theme")
		#ifdef __USE_GTK__
			This.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
		#else
			This.Icon.LoadFromResourceID(1)
		#endif
		This.StartPosition = FormStartPosition.CenterParent
		This.SetBounds 0, 0, 310, 156
		' lblThemeName
		lblThemeName.Name = "lblThemeName"
		lblThemeName.Text = ML("Theme name") & ":"
		lblThemeName.SetBounds 16, 16, 104, 16
		lblThemeName.Parent = @This
		' txtThemeName
		txtThemeName.Name = "txtThemeName"
		txtThemeName.Text = ""
		txtThemeName.SetBounds 16, 40, 264, 18
		txtThemeName.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.SetBounds 16, 80, 80, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 200, 80, 80, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
	End Constructor
	
	Dim Shared fTheme As frmTheme
	pfTheme = @fTheme
	
	#ifndef _NOT_AUTORUN_FORMS_
		fTheme.Show
		
		App.Run
	#endif
'#End Region


Private Sub frmTheme.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If fTheme.txtThemeName.Text = "" Then
		MsgBox "Theme name is empty"
		Exit Sub
	End If
	fTheme.ModalResult = ModalResults.OK
	fTheme.CloseForm
End Sub

Private Sub frmTheme.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fTheme.ModalResult = ModalResults.Cancel
	fTheme.CloseForm
End Sub
