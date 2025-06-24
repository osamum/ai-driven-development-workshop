# Azure Functions API 動作確認・テスト手順書

## 概要

実装されたAzure Functions APIの動作確認とテスト手順を説明します。

## ローカル開発環境でのテスト

### C# Functions のテスト

```bash
# プロジェクトディレクトリに移動
cd azure-functions/csharp-functions

# ローカル実行
func start --port 7071

# 別ターミナルでテスト実行
# 設備グループ一覧取得
curl "http://localhost:7071/api/equipment-groups"

# フィルター付き設備取得
curl "http://localhost:7071/api/equipment?groupId=1&status=稼働中"

# 特定設備取得
curl "http://localhost:7071/api/equipment/1"

# センサーデータ取得（日付フィルター）
curl "http://localhost:7071/api/sensor-data?fromDate=2024-01-01&toDate=2024-12-31"

# アラート取得（重要度フィルター）
curl "http://localhost:7071/api/alerts?severity=高"
```

### Python Functions のテスト

```bash
# プロジェクトディレクトリに移動
cd azure-functions/python-functions

# Python仮想環境作成（初回のみ）
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# ローカル実行
func start --port 7072

# 別ターミナルでテスト実行
# 設備効率分析
curl "http://localhost:7072/api/analytics/equipment-efficiency"

# グループ別設備効率分析
curl "http://localhost:7072/api/analytics/equipment-efficiency?groupId=1"

# 予知保全分析
curl "http://localhost:7072/api/analytics/predictive-maintenance"

# 特定設備の予知保全分析
curl "http://localhost:7072/api/analytics/predictive-maintenance?equipmentId=1"

# センサー統計分析
curl "http://localhost:7072/api/analytics/sensor-statistics"

# 特定センサーの統計分析
curl "http://localhost:7072/api/analytics/sensor-statistics?sensorId=1"
```

### Node.js Functions のテスト

```bash
# プロジェクトディレクトリに移動
cd azure-functions/nodejs-functions

# 依存関係インストール（初回のみ）
npm install

# ローカル実行
func start --port 7073

# 別ターミナルでテスト実行
# リアルタイム通知取得
curl "http://localhost:7073/api/notifications/realtime"

# フィルター付きリアルタイム通知
curl "http://localhost:7073/api/notifications/realtime?severity=高&limit=5"

# WebSocket状態確認
curl "http://localhost:7073/api/websocket/status"

# システム健全性チェック
curl "http://localhost:7073/api/system/health"

# チャット通知送信（POST）
curl -X POST "http://localhost:7073/api/notifications/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "設備1で異常を検知しました",
    "channel": "maintenance",
    "priority": "high",
    "equipment_id": 1
  }'
```

## 統合テスト

### PowerShell スクリプト例（Windows）

```powershell
# Azure Functions API 統合テスト
$baseUrls = @{
    csharp = "http://localhost:7071"
    python = "http://localhost:7072" 
    nodejs = "http://localhost:7073"
}

Write-Host "Azure Functions API 統合テスト開始" -ForegroundColor Green

# C# Functions テスト
Write-Host "C# Functions テスト..." -ForegroundColor Yellow
$equipmentGroups = Invoke-RestMethod -Uri "$($baseUrls.csharp)/api/equipment-groups"
$equipmentCount = Invoke-RestMethod -Uri "$($baseUrls.csharp)/api/equipment"
Write-Host "設備グループ数: $($equipmentGroups.Count), 設備数: $($equipmentCount.Count)"

# Python Functions テスト
Write-Host "Python Functions テスト..." -ForegroundColor Yellow
$efficiency = Invoke-RestMethod -Uri "$($baseUrls.python)/api/analytics/equipment-efficiency"
$predictive = Invoke-RestMethod -Uri "$($baseUrls.python)/api/analytics/predictive-maintenance"
Write-Host "効率分析データ数: $($efficiency.Count), 予知保全データ数: $($predictive.Count)"

# Node.js Functions テスト
Write-Host "Node.js Functions テスト..." -ForegroundColor Yellow
$notifications = Invoke-RestMethod -Uri "$($baseUrls.nodejs)/api/notifications/realtime"
$health = Invoke-RestMethod -Uri "$($baseUrls.nodejs)/api/system/health"
Write-Host "通知数: $($notifications.Count), システム状態: $($health.overall_status)"

Write-Host "統合テスト完了" -ForegroundColor Green
```

### Bash スクリプト例（Linux/Mac）

```bash
#!/bin/bash

# Azure Functions API 統合テスト
CSHARP_URL="http://localhost:7071"
PYTHON_URL="http://localhost:7072"
NODEJS_URL="http://localhost:7073"

echo "Azure Functions API 統合テスト開始"

# C# Functions テスト
echo "C# Functions テスト..."
EQUIPMENT_GROUPS=$(curl -s "$CSHARP_URL/api/equipment-groups" | jq length)
EQUIPMENT_COUNT=$(curl -s "$CSHARP_URL/api/equipment" | jq length)
echo "設備グループ数: $EQUIPMENT_GROUPS, 設備数: $EQUIPMENT_COUNT"

# Python Functions テスト
echo "Python Functions テスト..."
EFFICIENCY_COUNT=$(curl -s "$PYTHON_URL/api/analytics/equipment-efficiency" | jq length)
PREDICTIVE_COUNT=$(curl -s "$PYTHON_URL/api/analytics/predictive-maintenance" | jq length)
echo "効率分析データ数: $EFFICIENCY_COUNT, 予知保全データ数: $PREDICTIVE_COUNT"

# Node.js Functions テスト
echo "Node.js Functions テスト..."
NOTIFICATION_COUNT=$(curl -s "$NODEJS_URL/api/notifications/realtime" | jq length)
HEALTH_STATUS=$(curl -s "$NODEJS_URL/api/system/health" | jq -r .overall_status)
echo "通知数: $NOTIFICATION_COUNT, システム状態: $HEALTH_STATUS"

echo "統合テスト完了"
```

