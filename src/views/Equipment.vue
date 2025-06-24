<template>
  <div class="equipment">
    <div class="equipment-header">
      <h1>設備管理</h1>
      <p>工場設備の詳細情報と状態管理</p>
    </div>
    
    <!-- フィルター -->
    <div class="equipment-filters card">
      <div class="filter-group">
        <label class="form-label">設備タイプ</label>
        <select v-model="selectedType" class="form-input">
          <option value="">すべて</option>
          <option value="CNC加工機">CNC加工機</option>
          <option value="搬送ロボット">搬送ロボット</option>
          <option value="プレス機">プレス機</option>
          <option value="検査機">検査機</option>
        </select>
      </div>
      
      <div class="filter-group">
        <label class="form-label">状態</label>
        <select v-model="selectedStatus" class="form-input">
          <option value="">すべて</option>
          <option value="稼働中">稼働中</option>
          <option value="保守中">保守中</option>
          <option value="停止中">停止中</option>
        </select>
      </div>
      
      <div class="filter-group">
        <label class="form-label">検索</label>
        <input 
          v-model="searchQuery"
          type="text" 
          class="form-input"
          placeholder="設備名、場所で検索..."
        >
      </div>
    </div>
    
    <!-- 設備リスト -->
    <div class="equipment-list">
      <div 
        v-for="equipment in filteredEquipment" 
        :key="equipment.id"
        class="equipment-card card"
        @click="selectEquipment(equipment)"
        :class="{ 'selected': selectedEquipment?.id === equipment.id }"
      >
        <div class="equipment-basic">
          <h3>{{ equipment.equipment_name }}</h3>
          <div class="equipment-meta">
            <span class="equipment-type">{{ equipment.equipment_type }}</span>
            <span class="equipment-location">{{ equipment.location }}</span>
          </div>
          <div class="equipment-status" :class="getStatusClass(equipment.status)">
            {{ equipment.status }}
          </div>
        </div>
        
        <div class="equipment-details">
          <div class="detail-item">
            <span class="detail-label">型番:</span>
            <span>{{ equipment.model_number }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">製造元:</span>
            <span>{{ equipment.manufacturer }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">設置日:</span>
            <span>{{ formatDate(equipment.installation_date) }}</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 設備詳細パネル -->
    <div v-if="selectedEquipment" class="equipment-detail-panel card">
      <div class="detail-header">
        <h2>{{ selectedEquipment.equipment_name }} - 詳細情報</h2>
        <button @click="selectedEquipment = null" class="btn btn-secondary">閉じる</button>
      </div>
      
      <div class="detail-tabs">
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
      
      <div class="detail-content">
        <!-- 概要タブ -->
        <div v-if="activeTab === 'overview'" class="tab-content">
          <div class="overview-grid grid grid-2">
            <div class="overview-section">
              <h4>基本情報</h4>
              <div class="info-list">
                <div class="info-item">
                  <span class="info-label">設備ID:</span>
                  <span>{{ selectedEquipment.equipment_id }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">シリアル番号:</span>
                  <span>{{ selectedEquipment.serial_number }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">設備グループ:</span>
                  <span>{{ selectedEquipment.group_id }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">最終更新:</span>
                  <span>{{ formatDateTime(selectedEquipment.updated_at) }}</span>
                </div>
              </div>
            </div>
            
            <div class="overview-section">
              <h4>稼働状況</h4>
              <div class="status-info">
                <div class="status-indicator" :class="getStatusClass(selectedEquipment.status)">
                  {{ selectedEquipment.status }}
                </div>
                <div class="status-details">
                  <p>稼働時間: 8時間 32分</p>
                  <p>稼働率: 94.2%</p>
                  <p>次回保全: 2024-07-15</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- センサーデータタブ -->
        <div v-if="activeTab === 'sensors'" class="tab-content">
          <div class="sensor-grid grid grid-3">
            <div v-for="sensor in sensorData" :key="sensor.id" class="sensor-card">
              <h5>{{ sensor.name }}</h5>
              <div class="sensor-value" :class="getSensorStatusClass(sensor.status)">
                {{ sensor.value }} {{ sensor.unit }}
              </div>
              <div class="sensor-status">{{ sensor.status }}</div>
              <small>更新: {{ formatTime(sensor.updated_at) }}</small>
            </div>
          </div>
        </div>
        
        <!-- 履歴タブ -->
        <div v-if="activeTab === 'history'" class="tab-content">
          <div class="history-list">
            <div v-for="record in maintenanceHistory" :key="record.id" class="history-item">
              <div class="history-date">{{ formatDate(record.date) }}</div>
              <div class="history-content">
                <h5>{{ record.type }}</h5>
                <p>{{ record.description }}</p>
                <small>担当者: {{ record.technician }}</small>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 保全タブ -->
        <div v-if="activeTab === 'maintenance'" class="tab-content">
          <div class="maintenance-actions">
            <button class="btn btn-primary">保全計画を作成</button>
            <button class="btn btn-warning">緊急点検を実施</button>
            <button class="btn btn-success">作業報告を入力</button>
          </div>
          
          <div class="maintenance-schedule">
            <h4>保全スケジュール</h4>
            <div v-for="schedule in maintenanceSchedule" :key="schedule.id" class="schedule-item">
              <div class="schedule-date">{{ formatDate(schedule.date) }}</div>
              <div class="schedule-content">
                <strong>{{ schedule.type }}</strong>
                <p>{{ schedule.description }}</p>
              </div>
              <div class="schedule-status" :class="schedule.status">
                {{ schedule.status }}
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
  name: 'Equipment',
  data() {
    return {
      selectedType: '',
      selectedStatus: '',
      searchQuery: '',
      selectedEquipment: null,
      activeTab: 'overview',
      tabs: [
        { id: 'overview', label: '概要' },
        { id: 'sensors', label: 'センサーデータ' },
        { id: 'history', label: '履歴' },
        { id: 'maintenance', label: '保全' }
      ],
      equipmentList: [
        {
          id: 'eq1',
          equipment_id: 1,
          group_id: 1,
          equipment_name: 'CNC加工機A1',
          equipment_type: 'CNC加工機',
          model_number: 'CNC-1000X',
          serial_number: 'CNC1000X-001',
          manufacturer: 'マキノ精機',
          installation_date: '2023-06-15',
          location: '工場棟A-1F-001',
          status: '稼働中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T05:00:00Z'
        },
        {
          id: 'eq2',
          equipment_id: 2,
          group_id: 1,
          equipment_name: '搬送ロボット1',
          equipment_type: '搬送ロボット',
          model_number: 'ROBOT-500',
          serial_number: 'ROBOT500-001',
          manufacturer: '安川電機',
          installation_date: '2023-08-10',
          location: '工場棟A-1F-002',
          status: '稼働中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T05:00:00Z'
        },
        {
          id: 'eq3',
          equipment_id: 3,
          group_id: 2,
          equipment_name: 'プレス機B1',
          equipment_type: 'プレス機',
          model_number: 'PRESS-800',
          serial_number: 'PRESS800-001',
          manufacturer: 'アマダ',
          installation_date: '2023-05-20',
          location: '工場棟B-1F-001',
          status: '保守中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T04:30:00Z'
        },
        {
          id: 'eq4',
          equipment_id: 4,
          group_id: 3,
          equipment_name: '検査機C1',
          equipment_type: '検査機',
          model_number: 'INSPECT-300',
          serial_number: 'INSPECT300-001',
          manufacturer: 'キーエンス',
          installation_date: '2023-07-05',
          location: '工場棟C-1F-001',
          status: '稼働中',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-06-24T05:00:00Z'
        }
      ],
      sensorData: [
        {
          id: 1,
          name: '温度',
          value: 78.9,
          unit: '℃',
          status: '正常',
          updated_at: new Date()
        },
        {
          id: 2,
          name: '振動',
          value: 2.1,
          unit: 'mm/s',
          status: '注意',
          updated_at: new Date()
        },
        {
          id: 3,
          name: '電流',
          value: 15.2,
          unit: 'A',
          status: '正常',
          updated_at: new Date()
        }
      ],
      maintenanceHistory: [
        {
          id: 1,
          date: '2024-06-20',
          type: '定期点検',
          description: 'オイル交換、フィルター清掃を実施',
          technician: '田中太郎'
        },
        {
          id: 2,
          date: '2024-06-15',
          type: '緊急修理',
          description: 'モーター異音の修理対応',
          technician: '佐藤花子'
        }
      ],
      maintenanceSchedule: [
        {
          id: 1,
          date: '2024-06-30',
          type: '定期保全',
          description: '月次点検・調整',
          status: '予定'
        },
        {
          id: 2,
          date: '2024-07-15',
          type: '部品交換',
          description: 'ベアリング交換',
          status: '予定'
        }
      ]
    }
  },
  computed: {
    filteredEquipment() {
      return this.equipmentList.filter(equipment => {
        const matchesType = !this.selectedType || equipment.equipment_type === this.selectedType
        const matchesStatus = !this.selectedStatus || equipment.status === this.selectedStatus
        const matchesSearch = !this.searchQuery || 
          equipment.equipment_name.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
          equipment.location.toLowerCase().includes(this.searchQuery.toLowerCase())
        
        return matchesType && matchesStatus && matchesSearch
      })
    }
  },
  mounted() {
    this.loadEquipmentData()
  },
  methods: {
    loadEquipmentData() {
      // 実際の実装では API からデータを取得
      // サンプルデータフォルダーから読み込み
      this.loadSampleData()
    },
    
    loadSampleData() {
      // オフライン対応: ローカルストレージからデータを読み込み
      const cached = localStorage.getItem('equipmentData')
      if (cached) {
        this.equipmentList = JSON.parse(cached)
      }
    },
    
    selectEquipment(equipment) {
      this.selectedEquipment = equipment
      this.activeTab = 'overview'
    },
    
    getStatusClass(status) {
      switch (status) {
        case '稼働中': return 'status-active'
        case '保守中': return 'status-maintenance'
        case '停止中': return 'status-stopped'
        default: return ''
      }
    },
    
    getSensorStatusClass(status) {
      switch (status) {
        case '正常': return 'sensor-normal'
        case '注意': return 'sensor-warning'
        case '異常': return 'sensor-error'
        default: return ''
      }
    },
    
    formatDate(dateString) {
      return new Date(dateString).toLocaleDateString('ja-JP')
    },
    
    formatDateTime(dateString) {
      return new Date(dateString).toLocaleString('ja-JP')
    },
    
    formatTime(date) {
      const now = new Date()
      const diff = Math.floor((now - date) / 1000)
      
      if (diff < 60) return `${diff}秒前`
      if (diff < 3600) return `${Math.floor(diff / 60)}分前`
      return date.toLocaleTimeString('ja-JP')
    }
  }
}
</script>

<style scoped>
.equipment-header {
  margin-bottom: 2rem;
}

.equipment-filters {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.filter-group {
  min-width: 150px;
}

.equipment-list {
  display: grid;
  gap: 1rem;
  margin-bottom: 2rem;
}

.equipment-card {
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.equipment-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}

.equipment-card.selected {
  border-color: #3498db;
}

.equipment-basic {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.equipment-basic h3 {
  margin: 0;
  color: #2c3e50;
}

.equipment-meta {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.equipment-type {
  background-color: #ecf0f1;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
}

.equipment-location {
  color: #7f8c8d;
  font-size: 0.9rem;
}

.equipment-status {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: bold;
  font-size: 0.9rem;
}

.status-active {
  background-color: #d5f4e6;
  color: #27ae60;
}

.status-maintenance {
  background-color: #fef5e7;
  color: #f39c12;
}

.status-stopped {
  background-color: #fadbd8;
  color: #e74c3c;
}

.equipment-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 0.5rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
}

.detail-label {
  font-weight: bold;
  color: #7f8c8d;
}

.equipment-detail-panel {
  position: fixed;
  top: 5%;
  left: 5%;
  right: 5%;
  bottom: 5%;
  z-index: 1000;
  background: white;
  overflow-y: auto;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #ecf0f1;
}

.detail-tabs {
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

.overview-section h4 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.info-label {
  font-weight: bold;
  color: #7f8c8d;
}

.status-info {
  text-align: center;
}

.status-indicator {
  display: inline-block;
  padding: 1rem 2rem;
  border-radius: 8px;
  font-size: 1.2rem;
  font-weight: bold;
  margin-bottom: 1rem;
}

.status-details p {
  margin: 0.25rem 0;
  color: #7f8c8d;
}

.sensor-card {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 8px;
  text-align: center;
}

.sensor-card h5 {
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.sensor-value {
  font-size: 1.5rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
}

.sensor-normal {
  color: #27ae60;
}

.sensor-warning {
  color: #f39c12;
}

.sensor-error {
  color: #e74c3c;
}

.sensor-status {
  font-size: 0.9rem;
  color: #7f8c8d;
  margin-bottom: 0.5rem;
}

.history-item {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  border: 1px solid #ecf0f1;
  border-radius: 4px;
  margin-bottom: 0.5rem;
}

.history-date {
  min-width: 100px;
  font-weight: bold;
  color: #7f8c8d;
}

.history-content h5 {
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.history-content p {
  margin-bottom: 0.25rem;
  color: #7f8c8d;
}

.maintenance-actions {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.schedule-item {
  display: flex;
  gap: 1rem;
  align-items: center;
  padding: 1rem;
  border: 1px solid #ecf0f1;
  border-radius: 4px;
  margin-bottom: 0.5rem;
}

.schedule-date {
  min-width: 100px;
  font-weight: bold;
  color: #2c3e50;
}

.schedule-content {
  flex: 1;
}

.schedule-content strong {
  color: #2c3e50;
}

.schedule-content p {
  margin: 0.25rem 0;
  color: #7f8c8d;
}

.schedule-status {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.8rem;
  background-color: #d6eaf8;
  color: #3498db;
}

@media (max-width: 768px) {
  .equipment-filters {
    flex-direction: column;
  }
  
  .equipment-basic {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .equipment-detail-panel {
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
  }
  
  .maintenance-actions {
    flex-direction: column;
  }
  
  .schedule-item {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>