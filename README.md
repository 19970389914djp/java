# java

学习记录 java

## 仓库内容

| 目录/文件 | 说明 |
|-----------|------|
| `login.html` | 最初的静态登录页面（海绵宝宝主题） |
| `vue-login/` | 前端：Vue 3 + Vite 登录注册项目（端口 5173，`/api` 代理到后端） |
| `springboottest/` | 后端：Spring Boot 3 + MyBatis-Plus + MySQL（端口 8080） |

## 快速启动（Windows）

每次开机 `node_modules` / `target` 会被清除，脚本已内置自动重装/重编译：

```bat
vue-login\一键启动.bat    :: 一键启动后端(8080) + 前端(5173)
vue-login\一键停止.bat    :: 一键停止
```

也可以分别使用 `启动前端.bat` / `启动后端.bat` / `停止前端.bat` / `停止后端.bat`。

环境要求：Node.js、JDK 21、MySQL（库 `user_db`，建库脚本在 `springboottest/sql/user_db.sql`）、Maven（脚本会自动探测 PATH / IDEA 自带 / wrapper 缓存）。

更多细节见 `vue-login/AI-NOTES.md`。
