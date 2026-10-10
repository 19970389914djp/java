@echo off
chcp 936 >nul
title vue-login 前端 (5173)
cd /d "%~dp0"

echo ========================================
echo   vue-login 前端启动脚本
echo ========================================

where npm >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到 npm，请确认 Node.js 已安装并加入 PATH
    pause
    exit /b 1
)

rem node_modules 每次开机会被删除，不存在则重新安装依赖
if not exist "node_modules\" (
    echo [提示] node_modules 不存在，正在安装依赖，请稍候...
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
    echo [提示] 依赖安装完成
)

echo [提示] 启动开发服务器: http://localhost:5173
echo [提示] 关闭本窗口即停止前端服务
call npm run dev
pause
