<template>
  <div class="home">
    <h2 class="page-title">統合ダッシュボード</h2>
    
    <!-- KPI概要セクション -->
    <section class="kpi-section">
      <div class="grid grid-4">
        <div class="card kpi-card">
          <h3>総設備数</h3>
          <div class="kpi-value">{{ summary.totalEquipment }}</div>
          <div class="kpi-label">台</div>
        </div>
        <div class="card kpi-card">
          <h3>稼働率</h3>
          <div class="kpi-value status-active">{{ summary.operationRate }}%</div>
          <div class="kpi-label">平均稼働率</div>
        </div>
        <div class="card kpi-card">
          <h3>アクティブアラート</h3>
          <div class="kpi-value status-warning">{{ summary.activeAlerts }}</div>
          <div class="kpi-label">件</div>
        </div>
        <div class="card kpi-card">
          <h3>保全予定</h3>
          <div class="kpi-value">{{ summary.maintenanceScheduled }}</div>
          <div class="kpi-label">件</div>
        </div>
      </div>
    </section>

    <!-- メインダッシュボードグリッド（4×3レイアウト） -->
    <section class="dashboard-grid">
      <div class="grid dashboard-main">
        
        <!-- 設備全体マップ -->
        <div class="card widget equipment-map">
          <h3>設備全体マップ</h3>
          <div class="map-container">
            <div class="equipment-grid">
              <div 
                v-for="equipment in equipmentList" 
                :key="equipment.id"
                :class="['equipment-item', getStatusClass(equipment.status)]"
                @click="selectEquipment(equipment)"
              >
                <div class="equipment-name">{{ equipment.equipment_name }}</div>
                <div class="equipment-status">{{ equipment.status }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- KPI詳細チャート -->
        <div class="card widget kpi-chart">
          <h3>KPI推移</h3>
          <div class="chart-container">
            <div class="chart-placeholder">
              <div class="chart-bar" v-for="(value, index) in kpiData" :key="index" :style="{ height: value + '%' }"></div>
            </div>
            <div class="chart-labels">
              <span>稼働率</span>
              <span>品質率</span>
              <span>生産性</span>
              <span>効率性</span>
            </div>
          </div>
        </div>

        <!-- アラート一覧 -->
        <div class="card widget alert-list">
          <h3>アクティブアラート</h3>
          <div class="alert-container">
            <div 
              v-for="alert in alerts" 
              :key="alert.id"
              :class="['alert-item', getSeverityClass(alert.severity)]"
            >
              <div class="alert-header">
                <span class="alert-equipment">{{ alert.equipment_name }}</span>
                <span class="alert-time">{{ formatTime(alert.timestamp) }}</span>
              </div>
              <div class="alert-message">{{ alert.message }}</div>
            </div>
          </div>
        </div>

        <!-- 予知保全スケジュール -->
        <div class="card widget maintenance-schedule">
          <h3>予知保全スケジュール</h3>
          <div class="schedule-container">
            <div 
              v-for="maintenance in maintenanceSchedule" 
              :key="maintenance.id"
              class="schedule-item"
            >
              <div class="schedule-date">{{ formatDate(maintenance.scheduled_date) }}</div>
              <div class="schedule-equipment">{{ maintenance.equipment_name }}</div>
              <div class="schedule-type">{{ maintenance.maintenance_type }}</div>
            </div>
          </div>
        </div>

        <!-- センサーデータ概要 -->
        <div class="card widget sensor-overview">
          <h3>センサーデータ概要</h3>
          <div class="sensor-grid">
            <div v-for="sensor in sensorSummary" :key="sensor.id" class="sensor-item">
              <div class="sensor-name">{{ sensor.sensor_name }}</div>
              <div class="sensor-value" :class="getSensorStatusClass(sensor.status)">
                {{ sensor.current_value }} {{ sensor.unit }}
              </div>
            </div>
          </div>
        </div>

        <!-- 生産実績 -->
        <div class="card widget production-summary">
          <h3>本日の生産実績</h3>
          <div class="production-stats">
            <div class="stat-item">
              <div class="stat-label">目標生産数</div>
              <div class="stat-value">1,000 個</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">実績生産数</div>
              <div class="stat-value status-active">856 個</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">達成率</div>
              <div class="stat-value">85.6%</div>
            </div>
          </div>
        </div>

      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'Home',
  data() {
    return {
      // サマリーデータ
      summary: {
        totalEquipment: 0,
        operationRate: 0,
        activeAlerts: 0,
        maintenanceScheduled: 0
      },
      // 設備リスト
      equipmentList: [],
      // アラートリスト
      alerts: [],
      // 保全スケジュール
      maintenanceSchedule: [],
      // センサーサマリー
      sensorSummary: [],
      // KPIチャートデータ
      kpiData: [85, 92, 78, 88], // パーセンテージ
      // 選択された設備
      selectedEquipment: null
    }
  },
  async mounted() {
    await this.loadData();
  },
  methods: {
    async loadData() {
      try {
        // 設備データの読み込み
        const equipmentResponse = await fetch('/sample-data/equipment.json');
        const equipmentData = await equipmentResponse.json();
        this.equipmentList = equipmentData.slice(0, 12); // 最初の12件を表示

        // アラートデータの読み込み
        const alertsResponse = await fetch('/sample-data/alerts.json');
        const alertsData = await alertsResponse.json();
        this.alerts = alertsData.filter(alert => alert.status === 'アクティブ').slice(0, 5);

        // センサーデータの読み込み
        const sensorsResponse = await fetch('/sample-data/sensors.json');
        const sensorsData = await sensorsResponse.json();
        this.sensorSummary = sensorsData.slice(0, 6);

        // サマリーデータの計算
        this.calculateSummary();
        
        // 保全スケジュールのサンプルデータ
        this.maintenanceSchedule = [
          {
            id: 1,
            equipment_name: 'CNC加工機A1',
            maintenance_type: '定期点検',
            scheduled_date: '2024-06-25'
          },
          {
            id: 2,
            equipment_name: '搬送ロボット1',
            maintenance_type: '予知保全',
            scheduled_date: '2024-06-26'
          },
          {
            id: 3,
            equipment_name: 'プレス機001',
            maintenance_type: 'オイル交換',
            scheduled_date: '2024-06-27'
          }
        ];

      } catch (error) {
        console.error('データの読み込みエラー:', error);
        // フォールバックデータを設定
        this.setFallbackData();
      }
    },

    setFallbackData() {
      // サンプルデータが読み込めない場合のフォールバック
      this.equipmentList = [
        { id: 'eq1', equipment_name: 'CNC加工機A1', status: '稼働中' },
        { id: 'eq2', equipment_name: '搬送ロボット1', status: '稼働中' },
        { id: 'eq3', equipment_name: 'プレス機001', status: '停止中' },
        { id: 'eq4', equipment_name: '射出成型機', status: '稼働中' }
      ];
      this.alerts = [
        { id: 1, equipment_name: 'プレス機001', message: '温度異常を検知しました', severity: 'high', timestamp: new Date().toISOString() }
      ];
      this.calculateSummary();
    },

    calculateSummary() {
      this.summary.totalEquipment = this.equipmentList.length;
      this.summary.activeAlerts = this.alerts.length;
      this.summary.maintenanceScheduled = this.maintenanceSchedule.length;
      
      // 稼働率計算（稼働中の設備 / 総設備数）
      const activeCount = this.equipmentList.filter(eq => eq.status === '稼働中').length;
      this.summary.operationRate = this.equipmentList.length > 0 
        ? Math.round((activeCount / this.equipmentList.length) * 100) 
        : 0;
    },

    getStatusClass(status) {
      switch (status) {
        case '稼働中': return 'status-active';
        case '停止中': return 'status-warning';
        case '故障': return 'status-error';
        default: return '';
      }
    },

    getSeverityClass(severity) {
      switch (severity) {
        case 'high': return 'severity-high';
        case 'medium': return 'severity-medium';
        case 'low': return 'severity-low';
        default: return '';
      }
    },

    getSensorStatusClass(status) {
      switch (status) {
        case '正常': return 'status-active';
        case '警告': return 'status-warning';
        case '異常': return 'status-error';
        default: return '';
      }
    },

    selectEquipment(equipment) {
      this.selectedEquipment = equipment;
      // 設備詳細表示やナビゲーションのロジックをここに追加
    },

    formatTime(timestamp) {
      return new Date(timestamp).toLocaleTimeString('ja-JP');
    },

    formatDate(dateStr) {
      return new Date(dateStr).toLocaleDateString('ja-JP');
    }
  }
}
</script>

