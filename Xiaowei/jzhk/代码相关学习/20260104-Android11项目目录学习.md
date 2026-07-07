# 输入法

```路径
sprd/packages/inputmethods
```

![image-20251224112307511](C:\Users\admin38\AppData\Roaming\Typora\typora-user-images\image-20251224112307511.png)

## LatinIME（**拉丁输入法**）

1. **作用**：Android **默认的软键盘输入法**，支持：
   - 拼音、笔画、手写（中文）
   - 英文 QWERTY 键盘
   - 其他拉丁语系语言
2. **用途**：普通手机/平板等**触屏设备**的主要输入法。
3. **特点**：
   - 包含字典、词库、预测输入
   - 支持多点触控、手势输入
   - 是 AOSP 中功能最完整的输入法实现

### common模块

![image-20251224113225952](C:\Users\admin38\AppData\Roaming\Typora\typora-user-images\image-20251224113225952.png)

#### annotations

- 作用：注解定义目录
- 内容：
  - ExternallyReferenced.java：标记被外部代码引用的类或方法
  - UsedForTesting.java：标记仅用于测试的类或方法

#### latin/commom

- 作用：拉丁输入法通用工具类目录
- 内容：
  - CodePointUtils.java：Unicode 码点处理工具
  - CollectionUtils.java：集合操作工具
  - ComposedData.java：组合数据处理类
  - Constants.java：常量定义
  - CoordinateUtils.java：坐标计算工具
  - FileUtils.java：文件操作工具
  - InputPointers.java：输入指针管理
  - LocaleUtils.java：本地化相关工具
  - NativeSuggestOptions.java：原生建议选项
  - ResizableIntArray.java：可调整大小的整数数组
  - StringUtils.java：字符串处理工具
  - UnicodeSurrogate.java：Unicode 代理对处理

### dictionaries模块

dictionaries 目录包含输入法使用的词典数据文件，这些文件是经过压缩的二进制格式。![image-20251224113848919](C:\Users\admin38\AppData\Roaming\Typora\typora-user-images\image-20251224113848919.png)

#### 语言字典文件

```
命名规则：[语言代码]_[地区代码]_wordlist.combined.gz
```

示例：

- en_US_wordlist.combined.gz：美式英语词典
- zh_CN_wordlist.combined.gz：简体中文词典
- th_wordlist.combined.gz：泰语词典

#### 表情符号词典文件

```
命名规则：[语言代码]_emoji.combined.gz
```

示例：

- en_emoji.combined.gz：英文表情符号词典
- fr_emoji.combined.gz：法文表情符号词典

#### 样本文件

- 文件名：sample.combined
- 作用：样本词典文件，用于测试和演示

### gradle模块

![image-20251224114219649](C:\Users\admin38\AppData\Roaming\Typora\typora-user-images\image-20251224114219649.png)

作用：

- 提供 Gradle Wrapper 的实现
- 确保项目使用特定版本的 Gradle 进行构建
- 使构建过程独立于开发环境中的 Gradle 安装

### java模块

#### res

- 作用：资源目录

- 内容：包含所有非代码资源文件

##### anim

- 作用：动画资源目录
- 内容：
  - ait_code_key_while_typing_fadein.xml：输入时按键淡入动画
  - ait_code_key_while_typing_fadeout.xml：输入时按键淡出动画
  - key_preview_dismiss_holo.xml：按键预览消失动画
  - key_preview_show_up_holo.xml：按键预览显示动画
  - language_on_spacebar_fadeout.xml：空格键语言切换淡出动画

##### color

- 作用：颜色资源目录
- 内容：
  - setup_step_action_background.xml：设置步骤操作背景色
  - setup_step_action_color.xml：设置步骤操作文字颜色

##### layout

- 作用：布局资源目录
- 内容：
  - additional_subtype_dialog.xml：附加子类型对话框布局
  - dictionary_line.xml：词典条目布局
  - download_over_metered.xml：计量网络下载完成布局
  - emoji_keyboard_page.xml：表情键盘页面布局
  - emoji_keyboard_tab_icon.xml：表情键盘标签图标布局
  - emoji_palettes_view.xml：表情调色板视图布局
  - input_view.xml：输入视图主布局
  - loading_page.xml：加载页面布局
  - main_keyboard_frame.xml：主键盘框架布局
  - more_keys_keyboard.xml：更多按键键盘布局
  - more_keys_keyboard_for_action_lix.xml：动作键更多按键键盘布局
  - more_suggestions.xml：更多建议布局
  - radio_button_preference_widget.xml：单选按钮偏好项小部件布局
  - seek_bar_dialog.xml：滑动条对话框布局
  - setup_start_indicator_label.xml：设置开始指示器标签布局
  - setup_step.xml：设置步骤布局
  - setup_steps_cards.xml：设置步骤卡片布局
  - setup_steps_screen.xml：设置步骤屏幕布局
  - setup_steps_title.xml：设置步骤标题布局
  - setup_welcome_screen.xml：欢迎屏幕布局
  - setup_welcome_title.xml：欢迎标题布局
  - setup_welcome_video.xml：欢迎视频布局
  - setup_wizard.xml：设置向导布局
  - suggestion_divider.xml：建议分隔线布局
  - suggestions_strip.xml：建议条布局
  - user_dictionary_add_word_fullscreen.xml：用户词典添加单词全屏布局
  - user_dictionary_item.xml：用户词典项目布局

