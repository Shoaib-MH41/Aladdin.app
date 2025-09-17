#!/bin/sh
export "FLUTTER_BUILD_DIR=Debug"
export "SYMROOT=${SOURCE_ROOT}/../build/ios"
export "FLUTTER_BUILD_NAME=1.0.0"
export "FLUTTER_BUILD_NUMBER=1"
export "DART_DEFINES=$(dart defines)"
