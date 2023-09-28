Language: <b>English</b> | <a href="README_CN.md">中文介绍</a>
# Visual FB Editor
## IDE for FreeBasic

#### Introduction
VisualFBEditor is the IDE for FreeBasic with visual designer, debugger, project support and etc. VisualFBEditor based on the library <a href="https://github.com/XusinboyBekchanov/Controls/MyFbFramework">MyFbFramework</a>.

#### Requirements:

* FreeBASIC Compiler V 1.10.0 or above: http://www.freebasic.net/

#### Screenshots
![VisualFBEditor-1](https://user-images.githubusercontent.com/35757455/197079538-16cc5d7d-150e-46f1-b673-f9fe7352ad17.png)
![VisualFBEditor-2](https://user-images.githubusercontent.com/35757455/197079581-596100e9-86be-4469-8aae-104309845b2c.png)
![VisualFBEditor-3](https://user-images.githubusercontent.com/35757455/197079617-4c4d6902-3809-40da-a746-46bcdf993a75.png)
![VisualFBEditor-4](https://user-images.githubusercontent.com/35757455/197079674-2a2a685e-2403-4b8b-9b3b-95c4cc8bf5dc.png)
![VisualFBEditor-5](https://user-images.githubusercontent.com/35757455/197079706-5419cc84-db93-48b2-93f9-456db2414956.png)
![VisualFBEditor-6](https://user-images.githubusercontent.com/35757455/197079725-a88431cb-34e7-4a75-be8f-cd7f3f845ce5.png)
![image](https://github.com/XusinboyBekchanov/VisualFBEditor/assets/32607344/f98ffda9-88be-4e67-8074-1b58b24ae151)

#### Compilation:

To compile use the following command lines:

#### For Windows 32-bit:
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "Path_to_VisualFBEditor/Controls/MyFbFramework"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32.dll"
```
#### For Windows 32-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32_gtk2.exe" "VisualFBEditor.rc" -d __USE_GTK__ -i "Path_to_VisualFBEditor/Controls/MyFbFramework" -p "Path_to_msys2\msys32\mingw32\lib"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32_gtk2.dll" -d __USE_GTK__ -p "Path_to_msys2\msys32\mingw32\lib"
```
#### For Windows 32-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor32_gtk3.exe" "VisualFBEditor.rc" -d __USE_GTK__ -d __USE_GTK3__ -i "Path_to_VisualFBEditor/Controls/MyFbFramework" -p "Path_to_msys2\msys32\mingw32\lib"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff32_gtk3.dll" -d __USE_GTK__ -d __USE_GTK3__ -p "Path_to_msys2\msys32\mingw32\lib"
```
#### For Windows 64-bit:
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "Path_to_VisualFBEditor/Controls/MyFbFramework"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64.dll"
```
#### For Windows 64-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64_gtk2.exe" "VisualFBEditor.rc" -d __USE_GTK__ -i "Path_to_VisualFBEditor/Controls/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64_gtk2.dll" -d __USE_GTK__ -p "Path_to_msys2\msys32\mingw64\lib"
```
#### For Windows 64-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -s gui -x "../VisualFBEditor64_gtk3.exe" "VisualFBEditor.rc" -d __USE_GTK__ -d __USE_GTK3__ -i "Path_to_VisualFBEditor/Controls/MyFbFramework" -p "Path_to_msys2\msys32\mingw64\lib"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" "mff.rc" -dll -x "../mff64_gtk3.dll" -d __USE_GTK__ -d __USE_GTK3__ -p "Path_to_msys2\msys32\mingw64\lib"
```
#### For Linux 32-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk2" -i "Path_to_VisualFBEditor/Controls/MyFbFramework"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff32_gtk2.so"
```
#### For Linux 32-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "Path_to_VisualFBEditor/Controls/MyFbFramework" -d __USE_GTK3__
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff32_gtk3.so" -d __USE_GTK3__
```
#### For Linux 64-bit (for gtk2):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk2" -i "Path_to_VisualFBEditor/Controls/MyFbFramework"
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff64_gtk2.so"
```
#### For Linux 64-bit (for gtk3):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "Path_to_VisualFBEditor/Controls/MyFbFramework" -d __USE_GTK3__
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
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

REM "C:\FreeBasic\Projects\VisualFBEditor-master\Controls\MyFbFramework"

REM the 64 bit FreeBasic compiler is located in

REM "C:\FreeBasic\X64\fbc.exe"

REM "Version 1.08.0 64 bit Windows build"

REM BUILD COMMAND

"C:\FreeBasic\X64\fbc.exe" "VisualFBEditor.bas" "VisualFBEditor.rc" -s gui -x "../VisualFBEditor64.exe" -i "C:\FreeBasic\Projects\VisualFBEditor-master\Controls\MyFbFramework"

REM Change path to the MyFbFramework source

cd "C:\FreeBasic\Projects\VisualFBEditor-master\Controls\MyFbFramework\mff"

"C:\FreeBasic\X64\fbc.exe" -b "mff.bi" "mff.rc" -dll -x "..\mff64.dll"
```
__
