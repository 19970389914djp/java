import request from './request'

const TOKEN_KEY = 'adminToken'

/** 后台登录 */
export function adminLogin(data) {
  return request.post('/admin/login', data)
}

/** 退出登录 */
export function adminLogout() {
  return request.post('/admin/logout', null, {
    headers: { Authorization: localStorage.getItem(TOKEN_KEY) || '' }
  })
}

// ---------- 生涯荣誉 ----------
export function getHonors() {
  return request.get('/admin/honors', authHeader())
}
export function addHonor(data) {
  return request.post('/admin/honor', data, authHeader())
}
export function updateHonor(data) {
  return request.put('/admin/honor', data, authHeader())
}
export function deleteHonor(id) {
  return request.delete(`/admin/honor/${id}`, authHeader())
}

// ---------- 高光时刻 ----------
export function getMoments() {
  return request.get('/admin/moments', authHeader())
}
export function addMoment(data) {
  return request.post('/admin/moment', data, authHeader())
}
export function updateMoment(data) {
  return request.put('/admin/moment', data, authHeader())
}
export function deleteMoment(id) {
  return request.delete(`/admin/moment/${id}`, authHeader())
}

// ---------- 热门搜索词 ----------
export function getHotKeywords() {
  return request.get('/admin/hot-keywords', authHeader())
}
export function addHotKeyword(data) {
  return request.post('/admin/hot-keyword', data, authHeader())
}
export function updateHotKeyword(data) {
  return request.put('/admin/hot-keyword', data, authHeader())
}
export function deleteHotKeyword(id) {
  return request.delete(`/admin/hot-keyword/${id}`, authHeader())
}

/** 携带内存 token 的请求头 */
function authHeader() {
  return { headers: { Authorization: localStorage.getItem(TOKEN_KEY) || '' } }
}
