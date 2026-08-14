@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
title ADB Push APK Installer

set "SCRIPT_EXIT_CODE=0"
call :main %*
set "SCRIPT_EXIT_CODE=%errorlevel%"

echo.
echo ========================================
echo 执行结束，按任意键退出
echo ========================================
pause >nul
exit /b %SCRIPT_EXIT_CODE%

:main
echo ========================================
echo Windows ADB Push + Install APK 脚本
echo ========================================
echo.

call :check_adb || exit /b 1
call :check_device || exit /b 1
call :resolve_apk "%~1" || exit /b 1
call :push_and_install || exit /b 1

echo.
echo [成功] APK 已推送并安装完成
exit /b 0

:check_adb
echo [1/4] 检查 ADB...
where adb >nul 2>&1 || (
    echo [错误] 未找到 adb，请先安装 Android SDK Platform Tools
    echo 下载地址: https://developer.android.com/studio/releases/platform-tools
    exit /b 1
)
adb version >nul 2>&1 || (
    echo [错误] adb 无法正常执行，请检查环境变量 PATH
    exit /b 1
)
echo [成功] ADB 可用
echo.
exit /b 0

:check_device
set "DEVICE_FOUND="
echo [2/4] 检查设备连接...
call :probe_device
if not defined DEVICE_FOUND (
    echo [提示] 未检测到设备，尝试重启 ADB 服务...
    adb kill-server >nul 2>&1
    adb start-server >nul 2>&1
    ping -n 3 127.0.0.1 >nul
    call :probe_device
)
if not defined DEVICE_FOUND (
    echo [错误] 未检测到可用设备
    echo 当前设备列表:
    adb devices
    echo.
    echo 请确认:
    echo - 手机已开启 USB 调试
    echo - 已授权当前电脑调试权限
    echo - 连接状态不是 unauthorized/offline
    exit /b 1
)
echo [成功] 已检测到设备
echo.
exit /b 0

:probe_device
for /f "tokens=1,2" %%A in ('adb devices') do (
    if /i "%%B"=="device" set "DEVICE_FOUND=1"
)
exit /b 0

:resolve_apk
echo [3/4] 解析 APK 路径...
set "APK_PATH=%~1"
if not defined APK_PATH set /p "APK_PATH=请输入 APK 完整路径（可拖拽文件到窗口）: "
if not defined APK_PATH (
    echo [错误] 未提供 APK 路径
    exit /b 1
)
if not exist "%APK_PATH%" (
    echo [错误] 文件不存在: "%APK_PATH%"
    exit /b 1
)

for %%F in ("%APK_PATH%") do (
    set "APK_EXT=%%~xF"
    set "APK_NAME=%%~nxF"
)
if /i not "%APK_EXT%"==".apk" (
    echo [错误] 目标文件不是 .apk: "%APK_PATH%"
    exit /b 1
)

set "REMOTE_APK=/data/local/tmp/%APK_NAME%"
echo [成功] APK: "%APK_PATH%"
echo.
exit /b 0

:push_and_install
setlocal EnableDelayedExpansion
call :init_logs

echo [4/4] 推送并安装 APK...
echo [信息] 正在推送到设备: %REMOTE_APK%
adb push "%APK_PATH%" "%REMOTE_APK%" || call :fail "adb push 失败"

echo [信息] 正在安装（覆盖安装，保留数据）...
adb shell pm install -r "%REMOTE_APK%" > "!INSTALL_LOG!" 2>&1
set "INSTALL_RC=!errorlevel!"
type "!INSTALL_LOG!"
if "!INSTALL_RC!"=="0" (
    call :cleanup_logs
    endlocal & exit /b 0
)

findstr /i /c:"persistent app" "!INSTALL_LOG!" >nul || (
    echo [错误] 安装失败，可尝试手动执行:
    echo adb shell pm install -r "%REMOTE_APK%"
    call :cleanup_logs
    endlocal & exit /b 1
)

call :handle_persistent_install
set "PERSISTENT_RC=!errorlevel!"
call :cleanup_logs
endlocal & exit /b %PERSISTENT_RC%

:init_logs
set "INSTALL_LOG=%TEMP%\adb_install_result_%RANDOM%.log"
set "PM_PATH_LOG=%TEMP%\adb_pm_path_%RANDOM%.log"
set "SYSTEM_PUSH_LOG=%TEMP%\adb_system_push_%RANDOM%.log"
set "VERIFY_LOG=%TEMP%\adb_verify_%RANDOM%.log"
set "PKG_NAME="
set "TARGET_APK="
set "SYSTEM_PUSH_RC=1"
exit /b 0

:cleanup_logs
adb shell rm -f "%REMOTE_APK%" >nul 2>&1
del /q "!INSTALL_LOG!" >nul 2>&1
del /q "!PM_PATH_LOG!" >nul 2>&1
del /q "!SYSTEM_PUSH_LOG!" >nul 2>&1
del /q "!VERIFY_LOG!" >nul 2>&1
exit /b 0

:handle_persistent_install
for /f "tokens=4" %%P in ('findstr /i /c:"persistent app" "!INSTALL_LOG!"') do (
    if not defined PKG_NAME set "PKG_NAME=%%P"
)
if not defined PKG_NAME (
    echo [错误] 检测到 persistent app 限制，但未能解析包名
    echo 请手动替换系统分区中的 APK 后重启设备
    exit /b 1
)

