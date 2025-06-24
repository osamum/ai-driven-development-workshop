# Azure サーバーレスアーキテクチャ実装手順書
## 工場設備管理システム用コスト最適化実装ガイド

## 概要

本手順書では、工場設備管理システムのサーバーレス・スケーラブルアーキテクチャを Azure 上に実装するための詳細な手順を記載します。コスト効率性を重視し、Azure CLI を使用した自動化可能な構築手順を提供します。

## 前提条件

### 必要なツール
```bash
# Azure CLI のインストール確認
az --version

# Azure CLI がインストールされていない場合
# Windows
# Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# macOS  
# brew install azure-cli

# Linux (Ubuntu)
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Azure ログイン
```bash
# Azure アカウントにログイン
az login

# サブスクリプション確認
az account list --output table

# 使用するサブスクリプションを設定
az account set --subscription "<サブスクリプション名またはID>"
```

## 1. 基盤リソースの作成

### 1.1 リソースグループの作成
```bash
# 環境変数の設定
export RESOURCE_GROUP="rg-factory-management-system"
export LOCATION="japaneast"
export PROJECT_NAME="factory-mgmt"

# リソースグループ作成
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags project=$PROJECT_NAME environment=production
```

### 1.2 Azure Active Directory B2C の設定
```bash
# B2C テナント用のドメイン名設定
export B2C_TENANT_NAME="${PROJECT_NAME}b2c"

# B2C テナント作成（Azure portal での手動作成が必要）
echo "B2C テナントは Azure portal で手動作成してください:"
echo "https://portal.azure.com/#create/Microsoft.AzureActiveDirectoryB2C"
echo "テナント名: ${B2C_TENANT_NAME}.onmicrosoft.com"
```

## 2. データ層の構築

### 2.1 Azure Cosmos DB (Serverless) の作成
```bash
# Cosmos DB アカウント名（グローバルで一意である必要があります）
export COSMOS_ACCOUNT_NAME="${PROJECT_NAME}-cosmos-$(date +%Y%m%d%H%M)"

# Cosmos DB アカウント作成（Serverless モード）
az cosmosdb create \
  --name $COSMOS_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --locations regionName=$LOCATION \
  --capabilities EnableServerless \
  --default-consistency-level "Session" \
  --enable-automatic-failover true

# データベースの作成
az cosmosdb sql database create \
  --account-name $COSMOS_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --name "FactoryManagementDB"

# コンテナーの作成
az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --database-name "FactoryManagementDB" \
  --name "Devices" \
  --partition-key-path "/deviceId"

az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --database-name "FactoryManagementDB" \
  --name "SensorData" \
  --partition-key-path "/deviceId"

az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --database-name "FactoryManagementDB" \
  --name "MaintenanceRecords" \
  --partition-key-path "/deviceId"
```

### 2.2 Azure Data Lake Storage Gen2 の作成
```bash
# ストレージアカウント名（グローバルで一意である必要があります）
export STORAGE_ACCOUNT_NAME="${PROJECT_NAME}datalake$(date +%Y%m%d%H%M)"

# Data Lake Storage Gen2 の作成
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --enable-hierarchical-namespace true \
  --access-tier Cool

# ライフサイクル管理ポリシーの設定（コスト最適化）
cat > lifecycle-policy.json << EOF
{
  "rules": [
    {
      "name": "ArchiveOldData",
      "enabled": true,
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"]
        },
        "actions": {
          "baseBlob": {
            "tierToCool": {
              "daysAfterModificationGreaterThan": 30
            },
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 180
            }
          }
        }
      }
    }
  ]
}
EOF

az storage account management-policy create \
  --account-name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --policy @lifecycle-policy.json
```

### 2.3 Azure Redis Cache の作成
```bash
# Redis Cache 名
export REDIS_CACHE_NAME="${PROJECT_NAME}-redis-cache"

# Redis Cache 作成（Basic tier - コスト効率重視）
az redis create \
  --name $REDIS_CACHE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Basic \
  --vm-size c0 \
  --enable-non-ssl-port false
```

## 3. IoT・データ処理層の構築

### 3.1 Azure IoT Hub の作成
```bash
# IoT Hub 名
export IOT_HUB_NAME="${PROJECT_NAME}-iot-hub"

# IoT Hub 作成（S1 tier - スケーラビリティ重視）
az iot hub create \
  --name $IOT_HUB_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku S1 \
  --unit 1

# IoT Hub への接続文字列取得
az iot hub connection-string show \
  --hub-name $IOT_HUB_NAME \
  --resource-group $RESOURCE_GROUP
```

### 3.2 Azure Event Hubs の作成
```bash
# Event Hubs 名前空間
export EVENT_HUB_NAMESPACE="${PROJECT_NAME}-eventhub-ns"

