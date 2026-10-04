# OrangeFox for BOOX (XiaoYuan S2, trinket/SM6125 = 骁龙665, Android 11)
# 继承与 omni_BOOX.mk 相同的基础, OrangeFox 用 twrp_<device> 前缀 lunch
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff (OrangeFox 基于 OmniROM)
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from BOOX device
$(call inherit-product, device/onyx/BOOX/device.mk)

PRODUCT_DEVICE := BOOX
PRODUCT_NAME := twrp_BOOX
PRODUCT_BRAND := ONYX
PRODUCT_MODEL := NoteAir2
PRODUCT_MANUFACTURER := onyx
