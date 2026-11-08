cd ..
cd ..
cd ..

curl -L -O https://www.7-zip.org/a/7za920.zip

PowerShell Expand-Archive -LiteralPath "7za920.zip" -DestinationPath ".\7z" -Force

curl -L -O https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Windows/FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z

set FBC32=%~dp0..\..\Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc32.exe

rem MyFbFramework: git clone (the archive master.zip of github.com sometimes gives an error page instead of the zip), 3 tries
git clone --depth 1 https://github.com/XusinboyBekchanov/MyFbFramework VisualFBEditor\Controls\MyFbFramework || git clone --depth 1 https://github.com/XusinboyBekchanov/MyFbFramework VisualFBEditor\Controls\MyFbFramework || git clone --depth 1 https://github.com/XusinboyBekchanov/MyFbFramework VisualFBEditor\Controls\MyFbFramework
if not exist VisualFBEditor\Controls\MyFbFramework\mff\mff.bi exit 1

7z\7za.exe x "FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z" -oVisualFBEditor\Compilers

cd VisualFBEditor\Controls\MyFbFramework\mff

"%FBC32%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v

if not exist ../mff32.dll exit 1

cd ..\..\..\src

"%FBC32%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v

if not exist ../VisualFBEditor32.exe exit 1

cd ..
ls
