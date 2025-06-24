<template>
  <div id="app">
    <nav v-if="$route.name !== 'Login'" class="navbar">
      <div class="nav-brand">
        <h2>工場設備管理システム</h2>
      </div>
      <div class="nav-menu">
        <router-link to="/dashboard" class="nav-item">ダッシュボード</router-link>
        <router-link to="/equipment" class="nav-item">設備管理</router-link>
        <router-link to="/alerts" class="nav-item">アラート</router-link>
        <router-link to="/maintenance" class="nav-item">保全管理</router-link>
        <router-link to="/reports" class="nav-item">分析・レポート</router-link>
        <router-link to="/settings" class="nav-item">設定</router-link>
        <button @click="logout" class="nav-logout">ログアウト</button>
      </div>
    </nav>
    
    <main class="main-content" :class="{ 'full-height': $route.name === 'Login' }">
      <router-view />
    </main>
    
    <!-- オフライン状態の表示 -->
    <div v-if="!isOnline" class="offline-banner">
      オフラインモードで動作中
    </div>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      isOnline: navigator.onLine
    }
  },
  mounted() {
    // オンライン/オフライン状態の監視
    window.addEventListener('online', this.handleOnline)
    window.addEventListener('offline', this.handleOffline)
  },
  beforeUnmount() {
    window.removeEventListener('online', this.handleOnline)
    window.removeEventListener('offline', this.handleOffline)
  },
  methods: {
    logout() {
      // ログアウト処理
      localStorage.removeItem('authToken')
      this.$router.push('/login')
    },
    handleOnline() {
      this.isOnline = true
    },
    handleOffline() {
      this.isOnline = false
    }
  }
}
</script>

<style>
/* リセットCSS */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Hiragino Sans', 'ヒラギノ角ゴ ProN', 'Hiragino Kaku Gothic ProN', 'メイリオ', Meiryo, sans-serif;
  background-color: #f5f5f5;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* ナビゲーションバー */
.navbar {
  background-color: #2c3e50;
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.nav-brand h2 {
  color: white;
}

.nav-menu {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.nav-item {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.nav-item:hover,
.nav-item.router-link-active {
  background-color: #34495e;
}

.nav-logout {
  background-color: #e74c3c;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.nav-logout:hover {
  background-color: #c0392b;
}

/* メインコンテンツ */
.main-content {
  flex: 1;
  padding: 2rem;
}

.main-content.full-height {
  padding: 0;
}

/* オフラインバナー */
.offline-banner {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  background-color: #f39c12;
  color: white;
  text-align: center;
  padding: 0.5rem;
  z-index: 1000;
}

/* レスポンシブデザイン */
@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    gap: 1rem;
  }
  
  .nav-menu {
    flex-wrap: wrap;
    justify-content: center;
  }
  
  .main-content {
    padding: 1rem;
  }
}

/* 共通ボタンスタイル */
.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover {
  background-color: #2980b9;
}

.btn-success {
  background-color: #27ae60;
  color: white;
}

.btn-success:hover {
  background-color: #229954;
}

.btn-danger {
  background-color: #e74c3c;
  color: white;
}

.btn-danger:hover {
  background-color: #c0392b;
}

.btn-warning {
  background-color: #f39c12;
  color: white;
}

.btn-warning:hover {
  background-color: #e67e22;
}

/* カード共通スタイル */
.card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin-bottom: 1rem;
}

.card-title {
  font-size: 1.2rem;
  margin-bottom: 1rem;
  color: #2c3e50;
}

/* フォーム共通スタイル */
.form-group {
  margin-bottom: 1rem;
}

.form-label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
  color: #2c3e50;
}

.form-input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #3498db;
}

/* グリッドレイアウト */
.grid {
  display: grid;
  gap: 1rem;
}

.grid-2 {
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
}

.grid-3 {
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}

.grid-4 {
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
}

/* ユーティリティクラス */
.text-center {
  text-align: center;
}

.text-success {
  color: #27ae60;
}

.text-danger {
  color: #e74c3c;
}

.text-warning {
  color: #f39c12;
}

.mb-1 {
  margin-bottom: 1rem;
}

.mb-2 {
  margin-bottom: 2rem;
}

.mt-1 {
  margin-top: 1rem;
}

.mt-2 {
  margin-top: 2rem;
}
</style>