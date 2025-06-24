# Azure SQL Database セットアップ手順書

## 概要

工場設備管理システム用のAzure SQL Databaseを作成し、サンプルデータを登録する手順を説明します。

## 前提条件

- Azure サブスクリプションを持っていること
- Azure CLI がインストールされていること
- 適切な権限（サブスクリプション所有者またはコントリビューター）を持っていること

## Azure SQL Database の作成手順

### 1. Azure にログイン

```bash
# Azureにログイン
az login
```

### 2. リソースグループの作成

```bash
# リソースグループの作成
az group create \
    --name factory-management-rg \
    --location japaneast
```

### 3. SQL Server の作成

```bash
# SQL Server の作成
az sql server create \
    --name factory-management-server \
    --resource-group factory-management-rg \
    --location japaneast \
    --admin-user sqladmin \
    --admin-password "P@ssw0rd123!"
```

### 4. ファイアウォール規則の設定

```bash
# Azure サービスからのアクセスを許可
az sql server firewall-rule create \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# クライアント IP アドレスからのアクセスを許可（必要に応じて調整）
az sql server firewall-rule create \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --name AllowClientIP \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255
```

### 5. SQL Database の作成

```bash
# SQL Database の作成
az sql db create \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --name FactoryManagementDB \
    --service-objective S0
```

### 6. 接続文字列の取得

```bash
# 接続文字列の取得
az sql db show-connection-string \
    --server factory-management-server \
    --name FactoryManagementDB \
    --client sqlcmd
```

## データベーススキーマとサンプルデータの作成

### 1. テーブル作成

作成されたデータベースに対して、`create-tables.sql` ファイルを実行してテーブルを作成します。

```bash
# SQL Server Management Studio または Azure Data Studio を使用してテーブル作成スクリプトを実行
# または sqlcmd を使用
sqlcmd -S factory-management-server.database.windows.net -d FactoryManagementDB -U sqladmin -P "P@ssw0rd123!" -i create-tables.sql
```

### 2. サンプルデータの挿入

テーブル作成後、`sample-data.sql` ファイルを実行してサンプルデータを挿入します。

```bash
# サンプルデータの挿入
sqlcmd -S factory-management-server.database.windows.net -d FactoryManagementDB -U sqladmin -P "P@ssw0rd123!" -i sample-data.sql
```

## セキュリティ設定の強化

### 1. 透明な暗号化の有効化

```bash
# Transparent Data Encryption (TDE) の有効化
az sql db tde set \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --database FactoryManagementDB \
    --status Enabled
```

### 2. Advanced Data Security の有効化

```bash
# Advanced Data Security の有効化
az sql server ad-admin create \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --display-name "DB Admin" \
    --object-id <Azure AD User Object ID>
```

## 監視とメンテナンス

### 1. データベース使用状況の確認

```bash
# データベース使用状況の確認
az sql db show \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --name FactoryManagementDB
```

### 2. バックアップ設定の確認

```bash
# バックアップポリシーの確認
az sql db ltr-policy show \
    --server factory-management-server \
    --resource-group factory-management-rg \
    --database FactoryManagementDB
```

## 注意事項

1. **パスワードセキュリティ**: 本手順書では簡単なパスワードを使用していますが、本番環境では複雑なパスワードを使用してください。
2. **ファイアウォール設定**: 本手順書では全てのIPアドレスからのアクセスを許可していますが、本番環境では必要最小限のIPアドレスのみ許可してください。
3. **コスト管理**: 使用しない場合はリソースを削除してコストを削減してください。

## リソースの削除

テスト完了後、リソースを削除する場合は以下のコマンドを実行してください。

```bash
# リソースグループごと削除（注意：復元できません）
az group delete \
    --name factory-management-rg \
    --yes \
    --no-wait
```