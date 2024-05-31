# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2020-2023 Roman Stratiienko (r.stratiienko@gmail.com)

$(call inherit-product, glodroid/configuration/common/device-common.mk)
$(call inherit-product, glodroid/devices-community/gd_rpi4/drm/device.mk)

# Firmware
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/firmware/brcmfmac43455-sdio.clm_blob:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43455-sdio.clm_blob \
    $(LOCAL_PATH)/firmware/brcmfmac43455-sdio.bin:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43455-sdio.bin \
    $(LOCAL_PATH)/firmware/brcmfmac43455-sdio.txt:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43455-sdio.txt \
    $(LOCAL_PATH)/firmware/brcmfmac43456-sdio.clm_blob:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43456-sdio.clm_blob \
    $(LOCAL_PATH)/firmware/brcmfmac43456-sdio.bin:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43456-sdio.bin \
    $(LOCAL_PATH)/firmware/brcmfmac43456-sdio.txt:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43456-sdio.txt \
    $(LOCAL_PATH)/firmware/LICENCE.broadcom_bcm43xx:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/LICENCE.broadcom_bcm43xx \
    $(LOCAL_PATH)/firmware/BCM4345C0.hcd:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/BCM4345C0.hcd \
    $(LOCAL_PATH)/firmware/BCM4345C5.hcd:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/BCM4345C5.hcd \
    $(LOCAL_PATH)/firmware/regulatory.db:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/regulatory.db \
    $(LOCAL_PATH)/firmware/regulatory.db.p7s:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/regulatory.db.p7s \

# Disable suspend. During running some VTS device suspends, which sometimes causes kernel to crash in WIFI driver and reboot.
PRODUCT_COPY_FILES += \
    glodroid/configuration/common/no_suspend.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/no_suspend.rpi4.rc \

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/etc/power.rpi4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/power.rpi4.rc \
    $(LOCAL_PATH)/etc/uevent.device.rc:$(TARGET_COPY_OUT_VENDOR)/etc/uevent.device.rc \

# drm_hwcomposer
# RPI4's hardware doesn't have hardware CTM support, while GPU is slow
# to handle the whole composition. Ignore CTM instead.
PRODUCT_VENDOR_PROPERTIES += vendor.hwc.drm.ctm=DRM_OR_IGNORE

# Checked by android.opengl.cts.OpenGlEsVersionTest#testOpenGlEsVersion. Required to run correct set of dEQP tests.
# 196609 == 0x00030001 == GLES v3.1
PRODUCT_VENDOR_PROPERTIES += \
    ro.opengles.version=196609

# Camera
PRODUCT_PACKAGES += ipa_rpi_vc4.so ipa_rpi_vc4.so.sign

LIBCAMERA_CFGS := $(wildcard glodroid/vendor/libcamera/src/ipa/rpi/vc4/data/*json)
PRODUCT_COPY_FILES += $(foreach cfg,$(LIBCAMERA_CFGS),$(cfg):$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/vc4/$(notdir $(cfg))$(space))

# Codecs
PRODUCT_VENDOR_PROPERTIES += \
    persist.ffmpeg_codec2.v4l2.h264=true \
    persist.ffmpeg_codec2.v4l2.h265=true \
    persist.ffmpeg_codec2.rank.audio=16 \
    persist.ffmpeg_codec2.rank.video=128 \

# Vulkan
PRODUCT_PACKAGES += \
    vulkan.broadcom

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_0_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2023-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \

PRODUCT_VENDOR_PROPERTIES +=    \
    ro.hardware.vulkan=broadcom \

# Enable Vulkan backend for SKIA/HWUI
TARGET_USES_VULKAN = true

# Bluetooth
PRODUCT_VENDOR_PROPERTIES +=    \
    bluetooth.device.class_of_device=90,2,12 \
    bluetooth.profile.asha.central.enabled=true \
    bluetooth.profile.a2dp.source.enabled=true \
    bluetooth.profile.avrcp.target.enabled=true \
    bluetooth.profile.bap.broadcast.assist.enabled=true \
    bluetooth.profile.bap.unicast.client.enabled=true \
    bluetooth.profile.bas.client.enabled=true \
    bluetooth.profile.csip.set_coordinator.enabled=true \
    bluetooth.profile.gatt.enabled=true \
    bluetooth.profile.hap.client.enabled=true \
    bluetooth.profile.hfp.ag.enabled=true \
    bluetooth.profile.hid.device.enabled=true \
    bluetooth.profile.hid.host.enabled=true \
    bluetooth.profile.map.server.enabled=true \
    bluetooth.profile.mcp.server.enabled=true \
    bluetooth.profile.opp.enabled=true \
    bluetooth.profile.pan.nap.enabled=true \
    bluetooth.profile.pan.panu.enabled=true \
    bluetooth.profile.pbap.server.enabled=true \
    bluetooth.profile.sap.server.enabled=true \
    bluetooth.profile.ccp.server.enabled=true \
    bluetooth.profile.vcp.controller.enabled=true \
    persist.bluetooth.a2dp_aac.vbr_supported=true

# HACK virtual display size == virtual touchscreen size == phisical display size
PRODUCT_VENDOR_PROPERTIES +=    \
    debug.drm.mode.force=1024x768

# Default apps
GD_NO_DEFAULT_APPS = false

# Audio
GD_NO_DEFAULT_AUDIO = true

PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@7.1-impl \
    android.hardware.audio.effect@7.0-impl \
    audio.primary.rpi \
    audio.r_submix.default \
    audio.usb.default

PRODUCT_PACKAGES += \
    tinycap \
    tinyhostless \
    tinymix \
    tinypcminfo \
    tinyplay

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

PRODUCT_VENDOR_PROPERTIES +=    \
    persist.audio.pcm.card=0 \
    persist.audio.pcm.device=0 \
    ro.config.media_vol_default=100 \
    ro.config.media_vol_steps=25 \
    ro.hardware.audio.primary=rpi \

DEVICE_MANIFEST_FILE += \
    glodroid/configuration/common/audio/android.hardware.audio@7.1.xml \
    glodroid/configuration/common/audio/android.hardware.audio.effect@7.0.xml \
