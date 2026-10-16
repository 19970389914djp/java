import request from './request'

/** 首页聚合数据：荣誉卡 + 热门搜索词 + 全部高光时刻 */
export function getHome() {
  return request.get('/home')
}

/** 搜索高光时刻（keyword 为空返回全部） */
export function searchMoments(keyword) {
  return request.get('/search', { params: { keyword } })
}
