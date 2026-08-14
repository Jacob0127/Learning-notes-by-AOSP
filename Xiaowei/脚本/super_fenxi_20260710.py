
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Android设备Super分区分析工具
获取设备信息并分析super分区使用情况
"""

import subprocess
import re
import sys
import os
from datetime import datetime

# //xupei Add For "Super size threshold check" Start
STORAGE_SUPER_MIN_MB = {
    32: 7500,
    64: 8500,
    128: 10500,
    256: 10500,
    512: 10500,
}
MIN_FREE_MB = 1300
ANSI_RED = '\033[91m'
# //xupei Add For "Pass status green color" Start
ANSI_GREEN = '\033[92m'
# //xupei Add For "Pass status green color" End
ANSI_RESET = '\033[0m'


def enable_ansi_color():
    if sys.platform == 'win32':
        try:
            import ctypes
            kernel32 = ctypes.windll.kernel32
            kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
        except Exception:
            pass


def format_red(text):
    return f"{ANSI_RED}{text}{ANSI_RESET}"


# //xupei Add For "Pass status green color" Start
def format_green(text):
    return f"{ANSI_GREEN}{text}{ANSI_RESET}"
# //xupei Add For "Pass status green color" End


def get_device_storage_gb():
    """
    根据/data分区总容量判断设备存储档位(32/64/128/256/512 GB)
    """
    output = run_adb_command("adb shell df -k /data")
    if not output:
        return None

    lines = output.strip().splitlines()
    if len(lines) < 2:
        return None

    parts = lines[-1].split()
    if len(parts) < 2:
        return None

    try:
        total_kb = int(parts[1])
    except ValueError:
        return None

    total_gb = total_kb / (1024 * 1024)
    if total_gb < 40:
        return 32
    if total_gb < 80:
        return 64
    if total_gb < 180:
        return 128
    if total_gb < 360:
        return 256
    return 512
# //xupei Add For "Super size threshold check" End

def run_adb_command(command):
    """
    执行adb命令并返回输出
    """
    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                              text=True, check=True, shell=True)
        return result.stdout.strip()
    except subprocess.CalledProcessFailed as e:
        print(f"执行命令失败: {e.stderr}")
        return None
    except FileNotFoundError:
        print("未找到adb命令，请确保已安装Android SDK")
        return None

def get_product_name():
    """
    获取设备项目名称
    """
    print("正在获取设备项目名称...")
    product_name = run_adb_command("adb shell getprop ro.product.name")
    
    if product_name:
        print(f"设备项目名称: {product_name}")
        return product_name
    else:
        print("获取设备项目名称失败")
        return None

def run_lpdump(product_name):
    """
    执行lpdump命令并保存到带日期的文件
    """
    if not product_name:
        return False
        
    # 获取当前日期
    current_date = datetime.now().strftime("%Y%m%d")
    
    # 创建文件名
    filename = f"lpdump_{product_name}_{current_date}.txt"
    
    try:
        print(f"正在执行adb shell lpdump命令，保存到 {filename}...")
        # 检查adb是否可用
        subprocess.run(['adb', 'version'], capture_output=True, check=True)
        
        # 执行lpdump命令并保存到文件
        with open(filename, 'w') as f:
            result = subprocess.run(['adb', 'shell', 'lpdump', '/dev/block/by-name/super'], 
                                  stdout=f, stderr=subprocess.PIPE, text=True, check=True)
        print(f"lpdump输出已保存到 {filename}")
        return filename
    except subprocess.CalledProcessFailed as e:
        print(f"执行adb命令失败: {e.stderr}")
        print("请确保设备已连接并启用调试模式")
        return None
    except FileNotFoundError:
        print("未找到adb命令，请确保已安装Android SDK")
        return None

def parse_lpdump_file(filename):
    """
    解析lpdump文件，提取分区信息
    """
    if not os.path.exists(filename):
        print(f"错误: {filename}文件不存在")
        return None
        
    try:
        with open(filename, 'r') as f:
            content = f.read()
    except Exception as e:
        print(f"读取{filename}文件失败: {e}")
        return None
    
    # 提取以super:开头的行中的分区名称和sectors数
    partition_pattern = r'super:\s*\d+\s*\.\.\s*\d+:\s*(\w+)_a\s*\((\d+)\s+sectors\)'
    partition_matches = re.findall(partition_pattern, content)
    
    # 提取super分区总大小
    size_pattern = r'Size:\s*(\d+)\s+bytes'
    size_match = re.search(size_pattern, content)
    
    if not partition_matches:
        print("未找到任何分区信息")
        return None
    
    if not size_match:
        print("未找到super分区总大小信息")
        return None
    
    # 转换为整数
    partitions = [(match[0], int(match[1])) for match in partition_matches]
    total_size = int(size_match.group(1))
    
    return {
        'partitions': partitions,
        'total_size': total_size
    }

def calculate_partition_sizes(partitions):
    """
    计算各分区大小(MB)
    """
    sector_size = 512  # 每个扇区512字节
    results = []
    
    for name, sectors in partitions:
        size_bytes = sectors * sector_size
        size_mb = size_bytes / (1024 * 1024)
        results.append({
            'name': name,
            'sectors': sectors,
            'size_mb': size_mb
        })
    
    return results

def analyze_super_partition(data):
    """
    分析super分区使用情况
    """
    # 计算各分区大小
    partition_sizes = calculate_partition_sizes(data['partitions'])
    
    # 计算已使用总大小
    used_size_mb = sum(partition['size_mb'] for partition in partition_sizes)
    
    # 计算super分区总大小(MB)
    total_size_mb = data['total_size'] / (1024 * 1024)
    
    # 计算剩余空间
    free_size_mb = total_size_mb - used_size_mb
    
    return {
        'partition_sizes': partition_sizes,
        'used_size_mb': used_size_mb,
        'total_size_mb': total_size_mb,
        'free_size_mb': free_size_mb
    }

def print_analysis_result(result, storage_gb=None):
    """
    打印分析结果
    """
    # //xupei Add For "Super size threshold check" Start
    enable_ansi_color()
    # //xupei Add For "Super size threshold check" End
    print("=" * 80)
    print("Android Super分区空间分析报告")
    print("=" * 80)
    
    print("\n1. 各分区占用情况:")
    print("   " + "-" * 70)
    print(f"   {'分区名称':<15} {'Sectors数':<15} {'大小(MB)':<15}")
    print("   " + "-" * 70)
    
    for partition in result['partition_sizes']:
        print(f"   {partition['name']:<15} {partition['sectors']:<15} {partition['size_mb']:<15.2f}")
    
    print("\n2. Super分区总体情况:")
    print("   " + "-" * 70)
    # //xupei Add For "Super size threshold check" Start
    total_size_line = f"   总大小: {result['total_size_mb']:.2f} MB"
    if storage_gb and storage_gb in STORAGE_SUPER_MIN_MB:
        min_super_mb = STORAGE_SUPER_MIN_MB[storage_gb]
        if result['total_size_mb'] < min_super_mb:
            total_size_line = format_red(
                f"{total_size_line}  [不达标! {storage_gb}GB机型要求>={min_super_mb}MB]"
            )
        else:
            total_size_line = format_green(
                f"{total_size_line}  [达标, {storage_gb}GB机型要求>={min_super_mb}MB]"
            )
    print(total_size_line)
    # //xupei Add For "Super size threshold check" End
    print(f"   已使用: {result['used_size_mb']:.2f} MB")
    # //xupei Add For "Free space threshold check" Start
    free_size_line = f"   剩余空间: {result['free_size_mb']:.2f} MB"
    if result['free_size_mb'] <= MIN_FREE_MB:
        free_size_line = format_red(
            f"{free_size_line}  [不达标! 要求>{MIN_FREE_MB}MB]"
        )
    else:
        free_size_line = format_green(
            f"{free_size_line}  [达标, 要求>{MIN_FREE_MB}MB]"
        )
    print(free_size_line)
    # //xupei Add For "Free space threshold check" End

    # //xupei Add For "Remove space usage analysis section" Start
    # difference = result['total_size_mb'] - result['used_size_mb']
    # print(f"\n3. 空间使用分析:")
    # print("   " + "-" * 70)
    # print(f"   各分区大小总和: {result['used_size_mb']:.2f} MB")
    # print(f"   Super分区总大小: {result['total_size_mb']:.2f} MB")
    # print(f"   差值: {difference:.2f} MB")
    #
    # if abs(difference) <= 500:
    #     print("   警告: 差值在500MB以内，建议加大super分区大小!")
    # else:
    #     print("   正常: 差值大于500MB，空间充足。")
    # //xupei Add For "Remove space usage analysis section" End

    # //xupei Add For "Super size threshold check" Start
    print(f"\n3. Super总空间最低要求:")
    print("   " + "-" * 70)
    # //xupei Add For "Table column alignment fix" Start
    print("   机型存储    最低Super(MB)  当前Super(MB)   结果")
    print("   " + "-" * 70)
    DATA_STORAGE_COL_WIDTH = 14
    DATA_MIN_COL_WIDTH = 15
    for storage, min_mb in STORAGE_SUPER_MIN_MB.items():
        current_mb = result['total_size_mb']
        storage_text = f"{storage:>3}GB"
        if storage_gb == storage:
            status = format_green("达标") if current_mb >= min_mb else format_red("不达标")
            print(f"   {storage_text:<{DATA_STORAGE_COL_WIDTH}}{min_mb:<{DATA_MIN_COL_WIDTH}}{current_mb:<15.2f}{status}")
        else:
            print(f"   {storage_text:<{DATA_STORAGE_COL_WIDTH}}{min_mb:<{DATA_MIN_COL_WIDTH}}{'-':<15}{'-':<8}")
    # //xupei Add For "Table column alignment fix" End
    # //xupei Add For "Super size threshold check" End
    
    print("=" * 80)

def main():
    """
    主函数
    """
    print("=" * 50)
    print("Android设备信息获取工具")
    print("=" * 50)
    
    # 获取设备项目名称
    product_name = get_product_name()
    
    if not product_name:
        print("无法获取设备项目名称，程序退出")
        sys.exit(1)
    
    # 执行lpdump命令
    filename = run_lpdump(product_name)
    
    if not filename:
        print("执行lpdump命令失败，程序退出")
        sys.exit(1)
    
    # 解析文件
    data = parse_lpdump_file(filename)
    
    if data is None:
        print("解析失败，无法计算结果")
        sys.exit(1)
    
    # 分析分区使用情况
    result = analyze_super_partition(data)

    # //xupei Add For "Super size threshold check" Start
    storage_gb = get_device_storage_gb()
    if storage_gb:
        print(f"检测到设备存储档位: {storage_gb}GB")
    else:
        print("无法检测设备存储档位，将跳过Super总空间达标判断")
    # //xupei Add For "Super size threshold check" End
    
    # 输出分析结果
    print_analysis_result(result, storage_gb)

if __name__ == "__main__":
    main()
