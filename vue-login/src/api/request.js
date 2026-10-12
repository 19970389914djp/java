import axios from 'axios'

// 统一 axios 实例，/api 前缀由 vite 代理转发到后端 http://localhost:8080
const request = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 响应拦截：统一取出后端 Result 结构
request.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const msg = error.response?.data?.msg || '网络异常，请检查后端服务是否已启动'
    return Promise.reject(new Error(msg))
  }
)

export default request
