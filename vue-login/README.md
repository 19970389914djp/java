# vue-login

基于 Vue 3 + Vite 的登录界面项目（由 `login.html` 转换而来）。

## 项目结构

```
vue-login/
├── index.html              # 入口 HTML
├── package.json            # 依赖与脚本
├── vite.config.js          # Vite 配置
└── src/
    ├── main.js             # 应用入口，挂载 App
    ├── style.css           # 全局样式重置
    ├── App.vue             # 根组件
    └── components/
        └── LoginPage.vue   # 登录页面（模板 + 逻辑 + scoped 样式）
```

## 功能

- 手机号 / 邮箱、密码、验证码输入
- 密码显示 / 隐藏切换
- 获取验证码（60 秒倒计时）
- 表单校验：非空、密码长度 6–20 位、验证码必填
- 错误 / 成功提示文案
- 记住我、忘记密码、立即注册占位链接
- 第三方登录占位（微信 / QQ / Google）

## 开发

```bash
npm install      # 安装依赖
npm run dev      # 启动开发服务器（默认 http://localhost:5173）
```

## 构建

```bash
npm run build    # 产出到 dist/
npm run preview  # 本地预览构建产物
```

> 提交校验通过后仅显示「登录成功，正在跳转…」提示，可在此处对接后端登录接口。
