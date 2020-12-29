#!/bin/bash

# Setting up build env
sudo yum update -y
sudo yum groupinstall -y "Development Tools"
sudo yum install -y git cmake gcc-c++ gcc python3 python3-pip python3-devel chrpath openssl-devel
mkdir -p lambda-package/cv2 build/numpy

# Build CMake3
cd build
wget https://cmake.org/files/v3.18/cmake-3.18.0.tar.gz
tar -xvzf cmake-3.18.0.tar.gz
cd cmake-3.18.0
./bootstrap
make
sudo make install
cd ../../

# Build numpy
sudo pip3 install Cython
pip3 install --install-option="--prefix=$PWD/build/numpy" numpy
cp -rf build/numpy/lib64/python3.7/site-packages/numpy lambda-package

# Build OpenCV 4.5
(
	NUMPY=$PWD/lambda-package/numpy/core/include
	cd build
	git clone https://github.com/opencv/opencv.git
	cd opencv
	git checkout 4.5.0
	mkdir build
	cd build
	cmake \
		-D CMAKE_BUILD_TYPE=RELEASE \
		-D WITH_TBB=ON \
		-D WITH_IPP=ON \
		-D WITH_V4L=ON \
		-D ENABLE_AVX=ON \
		-D ENABLE_SSSE3=ON \
		-D ENABLE_SSE41=ON \
		-D ENABLE_SSE42=ON \
		-D ENABLE_POPCNT=ON \
		-D ENABLE_FAST_MATH=ON \
		-D BUILD_EXAMPLES=OFF \
		-D BUILD_TESTS=OFF \
		-D BUILD_PERF_TESTS=OFF \
		-D PYTHON3_NUMPY_INCLUDE_DIRS="$NUMPY" \
		..
	make -j`cat /proc/cpuinfo | grep MHz | wc -l`
)
#cp build/opencv/build/lib/python3/cv2.cpython-37m-x86_64-linux-gnu.so lambda-package/cv2/__init__.so
#cp -L build/opencv/build/lib/*.so.4.5 lambda-package/cv2
#strip --strip-all lambda-package/cv2/*
#chrpath -r '$ORIGIN' lambda-package/cv2/__init__.so
#touch lambda-package/cv2/__init__.py

cp -r /usr/local/lib/python3.7/site-packages/cv2/ lambda-package/
cp -L build/opencv/build/lib/*.so.4.5 lambda-package/cv2

# Copy template function and zip package
cp template.py lambda-package/lambda_function.py
cd lambda-package
zip -r ../lambda-package.zip *
