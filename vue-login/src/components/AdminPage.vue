<script setup>
import { ref, reactive, onMounted } from 'vue'
import {
  adminLogout,
  getHonors, addHonor, updateHonor, deleteHonor,
  getMoments, addMoment, updateMoment, deleteMoment,
  getHotKeywords, addHotKeyword, updateHotKeyword, deleteHotKeyword
} from '../api/admin'

const emit = defineEmits(['logout'])

// 登录账号（仅展示用）
const adminName = ref(localStorage.getItem('adminUsername') || 'admin')

// ---------- 模块定义 ----------
const MODULES = {
  honor: {
    label: '生涯荣誉',
    fetch: getHonors,
    add: addHonor,
    update: updateHonor,
    remove: deleteHonor,
    columns: [
      { key: 'label', label: '荣誉名称' },
      { key: 'value', label: '荣誉数值' },
      { key: 'sortOrder', label: '顺序', width: '80px' }
    ],
    emptyText: '荣誉名称/荣誉数值'
  },
  moment: {
    label: '高光时刻',
    fetch: getMoments,
    add: addMoment,
    update: updateMoment,
    remove: deleteMoment,
    columns: [
      { key: 'year', label: '年份', width: '80px' },
      { key: 'title', label: '标题', width: '180px' },
      { key: 'description', label: '描述' },
      { key: 'tags', label: '标签', width: '180px' },
      { key: 'sortOrder', label: '顺序', width: '80px' }
    ],
    emptyText: '年份/标题/描述'
  },
  hotKeyword: {
    label: '热门搜索词',
    fetch: getHotKeywords,
    add: addHotKeyword,
    update: updateHotKeyword,
    remove: deleteHotKeyword,
    columns: [
      { key: 'keyword', label: '搜索词' },
      { key: 'sortOrder', label: '顺序', width: '80px' }
    ],
    emptyText: '搜索词'
  }
}

const currentModule = ref('honor')
const rows = ref([])
const tableLoading = ref(false)

// ---------- 提示信息 ----------
const message = ref('')
const msgType = ref('')
function showMsg(text, type) {
  message.value = text
  msgType.value = type || ''
  // 5 秒后自动清除
  clearTimeout(showMsg._timer)
  showMsg._timer = setTimeout(() => { message.value = '' }, 5000)
}

// ---------- 列表加载 ----------
async function loadRows() {
  const mod = MODULES[currentModule.value]
  tableLoading.value = true
  try {
    const res = await mod.fetch()
    if (res.code !== 200) {
      showMsg(res.msg || '获取数据失败', 'error')
      // token 失效则回登录页
      if (res.msg && res.msg.includes('重新登录')) {
        localStorage.removeItem('adminToken')
        emit('logout')
      }
      return
    }
    rows.value = res.data
  } catch (e) {
    showMsg(e.message, 'error')
  } finally {
    tableLoading.value = false
  }
}

function switchModule(key) {
  currentModule.value = key
  loadRows()
}

// ---------- 弹窗表单 ----------
const modalVisible = ref(false)
const editingId = ref(null) // null = 新增
const form = reactive({})
const formError = ref('')

// 各模块表单字段定义
const FORM_FIELDS = {
  honor: [
    { key: 'label', label: '荣誉名称', type: 'text', required: true, placeholder: '如：总冠军' },
    { key: 'value', label: '荣誉数值', type: 'text', required: true, placeholder: '如：4、40000+' },
    { key: 'sortOrder', label: '展示顺序（越小越靠前）', type: 'number', required: false, placeholder: '0' }
  ],
  moment: [
    { key: 'year', label: '年份', type: 'text', required: true, placeholder: '如：2016、23' },
    { key: 'title', label: '标题', type: 'text', required: true, placeholder: '如：1-3 史诗翻盘' },
    { key: 'description', label: '描述', type: 'textarea', required: true, placeholder: '描述这个时刻…' },
    { key: 'tags', label: '标签（逗号分隔）', type: 'text', required: false, placeholder: '如：骑士,总冠军,翻盘' },
    { key: 'sortOrder', label: '展示顺序（越小越靠前）', type: 'number', required: false, placeholder: '0' }
  ],
  hotKeyword: [
    { key: 'keyword', label: '搜索词', type: 'text', required: true, placeholder: '如：总冠军' },
    { key: 'sortOrder', label: '展示顺序（越小越靠前）', type: 'number', required: false, placeholder: '0' }
  ]
}

