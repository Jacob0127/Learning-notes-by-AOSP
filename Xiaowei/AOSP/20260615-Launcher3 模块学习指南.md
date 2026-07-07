# Launcher3 模块学习指南

> 项目: C26_Mini_go_EEA (OUKITEL) | 平台: SPRD/UNISOC split build (Android 12+)

---

## 1. 模块位置总览

```
SYS/packages/apps/Launcher3/                          # [核心] AOSP Launcher3 主源码
SYS/vendor/sprd/platform/packages/apps/Launcher3/     # [扩展] SPRD 平台扩展 (UniLauncher3)
SYS/vendor/sprd/ex-interface/packages/apps/Launcher3/ # [接口] SPRD 扩展接口定义
SYS/vendor/sprd/Multi-lang/packages/apps/Launcher3/   # [多语言] 翻译 overlay
SYS/vendor/partner_gms/unisoc_conf/overlay/.../Launcher3/ # [GMS] GMS overlay 配置覆盖
```

**学习时以核心 AOSP 源码为主，SPRD 扩展为辅。**

---

## 2. Launcher.java 架构分析 (3130 行)

### 2.1 类继承链

```
Activity
  └── BaseActivity                    (基础 Activity，配置变化处理)
        └── StatefulActivity<LauncherState>   (引入状态机框架)
              └── Launcher            (默认桌面主入口)
```

### 2.2 实现的接口

| 接口 | 职责 |
|------|------|
| `Callbacks` (→ `BgDataModel.Callbacks`) | 接收 LauncherModel 加载完成后的数据回调 |
| `InvariantDeviceProfile.OnIDPChangeListener` | 设备配置变化 (屏幕密度/尺寸) 监听 |
| `PluginListener<LauncherOverlayPlugin>` | SystemUI 插件 (如 -1 屏 Google Feed) 监听 |

### 2.3 核心成员变量 (按职责分组)

**视图层 (UI):**
| 变量 | 类型 | 说明 |
|------|------|------|
| `mWorkspace` | `Workspace<?>` | **桌面工作区** — 所有图标/Widget 的容器，支持多页滑动 |
| `mDragLayer` | `DragLayer` | **拖拽层** — 最顶层 FrameLayout，管理拖拽动画和浮层 |
| `mHotseat` | `Hotseat` | **底部热座** — 固定在底部的图标栏 (常驻应用) |
| `mAppsView` | `ActivityAllAppsContainerView` | **所有应用列表** — 抽屉式应用列表 |
| `mAllAppsController` | `AllAppsTransitionController` | 桌面↔应用列表切换的动画控制器 |
| `mScrimView` | `ScrimView` | 半透明遮罩 (应用列表/Overview 状态时) |
| `mOverviewPanel` | `View` | Overview 面板 (Recent/多任务) |
| `mDropTargetBar` | `DropTargetBar` | 拖拽目标栏 (删除/卸载区域) |

**控制器层 (Controller):**
| 变量 | 类型 | 说明 |
|------|------|------|
| `mDragController` | `DragController` | 拖拽手势控制器 |
| `mStateManager` | `StateManager<LauncherState>` | **状态机** — 管理 Launcher 所有 UI 状态切换 |
| `mRotationHelper` | `RotationHelper` | 屏幕旋转锁定/解锁 |
| `mFocusHandler` | `ViewGroupFocusHelper` | 键盘焦点导航管理 |
| `mAnimationCoordinator` | `CannedAnimationCoordinator` | 预定义动画协调器 |

**数据层 (Model):**
| 变量 | 类型 | 说明 |
|------|------|------|
| `mModel` | `LauncherModel` | **核心数据模型** — 加载/管理桌面布局数据 |
| `mModelWriter` | `ModelWriter` | 数据写入器 — 增删改桌面项 |
| `mIconCache` | `IconCache` | 图标缓存 |
| `mAppWidgetManager` | `WidgetManagerHelper` | Widget 管理器包装 |
| `mAppWidgetHolder` | `LauncherWidgetHolder` | Widget 宿主 (持有 AppWidgetHost) |
| `mPopupDataProvider` | `PopupDataProvider` | 长按弹出菜单数据 |
| `mWidgetPickerDataProvider` | `WidgetPickerDataProvider` | Widget 选择器数据 |