##### values

- 作用：字符串资源目录
- 内容：包含各种语言的字符串资源，按语言和地区分类

#### src

- 作用：Java 源代码根目录
- 内容：包含所有 Java 源文件

##### accessibility

- 作用：无障碍支持
- 内容：提供无障碍功能的实现

##### compat

- 作用：兼容性支持
- 内容：处理不同 Android 版本的兼容性问题

##### dictionarypack

- 作用：词典包管理
- 内容：处理词典包的下载、安装和更新

##### event

- 作用：事件处理
- 内容：处理输入事件和系统事件

##### keyboard

- 作用：键盘功能实现
- 内容：包含键盘的核心逻辑和交互

##### latin

- 作用：拉丁输入法实现
- 内容：包含拉丁输入法的具体实现

##### inputmethodcommon（通用输入法）

- 作用：输入法通用设置
- 内容：
  - InputMethodSettingsActivity.java：输入法设置活动
  - InputMethodSettingsFragment.java：输入法设置片段
  - InputMethodSettingsImpl.java：输入法设置实现
  - InputMethodSettingsInterface.java：输入法设置接口

## LeanbackIME（**电视输入法**）

1. **作用**：专为 **Android TV（电视/大屏设备）** 设计的输入法。
2. **设计特点**：
   - **大字体、高对比度**，适合远距离观看
   - **方向键导航**（用遥控器 D-pad 选择字母）
   - **简化布局**，通常只有字母和数字，无复杂手势
   - 支持**语音输入**（电视遥控器常带麦克风）
3. **用途**：电视、机顶盒、车载大屏等**非触屏设备**。

# jzhk（九州华科）

## driver（驱动）

### audio_nv（音频）

### camera（相机）

### lcm（LCD Module液晶显示模组）

### mk_config（配置文件）

### pcb_diff（电路板差异配置）

### pinmap（引脚映射配置）

### project（项目）

## mk（配置文件）

## product（产品）

- 存储不同产品的特定配置
- 管理启动动画
- 配置展锐芯片相关设置
- 定义用户界面主题

![image-20251224145346035](C:\Users\admin38\AppData\Roaming\Typora\typora-user-images\image-20251224145346035.png)

### boot_animation（启动动画）

- 作用：启动动画目录
- 内容：包含设备启动时显示的动画文件

### sprd（展锐）

- 作用：展锐（Sprd）相关配置
- 内容：包含展锐芯片相关的配置文件

#### bsp（板级支持包）

- 作用：板级支持包（Board Support Package）
- 内容：包含硬件相关的驱动和配置

##### bootloader（引导加载程序）

- 作用：引导加载程序
- 内容：
  - u-boot15：U-Boot 引导加载程序
  - include/boot_mode.h：启动模式定义

##### device（设备）

- 作用：设备相关配置
- 内容：
  - pike2：Pike2 平台配置
  - androidr/sp7731e_1h10/sp7731e_1h10_base/tos.cfg：TOS 配置文件

#### build（构建）

- 作用：构建系统
- 内容：
  - make/core/Makefile：核心 Makefile
  - target/product/base_system.mk：基础系统构建规则
  - tools/buildinfo.sh：构建信息脚本
  - tools/buildinfo_common.sh：通用构建信息脚本

#### device（设备）

- 作用：设备相关配置
- 内容：
  - sprd/mpool/module/media/codec/msoc/pike2/media_codecs_performance.xml：媒体编解码器性能配置
  - security/msoc/pike2/pike2.mk：安全模块配置
  - telephony/main.mk：电话模块构建规则
  - pike2/sp7731e_1h10/module/partition/md.mk：分区配置
  - pike2/sp7731e_1h10/module/security/md.mk：安全配置
  - pike2/sp7731e_1h10/module/sensor/md.mk：传感器配置
  - pike2/sp7731e_1h10/module/wallpaper/overlay/frameworks/base/core/res/res/values/config.xml：壁纸配置
  - pike2/sp7731e_1h10/module/wallpaper/overlay/device/base/frameworks/base/core/res/xml/power_profile.xml：电源配置
  - pike2/sp7731e_1h10/product/sp7731e_1h10_go2g/main.mk：产品构建规则
  - pike2/sp7731e_1h10/product/sp7731e_1h10.xml：产品配置
  - frameworks/base/core/res/res/values/config.xml：框架配置
  - packages/SettingsProvider/res/values/defaults.xml：设置提供者默认值

##### sprd

###### mpool（内存池Memory Pool）

