# 命令

```bash
adb shell dumpsys window | findstr mCurrentFocus
```

- **`dumpsys window`**：转储WindowManager服务信息
- **`findstr mCurrentFocus`**：Windows下过滤包含`mCurrentFocus`的关键行

# 输出示例

![image-20260407163625163](文档图片存放路径/image-20260407163625163.png)

```bash
mCurrentFocus=Window{5e60f6 u0 com.android.camera2/com.android.camera.CameraLauncher}, [type=1, isChildWindow=false]-[Surface(name=*Title#794)/@0xddd2fdf]
```

- `5e60f6`：uid
- `u0`：用户id
- `com.android.camera2`：包名
- `com.android.camera.CameraLauncher`：Activity全类名