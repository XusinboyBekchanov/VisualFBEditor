#ifdef __FB_WIN32__
	'#Compile "GridDataTest.rc"
#endif
'#########################################################
'#  frmGridDataTest.bas                                  #
'#  Authors: Liu ZiQI (2019)                             #
'#########################################################
'#Define __USE_GTK__
#define GetMN
On Error Goto ErrorQ
#include "vbcompat.bi"
#include once "mff/SysUtils.bi"
#include once "SQLITE3_UTILITY.inc"
#include once "mff/Panel.bi"
#include once "mff/Splitter.bi"

Dim Shared SQLiteDB As sqlite3 Ptr
If SQLiteOpen(SQLiteDB, ExePath & "\Data\Test.db", "") Then
	Print "OPEN SQLiteDB Failure." + Chr(13,10)+SQLiteErrMsg(SQLiteDB)
Else
	Print "Opened SQLiteDB successfully.", ExePath & "\Data\Test.db"
End If
#define _NOT_AUTORUN_FORMS_
#include once "mff/Form.bi"
#include once "mff/Dialogs.bi"
#include once "mff/TextBox.bi"
#include once "mff/RichTextBox.bi"
#include once "mff/TabControl.bi"
#include once "mff/StatusBar.bi"
#include once "mff/Splitter.bi"
#include once "mff/ToolBar.bi"
#include once "mff/ListControl.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/CommandButton.bi"
#include once "mff/GroupBox.bi"
#include once "mff/RadioButton.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/ScrollBarControl.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TrackBar.bi"
#include once "mff/UpDown.bi"
#include once "mff/Animate.bi"
#include once "mff/Clipboard.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"

'GRIDDATA
#include once "mff/GridData.bi"
#include once "mff/Picture.bi"
#include once "mff/IniFile.bi"

