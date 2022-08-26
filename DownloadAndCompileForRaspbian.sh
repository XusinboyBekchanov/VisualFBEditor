sudo apt install gcc libncurses5-dev libffi-dev libgl1-mesa-dev libx11-dev libxext-dev libxrender-dev libxrandr-dev libxpm-dev libtinfo5 libgpm-dev
sudo apt install libgtk-3-dev
sudo apt install git
sudo apt-get install wget
rm -r VisualFBEditor
git clone https://github.com/XusinboyBekchanov/VisualFBEditor
cd VisualFBEditor/Controls
git clone https://github.com/XusinboyBekchanov/MyFbFramework
cd ..
mkdir Compilers
cd Compilers
wget -O FreeBASIC-1.09.0-raspbian9-arm.tar.xz https://versaweb.dl.sourceforge.net/project/fbc/FreeBASIC-1.09.0/Binaries-Linux/raspbian9/FreeBASIC-1.09.0-raspbian9-arm.tar.xz
tar xf FreeBASIC-1.09.0-raspbian9-arm.tar.xz
cd ..
cd src
../Compilers/FreeBASIC-1.09.0-raspbian9-arm/bin/fbc "VisualFBEditor.bas" -x "../VisualFBEditor_gtk3" -i "../Controls/MyFbFramework" -d __USE_GTK3__ -v
cd ..
cd Controls/MyFbFramework/mff
../../../Compilers/FreeBASIC-1.09.0-raspbian9-arm/bin/fbc -b "mff.bi" -dll -x "../libmff32_gtk3.so" -d __USE_GTK3__ -v
cd ..
cd ..
cd ..