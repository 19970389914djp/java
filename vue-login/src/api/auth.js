import request from './request'

/** 发送验证码（target 为邮箱） */
export function sendCode(target) {
  return request.post('/auth/send-code', { target })
}

/** 邮箱注册 */
export function register(data) {
  return request.post('/auth/register', data)
}

/** 登录 */
export function login(data) {
  return request.post('/auth/login', data)
}
