<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <h1>統合ダッシュボード</h1>
      <p>ようこそ、{{ username }}さん</p>
    </div>
    
    <!-- KPI サマリー -->
    <div class="kpi-grid grid grid-4">
      <div class="kpi-card card">
        <h3>稼働設備数</h3>
        <div class="kpi-value text-success">{{ kpis.activeEquipment }}</div>
        <div class="kpi-total">/ {{ kpis.totalEquipment }} 台</div>
      </div>
      
      <div class="kpi-card card">
        <h3>アクティブアラート</h3>
        <div class="kpi-value text-danger">{{ kpis.activeAlerts }}</div>
        <div class="kpi-total">件</div>
      </div>
      
      <div class="kpi-card card">
        <h3>稼働率</h3>
        <div class="kpi-value text-success">{{ kpis.operationRate }}%</div>
        <div class="kpi-total">今日</div>
      </div>
      
      <div class="kpi-card card">
        <h3>保全予定</h3>
        <div class="kpi-value text-warning">{{ kpis.maintenanceScheduled }}</div>
        <div class="kpi-total">件 (今週)</div>
      </div>
    </div>
    
    <!-- メインコンテンツエリア -->
    <div class="dashboard-content grid grid-2">
      <!-- 設備状況 -->
      <div class="card">
        <h2 class="card-title">設備状況</h2>
        <div class="equipment-list">
          <div 
            v-for="equipment in equipmentList" 
            :key="equipment.id"
            class="equipment-item"
            :class="getStatusClass(equipment.status)"
          >
            <div class="equipment-info">
              <strong>{{ equipment.name }}</strong>
              <span class="equipment-location">{{ equipment.location }}</span>
            </div>
            <div class="equipment-status">
              {{ equipment.status }}
            </div>
          </div>
        </div>
        <router-link to="/equipment" class="btn btn-primary mt-1">
          設備一覧を見る
        </router-link>
      </div>
      
      <!-- 最新アラート -->
      <div class="card">
        <h2 class="card-title">最新アラート</h2>
        <div class="alert-list">
          <div 
            v-for="alert in recentAlerts" 
            :key="alert.id"
            class="alert-item"
            :class="getSeverityClass(alert.severity)"
          >
            <div class="alert-info">
              <strong>{{ alert.title }}</strong>
              <p>{{ alert.description }}</p>
              <small>{{ formatTime(alert.detected_at) }}</small>
            </div>
            <div class="alert-severity">
              {{ alert.severity }}
            </div>
          </div>
        </div>
        <router-link to="/alerts" class="btn btn-danger mt-1">
          アラート管理を見る
        </router-link>
      </div>
    </div>
    
    <!-- クイックアクション -->
    <div class="quick-actions card">
      <h2 class="card-title">クイックアクション</h2>
      <div class="action-buttons grid grid-4">
        <router-link to="/equipment" class="btn btn-primary">
          設備詳細
        </router-link>
        <router-link to="/alerts" class="btn btn-danger">
          アラート管理
        </router-link>
        <router-link to="/maintenance" class="btn btn-warning">
          保全管理
        </router-link>
        <router-link to="/reports" class="btn btn-success">
          分析・レポート
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Dashboard',
  data() {
    return {
      username: '',
      kpis: {
        activeEquipment: 8,
        totalEquipment: 10,
        activeAlerts: 3,
        operationRate: 94.5,
        maintenanceScheduled: 2
      },
      equipmentList: [
        {
          id: 1,
          name: 'CNC加工機A1',
          location: '工場棟A-1F-001',
          status: '稼働中'
        },
        {
          id: 2,
          name: '搬送ロボット1',
          location: '工場棟A-1F-002',
          status: '稼働中'
        },
        {
          id: 3,
          name: 'プレス機B1',
          location: '工場棟B-1F-001',
          status: '保守中'
        },
        {
          id: 4,
          name: '検査機C1',
          location: '工場棟C-1F-001',
          status: '稼働中'
        }
      ],
      recentAlerts: [
        {
          id: 1,
          title: 'CNC加工機A1 温度異常',
          description: '設備温度が正常範囲を超過しました',
          severity: '高',
          detected_at: new Date(Date.now() - 30000) // 30秒前
        },
        {
          id: 2,
          title: '搬送ロボット1 動作異常',
          description: '動作速度が通常より低下しています',
          severity: '中',
          detected_at: new Date(Date.now() - 300000) // 5分前
        },
        {
          id: 3,
          title: '電力使用量注意',
          description: '工場全体の電力使用量が増加傾向',
          severity: '低',
          detected_at: new Date(Date.now() - 900000) // 15分前
        }
      ]
    }
  },
  mounted() {
    this.username = localStorage.getItem('username') || 'ユーザー'
    this.loadDashboardData()
  },
  methods: {
    loadDashboardData() {
      // 実際の実装では API からデータを取得
      // オフライン対応のため、ローカルストレージからもデータを取得可能にする
      this.loadFromLocalStorage()
    },
    
    loadFromLocalStorage() {
      // ローカルストレージからキャッシュされたデータを読み込み
      const cachedData = localStorage.getItem('dashboardData')
      if (cachedData) {
        const data = JSON.parse(cachedData)
        this.kpis = data.kpis || this.kpis
        this.equipmentList = data.equipmentList || this.equipmentList
        this.recentAlerts = data.recentAlerts || this.recentAlerts
      }
    },
    
    getStatusClass(status) {
      switch (status) {
        case '稼働中': return 'status-active'
        case '保守中': return 'status-maintenance'
        case '停止中': return 'status-stopped'
        default: return ''
      }
    },
    
    getSeverityClass(severity) {
      switch (severity) {
        case '高': return 'severity-high'
        case '中': return 'severity-medium'
        case '低': return 'severity-low'
        default: return ''
      }
    },
    
    formatTime(date) {
      const now = new Date()
      const diff = Math.floor((now - date) / 1000)
      
      if (diff < 60) return `${diff}秒前`
      if (diff < 3600) return `${Math.floor(diff / 60)}分前`
      if (diff < 86400) return `${Math.floor(diff / 3600)}時間前`
      return date.toLocaleDateString('ja-JP')
    }
  }
}
</script>