<style scoped>
.home {
  max-width: 1400px;
  margin: 0 auto;
}

.page-title {
  font-size: 2rem;
  margin-bottom: 2rem;
  color: #2c3e50;
}

/* KPIセクション */
.kpi-section {
  margin-bottom: 2rem;
}

.kpi-card {
  text-align: center;
  padding: 1.5rem;
}

.kpi-card h3 {
  font-size: 0.9rem;
  color: #7f8c8d;
  margin-bottom: 0.5rem;
}

.kpi-value {
  font-size: 2.5rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
}

.kpi-label {
  font-size: 0.8rem;
  color: #95a5a6;
}

/* ダッシュボードグリッド */
.dashboard-main {
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.widget {
  min-height: 300px;
}

.widget h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
  border-bottom: 2px solid #ecf0f1;
  padding-bottom: 0.5rem;
}

/* 設備マップ */
.equipment-map {
  grid-column: span 2;
}

.equipment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 0.5rem;
}

.equipment-item {
  padding: 0.75rem;
  border: 2px solid #ecf0f1;
  border-radius: 4px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
}

.equipment-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.equipment-item.status-active {
  border-color: #27ae60;
  background-color: #d5f4e6;
}

.equipment-item.status-warning {
  border-color: #f39c12;
  background-color: #fef9e7;
}

