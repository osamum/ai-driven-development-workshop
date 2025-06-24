const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const equipmentRoutes = require('./routes/equipment');

// 環境変数の読み込み
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// ミドルウェア設定
app.use(cors());
app.use(express.json());

// ルート設定
app.use('/api/equipment', equipmentRoutes);

// ヘルスチェックエンドポイント
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// サーバー起動
app.listen(PORT, () => {
  console.log(`設備管理システムAPI サーバーが起動しました: http://localhost:${PORT}`);
  console.log(`Cosmos DB エンドポイント: ${process.env.COSMOS_DB_ENDPOINT || '未設定'}`);
});

module.exports = app;