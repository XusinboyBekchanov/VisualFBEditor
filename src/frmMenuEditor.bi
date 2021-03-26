'#Region "Form"
	#include once "mff/Form.bi"
	
	Using My.Sys.Forms
	
	Type frmMenuEditor Extends Form
		Declare Constructor
		
	End Type
	
	Common Shared pfMenuEditor As frmMenuEditor Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmMenuEditor.frm"
#endif
