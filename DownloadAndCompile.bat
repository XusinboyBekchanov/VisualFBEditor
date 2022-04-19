curl -L -O https://github.com/XusinboyBekchanov/VisualFBEditor/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "." -Force

Rename VisualFBEditor-master VisualFBEditor

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "VisualFBEditor" -Force

cd VisualFBEditor

Rename MyFbFramework-master MyFbFramework

cd MyFbFramework\mff

set FBC=D:\FreeBasic\FreeBASIC-1.09.0-winlibs-gcc-9.3.0\fbc32.exe

"%FBC%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v

cd ..\..\..\VisualFBEditor\src

"%FBC%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\MyFbFramework" -v

cd ..\..\