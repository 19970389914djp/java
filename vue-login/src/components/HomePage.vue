<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { getHome, searchMoments } from '../api/home'

const emit = defineEmits(['logout', 'go-admin'])

const userInfo = ref({ nickname: '', email: '', permission: 1 })

// 仅 permission=0（管理员）可见后台管理按钮
const isAdmin = computed(() => Number(userInfo.value.permission) === 0)

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
  window.addEventListener('keydown', onDetailKeydown)
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

// 经典时刻配图（真实照片，来自新浪体育等国内站点，按内容匹配，未匹配的循环使用）
const IMG_DRAFT = '/images/moment-2003.jpg'       // 骑士早期 23 号（2003 天选之子）
const IMG_HEAT = '/images/moment-2012.jpg'        // 热火 6 号（2012/2013 冠军时期）
const IMG_BLOCK = '/images/moment-2016-block.jpg' // 骑士怒吼（2016 翻盘/The Block）
const IMG_TROPHY = '/images/moment-2020.jpg'      // 湖人怒吼（2020 紫金复辟）
const IMG_40000 = '/images/moment-40000.jpg'      // 湖人球衣肖像（40000 分里程碑）
const IMG_RITUAL = '/images/moment-ritual.jpg'    // 赛前氛围肖像（粉笔仪式）
const galleryImages = [IMG_DRAFT, IMG_HEAT, IMG_BLOCK, IMG_TROPHY, IMG_40000, IMG_RITUAL]

function imageFor(m) {
  const t = (m.title || '') + ' ' + (m.year || '') + ' ' + (m.tags || '')
  if (t.includes('2003') || t.includes('天选之子') || t.includes('选秀') || t.includes('状元')) return IMG_DRAFT
  if (/首冠|卫冕|热火|2012|2013/.test(t)) return IMG_HEAT
  if (t.includes('The Block') || t.includes('追身大帽') || t.includes('防守')) return IMG_BLOCK
  if (t.includes('40000') || t.includes('里程碑') || t.includes('得分王')) return IMG_40000
  if (t.includes('粉笔') || t.includes('仪式')) return IMG_RITUAL
  if (/摊手|一跪|撸头|推手|垫脚|伸腿|看戏/.test(t)) return IMG_RITUAL
  if (t.includes('快攻')) return IMG_DRAFT
  if (/马刺|小牛|2011|2015|2017/.test(t)) return IMG_BLOCK
  if (t.includes('戳眼') || t.includes('40000') || t.includes('横扫')) return IMG_40000
  if (/总冠军|紫金|2020|湖人/.test(t)) return IMG_TROPHY
  if (t.includes('2016') || t.includes('骑士') || t.includes('翻盘')) return IMG_BLOCK
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
    // 搜索出结果后，自动跳转到结果所在的页面位置（经典时刻板块）
    jumpToResults()
  } catch (e) {
    if (seq === searchSeq) {
      loadError.value = '搜索失败：' + (e.message || '网络异常')
    }
  }
}

// ===== 搜索跳转：滚动到结果区域并高亮第一条命中 =====
const searching = ref(false) // 跳转期间给卡片加过渡遮罩，避免滚动中布局跳动

async function jumpToResults() {
  searching.value = true
  const sec = document.getElementById('moments')
  sec?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  await nextTick()
  // 等平滑滚动基本完成后解除遮罩（滚动时长约 500ms）
  setTimeout(() => { searching.value = false }, 600)
}

// 判断某条时刻是否命中当前关键词（用于结果高亮）
function isHit(m) {
  const kw = keyword.value.trim().toLowerCase()
  if (!kw) return false
  const text = [m.title, m.year, (m.tags || []).join(' '), m.description]
    .join(' ').toLowerCase()
  return text.includes(kw)
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
  window.removeEventListener('keydown', onDetailKeydown)
})

function setKeyword(k) {
  keyword.value = keyword.value === k ? '' : k
}

const filteredMoments = computed(() => moments.value)

