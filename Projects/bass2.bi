'Coded by UEZ build 2020-06-17
#include once "windows.bi"
#include once "file.bi"

Const BASS_UNICODE = &h80000000, BASS_DEVICE_ENABLED = 1, BASS_FILEDATA_END = 0, BASS_FILEPOS_START = 3, BASS_SAMPLE_8BITS = 1, _
     BASS_SAMPLE_FLOAT = 256, BASS_SAMPLE_MONO = 2, BASS_SAMPLE_LOOP = 4, BASS_SAMPLE_3D = 8, BASS_SAMPLE_SOFTWARE = 16, _
     BASS_SAMPLE_MUTEMAX = 32, BASS_SAMPLE_VAM = 64, BASS_SAMPLE_FX = 128, BASS_STREAM_PRESCAN = &h20000, BASS_STREAM_AUTOFREE = &h400001, _
     BASS_STREAM_RESTRATE = &h800001, BASS_STREAM_BLOCK = &h100000, BASS_STREAM_DECODE = &h200000, BASS_MUSIC_RAMP = &h200, _
     BASS_MUSIC_RAMPS = &h400, BASS_MUSIC_SURROUND = &h800, BASS_MUSIC_SURROUND2 = &h1000, BASS_MUSIC_FT2PAN = &h2000, _
     BASS_MUSIC_FT2MOD = &h2000, BASS_MUSIC_PT1MOD = &h4000, BASS_MUSIC_NONINTER = &h10000, BASS_MUSIC_STOPBACK = &h80000, _
     BASS_ASYNCFILE = &h40000000, BASS_CTYPE_SAMPLE = 1, BASS_CTYPE_RECORD = 2, BASS_CTYPE_STREAM = &h10000, BASS_CTYPE_STREAM_OGG = &h10002, _
     BASS_CTYPE_STREAM_MP1 = &h10003, BASS_CTYPE_STREAM_MP2 = &h10004, BASS_CTYPE_STREAM_MP3 = &h10005, BASS_CTYPE_STREAM_AIFF = &h10006, _
     BASS_CTYPE_STREAM_CA = &h10007, BASS_CTYPE_STREAM_MF = &h10008, BASS_CTYPE_STREAM_AM = &h10009, BASS_CTYPE_STREAM_DUMMY = &h18000, _
     BASS_CTYPE_STREAM_DEVICE = &h18001, BASS_CTYPE_STREAM_WAV = &h40000, BASS_CTYPE_STREAM_WAV_PCM = &h50001, BASS_CTYPE_STREAM_WAV_FLOAT = &h50003, _
     BASS_CTYPE_MUSIC_MOD = &h20000, BASS_CTYPE_MUSIC_MTM = &h20001, BASS_CTYPE_MUSIC_S3M = &h20002, BASS_CTYPE_MUSIC_XM = &h20003, _
     BASS_CTYPE_MUSIC_IT = &h20004, BASS_CTYPE_MUSIC_MO3 = &h00100, BASS_DATA_AVAILABLE = 0, BASS_DATA_FIXED = &h20000000, _
     BASS_DATA_FLOAT = &h40000000, BASS_DATA_FFT256 = &h80000000, BASS_DATA_FFT512 = &h80000001, BASS_DATA_FFT1024 = &h80000002, _
     BASS_DATA_FFT2048 = &h80000003, BASS_DATA_FFT4096 = &h80000004, BASS_DATA_FFT8192 = &h80000005, BASS_DATA_FFT16384 = &h80000006, _
     BASS_DATA_FFT32768 = &h80000007, BASS_DATA_FFT_INDIVIDUAL = &h10, BASS_DATA_FFT_NOWINDOW = &h20, BASS_DATA_FFT_REMOVEDC = &h40, _
     BASS_DATA_FFT_COMPLEX = &h80, BASS_DATA_FFT_NYQUIST = &h100, BASS_POS_BYTE = 0, BASS_POS_MUSIC_ORDER = 1, BASS_POS_OGG = 3, _
     BASS_ATTRIB_FREQ = 1, BASS_ATTRIB_VOL = 2, BASS_ATTRIB_PAN = 3, BASS_ATTRIB_EAXMIX = 4, BASS_ATTRIB_NOBUFFER = 5, BASS_ATTRIB_VBR = 6, _
     BASS_ATTRIB_CPU = 7, BASS_ATTRIB_SRC = 8, BASS_ATTRIB_NET_RESUME = 9, BASS_ATTRIB_SCANINFO = 10, BASS_ATTRIB_NORAMP = 11, _
     BASS_ATTRIB_BITRATE = 12, BASS_ATTRIB_BUFFER = 13, BASS_ATTRIB_MUSIC_AMPLIFY = &h100, BASS_ATTRIB_MUSIC_PANSEP = &h101, _
     BASS_ATTRIB_MUSIC_PSCALER = &h102, BASS_ATTRIB_MUSIC_BPM = &h103, BASS_ATTRIB_MUSIC_SPEED = &h104, BASS_ATTRIB_MUSIC_VOL_GLOBAL = &h105, _
     BASS_ATTRIB_MUSIC_ACTIVE = &h106, BASS_ATTRIB_MUSIC_VOL_CHAN = &h200, BASS_ATTRIB_MUSIC_VOL_INST = &h300, BASS_MUSIC_PRESCAN = BASS_STREAM_PRESCAN


