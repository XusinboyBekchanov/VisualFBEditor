@echo off

cd ..\..\

set e7Zip=7z

curl -L -O https://www.7-zip.org/a/7za920.zip

PowerShell Expand-Archive -LiteralPath "7za920.zip" -DestinationPath ".\7z" -Force

set e7Zip=%~dp0\7z\7za.exe

:compiler

curl -L -O https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Windows/FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z

:setpath

set FBC32=%~dp0Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc32.exe

:downloadsources

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "Controls" -Force

"%e7Zip%" x "FreeBASIC-1.09.0-winlibs-gcc-9.3.0.7z" -o%~dp0Compilers

:start

cd Controls

Rename MyFbFramework-master MyFbFramework

cd MyFbFramework\mff

"%FBC32%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v

cd ..\..\..\src

"%FBC32%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v

cd ..\