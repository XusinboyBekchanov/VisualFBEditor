'################################################################################
'#  GridData.bi                                                                 #
'#  Authors: Liu ZiQI (2019)                                                    #
'################################################################################
#define GetMN
#include once "mff/DateTimePicker.bi"
#include once "mff/LinkLabel.bi" 
#include once "mff/ComboBoxEdit.bi" 
#include once "mff/TextBox.bi" 
#include once "mff/ListView.bi"

Using My.Sys.Forms

Enum GridDataTypeEnum   
   DT_Nothing=0
   DT_Numeric = 1
   DT_LinkLabel = 2   
   DT_Boolean = 3
   DT_ProgressBar = 4
   DT_Custom = 5
   DT_Button = 6
   DT_ComBoBoxEdit = 7
   DT_Date = 8
   DT_String = 9
End Enum

Enum GridControlTypeEnum
   CT_Nothing=0
   CT_CheckBox = 1
   CT_LinkLabel = 2
   CT_DateTimePicker = 3
   CT_ProgressBar = 4
   CT_Custom = 5
   CT_Button = 6
   CT_ComboBoxEdit = 7
   CT_TextBox = 9
End Enum

Enum GridLinesEnum
   GRIDLINE_None
   GRIDLINE_Both
   GRIDLINE_Vertical
   GRIDLINE_Horizontal
End Enum 

 Enum GridCellFormatEnum
   CFBackColor = 1
   CFForeColor = 4
   CFImage = 8
   CFFontName = 16
   CFFontBold = 32
   CFFontItalic = 64
   CFFontUnderline = 128
   CFHandPointer = 256
   CFAlignment = 512
End Enum 

Enum GridFocusRectModeEnum
   GridFocus_None = 0
   GridFocus_Row = 1
   GridFocus_Col = 2
End Enum

'Namespace My.Sys.Forms
    #define QGridData(__Ptr__) *Cast(GridData Ptr,__Ptr__)
    #define QGridDataItem(__Ptr__) *Cast(GridDataItem Ptr,__Ptr__)
    #define QGridDataColumn(__Ptr__) *Cast(GridDataColumn Ptr,__Ptr__)

    Type PGridDataItem As GridDataItem Ptr    
    Type GridDataItems
        Private:
            FItems As List
            PItem As PGridDataItem
            FParentItem As PGridDataItem            
            #ifndef __USE_GTK__
               lviItems As LVITEM
			   #endif
        Public:
        	#ifdef __USE_GTK__
        		Declare Function FindByIterUser_Data(User_Data As Any Ptr) As PGridDataItem
        	#else
        		Declare Function FindByHandle(Value As LParam) As PGridDataItem
        	#endif
            Parent   As Control Ptr
            Declare Property Count As Integer
            Declare Property Count(Value As Integer)
            Declare Property Item(Index As Integer) As PGridDataItem
            Declare Property Item(Index As Integer, Value As PGridDataItem)
            Declare Function Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As PGridDataItem
            Declare Function Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, Indent As Integer = 0) As PGridDataItem
            Declare Function Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As PGridDataItem
            Declare Sub Remove(Index As Integer)
            Declare Property ParentItem As PGridDataItem
            Declare Property ParentItem(Value As PGridDataItem)
            Declare Function IndexOf(ByRef FItem As PGridDataItem) As Integer
            Declare Function IndexOf(ByRef FCaption As WString) As Integer
            Declare Function Contains(ByRef FCaption As WString) As Boolean
            Declare Sub Clear
            Declare Sub Sort
            Declare Operator Cast As Any Ptr
            Declare Constructor
            Declare Destructor
    End Type

    Type GridDataItem Extends My.Sys.Object
        Private:
            FText               As WString Ptr                        
            FHint               As WString Ptr
            FSubItems           As WStringList
            FImageIndex         As Integer
            FSelectedImageIndex As Integer
            FSmallImageIndex    As Integer
            FImageKey           As WString Ptr
            FSelectedImageKey   As WString Ptr
            FSmallImageKey      As WString Ptr
            FParentItem As PGridDataItem
            FVisible            As Boolean
            FState              As Integer
            FIndent             As Integer
            FExpanded			As Boolean      
           ' FBackColor(10)     As Integer
           ' FForeColor(1)     As Integer
                  
            #ifndef __USE_GTK__
				  Dim lviItem             As LVITEM
              
			   #endif
		Protected:
        	#ifndef __USE_GTK__
				
         #endif
        Public:
        	   #ifdef __USE_GTK__
				TreeIter As GtkTreeIter
			   #else
				Handle As LParam
				Declare Function GetItemIndex() As Integer
            #endif
            Parent   As Control Ptr
            Items As GridDataItems
            Tag As Any Ptr
            Declare Sub SelectItem
            Declare Sub Collapse
            Declare Sub Expand
            Declare Function IsExpanded As Boolean
            Declare Function Index As Integer
            Declare Property Text(iSubItem As Integer) ByRef As WString
            Declare Property Text(iSubItem As Integer, ByRef Value As WString)                                       
            Declare Property ForeColor(iSubItem As Integer,Value As Integer)            
            Declare Property ForeColor(iSubItem As Integer) As Integer
            Declare Property BackColor(iSubItem As Integer,Value As Integer)            
            Declare Property BackColor(iSubItem As Integer) As Integer
            Declare Property Hint ByRef As WString
            Declare Property Hint(ByRef Value As WString)
            Declare Property ParentItem As PGridDataItem
            Declare Property ParentItem(Value As PGridDataItem)
            Declare Property ImageIndex As Integer
            Declare Property ImageIndex(Value As Integer)
            Declare Property SelectedImageIndex As Integer
            Declare Property SelectedImageIndex(Value As Integer)
            Declare Property SmallImageIndex As Integer
            Declare Property SmallImageIndex(Value As Integer)
            Declare Property ImageKey ByRef As WString
            Declare Property ImageKey(ByRef Value As WString)
            Declare Property SelectedImageKey ByRef As WString
            Declare Property SelectedImageKey(ByRef Value As WString)
            Declare Property SmallImageKey ByRef As WString
            Declare Property SmallImageKey(ByRef Value As WString)
            Declare Property Visible As Boolean
            Declare Property Visible(Value As Boolean)
            Declare Property State As Integer
            Declare Property State(Value As Integer)
            Declare Property Indent As Integer
            Declare Property Indent(Value As Integer)
            Declare Operator Cast As Any Ptr
            Declare Constructor
            Declare Destructor
            OnClick As Sub(ByRef Sender As My.Sys.Object)
            OnDblClick As Sub(ByRef Sender As My.Sys.Object)
    End Type

    Type GridDataColumn Extends My.Sys.Object
        Private:
            FText            As WString Ptr
            FHint            As WString Ptr
            FImageIndex   As Integer
            FColWidth      As Integer
            FFormat      As ColumnFormat
            FVisible      As Boolean
            FEditable	 As Boolean
            FLocked	 As Boolean
            FControlType      As Integer
            FDataType      As Integer            
            FGridEditComboItem As WString Ptr
            FSortOrder       As SortStyle
        Public:
        	#ifdef __USE_GTK__
        		Dim As GtkTreeViewColumn Ptr Column
        	#endif
            Index As Integer
            Parent   As Control Ptr             
            Declare Sub SelectItem
            Declare Property Text ByRef As WString
            Declare Property Text(ByRef Value As WString)
            Declare Property Hint ByRef As WString
            Declare Property Hint(ByRef Value As WString)
            Declare Property ImageIndex As Integer
            Declare Property ImageIndex(Value As Integer)
            Declare Property Visible As Boolean
            Declare Property Visible(Value As Boolean)
            Declare Property Editable As Boolean
            Declare Property Editable(Value As Boolean)
            Declare Property Locked As Boolean
            Declare Property Locked(Value As Boolean)
            Declare Property ControlType As Integer
            Declare Property ControlType(Value As Integer)
            Declare Property SortOrder As SortStyle
            Declare Property SortOrder(Value As SortStyle)            
            Declare Property GridEditComboItem ByRef As WString
            Declare Property GridEditComboItem(ByRef Value As WString)            
            Declare Property DataType As Integer
            Declare Property DataType(Value As Integer)            
            Declare Property ColWidth As Integer
            Declare Property ColWidth(Value As Integer)
            Declare Property Format As ColumnFormat
            Declare Property Format(Value As ColumnFormat)
            Declare Operator Cast As Any Ptr
            Declare Constructor
            Declare Destructor
            OnClick As Sub(ByRef Sender As My.Sys.Object)
            OnDblClick As Sub(ByRef Sender As My.Sys.Object)
    End Type

    Type GridDataColumns
        Private:
            FColumns As List
        	#ifdef __USE_GTK__
            	Declare Static Sub Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
        		Declare Static Sub Cell_Editing(cell As GtkCellRenderer Ptr, editable As GtkCellEditable Ptr, path As Const gchar Ptr, user_data As Any Ptr)
        	#endif
        Public:
            Parent   As Control Ptr
            Declare Property Count As Integer
            Declare Property Count(Value As Integer)
            Declare Property Column(Index As Integer) As GridDataColumn Ptr
            Declare Property Column(Index As Integer, Value As GridDataColumn Ptr)
            Declare Function Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, tFormat As ColumnFormat = cfLeft, ColEditable As Boolean = True,tDataType As GridDataTypeEnum = DT_String,tLocked As Boolean=False,tControlType As GridControlTypeEnum=CT_TextBox,ByRef tComboItem As WString = "",tSortOrder As SortStyle=ssSortAscending) As GridDataColumn Ptr
            Declare Sub Insert(Index As Integer,ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, tFormat As ColumnFormat = cfLeft, ColEditable As Boolean = True,tDataType As GridDataTypeEnum = DT_String,tLocked As Boolean=False,tControlType As GridControlTypeEnum=CT_TextBox,ByRef tComboItem As WString = "",tSortOrder As SortStyle=ssSortAscending)
            Declare Sub Remove(Index As Integer)
            Declare Function IndexOf(ByRef FColumn As GridDataColumn Ptr) As Integer
            Declare Sub Clear
            Declare Operator Cast As Any Ptr
            Declare Constructor
            Declare Destructor
    End Type

    Type GridData Extends Control
        Private:
            FBold      As Boolean
            FItalic    As Boolean
            FUnderline As Boolean
            FStrikeOut As Boolean
            FSize      As Integer
            FName      As WString Ptr
            FForeColor     As Integer
            FCharSet   As Integer             
            FBolds(2)  As Integer
            FCyPixels  As Integer
            FEscapement As Integer=0'????????
            FOrientation As Integer=0'????????
            FontHandleBody As HFONT 
            FontHandleBodyUnderline As HFONT 'For Link Text
            FontHeight As Integer
            FontWidth As Integer  
            
            FBoldHeader      As Boolean
            FItalicHeader    As Boolean
            FUnderlineHeader As Boolean
            FStrikeOutHeader As Boolean
            FSizeHeader      As Integer
            FNameHeader      As WString Ptr
            FForeColorHeader     As Integer
            FCharSetHeader   As Integer             
            FBoldsHeader(2)  As Integer
            FCyPixelsHeader  As Integer
            FEscapementHeader As Integer=0'????????
            FOrientationHeader As Integer=0'????????                        
            FontHandleHeader As HFONT            
            
            FView As ViewStyle
            FColumnHeaderHidden As Boolean
            FSingleClickActivate As Boolean
            FSortStyle As SortStyle         
                
            GridEditComboBox   As ComboBoxEdit   
            GridEditText  As TextBox
            GridEditDateTimePicker As DateTimePicker
            GridEditLinkLabel  As LinkLabel 
            FLvi As LVITEM                                    
            
            FRowHeightHeader As Integer=-1
            FRowHeight As Integer =-1
            mRowHeightShow(Any) As Integer
            FGridDataDC As hDC 
            FGridDataDCHeader As hDC
            mRow As Integer =0
            mCol As Integer =1
            mRowHover As Integer =0
            mColHover As Integer =1                        
            FItems As List 
            
            'GRID PROPER
            muGridLineDrawMode    As Integer =GRIDLINE_Both              
            muGridColorLine    As Integer =clSilver'BGR(166, 166, 166)'clSilver
            muGridColorSelected    As Integer =BGR(190, 228, 255)'BGR(178, 214, 255)
            muGridColorHover    As Integer =BGR(190, 228, 255)                          
            muGridLineWidth    As Integer =1
            muGridLinePenMode  As Integer = PS_SOLID    
            mShowHoverBar As Boolean=True    
            mShowSelection As Boolean=True                 
            mCountPerPage  As Integer   
            mDrawRowStart  As Integer   
            
            
            Declare Sub DrawRect(tDc As hDC,R As Rect,FillColor As Integer = -1,tRowSelction As Integer = -1)
            Declare Sub DrawLine(hdc As hDC,x1 As Integer,y1 As Integer, x2 As Integer, y2 As Integer,lColor As Integer, lWidth As Integer = 1,lLineType As Integer = PS_SOLID)
            Declare Sub GridDrawHeader(ColShowStart As Integer, ColShowEnd As Integer)
            Declare Sub GridReDraw(RowShowStart As Integer,RowShowEnd As Integer,RowHover As Integer=-1, ColHover As Integer=-1)
            Declare Static Sub WndProc(ByRef Message As Message)
			   Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
			   Declare Static Sub HandleIsDestroyed(ByRef Sender As Control)
			   Declare Sub ProcessMessage(ByRef Message As Message)
            
            
        Protected:
        	#ifdef __USE_GTK__
        		Declare Static Function GridData_TestExpandRow(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
        	#else
        		Declare Function GetGridDataItem(Item As Integer) As GridDataItem Ptr
        	#endif
        Public:
			   #ifdef __USE_GTK__
				TreeStore As GtkTreeStore Ptr
				TreeSelection As GtkTreeSelection Ptr
				ColumnTypes As GType Ptr
			#else
				FHandleHeader As HWND
            #endif
            Declare Sub Init()
   			ListItems         As GridDataItems
            Columns           As GridDataColumns
            Images            As ImageList Ptr
            StateImages       As ImageList Ptr
            SmallImages       As ImageList Ptr
            GroupHeaderImages As ImageList Ptr             
            
            Declare Sub SetGridLines(tDrawMode As GridLinesEnum=GRIDLINE_Both,tColorLine As Integer=clSilver,tColorSelected As Integer =clYellow,tColorHover As Integer =clLime,tWidth As Integer=1,PenMode As Integer=PS_SOLID)
            Declare Sub SetFontHeader(tFontColor As Integer,tNameHeader As WString,tSizeHeader As Integer,tCharSetHeader As Integer=FontCharset.Default,tBoldsHeader As Boolean=False,tItalicHeader As Boolean=False,tUnderlineHeader As Boolean=False,tStrikeoutHeader As Boolean=False)
            Declare Sub SetFont(tFontColor As Integer,tName As WString,tSize As Integer,tCharSet As Integer=FontCharset.Default,tBolds As Boolean=False,tItalic As Boolean=False,tUnderline As Boolean=False,tStrikeout As Boolean=False)
            Declare Sub CollapseAll
            Declare Sub ExpandAll
            Declare Property ColumnHeaderHidden As Boolean
            Declare Property ColumnHeaderHidden(Value As Boolean)
            Declare Property ShowHint As Boolean
            Declare Property ShowHint(Value As Boolean)
            Declare Property View As ViewStyle
            Declare Property View(Value As ViewStyle)
            Declare Property Sort As SortStyle
            Declare Property Sort(Value As SortStyle)
            Declare Property SelectedItem As GridDataItem Ptr
            Declare Property SelectedItem(Value As GridDataItem Ptr)
            Declare Property SelectedItemIndex As Integer
            Declare Property SelectedItemIndex(Value As Integer)
            Declare Property SelectedColumn As GridDataColumn Ptr
            Declare Property SelectedColumn(Value As GridDataColumn Ptr)
            Declare Property SingleClickActivate As Boolean
            Declare Property SingleClickActivate(Value As Boolean)
            Declare Property HandleHeader As HWND
            Declare Property HandleHeader(Value As HWND)
            Declare Property RowHeightHeader As Integer
            Declare Property RowHeightHeader(Value As Integer)
            Declare Property RowHeight As Integer
            Declare Property RowHeight(Value As Integer)
            Declare Property ShowHoverBar As Boolean    
            Declare Property ShowHoverBar(ByVal Value As Boolean)    
            Declare Property ShowSelection As Boolean    
            Declare Property ShowSelection(ByVal Value As Boolean)    
            
            'RowHeightHeader
'            Declare Static Sub GridEditComboBox_Change(ByRef Sender As Control)
'            Declare Static Sub GridEditText_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
'            Declare Static Sub GridEditText_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)              
'            Declare Static Sub GridEditText_KeyPress(ByRef Sender As Control, Key As Byte)
             
            Declare Operator Cast As Control Ptr
            Declare Constructor
            Declare Destructor
            OnHeadClick As Sub(ByRef Sender As GridData, ColIndex As Integer)
            OnHeadColWidthAdjust As Sub(ByRef Sender As GridData, ColIndex As Integer)            
            OnItemActivate As Sub(ByRef Sender As GridData, ByRef Item As GridDataItem Ptr)            
            OnItemClick As Sub(ByRef Sender As GridData, RowIndex As Integer, ColIndex As Integer,FGridDataDCC As hDc)
            OnItemDblClick As Sub(ByRef Sender As GridData, ByRef Item As GridDataItem Ptr)
            OnItemKeyDown As Sub(ByRef Sender As GridData, ByRef Item As GridDataItem Ptr)
            OnItemExpanding As Sub(ByRef Sender As GridData, ByRef Item As GridDataItem Ptr)
            OnCellEditing As Sub(ByRef Sender As GridData, ByRef Item As GridDataItem Ptr, SubItemIndex As Integer, CellEditor As Control Ptr)
            OnCellEdited As Sub(ByRef Sender As GridData, ByRef Item As GridDataItem Ptr, SubItemIndex As Integer, ByRef NewText As WString)
            OnSelectedItemChanged As Sub(ByRef Sender As GridData, RowIndex As Integer, ColIndex As Integer, FGridDataDCC As hDc)
            OnBeginScroll As Sub(ByRef Sender As GridData)
            OnEndScroll As Sub(ByRef Sender As GridData)
    End Type

	#ifndef __USE_GTK__
		Function GridDataItem.GetItemIndex() As Integer
         Return Index '		
'         Var nItem = ListView_GetItemCount(Parent->Handle)
'			For i As Integer = 0 To nItem - 1
'				lviItem.Mask = LVIF_PARAM
'				lviItem.iItem = i
'				lviItem.iSubItem   = 0
'				ListView_GetItem(Parent->Handle, @lviItem)
'				If lviItem.LParam = Cast(LParam, @This) Then
'					Return i
'				End If
'			Next i
'			Return -1
		End Function
	#endif

	Sub GridDataItem.Collapse
        #ifdef __USE_GTK__
			If Parent AndAlso Parent->widget AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_Tree_model(Cast(GridData Ptr, Parent)->TreeStore), @TreeIter))
				gtk_tree_view_collapse_row(gtk_tree_view(Parent->widget), TreePath)
				gtk_tree_path_free(TreePath)
			End If
        #else
        	Var ItemIndex = This.GetItemIndex()
        	If ItemIndex <> -1 Then
        		State = 1
	        	Var nItem = ListView_GetItemCount(Parent->Handle)
				Var i = ItemIndex + 1
				Do While i < nItem
					lviItem.Mask = LVIF_INDENT
					lviItem.iItem = i
					lviItem.iSubItem   = 0
					ListView_GetItem(Parent->Handle, @lviItem)
					If lviItem.iIndent > FIndent Then
						ListView_DeleteItem(Parent->Handle, i)
						nItem -= 1
					ElseIf lviItem.iIndent <= FIndent Then
						Exit Do
					End If
				Loop
			End If
		#EndIf
		FExpanded = False
    End Sub
    
 	Sub GridDataItem.Expand
        #IfDef __USE_GTK__
			If Parent AndAlso Parent->widget AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_Tree_model(Cast(GridData Ptr, Parent)->TreeStore), @TreeIter))
				gtk_tree_view_expand_row(gtk_tree_view(Parent->widget), TreePath, False)
				gtk_tree_path_free(TreePath)
			End If
        #Else
        	If Parent AndAlso Parent->Handle Then
        		State = 2
	        	Var ItemIndex = This.GetItemIndex
	        	If ItemIndex <> -1 Then
	        		For i As Integer = 0 To Items.Count - 1
						lviItem.Mask = LVIF_TEXT or LVIF_IMAGE or LVIF_State or LVIF_Indent or LVIF_PARAM
						lviItem.pszText  = @Items.Item(i)->Text(0)
						lviItem.cchTextMax = Len(Items.Item(i)->Text(0))
						lviItem.iItem = ItemIndex + i + 1
						lviItem.iImage   = Items.Item(i)->FImageIndex
						If Items.Item(i)->Items.Count > 0 Then
							lviItem.State   = INDEXTOSTATEIMAGEMASK(1)
							Items.Item(i)->FExpanded = False
						Else
							lviItem.State   = 0
						End If
						lviItem.stateMask = LVIS_STATEIMAGEMASK
						lviItem.iIndent   = Items.Item(i)->Indent
						lviItem.LParam = Cast(LParam, Items.Item(i))
						ListView_InsertItem(Parent->Handle, @lviItem)
						For j As Integer = 1 To Cast(GridData Ptr, Parent)->Columns.Count - 1
							Dim As LVITEM lvi1
							lvi1.Mask = LVIF_TEXT
							lvi1.iItem = ItemIndex + i + 1
							lvi1.iSubItem   = j
							lvi1.pszText    = @Items.Item(i)->Text(j)
							lvi1.cchTextMax = Len(Items.Item(i)->Text(j))
							ListView_SetItem(Parent->Handle, @lvi1)
						Next j
					Next i
	        	End If
	        End If
        #EndIf
		FExpanded = True
    End Sub

    Function GridDataItem.IsExpanded As Boolean
        #IfDef __USE_GTK__
			If Parent AndAlso Parent->widget AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_Tree_model(Cast(GridData Ptr, Parent)->TreeStore), @TreeIter))
				Var bResult = gtk_tree_view_row_expanded(gtk_tree_view(Parent->widget), TreePath)
				gtk_tree_path_free(TreePath)
				Return bResult
			End If
		#Else
			Return FExpanded
			'If Parent AndAlso Parent->Handle Then Return TreeView_GetItemState(Parent->Handle, Handle, TVIS_EXPANDED)
		#EndIf
    End Function
    
    Function GridDataItem.Index As Integer
        If FParentItem <> 0 Then
            Return FParentItem->Items.IndexOf(@This)
        ElseIf Parent <> 0 Then
            Return Cast(GridData Ptr, Parent)->ListItems.IndexOf(@This)
        Else
            Return -1
        End If
    End Function
    
    Sub GridDataItem.SelectItem
		#IfDef __USE_GTK__
			If Parent AndAlso Cast(GridData Ptr, Parent)->TreeSelection Then
				gtk_tree_selection_select_iter(Cast(GridData Ptr, Parent)->TreeSelection, @TreeIter)
			End If
		#Else
			If Parent AndAlso Parent->Handle Then
				Var ItemIndex = This.GetItemIndex
				If ItemIndex = -1 Then Exit Sub 
				Dim lvi As LVITEM
				lvi.iItem = Index
				lvi.iSubItem   = 0
				lvi.state    = LVIS_SELECTED
				lvi.statemask = LVNI_SELECTED
				ListView_SetItem(Parent->Handle, @lvi)
			End If
		#EndIf
    End Sub
   
     
