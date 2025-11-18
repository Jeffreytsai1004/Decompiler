@echo off
chcp 65001 >nul
echo ========================================
echo Python反编译工具 - 调试模式
echo ========================================
echo.

REM 检查Python是否安装
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到Python，请先安装Python 3.6+
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [✓] %PYTHON_VERSION%

REM 检查decompiler_gui.py是否存在
if not exist "decompiler_gui.py" (
    echo [错误] 未找到 decompiler_gui.py
    pause
    exit /b 1
)
echo [✓] 找到GUI脚本: decompiler_gui.py

REM 检查pycdc.exe是否存在
if not exist "build\Release\pycdc.exe" (
    echo [警告] 未找到 build\Release\pycdc.exe
    echo 核心反编译功能可能无法使用
    echo 请先运行 Build.bat 构建C++核心程序
    echo.
    set /p continue="是否继续启动GUI？(Y/N): "
    if /i not "%continue%"=="Y" (
        exit /b 0
    )
) else (
    echo [✓] 找到核心程序: build\Release\pycdc.exe
)

echo.
echo ========================================
echo 检查并安装依赖
echo ========================================

REM 检查customtkinter是否安装
python -c "import customtkinter" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] 缺少customtkinter，正在安装依赖...
    python -m pip install -r requirements.txt
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
    echo [✓] 依赖安装完成
) else (
    echo [✓] 依赖已安装
)

echo.
echo ========================================
echo 启动调试模式
echo ========================================
echo [*] 使用Python直接运行GUI脚本
echo [*] 控制台输出将显示调试信息
echo [*] 关闭GUI窗口将结束程序
echo [*] 按Ctrl+C可强制终止程序
echo.
echo 正在启动...
echo ========================================
echo.

REM 直接运行Python脚本，保持控制台窗口显示输出
python decompiler_gui.py

echo.
echo ========================================
if %errorlevel% neq 0 (
    echo [错误] 程序异常退出，错误代码: %errorlevel%
) else (
    echo [✓] 程序正常退出
)
echo ========================================
pause
