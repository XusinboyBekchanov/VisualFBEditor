cd ..
cd ..
cd ..

curl -L -O https://www.7-zip.org/a/7za920.zip

PowerShell Expand-Archive -LiteralPath "7za920.zip" -DestinationPath ".\7z" -Force

curl -L -O https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Windows/FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z

set FBC32=%~dp0..\..\Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc32.exe

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "VisualFBEditor\Controls" -Force

7z\7za.exe x "FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z" -oVisualFBEditor\Compilers

cd VisualFBEditor\Controls

Rename MyFbFramework-master MyFbFramework

cd MyFbFramework\mff

"%FBC32%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v

if not exist ../mff32.dll exit 1

cd ..\..\..\src

"%FBC32%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v

if not exist ../VisualFBEditor32.exe exit 1

cd ..
ls