function openAdd() {
  editingId.value = null
  Object.keys(form).forEach(k => delete form[k])
  FORM_FIELDS[currentModule.value].forEach(f => {
    form[f.key] = f.type === 'number' ? 0 : ''
  })
  formError.value = ''
  modalVisible.value = true
}

function openEdit(row) {
  editingId.value = row.id
  Object.keys(form).forEach(k => delete form[k])
  FORM_FIELDS[currentModule.value].forEach(f => {
    form[f.key] = row[f.key] ?? (f.type === 'number' ? 0 : '')
  })
  formError.value = ''
  modalVisible.value = true
}

function closeModal() {
  modalVisible.value = false
}

async function submitForm() {
  const mod = MODULES[currentModule.value]
  // 必填校验
  for (const f of FORM_FIELDS[currentModule.value]) {
    if (f.required && String(form[f.key] ?? '').trim() === '') {
      formError.value = `请填写${f.label}`
      return
    }
  }
  formError.value = ''
  try {
    const payload = { ...form }
    if (editingId.value !== null) payload.id = editingId.value
    const res = editingId.value === null ? await mod.add(payload) : await mod.update(payload)
    if (res.code !== 200) {
      formError.value = res.msg || '保存失败'
      return
    }
    showMsg(res.msg || '保存成功', 'success')
    modalVisible.value = false
    loadRows()
  } catch (e) {
    formError.value = e.message
  }
}

// ---------- 删除确认 ----------
const confirmVisible = ref(false)
const deleteTarget = ref(null)
function askDelete(row) {
  deleteTarget.value = row
  confirmVisible.value = true
}
function cancelDelete() {
  confirmVisible.value = false
  deleteTarget.value = null
}
async function doDelete() {
  const mod = MODULES[currentModule.value]
  try {
    const res = await mod.remove(deleteTarget.value.id)
    if (res.code !== 200) {
      showMsg(res.msg || '删除失败', 'error')
    } else {
      showMsg(res.msg || '删除成功', 'success')
      loadRows()
    }
  } catch (e) {
    showMsg(e.message, 'error')
  } finally {
    cancelDelete()
  }
}

// ---------- 退出登录 ----------
async function handleLogout() {
  try {
    await adminLogout()
  } catch (_) { /* 忽略网络错误，本地清理即可 */ }
  localStorage.removeItem('adminToken')
  localStorage.removeItem('adminUsername')
  emit('logout')
}

onMounted(loadRows)
</script>

