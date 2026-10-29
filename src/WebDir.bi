'#########################################################
'#  WebDir.bi                                            #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#########################################################

'Web: Dir of the js-asmjs runtime finds nothing in the virtual file system (fb_Dir and fb_DirNext of libfb are empty).
'The program has its own fb_Dir and fb_DirNext, so the linker takes them instead of the ones of libfb.a and every Dir
'(of the IDE and of MyFbFramework) reads the folders with the C library of emscripten, with the attributes like
'Dir of libfb on Linux (a name with a dot at the start is hidden)
#include once "dir.bi"

Extern "C"
	Declare Function WebDir_opendir Alias "opendir"(ByVal DirName As ZString Ptr) As Any Ptr
	Declare Function WebDir_readdir Alias "readdir"(ByVal DirPtr As Any Ptr) As UByte Ptr
	Declare Function WebDir_closedir Alias "closedir"(ByVal DirPtr As Any Ptr) As Long
	Declare Function WebDir_fnmatch Alias "fnmatch"(ByVal Pattern As ZString Ptr, ByVal FileName As ZString Ptr, ByVal Flags As Long) As Long
End Extern

Const WebDir_FNM_CASEFOLD = &h10
'struct dirent of emscripten: d_ino (8 bytes), d_off (8 bytes), d_reclen (2 bytes), d_type (1 byte), d_name
Const WebDir_DTypeOffset = 18, WebDir_DNameOffset = 19
Const WebDir_DT_UNKNOWN = 0, WebDir_DT_DIR = 4

Dim Shared As Any Ptr WebDir_Handle
Dim Shared As String WebDir_Folder, WebDir_Pattern
Dim Shared As Long WebDir_Mask

'The next name of the search (Dir() and Dir(out_attrib))
Function WebDir_DirNext cdecl Alias "fb_DirNext"(ByVal p_out_attrib As Long Ptr) As String
	If p_out_attrib Then *p_out_attrib = 0
	If WebDir_Handle = 0 Then Return ""
	Do
		Dim As UByte Ptr Entry = WebDir_readdir(WebDir_Handle)
		If Entry = 0 Then Exit Do
		Dim As ZString Ptr EntryName = Cast(ZString Ptr, Entry + WebDir_DNameOffset)
		If WebDir_fnmatch(StrPtr(WebDir_Pattern), EntryName, WebDir_FNM_CASEFOLD) <> 0 Then Continue Do
		Dim As Boolean IsFolder = Entry[WebDir_DTypeOffset] = WebDir_DT_DIR
		If Entry[WebDir_DTypeOffset] = WebDir_DT_UNKNOWN Then
			Dim As String FullName = WebDir_Folder & *EntryName
			Dim As Any Ptr FolderPtr = WebDir_opendir(StrPtr(FullName))
			IsFolder = FolderPtr <> 0
			If FolderPtr Then WebDir_closedir FolderPtr
		End If
		Dim As Long Attrib = IIf(IsFolder, fbDirectory, fbArchive)
		If (*EntryName)[0] = Asc(".") Then Attrib Or= fbHidden
		If CBool(Attrib And fbDirectory) AndAlso CBool((WebDir_Mask And fbDirectory) = 0) Then Continue Do
		If CBool(Attrib And fbHidden) AndAlso CBool((WebDir_Mask And fbHidden) = 0) Then Continue Do
		If p_out_attrib Then *p_out_attrib = Attrib
		Return *EntryName
	Loop
	WebDir_closedir WebDir_Handle
	WebDir_Handle = 0
	Return ""
End Function

'The first name of a new search (Dir(FileSpec, ...)): the folder of FileSpec, its name part is the pattern (* and ?)
Function WebDir_Dir cdecl Alias "fb_Dir"(ByRef FileSpec As String, ByVal attrib_mask As Long, ByVal p_out_attrib As Long Ptr) As String
	If WebDir_Handle Then
		WebDir_closedir WebDir_Handle
		WebDir_Handle = 0
	End If
	If p_out_attrib Then *p_out_attrib = 0
	Dim As String Spec = FileSpec
	For i As Integer = 0 To Len(Spec) - 1
		If Spec[i] = Asc("\") Then Spec[i] = Asc("/")
	Next
	Dim As Integer SlashPos = InStrRev(Spec, "/")
	WebDir_Folder = IIf(SlashPos > 0, Left(Spec, SlashPos), "./")
	WebDir_Pattern = Mid(Spec, SlashPos + 1)
	If WebDir_Pattern = "" Then Return ""
	WebDir_Mask = attrib_mask
	WebDir_Handle = WebDir_opendir(StrPtr(WebDir_Folder))
	Return WebDir_DirNext(p_out_attrib)
End Function
