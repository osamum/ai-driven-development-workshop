# メンテナンス中設備検索クエリ

## 概要

Azure Cosmos Database に対して、メンテナンス中の設備を検索するためのSQL文集です。

## クエリの目的

**質問**: メンテナンス中のある設備はどれですか？  
**回答**: 以下のクエリを使用してメンテナンス状態の設備を特定できます。

## 基本的な使用方法

### 1. シンプルなメンテナンス設備検索

```sql
SELECT 
    c.equipment_id,
    c.equipment_name,
    c.equipment_type,
    c.location,
    c.status
FROM c
WHERE c.status = "保守中"
```

### 2. Azure CLI での実行

```bash
az cosmosdb sql query \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name Equipment \
  --query-text "SELECT c.equipment_id, c.equipment_name, c.equipment_type, c.location, c.status FROM c WHERE c.status = '保守中'"
```

## 想定される結果例

クエリの実行により、以下のような設備情報が取得されます：

```json
[
  {
    "equipment_id": 3,
    "equipment_name": "プレス機B1",
    "equipment_type": "プレス機",
    "location": "工場棟B-1F-001",
    "status": "保守中"
  }
]
```

## 高度なクエリオプション

### 複数のメンテナンス状態に対応

```bash
az cosmosdb sql query \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name Equipment \
  --query-text "SELECT c.equipment_id, c.equipment_name, c.status FROM c WHERE c.status IN ('保守中', 'メンテナンス', 'メンテナンス中')"
```

### 詳細情報付きの検索

```bash
az cosmosdb sql query \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name Equipment \
  --query-text "SELECT c.equipment_id, c.equipment_name, c.equipment_type, c.manufacturer, c.location, c.status, c.updated_at FROM c WHERE c.status = '保守中' ORDER BY c.updated_at DESC"
```

## 前提条件

1. **Azure Cosmos DB インスタンスが作成済みであること**
   - アカウント名: `factory-cosmosdb-account`
   - リソースグループ: `factory-management-rg`
   - データベース名: `FactoryManagementDB`
   - コンテナー名: `Equipment`

2. **Azure CLI がインストール・ログイン済みであること**

```bash
az login
az account set --subscription "サブスクリプション名"
```

3. **サンプルデータがインポート済みであること**

詳細なセットアップ手順は `azure-cosmos-db-setup-guide.md` を参照してください。

## 注意事項

- Cosmos DB SQL API では大文字小文字が区別されます
- `status` フィールドの正確な値（"保守中", "メンテナンス" など）を事前に確認してください
- パーティション効率のため、必要に応じて `group_id` での絞り込みを追加できます

## 関連ファイル

- `maintenance-equipment-query.sql` - クエリ文の詳細版
- `azure-cosmos-db-setup-guide.md` - Cosmos DB セットアップ手順
- `sample-data/equipment.json` - 設備のサンプルデータ