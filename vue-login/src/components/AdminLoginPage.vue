<script setup>
import { ref } from 'vue'
import { adminLogin } from '../api/admin'

const emit = defineEmits(['go-home', 'login-success'])

const username = ref('')
const password = ref('')
const showPassword = ref(false)

const message = ref('')
const msgType = ref('') // '' | 'error' | 'success'
const loading = ref(false)

function showMsg(text, type) {
  message.value = text
  msgType.value = type || ''
}

function togglePassword() {
  showPassword.value = !showPassword.value
}

async function handleSubmit() {
  const acc = username.value.trim()
  const pwd = password.value.trim()

  if (!acc) {
    showMsg('请输入账号', 'error')
    return
  }
  if (!pwd) {
    showMsg('请输入密码', 'error')
    return
  }

  loading.value = true
  try {
    const res = await adminLogin({ username: acc, password: pwd })
    if (res.code !== 200) {
      showMsg(res.msg || '登录失败', 'error')
      return
    }
    localStorage.setItem('adminToken', res.data.token)
    localStorage.setItem('adminUsername', res.data.username)
    showMsg('登录成功，正在进入后台…', 'success')
    setTimeout(() => emit('login-success'), 600)
  } catch (e) {
    showMsg(e.message, 'error')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="admin-login-page">
    <div class="watermark" aria-hidden="true">ADMIN</div>
    <div class="login-card">
        <div class="login-header">
          <div class="overline">MANAGEMENT</div>
          <h1>后台管理登录</h1>
          <p>仅限管理员权限账号（permission=0）登录</p>
        </div>

        <div class="msg" :class="msgType">{{ message }}</div>

        <form class="login-form" @submit.prevent="handleSubmit" autocomplete="off">
          <div class="field">
            <label for="admin-account">账号（邮箱）</label>
            <div class="input-wrap">
              <input id="admin-account" type="text" v-model="username" placeholder="请输入管理员邮箱" />
            </div>
          </div>

        <div class="field">
          <label for="admin-password">密码</label>
          <div class="input-wrap">
            <input
              id="admin-password"
              :type="showPassword ? 'text' : 'password'"
              v-model="password"
              placeholder="请输入密码"
            />
            <span class="toggle-pwd" @click="togglePassword">
              {{ showPassword ? '隐藏密码' : '显示密码' }}
            </span>
          </div>
        </div>

        <button type="submit" class="submit-btn" :disabled="loading">
          {{ loading ? '登录中…' : '登 录' }}
        </button>
      </form>

      <div class="back-tip">
        <a href="#" class="link" @click.prevent="emit('go-home')">← 返回首页</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 与前台登录页保持同一湖人紫 + 金主题 */
.admin-login-page {
  position: relative;
  overflow: hidden;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #f5f0ff;
  background:
    radial-gradient(900px 520px at 15% -10%, rgba(253, 185, 39, 0.16), transparent 60%),
    radial-gradient(820px 620px at 110% 112%, rgba(85, 37, 131, 0.6), transparent 55%),
    linear-gradient(150deg, #2a1450 0%, #1a0b2e 45%, #0e0619 100%);
}
.watermark {
  position: absolute;
  right: -40px;
  bottom: -60px;
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 220px;
  line-height: 1;
  letter-spacing: -8px;
  color: transparent;
  -webkit-text-stroke: 2px rgba(253, 185, 39, 0.1);
  transform: rotate(-6deg);
  pointer-events: none;
  user-select: none;
}
.login-card {
  position: relative;
  width: 380px;
  padding: 42px 34px 34px;
  background: rgba(26, 12, 46, 0.82);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  border: 1px solid rgba(253, 185, 39, 0.35);
  border-radius: 18px;
  box-shadow:
    0 24px 70px rgba(0, 0, 0, 0.55),
    inset 0 0 0 1px rgba(255, 255, 255, 0.03),
    0 0 46px rgba(253, 185, 39, 0.07);
}
.login-header {
  text-align: center;
  margin-bottom: 26px;
}
.overline {
  margin: 0 0 8px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 7px;
  text-indent: 7px;
  color: #fdb927;
}
.login-header h1 {
  font-size: 26px;
  font-weight: 800;
  letter-spacing: 2px;
  color: #ffffff;
  text-shadow: 0 2px 18px rgba(253, 185, 39, 0.25);
}
.login-header p {
  margin-top: 8px;
  font-size: 12px;
  letter-spacing: 1px;
  color: rgba(245, 240, 255, 0.55);
}
.field {
  margin-bottom: 18px;
}
.field label {
  display: block;
  font-size: 13px;
  color: rgba(245, 240, 255, 0.62);
  margin-bottom: 7px;
}
.input-wrap {
  position: relative;
}
.input-wrap input {
  width: 100%;
  height: 44px;
  padding: 0 14px;
  border: 1px solid rgba(140, 110, 190, 0.35);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}
.input-wrap input::placeholder {
  color: rgba(245, 240, 255, 0.3);
}
.input-wrap input:focus {
  border-color: #fdb927;
  box-shadow: 0 0 0 3px rgba(253, 185, 39, 0.15);
}
.input-wrap .toggle-pwd {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 12px;
  color: rgba(253, 185, 39, 0.75);
  cursor: pointer;
  user-select: none;
}
.toggle-pwd:hover {
  color: #fdb927;
}
.submit-btn {
  width: 100%;
  height: 46px;
  margin-top: 6px;
  border: none;
  border-radius: 10px;
  background: linear-gradient(135deg, #fdb927 0%, #e9a51f 100%);
  color: #241043;
  font-size: 16px;
  font-weight: 800;
  letter-spacing: 6px;
  text-indent: 6px;
  cursor: pointer;
  box-shadow: 0 10px 26px rgba(253, 185, 39, 0.25);
  transition: transform 0.15s, box-shadow 0.2s, filter 0.2s;
}
.submit-btn:hover:not(:disabled) {
  filter: brightness(1.06);
  transform: translateY(-1px);
  box-shadow: 0 14px 32px rgba(253, 185, 39, 0.35);
}
.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}
.back-tip {
  text-align: center;
  font-size: 13px;
  margin-top: 18px;
}
.link {
  color: #fdb927;
  text-decoration: none;
}
.link:hover {
  text-decoration: underline;
}
.msg {
  font-size: 13px;
  min-height: 18px;
  margin-bottom: 12px;
  text-align: center;
}
.msg.error {
  color: #ff7d7d;
}
.msg.success {
  color: #7de8a9;
}
@media (max-width: 480px) {
  .login-card {
    width: calc(100% - 32px);
    padding: 34px 22px 26px;
  }
  .watermark {
    font-size: 120px;
    right: -20px;
    bottom: -34px;
  }
}
</style>