'    Property GridDataItem.BackColor(iSubItem As Integer)As Integer
'        If FSubItems.Count > iSubItem Then
'			Return clWhite'FBackColor(iSubItem)
'		Else
'			Return clWhite
'		End If
'    End Property
'    Property GridDataItem.BackColor(iSubItem As Integer,Value As Integer)  
'       'FBackColor(iSubItem) = Value
'    End Property
     
'    Property GridDataItem.ForeColor(iSubItem As Integer)As Integer
'        If FSubItems.Count > iSubItem Then
'			Return clBlack' FForeColor(iSubItem)
'		Else
'			Return clBlack
'		End If
'    End Property
'    Property GridDataItem.ForeColor(iSubItem As Integer,Value As Integer)  
'         'FForeColor(iSubItem) = Value
'    End Property
    
    
    Property GridDataItem.Text(iSubItem As Integer) ByRef As WString
        If FSubItems.Count > iSubItem Then
			Return FSubItems.Item(iSubItem)
		Else
			Return WStr("")
		End If
    End Property 
    Property GridDataItem.Text(iSubItem As Integer, ByRef Value As WString)
        WLet FText, Value
		For i As Integer = FSubItems.Count To iSubItem
			FSubItems.Add ""
		Next i
		FSubItems.Item(iSubItem) =Value
		If Parent Then
			#IfDef __USE_GTK__
				If Cast(GridData Ptr, Parent)->TreeStore Then
					gtk_tree_store_set (Cast(GridData Ptr, Parent)->TreeStore, @TreeIter, iSubItem + 1, ToUtf8(Value), -1)
				End If
			#Else
				If Parent AndAlso Parent->Handle Then
					Var ItemIndex = This.GetItemIndex
					If ItemIndex = -1 Then Exit Property
					lviItem.Mask = LVIF_TEXT
					lviItem.iItem = ItemIndex
					lviItem.iSubItem   = iSubItem
					lviItem.pszText    = FText
					lviItem.cchTextMax = Len(*FText)
					ListView_SetItem(Parent->Handle, @lviItem)
				End If
			#EndIf 
		End If
    End Property

    Property GridDataItem.State As Integer
		Return FState
    End Property

    Property GridDataItem.State(Value As Integer)
        FState = Value
        #IfNDef __USE_GTK__
			If Parent AndAlso Parent->Handle Then
				Var ItemIndex = GetItemIndex
				If ItemIndex = -1 Then Exit Property
				lviItem.Mask = LVIF_STATE
				lviItem.iItem = ItemIndex
				lviItem.iSubItem   = 0
				lviItem.State    = INDEXTOSTATEIMAGEMASK(Value)
				lviItem.stateMask = LVIS_STATEIMAGEMASK
				ListView_SetItem(Parent->Handle, @lviItem)
			End If
		#EndIf 
    End Property
    
    

    Property GridDataItem.Indent As Integer
        Return FIndent
    End Property

    Property GridDataItem.Indent(Value As Integer)
        FIndent = Value
        #IfNDef __USE_GTK__
			If Parent AndAlso Parent->Handle Then
				Var ItemIndex = GetItemIndex
				If ItemIndex = -1 Then Exit Property
				lviItem.Mask = LVIF_INDENT
				lviItem.iItem = ItemIndex
				lviItem.iSubItem   = 0
				lviItem.iIndent    = Value
				ListView_SetItem(Parent->Handle, @lviItem)
			End If
		#EndIf 
    End Property

    Property GridDataItem.Hint ByRef As WString
        Return WGet(FHint)
    End Property

    Property GridDataItem.Hint(ByRef Value As WString)
        WLet FHint, Value
    End Property


    Property GridDataItem.ImageIndex As Integer
        Return FImageIndex
    End Property

    Property GridDataItem.ImageIndex(Value As Integer)
        If Value <> FImageIndex Then
            FImageIndex = Value
            If Parent Then 
                With QControl(Parent)
                    '.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
                End With
            End If
        End If
    End Property

    Property GridDataItem.SelectedImageIndex As Integer
        Return FImageIndex
    End Property

    Property GridDataItem.SelectedImageIndex(Value As Integer)
        If Value <> FSelectedImageIndex Then
            FSelectedImageIndex = Value
            If Parent Then 
                With QControl(Parent)
                    '.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
                End With
            End If
        End If
    End Property

    Property GridDataItem.Visible As Boolean
        Return FVisible
    End Property
    
    Property GridDataItem.ParentItem As GridDataItem Ptr
        Return FParentItem
    End Property
    
    Property GridDataItem.ParentItem(Value As GridDataItem Ptr)
        FParentItem = Value
    End Property
    
    Property GridDataItem.ImageKey ByRef As WString
        Return WGet(FImageKey)
    End Property

    Property GridDataItem.ImageKey(ByRef Value As WString)
        'If Value <> *FImageKey Then
            WLet FImageKey, Value
            #IfDef __USE_GTK__
            	If Parent AndAlso Parent->widget Then
					gtk_tree_store_set (Cast(GridData Ptr, Parent)->TreeStore, @TreeIter, 0, ToUTF8(Value), -1)
				End If
			#Else
            	If Parent Then 
             	   With QControl(Parent)
              	      '.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
               		End With
            	End If
            #EndIf
        'End If
    End Property

    Property GridDataItem.SelectedImageKey ByRef As WString
        Return WGet(FImageKey)
    End Property

    Property GridDataItem.SelectedImageKey(ByRef Value As WString)
        'If Value <> *FSelectedImageKey Then
            WLet FSelectedImageKey, Value
            If Parent Then 
                With QControl(Parent)
                    '.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
                End With
            End If
        'End If
    End Property

    Property GridDataItem.Visible(Value As Boolean)
        If Value <> FVisible Then
            FVisible = Value
            #IfNDef __USE_GTK__
	            If Parent AndAlso Parent->Handle Then
					Var ItemIndex = GetItemIndex
					If ItemIndex = -1 Then Exit Property
					If Value = False Then
						ListView_DeleteItem(Parent->Handle, ItemIndex)
					End If
    			  End If
    		   #EndIf
        End If
    End Property

    Operator GridDataItem.Cast As Any Ptr
        Return @This
    End Operator

    Constructor GridDataItem
        Items.Clear
        Items.Parent = Parent
        Items.ParentItem = @This
        FHint = CAllocate(0)
        FText = CAllocate(0)
        FVisible    = 1
        Text(0)    = ""
        Hint       = ""
        FImageIndex = -1
        FSelectedImageIndex = -1
        FSmallImageIndex = -1
    End Constructor

    Destructor GridDataItem
    	Items.Clear
        WDeallocate FHint
        WDeallocate FText
        WDeallocate FImageKey
        WDeallocate FSelectedImageKey
        WDeallocate FSmallImageKey
    End Destructor
    
    Sub GridDataColumn.SelectItem
		#IfNDef __USE_GTK__
			If Parent AndAlso Parent->Handle Then ListView_SetSelectedColumn(Parent->Handle, Index)
		#EndIf
    End Sub

    Property GridDataColumn.Text ByRef As WString
        Return WGet(FText)
    End Property

    Property GridDataColumn.Text(ByRef Value As WString)
        WLet FText, Value
        #IfNDef __USE_GTK__
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = TVIF_TEXT
				lvc.iSubItem = Index
				lvc.pszText = FText
				lvc.cchTextMax = Len(*FText)
				ListView_SetColumn(Parent->Handle, Index, @lvc)
			  End If
		#EndIf 
    End Property

    Property GridDataColumn.ColWidth As Integer
        Return FColWidth
    End Property

    Property GridDataColumn.ColWidth(Value As Integer)
        FColWidth = Value
		#IfDef __USE_GTK__
			#IfDef __USE_GTK3__
				If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(-1, Value))
			#Else
				If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(1, Value))
			#EndIf
		#Else
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = LVCF_WIDTH OR LVCF_SUBITEM
				lvc.iSubItem = Index
				lvc.cx = Value
				ListView_SetColumn(Parent->Handle, Index, @lvc)
			  End If
		#EndIf 
    End Property
    
    Property GridDataColumn.ControlType As Integer
        Return FControlType
    End Property
    Property GridDataColumn.ControlType(Value As Integer)
        FControlType = Value 		 
    End Property
    
    Property GridDataColumn.DataType As Integer
        Return FDataType
    End Property
    Property GridDataColumn.DataType(Value As Integer)
        FDataType = Value 		 
    End Property
    
    Property GridDataColumn.Locked(Value As Boolean)
        FLocked = Value		 
    End Property
    Property GridDataColumn.Locked As Boolean
        Return FLocked
    End Property
    
    Property GridDataColumn.SortOrder(Value As SortStyle)
        FSortOrder = Value		 
    End Property
    Property GridDataColumn.SortOrder As SortStyle
        Return FSortOrder
    End Property


    Property GridDataColumn.Format As ColumnFormat
        Return FFormat
    End Property
    Property GridDataColumn.Format(Value As ColumnFormat)
        FFormat = Value
        #IfNDef __USE_GTK__
			If Parent AndAlso Parent->Handle Then
				Dim lvc As LVCOLUMN
				lvc.mask = LVCF_FMT OR LVCF_SUBITEM
				lvc.iSubItem = Index
				lvc.fmt = Value
				ListView_SetColumn(Parent->Handle, Index, @lvc)
			  End If
		#EndIf 
    End Property

    Property GridDataColumn.Hint ByRef As WString
        Return WGet(FHint)
    End Property

    Property GridDataColumn.Hint(ByRef Value As WString)
        WLet FHint, Value
    End Property
    
    Property GridDataColumn.GridEditComboItem byref As Wstring     
		Return *FGridEditComboItem
	End Property

	Property GridDataColumn.GridEditComboItem(byref Value As wstring)
      FGridEditComboItem = Reallocate(FGridEditComboItem, (Len(Value) + 1) * SizeOf(WString))
		*FGridEditComboItem = Value
   end property

    Property GridDataColumn.ImageIndex As Integer
        Return FImageIndex
    End Property

    Property GridDataColumn.ImageIndex(Value As Integer)
        If Value <> FImageIndex Then
            FImageIndex = Value
            If Parent Then 
                With QControl(Parent)
                    '.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
                End With
            End If
        End If
    End Property

    Property GridDataColumn.Visible As Boolean
        Return FVisible
    End Property

    Property GridDataColumn.Visible(Value As Boolean)
        If Value <> FVisible Then
            FVisible = Value
            If Parent Then 
                With QControl(Parent)
                    '.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
                End With
            End If
        End If
    End Property

	Property GridDataColumn.Editable As Boolean
        Return FEditable
    End Property

    Property GridDataColumn.Editable(Value As Boolean)
        If Value <> FEditable Then
            FEditable = Value
        End If
    End Property

    Operator GridDataColumn.Cast As Any Ptr
        Return @This
    End Operator

    Constructor GridDataColumn
        FHint = CAllocate(0)
        FText = CAllocate(0)
        FVisible    = 1
        Text    = ""
        Hint       = ""
        FImageIndex = -1
        FGridEditComboItem =CAllocate(0)
    End Constructor

    Destructor GridDataColumn
        If FHint Then Deallocate FHint
        If FText Then Deallocate FText
        If FGridEditComboItem Then Deallocate FGridEditComboItem
    End Destructor

    Property GridDataItems.Count As Integer
        Return FItems.Count
    End Property

    Property GridDataItems.Count(Value As Integer)
    End Property

    Property GridDataItems.Item(Index As Integer) As GridDataItem Ptr
        Return QGridDataItem(FItems.Items[Index])
    End Property

    Property GridDataItems.Item(Index As Integer, Value As GridDataItem Ptr)
       'QToolButton(FItems.Items[Index]) = Value 
    End Property
    
    #IfDef __USE_GTK__
	    Function GridDataItems.FindByIterUser_Data(User_Data As Any Ptr) As GridDataItem Ptr
			If ParentItem AndAlso ParentItem->TreeIter.User_Data = User_Data Then Return ParentItem
			For i as integer = 0 to Count - 1
				PItem = Item(i)->Items.FindByIterUser_Data(User_Data)
				If PItem <> 0 Then Return PItem
			Next i
			Return 0
	    End Function
	#Else
	   	Function GridDataItems.FindByHandle(Value As LParam) As GridDataItem Ptr
			If ParentItem AndAlso ParentItem->Handle = Value Then Return ParentItem
			'For i as integer = 0 to Count - 1
         For i as integer = 0 to FItems.Count - 1   
				PItem = Item(i)->Items.FindByHandle(Value)
				If PItem <> 0 Then Return PItem
			Next i
			Return 0
	    End Function
	#EndIf
	
	Property GridDataItems.ParentItem As GridDataItem Ptr
        Return FParentItem
    End Property
    
    Property GridDataItems.ParentItem(Value As GridDataItem Ptr)
        FParentItem = Value
    End Property

    Function GridDataItems.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As GridDataItem Ptr
        PItem = New GridDataItem
        FItems.Add PItem
        With *PItem
            .ImageIndex     = FImageIndex
            '.Text(0)        = str(FItems.count)
            .Text(0)        = FCaption
            .State        = State
            If ParentItem Then
            	.Indent        = ParentItem->Indent + 1
            Else
            	.Indent        = 0
            End If
            .Parent         = Parent
            #IfNDef __USE_GTK__
            	.Handle = Cast(LParam, PItem)
            #EndIf
            .Items.Parent         = Parent
            .ParentItem        = ParentItem
            If FItems.Count = 1 AndAlso ParentItem Then
            	ParentItem->State = IIF(ParentItem->IsExpanded, 2, 1)
            End If
        	#IfDef __USE_GTK__
				If Parent AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
					Cast(GridData Ptr, Parent)->Init
					If ParentItem <> 0 Then
						gtk_tree_store_append (Cast(GridData Ptr, Parent)->TreeStore, @PItem->TreeIter, @.ParentItem->TreeIter)
					Else
						gtk_tree_store_append (Cast(GridData Ptr, Parent)->TreeStore, @PItem->TreeIter, NULL)
        			End If
        			gtk_tree_store_set (Cast(GridData Ptr, Parent)->TreeStore, @PItem->TreeIter, 1, ToUtf8(FCaption), -1)
				End If
				PItem->Text(0) = FCaption
	        #Else
	        	If CInt(Parent) AndAlso CInt(Parent->Handle) AndAlso CInt(CInt(ParentItem = 0) OrElse CInt(ParentItem->IsExpanded)) Then
					lviItems.Mask = LVIF_TEXT or LVIF_IMAGE or LVIF_STATE or LVIF_INDENT or LVIF_PARAM
					'lviItems.pszText  = @FCaption
					lviItems.cchTextMax = Len(FCaption)
					lviItems.iItem = FItems.Count - 1
					lviItems.iSubItem = 0
					lviItems.iImage   = FImageIndex
					lviItems.State   = INDEXTOSTATEIMAGEMASK(State)
					lviItems.stateMask = LVIS_STATEIMAGEMASK
					lviItems.iIndent   = .Indent
					lviItems.LParam = Cast(LParam, PItem)
					ListView_InsertItem(Parent->Handle, @lviItems)
				End If
			#EndIf
		End With
		Return PItem
    End Function
    
    Function GridDataItems.Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, Indent As Integer = 0) As GridDataItem Ptr
        If Parent AndAlso Cast(GridData Ptr, Parent)->Images Then
            PItem = Add(FCaption, Cast(GridData Ptr, Parent)->Images->IndexOf(FImageKey), State, Indent)
        Else
            PItem = Add(FCaption, -1, State, Indent)
        End If
        If PItem Then PItem->ImageKey = FImageKey
        Return PItem
    End Function

    Function GridDataItems.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As GridDataItem Ptr
        Dim As GridDataItem Ptr PItem
        #IfNDef __USE_GTK__
			Dim As LVITEM lvi
		#EndIf
        PItem = New GridDataItem
        FItems.Insert Index, PItem
        With *PItem
            .ImageIndex     = FImageIndex
            .Text(0)        = FCaption
            .State          = State
            If ParentItem Then
            	.Indent        = ParentItem->Indent + 1
            Else
            	.Indent        = 0
            End If
            #IfNDef __USE_GTK__
            	.Handle 		= Cast(LParam, PItem)
            #EndIf
            .Parent         = Parent
            .Items.Parent         = Parent
            .ParentItem        = Cast(GridDataItem Ptr, ParentItem)
            If FItems.Count = 1 AndAlso ParentItem Then
            	ParentItem->State = IIF(ParentItem->IsExpanded, 2, 1)
            End If
	        #IfDef __USE_GTK__
	        #Else
				If Parent AndAlso Parent->Handle Then 
					lvi.Mask = LVIF_TEXT or LVIF_IMAGE or LVIF_State or LVIF_Indent or LVIF_PARAM
					lvi.pszText  = @FCaption
					lvi.cchTextMax = Len(FCaption)
					lvi.iItem = Index
					lvi.iImage   = FImageIndex
					lvi.State   = INDEXTOSTATEIMAGEMASK(State)
					lvi.stateMask = LVIS_STATEIMAGEMASK
					lvi.iIndent   = .Indent
					lvi.LParam = Cast(LParam, PItem)
					ListView_InsertItem(Parent->Handle, @lvi)
				End If
			#EndIf
		End With
        Return PItem
    End Function

    Sub GridDataItems.Remove(Index As Integer)
        #IfDef __USE_GTK__
        	If Parent AndAlso Parent->widget Then
				gtk_tree_store_remove(Cast(GridData Ptr, Parent)->TreeStore, @This.Item(Index)->TreeIter)
			End If
        #Else
			If Parent AndAlso Parent->Handle Then
				Item(Index)->Visible = False
			End If
		#EndIf
		FItems.Remove Index
    End Sub	
	