Using My.Sys.Forms
'Dim Shared As Form frmGridDataTest
'#Region "Form"
	Type frmGridDataTest Extends Form
		Declare Static Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub CommandButton2_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Static Sub Form_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Action As Integer)
		Declare Static Sub Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		
		'GRID DATA
		Declare Static Sub MSHFGridCont_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGridCont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		#endif
		Declare Static Sub MSHFGridCont_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
		Declare Static Sub MSHFGridCont_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		Declare Static Sub MSHFGridCont_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGridCont_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, RowIndex As Integer, ColIndex As Integer, tGridDCC As HDC)
		#endif
		Declare Static Sub MSHFGridCont_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer,Shift As Integer)
		Declare Static Sub MSHFGridCont_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
		Declare Static Sub MSHFGridCont_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub MSHFGridCont_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		
		'GRID DATA
		Declare Static Sub MSHFGrid_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGrid_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		#endif
		Declare Static Sub MSHFGrid_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
		Declare Static Sub MSHFGrid_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		Declare Static Sub MSHFGrid_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
		#ifdef __USE_WINAPI__
			Declare Static Sub MSHFGrid_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		#endif
		Declare Static Sub MSHFGrid_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub MSHFGrid_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
		Declare Static Sub MSHFGrid_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Static Sub MSHFGrid_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Static Sub Frame_Sql_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As GroupBox)
		Declare Sub Frame_Sql_Click(ByRef Sender As GroupBox)
		Declare Static Sub _cmdRefrshDataBase_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRefrshDataBase_Click(ByRef Sender As Control)
		Declare Function DataBindingCombo(ByRef tControl As ComboBoxEdit, db As sqlite3 Ptr, sSql As ZString Ptr, AddHeader As Boolean = True) As Integer
		Declare Function DataBindingGrid(ByRef tControl As GridData, db As sqlite3 Ptr, sSql As ZString Ptr, AddHeader As Boolean = True) As Integer
		Declare Constructor
		
		
		'Dim As Panel Frame_Sql
		Dim As GroupBox Frame_Sql
		Dim As ListView ListView_Offset
		Dim As CommandButton Command_OffsetSave
		Dim As CommandButton Command_OffsetCancel
		Dim As ComboBoxEdit Combo_ACR
		Dim As CommandButton Command5
		Dim As ComboBoxEdit Combo_Offset_UseRule
		Dim As TextBox Text_OffsetName
		Dim As CommandButton Command_OffsetlistChoose
		Dim As CommandButton Command_OffsetListAction
		Dim As CommandButton Command3
		Dim As CommandButton Command_Show
		Dim As TextBox Text_OffsetReference
		Dim As Label Label_OffsetNum
		Dim As Picture Image_OffsetLocked
		Dim As Picture Image_Reference
		Dim As Label Label_Reference
		Dim As Label Label_InterpShowMsg
		Dim As TextBox TXTR
		Dim As CommandButton CMD100000
		Dim As CommandButton Command1
		Dim As CommandButton Command_MaxForm
		
		Dim As ImageList ImageList1
		Dim As TreeView TreeView1
		Dim As ComboBoxEdit Combo_Search
		Dim As CommandButton CommandEncrypt
		
		Dim As CommandButton Command_CopyGrid
		Dim As TextBox txtEdit
		Dim As ListControl lstTable
		Dim As ComboBoxEdit cboServer
		Dim As CommandButton cmdFindServer
		Dim As CommandButton cmdRefrshDataBase
		Dim As TextBox txtPWD
		Dim As ComboBoxEdit TxtID
		Dim As ComboBoxEdit cboSource
		Dim As RadioButton Option_DB
		Dim As GridData MSHFGrid, MSHFGridCont
		Dim As ImageList imgListGrid1
		
		Dim As Label Label1
		Dim As Label Label2
		Dim As Picture Image_Toolbar
		Dim As Panel Panel1, Panel2
		Dim As Splitter Splitter1, Splitter2
	End Type
	
	Constructor frmGridDataTest
		
		' Form Property
		This.Name = "frmGridDataTest"
		This.Text = "GridDataTest"
		This.OnCreate = @Form_Create
		This.OnClose = @Form_Close
		This.OnShow = @Form_Show
		This.OnResize = @Form_Resize
		This.MinimizeBox = True
		This.MaximizeBox = True
		This.SetBounds 0, 0, 800, 500
		This.CenterToScreen
		This.Caption = "GridDataTest"
		This.BorderStyle = FormBorderStyle.Sizable 'FixedDialog
		
		TreeView1.Name = "TreeView1"
		TreeView1.Text = "ListView_Offset_Save"
		'TreeView1.BackColor = clWhite
		'TreeView1.Anchor.Right = asAnchor
		'TreeView1.OnClick = @TreeView1_Click
		TreeView1.Align = DockStyle.alLeft
		TreeView1.ExtraMargins.Top = 10
		TreeView1.ExtraMargins.Right = 0
		TreeView1.ExtraMargins.Bottom = 10
		TreeView1.ExtraMargins.Left = 10
		TreeView1.SetBounds 10, 10, 270, 441
		TreeView1.BackColor = -1
		TreeView1.ID = 1001
		TreeView1.Parent = @This
		' Splitter2
		With Splitter2
			.Name = "Splitter2"
			.Text = "Splitter2"
			.SetBounds 290, 0, 10, 461
			.Designer = @This
			.Parent = @This
		End With
		Frame_Sql.Name = "Frame_Sql"
		'Frame_Sql.Text = "Frame Sql"
		'Frame_Sql.BackColor =
		'Frame_Sql.Font.Size = 11
		'Frame_Sql.OnClick = @Frame_Sql_Click
		Frame_Sql.Align = DockStyle.alClient
		Frame_Sql.ExtraMargins.Top = 10
		Frame_Sql.ExtraMargins.Right = 10
		Frame_Sql.ExtraMargins.Bottom = 10
		Frame_Sql.SetBounds 270, 0, 794, 761
		Frame_Sql.Designer = @This
		Frame_Sql.OnClick = @Frame_Sql_Click_
		Frame_Sql.Parent = @This
		
		cboServer.Name = "cboServer"
		cboServer.Text = "YOGA2\SQLEXPRESS"
		cboServer.AddItem "YOGA2\SQLEXPRESS"
		cboServer.AddItem "local"
		cboServer.BackColor = clWhite
		'cboServer.Font.Size = 11
		'cboServer.OnClick = @cboServer_Click
		cboServer.SetBounds 16, 16, 94, 21
		cboServer.Parent = @Panel1
		
		cboSource.Name = "cboSource"
		cboSource.Text = "YOGA2\SQLEXPRESS"
		cboSource.AddItem "YOGA2\SQLEXPRESS"
		cboSource.AddItem "local"
		cboSource.BackColor = clWhite
		'cboSource.Font.Size = 11
		'cboSource.OnClick = @cboSource_Click
		cboSource.SetBounds 120, 16, 94, 21
		cboSource.Parent = @Panel1
		
		
		cmdFindServer.Name = "cmdFindServer"
		cmdFindServer.Text = "..."
		cmdFindServer.BackColor = clWhite
		'cmdFindServer.Font.Size = 11
		'cmdFindServer.OnClick = @cmdFindServer_Click
		cmdFindServer.SetBounds 225, 16, 30, 25
		cmdFindServer.Parent = @Panel1
		
		cmdRefrshDataBase.Name = "cmdRefrshDataBase"
		cmdRefrshDataBase.Text = "Refresh DataBase"
		cmdRefrshDataBase.BackColor = clWhite
		'cmdRefrshDataBase.Font.Size = 11
		'cmdRefrshDataBase.OnClick = @cmdRefrshDataBase_Click
		cmdRefrshDataBase.SetBounds 260, 16, 121, 25
		cmdRefrshDataBase.Designer = @This
		cmdRefrshDataBase.OnClick = @_cmdRefrshDataBase_Click
		cmdRefrshDataBase.Parent = @Panel1
		
		txtPWD.Name = "txtPWD"
		txtPWD.Text = "dtquser"
		'txtPWD.BackColor = clWhite
		'txtPWD.Font.Size = 11
		'txtPWD.OnClick = @txtPWD_Click
		txtPWD.SetBounds 232, 75, 72, 25
		txtPWD.Parent = @Panel1
		
		TxtID.Name = "TxtID"
		TxtID.Text = "Combo1"
		'TxtID.BackColor = clWhite
		'TxtID.Font.Size = 11
		'TxtID.OnClick = @TxtID_Click
		TxtID.SetBounds 56, 75, 80, 21
		TxtID.Parent = @Panel1
		
		Label1.Name = "Label1"
		Label1.Text = "ID:"
		'Label1.BackColor = clWhite
		'Label1.Font.Size = 11
		Label1.SetBounds 24, 75, 22, 22
		Label1.Parent = @Panel1
		
		Label2.Name = "Label2"
		Label2.Text ="Password:"
		'Label2.BackColor = clWhite
		'Label2.Font.Size = 11
		Label2.SetBounds 150, 75, 80, 22
		Label2.Parent = @Panel1
		
		Option_DB.Name = "Option_DB"
		Option_DB.Text = "Show DataBase"
		'Option_DB.BackColor = clWhite
		'Option_DB.Font.Size = 11
		'Option_DB.OnClick = @Option_DB_Click
		Option_DB.SetBounds 24, 48, 101, 22
		Option_DB.Parent = @Panel1
		
		imgListGrid1.Height=16 'Change the Height of Body
		imgListGrid1.Width=16
		imgListGrid1.Add "Grid", "Grid"
		imgListGrid1.Add "New", "New"
		imgListGrid1.Add "Open", "Open"
		imgListGrid1.Add "Save", "Save"
		'MSHFGridCont.Align = 1'alLeft  2'alRight 3'alTop 4'alBottom 5'alClient
		'MSHFGridCont.SetMargins 0,50,10,10
		
		MSHFGrid.SetBounds 10, 150, 150, 250
		MSHFGrid.StateImages =@imgListGrid1             ' @imgList
		MSHFGrid.SmallImages =@imgListGrid1             '@imgList
		'MSHFGridCont.Font.Size=13'22 two line 'Change the Height of Header
		MSHFGrid.RowHeight = 20
		MSHFGrid.Align = DockStyle.alLeft
		MSHFGrid.Parent = @Panel2 ' @This
		'MSHFGrid.Columns.Add "NO ", 0,35,cfCenter, False,CT_Header,False,CT_Header,,ssSortAscending
		'MSHFGrid.ListItems.Add  "1",0,1
		' Splitter1
		With Splitter1
			.Name = "Splitter1"
			.Text = "Splitter1"
			.SetBounds 0, 0, 10, 291
			.Designer = @This
			.Parent = @Panel2
		End With
		
		MSHFGridCont.SetBounds 170, 150, 760, 250
		MSHFGridCont.StateImages =@imgListGrid1             ' @imgList
		MSHFGridCont.SmallImages =@imgListGrid1             '@imgList
		'MSHFGridCont.Font.Size=13'22 two line 'Change the Height of Header
		MSHFGridCont.RowHeight = 40
		MSHFGridCont.Align = DockStyle.alClient
		MSHFGridCont.Parent = @Panel2 ' @This
		'MSHFGridCont.RowHeightHeader=40
		'MSHFGridCont.SetGridLines(FocusRect_Row,GRIDLINE_Both,clSilver,,,,,PS_SOLID)
		'MSHFGridCont.GridEditComboBox.GridEditComboItem ="True" +CHR(9) +"False"
		
		'MSHFGridCont.SendToBack
		'MSHFGridCont.ColumnHeaderHidden = True
		'SendMessage(MSHFGridCont.HandleHeader, HDM_SETIMAGELIST, 0, Cast(LPARAM, imgListGrid1.Handle))
		'https://www.cnblogs.com/hbtmwangjin/p/7941403.html
		'dim as String sSql="SELECT operator_id, name,logo,preferences_id,numsd,acrule_id,confidence1d,confidence2d,confidence3d,updated_by,update_date,comments,locked FROM operator"
		'SELECT
		'print "frmGridDataTest.Form_Show"
		
		MSHFGridCont.Init
		Dim As WString Ptr ComboEditItem
		WLet ComboEditItem, "True"+Chr(9)+"False" +Chr(9)+"121313"+Chr(9)+"321232"
		MSHFGridCont.Columns.Add  "NO ", 0, 35, cfCenter, DT_Numeric, False, , , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Property" + WChr(13, 10) + "1TH", 0, 100, cfLeft, DT_Numeric, False, CT_TextBox, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Property" + WChr(13, 10) + "2nd", 0, 100, cfRight, DT_Numeric, False, CT_LinkLabel, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Property" + WChr(13, 10) + "3RD", 0, 100, cfCenter, DT_Numeric, False, CT_Button, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "Value", 0, 70, cfCenter, True, False, CT_ComboBoxEdit, *ComboEditItem, SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "5TH", 0, 100, cfCenter, True, False, CT_CheckBox, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "6TH", 0, 100, cfCenter, DT_Numeric, False, CT_ProgressBar, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "7TH", 0, 100, cfCenter, DT_Date, False, CT_DateTimePicker, , SortStyle.ssSortAscending
		MSHFGridCont.Columns.Add "GridData" + WChr(13, 10) + "8TH", 0, 100, cfCenter, True, False, CT_TextBox, , SortStyle.ssSortAscending
		
		Dim ItemsCount As Integer
		For ii As Integer  =0 To 30
			MSHFGridCont.ListItems.Add  "1",0,1
			ItemsCount=MSHFGridCont.ListItems.Count - 1
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(0) =Right(Str(ii+1),5)'right("00"+str(ii),3)
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(1) =Format(Rnd(1)*10000,"#0.00")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(2) =Format(Rnd(1)*10000,"#0.00")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(3) =Format(Rnd(1)*10000,"#0.00")+WChr(13,10)+"汇总值"
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(4) =IIf( ii Mod 2,"True","False")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(5) =IIf(ii Mod 2,WChr(30),"1234567890"+WChr(13,10)+"汇总值"+WChr(31))
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(6) =Format(Rnd(1)*100,"#0")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(7) =Format(Rnd(1)*10000,"yyyy/mm/dd")
			MSHFGridCont.ListItems.Item(ItemsCount)->Text(8) ="汇总值"+Right("00000"+Str(ii),5)+WChr(13,10)+"总汇值FF"+WChr(13,10)+"值汇总"+Right("00000000"+Str(ii),5)
			'     MSHFGridCont.ListItems.Item(ItemsCount)->ForeColor(1) =iif(ii mod 2,clPurple,clYellow)
			'     MSHFGridCont.ListItems.Item(ItemsCount)->ForeColor(2) =clGreen
			'    MSHFGridCont.ListItems.Item(ItemsCount)->BackColor(2) =iif(ii mod 2,clMaroon,clLtGray)
			'    MSHFGridCont.ListItems.Item(ItemsCount)->ForeColor(7) =clAqua
			'    MSHFGridCont.ListItems.Item(ItemsCount)->BackColor(7) =iif(ii mod 2,clYellow,clOlive)
			'    MSHFGridCont.ListItems.Item(ItemsCount)->ForeColor(4) =clPurple
			'    MSHFGridCont.ListItems.Item(ItemsCount)->BackColor(4) =iif(ii mod 2,clTeal,clBlue)
			
		Next
		MSHFGridCont.OnEndScroll = @MSHFGridCont_EndScroll
		MSHFGridCont.OnResize = @MSHFGridCont_Resize
		MSHFGridCont.OnKeyDown = @MSHFGridCont_KeyDown
		#ifdef __USE_WINAPI__
			MSHFGridCont.OnItemClick=@MSHFGridCont_Click
			MSHFGridCont.OnItemDblClick = @MSHFGridCont_DblClick
		#endif
		MSHFGridCont.OnHeadClick=@MSHFGridCont_OnHeadClick
		MSHFGridCont.OnHeadColWidthAdjust=@MSHFGridCont_OnHeadColWidthAdjust
		'   MSHFGridCont.AllowEdit=true
		MSHFGrid.OnEndScroll = @MSHFGrid_EndScroll
		MSHFGrid.OnResize = @MSHFGrid_Resize
		MSHFGrid.OnKeyDown = @MSHFGridCont_KeyDown
		#ifdef __USE_WINAPI__
			MSHFGrid.OnItemClick = @MSHFGrid_Click
			'MSHFGrid.OnItemDblClick=@MSHFGrid_DblClick
		#endif
		MSHFGrid.OnHeadClick=@MSHFGrid_OnHeadClick
		MSHFGrid.OnHeadColWidthAdjust=@MSHFGrid_OnHeadColWidthAdjust
		
		'	MSHGrid.Name = "MSHGrid"
		'	MSHGrid.Text = "Show WA"
		'	MSHGrid.BackColor = clWhite
		'	'MSHGrid.Font.Size = 11
		'	'MSHGrid.OnClick = @MSHGrid_Click
		'	MSHGrid.SetBounds 272, 40, 490, 129
		'	MSHGrid.Parent = @Frame_Sql
		
		'	MSHFGridCont.Name = "MSHFGridCont"
		'	MSHFGridCont.Text = "Show WA"
		'	MSHFGridCont.BackColor = clWhite
		'	'MSHFGridCont.Font.Size = 11
		'	'MSHFGridCont.OnClick = @MSHFGridCont_Click
		'	MSHFGridCont.SetBounds 272, 176, 490, 241
		'	MSHFGridCont.Parent = @Frame_Sql
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		'Image_Toolbar.Font.Size = 11
		'Image_Toolbar.OnClick = @Image_Toolbar_Click
		Image_Toolbar.SetBounds 72, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text ="ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		'Image_Toolbar.Font.Size = 11
		'Image_Toolbar.OnClick = @Image_Toolbar_Click
		Image_Toolbar.SetBounds 56, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		'Image_Toolbar.Font.Size = 11
		'Image_Toolbar.OnClick = @Image_Toolbar_Click
		Image_Toolbar.SetBounds 90, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		'Image_Toolbar.Font.Size = 11
		'Image_Toolbar.OnClick = @Image_Toolbar_Click
		Image_Toolbar.SetBounds 32, 3, 16, 16
		Image_Toolbar.Parent = @This
		
		Image_Toolbar.Name = "Image_Toolbar"
		Image_Toolbar.Text = "ListView_Offset_Save"
		Image_Toolbar.BackColor = clWhite
		'Image_Toolbar.Font.Size = 11
		'Image_Toolbar.OnClick = @Image_Toolbar_Click
		
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 12
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 20
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.SetBounds 140, -80, 464, 110
			.Designer = @This
			.Parent = @Frame_Sql
		End With
		' Panel2
		With Panel2
			.Name = "Panel2"
			.Text = "Panel2"
			.TabIndex = 13
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.Align = DockStyle.alClient
			.SetBounds 50, 160, 464, 291
			.Designer = @This
			.Parent = @Frame_Sql
		End With
	End Constructor
	
	Private Sub frmGridDataTest._cmdRefrshDataBase_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmGridDataTest Ptr, Sender.Designer)).cmdRefrshDataBase_Click(Sender)
	End Sub
	
	Private Sub frmGridDataTest.Frame_Sql_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As GroupBox)
		(*Cast(frmGridDataTest Ptr, Sender.Designer)).Frame_Sql_Click(Sender)
	End Sub
	
	Dim Shared fGridDataTest As frmGridDataTest
	
	'#IfnDef _NOT_AUTORUN_FORMS_
	fGridDataTest.Show
	App.Run
	'#EndIf
