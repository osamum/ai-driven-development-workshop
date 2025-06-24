#!/bin/bash

# Azure Cosmos DB サンプルデータ自動インポートスクリプト
# 使用方法: ./import-sample-data.sh <cosmos-account-name> <resource-group-name>

set -e

# パラメーター確認
if [ $# -ne 2 ]; then
    echo "使用方法: $0 <cosmos-account-name> <resource-group-name>"
    echo "例: $0 factory-cosmosdb-account factory-management-rg"
    exit 1
fi

ACCOUNT_NAME=$1
RESOURCE_GROUP=$2
DATABASE_NAME="FactoryManagementDB"

echo "========================================"
echo "Azure Cosmos DB サンプルデータインポート"
echo "========================================"
echo "アカウント名: $ACCOUNT_NAME"
echo "リソースグループ: $RESOURCE_GROUP"
echo "データベース: $DATABASE_NAME"
echo "========================================"

# jqコマンドの確認
if ! command -v jq &> /dev/null; then
    echo "エラー: jqコマンドが見つかりません。以下のコマンドでインストールしてください："
    echo "Ubuntu/Debian: sudo apt-get install jq"
    echo "macOS: brew install jq"
    echo "Windows: choco install jq"
    exit 1
fi

# Azure CLIの確認
if ! command -v az &> /dev/null; then
    echo "エラー: Azure CLIが見つかりません。Azure CLIをインストールしてください。"
    exit 1
fi

# Cosmos DBアカウントの存在確認
echo "Cosmos DBアカウントの存在確認中..."
if ! az cosmosdb show --name "$ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo "エラー: Cosmos DBアカウント '$ACCOUNT_NAME' が見つかりません。"
    exit 1
fi

# データベースの存在確認
echo "データベースの存在確認中..."
if ! az cosmosdb sql database show --account-name "$ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --name "$DATABASE_NAME" &> /dev/null; then
    echo "エラー: データベース '$DATABASE_NAME' が見つかりません。"
    exit 1
fi

# インポート関数
import_data() {
    local container_name=$1
    local file_path=$2
    local partition_key_path=$3
    
    echo "[$container_name] データをインポート中..."
    
    if [ ! -f "$file_path" ]; then
        echo "警告: ファイル '$file_path' が見つかりません。スキップします。"
        return
    fi
    
    # コンテナーの存在確認
    if ! az cosmosdb sql container show --account-name "$ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --database-name "$DATABASE_NAME" --name "$container_name" &> /dev/null; then
        echo "警告: コンテナー '$container_name' が見つかりません。スキップします。"
        return
    fi
    
    local count=0
    local success=0
    local failed=0
    
    # JSONファイルから各レコードを読み込んでインサート
    while IFS= read -r item; do
        if [ -n "$item" ] && [ "$item" != "null" ]; then
            count=$((count + 1))
            
            # パーティションキー値を抽出
            local partition_value
            partition_value=$(echo "$item" | jq -r "$partition_key_path")
            
            if [ "$partition_value" = "null" ]; then
                echo "  エラー: パーティションキー値が見つかりません (レコード #$count)"
                failed=$((failed + 1))
                continue
            fi
            
            # アイテムをインサート
            if az cosmosdb sql item create \
                --account-name "$ACCOUNT_NAME" \
                --resource-group "$RESOURCE_GROUP" \
                --database-name "$DATABASE_NAME" \
                --container-name "$container_name" \
                --body "$item" \
                --partition-key-value "$partition_value" &> /dev/null; then
                success=$((success + 1))
                echo "  ✓ レコード #$count インサート成功"
            else
                failed=$((failed + 1))
                echo "  ✗ レコード #$count インサート失敗"
            fi
        fi
    done < <(jq -c '.[]' "$file_path")
    
    echo "[$container_name] 完了: 成功=$success, 失敗=$failed"
}

# データインポート実行
echo ""
echo "データインポートを開始します..."
echo ""

# Equipment Groups
import_data "EquipmentGroups" "sample-data/equipment-groups.json" ".group_id"

# Equipment
import_data "Equipment" "sample-data/equipment.json" ".group_id"

# Sensors
import_data "Sensors" "sample-data/sensors.json" ".equipment_id"

# Sensor Data
import_data "SensorData" "sample-data/sensor-data.json" ".sensor_id"

# Users
import_data "Users" "sample-data/users.json" ".role_id"

# Alerts
import_data "Alerts" "sample-data/alerts.json" ".equipment_id"

echo ""
echo "========================================"
echo "インポート処理完了"
echo "========================================"

# データ確認のためのクエリ例を表示
echo ""
echo "データ確認用のクエリ例:"
echo "az cosmosdb sql query --account-name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP --database-name $DATABASE_NAME --container-name Equipment --query-text \"SELECT * FROM c\""
echo ""
echo "Azure Portalでの確認:"
echo "https://portal.azure.com → Cosmos DB → $ACCOUNT_NAME → データエクスプローラー"