echo [提示] 检测到持久化应用: !PKG_NAME!
echo [提示] 正在尝试系统分区替换安装（需要 adbd root + remount）...
adb root >nul 2>&1
adb remount >nul 2>&1
if errorlevel 1 (
    echo [错误] 设备不支持 adb root/remount，无法自动替换 persistent app
    echo 请在可写 system 环境或刷机流程中更新该 APK
    exit /b 1
)

adb shell pm path !PKG_NAME! > "!PM_PATH_LOG!" 2>&1
for /f "tokens=2 delims=:" %%A in ('findstr /i "package:" "!PM_PATH_LOG!"') do (
    if not defined TARGET_APK set "TARGET_APK=%%A"
)
if not defined TARGET_APK (
    echo [错误] 无法获取 !PKG_NAME! 的系统 APK 路径
    type "!PM_PATH_LOG!"
    exit /b 1
)

echo [信息] 检测到系统 APK 路径: !TARGET_APK!
call :push_system_apk "%APK_PATH%" "!TARGET_APK!"
if errorlevel 1 (
    echo [错误] 系统分区替换失败
    exit /b 1
)

call :verify_remote_apk "%APK_PATH%" "!TARGET_APK!" "!VERIFY_LOG!"
if errorlevel 1 (
    echo [错误] 已执行 push，但校验未通过，目标文件可能未被实际替换
    exit /b 1
)

echo [成功] 已替换系统 APK: !TARGET_APK!
echo [提示] 需要重启设备使 persistent app 新版本生效
set "DO_REBOOT="
set /p "DO_REBOOT=Reboot device now? [Y/N, default N]: "
if /i "!DO_REBOOT!"=="Y" (
    echo [信息] 正在重启设备...
    adb reboot
    echo [提示] 已发送重启命令
) else (
    echo [提示] 已跳过重启，请稍后手动重启设备使应用生效
)
exit /b 0

:push_system_apk
set "LOCAL_APK=%~1"
set "SYSTEM_APK=%~2"
adb push "!LOCAL_APK!" "!SYSTEM_APK!" > "!SYSTEM_PUSH_LOG!" 2>&1
set "SYSTEM_PUSH_RC=!errorlevel!"
type "!SYSTEM_PUSH_LOG!"
if "!SYSTEM_PUSH_RC!"=="0" exit /b 0

findstr /i /c:"Read-only file system" "!SYSTEM_PUSH_LOG!" >nul || exit /b 1
echo [提示] 检测到 system 分区只读，尝试 disable-verity 后重试...
call :try_make_system_rw || exit /b 1

adb push "!LOCAL_APK!" "!SYSTEM_APK!" > "!SYSTEM_PUSH_LOG!" 2>&1
set "SYSTEM_PUSH_RC=!errorlevel!"
type "!SYSTEM_PUSH_LOG!"
if "!SYSTEM_PUSH_RC!"=="0" (exit /b 0) else (exit /b 1)

:try_make_system_rw
echo [信息] 执行 adb disable-verity...
adb disable-verity >nul 2>&1 || (
    echo [错误] adb disable-verity 失败，设备可能不支持该操作
    echo 请使用可写 system 的构建版本或刷机方式更新 persistent app
    exit /b 1
)
echo [信息] 正在重启设备以应用 verity 设置...
adb reboot >nul 2>&1
adb wait-for-device || (
    echo [错误] 设备重启后未正常连接
    exit /b 1
)
echo [信息] 重新获取 root 并 remount...
adb root >nul 2>&1
adb wait-for-device >nul 2>&1
adb remount >nul 2>&1 || (
    echo [错误] remount 仍失败，system 依旧不可写
    echo 请改用 fastboot/刷机流程更新该 persistent app
    exit /b 1
)
exit /b 0

:verify_remote_apk
setlocal EnableDelayedExpansion
set "LOCAL_FILE=%~1"
set "REMOTE_FILE=%~2"
set "OUT_LOG=%~3"
set "LOCAL_MD5="
set "REMOTE_MD5="

for /f %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm MD5 -LiteralPath \"%LOCAL_FILE%\").Hash.ToLower()"') do (
    if not defined LOCAL_MD5 set "LOCAL_MD5=%%H"
)
if not defined LOCAL_MD5 (
    echo [错误] 无法计算本地 APK MD5
    endlocal & exit /b 1
)

adb shell md5sum "!REMOTE_FILE!" > "!OUT_LOG!" 2>&1
for /f "tokens=1" %%H in ('type "!OUT_LOG!"') do if not defined REMOTE_MD5 set "REMOTE_MD5=%%H"
if not defined REMOTE_MD5 (
    adb shell toybox md5sum "!REMOTE_FILE!" > "!OUT_LOG!" 2>&1
    for /f "tokens=1" %%H in ('type "!OUT_LOG!"') do if not defined REMOTE_MD5 set "REMOTE_MD5=%%H"
)
if not defined REMOTE_MD5 (
    echo [错误] 无法读取设备端 MD5，输出如下:
    type "!OUT_LOG!"
    endlocal & exit /b 1
)

echo [信息] 本地 MD5 : !LOCAL_MD5!
echo [信息] 设备 MD5 : !REMOTE_MD5!
if /i not "!LOCAL_MD5!"=="!REMOTE_MD5!" endlocal & exit /b 1
endlocal & exit /b 0

:fail
echo [错误] %~1
exit /b 1
