#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
DEVICE_PATH := device/onyx/BOOX
# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true
# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    vendor \
    system_ext \
    system \
    product
# BOARD_USES_RECOVERY_AS_BOOT := true  # 已删除：小猿 S2 有独立 recovery 分区，需单独生成 recovery.img
# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 := 
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := generic
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := generic
# APEX
OVERRIDE_TARGET_FLATTEN_APEX := true
# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := qcom
TARGET_NO_BOOTLOADER := true
# Display
TARGET_SCREEN_DENSITY := 240
# Kernel
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=1 earlycon=msm_geni_serial,0x4a90000 loop.max_part=7 cgroup.memory=nokmem,nosocket buildvariant=user
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
TARGET_KERNEL_CONFIG := BOOX_defconfig
TARGET_KERNEL_SOURCE := kernel/onyx/BOOX
# Kernel - prebuilt（原版多平台内核，支持 trinket(SM6125/骁龙665) 与 msm8953）
TARGET_FORCE_PREBUILT_KERNEL := true
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL),true)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_INCLUDE_DTB_IN_BOOTIMG := 
endif
# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)
# 实测 boot_a 分区为 0x4000000 = 67108864（64MB）
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
# 小猿 S2 存在独立 recovery 分区（recovery_a.img 实测 100663296 字节）
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 100663296
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
# Platform：小猿 S2 实际 SoC = trinket（SM6125 / 骁龙 665），非 msm8953。
# prebuilt/kernel 为原版多平台内核（含 trinket 与 msm8953 支持）。
TARGET_BOARD_PLATFORM := trinket
# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
# Security patch level
VENDOR_SECURITY_PATCH := 2021-08-01
# Hack: prevent anti rollback
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
# 编译时使用 Omni android-11 分支，PLATFORM_VERSION 由构建系统自动设为 11，
# 不再在 device tree 中硬编码（twrpdtgen 默认的 16.1.0 会干扰 Android 11 基线）。
# TWRP Configuration
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
TW_INCLUDE_REPACKTOOLS := true
# ---- EPD 墨水屏显示（小猿 S2 / Onyx BOOX 平台）----
# 内核为 trinket(SM6125) + mdss + EPD 驱动（epd_mode / epd_busy / update_waveform sysfs），
# cmdline: video=vfb:640x400,bpp=32,memsize=3072000
# TWRP minui 默认打开 /dev/graphics/fb0 绘制。
# 分辨率 1404x1872（10.3" 227ppi），RGBX/RGBA 8888 帧缓冲。
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
# OrangeFox/TWRP 主题布局：必须同时设置 TARGET_SCREEN_WIDTH/HEIGHT 与 TW_THEME，
# 否则 soong 找不到对应的 ui.xml（theme selection failed）
TARGET_SCREEN_WIDTH := 1404
TARGET_SCREEN_HEIGHT := 1872

# ---- 禁用 MTP（稳定方案：修复 recovery 启动即崩）----
# 现象：libtwrpmtp-ffs.so(MTP 库) 依赖 libasyncio.so，但 OrangeFox 编译时漏打包
# libasyncio.so → recovery 主程序启动即崩（CANNOT LINK EXECUTABLE, exit status 1），
# 只剩 adbd → 有 adb 无显示；手动补 libasyncio.so 后 recovery 能启动但 MTP 初始化
# 连带 adbd 起不来 → 亮屏无 adb。
# 方案：禁用 MTP。libtwrpmtp-ffs.so 不再编译/链接，不再依赖 libasyncio.so，
# recovery 启动不崩、adbd 正常。刷写功能走 adb sideload（fstab 已含 /boot /misc 等），
# 不需要 MTP。
TW_EXCLUDE_MTP := true

# ---- 墨水屏 recovery 不需要前光/背光 ----
# 小猿 S2 为 EPD 墨水屏（无背光，前光由系统 app 控制；rec 模式下不需要前光）。
# 禁用 OrangeFox 背光调节与自动熄屏逻辑，避免亮屏/熄屏干扰墨水屏。
TW_NO_SCREEN_BLANK := true
TW_MAX_BRIGHTNESS := 0
