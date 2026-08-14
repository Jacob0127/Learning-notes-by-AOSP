# Android 构建命令详解：ninja 与 m / mm / mmm

版本：V1.2，2026-08-13
适用平台：Android 12+（展讯 split build 环境）
配套文档：`doc_编译脚本使用说明.md`（mk 脚本）、`doc/编译单元与编译命令判断.md`（单元判断）

## 1 总览：一图看懂调用链

```
Android.bp（Soong 声明式构建文件）
Android.mk（Make 格式，兼容）
        │  soong_ui.bash（build/soong/soong_ui.bash）
        ▼
kati（Android.mk → ninja 语法）  soong（Android.bp → ninja 语法）
        ▼
build-<产品>.ninja（out_system/build-ussi_arm64_full_64only.ninja）
        │  ninja（真正干活的执行引擎）
        ▼
编译产物（out_system/target/product/...）
```

调用链结论：

- **ninja 是真正的执行引擎**，所有编译最终都由它执行
- **soong_ui.bash 是总入口**：解析源码生成 ninja 文件，再调用 ninja
- **m / mm / mmm 只是上层的便捷封装**，最终都汇到 soong_ui → ninja

## 2 ninja 是什么

**ninja 是一个极速构建引擎**，Google 为 Chromium 编写，Android 7.0 起成为 AOSP 的底层构建引擎。

特点：

| 特性 | 说明 |
|------|------|
| 声明式 | 不自己分析源码依赖，一切由 .ninja 文件描述：目标、依赖、命令 |
| 并行 | 按依赖图最大化并行（-j 控制线程数） |
| 增量 | 只重编依赖变化的模块（按 mtime 判断） |
| 极快 | 启动和调度开销极小，适合大项目 |

ninja 文件长这样（`SYS/out_system/build-ussi_arm64_full_64only.ninja` 实测）：

```
build out_system/.../obj/APPS/BlockBlast_intermediates/package.apk: rule3087 \
    vendor/sprd/third_preloadapp/BlockBlast/BlockBlast.apk \
    out_system/.../enforce_uses_libraries.status
    description = target Prebuilt: BlockBlast
    command = /bin/bash -c "(cp ... BlockBlast.apk .../package.apk)"
```

每行 `build <输出>: <规则> <输入>`，`command` 是实际执行的命令。**模块的每一步构建命令都能在 ninja 文件里查到**（这也是排查"模块怎么编的"的依据，见《编译单元与编译命令判断.md》2.4 节）。

ninja 可执行文件位置：`SYS/prebuilts/build-tools/linux_musl-x86/bin/ninja`。

## 3 m / mm / mmm 是什么

三者都是构建环境的便捷函数（shell 函数），来源不同、行为不同：

| 命令 | 全称含义 | 行为 | 当前状态 |
|------|---------|------|---------|
| m | make 的封装 | 在树根时自动改调 `build/soong/soong_ui.bash --make-mode`，可全量编译或指定目标 | 新版保留 |
| mm | make module（当前目录） | 编译**当前目录**所在的模块 | 官方已移除（Android 12 前后 envsetup.sh 里 `unset mmm`，官方改推 m）；展讯 mk 环境保留可用 |
| mmm | make module path | 编译**指定路径**的模块，`mmm <路径>:<模块名>` | 官方已移除；展讯 mk 环境保留可用 |

实测依据（`SYS/build/envsetup.sh`）：

```bash
function make()
{
    _wrap_build $(get_make_command "$@") "$@"
}
# get_make_command 在树根时返回 build/soong/soong_ui.bash --make-mode
...
unset mmm    # 新版 AOSP 不再提供 mmm/mm
```

即：**m 的本质 = 调 soong_ui.bash --make-mode**，而 soong_ui 内部就是"生成 ninja + 跑 ninja"。mm/mmm 是旧版 make 时代的产物，新版删除，但展讯的 mk 脚本环境（lsys 等）里仍然可用（`. mk lsys mmm <路径>:<模块>` 是官方用法）。

