@echo off
chcp 936 >nul
title 停止 vue-login 前端

set "FOUND=0"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5173" ^| findstr "LISTENING"') do (
    echo [提示] 正在停止占用 5173 端口的进程 PID=%%a
    taskkill /F /PID %%a >nul 2>nul
    set "FOUND=1"
)
if "%FOUND%"=="0" echo [提示] 5173 端口空闲，前端未在运行
pause
