# AI-NOTES.md（写给 AI 助手 / WorkBuddy 的操作手册）

> 下次开机后用户让你"启动项目"时，**先读这个文件，直接执行，不要重新分析项目结构**。

## 一句话架构

前后端分离登录注册 Demo（学习项目）：

| 模块 | 路径 | 技术栈 | 端口 |
|------|------|--------|------|
| 前端 | `Desktop\vue-login`（本目录） | Vue 3 + Vite 5，`/api` 代理到 8080 | 5173 |
| 后端 | `Desktop\springboottest`（本目录的兄弟目录） | Spring Boot 3.3.5 + MyBatis-Plus + Java 21 | 8080 |
| 数据库 | 本机 MySQL 8.0 | 库 `user_db`，root / 123456，建库脚本在 `springboottest\sql\user_db.sql` | 3306 |

## 关键事实（已核实 2026-10-10）

- **电脑每次开机重置**：`node_modules\` 和 `target\` 会被删除，其余文件保留。启动脚本已内置自动重装/重编译，直接用脚本即可。
- **Node.js**：`D:\Program Files\nodejs`（v20，npm 在 PATH）。
- **Java**：`C:\Program Files\Zulu\zulu-21`（在 PATH）。
- **Maven 不在 PATH**，探测顺序：
  1. `where mvn`
  2. IDEA 自带：`D:\IntelliJ IDEA 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd`
  3. Wrapper 缓存：`%USERPROFILE%\.m2\wrapper\dists\` 下递归找 `mvn.cmd`
- **Maven 本地仓库** `%USERPROFILE%\.m2\repository` 不会被重置，依赖已缓存，重编译只需 1-2 分钟，无需重新下载。
- 后端验证码是**开发模式**：不发真实邮件，验证码打印在后端控制台并随响应 `data.code` 返回。
- 登录 token 是简易 UUID，存前端 localStorage；已登录会直接进主页。

## 启动 / 停止（全部用脚本，勿手敲命令）

| 操作 | 脚本 |
|------|------|
| 一键启动前后端 | `vue-login\一键启动.bat` |
| 一键停止前后端 | `vue-login\一键停止.bat` |
| 只启动前端 | `vue-login\启动前端.bat`（node_modules 缺失自动 `npm ci`） |
| 只启动后端 | `springboottest\启动后端.bat`（自动探测 Maven，`mvn spring-boot:run`） |
| 停止前端 / 后端 | 对应 `停止前端.bat` / `停止后端.bat`（按 5173/8080 端口杀进程） |

启动顺序建议：先后端再前端。Vite 代理按需转发，后端没起好时登录会提示"网络异常"，属正常现象，等后端编译完重试即可。

## 给 AI 的维护提醒

- **所有 .bat 脚本必须是 GBK 编码**（中文 cmd 默认 chcp 936）。编辑后务必转码：`iconv -f UTF-8 -t GBK`，否则中文乱码。
- 脚本内项目路径一律用 `%~dp0` 相对定位，禁止写死绝对路径（Maven 探测路径除外）。
- 前端接口：`POST /api/auth/send-code | register | login`，统一 `Result` 结构（code/msg/data），axios 拦截器已解包。
- README.md 的项目结构图已过时（缺 `src/api/`、`HomePage.vue`、`RegisterPage.vue`），以本文件为准。
