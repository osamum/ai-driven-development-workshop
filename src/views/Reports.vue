<template>
  <div class="reports">
    <div class="reports-header">
      <h1>分析・レポート</h1>
      <p>設備データの分析とレポート生成</p>
    </div>
    
    <!-- レポートタイプ選択 -->
    <div class="report-types grid grid-4">
      <div 
        v-for="type in reportTypes"
        :key="type.id"
        class="report-type-card card"
        :class="{ 'selected': selectedReportType === type.id }"
        @click="selectReportType(type.id)"
      >
        <h3>{{ type.title }}</h3>
        <p>{{ type.description }}</p>
        <div class="report-icon">{{ type.icon }}</div>
      </div>
    </div>
    
    <!-- フィルター設定 -->
    <div class="report-filters card">
      <h3>レポート設定</h3>
      <div class="filter-row">
        <div class="filter-group">
          <label class="form-label">期間</label>
          <select v-model="selectedPeriod" class="form-input">
            <option value="week">今週</option>
            <option value="month">今月</option>
            <option value="quarter">四半期</option>
            <option value="year">年間</option>
            <option value="custom">カスタム</option>
          </select>
        </div>
        
        <div v-if="selectedPeriod === 'custom'" class="filter-group">
          <label class="form-label">開始日</label>
          <input v-model="customStartDate" type="date" class="form-input">
        </div>
        
        <div v-if="selectedPeriod === 'custom'" class="filter-group">
          <label class="form-label">終了日</label>
          <input v-model="customEndDate" type="date" class="form-input">
        </div>
        
        <div class="filter-group">
          <label class="form-label">設備グループ</label>
          <select v-model="selectedGroup" class="form-input">
            <option value="">すべて</option>
            <option value="1">工場棟A</option>
            <option value="2">工場棟B</option>
            <option value="3">工場棟C</option>
          </select>
        </div>
        
        <div class="filter-actions">
          <button @click="generateReport" class="btn btn-primary">レポート生成</button>
          <button @click="exportReport" class="btn btn-success">エクスポート</button>
        </div>
      </div>
    </div>
    
    <!-- レポート表示エリア -->
    <div v-if="generatedReport" class="report-content">
      <!-- 稼働率分析レポート -->
      <div v-if="selectedReportType === 'operation'" class="report-section">
        <h2>稼働率分析レポート</h2>
        
        <div class="kpi-summary grid grid-4">
          <div class="kpi-card">
            <h4>平均稼働率</h4>
            <div class="kpi-value text-success">{{ operationReport.averageOperationRate }}%</div>
          </div>
          <div class="kpi-card">
            <h4>総稼働時間</h4>
            <div class="kpi-value">{{ operationReport.totalOperationHours }}h</div>
          </div>
          <div class="kpi-card">
            <h4>停止回数</h4>
            <div class="kpi-value text-warning">{{ operationReport.totalStops }}回</div>
          </div>
          <div class="kpi-card">
            <h4>平均停止時間</h4>
            <div class="kpi-value">{{ operationReport.averageStopDuration }}分</div>
          </div>
        </div>
        
        <div class="chart-section">
          <h3>設備別稼働率</h3>
          <div class="chart-placeholder">
            <div class="chart-bar-container">
              <div 
                v-for="equipment in operationReport.equipmentRates"
                :key="equipment.name"
                class="chart-bar-item"
              >
                <div class="chart-bar">
                  <div 
                    class="chart-bar-fill"
                    :style="{ width: equipment.rate + '%' }"
                    :class="getOperationRateClass(equipment.rate)"
                  ></div>
                </div>
                <div class="chart-label">{{ equipment.name }}</div>
                <div class="chart-value">{{ equipment.rate }}%</div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="trend-analysis">
          <h3>トレンド分析</h3>
          <div class="trend-items">
            <div class="trend-item">
              <span class="trend-icon text-success">↗</span>
              <span>CNC加工機A1の稼働率が前月比+5.2%向上</span>
            </div>
            <div class="trend-item">
              <span class="trend-icon text-danger">↘</span>
              <span>プレス機B1の稼働率が前月比-3.1%低下（保守による影響）</span>
            </div>
            <div class="trend-item">
              <span class="trend-icon text-success">↗</span>
              <span>全体平均稼働率が目標値90%を上回る</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 故障率分析レポート -->
      <div v-if="selectedReportType === 'failure'" class="report-section">
        <h2>故障率分析レポート</h2>
        
        <div class="failure-summary grid grid-3">
          <div class="summary-card">
            <h4>総故障件数</h4>
            <div class="summary-value text-danger">{{ failureReport.totalFailures }}</div>
          </div>
          <div class="summary-card">
            <h4>MTBF</h4>
            <div class="summary-value">{{ failureReport.mtbf }}時間</div>
            <small>平均故障間隔</small>
          </div>
          <div class="summary-card">
            <h4>MTTR</h4>
            <div class="summary-value">{{ failureReport.mttr }}時間</div>
            <small>平均修理時間</small>
          </div>
        </div>
        
        <div class="failure-analysis">
          <h3>故障原因分析</h3>
          <div class="failure-causes">
            <div 
              v-for="cause in failureReport.causes"
              :key="cause.type"
              class="cause-item"
            >
              <div class="cause-label">{{ cause.type }}</div>
              <div class="cause-bar">
                <div 
                  class="cause-bar-fill"
                  :style="{ width: (cause.count / failureReport.totalFailures * 100) + '%' }"
                ></div>
              </div>
              <div class="cause-count">{{ cause.count }}件</div>
            </div>
          </div>
        </div>
        
        <div class="failure-recommendations">
          <h3>改善提案</h3>
          <ul>
            <li>電気系故障が多いため、定期的な電気点検の頻度を増加</li>
            <li>機械的故障の早期発見のため、振動監視システムの導入検討</li>
            <li>予防保全計画の見直しにより、突発故障の削減を図る</li>
          </ul>
        </div>
      </div>
      
      <!-- 品質相関分析レポート -->
      <div v-if="selectedReportType === 'quality'" class="report-section">
        <h2>品質相関分析レポート</h2>
        
        <div class="quality-metrics grid grid-3">
          <div class="metric-card">
            <h4>不良率</h4>
            <div class="metric-value text-success">{{ qualityReport.defectRate }}%</div>
            <small>前月比 -0.3%</small>
          </div>
          <div class="metric-card">
            <h4>歩留まり</h4>
            <div class="metric-value text-success">{{ qualityReport.yieldRate }}%</div>
            <small>前月比 +1.2%</small>
          </div>
          <div class="metric-card">
            <h4>リワーク率</h4>
            <div class="metric-value text-warning">{{ qualityReport.reworkRate }}%</div>
            <small>前月比 +0.1%</small>
          </div>
        </div>
        
        <div class="correlation-analysis">
          <h3>設備パラメータと品質の相関</h3>
          <div class="correlation-table">
            <table>
              <thead>
                <tr>
                  <th>パラメータ</th>
                  <th>相関係数</th>
                  <th>影響度</th>
                  <th>推奨値</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="param in qualityReport.correlations" :key="param.parameter">
                  <td>{{ param.parameter }}</td>
                  <td>{{ param.correlation }}</td>
                  <td>
                    <span :class="getCorrelationClass(param.correlation)">
                      {{ getCorrelationLevel(param.correlation) }}
                    </span>
                  </td>
                  <td>{{ param.recommendedValue }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      
      <!-- カスタムレポート -->
      <div v-if="selectedReportType === 'custom'" class="report-section">
        <h2>カスタムレポート</h2>
        
        <div class="custom-report-builder">
          <h3>レポート項目選択</h3>
          <div class="report-items">
            <div class="item-category">
              <h4>稼働データ</h4>
              <div class="item-checkboxes">
                <label>
                  <input type="checkbox" v-model="customReport.includeOperation">
                  稼働率
                </label>
                <label>
                  <input type="checkbox" v-model="customReport.includeDowntime">
                  停止時間
                </label>
                <label>
                  <input type="checkbox" v-model="customReport.includeUtilization">
                  設備利用率
                </label>
              </div>
            </div>
            
            <div class="item-category">
              <h4>保全データ</h4>
              <div class="item-checkboxes">
                <label>
                  <input type="checkbox" v-model="customReport.includeMaintenance">
                  保全コスト
                </label>
                <label>
                  <input type="checkbox" v-model="customReport.includeFailures">
                  故障履歴
                </label>
                <label>
                  <input type="checkbox" v-model="customReport.includePreventive">
                  予防保全実施率
                </label>
              </div>
            </div>
            
            <div class="item-category">
              <h4>品質データ</h4>
              <div class="item-checkboxes">
                <label>
                  <input type="checkbox" v-model="customReport.includeQuality">
                  品質指標
                </label>
                <label>
                  <input type="checkbox" v-model="customReport.includeDefects">
                  不良分析
                </label>
              </div>
            </div>
          </div>
          
          <button @click="generateCustomReport" class="btn btn-primary">カスタムレポート生成</button>
        </div>
        
        <div v-if="customReportGenerated" class="custom-report-result">
          <h3>生成されたカスタムレポート</h3>
          <p>選択された項目に基づいてレポートが生成されました。</p>
          <!-- ここに選択された項目に応じた内容を表示 -->
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Reports',
  data() {
    return {
      selectedReportType: 'operation',
      selectedPeriod: 'month',
      selectedGroup: '',
      customStartDate: '',
      customEndDate: '',
      generatedReport: false,
      customReportGenerated: false,
      reportTypes: [
        {
          id: 'operation',
          title: '稼働率分析',
          description: '設備の稼働状況と効率性の分析',
          icon: '📊'
        },
        {
          id: 'failure',
          title: '故障率分析',
          description: '故障パターンと予防策の分析',
          icon: '⚠️'
        },
        {
          id: 'quality',
          title: '品質相関分析',
          description: '設備パラメータと品質の関係分析',
          icon: '🎯'
        },
        {
          id: 'custom',
          title: 'カスタムレポート',
          description: '任意の項目を組み合わせたレポート',
          icon: '🔧'
        }
      ],
      operationReport: {
        averageOperationRate: 92.5,
        totalOperationHours: 1456,
        totalStops: 23,
        averageStopDuration: 18,
        equipmentRates: [
          { name: 'CNC加工機A1', rate: 94.2 },
          { name: '搬送ロボット1', rate: 96.8 },
          { name: 'プレス機B1', rate: 85.3 },
          { name: '検査機C1', rate: 93.7 }
        ]
      },
      failureReport: {
        totalFailures: 12,
        mtbf: 156,
        mttr: 2.5,
        causes: [
          { type: '電気系故障', count: 5 },
          { type: '機械的故障', count: 4 },
          { type: 'ソフトウェア問題', count: 2 },
          { type: 'その他', count: 1 }
        ]
      },
      qualityReport: {
        defectRate: 1.2,
        yieldRate: 98.5,
        reworkRate: 2.8,
        correlations: [
          {
            parameter: '温度',
            correlation: 0.73,
            recommendedValue: '75-80℃'
          },
          {
            parameter: '振動',
            correlation: -0.68,
            recommendedValue: '<2.0mm/s'
          },
          {
            parameter: '電流',
            correlation: 0.45,
            recommendedValue: '14-16A'
          },
          {
            parameter: '速度',
            correlation: -0.32,
            recommendedValue: '85-95%'
          }
        ]
      },
      customReport: {
        includeOperation: false,
        includeDowntime: false,
        includeUtilization: false,
        includeMaintenance: false,
        includeFailures: false,
        includePreventive: false,
        includeQuality: false,
        includeDefects: false
      }
    }
  },
  methods: {
    selectReportType(typeId) {
      this.selectedReportType = typeId
      this.generatedReport = false
    },
    
    generateReport() {
      // レポート生成処理
      this.generatedReport = true
    },
    
    exportReport() {
      // レポートエクスポート処理
      alert('レポートをエクスポートしました。')
    },
    
    generateCustomReport() {
      this.customReportGenerated = true
    },
    
    getOperationRateClass(rate) {
      if (rate >= 95) return 'rate-excellent'
      if (rate >= 90) return 'rate-good'
      if (rate >= 80) return 'rate-fair'
      return 'rate-poor'
    },
    
    getCorrelationClass(correlation) {
      const abs = Math.abs(correlation)
      if (abs >= 0.7) return 'correlation-strong'
      if (abs >= 0.5) return 'correlation-moderate'
      return 'correlation-weak'
    },
    
    getCorrelationLevel(correlation) {
      const abs = Math.abs(correlation)
      if (abs >= 0.7) return '強い'
      if (abs >= 0.5) return '中程度'
      return '弱い'
    }
  }
}
</script>

