# VisualFBEditor
## IDE for FreeBasic

#### Introduction
VisualFBEditor is the IDE for FreeBasic with visual designer, debugger, project support and etc. VisualFBEditor based on the library <a href="https://github.com/XusinboyBekchanov/MyFbFramework">MyFbFramework</a>.

#### Requirements:

* FreeBASIC Compiler: http://www.freebasic.net/

#### Screenshots
![ScreenShot](https://www.cyberforum.ru/blog_attachment.php?attachmentid=4921&d=1531765249)
![ScreenShot](https://www.cyberforum.ru/blog_attachment.php?attachmentid=5144&d=1545153885)

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

"C:\FreeBasic\X64\fbc.exe" "VisualFBEditor.bas" "VisualFBEditor.rc" -x "../VisualFBEditor64.exe" -i "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework"

REM Change path to the MyFbFramework source

cd "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework\mff"

"C:\FreeBasic\X64\fbc.exe" -b "mff.bi" "mff.rc" -dll -x "..\mff64.dll"
```
