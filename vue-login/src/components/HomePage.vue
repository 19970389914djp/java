<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { getHome, searchMoments } from '../api/home'

const emit = defineEmits(['logout', 'go-admin'])

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
  initScrollSpy()
})

// 滚动到哪个板块就高亮对应导航
let navObserver = null
function initScrollSpy() {
  if (typeof IntersectionObserver === 'undefined') return
  navObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) activeNav.value = e.target.id
      })
    },
    { rootMargin: '-45% 0px -50% 0px' }
  )
  navItems.forEach((i) => {
    const el = document.getElementById(i.key)
    if (el) navObserver.observe(el)
  })
}

function logout() {
  localStorage.removeItem('token')
  localStorage.removeItem('userInfo')
  emit('logout')
}

// ===== 导航栏（锚点滚动） =====
const navItems = [
  { key: 'hero', label: '首页' },
  { key: 'honors', label: '生涯荣誉' },
  { key: 'moments', label: '经典时刻' },
  { key: 'about', label: '关于詹姆斯' }
]
const activeNav = ref('hero')
function goSection(key) {
  activeNav.value = key
  document.getElementById(key)?.scrollIntoView({ behavior: 'smooth' })
}

// ===== 首页数据（来自后端 GET /api/home）=====
const honors = ref([])      // 生涯荣誉卡（数据库驱动，后台可管理）
const hotKeywords = ref([]) // 热门搜索词（图集筛选芯片）
const allMoments = ref([])  // 全部高光时刻（图集数据源）
const moments = ref([])     // 当前展示的时刻列表（筛选结果）
const loadError = ref('')   // 加载失败提示

// 经典时刻配图（AI 生成插画，按内容匹配，未匹配的循环使用）
const IMG_DRAFT = '/images/moment-2003.png'
const IMG_BLOCK = '/images/moment-2016-block.png'
const IMG_TROPHY = '/images/moment-2020.png'
const IMG_40000 = '/images/moment-40000.png'
const galleryImages = [IMG_DRAFT, IMG_TROPHY, IMG_BLOCK, IMG_40000]

function imageFor(m) {
  const t = (m.title || '') + ' ' + (m.year || '') + ' ' + (m.tags || '')
  if (t.includes('2003') || t.includes('天选之子')) return IMG_DRAFT
  if (t.includes('The Block') || t.includes('追身大帽') || t.includes('防守')) return IMG_BLOCK
  if (t.includes('40000') || t.includes('里程碑')) return IMG_40000
  if (/首冠|卫冕|总冠军|紫金|2020/.test(t)) return IMG_TROPHY
  return galleryImages[(m.sortOrder || 0) % galleryImages.length]
}

function toTags(tagsStr) {
  return (tagsStr || '').split(',').map((t) => t.trim()).filter(Boolean)
}

async function loadHome() {
  try {
    loadError.value = ''
    const res = await getHome()
    honors.value = res.data.honors || []
    hotKeywords.value = res.data.hotKeywords || []
    allMoments.value = (res.data.moments || []).map((m) => ({ ...m, tags: toTags(m.tags) }))
    moments.value = allMoments.value
  } catch (e) {
    loadError.value = '首页数据加载失败：' + (e.message || '网络异常')
  }
}

// ===== 经典时刻筛选（调用后端 GET /api/search?keyword=xxx，输入防抖 300ms）=====
const keyword = ref('')
let searchTimer = null
let searchSeq = 0 // 竞态序号：只认最后一次请求的结果

async function doSearch(k) {
  const seq = ++searchSeq
  try {
    const res = await searchMoments(k)
    if (seq !== searchSeq) return
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
    searchSeq++
    moments.value = allMoments.value
    return
  }
  searchTimer = setTimeout(() => doSearch(kw), 300)
})

onUnmounted(() => {
  clearTimeout(searchTimer)
  if (navObserver) navObserver.disconnect()
})

function setKeyword(k) {
  keyword.value = keyword.value === k ? '' : k
}

const filteredMoments = computed(() => moments.value)

