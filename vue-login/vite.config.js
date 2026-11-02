import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 后端在本机运行，代理直接走本机回环地址（不受局域网 IP 变化影响）
const API_HOST = '127.0.0.1'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0', // 监听所有网卡，手机/局域网其他电脑可通过本机 IP:5173 访问
    port: 5173,
    open: true,
    proxy: {
      // 前端 /api 请求代理到 Spring Boot 后端
      '/api': {
        target: `http://${API_HOST}:8080`,
        changeOrigin: true
      }
    }
  }
})
