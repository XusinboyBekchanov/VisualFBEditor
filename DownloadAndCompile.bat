curl -L -O https://github.com/XusinboyBekchanov/VisualFBEditor/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "." -Force

Rename VisualFBEditor-master VisualFBEditor

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "VisualFBEditor\Controls" -Force

cd VisualFBEditor\Controls

Rename MyFbFramework-master MyFbFramework

cd MyFbFramework\mff

set FBC32=D:\FreeBasic\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc32.exe
set FBC64=D:\FreeBasic\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc64.exe

"%FBC32%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v
"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -Wc -O3 -x "../mff64.dll" -v

cd ..\..\..\..\VisualFBEditor\src

"%FBC32%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v
"%FBC64%" "VisualFBEditor.bas" -s gui -gen gcc -Wc -O3 -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v

cd ..\..\
