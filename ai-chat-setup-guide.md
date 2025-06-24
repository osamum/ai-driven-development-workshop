# AI Chat 機能 - Azure OpenAI 設定ガイド

## 概要

工場設備管理システムにAI Chat機能が追加されました。この機能はAzure OpenAI APIを使用して、設備管理に関する質問に自動で回答します。

## 機能一覧

- **AI Chat インターフェース**: ユーザーが質問を入力すると、AIが回答を返します
- **履歴保存**: 過去の会話履歴を保存し、コンテキストを維持します
- **セッション管理**: ユーザーごとに会話セッションを分離管理
- **フォールバック機能**: Azure OpenAI APIが利用できない場合もデモ応答を提供

## Azure OpenAI サービスの作成

### 1. Azure OpenAI リソースの作成

```bash
# Azure ログイン
az login

# リソースグループの作成
az group create --name factory-ai-rg --location eastus

# Cognitive Services アカウント（OpenAI）の作成
az cognitiveservices account create \
  --name factory-openai-service \
  --resource-group factory-ai-rg \
  --location eastus \
  --kind OpenAI \
  --sku S0
```

### 2. GPTモデルのデプロイ

```bash
# デプロイメント名を設定
DEPLOYMENT_NAME="gpt-35-turbo"

# GPT-3.5-turbo モデルをデプロイ
az cognitiveservices account deployment create \
  --name factory-openai-service \
  --resource-group factory-ai-rg \
  --deployment-name $DEPLOYMENT_NAME \
  --model-name gpt-35-turbo \
  --model-version "0613" \
  --model-format OpenAI \
  --scale-settings-scale-type "Standard"
```

### 3. アクセスキーとエンドポイントの取得

```bash
# エンドポイント取得
az cognitiveservices account show \
  --name factory-openai-service \
  --resource-group factory-ai-rg \
  --query "properties.endpoint" --output tsv

# アクセスキー取得
az cognitiveservices account keys list \
  --name factory-openai-service \
  --resource-group factory-ai-rg \
  --query "key1" --output tsv
```

## 環境変数の設定

### Azure Functions（`local.settings.json`）

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "AZURE_OPENAI_ENDPOINT": "https://your-openai-resource.openai.azure.com",
    "AZURE_OPENAI_API_KEY": "your-api-key-here",
    "AZURE_OPENAI_DEPLOYMENT_NAME": "gpt-35-turbo"
  }
}
```

### 本番環境での設定

```bash
# Azure Function App への環境変数設定
az functionapp config appsettings set \
  --name your-function-app-name \
  --resource-group your-resource-group \
  --settings \
    AZURE_OPENAI_ENDPOINT="https://your-openai-resource.openai.azure.com" \
    AZURE_OPENAI_API_KEY="your-api-key" \
    AZURE_OPENAI_DEPLOYMENT_NAME="gpt-35-turbo"
```

## API エンドポイント

### 1. AI Chat メッセージ送信

- **エンドポイント**: `POST /api/ai/chat`
- **リクエスト**:
  ```json
  {
    "message": "設備の稼働状況を教えて",
    "sessionId": "user123"
  }
  ```
- **レスポンス**:
  ```json
  {
    "success": true,
    "response": "現在の設備稼働状況は...",
    "chatId": "chat_1234567890",
    "sessionId": "user123",
    "timestamp": "2024-01-01T10:00:00.000Z"
  }
  ```

### 2. Chat 履歴取得

- **エンドポイント**: `GET /api/ai/chat/history?sessionId=user123&limit=20`
- **レスポンス**:
  ```json
  {
    "success": true,
    "sessionId": "user123",
    "history": [
      {
        "id": "chat_1234567890",
        "userMessage": "設備の稼働状況を教えて",
        "aiResponse": "現在の設備稼働状況は...",
        "timestamp": "2024-01-01T10:00:00.000Z"
      }
    ],
    "totalCount": 1
  }
  ```

## Vue.js コンポーネント

新しく追加された **AiChat.vue** コンポーネントは以下の機能を提供します：

- **チャットインターフェース**: メッセージの送信と受信
- **履歴表示**: 過去の会話を表示
- **リアルタイム表示**: タイピングインジケーター
- **サンプル質問**: よくある質問への簡単アクセス
- **レスポンシブデザイン**: モバイル対応

## 使用方法

1. **ナビゲーション**: アプリケーションで「AI チャット」をクリック
2. **質問入力**: テキストエリアに質問を入力
3. **送信**: Enterキーまたは送信ボタンで質問を送信
4. **履歴確認**: 過去の会話が自動的に表示されます

## 開発環境での実行

```bash
# Vue.js アプリケーション起動
npm run serve

# Azure Functions ローカル実行（別ターミナル）
cd azure-functions/nodejs-functions
func start
```

## セキュリティ考慮事項

1. **API キーの保護**: 環境変数でAPI キーを管理
2. **アクセス制御**: Azure OpenAI リソースへのアクセス制御
3. **レート制限**: API 呼び出し頻度の制限
4. **データプライバシー**: 会話履歴の適切な管理

## トラブルシューティング

### よくある問題

1. **API キーエラー**
   - 環境変数が正しく設定されているか確認
   - Azure OpenAI リソースのキーが有効か確認

2. **デプロイメントエラー**
   - デプロイメント名が正しいか確認
   - モデルが正常にデプロイされているか確認

3. **接続エラー**
   - エンドポイントURLが正しいか確認
   - ネットワーク接続を確認

### ログ確認

```bash
# Azure Functions ログ確認
func logs
```

## 今後の拡張予定

- **データベース連携**: Cosmos DB での履歴永続化
- **ユーザー認証**: Azure AD による認証
- **高度な機能**: ファイルアップロード、画像認識
- **分析機能**: 質問パターンの分析