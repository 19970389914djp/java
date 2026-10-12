# AI-NOTES.md（写给 AI 助手 / WorkBuddy 的操作手册）

> 下次开机后用户让你"启动项目"时，**先读这个文件，直接执行，不要重新分析项目结构**。

## 一句话架构

前后端分离登录注册 Demo（学习项目）：

| 模块 | 路径 | 技术栈 | 端口 |
|------|------|--------|------|
| 前端 | `Desktop\vue-login`（本目录） | Vue 3 + Vite 5，`/api` 代理到 8080 | 5173 |
| 后端 | `Desktop\springboottest`（本目录的兄弟目录） | Spring Boot 3.3.5 + MyBatis-Plus + Java 21 | 8080 |
| 数据库 | 本机 MySQL 8.0 | 库 `user_db`，root / 123456，建库脚本在 `springboottest\sql\user_db.sql` | 3306 |

## 关键事实（已核实 2026-10-12）

- **电脑每次开机重置**：`node_modules\` 和 `target\` 会被删除，其余文件保留。启动脚本已内置自动重装/重编译，直接用脚本即可。
- **⚠️ 端口污染坑（2026-10-12 已修复）**：WorkBuddy 桌面端会向环境注入 `SERVER__PORT` / `SERVER__HOST`（值为其内部代理端口 53148 等），Spring Boot 宽松绑定会把它们误读为 `server.port` / `server.address`，导致后端绑定到错误端口且启动失败。启动后端脚本已内置修复：启动前清空这两个变量，并用命令行参数 `--server.port=8080` 显式锁定端口（优先级高于环境变量）。若在其他环境遇到"Port 53148 was already in use"之类的诡异报错，即为此因。
- **Node.js**：`D:\Program Files\nodejs`（v20，npm 在 PATH）。
- **Java**：`C:\Program Files\Zulu\zulu-21`（在 PATH）。
- **Maven 不在 PATH**，探测顺序：
  1. `where mvn`
  2. IDEA 自带（脚本用 `D:\IntelliJ IDEA*` / `C:\Program Files\JetBrains\IntelliJ IDEA*` 通配符扫描，不写死版本号）
  3. Wrapper 缓存：`%USERPROFILE%\.m2\wrapper\dists\` 下递归找 `mvn.cmd`
- **Maven 本地仓库** `%USERPROFILE%\.m2\repository` 不会被重置，依赖已缓存，重编译只需 1-2 分钟，无需重新下载。
- **端口检测注意**：本机 MySQL 同时监听 3306 和 33060，`findstr ":3306"` 会误匹配 33060。脚本统一用 `findstr /r ":端口[^0-9]"` 精确匹配。
- 后端验证码是**开发模式**：不发真实邮件，验证码打印在后端控制台并随响应 `data.code` 返回。
- 登录 token 是简易 UUID，存前端 localStorage；已登录会直接进主页。

## 启动 / 停止（全部用脚本，勿手敲命令）

| 操作 | 脚本 |
|------|------|
| 一键启动前后端 | `vue-login\一键启动.bat`（轮询等待后端就绪，最长 150 秒，再启动前端） |
| 一键停止前后端 | `vue-login\一键停止.bat` |
| 只启动前端 | `vue-login\启动前端.bat`（node_modules 缺失/残缺自动 `npm ci`，启动前自动清理 5173 端口旧进程） |
| 只启动后端 | `springboottest\启动后端.bat`（自动探测 Maven，`mvn spring-boot:run`，锁定 8080 端口，启动前自动清理旧进程） |
| 停止前端 / 后端 | 对应 `停止前端.bat` / `停止后端.bat`（按 5173/8080 端口杀进程树；传 `nopause` 参数可跳过暂停，供脚本间静默调用） |

启动顺序建议：先后端再前端（一键启动脚本已内置）。Vite 代理按需转发，后端没起好时登录会提示"网络异常"，属正常现象，等后端编译完重试即可。

## 给 AI 的维护提醒

- **所有 .bat 脚本必须是 GBK 编码**（中文 cmd 默认 chcp 936）。编辑后务必转码：`iconv -f UTF-8 -t GBK`，否则中文乱码。
- 脚本内项目路径一律用 `%~dp0` 相对定位，禁止写死绝对路径（Maven 探测路径除外）。
- **所有启动/停止脚本已内置"位置自检"**：脚本所在目录缺少 `package.json` / `pom.xml`（例如用户在 WinRAR 预览窗口里直接双击运行、或只拷出单个 bat）时会明确报错并退出，不会莫名失败。2026-10-12 用户曾因此报"无法启动"——特征是其回传 zip 里出现 `Rar$DIa*` 临时目录产物、`package-lock.json` 被写坏成 95 字节。遇到此类反馈先确认用户是否完整解压了项目。
- 前端接口：`POST /api/auth/send-code | register | login`，统一 `Result` 结构（code/msg/data），axios 拦截器已解包。
- README.md 的项目结构图已过时（缺 `src/api/`、`HomePage.vue`、`RegisterPage.vue`），以本文件为准。