```
mpool/
├── module/          # 各模块配置
│   ├── camera/      # 相机内存池配置
│   ├── video/       # 视频编解码
│   └── audio/       # 音频（较少用）
├── mpool.rc         # init.rc 服务定义
├── mpool.te         # SELinux 策略
├── mpoold/          # 守护进程源码
│   └── mpoold.c     # 核心守护进程
└── mpool_client.c   # 客户端库
```



###### sharkl5（芯片）

```
sharkl5/                              # 展讯sharkl5芯片平台根目录
├── ums312_2h10/                      # 参考设计：硬件配置代号ums312_2h10
└── module/                           # 模块化配置目录
    ├── security/                     # 安全模块配置（加密、验证等）
    │   └── md.mk                     # 安全模块的编译配置文件
    ├── ts/                           # 触摸屏（Touch Screen）模块
    │   └── md.mk                     # 触摸屏模块的编译配置文件
    └── md.mk                         # 模块化系统的主配置文件
```



#### frameworks（框架）

- 作用：frameworks 目录包含 Android 系统的核心框架代码，是系统运行的基础。

- 内容：
  - base：Android 基础框架，包含核心库和系统服务
  - core：核心组件，如 ActivityManager、WindowManager 等
  - res：资源文件，包括字符串、颜色、样式等
  - values：配置值，如默认设置、常量等

#### packages（应用程序包）

- 作用：packages 目录包含 Android 系统的各种应用程序包，是用户界面的主要组成部分。
- 内容：
  - apps：预装应用程序，如 Launcher3、Settings 等
  - Launcher3：主屏幕启动器，负责显示桌面图标和应用列表
  - Settings：系统设置应用，提供各种系统配置选项
  - res/values/config_ext.xml：扩展配置文件，包含特定设备的配置项
  - res/xml/notify_settings.xml：通知设置界面配置
  - res/xml/display_settings.xml：显示设置界面配置
  - res/xml/gestures.xml：手势设置界面配置

#### system（系统）

- 作用：system 目录包含系统级的二进制文件和库，是系统运行的必要组件。
- 内容：
  - bin：可执行文件，如系统工具和守护进程
  - lib：共享库，如系统库和第三方库
  - etc：配置文件，如网络配置、系统参数等
  - fonts：字体文件，用于系统文本显示
  - media：媒体文件，如系统声音、动画等

#### vendor（供应商）

- 作用：vendor 目录包含厂商特定的代码和资源，用于支持特定硬件和功能。
- 内容：
  - bin：厂商特定的可执行文件
  - lib：厂商特定的共享库
  - etc：厂商特定的配置文件
  - firmware：固件文件，用于初始化硬件
  - modules：模块文件，用于加载驱动程序

### ui_theme（主题）

- 作用：用户界面主题目录
- 内容：包含设备的 UI 主题和样式文件

## script（脚本）



# sprd（展讯）

## art（Android Runtime）

- 作用：Android Runtime（ART）目录
- 内容：包含 Android 运行时环境的核心组件

### adbconnection（adb连接）

- 作用：ADB 连接相关代码
- 内容：处理 ADB 连接和通信

### benchmark（基准）

- 作用：性能基准测试
- 内容：包含性能测试工具和脚本

### build（构建）

- 作用：构建系统
- 内容：包含构建规则和配置文件

### cmdline（命令行）

- 作用：命令行解析
- 内容：处理命令行参数和选项

### compiler（编译器）

- 作用：编译器
- 内容：包含代码编译和优化逻辑

### dalvikvm（Dalvik 虚拟机）

- 作用：Dalvik 虚拟机
- 内容：旧版虚拟机实现

### dex2oat（DEX 到 OAT 转换）

- 作用：DEX 到 OAT 转换
- 内容：将 DEX 文件转换为 OAT 文件

### dexdump（DEX 文件转储）

- 作用：DEX 文件转储
- 内容：分析和显示 DEX 文件内容

### dexlayout（DEX 布局）

- 作用：DEX 布局
- 内容：管理 DEX 文件的布局和结构

### dexlist（DEX 列表）

- 作用：DEX 列表
- 内容：管理 DEX 文件列表

### dexoptanalyzer（DEX 优化分析）

- 作用：DEX 优化分析
- 内容：分析 DEX 优化过程

### disassembler（反汇编器）

- 作用：反汇编器
- 内容：将二进制代码转换为可读格式

### dt_fd_forward（数据传输转发）

- 作用：数据传输转发
- 内容：处理数据传输和转发

### imgdiag（镜像诊断）

- 作用：镜像诊断
- 内容：分析和诊断系统镜像

### libartbase（ART 基础库）

- 作用：ART 基础库
- 内容：提供基础功能和工具

### libartimagevalues（ART 图像值）

- 作用：ART 图像值
- 内容：管理图像相关的值

### libartpalette（ART 调色板）

- 作用：ART 调色板
- 内容：管理颜色和调色板

### libdexfile（DEX 文件库）

