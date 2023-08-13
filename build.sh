#!/bin/bash -e

trap 'echo -e "\nbuild.sh interrupted"; exit 1' SIGINT

echo Building the Android
pushd aosptree
. build/envsetup.sh
lunch tesla_android_rpi4-userdebug
make images -k || make images -j1
make sdcard
make otapackage
popd
