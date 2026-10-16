@echo off
chcp 936 >nul
title springboottest 后端 (8080)
cd /d "%~dp0"

rem ---------- 位置自检：防止从压缩包预览窗口直接运行 ----------
if not exist "pom.xml" (
    echo [错误] 脚本不在项目目录中，无法启动！
    echo [错误] 请先把整个项目完整解压到磁盘文件夹（右键 - 全部解压），
    echo [错误] 再进入解压后的文件夹运行本脚本。
    echo [错误] 不要在 WinRAR / 7-Zip 等压缩软件的预览窗口里直接双击运行！
    pause
    exit /b 1
)

echo ========================================
echo   springboottest 后端启动脚本
echo ========================================

rem ---------- 0. 端口预检：8080 被占用则先停掉旧实例 ----------
netstat -ano | findstr /r ":8080[^0-9]" | findstr "LISTENING" >nul
if not errorlevel 1 (
    echo [提示] 检测到 8080 端口已被占用，先停止旧的后端进程...
    call "%~dp0停止后端.bat" nopause
    title springboottest 后端 (8080)
)

rem ---------- 1. 检查 JDK ----------
where java >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到 java，请确认 JDK 21 已安装并加入 PATH
    pause
    exit /b 1
)

rem ---------- 2. 定位 Maven（不在 PATH，按优先级探测） ----------
set "MVN="
where mvn >nul 2>nul && set "MVN=mvn"

rem IDEA 自带的 Maven（通配符扫描，不写死版本号，IDEA 升级后依然有效）
if not defined MVN (
    for /d %%d in ("D:\IntelliJ IDEA*" "C:\Program Files\JetBrains\IntelliJ IDEA*") do (
        if not defined MVN if exist "%%d\plugins\maven\lib\maven3\bin\mvn.cmd" set "MVN=%%d\plugins\maven\lib\maven3\bin\mvn.cmd"
    )
)

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

rem ---------- 3. 检查 MySQL ----------
netstat -ano | findstr /r ":3306[^0-9]" | findstr "LISTENING" >nul
if errorlevel 1 (
    echo [警告] 未检测到 MySQL 服务（3306 端口），后端将无法连接数据库
    echo [警告] 请先启动 MySQL，再继续
    pause
)

rem ---------- 4. 清理干扰变量并锁定端口 ----------
rem 某些工具（如 WorkBuddy）会向环境注入 SERVER__PORT / SERVER__HOST，
rem Spring Boot 宽松绑定会误读为 server.port / server.address 导致端口错乱
set "SERVER__PORT="
set "SERVER__HOST="
rem 命令行参数优先级最高，显式锁定 8080，不受任何环境变量影响

rem ---------- 5. 编译并启动 ----------
rem target 每次开机会被删除，spring-boot:run 会自动重新编译，不依赖旧 target
rem 依赖已缓存在 %USERPROFILE%\.m2\repository，无需重新下载
echo [提示] 正在编译并启动后端（target 被删后首次约 1-2 分钟）...
echo [提示] 后端地址: http://localhost:8080
echo [提示] 关闭本窗口即停止后端服务
call "%MVN%" spring-boot:run "-Dspring-boot.run.arguments=--server.port=8080"
pause
