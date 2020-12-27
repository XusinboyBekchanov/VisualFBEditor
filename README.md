# VisualFBEditor
## IDE for FreeBasic

#### Introduction
VisualFBEditor is the IDE for FreeBasic with visul designer, debugger, project support and etc. VisualFBEditor based on the library <a href="https://github.com/XusinboyBekchanov/MyFbFramework">MyFbFramework</a>.

#### Requirements:

* FreeBASIC Compiler: http://www.freebasic.net/

#### Compilation:

To compile use the following command lines:

#### For Windows 32-bit:
```shell
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "Path_to_MyFbFramework"
```
#### For Windows 64-bit:
```shell
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "Path_to_MyFbFramework"
```
#### For Linux 32-bit:
```shell
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "Path_to_MyFbFramework"
```
#### For Linux 64-bit:
```shell
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "Path_to_MyFbFramework"
```
#### Sample bat file:
```shell
REM Sample Windows 64 bit Build

REM CHANGE ACC. YOUR SETUP / PATHS

REM Change path to the VisualFBEditor source

c:

cd "C:\FreeBasic\Projects\VisualFBEditor-master\src"


REM A Copy of the MyFbFramework was also placed to

REM "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework"

REM the 64 bit FreeBasic compiler is located in

REM "C:\FreeBasic\X64\fbc.exe"

REM "Version 1.08.0 64 bit Windows build"

REM BUILD COMMAND

"C:\FreeBasic\X64\fbc.exe" "VisualFBEditor.bas" -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework"

"C:\FreeBasic\X64\fbc.exe" "..\MyFbFramework\mff\mff.bi" -dll -x "..\MyFbFramework\mff64.dll" "..\MyFbFramework\mff\mff.rc"
```