'#End Region

Private Sub frmGridDataTest.Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	
End Sub
Private Sub frmGridDataTest.Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Action As Integer)
	Print "frmGridDataTest.Form_Close"
	SQLiteClose(SQLiteDB)
	End
End Sub

Private Sub frmGridDataTest.Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fGridDataTest.CenterToScreen
	'dim as String sSql="SELECT * FROM sqlite_master WHERE TYPE='table'" 'performs a (short) Table- and Index-Analysis, for better optimized queries
	Dim As String sSql="SELECT NAME FROM sqlite_master WHERE type='table' ORDER BY name" 'performs a (short) Table- and Index-Analysis, for better optimized queries
	fGridDataTest.MSHFGrid.Init
	fGridDataTest.MSHFGrid.Columns.Add "NO ", 0, 35, cfCenter, False, False, DT_String, , SortStyle.ssSortAscending
	fGridDataTest.MSHFGrid.Columns.Add "Table" + WChr(13, 10) + "Name", 0, 130, cfLeft, True, False, CT_TextBox, , SortStyle.ssSortAscending
	'   if fGridDataTest.MSHFGrid.DataBinding(SQLiteDB,sSql,FALSE)<=0 Then
	'      Print "OPEN DataBase Records Failure.", sSql
	'      'fGridDataTest.MSHFGrid.ListItems.Add  "1",0,1
	'   end if
	
