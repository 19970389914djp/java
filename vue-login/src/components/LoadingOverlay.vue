<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

/**
 * 登录后的全屏加载动画（詹姆斯生涯集锦轮播）
 * - 本地图片轮播（图片来自新浪体育等国内站点）+ 缓慢推拉镜头（Ken Burns）
 * - 底部进度条 + 百分比，最短展示 DURATION 后淡出
 * - 结束后 emit('done')，由 App.vue 控制卸载
 */
const emit = defineEmits(['done'])

const DURATION = 3200   // 最短展示时长（毫秒）
const SLIDE_MS = 1300   // 每张图停留时长

// 集锦片段（图片均在 public/images，来源：新浪体育等国内站点）
const slides = [
  { img: '/images/moment-2003.jpg',       year: '2003', title: '天选之子降临' },
  { img: '/images/moment-2012.jpg',       year: '2012', title: '首冠加冕' },
  { img: '/images/moment-2016-block.jpg', year: '2016', title: '1-3 史诗翻盘' },
  { img: '/images/moment-2020.jpg',       year: '2020', title: '紫金复辟' },
  { img: '/images/moment-40000.jpg',      year: '2024', title: '40000 分里程碑' },
  { img: '/images/moment-ritual.jpg',     year: '23',   title: '粉笔仪式' }
]

const index = ref(0)
const progress = ref(0)
const leaving = ref(false)

let slideTimer = null
let progressTimer = null

onMounted(() => {
  // 图片轮播
  slideTimer = setInterval(() => {
    index.value = (index.value + 1) % slides.length
  }, SLIDE_MS)

  // 进度条 0 → 100
  const step = 30
  progressTimer = setInterval(() => {
    progress.value = Math.min(100, progress.value + step * 100 / (DURATION / 30) / 1)
    if (progress.value >= 100) clearInterval(progressTimer)
  }, 30)

  // 展示够时长后淡出并通知父组件卸载
  setTimeout(() => {
    leaving.value = true
    setTimeout(() => emit('done'), 650)
  }, DURATION)
})

onUnmounted(() => {
  clearInterval(slideTimer)
  clearInterval(progressTimer)
})
</script>

<template>
  <div class="loading-overlay" :class="{ leaving }">
    <!-- 背景集锦轮播 -->
    <div
      v-for="(s, i) in slides"
      :key="i"
      class="slide"
      :class="{ active: i === index, 'zoom-in': i % 2 === 0, 'zoom-out': i % 2 !== 0 }"
      :style="{ backgroundImage: `url(${s.img})` }"
    ></div>

    <!-- 压暗遮罩 -->
    <div class="shade"></div>

    <!-- 文案层 -->
    <div class="content">
      <p class="slogan">STRIVE FOR GREATNESS</p>

      <transition name="cap" mode="out-in">
        <div class="caption" :key="index">
          <span class="cap-year">{{ slides[index].year }}</span>
          <span class="cap-title">{{ slides[index].title }}</span>
        </div>
      </transition>

      <div class="brand">
        <h1>KING JAMES</h1>
        <p>生涯集锦 · 正在加载</p>
      </div>

      <div class="progress-wrap">
        <div class="progress-track">
          <div class="progress-bar" :style="{ width: progress + '%' }"></div>
        </div>
        <span class="progress-num">{{ Math.floor(progress) }}%</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.loading-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: #0a0a0f;
  overflow: hidden;
  transition: opacity 0.6s ease, visibility 0.6s ease;
}
.loading-overlay.leaving {
  opacity: 0;
  visibility: hidden;
}

/* ---- 背景轮播 ---- */
.slide {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: center;
  opacity: 0;
  transition: opacity 0.7s ease;
  will-change: transform, opacity;
}
.slide.active { opacity: 1; }
.slide.zoom-in.active  { animation: kenburns-in 1.6s ease-out forwards; }
.slide.zoom-out.active { animation: kenburns-out 1.6s ease-out forwards; }
@keyframes kenburns-in {
  from { transform: scale(1.12) translate(1.5%, -1%); }
  to   { transform: scale(1)    translate(0, 0); }
}
@keyframes kenburns-out {
  from { transform: scale(1)    translate(-1%, 1%); }
  to   { transform: scale(1.12) translate(0, 0); }
}

.shade {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse at center, rgba(10, 10, 15, 0.25) 0%, rgba(10, 10, 15, 0.78) 100%),
    linear-gradient(to bottom, rgba(10, 10, 15, 0.55), rgba(10, 10, 15, 0.15) 40%, rgba(10, 10, 15, 0.85));
}

/* ---- 文案 ---- */
.content {
  position: relative;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 26px;
  color: #f5f1e8;
  text-align: center;
  padding: 0 24px;
}
.slogan {
  font-size: 12px;
  letter-spacing: 6px;
  color: rgba(245, 241, 232, 0.55);
  text-transform: uppercase;
}
.caption {
  display: flex;
  align-items: baseline;
  gap: 14px;
  height: 56px;
}
.cap-year {
  font-size: 44px;
  font-weight: 900;
  font-style: italic;
  color: #d4af37;
  letter-spacing: 2px;
}
.cap-title {
  font-size: 20px;
  font-weight: 600;
  color: rgba(245, 241, 232, 0.92);
  letter-spacing: 3px;
}
.cap-enter-active, .cap-leave-active { transition: opacity 0.3s ease, transform 0.3s ease; }
.cap-enter-from { opacity: 0; transform: translateY(10px); }
.cap-leave-to   { opacity: 0; transform: translateY(-10px); }

.brand h1 {
  font-size: 34px;
  font-weight: 900;
  letter-spacing: 10px;
  margin: 0;
  text-shadow: 0 2px 18px rgba(0, 0, 0, 0.6);
}
.brand p {
  margin: 8px 0 0;
  font-size: 13px;
  letter-spacing: 4px;
  color: rgba(245, 241, 232, 0.6);
}

/* ---- 进度条 ---- */
.progress-wrap {
  width: min(320px, 70vw);
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 6px;
}
.progress-track {
  flex: 1;
  height: 3px;
  border-radius: 3px;
  background: rgba(245, 241, 232, 0.18);
  overflow: hidden;
}
.progress-bar {
  height: 100%;
  border-radius: 3px;
  background: linear-gradient(90deg, #d4af37, #f1d27a);
  transition: width 0.12s linear;
}
.progress-num {
  font-size: 12px;
  font-variant-numeric: tabular-nums;
  color: rgba(245, 241, 232, 0.7);
  min-width: 38px;
  text-align: right;
}

/* 移动端 */
@media (max-width: 640px) {
  .cap-year { font-size: 34px; }
  .cap-title { font-size: 16px; }
  .brand h1 { font-size: 26px; letter-spacing: 6px; }
}
</style>
