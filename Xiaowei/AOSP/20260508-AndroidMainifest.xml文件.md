# 一、AndroidMainifest.xml介绍

`AndroidMainifest.xml`文件是Android应用的**核心配置文件**。是每个Android项目**必须存在且不可缺少**的文件。

## AndroidManifest.xml 的核心作用

1. **应用身份标识**：定义应用的包名、版本号、签名信息等唯一标识；
2. **组件注册**：声明应用的所有核心组件（Activity、Service、BroadcastReceiver、ContentProvider），未注册的组件系统无法识别；
3. **权限管理**：声明应用需要的系统权限（如联网、拍照、读写文件）；
4. **配置属性**：指定应用的最小 SDK 版本、启动页、主题、进程名等；
5. **系统交互**：定义应用与系统的交互规则（如隐式意图过滤、服务绑定）。



# 二、AndroidMainifest.xml详解

## 1. 整体结构（以Android16的Launcher模块为例）

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
/*
**
** Copyright 2008, The Android Open Source Project
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
*/
-->
<manifest
    xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.android.launcher3"> <!-- 应用包名（唯一标识） -->
    
    <!-- 1. SDK版本配置（必选） -->
    <uses-sdk android:targetSdkVersion="33" android:minSdkVersion="30"/> <!-- 目标SDK版本，最低30，最高33 -->
    <!--
    Manifest entries specific to Launcher3. This is merged with AndroidManifest-common.xml.
    Refer comments around specific entries on how to extend individual components.
    -->
	
    <!-- 2. 权限声明（按需添加），Launcher中没有 -->
    
    <!-- 3. 应用核心配置（必选） -->
    <application
        android:backupAgent="com.android.launcher3.LauncherBackupAgent" <!-- 声明应用的备份代理类 -->
        android:fullBackupOnly="true" <!-- true:使用自动完整备份,false:使用传统的键值对备份 -->
        android:fullBackupContent="@xml/backupscheme" <!-- 指定一个 XML 配置文件，用来声明哪些文件需要备份、哪些文件不需要备份 -->
        android:hardwareAccelerated="true" <!-- 是否开启硬件加速 -->
        android:debuggable="true"
        android:icon="@drawable/ic_launcher_home"
        android:label="@string/derived_app_name"
        android:theme="@style/AppTheme"
        android:largeHeap="@bool/config_largeHeap" <!-- 是否允许应用请求更大的堆内存（Heap） -->
        android:restoreAnyVersion="true" <!-- 是否允许应用从任意版本的备份数据中回复（必须要与android:allowBackup="true"配合使用，或者再BackupAgent中做好兼容处理 -->
        android:supportsRtl="true" > <!-- 声明应用是否支持从右到左（RTL）的布局方向，主要用于阿拉伯语、希伯来语等语言 -->

        <!--
        Main launcher activity. When extending only change the name, and keep all the
        attributes and intent filters the same
        -->
    	<!-- 4. Activity注册（核心组件） -->
        <activity
            android:name="com.android.launcher3.Launcher"
            android:launchMode="singleTask"
            android:clearTaskOnLaunch="true"
            android:stateNotNeeded="true" <!-- 是否需要保存状态 -->
            android:windowSoftInputMode="adjustPan"
            android:screenOrientation="unspecified"
            android:configChanges="keyboard|keyboardHidden|mcc|mnc|navigation|orientation|screenSize|screenLayout|smallestScreenSize"
            android:resizeableActivity="true"
            android:resumeWhilePausing="true"
            android:taskAffinity=""
            android:exported="true"
            android:enabled="true">
    		<!-- 启动页配置：应用打开时第一个启动的Activity -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <action android:name="android.intent.action.SHOW_WORK_APPS" />
                <action android:name="android.intent.action.ALL_APPS" />
                <category android:name="android.intent.category.HOME" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.MONKEY"/>
                <category android:name="android.intent.category.LAUNCHER_APP" />
            </intent-filter>
            <meta-data
                android:name="com.android.launcher3.grid.control"
                android:value="${packageName}.grid_control" />
        </activity>

    </application>
