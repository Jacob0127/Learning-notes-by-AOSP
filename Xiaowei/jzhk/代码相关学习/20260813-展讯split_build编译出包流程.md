# 展讯 split_build 编译出包流程

版本：V1.0，2026-08-13
适用平台：展讯 17 系 split build（SYS/VND/KERNEL 三棵树），Android 17
配套文档：`doc/编译单元与编译命令判断.md`（单元判断）、`doc/Android构建命令详解-ninja与m-mm-mmm.md`（编译命令）

## 1 背景：为什么展讯要拆单元编译

标准 AOSP 是单棵树、单产品、一次全量编译。展讯项目大（含 GMS 快速通道），一次全量编译耗时过长，于是把整个系统拆成多个**编译单元**，各自独立编译（可并行），最后**合并（merge）**成一个完整镜像，再打成展讯专用的 **PAC 刷机包**。

> **说明**：split build、merge、PAC 都是展讯定制体系。标准 AOSP 没有 merge 概念（本来就是一棵树），PAC 是展讯工厂/售后刷机格式。MTK 是另一套类似拆分的体系（out_sys_debug/out_vext_debug 等），工具完全不同。

## 2 架构：六个编译单元

| 树 | 编译单元 | out 目录 | 内容 |
|----|---------|---------|------|
| SYS | system | `out_system` | frameworks、普通 app、三方预装 |
| SYS | android_others | `out_android_others` | GMS 应用、个别工具 |
| VND | vendor | `out_vendor` | vendor 侧模块 |
| VND | vnd_others | `out_vnd_others` | sepolicy、init.rc |
| VND | bsp | `VND/bsp/out` | bootloader、sensorhub |
| KERNEL | kernel | `KERNEL/out` | 内核 |

各单元独立编译、产物互不干扰，这是并行加速的本质。

## 3 完整出包流程

```
各单元独立编译（六个 out）
        │
        ▼
split_build merge（merge.py + merge_split_target_files.py）
        │  ① 按 sys_config.yml 的 artifacts 清单收集各单元产物 → VND/out_merge/
        │  ② 合成完整 target_files（MergeVndTargetFiles）
        │  ③ 合成 merged images + super image
        ▼
VND/out_merge/（合并产物：system_artifacts、vendor_artifacts、vnd_others_artifacts、
                bsp_artifacts、kernel_artifacts、android_others_artifacts、dist）
        │
        ▼
PAC 打包（package_tool.py BuildPac → VND/vendor/sprd/release/pac_script/makepac.py）
        ▼
release/<项目>_<变体>_<代号>_<时间>/*.pac
```

### 3.1 第一步：各单元独立编译

每个单元在自己的 out 目录编译（命令见《编译单元与编译命令判断.md》第 3 节）。产物是分区级的中间结果，尚不成完整镜像。

### 3.2 第二步：merge 合成

split_build 编译完成后自动进入 merge 阶段（split_build.py 参数 `--merge-only` 可只 merge 不编译，`--force-merge` 跳过兼容性检查）：

1. **按清单收集**：`config/sys_config.yml` 定义各单元 artifacts 清单（system_artifacts、android_others_artifacts、vendor_artifacts、vnd_others_artifacts、bsp_artifacts、kernel_artifacts），按清单从各 out 收集产物到 `VND/out_merge/`（实测该目录下正是这六个 artifacts 目录 + dist）
2. **合成 target_files**：`merge_split_target_files.py` 的 `MergeVndTargetFiles` 把 VND 侧多个单元的 target_files 合并，同时处理 postinstall 配置合并（MergePostinstallConfig）、NOTICE 合并（MergeNoticeGz）、文件系统配置合并（MergeVendorFileSystemConfig）、kernel 分支信息写入 vendor（InstallKernelBranchInfoIntoVendor）等
3. **合成镜像**：生成 merged images 与 super image（动态分区镜像）

