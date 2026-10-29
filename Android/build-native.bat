@echo off
@rem Builds the IDE (src/VisualFBEditor.bas) as libmff-app.so of this Android project.
@rem Then gradlew assembleDebug makes the APK: app/build/outputs/apk/debug/app-debug.apk
setlocal
if "%FBC%" == "" set FBC=D:\GitHub\fbc-android9\bin\fbc.exe
if "%NDK%" == "" set NDK=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b
set APP=%~dp0app\src\main\jniLibs
@rem The shared objects of the IDE are constructed before its main code: see fbinitorder.h
set INITORDER=-Wc -include,"%~dp0fbinitorder.h"
cd /d "%~dp0..\src"
"%FBC%" VisualFBEditor.bas -x "%APP%/arm64-v8a/libmff-app.so" -target aarch64-linux-android -i ../Controls/MyFbFramework -v -dll %INITORDER% -sysroot "%NDK%/platforms/android-21/arch-arm64" -Wl "-L %NDK%/platforms/android-21/arch-arm64/usr/lib"
if errorlevel 1 exit /b 1
"%FBC%" VisualFBEditor.bas -x "%APP%/x86/libmff-app.so" -target i686-linux-android -i ../Controls/MyFbFramework -v -dll %INITORDER% -sysroot "%NDK%/platforms/android-21/arch-x86" -Wl "-L %NDK%/platforms/android-21/arch-x86/usr/lib"
if errorlevel 1 exit /b 1