**SPRD 扩展:**
| 变量 | 类型 | 说明 |
|------|------|------|
| `mUniLauncher3Factory` | `UniLauncher3Factory` | SPRD 统一 Launcher 工厂，注入平台定制行为 |

### 2.4 核心生命周期方法

```
onCreate()
  ├── createStartupLatencyLogger()     # 启动性能统计
  ├── super.onCreate()                 # StatefulActivity 初始化
  ├── LauncherAppState.getInstance()   # 获取全局单例
  ├── mModel = app.getModel()          # 获取数据模型
  ├── initDeviceProfile(idp)           # 初始化设备参数 (行列数/图标大小)
  ├── initDragController()             # 初始化拖拽
  ├── setupViews()                     # 加载布局视图树 ⬅ 关键!
  ├── restoreState()                   # 恢复上次状态
  ├── mModel.addCallbacksAndLoad()     # 注册回调 + 开始加载桌面数据
  ├── setContentView(getRootView())    # 设置根视图
  └── PluginManagerWrapper...          # 注册 Overlay 插件

onStart() → onResume()
  ├── 处理 pending ActivityResult
  ├── 刷新 Widget/图标
  └── 恢复 UI 状态

onNewIntent()
  └── 处理外部 Intent (搜索/Widget 添加等)

onBackPressed()
  └── 按优先级分发: FloatingView → BackHandler → StateManager
```

---

## 3. 核心设计模式: 状态机 (StateManager)

Launcher 最核心的设计是 **状态机模式**，所有 UI 场景都是不同的 `LauncherState`:

```
NORMAL  ←——————→  ALL_APPS       (应用抽屉)
   ↕                    ↕
OVERVIEW                ↕
   ↕              SPRING_LOADED   (拖拽时)
EDIT_MODE                 
   ↕
HINT_STATE               (手势提示)
```

每个 State 定义了:
- 各 View 的可见性 (Hotseat/Workspace/AllApps)
- 各 View 的属性动画目标值 (alpha/translation/scale)
- 页面指示器行为
- 是否可以交互

**关键文件:**
- `LauncherState.java` — 状态基类和标志位
- `StateManager.java` — 状态切换引擎
- `states/` 目录 — 各具体状态实现

---

## 4. 模块目录结构速查

| 目录 | 职责 | 关键类 |
|------|------|--------|
| `statemanager/` | 状态机框架 | `StateManager`, `BaseState`, `StatefulActivity` |
| `states/` | 各 UI 状态实现 | `AllAppsState`, `OverviewState`, `EditModeState` |
| `model/` | 数据模型层 | `LauncherModel` (加载), `ModelWriter` (写入) |
| `model/data/` | 桌面数据项 | `ItemInfo`, `WorkspaceItemInfo`, `FolderInfo`, `LauncherAppWidgetInfo` |
| `dragndrop/` | 拖拽系统 | `DragController`, `DragLayer`, `DragView` |
| `folder/` | 文件夹功能 | `Folder`, `FolderIcon` |
| `allapps/` | 全部应用列表 | `ActivityAllAppsContainerView`, `AllAppsTransitionController` |
| `widget/` | Widget 系统 | `LauncherWidgetHolder`, `WidgetsFullSheet` |
| `popup/` | 长按菜单 | `PopupDataProvider`, `SystemShortcut`, `OptionsPopupView` |
| `touch/` | 触控交互 | `ItemClickHandler`, `ItemLongClickListener`, `AllAppsSwipeController` |
| `accessibility/` | 无障碍 | `LauncherAccessibilityDelegate` |
| `notification/` | 角标通知 | `NotificationListener` |
| `shortcuts/` | Deep Shortcuts | Android 7.1+ |
| `celllayout/` | 网格布局 | `CellLayout`, `CellPosMapper` |
| `config/` | 功能开关 | `FeatureFlags` |
| `util/` | 工具类 | `Utilities`, `SettingsCache`, `SystemUiController` |
| `views/` | 通用视图 | `ScrimView`, `FloatingIconView`, `ActivityContext` |
| `graphics/` | 图形绘制 | Bitmap/Shader |
| `anim/` | 动画工具 | 动画监听器 |
| `icons/` | 图标处理 | `IconCache`, BitmapRenderer |

