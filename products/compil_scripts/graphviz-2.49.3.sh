#!/bin/bash

echo "##########################################################################"
echo "graphviz" $VERSION
echo "##########################################################################"

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

CMAKE_OPTIONS=
# common settings
CMAKE_OPTIONS+=" -DCMAKE_INSTALL_PREFIX=${PRODUCT_INSTALL}"
CMAKE_OPTIONS+=" -DCMAKE_VERBOSE_MAKEFILE=ON"
CMAKE_OPTIONS+=" -DCMAKE_BUILD_TYPE=Release"
CMAKE_OPTIONS+=" -DENABLE_BUILD_SHARED=ON"
CMAKE_OPTIONS+=" -DPython3_ROOT_DIR=$PYTHON_ROOT_DIR"
CMAKE_OPTIONS+=" -DPython3_EXECUTABLE=$PYTHON_ROOT_DIR/bin/python3"

if [ "$DIST_NAME" = "macOS" ]; then
    CMAKE_OPTIONS+=' -DCMAKE_MACOSX_RPATH=ON'
    CMAKE_OPTIONS+=' -DCMAKE_SKIP_INSTALL_RPATH=FALSE'
    CMAKE_OPTIONS+=' -DCMAKE_BUILD_WITH_INSTALL_RPATH=FALSE'
    CMAKE_OPTIONS+=' -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON'
    CMAKE_OPTIONS+=' -DCMAKE_INSTALL_RPATH="@loader_path;@loader_path/../lib;@executable_path/../lib"'
fi


echo "*** cmake" $CMAKE_OPTIONS
cmake --fresh $CMAKE_OPTIONS $SOURCE_DIR

if [ $? -ne 0 ]
then
    echo "ERROR on CMake"
    exit 1
fi

echo
echo "*** make" $MAKE_OPTIONS
make $MAKE_OPTIONS
if [ $? -ne 0 ]
then
    echo "ERROR on make"
    exit 2
fi

echo
echo "*** make install"
make install
if [ $? -ne 0 ]
then
    echo "ERROR on make install"
    exit 3
fi

echo
echo "########## END"