// ===== 生涯时间轴（静态内容） =====
const timeline = [
  { year: '2003', title: '天选之子 · 骑士', desc: '阿克伦之子以状元身份加盟克利夫兰骑士，传奇之旅从此启程。', team: 'CLE' },
  { year: '2012', title: '南海岸 · 首冠', desc: '加盟迈阿密热火，连续四年闯入总决赛，两夺总冠军与 FMVP。', team: 'MIA' },
  { year: '2014', title: '游子归乡', desc: '「I\'m coming home.」重回克利夫兰，只为兑现那一份承诺。', team: 'CLE' },
  { year: '2016', title: '1-3 史诗翻盘', desc: '总决赛 1-3 落后 73 胜勇士，连扳三场，为家乡带来 52 年首冠。', team: 'CLE' },
  { year: '2018', title: '紫金时代', desc: '签约洛杉矶湖人，传奇继续书写。', team: 'LAL' },
  { year: '2020', title: '第 4 冠 · 曼巴致敬', desc: '园区内率领湖人夺冠，为科比而战，紫金王朝再度闪耀。', team: 'LAL' },
  { year: '2024', title: '40000 分里程碑', desc: 'NBA 历史首位生涯总得分突破 40000 分的球员，前无古人。', team: 'LAL' }
]
</script>

