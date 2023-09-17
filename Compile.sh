cd Controls/MyFbFramework/mff
../../../Compilers/FreeBASIC-1.10.0-linux-x86_64/bin/fbc -b "mff.bi" -dll -x "../libmff64_gtk2.so" -d __USE_GTK2__ -v
../../../Compilers/FreeBASIC-1.10.0-linux-x86_64/bin/fbc -b "mff.bi" -dll -x "../libmff64_gtk3.so" -d __USE_GTK3__ -v
cd ..
cd ..
cd ..
cd src
../Compilers/FreeBASIC-1.10.0-linux-x86_64/bin/fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk2" -i "../Controls/MyFbFramework" -d __USE_GTK2__ -v
../Compilers/FreeBASIC-1.10.0-linux-x86_64/bin/fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "../Controls/MyFbFramework" -d __USE_GTK3__ -v
cd ..