- 作用：DEX 文件库
- 内容：处理 DEX 文件的读写和解析

### libelffile（ELF 文件库）

- 作用：ELF 文件库
- 内容：处理 ELF 文件的读写和解析

### libnativebridge（本地桥接）

- 作用：本地桥接
- 内容：连接 Java 和本地代码

### libnativeloader（本地加载器）

- 作用：本地加载器
- 内容：加载本地库

### libprofile（性能分析）

- 作用：性能分析
- 内容：收集和分析性能数据

### oatdump（OAT 文件转储）

- 作用：OAT 文件转储
- 内容：分析和显示 OAT 文件内容

### openjdkjvm（OpenJDK 虚拟机）

- 作用：提供 OpenJDK 虚拟机的核心实现
- 内容：
  - 实现 OpenJDK 的虚拟机接口
  - 提供与 Java 虚拟机交互的基础功能
  - 支持 Android 系统中 OpenJDK 标准的兼容性

### openjdkjvmti（OpenJDK JVM 工具接口）

- 作用：提供 OpenJDK JVM 工具接口（JVMTI）的实现
- 内容：
  - 实现 JVMTI v1.2 接口的部分功能
  - 提供调试和监控代理接口
  - 支持通过代理修改程序运行状态
  - 依赖 libart-compiler、libart-dexlayout 等组件

### perfetto_hprof（性能分析 HPROF）

- 作用：性能分析 HPROF
- 内容：提供 HPROF 性能分析功能

### profman（性能管理）

- 作用：性能管理
- 内容：管理性能分析任务的工具

### runtime（运行时环境）

- 作用：运行时环境
- 内容：ART 运行时环境的核心实现

### sigchainlib（信号链库）

- 作用：信号链库
- 内容：处理信号链的库

### simulator（模拟器）

- 作用：模拟器
- 内容：提供 ART 模拟器功能

### tool（工具）

- 作用：工具脚本
- 内容：包含各种构建和调试工具

## bionic（C/C++运行时库）

- 作用：提供系统级功能支持
- 内容：Android的C/C++运行时库

### apex（Android Package Extension安卓扩展包程序）

- 作用：支持 APEX（Android Package Extension）模块化更新。
- 内容：
  - 包含与 APEX 相关的构建规则和配置。
  - 用于在运行时动态加载和更新系统组件（如 libc、libm 等），实现“热更新”功能。
  - 支持 OTA 升级中对核心库的独立更新。

### benchmarks（基准测试代码）

- 作用：性能基准测试代码。
- 内容：
  - 包含对 libc、libm、libstdc++ 等库的性能测试脚本。
  - 用于评估函数执行效率（如 memcpy 的速度）。
  - 帮助优化底层库的实现。

### build（构建）

- 作用：构建系统配置。
- 内容：
  - 包含 Android.mk 和 CleanSpec.mk 文件。
  - 定义了如何编译 bionic 中的各个模块（如 libc、libm）。
  - 指定依赖关系、编译选项和输出路径。

### docs（文档）

- 作用：文档存放目录。
- 内容：
  - 存放 API 使用说明、设计文档、开发指南等。
  - 提供开发者了解 bionic 架构和接口的参考资料。

### libc（标准C库）

- 作用：标准 C 库（C Standard Library）。
- 内容：
  - 提供基本的函数结构，包括：
    - 字符串操作：strcpy, strlen
    - 内存管理：malloc, free
    - 文件 I/O：fopen, fclose
    - 数学运算：sqrt, sin
  - 是所有原生代码的基础库，支撑 NDK 兼容性。

### libdl（动态链接库加载库）

- 作用：动态链接库加载库。
- 内容：
  - 实现 POSIX 动态链接接口，如：
    - dlopen：打开共享库
    - dlsym：获取符号地址
    - dlclose：关闭共享库
  - 用于运行时加载 .so 文件，支持插件化架构。

### libfdtrack（文件描述符跟踪工具）

- 内容：
  - 用于监控和调试文件描述符的使用情况。
  - 在调试内存泄漏或资源未释放问题时非常有用。
  - 可以记录每个文件描述符的创建和关闭过程。

### libm（数学库Math Library）

- 内容：
  - 提供数学函数支持，包括：
    - 三角函数：sin, cos, tan
    - 指数与对数：exp, log, pow
    - 随机数生成：rand
  - 为科学计算和图形处理提供基础支持。

### libstdc++（C++ 标准库，C++ Standard Library）

- 内容：
  - 实现 STL（Standard Template Library）中的容器、算法等，如：
    - 容器：vector, map, list
    - 算法：sort, find
    - 输入输出流：iostream
  - 支持 C++ 编程语言在 Android 平台上的使用。

### linker（动态链接器Dynamic Linker）

- 内容：
  - 负责在程序启动时解析并加载依赖的 .so 文件。
  - 是 Android 系统中 .so 文件加载的关键组件。
  - 支持符号重定位、延迟绑定等功能。

