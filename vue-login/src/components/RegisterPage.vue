<script setup>
import { ref, onUnmounted } from 'vue'
import { sendCode as sendCodeApi, register as registerApi } from '../api/auth'

const emit = defineEmits(['go-login'])

// 表单状态（仅支持邮箱注册，不使用手机号）
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const code = ref('')
const agree = ref(false)
const showPassword = ref(false)
const showConfirmPassword = ref(false)

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

// 邮箱格式校验
function isValidEmail(val) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val)
}

// 显示 / 隐藏密码
function togglePassword() {
  showPassword.value = !showPassword.value
}
function toggleConfirmPassword() {
  showConfirmPassword.value = !showConfirmPassword.value
}

// 获取邮箱验证码（60s 倒计时）
async function sendCode() {
  if (countdown.value > 0) return
  const val = email.value.trim()
  if (!val) {
    showMsg('请先输入邮箱', 'error')
    return
  }
  if (!isValidEmail(val)) {
    showMsg('邮箱格式不正确', 'error')
    return
  }
  try {
    const res = await sendCodeApi(val)
    if (res.code !== 200) {
      showMsg(res.msg || '验证码发送失败', 'error')
      return
    }
    countdown.value = 60
    // 开发模式：后端会随响应返回验证码，自动填入方便调试
    if (res.data?.code) {
      code.value = res.data.code
      showMsg('验证码已发送（开发模式已自动填入）', 'success')
    } else {
      showMsg('验证码已发送至您的邮箱，请查收', 'success')
    }
    timer = setInterval(() => {
      countdown.value -= 1
      if (countdown.value <= 0) {
        clearInterval(timer)
        timer = null
      }
    }, 1000)
  } catch (e) {
    showMsg(e.message, 'error')
  }
}

