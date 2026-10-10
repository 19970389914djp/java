@echo off
chcp 936 >nul
title springboottest 后端 (8080)
cd /d "%~dp0"

echo ========================================
echo   springboottest 后端启动脚本
echo ========================================

rem ---------- 1. 定位 Maven（不在 PATH，按优先级探测） ----------
set "MVN="
where mvn >nul 2>nul && set "MVN=mvn"

rem IDEA 自带的 Maven
if not defined MVN if exist "D:\IntelliJ IDEA 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd" set "MVN=D:\IntelliJ IDEA 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd"

rem Maven Wrapper 下载缓存里的 Maven
if not defined MVN (
    for /f "delims=" %%f in ('dir /b /s "%USERPROFILE%\.m2\wrapper\dists\mvn.cmd" 2^>nul') do (
        set "MVN=%%f"
        goto :mvn_found
    )
)
:mvn_found
if not defined MVN (
    echo [错误] 未找到 Maven，请安装 Maven 或 IDEA 后重试
    pause
    exit /b 1
)
echo [提示] 使用 Maven: %MVN%

rem ---------- 2. 检查 MySQL ----------
netstat -ano | findstr ":3306" | findstr "LISTENING" >nul
if errorlevel 1 (
    echo [警告] 未检测到 MySQL 服务（3306 端口），后端将无法连接数据库
    echo [警告] 请先启动 MySQL，再继续
    pause
)

rem ---------- 3. 编译并启动 ----------
rem target 每次开机会被删除，spring-boot:run 会自动重新编译
rem 依赖已缓存在 %USERPROFILE%\.m2\repository，无需重新下载
echo [提示] 正在编译并启动后端（target 被删后首次约 1-2 分钟）...
echo [提示] 后端地址: http://localhost:8080
echo [提示] 关闭本窗口即停止后端服务
call "%MVN%" spring-boot:run
pause