### tests（单元测试）

- 内容：
  - 包含对 libc、libm、libstdc++ 等库的测试用例。
  - 用于验证每个函数的功能正确性和边界条件。
  - 自动化测试框架的一部分。

### tools（开发工具集合）

- 内容：
  - 包含辅助脚本、调试工具、构建工具等。
  - 例如：生成符号表、分析二进制文件等。

### .clang-format（代码格式化配置文件）

- 内容：
  - 定义了代码风格规范（如缩进、空格、换行等）。
  - 用于统一团队代码风格，确保可读性。

###  android-changes-for-ndk-developers.md（NDK 开发者变更说明）

- 内容：
  - 列出每次版本更新中对 NDK 的影响。
  - 帮助开发者了解新特性、API 变更和兼容性问题。

### CleanSpec.mk（清理规则文件）

- 内容：
  - 指定哪些文件在清理时需要删除。
  - 用于 make clean 或 make distclean 命令。

### CPPLINT.cfg（C++ 代码检查配置文件）

- 内容：
  - 定义了 cpplint 工具的检查规则。
  - 用于静态代码分析，发现潜在问题（如命名不规范、注释缺失等）。

### OWNERS（负责人列表）

- 内容：
  - 列出负责维护 bionic 模块的开发者。
  - 便于问题追踪和代码审查。

### PREUPLOAD.cfg（预上传检查配置）

- 内容：
  - 定义了提交代码前的检查规则。
  - 例如：是否通过格式化检查、是否有未解决的警告等。

## bootable（Android启动过程中使用的可执行程序和工具）

bootable 目录包含 Android 启动过程中使用的可执行程序和工具，主要包括：

- Bootloader：引导程序，负责加载内核。
- Recovery：恢复模式，用于系统更新、修复等操作。
- Fastboot：刷机模式，允许通过 USB 与 PC 通信进行固件更新。
- 其他辅助工具：如加密、验证、安装脚本等。

这些组件共同构成了 Android 的“启动链”（Boot Chain），确保设备能够正常启动并进入操作系统。

### recovery（恢复模式）

- 内容：
  - 提供一个独立于主系统的环境，用于：
    - 安装 OTA 更新
    - 清除数据（wipe）
    - 重启设备
    - 备份/恢复系统

#### applypatch（应用OTA补丁文件）

- 内容：
  - 解析 .patch 文件格式。
  - 执行增量更新逻辑（如 bzip2 压缩、差分算法）。
  - 将补丁应用到目标分区。

#### bootloader_message（存储 bootloader 信息）

- 内容：
  - 存放启动时的提示信息或状态标志。
  - 可被 recovery 或 fastboot 读取，用于判断当前状态。

#### edify（解析和执行OTA升级脚本）

- 内容：
  - 支持 .img 和 .zip 格式的升级包。
  - 解析 updater-script 中的命令（如 package_extract_file, mount, set_perm）。
  - 是 OTA 更新流程的核心引擎。

#### etc（配置文件）

- 内容：
  - 存放 recovery 的默认设置，如语言、主题、网络参数等。
  - 可被 recovery 在启动时读取。

#### fastboot（Fastboot模式）

- 内容：
  - 实现与 PC 的 USB 通信协议。
  - 支持命令如 flash, erase, reboot, getvar。
  - 允许用户通过 fastboot 工具刷入新固件。

#### fonts（字体）

- 内容：
  - 存放 recovery 界面中使用的字体文件（.ttf）。
  - 支持多语言显示。

#### fuse_sideload（USB传输文件）

- 内容：
  - 实现类似 “ADB Sideload” 的功能。
  - 允许在 recovery 模式下直接从 PC 传输 OTA 包。

#### install（安装）

- 内容：
  - 负责将 OTA 包中的文件解压并写入对应分区。
  - 包括校验、权限设置、符号链接创建等步骤。

#### minui（最小化用户界面）

- 内容：
  - 实现 recovery 的图形界面。
  - 使用 OpenGL ES 绘制菜单、按钮、进度条等。
  - 支持触摸屏和按键输入。

#### otautil（OTA工具库）

- 内容：
  - 提供通用的 OTA 操作函数，如：
    - 文件校验（MD5, SHA1）
    - 分区挂载
    - 数据写入
  - 被 applypatch 和 install 调用。

#### recovery_ui（UI控制逻辑）

- 内容：
  - 定义菜单结构、选项处理、动画效果。
  - 处理用户交互事件（如选择、确认）。

#### recovery_utils（通用工具）

- 内容：
  - 提供日志记录、字符串处理、文件操作等基础功能。
  - 被多个模块共享使用。

#### res-hdpi, res-mdpi, res-xhdpi, res-xxhdpi, res-xxxhdpi（不同分辨率资源文件）

- 内容：
  - 存放图标、背景图、按钮样式等。
  - 根据屏幕密度自动选择合适的资源。

#### uncrypt（解密工具）

- 内容：
  - 支持对加密的 OTA 包进行解密。
  - 使用 AES 等算法还原原始数据。

