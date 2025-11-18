@echo off
chcp 65001 >nul
echo ========================================
echo Python反编译工具 - 构建脚本
echo ========================================
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到Python，请先安装Python 3.6+
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [✓] Python已安装

REM 检查CMake是否安装
cmake --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到CMake，请先安装CMake
    echo 下载地址: https://cmake.org/download/
    pause
    exit /b 1
)
echo [✓] CMake已安装

REM 检查MSBuild是否存在
set "MSBUILD_PATH=D:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
if not exist "%MSBUILD_PATH%" (
    set "MSBUILD_PATH=D:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
)
if not exist "%MSBUILD_PATH%" (
    echo [错误] 未找到MSBuild，请先安装Visual Studio 2019或2022
    echo 下载地址: https://visualstudio.microsoft.com/
    pause
    exit /b 1
)
echo [✓] MSBuild已找到: %MSBUILD_PATH%

echo.
echo ========================================
echo 步骤1: 安装Python依赖
echo ========================================
python -m pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo [错误] Python依赖安装失败
    pause
    exit /b 1
)
echo [✓] Python依赖安装完成

REM 安装Pillow用于图标转换
python -m pip install pillow
if %errorlevel% neq 0 (
    echo [警告] Pillow安装失败，图标转换可能无法工作
)

echo.
echo ========================================
echo 步骤2: 构建C++核心程序 (pycdc.exe)
echo ========================================

REM 创建build目录
if not exist "build" (
    mkdir build
    echo [✓] 创建build目录
)

cd build

REM 运行CMake生成项目文件
echo [*] 正在生成Visual Studio项目文件...
cmake ..
if %errorlevel% neq 0 (
    echo [错误] CMake配置失败
    cd ..
    pause
    exit /b 1
)
echo [✓] CMake配置完成

REM 使用MSBuild编译Release版本
echo [*] 正在编译Release版本...
"%MSBUILD_PATH%" pycdc.sln /p:Configuration=Release /m
if %errorlevel% neq 0 (
    echo [错误] 编译失败
    cd ..
    pause
    exit /b 1
)
echo [✓] C++程序编译完成

cd ..

REM 检查pycdc.exe是否生成
if not exist "build\Release\pycdc.exe" (
    echo [错误] pycdc.exe未生成
    pause
    exit /b 1
)
echo [✓] pycdc.exe已生成: build\Release\pycdc.exe

REM 检查pycdas.exe是否生成
if exist "build\Release\pycdas.exe" (
    echo [✓] pycdas.exe已生成: build\Release\pycdas.exe
)

echo.
echo ========================================
echo 步骤3: 打包GUI应用程序
echo ========================================

REM 卸载typing包（与PyInstaller不兼容）
echo [*] 检查typing包...
python -c "import typing" >nul 2>&1
if %errorlevel% equ 0 (
    python -c "import sys; print(sys.modules['typing'].__file__)" | findstr "site-packages" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [*] 检测到第三方typing包，正在卸载...
        python -m pip uninstall -y typing
        if %errorlevel% equ 0 (
            echo [✓] typing包已卸载（Python 3.5+已内置typing模块）
        ) else (
            echo [警告] typing包卸载失败，打包可能会出错
        )
    )
)

REM 检查python目录是否存在
if not exist "python" (
    echo [警告] 未找到python目录，打包可能会失败
    echo 请确保python embed包已解压到python目录
)

REM 使用PyInstaller打包
echo [*] 正在打包GUI应用程序...
python -m PyInstaller decompiler.spec
if %errorlevel% neq 0 (
    echo [错误] 打包失败
    pause
    exit /b 1
)
echo [✓] GUI应用程序打包完成

echo.
echo ========================================
echo 构建完成！
echo ========================================
echo.
echo 生成的文件:
echo   - C++核心程序: build\Release\pycdc.exe
echo   - C++反汇编器: build\Release\pycdas.exe
echo   - GUI应用程序: dist\Python反编译工具.exe
echo.
echo 您可以运行 Run.bat 来启动GUI应用程序
echo 或直接运行 dist\Python反编译工具.exe
echo.
pause
