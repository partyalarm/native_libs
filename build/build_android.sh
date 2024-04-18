#!/bin/sh

# android
( cd `dirname $0`
  mkdir _build_android_aarch64
  cd    _build_android_aarch64
  cmake --toolchain ../toolchain_android_aarch64.cmake -S ../..
  make
)


