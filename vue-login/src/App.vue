<script setup>
import { ref } from 'vue'
import LoginPage from './components/LoginPage.vue'
import RegisterPage from './components/RegisterPage.vue'
import HomePage from './components/HomePage.vue'
import AdminLoginPage from './components/AdminLoginPage.vue'
import AdminPage from './components/AdminPage.vue'

// 当前页面：'login' | 'register' | 'home' | 'adminLogin' | 'admin'
// 已登录（localStorage 有 token）则直接进入主页；
// 已进入后台（localStorage 有 adminToken）则直接进入后台管理
const currentPage = ref(
  localStorage.getItem('adminToken') ? 'admin'
    : localStorage.getItem('token') ? 'home'
    : 'login'
)
</script>

<template>
  <LoginPage
    v-if="currentPage === 'login'"
    @go-register="currentPage = 'register'"
    @login-success="currentPage = 'home'"
  />
  <RegisterPage v-else-if="currentPage === 'register'" @go-login="currentPage = 'login'" />
  <HomePage
    v-else-if="currentPage === 'home'"
    @logout="currentPage = 'login'"
    @go-admin="currentPage = 'adminLogin'"
  />
  <AdminLoginPage
    v-else-if="currentPage === 'adminLogin'"
    @go-home="currentPage = 'home'"
    @login-success="currentPage = 'admin'"
  />
  <AdminPage v-else @logout="currentPage = 'adminLogin'" />
</template>
