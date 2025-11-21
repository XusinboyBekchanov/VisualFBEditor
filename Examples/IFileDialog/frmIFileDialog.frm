'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	
	#include once "IFileDialog.bi"
	
	Using My.Sys.Forms
	
	Type frmIFileDialogType Extends Form
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As Panel Panel1
		Dim As CommandButton CommandButton1
		Dim As TextBox TextBox1, TextBox2
	End Type
	
	Constructor frmIFileDialogType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' frmIFileDialog
		With This
			.Name = "frmIFileDialog"
			.Text = "IFileDialog"
			.Designer = @This
			.Caption = "IFileDialog"
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.SetBounds 0, 0, 350, 300
		End With
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 0
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 334, 40
			.Designer = @This
			.Parent = @This
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "IFileDialog"
			.TabIndex = 1
			.Caption = "IFileDialog"
			.SetBounds 10, 10, 100, 20
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @CommandButton1_Click)
			.Parent = @Panel1
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 2
			.Anchor.Left = AnchorStyle.asAnchor
			.Anchor.Right = AnchorStyle.asAnchor
			.SetBounds 120, 10, 200, 20
			.Designer = @This
			.Parent = @Panel1
		End With
		' TextBox2
		With TextBox2
			.Name = "TextBox2"
			.Text = ""
			.TabIndex = 3
			.Align = DockStyle.alClient
			.Multiline = True
			.ID = 1005
			.ScrollBars = ScrollBarsType.Both
			.SetBounds 0, 40, 334, 221
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmIFileDialog As frmIFileDialogType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmIFileDialog.MainForm = True
		frmIFileDialog.Show
		App.Run
	#endif
'#End Region


Private Sub frmIFileDialogType.Form_Create(ByRef Sender As Control)
	CoInitialize(NULL)
	TextBox1.Text = ExePath
End Sub

Private Sub frmIFileDialogType.Form_Destroy(ByRef Sender As Control)
	CoUninitialize()
End Sub

Private Sub frmIFileDialogType.CommandButton1_Click(ByRef Sender As Control)
	? "Starting file selection process..."
	TextBox2.Clear
	Dim pItems As IShellItemArray Ptr = ShowOpenFileDialog(Handle, TextBox1.Text)
	If pItems = NULL Then
		? "No files selected"
		Sleep()
		Exit Sub
	End If
	
	Dim dwItemCount As DWORD = 0
	Dim hr As HRESULT = pItems->lpVtbl->GetCount(pItems, @dwItemCount)
	
	If SUCCEEDED(hr) Then
		? "Selected " & dwItemCount & " files:"
		
		For idx As DWORD = 0 To dwItemCount - 1
			Dim pItem As IShellItem Ptr = NULL
			hr = pItems->lpVtbl->GetItemAt(pItems, idx, @pItem)
			
			If SUCCEEDED(hr) AndAlso pItem <> NULL Then
				Dim pwszName As WString Ptr = NULL
				hr = pItem->lpVtbl->GetDisplayName(pItem, SIGDN_FILESYSPATH, @pwszName)
				
				If SUCCEEDED(hr) AndAlso pwszName <> NULL Then
					? "File " & (idx + 1) & ": " & *pwszName
					TextBox2.AddLine *pwszName
					CoTaskMemFree(pwszName)
				Else
					? "File " & (idx + 1) & ": [Cannot get file name]"
				End If
				
				SAFE_RELEASE(pItem)
			Else
				? "File " & (idx + 1) & ": [Cannot get file item]"
			End If
		Next
	Else
		? "Error: Cannot get file count: " & Hex(hr) & ", " & dwItemCount
	End If
	
	SAFE_RELEASE(pItems)
	? "File list display completed"
End Sub