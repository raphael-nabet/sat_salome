#!/bin/bash

echo "##########################################################################"
echo "OPENSSL" $VERSION
echo "##########################################################################"


rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

$SOURCE_DIR/Configure darwin64-arm64-cc --prefix=$PRODUCT_INSTALL

if [ $? -ne 0 ]; then 
    echo "Error could not configure openssl"
    exit 1
fi

make
if [ $? -ne 0 ]; then 
    echo "Error could not build openssl"
    exit 2
fi

make install
if [ $? -ne 0 ]; then 
    echo "Error could not install openssl"
    exit 3
fi

echo
echo "########## END"
