#!/bin/bash

is-variable-set() {
    declare -p $1 &>dev/null
}

PLATFORM=${PLATFORM:-OS}             # Default to "OS" platform
BUILD_SHARED=${BUILD_SHARED:-0}
USE_XCODE=${USE_XCODE:-0}
BUILD_CURL=${BUILD_CURL:-0}
USE_STRICT_COMPILER_CHECKS=${USE_STRICT_COMPILER_CHECKS:-0}
DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:-11.0}

SHARED_EXT=""
if [[ ${BUILD_SHARED} -eq 1 ]]; then
    SHARED_EXT="-DBUILD_SHARED=1 -DENABLE_VISIBILITY=1"
fi

GENERATOR_EXT=""
if [[ ${USE_XCODE} -eq 1 ]]; then
    GENERATOR_EXT="-G Xcode"
fi

if [[ ${BUILD_CURL} -eq 1 ]]; then
  mkdir -p example/example-curl/build
  pushd example/example-curl/build
  cmake .. \
    ${GENERATOR_EXT} -DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake \
    -DPLATFORM=${PLATFORM} -DDEPLOYMENT_TARGET=${DEPLOYMENT_TARGET} -DENABLE_STRICT_TRY_COMPILE=${USE_STRICT_COMPILER_CHECKS} || exit 1
  cmake --build . --config Release --parallel 4 || exit 1
  popd
else
  mkdir -p example/example-lib/build
  pushd example/example-lib/build
  cmake .. \
    ${GENERATOR_EXT} -DCMAKE_TOOLCHAIN_FILE=../../ios.toolchain.cmake -DCMAKE_INSTALL_PREFIX=../out \
    -DPLATFORM=${PLATFORM} -DDEPLOYMENT_TARGET=${DEPLOYMENT_TARGET} -DENABLE_STRICT_TRY_COMPILE=${USE_STRICT_COMPILER_CHECKS} ${SHARED_EXT}\
   || exit 1
  cmake --build . --config Release || exit 1
  cmake --install . --config Release || exit 1
  popd
fi
