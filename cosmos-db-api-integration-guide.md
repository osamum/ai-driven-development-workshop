# Azure Cosmos DB API 統合実装ガイド

## 概要

工場設備管理システムのサーバー側APIにAzure Cosmos DBとの統合機能を追加しました。この実装により、ファイルベースのサンプルデータから実際のデータベースへの移行が可能になります。

## 実装内容

### 1. Cosmos DB データサービスの追加

- **CosmosDataService.cs**: Azure Cosmos DB を使用したデータアクセスクラス
- **IDataService インターフェース拡張**: フィルタリング機能付きメソッドを追加

### 2. 設定可能な接続

環境変数で Cosmos DB への接続を制御：

```json
{
  "CosmosDB:ConnectionString": "AccountEndpoint=https://xxx.documents.azure.com:443/;AccountKey=xxx;",
  "CosmosDB:DatabaseName": "FactoryManagementDB"
}
```

### 3. API エンドポイントの拡張

#### 設備関連
- `GET /api/equipment` - フィルタリング機能強化
  - `groupId`: 設備グループでフィルタ
  - `equipmentType`: 設備タイプでフィルタ
  - `status`: ステータスでフィルタ  
  - `location`: 設置場所でフィルタ

- `GET /api/equipment/{id}/sensor-data` - 設備別センサーデータ取得
  - `fromDate`: 開始日時でフィルタ
  - `toDate`: 終了日時でフィルタ

#### 統合エンドポイント
- `GET /api/equipment-status` - 設備稼働状況の統合データ
  - 設備、センサー、センサーデータを一括取得
  - ステータス集計情報を含む

### 4. フォールバック機能

- Cosmos DB接続情報が未設定または接続失敗時は自動的にファイルベースサービスを使用
- 既存のサンプルデータとの互換性を維持

## データベース構造

### 必要なコンテナー
1. **Equipment** - 設備マスター
2. **EquipmentGroups** - 設備グループマスター  
3. **Sensors** - センサーマスター
4. **SensorData** - センサーデータ
5. **Users** - ユーザーマスター
6. **Alerts** - アラート情報

### パーティションキー設計
各コンテナーは適切なパーティションキーを設定してください：
- Equipment: `/group_id`
- EquipmentGroups: `/group_id`
- Sensors: `/equipment_id`
- SensorData: `/sensor_id`
- Users: `/department`
- Alerts: `/equipment_id`

## 設定手順

### 1. Azure Cosmos DB の準備

```bash
# Cosmos DB アカウントの作成
az cosmosdb create \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --default-consistency-level Session

# データベースの作成
az cosmosdb sql database create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --name FactoryManagementDB

# コンテナーの作成例
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name Equipment \
  --partition-key-path "/group_id"
```

### 2. 接続文字列の設定

```bash
# 接続文字列の取得
az cosmosdb keys list \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --type connection-strings
```

### 3. Azure Functions の設定

local.settings.json または Azure Functions の設定で以下を設定：

```json
{
  "CosmosDB:ConnectionString": "AccountEndpoint=https://factory-cosmosdb-account.documents.azure.com:443/;AccountKey=YOUR_KEY;",
  "CosmosDB:DatabaseName": "FactoryManagementDB"
}
```

## テスト方法

### 1. ファイルベースでのテスト

接続文字列を設定せずに Functions を起動すると、既存のサンプルデータを使用します。

### 2. Cosmos DB でのテスト

1. Cosmos DB に サンプルデータをインポート
2. 接続文字列を設定
3. Functions を再起動
4. API エンドポイントをテスト

### API テスト例

```bash
# 設備一覧取得（フィルタリングなし）
curl "https://your-function-app.azurewebsites.net/api/equipment"

# ステータスでフィルタリング
curl "https://your-function-app.azurewebsites.net/api/equipment?status=稼働中"

# 設備別センサーデータ取得
curl "https://your-function-app.azurewebsites.net/api/equipment/1/sensor-data?fromDate=2024-01-01&toDate=2024-12-31"

# 統合データ取得
curl "https://your-function-app.azurewebsites.net/api/equipment-status"
```

## パフォーマンス考慮事項

1. **インデックス設定**: よく使用されるフィルタ条件に対してインデックスを作成
2. **パーティション設計**: データアクセスパターンに応じた適切なパーティションキーの選択
3. **クエリ最適化**: 必要なフィールドのみを SELECT するようクエリを最適化

## トラブルシューティング

### よくある問題

1. **接続エラー**
   - 接続文字列の確認
   - ネットワーク接続の確認
   - ファイアウォール設定の確認

2. **パフォーマンス問題**
   - Request Unit (RU) の監視
   - インデックス設定の確認
   - クエリパフォーマンスの分析

3. **データ構造の不整合**
   - サンプルデータとの互換性確認
   - 日時フォーマットの統一
   - データ型の整合性確認

## 次のステップ

1. 本格運用前の負荷テスト実施
2. バックアップとリストア手順の確立
3. 監視・アラート設定の実装
4. セキュリティポリシーの適用