End Sub

Private Sub frmGridDataTest.Form_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
'	Dim R As Rect
'	fGridDataTest.TreeView1.Left=5
'	R.Left=fGridDataTest.TreeView1.Width+10
'	R.Top=fGridDataTest.TreeView1.Top
'	R.Right=fGridDataTest.ClientWidth-fGridDataTest.TreeView1.Width-60
'	fGridDataTest.TreeView1.Height=fGridDataTest.ClientHeight-60
'	R.Bottom=fGridDataTest.TreeView1.Height/2
'	'print "frmGridDataTest.Form_Resize ",R.Right
'	If R.Right>0 Then
'		If R.Bottom>75 AndAlso R.Right>150 Then
'			fGridDataTest.Frame_Sql.SetBounds R.Left,R.top,R.Right,R.Bottom+50
'			'fGridDataTest.MSHFGrid.SetBounds R.Left,150,190,R.Bottom-65
'			'fGridDataTest.MSHFGridCont.SetBounds R.Left+205,150,R.Right-205,R.Bottom-65
'			?10,110,130,R.Bottom-65
'			'fGridDataTest.MSHFGrid.SetBounds 10,110,130,R.Bottom-65
'			fGridDataTest.MSHFGridCont.SetBounds 180,110,R.Right-205,R.Bottom-65
'			'fGridDataTest.MSHFGrid.Refresh
'			'fGridDataTest.MSHFGridCont.Refresh
''			fGridDataTest.Picture1.SetBounds R.Left, R.Bottom + 100, R.Right, R.Bottom - 80
''			fGridDataTest.cmdDraw.SetBounds R.Left,R.Bottom*2+5,100,25
''			fGridDataTest.cmdDraw_Click(Sender)
'			
'			'InvalidateRect(fGridDataTest.Picture1.Handle,null,True) 'Refresh the current handle only. do not updated the child
'			'UpdateWindow fGridDataTest.Picture1.Handle
'		End If
'		
'	End If
End Sub

