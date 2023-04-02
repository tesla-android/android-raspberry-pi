# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2019 The Android Open-Source Project

include glodroid/configuration/common/board-common.mk

BOARD_MESA3D_GALLIUM_DRIVERS := vc4 v3d
BOARD_MESA3D_VULKAN_DRIVERS := broadcom

BOARD_KERNEL_CMDLINE += coherent_pool=1M 8250.nr_uarts=1 snd_bcm2835.enable_compat_alsa=0 snd_bcm2835.enable_hdmi=1 snd_bcm2835.enable_headphones=1 \
                        vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000 console=ttyS0,115200

BOARD_LIBCAMERA_EXTRA_TARGETS := \
    libetc:libcamera/ipa_rpi.so:libcamera:ipa_rpi.so:           \
    libetc:libcamera/ipa_rpi.so.sign:libcamera:ipa_rpi.so.sign: \
