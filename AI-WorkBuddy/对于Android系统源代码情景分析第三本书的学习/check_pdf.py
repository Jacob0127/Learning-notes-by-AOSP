#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""检查PDF是否有文字层，并尝试提取前几页内容"""

import fitz  # pymupdf

PDF_PATH = r"C:\Users\admin38\Desktop\Android系统源代码情景分析  第3版@www.java1234.com\Android系统源代码情景分析  第3版@www.java1234.com.pdf"

doc = fitz.open(PDF_PATH)
print(f"PDF总页数: {doc.page_count}")
print(f"PDF元数据: {doc.metadata}")
print()

# 检查前20页是否有文字层
has_text_any = False
for page_num in range(min(20, doc.page_count)):
    page = doc[page_num]
    text = page.get_text()
    if text.strip():
        has_text_any = True
        print(f"=== 第 {page_num+1} 页 (有文字层) ===")
        print(text[:500])
        print("..." if len(text) > 500 else "")
    else:
        print(f"=== 第 {page_num+1} 页 (无文字层，可能是扫描版) ===")
        # 检查是否有图片
        images = page.get_images()
        print(f"    内含图片: {len(images)} 张")

doc.close()

if not has_text_any:
    print("\n\n结论: 此PDF是纯扫描版，无文字层。需要使用OCR识别。")
else:
    print("\n\n结论: 此PDF包含文字层，可以直接提取。")