Private Sub frmGridDataTest.Form_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	
End Sub

Private Sub frmGridDataTest.CommandButton1_Click(ByRef Sender As Control)
	' CommandButton3_Click(Sender)
	Cast(frmGridDataTest Ptr, Sender.Parent)->CloseForm
End Sub

Private Sub frmGridDataTest.CommandButton2_Click(ByRef Sender As Control)
	Cast(frmGridDataTest Ptr, Sender.Parent)->CloseForm
End Sub
'Private Sub frmGridDataTest.cmdDraw_Click(ByRef Sender As Control)
'	Dim R As Rect
'	R.Right = fGridDataTest.ClientWidth - fGridDataTest.Picture1.Width - 55
'	R.Bottom= fGridDataTest.Picture1.Height-fGridDataTest.Picture1.top-fGridDataTest.Picture1.top-10'fGridDataTest.ClientHeight - 20
'	Static As logfont lf
'	'    with Sender
'	'        lf.lfHeight=20
'	'        lf.lfunderline=1
'	'        lf.lfWeight=700
'	'        lf.lfEscapement=10*45 ' degrees to rotate
'	'        lf.lfOrientation=10*45
'	'        lf.lfCharSet=DEFAULT_CHARSET
'	'        lf.lfFaceName="Tahoma"
'	'        .Canvas.Font.Color=255
'	'        .Canvas.Font=CreateFontIndirect(@lf)
'	'        .Canvas.TextOut(10, 100, "Rotated text")
'	'        .Canvas.TextOut(10, 128, "GUI-S is great !")
'	'    end with
'	
'	With fGridDataTest
'		' If .BrowsD.Execute Then
'		'     .txtMFFPath.Text = .BrowsD.Directory
'		' End If
'		
'		'fGridDataTest.Picture1.Style=2
'		'fGridDataTest.Picture1.Canvas.Rectangle(R)
'		
'		'        fGridDataTest.Picture1.Canvas.Font.Orientation=10
'		fGridDataTest.Picture1.Canvas.Font.Size=24
'		'        fGridDataTest.Picture1.Canvas.Bitmap = "Logo"
'		'fGridDataTest.Picture1.Canvas.Font=CreateFontIndirect(@lf)
'		'fGridDataTest.Picture1.Canvas.TextOut(10, 100, "Rotated text")
'		'fGridDataTest.Picture1.Canvas.TextOut(10, 128, "GUI-S is great !")
'		
'		fGridDataTest.Picture1.Canvas.Pen.Color =clred' BGR(102,24,25)
'		fGridDataTest.Picture1.Canvas.Line 0,0,104,168
'		fGridDataTest.Picture1.Canvas.Pen.Color = clYellow'BGR(202,24,25)
'		fGridDataTest.Picture1.Canvas.Line 104,168,R.Right,R.Bottom
'		fGridDataTest.Picture1.Canvas.TextOut 100,140,"Test String",clBlue,-1'clNone
'		'fGridDataTest.Picture1.line 50,50,124,128
'		'fGridDataTest.Picture1.line 124,128,444,498
'		fGridDataTest.Canvas.line 0,0,524,428
'		
'	End With
'End Sub
'Private Sub frmGridDataTest.Picture1_Paint(ByRef Sender As Control, ByRef R As Rect,DC As HDC)
'	'print "DC",DC
'	' dim hBrush_HP As HBRUSH
'	'hBrush_HP = CreateSolidBrush(BGR(255, 96, 96))
'	' FrameRect(DC,@R,hBrush_HP)
'	'Line(DC,154,198,R.Right,R.Bottom)
'	'DeleteObject(hBrush_HP)
'	fGridDataTest.cmdDraw_Click(Sender)
'End Sub
'AA1
'########################################################################################
'GRID CODE

'GRIDDATA
' #IfDef __USE_GTK__
'Sub frmGridDataTest.MSHFGridCont_SelectedItemChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
'    '  print "RowIndex:ColIndex in SelectedItemChanged " ,RowIndex , ColIndex
'    ' GridCtrlEdit->Visible = False
'End Sub
'#else
' Sub frmGridDataTest.MSHFGridCont_SelectedItemChanged(ByRef Sender As GridData, Byval RowIndex as integer , BYVAL ColIndex as Integer,ByVal nmcdhDC as hDc )

