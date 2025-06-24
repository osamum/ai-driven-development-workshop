#!/bin/bash

# メンテナンス中設備検索のデータ検証スクリプト

echo "=================================================="
echo "メンテナンス中設備の検証"
echo "=================================================="

# サンプルデータから保守中の設備を検索
echo "サンプルデータ内の保守中設備:"
echo "----------------------------------------"

if [ -f "sample-data/equipment.json" ]; then
    echo "equipment.json をチェック中..."
    cat sample-data/equipment.json | jq '.[] | select(.status == "保守中") | {equipment_id, equipment_name, equipment_type, location, status}'
    echo ""
fi

if [ -f "sample-data/02_equipment.json" ]; then
    echo "02_equipment.json をチェック中..."
    cat sample-data/02_equipment.json | jq '.[] | select(.status == "保守中" or .status == "メンテナンス" or .status == "メンテナンス中") | {equipment_id, equipment_name, equipment_type, location, status}'
    echo ""
fi

# 実際のCosmosDBに対するクエリテスト（環境に応じて調整）
echo "=========================================="
echo "Cosmos DB クエリ実行例"
echo "=========================================="

echo "以下のコマンドで実際のCosmosDBに対してクエリを実行できます:"
echo ""
echo "az cosmosdb sql query \\"
echo "  --account-name factory-cosmosdb-account \\"
echo "  --resource-group factory-management-rg \\"
echo "  --database-name FactoryManagementDB \\"
echo "  --container-name Equipment \\"
echo "  --query-text \"SELECT c.equipment_id, c.equipment_name, c.equipment_type, c.location, c.status FROM c WHERE c.status = '保守中'\""
echo ""

echo "クエリが正常に動作することを確認するため、上記コマンドを実行してください。"