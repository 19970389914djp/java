import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 本机局域网 IP，前后端统一走该地址（手机/其他电脑也可访问）
const LAN_IP = '192.168.68.27'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0', // 监听所有网卡，允许局域网通过 192.168.68.27:5173 访问
    port: 5173,
    open: true,
    proxy: {
      // 前端 /api 请求代理到 Spring Boot 后端
      '/api': {
        target: `http://${LAN_IP}:8080`,
        changeOrigin: true
      }
    }
  }
})
