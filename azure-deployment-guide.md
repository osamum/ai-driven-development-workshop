# FactoryManagement Azure デプロイメント手順書

## 概要

FactoryManagementアプリケーションをMicrosoft Azureにデプロイするための詳細な手順を説明します。このシステムはVue.jsベースの工場設備管理システムで、Azure App Service、Cosmos DB、SQL Database、Storage Account、Key Vault、Application Insightsを使用します。

## 前提条件

- Azureアカウントが作成済みであること
- Azure CLI がインストールされていること
- GitHubアカウントとリポジトリへのアクセス権があること
- 適切なAzureサブスクリプションの権限（Contributor以上）があること

### Azure CLI のインストール

#### Windows
```bash
# PowerShellを管理者権限で実行
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
Remove-Item .\AzureCLI.msi
```

#### macOS
```bash
brew update && brew install azure-cli
```

#### Linux (Ubuntu/Debian)
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## デプロイメント手順

### 手順1: Azure にログイン

```bash
# Azureにログイン
az login

# サブスクリプション一覧を確認
az account list --output table

# 使用するサブスクリプションを設定（必要に応じて）
az account set --subscription "your-subscription-id"
```

### 手順2: リソース名のプリフィックスを決定

リソース名の重複を避けるため、会社名や部署名などの一意のプリフィックスを決定します。
例: `mycompany`, `factory01`, `team-a` など

**注意事項:**
- プリフィックスは小文字と数字のみ使用
- 3文字以上、10文字以内推奨
- 全世界で一意である必要があるリソース（ストレージアカウントなど）があるため、具体的な名前を推奨

### 手順3: 手動デプロイ（初回セットアップ）

#### 3.1 基本インフラストラクチャのデプロイ

```bash
# リポジトリをクローン（まだの場合）
git clone https://github.com/osamum/ai-driven-development-workshop.git
cd ai-driven-development-workshop

# デプロイスクリプトを実行
chmod +x azure-deploy.sh
./azure-deploy.sh <your-prefix> dev

# 例
./azure-deploy.sh mycompany dev
```

#### 3.2 Cosmos DB のセットアップ

```bash
# Cosmos DB 作成スクリプトの実行（既存のスクリプトを利用）
# 詳細は azure-cosmos-db-setup-guide.md を参照

RESOURCE_GROUP="mycompany-factory-management-dev-rg"
COSMOSDB_ACCOUNT="mycompany-factory-cosmosdb-dev"

# Cosmos DB アカウントの作成
az cosmosdb create \
  --name $COSMOSDB_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --kind GlobalDocumentDB \
  --locations regionName=japaneast failoverPriority=0 isZoneRedundant=False \
  --default-consistency-level "Session" \
  --enable-automatic-failover true

# データベースの作成
az cosmosdb sql database create \
  --account-name $COSMOSDB_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --name FactoryManagementDB
```

#### 3.3 SQL Database のセットアップ

```bash
# SQL Database 作成スクリプトの実行（既存のスクリプトを利用）
# 詳細は azure-sql-setup.md を参照

SQL_SERVER="mycompany-factory-sql-dev"
SQL_PASSWORD="P@ssw0rd123!"  # 本番環境では強力なパスワードを使用

# SQL Server の作成
az sql server create \
  --name $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --location japaneast \
  --admin-user sqladmin \
  --admin-password $SQL_PASSWORD

# SQL Database の作成
az sql db create \
  --server $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --name FactoryManagementDB \
  --service-objective S1

# ファイアウォール規則の設定
az sql server firewall-rule create \
  --server $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### 手順4: GitHub Actions CI/CD の設定

#### 4.1 Azure Service Principal の作成

```bash
# Service Principal の作成（GitHub Actions用）
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az ad sp create-for-rbac \
  --name "factory-management-github-actions" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth
