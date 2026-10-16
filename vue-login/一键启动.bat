@echo off
chcp 936 >nul
title 一键启动 vue-login 全家桶
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
if not exist "%~dp0..\springboottest\pom.xml" (
    echo [错误] 缺少 ..\springboottest 后端目录，请确认解压了完整项目
    pause
    exit /b 1
)

echo ========================================
echo   一键启动：后端 + 前端
echo ========================================

echo [提示] 启动后端（新窗口，首次编译约 1-2 分钟）...
start "springboottest 后端 (8080)" cmd /k "%~dp0..\springboottest\启动后端.bat"

rem ---------- 轮询等待后端就绪（最多 150 秒，每 5 秒检测一次 8080 端口） ----------
echo [提示] 等待后端编译并监听 8080 端口...
set /a WAITED=0
:wait_backend
netstat -ano | findstr /r ":8080[^0-9]" | findstr "LISTENING" >nul
if not errorlevel 1 goto :backend_ok
set /a WAITED+=5
if %WAITED% GEQ 150 goto :backend_timeout
ping -n 6 127.0.0.1 >nul
echo [提示] 已等待 %WAITED% 秒，后端仍在编译...
goto :wait_backend

:backend_ok
echo [提示] 后端已就绪（约耗时 %WAITED% 秒）
goto :start_front

:backend_timeout
echo [警告] 等待超时，后端仍未监听 8080，请查看后端窗口的报错信息

:start_front
echo [提示] 启动前端（新窗口）...
start "vue-login 前端 (5173)" cmd /k "%~dp0启动前端.bat"

echo.
echo [完成] 两个服务已在新窗口启动：
echo   前端: http://localhost:5173  （会自动打开浏览器）
echo   后端: http://localhost:8080
echo [提示] 若后端编译超时，登录会提示网络异常，等后端就绪后重试即可
pause
