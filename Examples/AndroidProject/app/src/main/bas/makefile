MFF:= /mnt/GitHub/VisualFBEditor/MyFbFramework
MFF= "F:/Install/Install2/VisualFBEditor/MyFbFramework"
FBC:= mnt/GitHub/fbc-android4/bin/fbc
FBC= F:/Install/Install2/fbc-android1/bin/fbc.exe
CFLAGS:= -i $(MFF) -v -dll -exx -sysroot "/mnt/media/GitHub/android-ndk-r12b/platforms/android-9/arch-x86" $(GFLAG)
CFLAGS= -i $(MFF) -v -dll -exx -sysroot "F:/Install/Install2/android-ndk-r12b-windows-x86/android-ndk-r12b/platforms/android-9/arch-x86" -Wl "-L F:/Install/Install2/android-ndk-r12b-windows-x86/android-ndk-r12b/platforms/android-9/arch-x86/usr/lib" $(GFLAG)

all: Form1.bas
	$(FBC) Form1.bas -x "../jniLibs/x86/libmff-app.so" -target i686-linux-android $(CFLAGS)
