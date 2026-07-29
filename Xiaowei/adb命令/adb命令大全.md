# 一、设备管理

## 一、‌查看连接设备‌

```
adb devices（显示设备列表及状态）
adb get-serialno（获取设备序列号）
adb devices -l（显示详细设备信息）
```

## 二、‌服务控制‌

```
adb kill-server / adb start-server（重启ADB服务）
adb root（获取root权限）
```

# 二、应用管理

## 一、‌安装与卸载

```
adb install <文件绝对路径>
adb install -r -d xxx.apk（覆盖安装并允许降级）
adb uninstall com.example.app（卸载应用）
```



## 二、‌包名查询

```
adb shell dumpsys window | findstr mCurrentFocus（查找当前前台应用包名）
adb shell pm list packages（列出已安装应用包名）
adb shell pm list packages -3（列出第三方应用）
adb shell pm list packages -s（列出系统应用）
```



## 三、运行与关停

```
adb shell am force-stop <包名>（强行停止软件）
```

### 冷启动

```
adb shell am start -W -S -n com.example.app/.MainActivity（冷启动）
```

> -W：打印启动耗时（TotalTime/ThisTime）。
> -S：强制停止应用以确保冷启动环境。

### 热启动

```
adb shell input keyevent 3（模拟Home键退出到后台）
adb shell am start -W -n com.example.app/.MainActivity
```

### 多次测试取平均值‌

```
adb shell am start -S -R 10 -W com.example.app/.MainActivity
```

> -R 10：重复测试10次。

# 三、文件操作

## 一、‌文件传输

### （一）复制电脑文件到手机‌

```bash
# 格式
adb push <文件地址> <手机目录>

# 例子
adb push D:\test\video\1.mp4 /storage/emulated/0/
# 例子
adb push local.txt /sdcard/

# 导出Log
adb pull /storage/emulated/0/mtklog/ D:\LOG\1
```



### （二）导出手机文件到电脑

```bash
# 格式
adb pull <手机文件地址> <电脑保存位置>

# 例子
adb pull /storage/emulated/0/BatteryLog.csv D:\test\Battery
# 例子
adb pull /sdcard/file.txt ~/Desktop/
```

## 二、‌目录管理‌

```bash
# 删除文件
adb shell rm /sdcard/file.txt

# 创建目录
adb shell mkdir /sdcard/new_folder
```

# 四、系统调试

## 一、系统启停

```bash
# 重启到edl模式
adb reboot edl
# 重启到系统
adb reboot
```

### 从Recovery模式重启到系统‌：

```bash
adb reboot
adb reboot system
```

###  从Bootloader/Fastboot模式重启到系统‌：


   需确保设备已通过 fastboot devices 正确识别

```bash
adb reboot bootloader（重启到fastboot模式）
adb reboot recovery（重启到recovery模式）
adb -s <设备序列号> reboot（多设备重启 -s 指定序列号）
adb shell reboot -p（强制重启）
adb shell input keyevent KEYCODE_POWER（模拟电源键长按（需root权限））
```

## 二、‌日志查看‌

```bash
# 输出日志到文件
adb logcat > log.txt
# 过滤关键日志
adb logcat | findstr "error"
# 过滤关键事件
adb logcat -b all -v threadtime | grep -E 'CRASH|ANR'
# 带时间戳的AP日志
adb logcat -b main -v time > main_log.txt
# 带时间戳的Kernel日志
adb logcat -b kernel -v time > kernel_log.txt
```

> 通过-v time参数确保日志包含精确到毫秒的时间戳

## 三、‌Activity管理‌

```bash
# 使用grep（Linux/Mac）或findstr（Windows）过滤目标应用
adb shell pm list packages | grep "关键词" 

# 直接查看APK路径与包名的映射关系
adb shell pm list packages -f

# 通过dumpsys命令查找（获取主Activity）
# 输出中标记为category.LAUNCHER的Activity即为入口
adb shell dumpsys package 包名 | grep -i "launcher"

# 查看当前Activity（Linux/MAC）
adb shell dumpsys activity | grep "mFocusedActivity"

# 获取当前前台Activity（Win平台）
adb shell dumpsys window | findstr mCurrentFocus

# 通过APK解析获取入口Activity
# 需提前安装Android SDK的aapt工具
aapt dump badging app.apk | findstr "launchable-activity"

# 启动指定Activity
# -n 后需接完整组件路径，格式为 “包名/Activity” 全类名
# 使用grep（Linux/Mac）或findstr（Windows）过滤目标应用
adb shell am start -n com.example/.MainActivity

# am start 用于启动一个 Activity
# -a android.media.action.STILL_IMAGE_CAMERA 指定要启动相机应用的动作
# adb shell am start -W -n 包名/Activity（带延迟启动）
adb shell am start -a android.media.action.STILL_IMAGE_CAMERA（启动相机）
```

# 五、模拟操作

## 一、‌按键事件‌

```bash
# KEYCODE_HOME（HOME键）
adb shell input keyevent 3

# 返回键
adb shell input keyevent 4

# 增加音量
adb shell input keyevent 24 

# 降低音量
adb shell input keyevent 25 

# 电源键
adb shell input keyevent 26

# 拍一张照片（相机界面）
adb shell input keyevent 27

# KEYCODE_MENU（菜单键）
adb shell input keyevent 82

# 播放/暂停
adb shell input keyevent 85

# 下一曲
adb shell input keyevent 88

# 最近任务键
adb shell input keyevent 187

# 熄灭屏幕
adb shell input keyevent 223

# 点亮屏幕
adb shell input keyevent 224
```

## 二、‌触控操作‌

```bash
# 点击坐标
adb shell input tap 500 800

# 滑动屏幕从(300,500)滑动到(800,500)
adb shell input swipe 300 500 800 500

# 坐标相同+时长(ms)
adb shell input swipe 500 500 500 500 2000
```

# 六、系统信息

## 一、‌硬件信息‌

```bash
# 屏幕分辨率
adb shell wm size

# 查看屏幕密度(dpi)
adb shell wm density

# 内存信息
adb shell cat /proc/meminfo

# 查看电池信息
adb shell dumpsys battery

# 查看Android的CPU型号架构等信息
adb shell cat /proc/cpuinfo
```



## 二、‌属性查询‌

```bash
# Android版本
adb shell getprop ro.build.version.release

# 设备型号
adb shell getprop ro.product.model

# 判断手机是user版本还是debug版本
adb shell getprop ro.build.type
```



# 七、高级功能

## 一、‌网络调试‌

```bash
# 启用无线调试
adb tcpip 5555

# 无线连接设备
adb connect 192.168.1.100
```



## 二、‌内存分析‌

```bash
# 应用内存详情
adb shell dumpsys meminfo com.example.app
```