.equipment-item.status-error {
  border-color: #e74c3c;
  background-color: #fadbd8;
}

.equipment-name {
  font-weight: bold;
  font-size: 0.8rem;
  margin-bottom: 0.25rem;
}

.equipment-status {
  font-size: 0.7rem;
}

/* KPIチャート */
.chart-container {
  height: 200px;
  display: flex;
  flex-direction: column;
}

.chart-placeholder {
  flex: 1;
  display: flex;
  align-items: end;
  gap: 1rem;
  padding: 1rem 0;
}

.chart-bar {
  flex: 1;
  background: linear-gradient(to top, #3498db, #5dade2);
  border-radius: 4px 4px 0 0;
  min-height: 20px;
  transition: all 0.3s;
}

.chart-bar:hover {
  background: linear-gradient(to top, #2980b9, #3498db);
}

.chart-labels {
  display: flex;
  gap: 1rem;
  font-size: 0.8rem;
  text-align: center;
}

.chart-labels span {
  flex: 1;
}

/* アラートリスト */
.alert-container {
  max-height: 250px;
  overflow-y: auto;
}

.alert-item {
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  border-left: 4px solid #ecf0f1;
  background-color: #f8f9fa;
  border-radius: 0 4px 4px 0;
}

.alert-item.severity-high {
  border-left-color: #e74c3c;
}

.alert-item.severity-medium {
  border-left-color: #f39c12;
}

.alert-item.severity-low {
  border-left-color: #f1c40f;
}

.alert-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.25rem;
  font-weight: bold;
}

.alert-equipment {
  color: #2c3e50;
}

.alert-time {
  color: #7f8c8d;
  font-size: 0.8rem;
}

.alert-message {
  font-size: 0.9rem;
  color: #5d6d7e;
}

/* 保全スケジュール */
.schedule-container {
  max-height: 250px;
  overflow-y: auto;
}

.schedule-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.schedule-date {
  font-weight: bold;
  color: #3498db;
}

.schedule-equipment {
  color: #2c3e50;
}

.schedule-type {
  font-size: 0.8rem;
  color: #7f8c8d;
}

/* センサーデータ */
.sensor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 0.75rem;
}

.sensor-item {
  text-align: center;
  padding: 0.75rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.sensor-name {
  font-size: 0.8rem;
  margin-bottom: 0.5rem;
  color: #7f8c8d;
}

.sensor-value {
  font-weight: bold;
  font-size: 1.1rem;
}

/* 生産実績 */
.production-stats {
  display: flex;
  justify-content: space-around;
  text-align: center;
}

.stat-item {
  flex: 1;
}

.stat-label {
  font-size: 0.8rem;
  color: #7f8c8d;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: bold;
  color: #2c3e50;
}

/* レスポンシブデザイン */
@media (max-width: 768px) {
  .dashboard-main {
    grid-template-columns: 1fr;
  }
  
  .equipment-map {
    grid-column: span 1;
  }
  
  .equipment-grid {
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  }
  
  .production-stats {
    flex-direction: column;
    gap: 1rem;
  }
}
</style>