# VisualFBEditor
## IDE for FreeBasic

#### Introduction
VisualFBEditor is the IDE for FreeBasic with visul designer, debugger, project support and etc. VisualFBEditor based on the library <a href="https://github.com/XusinboyBekchanov/MyFbFramework">MyFbFramework</a>.

Requirements:

* FreeBASIC Compiler: http://www.freebasic.net/

Compilation:

To compile use the following command lines:
For Windows 32-bit:
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32.exe" "VisualFBEditor.rc" -i "Path_to_MyFbFramework"
For Windows 64-bit:
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "Path_to_MyFbFramework"
For Linux 32-bit:
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "Path_to_MyFbFramework"
For Linux 64-bit:
  fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "Path_to_MyFbFramework"