<style scoped>
.dashboard-header {
  margin-bottom: 2rem;
}

.dashboard-header h1 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.dashboard-header p {
  color: #7f8c8d;
}

.kpi-grid {
  margin-bottom: 2rem;
}

.kpi-card {
  text-align: center;
}

.kpi-card h3 {
  color: #7f8c8d;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.kpi-value {
  font-size: 2rem;
  font-weight: bold;
}

.kpi-total {
  color: #95a5a6;
  font-size: 0.8rem;
}

.equipment-item, .alert-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  border: 1px solid #ecf0f1;
  border-radius: 4px;
  margin-bottom: 0.5rem;
}

.equipment-info, .alert-info {
  flex: 1;
}

.equipment-location {
  display: block;
  color: #7f8c8d;
  font-size: 0.8rem;
}

.alert-info p {
  margin: 0.25rem 0;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.alert-info small {
  color: #95a5a6;
  font-size: 0.8rem;
}

.equipment-status, .alert-severity {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: bold;
}

.status-active .equipment-status {
  background-color: #d5f4e6;
  color: #27ae60;
}

.status-maintenance .equipment-status {
  background-color: #fef5e7;
  color: #f39c12;
}

.status-stopped .equipment-status {
  background-color: #fadbd8;
  color: #e74c3c;
}

.severity-high .alert-severity {
  background-color: #fadbd8;
  color: #e74c3c;
}

.severity-medium .alert-severity {
  background-color: #fef5e7;
  color: #f39c12;
}

.severity-low .alert-severity {
  background-color: #d6eaf8;
  color: #3498db;
}

.action-buttons {
  gap: 1rem;
}

.action-buttons .btn {
  text-align: center;
  text-decoration: none;
}

@media (max-width: 768px) {
  .kpi-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .dashboard-content {
    grid-template-columns: 1fr;
  }
  
  .action-buttons {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>