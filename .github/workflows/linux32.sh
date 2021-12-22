cd ..
cd ..
cd ..
apt install libgtk-3-dev
wget -O FreeBASIC-1.08.1-ubuntu-18.04-x86_64.tar.xz https://versaweb.dl.sourceforge.net/project/fbc/FreeBASIC-1.08.1/Binaries-Linux/ubuntu-18.04/FreeBASIC-1.08.1-ubuntu-18.04-x86_64.tar.xz
tar xf FreeBASIC-1.08.1-ubuntu-18.04-x86_64.tar.xz
cd FreeBASIC-1.08.1-ubuntu-18.04-x86_64
./install.sh -i
cd ..
cd VisualFBEditor
git clone https://github.com/XusinboyBekchanov/MyFbFramework
cd src
fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "../MyFbFramework" -d __USE_GTK3__
cd ..
cd MyFbFramework/mff
fbc -b "mff.bi" -dll -x "../../libmff32_gtk3.so" -d __USE_GTK3__

cd ..
cd ..
ls
