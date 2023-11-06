cd ..
cd ..
cd ..
apt install libgtk-3-dev

wget -O FreeBASIC-1.10.0-ubuntu-22.04-x86_64.tar.xz https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Linux/FreeBASIC-1.10.0-ubuntu-22.04-x86_64.tar.xz
tar xf FreeBASIC-1.10.0-ubuntu-22.04-x86_64.tar.xz
cd FreeBASIC-1.10.0-ubuntu-22.04-x86_64
./install.sh -i
cd ..
cd VisualFBEditor
git clone https://github.com/XusinboyBekchanov/MyFbFramework
cd src
fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "../MyFbFramework" -d __USE_GTK3__ -v
cd ..

if [ ! -f VisualFBEditor64_gtk3 ]
then
    echo "VisualFBEditor64_gtk3 does not exist"
    exit 1
fi

cd MyFbFramework/mff
fbc -b "mff.bi" -dll -x "../libmff64_gtk3.so" -d __USE_GTK3__ -v

if [ ! -f ../libmff64_gtk3.so ]
then
    echo "libmff64_gtk3.so does not exist"
    exit 1
fi

cd ..
cd ..
ls
