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
#### Building on Linux

**1. Install the development files of GTK** (the only package VisualFBEditor needs itself):

| Distribution | GTK2 | GTK3 | GTK4 |
|---|---|---|---|
| Debian / Ubuntu / Linux Mint | `sudo apt install libgtk2.0-dev` | `sudo apt install libgtk-3-dev` | `sudo apt install libgtk-4-dev` |
| Fedora | `sudo dnf install gtk2-devel` | `sudo dnf install gtk3-devel` | `sudo dnf install gtk4-devel` |
| Arch Linux / Manjaro | `sudo pacman -S gtk2` | `sudo pacman -S gtk3` | `sudo pacman -S gtk4` |

**2. Install FreeBASIC and the packages it needs** (gcc, binutils, ncurses, ...: see the list for your distribution in the [README of FreeBASIC](https://github.com/freebasic/fbc#readme)). The official binaries are recommended: https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.1/Binaries-Linux/
```shell
  wget https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.1/Binaries-Linux/FreeBASIC-1.10.1-linux-x86_64.tar.gz
  tar xf FreeBASIC-1.10.1-linux-x86_64.tar.gz
  cd FreeBASIC-1.10.1-linux-x86_64
  sudo ./install.sh -i
```
fbc looks for its libraries in `lib/freebasic/linux-x86_64` next to its `bin` folder. Some packages (for example the `.deb` packages of FreeBASIC 1.10.3-1 from deb.fbxl.net) put them into `/usr/lib/freebasic` itself, and then linking fails with `cannot open linker script file /usr/bin/../lib/freebasic/linux-x86_64/fbextra.x` or `cannot find .../fbrt0.o`. A link to the folder fixes it:
```shell
  sudo ln -s . /usr/lib/freebasic/linux-x86_64
```

**3. Get the sources.** MyFbFramework must be in the folder `Controls/MyFbFramework`. Always use the git versions of both repositories together (`git pull` in both): a release archive of MyFbFramework can be older than the sources of VisualFBEditor.
```shell
  git clone https://github.com/XusinboyBekchanov/VisualFBEditor
  cd VisualFBEditor/Controls
  git clone https://github.com/XusinboyBekchanov/MyFbFramework
```

**4. Compile the IDE and the library of the controls** (the commands below, for example for Linux 64-bit with GTK3). The library (`libmff64_gtk3.so`) is not in git: the IDE needs it in `Controls/MyFbFramework` to show the controls in the Toolbox and in the designer of forms. `DownloadAndCompile.sh` installs GTK3, downloads FreeBASIC into the folder `Compilers` and compiles both itself (`Compile.sh` compiles again with that FreeBASIC), the packages of FreeBASIC from step 2 are still needed.

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
#### For Linux 64-bit (for gtk4):
```shell
  cd Path_to_VisualFBEditor/src
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk4" -i "Path_to_VisualFBEditor/Controls/MyFbFramework" -d __USE_GTK__ -d __USE_GTK4__
  cd Path_to_VisualFBEditor/Controls/MyFbFramework/mff
  fbc -b "mff.bi" -dll -x "../libmff64_gtk4.so" -d __USE_GTK__ -d __USE_GTK4__
```
#### Sample bat file (Windows 64-bit):
```bat
@echo off
REM Change these paths to yours
set FBC=C:\FreeBASIC\fbc64.exe
set VFBE=C:\FreeBASIC\Projects\VisualFBEditor

cd /d "%VFBE%\src"
"%FBC%" "VisualFBEditor.bas" "VisualFBEditor.rc" -s gui -x "../VisualFBEditor64.exe" -i "%VFBE%\Controls\MyFbFramework" || exit /b 1

cd /d "%VFBE%\Controls\MyFbFramework\mff"
"%FBC%" -b "mff.bi" "mff.rc" -dll -x "../mff64.dll" || exit /b 1
```
