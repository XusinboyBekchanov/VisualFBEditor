#ifdef __FB_64BIT__
	#cmdline "ScintillaControl.rc -dll -x ScintillaControl64.dll -gen gas64"
#else
	#cmdline "ScintillaControl.rc -dll -x ScintillaControl32.dll"
#endif
#define __EXPORT_PROCS__

#include once "ScintillaControl.bi"

#ifdef __EXPORT_PROCS__
	#include once "mff/List.bi"
	Dim Shared Objects As List
	
	Using My.Sys.Forms
	
	Common Shared Ctrl As Control Ptr
	Function CreateControl Alias "CreateControl" (ByRef ClassName As String, ByRef sName As WString, ByRef Text As WString, lLeft As Integer, lTop As Integer, lWidth As Integer, lHeight As Integer, Parent As Control Ptr) As Control Ptr Export
		Ctrl = 0
		Select Case LCase(ClassName)
		Case "scintillacontrol": Ctrl = New_(ScintillaControl)
		End Select
		If Ctrl Then
			Ctrl->Name = sName
			Ctrl->WriteProperty("Text", @Text)
			Ctrl->SetBounds lLeft, lTop, lWidth, lHeight
			Ctrl->WriteProperty("Parent", Parent)
			If Not Objects.Contains(Ctrl) Then Objects.Add Ctrl
		EndIf
		Return Ctrl
	End Function
	
	Common Shared Cpnt As Component Ptr
	Function CreateComponent Alias "CreateComponent" (ByRef ClassName As String, ByRef sName As WString, lLeft As Integer, lTop As Integer, Parent As Component Ptr) As Component Ptr Export
		Cpnt = 0
		Select Case LCase(ClassName)
		Case Else: Cpnt = CreateControl(ClassName, sName, sName, lLeft, lTop, 10, 10, Cast(Control Ptr, Parent))
		End Select
		If Cpnt Then
			Cpnt->Name = sName
			Cpnt->Left = lLeft
			Cpnt->Top = lTop
			Cpnt->WriteProperty("Parent", Parent)
			If Not Objects.Contains(Cpnt) Then Objects.Add Cpnt
		EndIf
		Return Cpnt
	End Function
	
	Common Shared Obj As My.Sys.Object Ptr
	Function CreateObject Alias "CreateObject"(ByRef ClassName As String) As Object Ptr Export
		Obj = 0
		Select Case LCase(ClassName)
		Case Else: Obj = CreateComponent(ClassName, "", 0, 0, 0)
		End Select
		If Obj Then
			If Not Objects.Contains(Obj) Then Objects.Add Obj
		End If
		Return Obj
	End Function
	
	Common Shared bNotRemoveObject As Boolean
	Function DeleteComponent Alias "DeleteComponent"(Ctrl As Any Ptr) As Boolean Export
		If Ctrl = 0 Then Return False
		Select Case LCase(Cast(Component Ptr, Ctrl)->ClassName)
		Case "scintillacontrol": Delete( Cast(ScintillaControl Ptr, Ctrl))
		Case Else: Return False
		End Select
		If bNotRemoveObject = False Then 
			If Objects.Contains(Ctrl) Then
				Objects.Remove Objects.IndexOf(Ctrl)
			End If
		End If
		Return True
	End Function
	
	Function ObjectDelete Alias "ObjectDelete"(Obj As Any Ptr) As Boolean Export
		If Obj = 0 Then Return False
 		Select Case LCase(Cast(My.Sys.Object Ptr, Obj)->ClassName)
		Case Else: Return DeleteComponent(Obj)
		End Select
		If bNotRemoveObject = False Then
			If Objects.Contains(Obj) Then
				Objects.Remove Objects.IndexOf(Obj)
			End If
		End If
		Return True
	End Function
	
	Function DeleteAllObjects Alias "DeleteAllObjects"() As Boolean Export
		bNotRemoveObject = True
		For i As Integer = 0 To Objects.Count - 1
			ObjectDelete(Objects.Item(i))
		Next
		Objects.Clear
		bNotRemoveObject = False
		Return True
	End Function
#endif
