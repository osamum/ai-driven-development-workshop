# 工場設備管理システム - Vue.js オフライン環境構築・動作確認手順書

## 概要

本手順書は、工場設備管理システムの Vue.js フロントエンドアプリケーションをオフラインのローカル環境で構築し、動作確認を行うための詳細な手順を説明します。

## 前提条件

### システム要件
- **オペレーティングシステム**: Windows 10/11, macOS 10.15+, Ubuntu 18.04+ 
- **メモリ**: 最低 4GB RAM (推奨 8GB 以上)
- **ストレージ**: 最低 2GB の空き容量
- **ネットワーク**: 初期セットアップ時のみインターネット接続が必要

### 必要なソフトウェア
- **Node.js**: バージョン 16.x 以上 (推奨: 18.x LTS)
- **npm**: Node.js に同梱 (バージョン 8.x 以上)
- **Git**: バージョン 2.x 以上 (任意、ソースコード取得用)

## 1. 開発環境のセットアップ

### 1.1 Node.js のインストール

#### Windows の場合
```bash
# Node.js 公式サイトからインストーラーをダウンロード
# https://nodejs.org/ja/ からLTS版をダウンロードしてインストール

# インストール確認
node --version
npm --version
```

#### macOS の場合
```bash
# Homebrew を使用する場合
brew install node

# または公式インストーラーを使用
# https://nodejs.org/ja/ からLTS版をダウンロードしてインストール

# インストール確認
node --version
npm --version
```

#### Ubuntu の場合
```bash
# NodeSource リポジトリを追加
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Node.js をインストール
sudo apt-get install -y nodejs

# インストール確認
node --version
npm --version
```

### 1.2 プロジェクトディレクトリの準備

```bash
# プロジェクトディレクトリに移動
cd /path/to/ai-driven-development-workshop

# プロジェクト構造の確認
ls -la
```

## 2. 依存関係のインストール

### 2.1 npm パッケージのインストール

```bash
# package.json の依存関係をインストール
npm install

# インストール完了の確認
npm list --depth=0
```

### 2.2 インストールされる主要な依存関係

#### プロダクション依存関係
- **vue**: v3.3.0 - Vue.js フレームワーク
- **vue-router**: v4.2.0 - ルーティング機能
- **@vue/cli-service**: v5.0.8 - ビルドツール

#### 開発依存関係
- **@vue/cli-plugin-router**: v5.0.8 - ルーター プラグイン
- **@vue/cli-plugin-eslint**: v5.0.8 - ESLint プラグイン
- **eslint**: v8.49.0 - コード品質チェック
- **@babel/core**: - JavaScript トランスパイラ

## 3. 開発サーバーの起動

### 3.1 基本的な起動手順

```bash
# 開発サーバーを起動
npm run serve

# 正常に起動すると以下のような出力が表示されます：
#   App running at:
#   - Local:   http://localhost:8080/
#   - Network: http://192.168.x.x:8080/
```

### 3.2 ポート変更が必要な場合

```bash
# ポート 3000 で起動する場合
npm run serve -- --port 3000

# または環境変数で指定
PORT=3000 npm run serve
```

### 3.3 サーバー停止

```bash
# Ctrl+C または Cmd+C でサーバーを停止
```

## 4. アプリケーションの動作確認

### 4.1 ブラウザでのアクセス

1. **ブラウザを開く**
   - 推奨ブラウザ: Chrome, Firefox, Safari, Edge の最新版

2. **アプリケーションにアクセス**
   ```
   http://localhost:8080
   ```

3. **ログイン画面の確認**
   - ログイン画面が表示されることを確認
   - 以下のデモアカウントでログインテスト:
     - ユーザー名: `admin` / パスワード: `password`
     - ユーザー名: `operator` / パスワード: `password`
     - ユーザー名: `maintenance` / パスワード: `password`

### 4.2 主要機能の動作確認

#### 4.2.1 ダッシュボード
- **URL**: `http://localhost:8080/dashboard`
- **確認項目**:
  - KPI サマリーの表示
  - 設備状況一覧の表示
  - 最新アラート一覧の表示
  - クイックアクションボタンの動作

