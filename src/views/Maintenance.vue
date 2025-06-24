<template>
  <div class="maintenance">
    <div class="maintenance-header">
      <h1>保全管理</h1>
      <p>予知保全と定期保全の管理</p>
    </div>
    
    <!-- 保全サマリー -->
    <div class="maintenance-summary grid grid-4">
      <div class="summary-card card">
        <h3>今週の予定</h3>
        <div class="summary-value text-warning">{{ weeklySchedule.length }}</div>
        <div class="summary-label">件</div>
      </div>
      <div class="summary-card card">
        <h3>完了済み</h3>
        <div class="summary-value text-success">{{ completedCount }}</div>
        <div class="summary-label">件 (今月)</div>
      </div>
      <div class="summary-card card">
        <h3>遅延中</h3>
        <div class="summary-value text-danger">{{ overdueCount }}</div>
        <div class="summary-label">件</div>
      </div>
      <div class="summary-card card">
        <h3>予知保全推奨</h3>
        <div class="summary-value text-warning">{{ predictiveCount }}</div>
        <div class="summary-label">件</div>
      </div>
    </div>
    
    <!-- タブナビゲーション -->
    <div class="maintenance-tabs">
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
    
    <!-- 予知保全計画タブ -->
    <div v-if="activeTab === 'predictive'" class="tab-content">
      <div class="section-header">
        <h2>予知保全計画</h2>
        <button class="btn btn-primary">新規計画作成</button>
      </div>
      
      <div class="predictive-list">
        <div 
          v-for="prediction in predictiveMaintenanceList"
          :key="prediction.id"
          class="predictive-card card"
          :class="getPriorityClass(prediction.priority)"
        >
          <div class="predictive-header">
            <h3>{{ prediction.equipment_name }}</h3>
            <span class="priority-badge" :class="getPriorityClass(prediction.priority)">
              {{ prediction.priority }}
            </span>
          </div>
          
          <div class="predictive-content">
            <p><strong>推奨作業:</strong> {{ prediction.recommended_action }}</p>
            <p><strong>理由:</strong> {{ prediction.reason }}</p>
            <p><strong>推奨実施日:</strong> {{ formatDate(prediction.recommended_date) }}</p>
            <p><strong>予想コスト:</strong> ¥{{ prediction.estimated_cost.toLocaleString() }}</p>
          </div>
          
          <div class="predictive-actions">
            <button class="btn btn-success">計画作成</button>
            <button class="btn btn-secondary">詳細分析</button>
            <button class="btn btn-warning">後で確認</button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 定期保全スケジュールタブ -->
    <div v-if="activeTab === 'scheduled'" class="tab-content">
      <div class="section-header">
        <h2>定期保全スケジュール</h2>
        <button class="btn btn-primary">スケジュール追加</button>
      </div>
      
      <div class="schedule-calendar">
        <div class="calendar-header">
          <button @click="previousMonth" class="btn btn-secondary">‹</button>
          <h3>{{ currentMonthYear }}</h3>
          <button @click="nextMonth" class="btn btn-secondary">›</button>
        </div>
        
        <div class="schedule-list">
          <div 
            v-for="schedule in filteredSchedule"
            :key="schedule.id"
            class="schedule-item card"
            :class="getScheduleStatusClass(schedule.status)"
          >
            <div class="schedule-date">
              {{ formatDate(schedule.scheduled_date) }}
            </div>
            <div class="schedule-content">
              <h4>{{ schedule.maintenance_type }}</h4>
              <p><strong>設備:</strong> {{ schedule.equipment_name }}</p>
              <p><strong>作業内容:</strong> {{ schedule.description }}</p>
              <p><strong>担当者:</strong> {{ schedule.assigned_technician }}</p>
              <p><strong>予定時間:</strong> {{ schedule.estimated_duration }}時間</p>
            </div>
            <div class="schedule-status">
              <span class="status-badge" :class="getScheduleStatusClass(schedule.status)">
                {{ schedule.status }}
              </span>
            </div>
            <div class="schedule-actions">
              <button 
                v-if="schedule.status === '予定'"
                class="btn btn-primary btn-sm"
                @click="startMaintenance(schedule)"
              >
                開始
              </button>
              <button 
                v-if="schedule.status === '実施中'"
                class="btn btn-success btn-sm"
                @click="completeMaintenance(schedule)"
              >
                完了
              </button>
              <button class="btn btn-secondary btn-sm">詳細</button>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 保全実施記録タブ -->
    <div v-if="activeTab === 'records'" class="tab-content">
      <div class="section-header">
        <h2>保全実施記録</h2>
        <button class="btn btn-primary">記録追加</button>
      </div>
      
      <div class="records-filters">
        <select v-model="recordsFilter" class="form-input">
          <option value="">すべて</option>
          <option value="定期保全">定期保全</option>
          <option value="予防保全">予防保全</option>
          <option value="緊急修理">緊急修理</option>
        </select>
        <input 
          v-model="recordsSearch"
          type="text"
          class="form-input"
          placeholder="設備名で検索..."
        >
      </div>
      
      <div class="records-list">
        <div 
          v-for="record in filteredRecords"
          :key="record.id"
          class="record-card card"
        >
          <div class="record-header">
            <h3>{{ record.equipment_name }}</h3>
            <span class="record-date">{{ formatDate(record.completion_date) }}</span>
          </div>
          
          <div class="record-content">
            <div class="record-details">
              <p><strong>作業タイプ:</strong> {{ record.maintenance_type }}</p>
              <p><strong>作業時間:</strong> {{ record.actual_duration }}時間</p>
              <p><strong>担当技術者:</strong> {{ record.technician }}</p>
              <p><strong>使用部品:</strong> {{ record.parts_used || 'なし' }}</p>
              <p><strong>作業費用:</strong> ¥{{ record.cost.toLocaleString() }}</p>
            </div>
            
            <div class="record-description">
              <h4>作業内容</h4>
              <p>{{ record.work_description }}</p>
            </div>
            
            <div class="record-notes">
              <h4>特記事項・次回推奨事項</h4>
              <p>{{ record.notes || '特になし' }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 保全リソース管理タブ -->
    <div v-if="activeTab === 'resources'" class="tab-content">
      <div class="section-header">
        <h2>保全リソース管理</h2>
        <button class="btn btn-primary">リソース追加</button>
      </div>
      
      <div class="resources-grid grid grid-2">
        <!-- 技術者管理 -->
        <div class="resource-section card">
          <h3>技術者</h3>
          <div class="technician-list">
            <div 
              v-for="technician in technicians"
              :key="technician.id"
              class="technician-item"
            >
              <div class="technician-info">
                <strong>{{ technician.name }}</strong>
                <span class="technician-specialty">{{ technician.specialty }}</span>
              </div>
              <div class="technician-status" :class="technician.available ? 'available' : 'busy'">
                {{ technician.available ? '対応可能' : '作業中' }}
              </div>
            </div>
          </div>
        </div>
        
        <!-- 部品在庫 -->
        <div class="resource-section card">
          <h3>部品在庫</h3>
          <div class="parts-list">
            <div 
              v-for="part in partsInventory"
              :key="part.id"
              class="part-item"
              :class="{ 'low-stock': part.quantity < part.min_quantity }"
            >
              <div class="part-info">
                <strong>{{ part.name }}</strong>
                <span class="part-code">{{ part.part_number }}</span>
              </div>
              <div class="part-quantity">
                在庫: {{ part.quantity }}{{ part.unit }}
                <span v-if="part.quantity < part.min_quantity" class="low-stock-warning">
                  (要発注)
                </span>
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
  name: 'Maintenance',
  data() {
    return {
      activeTab: 'predictive',
      currentDate: new Date(),
      recordsFilter: '',
      recordsSearch: '',
      tabs: [
        { id: 'predictive', label: '予知保全計画' },
        { id: 'scheduled', label: '定期保全スケジュール' },
        { id: 'records', label: '保全実施記録' },
        { id: 'resources', label: 'リソース管理' }
      ],
      predictiveMaintenanceList: [
        {
          id: 1,
          equipment_name: 'CNC加工機A1',
          recommended_action: 'ベアリング交換',
          reason: '振動レベルが基準値の120%に上昇。交換時期が近づいています。',
          priority: '高',
          recommended_date: '2024-07-15',
          estimated_cost: 45000
        },
        {
          id: 2,
          equipment_name: '搬送ロボット1',
          recommended_action: 'モーター点検',
          reason: '電流値の変動が増加。早期点検を推奨します。',
          priority: '中',
          recommended_date: '2024-07-20',
          estimated_cost: 25000
        }
      ],
      maintenanceSchedule: [
        {
          id: 1,
          equipment_name: 'CNC加工機A1',
          maintenance_type: '定期点検',
          description: '月次定期点検・オイル交換',
          scheduled_date: '2024-06-30',
          assigned_technician: '田中太郎',
          estimated_duration: 4,
          status: '予定'
        },
        {
          id: 2,
          equipment_name: 'プレス機B1',
          maintenance_type: '部品交換',
          description: 'フィルター交換・調整',
          scheduled_date: '2024-07-02',
          assigned_technician: '佐藤花子',
          estimated_duration: 2,
          status: '実施中'
        },
        {
          id: 3,
          equipment_name: '検査機C1',
          maintenance_type: '定期保全',
          description: '校正・清掃作業',
          scheduled_date: '2024-07-05',
          assigned_technician: '鈴木一郎',
          estimated_duration: 3,
          status: '完了'
        }
      ],
      maintenanceRecords: [
        {
          id: 1,
          equipment_name: 'CNC加工機A1',
          maintenance_type: '定期保全',
          completion_date: '2024-06-20',
          technician: '田中太郎',
          actual_duration: 3.5,
          cost: 35000,
          parts_used: 'オイルフィルター、潤滑油',
          work_description: '月次定期点検を実施。オイル交換、フィルター清掃、各部点検を行いました。',
          notes: '次回はベアリングの状態要確認。振動レベルやや上昇傾向。'
        },
        {
          id: 2,
          equipment_name: '搬送ロボット1',
          maintenance_type: '緊急修理',
          completion_date: '2024-06-15',
          technician: '佐藤花子',
          actual_duration: 2,
          cost: 18000,
          parts_used: 'センサー部品',
          work_description: '位置センサーの故障対応。センサー交換と調整を実施。',
          notes: '交換後の動作確認完了。1週間後に再点検予定。'
        }
      ],
      technicians: [
        {
          id: 1,
          name: '田中太郎',
          specialty: 'CNC・工作機械',
          available: true
        },
        {
          id: 2,
          name: '佐藤花子',
          specialty: 'ロボット・自動化',
          available: false
        },
        {
          id: 3,
          name: '鈴木一郎',
          specialty: '検査・測定機器',
          available: true
        }
      ],
      partsInventory: [
        {
          id: 1,
          name: 'オイルフィルター',
          part_number: 'OF-001',
          quantity: 15,
          unit: '個',
          min_quantity: 10
        },
        {
          id: 2,
          name: 'ベアリング 6200',
          part_number: 'BR-6200',
          quantity: 3,
          unit: '個',
          min_quantity: 5
        },
        {
          id: 3,
          name: '位置センサー',
          part_number: 'PS-101',
          quantity: 8,
          unit: '個',
          min_quantity: 5
        }
      ]
    }
  },
  computed: {
    weeklySchedule() {
      const now = new Date()
      const weekStart = new Date(now.setDate(now.getDate() - now.getDay()))
      const weekEnd = new Date(now.setDate(now.getDate() - now.getDay() + 6))
      
      return this.maintenanceSchedule.filter(schedule => {
        const scheduleDate = new Date(schedule.scheduled_date)
        return scheduleDate >= weekStart && scheduleDate <= weekEnd
      })
    },
    
    completedCount() {
      return this.maintenanceRecords.filter(record => {
        const recordDate = new Date(record.completion_date)
        const now = new Date()
        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
        return recordDate >= monthStart
      }).length
    },
    
    overdueCount() {
      const now = new Date()
      return this.maintenanceSchedule.filter(schedule => {
        const scheduleDate = new Date(schedule.scheduled_date)
        return scheduleDate < now && schedule.status !== '完了'
      }).length
    },
    
    predictiveCount() {
      return this.predictiveMaintenanceList.length
    },
    
    currentMonthYear() {
      return this.currentDate.toLocaleDateString('ja-JP', { year: 'numeric', month: 'long' })
    },
    
    filteredSchedule() {
      return this.maintenanceSchedule.filter(schedule => {
        const scheduleDate = new Date(schedule.scheduled_date)
        return scheduleDate.getMonth() === this.currentDate.getMonth() &&
               scheduleDate.getFullYear() === this.currentDate.getFullYear()
      })
    },
    
    filteredRecords() {
      return this.maintenanceRecords.filter(record => {
        const matchesFilter = !this.recordsFilter || record.maintenance_type === this.recordsFilter
        const matchesSearch = !this.recordsSearch || 
          record.equipment_name.toLowerCase().includes(this.recordsSearch.toLowerCase())
        return matchesFilter && matchesSearch
      })
    }
  },
  methods: {
    previousMonth() {
      this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, 1)
    },
    
    nextMonth() {
      this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1)
    },
    
    startMaintenance(schedule) {
      schedule.status = '実施中'
    },
    
    completeMaintenance(schedule) {
      schedule.status = '完了'
    },
    
    getPriorityClass(priority) {
      switch (priority) {
        case '高': return 'priority-high'
        case '中': return 'priority-medium'
        case '低': return 'priority-low'
        default: return ''
      }
    },
    
    getScheduleStatusClass(status) {
      switch (status) {
        case '予定': return 'schedule-scheduled'
        case '実施中': return 'schedule-in-progress'
        case '完了': return 'schedule-completed'
        case '遅延': return 'schedule-overdue'
        default: return ''
      }
    },
    
    formatDate(dateString) {
      return new Date(dateString).toLocaleDateString('ja-JP')
    }
  }
}
</script>

