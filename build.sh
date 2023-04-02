#!/bin/bash

echo Building the Android
pushd aosptree
. build/envsetup.sh
lunch gd_rpi4-userdebug
make images -k || make images -j1
make sdcard
popd
