#!/bin/bash -e

trap 'echo -e "\nbuild.sh interrupted"; exit 1' SIGINT

# Ensure dependencies are installed
if ! command -v repo &> /dev/null
then
    echo "repo could not be found. Please install the necessary dependencies as mentioned in the README.md file."
    exit 1
fi

# Navigate to the root directory of the repository
cd "$(dirname "$0")"

echo Building the Android
pushd aosptree
. build/envsetup.sh
lunch tesla_android_cm4-userdebug
make images -k || make images -j1
make sdcard
make otapackage
popd
