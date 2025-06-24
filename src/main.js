import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { dataLoader } from './data/dataLoader'

// Service Worker の登録（オフライン対応）
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .then((registration) => {
        console.log('Service Worker 登録成功:', registration.scope)
      })
      .catch((error) => {
        console.log('Service Worker 登録失敗:', error)
      })
  })
}

// サンプルデータの初期化
dataLoader.initializeData()

createApp(App).use(router).mount('#app')