<style scoped>
.maintenance-header {
  margin-bottom: 2rem;
}

.maintenance-summary {
  margin-bottom: 2rem;
}

.summary-card {
  text-align: center;
}

.summary-card h3 {
  color: #7f8c8d;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.summary-value {
  font-size: 2rem;
  font-weight: bold;
}

.summary-label {
  color: #95a5a6;
  font-size: 0.8rem;
}

.maintenance-tabs {
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

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.predictive-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.predictive-card {
  border-left: 4px solid #ecf0f1;
}

.predictive-card.priority-high {
  border-left-color: #e74c3c;
}

.predictive-card.priority-medium {
  border-left-color: #f39c12;
}

.predictive-card.priority-low {
  border-left-color: #3498db;
}

.predictive-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.predictive-header h3 {
  margin: 0;
  color: #2c3e50;
}

.priority-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: bold;
}

.priority-high {
  background-color: #fadbd8;
  color: #e74c3c;
}

.priority-medium {
  background-color: #fef5e7;
  color: #f39c12;
}

.priority-low {
  background-color: #d6eaf8;
  color: #3498db;
}

.predictive-content {
  margin-bottom: 1rem;
}

.predictive-content p {
  margin: 0.5rem 0;
  color: #7f8c8d;
}

.predictive-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.calendar-header {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.calendar-header h3 {
  margin: 0;
  min-width: 200px;
  text-align: center;
}

.schedule-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.schedule-item {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}

.schedule-date {
  min-width: 100px;
  font-weight: bold;
  color: #2c3e50;
}

.schedule-content {
  flex: 1;
}

.schedule-content h4 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
}

