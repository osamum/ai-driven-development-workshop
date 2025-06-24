# 工場設備管理システム - データベースセットアップガイド

## 概要

このディレクトリには、工場設備管理システム用のAzure SQL Databaseのセットアップとサンプルデータ投入に必要なすべてのファイルが含まれています。

## ファイル構成

### ドキュメント
- `azure-sql-setup.md` - Azure SQL Databaseの詳細セットアップ手順書
- `data-model.md` - データモデル設計書
- `database-setup-guide.md` - このファイル（データベースセットアップガイド）

### SQLスクリプト
- `create-tables.sql` - テーブル作成DDLスクリプト
- `sample-data.sql` - サンプルデータ挿入DMLスクリプト
- `data-validation.sql` - データ検証・確認用クエリ

## クイックスタート

### 1. 必要な準備

```bash
# Azure CLIのインストール確認
az --version

# Azureにログイン
az login
```

### 2. Azure SQL Databaseの作成

詳細手順は `azure-sql-setup.md` を参照してください。

```bash
# リソースグループ作成
az group create --name factory-management-rg --location japaneast

# SQL Server作成
az sql server create \
    --name factory-management-server \
    --resource-group factory-management-rg \
    --location japaneast \
    --admin-user sqladmin \
    --admin-password "P@ssw0rd123!"

# データベース作成
az sql db create \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --name FactoryManagementDB \
    --service-objective S0
```

### 3. テーブル作成

```bash
# テーブル作成スクリプトの実行
sqlcmd -S factory-management-server.database.windows.net \
        -d FactoryManagementDB \
        -U sqladmin \
        -P "P@ssw0rd123!" \
        -i create-tables.sql
```

### 4. サンプルデータ投入

```bash
# サンプルデータ投入スクリプトの実行
sqlcmd -S factory-management-server.database.windows.net \
        -d FactoryManagementDB \
        -U sqladmin \
        -P "P@ssw0rd123!" \
        -i sample-data.sql
```

### 5. データ検証

```bash
# データ検証スクリプトの実行
sqlcmd -S factory-management-server.database.windows.net \
        -d FactoryManagementDB \
        -U sqladmin \
        -P "P@ssw0rd123!" \
        -i data-validation.sql
```

## サンプルデータの内容

投入されるサンプルデータには以下が含まれます：

### マスターデータ
- **設備グループ**: 5グループ（製造ライン1/2、品質管理、電力システム、空調システム）
- **設備**: 8台の設備（プレス機、射出成型機、コンベア、検査機など）
- **センサー**: 15個のセンサー（温度、振動、圧力、流量など）
- **ユーザー**: 8名のユーザー（管理者、設備管理者、保全担当者など）
- **部品**: 8種類の部品（フィルター、ベアリング、センサーなど）

### トランザクションデータ
- **センサーデータ**: 過去1週間分の時系列データ
- **アラート**: 3件のアクティブなアラート
- **保全計画**: 今後の保全作業計画
- **KPI指標**: 設備パフォーマンス指標
- **AI予測結果**: 故障予測結果

## データベース構造

### 主要エンティティ
1. **設備関連**: EquipmentGroup, Equipment, Sensor, SensorData, EquipmentStatus
2. **ユーザー関連**: UserRole, User
3. **アラート関連**: AlertType, Alert, AlertAction
4. **保全関連**: MaintenanceType, MaintenancePlan, MaintenanceWork, Part
5. **分析・レポート**: AnalyticsReport, KPIMetrics
6. **通知**: NotificationType, Notification
7. **AI/ML**: PredictiveModel, PredictionResult
8. **外部システム**: ExternalSystem, DataSyncLog

### 主要な関係性
- 設備 → センサー → センサーデータ（1対多）
- 設備 → アラート（1対多）
- 設備 → 保全計画（1対多）
- ユーザー → アラート（担当者として）
- ユーザー → 保全作業（実施者として）

## パフォーマンス最適化

作成されるインデックス：
- センサーデータの時系列検索用インデックス
- 設備状態の時系列検索用インデックス
- アラートの状態・日時検索用インデックス
- KPI指標の設備・時刻検索用インデックス

## セキュリティ設定

### 推奨設定
- Transparent Data Encryption (TDE) の有効化
- Advanced Data Security の有効化
- ファイアウォール規則の適切な設定
- Azure Active Directory 統合認証

### アクセス制御
サンプルデータには以下の役割が定義されています：
- システム管理者：全権限
- 設備管理者：設備監視・管理権限
- 保全担当者：保全作業権限
- 品質管理者：品質データ確認・分析権限
- オペレーター：基本監視権限

## トラブルシューティング

### よくある問題

1. **接続エラー**
   - ファイアウォール設定を確認
   - 接続文字列の確認

2. **認証エラー**
   - ユーザー名・パスワードの確認
   - SQL Server認証が有効になっているか確認

3. **権限エラー**
   - データベース作成権限があるか確認
   - 適切なロールが割り当てられているか確認

### ログの確認
```bash
# Azure Activity Logの確認
az monitor activity-log list --resource-group factory-management-rg

# SQL Database メトリクス確認
az sql db show \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --name FactoryManagementDB
```

## 本番環境への適用

### 注意事項
1. **パスワード**: 本番環境では複雑なパスワードを使用
2. **ファイアウォール**: 必要最小限のIPアドレスのみ許可
3. **バックアップ**: 定期バックアップの設定
4. **監視**: Application Insights等の監視設定

### 推奨設定
- Service Objective: 本番負荷に応じてS2以上を推奨
- Geo-replication: 災害復旧のため副次リージョンへの複製
- Long-term backup retention: 長期バックアップ保持ポリシー

## サポート

問題が発生した場合は、以下を確認してください：
1. `data-validation.sql` の実行結果
2. Azure Portal での SQL Database の状態
3. Activity Log でのエラーメッセージ

## ライセンス

このプロジェクトのサンプルデータは開発・テスト目的でのみ使用してください。
本番データとは異なる、架空のデータが含まれています。