// 提交校验
async function handleSubmit() {
  const em = email.value.trim()
  const pwd = password.value.trim()
  const cpwd = confirmPassword.value.trim()
  const cd = code.value.trim()

  if (!em) {
    showMsg('请输入邮箱', 'error')
    return
  }
  if (!isValidEmail(em)) {
    showMsg('邮箱格式不正确', 'error')
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
  if (pwd !== cpwd) {
    showMsg('两次输入的密码不一致', 'error')
    return
  }
  if (!cd) {
    showMsg('请输入邮箱验证码', 'error')
    return
  }
  if (!agree.value) {
    showMsg('请先阅读并同意用户协议与隐私政策', 'error')
    return
  }

  try {
    const res = await registerApi({ email: em, password: pwd, code: cd })
    if (res.code !== 200) {
      showMsg(res.msg || '注册失败', 'error')
      return
    }
    showMsg('注册成功，正在跳转到登录…', 'success')
    setTimeout(() => emit('go-login'), 1200)
  } catch (e) {
    showMsg(e.message, 'error')
  }
}

// 组件卸载时清理定时器
onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<template>
  <div class="register-page">
    <div class="watermark" aria-hidden="true">KING</div>
    <div class="register-card">
      <div class="jersey-badge" title="LeBron James · 23">23</div>
      <div class="register-header">
        <svg class="crown" viewBox="0 0 64 44" aria-hidden="true">
          <path d="M6 30 L10 9 L22 19 L32 4 L42 19 L54 9 L58 30 Z" />
          <circle cx="10" cy="9" r="2.6" />
          <circle cx="32" cy="4" r="2.6" />
          <circle cx="54" cy="9" r="2.6" />
          <rect x="6" y="33" width="52" height="5" rx="2.5" />
        </svg>
        <div class="overline">KING JAMES</div>
        <h1>创建账号</h1>
        <p>加入紫金王朝 · EARN YOUR CROWN</p>
      </div>

      <div class="msg" :class="msgType">{{ message }}</div>

      <form class="register-form" @submit.prevent="handleSubmit" autocomplete="off">
        <div class="field">
          <label for="reg-email">邮箱</label>
          <div class="input-wrap">
            <input id="reg-email" type="text" v-model="email" placeholder="请输入邮箱地址" />
          </div>
        </div>

        <div class="field">
          <label for="reg-password">密码</label>
          <div class="input-wrap">
            <input
              id="reg-password"
              :type="showPassword ? 'text' : 'password'"
              v-model="password"
              placeholder="请输入密码（6–20 位）"
            />
            <span class="toggle-pwd" @click="togglePassword">
              {{ showPassword ? '隐藏密码' : '显示密码' }}
            </span>
          </div>
        </div>

        <div class="field">
          <label for="reg-confirm">确认密码</label>
          <div class="input-wrap">
            <input
              id="reg-confirm"
              :type="showConfirmPassword ? 'text' : 'password'"
              v-model="confirmPassword"
              placeholder="请再次输入密码"
            />
            <span class="toggle-pwd" @click="toggleConfirmPassword">
              {{ showConfirmPassword ? '隐藏密码' : '显示密码' }}
            </span>
          </div>
        </div>

        <div class="field">
          <label for="reg-code">邮箱验证码</label>
          <div class="code-row">
            <input id="reg-code" type="text" v-model="code" placeholder="请输入验证码" maxlength="6" />
            <button type="button" class="code-btn" :disabled="countdown > 0" @click="sendCode">
              {{ countdown > 0 ? countdown + 's' : '获取验证码' }}
            </button>
          </div>
        </div>

        <div class="agree-row">
          <label class="agree">
            <input type="checkbox" v-model="agree" />
            我已阅读并同意
            <a href="#" class="link" @click.prevent>《用户协议》</a>
            和
            <a href="#" class="link" @click.prevent>《隐私政策》</a>
          </label>
        </div>

        <button type="submit" class="submit-btn">注 册</button>
      </form>

      <div class="login-tip">
        已有账号？<a href="#" class="link" @click.prevent="emit('go-login')">立即登录</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ===== 背景球场：湖人紫 + 金色聚光（与登录页同族） ===== */
.register-page {
  position: relative;
  overflow: hidden;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #f5f0ff;
  background:
    radial-gradient(900px 520px at 85% -10%, rgba(253, 185, 39, 0.14), transparent 60%),
    radial-gradient(820px 620px at -10% 112%, rgba(85, 37, 131, 0.6), transparent 55%),
    linear-gradient(210deg, #2a1450 0%, #1a0b2e 45%, #0e0619 100%);
}
.register-page::before {
  content: '';
  position: absolute;
  left: 50%;
  top: 50%;
  width: 560px;
  height: 560px;
  border: 1px solid rgba(253, 185, 39, 0.1);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
}
.register-page::after {
  content: '';
  position: absolute;
  left: -100vw;
  right: -100vw;
  top: 50%;
  height: 1px;
  background: rgba(253, 185, 39, 0.08);
  pointer-events: none;
}
/* 巨型 KING 水印 */
.watermark {
  position: absolute;
  left: -56px;
  bottom: -104px;
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 300px;
  line-height: 1;
  letter-spacing: -4px;
  color: transparent;
  -webkit-text-stroke: 2px rgba(253, 185, 39, 0.12);
  transform: rotate(-6deg);
  pointer-events: none;
  user-select: none;
}

/* ===== 卡片 ===== */
.register-card {
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

/* 角标：23 号徽章 */
.jersey-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 42px;
  height: 42px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 17px;
  color: #fdb927;
  background: rgba(253, 185, 39, 0.08);
  border: 1px solid rgba(253, 185, 39, 0.45);
  border-radius: 50%;
  user-select: none;
}

/* ===== 头部 ===== */
.register-header {
  text-align: center;
  margin-bottom: 26px;
}
.crown {
  width: 56px;
  height: auto;
  fill: #fdb927;
  filter: drop-shadow(0 0 12px rgba(253, 185, 39, 0.55));
}
.overline {
  margin: 12px 0 8px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 7px;
  text-indent: 7px;
  color: #fdb927;
}
.register-header h1 {
  font-size: 26px;
  font-weight: 800;
  letter-spacing: 2px;
  color: #ffffff;
  text-shadow: 0 2px 18px rgba(253, 185, 39, 0.25);
}
.register-header p {
  margin-top: 8px;
  font-size: 12px;
  letter-spacing: 1px;
  color: rgba(245, 240, 255, 0.55);
}

/* ===== 表单 ===== */
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

.code-row {
  display: flex;
  gap: 10px;
}
.code-row input {
  flex: 1;
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
.code-row input::placeholder {
  color: rgba(245, 240, 255, 0.3);
}
.code-row input:focus {
  border-color: #fdb927;
  box-shadow: 0 0 0 3px rgba(253, 185, 39, 0.15);
}
.code-btn {
  width: 110px;
  flex-shrink: 0;
  border: 1px solid rgba(253, 185, 39, 0.55);
  background: transparent;
  color: #fdb927;
  border-radius: 10px;
  font-size: 13px;
  cursor: pointer;
  transition: 0.2s;
}
.code-btn:hover:not(:disabled) {
  background: #fdb927;
  color: #241043;
}
.code-btn:disabled {
  border-color: rgba(140, 110, 190, 0.3);
  color: rgba(245, 240, 255, 0.35);
  cursor: not-allowed;
}

.agree-row {
  margin: 6px 0 22px;
  font-size: 13px;
}
.agree {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 4px;
  color: rgba(245, 240, 255, 0.7);
  cursor: pointer;
}
.agree input {
  width: 15px;
  height: 15px;
  accent-color: #fdb927;
  flex-shrink: 0;
}
.link {
  color: #fdb927;
  text-decoration: none;
}
.link:hover {
  text-decoration: underline;
}

/* 金色主按钮 */
.submit-btn {
  width: 100%;
  height: 46px;
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
.submit-btn:hover {
  filter: brightness(1.06);
  transform: translateY(-1px);
  box-shadow: 0 14px 32px rgba(253, 185, 39, 0.35);
}
.submit-btn:active {
  transform: translateY(0);
}

.login-tip {
  text-align: center;
  font-size: 13px;
  color: rgba(245, 240, 255, 0.5);
  margin-top: 18px;
}

/* ===== 提示信息（语义色保留） ===== */
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

/* ===== 小屏适配 ===== */
@media (max-width: 480px) {
  .register-card {
    width: calc(100% - 32px);
    padding: 34px 22px 26px;
  }
  .watermark {
    font-size: 190px;
    left: -34px;
    bottom: -64px;
  }
}
</style>