## Vue.js アプリケーションでのテスト

### 1. API サービスの統合

```javascript
// main.js または main.ts
import { createApp } from 'vue'
import App from './App.vue'
import apiService from './services/api-service.js'

const app = createApp(App)

// グローバルプロパティとしてAPIサービスを登録
app.config.globalProperties.$api = apiService

app.mount('#app')
```

### 2. コンポーネントでの使用例

```vue
<template>
  <div class="dashboard">
    <h1>工場設備管理ダッシュボード</h1>
    
    <!-- システム状態 -->
    <div class="system-status" v-if="systemHealth">
      <h2>システム状態: {{ systemHealth.overall_status }}</h2>
      <p>CPU使用率: {{ systemHealth.system_metrics?.cpu_usage_percent }}%</p>
    </div>

    <!-- 設備グループ -->
    <div class="equipment-groups">
      <h2>設備グループ</h2>
      <ul>
        <li v-for="group in equipmentGroups" :key="group.groupId">
          {{ group.groupName }} - {{ group.description }}
        </li>
      </ul>
    </div>

    <!-- リアルタイム通知 -->
    <div class="notifications">
      <h2>リアルタイム通知</h2>
      <ul>
        <li v-for="notification in notifications" :key="notification.alert_id">
          [{{ notification.severity }}] {{ notification.message }}
        </li>
      </ul>
    </div>

    <!-- エラー表示 -->
    <div v-if="error" class="error">
      エラー: {{ error }}
    </div>
  </div>
</template>

<script>
import apiService from '../services/api-service.js'

export default {
  name: 'Dashboard',
  data() {
    return {
      equipmentGroups: [],
      notifications: [],
      systemHealth: null,
      error: null,
      pollingInterval: null
    }
  },
  async mounted() {
    await this.loadDashboardData()
    this.startRealtimeUpdates()
  },
  beforeUnmount() {
    this.stopRealtimeUpdates()
  },
  methods: {
    async loadDashboardData() {
      try {
        const data = await apiService.getDashboardData()
        this.equipmentGroups = data.equipmentGroups
        this.systemHealth = data.systemHealth
        this.notifications = data.realtimeNotifications
      } catch (error) {
        this.error = error.message
        console.error('ダッシュボードデータ読み込みエラー:', error)
      }
    },
    startRealtimeUpdates() {
      this.pollingInterval = apiService.startRealtimePolling(
        (data) => {
          this.systemHealth = data.status
          this.notifications = data.notifications
        },
        30000 // 30秒間隔
      )
    },
    stopRealtimeUpdates() {
      apiService.stopRealtimePolling(this.pollingInterval)
    }
  }
}
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.system-status {
  background-color: #f0f8ff;
  padding: 15px;
  border-radius: 5px;
  margin-bottom: 20px;
}

.equipment-groups, .notifications {
  margin-bottom: 20px;
}

.error {
  color: red;
  background-color: #ffe6e6;
  padding: 10px;
  border-radius: 5px;
}
</style>
```

## パフォーマンステスト

### 負荷テスト例（Apache Bench）

```bash
# 設備グループAPI負荷テスト（100リクエスト、10並行）
ab -n 100 -c 10 http://localhost:7071/api/equipment-groups

# 分析API負荷テスト
ab -n 50 -c 5 http://localhost:7072/api/analytics/equipment-efficiency

# リアルタイム通知API負荷テスト
ab -n 200 -c 20 http://localhost:7073/api/notifications/realtime
```

## エラーハンドリングテスト

```bash
# 存在しない設備ID
curl "http://localhost:7071/api/equipment/9999"

# 不正なパラメータ
curl "http://localhost:7071/api/equipment?groupId=invalid"

# 存在しないエンドポイント
curl "http://localhost:7071/api/nonexistent"
```

## 監視・ログ確認

### Application Insights での確認項目

1. **パフォーマンス**
   - 平均応答時間
   - スループット（RPS）
   - 失敗率

2. **エラー**
   - 例外ログ
   - HTTP 4xx/5xx エラー
   - カスタムエラーメッセージ

3. **依存関係**
   - 外部API呼び出し
   - データベース接続（将来的に）

### ローカルログ確認

```bash
# Function実行ログの確認
func start --verbose

# 特定のFunctionのログフィルタリング
func start | grep "EquipmentGroupFunctions"
```

## 本番環境でのテスト

### デプロイ後の動作確認

```bash
# C# Functions
curl "https://factory-csharp-functions-XXXXX.azurewebsites.net/api/equipment-groups"

# Python Functions  
curl "https://factory-python-functions-XXXXX.azurewebsites.net/api/analytics/equipment-efficiency"

# Node.js Functions
curl "https://factory-nodejs-functions-XXXXX.azurewebsites.net/api/notifications/realtime"
```

### セキュリティテスト

```bash
# CORS テスト
curl -H "Origin: https://yourdomain.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: X-Requested-With" \
  -X OPTIONS \
  "https://factory-csharp-functions-XXXXX.azurewebsites.net/api/equipment-groups"

# 認証テスト（設定されている場合）
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "https://factory-csharp-functions-XXXXX.azurewebsites.net/api/equipment-groups"
```