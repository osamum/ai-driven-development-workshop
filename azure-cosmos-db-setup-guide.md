# Azure Cosmos DB (NoSQL) インスタンス作成とサンプルデータインポート手順書

## 概要

本文書では、工場設備管理システム用のサンプルデータをAzure Cosmos DB NoSQL APIにインポートするための詳細な手順を説明します。Azure初心者でも実行できるよう、ステップバイステップで解説します。

## 前提条件

- Azureアカウントが作成済みであること
- Azure CLIがインストールされていること
- 適切なAzureサブスクリプションの権限があること

### Azure CLIのインストール（必要な場合）

#### Windows
```bash
# PowerShellを管理者権限で実行
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
```

#### macOS
```bash
brew update && brew install azure-cli
```

#### Linux (Ubuntu/Debian)
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## 手順1: Azureへのログイン

### 1.1 Azure CLIでのログイン
```bash
# Azureにログイン
az login
```

実行すると、ブラウザが開きます。Azureアカウントでログインしてください。

### 1.2 サブスクリプションの確認と設定
```bash
# 利用可能なサブスクリプションの一覧表示
az account list --output table

# 使用するサブスクリプションを設定（必要に応じて）
az account set --subscription "サブスクリプション名またはID"
```

## 手順2: リソースグループの作成

### 2.1 リソースグループの作成
```bash
# リソースグループを作成
az group create \
  --name factory-management-rg \
  --location japaneast \
  --tags project=factory-management environment=development
```

### 2.2 作成の確認
```bash
# リソースグループの確認
az group show --name factory-management-rg --output table
```

## 手順3: Azure Cosmos DB アカウントの作成

### 3.1 Cosmos DBアカウントの作成
```bash
# Cosmos DB アカウントを作成（NoSQL API）
az cosmosdb create \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --locations regionName=japaneast failoverPriority=0 isZoneRedundant=false \
  --default-consistency-level Session \
  --enable-automatic-failover false \
  --enable-multiple-write-locations false \
  --tags project=factory-management environment=development
```

**注意**: アカウント名は全世界で一意である必要があります。既に使用されている場合は、別の名前（例：`factory-cosmosdb-account-20241224`）を使用してください。

### 3.2 作成状況の確認
```bash
# Cosmos DB アカウントの状態確認
az cosmosdb show \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --query "provisioningState" \
  --output tsv
```

作成完了まで数分かかります。`Succeeded`と表示されるまで待機してください。

## 手順4: データベースとコンテナーの作成

### 4.1 データベースの作成
```bash
# データベースを作成
az cosmosdb sql database create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --name FactoryManagementDB \
  --throughput 400
```

### 4.2 コンテナーの作成

#### 4.2.1 設備関連コンテナー
```bash
# EquipmentGroups コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name EquipmentGroups \
  --partition-key-path "/group_id" \
  --throughput 400

# Equipment コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name Equipment \
  --partition-key-path "/group_id" \
  --throughput 400

# Sensors コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name Sensors \
  --partition-key-path "/equipment_id" \
  --throughput 400
```

#### 4.2.2 センサーデータコンテナー（大容量対応）
```bash
# SensorData コンテナー（時系列データ用）
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name SensorData \
  --partition-key-path "/sensor_id" \
  --throughput 1000
```

#### 4.2.3 ユーザー関連コンテナー
```bash
# UserRoles コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name UserRoles \
  --partition-key-path "/role_id" \
  --throughput 400

# Users コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name Users \
  --partition-key-path "/role_id" \
  --throughput 400
```

#### 4.2.4 アラート関連コンテナー
```bash
# AlertTypes コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name AlertTypes \
  --partition-key-path "/alert_type_id" \
  --throughput 400

# Alerts コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name Alerts \
  --partition-key-path "/equipment_id" \
  --throughput 400
```

#### 4.2.5 保全関連コンテナー
```bash
# MaintenanceTypes コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name MaintenanceTypes \
  --partition-key-path "/maintenance_type_id" \
  --throughput 400

# MaintenancePlans コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name MaintenancePlans \
  --partition-key-path "/equipment_id" \
  --throughput 400

# Parts コンテナー
az cosmosdb sql container create \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --name Parts \
  --partition-key-path "/part_id" \
  --throughput 400
```

### 4.3 作成したコンテナーの確認
```bash
# 作成されたコンテナーの一覧表示
az cosmosdb sql container list \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --query "[].name" \
  --output table
```

## 手順5: 接続文字列の取得

### 5.1 接続文字列の取得
```bash
# プライマリ接続文字列を取得
az cosmosdb keys list \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --type connection-strings \
  --query "connectionStrings[0].connectionString" \
  --output tsv
```

