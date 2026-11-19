#!/bin/bash

echo "##########################################################################"
echo "Metis" $VERSION
echo "##########################################################################"

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

CMAKE_OPTIONS=" -DCMAKE_VERBOSE_MAKEFILE=1"
CMAKE_OPTIONS+=" -DCMAKE_INSTALL_PREFIX=${PRODUCT_INSTALL}"
CMAKE_OPTIONS+=" -DGKLIB_PATH=${SOURCE_DIR}/GKlib"

if [ "$DIST_NAME" = "macOS" ]; then
    CMAKE_OPTIONS+=" $SAT_CMAKE_OPTIONS"
fi

echo
echo "*** cmake ${CMAKE_OPTIONS}"
cmake ${CMAKE_OPTIONS} $SOURCE_DIR
if [ $? -ne 0 ]
then
    echo "ERROR on cmake"
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
    echo "ERROR on install"
    exit 3
fi

echo
echo "########## END"