#### 4.2.2 設備管理
- **URL**: `http://localhost:8080/equipment`
- **確認項目**:
  - 設備一覧の表示
  - フィルター機能の動作
  - 設備詳細ダイアログの表示
  - タブ切り替え（概要、センサーデータ、履歴、保全）

#### 4.2.3 アラート管理
- **URL**: `http://localhost:8080/alerts`
- **確認項目**:
  - アラート統計の表示
  - アラート一覧の表示
  - フィルター機能の動作
  - アラート詳細モーダルの表示
  - アラート対応ボタンの動作

#### 4.2.4 保全管理
- **URL**: `http://localhost:8080/maintenance`
- **確認項目**:
  - 保全サマリーの表示
  - 予知保全計画の表示
  - 定期保全スケジュールの表示
  - 保全実施記録の表示
  - リソース管理の表示

#### 4.2.5 分析・レポート
- **URL**: `http://localhost:8080/reports`
- **確認項目**:
  - レポートタイプ選択の動作
  - 各種レポートの生成
  - フィルター設定の動作
  - カスタムレポート機能

#### 4.2.6 設定
- **URL**: `http://localhost:8080/settings`
- **確認項目**:
  - ユーザー設定の表示・編集
  - 通知設定の変更
  - ダッシュボード設定の変更
  - システム管理機能

### 4.3 レスポンシブデザインの確認

```bash
# ブラウザの開発者ツールを開く（F12）
# デバイスエミュレーションで以下を確認：
# - スマートフォン表示（360x640）
# - タブレット表示（768x1024）
# - デスクトップ表示（1920x1080）
```

## 5. オフライン機能の確認

### 5.1 Service Worker の動作確認

1. **ブラウザの開発者ツールを開く**
   ```
   F12 → Application タブ → Service Workers
   ```

2. **Service Worker の登録確認**
   - ステータスが "activated and is running" であることを確認

3. **キャッシュの確認**
   ```
   Application タブ → Storage → Cache Storage
   ```

### 5.2 オフライン動作テスト

1. **ネットワークの無効化**
   ```
   開発者ツール → Network タブ → "Offline" チェックボックスをオン
   ```

2. **基本機能の確認**
   - ページリロードが正常に動作する
   - 画面遷移が正常に動作する
   - ローカルストレージのデータが表示される

3. **オフライン表示の確認**
   - 画面上部にオフラインバナーが表示される

## 6. プロダクションビルド

### 6.1 ビルドの実行

```bash
# プロダクション用ビルドを実行
npm run build

# ビルド成果物の確認
ls -la dist/
```

### 6.2 ビルド成果物の構成

```
dist/
├── index.html          # メインHTMLファイル
├── favicon.ico         # ファビコン
├── service-worker.js   # Service Worker
├── css/
│   └── app.[hash].css  # 統合されたCSSファイル
└── js/
    ├── app.[hash].js   # アプリケーションコード
    ├── chunk-vendors.[hash].js  # サードパーティライブラリ
    └── chunk-common.[hash].js   # 共通コード
```

### 6.3 静的ファイルサーバーでの動作確認

```bash
# 静的ファイルサーバーをインストール（初回のみ）
npm install -g serve

# プロダクションビルドを配信
serve -s dist -l 5000

# ブラウザで確認
# http://localhost:5000
```

## 7. トラブルシューティング

### 7.1 よくある問題と解決方法

#### 問題: npm install でエラーが発生する
```bash
# キャッシュをクリアして再実行
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

#### 問題: ポート 8080 が使用中
```bash
# 使用中のプロセスを確認
lsof -ti:8080

# プロセスを終了
kill -9 $(lsof -ti:8080)

# または別のポートを使用
npm run serve -- --port 3000
```

#### 問題: ブラウザでアクセスできない
```bash
# ファイアウォール設定の確認
# Windows: Windows Defender ファイアウォールの設定
# macOS: システム環境設定 → セキュリティとプライバシー → ファイアウォール
# Linux: ufw status
```

#### 問題: ESLint エラーが発生する
```bash
# ESLint 設定の確認
npm run lint