Type HSTREAM As DWORD
type HPLUGIN as DWORD
type HSAMPLE as DWORD
type HMUSIC as DWORD
Type QWORD As Longint

Type BASS_DEVICEINFO
   As Zstring Ptr name, driver
   As DWORD flags
End Type

Type BASS_CHANNELINFO
   as DWORD freq, chans, flags, ctype, origres
   as HPLUGIN plugin
   as HSAMPLE sample
   as Zstring Ptr filename
end type


Dim Shared BASS_Init As Function stdcall(Byval As Long, Byval As DWORD, Byval As DWORD, Byval As HWND, Byval As GUID Ptr) As BOOL
Dim Shared BASS_GetDeviceInfo As Function stdcall(As DWORD, As BASS_DEVICEINFO Ptr) As Integer
Dim Shared BASS_GetDevice As Function stdcall() As DWORD
Dim Shared BASS_Free As Function stdcall() As BOOL
Dim Shared BASS_Stop As Function stdcall() As BOOL
Dim Shared BASS_SetVolume As Function stdcall(Byval As Single) As BOOL
Dim Shared BASS_ErrorGetCode As Function stdcall() As Integer
Dim Shared BASS_StreamGetFilePosition As Function stdcall(Byval As HSTREAM, As DWORD) As QWORD
Dim Shared BASS_StreamCreateFile As Function stdcall(Byval As BOOL, Byval As Any Ptr, Byval As QWORD, Byval As QWORD, Byval As DWORD) As HSTREAM
Dim Shared BASS_StreamFree As Function stdcall(Byval As HSTREAM) As BOOL
Dim Shared BASS_ChannelPlay As Function stdcall(Byval As DWORD, Byval As BOOL) As BOOL
Dim Shared BASS_ChannelStop As Function stdcall(Byval As DWORD) As BOOL
Dim Shared BASS_ChannelPause As Function stdcall(Byval As DWORD) As BOOL
Dim Shared BASS_ChannelGetInfo As Function stdcall(Byval As DWORD, As BASS_CHANNELINFO) As BOOL
Dim Shared BASS_ChannelGetData As Function stdcall(Byval As DWORD, As any Ptr, As DWORD) As DWORD
Dim Shared BASS_ChannelGetLevel As Function stdcall(Byval As DWORD) As DWORD
Dim Shared BASS_ChannelGetPosition As Function stdcall(Byval As DWORD, Byval As DWORD) As DWORD
Dim Shared BASS_ChannelGetLength As Function stdcall(Byval As DWORD, Byval As DWORD) As QWORD
Dim Shared BASS_ChannelBytes2Seconds As Function stdcall(Byval As DWORD, Byval As QWORD) As Double
Dim Shared BASS_ChannelSetAttribute As Function stdcall(Byval As DWORD, Byval As DWORD, Byval as single) As BOOL
Dim Shared BASS_MusicLoad As Function stdcall(Byval As BOOL, Byval As Any Ptr, Byval As QWORD, Byval As DWORD, Byval As DWORD, Byval As DWORD) As HMUSIC
Dim Shared BASS_MusicFree As Function stdcall(Byval As HMUSIC) As BOOL