'	#IfNDef __USE_GTK__
'		Function CompareFunc( lParam1 As LPARAM, lParam2 As LPARAM, lParamSort As LPARAM) As Long
'			Return 0
'		End Function
'	#EndIf
     
'    Sub GridDataItems.Sort
'		#IfNDef __USE_GTK__
'			If Parent AndAlso Parent->Handle Then
'				Parent->Perform LVM_SORTITEMS, 0, @CompareFunc
'				ListView_SortItems 
'			End If
'		#EndIf
'    End Sub
    
    Function GridDataItems.IndexOf(BYREF FItem As GridDataItem Ptr) As Integer
        Return FItems.IndexOF(FItem)
    End Function

    Function GridDataItems.IndexOf(ByRef Caption As WString) As Integer
        For i As Integer = 0 To FItems.Count - 1
            If QGridDataItem(FItems.Items[i]).Text(0) = Caption Then
                Return i
            End If 
        Next i
        Return -1
    End Function

    Function GridDataItems.Contains(ByRef Caption As WString) As Boolean
        Return IndexOf(Caption) <> -1
    End Function

    Sub GridDataItems.Clear
		#IfDef __USE_GTK__
			If Parent AndAlso Cast(GridData Ptr, Parent)->TreeStore Then gtk_tree_store_clear(Cast(GridData Ptr, Parent)->TreeStore)
		#Else
			If Parent AndAlso Parent->Handle Then Parent->Perform LVM_DELETEALLITEMS, 0, 0 
        #EndIf
        For i As Integer = FItems.Count -1 To 0 Step -1
            Delete Cast(GridDataItem Ptr, FItems.Items[i])
        Next i
        FItems.Clear
    End Sub

    Operator GridDataItems.Cast As Any Ptr
        Return @This
    End Operator

    Constructor GridDataItems
        This.Clear
    End Constructor

    Destructor GridDataItems
         This.Clear
    End Destructor

    Property GridDataColumns.Count As Integer
        Return FColumns.Count
    End Property

    Property GridDataColumns.Count(Value As Integer)
    End Property

    Property GridDataColumns.Column(Index As Integer) As GridDataColumn Ptr
        Return QGridDataColumn(FColumns.Items[Index])
    End Property

    Property GridDataColumns.Column(Index As Integer, Value As GridDataColumn Ptr)
       'QGridDataColumn(FColumns.Items[Index]) = Value 
    End Property

	#IfDef __USE_GTK__
		Sub GridDataColumns.Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
			Dim As GridDataColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As GridData Ptr lv = Cast(GridData Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(gtk_tree_view(lv->Widget))
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				If lv->OnCellEdited Then lv->OnCellEdited(*lv, lv->ListItems.FindByIterUser_Data(iter.User_Data), PColumn->Index, *new_text)
				'gtk_tree_store_set(lv->TreeStore, @iter, PColumn->Index + 1, ToUtf8(*new_text), -1)
			End If
		End Sub
		
		Sub GridDataColumns.Cell_Editing(cell As GtkCellRenderer Ptr, editable As GtkCellEditable Ptr, path As const gchar Ptr, user_data As Any Ptr)
			Dim As GridDataColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As GridData Ptr lv = Cast(GridData Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(gtk_tree_view(lv->Widget))
			Dim As Control Ptr CellEditor
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				If lv->OnCellEditing Then lv->OnCellEditing(*lv, lv->ListItems.FindByIterUser_Data(iter.User_Data), PColumn->Index, CellEditor)
				If CellEditor <> 0 Then editable = gtk_cell_editable(CellEditor->Widget)
			End If
		End Sub
	#EndIf

    Function GridDataColumns.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, tFormat As ColumnFormat = cfLeft, ColEditable As Boolean = True,tDataType As GridDataTypeEnum = DT_String,tLocked As Boolean=False,tControlType As GridControlTypeEnum=CT_TextBox,ByRef tComboItem As WString = "",tSortOrder As SortStyle=ssSortAscending) As GridDataColumn Ptr
        Dim As GridDataColumn Ptr PColumn
        Dim As Integer Index
        #IfNDef __USE_GTK__
			Dim As LVCOLUMN lvc
        #EndIf
        PColumn = New GridDataColumn
        FColumns.Add PColumn
        Index = FColumns.Count - 1 
        With *PColumn
            .ImageIndex     = FImageIndex
            .Text        = FCaption            
            .Index = Index             
            .ColWidth     = iWidth            
            .Format = tFormat
            .Editable=ColEditable
            .DataType =tDataType 
            .Locked=tLocked
            .ControlType=tControlType
            .SortOrder=tSortOrder
            .GridEditComboItem= tComboItem            
        End With
        #IfDef __USE_GTK__
			If Parent Then
				With *Cast(ListView Ptr, Parent)
				If .ColumnTypes Then Delete [] .ColumnTypes
				.ColumnTypes = New GType[Index + 2]
				For i As Integer = 0 To Index + 1
					.ColumnTypes[i] = G_TYPE_STRING
				Next i
				End With
				PColumn->Column = gtk_tree_view_column_new()
				Dim As GtkCellRenderer Ptr rendertext = gtk_cell_renderer_text_new ()
				If ColEditable Then
					Dim As GValue bValue '= G_VALUE_INIT
					g_value_init_(@bValue, G_TYPE_BOOLEAN)
					g_value_set_boolean(@bValue, TRUE)
					g_object_set_property(G_OBJECT(rendertext), "editable", @bValue)
					g_object_set_property(G_OBJECT(rendertext), "editable-set", @bValue)
					g_value_unset(@bValue)
					'Dim bTrue As gboolean = True
					'g_object_set(rendertext, "mode", GTK_CELL_RENDERER_MODE_EDITABLE, NULL)
					'g_object_set(gtk_cell_renderer_text(rendertext), "editable-set", true, NULL)
					'g_object_set(rendertext, "editable", bTrue, NULL)
				End If
				If Index = 0 Then
					Dim As GtkCellRenderer Ptr renderpixbuf = gtk_cell_renderer_pixbuf_new()
					gtk_tree_view_column_pack_start(PColumn->Column, renderpixbuf, False)
					gtk_tree_view_column_add_attribute(PColumn->Column, renderpixbuf, ToUTF8("icon_name"), 0)
				End If
				g_signal_connect(G_OBJECT(rendertext), "edited", G_CALLBACK (@Cell_Edited), PColumn)
				g_signal_connect(G_OBJECT(rendertext), "editing-started", G_CALLBACK (@Cell_Editing), PColumn)
				gtk_tree_view_column_pack_start(PColumn->Column, rendertext, True)
				gtk_tree_view_column_add_attribute(PColumn->Column, rendertext, ToUTF8("text"), Index + 1)
				gtk_tree_view_column_set_resizable(PColumn->Column, True)
				gtk_tree_view_column_set_title(PColumn->Column, ToUTF8(FCaption))
				gtk_tree_view_append_column(GTK_TREE_VIEW(Cast(ListView Ptr, Parent)->widget), PColumn->Column)
				#IfDef __USE_GTK3__
					gtk_tree_view_column_set_fixed_width(PColumn->Column, Max(-1, iWidth))
				#Else
					gtk_tree_view_column_set_fixed_width(PColumn->Column, Max(1, iWidth))
				#EndIf
			End If
        #Else
			lvC.mask      =LVCF_FMT Or LVCF_IMAGE 'OR LVCF_WIDTH OR LVCF_SUBITEM OR LVCFMT_IMAGE 'LVCF_TEXT |LVCF_WIDTH| LVCF_FMT |LVCF_SUBITEM
			lvC.fmt       =  LVCFMT_LEFT Or LVCFMT_IMAGE Or LVCFMT_COL_HAS_IMAGES OR HDF_OWNERDRAW  'tFormat
			lvc.cx		  = IIF(iWidth = -1, 50, iWidth)          
			lvc.iImage   = PColumn->ImageIndex
			lvc.iSubItem = PColumn->Index         
			'lvc.pszText  = @FCaption
			lvc.cchTextMax = Len(FCaption)          
		#EndIf
		If Parent Then
			PColumn->Parent = Parent
			#IfDef __USE_GTK__
				
			#Else
				If Parent->Handle Then
					ListView_InsertColumn(Parent->Handle, PColumn->Index, @lvc)              
				End If
			#EndIf
		End If
        Return PColumn
    End Function

    Sub GridDataColumns.Insert(Index As Integer,ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, tFormat As ColumnFormat = cfLeft, ColEditable As Boolean = True,tDataType As GridDataTypeEnum = DT_String,tLocked As Boolean=False,tControlType As GridControlTypeEnum=CT_TextBox,ByRef tComboItem As WString = "",tSortOrder As SortStyle=ssSortAscending)
        Dim As GridDataColumn Ptr PColumn
        #IfNDef __USE_GTK__
			Dim As LVCOLUMN lvc
        #EndIf
        PColumn = New GridDataColumn
        FColumns.Insert Index, PColumn
        With *PColumn
            .ImageIndex     = FImageIndex
            .Text        = FCaption
            .Index        = FColumns.Count - 1
            .ColWidth     = iWidth            
            .Format = tFormat
            .Editable=ColEditable
            .DataType =tDataType 
            .Locked=tLocked
            .ControlType=tControlType
            .SortOrder=tSortOrder 
            .GridEditComboItem= tComboItem
        End With
		#IfNDef __USE_GTK__
			lvC.mask      =  LVCF_FMT OR LVCF_WIDTH OR LVCF_TEXT OR LVCF_SUBITEM
			lvC.fmt       =  tFormat
			lvc.cx=0
			lvc.iImage   = PColumn->ImageIndex
			lvc.iSubItem = PColumn->Index
			'lvc.pszText  = @FCaption
			lvc.cchTextMax = Len(FCaption)
			If Parent Then
				PColumn->Parent = Parent
				If Parent->Handle Then
					ListView_InsertColumn(Parent->Handle, Index, @lvc)
					ListView_SetColumnWidth(Parent->Handle, Index, iWidth)
				End If
			End If
		#EndIf
    End Sub

    Sub GridDataColumns.Remove(Index As Integer)
        FColumns.Remove Index
        #IfNDef __USE_GTK__
			If Parent AndAlso Parent->Handle Then
				Parent->Perform LVM_DELETECOLUMN, cast(WPARAM, Index), 0
			End If
		#EndIf
    End Sub

    Function GridDataColumns.IndexOf(BYREF FColumn As GridDataColumn Ptr) As Integer
        Return FColumns.IndexOF(FColumn)
    End Function

    Sub GridDataColumns.Clear
        For i As Integer = Count -1 To 0 Step -1
            Delete @QGridDataColumn(FColumns.Items[i])
            Remove i
        Next i
        FColumns.Clear
    End Sub

    Operator GridDataColumns.Cast As Any Ptr
        Return @This
    End Operator

    Constructor GridDataColumns
        This.Clear
    End Constructor

    Destructor GridDataColumns
         This.Clear         
    End Destructor
    
    Sub GridData.Init()
    	#IfDef __USE_GTK__
			If gtk_tree_view_get_model(gtk_tree_view(widget)) = NULL Then
				gtk_tree_store_set_column_types(TreeStore, Columns.Count + 1, ColumnTypes)
				gtk_tree_view_set_model(gtk_tree_view(widget), GTK_TREE_MODEL(TreeStore))
				gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), true)
			End If
      #else
        FLvi.iSubItem=0
        FLvi.iItem=0
		#EndIf
    End Sub
    
    Property GridData.ColumnHeaderHidden As Boolean
        Return FColumnHeaderHidden
    End Property

    Property GridData.ColumnHeaderHidden(Value As Boolean)
        FColumnHeaderHidden = Value
        #IfDef __USE_GTK__
			gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), Not Value)
        #Else
			ChangeStyle LVS_NOCOLUMNHEADER, Value
		#EndIf
    End Property
    
    Property GridData.SingleClickActivate As Boolean
        Return FSingleClickActivate
    End Property

    Property GridData.SingleClickActivate(Value As Boolean)
        FSingleClickActivate = Value
        #IfDef __USE_GTK__
        	#IfDef __USE_GTK3__
				gtk_tree_view_set_activate_on_single_click(GTK_TREE_VIEW(widget), Value)
        	#Else
        		
        	#EndIf
        #Else
			
		#EndIf
    End Property

    Property GridData.View As ViewStyle
        #IfNDef __USE_GTK__
			If Handle Then 
				FView = ListView_GetView(Handle)
			End If
		#EndIf
        Return FView
    End Property

    Property GridData.View(Value As ViewStyle)
        FView = Value
		#IfNDef __USE_GTK__
			If Handle Then Perform LVM_SETVIEW, cast(wparam, cast(dword, Value)), 0
		#EndIf
    End Property

    Property GridData.SelectedItem As GridDataItem Ptr
        #IfDef __USE_GTK__
        	Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Return ListItems.FindByIterUser_Data(iter.User_Data)
			End If
        #Else
			If Handle Then
				Dim As Integer item = ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
				If item <> -1 Then Return GetGridDataItem(item)
			End If
		#EndIf
        Return 0
    End Property
    
    Property GridData.SelectedItemIndex As Integer
        #IfDef __USE_GTK__
        	Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Dim As GridDataItem Ptr lvi = ListItems.FindByIterUser_Data(iter.User_Data)
				If lvi <> 0 Then Return lvi->Index
			End If
        #Else
			If Handle Then
				Return ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
			End If
		#EndIf
        Return -1
    End Property
    
    Property GridData.SelectedItemIndex(Value As Integer)
        #IfDef __USE_GTK__
			If TreeSelection Then
				If Value = -1 Then
					gtk_tree_selection_unselect_all(TreeSelection)
				ElseIf Value > -1 AndAlso Value < ListItems.Count Then
					gtk_tree_selection_select_iter(TreeSelection, @ListItems.Item(Value)->TreeIter)
					gtk_tree_view_scroll_to_cell(gtk_tree_view(widget), gtk_tree_model_get_path(gtk_tree_model(TreeStore), @ListItems.Item(Value)->TreeIter), NULL, False, 0, 0)
				End If
			End If
		#Else
			If Handle Then
				Dim lvi As LVITEM
				lvi.iItem = Value
				lvi.iSubItem   = 0
				lvi.state    = LVIS_SELECTED
				lvi.statemask = LVNI_SELECTED
				ListView_SetItem(Handle, @lvi)
			End If
		#EndIf
    End Property   
     
    Property GridData.HandleHeader As HWND
         Return FHandleHeader
    end property
    Property GridData.HandleHeader(Value As HWND)       
         FHandleHeader=Value
         FGridDataDCHeader = GetDC(FHandleHeader)
    end property

   
   Sub GridData.SetGridLines(tDrawMode As GridLinesEnum=GRIDLINE_Both,tColorLine as integer=clSilver,tColorSelected as integer =clYellow,tColorHover as integer =clLime,tWidth as integer=1,PenMode as integer=PS_SOLID)
      muGridLineDrawMode = tDrawMode
      muGridColorLine = tColorLine
      muGridLineWidth = tWidth
      muGridLinePenMode = PenMode
      muGridColorSelected=tColorSelected     
      muGridColorHover=tColorHover     
   End Sub

    Property GridData.RowHeightHeader As INTEGER 
         Return  FRowHeightHeader
    end property
    Property GridData.RowHeightHeader(Value As INTEGER)       
      dim as integer FSizeHeaderSave
      FRowHeightHeader=iif(Value<18,18,Value) 
      'FRowHeight=(18+(Fsize-8)*1.45
       'Fsize=(FRowHeight-18)/1.45+8             
       FSizeHeaderSave=FSizeHeader
       FSizeHeader=iif(Value<18,8,(FRowHeightHeader-18)/1.45+8)            
       If FontHandleHeader Then DeleteObject(FontHandleHeader)  
       FontHandleHeader=CreateFontW(-MulDiv(FSizeHeader,FcyPixelsHeader,72),0,FOrientationHeader*FSizeHeader,FOrientationHeader*FSizeHeader,FBoldsHeader(Abs_(FBoldHeader)),FItalicHeader,FUnderlineHeader,FStrikeoutHeader,FCharSetHeader,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*FNameHeader)
       SendMessage(FHandleHeader, WM_SETFONT,CUInt(FontHandleHeader),True) 'enlarge the height of header
       'SelectObject(FGridDataDCHeader,FontHandleBody)            
                    
       FSizeHeader=FSizeHeaderSave
       If FontHandleHeader Then DeleteObject(FontHandleHeader)  
       FontHandleHeader=CreateFontW(-MulDiv(FSizeHeader,FcyPixelsHeader,72),0,FOrientationHeader*FSizeHeader,FOrientationHeader*FSizeHeader,FBoldsHeader(Abs_(FBoldHeader)),FItalicHeader,FUnderlineHeader,FStrikeoutHeader,FCharSetHeader,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*FNameHeader)
       SelectObject(FGridDataDCHeader,FontHandleHeader)        
    end property
     
    Sub GridData.SetFontHeader(tFontColor as integer=CLBlack,tNameHeader as wString="TAHOMA",tSizeHeader as integer=10,tCharSetHeader as INteger=FontCharset.Default,tBoldsHeader As Boolean=False,tItalicHeader as Boolean=False,tUnderlineHeader as Boolean=False,tStrikeoutHeader as Boolean=False)
        FForeColorHeader=tFontColor
        WLET FNameHeader, tNameHeader 
        FSizeHeader=tSizeHeader
        FBoldHeader=tBoldsHeader
        FItalicHeader =tItalicHeader
        FUnderlineHeader=tUnderlineHeader
        FStrikeoutHeader=tStrikeoutHeader
        FCharSetHeader=tCharSetHeader 
       If FontHandleHeader Then DeleteObject(FontHandleHeader)  
       FontHandleHeader=CreateFontW(-MulDiv(FSizeHeader,FcyPixelsHeader,72),0,FOrientationHeader*FSizeHeader,FOrientationHeader*FSizeHeader,FBoldsHeader(Abs_(FBoldHeader)),FItalicHeader,FUnderlineHeader,FStrikeoutHeader,FCharSetHeader,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*FNameHeader)
       SelectObject(FGridDataDCHeader,FontHandleHeader)
       
     end Sub
      
     Sub GridData.SetFont(tFontColor as integer=CLBlack,tName as wString="TAHOMA",tSize as integer=10,tCharSet as INteger=FontCharset.Default,tBolds As Boolean=False,tItalic as Boolean=False,tUnderline as Boolean=False,tStrikeout as Boolean=False)
        FForeColor=tFontColor
        WLET FName, tName 
        FSize=tSize
        FBold=tBolds
        FItalic =tItalic
        FUnderline=tUnderline
        FStrikeout=tStrikeout
        FCharSet=tCharSet
        If FontHandleBody Then DeleteObject(FontHandleBody)  
        FontHandleBody=CreateFontW(-MulDiv(FSize,FcyPixels,72),0,FOrientation*FSize,FOrientation*FSize,FBolds(Abs_(FBold)),FItalic,FUnderline,FStrikeout,FCharSet,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*FName)
        SelectObject(FGridDataDC,FontHandleBody)
        Dim Sz As SIZE			
		  GetTextExtentPoint32(FGridDataDC,"B",Len("B"),@Sz) 
        FontHeight=Sz.cY
        FontWidth=Sz.cX
     end Sub
     
    Property GridData.ShowHoverBar As Boolean 
         Return  mShowHoverBar
    end property
    Property GridData.ShowHoverBar(Value As Boolean)
        mShowHoverBar=Value
    end property
    
    Property GridData.ShowSelection As Boolean 
         Return  mShowSelection
    end property
    Property GridData.ShowSelection(Value As Boolean)
        mShowSelection=Value
    end property

    Property GridData.RowHeight As INTEGER 
         Return  FRowHeight
    end property
    Property GridData.RowHeight(Value As INTEGER)
      dim as integer FSizeSave
      FRowHeight=iif(Value<18,18,Value) 
      'FRowHeight=(18+(Fsize-8)*1.45       
      This.Font.Size=(FRowHeight-18)/1.45+8
      FRowHeight=-1             
    end property

    Property GridData.SelectedItem(Value As GridDataItem Ptr)
        Value->SelectItem
    End Property

    Property GridData.SelectedColumn As GridDataColumn Ptr
        #IfNDef __USE_GTK__
			If Handle Then
				Return Columns.Column(ListView_GetSelectedColumn(Handle))
			End If
		#EndIf
        Return 0
    End Property
    
    #IfNDef __USE_GTK__
	    Function GridData.GetGridDataItem(iItem As Integer) As GridDataItem Ptr
	    	Dim lvi As LVITEM
			lvi.mask = LVIF_PARAM
			lvi.iItem = iItem
			If ListView_GetItem(Handle, @lvi) Then
				Return Cast(GridDataItem Ptr, lvi.LParam)
			End If
			Return 0
	    End Function
	#EndIf
    
    Property GridData.Sort As SortStyle
        Return FSortStyle
    End Property

    Property GridData.Sort(Value As SortStyle)
        FSortStyle = Value
        #IfNDef __USE_GTK__
			Select Case FSortStyle
			Case ssNone
				ChangeStyle LVS_SORTASCENDING, False
				ChangeStyle LVS_SORTDESCENDING, False
			Case ssSortAscending
				ChangeStyle LVS_SORTDESCENDING, False
				ChangeStyle LVS_SORTASCENDING, True
			Case ssSortDescending
				ChangeStyle LVS_SORTASCENDING, False
				ChangeStyle LVS_SORTDESCENDING, True
			End Select
		#EndIf
    End Property

    Property GridData.SelectedColumn(Value As GridDataColumn Ptr)
        #IfNDef __USE_GTK__
			If Handle Then ListView_SetSelectedColumn(Handle, Value->Index)
		#endif
    End Property

    Property GridData.ShowHint As Boolean
        Return FShowHint
    End Property

    Property GridData.ShowHint(Value As Boolean)
        FShowHint = Value
    End Property

	Sub GridData.WndProc(ByRef Message As Message)
	End Sub
   
   Sub GridData.DrawLine(tDC As HDC, x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer, lColor As Integer=-1, lWidth As Integer = 1,lLineType As Integer = PS_SOLID)
       Dim pt As LPPOINT
    If lColor<>-1 Then
        Static As  HPEN hPen,hPenSele          
         hPen = CreatePen(lLineType, lWidth, lColor)         
         hPenSele = SelectObject(tDC, hPen)         
         MoveToEx tDC, x1, y1, pt
         LineTo tDC, x2, y2
        SelectObject tDC, hPenSele
        DeleteObject hPen
    Else
       MoveToEx tDC, x1, y1, pt
       LineTo tDC, x2, y2
    End If      
   End Sub
	Sub GridData.DrawRect(tDc As hDC,R As Rect,FillColor As Integer = -1,tRowSelction As Integer = -1)
      #ifndef __USE_GTK__
			Static As HBRUSH BSelction
         Static As HBRUSH BCellBack			
			Static As Integer FillColorSave         
         Dim As LPPOINT lppt        			
         If CInt(tRowSelction=mRow) And CInt(mShowSelection) Then
             If BSelction <> 0 Then BSelction=CreateSolidBrush(muGridColorSelected)
             FillRect tDc,@R,BSelction             
         Else
            If FillColor<>FillColorSave  Then 
               If BCellBack Then DeleteObject BCellBack
               If FillColor <> -1 Then 
                BCellBack = CreateSolidBrush(FillColor)			   
               Else
                BCellBack = CreateSolidBrush(clWhite)         
               End If
            End If
            FillColorSave=FillColor
            'DrawEdge tDc,@R,BDR_RAISEDINNER,BF_FLAT'BF_BOTTOM
            If muGridLineDrawMode = GRIDLINE_None  Then  ' GRIDLINE_None Both GRIDLINE_Vertical GRIDLINE_Horizontal Then 
               DrawEdge tDc,@R,BDR_SUNKENOUTER,BF_FLAT
               'InflateRect(@R, -1, -1)     
               FillRect tDc,@R,BCellBack
            Else
               FillRect tDc,@R,BCellBack           
            End If
         End If   
            
         'https://docs.microsoft.com/zh-cn/windows/win32/api/winuser/nf-winuser-drawedge 
         'DrawEdge tDc,@R,BDR_RAISEDINNER,BF_BOTTOM
         'MoveToEx tDc,R.Left,R.bottom,lppt            
         'LineTo tDc, R.Right,R.bottom   
		#endif
    End Sub
 Sub GridData.GridDrawHeader(ColShowStart As Integer=0, ColShowEnd As Integer=0)
