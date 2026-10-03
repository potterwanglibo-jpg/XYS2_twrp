#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from BOOX device
$(call inherit-product, device/onyx/BOOX/device.mk)

PRODUCT_DEVICE := BOOX
PRODUCT_NAME := omni_BOOX
PRODUCT_BRAND := ONYX
PRODUCT_MODEL := NoteAir2
PRODUCT_MANUFACTURER := onyx

PRODUCT_GMS_CLIENTID_BASE := android-onyx

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="BOOX-userdebug 11 RKQ1.210614.002 200 release-keys"

BUILD_FINGERPRINT := ONYX/BOOX/BOOX:11/RKQ1.210614.002/200:userdebug/release-keys