'     If MSHFGridCont.SelectedItem = 0 Then

'         exit sub
'     end if


'  End Sub
'#EndIf
Sub frmGridDataTest.MSHFGridCont_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	'print "MSHFGridCont_EndScroll"
	Dim As My.Sys.Drawing.Rect lpRect
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGridCont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		If ColIndex<=0 Then
		End If
		
		'print "tb ",tb
		Dim As Rect lpRect
		'Dim As GridDataItem Ptr Item = MSHFGridCont.ListItems.Item(RowIndex)
		
		#ifndef __USE_GTK__
			' ListView_GetSubItemRect(Sender.Handle, RowIndex, ColIndex, LVIR_BOUNDS, @lpRect) 'reutrn Rect of fullRow when click on the first col
			'print "lpRect.Left,Top,Right,Bottom ",lpRect.Left, lpRect.Top,lpRect.Right,lpRect.Bottom
		#endif
		
	End Sub
#endif

Sub frmGridDataTest.MSHFGridCont_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
	'Dim Item As GridDataItem Ptr = MSHFGridCont.ListItems.Item(itemIndex)
	' print "Item->Text(2)" + Item->Text(2)
	' SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(Sender.Text), Item->Tag)
End Sub

Sub frmGridDataTest.MSHFGridCont_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
	'print "MSHFGridCont OnHeadClick ColIndex ",ColIndex
End Sub

Sub frmGridDataTest.MSHFGridCont_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
	'print "OnHeadColWidthAdjust ColIndex ",ColIndex
	#ifndef __USE_GTK__
		Dim As Rect lpRect
		'If GridCtrlEdit > 0 Then
		'ListView_GetSubItemRect(MSHFGridCont.Handle, GridRow1, GridCol1, LVIR_BOUNDS, @lpRect) 'reutrn Rect of fullRow when click on the first col
		'GridCtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
		'end if
	#endif
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGridCont_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As GridData, RowIndex As Integer, ColIndex As Integer, tGridDCC As HDC)
		'Dim Item As GridDataItem Ptr = MSHFGridCont.ListItems.Item(itemIndex)
		'print "Item->Text(2)" + Item->Text(2)
		' dim as SCROLLINFO si
		'  si.cbSize = sizeof (SCROLLINFO)
		'  'si.cbMask =SIF_ALL' SIF_RANGE OR SIF_PAGE
		'  si.nMin = 0
		'  si.nMax = 10
		'  si.nPage = 4
		'SetScrollInfo(MSHFGridCont.Handle, SB_HORZ, &si, TRUE) 'SB_HORZ  SB_VERT
		
		' SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(MSHFGridCont.Text), Item->Tag)
	End Sub
#endif

Sub frmGridDataTest.MSHFGridCont_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	' Dim Item As GridDataItem Ptr = MSHFGridCont.SelectedItem
	#ifndef __USE_GTK__
		If Key = VK_RETURN Then
			'Dim lvi As GridDataItem Ptr = MSHFGridCont.SelectedItem
			
			'If lvi <> 0 Then MSHFGridCont_ItemDblClick Sender, *lvi
		End If
	#endif
	' print "MSHFGridCont_KeyDown", Item->Text(1)
	
End Sub

Sub frmGridDataTest.MSHFGridCont_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_RETURN
		Case VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR
		End Select
	#endif
End Sub

Sub frmGridDataTest.MSHFGridCont_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	
	'print "MSHFGridCont_KeyUp"
	'Key = 0
End Sub
Sub frmGridDataTest.MSHFGridCont_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As Integer tWidth = Sender.Width - 22
	'frmGridDataTest.MSHFGridCont.Width = tWidth
	'print tWidth,fGridDataTest.GridData1.Width  'fGridDataTest.GridData1.RowHeight
	'GridData1_EndScroll(*Cast(GridData Ptr, @Sender))
End Sub



'GRID DATA CODE
'########################################################################################

'#######################################################################################
'GRIDDATA
' #IfDef __USE_GTK__
'Sub frmGridDataTest.MSHFGrid_SelectedItemChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
'    '  print "RowIndex:ColIndex in SelectedItemChanged " ,RowIndex , ColIndex
'    ' GridCtrlEdit->Visible = False
'End Sub
'#else
' Sub frmGridDataTest.MSHFGrid_SelectedItemChanged(ByRef Sender As GridData, Byval RowIndex as integer , BYVAL ColIndex as Integer,ByVal nmcdhDC as hDc )

'     If MSHFGrid.SelectedItem = 0 Then

'         exit sub
'     end if


'  End Sub
'#EndIf
Sub frmGridDataTest.MSHFGrid_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	'print "MSHFGrid_EndScroll"
	'Dim As Rect lpRect
	
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGrid_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		
	End Sub
#endif

Sub frmGridDataTest.MSHFGrid_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As GridDataItem Ptr)
	'Dim Item As GridDataItem Ptr = fGridDataTest.MSHFGrid.ListItems.Item(itemIndex)
	Print "ItemActivate Item->Text(1)" + Item->Text(1)
	' SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(Sender.Text), Item->Tag)
End Sub

Sub frmGridDataTest.MSHFGrid_OnHeadClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
	'print "MSHFGrid OnHeadClick ColIndex ",ColIndex
End Sub

Sub frmGridDataTest.MSHFGrid_OnHeadColWidthAdjust(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ColIndex As Integer)
	'print "OnHeadColWidthAdjust ColIndex ",ColIndex
	#ifndef __USE_GTK__
		Dim As Rect lpRect
		'If GridCtrlEdit > 0 Then
		'ListView_GetSubItemRect(MSHFGrid.Handle, GridRow1, GridCol1, LVIR_BOUNDS, @lpRect) 'reutrn Rect of fullRow when click on the first col
		'GridCtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
		'end if
	#endif