<style scoped>
.reports-header {
  margin-bottom: 2rem;
}

.report-types {
  margin-bottom: 2rem;
}

.report-type-card {
  cursor: pointer;
  transition: all 0.3s;
  text-align: center;
  border: 2px solid transparent;
}

.report-type-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.15);
}

.report-type-card.selected {
  border-color: #3498db;
  background-color: #f8f9fa;
}

.report-type-card h3 {
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.report-type-card p {
  margin-bottom: 1rem;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.report-icon {
  font-size: 2rem;
}

.report-filters h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.filter-row {
  display: flex;
  gap: 1rem;
  align-items: end;
  flex-wrap: wrap;
}

.filter-group {
  min-width: 150px;
}

.filter-actions {
  display: flex;
  gap: 0.5rem;
}

.report-content {
  margin-top: 2rem;
}

.report-section h2 {
  margin-bottom: 2rem;
  color: #2c3e50;
  border-bottom: 2px solid #3498db;
  padding-bottom: 0.5rem;
}

.kpi-summary {
  margin-bottom: 2rem;
}

.kpi-card {
  text-align: center;
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.kpi-card h4 {
  margin-bottom: 0.5rem;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.kpi-value {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
}

.chart-section {
  margin-bottom: 2rem;
}

.chart-section h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.chart-placeholder {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.chart-bar-container {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.chart-bar-item {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.chart-label {
  min-width: 120px;
  font-weight: bold;
  color: #2c3e50;
}

.chart-bar {
  flex: 1;
  height: 20px;
  background-color: #ecf0f1;
  border-radius: 10px;
  overflow: hidden;
}

.chart-bar-fill {
  height: 100%;
  border-radius: 10px;
  transition: width 0.5s ease;
}

.rate-excellent {
  background-color: #27ae60;
}

.rate-good {
  background-color: #f39c12;
}

.rate-fair {
  background-color: #e67e22;
}

.rate-poor {
  background-color: #e74c3c;
}

.chart-value {
  min-width: 50px;
  text-align: right;
  font-weight: bold;
  color: #2c3e50;
}

.trend-analysis {
  margin-bottom: 2rem;
}

.trend-analysis h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.trend-items {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.trend-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  padding: 0.5rem;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.trend-item:last-child {
  margin-bottom: 0;
}

.trend-icon {
  font-size: 1.2rem;
  font-weight: bold;
}

.failure-summary {
  margin-bottom: 2rem;
}

.summary-card {
  text-align: center;
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.summary-card h4 {
  margin-bottom: 0.5rem;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.summary-value {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
}

.summary-card small {
  color: #95a5a6;
  font-size: 0.8rem;
}

.failure-analysis,
.failure-recommendations {
  margin-bottom: 2rem;
}

.failure-analysis h3,
.failure-recommendations h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.failure-causes {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.cause-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.cause-label {
  min-width: 120px;
  font-weight: bold;
  color: #2c3e50;
}

.cause-bar {
  flex: 1;
  height: 20px;
  background-color: #ecf0f1;
  border-radius: 10px;
  overflow: hidden;
}

.cause-bar-fill {
  height: 100%;
  background-color: #e74c3c;
  border-radius: 10px;
}

.cause-count {
  min-width: 50px;
  text-align: right;
  font-weight: bold;
  color: #2c3e50;
}

.failure-recommendations {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.failure-recommendations ul {
  margin: 0;
  padding-left: 1.5rem;
}

.failure-recommendations li {
  margin-bottom: 0.5rem;
  color: #7f8c8d;
  line-height: 1.5;
}

.quality-metrics {
  margin-bottom: 2rem;
}

.metric-card {
  text-align: center;
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.metric-card h4 {
  margin-bottom: 0.5rem;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.metric-value {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 0.25rem;
}

.metric-card small {
  color: #95a5a6;
  font-size: 0.8rem;
}

.correlation-analysis h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.correlation-table {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  overflow-x: auto;
}

.correlation-table table {
  width: 100%;
  border-collapse: collapse;
}

.correlation-table th,
.correlation-table td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #ecf0f1;
}

.correlation-table th {
  background-color: #f8f9fa;
  font-weight: bold;
  color: #2c3e50;
}

.correlation-strong {
  color: #e74c3c;
  font-weight: bold;
}

.correlation-moderate {
  color: #f39c12;
  font-weight: bold;
}

.correlation-weak {
  color: #7f8c8d;
}

.custom-report-builder {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.custom-report-builder h3 {
  margin-bottom: 1.5rem;
  color: #2c3e50;
}

.report-items {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.item-category h4 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.item-checkboxes {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.item-checkboxes label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.custom-report-result {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.custom-report-result h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

@media (max-width: 768px) {
  .filter-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-actions {
    margin-top: 1rem;
  }
  
  .chart-bar-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .chart-bar {
    width: 100%;
  }
  
  .cause-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .cause-bar {
    width: 100%;
  }
  
  .correlation-table {
    font-size: 0.9rem;
  }
  
  .report-items {
    grid-template-columns: 1fr;
  }
}
</style>