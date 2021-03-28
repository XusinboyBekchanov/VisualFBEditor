'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type frmMenuEditor Extends Form
		Declare Constructor
		
		Dim As TextBox TextBox1
	End Type
	
	Common Shared pfMenuEditor As frmMenuEditor Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmMenuEditor.frm"
#endif
