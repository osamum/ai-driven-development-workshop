# Azure SQL Database テーブル作成手順書

## 概要

本ドキュメントでは、工場設備管理システム用のAzure SQL Databaseのテーブル作成手順を説明します。Azure SQL Database v12に対応した包括的なデータベーススキーマを構築します。

## 前提条件

- Azure サブスクリプション
- Azure CLI のインストール
- SQL Server Management Studio (SSMS) または Azure Data Studio
- 適切な権限（Contributor以上）

## Azure リソースの作成

### 1. Azure CLIでのログイン

```bash
# Azureにログイン
az login

# サブスクリプションの確認
az account show

# 使用するサブスクリプションの設定（必要に応じて）
az account set --subscription "your-subscription-id"
```

### 2. リソースグループの作成

```bash
# リソースグループの作成
az group create \
  --name rg-factory-management-system \
  --location japaneast
```

### 3. SQL Server（論理サーバー）の作成

```bash
# SQL Server論理サーバーの作成
az sql server create \
  --name sql-factory-management-$(date +%s) \
  --resource-group rg-factory-management-system \
  --location japaneast \
  --admin-user sqladmin \
  --admin-password 'P@ssw0rd2024!'
```

**重要:** パスワードは実際のプロダクション環境では、より複雑で安全なものを使用してください。

### 4. ファイアウォールルールの設定

```bash
# 現在のクライアントIPからのアクセスを許可
az sql server firewall-rule create \
  --resource-group rg-factory-management-system \
  --server sql-factory-management-XXXXX \
  --name AllowCurrentClientIP \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Azure サービスからのアクセスを許可
az sql server firewall-rule create \
  --resource-group rg-factory-management-system \
  --server sql-factory-management-XXXXX \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### 5. SQL Database の作成

```bash
# SQL Database の作成
az sql db create \
  --resource-group rg-factory-management-system \
  --server sql-factory-management-XXXXX \
  --name factory-management-db \
  --service-objective S2 \
  --collation Japanese_CI_AS
```

## データベーススキーマの展開

### 1. データベースへの接続

SQL Server Management Studio (SSMS) または Azure Data Studio を使用してデータベースに接続します。

**接続情報:**
- サーバー名: `sql-factory-management-XXXXX.database.windows.net`
- データベース名: `factory-management-db`
- 認証: SQL Server認証
- ユーザー名: `sqladmin`
- パスワード: 作成時に設定したパスワード

### 2. SQLスクリプトの実行

1. `azure-sql-tables.sql` ファイルを開きます
2. データベースに接続した状態でスクリプトを実行します
3. エラーが発生しないことを確認します

```sql
-- 実行確認クエリ
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
```

## 作成されるテーブル一覧

### 設備関連テーブル（5テーブル）
- `EquipmentGroup` - 設備グループ
- `Equipment` - 設備
- `Sensor` - センサー
- `SensorData` - センサーデータ
- `EquipmentStatus` - 設備状態

### ユーザー関連テーブル（2テーブル）
- `UserRole` - ユーザー役割
- `User` - ユーザー

### アラート関連テーブル（3テーブル）
- `AlertType` - アラート種別
- `Alert` - アラート
- `AlertAction` - アラート対応

### 保全関連テーブル（5テーブル）
- `MaintenanceType` - 保全種別
- `MaintenancePlan` - 保全計画
- `MaintenanceWork` - 保全作業
- `Part` - 部品
- `MaintenancePartUsage` - 保全部品使用

### その他のテーブル（3テーブル）
- `AnalyticsReport` - 分析レポート
- `KPIMetrics` - KPI指標
- `Notification` - 通知
- `NotificationType` - 通知種別
- `PredictiveModel` - 予測モデル
- `PredictionResult` - 予測結果
- `ExternalSystem` - 外部システム
- `DataSyncLog` - データ同期ログ

## パフォーマンス最適化設定

### 1. 自動チューニングの有効化

```bash
# 自動チューニングの有効化
az sql db update \
  --resource-group rg-factory-management-system \
  --server sql-factory-management-XXXXX \
  --name factory-management-db \
  --auto-pause-delay 60 \
  --compute-model Provisioned
```

### 2. Query Store の有効化

```sql
-- Query Store の有効化（SSMSで実行）
ALTER DATABASE [factory-management-db] SET QUERY_STORE = ON;
ALTER DATABASE [factory-management-db] SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);
```

## セキュリティ設定

### 1. Transparent Data Encryption (TDE) の有効化

```bash
# TDE の有効化
az sql db tde set \
  --resource-group rg-factory-management-system \
  --server sql-factory-management-XXXXX \
  --database factory-management-db \
  --status Enabled
```

### 2. Advanced Data Security の有効化

```bash
# Advanced Data Security の有効化
az sql server ad-admin create \
  --resource-group rg-factory-management-system \
  --server-name sql-factory-management-XXXXX \
  --display-name "Azure AD Admin" \
  --object-id your-azure-ad-object-id
```

## 監視とメンテナンス

### 1. メトリクス監視の設定

```bash
# 診断設定の作成
az monitor diagnostic-settings create \
  --name factory-db-diagnostics \
  --resource /subscriptions/your-subscription-id/resourceGroups/rg-factory-management-system/providers/Microsoft.Sql/servers/sql-factory-management-XXXXX/databases/factory-management-db \
  --logs '[{"category": "SQLInsights", "enabled": true}, {"category": "AutomaticTuning", "enabled": true}]' \
  --metrics '[{"category": "Basic", "enabled": true}]' \
  --storage-account your-storage-account-id
```

### 2. 自動バックアップの確認

```bash
# バックアップポリシーの確認
az sql db show-backup-long-term-retention-policy \
  --resource-group rg-factory-management-system \
  --server sql-factory-management-XXXXX \
  --database factory-management-db
```

## データベース接続文字列

アプリケーションから接続する際の接続文字列の例：

```
Server=tcp:sql-factory-management-XXXXX.database.windows.net,1433;Initial Catalog=factory-management-db;Persist Security Info=False;User ID=sqladmin;Password=P@ssw0rd2024!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

## トラブルシューティング

### よくある問題と解決方法

1. **接続エラー**
   - ファイアウォールルールの確認
   - 接続文字列の確認
   - ネットワーク接続の確認

2. **パフォーマンス問題**
   - インデックスの確認
   - クエリの最適化
   - DTU使用率の監視

3. **容量不足**
   - データベースサイズの監視
   - 古いデータのアーカイブ
   - サービスレベルの拡張

## コスト最適化

### 1. 自動一時停止の設定（Serverlessの場合）

```bash
# Serverless構成への変更
az sql db update \
  --resource-group rg-factory-management-system \
  --server sql-factory-management-XXXXX \
  --name factory-management-db \
  --edition GeneralPurpose \
  --compute-model Serverless \
  --auto-pause-delay 60
```

### 2. リソース使用状況の監視

定期的にDTU使用率とストレージ使用量を監視し、適切なサービスレベルを選択してください。

## まとめ

この手順書に従って、Azure SQL Database v12上に工場設備管理システム用の包括的なデータベースを構築できます。セキュリティ、パフォーマンス、コスト最適化の観点から適切な設定を行い、運用に備えてください。