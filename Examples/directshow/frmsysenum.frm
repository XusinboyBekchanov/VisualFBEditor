'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "frmsysenum.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif

	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/ListControl.bi"
	#include once "mff/CheckBox.bi"
	
	#include once "win/dshow.bi"
	#include once "win/strmif.bi"
	#include once "win/control.bi"
	#include once "win/uuids.bi"
	#include once "win/comcat.bi"
	#include once "win/mmsystem.bi"
	#include once "win/mmreg.bi"
	#include once "win/d3d9types.bi"
	#include once "win/dsound.bi"
	
	#define NUM_CATEGORIES 6
	#define STR_CLASSES "System Device Classes"
	#define STR_FILTERS "Registered Filters"
	
	Using My.Sys.Forms
	
	Type frmSysEnumType Extends Form
		
		categories(NUM_CATEGORIES) As CATEGORYINFO = { _
		(CLSID_AudioInputDeviceCategory, 0, "Audio Capture Devices"), _
		(CLSID_AudioCompressorCategory, 0, "Audio Compressors"), _
		(CLSID_AudioRendererCategory, 0, "Audio Renderers"), _
		(CLSID_LegacyAmFilterCategory, 0, "DirectShow Filters"), _
		(CLSID_MidiRendererCategory, 0, "Midi Renderers"), _
		(CLSID_VideoInputDeviceCategory, 0, "Video Capture Devices"), _
		(CLSID_VideoCompressorCategory, 0, "Video Compressors") _
		}
		
		m_pSysDevEnum As ICreateDevEnum Ptr
		
		Declare Sub SetNumClasses(nClasses As Integer)
		Declare Sub SetNumFilters(nFilters As Integer)
		Declare Sub AddFilterCategory(szCatDesc As TCHAR Ptr, pCatGuid As GUID Ptr)
		Declare Sub AddFilter(szFilterName As TCHAR Ptr, pCatGuid As GUID Ptr)
		Declare Sub FillCategoryList()
		Declare Sub ClearDeviceList()
		Declare Sub ClearFilterList()
		Declare Function EnumFilters(pEnumCat As IEnumMoniker Ptr) As HRESULT
		Declare Sub DisplayFullCategorySet()
		Declare Sub ShowFilenameByCLSID(clsid As REFCLSID)
		
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub CheckBox1_Click(ByRef Sender As CheckBox)
		Declare Sub ListControl1_Click(ByRef Sender As Control)
		Declare Sub ListControl2_Click(ByRef Sender As Control)
		Declare Constructor
		Dim As Label Label1, Label2, Label3, Label4
		Dim As ListControl ListControl1, ListControl2
		Dim As CheckBox CheckBox1
	End Type
	
	Constructor frmSysEnumType
		
		'frmSysEnum
		With This
			.Name = "frmSysEnum"
			.Text = "DirectShow Filter Enumerator Sample"
			.Caption = "DirectShow Filter Enumerator Sample"
			.StartPosition = FormStartPosition.CenterScreen
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.Designer = @This
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.SetBounds 0, 0, 530, 390
		End With
		'Label1
		With Label1
			.Name = "Label1"
			.Text = "System Device Classes"
			.TabIndex = 0
			.Caption = "System Device Classes"
			.SetBounds 10, 10, 240, 20
			.Parent = @This
		End With
		'Label2
		With Label2
			.Name = "Label2"
			.Text = "Registered Filters"
			.TabIndex = 1
			.Caption = "Registered Filters"
			.SetBounds 260, 10, 240, 20
			.Parent = @This
		End With
		'ListControl1
		With ListControl1
			.Name = "ListControl1"
			.Text = "ListControl1"
			.TabIndex = 2
			.SetBounds 10, 30, 240, 262
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ListControl1_Click)
			.Parent = @This
		End With
		'ListControl2
		With ListControl2
			.Name = "ListControl2"
			.Text = "ListControl2"
			.TabIndex = 3
			.SetBounds 260, 30, 240, 258
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @ListControl2_Click)
			.Parent = @This
		End With
		'CheckBox1
		With CheckBox1
			.Name = "CheckBox1"
			.Text = "Show All Filter Categories"
			.TabIndex = 4
			.Caption = "Show All Filter Categories"
			.SetBounds 10, 300, 240, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CheckBox1_Click)
			.Parent = @This
		End With
		'Label3
		With Label3
			.Name = "Label3"
			.Text = "Filename: "
			.TabIndex = 5
			.Caption = "Filename: "
			.SetBounds 10, 330, 60, 20
			.Parent = @This
		End With
		'Label4
		With Label4
			.Name = "Label4"
			.Text = "Label4"
			.TabIndex = 6
			.SetBounds 70, 330, 430, 20
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmSysEnum As frmSysEnumType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True	
		frmSysEnum.MainForm = True
		frmSysEnum.Show
		App.Run
	#endif
