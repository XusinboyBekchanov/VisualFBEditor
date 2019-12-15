'################################################################
'#  frmFind.bas                                                 #
'#  This file is part of VisualFBEditor                         #
'#  Authors: Xusinboy Bekchanov (2018-2019), Liu ZiQI (2019)    #
'################################################################

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CheckBox.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TrackBar.bi"
#include once "mff/Label.bi"
#include once "TabWindow.bi"

#define Me *Cast(frmFind Ptr, Sender.GetForm) 
Using My.Sys.Forms
    
'#Region "Form"
    Type frmFind Extends Form
        Declare Static Sub _Form_Show_(ByRef Sender As Form)
        Declare Static Sub _Form_Close_(ByRef Sender As Form, ByRef Action As Integer)
        Declare Static Sub _btnFind_Click_(ByRef Sender As Control)        
        Declare Static Sub _btnFindAll_Click_(ByRef Sender As Control)
        Declare Static Sub _btnFindPrev_Click_(ByRef Sender As Control)
        Declare Static Sub _btnReplace_Click_(ByRef Sender As Control)        
        Declare Static Sub _btnReplaceAll_Click_(ByRef Sender As Control)
        Declare Static Sub _btnReplaceShow_Click_(ByRef Sender As Control)
        Declare Static Sub _btnCancel_Click_(ByRef Sender As Control)         
        Declare Sub Form_Show(ByRef Sender As Form)
        Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
        Declare Sub btnFind_Click(ByRef Sender As Control)        
        Declare Function FindAll(bNotShowResults As Boolean = False) As Integer
        Declare Sub btnFindPrev_Click(ByRef Sender As Control)
        Declare Sub btnReplace_Click(ByRef Sender As Control)        
        Declare Sub btnReplaceAll_Click(ByRef Sender As Control)
        Declare Sub btnReplaceShow_Click(ByRef Sender As Control)        
        Declare Sub btnCancel_Click(ByRef Sender As Control)
        Declare Function Find(Down As Boolean, bNotShowResults As Boolean = False) As Integer
        Declare Static Sub TrackBar1_Change(ByRef Sender As TrackBar,Position As Integer)
        Declare Static Sub btnFindAll_Click(ByRef Sender As Control)
        Declare Static Sub Form_Create(ByRef Sender As Control)
        DECLARE Constructor
        DECLARE Destructor
        
        DIM AS CheckBox chkMatchCase, chkSelection

        DIM AS Label lblFind, lblTrack, lblReplace

        DIM AS ComboBoxEdit txtFind, txtReplace

        DIM AS WStringList mFindResultList

        DIM AS CommandButton btnFind, btnCancel, btnFindPrev, btnReplaceAll, btnReplace, btnReplaceShow, btnFindAll

        DIM AS TrackBar TrackBar1
    END Type
    
    COMMON SHARED AS frmFind PTR pfFind
'#End Region

#IFNDEF __USE_MAKE__
	#INCLUDE ONCE "frmFind.bas"
#EndIf