</manifest>
```

## 2. 核心标签逐行详解（按重要度排序）

### 2.1 根标签：`<manifest>`（必选）

| 属性                | 作用                                                         |
| ------------------- | ------------------------------------------------------------ |
| package             | 应用的唯一包名，作为应用的全局标识，发布后不可修改           |
| android:versionCode | 版本号（整数，如 1、2、3），用于应用商店判断更新（数值越大版本越高） |
| android:versionName | 版本名称（字符串，如 1.0、1.0.1），给用户看的版本号          |
| xmlns:android       | Android 命名空间（固定值），必须包含，否则无法识别 Android 属性 |

### 2.2 SDK版本配置：`<uses-sdk>`（必选）

| 属性              | 作用                                                         |
| ----------------- | ------------------------------------------------------------ |
| minSdkVersion     | 应用兼容的最小 Android 版本（如 21=Android 5.0），低于该版本的设备无法安装 |
| targetSdkVersion  | 应用适配的目标版本（如 34=Android 14），系统会按该版本的规则运行应用 |
| compileSdkVersion | 编译应用的 SDK 版本（需与 Android Studio 的 SDK 版本一致）   |

> 核心规则：minSdkVersion ≤ targetSdkVersion ≤ compileSdkVersion

### 2.3 权限声明：`<uses-permission>`（按需）

Android 权限分为「普通权限」和「危险权限」：

- **普通权限**：无需用户授权（如联网`INTERNET`、震动`VIBRATE`）；
- **危险权限**：需用户手动授权（如读写文件、拍照、定位）。

> 注：Android 6.0（API 23）+ 危险权限需在代码中动态申请，仅在 Manifest 声明无效。

### 2.4 应用核心配置：`<application>`（必选）

所有组件（Activity/Service 等）都必须放在该标签内，核心属性：

| 属性                | 作用                                    |
| ------------------- | --------------------------------------- |
| android:icon        | 应用图标                                |
| android:lable       | 应用名称                                |
| android:theme       | 应用全局主题                            |
| android:allowBackup | 是否允许系统备份应用数据，建议设为 true |
| android:debuggable  | 是否为调试模式，发布版必须设为 false    |

#### 2.4.1 Activity 注册：`<activity>`（核心组件）

Activity 是 Android 的「界面载体」，**每个 Activity 必须在 Manifest 中注册**，否则启动时崩溃。

| 属性                      | 作用                                                         |
| ------------------------- | ------------------------------------------------------------ |
| android:name              | Activity 类名（相对路径：`.MainActivity` = `com.example.myapp.MainActivity`） |
| android:exported          | Android 12 + 必选，是否允许外部应用启动该 Activity：✅ 启动页设为`true`（桌面能打开）✅ 其他 Activity 设为`false`（安全） |
| android:screenOrientation | 屏幕方向（`portrait`竖屏 /`landscape`横屏）                  |
| android:launchMode        | 启动模式（`standard`/`singleTop`/`singleTask`/`singleInstance`），控制 Activity 实例创建规则 |

##### 启动页核心配置：`<intent-filter>`

```xml
<intent-filter>
    <action android:name="android.intent.action.MAIN" /> <!-- 应用入口 -->
    <category android:name="android.intent.category.LAUNCHER" /> <!-- 桌面图标可见 -->
</intent-filter>
```

- 只有包含该过滤器的 Activity 才会成为「启动页」，应用打开时第一个启动；
- 如果移除`LAUNCHER`，应用不会显示在桌面（如后台服务类应用）。

#### 2.4.2 其他组件注册

##### Service（后台服务）

```xml
<service 
    android:name=".MyService" 
    android:exported="false"/> <!-- 不允许外部应用调用 -->
```

- 用于后台执行耗时任务（如下载、播放音乐），无界面；
- `exported="false"` 提升安全性，避免外部应用调用。

##### BroadcastReceiver（广播接收器）

```xml
<receiver 
    android:name=".MyReceiver" 
    android:exported="false">
    <!-- 接收系统广播（如开机完成） -->
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

- 用于接收系统 / 应用广播（如开机、网络变化）。

##### ContentProvider（内容提供者）

```xml
<provider
    android:name=".MyProvider"
    android:authorities="com.example.myapp.provider" <!-- 唯一标识 -->
    android:exported="false"/>
```

- 用于不同应用间共享数据（如通讯录、相册）。



# 三、注意事项

## 1.包名与类名规则

- `android:name` 属性支持「相对路径」（`.MainActivity`）和「绝对路径」（`com.example.myapp.MainActivity`），推荐用相对路径；
- 包名必须符合 Java 命名规范（小写字母 + 点分隔），如`com.company.app`，不能包含特殊字符。

## 2.Android12+强制要求

- `Activity/Service/Receiver` 必须显式声明`android:exported`属性（true/false），否则编译报错；
- 启动页的`exported`必须设为`true`，否则应用无法从桌面启动。

## 3.权限声明误区

- 危险权限仅在 Manifest 声明无效，需在代码中动态申请（如读写文件）；
- Android 10+ 读写文件推荐使用「作用域存储」，无需申请`WRITE_EXTERNAL_STORAGE`。

## 4.版本号规则

- `versionCode` 必须是整数，每次发布更新需递增（如 1→2→3）；
- `versionName` 可自定义格式（如 1.0、1.0.1、2.0-beta），无强制规则。

## 5.资源引用规则

- 引用资源（图标、主题、字符串）必须用`@`开头：
  - `@mipmap/ic_launcher`：引用 mipmap 目录下的图标；
  - `@string/app_name`：引用 strings.xml 中的字符串；
  - `@style/Theme.MyApp`：引用 styles.xml 中的主题。
