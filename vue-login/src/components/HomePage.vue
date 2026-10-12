<script setup>
import { ref, onMounted } from 'vue'

const emit = defineEmits(['logout'])

const userInfo = ref({ nickname: '', email: '' })

onMounted(() => {
  try {
    const raw = localStorage.getItem('userInfo')
    if (raw) {
      userInfo.value = JSON.parse(raw)
    }
  } catch {
    // 忽略解析异常
  }
})

function logout() {
  localStorage.removeItem('token')
  localStorage.removeItem('userInfo')
  emit('logout')
}
</script>

<template>
  <div class="home-page">
    <div class="home-card">
      <div class="avatar">{{ (userInfo.nickname || 'U').charAt(0).toUpperCase() }}</div>
      <h1>欢迎回来，{{ userInfo.nickname || '用户' }}</h1>
      <p class="sub">您已成功登录系统</p>

      <div class="info-box">
        <div class="info-row">
          <span class="label">邮箱</span>
          <span class="value">{{ userInfo.email || '-' }}</span>
        </div>
        <div class="info-row">
          <span class="label">用户 ID</span>
          <span class="value">{{ userInfo.id ?? '-' }}</span>
        </div>
      </div>

      <button class="logout-btn" @click="logout">退出登录</button>
    </div>
  </div>
</template>

<style scoped>
.home-page {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #333;
}

.home-card {
  width: 380px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.25);
  padding: 40px 34px 34px;
  text-align: center;
}

.avatar {
  width: 72px;
  height: 72px;
  margin: 0 auto 18px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  font-size: 30px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

h1 {
  font-size: 22px;
  font-weight: 700;
  color: #2d2d44;
}

.sub {
  font-size: 13px;
  color: #999;
  margin-top: 6px;
}

.info-box {
  margin: 24px 0;
  border: 1px solid #eee;
  border-radius: 10px;
  overflow: hidden;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 12px 16px;
  font-size: 13px;
}
.info-row + .info-row {
  border-top: 1px solid #eee;
}
.info-row .label {
  color: #999;
}
.info-row .value {
  color: #333;
  font-weight: 500;
}

.logout-btn {
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
.logout-btn:hover {
  opacity: 0.92;
}
</style>
