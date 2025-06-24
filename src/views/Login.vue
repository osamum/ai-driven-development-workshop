<template>
  <div class="login-container">
    <div class="login-form">
      <div class="login-header">
        <h1>工場設備管理システム</h1>
        <p>Factory Equipment Management System</p>
      </div>
      
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label for="username" class="form-label">ユーザー名</label>
          <input
            id="username"
            v-model="username"
            type="text"
            class="form-input"
            placeholder="ユーザー名を入力してください"
            required
          >
        </div>
        
        <div class="form-group">
          <label for="password" class="form-label">パスワード</label>
          <input
            id="password"
            v-model="password"
            type="password"
            class="form-input"
            placeholder="パスワードを入力してください"
            required
          >
        </div>
        
        <div v-if="error" class="error-message">
          {{ error }}
        </div>
        
        <button type="submit" class="btn btn-primary login-btn" :disabled="loading">
          {{ loading ? 'ログイン中...' : 'ログイン' }}
        </button>
      </form>
      
      <div class="demo-info">
        <h3>デモアカウント</h3>
        <p>ユーザー名: admin / パスワード: password</p>
        <p>ユーザー名: operator / パスワード: password</p>
        <p>ユーザー名: maintenance / パスワード: password</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Login',
  data() {
    return {
      username: '',
      password: '',
      loading: false,
      error: ''
    }
  },
  methods: {
    async handleLogin() {
      this.loading = true
      this.error = ''
      
      try {
        // デモ用の認証ロジック
        if (this.validateCredentials()) {
          // 認証トークンを保存（実際の実装では API 呼び出し）
          localStorage.setItem('authToken', 'demo-token-' + Date.now())
          localStorage.setItem('username', this.username)
          
          // ダッシュボードへリダイレクト
          this.$router.push('/dashboard')
        } else {
          this.error = 'ユーザー名またはパスワードが正しくありません'
        }
      } catch (error) {
        this.error = 'ログインに失敗しました。しばらく後に再試行してください。'
      }
      
      this.loading = false
    },
    
    validateCredentials() {
      // デモ用の認証
      const validUsers = [
        { username: 'admin', password: 'password' },
        { username: 'operator', password: 'password' },
        { username: 'maintenance', password: 'password' }
      ]
      
      return validUsers.some(user => 
        user.username === this.username && user.password === this.password
      )
    }
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-form {
  background: white;
  padding: 2rem;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.2);
  width: 100%;
  max-width: 400px;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.login-header h1 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.login-header p {
  color: #7f8c8d;
  font-size: 0.9rem;
}

.login-btn {
  width: 100%;
  padding: 0.75rem;
  font-size: 1.1rem;
  margin-top: 1rem;
}

.error-message {
  background-color: #e74c3c;
  color: white;
  padding: 0.5rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  text-align: center;
}

.demo-info {
  margin-top: 2rem;
  padding: 1rem;
  background-color: #ecf0f1;
  border-radius: 4px;
}

.demo-info h3 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 1rem;
}

.demo-info p {
  color: #7f8c8d;
  font-size: 0.8rem;
  margin-bottom: 0.2rem;
}

@media (max-width: 480px) {
  .login-form {
    margin: 1rem;
    padding: 1.5rem;
  }
}
</style>