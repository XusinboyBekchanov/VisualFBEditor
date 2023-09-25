cd ..
cd ..
cd ..
apt install libgtk-3-dev
wget -O FreeBASIC-1.10.0-ubuntu-18.04-x86_64.tar.xz https://versaweb.dl.sourceforge.net/project/fbc/FreeBASIC-1.10.0/Binaries-Linux/ubuntu-18.04/FreeBASIC-1.10.0-ubuntu-18.04-x86_64.tar.xz
tar xf FreeBASIC-1.10.0-ubuntu-18.04-x86_64.tar.xz
cd FreeBASIC-1.10.0-ubuntu-18.04-x86_64
./install.sh -i
cd ..
cd VisualFBEditor
git clone https://github.com/XusinboyBekchanov/MyFbFramework
cd src
fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "../MyFbFramework" -d __USE_GTK3__
cd ..
which VisualFBEditor32_gtk3 >/dev/null 2>&1 || die "ERROR"

if [ ! -f VisualFBEditor32_gtk3 ]
then
    echo "VisualFBEditor32_gtk3 does not exist"
    exit 1
fi

cd MyFbFramework/mff
fbc -b "mff.bi" -dll -x "../../libmff32_gtk3.so" -d __USE_GTK3__

if [ ! -f ../../libmff32_gtk3.so ]
then
    echo "libmff32_gtk3.so does not exist"
    exit 1
fi

cd ..
cd ..
ls
