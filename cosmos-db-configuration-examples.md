# Cosmos DB 統合設定例

## 環境変数設定（Azure Functions）

### local.settings.json での設定
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "CosmosDB:ConnectionString": "AccountEndpoint=https://factory-cosmosdb-account.documents.azure.com:443/;AccountKey=YOUR_PRIMARY_KEY;",
    "CosmosDB:DatabaseName": "FactoryManagementDB"
  }
}
```

### Azure Functions App での設定
```bash
# Azure CLI で設定
az functionapp config appsettings set \
  --name your-function-app-name \
  --resource-group factory-management-rg \
  --settings "CosmosDB:ConnectionString=AccountEndpoint=https://factory-cosmosdb-account.documents.azure.com:443/;AccountKey=YOUR_PRIMARY_KEY;"

az functionapp config appsettings set \
  --name your-function-app-name \
  --resource-group factory-management-rg \
  --settings "CosmosDB:DatabaseName=FactoryManagementDB"
```

## フロントエンド設定（Vue.js）

### .env.local での設定
```
# Azure Functions のベースURL
VUE_APP_API_BASE_URL=https://your-function-app.azurewebsites.net
```

### .env.development での設定（開発環境）
```
# ローカル Azure Functions
VUE_APP_API_BASE_URL=http://localhost:7071
```

## API使用例

### JavaScript での API呼び出し例

```javascript
import apiService from '@/services/api';

// 設備稼働状況の取得（フィルタリングなし）
const status = await apiService.getEquipmentStatus();

// フィルタリング付きで設備稼働状況を取得
const filteredStatus = await apiService.getEquipmentStatus({
  status: '稼働中',
  location: '工場棟A'
});

// 設備別センサーデータの取得
const sensorData = await apiService.getEquipmentSensorData(1, {
  fromDate: '2024-01-01',
  toDate: '2024-12-31'
});
```

### REST API 直接呼び出し例

```bash
# 基本的な設備稼働状況取得
curl "https://your-function-app.azurewebsites.net/api/equipment-status"

# フィルタリング付き設備データ取得
curl "https://your-function-app.azurewebsites.net/api/equipment?status=稼働中&location=工場棟A"

# 設備別センサーデータ取得
curl "https://your-function-app.azurewebsites.net/api/equipment/1/sensor-data?fromDate=2024-01-01T00:00:00Z&toDate=2024-12-31T23:59:59Z"
```

## 設定の検証方法

### 1. ローカル開発環境での確認

```bash
# Azure Functions をローカルで起動
cd azure-functions/csharp-functions
func start

# 別ターミナルでAPIテスト
curl "http://localhost:7071/api/equipment-status"
```

### 2. Cosmos DB 接続の確認

```bash
# Azure CLI で接続テスト
az cosmosdb sql database show \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --name FactoryManagementDB
```

### 3. Vue.js フロントエンドでの確認

```bash
# 開発サーバー起動
npm run serve

# ブラウザで http://localhost:8080 にアクセス
# ブラウザのDevToolsでAPIリクエストを確認
```

## トラブルシューティング

### Functions がファイルベースで動作している場合

コンソールログで以下のメッセージを確認：
- "Cosmos DB データサービスを使用します" → Cosmos DB使用中
- "ファイルベースサービスを使用します" → ファイルベース使用中

### 設定確認

```bash
# Azure Functions の環境変数確認
az functionapp config appsettings list \
  --name your-function-app-name \
  --resource-group factory-management-rg
```