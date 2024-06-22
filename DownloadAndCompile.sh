if command -v apt &> /dev/null; then
    echo "Debian-based system"
    sudo apt install libgtk-3-dev
    sudo apt install git
    sudo apt-get install wget
elif command -v pacman &> /dev/null; then
    echo "Arch-based system"
    if ! pacman -Q gtk3 &> /dev/null; then
        sudo pacman -S gtk3
    fi
    if ! pacman -Q git &> /dev/null; then
        sudo pacman -S git
    fi
    if ! pacman -Q wget &> /dev/null; then
        sudo pacman -S wget
    fi
    if ! pacman -Q ncurses5-compat-libs  &> /dev/null; then
        sudo pacman -S ncurses5-compat-libs
    fi
fi
rm -r VisualFBEditor
git clone https://github.com/XusinboyBekchanov/VisualFBEditor
cd VisualFBEditor/Controls
git clone https://github.com/XusinboyBekchanov/MyFbFramework
cd ..
mkdir Compilers
cd Compilers
wget -O FreeBASIC-1.10.0-linux-x86_64.tar.xz https://sourceforge.net/projects/fbc/files/FreeBASIC-1.10.0/Binaries-Linux/FreeBASIC-1.10.0-linux-x86_64.tar.xz
tar xf FreeBASIC-1.10.0-linux-x86_64.tar.xz
cd ..
cd src
../Compilers/FreeBASIC-1.10.0-linux-x86_64/bin/fbc "VisualFBEditor.bas" -x "../VisualFBEditor64_gtk3" -i "../Controls/MyFbFramework" -d __USE_GTK3__ -v
cd ..
cd Controls/MyFbFramework/mff
../../../Compilers/FreeBASIC-1.10.0-linux-x86_64/bin/fbc -b "mff.bi" -dll -x "../libmff64_gtk3.so" -d __USE_GTK3__ -v
cd ..
cd ..
cd ..

