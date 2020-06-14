#include once "frmAdvancedOptions.bi"

'#Region "Form"
	Constructor frmAdvancedOptions
		' frmAdvancedOptions
		With This
			.Name = "frmAdvancedOptions"
			.Text = ML("Advanced Options")
			.Name = "frmAdvancedOptions"
			.StartPosition = FormStartPosition.CenterScreen
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

