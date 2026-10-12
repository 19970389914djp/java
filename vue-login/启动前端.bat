@echo off
chcp 936 >nul
title vue-login 前端 (5173)
cd /d "%~dp0"

rem ---------- 位置自检：防止从压缩包预览窗口直接运行 ----------
if not exist "package.json" (
    echo [错误] 脚本不在项目目录中，无法启动！
    echo [错误] 请先把整个项目完整解压到磁盘文件夹（右键 - 全部解压），
    echo [错误] 再进入解压后的文件夹运行本脚本。
    echo [错误] 不要在 WinRAR / 7-Zip 等压缩软件的预览窗口里直接双击运行！
    pause
    exit /b 1
)

echo ========================================
echo   vue-login 前端启动脚本
echo ========================================

where npm >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到 npm，请确认 Node.js 已安装并加入 PATH
    pause
    exit /b 1
)

rem ---------- 端口预检：5173 被占用则先停掉旧实例 ----------
netstat -ano | findstr /r ":5173[^0-9]" | findstr "LISTENING" >nul
if not errorlevel 1 (
    echo [提示] 检测到 5173 端口已被占用，先停止旧的前端进程...
    call "%~dp0停止前端.bat" nopause
    title vue-login 前端 (5173)
)

rem ---------- 依赖检查与安装 ----------
rem node_modules 每次开机会被删除，脚本从不依赖它已存在
rem 校验关键依赖 vite，防止上次安装中断留下的残缺 node_modules
if exist "node_modules\.bin\vite.cmd" goto :deps_ok
echo [提示] node_modules 缺失或不完整，正在安装依赖，请稍候...
if exist "package-lock.json" (
    call npm ci
) else (
    call npm install
)
if errorlevel 1 (
    echo [错误] 依赖安装失败，请检查网络后重试
    pause
    exit /b 1
)
if not exist "node_modules\.bin\vite.cmd" (
    echo [错误] 依赖安装后仍缺少 vite，请删除 node_modules 后重新运行本脚本
    pause
    exit /b 1
)
echo [提示] 依赖安装完成
:deps_ok
echo [提示] 依赖就绪，启动开发服务器: http://localhost:5173
echo [提示] 关闭本窗口即停止前端服务
call npm run dev
pause
