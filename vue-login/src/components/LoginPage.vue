<script setup>
import { ref, onUnmounted } from 'vue'

// 表单状态
const account = ref('')
const password = ref('')
const code = ref('')
const remember = ref(false)
const showPassword = ref(false)

// 提示信息
const message = ref('')
const msgType = ref('') // '' | 'error' | 'success'

// 验证码倒计时
const countdown = ref(0)
let timer = null

function showMsg(text, type) {
  message.value = text
  msgType.value = type || ''
}

// 显示 / 隐藏密码
function togglePassword() {
  showPassword.value = !showPassword.value
}

// 获取验证码（60s 倒计时）
function sendCode() {
  if (countdown.value > 0) return
  if (!account.value.trim()) {
    showMsg('请先输入手机号或邮箱', 'error')
    return
  }
  countdown.value = 60
  showMsg('验证码已发送，请查收', 'success')
  timer = setInterval(() => {
    countdown.value -= 1
    if (countdown.value <= 0) {
      clearInterval(timer)
      timer = null
    }
  }, 1000)
}

// 提交校验
function handleSubmit() {
  const acc = account.value.trim()
  const pwd = password.value.trim()
  const cd = code.value.trim()

  if (!acc) {
    showMsg('请输入手机号或邮箱', 'error')
    return
  }
  if (!pwd) {
    showMsg('请输入密码', 'error')
    return
  }
  if (pwd.length < 6 || pwd.length > 20) {
    showMsg('密码长度需为 6–20 位', 'error')
    return
  }
  if (!cd) {
    showMsg('请输入验证码', 'error')
    return
  }

  showMsg('登录成功，正在跳转…', 'success')
  // 此处可对接后端登录接口
}

// 第三方登录占位
function oauth(name) {
  showMsg('正在跳转到 ' + name + ' 登录…', 'success')
}

// 组件卸载时清理定时器
onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-header">
        <h1>欢迎登录</h1>
        <p>登录到您的账户</p>
      </div>

      <div class="msg" :class="msgType">{{ message }}</div>

      <form class="login-form" @submit.prevent="handleSubmit" autocomplete="off">
        <div class="field">
          <label for="account">手机号 / 邮箱</label>
          <div class="input-wrap">
            <input id="account" type="text" v-model="account" placeholder="请输入手机号或邮箱" />
          </div>
        </div>

        <div class="field">
          <label for="password">密码</label>
          <div class="input-wrap">
            <input
              id="password"
              :type="showPassword ? 'text' : 'password'"
              v-model="password"
              placeholder="请输入密码"
            />
            <span class="toggle-pwd" @click="togglePassword">
              {{ showPassword ? '隐藏密码' : '显示密码' }}
            </span>
          </div>
        </div>

        <div class="field">
          <label for="code">验证码</label>
          <div class="code-row">
            <input id="code" type="text" v-model="code" placeholder="请输入验证码" maxlength="6" />
            <button type="button" class="code-btn" :disabled="countdown > 0" @click="sendCode">
              {{ countdown > 0 ? countdown + 's' : '获取验证码' }}
            </button>
          </div>
        </div>

        <div class="row-between">
          <label class="remember">
            <input type="checkbox" v-model="remember" /> 记住我
          </label>
          <a href="#" class="link" @click.prevent>忘记密码？</a>
        </div>

        <button type="submit" class="submit-btn">登 录</button>
      </form>

      <div class="register-tip">
        还没有账号？<a href="#" class="link" @click.prevent>立即注册</a>
      </div>

      <div class="divider"><span>其他方式登录</span></div>
      <div class="oauth">
        <button title="使用微信登录" @click="oauth('微信')">微</button>
        <button title="使用 QQ 登录" @click="oauth('QQ')">Q</button>
        <button title="使用 Google 账号登录" @click="oauth('Google')">G</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #333;
}

.login-card {
  width: 380px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.25);
  padding: 40px 34px 34px;
}

.login-header {
  text-align: center;
  margin-bottom: 28px;
}
.login-header h1 {
  font-size: 24px;
  font-weight: 700;
  color: #2d2d44;
}
.login-header p {
  font-size: 13px;
  color: #999;
  margin-top: 6px;
}

.field {
  margin-bottom: 18px;
}
.field label {
  display: block;
  font-size: 13px;
  color: #666;
  margin-bottom: 7px;
}
.input-wrap {
  position: relative;
}
.input-wrap input {
  width: 100%;
  height: 44px;
  padding: 0 14px;
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s;
}
.input-wrap input:focus {
  border-color: #667eea;
}
.input-wrap .toggle-pwd {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 12px;
  color: #888;
  cursor: pointer;
  user-select: none;
}

.code-row {
  display: flex;
  gap: 10px;
}
.code-row input {
  flex: 1;
}
.code-btn {
  width: 110px;
  flex-shrink: 0;
  border: 1px solid #667eea;
  background: #fff;
  color: #667eea;
  border-radius: 8px;
  font-size: 13px;
  cursor: pointer;
  transition: 0.2s;
}
.code-btn:hover:not(:disabled) {
  background: #667eea;
  color: #fff;
}
.code-btn:disabled {
  border-color: #ccc;
  color: #bbb;
  cursor: not-allowed;
}

.row-between {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 6px 0 22px;
  font-size: 13px;
}
.remember {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #666;
  cursor: pointer;
}
.remember input {
  width: 15px;
  height: 15px;
  accent-color: #667eea;
}
.link {
  color: #667eea;
  text-decoration: none;
}
.link:hover {
  text-decoration: underline;
}

.submit-btn {
  width: 100%;
  height: 46px;
  border: none;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.2s;
}
.submit-btn:hover {
  opacity: 0.92;
}

.register-tip {
  text-align: center;
  font-size: 13px;
  color: #888;
  margin-top: 18px;
}

.divider {
  display: flex;
  align-items: center;
  margin: 22px 0 18px;
  color: #bbb;
  font-size: 12px;
}
.divider::before,
.divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: #eee;
}
.divider span {
  padding: 0 12px;
}

.oauth {
  display: flex;
  justify-content: center;
  gap: 16px;
}
.oauth button {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 1px solid #eee;
  background: #fafafa;
  font-size: 18px;
  cursor: pointer;
  transition: 0.2s;
}
.oauth button:hover {
  background: #f0f0f5;
}

.msg {
  font-size: 13px;
  min-height: 18px;
  margin-bottom: 12px;
  text-align: center;
}
.msg.error {
  color: #e74c3c;
}
.msg.success {
  color: #2ecc71;
}
</style>
