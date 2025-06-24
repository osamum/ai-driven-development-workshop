<template>
  <div class="equipment-status">
    <h2 class="page-title">設備稼働状況</h2>
    
    <!-- フィルターセクション -->
    <section class="filter-section">
      <div class="card">
        <div class="filter-controls">
          <div class="filter-group">
            <label>設備グループ:</label>
            <select v-model="selectedGroup" @change="filterEquipment">
              <option value="">すべて</option>
              <option v-for="group in equipmentGroups" :key="group.id" :value="group.group_name">
                {{ group.group_name }}
              </option>
            </select>
          </div>
          <div class="filter-group">
            <label>ステータス:</label>
            <select v-model="selectedStatus" @change="filterEquipment">
              <option value="">すべて</option>
              <option value="稼働中">稼働中</option>
              <option value="停止中">停止中</option>
              <option value="故障">故障</option>
              <option value="メンテナンス">メンテナンス</option>
            </select>
          </div>
          <div class="filter-group">
            <label>検索:</label>
            <input 
              type="text" 
              v-model="searchTerm" 
              @input="filterEquipment"
              placeholder="設備名で検索..."
            >
          </div>
        </div>
      </div>
    </section>

    <!-- 稼働状況サマリー -->
    <section class="status-summary">
      <div class="grid grid-4">
        <div class="card status-card active">
          <div class="status-icon">🟢</div>
          <div class="status-info">
            <div class="status-count">{{ statusCounts.active }}</div>
            <div class="status-label">稼働中</div>
          </div>
        </div>
        <div class="card status-card stopped">
          <div class="status-icon">🟡</div>
          <div class="status-info">
            <div class="status-count">{{ statusCounts.stopped }}</div>
            <div class="status-label">停止中</div>
          </div>
        </div>
        <div class="card status-card error">
          <div class="status-icon">🔴</div>
          <div class="status-info">
            <div class="status-count">{{ statusCounts.error }}</div>
            <div class="status-label">故障</div>
          </div>
        </div>
        <div class="card status-card maintenance">
          <div class="status-icon">🔧</div>
          <div class="status-info">
            <div class="status-count">{{ statusCounts.maintenance }}</div>
            <div class="status-label">メンテナンス</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 設備リスト -->
    <section class="equipment-list">
      <div class="card">
        <div class="equipment-header">
          <h3>設備一覧 ({{ filteredEquipment.length }}件)</h3>
          <div class="view-controls">
            <button 
              :class="['btn', { 'btn-primary': viewMode === 'grid' }]"
              @click="viewMode = 'grid'"
            >
              グリッド表示
            </button>
            <button 
              :class="['btn', { 'btn-primary': viewMode === 'table' }]"
              @click="viewMode = 'table'"
            >
              テーブル表示
            </button>
          </div>
        </div>

        <!-- グリッド表示 -->
        <div v-if="viewMode === 'grid'" class="equipment-grid">
          <div 
            v-for="equipment in filteredEquipment" 
            :key="equipment.id"
            class="equipment-card"
            @click="selectEquipment(equipment)"
          >
            <div class="equipment-card-header">
              <h4>{{ equipment.equipment_name }}</h4>
              <span :class="['status-badge', getStatusClass(equipment.status)]">
                {{ equipment.status }}
              </span>
            </div>
            
            <div class="equipment-info">
              <div class="info-row">
                <span class="info-label">種別:</span>
                <span>{{ equipment.equipment_type }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">場所:</span>
                <span>{{ equipment.location }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">モデル:</span>
                <span>{{ equipment.model_number }}</span>
              </div>
            </div>

            <!-- センサーデータ表示 -->
            <div v-if="equipment.sensors" class="sensor-data">
              <h5>センサー値</h5>
              <div class="sensor-grid">
                <div v-for="sensor in equipment.sensors.slice(0, 3)" :key="sensor.id" class="sensor-item">
                  <div class="sensor-name">{{ sensor.sensor_name }}</div>
                  <div :class="['sensor-value', getSensorStatusClass(sensor.status)]">
                    {{ sensor.current_value }} {{ sensor.unit }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- テーブル表示 -->
        <div v-if="viewMode === 'table'" class="equipment-table">
          <table>
            <thead>
              <tr>
                <th>設備名</th>
                <th>種別</th>
                <th>ステータス</th>
                <th>場所</th>
                <th>最終更新</th>
                <th>アクション</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="equipment in filteredEquipment" :key="equipment.id">
                <td>
                  <strong>{{ equipment.equipment_name }}</strong>
                  <br>
                  <small>{{ equipment.model_number }}</small>
                </td>
                <td>{{ equipment.equipment_type }}</td>
                <td>
                  <span :class="['status-badge', getStatusClass(equipment.status)]">
                    {{ equipment.status }}
                  </span>
                </td>
                <td>{{ equipment.location }}</td>
                <td>{{ formatDateTime(equipment.updated_at) }}</td>
                <td>
                  <button class="btn btn-primary btn-sm" @click="selectEquipment(equipment)">
                    詳細
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- 選択された設備の詳細モーダル -->
    <div v-if="selectedEquipment" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ selectedEquipment.equipment_name }} - 詳細情報</h3>
          <button class="close-btn" @click="closeModal">&times;</button>
        </div>
        
        <div class="modal-body">
          <div class="equipment-details">
            <div class="detail-section">
              <h4>基本情報</h4>
              <div class="detail-grid">
                <div class="detail-item">
                  <span class="detail-label">設備ID:</span>
                  <span>{{ selectedEquipment.equipment_id }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">種別:</span>
                  <span>{{ selectedEquipment.equipment_type }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">製造元:</span>
                  <span>{{ selectedEquipment.manufacturer }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">設置日:</span>
                  <span>{{ formatDate(selectedEquipment.installation_date) }}</span>
                </div>
              </div>
            </div>

            <div class="detail-section" v-if="selectedEquipment.sensors">
              <h4>センサーデータ</h4>
              <div class="sensor-detail-grid">
                <div v-for="sensor in selectedEquipment.sensors" :key="sensor.id" class="sensor-detail-item">
                  <div class="sensor-detail-header">
                    <span class="sensor-detail-name">{{ sensor.sensor_name }}</span>
                    <span :class="['sensor-detail-status', getSensorStatusClass(sensor.status)]">
                      {{ sensor.status }}
                    </span>
                  </div>
                  <div class="sensor-detail-value">
                    {{ sensor.current_value }} {{ sensor.unit }}
                  </div>
                  <div class="sensor-detail-range">
                    正常範囲: {{ sensor.normal_min }}～{{ sensor.normal_max }} {{ sensor.unit }}
                  </div>
                </div>
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
  name: 'EquipmentStatus',
  data() {
    return {
      // 設備データ
      equipmentList: [],
      filteredEquipment: [],
      equipmentGroups: [],
      
      // センサーデータ
      sensorData: [],
      
      // フィルター設定
      selectedGroup: '',
      selectedStatus: '',
      searchTerm: '',
      
      // 表示設定
      viewMode: 'grid', // 'grid' or 'table'
      
      // 選択された設備
      selectedEquipment: null,
      
      // ステータス集計
      statusCounts: {
        active: 0,
        stopped: 0,
        error: 0,
        maintenance: 0
      }
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
        
        // 設備グループの読み込み
        const groupsResponse = await fetch('/sample-data/equipment-groups.json');
        const groupsData = await groupsResponse.json();
        
        // センサーデータの読み込み
        const sensorsResponse = await fetch('/sample-data/sensors.json');
        const sensorsData = await sensorsResponse.json();
        
        // センサーデータの読み込み
        const sensorDataResponse = await fetch('/sample-data/sensor-data.json');
        const sensorDataValues = await sensorDataResponse.json();
        
        this.equipmentGroups = groupsData;
        this.sensorData = sensorDataValues;
        
        // 設備データにセンサー情報を関連付け
        this.equipmentList = equipmentData.map(equipment => ({
          ...equipment,
          sensors: this.getEquipmentSensors(equipment.equipment_id, sensorsData, sensorDataValues)
        }));
        
        this.filteredEquipment = [...this.equipmentList];
        this.calculateStatusCounts();
        
      } catch (error) {
        console.error('データの読み込みエラー:', error);
        this.setFallbackData();
      }
    },

    setFallbackData() {
      // フォールバックデータ
      this.equipmentList = [
        {
          id: 'eq1',
          equipment_id: 1,
          equipment_name: 'CNC加工機A1',
          equipment_type: 'CNC加工機',
          model_number: 'CNC-1000X',
          manufacturer: 'マキノ精機',
          location: '工場棟A-1F-001',
          status: '稼働中',
          installation_date: '2023-06-15',
          updated_at: new Date().toISOString(),
          sensors: [
            { id: 1, sensor_name: '温度', current_value: 45.2, unit: '℃', status: '正常', normal_min: 20, normal_max: 60 }
          ]
        }
      ];
      this.filteredEquipment = [...this.equipmentList];
      this.calculateStatusCounts();
    },

    getEquipmentSensors(equipmentId, sensorsData, sensorDataValues) {
      const equipmentSensors = sensorsData.filter(sensor => sensor.equipment_id === equipmentId);
      return equipmentSensors.map(sensor => {
        const latestData = sensorDataValues.find(data => data.sensor_id === sensor.sensor_id);
        return {
          ...sensor,
          current_value: latestData ? latestData.value : 0,
          status: latestData ? latestData.status : '不明',
          unit: sensor.measurement_unit || ''
        };
      });
    },

    filterEquipment() {
      this.filteredEquipment = this.equipmentList.filter(equipment => {
        const matchesGroup = !this.selectedGroup || equipment.equipment_type.includes(this.selectedGroup);
        const matchesStatus = !this.selectedStatus || equipment.status === this.selectedStatus;
        const matchesSearch = !this.searchTerm || 
          equipment.equipment_name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
          equipment.equipment_type.toLowerCase().includes(this.searchTerm.toLowerCase());
        
        return matchesGroup && matchesStatus && matchesSearch;
      });
      
      this.calculateStatusCounts();
    },

    calculateStatusCounts() {
      this.statusCounts = {
        active: this.filteredEquipment.filter(eq => eq.status === '稼働中').length,
        stopped: this.filteredEquipment.filter(eq => eq.status === '停止中').length,
        error: this.filteredEquipment.filter(eq => eq.status === '故障').length,
        maintenance: this.filteredEquipment.filter(eq => eq.status === 'メンテナンス').length
      };
    },

    getStatusClass(status) {
      switch (status) {
        case '稼働中': return 'status-active';
        case '停止中': return 'status-warning';
        case '故障': return 'status-error';
        case 'メンテナンス': return 'status-maintenance';
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
    },

    closeModal() {
      this.selectedEquipment = null;
    },

    formatDateTime(dateStr) {
      return new Date(dateStr).toLocaleString('ja-JP');
    },

    formatDate(dateStr) {
      return new Date(dateStr).toLocaleDateString('ja-JP');
    }
  }
}
</script>

<style scoped>
.equipment-status {
  max-width: 1400px;
  margin: 0 auto;
}

.page-title {
  font-size: 2rem;
  margin-bottom: 2rem;
  color: #2c3e50;
}

/* フィルターセクション */
.filter-section {
  margin-bottom: 2rem;
}

.filter-controls {
  display: flex;
  gap: 2rem;
  align-items: end;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-group label {
  font-weight: bold;
  color: #2c3e50;
}

.filter-group select,
.filter-group input {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  min-width: 150px;
}

/* ステータスサマリー */
.status-summary {
  margin-bottom: 2rem;
}

.status-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
}

.status-icon {
  font-size: 2rem;
}

.status-count {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
}

.status-label {
  color: #7f8c8d;
  font-size: 0.9rem;
}

.status-card.active .status-count {
  color: #27ae60;
}

.status-card.stopped .status-count {
  color: #f39c12;
}

.status-card.error .status-count {
  color: #e74c3c;
}

.status-card.maintenance .status-count {
  color: #9b59b6;
}

/* 設備リスト */
.equipment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.view-controls {
  display: flex;
  gap: 0.5rem;
}

.btn-sm {
  padding: 0.25rem 0.75rem;
  font-size: 0.875rem;
}

/* グリッド表示 */
.equipment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.equipment-card {
  border: 1px solid #e1e8ed;
  border-radius: 8px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.3s;
  background: white;
}

.equipment-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.equipment-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.equipment-card-header h4 {
  margin: 0;
  color: #2c3e50;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: bold;
  text-align: center;
}

.status-badge.status-active {
  background-color: #d5f4e6;
  color: #27ae60;
}

.status-badge.status-warning {
  background-color: #fef9e7;
  color: #f39c12;
}

.status-badge.status-error {
  background-color: #fadbd8;
  color: #e74c3c;
}

.status-badge.status-maintenance {
  background-color: #f4ecf7;
  color: #9b59b6;
}

.equipment-info {
  margin-bottom: 1rem;
}

.info-row {
  display: flex;
  margin-bottom: 0.5rem;
}

.info-label {
  font-weight: bold;
  min-width: 60px;
  color: #7f8c8d;
}

.sensor-data h5 {
  margin-bottom: 0.75rem;
  color: #2c3e50;
}

.sensor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(80px, 1fr));
  gap: 0.5rem;
}

.sensor-item {
  text-align: center;
  padding: 0.5rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.sensor-name {
  font-size: 0.75rem;
  color: #7f8c8d;
  margin-bottom: 0.25rem;
}

.sensor-value {
  font-weight: bold;
  font-size: 0.875rem;
}

/* テーブル表示 */
.equipment-table {
  overflow-x: auto;
}

.equipment-table table {
  width: 100%;
  border-collapse: collapse;
}

.equipment-table th,
.equipment-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #e1e8ed;
}

.equipment-table th {
  background-color: #f8f9fa;
  font-weight: bold;
  color: #2c3e50;
}

.equipment-table tr:hover {
  background-color: #f8f9fa;
}

/* モーダル */
.modal-overlay {
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

.modal-content {
  background: white;
  border-radius: 8px;
  max-width: 600px;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e1e8ed;
}

.modal-header h3 {
  margin: 0;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #7f8c8d;
}

.close-btn:hover {
  color: #2c3e50;
}

.modal-body {
  padding: 1.5rem;
}

.detail-section {
  margin-bottom: 2rem;
}

.detail-section h4 {
  margin-bottom: 1rem;
  color: #2c3e50;
  border-bottom: 1px solid #e1e8ed;
  padding-bottom: 0.5rem;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-label {
  font-weight: bold;
  color: #7f8c8d;
  font-size: 0.875rem;
}

.sensor-detail-grid {
  display: grid;
  gap: 1rem;
}

.sensor-detail-item {
  padding: 1rem;
  border: 1px solid #e1e8ed;
  border-radius: 4px;
  background-color: #f8f9fa;
}

.sensor-detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.sensor-detail-name {
  font-weight: bold;
  color: #2c3e50;
}

.sensor-detail-status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: bold;
}

.sensor-detail-value {
  font-size: 1.25rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
  color: #2c3e50;
}

.sensor-detail-range {
  font-size: 0.875rem;
  color: #7f8c8d;
}

/* レスポンシブデザイン */
@media (max-width: 768px) {
  .filter-controls {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-group {
    width: 100%;
  }
  
  .filter-group select,
  .filter-group input {
    min-width: 100%;
  }
  
  .equipment-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .equipment-grid {
    grid-template-columns: 1fr;
  }
  
  .modal-content {
    margin: 1rem;
    max-height: calc(100vh - 2rem);
  }
}
</style>