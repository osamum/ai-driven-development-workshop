# 設備管理システム API接続手順書

## 概要

このドキュメントでは、設備管理システムのサーバーAPIとAzure Cosmos DBを統合し、Vue.jsフロントエンドからデータベースにアクセスする方法について説明します。

## システム構成

- **フロントエンド**: Vue.js 3.x + Vue Router
- **バックエンドAPI**: Node.js + Express.js
- **データベース**: Azure Cosmos DB (NoSQL API)
- **フォールバック**: ローカルJSON データ

## 前提条件

1. Node.js 16.x 以上がインストールされていること
2. Azure CLI がインストールされ、Azure アカウントにログインしていること
3. Azure Cosmos DB インスタンスが作成済みであること（オプション）

## 手順1: 依存関係のインストール

```bash
# プロジェクトディレクトリに移動
cd /path/to/ai-driven-development-workshop

# 依存関係をインストール
npm install
```

## 手順2: 環境変数の設定

### 2.1 環境変数ファイルの作成

```bash
# .env.example をコピーして .env ファイルを作成
cp .env.example .env
```

### 2.2 Azure Cosmos DB 接続情報の設定

`.env` ファイルを編集し、以下の情報を設定します：

```bash
# Azure Cosmos DB 接続設定
COSMOS_DB_ENDPOINT=https://your-cosmos-account.documents.azure.com:443/
COSMOS_DB_KEY=your-primary-key-here
COSMOS_DB_DATABASE_NAME=FactoryManagementDB

# サーバー設定
PORT=3001

# 開発環境設定
NODE_ENV=development
```

### 2.3 Azure Cosmos DB 接続情報の取得

```bash
# 接続文字列の取得
az cosmosdb keys list \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --type connection-strings \
  --query "connectionStrings[0].connectionString" \
  --output tsv

# エンドポイントとキーの個別取得
az cosmosdb show \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --query "documentEndpoint" \
  --output tsv

az cosmosdb keys list \
  --name factory-cosmosdb-account \
  --resource-group factory-management-rg \
  --query "primaryMasterKey" \
  --output tsv
```

## 手順3: APIサーバーの起動

### 3.1 開発モードでの起動

```bash
# APIサーバーの起動（開発モード）
npm run server

# または、ファイル監視モード
npm run dev-server
```

### 3.2 サーバー起動の確認

```bash
# ヘルスチェック
curl http://localhost:3001/health

# データベース接続確認
curl http://localhost:3001/api/equipment/health/db
```

## 手順4: フロントエンドの起動

```bash
# 別のターミナルでVue.jsアプリケーションを起動
npm run dev
```

## 手順5: APIエンドポイントの動作確認

### 5.1 設備一覧の取得

```bash
# 全設備の取得
curl http://localhost:3001/api/equipment

# ステータスでフィルタリング
curl "http://localhost:3001/api/equipment?status=稼働中"

# 設備タイプでフィルタリング
curl "http://localhost:3001/api/equipment?equipment_type=CNC"

# 検索フィルタリング
curl "http://localhost:3001/api/equipment?search=フライス"

# 複合フィルタリング
curl "http://localhost:3001/api/equipment?status=稼働中&search=CNC"
```

### 5.2 特定設備の詳細取得

```bash
# 設備ID=1の詳細情報
curl http://localhost:3001/api/equipment/1
```

### 5.3 設備グループ一覧の取得

```bash
# 設備グループ一覧
curl http://localhost:3001/api/equipment/groups/list
```

## APIレスポンス形式

### 成功レスポンス

```json
{
  "success": true,
  "data": [
    {
      "equipment_id": 1,
      "equipment_name": "CNCフライス盤#1",
      "equipment_type": "加工機械",
      "status": "稼働中",
      "location": "第1製造ライン A1-01",
      "sensors": [
        {
          "sensor_id": 1,
          "sensor_name": "主軸温度センサー",
          "current_value": 45.2,
          "sensor_status": "正常",
          "measurement_unit": "℃"
        }
      ]
    }
  ],
  "total": 12,
  "filters": {
    "status": "稼働中"
  }
}
```

### エラーレスポンス

```json
{
  "success": false,
  "error": "エラーメッセージ",
  "message": "詳細なエラー情報（開発モードのみ）"
}
```

## トラブルシューティング

### 1. APIサーバーが起動しない

```bash
# ポートが使用中の場合
lsof -ti:3001 | xargs kill -9

# または環境変数でポートを変更
export PORT=3002
npm run server
```

### 2. Azure Cosmos DB 接続エラー

```bash
# 接続情報の確認
echo $COSMOS_DB_ENDPOINT
echo $COSMOS_DB_KEY

# Azure CLI でアカウント確認
az cosmosdb show --name factory-cosmosdb-account --resource-group factory-management-rg
```

### 3. フロントエンドからAPIにアクセスできない

Vue.jsアプリケーションの環境変数を設定：

```bash
# .env.local ファイルを作成
echo "VUE_APP_API_BASE_URL=http://localhost:3001" > .env.local
```

### 4. CORSエラーが発生する場合

API サーバーで許可するオリジンを追加：

```javascript
// server/index.js
app.use(cors({
  origin: ['http://localhost:8080', 'http://localhost:3000'],
  credentials: true
}));
```

## モックデータモード

Azure Cosmos DBが利用できない場合、システムは自動的にローカルのサンプルデータを使用します：

- データファイル: `sample-data/` ディレクトリ内のJSONファイル
- 機能制限: リアルタイムデータ更新なし
- フィルタリング: クライアント側でのみ実行

## 本番環境への配備

### 1. 環境変数の設定

```bash
# 本番環境用の環境変数
NODE_ENV=production
PORT=80
COSMOS_DB_ENDPOINT=https://your-prod-cosmos.documents.azure.com:443/
COSMOS_DB_KEY=your-production-key
```

### 2. アプリケーションのビルド

```bash
# フロントエンドのビルド
npm run build

# API サーバーの起動
npm run server
```

### 3. セキュリティ設定

- HTTPS の強制
- API キーの適切な管理
- CORS設定の最適化
- レート制限の実装

## 参考資料

- [Azure Cosmos DB ドキュメント](https://docs.microsoft.com/ja-jp/azure/cosmos-db/)
- [Express.js ガイド](https://expressjs.com/)
- [Vue.js ドキュメント](https://v3.vuejs.org/)
- プロジェクト内の `azure-cosmos-db-setup-guide.md`