## 4 区别对比

| 维度 | m | mm | mmm | ninja |
|------|---|----|-----|-------|
| 作用范围 | 全量或任意指定目标 | 当前目录的模块 | 指定路径的模块 | 任意 ninja 目标 |
| 在哪里执行 | 任意目录（树内） | 模块目录内 | 任意目录 | 任意目录（指定 -f） |
| 典型用法 | `m`、`m Settings` | `cd <模块目录> && mm` | `mmm <路径>:<模块>` | `ninja -f <ninja文件> <目标>` |
| 是否解析源码 | 否（交给 soong） | 否 | 否 | 否，只按图执行 |
| 增量 | 是 | 是 | 是 | 是 |
| 能查构建信息 | 否 | 否 | 否 | 能（-t query/commands） |

一句话区分：

- **m**：我不关心模块在哪，全量或点名编译
- **mm**：我就在模块目录里，编当前这个
- **mmm**：我知道模块路径，编那个
- **ninja**：跳过一切封装，直接操作构建图

## 5 什么时候用哪个

| 场景 | 用哪个 |
|------|--------|
| 整编出包（本项目） | `. mk msys` / `. mk new`（mk 脚本封装，最省事） |
| 改了很多模块，要重新出镜像 | `m` 或对应单元整编 |
| 单编某个模块验证 | `mmm <路径>:<模块>` 或 `. mk ms <模块>` 或 soong_ui 直调 |
| 只想编当前目录的模块 | `mm`（旧环境） |
| 查模块的构建命令/依赖关系 | `ninja -t commands / -t query` |
| 强制重编某个模块（缓存失效怀疑） | 删 `<模块>_intermediates` 目录后重编，或 `ninja -t clean` 相关目标 |

本项目实际最常用的三件套：

```bash
. mk lsys mmm packages/apps/Settings:Settings   # 单编指定模块（system 单元）
. mk lothers mmm <others模块路径>:<模块>        # others 单元
. mk ms <模块名>                                 # 快速单编（仅改 java/kt 时）
```

## 6 怎么用

### 6.1 lunch 与产品列表（编译前的环境初始化）

**新版 lunch 不再显示产品列表**。旧版 `lunch` 不带参数会弹交互式列表，新版（实测 envsetup.sh）不带参数直接报错：

```
$ lunch
No target specified. See lunch --help
```

lunch 必须带完整参数。产品列表本身还在，只是不归 lunch 展示了。

**怎么列出有哪些产品**（三选一）：

```bash
# 方式一：看产品定义文件（官方机制，通用）
find device -maxdepth 3 -name AndroidProducts.mk

# 方式二：直接看产品目录（最朴素）
ls device/sprd/ussi/*/product/      # 展讯：每个子目录 = 一个产品
ls device/<厂商>/<产品>/             # 通用

# 方式三：mk 脚本（本项目）
. mk list                            # 列出可编译项目并编号
. mk show                            # 看当前选中的工程
```

展讯产品列表机制（`device/sprd/ussi/AndroidProducts.mk` 实测）：动态扫描 `device/sprd/ussi/*/product/` 目录，每个子目录（main.mk）是一个产品，lunch 组合为 `<产品>-<release>-<variant>-<build_version>`。

**当前项目的 lunch 命令**（各单元，值取自 mk 脚本模板与 dumpvars）：

```bash
cd SYS && unset -f grep && source build/envsetup.sh

lunch ussi_arm64_full_64only-unisoc_release-userdebug-gms   # system / android_others
lunch ugvi_arm64_full_64only-unisoc_release-userdebug       # vendor
lunch uck_arm64_kernel6.18-userdebug                        # kernel
```

