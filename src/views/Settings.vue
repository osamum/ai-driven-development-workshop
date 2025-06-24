<template>
  <div class="settings">
    <div class="settings-header">
      <h1>設定</h1>
      <p>システム設定とユーザー設定の管理</p>
    </div>
    
    <!-- 設定タブ -->
    <div class="settings-tabs">
      <button 
        v-for="tab in tabs"
        :key="tab.id"
        @click="activeTab = tab.id"
        class="tab-button"
        :class="{ 'active': activeTab === tab.id }"
      >
        {{ tab.label }}
      </button>
    </div>
    
    <!-- ユーザー設定タブ -->
    <div v-if="activeTab === 'user'" class="tab-content">
      <div class="settings-section card">
        <h2>ユーザー設定</h2>
        
        <div class="setting-group">
          <h3>プロフィール</h3>
          <div class="form-group">
            <label class="form-label">ユーザー名</label>
            <input v-model="userSettings.username" type="text" class="form-input" readonly>
          </div>
          <div class="form-group">
            <label class="form-label">表示名</label>
            <input v-model="userSettings.displayName" type="text" class="form-input">
          </div>
          <div class="form-group">
            <label class="form-label">メールアドレス</label>
            <input v-model="userSettings.email" type="email" class="form-input">
          </div>
          <div class="form-group">
            <label class="form-label">部署</label>
            <select v-model="userSettings.department" class="form-input">
              <option value="">選択してください</option>
              <option value="manufacturing">製造部</option>
              <option value="maintenance">保全部</option>
              <option value="quality">品質管理部</option>
              <option value="management">管理部</option>
            </select>
          </div>
        </div>
        
        <div class="setting-group">
          <h3>言語・地域設定</h3>
          <div class="form-group">
            <label class="form-label">言語</label>
            <select v-model="userSettings.language" class="form-input">
              <option value="ja">日本語</option>
              <option value="en">English</option>
              <option value="zh">中文</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">タイムゾーン</label>
            <select v-model="userSettings.timezone" class="form-input">
              <option value="Asia/Tokyo">Asia/Tokyo (JST)</option>
              <option value="UTC">UTC</option>
              <option value="America/New_York">America/New_York (EST)</option>
            </select>
          </div>
        </div>
        
        <div class="setting-actions">
          <button @click="saveUserSettings" class="btn btn-primary">保存</button>
          <button @click="resetUserSettings" class="btn btn-secondary">リセット</button>
        </div>
      </div>
    </div>
    
    <!-- 通知設定タブ -->
    <div v-if="activeTab === 'notifications'" class="tab-content">
      <div class="settings-section card">
        <h2>通知設定</h2>
        
        <div class="setting-group">
          <h3>アラート通知</h3>
          <div class="notification-item">
            <label class="notification-label">
              <input type="checkbox" v-model="notificationSettings.alerts.email">
              メール通知
            </label>
            <p class="notification-description">重要度「高」のアラートをメールで受信</p>
          </div>
          <div class="notification-item">
            <label class="notification-label">
              <input type="checkbox" v-model="notificationSettings.alerts.browser">
              ブラウザ通知
            </label>
            <p class="notification-description">リアルタイムでブラウザに通知を表示</p>
          </div>
          <div class="notification-item">
            <label class="notification-label">
              <input type="checkbox" v-model="notificationSettings.alerts.sound">
              音声通知
            </label>
            <p class="notification-description">アラート発生時に音で通知</p>
          </div>
        </div>
        
        <div class="setting-group">
          <h3>保全通知</h3>
          <div class="notification-item">
            <label class="notification-label">
              <input type="checkbox" v-model="notificationSettings.maintenance.schedule">
              保全スケジュール通知
            </label>
            <p class="notification-description">保全予定の1日前にメール通知</p>
          </div>
          <div class="notification-item">
            <label class="notification-label">
              <input type="checkbox" v-model="notificationSettings.maintenance.overdue">
              保全遅延通知
            </label>
            <p class="notification-description">予定時刻を過ぎた保全作業を通知</p>
          </div>
        </div>
        
        <div class="setting-group">
          <h3>レポート通知</h3>
          <div class="notification-item">
            <label class="notification-label">
              <input type="checkbox" v-model="notificationSettings.reports.weekly">
              週次レポート
            </label>
            <p class="notification-description">毎週月曜日に週次レポートを送信</p>
          </div>
          <div class="notification-item">
            <label class="notification-label">
              <input type="checkbox" v-model="notificationSettings.reports.monthly">
              月次レポート
            </label>
            <p class="notification-description">毎月1日に月次レポートを送信</p>
          </div>
        </div>
        
        <div class="setting-actions">
          <button @click="saveNotificationSettings" class="btn btn-primary">保存</button>
          <button @click="testNotification" class="btn btn-warning">通知テスト</button>
        </div>
      </div>
    </div>
    
    <!-- ダッシュボード設定タブ -->
    <div v-if="activeTab === 'dashboard'" class="tab-content">
      <div class="settings-section card">
        <h2>ダッシュボード設定</h2>
        
        <div class="setting-group">
          <h3>表示設定</h3>
          <div class="form-group">
            <label class="form-label">更新間隔</label>
            <select v-model="dashboardSettings.refreshInterval" class="form-input">
              <option value="5">5秒</option>
              <option value="10">10秒</option>
              <option value="30">30秒</option>
              <option value="60">1分</option>
              <option value="300">5分</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">デフォルト期間</label>
            <select v-model="dashboardSettings.defaultPeriod" class="form-input">
              <option value="1h">1時間</option>
              <option value="6h">6時間</option>
              <option value="24h">24時間</option>
              <option value="7d">7日間</option>
              <option value="30d">30日間</option>
            </select>
          </div>
        </div>
        
        <div class="setting-group">
          <h3>ウィジェット設定</h3>
          <div class="widget-settings">
            <div 
              v-for="widget in dashboardSettings.widgets"
              :key="widget.id"
              class="widget-item"
            >
              <div class="widget-info">
                <label class="widget-label">
                  <input type="checkbox" v-model="widget.enabled">
                  {{ widget.name }}
                </label>
                <p class="widget-description">{{ widget.description }}</p>
              </div>
              <div class="widget-controls">
                <select v-model="widget.size" class="form-input widget-size">
                  <option value="small">小</option>
                  <option value="medium">中</option>
                  <option value="large">大</option>
                </select>
                <input 
                  v-model="widget.order" 
                  type="number" 
                  class="form-input widget-order"
                  min="1"
                  max="10"
                >
              </div>
            </div>
          </div>
        </div>
        
        <div class="setting-actions">
          <button @click="saveDashboardSettings" class="btn btn-primary">保存</button>
          <button @click="resetDashboardLayout" class="btn btn-secondary">レイアウトリセット</button>
        </div>
      </div>
    </div>
    
    <!-- システム管理タブ -->
    <div v-if="activeTab === 'system'" class="tab-content">
      <div class="settings-section card">
        <h2>システム管理</h2>
        
        <div class="setting-group">
          <h3>データ管理</h3>
          <div class="system-action">
            <h4>データバックアップ</h4>
            <p>システムデータの手動バックアップを実行します。</p>
            <button @click="backupData" class="btn btn-success">バックアップ実行</button>
          </div>
          <div class="system-action">
            <h4>データクリーンアップ</h4>
            <p>古いログデータとキャッシュデータを削除します。</p>
            <button @click="cleanupData" class="btn btn-warning">クリーンアップ実行</button>
          </div>
        </div>
        
        <div class="setting-group">
          <h3>システム情報</h3>
          <div class="system-info">
            <div class="info-item">
              <span class="info-label">バージョン:</span>
              <span>v1.0.0</span>
            </div>
            <div class="info-item">
              <span class="info-label">最終更新:</span>
              <span>{{ formatDate(systemInfo.lastUpdate) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">接続設備数:</span>
              <span>{{ systemInfo.connectedDevices }}台</span>
            </div>
            <div class="info-item">
              <span class="info-label">ストレージ使用量:</span>
              <span>{{ systemInfo.storageUsed }}GB / {{ systemInfo.storageTotal }}GB</span>
            </div>
            <div class="info-item">
              <span class="info-label">ユーザー数:</span>
              <span>{{ systemInfo.totalUsers }}名</span>
            </div>
          </div>
        </div>
        
        <div class="setting-group">
          <h3>メンテナンス</h3>
          <div class="system-action">
            <h4>システム再起動</h4>
            <p>システム全体を再起動します。一時的にサービスが停止します。</p>
            <button @click="restartSystem" class="btn btn-danger">再起動</button>
          </div>
          <div class="system-action">
            <h4>設定リセット</h4>
            <p>すべての設定を初期値にリセットします。</p>
            <button @click="resetAllSettings" class="btn btn-danger">リセット</button>
          </div>
        </div>
        
        <div class="setting-group">
          <h3>ログ・監査</h3>
          <div class="log-section">
            <h4>最近のシステムログ</h4>
            <div class="log-entries">
              <div 
                v-for="log in systemLogs"
                :key="log.id"
                class="log-entry"
                :class="getLogLevelClass(log.level)"
              >
                <span class="log-time">{{ formatTime(log.timestamp) }}</span>
                <span class="log-level">{{ log.level }}</span>
                <span class="log-message">{{ log.message }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Settings',
  data() {
    return {
      activeTab: 'user',
      tabs: [
        { id: 'user', label: 'ユーザー設定' },
        { id: 'notifications', label: '通知設定' },
        { id: 'dashboard', label: 'ダッシュボード設定' },
        { id: 'system', label: 'システム管理' }
      ],
      userSettings: {
        username: 'admin',
        displayName: '管理者',
        email: 'admin@factory.com',
        department: 'management',
        language: 'ja',
        timezone: 'Asia/Tokyo'
      },
      notificationSettings: {
        alerts: {
          email: true,
          browser: true,
          sound: false
        },
        maintenance: {
          schedule: true,
          overdue: true
        },
        reports: {
          weekly: true,
          monthly: true
        }
      },
      dashboardSettings: {
        refreshInterval: 30,
        defaultPeriod: '24h',
        widgets: [
          {
            id: 1,
            name: 'KPI サマリー',
            description: '主要指標の概要表示',
            enabled: true,
            size: 'large',
            order: 1
          },
          {
            id: 2,
            name: '設備状況',
            description: '設備の稼働状況一覧',
            enabled: true,
            size: 'medium',
            order: 2
          },
          {
            id: 3,
            name: '最新アラート',
            description: '最新のアラート情報',
            enabled: true,
            size: 'medium',
            order: 3
          },
          {
            id: 4,
            name: '保全スケジュール',
            description: '今後の保全予定',
            enabled: false,
            size: 'small',
            order: 4
          },
          {
            id: 5,
            name: '稼働率グラフ',
            description: '時系列稼働率グラフ',
            enabled: true,
            size: 'large',
            order: 5
          }
        ]
      },
      systemInfo: {
        lastUpdate: new Date('2024-06-20T10:30:00'),
        connectedDevices: 4,
        storageUsed: 2.5,
        storageTotal: 10,
        totalUsers: 15
      },
      systemLogs: [
        {
          id: 1,
          timestamp: new Date(Date.now() - 300000),
          level: 'INFO',
          message: 'システム定期バックアップが完了しました'
        },
        {
          id: 2,
          timestamp: new Date(Date.now() - 600000),
          level: 'WARNING',
          message: 'CNC加工機A1からの通信遅延を検出'
        },
        {
          id: 3,
          timestamp: new Date(Date.now() - 900000),
          level: 'INFO',
          message: 'ユーザー「田中太郎」がログインしました'
        },
        {
          id: 4,
          timestamp: new Date(Date.now() - 1200000),
          level: 'ERROR',
          message: 'プレス機B1のセンサーデータ取得に失敗'
        }
      ]
    }
  },
  mounted() {
    this.loadSettings()
  },
  methods: {
    loadSettings() {
      // ローカルストレージから設定を読み込み
      const saved = localStorage.getItem('userSettings')
      if (saved) {
        this.userSettings = { ...this.userSettings, ...JSON.parse(saved) }
      }
    },
    
    saveUserSettings() {
      localStorage.setItem('userSettings', JSON.stringify(this.userSettings))
      alert('ユーザー設定を保存しました。')
    },
    
    resetUserSettings() {
      this.userSettings = {
        username: 'admin',
        displayName: '管理者',
        email: 'admin@factory.com',
        department: 'management',
        language: 'ja',
        timezone: 'Asia/Tokyo'
      }
    },
    
    saveNotificationSettings() {
      localStorage.setItem('notificationSettings', JSON.stringify(this.notificationSettings))
      alert('通知設定を保存しました。')
    },
    
    testNotification() {
      if ('Notification' in window) {
        if (Notification.permission === 'granted') {
          new Notification('テスト通知', {
            body: 'これはテスト通知です。',
            icon: '/favicon.ico'
          })
        } else if (Notification.permission !== 'denied') {
          Notification.requestPermission().then(permission => {
            if (permission === 'granted') {
              new Notification('テスト通知', {
                body: 'これはテスト通知です。',
                icon: '/favicon.ico'
              })
            }
          })
        }
      } else {
        alert('このブラウザは通知をサポートしていません。')
      }
    },
    
    saveDashboardSettings() {
      localStorage.setItem('dashboardSettings', JSON.stringify(this.dashboardSettings))
      alert('ダッシュボード設定を保存しました。')
    },
    
    resetDashboardLayout() {
      if (confirm('ダッシュボードレイアウトを初期設定にリセットしますか？')) {
        // レイアウトリセット処理
        alert('ダッシュボードレイアウトをリセットしました。')
      }
    },
    
    backupData() {
      if (confirm('データバックアップを実行しますか？')) {
        // バックアップ処理のシミュレーション
        setTimeout(() => {
          alert('データバックアップが完了しました。')
        }, 2000)
      }
    },
    
    cleanupData() {
      if (confirm('データクリーンアップを実行しますか？古いデータが削除されます。')) {
        // クリーンアップ処理のシミュレーション
        setTimeout(() => {
          alert('データクリーンアップが完了しました。')
        }, 1500)
      }
    },
    
    restartSystem() {
      if (confirm('システムを再起動しますか？一時的にサービスが停止します。')) {
        alert('システム再起動を開始します。しばらくお待ちください。')
        // 実際の実装では再起動処理
      }
    },
    
    resetAllSettings() {
      if (confirm('すべての設定を初期値にリセットしますか？この操作は取り消せません。')) {
        localStorage.clear()
        alert('すべての設定をリセットしました。ページを再読み込みしてください。')
      }
    },
    
    getLogLevelClass(level) {
      switch (level) {
        case 'ERROR': return 'log-error'
        case 'WARNING': return 'log-warning'
        case 'INFO': return 'log-info'
        default: return ''
      }
    },
    
    formatDate(date) {
      return new Date(date).toLocaleDateString('ja-JP')
    },
    
    formatTime(date) {
      return new Date(date).toLocaleString('ja-JP')
    }
  }
}
</script>

<style scoped>
.settings-header {
  margin-bottom: 2rem;
}

.settings-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 1px solid #ecf0f1;
}

.tab-button {
  padding: 0.75rem 1.5rem;
  border: none;
  background: none;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.3s;
}

.tab-button.active {
  border-bottom-color: #3498db;
  color: #3498db;
}

.settings-section h2 {
  margin-bottom: 2rem;
  color: #2c3e50;
  border-bottom: 2px solid #3498db;
  padding-bottom: 0.5rem;
}

.setting-group {
  margin-bottom: 2rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid #ecf0f1;
}

.setting-group:last-child {
  border-bottom: none;
}

.setting-group h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.form-group {
  margin-bottom: 1rem;
}

.setting-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #ecf0f1;
}

