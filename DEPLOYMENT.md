# FactoryManagement デプロイメント設定

このディレクトリには、FactoryManagementアプリケーションをMicrosoft Azureにデプロイするためのスクリプトとワークフローが含まれています。

## 📁 ファイル構成

### デプロイメントスクリプト
- `azure-deploy.sh` - Azure リソース作成スクリプト
- `azure-cleanup.sh` - Azure リソース削除スクリプト
- `setup-github-secrets.sh` - GitHub Secrets セットアップ補助スクリプト
- `azure-deployment-guide.md` - 詳細なデプロイメント手順書

### GitHub Actions ワークフロー
- `.github/workflows/ci-cd.yml` - アプリケーションのCI/CDワークフロー
- `.github/workflows/azure-infrastructure.yml` - Azure インフラストラクチャデプロイワークフロー

## 🚀 クイックスタート

### 1. 手動デプロイ（初回セットアップ）

```bash
# Azure CLI でログイン
az login

# インフラストラクチャのデプロイ
chmod +x azure-deploy.sh
./azure-deploy.sh <your-prefix> dev

# 例
./azure-deploy.sh mycompany dev
```

### 2. GitHub Actions セットアップ

```bash
# GitHub Secrets 設定の補助スクリプト実行
chmod +x setup-github-secrets.sh
./setup-github-secrets.sh <your-prefix> dev

# 表示される値をGitHub Secretsに設定
```

1. GitHub Secrets に必要な認証情報を設定
2. `main` ブランチへのプッシュで本番環境に自動デプロイ
3. `develop` ブランチへのプッシュで開発環境に自動デプロイ

### 3. 作成されるAzureリソース

- App Service (Vue.js アプリケーション)
- Storage Account (静的ファイル)
- Key Vault (シークレット管理)
- Application Insights (監視)
- Cosmos DB (NoSQL データベース)
- SQL Database (リレーショナルデータベース)

## 📖 詳細な手順

詳細なセットアップ手順は [`azure-deployment-guide.md`](./azure-deployment-guide.md) を参照してください。

## 🔧 必要な前提条件

- Azure アカウント
- Azure CLI
- GitHub アカウント
- 適切なAzure権限（Contributor以上）

## 🏷️ 環境とプリフィックス

### プリフィックス
リソース名の重複を避けるため、会社名や部署名などの一意のプリフィックスを指定します。

例: `mycompany`, `factory01`, `team-a`

### 環境
- `dev` - 開発環境
- `staging` - ステージング環境  
- `prod` - 本番環境

### リソース命名規則
`<prefix>-factory-management-<environment>-<resource-type>`

例: `mycompany-factory-management-dev-rg`

## ⚠️ 注意事項

- 本番環境では強力なパスワードを使用してください
- コスト管理のため、不要なリソースは定期的に削除してください
- セキュリティ設定を適切に行ってください

## 🆘 トラブルシューティング

よくある問題と解決方法については [`azure-deployment-guide.md`](./azure-deployment-guide.md) のトラブルシューティング章を参照してください。