#include "windows.bi"   ' JJ 18.4.2020
Dim Shared As Handle hEdit
Function WndProc(hWnd As HWND, msg As  UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
  Dim As RECT rc
  Dim As PAINTSTRUCT ps
  Dim As HANDLE PtDC
  Dim As HMENU hMenu, hPopup, hEsi
  Select Case msg
  Case WM_CREATE
   hMenu=CreateMenu()               ' create the main menu
   hPopup=CreatePopupMenu()               ' create a sub-menu
   AppendMenu(hMenu, MF_POPUP, hPopup, "&File")      ' add it to the main menu
   AppendMenu(hPopup, MF_STRING, 101, "&Open")       ' one more main item
   hEsi=CreatePopupMenu()               ' create a sub-menu
   AppendMenu(hEsi, MF_STRING, 121, "&sources")      ' fill it
   AppendMenu(hEsi, MF_STRING, 122, "&includes")      ' with various
   AppendMenu(hEsi, MF_STRING, 123, "&DLLs")         ' options
   AppendMenu(hPopup, MF_POPUP, hEsi, "&Dir")      ' and add it to the main menu as "Dir"
   AppendMenu(hPopup, MF_STRING, 102, "&Save")       ' one more main item
   AppendMenu(hPopup, MF_STRING, 103, "E&xit")       ' one more main item
   SetMenu(hWnd, hMenu)               ' attach menu to main window
   hEdit=CreateWindowEx(WS_EX_CLIENTEDGE, "edit", "Hello, I am an edit control",_
   WS_CHILD Or WS_VISIBLE or ES_MULTILINE, 0, 0, 100, 100, hWnd, 100, 0, 0)
  Case WM_COMMAND
   Select Case wParam
       Case 101: MessageBox(hWnd, "Open not implemented", 0, MB_OK)
       Case 102: MessageBox(hWnd, "Save not implemented", 0, MB_OK)
       Case 121: MessageBox(hWnd, "No *.bas files found", 0, MB_OK)
       Case 122: MessageBox(hWnd, "No *.inc files found", 0, MB_OK)
       Case 123: MessageBox(hWnd, "No *.dll files found", 0, MB_OK)
       Case 103: SendMessage(hWnd, WM_CLOSE, 0, 0)
   End Select
  Case WM_PAINT
   PtDC=BeginPaint(hWnd, @ps)
   TextOut(PtDC, 3, 3, "TextOut in the WM_PAINT handler", 31)
   EndPaint(hWnd, @ps)
  Case WM_KEYDOWN
     if wParam=VK_ESCAPE then SendMessage(hWnd, WM_CLOSE, 0, 0)
  Case WM_SIZE
   GetClientRect(hWnd, @rc)
   MoveWindow(hEdit, 3, 28, rc.right-6, rc.bottom-30, 0)
  Case WM_DESTROY
      PostQuitMessage(0)
  End Select
  return DefWindowProc(hwnd, msg, wParam, lParam)
End Function

Function WinMain(hInstance As HINSTANCE, hPrevInstance As HINSTANCE, lpCmdLine As LPSTR, nShowCmd As Integer) As Integer
  Dim As WNDCLASSEX wc
  Dim As MSG msg
  Dim As string classname="FbGui"
  Dim As HANDLE hIconLib, hDll
  type pCall as function (xy as any ptr) as long
  Dim As pCall pGetVersion
  type DLLVERSIONINFO
   cbSize as long
   dwMajorVersion as long
   dwMinorVersion as long
   dwBuildNumber as long
   dwPlatformID as long
  end type
  Dim As DLLVERSIONINFO dvi
  dvi.cbSize=sizeof(DLLVERSIONINFO)
  hIconLib=LoadLibrary("shell32")
  wc.hIcon = LoadIcon(hIconLib, 239)   ' get the butterfly icon
  FreeLibrary(hIconLib)
  hDll=LoadLibrary("ComCtl32")
  pGetVersion=GetProcAddress(hDll, "DllGetVersion")
  pGetVersion(@dvi)
  if @dvi.dwMajorVersion then print "Using common controls version ";str(dvi.dwMajorVersion);".";str(dvi.dwMinorVersion)
  FreeLibrary(hDll)
  wc.cbSize = sizeof(WNDCLASSEX)
  wc.hbrBackground = COLOR_BTNFACE+1
  wc.hCursor = LoadCursor(0, IDC_ARROW)
  wc.hIconSm = wc.hIcon
  wc.hInstance = hInstance
  wc.lpfnWndProc = @WndProc
  wc.lpszClassName = StrPtr(classname)
  wc.style = CS_HREDRAW Or CS_VREDRAW
  RegisterClassEx(@wc)
  If CreateWindowEx(0, wc.lpszClassName, "Hello World",_
   WS_OVERLAPPEDWINDOW Or WS_VISIBLE, (GetSystemMetrics(SM_CXSCREEN) / 2) - 150,_
   (GetSystemMetrics(SM_CYSCREEN) / 2) - 150, 300, 300, 0, 0, hInstance, 0)=0 Then
          MessageBox(0, "Creating hMain failed miserably", 0, MB_OK)
          Return 0
  End If

  While GetMessage(@msg, 0, 0, 0)
      TranslateMessage(@msg)
      DispatchMessage(@msg)
  Wend

  Return msg.wParam
End Function
WinMain(GetModuleHandle(NULL), NULL, COMMAND(), SW_NORMAL)
