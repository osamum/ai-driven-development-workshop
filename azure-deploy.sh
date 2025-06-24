#!/bin/bash

# FactoryManagement Azure デプロイメントスクリプト
# 使用方法: ./azure-deploy.sh <prefix> [environment]
# 例: ./azure-deploy.sh mycompany dev

set -e

# パラメータチェック
if [ $# -lt 1 ]; then
    echo "使用方法: $0 <prefix> [environment]"
    echo "例: $0 mycompany dev"
    exit 1
fi

PREFIX=$1
ENVIRONMENT=${2:-prod}
LOCATION="japaneast"
RESOURCE_GROUP="${PREFIX}-factory-management-${ENVIRONMENT}-rg"
APP_NAME="${PREFIX}-factory-management-${ENVIRONMENT}"
STORAGE_ACCOUNT="${PREFIX}factorystorage${ENVIRONMENT}"
KEYVAULT_NAME="${PREFIX}-factory-kv-${ENVIRONMENT}"
APPINSIGHTS_NAME="${PREFIX}-factory-insights-${ENVIRONMENT}"

echo "=== FactoryManagement Azure デプロイメント開始 ==="
echo "プリフィックス: $PREFIX"
echo "環境: $ENVIRONMENT"
echo "リソースグループ: $RESOURCE_GROUP"
echo "=================================="

# Azure ログイン確認
echo "Azure ログイン状況を確認しています..."
if ! az account show >/dev/null 2>&1; then
    echo "Azureにログインしてください"
    az login
fi

# 現在のサブスクリプション情報表示
echo "現在のサブスクリプション:"
az account show --query "{Name:name, SubscriptionId:id}" --output table

# リソースグループの作成
echo "リソースグループを作成しています: $RESOURCE_GROUP"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --tags project=factory-management environment=$ENVIRONMENT prefix=$PREFIX

# App Service Plan の作成
echo "App Service Plan を作成しています..."
az appservice plan create \
    --name "${APP_NAME}-plan" \
    --resource-group $RESOURCE_GROUP \
    --sku B1 \
    --is-linux

# Web App の作成
echo "Web App を作成しています..."
az webapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan "${APP_NAME}-plan" \
    --runtime "NODE|18-lts" \
    --startup-file "npm start"

# ストレージアカウントの作成
echo "ストレージアカウントを作成しています..."
# ストレージアカウント名は小文字のみで24文字以内
STORAGE_ACCOUNT_CLEAN=$(echo "${PREFIX}factory${ENVIRONMENT}" | tr '[:upper:]' '[:lower:]' | head -c 24)
az storage account create \
    --name $STORAGE_ACCOUNT_CLEAN \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2

# Key Vault の作成
echo "Key Vault を作成しています..."
az keyvault create \
    --name $KEYVAULT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku standard

# Application Insights の作成
echo "Application Insights を作成しています..."
az monitor app-insights component create \
    --app $APPINSIGHTS_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --kind web \
    --application-type web

# Application Insights のインストルメンテーションキーを取得
APPINSIGHTS_KEY=$(az monitor app-insights component show \
    --app $APPINSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey \
    --output tsv)

echo "Application Insights インストルメンテーションキー: $APPINSIGHTS_KEY"

# Web App の環境変数設定
echo "Web App の環境変数を設定しています..."
az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        NODE_ENV=$ENVIRONMENT \
        APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_KEY \
        WEBSITE_NODE_DEFAULT_VERSION=18.17.0

# Web App のデプロイ設定
echo "GitHub Actions デプロイ用の発行プロファイルを生成しています..."
az webapp deployment list-publishing-profiles \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --xml

echo "=== デプロイメント完了 ==="
echo "Web App URL: https://${APP_NAME}.azurewebsites.net"
echo "リソースグループ: $RESOURCE_GROUP"
echo "ストレージアカウント: $STORAGE_ACCOUNT_CLEAN"
echo "Key Vault: $KEYVAULT_NAME"
echo "Application Insights: $APPINSIGHTS_NAME"
echo "=================================="

echo "次のステップ:"
echo "1. GitHub Secretsに発行プロファイルを設定してください"
echo "2. Cosmos DBとSQL Databaseを設定してください（既存のスクリプトを使用）"
echo "3. GitHub Actionsワークフローを実行してください"