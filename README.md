# VisualFBEditor
## IDE for FreeBasic

#### Introduction
VisualFBEditor is the IDE for FreeBasic with visual designer, debugger, project support and etc. VisualFBEditor based on the library <a href="https://github.com/XusinboyBekchanov/MyFbFramework">MyFbFramework</a>.

#### Requirements:

* FreeBASIC Compiler: http://www.freebasic.net/

#### Screenshots
![ScreenShot](https://www.cyberforum.ru/blog_attachment.php?attachmentid=4921&d=1531765249)
![ScreenShot](https://www.cyberforum.ru/blog_attachment.php?attachmentid=5144&d=1545153885)
![ScreenShot](https://github.com/XusinboyBekchanov/VisualFBEditor/blob/master/Resources/VisualFBEditor.png)
![ScreenShot](https://github.com/XusinboyBekchanov/VisualFBEditor/blob/master/Resources/VisualFBEditor1.png)
![ScreenShot](https://github.com/XusinboyBekchanov/VisualFBEditor/blob/master/Resources/VisualFBEditor2.png)

#### Compilation:

To compile use the following command lines:

#### For Windows 32-bit:
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32.dll"
```
#### For Windows 32-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32_gtk2.exe" "VisualFBEditor.rc" -d __USE_GTK__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32_gtk2.dll"
```
#### For Windows 32-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32_gtk3.exe" "VisualFBEditor.rc" -d __USE_GTK__ -d __USE_GTK3__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32_gtk3.dll"
```
#### For Windows 64-bit:
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64.dll"
```
#### For Windows 64-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64_gtk2.exe" "VisualFBEditor.rc" -d __USE_GTK__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64_gtk2.dll"
```
#### For Windows 64-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64_gtk3.exe" "VisualFBEditor.rc" -d __USE_GTK__ -d __USE_GTK3__ -i "Path_to_VisualFBEditor/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64_gtk3.dll"
```
#### For Linux 32-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk2" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff32_gtk2.so"
```
#### For Linux 32-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "Path_to_VisualFBEditor/MyFbFramework" -d __USE_GTK3__
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff32_gtk3.so" -d __USE_GTK3__
```
#### For Linux 64-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk2" -i "Path_to_VisualFBEditor/MyFbFramework"
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff64_gtk2.so"
```
#### For Linux 64-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "Path_to_VisualFBEditor/MyFbFramework" -d __USE_GTK3__
  cd Path_to_VisualFBEditor/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff64_gtk3.so" -d __USE_GTK3__
```
#### Sample bat file:
```shell
REM Sample Windows 64 bit Build

REM CHANGE YOUR SETUP / PATHS

REM Change path to the VisualFBEditor source

c:

cd "C:\FreeBasic\Projects\VisualFBEditor-master\src"

REM A Copy of the MyFbFramework was also placed to

REM "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework"

REM the 64 bit FreeBasic compiler is located in

REM "C:\FreeBasic\X64\fbc.exe"

REM "Version 1.08.0 64 bit Windows build"

REM BUILD COMMAND

"C:\FreeBasic\X64\fbc.exe" "VisualFBEditor.bas" "VisualFBEditor.rc" -s gui -x "../VisualFBEditor64.exe" -i "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework"

REM Change path to the MyFbFramework source

cd "C:\FreeBasic\Projects\VisualFBEditor-master\MyFbFramework\mff"

"C:\FreeBasic\X64\fbc.exe" -b "mff.bi" "mff.rc" -dll -x "..\mff64.dll"
```
__