merge.py 的 docstring（实测）概括输出内容：Merged images、Super image、Merged target files and OTA package、PAC。

### 3.3 第三步：PAC 打包

merge.py 里 `pkg_tool.BuildPac()`（实测 merge.py:361）调用 `VND/vendor/sprd/release/pac_script/makepac.py`，把合并后的各分区镜像打包成 .pac 刷机文件（含签名与校验，供工厂/售后刷机工具使用）。

最终输出到 `release/<项目>_<变体>_<代号>_<时间>/`，实测内容：

```
release/t40_d4xef_t615_hd_800_1280_yunji_P03D_incell_256GB_6GB_debug_C_2026_08_12_23_26/
├── boot.img            ← 内核（KERNEL/out）
├── init_boot.img       ← 17 系 init_boot 分区
├── vendor_boot.img     ← vendor boot 分区
├── vmlinux             ← 内核符号表
├── qogirl6_cm4.elf     ← sensorhub 固件（bsp）
├── build.prop          ← 版本信息
├── git_info.txt        ← 构建环境与产物属性
├── gms_info.txt        ← GMS 版本信息
└── t40_....pac         ← 主刷机包（所有分区镜像合成）
```

> **说明**：PAC 包名里的单个版本字母是 Android 大版本代号：V=A15 / W=A16 / X=A17；改后 B=A16 / C=A17 / D=A18。本例 C 即 Android 17。

## 4 split_build 工具用法

工具位置：`SYS/vendor/sprd/release/split_build/split_build`（Python 入口 split_build.py）

```bash
# 完整流程：编译指定组件 + merge + 出 PAC
split_build -v --lunch <target> --components system --build-pac --out ./VND/out_merge/

# 全编（所有单元）+ merge + PAC（等价 . mk new）
split_build -v --lunch <target> --components system android_others vendor vnd_others bsp kernel \
    --build-pac --out ./VND/out_merge/

# 只 merge 不编译（产物没变想重新出包）
split_build -v --lunch <target> --merge-only --build-pac --out ./VND/out_merge/
```

mk 脚本对应关系（实测 mk 脚本）：

```bash
. mk msys   ≈  split_build --components system --build-pac --out ./VND/out_merge/
. mk new    ≈  split_build --components <全部单元> --build-pac --out ./VND/out_merge/
. mk pac    ≈  split_build --merge-only（或等效）不重编直接出包
```

## 5 与其他构建体系对比

| 维度 | 标准 AOSP | 展讯 split build | MTK |
|------|----------|-----------------|-----|
| 树结构 | 单树 | SYS/VND/KERNEL 三树 | 多目录（W/、V/ 等） |
| 编译单元 | 无（单产品全量） | 六单元独立编译 | 类似拆分（sys/vext/krn/hal） |
| 出包产物 | system.img 等 + target_files | merge 后 .pac + 各 img | 类似 AOSP + 定制 |
| 刷机格式 | fastboot/OTA | PAC（工厂用） | 定制格式 |
| merge 概念 | 无 | 有（split_build merge） | 有（类似） |
| 主要工具 | m / soong_ui | split_build | 自有脚本 + mmm |

## 6 常见问题

| 现象 | 原因 | 处理 |
|------|------|------|
| 改了代码刷机没生效 | 单编了模块但没整编/merge | 整编组件（msys）或 --merge-only 重新出包 |
| release 包日期旧 | 没重新 merge | 重新跑出包命令（. mk pac 或 merge-only） |
| merge 报兼容性错误 | 单元产物版本不一致 | `--force-merge`（谨慎，确认改动匹配） |
| 只想重出包不想编译 | 编译已完成 | `--merge-only --build-pac` |

## 变更记录

| 日期 | 版本 | 内容 |
|------|------|------|
| 2026-08-13 | V1.0 | 初版：split build 背景、六单元架构、编译→merge→PAC 三步流程（含实测证据）、split_build 用法、与 AOSP/MTK 对比 |
