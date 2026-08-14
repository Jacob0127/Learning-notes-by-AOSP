#!/bin/bash
# 图片批量重命名工具
#
# 选择模式：
#   1) 锁屏壁纸  → wallpaper01, wallpaper02, ... （无 _small 副本）
#   2) 桌面壁纸  → wallpaper_00 + wallpaper_00_small, ... （有 _small 副本）
#   3) 开机动画  → 00, 01, ... （无前缀，无 _small 副本）
#
# 支持格式: jpg, jpeg, png, gif, bmp, webp, svg

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "==================================="
echo "       图片批量重命名工具"
echo "==================================="
echo ""
echo "请选择处理模式："
echo "  1) 锁屏壁纸  → wallpaper01.ext, wallpaper02.ext ..."
echo "  2) 桌面壁纸  → wallpaper_00.ext + wallpaper_00_small.ext ..."
echo "  3) 开机动画  → 00.ext, 01.ext ..."
echo ""
read -r -p "请输入数字 (1/2/3): " MODE

case "$MODE" in
    1)
        PREFIX="wallpaper"
        START_NUM=1
        GEN_SMALL=false
        TYPE_DESC="锁屏壁纸"
        ;;
    2)
        PREFIX="wallpaper_"
        START_NUM=0
        GEN_SMALL=true
        TYPE_DESC="桌面壁纸"
        ;;
    3)
        PREFIX=""
        START_NUM=0
        GEN_SMALL=false
        TYPE_DESC="开机动画"
        ;;
    *)
        echo "错误: 无效输入，请输入 1、2 或 3"
        exit 1
        ;;
esac

echo ""
echo "模式: $TYPE_DESC (前缀: ${PREFIX}, 起始序号: ${START_NUM})"
echo ""

# 收集所有图片文件
IMAGE_FILES=()
for f in *; do
    if [ ! -f "$f" ]; then
        continue
    fi
    # 跳过脚本自身
    case "$f" in
        *.sh) continue ;;
    esac
    # 跳过已处理过的输出文件，避免重复处理
    base="${f%.*}"
    if [ -n "$PREFIX" ]; then
        case "$f" in
            ${PREFIX}[0-9]*) continue ;;
        esac
    else
        # 开机动画模式：跳过纯数字文件名（如 00.jpg）
        if echo "$base" | grep -qE '^[0-9]{2}$'; then
            continue
        fi
    fi
    ext="${f##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    case "$ext_lower" in
        jpg|jpeg|png|gif|bmp|webp|svg)
            IMAGE_FILES+=("$f")
            ;;
    esac
done

if [ ${#IMAGE_FILES[@]} -eq 0 ]; then
    echo "当前目录下没有找到需要处理的图片文件"
    exit 1
fi

# 排序
IFS=$'\n' IMAGE_FILES=($(sort <<<"${IMAGE_FILES[*]}"))

echo "找到 ${#IMAGE_FILES[@]} 个图片文件"
echo "-----------------------------------"

INDEX=$START_NUM
for src in "${IMAGE_FILES[@]}"; do
    ext="${src##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    seq_num=$(printf "%02d" "$INDEX")

    new_name="${PREFIX}${seq_num}.${ext_lower}"
    new_name_small="${PREFIX}${seq_num}_small.${ext_lower}"

    echo "重命名: $src  ->  $new_name"
    mv "$src" "$new_name"

    if [ "$GEN_SMALL" = true ]; then
        echo "复制:   $new_name  ->  $new_name_small"
        cp "$new_name" "$new_name_small"
    fi

    INDEX=$((INDEX + 1))
done

echo "-----------------------------------"
echo "处理完成！"
