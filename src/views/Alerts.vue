<template>
  <div class="alerts">
    <div class="alerts-header">
      <h1>アラート管理</h1>
      <p>設備アラートの監視と対応管理</p>
    </div>
    
    <!-- アラート統計 -->
    <div class="alert-stats grid grid-4">
      <div class="stat-card card">
        <h3>アクティブアラート</h3>
        <div class="stat-value text-danger">{{ activeAlerts.length }}</div>
      </div>
      <div class="stat-card card">
        <h3>高重要度</h3>
        <div class="stat-value text-danger">{{ highSeverityCount }}</div>
      </div>
      <div class="stat-card card">
        <h3>未対応</h3>
        <div class="stat-value text-warning">{{ unacknowledgedCount }}</div>
      </div>
      <div class="stat-card card">
        <h3>今日解決</h3>
        <div class="stat-value text-success">{{ todayResolvedCount }}</div>
      </div>
    </div>
    
    <!-- フィルター -->
    <div class="alert-filters card">
      <div class="filter-group">
        <label class="form-label">重要度</label>
        <select v-model="selectedSeverity" class="form-input">
          <option value="">すべて</option>
          <option value="高">高</option>
          <option value="中">中</option>
          <option value="低">低</option>
        </select>
      </div>
      
      <div class="filter-group">
        <label class="form-label">状態</label>
        <select v-model="selectedStatus" class="form-input">
          <option value="">すべて</option>
          <option value="未対応">未対応</option>
          <option value="対応中">対応中</option>
          <option value="解決済み">解決済み</option>
        </select>
      </div>
      
      <div class="filter-group">
        <label class="form-label">設備</label>
        <select v-model="selectedEquipment" class="form-input">
          <option value="">すべて</option>
          <option value="1">CNC加工機A1</option>
          <option value="2">搬送ロボット1</option>
          <option value="3">プレス機B1</option>
          <option value="4">検査機C1</option>
        </select>
      </div>
      
      <div class="filter-group">
        <label class="form-label">検索</label>
        <input 
          v-model="searchQuery"
          type="text" 
          class="form-input"
          placeholder="タイトル、説明で検索..."
        >
      </div>
    </div>
    
    <!-- アラートリスト -->
    <div class="alert-list">
      <div 
        v-for="alert in filteredAlerts" 
        :key="alert.id"
        class="alert-item card"
        :class="getSeverityClass(alert.severity)"
        @click="selectAlert(alert)"
      >
        <div class="alert-main">
          <div class="alert-header-info">
            <h3>{{ alert.title }}</h3>
            <div class="alert-meta">
              <span class="alert-equipment">{{ getEquipmentName(alert.equipment_id) }}</span>
              <span class="alert-time">{{ formatTime(alert.detected_at) }}</span>
            </div>
          </div>
          
          <div class="alert-badges">
            <span class="severity-badge" :class="getSeverityClass(alert.severity)">
              {{ alert.severity }}
            </span>
            <span class="status-badge" :class="getStatusClass(alert.status)">
              {{ alert.status }}
            </span>
          </div>
        </div>
        
        <div class="alert-description">
          {{ alert.description }}
        </div>
        
        <div class="alert-actions">
          <button 
            v-if="alert.status === '未対応'"
            @click.stop="acknowledgeAlert(alert)"
            class="btn btn-warning btn-sm"
          >
            確認
          </button>
          <button 
            v-if="alert.status !== '解決済み'"
            @click.stop="resolveAlert(alert)"
            class="btn btn-success btn-sm"
          >
            解決
          </button>
          <button 
            @click.stop="escalateAlert(alert)"
            class="btn btn-danger btn-sm"
          >
            エスカレーション
          </button>
        </div>
      </div>
    </div>
    
    <!-- アラート詳細モーダル -->
    <div v-if="selectedAlert" class="alert-modal-overlay" @click="closeModal">
      <div class="alert-modal card" @click.stop>
        <div class="modal-header">
          <h2>{{ selectedAlert.title }}</h2>
          <button @click="closeModal" class="btn btn-secondary">×</button>
        </div>
        
        <div class="modal-content">
          <div class="alert-detail-info">
            <div class="detail-row">
              <span class="detail-label">アラートID:</span>
              <span>{{ selectedAlert.alert_id }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">設備:</span>
              <span>{{ getEquipmentName(selectedAlert.equipment_id) }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">センサー:</span>
              <span>センサー{{ selectedAlert.sensor_id }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">重要度:</span>
              <span class="severity-badge" :class="getSeverityClass(selectedAlert.severity)">
                {{ selectedAlert.severity }}
              </span>
            </div>
            <div class="detail-row">
              <span class="detail-label">状態:</span>
              <span class="status-badge" :class="getStatusClass(selectedAlert.status)">
                {{ selectedAlert.status }}
              </span>
            </div>
            <div class="detail-row">
              <span class="detail-label">検知時刻:</span>
              <span>{{ formatDateTime(selectedAlert.detected_at) }}</span>
            </div>
            <div class="detail-row" v-if="selectedAlert.acknowledged_at">
              <span class="detail-label">確認時刻:</span>
              <span>{{ formatDateTime(selectedAlert.acknowledged_at) }}</span>
            </div>
            <div class="detail-row" v-if="selectedAlert.resolved_at">
              <span class="detail-label">解決時刻:</span>
              <span>{{ formatDateTime(selectedAlert.resolved_at) }}</span>
            </div>
          </div>
          
          <div class="alert-description-full">
            <h4>詳細説明</h4>
            <p>{{ selectedAlert.description }}</p>
          </div>
          
          <div class="alert-response-history">
            <h4>対応履歴</h4>
            <div class="response-list">
              <div class="response-item">
                <div class="response-time">{{ formatDateTime(selectedAlert.detected_at) }}</div>
                <div class="response-action">アラート検知</div>
                <div class="response-user">システム</div>
              </div>
              <div v-if="selectedAlert.acknowledged_at" class="response-item">
                <div class="response-time">{{ formatDateTime(selectedAlert.acknowledged_at) }}</div>
                <div class="response-action">アラート確認</div>
                <div class="response-user">{{ selectedAlert.assigned_user_id ? 'ユーザー' + selectedAlert.assigned_user_id : '未割当' }}</div>
              </div>
              <div v-if="selectedAlert.resolved_at" class="response-item">
                <div class="response-time">{{ formatDateTime(selectedAlert.resolved_at) }}</div>
                <div class="response-action">問題解決</div>
                <div class="response-user">{{ selectedAlert.assigned_user_id ? 'ユーザー' + selectedAlert.assigned_user_id : '未割当' }}</div>
              </div>
            </div>
          </div>
          
          <div class="modal-actions">
            <button 
              v-if="selectedAlert.status === '未対応'"
              @click="acknowledgeAlert(selectedAlert)"
              class="btn btn-warning"
            >
              確認
            </button>
            <button 
              v-if="selectedAlert.status !== '解決済み'"
              @click="resolveAlert(selectedAlert)"
              class="btn btn-success"
            >
              解決
            </button>
            <button 
              @click="escalateAlert(selectedAlert)"
              class="btn btn-danger"
            >
              エスカレーション
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Alerts',
  data() {
    return {
      selectedSeverity: '',
      selectedStatus: '',
      selectedEquipment: '',
      searchQuery: '',
      selectedAlert: null,
      alerts: [
        {
          id: 'alert1',
          alert_id: 1,
          equipment_id: 1,
          sensor_id: 1,
          alert_type_id: 1,
          assigned_user_id: 2,
          title: 'CNC加工機A1 温度異常',
          description: '設備温度が正常範囲(80℃)を超過しました。現在値: 78.9℃',
          severity: '高',
          status: '未対応',
          detected_at: new Date(Date.now() - 30000),
          acknowledged_at: null,
          resolved_at: null,
          created_at: new Date(Date.now() - 30000),
          updated_at: new Date(Date.now() - 30000)
        },
        {
          id: 'alert2',
          alert_id: 2,
          equipment_id: 2,
          sensor_id: 2,
          alert_type_id: 2,
          assigned_user_id: 3,
          title: '搬送ロボット1 動作異常',
          description: '搬送速度が通常より20%低下しています。メンテナンスが必要です。',
          severity: '中',
          status: '対応中',
          detected_at: new Date(Date.now() - 300000),
          acknowledged_at: new Date(Date.now() - 240000),
          resolved_at: null,
          created_at: new Date(Date.now() - 300000),
          updated_at: new Date(Date.now() - 240000)
        },
        {
          id: 'alert3',
          alert_id: 3,
          equipment_id: 3,
          sensor_id: 3,
          alert_type_id: 3,
          assigned_user_id: 1,
          title: 'プレス機B1 振動レベル注意',
          description: '振動レベルが基準値を上回りました。定期点検を推奨します。',
          severity: '低',
          status: '解決済み',
          detected_at: new Date(Date.now() - 3600000),
          acknowledged_at: new Date(Date.now() - 3300000),
          resolved_at: new Date(Date.now() - 1800000),
          created_at: new Date(Date.now() - 3600000),
          updated_at: new Date(Date.now() - 1800000)
        },
        {
          id: 'alert4',
          alert_id: 4,
          equipment_id: 4,
          sensor_id: 4,
          alert_type_id: 1,
          assigned_user_id: 2,
          title: '検査機C1 電力消費異常',
          description: '電力消費量が通常の150%に増加しています。',
          severity: '中',
          status: '未対応',
          detected_at: new Date(Date.now() - 900000),
          acknowledged_at: null,
          resolved_at: null,
          created_at: new Date(Date.now() - 900000),
          updated_at: new Date(Date.now() - 900000)
        }
      ],
      equipmentNames: {
        1: 'CNC加工機A1',
        2: '搬送ロボット1',
        3: 'プレス機B1',
        4: '検査機C1'
      }
    }
  },
  computed: {
    filteredAlerts() {
      return this.alerts.filter(alert => {
        const matchesSeverity = !this.selectedSeverity || alert.severity === this.selectedSeverity
        const matchesStatus = !this.selectedStatus || alert.status === this.selectedStatus
        const matchesEquipment = !this.selectedEquipment || alert.equipment_id.toString() === this.selectedEquipment
        const matchesSearch = !this.searchQuery || 
          alert.title.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
          alert.description.toLowerCase().includes(this.searchQuery.toLowerCase())
        
        return matchesSeverity && matchesStatus && matchesEquipment && matchesSearch
      }).sort((a, b) => {
        // 重要度順、検知時刻順でソート
        const severityOrder = { '高': 3, '中': 2, '低': 1 }
        if (severityOrder[a.severity] !== severityOrder[b.severity]) {
          return severityOrder[b.severity] - severityOrder[a.severity]
        }
        return new Date(b.detected_at) - new Date(a.detected_at)
      })
    },
    
    activeAlerts() {
      return this.alerts.filter(alert => alert.status !== '解決済み')
    },
    
    highSeverityCount() {
      return this.alerts.filter(alert => alert.severity === '高' && alert.status !== '解決済み').length
    },
    
    unacknowledgedCount() {
      return this.alerts.filter(alert => alert.status === '未対応').length
    },
    
    todayResolvedCount() {
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      return this.alerts.filter(alert => 
        alert.resolved_at && new Date(alert.resolved_at) >= today
      ).length
    }
  },
  mounted() {
    this.loadAlerts()
  },
  methods: {
    loadAlerts() {
      // 実際の実装では API からデータを取得
      // オフライン対応のため、ローカルストレージからデータを読み込み
      const cached = localStorage.getItem('alertsData')
      if (cached) {
        this.alerts = JSON.parse(cached)
      }
    },
    
    selectAlert(alert) {
      this.selectedAlert = alert
    },
    
    closeModal() {
      this.selectedAlert = null
    },
    
    acknowledgeAlert(alert) {
      alert.status = '対応中'
      alert.acknowledged_at = new Date()
      alert.updated_at = new Date()
      this.saveToLocalStorage()
      
      if (this.selectedAlert) {
        this.selectedAlert = null
      }
    },
    
    resolveAlert(alert) {
      alert.status = '解決済み'
      alert.resolved_at = new Date()
      alert.updated_at = new Date()
      this.saveToLocalStorage()
      
      if (this.selectedAlert) {
        this.selectedAlert = null
      }
    },
    
    escalateAlert(alert) {
      // エスカレーション処理
      alert.severity = alert.severity === '低' ? '中' : '高'
      alert.updated_at = new Date()
      this.saveToLocalStorage()
      
      alert('アラートをエスカレーションしました。管理者に通知されます。')
    },
    
    saveToLocalStorage() {
      localStorage.setItem('alertsData', JSON.stringify(this.alerts))
    },
    
    getSeverityClass(severity) {
      switch (severity) {
        case '高': return 'severity-high'
        case '中': return 'severity-medium'
        case '低': return 'severity-low'
        default: return ''
      }
    },
    
    getStatusClass(status) {
      switch (status) {
        case '未対応': return 'status-unacknowledged'
        case '対応中': return 'status-in-progress'
        case '解決済み': return 'status-resolved'
        default: return ''
      }
    },
    
    getEquipmentName(equipmentId) {
      return this.equipmentNames[equipmentId] || `設備${equipmentId}`
    },
    
    formatTime(date) {
      const now = new Date()
      const diff = Math.floor((now - date) / 1000)
      
      if (diff < 60) return `${diff}秒前`
      if (diff < 3600) return `${Math.floor(diff / 60)}分前`
      if (diff < 86400) return `${Math.floor(diff / 3600)}時間前`
      return date.toLocaleDateString('ja-JP')
    },
    
    formatDateTime(date) {
      return new Date(date).toLocaleString('ja-JP')
    }
  }
}
</script>

<style scoped>
.alerts-header {
  margin-bottom: 2rem;
}

.alert-stats {
  margin-bottom: 2rem;
}

.stat-card {
  text-align: center;
}

.stat-card h3 {
  color: #7f8c8d;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 2rem;
  font-weight: bold;
}

.alert-filters {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.filter-group {
  min-width: 150px;
}

.alert-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.alert-item {
  cursor: pointer;
  transition: all 0.3s;
  border-left: 4px solid #ecf0f1;
}

.alert-item:hover {
  transform: translateX(5px);
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}

.alert-item.severity-high {
  border-left-color: #e74c3c;
}

.alert-item.severity-medium {
  border-left-color: #f39c12;
}

.alert-item.severity-low {
  border-left-color: #3498db;
}

.alert-main {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.alert-header-info h3 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
}

.alert-meta {
  display: flex;
  gap: 1rem;
}

.alert-equipment {
  color: #7f8c8d;
  font-weight: bold;
}

.alert-time {
  color: #95a5a6;
  font-size: 0.9rem;
}

.alert-badges {
  display: flex;
  gap: 0.5rem;
}

.severity-badge, .status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: bold;
}

.severity-high {
  background-color: #fadbd8;
  color: #e74c3c;
}

.severity-medium {
  background-color: #fef5e7;
  color: #f39c12;
}

.severity-low {
  background-color: #d6eaf8;
  color: #3498db;
}

.status-unacknowledged {
  background-color: #fadbd8;
  color: #e74c3c;
}

.status-in-progress {
  background-color: #fef5e7;
  color: #f39c12;
}

.status-resolved {
  background-color: #d5f4e6;
  color: #27ae60;
}

.alert-description {
  color: #7f8c8d;
  margin-bottom: 1rem;
  line-height: 1.5;
}

.alert-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.btn-sm {
  padding: 0.25rem 0.75rem;
  font-size: 0.8rem;
}

.alert-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.alert-modal {
  width: 90%;
  max-width: 800px;
  max-height: 90%;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #ecf0f1;
}

.modal-header h2 {
  margin: 0;
  color: #2c3e50;
}

.alert-detail-info {
  margin-bottom: 2rem;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  border-bottom: 1px solid #f8f9fa;
}

.detail-label {
  font-weight: bold;
  color: #7f8c8d;
}

.alert-description-full {
  margin-bottom: 2rem;
}

.alert-description-full h4 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.alert-description-full p {
  line-height: 1.6;
  color: #7f8c8d;
}

.alert-response-history h4 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.response-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.response-item {
  display: flex;
  gap: 1rem;
  padding: 0.75rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.response-time {
  min-width: 150px;
  font-size: 0.9rem;
  color: #7f8c8d;
}

.response-action {
  flex: 1;
  font-weight: bold;
  color: #2c3e50;
}

.response-user {
  min-width: 80px;
  font-size: 0.9rem;
  color: #7f8c8d;
  text-align: right;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #ecf0f1;
  flex-wrap: wrap;
}

@media (max-width: 768px) {
  .alert-filters {
    flex-direction: column;
  }
  
  .alert-main {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .alert-badges {
    align-self: flex-start;
  }
  
  .alert-modal {
    width: 95%;
    margin: 1rem;
  }
  
  .detail-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
  }
  
  .response-item {
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .response-user {
    text-align: left;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}
</style>