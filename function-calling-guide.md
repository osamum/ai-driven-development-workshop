# Function Calling 機能実装ガイド

## 概要

Azure OpenAI サービスのFunction Calling機能を使用して、AIチャットに現在時刻を取得する機能を追加しました。この機能により、ユーザーが時刻に関する質問をした際に、AIが実際の現在時刻を取得して回答できるようになります。

## 実装内容

### 1. Function Calling 関数の定義

`azure-functions/nodejs-functions/src/functions/index.js` に以下の機能を追加しました：

#### 現在時刻取得関数
```javascript
const availableFunctions = {
    get_current_time: () => {
        const now = new Date();
        return {
            current_time: now.toISOString(),
            formatted_time: now.toLocaleString('ja-JP', {
                timeZone: 'Asia/Tokyo',
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            }),
            timestamp: now.getTime()
        };
    }
};
```

#### Function Schema 定義
OpenAI APIに送信する関数のスキーマ定義：

```javascript
const functionSchemas = [
    {
        type: "function",
        function: {
            name: "get_current_time",
            description: "現在の日時を取得します。ユーザーが時刻や日付を知りたい場合に使用してください。",
            parameters: {
                type: "object",
                properties: {},
                required: []
            }
        }
    }
];
```

### 2. AI Chat API の更新

Azure OpenAI APIの呼び出し部分を更新して、Function Callingをサポートしました：

- `tools` パラメータにFunction Schemaを追加
- `tool_choice: "auto"` で自動的に関数呼び出しを判断
- Function Callが検出された場合の処理ロジックを実装
- 関数実行結果を含めて再度AIに問い合わせる二段階処理

### 3. テスト機能

Function Calling機能の動作確認用テストスクリプトを作成しました：

```bash
# Azure Functions ディレクトリでテスト実行
cd azure-functions/nodejs-functions
node test-function-calling.js
```

## 使用方法

### 1. Azure OpenAI サービスの設定

Environment Variables に以下を設定してください：

```bash
AZURE_OPENAI_ENDPOINT=https://your-openai-resource.openai.azure.com
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-35-turbo
```

### 2. AI Chat での利用

AIチャットで以下のような質問を行うと、Function Callingが動作します：

- "今の時刻を教えて"
- "現在何時ですか？"
- "今日の日付と時刻は？"

### 3. レスポンス例

ユーザー: "今の時刻を教えて"

AI: "現在の時刻は2025年6月24日 16:31:12です。日本標準時（JST）での時刻をお知らせしました。"

## API エンドポイント

### AI Chat メッセージ送信（Function Calling対応）

- **エンドポイント**: `POST /api/ai/chat`
- **リクエスト**:
  ```json
  {
    "message": "今の時刻を教えて",
    "sessionId": "user123"
  }
  ```

- **レスポンス**:
  ```json
  {
    "success": true,
    "response": "現在の時刻は2025年6月24日 16:31:12です。日本標準時（JST）での時刻をお知らせしました。",
    "chatId": "chat_1750750272009",
    "sessionId": "user123",
    "timestamp": "2025-06-24T07:31:12.009Z"
  }
  ```

## 動作確認

### 1. ローカル環境でのテスト

```bash
# プロジェクトルートから
cd azure-functions/nodejs-functions
npm install
node test-function-calling.js
```

### 2. Azure Functions での動作確認

```bash
# Azure Functions Core Tools を使用
cd azure-functions/nodejs-functions
func start
```

その後、AIチャットインターフェースで時刻に関する質問を行い、Function Callingが動作することを確認します。

## トラブルシューティング

### 1. Function Calling が動作しない場合

- Azure OpenAI の deployment が Function Calling をサポートしているか確認
- GPT-3.5-turbo または GPT-4 モデルを使用していることを確認
- `api-version` が `2024-02-15-preview` 以降であることを確認

### 2. 時刻の表示がおかしい場合

- システムのタイムゾーン設定を確認
- `Asia/Tokyo` タイムゾーンの設定が正しく適用されているか確認

## 今後の拡張予定

- **追加の Function Calling 機能**
  - 設備情報取得関数
  - アラート情報取得関数
  - 保全スケジュール確認関数
- **エラーハンドリングの強化**
- **関数実行ログの詳細化**
- **パフォーマンス最適化**

## 関連ファイル

- `azure-functions/nodejs-functions/src/functions/index.js` - Function Calling 実装
- `azure-functions/nodejs-functions/test-function-calling.js` - テストスクリプト
- `src/components/AiChat.vue` - フロントエンド AI チャットコンポーネント