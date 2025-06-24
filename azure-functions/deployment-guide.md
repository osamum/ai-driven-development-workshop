# Azure Functions デプロイメント手順書

## 概要

工場設備管理システム用Azure Functions APIのデプロイメント手順を説明します。

## 前提条件

### 必要なツール
```bash
# Azure CLI のインストール
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure Functions Core Tools のインストール
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# .NET 8 SDK のインストール
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

# Python 3.11 のインストール
sudo apt-get install -y python3.11 python3.11-venv python3.11-dev

# Node.js v20 のインストール
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## Azure リソースの作成

### 1. Azureにログイン
```bash
az login
```

### 2. リソースグループの作成
```bash
az group create \
  --name rg-factory-management-functions \
  --location japaneast
```

### 3. ストレージアカウントの作成
```bash
az storage account create \
  --name stfactorymanagementXXXXX \
  --resource-group rg-factory-management-functions \
  --location japaneast \
  --sku Standard_LRS
```

### 4. Function App の作成

#### C# Functions App
```bash
az functionapp create \
  --resource-group rg-factory-management-functions \
  --consumption-plan-location japaneast \
  --runtime dotnet-isolated \
  --runtime-version 8 \
  --functions-version 4 \
  --name factory-csharp-functions-XXXXX \
  --storage-account stfactorymanagementXXXXX
```

#### Python Functions App
```bash
az functionapp create \
  --resource-group rg-factory-management-functions \
  --consumption-plan-location japaneast \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name factory-python-functions-XXXXX \
  --storage-account stfactorymanagementXXXXX
```

#### Node.js Functions App
```bash
az functionapp create \
  --resource-group rg-factory-management-functions \
  --consumption-plan-location japaneast \
  --runtime node \
  --runtime-version 20 \
  --functions-version 4 \
  --name factory-nodejs-functions-XXXXX \
  --storage-account stfactorymanagementXXXXX
```

## デプロイメント手順

### C# Functions のデプロイ
```bash
cd azure-functions/csharp-functions

# ビルド
dotnet build --configuration Release

# デプロイ
func azure functionapp publish factory-csharp-functions-XXXXX
```

### Python Functions のデプロイ
```bash
cd azure-functions/python-functions

# 依存関係のインストール
pip install -r requirements.txt

# デプロイ
func azure functionapp publish factory-python-functions-XXXXX
```

### Node.js Functions のデプロイ
```bash
cd azure-functions/nodejs-functions

# 依存関係のインストール
npm install

# デプロイ
func azure functionapp publish factory-nodejs-functions-XXXXX
```

## CORS設定

Vue.jsフロントエンドからのアクセスを許可するため、CORS設定を行います：

```bash
# C# Functions App の CORS 設定
az functionapp cors add \
  --resource-group rg-factory-management-functions \
  --name factory-csharp-functions-XXXXX \
  --allowed-origins "http://localhost:8080" "https://yourdomain.com"

# Python Functions App の CORS 設定
az functionapp cors add \
  --resource-group rg-factory-management-functions \
  --name factory-python-functions-XXXXX \
  --allowed-origins "http://localhost:8080" "https://yourdomain.com"

# Node.js Functions App の CORS 設定
az functionapp cors add \
  --resource-group rg-factory-management-functions \
  --name factory-nodejs-functions-XXXXX \
  --allowed-origins "http://localhost:8080" "https://yourdomain.com"
```

## 環境変数の設定

必要に応じて環境変数を設定します：

```bash
# アプリケーション設定の追加
az functionapp config appsettings set \
  --resource-group rg-factory-management-functions \
  --name factory-csharp-functions-XXXXX \
  --settings "SAMPLE_DATA_PATH=/home/site/wwwroot/sample-data"
```

## 動作確認

### デプロイ完了後のテスト
```bash
# C# Functions の動作確認
curl "https://factory-csharp-functions-XXXXX.azurewebsites.net/api/equipment-groups"

# Python Functions の動作確認
curl "https://factory-python-functions-XXXXX.azurewebsites.net/api/analytics/equipment-efficiency"

# Node.js Functions の動作確認
curl "https://factory-nodejs-functions-XXXXX.azurewebsites.net/api/notifications/realtime"
```

## 監視設定

### Application Insights の有効化
```bash
# Application Insights リソースの作成
az monitor app-insights component create \
  --app factory-management-insights \
  --location japaneast \
  --resource-group rg-factory-management-functions

# Function Apps に Application Insights を設定
APPINSIGHTS_KEY=$(az monitor app-insights component show \
  --app factory-management-insights \
  --resource-group rg-factory-management-functions \
  --query instrumentationKey -o tsv)

az functionapp config appsettings set \
  --resource-group rg-factory-management-functions \
  --name factory-csharp-functions-XXXXX \
  --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_KEY"
```

## コスト最適化

### 自動スケーリング設定
```bash
# Function App の自動スケーリング制限設定
az functionapp config set \
  --resource-group rg-factory-management-functions \
  --name factory-csharp-functions-XXXXX \
  --functionapp-scale-limit 10
```

## トラブルシューティング

### よくある問題と解決方法

1. **デプロイエラー**
   - Function App名の重複を確認
   - リソースグループの存在を確認
   - Azure CLIのログイン状態を確認

2. **CORS エラー**
   - 許可されたオリジンにフロントエンドのURLが含まれていることを確認
   - プリフライトリクエストが正しく処理されていることを確認

3. **Function実行エラー**
   - Application Insightsログを確認
   - 環境変数が正しく設定されていることを確認

## セキュリティ考慮事項

### 認証設定（本番環境用）
```bash
# Azure AD認証の有効化
az functionapp auth update \
  --resource-group rg-factory-management-functions \
  --name factory-csharp-functions-XXXXX \
  --enabled true \
  --action LoginWithAzureActiveDirectory
```

### ネットワークセキュリティ
```bash
# VNet統合の設定（必要に応じて）
az functionapp vnet-integration add \
  --resource-group rg-factory-management-functions \
  --name factory-csharp-functions-XXXXX \
  --vnet MyVNet \
  --subnet MySubnet
```

## 運用保守

### 定期的なメンテナンス項目

1. **パフォーマンス監視**
   - Application Insightsメトリクスの確認
   - 実行時間とメモリ使用量の監視

2. **コスト監視**
   - Azure Cost Managementでの定期的な確認
   - 実行回数とリソース使用量の分析

3. **セキュリティ更新**
   - ランタイムバージョンの定期的な更新
   - 依存パッケージの脆弱性チェック