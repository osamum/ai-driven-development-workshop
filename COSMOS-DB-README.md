# Azure Cosmos DB サンプルデータ

このディレクトリには、工場設備管理システム用のAzure Cosmos DB NoSQL APIサンプルデータが含まれています。

## ファイル構成

### メインファイル
- `azure-cosmos-db-setup-guide.md` - Azure Cosmos DB セットアップの詳細手順書
- `cosmos-db-sample-data.json` - 全サンプルデータを含む統合JSONファイル
- `import-sample-data.sh` - 自動インポート用Bashスクリプト

### サンプルデータファイル (sample-data/)
- `equipment-groups.json` - 設備グループのサンプルデータ
- `equipment.json` - 設備のサンプルデータ
- `sensors.json` - センサーのサンプルデータ
- `sensor-data.json` - センサーデータのサンプル
- `users.json` - ユーザーのサンプルデータ
- `alerts.json` - アラートのサンプルデータ

## クイックスタート

### 1. Azure Cosmos DB インスタンスの作成
詳細な手順は `azure-cosmos-db-setup-guide.md` を参照してください。

### 2. サンプルデータの自動インポート
```bash
# スクリプトに実行権限を付与
chmod +x import-sample-data.sh

# サンプルデータのインポート実行
./import-sample-data.sh <cosmos-account-name> <resource-group-name>

# 例:
./import-sample-data.sh factory-cosmosdb-account factory-management-rg
```

### 3. データの確認
```bash
# Azure CLIでのデータ確認
az cosmosdb sql query \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name Equipment \
  --query-text "SELECT * FROM c"
```

## データモデル概要

### 設備関連
- **EquipmentGroups**: 設備グループ（生産ライン1、生産ライン2、検査設備）
- **Equipment**: 個別設備（CNC加工機、搬送ロボット、プレス機、検査機）
- **Sensors**: 各設備に取り付けられたセンサー（温度、振動、電流、圧力、画像）

### データ関連
- **SensorData**: リアルタイムセンサー測定値
- **Alerts**: 設備異常アラート

### ユーザー関連
- **Users**: システム利用者（設備管理者、保全担当者、製造オペレーター）

## サンプルデータの内容

### 設備データ
- CNC加工機A1 (工場棟A-1F-001)
- 搬送ロボット1 (工場棟A-1F-002)
- プレス機B1 (工場棟B-1F-001) - 現在保守中
- 検査機C1 (工場棟C-1F-001)

### センサーデータ
- 温度センサー: 45.2℃ → 78.9℃（警告レベル）
- 振動センサー: 3.5mm/s → 12.3mm/s（異常レベル）
- 電流センサー: 15.8A（正常）
- 圧力センサー: 25.5MPa（正常）

### アラート例
- 温度異常: CNC加工機A1の温度が正常範囲を超過
- 振動異常: CNC加工機A1の振動が正常範囲を超過

## トラブルシューティング

### よくある問題
1. **jqコマンドが見つからない**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install jq
   
   # macOS
   brew install jq
   ```

2. **Azure CLIでのログインエラー**
   ```bash
   az login
   az account set --subscription "サブスクリプション名"
   ```

3. **パーティションキーエラー**
   - 各コンテナーのパーティションキーが正しく設定されているか確認
   - サンプルデータにパーティションキー値が含まれているか確認

## 参考資料
- [Azure Cosmos DB ドキュメント](https://docs.microsoft.com/ja-jp/azure/cosmos-db/)
- [Azure CLI リファレンス](https://docs.microsoft.com/ja-jp/cli/azure/cosmosdb)
- 既存のデータモデル設計書: `data-model.md`