# Event Hubs 名前空間作成（Standard tier）
az eventhubs namespace create \
  --name $EVENT_HUB_NAMESPACE \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard \
  --enable-auto-inflate true \
  --maximum-throughput-units 10

# Event Hub の作成
az eventhubs eventhub create \
  --name "sensor-data-hub" \
  --namespace-name $EVENT_HUB_NAMESPACE \
  --resource-group $RESOURCE_GROUP \
  --partition-count 4 \
  --message-retention 7
```

### 3.3 Azure Stream Analytics の作成
```bash
# Stream Analytics ジョブ名
export STREAM_ANALYTICS_JOB="${PROJECT_NAME}-stream-analytics"

# Stream Analytics ジョブ作成
az stream-analytics job create \
  --name $STREAM_ANALYTICS_JOB \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --output-error-policy "Drop" \
  --events-outof-order-policy "Adjust" \
  --events-outof-order-max-delay 5 \
  --events-late-arrival-max-delay 60 \
  --data-locale "ja-JP"
```

## 4. サーバーレス アプリケーション層の構築

### 4.1 Azure Functions アプリの作成
```bash
# Function App 用ストレージアカウント
export FUNC_STORAGE_ACCOUNT="${PROJECT_NAME}funcsto$(date +%Y%m%d%H%M)"

# Function App 用ストレージ作成
az storage account create \
  --name $FUNC_STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2

# Application Insights の作成
export APP_INSIGHTS_NAME="${PROJECT_NAME}-app-insights"

az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --kind web

# Function App の作成（Premium Plan - サーバーレス with VNet統合）
export FUNCTION_APP_NAME="${PROJECT_NAME}-functions"

az functionapp create \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --storage-account $FUNC_STORAGE_ACCOUNT \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --os-type Linux \
  --app-insights $APP_INSIGHTS_NAME

# Function App の設定
az functionapp config appsettings set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    "COSMOS_DB_CONNECTION_STRING=$(az cosmosdb keys list --name $COSMOS_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --type connection-strings --query 'connectionStrings[0].connectionString' -o tsv)" \
    "IOT_HUB_CONNECTION_STRING=$(az iot hub connection-string show --hub-name $IOT_HUB_NAME --resource-group $RESOURCE_GROUP --query 'connectionString' -o tsv)" \
    "REDIS_CONNECTION_STRING=$(az redis list-keys --name $REDIS_CACHE_NAME --resource-group $RESOURCE_GROUP --query 'primaryKey' -o tsv)"
```

### 4.2 Azure Logic Apps の作成
```bash
# Logic App 名
export LOGIC_APP_NAME="${PROJECT_NAME}-logic-app"

# Logic App の作成（Consumption プラン - サーバーレス）
az logic workflow create \
  --name $LOGIC_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --definition '{
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "triggers": {},
    "actions": {}
  }'
```

## 5. API管理・セキュリティ層の構築

### 5.1 Azure API Management の作成
```bash
# API Management 名
export APIM_NAME="${PROJECT_NAME}-apim"

# API Management 作成（Consumption tier - サーバーレス）
az apim create \
  --name $APIM_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --publisher-email "admin@company.com" \
  --publisher-name "Factory Management System" \
  --sku-name Consumption \
  --enable-managed-identity true
```

### 5.2 Azure Application Gateway の作成
```bash
# Virtual Network の作成
export VNET_NAME="${PROJECT_NAME}-vnet"

az network vnet create \
  --name $VNET_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16 \
  --subnet-name gateway-subnet \
  --subnet-prefix 10.0.1.0/24

# パブリック IP の作成
export PUBLIC_IP_NAME="${PROJECT_NAME}-public-ip"

az network public-ip create \
  --name $PUBLIC_IP_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --allocation-method Static \
  --sku Standard

# Application Gateway の作成
export APP_GATEWAY_NAME="${PROJECT_NAME}-app-gateway"

az network application-gateway create \
  --name $APP_GATEWAY_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --vnet-name $VNET_NAME \
  --subnet gateway-subnet \
  --public-ip-address $PUBLIC_IP_NAME \
  --sku Standard_v2 \
  --capacity 2 \
  --http-settings-cookie-based-affinity Disabled \
  --http-settings-protocol Http \
  --http-settings-port 80
```

## 6. AI・機械学習サービスの構築

### 6.1 Azure Machine Learning ワークスペースの作成
```bash
# Azure ML ワークスペース名
export AML_WORKSPACE_NAME="${PROJECT_NAME}-ml-workspace"

# Azure ML ワークスペース作成
az ml workspace create \
  --name $AML_WORKSPACE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION
```

### 6.2 Azure Cognitive Services の作成
```bash
# Cognitive Services アカウント名
export COGNITIVE_SERVICES_NAME="${PROJECT_NAME}-cognitive-services"