'#End Region

Private Sub frmSysEnumType.SetNumClasses(nClasses As Integer)
	Label1.Text = STR_CLASSES & " (" & nClasses + 1 & " found)"
End Sub

Private Sub frmSysEnumType.SetNumFilters(nFilters As Integer)
	If nFilters Then
		Label2.Text = STR_FILTERS & " (" & nFilters & " found)"
	Else
		Label2.Text = STR_FILTERS
	End If
End Sub

Private Sub frmSysEnumType.AddFilterCategory(szCatDesc As TCHAR Ptr, pCatGuid As GUID Ptr)
	Dim As CLSID Ptr pclsid = New CLSID
	*pclsid = *pCatGuid
	
	'Add the category Name And a Pointer To its CLSID To the list box
	Dim As Integer nIndexNew = ListControl1.ItemCount
	ListControl1.AddItem(*Cast(WString Ptr, szCatDesc))
	ListControl1.ItemData(nIndexNew) = pclsid
End Sub

Private Sub frmSysEnumType.AddFilter(szFilterName As TCHAR Ptr, pCatGuid As GUID Ptr)
	'Allocate a New CLSID, whose Pointer will be stored in
	'the listbox.  When the listbox Is cleared, these will be deleted.
	Dim As CLSID Ptr pclsid = New CLSID
	*pclsid = *pCatGuid
	
	'Add the category Name And a Pointer To its CLSID To the list box
	'Dim As Integer nSuccess  = m_FilterList.AddString(szFilterName)
	Dim As Integer nIndexNew = ListControl2.ItemCount
	ListControl2.AddItem *Cast(WString Ptr, szFilterName)
	ListControl2.ItemData(nIndexNew) = pclsid
End Sub

Private Sub frmSysEnumType.ClearDeviceList()
	Dim As CLSID Ptr pStoredId '= New CLSID
	Dim As Integer nCount = ListControl1.ItemCount - 1
	
	'Delete Any CLSID pointers that were stored in the listbox item Data
	Dim As Integer i
	For i = 0 To nCount
		pStoredId = Cast(CLSID Ptr, ListControl1.ItemData(i))
		If pStoredId Then
			Delete pStoredId
			pStoredId = NULL
		End If
	Next
	
	'Clean up
	ListControl1.Clear()
	SetNumClasses(0)
End Sub

Private Sub frmSysEnumType.ClearFilterList()
	Dim As CLSID Ptr pStoredId '= New CLSID
	
	Dim As Integer nCount = ListControl2.ItemCount-1
	
	'Delete Any CLSID pointers that were stored in the listbox item Data
	Dim As Integer i
	For i = 0 To nCount
		pStoredId = Cast(CLSID Ptr, ListControl2.ItemData(i))
		If pStoredId Then
			Delete pStoredId
			pStoredId = NULL
		End If
	Next
	
	'Clean up
	ListControl2.Clear
	Label4.Text = "< No filter selected >"
End Sub

Private Sub frmSysEnumType.FillCategoryList()
	If CheckBox1.Checked Then
		'Emulate the behavior of GraphEdit by enumerating all
		'categories in the System
		DisplayFullCategorySet()
	Else
		'Fill the category list box With the categories To display,
		'Using the names stored in the CATEGORY_INFO array.
		'SysEnumDlg.H For a category description.
		Dim i As Integer
		For i = 0 To NUM_CATEGORIES
			ListControl1.AddItem categories(i).szDescription
		Next
		
		'Update listbox title With number of classes
		SetNumClasses(NUM_CATEGORIES)
	End If
	
End Sub

