# OrangeFox for BOOX (XiaoYuan S2, trinket/SM6125 = 骁龙665, Android 11)
# 参考 OrangeFox 官方 vayu fox_11.0：OrangeFox product 继承 vendor/twrp/config/common.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# OrangeFox 用 vendor/twrp（TWRP vendor 树），不再用 vendor/omni
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from BOOX device
$(call inherit-product, device/onyx/BOOX/device.mk)

PRODUCT_DEVICE := BOOX
PRODUCT_NAME := twrp_BOOX
PRODUCT_BRAND := ONYX
PRODUCT_MODEL := NoteAir2
PRODUCT_MANUFACTURER := onyx
