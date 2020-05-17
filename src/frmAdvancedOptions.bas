#include once "frmAdvancedOptions.bi"

'#Region "Form"
	Constructor frmAdvancedOptions
		' frmAdvancedOptions
		With This
			.Name = "frmAdvancedOptions"
			.Text = "Advanced Options"
			.Name = "frmAdvancedOptions"
			.StartPosition = FormStartPosition.CenterScreen
			.Caption = "Advanced Options"
			.BorderStyle = FormBorderStyle.FixedDialog
			.SetBounds 0, 0, 350, 468
		End With
	End Constructor
	
	Dim Shared fAdvancedOptions As frmAdvancedOptions
	pfAdvancedOptions = @fAdvancedOptions
	
	#ifndef _NOT_AUTORUN_FORMS_
		fAdvancedOptions.Show
		
		App.Run
	#endif
'#End Region

