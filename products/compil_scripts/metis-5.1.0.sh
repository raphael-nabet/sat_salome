#!/bin/bash

echo "##########################################################################"
echo "Metis" $VERSION
echo "##########################################################################"

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

cp -r "$SOURCE_DIR/." .

CMAKE_OPTIONS=
if [ "$DIST_NAME" = "macOS" ]; then
    CMAKE_OPTIONS+=" $SAT_CMAKE_OPTIONS"
fi

echo
echo "*** make config"
make config prefix=${PRODUCT_INSTALL} CMAKE_ARGS="${CMAKE_OPTIONS}"

if [ $? -ne 0 ]
then
    echo "ERROR on make config"
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