End Sub

#ifdef __USE_WINAPI__
	Sub frmGridDataTest.MSHFGrid_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control, RowIndex As Integer, ColIndex As Integer, nmcdhDC As HDC)
		'Dim Item As GridDataItem Ptr = fGridDataTest.MSHFGrid.ListItems.Item(itemIndex)
		'  print "ItemDblClick Reading data Starting " '+ Item->Text(1),TImer
		' dim as SCROLLINFO si
		'  si.cbSize = sizeof (SCROLLINFO)
		'  'si.cbMask =SIF_ALL' SIF_RANGE OR SIF_PAGE
		'  si.nMin = 0
		'  si.nMax = 10
		'  si.nPage = 4
		'SetScrollInfo(MSHFGrid.Handle, SB_HORZ, &si, TRUE) 'SB_HORZ  SB_VERT
		' SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(MSHFGrid.Text), Item->Tag)
		Static As Boolean DataReading
		If ColIndex<=0 Or RowIndex<0  Then Exit Sub
		If DataReading=True Then Exit Sub
		DataReading=True
		'print "tb ",tb
		Dim As Rect lpRect
		Dim As GridDataItem Ptr Item = fGridDataTest.MSHFGrid.ListItems.Item(RowIndex)
		'print "MSHFGrid_Click,Start Time:",Time, Item->Text(ColIndex)
		fGridDataTest.MSHFGridCont.Init
		Dim As String sSql="SELECT * FROM "+Item->Text(ColIndex)+";"
		'print "sSql",sSql
		Dim As Long ItemRows '=fGridDataTest.MSHFGridCont.DataBinding(SQLiteDB,strptr(sSql),TRUE)
		If ItemRows<=0 Then
			Print "OPEN DataBase Records Failure."+ Chr(13,10)+ sSql
		Else
			'  print "Reading data ending " ,TIme,ItemRows
			'fGridDataTest.MSHFGridCont.Refresh
		End If
		DataReading=False
		#ifndef __USE_GTK__
			' ListView_GetSubItemRect(Sender.Handle, RowIndex, ColIndex, LVIR_BOUNDS, @lpRect) 'reutrn Rect of fullRow when click on the first col
			'print "lpRect.Left,Top,Right,Bottom ",lpRect.Left, lpRect.Top,lpRect.Right,lpRect.Bottom
		#endif
	End Sub
#endif

Sub frmGridDataTest.MSHFGrid_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	' Dim Item As GridDataItem Ptr = MSHFGrid.SelectedItem
	#ifndef __USE_GTK__
		If Key = VK_RETURN Then
			'Dim lvi As GridDataItem Ptr = MSHFGrid.SelectedItem
			
			'If lvi <> 0 Then MSHFGrid_ItemDblClick Sender, *lvi
		End If
	#endif
	' print "MSHFGrid_KeyDown", Item->Text(1)
	
End Sub

Sub frmGridDataTest.MSHFGrid_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Byte)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_RETURN
		Case VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR
		End Select
	#endif
End Sub

Sub frmGridDataTest.MSHFGrid_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	'print "MSHFGrid_KeyUp"
	'Key = 0
End Sub
Sub frmGridDataTest.MSHFGrid_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	Dim As Integer tWidth = Sender.Width - 22
	'frmGridDataTest.MSHFGrid.Width = tWidth
	'print tWidth,fGridDataTest.GridData1.Width  'fGridDataTest.GridData1.RowHeight
	'GridData1_EndScroll(*Cast(GridData Ptr, @Sender))
End Sub



'GRID DATA CODE
'########################################################################################

Function frmGridDataTest.DataBindingCombo(ByRef tControl As ComboBoxEdit, db As sqlite3 Ptr,sSql As ZString Ptr,AddHeader As Boolean=True) As Integer
'https://www.cnblogs.com/hbtmwangjin/p/7941403.html
    Dim As Integer i,j
    Dim lpTable    As ZString Ptr Ptr ' 返回给定表的数组指针（从列名称）
    Dim nRows      As Long=0         ' 返回的记录集的行数
    Dim nColumns   As Long=0         ' 返回的记录集的列数
    Dim lpErrorSz  As ZString Ptr         ' 错误信息
    'Dim zField     As ZString Ptr   ' 返回给定表的字段（在lpTable数组元素）
    Dim iFields    As Long=0         ' 返回表返回的字段数
    Dim iRow       As Long=0
    Dim iCol       As Long=0
    Dim iResult    As Long         ' 行或错误的数量由我函数返回

	#ifdef __USE_WINAPI__
	    Dim As HCURSOR hCurSave = GetCursor()
	    SetCursor(LoadCursor(0, IDC_WAIT))
	#endif
    If sqlite3_get_table(db, sSql, @lpTable, @nRows, @nColumns, @lpErrorSz) = 0 Then '成功
        'Print "BindData Reading Data ",nRows, nColumns
        If nRows = 0 OrElse nColumns<1  Then
            'declare sub sqlite3_free_table(byval result as zstring ptr ptr)
            'Print "No Data ******* ",nRows, nColumns
            sqlite3_free_table lpTable  '不论数据库查询是否成功，都释放 char** 查询结果
            lpTable=0
            Return  -1
        End If
        If AddHeader Then
            'For i = 0 To nColumns-1
                'tControl.Columns.Add *lpTable[i], 0, 100,cfCenter,DT_String,False,CT_TextBox,,ssSortAscending
            'Next
        End If
        iFields = ((nRows+1) * nColumns)-1
        'tControl.AddItem *lpTable[nColumns]
        For i = nColumns To iFields
            iCol +=1
            If iCol = nColumns Then iCol = 0
            If ((i) Mod nColumns = 0) AndAlso i<iFields Then
                iRow +=1
                tControl.AddItem *lpTable[i]
            End If
        Next
    Else
        iResult = -1
        sqlite3_free_table lpTable  '不论数据库查询是否成功，都释放 char** 查询结果
        lpTable=0
        Return  -1
    End If
    sqlite3_free_table lpTable  '不论数据库查询是否成功，都释放 char** 查询结果
    lpTable=0
    Return  nRows
