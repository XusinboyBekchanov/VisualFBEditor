@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  Gradle startup script for Windows
@rem
@rem ##########################################################################

set FBC=D:\FreeBasic\fbc_win32_mingw_0840_2024-01-28\fbc_win32_mingw\fbc.exe
set MFF=D:\GitHub\VisualFBEditor/./Controls/MyFbFramework
set NDK=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b
@rem make --directory ./app/src/main/bas
set GCC=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-gcc.exe
set AS=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-as.exe
set LD=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-ld.exe
"%FBC%" ./app/src/main/bas/Form1.bas -x "./app/src/main/jniLibs/x86/libmff-app.so" -target i686-linux-android -i "%MFF%" -v -dll -exx -sysroot "%NDK%/platforms/android-9/arch-x86" -Wl "-L %NDK%/platforms/android-9/arch-x86/usr/lib"
if "%ERRORLEVEL%" == "1" goto omega
set GCC=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-gcc.exe
set AS=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-as.exe
set LD=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-ld.exe
"%FBC%" ./app/src/main/bas/Form1.bas -x "./app/src/main/jniLibs/arm64-v8a/libmff-app.so" -target aarch64-linux-android -i "%MFF%" -v -dll -exx -sysroot "%NDK%/platforms/android-21/arch-arm64" -Wl "-L %NDK%/platforms/android-21/arch-arm64/usr/lib"
if "%ERRORLEVEL%" == "1" goto omega
set GCC=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-gcc.exe
set AS=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-as.exe
set LD=D:\GitHub\android-ndk-r12b-windows-x86\android-ndk-r12b\toolchains\x86-4.9\prebuilt\windows\bin\i686-linux-android-ld.exe
"%FBC%" ./app/src/main/bas/Form1.bas -x "./app/src/main/jniLibs/armeabi-v7a/libmff-app.so" -target arm-linux-androideabi -i "%MFF%" -v -dll -exx -sysroot "%NDK%/platforms/android-21/arch-arm" -Wl "-L %NDK%/platforms/android-9/arch-arm/usr/lib"
if "%ERRORLEVEL%" == "1" goto omega

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

@rem Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%"=="0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xME_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar

@rem Execute Gradle
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable GRADLE_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%GRADLE_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