// ===== 详情弹窗：点击任意模块卡片查看详情 =====
const detailModal = ref(null) // { img, title, meta, paras[], tags[] }

function openDetail(d) {
  detailModal.value = d
}
function closeDetail() {
  detailModal.value = null
}
function onDetailKeydown(e) {
  if (e.key === 'Escape') closeDetail()
}

// 荣誉卡详情文案（按荣誉名匹配）
const HONOR_DETAILS = {
  '总冠军': [
    '生涯 4 次捧起奥布莱恩杯：2012、2013 年随迈阿密热火两连冠，2016 年率克利夫兰骑士完成 1-3 史诗翻盘，2020 年在奥兰多园区为洛杉矶湖人夺得队史第 17 冠。',
    '四次夺冠均当选总决赛 MVP，是历史上唯一在三支不同球队均以核心身份夺冠并包揽 FMVP 的球员。'
  ],
  '总决赛 MVP': [
    '4 次总决赛 MVP：2012、2013（热火）、2016（骑士）、2020（湖人）。',
    '2016 年总决赛五项数据（得分、篮板、助攻、抢断、盖帽）领跑两队所有球员，历史唯一。'
  ],
  '常规赛 MVP': [
    '4 次常规赛 MVP：2009、2010 年在克利夫兰骑士蝉联，2012、2013 年在迈阿密热火再度蝉联。',
    '其中 2013 年差 1 票全票当选，该赛季同时包揽总冠军 + FMVP + 最佳防守阵容一阵。'
  ],
  '全明星': [
    '自 2005 年起连续 20 个赛季入选 NBA 全明星，入选次数历史第一，多次担任队长。',
    '3 次荣膺全明星赛 MVP（2006、2008、2018）。'
  ],
  '历史总得分王': [
    '2023 年 2 月超越卡里姆·阿卜杜尔-贾巴尔，登顶 NBA 历史总得分榜。',
    '2024 年 3 月成为历史首位生涯总得分突破 40000 分的球员，前无古人。'
  ],
  '历史助攻王': [
    '生涯助攻突破 11000 次，是 NBA 历史唯一达成「40000 分 + 10000 篮板 + 10000 助攻」的球员。',
    '以组织前锋身份重新定义了篮球场上全能战士的标准。'
  ]
}

// 关于詹姆斯：卡片数据 + 详情
const aboutCards = [
  {
    icon: '🏠', title: '阿克伦之子',
    desc: '1984 年生于俄亥俄州阿克伦，从圣文森特-圣玛丽高中直接进入 NBA，用天赋与自律扛起一座城市的希望。',
    detail: [
      '1984 年 12 月 30 日出生于俄亥俄州阿克伦，由单亲母亲抚养长大，童年多次搬家。',
      '高中就读于圣文森特-圣玛丽高中，三次率队夺得州冠军，登上《体育画报》封面，被誉为「天选之子（The Chosen One）」。',
      '2003 年以高中生身份当选 NBA 选秀状元，被家乡球队克利夫兰骑士选中，从此扛起一座城市的冠军梦想。'
    ]
  },
  {
    icon: '👑', title: 'NBA 传奇',
    desc: '20+ 个赛季常青树，历史唯一「40000 分 + 10000 篮板 + 10000 助攻」先生，四个时代的三双与纪录收割机。',
    detail: [
      '职业生涯横跨 2003 至今 20 余载，从骑士、热火、再回骑士到湖人，在每个阶段都保持联盟顶级水准。',
      'NBA 历史唯一达成 40000 分 + 10000 篮板 + 10000 助攻的球员，20 次全明星、20 次最佳阵容均创历史纪录。',
      '四次带领三支不同球队夺冠且全获 FMVP，2016 年为克利夫兰带来 52 年首个职业体育总冠军。'
    ]
  },
  {
    icon: '🏀', title: '历史得分王',
    desc: '2023 年超越贾巴尔登顶 NBA 历史总得分榜，2024 年成为首位突破 40000 分的球员，前无古人。',
    detail: [
      '2023 年 2 月 8 日对阵雷霆，一记翻身后仰跳投超越贾巴尔的 38387 分，加冕 NBA 历史得分王。',
      '2024 年 3 月对阵掘金，生涯总得分突破 40000 分大关，成为历史第一人。',
      '职业生涯场均 27+ 分，连续 20 个赛季场均得分 25+，得分稳定性历史罕见。'
    ]
  }
]
function openAboutDetail(card) {
  openDetail({ title: card.title, meta: '关于詹姆斯', paras: card.detail, tags: [] })
}
function openHonorDetail(h) {
  const paras = HONOR_DETAILS[h.label] || [h.label + '：' + h.value]
  openDetail({ title: h.label, meta: '生涯荣誉 · ' + h.value, paras, tags: [] })
}
function openMomentDetail(m) {
  openDetail({
    img: m.image || imageFor(m),
    title: m.title,
    meta: '经典时刻 · ' + (m.year || ''),
    paras: [m.description || '暂无详细介绍。'],
    tags: m.tags || []
  })
}
function openTimelineDetail(t) {
  openDetail({
    img: t.img,
    title: t.title,
    meta: '生涯时间轴 · ' + t.year + ' ' + t.team,
    paras: [t.desc],
    tags: []
  })
}

