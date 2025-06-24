#!/bin/bash

# FactoryManagement 簡単セットアップスクリプト
# GitHub Actions Secret の生成を補助します
# 使用方法: ./setup-github-secrets.sh <prefix> <environment>

set -e

if [ $# -lt 2 ]; then
    echo "使用方法: $0 <prefix> <environment>"
    echo "例: $0 mycompany dev"
    exit 1
fi

PREFIX=$1
ENVIRONMENT=$2
RESOURCE_GROUP="${PREFIX}-factory-management-${ENVIRONMENT}-rg"
APP_NAME="${PREFIX}-factory-management-${ENVIRONMENT}"

echo "=== GitHub Actions Secrets セットアップ補助 ==="
echo "プリフィックス: $PREFIX"
echo "環境: $ENVIRONMENT"
echo "=========================================="

# Azure ログイン確認
if ! az account show >/dev/null 2>&1; then
    echo "Azureにログインしてください"
    az login
fi

echo "現在のサブスクリプション:"
az account show --query "{Name:name, SubscriptionId:id}" --output table

# Service Principal作成
echo ""
echo "1. Service Principal を作成しています..."
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "factory-management-github-actions-${PREFIX}-${ENVIRONMENT}" \
    --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID \
    --sdk-auth)

echo ""
echo "📋 GitHub Secrets に設定する値:"
echo "=================================="
echo ""
echo "🔑 Secret名: AZURE_CREDENTIALS"
echo "値:"
echo "$SP_OUTPUT"
echo ""

# Web App が存在する場合、発行プロファイルを取得
if az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP >/dev/null 2>&1; then
    echo "2. 発行プロファイルを取得しています..."
    PUBLISH_PROFILE=$(az webapp deployment list-publishing-profiles \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --xml)
    
    echo "🔑 Secret名: AZURE_WEBAPP_NAME_${ENVIRONMENT^^}"
    echo "値: $APP_NAME"
    echo ""
    echo "🔑 Secret名: AZURE_WEBAPP_PUBLISH_PROFILE_${ENVIRONMENT^^}"
    echo "値:"
    echo "$PUBLISH_PROFILE"
    echo ""
else
    echo "⚠️  Web App '$APP_NAME' がまだ作成されていません。"
    echo "   先に azure-deploy.sh を実行してください。"
    echo ""
    echo "🔑 Secret名: AZURE_WEBAPP_NAME_${ENVIRONMENT^^}"
    echo "値: $APP_NAME"
    echo ""
fi

# SQL パスワードの推奨
echo "🔑 Secret名: SQL_ADMIN_PASSWORD"
echo "値: 強力なパスワードを生成して設定してください"
echo "推奨: $(openssl rand -base64 12 | tr -d '=+/' | cut -c1-12)Aa1!"
echo ""

echo "📝 GitHub Secrets 設定手順:"
echo "1. GitHubリポジトリページを開く"
echo "2. Settings > Secrets and variables > Actions"
echo "3. 'New repository secret' をクリック"
echo "4. 上記の Secret名と値をそれぞれ設定"
echo ""
echo "🚀 設定完了後、GitHub Actions でデプロイを実行できます！"