# 自動修正を実行
npm run lint -- --fix
```

### 7.2 ログの確認方法

#### ブラウザコンソールログ
```bash
# ブラウザ開発者ツール → Console タブ
# エラーメッセージや警告を確認
```

#### ネットワークログ
```bash
# ブラウザ開発者ツール → Network タブ
# APIリクエストの状態を確認
```

### 7.3 パフォーマンス確認

#### Lighthouse での確認
```bash
# Chrome 開発者ツール → Lighthouse タブ
# Performance, Accessibility, Best Practices, SEO を確認
```

#### Bundle サイズの確認
```bash
# Bundle アナライザーをインストール
npm install --save-dev webpack-bundle-analyzer

# 分析を実行
npm run build -- --analyze
```

## 8. セキュリティ設定

### 8.1 HTTPS での動作確認

```bash
# HTTPS での開発サーバー起動
npm run serve -- --https

# 自己署名証明書の警告が表示された場合は「詳細設定」→「localhost にアクセスする」
```

### 8.2 セキュリティヘッダーの確認

```bash
# ブラウザ開発者ツール → Network タブ → レスポンスヘッダー確認
# - Content-Security-Policy
# - X-Frame-Options
# - X-Content-Type-Options
```

## 9. デプロイメント準備

### 9.1 環境変数の設定

```bash
# .env.production ファイルを作成
echo "VUE_APP_API_BASE_URL=https://api.factory.example.com" > .env.production
echo "VUE_APP_VERSION=1.0.0" >> .env.production
```

### 9.2 プロダクション設定の確認

```bash
# プロダクション用設定ファイルの確認
cat vue.config.js

# 必要に応じて設定を調整
```

## 10. メンテナンス

### 10.1 定期メンテナンス

```bash
# 依存関係の更新確認
npm outdated

# セキュリティ脆弱性のチェック
npm audit

# 脆弱性の修正
npm audit fix
```

### 10.2 ログローテーション

```bash
# ブラウザキャッシュのクリア
# Chrome: Ctrl+Shift+Del → キャッシュと Cookie のクリア

# Service Worker のキャッシュクリア
# 開発者ツール → Application → Storage → Clear storage
```

## 付録

### A. 主要なファイル構成

```
project-root/
├── public/
│   ├── index.html          # メインHTMLテンプレート
│   └── service-worker.js   # オフライン機能用Service Worker
├── src/
│   ├── main.js            # アプリケーションエントリーポイント
│   ├── App.vue            # ルートコンポーネント
│   ├── router/
│   │   └── index.js       # ルーティング設定
│   └── views/             # 画面コンポーネント
│       ├── Login.vue      # ログイン画面
│       ├── Dashboard.vue  # ダッシュボード
│       ├── Equipment.vue  # 設備管理画面
│       ├── Alerts.vue     # アラート管理画面
│       ├── Maintenance.vue # 保全管理画面
│       ├── Reports.vue    # 分析・レポート画面
│       └── Settings.vue   # 設定画面
├── package.json           # 依存関係とスクリプト定義
├── .eslintrc.js          # ESLint設定
├── .babelrc.json         # Babel設定
└── README.md             # プロジェクト説明
```

### B. 対応ブラウザ

| ブラウザ | 最低バージョン | 推奨バージョン |
|---------|---------------|----------------|
| Chrome | 88+ | 最新版 |
| Firefox | 85+ | 最新版 |
| Safari | 14+ | 最新版 |
| Edge | 88+ | 最新版 |

### C. システム要件

| 項目 | 最低要件 | 推奨要件 |
|------|----------|----------|
| CPU | 2コア 2GHz | 4コア 3GHz+ |
| メモリ | 4GB | 8GB+ |
| ストレージ | 2GB | 5GB+ |
| ネットワーク | 初期セットアップ時のみ | 常時接続（推奨） |

### D. サポート・お問い合わせ

技術的な問題や質問については、以下の手順で対応してください：

1. **ログの収集**: ブラウザコンソールログとネットワークログ
2. **環境情報の確認**: OS、ブラウザ、Node.js のバージョン
3. **再現手順の記録**: エラーが発生する具体的な操作手順

---

## まとめ

本手順書に従って環境構築を行うことで、工場設備管理システムの Vue.js アプリケーションをオフライン環境で正常に動作させることができます。定期的なメンテナンスとセキュリティアップデートを実施し、安定したシステム運用を継続してください。