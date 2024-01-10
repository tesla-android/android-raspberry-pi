# Tesla Android for Raspberry Pi 4

[![License](https://img.shields.io/badge/license-GPL-blue)](https://opensource.org/licenses/gpl-3-0/)

This repository contains platform patches and manifest for Tesla Android on top of [GloDroidCommunity](https://github.com/GloDroidCommunity) AOSP.

Please refer to https://teslaandroid.com for release notes, hardware requirements and the install guide.

#### Please consider supporting the project: 

[Donations](https://teslaandroid.com/donations)

## Licenseing

Tesla Android is published under the General Public License 3.0. All generic board-specific patches are regularly submitted to [GloDroidCommunity/raspberry-pi](https://github.com/GloDroidCommunity/raspberry-pi) where they can be obtained under the Apache License.   

## Warning!

Tesla Android Project is a free and open-source initiative maintained by a group of volunteers. It is provided "as is" without any warranties or guarantees.

## Flashing images

Find the sdcard image or archive with fastboot images [here](https://github.com/tesla-android/android-raspberry-pi/releases)

Use the SDCard raw image to flash the Android into SDCard.

Or use the fastboot images archive to download Android on SDCard using fastboot mode:  

### Step 1
Extract the content of the archive.  
Using any available iso-to-usb utility, prepare recovery SDCARD.  
To flash Android on a sdcard, use *deploy-sd.img*  
  
### Step 2
Ensure you have installed the adb package: ```$ sudo apt install adb``` (required to set up udev rules)  
Insert recovery sdcard into the phone.  
Connect the phone and your PC using a typec cable.  
Power up the phone. Blue LED indicates that the phone is in bootloader mode, and you can proceed with flashing.  
  
### Step 3
Run .*/flash-sd.sh* utility for flashing Android to sdcard  
  
*After several minutes flashing should complete, and Android should boot*  

## Building from sources

Before building, ensure your system has at least 32GB of RAM, a swap file is at least 8GB, and 300GB of free disk space available.

### Install system packages
(Ubuntu 22.04 LTS is only supported. Building on other distributions can be done using docker)
<br/>

- [Install AOSP required packages](https://source.android.com/setup/build/initializing).
```bash
sudo apt-get install -y git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig
```

<br/>

- Install additional packages
```bash
sudo apt-get install -y swig libssl-dev flex bison device-tree-compiler mtools git gettext libncurses5 libgmp-dev libmpc-dev cpio rsync dosfstools kmod gdisk lz4 meson cmake libglib2.0-dev git-lfs
```

<br/>

- Install additional packages (for building mesa3d, libcamera, and other meson-based components)
```bash
sudo apt-get install -y python3-pip pkg-config python3-dev ninja-build
sudo pip3 install mako jinja2 ply pyyaml pyelftools
```

- Install the `repo` tool
```bash
sudo apt-get install -y python-is-python3 wget
wget -P ~/bin http://commondatastorage.googleapis.com/git-repo-downloads/repo
chmod a+x ~/bin/repo
```

### Fetching the sources and building the project

```bash
git clone https://github.com/tesla-android/android-raspberry-pi.git
cd android-raspberry-pi
```

### Building Tesla Android

```bash
./unfold_aosp.sh && ./build.sh
```

### Notes

- Depending on your hardware and internet connection, downloading and building may take 8h or more.  
- After the successful build, find the fastboot images at `./out/images.tar.gz` or sdcard image at `./out/sdcard.img`.
