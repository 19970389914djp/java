<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { getHome, searchMoments } from '../api/home'

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
  loadHome()
})

function logout() {
  localStorage.removeItem('token')
  localStorage.removeItem('userInfo')
  emit('logout')
}

// ===== 导航栏（纯前端切换，暂未接路由） =====
const navItems = ['首页', '球队', '赛程', '数据', '商城']
const activeNav = ref('首页')
function switchNav(item) {
  activeNav.value = item
}

// ===== 首页数据（来自后端 GET /api/home）=====
const stats = ref([])        // 生涯荣誉卡
const hotKeywords = ref([])  // 热门搜索词
const allMoments = ref([])   // 全部高光时刻（无关键词时展示）
const moments = ref([])      // 当前展示的时刻列表（搜索结果）
const loadError = ref('')    // 加载失败提示

function toTags(tagsStr) {
  return (tagsStr || '').split(',').map((t) => t.trim()).filter(Boolean)
}

async function loadHome() {
  try {
    loadError.value = ''
    const res = await getHome()
    stats.value = res.data.honors || []
    hotKeywords.value = res.data.hotKeywords || []
    allMoments.value = (res.data.moments || []).map((m) => ({ ...m, tags: toTags(m.tags) }))
    moments.value = allMoments.value
  } catch (e) {
    loadError.value = '首页数据加载失败：' + (e.message || '网络异常')
  }
}

// ===== 搜索栏（调用后端 GET /api/search?keyword=xxx，输入防抖 300ms）=====
const keyword = ref('')
let searchTimer = null
let searchSeq = 0 // 竞态序号：只认最后一次请求的结果

async function doSearch(k) {
  const seq = ++searchSeq
  try {
    const res = await searchMoments(k)
    if (seq !== searchSeq) return // 已有更新的请求，丢弃本次结果
    moments.value = (res.data.moments || []).map((m) => ({ ...m, tags: toTags(m.tags) }))
  } catch (e) {
    if (seq === searchSeq) {
      loadError.value = '搜索失败：' + (e.message || '网络异常')
    }
  }
}

watch(keyword, (k) => {
  clearTimeout(searchTimer)
  const kw = (k || '').trim()
  if (!kw) {
    // 清空关键词：直接回到全量列表，不发请求
    searchSeq++
    moments.value = allMoments.value
    return
  }
  searchTimer = setTimeout(() => doSearch(kw), 300)
})

onUnmounted(() => clearTimeout(searchTimer))

function setKeyword(k) {
  keyword.value = keyword.value === k ? '' : k
}

const filteredMoments = computed(() => moments.value)
</script>

