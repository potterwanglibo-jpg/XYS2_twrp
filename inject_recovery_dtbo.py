#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 编译完成后，把原版 recovery_dtbo（qcom 设备树表，含 trinket 平台）注入 recovery.img。
# 用法: python3 inject_recovery_dtbo.py <recovery.img> <recovery_dtbo.img>
# 复刻原版 recovery_a.img 布局:
#   dtb_size = 1160647 (qcom表前缀), dtb_addr = 0x1f00000
#   recovery_dtbo_size = 2351927 (整个 qcom 表), recovery_dtbo_offset = 实际位置
import struct, sys

def u32(d,o): return struct.unpack_from('<I',d,o)[0]
def u64(d,o): return struct.unpack_from('<Q',d,o)[0]

rec_path = sys.argv[1]
dtbo_path = sys.argv[2]

rec = open(rec_path,'rb').read()
qcom = open(dtbo_path,'rb').read()

page = u32(rec,36)
# 提取编译产物的 kernel / ramdisk
ksize = u32(rec,8); rsize = u32(rec,16)
k = rec[page:page+ksize]
off = page + ((ksize+page-1)//page)*page
r = rec[off:off+rsize]

# 组装: header + kernel + ramdisk + qcom表(dtb/recovery_dtbo)
out = bytearray()
out += rec[:1660]                    # header 基础（保留编译产物的 cmdline 等）
out += b'\x00'*((page - 1660) % page) # header pad 到 page
out += k; out += b'\x00'*(((-len(k))%page) if len(k)%page else 0)
out += r; out += b'\x00'*(((-len(r))%page) if len(r)%page else 0)
rdbo_off = len(out)
out += qcom

# 更新 header 字段
struct.pack_into('<I',out,8,len(k))            # kernel_size
struct.pack_into('<I',out,16,len(r))           # ramdisk_size
struct.pack_into('<I',out,24,0)                # second_size
struct.pack_into('<I',out,1632,len(qcom))      # recovery_dtbo_size
struct.pack_into('<Q',out,1636,rdbo_off)       # recovery_dtbo_offset
struct.pack_into('<I',out,1644,1660)           # header_size
struct.pack_into('<I',out,1648,1160647)        # dtb_size (原版 recovery 值，qcom表前缀)
struct.pack_into('<Q',out,1652,0x1f00000)      # dtb_addr (原版 recovery 值)

open(rec_path,'wb').write(bytes(out))
print(f"[inject_recovery_dtbo] OK: recovery_dtbo {len(qcom)}B @{rdbo_off}, total {len(out)}B")
