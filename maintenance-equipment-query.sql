-- ================================================================
-- レポーティング用クエリ: メンテナンス中の設備を取得
-- Query: メンテナンス中のある設備はどれですか?
-- ================================================================

-- 基本クエリ: 保守中の設備を取得
SELECT 
    c.equipment_id,
    c.equipment_name,
    c.equipment_type,
    c.manufacturer,
    c.location,
    c.status,
    c.updated_at
FROM c
WHERE c.status = "保守中"

-- ================================================================
-- 代替クエリ1: メンテナンス状態の設備を取得（複数の状態値に対応）
-- ================================================================

SELECT 
    c.equipment_id,
    c.equipment_name,
    c.equipment_type,
    c.manufacturer,
    c.location,
    c.status,
    c.updated_at
FROM c
WHERE c.status IN ("保守中", "メンテナンス", "メンテナンス中")

-- ================================================================
-- 代替クエリ2: 詳細情報付きでメンテナンス中の設備を取得
-- ================================================================

SELECT 
    c.equipment_id,
    c.equipment_name,
    c.equipment_type,
    c.model_number,
    c.serial_number,
    c.manufacturer,
    c.location,
    c.status,
    c.installation_date,
    c.updated_at
FROM c
WHERE c.status = "保守中"
ORDER BY c.updated_at DESC

-- ================================================================
-- 代替クエリ3: メンテナンス状態を含む部分一致検索
-- ================================================================

SELECT 
    c.equipment_id,
    c.equipment_name,
    c.equipment_type,
    c.location,
    c.status,
    c.updated_at
FROM c
WHERE CONTAINS(c.status, "保守") OR CONTAINS(c.status, "メンテナンス")

-- ================================================================
-- Azure CLI での実行例
-- ================================================================

/*
Azure CLIコマンドでの実行例:

az cosmosdb sql query \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name Equipment \
  --query-text "SELECT c.equipment_id, c.equipment_name, c.equipment_type, c.location, c.status, c.updated_at FROM c WHERE c.status = '保守中'"
*/

-- ================================================================
-- 使用方法とノート
-- ================================================================

/*
このクエリの使用方法:

1. 基本クエリは最もシンプルで、status = "保守中" の設備のみを取得します
2. 代替クエリ1は複数のメンテナンス状態値に対応し、より包括的な結果を返します  
3. 代替クエリ2は詳細情報を含み、最新の更新日順でソートします
4. 代替クエリ3は部分一致検索により、様々なメンテナンス関連状態を検出します

注意事項:
- Cosmos DB SQL APIでは大文字小文字を区別します
- データの status フィールドに格納されている正確な値を確認してから使用してください
- パーティション効率を高めるため、必要に応じて WHERE 句に group_id 条件を追加できます
*/