<template>
  <div class="home-page">
    <div class="watermark" aria-hidden="true">23</div>

    <!-- ===== 导航栏 ===== -->
    <header class="navbar">
      <div class="brand">
        <svg class="crown" viewBox="0 0 64 44" aria-hidden="true">
          <path d="M6 30 L10 9 L22 19 L32 4 L42 19 L54 9 L58 30 Z" />
          <circle cx="10" cy="9" r="2.6" />
          <circle cx="32" cy="4" r="2.6" />
          <circle cx="54" cy="9" r="2.6" />
          <rect x="6" y="33" width="52" height="5" rx="2.5" />
        </svg>
        <span class="brand-name">紫金王朝</span>
      </div>

      <nav class="nav-links">
        <a
          v-for="item in navItems"
          :key="item"
          href="#"
          class="nav-item"
          :class="{ active: activeNav === item }"
          @click.prevent="switchNav(item)"
        >
          {{ item }}
        </a>
      </nav>

      <div class="user-area">
        <div class="avatar">{{ (userInfo.nickname || 'U').charAt(0).toUpperCase() }}</div>
        <span class="nickname">{{ userInfo.nickname || '用户' }}</span>
        <button class="logout-btn" @click="logout">退出</button>
      </div>
    </header>

    <main class="main">
      <!-- ===== 加载失败提示 ===== -->
      <div v-if="loadError" class="load-error">{{ loadError }}</div>

      <!-- ===== 搜索区 ===== -->
      <section class="hero">
        <div class="overline">WELCOME TO THE COURT</div>
        <h1>见证伟大</h1>
        <p class="sub">STRIVE FOR GREATNESS · 搜索国王生涯的高光时刻</p>

        <div class="search-bar">
          <svg class="search-icon" viewBox="0 0 24 24" aria-hidden="true">
            <circle cx="11" cy="11" r="7" fill="none" stroke-width="2" />
            <line x1="16.5" y1="16.5" x2="21" y2="21" stroke-width="2" />
          </svg>
          <input
            v-model="keyword"
            type="text"
            placeholder="搜索：年份 / 球队 / 名场面，例如 2016、湖人、翻盘…"
          />
          <button class="search-btn" @click="doSearch(keyword.trim())">搜索</button>
        </div>

        <div class="hot-keywords">
          <span class="hot-label">热门：</span>
          <a
            v-for="k in hotKeywords"
            :key="k"
            href="#"
            class="chip"
            :class="{ on: keyword === k }"
            @click.prevent="setKeyword(keyword === k ? '' : k)"
          >
            {{ k }}
          </a>
        </div>
      </section>

      <!-- ===== 生涯荣誉 ===== -->
      <section class="stats">
        <div v-for="s in stats" :key="s.label" class="stat-card">
          <div class="stat-value">{{ s.value }}</div>
          <div class="stat-label">{{ s.label }}</div>
        </div>
      </section>

      <!-- ===== 高光时刻（搜索结果） ===== -->
      <section class="moments">
        <div class="section-head">
          <h2>高光时刻</h2>
          <span class="count" v-if="keyword.trim()">「{{ keyword.trim() }}」命中 {{ filteredMoments.length }} 条</span>
        </div>

        <div v-if="filteredMoments.length" class="moment-grid">
          <article v-for="(m, i) in filteredMoments" :key="i" class="moment-card">
            <div class="moment-year">{{ m.year }}</div>
            <h3>{{ m.title }}</h3>
            <p>{{ m.description }}</p>
            <div class="moment-tags">
              <span v-for="t in m.tags" :key="t" class="tag"># {{ t }}</span>
            </div>
          </article>
        </div>

        <div v-else class="empty">
          <div class="empty-title">没有找到「{{ keyword.trim() }}」相关内容</div>
          <p>换个关键词试试，比如：湖人、2016、总冠军</p>
        </div>
      </section>
    </main>

    <footer class="footer">
      STRIVE FOR GREATNESS · 紫金王朝 · 数据由后端接口提供（/api/home、/api/search）
    </footer>
  </div>
</template>

<style scoped>
/* ===== 背景：与登录/注册同族的球场 ===== */
.home-page {
  position: relative;
  overflow: hidden;
  min-height: 100vh;
  color: #f5f0ff;
  background:
    radial-gradient(1000px 560px at 12% -10%, rgba(253, 185, 39, 0.14), transparent 60%),
    radial-gradient(900px 640px at 110% 112%, rgba(85, 37, 131, 0.6), transparent 55%),
    linear-gradient(150deg, #2a1450 0%, #1a0b2e 45%, #0e0619 100%);
}
.home-page::before {
  content: '';
  position: absolute;
  left: 50%;
  top: 46%;
  width: 720px;
  height: 720px;
  border: 1px solid rgba(253, 185, 39, 0.09);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
}
.watermark {
  position: absolute;
  right: -56px;
  top: 120px;
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 380px;
  line-height: 1;
  letter-spacing: -12px;
  color: transparent;
  -webkit-text-stroke: 2px rgba(253, 185, 39, 0.1);
  transform: rotate(-8deg);
  pointer-events: none;
  user-select: none;
}

/* ===== 导航栏 ===== */
.navbar {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  gap: 28px;
  height: 64px;
  padding: 0 32px;
  background: rgba(14, 6, 25, 0.85);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  border-bottom: 1px solid rgba(253, 185, 39, 0.25);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.35);
}
.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}
.crown {
  width: 34px;
  height: auto;
  fill: #fdb927;
  filter: drop-shadow(0 0 10px rgba(253, 185, 39, 0.5));
}
.brand-name {
  font-size: 18px;
  font-weight: 800;
  letter-spacing: 3px;
  color: #fdb927;
}

