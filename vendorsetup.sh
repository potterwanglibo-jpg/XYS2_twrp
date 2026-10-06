#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

add_lunch_combo omni_BOOX-user
add_lunch_combo omni_BOOX-userdebug
add_lunch_combo omni_BOOX-eng
add_lunch_combo twrp_BOOX-user
add_lunch_combo twrp_BOOX-userdebug
add_lunch_combo twrp_BOOX-eng

# OrangeFox build vars —— 必须放在 shell 脚本/命令行，不能放 BoardConfig.mk（FOX_ 前缀）
# A/B 设备
export FOX_AB_DEVICE=1
# 使用预编译内核
export OF_FORCE_PREBUILT_KERNEL=1
# minimal manifest 编译需要
export ALLOW_MISSING_DEPENDENCIES=true
# 非 MIUI 设备，禁 MIUI 特性
export FOX_VANILLA_BUILD=1
# 卡 logo 常为解密(data)问题：提供 keymaster 服务版本（Android 11 trinket 常见 4.1）
export OF_DEFAULT_KEYMASTER_VERSION=4.1
