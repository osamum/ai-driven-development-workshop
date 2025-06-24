<template>
  <div id="app">
    <!-- ヘッダーナビゲーション -->
    <header class="header">
      <h1 class="header-title">工場設備管理システム</h1>
      <nav class="nav">
        <router-link to="/" class="nav-link">ホーム</router-link>
        <router-link to="/equipment-status" class="nav-link">設備稼働状況</router-link>
        <router-link to="/ai-chat" class="nav-link">AI チャット</router-link>
      </nav>
    </header>

    <!-- メインコンテンツ -->
    <main class="main-content">
      <router-view></router-view>
    </main>

    <!-- フッター -->
    <footer class="footer">
      <p>&copy; 2024 工場設備管理システム</p>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
/* グローバルスタイル */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
  line-height: 1.6;
  color: #333;
  background-color: #f5f5f5;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* ヘッダースタイル */
.header {
  background-color: #2c3e50;
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-title {
  font-size: 1.5rem;
  font-weight: bold;
}

.nav {
  display: flex;
  gap: 2rem;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.nav-link:hover {
  background-color: #34495e;
}

.nav-link.router-link-active {
  background-color: #3498db;
}

/* メインコンテンツ */
.main-content {
  flex: 1;
  padding: 2rem;
}

/* フッター */
.footer {
  background-color: #34495e;
  color: white;
  text-align: center;
  padding: 1rem;
  margin-top: auto;
}

/* レスポンシブデザイン */
@media (max-width: 768px) {
  .header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .nav {
    gap: 1rem;
  }
  
  .main-content {
    padding: 1rem;
  }
}

/* ユーティリティクラス */
.card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin-bottom: 1rem;
}

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

.status-active {
  color: #27ae60;
  font-weight: bold;
}

.status-warning {
  color: #f39c12;
  font-weight: bold;
}

.status-error {
  color: #e74c3c;
  font-weight: bold;
}

.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover {
  background-color: #2980b9;
}
</style>