.notification-item {
  margin-bottom: 1rem;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.notification-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: bold;
  color: #2c3e50;
  cursor: pointer;
}

.notification-description {
  margin: 0.5rem 0 0 1.5rem;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.widget-settings {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.widget-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.widget-info {
  flex: 1;
}

.widget-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: bold;
  color: #2c3e50;
  cursor: pointer;
}

.widget-description {
  margin: 0.5rem 0 0 1.5rem;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.widget-controls {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.widget-size {
  width: 80px;
}

.widget-order {
  width: 60px;
}

.system-action {
  margin-bottom: 2rem;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.system-action h4 {
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.system-action p {
  margin-bottom: 1rem;
  color: #7f8c8d;
}

.system-info {
  background-color: #f8f9fa;
  padding: 1rem;
  border-radius: 4px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid #ecf0f1;
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  font-weight: bold;
  color: #7f8c8d;
}

.log-section {
  background-color: #f8f9fa;
  padding: 1rem;
  border-radius: 4px;
}

.log-section h4 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.log-entries {
  max-height: 300px;
  overflow-y: auto;
  background-color: white;
  border-radius: 4px;
  padding: 0.5rem;
}

.log-entry {
  display: flex;
  gap: 1rem;
  padding: 0.5rem;
  border-bottom: 1px solid #ecf0f1;
  font-family: monospace;
  font-size: 0.9rem;
}

.log-entry:last-child {
  border-bottom: none;
}

.log-time {
  min-width: 120px;
  color: #7f8c8d;
}

.log-level {
  min-width: 80px;
  font-weight: bold;
}

.log-message {
  flex: 1;
  color: #2c3e50;
}

.log-error .log-level {
  color: #e74c3c;
}

.log-warning .log-level {
  color: #f39c12;
}

.log-info .log-level {
  color: #3498db;
}

@media (max-width: 768px) {
  .settings-tabs {
    flex-wrap: wrap;
  }
  
  .setting-actions {
    flex-direction: column;
  }
  
  .widget-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .widget-controls {
    align-self: stretch;
    justify-content: space-between;
  }
  
  .info-item {
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .log-entry {
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .log-time,
  .log-level {
    min-width: auto;
  }
}
</style>