@echo off

set /p Bit=What bitness of VisualFBEditor do you want to compile (32/64/both)? 

set /p DownloadCompiler=Do you want to download FreeBASIC Compiler 1.09.0 (yes/no/downloaded)? 

if "%DownloadCompiler%" == "no" goto selectpath

set /p Download7Zip=Do you want to download 7-Zip (yes/no)? 

set e7Zip=7z

if "%Download7Zip%" == "no" goto compiler

curl -L -O https://www.7-zip.org/a/7za920.zip

PowerShell Expand-Archive -LiteralPath "7za920.zip" -DestinationPath ".\7z" -Force

set e7Zip=%~dp0\7z\7za.exe

:compiler

if "%DownloadCompiler%" == "downloaded" goto unpack

curl -L -O https://sourceforge.net/projects/fbc/files/FreeBASIC-1.09.0/Binaries-Windows/winlibs-gcc-9.3.0/FreeBASIC-1.09.0-winlibs-gcc-9.3.0.7z

:unpack

"%e7Zip%" x "FreeBASIC-1.09.0-winlibs-gcc-9.3.0.7z"

set FBC32=%~dp0FreeBASIC-1.09.0-winlibs-gcc-9.3.0\fbc32.exe

set FBC64=%~dp0FreeBASIC-1.09.0-winlibs-gcc-9.3.0\fbc64.exe

goto download

:selectpath

if "%Bit%" == "64" goto selectpath64

set /p FBC32=Enter 32-bit compiler path: 

if "%Bit%" == "32" goto download

:selectpath64

set /p FBC64=Enter 64-bit compiler path: 

:download

set /p Download=Do you want to download VisualFBEditor and MyFbFramework (yes/no)? 

if "%Download%" == "no" goto start

curl -L -O https://github.com/XusinboyBekchanov/VisualFBEditor/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "." -Force

Rename VisualFBEditor-master VisualFBEditor

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "VisualFBEditor" -Force

:start

cd VisualFBEditor

Rename MyFbFramework-master MyFbFramework

cd ..\

if "%Bit%" == "64" goto compile64

cd VisualFBEditor\MyFbFramework\mff

"%FBC32%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v

cd ..\..\..\VisualFBEditor\src

"%FBC32%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\MyFbFramework" -v

cd ..\..\

if "%Bit%" == "32" goto finish

:compile64

cd VisualFBEditor\MyFbFramework\mff

"%FBC64%" -b "mff.bi" "mff.rc" -dll -x "../mff64.dll" -v

cd ..\..\..\VisualFBEditor\src

"%FBC64%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\MyFbFramework" -v

cd ..\..\

:finish
