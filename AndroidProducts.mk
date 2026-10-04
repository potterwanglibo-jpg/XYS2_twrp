#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/omni_BOOX.mk \
    $(LOCAL_DIR)/twrp_BOOX.mk

COMMON_LUNCH_CHOICES := \
    omni_BOOX-user \
    omni_BOOX-userdebug \
    omni_BOOX-eng \
    twrp_BOOX-user \
    twrp_BOOX-userdebug \
    twrp_BOOX-eng
