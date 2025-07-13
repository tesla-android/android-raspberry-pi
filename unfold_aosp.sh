#!/bin/bash -ex

LOCAL_PATH=$(pwd)

echo Init repo tree using AOSP manifest
pushd aosptree
repo init --depth=2 -u https://android.googlesource.com/platform/manifest -b refs/tags/android-platform-14.0.0_r20 ${GD_REPO_INIT_ARGS}
cd .repo/manifests
mv default.xml aosp.xml
cp ${LOCAL_PATH}/manifests/tesla-android.xml tesla-android.xml
cp ${LOCAL_PATH}/manifests/glodroid.xml glodroid.xml
cp ${LOCAL_PATH}/manifests/default_aosp.xml default.xml
git add *
git commit -m "Add GloDroid Project" --no-edit
popd

echo Sync repo tree
pushd aosptree
repo sync --no-clone-bundle --no-tags -j$(nproc --all) -v
popd

echo Patch AOSP tree
patch_dir() {
    pushd aosptree/$1
    repo sync -l .
    git am ${LOCAL_PATH}/patches-aosp/$1/*.patch
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

echo -e "\n\033[32m   Done   \033[0m"
