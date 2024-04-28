# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2019 The Android Open-Source Project

BC_PATH := $(patsubst $(CURDIR)/%,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include glodroid/configuration/common/board-common.mk
include glodroid/devices-community/gd_rpi4/drm/board.mk

BOARD_MESA3D_GALLIUM_DRIVERS := vc4 v3d
BOARD_MESA3D_VULKAN_DRIVERS := broadcom

BOARD_KERNEL_CMDLINE += coherent_pool=1M 8250.nr_uarts=1 snd_bcm2835.enable_compat_alsa=0 snd_bcm2835.enable_hdmi=1 snd_bcm2835.enable_headphones=1 \
                        vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000 console=ttyS0,115200

BOARD_LIBCAMERA_IPAS := rpi/vc4
BOARD_LIBCAMERA_PIPELINES := simple rpi/vc4

BOARD_LIBCAMERA_EXTRA_TARGETS += \
    libetc:libcamera/ipa_rpi_vc4.so:libcamera:ipa_rpi_vc4.so:           \
    libetc:libcamera/ipa_rpi_vc4.so.sign:libcamera:ipa_rpi_vc4.so.sign: \

# FIXME = Remove prebuilt binaries with broken elf
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

BOARD_FFMPEG_ENABLE_REQUEST_API := true
BOARD_FFMPEG_KERNEL_HEADERS_DIR := $(BC_PATH)/codecs/request_api_headers_v3
BOARD_FFMPEG_EXTRA_CONFIGURE_OPTIONS  := --enable-sand