<template>
  <div class="home-page">
    <!-- ===== 导航栏 ===== -->
    <header class="navbar">
      <a class="brand" href="#" @click.prevent="goSection('hero')">
        <svg class="crown" viewBox="0 0 64 44" aria-hidden="true">
          <path d="M6 30 L10 9 L22 19 L32 4 L42 19 L54 9 L58 30 Z" />
          <circle cx="10" cy="9" r="2.6" />
          <circle cx="32" cy="4" r="2.6" />
          <circle cx="54" cy="9" r="2.6" />
          <rect x="6" y="33" width="52" height="5" rx="2.5" />
        </svg>
        <span class="brand-name">King James</span>
      </a>

      <nav class="nav-links">
        <a
          v-for="item in navItems"
          :key="item.key"
          href="#"
          class="nav-item"
          :class="{ active: activeNav === item.key }"
          @click.prevent="goSection(item.key)"
        >
          {{ item.label }}
        </a>
      </nav>

      <div class="user-area">
        <button class="admin-btn" @click="emit('go-admin')">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 2 L20 5 V11 C20 16.5 16.6 20.6 12 22 C7.4 20.6 4 16.5 4 11 V5 Z"
                  fill="none" stroke-width="1.6" />
            <path d="M8.5 11.5 L11 14 L15.5 9.5" fill="none" stroke-width="1.8"
                  stroke-linecap="round" stroke-linejoin="round" />
          </svg>
          后台管理
        </button>
        <div class="avatar">{{ (userInfo.nickname || 'U').charAt(0).toUpperCase() }}</div>
        <span class="nickname">{{ userInfo.nickname || '用户' }}</span>
        <button class="logout-btn" @click="logout">退出</button>
      </div>
    </header>

    <!-- ===== 首屏 Hero ===== -->
    <section id="hero" class="hero">
      <div class="hero-bg" aria-hidden="true"></div>
      <div class="hero-mask" aria-hidden="true"></div>
      <div class="hero-content">
        <div class="overline">STRIVE FOR GREATNESS</div>
        <h1>KING JAMES</h1>
        <p class="hero-sub">勒布朗 · 詹姆斯</p>
        <button class="hero-btn" @click="goSection('honors')">查看生涯荣誉</button>
      </div>
      <div class="scroll-hint" aria-hidden="true">▼</div>
    </section>

    <main class="main">
      <div v-if="loadError" class="load-error">{{ loadError }}</div>

      <!-- ===== 关于詹姆斯（简介） ===== -->
      <section id="about" class="about">
        <div class="section-head">
          <h2>关于詹姆斯</h2>
          <span class="head-line"></span>
        </div>
        <div class="about-grid">
          <div class="about-card">
            <div class="about-icon">🏠</div>
            <h3>阿克伦之子</h3>
            <p>1984 年生于俄亥俄州阿克伦，从圣文森特-圣玛丽高中直接进入 NBA，用天赋与自律扛起一座城市的希望。</p>
          </div>
          <div class="about-card">
            <div class="about-icon">👑</div>
            <h3>NBA 传奇</h3>
            <p>20+ 个赛季常青树，历史唯一「40000 分 + 10000 篮板 + 10000 助攻」先生，四个时代的三双与纪录收割机。</p>
          </div>
          <div class="about-card">
            <div class="about-icon">🏀</div>
            <h3>历史得分王</h3>
            <p>2023 年超越贾巴尔登顶 NBA 历史总得分榜，2024 年成为首位突破 40000 分的球员，前无古人。</p>
          </div>
        </div>
      </section>

      <!-- ===== 生涯荣誉（数据库驱动） ===== -->
      <section id="honors" class="honors">
        <div class="section-head">
          <h2>生涯荣誉</h2>
          <span class="head-line"></span>
        </div>
        <div class="honor-grid">
          <div v-for="h in honors" :key="h.label" class="honor-card">
            <div class="honor-value">{{ h.value }}</div>
            <div class="honor-label">{{ h.label }}</div>
          </div>
        </div>
      </section>

      <!-- ===== 生涯时间轴 ===== -->
      <section class="timeline-section">
        <div class="section-head">
          <h2>生涯时间轴</h2>
          <span class="head-line"></span>
        </div>
        <div class="timeline">
          <div v-for="(t, i) in timeline" :key="t.year + t.title" class="timeline-item" :class="{ right: i % 2 === 1 }">
            <div class="timeline-dot"></div>
            <div class="timeline-card">
              <div class="timeline-year">{{ t.year }} <span class="timeline-team">{{ t.team }}</span></div>
              <h3>{{ t.title }}</h3>
              <p>{{ t.desc }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- ===== 经典高光图集 ===== -->
      <section id="moments" class="moments">
        <div class="section-head">
          <h2>经典时刻</h2>
          <span class="count" v-if="keyword.trim()">「{{ keyword.trim() }}」命中 {{ filteredMoments.length }} 条</span>
        </div>

        <!-- 筛选：热门搜索词（数据库驱动） -->
        <div class="filter-bar">
          <svg class="search-icon" viewBox="0 0 24 24" aria-hidden="true">
            <circle cx="11" cy="11" r="7" fill="none" stroke-width="2" />
            <line x1="16.5" y1="16.5" x2="21" y2="21" stroke-width="2" />
          </svg>
          <input v-model="keyword" type="text" placeholder="搜索：年份 / 球队 / 名场面，例如 2016、湖人、翻盘…" />
          <a
            v-for="k in hotKeywords"
            :key="k"
            href="#"
            class="chip"
            :class="{ on: keyword === k }"
            @click.prevent="setKeyword(k)"
          >
            {{ k }}
          </a>
        </div>

        <div v-if="filteredMoments.length" class="moment-grid">
          <article v-for="m in filteredMoments" :key="m.id || m.title" class="moment-card">
            <div class="moment-img-wrap">
              <img :src="imageFor(m)" :alt="m.title" loading="lazy" />
              <span class="moment-year">{{ m.year }}</span>
            </div>
            <div class="moment-body">
              <h3>{{ m.title }}</h3>
              <p>{{ m.description }}</p>
              <div class="moment-tags">
                <span v-for="t in m.tags" :key="t" class="tag"># {{ t }}</span>
              </div>
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
      KING JAMES · STRIVE FOR GREATNESS · 数据由后端接口提供（/api/home、/api/search）
    </footer>
  </div>
</template>

<style scoped>
/* ===== 整体 ===== */
.home-page {
  min-height: 100vh;
  color: #f5f0ff;
  background: linear-gradient(150deg, #2a1450 0%, #1a0b2e 45%, #0e0619 100%);
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
  text-decoration: none;
}
.crown {
  width: 34px;
  height: auto;
  fill: #fdb927;
  filter: drop-shadow(0 0 10px rgba(253, 185, 39, 0.5));
}
.brand-name {
  font-family: 'Georgia', 'Times New Roman', serif;
  font-size: 20px;
  font-weight: 700;
  font-style: italic;
  letter-spacing: 2px;
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
.admin-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  height: 34px;
  padding: 0 14px;
  border: 1px solid rgba(140, 110, 190, 0.45);
  border-radius: 8px;
  background: rgba(85, 37, 131, 0.35);
  color: rgba(245, 240, 255, 0.75);
  font-size: 13px;
  cursor: pointer;
  transition: 0.2s;
}
.admin-btn svg {
  width: 15px;
  height: 15px;
  stroke: currentColor;
}
.admin-btn:hover {
  border-color: #fdb927;
  background: rgba(253, 185, 39, 0.12);
  color: #fdb927;
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

/* ===== 首屏 Hero ===== */
.hero {
  position: relative;
  min-height: calc(100vh - 64px);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
.hero-bg {
  position: absolute;
  inset: 0;
  background: url('/images/hero-bg.png') center 30% / cover no-repeat;
  animation: heroZoom 18s ease-out forwards;
}
@keyframes heroZoom {
  from { transform: scale(1.12); }
  to { transform: scale(1); }
}
.hero-mask {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(180deg, rgba(14, 6, 25, 0.55) 0%, rgba(14, 6, 25, 0.25) 40%, rgba(14, 6, 25, 0.92) 100%),
    radial-gradient(900px 480px at 50% 42%, transparent 40%, rgba(14, 6, 25, 0.45) 100%);
}
.hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
  padding: 0 24px;
}
.overline {
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 10px;
  text-indent: 10px;
  color: #fdb927;
  text-shadow: 0 2px 14px rgba(0, 0, 0, 0.6);
}
.hero h1 {
  margin-top: 18px;
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: clamp(48px, 9vw, 96px);
  font-weight: 900;
  letter-spacing: 8px;
  color: #fff;
  text-shadow:
    0 4px 30px rgba(0, 0, 0, 0.65),
    0 0 60px rgba(253, 185, 39, 0.35);
}
.hero-sub {
  margin-top: 16px;
  font-size: clamp(16px, 2.4vw, 22px);
  letter-spacing: 12px;
  text-indent: 12px;
  color: rgba(245, 240, 255, 0.85);
  text-shadow: 0 2px 14px rgba(0, 0, 0, 0.6);
}
.hero-btn {
  margin-top: 42px;
  height: 54px;
  padding: 0 46px;
  border: 1px solid rgba(253, 185, 39, 0.7);
  border-radius: 999px;
  background: linear-gradient(135deg, rgba(253, 185, 39, 0.95), rgba(233, 165, 31, 0.95));
  color: #241043;
  font-size: 15px;
  font-weight: 800;
  letter-spacing: 4px;
  text-indent: 4px;
  cursor: pointer;
  box-shadow: 0 14px 40px rgba(0, 0, 0, 0.45), 0 0 30px rgba(253, 185, 39, 0.25);
  transition: filter 0.2s, transform 0.15s;
}
.hero-btn:hover {
  filter: brightness(1.08);
  transform: translateY(-2px);
}
.scroll-hint {
  position: absolute;
  bottom: 22px;
  left: 50%;
  transform: translateX(-50%);
  color: rgba(253, 185, 39, 0.6);
  font-size: 14px;
  animation: bounce 1.6s infinite;
}
@keyframes bounce {
  0%, 100% { transform: translate(-50%, 0); }
  50% { transform: translate(-50%, 8px); }
}

/* ===== 主体 ===== */
.main {
  position: relative;
  z-index: 1;
  max-width: 1120px;
  margin: 0 auto;
  padding: 80px 32px 40px;
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

/* ===== 板块标题 ===== */
.section-head {
  display: flex;
  align-items: center;
  gap: 18px;
  margin-bottom: 30px;
}
.section-head h2 {
  font-size: 24px;
  font-weight: 800;
  letter-spacing: 4px;
  color: #fff;
  white-space: nowrap;
}
.head-line {
  flex: 1;
  height: 1px;
  background: linear-gradient(90deg, rgba(253, 185, 39, 0.5), transparent);
}

/* ===== 关于詹姆斯 ===== */
.about {
  margin-bottom: 90px;
}
.about-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}
.about-card {
  padding: 28px 24px;
  background: rgba(26, 12, 46, 0.62);
  border: 1px solid rgba(140, 110, 190, 0.28);
  border-radius: 16px;
  transition: transform 0.2s, border-color 0.2s;
}
.about-card:hover {
  transform: translateY(-4px);
  border-color: rgba(253, 185, 39, 0.5);
}
.about-icon {
  font-size: 28px;
}
.about-card h3 {
  margin-top: 14px;
  font-size: 17px;
  font-weight: 800;
  letter-spacing: 2px;
  color: #fdb927;
}
.about-card p {
  margin-top: 12px;
  font-size: 13px;
  line-height: 1.9;
  color: rgba(245, 240, 255, 0.62);
}

/* ===== 生涯荣誉 ===== */
.honors {
  margin-bottom: 90px;
}
.honor-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}
.honor-card {
  padding: 34px 12px 28px;
  text-align: center;
  background: linear-gradient(160deg, rgba(26, 12, 46, 0.75), rgba(85, 37, 131, 0.35));
  border: 1px solid rgba(253, 185, 39, 0.25);
  border-radius: 16px;
  transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
}
.honor-card:hover {
  transform: translateY(-4px);
  border-color: rgba(253, 185, 39, 0.6);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.4), 0 0 30px rgba(253, 185, 39, 0.08);
}
.honor-value {
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 38px;
  color: #fdb927;
  text-shadow: 0 0 22px rgba(253, 185, 39, 0.4);
}
.honor-label {
  margin-top: 10px;
  font-size: 13px;
  letter-spacing: 3px;
  color: rgba(245, 240, 255, 0.65);
}

/* ===== 生涯时间轴 ===== */
.timeline-section {
  margin-bottom: 90px;
}
.timeline {
  position: relative;
  padding: 10px 0;
}
.timeline::before {
  content: '';
  position: absolute;
  left: 50%;
  top: 0;
  bottom: 0;
  width: 2px;
  transform: translateX(-50%);
  background: linear-gradient(180deg, rgba(253, 185, 39, 0.5), rgba(85, 37, 131, 0.4));
}
.timeline-item {
  position: relative;
  width: 50%;
  padding: 0 40px 36px 0;
}
.timeline-item.right {
  left: 50%;
  padding: 0 0 36px 40px;
}
.timeline-dot {
  position: absolute;
  top: 18px;
  right: -7px;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #fdb927;
  box-shadow: 0 0 0 4px rgba(253, 185, 39, 0.2), 0 0 16px rgba(253, 185, 39, 0.5);
}
.timeline-item.right .timeline-dot {
  right: auto;
  left: -7px;
}
.timeline-card {
  padding: 18px 20px;
  background: rgba(26, 12, 46, 0.65);
  border: 1px solid rgba(140, 110, 190, 0.28);
  border-radius: 14px;
  transition: transform 0.2s, border-color 0.2s;
}
.timeline-card:hover {
  transform: translateY(-3px);
  border-color: rgba(253, 185, 39, 0.5);
}
.timeline-year {
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 20px;
  color: #fdb927;
}
.timeline-team {
  margin-left: 8px;
  padding: 2px 10px;
  font-family: Arial, sans-serif;
  font-size: 11px;
  letter-spacing: 2px;
  color: #241043;
  background: linear-gradient(135deg, #fdb927, #e9a51f);
  border-radius: 6px;
  vertical-align: 3px;
}
.timeline-card h3 {
  margin-top: 10px;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 1px;
  color: #fff;
}
.timeline-card p {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.8;
  color: rgba(245, 240, 255, 0.6);
}

/* ===== 经典时刻 ===== */
.moments {
  margin-bottom: 40px;
}
.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 24px;
  padding: 10px 16px;
  background: rgba(26, 12, 46, 0.65);
  border: 1px solid rgba(140, 110, 190, 0.3);
  border-radius: 14px;
}
.search-icon {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
  stroke: rgba(253, 185, 39, 0.8);
  fill: none;
}
.filter-bar input {
  flex: 1;
  min-width: 200px;
  height: 36px;
  padding: 0 8px;
  border: none;
  background: transparent;
  color: #fff;
  font-size: 14px;
  outline: none;
}
.filter-bar input::placeholder {
  color: rgba(245, 240, 255, 0.32);
}
.chip {
  padding: 5px 14px;
  border: 1px solid rgba(140, 110, 190, 0.4);
  border-radius: 999px;
  font-size: 12px;
  color: rgba(245, 240, 255, 0.65);
  text-decoration: none;
  transition: 0.2s;
  white-space: nowrap;
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

.count {
  font-size: 12px;
  color: #fdb927;
}

.moment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
}
.moment-card {
  overflow: hidden;
  background: rgba(26, 12, 46, 0.62);
  border: 1px solid rgba(140, 110, 190, 0.28);
  border-radius: 16px;
  transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
}
.moment-card:hover {
  transform: translateY(-4px);
  border-color: rgba(253, 185, 39, 0.5);
  box-shadow: 0 16px 44px rgba(0, 0, 0, 0.4);
}
.moment-img-wrap {
  position: relative;
  aspect-ratio: 4 / 3;
  overflow: hidden;
}
.moment-img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s;
}
.moment-card:hover .moment-img-wrap img {
  transform: scale(1.06);
}
.moment-year {
  position: absolute;
  top: 12px;
  left: 12px;
  padding: 3px 12px;
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 12px;
  color: #241043;
  background: linear-gradient(135deg, #fdb927, #e9a51f);
  border-radius: 6px;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}
.moment-body {
  padding: 18px 20px 20px;
}
.moment-body h3 {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 1px;
  color: #fff;
}
.moment-body p {
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
@media (max-width: 900px) {
  .nav-links {
    display: none;
  }
  .about-grid,
  .honor-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .timeline::before {
    left: 8px;
  }
  .timeline-item,
  .timeline-item.right {
    width: 100%;
    left: 0;
    padding: 0 0 28px 30px;
  }
  .timeline-dot,
  .timeline-item.right .timeline-dot {
    left: 1px;
    right: auto;
  }
}
@media (max-width: 560px) {
  .navbar {
    padding: 0 16px;
  }
  .admin-btn span {
    display: none;
  }
  .nickname {
    display: none;
  }
  .main {
    padding: 48px 16px 32px;
  }
  .about-grid,
  .honor-grid {
    grid-template-columns: 1fr;
  }
}
</style>
