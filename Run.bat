@echo off
chcp 65001 >nul
echo ========================================
echo Python反编译工具 - 运行脚本
echo ========================================
echo.

REM 检查打包的GUI程序是否存在
if exist "dist\Python反编译工具.exe" (
    echo [*] 找到打包的应用程序
    echo [*] 启动GUI应用程序...
    echo.
    start "" "dist\Python反编译工具.exe"
    echo [✓] GUI应用程序已启动
    echo.
    echo 提示: 如需调试模式，请运行 RunDebug.bat
    exit /b 0
)

REM 如果打包程序不存在，尝试直接运行Python脚本
echo [警告] 未找到打包的应用程序: dist\Python反编译工具.exe
echo [*] 切换到开发模式（直接运行Python脚本）
echo.

REM 检查Python是否安装
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到Python，无法运行
    echo.
    echo 请先安装Python或运行 Build.bat 构建打包版本
    pause
    exit /b 1
)
echo [✓] %PYTHON_VERSION%

REM 检查pycdc.exe是否存在
if not exist "build\Release\pycdc.exe" (
    echo [错误] 未找到 build\Release\pycdc.exe
    echo.
    echo 请先运行 Build.bat 构建项目
    pause
    exit /b 1
)

REM 检查decompiler_gui.py是否存在
if not exist "decompiler_gui.py" (
    echo [错误] 未找到 decompiler_gui.py
    pause
    exit /b 1
)

echo.
echo ========================================
echo 检查依赖
echo ========================================

REM 检查依赖是否安装
python -c "import customtkinter" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] 缺少依赖库，正在安装...
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
echo 启动应用程序
echo ========================================
echo [*] 使用Python直接运行GUI脚本
echo.

REM 运行Python GUI脚本（后台模式，不阻塞控制台）
start "Python反编译工具" python decompiler_gui.py
echo [✓] GUI应用程序已启动
echo.
echo 提示: 如需查看调试信息，请运行 RunDebug.bat
