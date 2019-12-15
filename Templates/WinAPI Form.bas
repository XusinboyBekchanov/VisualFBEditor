'#Compile -exx "Form1.rc"
#INCLUDE "windows.bi"
#INCLUDE "win\commctrl.bi"
Dim msg As MSG 'структурированная переменная MSG
Dim As WNDCLASSEX wc 'структурированная переменная WNDCLASSEX
Dim As String NameClass="MyClass" ' переменная имени класса
Dim As HINSTANCE Hinst=GetModuleHandle(0) ' хендл модуля
' функция класса
Function wndproc(hwnd As HWND, msg As Uinteger,_
    wparam As WPARAM, lparam As LPARAM) As Integer
    Static As HWND edit1,edit2,edit3,edit4,button
    Select Case msg
        Case WM_CREATE
            edit1=CreateWindowEx(0,"edit","Простой Edit с горизонтальным автоскролом",WS_VISIBLE Or WS_CHILD Or ES_AUTOHSCROLL,10,10,130,20,hwnd,Cast(HMENU,1),0,0)
            edit2=CreateWindowEx(0,"edit","Ввод с клавиатуры только чисел",WS_VISIBLE Or ES_NUMBER Or WS_CHILD,10,40,230,20,hwnd,Cast(HMENU,2),0,0)
            edit3=CreateWindowEx(0,"edit","Пароль",WS_VISIBLE Or ES_PASSWORD Or WS_CHILD,10,70,80,20,hwnd,Cast(HMENU,3),0,0)
            edit4=CreateWindowEx(0,"edit","Многострочный Edit" ,WS_VISIBLE Or ES_MULTILINE Or ES_AUTOVSCROLL Or WS_CHILD,10,100,100,100,hwnd,Cast(HMENU,4),0,0)
            button=CreateWindowEx(0,"button","вставить текст" ,WS_VISIBLE  Or WS_CHILD,130,100,100,20,hwnd,Cast(HMENU,5),0,0)
        Case WM_COMMAND
            If Loword(wparam)=3 Then
                Dim As ZString*256 text
                GetWindowText(Edit3,@text,256)
                SetWindowText(Edit4,@text)
            Elseif Loword(wparam)=5 Then
                Dim As ZString*256 text
                GetWindowText(Edit2,@text,256)
                SendMessage(Edit4,EM_REPLACESEL,1,Cast(Lparam,@text))
            Endif
        Case WM_DESTROY
            PostQuitMessage(0)
    End Select
    Return DefWindowProc(hwnd,msg,wparam,lparam)
End Function
' Заполнение структуры WNDCLASSEX
With wc
    .cbSize=SizeOf(WNDCLASSEX)
    .style=CS_HREDRAW Or CS_VREDRAW
    .lpfnWndProc=@wndproc
    .hInstance=Hinst
    .hIcon=LoadIcon(0,IDI_QUESTION)
    .hCursor=LoadCursor(0,IDC_ARROW)
    .hbrBackground=Cast(HBRUSH,COLOR_WINDOW)
    .lpszClassName=StrPtr(NameClass)
    .hIconSm=.hIcon
End With
' Регистрация класса окна
If RegisterClassEx(@wc)=0 Then
    Print "Register error, press any key"
    Sleep
    End
Endif
InitCommonControls
'Создание окна
CreateWindowEx(0,NameClass,"Главное окно",_
WS_VISIBLE Or WS_OVERLAPPEDWINDOW,10,10,300,300,0,0,Hinst,0)
' Цикл сообщений
While GetMessage(@msg,0,0,0)
    TranslateMessage(@msg)
    DispatchMessage(@msg)
Wend