# Anomaly Detector サービス作成
az cognitiveservices account create \
  --name $COGNITIVE_SERVICES_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --kind AnomalyDetector \
  --sku S0
```

## 7. 監視・運用の設定

### 7.1 Azure Monitor の設定
```bash
# Log Analytics ワークスペース作成
export LOG_ANALYTICS_WORKSPACE="${PROJECT_NAME}-log-analytics"

az monitor log-analytics workspace create \
  --workspace-name $LOG_ANALYTICS_WORKSPACE \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --retention-time 30

# Application Insights を Log Analytics に接続
az monitor app-insights component update \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --workspace $(az monitor log-analytics workspace show --workspace-name $LOG_ANALYTICS_WORKSPACE --resource-group $RESOURCE_GROUP --query 'id' -o tsv)
```

### 7.2 コスト管理の設定
```bash
# 予算アラートの作成（月額10万円の例）
az consumption budget create \
  --resource-group $RESOURCE_GROUP \
  --budget-name "${PROJECT_NAME}-monthly-budget" \
  --amount 100000 \
  --category Cost \
  --time-grain Monthly \
  --start-date $(date +%Y-%m-01) \
  --end-date $(date -d "1 year" +%Y-%m-01) \
  --notifications '[{
    "enabled": true,
    "operator": "GreaterThan",
    "threshold": 80,
    "contactEmails": ["admin@company.com"],
    "contactRoles": [],
    "contactGroups": [],
    "thresholdType": "Actual"
  }]'
```

## 8. フロントエンド展開

### 8.1 Azure Static Web Apps の作成
```bash
# Static Web App 名
export STATIC_WEB_APP_NAME="${PROJECT_NAME}-webapp"

# Static Web App 作成（GitHub統合）
az staticwebapp create \
  --name $STATIC_WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --source "https://github.com/your-org/your-repo" \
  --branch main \
  --app-location "/" \
  --api-location "api" \
  --output-location "dist"
```

## 9. セキュリティ設定

### 9.1 Key Vault の作成
```bash
# Key Vault 名
export KEY_VAULT_NAME="${PROJECT_NAME}-kv-$(date +%Y%m%d%H%M)"

# Key Vault 作成
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enable-soft-delete true \
  --retention-days 7

# Function App にKey Vault アクセス権付与
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --object-id $(az functionapp identity show --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP --query 'principalId' -o tsv) \
  --secret-permissions get list

# 接続文字列をKey Vaultに格納
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "CosmosDbConnectionString" \
  --value "$(az cosmosdb keys list --name $COSMOS_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --type connection-strings --query 'connectionStrings[0].connectionString' -o tsv)"
```

## 10. 動作確認とテスト

### 10.1 基本動作確認
```bash
# リソース一覧の確認
az resource list --resource-group $RESOURCE_GROUP --output table

# Function App の状態確認
az functionapp show --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP --query 'state' -o tsv

# Cosmos DB の接続確認
az cosmosdb sql database list --account-name $COSMOS_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --output table
```

### 10.2 コスト確認
```bash
# 現在のコスト確認
az consumption usage list --start-date $(date -d "1 month ago" +%Y-%m-%d) --end-date $(date +%Y-%m-%d) --output table

# 予算の状態確認
az consumption budget list --resource-group $RESOURCE_GROUP --output table
```

## クリーンアップ手順

### 全リソースの削除
```bash
# 注意: この操作により、すべてのデータが削除されます
echo "警告: この操作により、リソースグループ内のすべてのリソースが削除されます。"
echo "続行するには 'yes' と入力してください:"
read confirmation

if [ "$confirmation" = "yes" ]; then
  az group delete --name $RESOURCE_GROUP --yes --no-wait
  echo "リソースグループの削除を開始しました。完了まで数分かかる場合があります。"
else
  echo "削除操作をキャンセルしました。"
fi
```

## 運用時の注意事項

### コスト最適化
1. **未使用リソースの監視**: Azure Advisor を定期的に確認
2. **自動停止の設定**: 開発環境では夜間・週末の自動停止を設定
3. **予約インスタンス**: 長期使用が確実なリソースは予約購入を検討

### セキュリティ
1. **定期的なキーローテーション**: Key Vault内のシークレットを定期更新
2. **アクセス制御**: 最小権限の原則に基づくロール設定
3. **監査ログ**: Azure Monitor での操作ログ監視

### パフォーマンス
1. **スケーリング設定**: ピーク時間に合わせた自動スケール設定
2. **キャッシュ戦略**: Redisキャッシュの効果的な活用
3. **データベース最適化**: Cosmos DBのパーティション戦略の見直し

この実装手順により、コスト効率性とスケーラビリティを両立したサーバーレス工場設備管理システムをAzure上に構築することができます。