#### update_verifier（更新包验证器）

- 内容：
  - 校验 OTA 包的完整性、签名合法性。
  - 防止恶意软件或损坏的包被安装。

#### updater（更新主程序）

- 内容：
  - 解析并执行 updater-script。
  - 协调各个模块完成更新任务。

#### updater_sample（示例更新脚本）

- 内容：
  - 提供一个标准的 updater-script 模板。
  - 用于开发者参考如何编写 OTA 更新包。

## bsp（板级支持包）

主要职责：

- 硬件初始化：如 CPU、内存、时钟、电源管理等。
- 设备驱动：提供对 GPIO、I2C、SPI、UART 等外设的支持。
- Bootloader 配置：定义引导程序的行为。
- 内核参数设置：为 Linux 内核传递启动参数。
- 厂商定制功能：实现 OEM 特有的功能（如指纹识别、摄像头优化）。

### bootloader（引导程序）

- 实现第一阶段（Stage 1）和第二阶段（Stage 2）的 bootloader。
- 负责加载内核镜像（zImage 或 kernel.img）并跳转执行。
- 支持多分区启动、安全验证、快速重启等功能。
- 通常使用汇编语言和 C 语言编写，直接操作硬件寄存器。

### build（构建系统配置）

- 包含 Android.mk 文件，定义如何编译 bsp 中的模块。
- 指定源码路径、依赖关系、输出文件名等。
- 可能还包含自定义的构建脚本或规则。

### device（具体设备的定制化代码）

- 每个设备型号可能有一个独立的子目录（如 j517c_sp9832e, j527b_sp9863a）。
- 包含设备特有的配置文件、驱动、初始化脚本。
- 例如：
  - board-config.mk：定义设备特性（如屏幕分辨率、摄像头数量）。
  - init.rc：系统启动脚本。
  - device.mk：设备构建规则。

### kernel（Linux内核相关配置）

- 存放内核启动参数（cmdline）、设备树（Device Tree）文件（.dts）、内核补丁等。
- 定义了内核如何与硬件交互。
- 例如：
  - arch/arm/boot/dts/sprd-xxx.dts：描述硬件拓扑结构。
  - kernel_config：内核编译选项。

### modules（可加载内核模块）

- 包含 .ko 文件（Kernel Object），即动态加载的驱动程序。

- 例如：

  - sprd-camera.ko：摄像头驱动

  - sprd-gpio.ko：GPIO 控制器驱动

- 这些模块在系统启动后由 insmod 命令加载。

### out（编译输出目录）

- 存放编译生成的二进制文件（如 boot.img, recovery.img, kernel.img）。
- 是构建过程的中间产物，通常不包含在源码仓库中。
- 在开发过程中，此目录会被自动清理和重建。

### prebuilt（预编译的二进制文件）

- 包含第三方库、工具链、固件等已编译好的文件。
- 例如：
  - libprop.so：属性服务库
  - fastboot.exe：Windows 平台的 fastboot 工具
- 避免重复编译，提高构建效率。

### toolchain（交叉编译工具链）

- 包含用于编译 ARM 架构代码的 GCC、Clang 等工具。
- 例如：
  - arm-linux-androideabi-gcc
  - arm-linux-androideabi-ld
- 用于在 x86 主机上编译 ARM 目标代码。

### tools（开发工具集合）

- 包含调试脚本、日志分析工具、烧录工具等。
- 例如：
  - flash_tool.py：用于通过 USB 烧录固件。
  - logcat_filter.sh：过滤 logcat 输出。

## build（构建）

- 构建规则定义：通过 Android.mk 和 Android.bp 文件描述模块的编译方式。
- 工具链管理：提供交叉编译所需的工具（如 GCC、Clang）。
- 目标平台配置：支持多架构（ARM、x86）、多版本（AOSP、OEM 定制）的构建。
- 自动化脚本：实现一键构建、清理、测试等操作。

### blueprint（Blueprint 构建系统的核心实现）

- Blueprint 是 Android 新一代构建系统的基础，取代传统的 Makefile。
- 使用 .bp 文件（如 Android.bp）定义模块的构建规则。
- 支持更复杂的依赖关系、变量替换和函数调用。
- 包含解析器、生成器、优化器等组件。

### core（构建系统核心逻辑）

- 实现构建流程的主控逻辑。
- 包括任务调度、依赖分析、并行编译等功能。
- 处理 Android.mk 和 Android.bp 的解析与执行。
- 提供全局配置（如默认编译选项、路径设置）。

### make（传统 Makefile 构建系统）

- 包含所有 .mk 文件的模板和规则。
- 如 BuildConfig.mk、BoardConfig.mk、ProductConfig.mk 等。
- 定义了如何编译 Java、C/C++、资源文件等。
- 是旧版 AOSP 构建系统的核心。

#### common(通用构建规则与工具)