mk 脚本做的事（对照）：`. mk list` 列项目、`. mk init` 选工程，lunch target 按模板拼好再调标准 lunch——本质还是官方 lunch，只是把 `sys_lunch_target="ussi_${arch}_${go_full}${extra_variant}-${rc_full}-${build_variant}${lunch_suffix}"` 这类变量填好了。

**官方推荐流程**（source.android.com/setup/build/building）：

```bash
. build/envsetup.sh
lunch <产品>-<variant>    # 官方新版：必须带参数
m                         # 官方主命令
```

官方单编工具（envsetup.sh 实测存在）：`tapas <模块>`（按模块名单编，不依赖完整产品环境）、`banchan`（编 APEX）。

### 6.2 通用底层命令（不依赖任何脚本，推荐掌握）

mk 脚本只是封装，底层通用命令才是根本。完整链路，不需要 mk 脚本、不需要 source envsetup：

**第一步：环境变量**（值从 `out_<单元>/dumpvars.txt` 拿）

```bash
cd /work/work1/xiaowei/5_sprd17/SYS && \
export OUT_DIR=out_system TARGET_PRODUCT=ussi_arm64_full_64only \
    TARGET_RELEASE=unisoc_release TARGET_BUILD_VARIANT=userdebug \
    TARGET_BUILD_VERSION=gms UNISOC_TARGET_RELEASE=unisoc_release
```

**第二步：编译**（标准 AOSP 总入口 soong_ui.bash）

```bash
# 全量编译（等价 . mk msys 的编译部分）
build/soong/soong_ui.bash --make-mode -j34

# 单编指定模块（等价 mmm / . mk ms）
build/soong/soong_ui.bash --make-mode BlockBlast -j34
build/soong/soong_ui.bash --make-mode Settings SystemUI -j34

# 指定镜像目标
build/soong/soong_ui.bash --make-mode systemimage -j34
```

**第三步（最底层）：直接跑 ninja**（已有 ninja 文件时，跳过 soong 重新生成）

```bash
./prebuilts/build-tools/linux_musl-x86/bin/ninja \
    -f out_system/build-ussi_arm64_full_64only.ninja \
    out_system/target/product/ussi_arm64/obj/APPS/BlockBlast_intermediates/package.apk
```

三层关系：

| 层 | 命令 | 依赖 | 何时用 |
|----|------|------|--------|
| 封装 | mk 脚本（`. mk msys` 等） | 公司环境 | 日常快用 |
| 标准 | `soong_ui.bash --make-mode` | 只要环境变量 | 无脚本时的标准做法 |
| 最底层 | `ninja -f build-*.ninja` | ninja 文件存在 | 查信息、精确重编 |

其他单元换 OUT_DIR（out_android_others / out_vendor / out_vnd_others），TARGET_PRODUCT 对应换（对照表见《编译单元与编译命令判断.md》3.2 节）。

mk 脚本与底层的对应关系（mk 只是封装，本质就是这些命令）：

```bash
. mk lsys        ≈  cd SYS && export OUT_DIR=out_system && lunch <target>
. mk msys        ≈  cd SYS &&（环境变量）&& soong_ui.bash --make-mode（全量）
. mk lsys mmm X  ≈  cd SYS &&（环境变量）&& soong_ui.bash --make-mode X
```

mk 额外做的两件事：overlay 拷贝（jzhk cp）和 merge 出包（PAC），是流程性附加，编译本身就是 soong_ui。

### 6.3 m/mm/mmm 的用法（envsetup 环境）

m/mm/mmm 需要构建环境（source + lunch），ninja 需要 ninja 文件存在（至少编过一次）：

```bash
cd SYS && unset -f grep && source build/envsetup.sh && lunch <target>
# 或用 mk 脚本：. mk lsys（进 SYS 并初始化 system 单元环境）
```

> **注意**：source envsetup.sh 前必须 `unset -f grep`（Bash 工具的 grep 是 ugrep 包装，会让 lunch 报误导性错误）。

### 6.4 m 的用法

