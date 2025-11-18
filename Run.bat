@echo off
chcp 65001 >nul
echo ========================================
echo Python反编译工具 - 运行脚本
echo ========================================
echo.

REM 检查打包的GUI程序是否存在
if exist "dist\Python反编译工具.exe" (
    echo [*] 启动打包的GUI应用程序...
    echo.
    start "" "dist\Python反编译工具.exe"
    echo [✓] GUI应用程序已启动
    exit /b 0
)

REM 如果打包程序不存在，尝试直接运行Python脚本
echo [警告] 未找到打包的应用程序: dist\Python反编译工具.exe
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到Python，无法运行
    echo.
    echo 请先运行 Build.bat 构建项目
    pause
    exit /b 1
)

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

echo [*] 使用Python直接运行GUI脚本...
echo.

REM 检查依赖是否安装
python -c "import customtkinter" >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 缺少依赖库，正在安装...
    python -m pip install -r requirements.txt
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
)

REM 运行Python GUI脚本
python decompiler_gui.py
if %errorlevel% neq 0 (
    echo.
    echo [错误] 程序运行失败
    pause
    exit /b 1
)

echo.
echo [✓] 程序已退出