```

この出力をコピーして GitHub Secrets に `AZURE_CREDENTIALS` として保存します。

#### 4.2 発行プロファイルの取得

```bash
# Web App の発行プロファイルを取得
APP_NAME="mycompany-factory-management-dev"
az webapp deployment list-publishing-profiles \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --xml
```

この出力をコピーして GitHub Secrets に保存します。

#### 4.3 GitHub Secrets の設定

GitHubリポジトリの Settings > Secrets and variables > Actions で以下のSecretsを設定:

**必須Secrets:**
- `AZURE_CREDENTIALS`: Service Principalの認証情報
- `AZURE_WEBAPP_NAME_DEV`: 開発環境のWeb App名
- `AZURE_WEBAPP_PUBLISH_PROFILE_DEV`: 開発環境の発行プロファイル
- `AZURE_WEBAPP_NAME_PROD`: 本番環境のWeb App名（本番環境作成後）
- `AZURE_WEBAPP_PUBLISH_PROFILE_PROD`: 本番環境の発行プロファイル（本番環境作成後）
- `SQL_ADMIN_PASSWORD`: SQL Serverの管理者パスワード

### 手順5: 自動デプロイメントの実行

#### 5.1 GitHub Actions ワークフローによるインフラ作成

1. GitHubリポジトリの「Actions」タブを開く
2. 「Azure Infrastructure Deployment」ワークフローを選択
3. 「Run workflow」をクリック
4. パラメータを入力:
   - prefix: リソース名のプリフィックス
   - environment: 環境（dev/staging/prod）
   - deploy_cosmos_db: Cosmos DBをデプロイするか
   - deploy_sql_db: SQL Databaseをデプロイするか
5. 「Run workflow」を実行

#### 5.2 アプリケーションのデプロイ

1. `main` ブランチにプッシュすると自動的に本番環境にデプロイ
2. `develop` ブランチにプッシュすると自動的に開発環境にデプロイ

## リソース構成

デプロイ完了後、以下のAzureリソースが作成されます：

### 共通リソース
- **リソースグループ**: `<prefix>-factory-management-<env>-rg`
- **App Service Plan**: `<prefix>-factory-management-<env>-plan`
- **Web App**: `<prefix>-factory-management-<env>`
- **Storage Account**: `<prefix>factory<env>`
- **Key Vault**: `<prefix>-factory-kv-<env>`
- **Application Insights**: `<prefix>-factory-insights-<env>`

### データベース関連（オプション）
- **Cosmos DB Account**: `<prefix>-factory-cosmosdb-<env>`
- **SQL Server**: `<prefix>-factory-sql-<env>`
- **SQL Database**: `FactoryManagementDB`

## 環境別設定

### 開発環境 (dev)
- 低コストのリソース構成
- 基本的な監視設定
- 開発用データベース

### ステージング環境 (staging)
- 本番環境と同等の構成
- 統合テスト用設定
- 本番データのサブセット

### 本番環境 (prod)
- 高可用性構成
- 詳細な監視とアラート設定
- バックアップとディザスタリカバリ

## セキュリティ設定

### Key Vault の利用

```bash
# 接続文字列などの機密情報をKey Vaultに保存
KEYVAULT_NAME="mycompany-factory-kv-dev"

# Cosmos DB 接続文字列の保存
COSMOS_CONNECTION_STRING=$(az cosmosdb keys list \
  --name $COSMOSDB_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --type connection-strings \
  --query "connectionStrings[0].connectionString" \
  --output tsv)

az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "CosmosDbConnectionString" \
  --value "$COSMOS_CONNECTION_STRING"

# SQL Database 接続文字列の保存
SQL_CONNECTION_STRING="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Initial Catalog=FactoryManagementDB;User ID=sqladmin;Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "SqlDbConnectionString" \
  --value "$SQL_CONNECTION_STRING"
```

### Web App での Key Vault 参照設定

```bash
# Web App に Key Vault 参照を設定
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    COSMOS_DB_CONNECTION_STRING="@Microsoft.KeyVault(VaultName=${KEYVAULT_NAME};SecretName=CosmosDbConnectionString)" \
    SQL_DB_CONNECTION_STRING="@Microsoft.KeyVault(VaultName=${KEYVAULT_NAME};SecretName=SqlDbConnectionString)"
```

## 監視とログ

### Application Insights の設定

Application Insights は自動的に作成され、Web App に設定されます。以下の監視項目が利用可能です：

- アプリケーションのパフォーマンス
- エラーと exception
- ユーザー行動分析
- カスタムメトリクス

### ログの確認

```bash
# Web App のログを確認
az webapp log show \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP

# リアルタイムログの監視
az webapp log tail \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP
```

## トラブルシューティング

### よくある問題と解決方法

#### 1. リソース名の重複エラー
```
Error: The name 'factory-management-dev' is already taken
```
**解決方法**: より具体的なプリフィックスを使用

#### 2. 権限不足エラー
```
Error: Insufficient privileges to complete the operation
```
**解決方法**: Azureサブスクリプションでの権限を確認し、Contributor以上の権限を取得

#### 3. GitHub Actions デプロイエラー
**解決方法**: GitHub Secrets の設定を確認し、発行プロファイルが正しく設定されているか確認

#### 4. データベース接続エラー
**解決方法**: ファイアウォール規則とKey Vaultの設定を確認

## リソースの削除

テスト完了後、リソースを削除する場合：

```bash
# リソースグループごと削除（注意：復元できません）
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait
```

## コスト最適化

### 開発環境での推奨設定
- App Service Plan: B1 (Basic)
- SQL Database: S1 (Standard)
- Cosmos DB: 400 RU/s (最小構成)

### 本番環境での推奨設定
- App Service Plan: P1V2 (Premium v2) 以上
- SQL Database: S2 以上
- Cosmos DB: オートスケール設定

## サポートと問い合わせ

技術的な問題が発生した場合は、GitHubのIssuesで報告してください。

## 更新履歴

- 2024-06-24: 初版作成
- Azure CLI ベースのデプロイメント手順を追加
- GitHub Actions CI/CD 設定手順を追加
- セキュリティ設定とKey Vault連携手順を追加