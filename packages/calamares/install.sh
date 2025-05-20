wget https://github.com/calamares/calamares/releases/download/v3.3.14/calamares-3.3.14.tar.gz

tar -xzf calamares*
cd calamares*

mkdir build && cd build
cmake ..
make

sudo mv calamares /usr/local/bin/