<template>
  <div class="admin-page">
    <header class="admin-header">
      <div class="brand">
        <span class="crown">♛</span>
        <span class="title">后台管理</span>
        <span class="user">{{ adminName }}</span>
      </div>
      <button class="logout-btn" @click="handleLogout">退出登录</button>
    </header>

    <div class="msg" :class="msgType">{{ message }}</div>

    <main class="admin-body">
      <nav class="tabs">
        <button
          v-for="(mod, key) in MODULES"
          :key="key"
          class="tab"
          :class="{ active: currentModule === key }"
          @click="switchModule(key)"
        >{{ mod.label }}</button>
        <button class="add-btn" @click="openAdd">+ 新增</button>
      </nav>

      <div class="table-card">
        <table class="table">
          <thead>
            <tr>
              <th style="width: 70px">ID</th>
              <th v-for="col in MODULES[currentModule].columns" :key="col.key" :style="col.width ? { width: col.width } : {}">
                {{ col.label }}
              </th>
              <th style="width: 150px">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="tableLoading">
              <td :colspan="MODULES[currentModule].columns.length + 2" class="empty">加载中…</td>
            </tr>
            <tr v-else-if="!rows.length">
              <td :colspan="MODULES[currentModule].columns.length + 2" class="empty">暂无数据，点击右上角「+ 新增」添加</td>
            </tr>
            <tr v-else v-for="row in rows" :key="row.id">
              <td class="mono">{{ row.id }}</td>
              <td v-for="col in MODULES[currentModule].columns" :key="col.key" :class="{ desc: col.key === 'description' }">
                {{ row[col.key] }}
              </td>
              <td class="actions">
                <button class="op edit" @click="openEdit(row)">编辑</button>
                <button class="op del" @click="askDelete(row)">删除</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </main>

    <!-- 新增 / 编辑弹窗 -->
    <div class="mask" v-if="modalVisible" @click.self="closeModal">
      <div class="modal">
        <h3>{{ editingId === null ? '新增' : '编辑' }}·{{ MODULES[currentModule].label }}</h3>
        <div class="form-error" v-if="formError">{{ formError }}</div>
        <div class="form-field" v-for="f in FORM_FIELDS[currentModule]" :key="f.key">
          <label>{{ f.label }}<span v-if="f.required" class="req">*</span></label>
          <textarea
            v-if="f.type === 'textarea'"
            v-model="form[f.key]"
            :placeholder="f.placeholder"
            rows="3"
          ></textarea>
          <input
            v-else
            :type="f.type"
            v-model="form[f.key]"
            :placeholder="f.placeholder"
          />
        </div>
        <div class="modal-actions">
          <button class="btn ghost" @click="closeModal">取消</button>
          <button class="btn primary" @click="submitForm">保存</button>
        </div>
      </div>
    </div>

    <!-- 删除确认弹窗 -->
    <div class="mask" v-if="confirmVisible" @click.self="cancelDelete">
      <div class="modal small">
        <h3>确认删除</h3>
        <p class="confirm-text">
          确定删除这条{{ MODULES[currentModule].label }}记录（ID: {{ deleteTarget?.id }}）吗？此操作不可恢复。
        </p>
        <div class="modal-actions">
          <button class="btn ghost" @click="cancelDelete">取消</button>
          <button class="btn danger" @click="doDelete">确认删除</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-page {
  min-height: 100vh;
  color: #f5f0ff;
  background:
    radial-gradient(900px 520px at 15% -10%, rgba(253, 185, 39, 0.1), transparent 60%),
    linear-gradient(150deg, #2a1450 0%, #1a0b2e 45%, #0e0619 100%);
}
.admin-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 28px;
  background: rgba(26, 12, 46, 0.85);
  border-bottom: 1px solid rgba(253, 185, 39, 0.25);
}
.brand {
  display: flex;
  align-items: center;
  gap: 12px;
}
.crown {
  font-size: 22px;
  color: #fdb927;
}
.title {
  font-size: 18px;
  font-weight: 800;
  letter-spacing: 2px;
}
.user {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 20px;
  border: 1px solid rgba(253, 185, 39, 0.4);
  color: #fdb927;
}
.logout-btn {
  padding: 8px 18px;
  border: 1px solid rgba(140, 110, 190, 0.4);
  border-radius: 8px;
  background: transparent;
  color: rgba(245, 240, 255, 0.8);
  font-size: 13px;
  cursor: pointer;
  transition: 0.2s;
}
.logout-btn:hover {
  border-color: #ff7d7d;
  color: #ff7d7d;
}