.nav-links {
  display: flex;
  gap: 6px;
  flex: 1;
  justify-content: center;
}
.nav-item {
  position: relative;
  padding: 8px 18px;
  font-size: 14px;
  letter-spacing: 2px;
  color: rgba(245, 240, 255, 0.65);
  text-decoration: none;
  border-radius: 8px;
  transition: color 0.2s, background 0.2s;
}
.nav-item:hover {
  color: #fdb927;
}
.nav-item.active {
  color: #fdb927;
  background: rgba(253, 185, 39, 0.1);
}
.nav-item.active::after {
  content: '';
  position: absolute;
  left: 50%;
  bottom: -1px;
  width: 22px;
  height: 2px;
  background: #fdb927;
  border-radius: 1px;
  transform: translateX(-50%);
}

.user-area {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}
.avatar {
  width: 34px;
  height: 34px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: linear-gradient(135deg, #552583, #7a3fbf);
  border: 1px solid rgba(253, 185, 39, 0.5);
  color: #fdb927;
  font-size: 15px;
  font-weight: 700;
}
.nickname {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 13px;
  color: rgba(245, 240, 255, 0.8);
}
.logout-btn {
  height: 34px;
  padding: 0 16px;
  border: 1px solid rgba(253, 185, 39, 0.55);
  border-radius: 8px;
  background: transparent;
  color: #fdb927;
  font-size: 13px;
  cursor: pointer;
  transition: 0.2s;
}
.logout-btn:hover {
  background: #fdb927;
  color: #241043;
}

/* ===== 主体 ===== */
.main {
  position: relative;
  z-index: 1;
  max-width: 1080px;
  margin: 0 auto;
  padding: 64px 32px 40px;
}

.load-error {
  margin-bottom: 20px;
  padding: 12px 18px;
  border: 1px solid rgba(255, 99, 99, 0.5);
  border-radius: 10px;
  background: rgba(120, 20, 40, 0.35);
  color: #ffb3b3;
  font-size: 13px;
  text-align: center;
}

/* ===== 搜索区 ===== */
.hero {
  text-align: center;
  margin-bottom: 48px;
}
.overline {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 7px;
  text-indent: 7px;
  color: #fdb927;
}
.hero h1 {
  margin-top: 12px;
  font-size: 44px;
  font-weight: 900;
  letter-spacing: 10px;
  text-indent: 10px;
  color: #fff;
  text-shadow: 0 2px 24px rgba(253, 185, 39, 0.3);
}
.hero .sub {
  margin-top: 12px;
  font-size: 13px;
  letter-spacing: 1px;
  color: rgba(245, 240, 255, 0.55);
}

.search-bar {
  display: flex;
  align-items: center;
  max-width: 640px;
  margin: 30px auto 0;
  height: 56px;
  padding: 0 6px 0 18px;
  background: rgba(26, 12, 46, 0.75);
  border: 1px solid rgba(253, 185, 39, 0.4);
  border-radius: 14px;
  box-shadow: 0 14px 40px rgba(0, 0, 0, 0.4), 0 0 30px rgba(253, 185, 39, 0.08);
  transition: border-color 0.2s, box-shadow 0.2s;
}
.search-bar:focus-within {
  border-color: #fdb927;
  box-shadow: 0 14px 44px rgba(0, 0, 0, 0.45), 0 0 0 4px rgba(253, 185, 39, 0.12);
}
.search-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
  stroke: rgba(253, 185, 39, 0.8);
  fill: none;
}
.search-bar input {
  flex: 1;
  height: 100%;
  padding: 0 14px;
  border: none;
  background: transparent;
  color: #fff;
  font-size: 14px;
  outline: none;
}
.search-bar input::placeholder {
  color: rgba(245, 240, 255, 0.32);
}
.search-btn {
  height: 42px;
  padding: 0 26px;
  border: none;
  border-radius: 10px;
  background: linear-gradient(135deg, #fdb927 0%, #e9a51f 100%);
  color: #241043;
  font-size: 14px;
  font-weight: 800;
  letter-spacing: 4px;
  text-indent: 4px;
  cursor: pointer;
  transition: filter 0.2s;
}
.search-btn:hover {
  filter: brightness(1.06);
}

.hot-keywords {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  margin-top: 16px;
  flex-wrap: wrap;
}
.hot-label {
  font-size: 12px;
  color: rgba(245, 240, 255, 0.45);
}
.chip {
  padding: 4px 14px;
  border: 1px solid rgba(140, 110, 190, 0.4);
  border-radius: 999px;
  font-size: 12px;
  color: rgba(245, 240, 255, 0.65);
  text-decoration: none;
  transition: 0.2s;
}
.chip:hover {
  border-color: rgba(253, 185, 39, 0.6);
  color: #fdb927;
}
.chip.on {
  border-color: #fdb927;
  background: rgba(253, 185, 39, 0.12);
  color: #fdb927;
}

/* ===== 生涯荣誉 ===== */
.stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 48px;
}
.stat-card {
  padding: 22px 12px;
  text-align: center;
  background: rgba(26, 12, 46, 0.62);
  border: 1px solid rgba(253, 185, 39, 0.22);
  border-radius: 14px;
  transition: transform 0.2s, border-color 0.2s;
}
.stat-card:hover {
  transform: translateY(-3px);
  border-color: rgba(253, 185, 39, 0.5);
}
.stat-value {
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 28px;
  color: #fdb927;
  text-shadow: 0 0 18px rgba(253, 185, 39, 0.35);
}
.stat-label {
  margin-top: 8px;
  font-size: 12px;
  letter-spacing: 2px;
  color: rgba(245, 240, 255, 0.6);
}

