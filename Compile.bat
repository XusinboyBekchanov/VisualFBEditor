@echo on
set FBC32=%~dp0Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc32.exe
set FBC64=%~dp0Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc64.exe
@echo %time%
cd Controls\MyFbFramework\mff
@echo %time%
"%FBC32%" -b "mff.bi" "mff.rc" -dll -gen gcc -Wc -O2 -x "../mff32.dll" -v
@echo %time%
"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -Wc -O2 -x "../mff64.dll" -v
@echo %time%
cd ..\..\..\..\VisualFBEditor\src
@echo %time%
"%FBC32%" "VisualFBEditor.bas" -s gui -gen gcc -Wc -O2 -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v
@echo %time%
"%FBC64%" "VisualFBEditor.bas" -s gui -gen gcc -Wc -O2 -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v
@echo %time%
cd ..\
Pause
exit