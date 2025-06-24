# 設備稼働状況画面とAPIの融合 - 実装ガイド

## 概要

設備稼働状況画面に API 呼び出し機能を統合し、Azure Functions のサーバー API を後で簡単に接続できるようにしました。現在はサンプルデータを使用していますが、URL の設定だけで実際の API に切り替え可能です。

## 実装内容

### 1. API サービスクラスの作成

`src/services/api.js` に API サービスクラスを実装しました。

**主な機能**：
- Azure Functions URL の設定に対応
- サンプルデータを使用するモック機能
- 設備データとセンサーデータの統合処理
- エラーハンドリングとフォールバック機能
- ステータス集計の計算機能

**後で Azure Functions に接続する方法**：
```bash
# 環境変数で Azure Functions の URL を設定
export VUE_APP_API_BASE_URL=https://your-functions-app.azurewebsites.net
```

### 2. 設備稼働状況コンポーネントの更新

`src/components/EquipmentStatus.vue` を以下のように更新しました：

**追加機能**：
- API サービスを使用したデータ取得
- ローディング状態の表示
- エラー表示とリトライ機能
- 更新ボタンによる手動リフレッシュ

**UI の改善**：
- ヘッダー部分にタイトルと更新ボタンを配置
- ローディングスピナーとメッセージの表示
- エラー時の分かりやすいメッセージ表示

## API エンドポイント仕様

Azure Functions 実装時に必要な API エンドポイント：

### GET /api/equipment-status

**レスポンス形式**：
```json
{
  "equipment": [
    {
      "equipment_id": 1,
      "equipment_name": "CNC加工機A1",
      "equipment_type": "CNC加工機",
      "status": "稼働中",
      "location": "工場棟A-1F-001",
      "model_number": "CNC-1000X",
      "manufacturer": "マキノ精機",
      "installation_date": "2023-06-15",
      "updated_at": "2024-06-24T05:00:00Z"
    }
  ],
  "groups": [
    {
      "id": 1,
      "group_name": "加工機",
      "description": "CNC加工機グループ"
    }
  ],
  "sensors": [
    {
      "sensor_id": 1,
      "equipment_id": 1,
      "sensor_name": "主軸温度センサー",
      "sensor_type": "温度",
      "measurement_unit": "℃",
      "normal_min": 20.0,
      "normal_max": 80.0,
      "status": "正常"
    }
  ],
  "sensorData": [
    {
      "data_id": 1,
      "sensor_id": 1,
      "value": 65.2,
      "status": "正常",
      "timestamp": "2024-06-24T06:00:00Z"
    }
  ],
  "timestamp": "2024-06-24T06:30:00Z"
}
```

## 動作確認

### 開発サーバーの起動

```bash
# 依存関係のインストール
npm install

# 開発サーバー起動
npm run dev
```

### ビルドとテスト

```bash
# プロダクションビルド
npm run build
```

## トラブルシューティング

### サンプルデータが読み込めない場合

API サービスは自動的にフォールバックデータを使用します。以下のファイルが存在することを確認してください：

- `/public/sample-data/equipment.json`
- `/public/sample-data/equipment-groups.json`
- `/public/sample-data/sensors.json`
- `/public/sample-data/sensor-data.json`

### API エラーが発生した場合

1. ネットワーク接続を確認
2. Azure Functions の URL が正しく設定されているか確認
3. CORS 設定が適切に行われているか確認

## 今後の拡張予定

- リアルタイム更新機能の追加
- 詳細な設備稼働レポート機能
- アラート通知機能の統合
- データのキャッシュ機能

## 関連ファイル

- `src/services/api.js` - API サービスクラス
- `src/components/EquipmentStatus.vue` - 設備稼働状況コンポーネント
- `sample-data/` - サンプルデータファイル群