Dim Shared As Any Ptr _g__hLib_Bass = 0
Dim Shared As Boolean _g__bSound = True

Function _Bass_Startup(sFolderDLL as string = CurDir) As Boolean
   #Ifdef __Fb_64bit__
      ? "Loading Bass64.dll"
      If Fileexists(sFolderDLL & "\Bass64.dll") = 0 Then
         _g__bSound = False
         Return False
      Else
         _g__hLib_Bass = Dylibload(sFolderDLL & "\Bass64.dll")
      Endif
   #Else
      ? "Loading Bass.dll"
      If Fileexists(sFolderDLL & "\Bass.dll") = 0 Then
         _g__bSound = False
         Return False
      Else
         _g__hLib_Bass = Dylibload(sFolderDLL & "\Bass.dll")
      Endif
   #Endif
   BASS_Init = Dylibsymbol(_g__hLib_Bass, "BASS_Init")
   If BASS_Init = 0 Then Return False
   BASS_Free = Dylibsymbol(_g__hLib_Bass, "BASS_Free")
   If BASS_Free = 0 Then Return False
   BASS_StreamCreateFile = Dylibsymbol(_g__hLib_Bass, "BASS_StreamCreateFile")
   If BASS_StreamCreateFile = 0 Then Return False
   BASS_StreamFree = Dylibsymbol(_g__hLib_Bass, "BASS_StreamFree")
   If BASS_StreamFree = 0 Then Return False
   BASS_ChannelPlay = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelPlay")
   If BASS_ChannelPlay = 0 Then Return False
   BASS_ChannelStop = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelStop")
   If BASS_ChannelStop = 0 Then Return False
   BASS_Stop = Dylibsymbol(_g__hLib_Bass, "BASS_Stop")
   If BASS_Stop = 0 Then Return False
   BASS_SetVolume = Dylibsymbol(_g__hLib_Bass, "BASS_SetVolume")
   If BASS_SetVolume = 0 Then Return False
   BASS_ErrorGetCode = Dylibsymbol(_g__hLib_Bass, "BASS_ErrorGetCode")
   If BASS_ErrorGetCode = 0 Then Return False
   BASS_GetDeviceInfo = Dylibsymbol(_g__hLib_Bass, "BASS_GetDeviceInfo")
   If BASS_GetDeviceInfo = 0 Then Return False
   BASS_GetDevice = Dylibsymbol(_g__hLib_Bass, "BASS_GetDevice")
   If BASS_GetDevice = 0 Then Return False   
   BASS_StreamGetFilePosition = Dylibsymbol(_g__hLib_Bass, "BASS_StreamGetFilePosition")
   If BASS_StreamGetFilePosition = 0 Then Return False
   BASS_ChannelGetInfo = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelGetInfo")
   If BASS_ChannelGetInfo = 0 Then Return False
   BASS_ChannelGetData = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelGetData")
   If BASS_ChannelGetData = 0 Then Return False
   BASS_ChannelGetLevel = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelGetLevel")
   If BASS_ChannelGetLevel = 0 Then Return False
   BASS_ChannelGetPosition = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelGetPosition")
   If BASS_ChannelGetPosition = 0 Then Return False
   BASS_ChannelPause = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelPause")
   If BASS_ChannelPause = 0 Then Return False
   BASS_ChannelGetLength = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelGetLength")
   If BASS_ChannelGetLength = 0 Then Return False            
   BASS_ChannelBytes2Seconds = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelBytes2Seconds")
   If BASS_ChannelBytes2Seconds = 0 Then Return False
   BASS_ChannelSetAttribute = Dylibsymbol(_g__hLib_Bass, "BASS_ChannelSetAttribute")
   If BASS_ChannelSetAttribute = 0 Then Return False   
   BASS_MusicLoad = Dylibsymbol(_g__hLib_Bass, "BASS_MusicLoad")
   If BASS_MusicLoad = 0 Then Return False
   BASS_MusicFree = Dylibsymbol(_g__hLib_Bass, "BASS_MusicFree")
   If BASS_MusicFree = 0 Then Return False   
   Return True