.schedule-content p {
  margin: 0.25rem 0;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.schedule-status {
  min-width: 80px;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: bold;
}

.schedule-scheduled {
  background-color: #d6eaf8;
  color: #3498db;
}

.schedule-in-progress {
  background-color: #fef5e7;
  color: #f39c12;
}

.schedule-completed {
  background-color: #d5f4e6;
  color: #27ae60;
}

.schedule-overdue {
  background-color: #fadbd8;
  color: #e74c3c;
}

.schedule-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.records-filters {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.records-filters .form-input {
  min-width: 200px;
}

.records-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.record-card {
  
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #ecf0f1;
}

.record-header h3 {
  margin: 0;
  color: #2c3e50;
}

.record-date {
  color: #7f8c8d;
  font-weight: bold;
}

.record-content {
  display: grid;
  gap: 1rem;
}

.record-details p {
  margin: 0.25rem 0;
  color: #7f8c8d;
}

.record-description h4,
.record-notes h4 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
  font-size: 1rem;
}

.record-description p,
.record-notes p {
  color: #7f8c8d;
  line-height: 1.5;
}

.resources-grid {
  gap: 2rem;
}

.resource-section h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.technician-list,
.parts-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.technician-item,
.part-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.part-item.low-stock {
  background-color: #fef5e7;
  border-left: 4px solid #f39c12;
}

.technician-info,
.part-info {
  display: flex;
  flex-direction: column;
}

.technician-specialty,
.part-code {
  font-size: 0.8rem;
  color: #7f8c8d;
}

.technician-status {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: bold;
}

.technician-status.available {
  background-color: #d5f4e6;
  color: #27ae60;
}

.technician-status.busy {
  background-color: #fef5e7;
  color: #f39c12;
}

.part-quantity {
  text-align: right;
}

.low-stock-warning {
  color: #f39c12;
  font-size: 0.8rem;
  font-weight: bold;
}

@media (max-width: 768px) {
  .maintenance-tabs {
    flex-wrap: wrap;
  }
  
  .section-header {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .schedule-item {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .schedule-actions {
    flex-direction: row;
  }
  
  .records-filters {
    flex-direction: column;
  }
  
  .record-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .resources-grid {
    grid-template-columns: 1fr;
  }
  
  .technician-item,
  .part-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>