// ===== 生涯时间轴（静态内容） =====
const timeline = [
  { year: '2003', title: '天选之子 · 骑士', desc: '阿克伦之子以状元身份加盟克利夫兰骑士，传奇之旅从此启程。', team: 'CLE', img: '/images/moment-2003.jpg' },
  { year: '2012', title: '南海岸 · 首冠', desc: '加盟迈阿密热火，连续四年闯入总决赛，两夺总冠军与 FMVP。', team: 'MIA', img: '/images/moment-2012.jpg' },
  { year: '2014', title: '游子归乡', desc: '「I\'m coming home.」重回克利夫兰，只为兑现那一份承诺。', team: 'CLE', img: '/images/hero-bg.jpg' },
  { year: '2016', title: '1-3 史诗翻盘', desc: '总决赛 1-3 落后 73 胜勇士，连扳三场，为家乡带来 52 年首冠。', team: 'CLE', img: '/images/moment-2016-block.jpg' },
  { year: '2018', title: '紫金时代', desc: '签约洛杉矶湖人，传奇继续书写。', team: 'LAL', img: '/images/timeline-2018.jpg' },
  { year: '2020', title: '第 4 冠 · 曼巴致敬', desc: '园区内率领湖人夺冠，为科比而战，紫金王朝再度闪耀。', team: 'LAL', img: '/images/moment-2020.jpg' },
  { year: '2024', title: '40000 分里程碑', desc: 'NBA 历史首位生涯总得分突破 40000 分的球员，前无古人。', team: 'LAL', img: '/images/moment-40000.jpg' }
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

      <!-- 全局搜索：任意位置输入，自动跳转到结果所在位置 -->
      <div class="nav-search">
        <svg class="nav-search-icon" viewBox="0 0 24 24" aria-hidden="true">
          <circle cx="11" cy="11" r="7" fill="none" stroke-width="2" />
          <line x1="16.5" y1="16.5" x2="21" y2="21" stroke-width="2" />
        </svg>
        <input
          v-model="keyword"
          type="text"
          placeholder="搜索詹姆斯：2016 / 湖人 / 翻盘…"
          @keyup.enter="jumpToResults"
        />
        <button v-if="keyword" class="nav-search-clear" @click="keyword = ''" aria-label="清空搜索">×</button>
      </div>

      <div class="user-area">
        <button v-if="isAdmin" class="admin-btn" @click="emit('go-admin')">
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
          <div
            v-for="card in aboutCards"
            :key="card.title"
            class="about-card clickable"
            role="button"
            tabindex="0"
            @click="openAboutDetail(card)"
            @keyup.enter="openAboutDetail(card)"
          >
            <div class="about-icon">{{ card.icon }}</div>
            <h3>{{ card.title }}</h3>
            <p>{{ card.desc }}</p>
            <span class="more-hint">点击查看详情 ›</span>
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
          <div
            v-for="h in honors"
            :key="h.label"
            class="honor-card clickable"
            role="button"
            tabindex="0"
            @click="openHonorDetail(h)"
            @keyup.enter="openHonorDetail(h)"
          >
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
            <div
              class="timeline-card clickable"
              role="button"
              tabindex="0"
              @click="openTimelineDetail(t)"
              @keyup.enter="openTimelineDetail(t)"
            >
              <img class="timeline-img" :src="t.img" :alt="t.title" loading="lazy" />
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

        <div v-if="filteredMoments.length" class="moment-grid" :class="{ dimmed: searching }">
          <article
            v-for="m in filteredMoments"
            :key="m.id || m.title"
            class="moment-card clickable"
            :class="{ hit: !!keyword.trim() }"
            role="button"
            tabindex="0"
            @click="openMomentDetail(m)"
            @keyup.enter="openMomentDetail(m)"
          >
            <div class="moment-img-wrap">
              <img :src="m.image || imageFor(m)" :alt="m.title" loading="lazy" />
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

    <!-- ===== 详情弹窗 ===== -->
    <Transition name="modal-fade">
      <div v-if="detailModal" class="detail-overlay" @click.self="closeDetail">
        <div class="detail-modal" role="dialog" aria-modal="true">
          <button class="detail-close" @click="closeDetail" aria-label="关闭详情">×</button>
          <img v-if="detailModal.img" class="detail-img" :src="detailModal.img" :alt="detailModal.title" />
          <div class="detail-body">
            <div class="detail-meta">{{ detailModal.meta }}</div>
            <h2 class="detail-title">{{ detailModal.title }}</h2>
            <p v-for="(p, i) in detailModal.paras" :key="i" class="detail-para">{{ p }}</p>
            <div v-if="detailModal.tags && detailModal.tags.length" class="detail-tags">
              <span v-for="t in detailModal.tags" :key="t" class="tag"># {{ t }}</span>
            </div>
          </div>
        </div>
      </div>
    </Transition>
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
  gap: 20px;
  height: 64px;
  padding: 0 24px;
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
  gap: 2px;
  flex: 0 1 auto;
  justify-content: center;
  min-width: 0;
}
.nav-item {
  position: relative;
  padding: 8px 18px;
  font-size: 14px;
  letter-spacing: 2px;
  white-space: nowrap;
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

/* ===== 导航栏全局搜索 ===== */
.nav-search {
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
  width: 200px;
  height: 36px;
  padding: 0 34px 0 12px;
  margin-left: auto;
  background: rgba(26, 12, 46, 0.75);
  border: 1px solid rgba(140, 110, 190, 0.4);
  border-radius: 999px;
  transition: border-color 0.2s, box-shadow 0.2s, width 0.25s;
}
.nav-search:focus-within {
  width: 250px;
  border-color: #fdb927;
  box-shadow: 0 0 18px rgba(253, 185, 39, 0.18);
}
.nav-search-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
  stroke: rgba(253, 185, 39, 0.85);
  fill: none;
}
.nav-search input {
  flex: 1;
  min-width: 0;
  height: 100%;
  border: none;
  background: transparent;
  color: #fff;
  font-size: 13px;
  outline: none;
}
.nav-search input::placeholder {
  color: rgba(245, 240, 255, 0.35);
}
.nav-search-clear {
  position: absolute;
  right: 6px;
  width: 22px;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 50%;
  background: rgba(140, 110, 190, 0.3);
  color: rgba(245, 240, 255, 0.85);
  font-size: 15px;
  line-height: 1;
  cursor: pointer;
  transition: 0.2s;
}
.nav-search-clear:hover {
  background: rgba(253, 185, 39, 0.35);
  color: #fff;
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
  background: url('/images/hero-bg.jpg') center 30% / cover no-repeat;
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
  padding: 14px 16px 18px;
  background: rgba(26, 12, 46, 0.65);
  border: 1px solid rgba(140, 110, 190, 0.28);
  border-radius: 14px;
  transition: transform 0.2s, border-color 0.2s;
}
.timeline-img {
  display: block;
  width: 100%;
  height: 170px;
  object-fit: cover;
  object-position: center top;
  border-radius: 10px;
  margin-bottom: 14px;
  background: rgba(85, 37, 131, 0.3);
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
/* 搜索跳转滚动期间轻微压暗，减少布局跳动观感 */
.moment-grid.dimmed {
  opacity: 0.55;
  transition: opacity 0.3s;
}
/* 命中当前搜索词的卡片高亮描边 */
.moment-card.hit {
  border-color: rgba(253, 185, 39, 0.65);
  animation: hitPulse 1.6s ease-out 1;
}
.moment-grid .moment-card.hit:first-child {
  box-shadow: 0 0 0 2px rgba(253, 185, 39, 0.55), 0 16px 44px rgba(0, 0, 0, 0.4);
}
@keyframes hitPulse {
  0% { box-shadow: 0 0 0 3px rgba(253, 185, 39, 0.65); }
  100% { box-shadow: 0 0 0 0 rgba(253, 185, 39, 0); }
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

/* ===== 可点击卡片 ===== */
.clickable {
  cursor: pointer;
}
.clickable:focus-visible {
  outline: 2px solid rgba(253, 185, 39, 0.7);
  outline-offset: 2px;
}
.more-hint {
  display: inline-block;
  margin-top: 12px;
  font-size: 12px;
  color: rgba(253, 185, 39, 0.75);
  letter-spacing: 1px;
}

/* ===== 详情弹窗 ===== */
.detail-overlay {
  position: fixed;
  inset: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: rgba(10, 4, 18, 0.72);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}
.detail-modal {
  position: relative;
  width: min(620px, 100%);
  max-height: 85vh;
  overflow-y: auto;
  background: linear-gradient(160deg, rgba(38, 18, 66, 0.98), rgba(20, 9, 36, 0.98));
  border: 1px solid rgba(253, 185, 39, 0.4);
  border-radius: 18px;
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.6), 0 0 40px rgba(253, 185, 39, 0.1);
}
.detail-img {
  display: block;
  width: 100%;
  height: 260px;
  object-fit: cover;
  border-radius: 18px 18px 0 0;
  background: rgba(85, 37, 131, 0.3);
}
.detail-close {
  position: absolute;
  top: 14px;
  right: 14px;
  z-index: 2;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(253, 185, 39, 0.5);
  border-radius: 50%;
  background: rgba(14, 6, 25, 0.75);
  color: #fdb927;
  font-size: 20px;
  line-height: 1;
  cursor: pointer;
  transition: 0.2s;
}
.detail-close:hover {
  background: #fdb927;
  color: #241043;
}
.detail-body {
  padding: 24px 30px 30px;
}
.detail-meta {
  font-size: 12px;
  letter-spacing: 3px;
  color: rgba(253, 185, 39, 0.8);
}
.detail-title {
  margin-top: 8px;
  font-size: 24px;
  font-weight: 800;
  letter-spacing: 2px;
  color: #fff;
}
.detail-para {
  margin-top: 14px;
  font-size: 14px;
  line-height: 2;
  color: rgba(245, 240, 255, 0.75);
}
.detail-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-top: 18px;
}
/* 弹窗过渡动画 */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.25s ease;
}
.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
.modal-fade-enter-active .detail-modal {
  animation: modalZoom 0.28s ease-out;
}
@keyframes modalZoom {
  from { transform: scale(0.92) translateY(12px); opacity: 0.6; }
  to { transform: scale(1) translateY(0); opacity: 1; }
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
@media (max-width: 1100px) {
  .nav-item {
    padding: 8px 10px;
    letter-spacing: 1px;
  }
  .nav-search {
    width: 170px;
  }
  .nav-search:focus-within {
    width: 200px;
  }
}
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
  .nav-search {
    width: 150px;
    padding-right: 30px;
  }
  .nav-search:focus-within {
    width: 190px;
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
