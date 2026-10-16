@echo off
chcp 936 >nul
title 一键停止 vue-login 全家桶
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

echo [提示] 停止前端...
call "%~dp0停止前端.bat" nopause

echo [提示] 停止后端...
call "%~dp0..\springboottest\停止后端.bat" nopause

echo.
echo [完成] 前后端已全部停止
pause
