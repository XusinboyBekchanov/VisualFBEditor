@echo off

set /p DownloadCompiler=Do you want to download FreeBASIC Compiler 1.10.0 (yes/no/downloaded)? 

set /p DownloadGDB=Do you want to download gdb 11.2.90.20220320 (yes/no)? 

set /p Download7Zip=Do you want to download 7-Zip (yes/no)? 

set e7Zip=7z

if "%Download7Zip%" == "no" goto compiler

curl -L -O https://www.7-zip.org/a/7za920.zip

PowerShell Expand-Archive -LiteralPath "7za920.zip" -DestinationPath ".\7z" -Force

set e7Zip=%~dp0\7z\7za.exe

:compiler

if "%DownloadCompiler%" == "no" goto selectpath

if "%DownloadCompiler%" == "downloaded" goto setpath

curl -L -O https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Windows/FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z

:setpath

set FBC32=%~dp0VisualFBEditor\Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc32.exe

set FBC64=%~dp0VisualFBEditor\Compilers\FreeBASIC-1.10.0-winlibs-gcc-9.3.0\fbc64.exe

goto download

:selectpath

if "%PROCESSOR_ARCHITEW6432%" == "AMD64" Set Bit = "64"
if "%PROCESSOR_ARCHITECTURE%" == ""      Set PROCESSOR_ARCHITECTURE = x86
if "%PROCESSOR_ARCHITECTURE%" == "x86"   Set Bit = "32"
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" Set Bit = "64"

if "%Bit%" == "64" Set Bit = "both"

if "%Bit%" == "64" goto selectpath64

set /p FBC32=Enter 32-bit compiler path: 

if "%Bit%" == "32" goto download

:selectpath64

set /p FBC64=Enter 64-bit compiler path: 

:download

if "%DownloadGDB%" == "no" goto downloadsources

curl -L -O https://github.com/ssbssa/gdb/releases/download/gdb-11.2.90.20220320/gdb-11.2.90.20220320-i686.7z

curl -L -O https://github.com/ssbssa/gdb/releases/download/gdb-11.2.90.20220320/gdb-11.2.90.20220320-x86_64.7z

:downloadsources

curl -L -O https://github.com/XusinboyBekchanov/VisualFBEditor/archive/master.zip

RMDIR /S /Q VisualFBEditor

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "." -Force

Rename VisualFBEditor-master VisualFBEditor

curl -L -O https://github.com/XusinboyBekchanov/MyFbFramework/archive/master.zip

PowerShell Expand-Archive -LiteralPath "master.zip" -DestinationPath "VisualFBEditor\Controls" -Force

if "%DownloadCompiler%" == "no" goto label7z

"%e7Zip%" x "FreeBASIC-1.10.0-winlibs-gcc-9.3.0.7z" -o%~dp0VisualFBEditor\Compilers

:label7z

if "%Download7Zip%" == "no" goto start

"%e7Zip%" x "gdb-11.2.90.20220320-i686.7z" -o%~dp0VisualFBEditor\Debuggers\gdb-11.2.90.20220320-i686

"%e7Zip%" x "gdb-11.2.90.20220320-x86_64.7z" -o%~dp0VisualFBEditor\Debuggers\gdb-11.2.90.20220320-x86_64

:start

cd VisualFBEditor\Controls

Rename MyFbFramework-master MyFbFramework

cd ..\..\

if "%Bit%" == "64" goto compile64

cd VisualFBEditor\Controls\MyFbFramework\mff

"%FBC32%" -b "mff.bi" "mff.rc" -dll -x "../mff32.dll" -v

cd ..\..\..\..\VisualFBEditor\src

"%FBC32%" "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v

cd ..\..\

if "%Bit%" == "32" goto finish

:compile64

cd VisualFBEditor\Controls\MyFbFramework\mff

"%FBC64%" -b "mff.bi" "mff.rc" -dll -x "../mff64.dll" -v

cd ..\..\..\..\VisualFBEditor\src

"%FBC64%" "VisualFBEditor.bas" -s gui -gen gcc -Wc -O3 -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v

cd ..\..\..\

:finish
