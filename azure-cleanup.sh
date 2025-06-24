#!/bin/bash

# FactoryManagement Azure リソース削除スクリプト
# 使用方法: ./azure-cleanup.sh <prefix> [environment]
# 例: ./azure-cleanup.sh mycompany dev

set -e

# パラメータチェック
if [ $# -lt 1 ]; then
    echo "使用方法: $0 <prefix> [environment]"
    echo "例: $0 mycompany dev"
    exit 1
fi

PREFIX=$1
ENVIRONMENT=${2:-prod}
RESOURCE_GROUP="${PREFIX}-factory-management-${ENVIRONMENT}-rg"

echo "=== FactoryManagement Azure リソース削除 ==="
echo "プリフィックス: $PREFIX"
echo "環境: $ENVIRONMENT"
echo "削除対象リソースグループ: $RESOURCE_GROUP"
echo "=================================="

# Azure ログイン確認
echo "Azure ログイン状況を確認しています..."
if ! az account show >/dev/null 2>&1; then
    echo "Azureにログインしてください"
    az login
fi

# リソースグループの存在確認
echo "リソースグループの存在を確認しています..."
if ! az group show --name $RESOURCE_GROUP >/dev/null 2>&1; then
    echo "エラー: リソースグループ '$RESOURCE_GROUP' が見つかりません"
    exit 1
fi

# リソース一覧表示
echo "削除対象のリソース一覧:"
az resource list --resource-group $RESOURCE_GROUP --output table

echo ""
echo "⚠️  警告: この操作は元に戻せません！"
echo "リソースグループ '$RESOURCE_GROUP' とその中のすべてのリソースが削除されます。"
echo ""
read -p "続行しますか？ (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "操作がキャンセルされました。"
    exit 0
fi

echo "リソースグループを削除しています: $RESOURCE_GROUP"
echo "この処理には数分かかる場合があります..."

az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait

echo "=== 削除処理を開始しました ==="
echo "削除の進行状況は Azure Portal で確認できます。"
echo "削除が完了するまで数分かかる場合があります。"
echo ""
echo "削除状況の確認コマンド:"
echo "az group show --name $RESOURCE_GROUP"
echo ""
echo "注意: GitHub Actions の Secrets も手動で削除してください:"
echo "  - AZURE_WEBAPP_NAME_${ENVIRONMENT^^}"
echo "  - AZURE_WEBAPP_PUBLISH_PROFILE_${ENVIRONMENT^^}"