'     Dim As RECT REC
'     Dim As String sText 
'     Dim As hDC FGridDataDCHeader
'  'Draw Header
'     'FGridDataDCHeader = GetDC(FHandleHeader)
'    ' SetBkMode FGridDataDCHeader, TRANSPARENT
'    ' SetTextColor(FGridDataDCHeader, clGreen)
'     ColShowEnd=iif(ColShowEnd<=0,Columns.Count,ColShowEnd)       
'     For iCol As Integer = ColShowStart To ColShowEnd
'         sText="Col" + Chr(13)+Chr(10)+str(iCol)'Columns.Column(iCol)->Text
'         ListView_GetSubItemRect(FHandleHeader, 0, iCol, LVIR_BOUNDS, @REC) '
'         'REC.Top = 10:REC.Left = iCol*200:REC.Right = 280:REC.Bottom =50
'         'print "ColShowEnd,Top,Left,Right,Bottom ",ColShowEnd, REC.Top ,REC.Left,REC.Right,REC.Bottom
'         DrawText(FGridDataDCHeader, sText, -1, @REC, DT_VCENTER Or DT_CENTER) 
'     Next
'     ReleaseDC(FHandleHeader, FGridDataDCHeader)     
 End Sub
   
Sub GridData.GridReDraw(RowShowStart As Integer, RowShowEnd As Integer,RowHover As Integer=-1, ColHover As Integer=-1)
   'https://blog.csdn.net/hurryboylqs/article/details/5858997
   
  Dim As String sText 
  Dim As Integer iColEnd=Columns.Count-1,iRow=0, iCol=0, iColStart=-1,iCT,GridWidth,GridHeight 
  Dim As Integer iColorBK  
  Dim si As SCROLLINFO
  Dim As RECT REC(iColEnd),RECHeader,RECbody             
  
  Dim pt As LPPOINT
  Static As  HPEN hPen,hPenSele   
  hPen = CreatePen(muGridLinePenMode, muGridLineWidth, muGridColorLine)         
  hPenSele = SelectObject(FGridDataDC, hPen)
  
   si.cbSize = SizeOf (si)
   si.fMask = SIF_ALL
   GetScrollInfo (Handle, SB_HORZ, @si) 'SB_VERT
                   
  ' muGridLineDrawMode = GRIDLINE_Both'None'Both
  If RowShowEnd>ListItems.Count-1 Then RowShowEnd=ListItems.Count-1
  For iCol = 0 To iColEnd                                    
       ListView_GetSubItemRect(Handle, RowShowStart, iCol, LVIR_BOUNDS, @REC(iCol)) 'Nothing   when in NM_CUSTOMDRAW mode       
       If REC(iCol).Right>=This.Width AndAlso iColEnd=Columns.Count AndAlso iCol>0 Then iColEnd=iCol
       If REC(iCol).left>0 AndAlso iColStart=-1 Then iColStart=iCol-1          
       'print "iCol.left" ,iCol, REC(iCol).left
  Next
  If FRowHeight<=0 And iColEnd >= 1 Then  FRowHeight=REC(1).Bottom -REC(1).Top
  If FRowHeightHeader<=0 And iColEnd >= 1 Then FRowHeightHeader=REC(1).Top-1
 
     'print "FRowHeight,FRowHeightHeader " ,FRowHeight,FRowHeightHeader  
    'FRowHeight=(18+(Fsize-8)*1.45
    'Fsize=(FRowHeight-18)/1.45+8 
    If iColEnd >= 1 Then
  GridWidth=REC(0).RIGHT   
  REC(0).RIGHT=REC(1).Left 
