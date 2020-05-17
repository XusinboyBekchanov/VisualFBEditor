'#Compile -exx "Form1.rc"
#include once "mff/Form.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAdvancedOptions Extends Form
		Declare Constructor
		
	End Type
	
	Common Shared pfAdvancedOptions As frmAdvancedOptions Ptr
'#End Region

#ifndef __USE_MAKE__
	#include once "frmAdvancedOptions.bas"
#endif
