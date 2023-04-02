#!/bin/bash -ex

LOCAL_PATH=$(pwd)

echo Init repo tree using AOSP manifest
pushd aosptree
repo init -u https://github.com/LineageOS/android.git -b 757f405bf66c7d0ece0a1a5ccd474d0b543a10ad
cd .repo/manifests
mv default.xml lineage.xml
cp ${LOCAL_PATH}/manifests/glodroid.xml glodroid.xml
cp ${LOCAL_PATH}/manifests/default_lineage.xml default.xml
git add *
git commit -m "Add GloDroid Project" --no-edit
popd

echo Sync repo tree
pushd aosptree
repo sync -cq
popd

echo Patch AOSP tree
patch_dir() {
    pushd aosptree/$1
    repo sync -l .
    git am ${LOCAL_PATH}/patches-aosp/$1/*
    popd
}

pushd patches-aosp
directories=$(find -name *patch | xargs dirname | uniq)
popd

for dir in ${directories}
do
    echo "Patching: $dir"
    patch_dir $dir
done

# Hack to avoid rebuilding AOSP from scratch
touch -c -t 200101010101 aosptree/external/libcxx/include/chrono

cd aosptree/external/chromium-webview/prebuilt/arm64
git lfs pull
cd -
cd aosptree/external/chromium-webview/prebuilt/arm
git lfs pull
cd -

echo -e "\n\033[32m   Done   \033[0m"