**重要**: この接続文字列は後でデータインポートに使用するため、安全な場所に保存してください。

### 5.2 エンドポイントとキーの取得（別途必要な場合）
```bash
# エンドポイントの取得
az cosmosdb show \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --query "documentEndpoint" \
  --output tsv

# プライマリキーの取得
az cosmosdb keys list \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --query "primaryMasterKey" \
  --output tsv
```

## 手順6: サンプルデータのインポート

### 6.1 Data Migration Toolのインストール

#### Windows
```bash
# PowerShellで実行
Invoke-WebRequest -Uri "https://aka.ms/csdmtool" -OutFile "dt.zip"
Expand-Archive "dt.zip" -DestinationPath ".\dt"
```

#### macOS/Linux
```bash
# .NET Core SDKをインストール（まだの場合）
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-6.0

# Data Migration Toolのビルド
git clone https://github.com/azure/azure-documentdb-datamigrationtool.git
cd azure-documentdb-datamigrationtool
dotnet build
```

### 6.2 Azure Portalでのデータインポート（推奨方法）

#### 6.2.1 Azure Portalにアクセス
1. https://portal.azure.com にアクセス
2. 作成したCosmos DBアカウント「factory-cosmosdb-account」を選択
3. 左メニューから「データエクスプローラー」を選択

#### 6.2.2 個別コンテナーへのデータ挿入

**EquipmentGroups コンテナーへのデータ挿入:**
1. データエクスプローラーで「EquipmentGroups」コンテナーを選択
2. 「Items」を選択
3. 「New Item」をクリック
4. 以下のJSONデータを入力：

```json
{
  "id": "group1",
  "group_id": 1,
  "group_name": "生産ライン1",
  "description": "メイン生産ラインの設備群",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

5. 「Save」をクリック
6. 同様の手順でgroup2、group3のデータも追加

**Equipment コンテナーへのデータ挿入:**
1. 「Equipment」コンテナーを選択
2. 同様の手順で設備データを追加

### 6.3 Azure CLIでのデータインポート（一括処理）

#### 6.3.1 PowerShellスクリプトでの一括インポート
```powershell
# cosmos-db-import.ps1

# 設定
$resourceGroup = "factory-management-rg"
$accountName = "factory-cosmosdb-account"
$databaseName = "FactoryManagementDB"

# 接続文字列の取得
$connectionString = az cosmosdb keys list --name $accountName --resource-group $resourceGroup --type connection-strings --query "connectionStrings[0].connectionString" --output tsv

# サンプルデータファイルの読み込み
$sampleData = Get-Content -Path "cosmos-db-sample-data.json" | ConvertFrom-Json

# 各コンテナーにデータを挿入
# EquipmentGroups
foreach ($group in $sampleData.equipmentGroups) {
    $jsonData = $group | ConvertTo-Json -Compress
    Write-Host "Inserting Equipment Group: $($group.group_name)"
    # Azure CLIでのアイテム作成
    az cosmosdb sql item create --account-name $accountName --resource-group $resourceGroup --database-name $databaseName --container-name "EquipmentGroups" --body $jsonData
}

# Equipment
foreach ($equipment in $sampleData.equipment) {
    $jsonData = $equipment | ConvertTo-Json -Compress
    Write-Host "Inserting Equipment: $($equipment.equipment_name)"
    az cosmosdb sql item create --account-name $accountName --resource-group $resourceGroup --database-name $databaseName --container-name "Equipment" --body $jsonData
}

# 他のデータも同様に処理...
```

#### 6.3.2 Bashスクリプトでの一括インポート
```bash
#!/bin/bash
# cosmos-db-import.sh

# 設定
RESOURCE_GROUP="factory-management-rg"
ACCOUNT_NAME="factory-cosmosdb-account"
DATABASE_NAME="FactoryManagementDB"

# jqコマンドの確認（JSONパース用）
if ! command -v jq &> /dev/null; then
    echo "jqコマンドをインストールしてください"
    echo "Ubuntu: sudo apt-get install jq"
    echo "macOS: brew install jq"
    exit 1
fi

# サンプルデータからEquipmentGroupsを抽出・挿入
echo "EquipmentGroupsデータを挿入中..."
cat cosmos-db-sample-data.json | jq -r '.equipmentGroups[]' | while IFS= read -r group; do
    echo "挿入中: $(echo $group | jq -r '.group_name')"
    az cosmosdb sql item create \
        --account-name $ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP \
        --database-name $DATABASE_NAME \
        --container-name "EquipmentGroups" \
        --body "$group"
