# 开机动画图片改名 + 打包工具
# 拖入图片 → 按拖入顺序改名为 00001.png、00002.png ...
# 可选打包成 bootanimation.zip(part0 + 可选 part1 + desc.txt)
# 由 rename_boot_animation.bat 双击调用

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path $scriptDir 'output'
$tmpDir = Join-Path $scriptDir 'bootani_tmp'
$zipPath = Join-Path $scriptDir 'bootanimation.zip'

Write-Host '========================================'
Write-Host '   开机动画图片改名 + 打包工具'
Write-Host '========================================'

# 清空上次的 output 和临时目录
foreach ($d in @($outputDir, $tmpDir)) {
    if (Test-Path $d) {
        Remove-Item -Path (Join-Path $d '*') -Force -Recurse -ErrorAction SilentlyContinue
    } else {
        New-Item -ItemType Directory -Path $d | Out-Null
    }
}

Write-Host '请把要改名的图片文件拖进这个窗口,然后按回车:'
Write-Host '改名顺序 = 拖入顺序;支持 png/jpg/jpeg/bmp/webp'
Write-Host '也可以直接拖整个文件夹进来(自动按文件名排序)'
$dragged = Read-Host

# 解析拖入的路径:优先取成对引号里的内容,否则按空格切分
$paths = @()
$m = [regex]::Matches($dragged, '"([^"]*)"')
if ($m.Count -gt 0) {
    $paths = $m | ForEach-Object { $_.Groups[1].Value }
} else {
    $paths = @($dragged -split '\s+' | Where-Object { $_ })
}

# 收集图片文件:文件直接收,文件夹递归收
$files = @()
foreach ($p in $paths) {
    if (Test-Path -LiteralPath $p) {
        $item = Get-Item -LiteralPath $p
        if ($item.PSIsContainer) {
            $sub = @(Get-ChildItem -LiteralPath $p -Recurse -File | Where-Object {
                    $_.Extension -match '^\.(png|jpg|jpeg|bmp|webp)$'
                } | Sort-Object @{ Expression = {
                        $mm = [regex]::Match($_.BaseName, '\d+')
                        if ($mm.Success) { [int]$mm.Value } else { [int]::MaxValue }
                    }; Ascending = $true }, @{ Expression = { $_.Name }; Ascending = $true })
            if ($sub.Count -gt 0) {
                $files += $sub
                Write-Host "文件夹 $($item.Name) 内找到 $($sub.Count) 张图片"
            } else {
                Write-Host "文件夹 $($item.Name) 内没有图片文件"
            }
        } elseif ($item.Extension -match '^\.(png|jpg|jpeg|bmp|webp)$') {
            $files += $item
        } else {
            Write-Host "跳过非图片文件: $($item.Name)"
        }
    } else {
        Write-Host "找不到: $p"
    }
}

if ($files.Count -eq 0) {
    Write-Host '没有可处理的图片文件'
    Read-Host '按回车退出' | Out-Null
    exit 1
}

Write-Host "收到 $($files.Count) 张图片,将按以下顺序处理:"
$i = 1
foreach ($f in $files) {
    Write-Host "  $i. $($f.Name)"
    $i++
}

# 复制到 output 目录并改名为 00001...
$renamed = @()
$i = 1
foreach ($f in $files) {
    $ext = $f.Extension.TrimStart('.')
    $newName = '{0:d5}.{1}' -f $i, $ext
    $dest = Join-Path $outputDir $newName
    Copy-Item -LiteralPath $f.FullName -Destination $dest
    $renamed += $dest
    Write-Host "已改名: $($f.Name) -> $newName"
    $i++
}
Write-Host "完成,共 $($files.Count) 张,原文件未被修改"

# 是否打包
$pack = Read-Host '是否需要打包成开机动画? y/n (直接回车默认 y)'
if ($pack -match '^[nN]') {
    Write-Host "未打包,改好的图片在 $outputDir"
    Read-Host '按回车退出' | Out-Null
    exit 0
}

# part1 选项:最后一张作为结束画面
$usePart1 = $true
$ans = Read-Host '是否将最后一张图片作为 part1 结束画面? y/n (直接回车默认 y)'
if ($ans -match '^[nN]') { $usePart1 = $false }

# 分辨率:默认取第一张图片的实际尺寸
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($renamed[0])
$w = $img.Width
$h = $img.Height
$img.Dispose()
Write-Host "检测到图片分辨率: $w x $h"
$ans = Read-Host '是否需要修改分辨率? y/n (直接回车默认 n)'
if ($ans -match '^[yY]') {
    $res = Read-Host '请输入分辨率,格式如 800x1280'
    $mm = [regex]::Match($res, '(\d+)\s*[xX*]\s*(\d+)')
    if ($mm.Success) {
        $w = [int]$mm.Groups[1].Value
        $h = [int]$mm.Groups[2].Value
    } else {
        Write-Host '格式不对,继续用图片分辨率'
    }
}

# 帧率:默认 30
$fps = 30
$ans = Read-Host '帧率默认 30,是否需要修改? y/n (直接回车默认 n)'
if ($ans -match '^[yY]') {
    $fpsInput = Read-Host '请输入帧率(正整数)'
    if ($fpsInput -match '^\d+$') { $fps = [int]$fpsInput }
    else { Write-Host '格式不对,继续用 30' }
}

# 组装 part0 / part1 / desc.txt
New-Item -ItemType Directory -Path (Join-Path $tmpDir 'part0') -Force | Out-Null
Copy-Item -Path (Join-Path $outputDir '*') -Destination (Join-Path $tmpDir 'part0') -Force
Write-Host "part0 已生成,共 $($files.Count) 张"

$desc = "$w $h $fps`n"
if ($usePart1) {
    New-Item -ItemType Directory -Path (Join-Path $tmpDir 'part1') -Force | Out-Null
    $lastExt = (Get-Item -LiteralPath $renamed[-1]).Extension.TrimStart('.')
    $part1Name = '00001.' + $lastExt
    Copy-Item -LiteralPath $renamed[-1] -Destination (Join-Path $tmpDir ('part1\' + $part1Name))
    Write-Host "part1 已生成(最后一张): $part1Name"
    $desc += "p 1 0 part0`n"
    $desc += "p 0 0 part1`n"
} else {
    $desc += "p 1 0 part0`n"
}

$descPath = Join-Path $tmpDir 'desc.txt'
[System.IO.File]::WriteAllText($descPath, $desc, [System.Text.Encoding]::ASCII)
Write-Host 'desc.txt 内容:'
Write-Host $desc.TrimEnd()

# 打包:store 不压缩(播放器只认不压缩的 png)
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path $zipPath) { Remove-Item -Path $zipPath -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($tmpDir, $zipPath, [System.IO.Compression.CompressionLevel]::NoCompression, $false)
Write-Host "打包完成: $zipPath"
Write-Host '零件保留在 bootani_tmp,可检查;zip 直接放进项目即可'
Read-Host '按回车退出' | Out-Null
