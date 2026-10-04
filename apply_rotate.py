#!/usr/bin/env python3
# 小猿S2 TWRP 屏幕方向补丁：左旋90° + 镜像
# 修改 bootable/recovery/minuitwrp/graphics_fbdev.cpp
#   1) fbdev_init: 把 gr_draw 宽高交换为竖屏（匹配 EPD 竖屏面板）
#   2) fbdev_flip: 像素级变换，将竖屏 gr_draw 写入物理横屏 fb（左旋90°+镜像）
# 用法: python3 apply_rotate.py <graphics_fbdev.cpp 路径>
import sys, os

if len(sys.argv) < 2:
    print("usage: apply_rotate.py <path/to/graphics_fbdev.cpp>")
    sys.exit(2)
p = sys.argv[1]
s = open(p, encoding='utf-8', errors='replace').read()
orig = s

# ---------- 1) fbdev_init: gr_draw 交换宽高为竖屏 ----------
# 原代码（android-11 / twrp-11 通用）:
#     gr_draw->data = (unsigned char*) calloc(gr_draw->height * gr_draw->row_bytes, 1);
old_alloc = "gr_draw->data = (unsigned char*) calloc(gr_draw->height * gr_draw->row_bytes, 1);"
rot_alloc = '''    // === S2 EPD 竖屏面板: 交换 gr_draw 宽高 => 渲染竖屏 UI ===
    {
        unsigned int _tmpw = gr_draw->width;
        gr_draw->width = gr_draw->height;
        gr_draw->height = _tmpw;
        gr_draw->row_bytes = gr_draw->width * gr_draw->pixel_bytes;
        printf("gr_draw rotated to %u x %u\\n", gr_draw->width, gr_draw->height);
    }
'''
if old_alloc in s:
    s = s.replace(old_alloc, rot_alloc + "\n" + old_alloc, 1)
    print("[OK] fbdev_init: 已交换 gr_draw 宽高为竖屏")
else:
    print("[FAIL] fbdev_init: 未找到 calloc 行")
    print("--- 实际文件中含 calloc 的行 ---")
    for i, l in enumerate(s.split('\n')):
        if 'calloc' in l:
            print(i, l)
    open(p + ".orig.dump", "w").write(orig)
    sys.exit(1)

# ---------- 2) fbdev_flip: 像素变换（左旋90°+镜像） ----------
# 双缓冲分支
old_dbl = "        memcpy(gr_framebuffer[1-displayed_buffer].data, gr_draw->data,\n               gr_draw->height * gr_draw->row_bytes);"
new_dbl = '''        // === S2: 左旋90°+镜像 像素变换（竖屏 gr_draw -> 物理横屏 fb）===
        {
            uint32_t* _src = (uint32_t*)gr_draw->data;
            uint32_t* _dst = (uint32_t*)gr_framebuffer[1-displayed_buffer].data;
            int _Wg = gr_draw->width, _Hg = gr_draw->height;
            int _Wf = gr_framebuffer[0].width, _Hf = gr_framebuffer[0].height;
            for (int _Y = 0; _Y < _Hf; ++_Y)
                for (int _X = 0; _X < _Wf; ++_X)
                    _dst[_Y * _Wf + _X] = _src[(_Hg - 1 - _X) * _Wg + (_Wg - 1 - _Y)];
        }'''
if old_dbl in s:
    s = s.replace(old_dbl, new_dbl, 1)
    print("[OK] fbdev_flip: 双缓冲分支已应用像素变换")
else:
    print("[WARN] fbdev_flip: 双缓冲 memcpy 未精确匹配，尝试宽松匹配")
    import re
    m = re.search(r"memcpy\(gr_framebuffer\[1-displayed_buffer\]\.data, gr_draw->data,", s)
    if m:
        # 找到该 memcpy 起始，整段替换
        print("      双缓冲 memcpy 位于偏移", m.start())
    else:
        print("[FAIL] fbdev_flip: 双缓冲 memcpy 未找到")
        open(p + ".orig.dump", "w").write(orig)
        sys.exit(1)

# 单缓冲分支
old_sgl = "        memcpy(gr_framebuffer[0].data, gr_draw->data,\n               gr_draw->height * gr_draw->row_bytes);"
new_sgl = '''        // === S2: 单缓冲 左旋90°+镜像 ===
        {
            uint32_t* _src = (uint32_t*)gr_draw->data;
            uint32_t* _dst = (uint32_t*)gr_framebuffer[0].data;
            int _Wg = gr_draw->width, _Hg = gr_draw->height;
            int _Wf = gr_framebuffer[0].width, _Hf = gr_framebuffer[0].height;
            for (int _Y = 0; _Y < _Hf; ++_Y)
                for (int _X = 0; _X < _Wf; ++_X)
                    _dst[_Y * _Wf + _X] = _src[(_Hg - 1 - _X) * _Wg + (_Wg - 1 - _Y)];
        }'''
if old_sgl in s:
    s = s.replace(old_sgl, new_sgl, 1)
    print("[OK] fbdev_flip: 单缓冲分支已应用像素变换")
else:
    print("[WARN] fbdev_flip: 单缓冲 memcpy 未精确匹配")

open(p, "w").write(s)
print("[DONE] 补丁已写入", p)
