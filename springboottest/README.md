# springboottest —— Vue 登录/注册演示后端

Spring Boot 3.3.5 + MyBatis-Plus 3.5.7 + MySQL 8.0，配合前端项目 `桌面/vue-login` 使用。

## 技术栈

- Spring Boot 3.3.5（Java 17+，本机使用 Zulu JDK 21）
- MyBatis-Plus 3.5.7（数据层）
- MySQL 8.0（本机 root / 123456）

## 项目结构

```
springboottest/
├── pom.xml
├── sql/
│   └── user_db.sql                  # 建库建表脚本（已在本机执行过）
└── src/main/
    ├── java/com/example/springboottest/
    │   ├── SpringBootTestApplication.java   # 启动类
    │   ├── common/Result.java               # 统一响应
    │   ├── config/CorsConfig.java           # 跨域配置
    │   ├── controller/AuthController.java   # /api/auth 接口
    │   ├── entity/User.java                 # 用户实体
    │   ├── mapper/UserMapper.java           # MyBatis-Plus BaseMapper
    │   └── service/                         # 业务层（验证码/注册/登录）
    └── resources/application.yml            # 端口 8080、数据源配置
```

## 接口一览

| 方法 | 路径 | 请求体 | 说明 |
| --- | --- | --- | --- |
| POST | /api/auth/send-code | `{"target":"邮箱"}` | 发送验证码（开发模式：验证码随响应 `data.code` 返回并打印到控制台，5 分钟有效） |
| POST | /api/auth/register | `{"email":"...","password":"...","code":"..."}` | 邮箱注册（仅支持邮箱，密码 6–20 位，MD5+盐存储） |
| POST | /api/auth/login | `{"account":"...","password":"...","code":"..."}` | 登录，成功返回 token 与 userInfo |

统一响应：`{"code":200,"msg":"...","data":{...}}`，`code=200` 表示成功。

## 启动方式（IDEA）

1. 确认本机 MySQL 已启动（root / 123456）。
2. 首次使用先执行建库脚本（已执行过可跳过）：
   ```
   "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot -p123456 < sql/user_db.sql
   ```
3. 用 IDEA 打开 `springboottest` 文件夹，等待 Maven 依赖下载完成。
4. 运行 `SpringBootTestApplication` 的 `main` 方法，服务监听 **8080** 端口。

## 前端联调

前端项目在 `springboottest` 的兄弟目录 `vue-login`（随项目一起，位于 `java-main/` 下）：

```
cd <项目目录>\vue-login
npm install
npm run dev
```

> 推荐直接用 `vue-login\一键启动.bat`，会自动先后端再前端并等待就绪，无需手敲命令。

前端通过 Vite 代理把 `/api/**` 转发到 `http://localhost:8080`（配置见 `vue-login/vite.config.js`），浏览器访问 http://localhost:5173/ 即可体验完整的注册→登录流程。

> 说明：本项目为学习用途，验证码存于内存（重启失效），token 为简易 UUID。生产环境建议接入 Redis 存储验证码、真实邮件服务和 JWT。
