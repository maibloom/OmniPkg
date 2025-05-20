# https://github.com/calamares/calamares/wiki/Develop-Guide#build
git clone https://github.com/calamares/calamares.git
mkdir calamares/build
cd calamares/build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make