Private Function frmSysEnumType.EnumFilters(pEnumCat As IEnumMoniker Ptr) As HRESULT
	Dim As HRESULT hr = S_OK
	Dim As IMoniker Ptr pMoniker
	Dim As ULong cFetched
	Dim As VARIANT varName
	Dim As Integer nFilters = 0
	
	'Clear the current filter list
	ClearFilterList()
	
	'If there are no filters of a requested Type, show default String
	If (pEnumCat = NULL) Then
		ListControl2.AddItem "< No entries >"
		SetNumFilters(nFilters)
		Return S_FALSE
	End If
	
	'Enumerate all items associated With the moniker
	While pEnumCat->lpVtbl->Next(pEnumCat, 1, @pMoniker, @cFetched) = S_OK
		
		Dim As IPropertyBag Ptr pPropBag
		Assert(pMoniker)
		
		'Associate moniker With a file
		hr = pMoniker->lpVtbl->BindToStorage(pMoniker, 0, 0, @IID_IPropertyBag, @pPropBag)
		Assert(SUCCEEDED(hr))
		Assert(pPropBag)
		If (FAILED(hr)) Then Continue While
		
		'Read filter Name from Property bag
		'varName.vt = VT_BSTR
		hr = pPropBag->lpVtbl->Read(pPropBag, "FriendlyName", @varName, 0)
		If (FAILED(hr)) Then Continue While
		
		'Get filter Name (converting BSTR Name To a CString)
		'CString Str(varName.bstrVal)
		nFilters += 1
		
		'Read filter's CLSID from property bag.  This CLSID string will be
		'converted To a Binary CLSID And passed To AddFilter(), which will
		'Add the filter's name to the listbox and its CLSID to the listbox
		'item's DataPtr item.  When the user clicks on a filter name in
		'the listbox, we'll read the stored CLSID, convert it to a string,
		'And use it To find the filter's filename in the registry.
		Dim As VARIANT varFilterClsid
		varFilterClsid.vt = VT_BSTR
		
		'Read CLSID String from Property bag
		hr = pPropBag->lpVtbl->Read(pPropBag, "CLSID", @varFilterClsid, 0)
		If (SUCCEEDED(hr)) Then
			Dim As LPCLSID clsidFilter = New CLSID
			
			'Add filter Name And CLSID To listbox
			If CLSIDFromString(varFilterClsid.bstrVal, clsidFilter) = S_OK Then
				AddFilter(varName.bstrVal, clsidFilter)
			End If
			
			SysFreeString(varFilterClsid.bstrVal)
		End If
		SysFreeString(varName.bstrVal)
		'Cleanup interfaces
		pPropBag->lpVtbl->Release(pPropBag)
		pMoniker->lpVtbl->Release(pMoniker)
	Wend
	
	'Update count of enumerated filters
	SetNumFilters(nFilters)
	Return hr
End Function

Private Sub frmSysEnumType.ShowFilenameByCLSID(clsid As REFCLSID)
	
	Dim As HRESULT hr
	Dim As LPOLESTR strCLSID
	
	'Convert Binary CLSID To a readable version
	hr = StringFromCLSID(clsid, @strCLSID)
	If SUCCEEDED(hr) Then
		
		Dim As HKEY hkeyFilter = 0
		Dim As DWORD dwSize= MAX_PATH
		Dim As UByte Ptr szFilename = Allocate(MAX_PATH)
		Dim As Integer rc = 0
		Label4.Text = *strCLSID
		
		'Open the CLSID key that contains information about the filter
		rc = RegOpenKey(HKEY_LOCAL_MACHINE, "Software\Classes\CLSID\" & *strCLSID & "\InprocServer32", @hkeyFilter)
		If rc = ERROR_SUCCESS Then
			'Read (Default) value
			rc = RegQueryValueEx(hkeyFilter, NULL,  NULL, NULL, szFilename, @dwSize)
			
			If (rc = ERROR_SUCCESS) Then
				Label4.Text = *Cast(WString Ptr, szFilename)
			Else
				Label4.Text = "< Unknow >"
			End If
			rc = RegCloseKey(hkeyFilter)
		End If
		'Free memory associated With strCLSID (allocated in StringFromCLSID)
		CoTaskMemFree(strCLSID)
		Deallocate(szFilename)
	End If
End Sub

Private Sub frmSysEnumType.DisplayFullCategorySet()
	Dim As HRESULT hr
	Dim As IEnumMoniker Ptr pEmCat
	Dim As ICreateDevEnum Ptr pCreateDevEnum
	Dim As Integer nClasses = 0
	
	'Create an enumerator
	hr = CoCreateInstance(@CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER, @IID_ICreateDevEnum, @pCreateDevEnum)
	If FAILED(hr) Then Exit Sub
	
	'Use the meta-category that contains a list of all categories.
	'This emulates the behavior of GraphEdit.
	hr = pCreateDevEnum->lpVtbl->CreateClassEnumerator(pCreateDevEnum, @CLSID_ActiveMovieCategories, @pEmCat, 0)
	
	If hr = S_OK Then
		Dim As IMoniker Ptr pMCat
		Dim As ULong cFetched
		
		'Enumerate over every category
		While pEmCat->lpVtbl->Next(pEmCat,1, @pMCat, @cFetched) = S_OK
			Dim As IPropertyBag Ptr pPropBag
			
			'Associate moniker With a file
			hr = pMCat->lpVtbl->BindToStorage(pMCat, 0, 0, @IID_IPropertyBag, @pPropBag)
			If SUCCEEDED(hr) Then
				Dim As VARIANT varCatClsid
				
				'Read CLSID String from Property bag
				hr = pPropBag->lpVtbl->Read(pPropBag, "CLSID", @varCatClsid, 0)
				If SUCCEEDED(hr) Then
					Dim As CLSID clsidCat
					If CLSIDFromString(varCatClsid.bstrVal, @clsidCat) = S_OK Then
						'Use the guid If we can't get the name
						Dim As WCHAR Ptr wszCatName
						Dim As VARIANT varCatName
						'varCatName.vt = VT_BSTR
						
						'Read filter Name
						hr = pPropBag->lpVtbl->Read(pPropBag, "FriendlyName", @varCatName, 0)
						If SUCCEEDED(hr) Then
							wszCatName = varCatName.bstrVal
						Else
							wszCatName = varCatClsid.bstrVal
						End If
						
						'Add category Name And CLSID To list box
						AddFilterCategory(wszCatName, @clsidCat)
						If SUCCEEDED(hr) Then SysFreeString(varCatName.bstrVal)
						nClasses += 1
					End If
					
					SysFreeString(varCatClsid.bstrVal)
				End If
				
				pPropBag->lpVtbl->Release(pPropBag)
			Else
				Exit While
			End If
			
			pMCat->lpVtbl->Release(pMCat)
		Wend
		
		pEmCat->lpVtbl->Release(pEmCat)
	End If
	
	pCreateDevEnum->lpVtbl->Release(pCreateDevEnum)
	
	'Update listbox title With number of classes
	SetNumClasses(nClasses)
End Sub

Private Sub frmSysEnumType.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)
	Dim As HRESULT hr
	hr = CoCreateInstance(@CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC, @IID_ICreateDevEnum, @m_pSysDevEnum)
	
	CheckBox1_Click(CheckBox1)
