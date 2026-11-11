# java

学习记录 java

## 仓库内容

| 目录/文件 | 说明 |
|-----------|------|
| `login.html` | 最初的静态登录页面（海绵宝宝主题） |
| `vue-login/` | 前端：Vue 3 + Vite 登录注册项目（端口 5173，`/api` 代理到后端） |
| `springboottest/` | 后端：Spring Boot 3 + MyBatis-Plus + MySQL（端口 8080） |

## 前端首页（King James 个人主页）

登录后进入的首页是詹姆斯主题展示页，导航栏：`King James | 首页 · 生涯荣誉 · 经典时刻 · 关于詹姆斯`（锚点滚动 + 滚动高亮）。

| 板块 | 内容 | 数据来源 |
|------|------|----------|
| Hero 首屏 | KING JAMES 大标题 + Strive For Greatness + 「查看生涯荣誉」按钮 | 静态 + `public/images/hero-bg.png` |
| 关于詹姆斯 | 阿克伦之子 / NBA 传奇 / 历史得分王 三张简介卡（可点击看详情） | 静态 |
| 生涯荣誉 | 荣誉数字卡片（总冠军、FMVP、MVP、全明星、得分王…，可点击看详情） | 接口 `/api/home` → `honor` 表（后台可改） |
| 生涯时间轴 | 2003 骑士 → 热火首冠 → 回归骑士 2016 夺冠 → 湖人 → 40000 分（可点击看详情） | 静态（`HomePage.vue` 内 `timeline`） |
| 经典时刻 | 图文卡片图集 + 搜索/热词筛选（可点击看详情） | 接口 `/api/home`、`/api/search` → `moment`、`hot_keyword` 表（后台可改） |

### 交互功能

- **全局搜索跳转**：顶部导航栏搜索框，输入关键词（300ms 防抖调 `/api/search`）后自动平滑滚动到「经典时刻」结果区，命中卡片金色高亮 + 脉冲动画，首条结果加强光晕；与板块内搜索框数据同步
- **卡片点击详情**：关于詹姆斯 / 生涯荣誉 / 时间轴 / 经典时刻 四类卡片均可点击，弹出详情弹窗（背景模糊遮罩、缩放动画），支持 × 按钮 / 点击遮罩 / ESC 关闭，支持键盘 Tab + Enter 操作
- 导航栏为吸顶布局，新增搜索框后已做 1100px 响应式断点，各档宽度不折行

配图位于 `vue-login/public/images/`（AI 生成插画），改版预览截图在 `vue-login/preview/`。

## 后台管理系统

- 首页导航栏右侧「后台管理」按钮 → 后台登录页（仅账密登录，无注册）
- 权限控制：`user` 表 `permission` 字段，`1`=默认用户、`0`=管理员
  - 仅 `permission=0` 的账号可在首页看到「后台管理」按钮并登录后台
  - 注册用户默认 `permission=1`，看不到按钮、也无法登录后台
- 内置管理员账号：`admin@test.com` / `admin123`（见 `springboottest/sql/user_db.sql`）
- 密码为明文存储（学习项目，不做加密）；旧 `admin` 表已废弃，仅历史保留
- 可管理首页展示数据：生涯荣誉（honor）、高光时刻（moment）、热门搜索词（hot_keyword）
- 管理接口前缀 `/api/admin/*`，除登录外均需请求头 `Authorization: <token>`

## 快速启动（Windows）

每次开机 `node_modules` / `target` 会被清除，脚本已内置自动重装/重编译：

```bat
vue-login\一键启动.bat    :: 一键启动后端(8080) + 前端(5173)
vue-login\一键停止.bat    :: 一键停止
```

也可以分别使用 `启动前端.bat` / `启动后端.bat` / `停止前端.bat` / `停止后端.bat`。

环境要求：Node.js、JDK 21、MySQL（库 `user_db`，建库脚本在 `springboottest/sql/user_db.sql`）、Maven（脚本会自动探测 PATH / IDEA 自带 / wrapper 缓存）。

更多细节见 `vue-login/AI-NOTES.md`。