done

echo "インポート完了"
```

## 手順7: データの確認

### 7.1 Azure Portal での確認
1. Azure Portal の「データエクスプローラー」で各コンテナーを確認
2. 「Items」を選択してデータが正しく格納されているか確認

### 7.2 Azure CLI での確認
```bash
# EquipmentGroups コンテナーのアイテム数確認
az cosmosdb sql item list \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name EquipmentGroups \
  --query "length(@)"

# 特定のアイテムの取得
az cosmosdb sql item show \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name EquipmentGroups \
  --id "group1" \
  --partition-key-value 1
```

### 7.3 クエリによるデータ検証
```bash
# SQLクエリの実行例
az cosmosdb sql query \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name Equipment \
  --query-text "SELECT * FROM c WHERE c.status = '稼働中'"
```

## 手順8: セキュリティ設定（推奨）

### 8.1 ファイアウォール設定
```bash
# 特定のIPアドレスからのアクセスのみを許可
az cosmosdb update \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --ip-range-filter "YOUR_IP_ADDRESS"
```

### 8.2 プライベートエンドポイントの設定（本格運用時）
```bash
# 仮想ネットワークの作成
az network vnet create \
  --resource-group factory-management-rg \
  --name factory-vnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name factory-subnet \
  --subnet-prefix 10.0.1.0/24

# プライベートエンドポイントの作成
az network private-endpoint create \
  --resource-group factory-management-rg \
  --name factory-cosmosdb-pe \
  --vnet-name factory-vnet \
  --subnet factory-subnet \
  --private-connection-resource-id $(az cosmosdb show --name factory-cosmosdb-account --resource-group factory-management-rg --query id --output tsv) \
  --connection-name factory-cosmosdb-connection \
  --group-id Sql
```

## 手順9: 運用監視の設定

### 9.1 診断設定の有効化
```bash
# 診断設定の作成（ログ分析ワークスペースへの送信）
az monitor diagnostic-settings create \
  --resource $(az cosmosdb show --name factory-cosmosdb-account --resource-group factory-management-rg --query id --output tsv) \
  --name "CosmosDB-Diagnostics" \
  --logs '[{"category":"DataPlaneRequests","enabled":true},{"category":"QueryRuntimeStatistics","enabled":true}]' \
  --metrics '[{"category":"Requests","enabled":true}]' \
  --workspace $(az monitor log-analytics workspace show --workspace-name factory-logs-workspace --resource-group factory-management-rg --query id --output tsv)
```

### 9.2 アラートルールの設定
```bash
# 高いRU消費量のアラート
az monitor metrics alert create \
  --name "CosmosDB-HighRU" \
  --resource-group factory-management-rg \
  --target-resource-id $(az cosmosdb show --name factory-cosmosdb-account --resource-group factory-management-rg --query id --output tsv) \
  --condition "avg TotalRequestUnits > 800" \
  --description "Cosmos DBのRU消費量が高い状態です"
```

## トラブルシューティング

### よくある問題と解決方法

#### 1. アカウント名が既に使用されている
```bash
# エラー: The account name 'factory-cosmosdb-account' is already taken
# 解決方法: 一意のアカウント名を使用
az cosmosdb create --name factory-cosmosdb-account-$(date +%Y%m%d%H%M) ...
```

#### 2. パーティションキーエラー
```bash
# エラー: PartitionKey value must be supplied for this operation
# 解決方法: パーティションキー値を正しく指定
az cosmosdb sql item create ... --partition-key-value "正しい値"
```

#### 3. スループット不足
```bash
# 警告: Request rate is large
# 解決方法: スループットの増加
az cosmosdb sql container throughput update \
  --account-name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --database-name FactoryManagementDB \
  --container-name SensorData \
  --throughput 2000
```

## まとめ

本手順書に従うことで、工場設備管理システム用のAzure Cosmos DB NoSQL APIインスタンスの作成と、サンプルデータのインポートが完了します。

### 作成されたリソース
- Cosmos DBアカウント: factory-cosmosdb-account
- データベース: FactoryManagementDB
- コンテナー: 11個（設備、センサー、ユーザー、アラート、保全関連）
- サンプルデータ: 工場設備管理システムの主要エンティティ

### 次のステップ
1. アプリケーションからの接続テスト
2. データモデルの詳細設計
3. セキュリティポリシーの実装
4. 監視・運用体制の構築

### 重要な注意点
- 接続文字列やキーは安全に管理してください
- 本格運用前にはプライベートエンドポイントの設定を検討してください
- 定期的なバックアップとスループット監視を実施してください