End If
  'REC(0).Top=REC(1).Top: REC(0).Bottom=REC(1).Bottom
  If iColStart<0 Then iColStart=0           
  If iColEnd>Columns.Count-1 Then iColStart=Columns.Count-1   
  If FGridDataDC > 0 Then
      For iRow = RowShowStart To RowShowEnd 'ListItems.Count
        For iCol=iColStart To iColEnd
                            
              'FrameRect(FGridDataDC, @REC, hBrush_HP)    '»жЦЖ±Яїт
              'ListView_SetTextColor(Handle,clRed) 'OK. working on ListView itself                                                
              'ListView_GetItemText(Handle, iRow, iCol, @sText, 255)
              'SetItemState (n, 0, LVIS_FOCUSED | LVIS_SELECTED)              
              RecBody= REC(iCol)            
              RecBody.Top=REC(0).Top: RecBody.Bottom=REC(0).Bottom              
              'clWhite'clLtGray'clSilver'cl3DLight'clLtGray
              iColorBK=This.BackColor
              stext=ListItems.Item(iRow)->Text(iCOl)
              iCT=Columns.Column(iCol)->ControlType                  
            Select Case iCT                     
               Case CT_Nothing'=0
                  DrawRect(FGridDataDC, RecBody, clBtnFace,-1)       '»жЦЖ
                  RecBody.Top =(RecBody.Top +RecBody.Bottom)/2-FontHeight/2+3                  
               Case CT_CheckBox '= 1
                    'https://www.cnblogs.com/doudongchun/p/3699719.html                       
                    DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ 
                    RecBody.Top =(RecBody.Top +RecBody.Bottom)/2-9
                    RecBody.Bottom =RecBody.Top+18                                                            
                    If UCase(stext)="TRUE" Or Val(stext)=1 Then                   
                       RecBody.Left =(RecBody.Left+RecBody.RIGHT)/2-9
                       RecBody.Right =RecBody.Left+18
                       DrawFrameControl(FGridDataDC, @RecBody,DFC_BUTTON,DFCS_BUTTONCHECK Or DFCS_CHECKED)
                       stext=""
                    ElseIf UCase(stext)="FALSE" Or Val(stext)=0 Then
                       RecBody.Left =(RecBody.Left+RecBody.RIGHT)/2-9
                       RecBody.Right =RecBody.Left+18
                       DrawFrameControl(FGridDataDC, @RecBody,DFC_BUTTON,DFCS_BUTTONCHECK)
                       stext=""
                    Else
                       RecBody.Left =Rec(iCol).Left+5
                       DrawFrameControl(FGridDataDC, @RecBody,DFC_BUTTON,DFCS_BUTTONCHECK)   
                       RecBody.Left =Rec(iCol).Left+20                       
                       RecBody.Bottom =Rec(iCol).Bottom-3
                    End If                                          
               Case CT_LinkLabel '= 2
                  iColorBK=clGreen
                  DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ
               Case CT_DateTimePicker' = 3
                  DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ
                  RecBody.Top =(RecBody.Top +RecBody.Bottom)/2-FontHeight/2 -9                 
               Case CT_ProgressBar' = 4
                  DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ                                  
                  'sText=iif(val(sText)>100,sText="100%",sText + "%")                  
                   If Val(sText)>100 Then 
                      sText="100%"
                   Else
                      sText=sText + "%"
                   End If
                  InflateRect(@RecBody, -3, -3)                  
                  RecBody.Top =(RecBody.Top +RecBody.Bottom)/2-9
                  RecBody.Bottom =RecBody.Top+18
                  RecBody.Right =RecBody.Left+ (RecBody.Right-RecBody.Left)* Val(sText)/100                    
                  If Val(sText)>0 Then DrawRect(FGridDataDC, RecBody, ClGreen,-1)       '»жЦЖ                                                   
                  RecBody.Right =rec(icol).right
               Case CT_Custom' = 5
                  DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ
               Case CT_Button' = 6
                  DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ
                  'https://docs.microsoft.com/zh-cn/windows/win32/api/winuser/nf-winuser-drawframecontrol
                  DrawFrameControl(FGridDataDC, @RecBody,DFC_BUTTON,DFCS_BUTTON3STATE) 'DFC_BUTTON,DFCS_BUTTONRADIO )              
               Case CT_ComboBoxEdit' = 7
                    'https://www.cnblogs.com/doudongchun/p/3699719.html
                   stext=ListItems.Item(iRow)->Text(iCOl)
                   DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ                   
                  RecBody.Top =(RecBody.Top +RecBody.Bottom)/2-9                                   
                  RecBody.Bottom =RecBody.Top +18
                  RecBody.Left =RecBody.Right-20                    
                  If Len(stext)>0 Then DrawFrameControl(FGridDataDC, @RecBody,DFC_SCROLL,DFCS_SCROLLDOWN) 'DFC_BUTTON,DFCS_BUTTONRADIO )                                  
                  RecBody.Left =Rec(iCol).Left+3
                  RecBody.Right= Rec(iCol).Right-23
               Case CT_TextBox '= 9                                     
                   DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ
                   InflateRect(@RecBody, -3, 0)
                   'RecBody.Top =RecBody.Top+'Infect all GRID  Drawing
               Case Else                   
                   DrawRect(FGridDataDC, RecBody, iColorBK,iRow)       '»жЦЖ
                   InflateRect(@RecBody, -3, 0)
                   'RecBody.Top =RecBody.Top+5
            End Select
            
 '           DrawRect(FGridDataDC, RecBody, iColorBK,0)       '»жЦЖ
            Dim uFormat As Short 
            Select Case Columns.Column(iCol)->DataType         
               Case DT_Nothing '=0                  
               Case DT_Numeric' = 1
                  uFormat=DT_SINGLELINE
               Case DT_LinkLabel' = 2
                  iColorBK=ClGreen
                  uFormat=DT_SINGLELINE
               Case DT_Boolean '= 3
                  uFormat=DT_SINGLELINE
               Case DT_ProgressBar' = 4
                  uFormat=DT_SINGLELINE
               Case DT_Custom '= 5
               Case DT_Button '= 6
                  uFormat=DT_SINGLELINE
               Case DT_ComboBoxEdit' = 7
                  uFormat=DT_SINGLELINE
               Case DT_Date '= 8
                  uFormat=DT_SINGLELINE
               Case Else 'DT_String = 9
                  uFormat=DT_WORDBREAK  'DT_CALCRECT Or DT_WORDBREAK
           End Select               
           If Len(stext)>0 Then
                 'InflateRect(@RecBody, -4, -4)
                 'https://www.cnblogs.com/lingyun1120/archive/2011/11/14/2248072.html
                 If Columns.Column(iCol)->Format=cfleft Then
                    DrawText(FGridDataDC, sText, -1, @RecBody, DT_VCENTER Or DT_LEFT Or uFormat)  'Or DT_SINGLELINE »жЦЖОДЧ 
                 ElseIf Columns.Column(iCol)->Format=cfRight Then
                     DrawText(FGridDataDC, sText, -1, @RecBody, DT_VCENTER Or DT_RIGHT Or uFormat)   'Or DT_SINGLELINE »жЦЖОДЧ 
                 Else
                    DrawText(FGridDataDC, sText, -1, @RecBody, DT_VCENTER Or DT_CENTER Or uFormat) 'Or DT_SINGLELINE »жЦЖОДЧ 
                 EndIf      
           EndIf               
           'Draw Header                           
            If iRow  = RowShowStart Then
               'print "ControlType iCol ",Columns.Column(iCol)->ControlType                 
                sText=Columns.Column(iCol)->Text                                      
                'print "FRowHeightHeader ",FRowHeightHeader
                'print "FRowHeight,FRowHeightHeader iRow  " ,iRow , FRowHeight,FRowHeightHeader ,Rec(0).Top
                RECHeader.Top=0
                RECHeader.Bottom =FRowHeightHeader'REC(0).Top 
                RECHeader.Left=si.nPos+REC(iCol).Left+2
                RECHeader.Right=si.nPos+REC(iCol).Right-1                                                                           
                DrawRect(FGridDataDCHeader, RECHeader,clBtnFace,clRed)       '»жЦЖ
                DrawText(FGridDataDCHeader, sText, -1, @RECHeader, DT_VCENTER Or DT_CENTER)'Or DT_SINGLELINE                    
                RECHeader.Left=RECHeader.Right-12
                RECHeader.Top=RECHeader.Bottom-12
                'https://docs.microsoft.com/zh-cn/windows/win32/api/winuser/nf-winuser-drawframecontrol
                If icol Mod 2 Then
                   DrawFrameControl(FGridDataDCHeader, @RECHeader,DFC_SCROLL,DFCS_SCROLLSIZEGRIP Or DFCS_PUSHED) 'DFC_BUTTON,DFCS_BUTTONRADIO )
                Else
                   DrawFrameControl(FGridDataDCHeader, @RECHeader,DFC_SCROLL,DFCS_SCROLLUP Or DFCS_INACTIVE Or DFCS_MONO) 'DFC_BUTTON,DFCS_BUTTONRADIO )
                EndIf
            End If
            'if irow=RowHover and iCol=ColHover then DrawFocusRect(FGridDataDC, @RecBody)               
          Next           
           If muGridLineDrawMode = GRIDLINE_Both Or muGridLineDrawMode = GRIDLINE_Horizontal Then  ' GRIDLINE_Vertical  
              DrawLine(FGridDataDC,REC(0).Left,RecBody.Top, REC(iColEnd).RIght,RecBody.Top,muGridColorLine,muGridLineWidth,muGridLinePenMode)
           End If
           REC(0).Top=REC(0).Top+FRowHeight
           REC(0).Bottom=REC(0).Top+FRowHeight           
      Next          
      If RowHover>=0 And ColHover>0 And iColEnd >=ColHover Then 'Draw one row only          
         RecBody.left =REC(ColHover).Left+1:   RecBody.Right =REC(ColHover).RIght-1 'GridWidth-1
         RecBody.Top =FRowHeightHeader+FRowHeight*(RowHover-RowShowStart)+2
         RecBody.Bottom =RecBody.Top+ FRowHeight
         'Draw Focus Row
         DrawFocusRect(FGridDataDC, @RecBody)
         
         'Draw Bottom Line of Grid Body
         If muGridLineDrawMode = GRIDLINE_Both Or muGridLineDrawMode = GRIDLINE_Horizontal Then  ' GRIDLINE_None Both GRIDLINE_VerticalThen       
            DrawLine(FGridDataDC,REC(0).Left,RecBody.Top+FRowHeight, REC(iColEnd).RIght,RecBody.Top+FRowHeight,muGridColorLine,muGridLineWidth,muGridLinePenMode)
         End If
         '
         If muGridLineDrawMode = GRIDLINE_Both Or muGridLineDrawMode = GRIDLINE_Vertical Then  ' GRIDLINE_None GRIDLINE_Horizontal Then                
            For iCol=iColStart To iColEnd            
               DrawLine(FGridDataDC,REC(iCol).Left-1,0, REC(iCol).Left-1,REC(0).Bottom,muGridColorLine,muGridLineWidth,muGridLinePenMode)
            Next
            'Draw Right Line of Grid Body
            DrawLine(FGridDataDC,REC(iColEnd).RIght,0, REC(iColEnd).Right,REC(0).Bottom,muGridColorLine,muGridLineWidth,muGridLinePenMode)
         End If 
         
          
         If GridWidth<This.Width Then 'Draw the Blank area at the right
           RecBody.left =GridWidth+1:      RecBody.Right=This.Width
           RecBody.Top =0:                 RecBody.Bottom=This.Height
           DrawRect(FGridDataDC,RecBody, This.BackColor ,-1)       '»жЦЖ        
         End If
         
        If RowShowStart < RowShowEnd Then ' Working when refresh all only, NOT ONE row updated
           GridHeight=REC(0).Bottom-FRowHeight+1
           'print GridHeight,This.Height        
           RecBody.left =0:             RecBody.Right=This.Width
           RecBody.Top =GridHeight:   RecBody.Bottom=This.Height
           DrawRect(FGridDataDC,RecBody,This.BackColor ,-1)       '»жЦЖ        
         End If
      End If       
     RECHeader.Top=-100 :RECHeader.Left=0:RECHeader.bottom = This.Height:RECHeader.Right = This.Width                          
     'InvalidateRect(Handle,@RECHeader,False)
     'InvalidateRect FParent->Handle, 0, True     
     'UpdateWindow Handle
     SelectObject FGridDataDC, hPenSele
     DeleteObject hPen 
  EndIf  
  
