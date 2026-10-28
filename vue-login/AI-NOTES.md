# AI-NOTES.md（写给 AI 助手 / WorkBuddy 的操作手册）

> 下次开机后用户让你"启动项目"时，**先读这个文件，直接执行，不要重新分析项目结构**。

## 一句话架构

前后端分离登录注册 Demo（学习项目）：

| 模块 | 路径 | 技术栈 | 端口 |
|------|------|--------|------|
| 前端 | `java-main\vue-login`（本目录） | Vue 3 + Vite 5，`/api` 代理到 8080 | 5173 |
| 后端 | `java-main\springboottest`（本目录的兄弟目录） | Spring Boot 3.3.5 + MyBatis-Plus + Java 21 | 8080 |
| 数据库 | 本机 MySQL 8.0 | 库 `user_db`，root / 123456，建库脚本在 `springboottest\sql\user_db.sql` | 3306 |

> 项目可能被整包复制到任意目录（当前在 `C:\Users\Administrator\Desktop\java-main\java-main\`）。
> 所有脚本都用 `%~dp0` 定位，**换目录不需要改脚本**。

## 关键事实（已核实 2026-10-16）

- **⚠️ 换行符坑（2026-10-16 已修复，最容易复发）**：`.bat` 文件**必须是 CRLF 换行**。若文件是 LF（Unix）换行，cmd.exe 解析批处理时会按字节偏移错位，表现为一堆莫名其妙的报错，例如
  `'"FOUND=0"' 不是内部或外部命令`、`'dstr' 不是内部或外部命令`（`findstr` 被吃掉前 3 个字符）、`命令语法不正确`，脚本静默失效（端口杀了但没提示、后端没停掉）。
  用户从 GitHub 下载 zip 得到的副本就会带 LF，因此**每次拿到新的项目副本都要先检查**：
  ```
  python -c "import glob;print([(p,open(p,'rb').read().replace(b'\r\n',b'').count(b'\n')) for p in glob.glob('**/*.bat',recursive=True)])"
  ```
  第二个数字必须全是 0；否则统一转换（见下方维护提醒）。
- **电脑每次开机重置**：`node_modules\` 和 `target\` 会被删除，其余文件保留。启动脚本已内置自动重装/重编译，直接用脚本即可。
- **⚠️ 端口污染坑（2026-10-12 已修复）**：WorkBuddy 桌面端会向环境注入 `SERVER__PORT` / `SERVER__HOST`（值为其内部代理端口 53148 等），Spring Boot 宽松绑定会把它们误读为 `server.port` / `server.address`，导致后端绑定到错误端口且启动失败。启动后端脚本已内置修复：启动前清空这两个变量，并用命令行参数 `--server.port=8080` 显式锁定端口（优先级高于环境变量）。若在其他环境遇到"Port 53148 was already in use"之类的诡异报错，即为此因。
- **Node.js**：WorkBuddy 托管版 `C:\Users\Administrator\.workbuddy\binaries\node\versions\22.22.2-2`（v22，npm 在 PATH），系统版在 `D:\Program Files\nodejs`（v20）。两者都能跑。
- **Java**：`C:\Program Files\Zulu\zulu-21`（在 PATH）。
- **⚠️ 局域网 IP 配置（2026-10-28 起）**：前后端统一走本机局域网 IP `192.168.68.27`（不再是 localhost）：
  - 后端数据源：`springboottest\src\main\resources\application.yml` 的 JDBC URL（`192.168.68.27:3306`）。
  - 前端代理与监听：`vue-login\vite.config.js` 顶部 `LAN_IP` 常量 + `server.host: '0.0.0.0'`。**换 IP 只需改这一处常量 + application.yml 的 URL**。
  - MySQL：`root` 原本仅 `@localhost`，已新建 `root@'%'`（同密码 123456），否则按 IP 连库报 `not allowed to connect`。
  - Windows 防火墙：已添加入站放行规则 `springboottest-8080`、`vite-5173`（TCP）。
  - IP 若因 DHCP 变化，需同步改 `vite.config.js` 与 `application.yml` 两处。
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

## 前端页面现状（2026-10-28 起为"King James 个人主页" + 后台管理系统）

- 全站湖人紫（#552583 系）+ 金（#FDB927）暗色主题，皇冠 SVG、23 号角标等元素复用。
- **HomePage（首页，登录后进入）**：King James 展示页。导航 `King James | 首页·生涯荣誉·经典时刻·关于詹姆斯`（锚点滚动 + IntersectionObserver 滚动高亮）；全屏 Hero（AI 图 `public/images/hero-bg.png`，标题 KING JAMES / STRIVE FOR GREATNESS / 「查看生涯荣誉」按钮）；关于三卡（静态）；荣誉卡 6 张（DB 驱动 honor 表）；生涯时间轴 7 节点（组件内 `timeline` 静态数组）；经典时刻图文图集（moment 数据 + 4 张 AI 插画按标题匹配 `imageFor()` + 热词芯片筛选调 `/api/search`）。导航栏右侧有「后台管理」按钮（emit `go-admin`）。
- **后台管理系统（2026-10-28 新增）**：
  - `AdminLoginPage.vue`（仅账密登录无注册）→ `AdminPage.vue`（honor / moment / hot_keyword 三模块表格 CRUD，弹窗表单 + 删除确认）。
  - 后端 `/api/admin/*`：`AdminController`/`AdminService`/`Admin`/`AdminMapper`，除 login 外均需请求头 `Authorization: <token>`（内存 token，后端重启失效）。
  - `admin` 表建表脚本 `springboottest\sql\admin.sql`。账号：`admin/admin123`、`demo@test.com/demo123`（MD5+盐 `@vue-login`，与前台一致）。
  - 前端接口封装 `src/api/admin.js`；App.vue 页面状态机：login/register/home/adminLogin/adminPage。
- 退出登录逻辑未变（清 localStorage 后回登录页）。

## 给 AI 的维护提醒

- **所有 .bat 脚本必须同时满足：GBK 编码 + CRLF 换行**（中文 cmd 默认 chcp 936；LF 换行会让 cmd 解析错位）。编辑后用下面这段一次性修正，改完必须跑一遍自检：
  ```python
  # 在项目根目录执行：GBK + CRLF 一起修
  import glob
  for p in glob.glob('**/*.bat', recursive=True):
      t = open(p, 'rb').read().decode('gbk')
      open(p, 'wb').write(t.encode('gbk').replace(b'\r\n', b'\n').replace(b'\n', b'\r\n'))
  ```
- **新机器 / 新副本首次启动要建库**：MySQL 里若没有 `user_db`，注册接口会报 HTTP 500（后端日志 `Unknown database 'user_db'`）。执行一次即可：
  ```
  "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot -p123456 < springboottest\sql\user_db.sql
  "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot -p123456 < springboottest\sql\home.sql
  "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot -p123456 < springboottest\sql\admin.sql
  ```
  `user_db.sql` 是 `CREATE DATABASE/TABLE IF NOT EXISTS`，重复执行安全；`home.sql`（首页功能三表：honor/moment/hot_keyword，2026-10-16 新增）是 DROP + 重建 + 灌数据，**会重置首页展示数据**，重复执行安全但会还原种子数据；`admin.sql`（后台管理员表，2026-10-28 新增）是 DROP + 重建 + 灌默认账号，重复执行安全。
- **首页后端（2026-10-16 新增）**：实体 `Moment`/`Honor`/`HotKeyword` + 对应 Mapper + `HomeService`/`HomeServiceImpl` + `HomeController`。接口：
  - `GET /api/home` → `{ honors, hotKeywords, moments }`（荣誉/热词/全部时刻，按 sort_order 排序）
  - `GET /api/search?keyword=xxx` → `{ moments, total }`（按年份/标题/描述/标签 LIKE 模糊匹配，空关键词返回全部）
  - moment.tags 存逗号分隔字符串，前端 `toTags()` 拆数组。
- 脚本内项目路径一律用 `%~dp0` 相对定位，禁止写死绝对路径（Maven 探测路径除外）。
- **所有启动/停止脚本已内置"位置自检"**：脚本所在目录缺少 `package.json` / `pom.xml`（例如用户在 WinRAR 预览窗口里直接双击运行、或只拷出单个 bat）时会明确报错并退出，不会莫名失败。2026-10-12 用户曾因此报"无法启动"——特征是其回传 zip 里出现 `Rar$DIa*` 临时目录产物、`package-lock.json` 被写坏成 95 字节。遇到此类反馈先确认用户是否完整解压了项目。
- **2026-10-16 已修复**：从 GitHub 下载的副本里 6 个 `.bat` 全是 LF 换行，导致 `一键启动/停止` 等脚本静默失效（详见上方"换行符坑"）。已全部转 CRLF；`一键启动.bat` 的轮询等待由 `timeout /t 5 /nobreak` 改为 `ping -n 6 127.0.0.1 >nul`（timeout 在 stdin 被重定向时会直接报 "Input redirection is not supported" 而空转）。
- 前端接口：`POST /api/auth/send-code | register | login`、`GET /api/home | /api/search`、`POST /api/admin/login | logout`、`GET /api/admin/data`、`POST /api/admin/honor|moment|hot-keyword`（body 带 id 更新不带新增）、`DELETE /api/admin/honor|moment|hot-keyword/{id}`，统一 `Result` 结构（code/msg/data），axios 拦截器已解包。
- README.md 的项目结构图已过时（缺 `src/api/`、`HomePage.vue`、`RegisterPage.vue`），以本文件为准。