End Function

Function _Bass_Shutdown() As Boolean
   If _g__hLib_Bass > 0 Then
      Dylibfree(_g__hLib_Bass)
      Return True
   End If
   Return False
 End Function


Function _BASS_ErrorGetCode() As String
   Select Case BASS_ErrorGetCode()
      Case 0 : Return "No Error."
      Case 1 : Return "There is insufficient memory."
      Case 2 : Return "The file could not be opened."
      Case 3 : Return "Cannot find a free sound driver."
      Case 4 : Return "The sample buffer was lost."
      Case 5 : Return "Invalid handle."
      Case 6 : Return "Unsupported sample format."
      Case 7 : Return "Invalid position."
      Case 8 : Return "BASS_Init has not been successfully called."
      Case 9 : Return "BASS_Start has not been successfully called."
      Case 10 : Return "SSL/HTTPS support is not available."
      Case 14 : Return "Already initialized/paused/whatever."
      Case 17 : Return "The file does not contain audio, or it also contains video and videos are disabled."
      Case 18 : Return "Cannot get a free channel."
      Case 19 : Return "An illegal type was specified."
      Case 20 : Return "An illegal parameter was specified."
      Case 21 : Return "Could not initialize 3D support."
      Case 22 : Return "No EAX support."
      Case 23 : Return "Illegal device number."
      Case 24 : Return "Not playing."
      Case 25 : Return "Illegal sample rate."
      Case 27 : Return "The stream is not a file stream."
      Case 29 : Return "No hardware voices available."
      Case 31 : Return "The Mod music has no sequence Data."
      Case 32 : Return "No internet connection could be opened."
      Case 33 : Return "Could not create the file."
      Case 34 : Return "Effects are not available."
      Case 37 : Return "Requested data is not available."
      Case 38 : Return "The channel is a decoding channel"
      Case 39 : Return "A sufficient DirectX version is not installed."
      Case 40 : Return "Connection timed out."
      Case 41 : Return "The file's format is not recognised/supported."
      Case 42 : Return "The specified SPEAKER flags are invalid."
      Case 43 : Return "The plugin requires a different BASS version."
      Case 44 : Return "Codec is not available/supported."
      Case 45 : Return "The channel/file has ended."
      Case 46 : Return "Something else has exclusive use of the device."
      Case 47 : Return "The file cannot be streamed using the buffered file system."
      Case -1 : Return "Some other mystery problem!"
   End Select
   Return "Hmmmm."
End Function

Function _Bass_Init(Device As DWORD = -1, Freq As Dword = 44100, Flags As Dword = 0, Win As HWND = Null, clsid As GUID Ptr = Null) As Boolean
   Return BASS_Init(Device, Freq, Flags, Win, clsid)
End Function

Function _Bass_Free() As Boolean
   Return BASS_Free()
End Function

Function _Bass_Stop() As Boolean
   Return BASS_Stop()
End Function
'Device-----------------------------------------------------------------------------------------------------------------------------------------
Function _BASS_GetDevice() As DWORD
   Return BASS_GetDevice()
End Function

Function _BASS_GetDeviceInfo(Device As DWORD, Info As BASS_DEVICEINFO Ptr) As Boolean
   Return BASS_GetDeviceInfo(Device, Info)