End Sub

Private Sub frmSysEnumType.CheckBox1_Click(ByRef Sender As CheckBox)
	'Clear listboxes
	ClearDeviceList()
	ClearFilterList()
	
	FillCategoryList()
	
	SetNumFilters(0)
End Sub

Private Sub frmSysEnumType.ListControl1_Click(ByRef Sender As Control)
	Dim As HRESULT hr
	Dim As IEnumMoniker Ptr pEnumCat
	
	'Get the currently selected category Name
	Dim As Integer nItem = ListControl1.ItemIndex
	Dim As CLSID Ptr pclsid'= New CLSID
	
	If CheckBox1.Checked Then
		'Read the CLSID Pointer from the list box's item data
		pclsid = Cast(CLSID Ptr, ListControl1.ItemData(nItem))
	Else
		'Read the CLSID Pointer from our hard-coded array of
		'documented filter categories
		pclsid = @categories(nItem).catid
	End If
	
	'WARNING!
	'
	'Some third-party filters throw an exception (Int 3) during enumeration
	'On Debug builds, often due To heap corruption in RtlFreeHeap().
	'This Is Not an issue On Release builds.
	
	'Enumerate all filters of the selected category
	hr = m_pSysDevEnum->lpVtbl->CreateClassEnumerator(m_pSysDevEnum, pclsid, @pEnumCat, 0)
	Assert(SUCCEEDED(hr))
	If FAILED(hr) Then Exit Sub
	
	'Enumerate all filters Using the category enumerator
	hr = EnumFilters(pEnumCat)
	
	'pEnumCat->lpVtbl->Release(pEnumCat)
End Sub

Private Sub frmSysEnumType.ListControl2_Click(ByRef Sender As Control)
	Dim As CLSID Ptr pclsid
	
	'Get the currently selected category Name
	Dim As Integer nItem = ListControl2.ItemIndex
	
	'Read the CLSID Pointer from the list box's item data
	pclsid = Cast(CLSID Ptr, ListControl2.ItemData(nItem))
	
	'Find the filter filename in the registry (by CLSID)
	If pclsid Then ShowFilenameByCLSID(pclsid)
End Sub

Private Sub frmSysEnumType.Form_Destroy(ByRef Sender As Control)
	ClearFilterList()
	ClearDeviceList()
	If m_pSysDevEnum Then m_pSysDevEnum->lpVtbl->Release(m_pSysDevEnum)
	CoUninitialize()
End Sub