End Sub
  Sub GridData.ProcessMessage(ByRef Message As Message)
  '?message.msg, GetMessageName(message.msg)
  #ifdef __USE_GTK__
  Dim As GdkEvent Ptr e = Message.Event
  Select Case Message.Event->Type
      Case GDK_MAP
          Init
  End Select
  #else
  Static  As hDC nmcdhDC '=-1  
  Static As Boolean tSCROLL_HorV ,tRefresh
  Static As Integer  ComboColOld   
  Dim tMOUSEWHEEL As Boolean = False   
  Dim lplvcd As NMLVCUSTOMDRAW Ptr  
  Dim As RECT RECHeader 
  Dim As String sText  
  If CInt(tRefresh) And CInt(WM_PAINT<>Message.Msg) And CInt(Message.Msg<>WM_DRAWITEM) Then Print GetMessageName(message.msg)
  Select Case Message.Msg
      Case WM_PAINT
         'print "WM_PAINT =================="
          message.Result =    CDRF_SKIPDEFAULT ' This is very important for custmor draw
      Case WM_ICONERASEBKGND
          Print " WM_ICONERASEBKGND =================="        
      Case WM_ERASEBKGND
          message.Result =    CDRF_SKIPDEFAULT  ' This is very important for custmor draw
'      case WM_NCHITTEST
'          'print "WM_NCHITTEST =================="      
'          message.Result =    CDRF_SKIPDEFAULT
'      CASE WM_NCPAINT
'         message.Result =    CDRF_SKIPDEFAULT
'      case WM_DRAWITEM '
'          'print "WM_DRAWITEM==================" 
'          'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
'          message.Result =    CDRF_SKIPDEFAULT
      Case WM_SIZE          
          GridEditText.SetBounds 1,1,2,2
          GridEditText.Visible=True
          mCountPerPage = ListView_GetCountPerPage(Handle)          
          mDrawRowStart=ListView_GetTopIndex(Handle)      
          'print "WM_SIZE ------------------------" ,nmcdhDC
          GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
          message.Result =    CDRF_SKIPDEFAULT           
'      Case WM_MOUSEACTIVATE    
      Case WM_MOUSEWHEEL
          'print "WM_MOUSEWHEEL ------------------------"
          'tMOUSEWHEEL = False           
           'message.Result  = CDRF_NOTIFYSUBITEMDRAW 
          'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
         ' tRefresh=not tRefresh 
'          'exit sub
'      case WM_MOUSEMOVE
'          'print "WM_MOUSEMOVE ######## " ,Message.lParamLo,Message.lParamHi 'X,Y
'      case WM_MOUSEHOVER
     
'      case WM_MOUSELEAVE
'          'print "WM_MOUSELEAVE !!!!!!!!!!" 
'      case WM_VSCROLL
'           tSCROLL_HorV=False
'           'print "WM_VSCROLL XXXXXXXXX"
            
'      case WM_HSCROLL
'           tSCROLL_HorV=true
'           'print "WM_HSCROLL !!!!!!!!!!"  
'      Case WM_RBUTTONDOWN             
      Case WM_LBUTTONDOWN
          Dim lvhti As LVHITTESTINFO
          lvhti.pt.x = Message.lParamLo
          lvhti.pt.y = Message.lParamHi
          lvhti.iItem = FLvi.iItem  'Must Let Value
          lvhti.iSubItem = FLvi.iSubItem 'Must Let Value
          'Print "WM_LBUTTONDOWN lvhti.iItem lvhti.iSubItem,x,y ",lvhti.iItem,lvhti.iSubItem ,lvhti.pt.x,lvhti.pt.y
          If (ListView_HitTest(Handle, @lvhti) <> -1) Then
              If (lvhti.flags = LVHT_ONITEMSTATEICON) Then
                  Var tlvi = GetGridDataItem(lvhti.iItem)
                  If tlvi AndAlso tlvi->Items.Count > 0 Then
                      If tlvi->IsExpanded Then
                          tlvi->Collapse
                      Else
                          If OnItemExpanding Then OnItemExpanding(This, tlvi)
                          tlvi->Expand
                      End If
                  End If
              End If
          End If
      Case CM_NOTIFY   '4002
          Dim lvp As NMLISTVIEW Ptr = Cast(NMLISTVIEW Ptr, message.lParam)
          lplvcd = Cast(NMLVCUSTOMDRAW Ptr, message.lParam)    
          'if tRefresh then print "CM_NOTIFY Key ",lvp->iItem,lvp->iSubItem,lplvcd->nmcd.hdr.code 
           
          message.Result = CDRF_DODEFAULT
          'Dim lplvcd As NMLVCUSTOMDRAW Ptr =Cast(NMLVCUSTOMDRAW Ptr, message.lparam)
          Select Case lplvcd->nmcd.hdr.code
             
              Case NM_CUSTOMDRAW
                          message.Result = CDRF_SKIPDEFAULT                          
                          'Print "CM_NOTIFY NM_CUSTOMDRAW mRow, mCol,lplvcd->nmcd.dwItemSpec,mCountPerPage ",mRow, mCol,lplvcd->nmcd.dwItemSpec,mCountPerPage
                          'mCountPerPage=This.Height\ RowHeight +1                           
                          'Print "CM_NOTIFY NM_CUSTOMDRAW nmcdhDC iRow,iCol ", nmcdhDC, iRow, iCol                          
                          'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
                          message.Result = CDRF_SKIPDEFAULT
              Case NM_CLICK
                  'Print "NM_CLICK ", lvp->iItem, lvp->iSubItem    'Nothing   when in NM_CUSTOMDRAW mode  
                  'Updating the input result
                   Select Case Columns.Column(mCol)->ControlType                     
                    'Case CT_Nothing                        
                    'case CT_Button                         
                    'case CT_ProgressBar                        
                    Case CT_ComboBoxEdit   
                      If GridEditComboBox.Visible=True Then ListItems.Item(mRow)->Text(mCol) =GridEditComboBox.Text
                    Case CT_DateTimePicker
                      If GridEditDateTimePicker.Visible=True Then  ListItems.Item(mRow)->Text(mCol) =GridEditDateTimePicker.Text
                    'case CT_CheckBox                                                                                               
                    Case CT_TextBox   
                      If GridEditText.Visible=True Then ListItems.Item(mRow)->Text(mCol)=GridEditText.Text
                    End Select                  
                   GridEditText.Visible =False 
                   GridEditDateTimePicker.Visible =False 
                   GridEditComboBox.Visible =False 
                  FLvi.iItem = lvp->iItem : FLvi.iSubItem = lvp->iSubItem                                  
                  
                  mRow=lvp->iItem: mCol=lvp->iSubItem
                  If mCol>0 AndAlso mRow>=0 Then 
                     'ListView_GetSubItemRect(Handle, mRow, mCol, LVIR_BOUNDS, @RECHeader)
                     'DrawFocusRect(FGridDataDC, @RECHeader)
                    GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
                  EndIf
                                             
                  If OnItemClick Then OnItemClick(This, lvp->iItem, lvp->iSubItem, nmcdhDC)
              Case NM_DBLCLK
                  Print "NM_DBLCLK ", lvp->iItem, lvp->iSubItem                  
                  
                   'Updating the input result
                   Select Case Columns.Column(mCol)->ControlType                     
                    'Case CT_Nothing                        
                    'case CT_Button                         
                    'case CT_ProgressBar                        
                    Case CT_ComboBoxEdit   
                      If GridEditComboBox.Visible=True Then ListItems.Item(mRow)->Text(mCol) =GridEditComboBox.Text
                    Case CT_DateTimePicker
                      If GridEditDateTimePicker.Visible=True Then  ListItems.Item(mRow)->Text(mCol) =GridEditDateTimePicker.Text
                    'case CT_CheckBox                                                                                               
                    Case CT_TextBox   
                      If GridEditText.Visible=True Then ListItems.Item(mRow)->Text(mCol)=GridEditText.Text
                    End Select
                  'Move to new position                   
                   
                 If lvp->iItem>0 AndAlso lvp->iSubItem>=0 Then 
                   mRow=lvp->iItem: mCol=lvp->iSubItem
                   ListView_GetSubItemRect(Handle, mRow, mCol, LVIR_BOUNDS, @RECHeader)
                  ' print "FRowHeight, FRowHeightHeader Before ",FRowHeight, FRowHeightHeader
                  ' FRowHeightHeader=RECHeader.Top-(mRow-mDrawRowStart)*FRowHeight 'For stranger things diffrence about the  position of the TOP row.
                  ' print "FRowHeight, FRowHeightHeader After ",FRowHeight, FRowHeightHeader 
                   sText=ListItems.Item(mRow)->Text(mCol)
                  Select Case Columns.Column(mCol)->ControlType                     
                    Case CT_Nothing
                          GridEditText.Visible =False 
                          GridEditDateTimePicker.Visible =False 
                          GridEditComboBox.Visible =False                      
                    Case CT_Button
                         'GridEditComboBox.Visible=false 'NOT Updating showing in time    ;'False.Left,VisibleFalse.Top,VisibleFalse.Right,VisibleFalse.Bottom
                          GridEditText.Visible =False 
                          GridEditDateTimePicker.Visible =False                       
                          GridEditComboBox.Visible =False                      
                    Case CT_ProgressBar
                       GridEditText.Visible =False 
                       GridEditDateTimePicker.Visible =False                       
                       GridEditComboBox.Visible =False                      
                    Case CT_ComboBoxEdit   
                       GridEditText.Visible =False 
                       GridEditDateTimePicker.Visible =False                                              
                       If ComboColOld<>mCol Then
                            GridEditComboBox.Clear
                            If Len(Columns.Column(mCol)->GridEditComboItem)>0 Then
                               Dim tArray() As UString
                               Split(Columns.Column(mCol)->GridEditComboItem,Chr(9),tArray())
                               For ii As Integer =0 To UBound(tArray)
                                  GridEditComboBox.AddItem  tArray(ii)                
                               Next
                            End If
                            ComboColOld=mCol
                       End If
                       RECHeader.Top =(RECHeader.Top +RECHeader.Bottom)/2-GridEditComboBox.Height/2
                       GridEditComboBox.Visible =True                      
                       GridEditComboBox.SetBounds RECHeader.Left, RECHeader.Top, RECHeader.Right - RECHeader.Left-1, FontHeight*1.2
                       GridEditComboBox.ItemIndex=GridEditComboBox.IndexOf(ListItems.Item(mRow)->Text(mCol))
                       GridEditComboBox.SetFocus
                    Case CT_DateTimePicker
                          GridEditText.Visible =False 
                          GridEditDateTimePicker.Visible =True                       
                          GridEditComboBox.Visible =False                      
                          GridEditDateTimePicker.Text=ListItems.Item(mRow)->Text(mCol)
                          GridEditDateTimePicker.SetBounds RECHeader.Left, RECHeader.Top, RECHeader.Right - RECHeader.Left-1, RECHeader.Bottom - RECHeader.Top
                          GridEditDateTimePicker.SetFocus
                    Case CT_CheckBox                        
                          GridEditText.Visible =False 
                          GridEditDateTimePicker.Visible =False                       
                          GridEditComboBox.Visible =False                      
                         
                         ListItems.Item(mRow)->Text(mCol)=IIf(ListItems.Item(mRow)->Text(mCol)="True","False","True")                         
                         GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)                           
                    Case CT_TextBox   
                         sText=ListItems.Item(mRow)->Text(mCol)                          
                         GridEditText.Visible =True 
                         GridEditDateTimePicker.Visible =False                       
                         GridEditComboBox.Visible =False                      
                         GridEditText.SetBounds RECHeader.Left, RECHeader.Top, RECHeader.Right - RECHeader.Left-1, RECHeader.Bottom - RECHeader.Top
                         
                         GridEditText.Text=sText                         
                         GridEditText.SetFocus 
                         GridEditText.SetSel Len(sText),Len(sText)                          
                         If Columns.Column(mCol)->DataType=DT_Numeric  Then
                         '1234567890+-./   .190 /191 +187  -189  NumPad abcdefghij n=. m=- k=+ o=/                         
                          'GridEditText.InputFilter="1234567890abcdefghijnmk`"+WCHR(190)+WCHR(187)+WCHR(189) 'For WM_KEYDOWN
                          'GridEditText.InputFilter="1234567890.-+"
                         Else
                          'GridEditText.InputFilter=""  
                         EndIf
                    End Select
                 Else
                          GridEditText.Visible =False 
                          GridEditDateTimePicker.Visible =False                       
                          GridEditComboBox.Visible =False                      
                  End If
                   InvalidateRect(Handle,@RECHeader,False)
                   'UpdateWindow Handle
                  If OnItemDblClick Then OnItemDblClick(This, GetGridDataItem(lvp->iItem))
              Case NM_KEYDOWN
                  Print "NM_KEYDOWN ", lvp->iItem, lvp->iSubItem
                 Select Case message.wParam
                 Case VK_DOWN, VK_UP,VK_RETURN,VK_LEFT,VK_RIGHT
                    mRow=lvp->iItem: mCol=lvp->iSubItem
                 Case VK_ESCAPE
                 Case VK_LEFT
                 Case VK_RIGHT
                 Case VK_TAB   
                 End Select
                   
                  If OnItemKeyDown Then OnItemKeyDown(This, GetGridDataItem(lvp->iItem))
                  
              Case LVN_ITEMACTIVATE
                  Print "LVN_ITEMACTIVATE ", lvp->iItem, lvp->iSubItem
                  If OnItemActivate Then OnItemActivate(This, GetGridDataItem(lvp->iItem))
              Case LVN_COLUMNCLICK
                   Print "LVN_COLUMNCLICK ************iItem,iSubItem " ,lvp->iItem ,lvp->iSubItem                    
                    If OnHeadClick Then OnHeadClick(This,lvp->iSubItem)
              Case LVN_BEGINSCROLL                    
                  If lvp->iSubItem < 0 Then
                      'Print "LVN_BEGINSCROLL up", lvp->iItem,lvp->iSubItem
                  Else
                      'Print "LVN_BEGINSCROLL DOWN", lvp->iItem,lvp->iSubItem
                  EndIf
                  If OnBeginScroll Then OnBeginScroll(This)                  
              Case LVN_ENDSCROLL 
