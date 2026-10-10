<script setup>
import { ref } from 'vue'
import LoginPage from './components/LoginPage.vue'
import RegisterPage from './components/RegisterPage.vue'
import HomePage from './components/HomePage.vue'

// 当前页面：'login' | 'register' | 'home'
// 已登录（localStorage 有 token）则直接进入主页
const currentPage = ref(localStorage.getItem('token') ? 'home' : 'login')
</script>

<template>
  <LoginPage
    v-if="currentPage === 'login'"
    @go-register="currentPage = 'register'"
    @login-success="currentPage = 'home'"
  />
  <RegisterPage v-else-if="currentPage === 'register'" @go-login="currentPage = 'login'" />
  <HomePage v-else @logout="currentPage = 'login'" />
</template>