End Function

Function frmGridDataTest.DataBindingGrid(ByRef tControl As GridData, db As sqlite3 Ptr,sSql As ZString Ptr,AddHeader As Boolean=True) As Integer
    'https://www.cnblogs.com/hbtmwangjin/p/7941403.html
    '获取数据，返回行数，如果=<0 为出错，可以读 ErrStr 来看什么错
    '返回 saRecSetZ() 2维数组
    '执行查询的结果在 saRecSetZ（ 行, 列）下标为零
    ' 结果第一行0为列名称,字段名字
    ' 数据从1开始连续
    Dim As Integer i, j, CountPerPage
    #ifdef __USE_WINAPI__
    	CountPerPage = ListView_GetCountPerPage(tControl.Handle)
    #endif
    Dim lpTable    As ZString Ptr Ptr ' 返回给定表的数组指针（从列名称）
    Dim nRows      As Long=0         ' 返回的记录集的行数
    Dim nColumns   As Long=0         ' 返回的记录集的列数
    Dim lpErrorSz  As ZString Ptr         ' 错误信息
    'Dim zField     As ZString Ptr   ' 返回给定表的字段（在lpTable数组元素）
    Dim iFields    As Long=0         ' 返回表返回的字段数
    Dim iRow       As Long=0
    Dim iCol       As Long=0
    Dim iResult    As Long         ' 行或错误的数量由我函数返回

	#ifdef __USE_WINAPI__
	    Dim As HCURSOR hCurSave = GetCursor()
	    SetCursor(LoadCursor(0, IDC_WAIT))
	#endif
    If sqlite3_get_table(db, sSql, @lpTable, @nRows, @nColumns, @lpErrorSz) = 0 Then '成功
        'Print "BindData Reading Data ",nRows, nColumns
        If nRows = 0 OrElse nColumns<1  Then
            'declare sub sqlite3_free_table(byval result as zstring ptr ptr)
            'Print "No Data ******* ",nRows, nColumns
            sqlite3_free_table lpTable  '不论数据库查询是否成功，都释放 char** 查询结果
            tControl.Columns.Add "NO", 0, 43,cfCenter,CT_Header,False,CT_Header,,ssSortAscending
            tControl.Columns.Add "  ", 0,130,cfCenter,DT_String,False,CT_TextBox,,ssSortAscending
            For i = nRows+1 To CountPerPage
                tControl.ListItems.Add Str(BLANKROW+(i-nRows)/10000),0,1
            Next
             tControl.ListItems.Item(0)->Text(1) = " "
            lpTable=0
            Return  -1
        End If
        If AddHeader Then
            tControl.Columns.Add "NO", 0, 43,cfCenter, CT_Header,False,CT_Header,,ssSortAscending
            For i = 0 To nColumns-1
                tControl.Columns.Add *lpTable[i], 0, 100,cfCenter,DT_String,False,CT_TextBox,,ssSortAscending
            Next
        End If
        tControl.ListItems.Add  Str(iRow+1),0,1
        tControl.ListItems.Item(iRow)->Text(0) = Str(iRow+1)
        iFields = ((nRows+1) * nColumns)-1
        'fGridDataTest.prProgress.MaxValue=100
        'Print "BindData Columns.Add ",nRows, nColumns,iFields
        For i = nColumns To iFields
             pApp->DoEvents
            'fGridDataTest.prProgress.Position=i*100/iFields
            tControl.ListItems.Item(iRow)->Text(iCol+1) = *lpTable[i]
            iCol +=1
            If iCol = nColumns Then iCol = 0
            If ((i+1) Mod nColumns = 0) AndAlso i<iFields Then
                iRow +=1
                tControl.ListItems.Add  Str(iRow+1),0,1
                tControl.ListItems.Item(iRow)->Text(0) = Str(iRow+1)
            End If
        Next
        'Marked the last row is BLANKROW
        tControl.ListItems.Item(nRows)->Text(0) = Str(BLANKROW+0.00005)
        If nRows<CountPerPage Then
            For i = nRows+1 To CountPerPage
                tControl.ListItems.Add Str(BLANKROW+(i-nRows)/10000),0,1
            Next
        End If
    Else
        iResult = -1
        sqlite3_free_table lpTable  '不论数据库查询是否成功，都释放 char** 查询结果
        tControl.Columns.Add " ", 0, 43,cfCenter,CT_Header,True,CT_Header,,ssSortAscending
        tControl.Columns.Add "  ", 0,130,cfCenter,DT_String,False,CT_TextBox,,ssSortAscending
        For i = nRows+1 To CountPerPage
            tControl.ListItems.Add Str(BLANKROW+(i-nRows)/10000),0,1
        Next
        tControl.ListItems.Item(0)->Text(1) = " "
        lpTable=0
        Return  -1
    End If
    sqlite3_free_table lpTable  '不论数据库查询是否成功，都释放 char** 查询结果
    lpTable=0
    Return  nRows
End Function

'fGridDataTest.CreateWnd
'fGridDataTest.Show
'App.MainForm = @frmGridDataTest
'App.Run
'End

End
ErrorQ:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in line " & Erl() & " " & _
"in function " & ZGet(Erfn()) & " " & _
"in module " & ZGet(Ermn())

Private Sub frmGridDataTest.Frame_Sql_Click(ByRef Sender As GroupBox)
	
End Sub

Private Sub frmGridDataTest.cmdRefrshDataBase_Click(ByRef Sender As Control)
	
End Sub
