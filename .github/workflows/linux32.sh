cd ..
cd ..
cd ..
git clone https://github.com/XusinboyBekchanov/MyFbFramework
apt install libgtk-3-dev
cd VisualFBEditor/src
fbc "VisualFBEditor.bas" -x "../VisualFBEditor32_gtk3" -i "$PWD/../../MyFbFramework"
