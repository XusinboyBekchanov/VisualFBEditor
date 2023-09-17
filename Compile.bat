set FBC32=%~dp0Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc32.exe
set FBC64=%~dp0Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc64.exe

cd Controls\MyFbFramework\mff

"%FBC32%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v
"%FBC64%" -b "mff.bi" "mff.rc" -dll -x "../mff64.dll" -v

cd ..\..\..\..\VisualFBEditor\src

"%FBC32%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v
"%FBC64%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v

cd ..\