'                  Dim si As SCROLLINFO
'                  si.cbSize = sizeof (si)
'                  si.fMask = SIF_ALL
'                  if tSCROLL_HorV then
'                     GetScrollInfo (Handle, SB_HORZ, @si)   
'                  else   
'                     GetScrollInfo (Handle, SB_VERT, @si)   
'                  end if
'                  Print "LVN_ENDSCROLL,nMin,nMax,nPage, nPos,nTrackPos", si.nMin,si.nMax,si.nPage, si.nPos,si.nTrackPos
                                                                                    
                   If OnEndScroll Then OnEndScroll(This)                   
                     mDrawRowStart=ListView_GetTopIndex(Handle)                     
                     GridEditText.Visible =False 
                     GridEditDateTimePicker.Visible =False                       
                     GridEditComboBox.Visible =False 
                     'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
                     'SendMessage(formh, WM_MOUSEMOVE,MK_LBUTTON,MAKELPARAM(321,477))  
                     'message.Result  = -1'  CDRF_SKIPDEFAULT
                  
              Case LVN_ITEMCHANGED 'Hover not updated if message.Result  = 1 in   WM_NOTIFY                  
                  'if lplvcd->nmcd.hDC > 100 then nmcdhDC=lplvcd->nmcd.hDC
                  'mRow = lvp->iItem    'Nothing   when in NM_CUSTOMDRAW mode
                  'mCol = lvp->iSubItem '=lplvcd->nmcd.hDC when in NM_CUSTOMDRAW mode

                  'Print "CM_NOTIFY LVN_ITEMCHANGED mRow, mCol, lplvcd->nmcd.dwItemSpec ,hDC ",mRow, mCol,lplvcd->nmcd.dwItemSpec ,lplvcd->nmcd.hDC
                  
                  If OnSelectedItemChanged Then OnSelectedItemChanged(This, lvp->iItem, lvp->iSubItem, nmcdhDC)
                 'message.Result  =  CDRF_SKIPDEFAULT
              'Case HDN_ITEMCHANGED 'Never reach here in Win OS                  
              'case HDN_BEGINTRACK  'Never reach here in Win OS
              'case HDN_ENDTRACK  'Never reach here in Win OS                       
              Case Else
                 'if tRefresh then print "CM_NOTIFY Key ",lvp->iItem,lvp->iSubItem,lplvcd->nmcd.hdr.code  
          End Select
      Case WM_KEYDOWN                 
           'PRINT  "WM_KEYDOWN",Message.wParam,Message.lParam            
      Case WM_KEYUP          
                 Select Case message.wParam
                 Case VK_DOWN,VK_UP
                    Dim As Integer tItemSelel=ListView_GetNextItem(Handle, -1, LVNI_SELECTED)
                    If tItemSelel<>-1 Then 
                       mRow=tItemSelel
                       If tItemSelel <=mDrawRowStart Or tItemSelel >=mDrawRowStart + mCountPerPage Then mDrawRowStart=ListView_GetTopIndex(Handle)
                       If message.LParam=99911 Then GridEditText.Visible =False
                       If message.LParam=99922 Then GridEditComboBox.Visible =False
                       If message.LParam=99933 Then GridEditDateTimePicker.Visible =False 
                       'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
                    End If
                 Case VK_SPACE
                      Print "VK_SPACE"
                 Case VK_LEFT
                      mCol-=1
                      If mCol<=0 Then 
                         mCol=1
                      Else
                         message.Result=  CDRF_SKIPDEFAULT   
                      End If 
                      message.Result=  CDRF_SKIPDEFAULT                       
                      'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)                                          
                 Case VK_RIGHT,VK_TAB                    
                      ListView_GetSubItemRect(Handle, mRow, mCol, LVIR_BOUNDS, @RECHeader)                                         
                      If RECHeader.Right<This.Width Then
                         message.Result=  CDRF_SKIPDEFAULT      
                      EndIf   
                      mCol+=1
                      If mCol>=Columns.Count-1 Then mCol=Columns.Count-1  
                      If message.LParam=99911 Then GridEditText.Visible =False
                      If message.LParam=99922 Then GridEditComboBox.Visible =False
                      If message.LParam=99933 Then GridEditDateTimePicker.Visible =False                                          
                      'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
                  Case VK_RETURN
                      ListView_GetSubItemRect(Handle, mRow, mCol, LVIR_BOUNDS, @RECHeader)                                         
                      If RECHeader.Right<This.Width Then
                         message.Result=  CDRF_SKIPDEFAULT      
                      EndIf   
                      mCol+=1
                      If mCol>=Columns.Count-1 Then mCol=Columns.Count-1                                           
                       message.Result=  CDRF_SKIPDEFAULT
                      'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)   
                             
                 Case VK_ESCAPE
                    If message.LParam=99911 Then GridEditText.Visible =False
                   If message.LParam=99922 Then GridEditComboBox.Visible =False
                   If message.LParam=99933 Then GridEditDateTimePicker.Visible =False  
                   'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)                    
                 End Select   
                
      Case WM_NOTIFY          
          'if tRefresh=true then print "lplvcd0->nmcd.hdr.code", lplvcd0->nmcd.hdr.code
          lplvcd= Cast(NMLVCUSTOMDRAW Ptr, message.lParam)
          Dim lvpHeader As NMHEADERA Ptr = Cast(NMHEADERA Ptr, message.lParam)
          Select Case lplvcd->nmcd.hdr.code'message.wParam
             Case LVN_ODCACHEHINT
                 Print "WM_NOTIFY LVN_ODCACHEHINT "
              Case LVN_BEGINSCROLL 'OK 
                 'Print "WM_NOTIFY LVN_ENDSCROLL "
              Case LVN_ENDSCROLL  'OK
                 'Print "WM_NOTIFY LVN_ENDSCROLL "
              Case HDN_ITEMCHANGED  'OK                  
                 'Print "WM_NOTIFY HDN_ITEMCHANGED",lplvcd->iSubItem,lvpHeader->iItem                              
                 'GridDrawHeader(0,-1)
                 If OnHeadColWidthAdjust Then OnHeadColWidthAdjust(This,lvpHeader->iItem)
              Case HDN_BEGINTRACK  'OK
                 If GridEditText.Visible=False Then
                 GridEditText.SetBounds 1,1,2,2
                 GridEditText.Visible=True         
                 EndIf   
              Case HDN_ENDTRACK    'OK                  
                 Print "WM_NOTIFY HDN_ENDTRACK",lplvcd->iSubItem,lvpHeader->iItem                                   
                  GridEditDateTimePicker.Visible =False                       
                  GridEditComboBox.Visible =False 
                  GridEditText.Visible=False
                  'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
                 'GridDrawHeader(0,-1)                 
                 If OnHeadColWidthAdjust Then OnHeadColWidthAdjust(This,lvpHeader->iItem)       
              Case Else
              'if tRefresh=true then print " WM_NOTIFY.wParam Else: ",message.wParam ,message.LParam ,message.lParamHi,message.lParamLo
          End Select       
      Case CM_COMMAND
          Print "CM_COMMAND "
          Select Case message.wParam                   
              Case LVN_ITEMACTIVATE                   
              Case LVN_KEYDOWN                   
              Case LVN_ITEMCHANGING                   
              Case LVN_ITEMCHANGED                   
              Case LVN_INSERTITEM                    
              Case LVN_DELETEITEM                    
              Case LVN_DELETEALLITEMS                  
              Case LVN_BEGINLABELEDIT                  
              Case LVN_ENDLABELEDIT                  
              Case LVN_COLUMNCLICK                   
              Case LVN_BEGINDRAG                  
              Case LVN_BEGINRDRAG                    
              Case LVN_ODCACHEHINT                    
              Case LVN_ODFINDITEM                    
              Case LVN_ODSTATECHANGED                  
              Case LVN_HOTTRACK                   
              Case LVN_GETDISPINFO                  
              Case LVN_SETDISPINFO
                  'Case LVN_COLUMNDROPDOWN
                  
              Case LVN_GETINFOTIP                   
                  'Case LVN_COLUMNOVERFLOWCLICK                   
              Case LVN_INCREMENTALSEARCH                    
              Case LVN_BEGINSCROLL                     
              Case LVN_ENDSCROLL                   
               'Case LVN_LINKCLICK 
               'Case LVN_GETEMPTYMARKUP
               
              'Message.LParamLo
              Case VK_DOWN                   
                   Print Message.LParam
                   If message.LParam=99911 Then GridEditText.Visible =False
                   If message.LParam=99922 Then GridEditComboBox.Visible =False
                   If message.LParam=99933 Then GridEditDateTimePicker.Visible =False                       
                   'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol) 
                   mRow+=1
                   If mRow>ListItems.Count-1 Then mRow=ListItems.Count-1
                    If mRow>=mDrawRowStart + mCountPerPage Then mDrawRowStart=ListView_GetTopIndex(Handle)
                    'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
              Case VK_UP                                       
                   If message.LParam=99911 Then GridEditText.Visible =False
                   If message.LParam=99922 Then GridEditComboBox.Visible =False
                   If message.LParam=99933 Then GridEditDateTimePicker.Visible =False                       
                   'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)                   
                    mRow-=1
                    If mRow<0 Then mRow=0
                    If mRow <=mDrawRowStart Then mDrawRowStart=ListView_GetTopIndex(Handle)
                    'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)                    
              Case VK_ESCAPE                   
                   If message.LParam=99911 Then GridEditText.Visible =False
                   If message.LParam=99922 Then GridEditComboBox.Visible =False
                   If message.LParam=99933 Then GridEditDateTimePicker.Visible =False                       
                   'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol) 
              Case VK_RETURN                   
                   If message.LParam=99911 Then 
                      ListItems.Item(mRow)->Text(mCol) =GridEditText.Text
                      GridEditText.Visible =False
                   End If
                   If message.LParam=99922 Then 
                      ListItems.Item(mRow)->Text(mCol) =GridEditComboBox.Text
                      GridEditComboBox.Visible =False
                   End If
                   If message.LParam=99933 Then 
                      ListItems.Item(mRow)->Text(mCol) =GridEditDateTimePicker.Text
                      GridEditDateTimePicker.Visible =False            
                      
                   End If 
                    'GridReDraw(mDrawRowStart, mDrawRowStart + mCountPerPage,mRow, mCol)
                                         
              Case VK_LEFT
                 
              Case VK_RIGHT
                 
              Case Else                   
                 ' message.Result = CDRF_DODEFAULT
          End Select
          
          'Dim As TBNOTIFY PTR Tbn
          'Dim As TBBUTTON TB
          'Dim As RECT R
          'Dim As Integer i
          'Tbn = Cast(TBNOTIFY PTR,Message.lParam)
          'Select Case Tbn->hdr.Code
          'Case TBN_DROPDOWN
          'If Tbn->iItem <> -1 Then
          'SendMessage(Tbn->hdr.hwndFrom,TB_GETRECT,Tbn->iItem,CInt(@R))
          'MapWindowPoints(Tbn->hdr.hwndFrom,0,Cast(Point Ptr,@R),2)
          'i = SendMessage(Tbn->hdr.hwndFrom,TB_COMMANDTOINDEX,Tbn->iItem,0)
          'If SendMessage(Tbn->hdr.hwndFrom,TB_GETBUTTON,i,CInt(@TB)) Then
          'TrackPopupMenu(Buttons.Button(i)->DropDownMenu.Handle,0,R.Left,R.Bottom,0,Tbn->hdr.hwndFrom,NULL)
          'End If
          'End If
          'End Select
      Case CM_NEEDTEXT
          Print "CM_NEEDTEXT"
          Dim As LPTOOLTIPTEXT TTX
          TTX = Cast(LPTOOLTIPTEXT, Message.lParam)
          TTX->hInst = GetModuleHandle(Null)
          If TTX->hdr.idFrom Then
              Dim As TBButton TB
              Dim As Integer Index
              Index = Perform(TB_COMMANDTOINDEX, TTX->hdr.idFrom, 0)
              If Perform(TB_GETBUTTON, Index, CInt(@TB)) Then
                  'If Buttons.Button(Index)->ShowHint Then
                  'If Buttons.Button(Index)->Hint <> "" Then
                  ''Dim As UString s
                  ''s = Buttons.Button(Index).Hint
                  'TTX->lpszText = @(Buttons.Button(Index)->Hint)
                  'End If
                  'End If
              End If
          End If
      Case Else
          'print " ELSE 12345678", Message.Msg
         ' message.Result = CDRF_DODEFAULT
  End Select
  #endif
  Base.ProcessMessage(Message)
