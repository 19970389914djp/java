@echo off
chcp 936 >nul
title 一键停止 vue-login 全家桶
cd /d "%~dp0"

echo [提示] 停止前端...
call "%~dp0停止前端.bat"

echo [提示] 停止后端...
call "%~dp0..\springboottest\停止后端.bat"