1. core.mk：通用核心构建规则
2. json.mk：提供对JSON数据处理的支持
3. math.mk：数学运算函数
4. strings.mk：字符串处理函数

### soong（Soong 构建系统）

- Soong 是 Google 推出的新一代构建系统，基于 Go 语言开发。
- 负责解析 Android.bp 文件，并将其转换为可执行的构建指令。
- 支持更高效的依赖分析和增量编译。
- 是当前 AOSP 默认构建系统。

### target（目标平台相关配置）

- 包含针对不同设备的构建规则。
- 如 product、board、device 的特定配置。
- 例如：
  - target/product/full.mk：完整产品构建规则
  - target/board/sprd.mk：展锐平台板级配置

### tools（构建工具集合）

- 包含用于构建过程的辅助工具。
- 例如：
  - m：简化版 make 命令
  - mm：仅构建当前目录
  - mma：仅构建当前目录及其子目录
  - mka：并行构建
  - mmp：并行构建指定模块
- 还包括日志分析、性能监控等工具。

## compatibility（兼容性测试套件）

- 确保所有基于 Android 的设备在功能、性能和安全方面保持一致。
- 防止厂商过度定制导致应用无法正常运行。
- 支持 Google Play 服务的兼容性验证。

### cdd(Compatibility Definition Document（兼容性定义文档）)

- 这是 Android 官方发布的兼容性规范文档，分为多个章节。
- 每个子目录对应一个主题，详细描述了设备必须满足的要求。

#### 1_introduction(引言部分)

- 介绍 CDD 的目的、范围和使用方法。
- 解释如何阅读和理解后续章节。

#### 2_device-types(设备类型定义)

- 定义了不同类型的 Android 设备（如手机、平板、手表、电视）。
- 规定了每种设备的基本硬件配置要求（如屏幕尺寸、分辨率、传感器）。

#### 3_software（软件兼容性要求）

- 要求设备必须预装哪些系统组件（如 Settings, Phone, Camera）。
- 定义 API 接口的行为规范（如 ActivityManager, PackageManager）。
- 确保第三方应用可以正常调用系统服务。

#### 4_application-packaging（应用打包规范）

- 规定 APK 文件的格式、签名、权限声明等。
- 要求所有应用必须通过 AAPT 工具进行构建。
- 支持多语言、多分辨率资源的正确加载。

#### 5_multimedia（多媒体兼容性）

- 定义音频、视频编解码器的支持要求（如 H.264, AAC, MP3）。
- 规范摄像头的分辨率、帧率、对焦模式等。
- 确保媒体播放器能够播放主流格式。

#### 6_dev-tools-and-options（开发者工具与选项）

- 要求设备必须支持调试模式（如 USB Debugging）。
- 提供 ADB、Fastboot 等工具的访问权限。
- 支持日志记录（logcat）、性能监控等功能。

#### 7_hardware-compatibility（硬件兼容性要求）

- 定义传感器（如加速度计、陀螺仪、指南针）的精度和响应时间。
- 规范 GPS、Wi-Fi、蓝牙等无线模块的性能指标。
- 要求设备必须支持特定的硬件接口（如 USB OTG、HDMI）。

#### 8_performance-and-power（性能与功耗要求）

- 规定设备的启动时间、应用响应速度等性能指标。
- 要求电池续航能力达到一定标准。
- 支持省电模式、后台限制等功能。

#### 9_security-model（安全模型规范）

- 定义权限管理机制（如 Manifest.permission）。
- 要求设备必须支持加密存储（如 FileProvider）。
- 规范用户数据保护策略（如隐私设置、应用隔离）。

#### 10_software-compatibility-testing（软件兼容性测试流程）

- 描述如何执行 CTS 测试。
- 提供测试用例的设计原则。
- 要求设备必须通过全部测试才能获得 Google 认证。

#### 11_updatable-software（可更新软件规范）

- 要求设备支持 OTA 更新。
- 定义更新包的格式、校验方式、安装流程。
- 支持增量更新、回滚机制。

#### 12_document-changelog（文档变更日志）

- 记录每次 CDD 版本更新的内容。
- 帮助开发者了解新版本的变化。

#### 13_contact-us（联系信息）

- 提供 Google 团队的联系方式。
- 用于提交问题、反馈或申请认证。

#### source（源码生成脚本）

- 包含用于生成 CDD 文档的脚本。
- 如 cdd_gen.sh：生成 HTML 或 PDF 格式的文档。
- make_cdd.py：Python 脚本，用于解析 Markdown 并输出最终格式。

## framework（框架）

### av（Audio音频/Video视频）

它包含 Android 系统中**音频、视频的底层框架、编码器、解码器、播放引擎、录音、摄像头视频捕获**等核心组件的实现代码。

### base（基本）

#### packages（包）

##### SystemUI（系统UI）

###### src/com/android/keyguard（锁屏）