---

## 5. SPRD 平台扩展层

SPRD 通过 `UniLauncher3Factory` 模式注入平台行为:

```
UniLauncher3Factory (SYS/vendor/sprd/ex-interface/...)
  └── UniLauncher3FactoryImpl (SYS/vendor/sprd/platform/...)
        ├── onLauncherPreCreate()      # onCreate 前拦截
        ├── onLauncherCreated()        # onCreate 后注入
        ├── DatabaseController         # 桌面布局数据库控制
        ├── MultiModeController        # 双屏/多模式支持
        ├── ManagedProfileController   # 工作资料管理
        └── HotseatController          # Hotseat 定制
```

---

## 6. 推荐学习路径

### 第一阶段: 理解生命周期和视图树 (1-2 天)

1. **`Launcher.java:onCreate()`** — 从 L444 开始逐行读，理解初始化顺序
2. **`setupViews()`** — 在 `BaseActivity` 子类中搜索此方法，理解布局层级:
   
   ```
   LauncherRootView
     └── DragLayer (最顶层，处理拖拽)
           ├── Workspace (桌面页，CellLayout 网格)
           ├── Hotseat (底部固定栏)
           ├── AllAppsContainerView (应用抽屉)
           ├── ScrimView (遮罩)
           └── DropTargetBar (删除按钮)
   ```
3. **`LauncherAppState.kt`** — 全局单例，理解 Model/IconCache/IDP 的初始化

### 第二阶段: 理解状态机 (1-2 天)

4. **`LauncherState.java`** — 读 NORMAL/ALL_APPS/OVERVIEW/EDIT_MODE 状态定义
5. **`StateManager.java`** — 理解 `goToState()` 如何驱动 UI 属性动画
6. **`states/AllAppsState.java`** — 挑一个状态深入，看它定义了哪些 View 属性变化
7. **`AllAppsTransitionController.java`** — 理解手势驱动的状态切换

### 第三阶段: 数据模型 (1 天)

8. **`LauncherModel.kt`** — 桌面数据加载流程 (LoaderTask)
9. **`model/data/ItemInfo.java`** — 理解桌面项的数据结构
10. **`ModelWriter.java`** — 理解增删改操作的写入路径

### 第四阶段: 交互系统 (2 天)

11. **`touch/ItemClickHandler.java`** — 点击打开应用
12. **`touch/ItemLongClickListener.java`** — 长按进入编辑模式
13. **`dragndrop/DragController.java`** — 拖拽流程
14. **`folder/Folder.java`** — 文件夹展开/折叠

### 第五阶段: SPRD 扩展 (1 天)

15. **`UniLauncher3Factory.java`** — 理解 SPRD 如何注入定制
16. **`MultiModeController.java`** — 双屏/折叠屏适配

---

## 7. 调试技巧

- `adb shell dumpsys activity com.android.launcher3` — 查看 Launcher 当前状态
- `adb shell settings put global launcher_oncreated 0` — 强制下次冷启动
- Launcher.java 内置了 DEBUG_STRICT_MODE 和崩溃通知 (L496-531)
- `StatsLogManager` 事件可用于追踪用户行为路径