.msg {
  min-height: 20px;
  margin: 10px 28px 0;
  font-size: 13px;
}
.msg.error { color: #ff7d7d; }
.msg.success { color: #7de8a9; }

.admin-body {
  max-width: 1100px;
  margin: 0 auto;
  padding: 20px 28px 40px;
}
.tabs {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}
.tab {
  padding: 9px 20px;
  border: 1px solid rgba(140, 110, 190, 0.4);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.04);
  color: rgba(245, 240, 255, 0.75);
  font-size: 14px;
  cursor: pointer;
  transition: 0.2s;
}
.tab:hover {
  border-color: rgba(253, 185, 39, 0.6);
}
.tab.active {
  background: linear-gradient(135deg, #fdb927 0%, #e9a51f 100%);
  border-color: transparent;
  color: #241043;
  font-weight: 700;
}
.add-btn {
  margin-left: auto;
  padding: 9px 20px;
  border: 1px solid rgba(253, 185, 39, 0.55);
  border-radius: 10px;
  background: transparent;
  color: #fdb927;
  font-size: 14px;
  cursor: pointer;
  transition: 0.2s;
}
.add-btn:hover {
  background: #fdb927;
  color: #241043;
  font-weight: 700;
}

.table-card {
  background: rgba(26, 12, 46, 0.7);
  border: 1px solid rgba(140, 110, 190, 0.3);
  border-radius: 14px;
  overflow: hidden;
}
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.table th {
  padding: 12px 14px;
  text-align: left;
  font-size: 12px;
  letter-spacing: 1px;
  color: rgba(253, 185, 39, 0.9);
  background: rgba(253, 185, 39, 0.06);
  border-bottom: 1px solid rgba(253, 185, 39, 0.2);
  white-space: nowrap;
}
.table td {
  padding: 11px 14px;
  border-bottom: 1px solid rgba(140, 110, 190, 0.15);
  color: rgba(245, 240, 255, 0.85);
  vertical-align: top;
}
.table tr:last-child td {
  border-bottom: none;
}
.table tr:hover td {
  background: rgba(253, 185, 39, 0.04);
}
.mono {
  font-family: Consolas, monospace;
  color: rgba(245, 240, 255, 0.5);
}
.desc {
  max-width: 320px;
}
.empty {
  text-align: center;
  padding: 40px 0 !important;
  color: rgba(245, 240, 255, 0.4);
}
.actions {
  white-space: nowrap;
}
.op {
  padding: 5px 12px;
  margin-right: 8px;
  border-radius: 7px;
  font-size: 12px;
  cursor: pointer;
  transition: 0.2s;
}
.op.edit {
  border: 1px solid rgba(253, 185, 39, 0.5);
  background: transparent;
  color: #fdb927;
}
.op.edit:hover {
  background: #fdb927;
  color: #241043;
}
.op.del {
  border: 1px solid rgba(255, 125, 125, 0.45);
  background: transparent;
  color: #ff7d7d;
}
.op.del:hover {
  background: #ff7d7d;
  color: #fff;
}

/* ===== 弹窗 ===== */
.mask {
  position: fixed;
  inset: 0;
  background: rgba(6, 2, 12, 0.7);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal {
  width: 460px;
  max-width: calc(100vw - 32px);
  max-height: 85vh;
  overflow-y: auto;
  padding: 26px 26px 22px;
  background: #22103e;
  border: 1px solid rgba(253, 185, 39, 0.35);
  border-radius: 16px;
  box-shadow: 0 24px 70px rgba(0, 0, 0, 0.6);
}
.modal.small {
  width: 360px;
}
.modal h3 {
  margin: 0 0 18px;
  font-size: 17px;
  color: #fff;
}
.confirm-text {
  font-size: 14px;
  line-height: 1.7;
  color: rgba(245, 240, 255, 0.8);
  margin: 0 0 20px;
}
.form-error {
  margin-bottom: 12px;
  font-size: 13px;
  color: #ff7d7d;
}
.form-field {
  margin-bottom: 14px;
}
.form-field label {
  display: block;
  font-size: 13px;
  color: rgba(245, 240, 255, 0.65);
  margin-bottom: 6px;
}
.req {
  color: #ff7d7d;
  margin-left: 3px;
}
.form-field input,
.form-field textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid rgba(140, 110, 190, 0.35);
  border-radius: 9px;
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
  font-family: inherit;
}
.form-field input:focus,
.form-field textarea:focus {
  border-color: #fdb927;
  box-shadow: 0 0 0 3px rgba(253, 185, 39, 0.15);
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}
.btn {
  padding: 9px 22px;
  border-radius: 9px;
  font-size: 14px;
  cursor: pointer;
  transition: 0.2s;
}
.btn.ghost {
  border: 1px solid rgba(140, 110, 190, 0.4);
  background: transparent;
  color: rgba(245, 240, 255, 0.8);
}
.btn.ghost:hover {
  border-color: rgba(245, 240, 255, 0.7);
}
.btn.primary {
  border: none;
  background: linear-gradient(135deg, #fdb927 0%, #e9a51f 100%);
  color: #241043;
  font-weight: 700;
}
.btn.primary:hover {
  filter: brightness(1.06);
}
.btn.danger {
  border: none;
  background: #e05252;
  color: #fff;
  font-weight: 700;
}
.btn.danger:hover {
  filter: brightness(1.08);
}
</style>