End Sub

		
	#ifndef __USE_GTK__
		Sub GridData.HandleIsDestroyed(ByRef Sender As Control)
		End Sub

		Sub GridData.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QGridData(Sender.Child)
					If .Images Then
						.Images->ParentWindow = @Sender
						If .Images->Handle Then ListView_SetImageList(.FHandle, CInt(.Images->Handle), LVSIL_NORMAL)
					End If
					If .StateImages Then .StateImages->ParentWindow = @Sender
					If .SmallImages Then .SmallImages->ParentWindow = @Sender
					If .GroupHeaderImages Then .GroupHeaderImages->ParentWindow = @Sender
					If .Images AndAlso .Images->Handle Then ListView_SetImageList(.FHandle, CInt(.Images->Handle), LVSIL_NORMAL)
					If .StateImages AndAlso .StateImages->Handle Then ListView_SetImageList(.FHandle, CInt(.StateImages->Handle), LVSIL_STATE)
					If .SmallImages AndAlso .SmallImages->Handle Then ListView_SetImageList(.FHandle, CInt(.SmallImages->Handle), LVSIL_SMALL)
					If .GroupHeaderImages AndAlso .GroupHeaderImages->Handle Then ListView_SetImageList(.FHandle, CInt(.GroupHeaderImages->Handle), LVSIL_GROUPHEADER)
					Dim lvStyle As Integer              
  
					lvStyle = SendMessage(.FHandle, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
               lvStyle = lvStyle Or LVS_EX_FULLROWSELECT Or LVS_EX_SIMPLESELECT Or LVS_EX_SUBITEMIMAGES Or LVS_EX_TRACKSELECT 
               'lvStyle = lvStyle Or  LVS_EX_GRIDLINES Or LVS_EX_FULLROWSELECT 
               ' Will got trouble in GetItemCount if remove LVS_EX_FULLROWSELECT
					'lvStyle = lvStyle Or LVS_EX_FULLROWSELECT Or LVS_EX_SIMPLESELECT or LVS_EX_HEADERDRAGDROP Or LVS_EX_SUBITEMIMAGES
               'lvStyle = lvStyle Or  LVS_EX_ONECLICKACTIVATE Or LVS_EX_LABELTIP Or LVS_EX_TRACKSELECT               
					 SendMessage(.FHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, lvStyle)					                
               .FGridDataDC = GetDC(.FHandle)
               .FHandleHeader = cast(HWND, SNDMSG((.FHandle), LVM_GETHEADER, cast(WPARAM, 0), cast(LPARAM, 0))) 'ListView_GetHeader(.Handle)
               .FGridDataDCHeader = GetDC(.FHandleHeader)
               SetBkMode .FGridDataDCHeader, TRANSPARENT
               SetBkMode .FGridDataDC, TRANSPARENT
               'SetTextColor(.FGridDataDC, clBlack)
               .GridEditText.ParentHandle=.FHandle
               .GridEditComboBox.ParentHandle=.FHandle          
               .GridEditDateTimePicker.ParentHandle=.FHandle      
               .GridEditText.SetBounds 1,1,2,2
               .GridEditComboBox.SetBounds -200,-100,-10,-50               
               .GridEditDateTimePicker.SetBounds -200,-100,-10,-50
               .GridEditLinkLabel.SetBounds -200,-100,-10,-50
               
             'FONT
             .FSize=10
             .FcyPixels=GetDeviceCaps(.FGridDataDC, LOGPIXELSY)  
             .FcyPixelsHeader=GetDeviceCaps(.FGridDataDC, LOGPIXELSY)  
             If .FontHandleBody Then DeleteObject(.FontHandleBody)  
             .FontHandleBody=CreateFontW(-MulDiv(.FSize,.FcyPixels,72),0,.FOrientation*.FSize,.FOrientation*.FSize,.FBolds(Abs_(.FBold)),.FItalic,.FUnderline,.FStrikeout,.FCharSet,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*.FName)                                        
             'SendMessage(.Handle, WM_SETFONT,CUInt(.FontHandleBody),True)
             SelectObject(.FGridDataDC ,.FontHandleBody)
              Dim Sz As SIZE			
              GetTextExtentPoint32(.FGridDataDC,"B",Len("B"),@Sz) 
              .FontHeight=Sz.cY
              .FontWidth=Sz.cX
'              If FontHandleBody Then DeleteObject(FontHandleBody)
'         If FontHandleHeader Then DeleteObject(FontHandleHeader) 
'         if FontHandleBodyUnderline then DeleteObject(FontHandleBodyUnderline)
'         if FontHandleEnLarge then DeleteObject(FontHandleEnLarge)
             
             'FRowHeight=(18+(Fsize-8)*1.45
             'Fsize=(FRowHeight-18)/1.45+8             
             .FSizeHeader=19
             If .FontHandleHeader Then DeleteObject(.FontHandleHeader)  
             .FontHandleHeader=CreateFontW(-MulDiv(.FSizeHeader,.FcyPixelsHeader,72),0,.FOrientationHeader*.FSizeHeader,.FOrientationHeader*.FSizeHeader,.FBoldsHeader(Abs_(.FBoldHeader)),.FItalicHeader,.FUnderlineHeader,.FStrikeoutHeader,.FCharSetHeader,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*.FNameHeader)                                        
             SendMessage(.FHandleHeader, WM_SETFONT,CUInt(.FontHandleHeader),True) 'enlarge the height of header
             'SelectObject(.FGridDataDCHeader,.FontHandleBody)
             'print "FontHandleBody ",.FontHandleBody
             
             .FSizeHeader=10
             .FBoldHeader=1
             If .FontHandleHeader Then DeleteObject(.FontHandleHeader)  
             .FontHandleHeader=CreateFontW(-MulDiv(.FSizeHeader,.FcyPixelsHeader,72),0,.FOrientationHeader*.FSizeHeader,.FOrientationHeader*.FSizeHeader,.FBoldsHeader(Abs_(.FBoldHeader)),.FItalicHeader,.FUnderlineHeader,.FStrikeoutHeader,.FCharSetHeader,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*.FNameHeader)                                        
             SelectObject(.FGridDataDCHeader,.FontHandleHeader)
              
              
               If .FView <> 0 Then .View = .View
					For i As Integer = 0 To .Columns.Count -1
						dim lvc as LVCOLUMN
						lvC.mask      =  LVCF_FMT OR LVCF_WIDTH OR LVCF_TEXT OR LVCF_SUBITEM
						lvC.fmt       =  .Columns.Column(i)->Format OR HDF_OWNERDRAW  
						lvc.cx=0
						'lvc.pszText              = @.Columns.Column(i)->Text
						'lvc.cchTextMax           = len(.Columns.Column(i)->text)
						lvc.iImage             = .Columns.Column(i)->ImageIndex
						lvc.iSubItem         = i
						ListView_InsertColumn(.FHandle, i, @lvc)
						ListView_SetColumnWidth(.FHandle, i, .Columns.Column(i)->ColWidth)
					Next i
					For i As Integer = 0 To .ListItems.Count -1
						dim lvi as LVITEM
						lvi.Mask = LVIF_TEXT or LVIF_IMAGE
						lvi.pszText              = @.ListItems.Item(i)->Text(0) 
						lvi.cchTextMax           = len(.ListItems.Item(i)->text(0))
						lvi.iItem             = i
						lvi.iImage             = .ListItems.Item(i)->ImageIndex
						ListView_InsertItem(.FHandle, @lvi)
               
						For j As Integer = 0 To .Columns.Count - 1
							Dim As LVITEM lvi1
							lvi1.Mask = LVIF_TEXT
							lvi1.iItem = i
							lvi1.iSubItem   = j
							lvi1.pszText    = @.ListItems.Item(i)->Text(j)
							lvi1.cchTextMax = Len(.ListItems.Item(i)->Text(j))
							ListView_SetItem(.Handle, @lvi1)
						Next j
					Next i
				End With
			End If
		End Sub 
  
	#EndIf

    Operator GridData.Cast As Control Ptr 
        Return @This
    End Operator

	#IfDef __USE_GTK__
		Sub GridData_RowActivated(tree_view As GtkTreeView Ptr, path As GtkTreePath Ptr, column As GtkTreeViewColumn Ptr, user_data As Any Ptr)
			Dim As GridData Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_tree_view_get_model(tree_view)
				
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If lv->OnItemActivate Then lv->OnItemActivate(*lv, lv->ListItems.FindByIterUser_Data(iter.User_Data))
				End If
			End If
	    End Sub
	    
	    Sub GridData_SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As GridData Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeIter iter
				Dim As GtkTreeModel Ptr model
				If gtk_tree_selection_get_selected(selection, @model, @iter) Then
					If lv->OnSelectedItemChanged Then lv->OnSelectedItemChanged(*lv, lv->ListItems.FindByIterUser_Data(iter.User_Data))
				End If
			End If
	    End Sub
	    
	    Sub GridData_Map(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As GridData Ptr lv = user_data
			lv->Init
	    End Sub
	    
	    Function GridData.TreeListView_TestExpandRow(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
	    	Dim As GridData Ptr lv = user_data
			If lv Then
				Dim As GtkTreeModel Ptr model
				model = gtk_tree_view_get_model(tree_view)
				If lv->OnItemExpanding Then lv->OnItemExpanding(*lv, lv->ListItems.FindByIterUser_Data(iter->User_Data))
			End If
			Return False
	    End Function
	#Else
    
	#EndIf
	
	Sub GridData.CollapseAll
    	#IfDef __USE_GTK__
    		gtk_tree_view_collapse_all(gtk_tree_view(widget))
    	#EndIf
    End Sub
    
    Sub GridData.ExpandAll
    	#IfDef __USE_GTK__
    		gtk_tree_view_expand_all(gtk_tree_view(widget))
    	#EndIf
    End Sub
    
    Constructor GridData
    	#IfDef __USE_GTK__
			TreeStore = gtk_tree_store_new(1, G_TYPE_STRING)
			scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(gtk_scrolled_window(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'widget = gtk_tree_view_new_with_model(gtk_tree_model(ListStore))
			widget = gtk_tree_view_new()
			gtk_container_add(gtk_container(scrolledwidget), widget)
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
			g_signal_connect(gtk_tree_view(widget), "map", G_CALLBACK(@GridData_Map), @This)
			g_signal_connect(gtk_tree_view(widget), "row-activated", G_CALLBACK(@GridData_RowActivated), @This)
			g_signal_connect(gtk_tree_view(widget), "test-expand-row", G_CALLBACK(@GridData_TestExpandRow), @This)
			g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@GridData_SelectionChanged), @This)
			gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), true)
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), GTK_TREE_VIEW_GRID_LINES_BOTH)
			ColumnTypes = New GType[1]
			ColumnTypes[0] = G_TYPE_STRING
			This.RegisterClass "GridData", @This
		#EndIf
        'Font
        FBolds(0) = 400
        FBolds(1) = 700
        WLet FName, "TAHOMA"        
        WLet FNameHeader, "TAHOMA"
        FCharSet=FontCharset.Default
        FCharSetHeader=FontCharset.Default
        FBoldsHeader(0) = 400
        FBoldsHeader(1) =700
                   
        FEnabled = True
        FVisible = True
        ListItems.Clear
        ListItems.Parent = @This
        Columns.Parent = @This
        
        GridEditComboBox.Parent = @This
        GridEditText.Parent = @This        
        GridEditDateTimePicker.Parent = @This
        GridEditLinkLabel.Parent = @This
        'GridEditText.BorderStyle = 0         
        'GridEditText.WantReturn = True
        GridEditText.MultiLine= True
        GridEditText.BringToFront 
        GridEditComboBox.BringToFront 
        GridEditDateTimePicker.BringToFront 
   
'        GridEditComboBox.Visible = False
'        GridEditDateTimePicker.Visible = False
'        GridEditLinkLabel.Visible = False
'        GridEditText.Visible = False
         
'         GridEditText.OnKeyDown = @GridEditText_KeyDown
'         GridEditText.OnKeyUp = @GridEditText_KeyUp
'         GridEditText.OnKeyPress = @GridEditText_KeyPress
'         'GridEditText.OnLostFocus = @GridEditText_LostFocus

'         'GridDataCbo.OnKeyUp = @GridDataText_KeyUp
'         GridEditComboBox.OnChange = @GridEditComboBox_Change 
       
        With This
			.Child             = @This
			#ifndef __USE_GTK__
				.OnHandleIsAllocated = @HandleIsAllocated
				.OnHandleIsDestroyed = @HandleIsDestroyed
				.RegisterClass "GridData", WC_ListView
				.ChildProc         = @WndProc
				.ExStyle           = WS_EX_CLIENTEDGE
				.Style             = WS_CHILD Or WS_TABSTOP Or WS_VISIBLE Or LVS_REPORT Or LVS_SINGLESEL Or LVS_OWNERDRAWFIXED 'Or LVS_SHOWSELALWAYS OR LVS_EDITLABELS OR LVS_EX_DOUBLEBUFFER
				WLet FClassAncestor, WC_ListView              
			#endif
            WLet FClassName, "GridData"            
            .Width             = 121
            .Height            = 121             
        End With 
    End Constructor

    Destructor GridData
    	ListItems.Clear
    	Columns.Clear
		#ifndef __USE_GTK__    
			UnregisterClass "GridData",GetmoduleHandle(NULL)
         If FontHandleBody Then DeleteObject(FontHandleBody)
         If FontHandleHeader Then DeleteObject(FontHandleHeader) 
         If FontHandleBodyUnderline Then DeleteObject(FontHandleBodyUnderline)         
         ReleaseDC(Handle, FGridDataDC)
         ReleaseDC(FHandleHeader, FGridDataDCHeader)         
          
		#else
			If ColumnTypes Then Delete [] ColumnTypes        
		#endif
      
    End Destructor
'End Namespace
