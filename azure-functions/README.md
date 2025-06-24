# Azure Functions API ドキュメント

## 概要

工場設備管理システム用Azure Functions APIの実装です。複数の言語（C#、Python、Node.js）を使用して、それぞれの特性を活かしたAPIエンドポイントを提供します。

## API エンドポイント一覧

### C# Functions (.NET 8) - 基本CRUD操作

#### 設備グループ関連
- `GET /api/equipment-groups` - 全設備グループ取得
  - クエリパラメータ: `groupId`, `groupName`
- `GET /api/equipment-groups/{id}` - 特定設備グループ取得

#### 設備関連
- `GET /api/equipment` - 全設備取得
  - クエリパラメータ: `groupId`, `equipmentType`, `status`, `location`
- `GET /api/equipment/{id}` - 特定設備取得

#### センサー関連
- `GET /api/sensors` - 全センサー取得
  - クエリパラメータ: `equipmentId`, `sensorType`, `status`
- `GET /api/sensor-data` - センサーデータ取得
  - クエリパラメータ: `sensorId`, `fromDate`, `toDate`, `status`

#### ユーザー関連
- `GET /api/users` - 全ユーザー取得
  - クエリパラメータ: `department`, `status`, `roleId`
- `GET /api/users/{id}` - 特定ユーザー取得

#### アラート関連
- `GET /api/alerts` - 全アラート取得
  - クエリパラメータ: `equipmentId`, `severity`, `status`, `fromDate`, `toDate`, `assignedTo`
- `GET /api/alerts/{id}` - 特定アラート取得

### Python Functions - データ分析・AI機能

#### 分析関連
- `GET /api/analytics/equipment-efficiency` - 設備効率分析
  - クエリパラメータ: `groupId`
  - レスポンス: OEE率、稼働率、品質率などの効率指標

- `GET /api/analytics/predictive-maintenance` - 予知保全分析
  - クエリパラメータ: `equipmentId`
  - レスポンス: 故障予測、保全推奨事項、リスク要因

- `GET /api/analytics/sensor-statistics` - センサーデータ統計分析
  - クエリパラメータ: `sensorId`
  - レスポンス: 統計値、異常検知、傾向分析

### Node.js Functions - リアルタイム・通知機能

#### 通知関連
- `GET /api/notifications/realtime` - リアルタイム通知取得
  - クエリパラメータ: `severity`, `equipmentId`, `limit`
  - レスポンス: 最新のアラート・通知情報

- `POST /api/notifications/chat` - チャット通知送信
  - ボディ: `{ "message", "channel", "priority", "equipment_id" }`
  - レスポンス: 通知送信結果

#### システム監視
- `GET /api/websocket/status` - WebSocket接続状態確認
  - レスポンス: 設備の接続状態とリアルタイムステータス

- `GET /api/system/health` - システム健全性チェック
  - レスポンス: 各コンポーネントの健全性とシステムメトリクス

## フィルタリング機能

各APIエンドポイントは豊富なフィルタリングオプションを提供します：

### 日付フィルター
- `fromDate` / `toDate` - 期間指定フィルター（ISO 8601形式）

### ID フィルター
- `groupId`, `equipmentId`, `sensorId`, `userId` - 関連エンティティでのフィルター

### 文字列検索フィルター
- `equipmentType`, `status`, `severity`, `department` - 部分一致検索

### 数値フィルター
- `limit` - 取得件数制限

## レスポンス形式

全てのAPIは統一されたJSON形式でレスポンスを返します：

```json
{
  "data": [...],
  "timestamp": "2024-03-01T10:30:00Z",
  "status": "success"
}
```

エラー時は以下の形式：

```json
{
  "error": "エラーメッセージ",
  "timestamp": "2024-03-01T10:30:00Z",
  "status": "error"
}
```

## 認証

現在は開発用設定で `AuthorizationLevel.Function` を使用しています。
本番環境では適切な認証方式（Azure AD、API Key等）を設定してください。

## CORS設定

フロントエンドアプリケーション（Vue.js）からの呼び出しに対応するため、適切なCORS設定を行ってください。

## デプロイ手順

各言語のFunctionsは独立してデプロイ可能です：

### C# Functions
```bash
cd azure-functions/csharp-functions
dotnet build
func start
```

### Python Functions
```bash
cd azure-functions/python-functions
pip install -r requirements.txt
func start
```

### Node.js Functions
```bash
cd azure-functions/nodejs-functions
npm install
func start
```

## サンプルデータ

APIは `sample-data/` ディレクトリのJSONファイルからデータを読み込みます。
実際のデータベース接続が必要な場合は、各DataServiceクラスを修正してください。

## パフォーマンス考慮事項

- データキャッシュ機能の実装を推奨
- 大量データ処理時はページネーション実装を推奨
- 定期的なログ監視とパフォーマンス分析を実施