1. CarrierText.java（运营商文本）

   1. **主要作用**：这个类负责在锁屏界面显示**运营商名称**、**SIM卡状态**和**飞行模式**等信息。
   2. **核心功能**
      1. 显示运营商信息
         - 显示当前 SIM 卡的运营商名称
         - 多 SIM 卡时显示多个运营商，用分隔符隔开
         - 示例显示：`中国移动 | 中国电信`

   2. **处理特殊状态**

      ```java
      // 显示配置项
      mShowAirplaneMode = a.getBoolean(R.styleable.CarrierText_showAirplaneMode, false);
      mShowMissingSim = a.getBoolean(R.styleable.CarrierText_showMissingSim, false);
      ```

      - **飞行模式**：当启用飞行模式时显示相应提示
      - **无 SIM 卡**：没有插入 SIM 卡时的提示信息
      - **SIM 卡错误**：SIM 卡异常状态

   3. 跑马灯效果（Marquee）

      ```java
      setSelected(mShouldMarquee); // Allow marquee to work.
      ```

      - 当运营商名称过长时，会自动滚动显示
      - 只有在设备唤醒时才启用跑马灯效果

   4. **在锁屏界面的位置**

      ```
      ┌─────────────────────────────────┐
      │         时间 12:30              │
      │         日期 2024年1月15日      │
      │                                 │
      │    [锁屏图案/密码/指纹区域]       │
      │                                 │
      │    ↓ 通常在这里显示 ↓            │
      │    中国移动 | 中国联通           │ ← CarrierText
      │                                 │
      │    紧急呼叫             相机    │
      └─────────────────────────────────┘
      ```

   5. 关键组件解析

      1. ### **CarrierTextController**

         ```java
         private CarrierTextController mCarrierTextController;
         ```

         - 核心控制器，负责监听和计算要显示的文本
         - 处理 SIM 卡状态变化、飞行模式变化等
         - 通过回调更新显示内容

      2. ### **CarrierTextCallback**

         ```java
         private CarrierTextController.CarrierTextCallback mCarrierTextCallback
         ```

         回调接口，处理：

         1. `updateCarrierInfo()` - 更新运营商文本
         2. `startedGoingToSleep()` - 设备休眠时停止跑马灯
         3. `finishedWakingUp()` - 设备唤醒时启动跑马灯

      3. ### **CarrierTextTransformationMethod**

         ```java
         private class CarrierTextTransformationMethod extends SingleLineTransformationMethod
         ```

         自定义文本转换方法：

         - 确保文本单行显示
         - 可选全部大写转换（通过 `allCaps` 属性控制）

2. AdminSecondaryLockScreenController.java（**次级锁屏控制器**）

   1. 核心功能

      实现 **企业级次级锁屏（Secondary Lockscreen）**，允许设备管理员在系统锁屏之上叠加一个额外的安全层。

   2. 工作流程

      ```text
      标准解锁流程：
      用户 → [系统锁屏] → [进入系统]
      
      企业级解锁流程：
      用户 → [系统锁屏] → [次级企业锁屏] → [进入系统]
      ```

   3. 关键组件解析

      1. ### **ServiceConnection（服务连接）**

         ```java
         private final ServiceConnection mConnection = new ServiceConnection()
         ```

         - 绑定到设备管理员提供的 `IKeyguardClient` 服务
         - 企业MDM应用通过这个服务提供自定义锁屏界面

      2. ### **IKeyguardCallback（回调接口）**

         ```java
         private final IKeyguardCallback mCallback = new IKeyguardCallback.Stub()
         ```

         接收来自企业锁屏服务的事件：

         - `onDismiss()` - 企业锁屏验证通过
         - `onRemoteContentReady()` - 远程内容（锁屏界面）准备就绪

      3. ### **SurfaceView 集成**

         ```java
         private class AdminSecurityView extends SurfaceView
         ```

         - 使用 `SurfaceView` 显示远程锁屏内容
         - 通过 `SurfaceControlViewHost` 跨进程渲染企业锁屏UI

   4. 核心方法

      1. ### `show(Intent serviceIntent)`

         ```java
         public void show(Intent serviceIntent) {
             mContext.bindService(serviceIntent, mConnection, Context.BIND_AUTO_CREATE);
             mParent.addView(mView);
         }
         ```

         启动企业锁屏：

         1. 绑定到企业MDM服务
         2. 将 `SurfaceView` 添加到视图层级

      2. ### `hide()`

         ```java
         public void hide() {
             mParent.removeView(mView);
             mContext.unbindService(mConnection);
         }
         ```

         关闭企业锁屏，清理资源

      3. ### `dismiss(int userId)`

         ```java
         private void dismiss(int userId) {
             hide();
             mKeyguardCallback.dismiss(/* securityVerified= */ true, userId,
                     /* bypassSecondaryLockScreen= */true,  SecurityMode.Invalid);
         }
         ```

         企业锁屏验证通过后，通知主锁屏继续解锁流程

###### src/com/android/systemui（系统ui）

1. keyguard
   1. KeyguardViewMediator.java（锁屏视图中介器）
