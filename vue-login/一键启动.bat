@echo off
chcp 936 >nul
title 一键启动 vue-login 全家桶
cd /d "%~dp0"

echo ========================================
echo   一键启动：后端 + 前端
echo ========================================

echo [提示] 启动后端（新窗口，首次编译约 1-2 分钟）...
start "springboottest 后端 (8080)" cmd /k "%~dp0..\springboottest\启动后端.bat"

echo [提示] 等待 10 秒让后端先跑起来...
timeout /t 10 /nobreak >nul

echo [提示] 启动前端（新窗口）...
start "vue-login 前端 (5173)" cmd /k "%~dp0启动前端.bat"

echo.
echo [完成] 两个服务已在新窗口启动：
echo   前端: http://localhost:5173  （会自动打开浏览器）
echo   后端: http://localhost:8080
echo [提示] 后端编译期间登录会提示网络异常，稍等片刻重试即可
pause