End Function
'Stream-----------------------------------------------------------------------------------------------------------------------------------------
Function _BASS_StreamFree(hStream As HSTREAM) As Boolean
   Return BASS_StreamFree(hStream)
End Function

Function _BASS_StreamCreateFile(File As String, Flags As Dword = 0, offset As QWORD = 0, Length As QWORD = 0, Mem As Boolean = False) As HSTREAM
   Return BASS_StreamCreateFile(Mem, StrPtr(File), offset, Length, Flags)
End Function

Function _BASS_StreamCreateMem(pMem As Any Ptr, Length As QWORD = 0, Flags As Dword = 0, offset As QWORD = 0, Mem As Boolean = True) As HSTREAM
   Return BASS_StreamCreateFile(Mem, pMem, offset, Length, Flags or BASS_UNICODE)
End Function

Function _BASS_SetVolume(Volume As Single) As Boolean
   Return BASS_SetVolume(Iif(Volume < 0, 0, Iif(Volume > 1.0, 1.0, Volume)))
End Function

Function _BASS_StreamGetFilePosition(hStream As HSTREAM, Mode As Dword) As QWORD
   Return BASS_StreamGetFilePosition(hStream, Mode)
End Function
'Music------------------------------------------------------------------------------------------------------------------------------------------
Function _BASS_MusicLoad(File As String, Flags As DWORD = 0, Freq as DWORD = 0, offset As QWORD = 0, Length As DWORD = 0, Mem As Boolean = False) As HMUSIC
   Return BASS_MusicLoad(Mem, StrPtr(File), offset, Length, Flags, Freq)
End Function

Function _BASS_MusicLoadMem(pMem As Any Ptr, Flags As DWORD = 0, Freq as DWORD = 0, offset As QWORD = 0, Length As DWORD = 0, Mem As Boolean = True) As HMUSIC
   Return BASS_MusicLoad(Mem, pMem, offset, Length, Flags, Freq)
End Function

Function _BASS_MusicFree(Handle as HMUSIC) as Boolean
   Return BASS_MusicFree(Handle)
end function
'Channel----------------------------------------------------------------------------------------------------------------------------------------
Function _BASS_ChannelPlay(Handle As DWORD, Restart As BOOL = False) As Boolean
   Return BASS_ChannelPlay(Handle, Restart)
End Function

Function _BASS_ChannelStop(Handle As DWORD) As Boolean
   Return BASS_ChannelStop(Handle)
End Function

Function _BASS_ChannelPause(Handle As DWORD) As Boolean
   Return BASS_ChannelPause(Handle)
End Function

Function _BASS_ChannelGetInfo(Handle as DWORD, ChanInfo as BASS_CHANNELINFO) as Boolean
   Return BASS_ChannelGetInfo(Handle, ChanInfo)
end function

Function _BASS_ChannelGetData(Handle As DWORD, Buffer As Any Ptr, Length As DWORD) As DWORD
   Return BASS_ChannelGetData(Handle, Buffer, Length)
End Function

Function _BASS_ChannelGetLevel(Handle As DWORD) As DWORD
   Return BASS_ChannelGetLevel(Handle)
End Function

Function _BASS_ChannelGetPosition(Handle As DWORD, Mode As DWORD) As QWORD
   Return BASS_ChannelGetPosition(Handle, Mode)
End Function

Function _BASS_ChannelGetLength(Handle As DWORD, Mode As DWORD = BASS_POS_BYTE) As QWORD
   Return BASS_ChannelGetLength(Handle, Mode)
End Function

Function _BASS_ChannelBytes2Seconds(Handle As DWORD, Position As QWORD) As Double
   Return BASS_ChannelBytes2Seconds(Handle, Position)
End Function

Function _BASS_ChannelSetAttribute(Handle As DWORD, Attrib As DWORD, Value As Single) As BOOL
   Return BASS_ChannelSetAttribute(Handle, Attrib, Value)
End Function

'-----------------------------------------------------------------------------------------------------------------------------------------------