m 支持直接按模块名单编（Google 废弃 mm/mmm 后官方推荐方式）：

```bash
m                          # 全量编译当前产品
m BlockBlast               # 单编一个模块（不用写路径，全产品范围按名解析）
m Settings SystemUI        # 多个模块空格分隔
m systemimage              # 编 system 镜像目标
m -j34 Settings            # 指定线程数
```

原理：soong 为每个模块生成 `<模块名>-target` 的 phony 目标（ninja 文件实测：`build Settings-target: phony device_Settings_all_targets`），`m <模块名>` 等价 `soong_ui.bash --make-mode <模块名>`，等价老 `mmm <路径>:<模块>`。

### 6.5 mm 的用法（旧环境）

```bash
cd packages/apps/Settings && mm    # 编译当前目录模块
```

### 6.6 mmm 的用法

```bash
mmm packages/apps/Settings:Settings        # 指定路径:模块名
mmm vendor/sprd/third_preloadapp/BlockBlast:BlockBlast
```

路径缺省模块名时取目录名（Android.mk 的 LOCAL_MODULE 或 Android.bp 的 name 为准）。

### 6.7 ninja 的用法

```bash
NINJA=SYS/prebuilts/build-tools/linux_musl-x86/bin/ninja

# 编译指定目标（等价于 make 指定模块，但直接走图）
$NINJA -f SYS/out_system/build-ussi_arm64_full_64only.ninja \
    out_system/target/product/ussi_arm64/obj/APPS/BlockBlast_intermediates/package.apk

# 查目标的依赖与命令
$NINJA -f <ninja文件> -t query BlockBlast
$NINJA -f <ninja文件> -t commands BlockBlast

# 查所有目标（模块名列表）
$NINJA -f <ninja文件> -t targets | grep BlockBlast
```

> **注意**：soong 生成的 ninja 文件引用自定义 pool（highmem_pool 等），直接调 ninja 可能报 `unknown pool name`，属正常现象——正常编译请走 soong_ui（m / mk 脚本），ninja 仅用于查信息。

### 6.8 17 系绕过 lunch 的直调（无 envsetup 时）

```bash
cd SYS && export OUT_DIR=out_system TARGET_PRODUCT=ussi_arm64_full_64only \
    TARGET_RELEASE=unisoc_release TARGET_BUILD_VARIANT=userdebug \
    TARGET_BUILD_VERSION=gms UNISOC_TARGET_RELEASE=unisoc_release && \
build/soong/soong_ui.bash --make-mode BlockBlast -j34
```

## 7 常见问题

| 现象 | 原因 | 处理 |
|------|------|------|
| mmm 提示 command not found | 环境没初始化（未 source envsetup / 未 lsys） | `. mk lsys` 后重试 |
| ninja 报 unknown pool name | soong ninja 文件带自定义 pool，裸 ninja 跑不了 | 用 m / soong_ui 编译，ninja 只查信息 |
| m 全量编译很久 | m 默认全量 | 用 m <模块> 或 mmm 单编 |
| 改了代码编译没生效 | 见《编译单元与编译命令判断.md》第 6 节四层验证 | 内容/mtime/设备 md5/链路排查 |

## 变更记录

| 日期 | 版本 | 内容 |
|------|------|------|
| 2026-08-13 | V1.0 | 初版：调用链总览、ninja 与 m/mm/mmm 概念、区别对照、场景选择、用法示例 |
| 2026-08-13 | V1.1 | 新增 6.1 通用底层命令（不依赖任何脚本：dumpvars 环境变量 + soong_ui 直调 + ninja 直跑，含 mk 封装对照）；6.2 起小节重新编号；明确 mm/mmm 为官方移除而非展讯行为 |
| 2026-08-13 | V1.2 | 新增 6.1 lunch 与产品列表（新版 lunch 不带参报错、三种列产品方式、当前项目各单元 lunch、官方推荐流程与 tapas/banchan）；后续小节顺延编号 |
