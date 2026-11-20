#!/bin/bash

echo "###############################################"
echo "freeimage" $VERSION
echo "###############################################"

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR
cp -r $SOURCE_DIR/* .

echo "*** FreeImage: make" $MAKE_OPTIONS

CMAKE_OPTIONS=
# common settings
CMAKE_OPTIONS+=" -DCMAKE_INSTALL_PREFIX=${PRODUCT_INSTALL}"
CMAKE_OPTIONS+=" -DCMAKE_VERBOSE_MAKEFILE=ON"
CMAKE_OPTIONS+=" -DCMAKE_BUILD_TYPE=Release"

if [ $DIST_NAME = "macOS" ]; then
    for file in $(grep -ril "fvisibility" .); do
        sed -i '' -e "s/-fvisibility=hidden//g" "$file"
    done
    # Shared library: the default static build defines FREEIMAGE_LIB, which
    # removes the constructor FreeImage_SO_Initialise() that registers the
    # plugins. OCCT never calls FreeImage_Initialise(), so with the static
    # library FreeImage knows 0 format and every image is refused
    # ("Error: image '...marker_dot.png' has unsupported file format").
    CMAKE_OPTIONS+=" -DBUILD_SHARED_LIBS=ON -DFREEIMAGE_STATIC=OFF"
    CMAKE_OPTIONS+=" ${SAT_CMAKE_OPTIONS}"
fi

echo "*** cmake $CMAKE_OPTIONS"
cmake $CMAKE_OPTIONS $SOURCE_DIR

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

if [ $DIST_NAME = "macOS" ]; then
    # The library must not be static: OCCT would link it inside TKService
    # without the plugin registration (see above)
    # (target "FreeImage": libFreeImage.dylib, case-insensitive check)
    if ! ls ${PRODUCT_INSTALL}/lib | grep -qi '^libfreeimage.*\.dylib$'; then
        echo "ERROR: no libFreeImage.dylib in ${PRODUCT_INSTALL}/lib"
        exit 4
    fi
fi

echo
echo "########## END"