/* ===== 高光时刻 ===== */
.section-head {
  display: flex;
  align-items: baseline;
  gap: 14px;
  margin-bottom: 18px;
}
.section-head h2 {
  font-size: 20px;
  font-weight: 800;
  letter-spacing: 3px;
  color: #fff;
}
.count {
  font-size: 12px;
  color: #fdb927;
}

.moment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}
.moment-card {
  padding: 20px 20px 18px;
  background: rgba(26, 12, 46, 0.62);
  border: 1px solid rgba(140, 110, 190, 0.28);
  border-radius: 14px;
  transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
}
.moment-card:hover {
  transform: translateY(-3px);
  border-color: rgba(253, 185, 39, 0.5);
  box-shadow: 0 14px 36px rgba(0, 0, 0, 0.35);
}
.moment-year {
  display: inline-block;
  padding: 2px 10px;
  margin-bottom: 12px;
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 12px;
  color: #241043;
  background: linear-gradient(135deg, #fdb927, #e9a51f);
  border-radius: 6px;
}
.moment-card h3 {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 1px;
  color: #fff;
}
.moment-card p {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.7;
  color: rgba(245, 240, 255, 0.62);
}
.moment-tags {
  display: flex;
  gap: 8px;
  margin-top: 14px;
  flex-wrap: wrap;
}
.tag {
  font-size: 11px;
  color: rgba(253, 185, 39, 0.8);
  background: rgba(253, 185, 39, 0.08);
  border: 1px solid rgba(253, 185, 39, 0.25);
  border-radius: 999px;
  padding: 2px 10px;
}

.empty {
  padding: 60px 20px;
  text-align: center;
  border: 1px dashed rgba(140, 110, 190, 0.35);
  border-radius: 14px;
  background: rgba(26, 12, 46, 0.4);
}
.empty-title {
  font-size: 16px;
  font-weight: 700;
  color: rgba(245, 240, 255, 0.85);
}
.empty p {
  margin-top: 10px;
  font-size: 13px;
  color: rgba(245, 240, 255, 0.5);
}

/* ===== 页脚 ===== */
.footer {
  position: relative;
  z-index: 1;
  padding: 26px 32px 30px;
  text-align: center;
  font-size: 12px;
  letter-spacing: 2px;
  color: rgba(245, 240, 255, 0.35);
  border-top: 1px solid rgba(253, 185, 39, 0.12);
}

/* ===== 小屏适配 ===== */
@media (max-width: 860px) {
  .nav-links {
    display: none;
  }
  .stats {
    grid-template-columns: repeat(2, 1fr);
  }
  .hero h1 {
    font-size: 32px;
    letter-spacing: 6px;
  }
  .watermark {
    font-size: 240px;
  }
}
@media (max-width: 480px) {
  .navbar {
    padding: 0 16px;
  }
  .main {
    padding: 40px 16px 32px;
  }
  .nickname {
    display: none;
  }
  .search-bar {
    height: 50px;
  }
}
</style>
