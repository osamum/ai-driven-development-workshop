# Vue.js オフライン環境構築・動作確認手順書

## 概要

この手順書は、工場設備管理システムのVue.jsアプリケーションを完全にオフラインのローカル環境で構築・実行するための詳細なガイドです。初心者の方でも迷わず設定できるよう、ステップバイステップで説明しています。

## 前提条件

### 必要な環境
- **オペレーティングシステム**: Windows 10/11、macOS 10.14以降、またはLinux
- **メモリ**: 最低4GB（推奨8GB以上）
- **ディスク容量**: 最低2GB の空き容量
- **ネットワーク**: 初回セットアップ時のみインターネット接続が必要（依存関係のダウンロード用）

### 事前インストールが必要なソフトウェア

1. **Node.js** (バージョン 16.x 以降)
   - 公式サイト: https://nodejs.org/
   - LTS版（長期サポート版）の最新バージョンを推奨
   
2. **Git** (バージョン管理用)
   - 公式サイト: https://git-scm.com/

## ステップ1: 開発環境の確認

### 1.1 Node.jsとnpmのバージョン確認

ターミナル（Windows はコマンドプロンプトまたはPowerShell）を開いて以下のコマンドを実行：

```bash
# Node.jsのバージョン確認
node --version

# npmのバージョン確認
npm --version
```

**期待される出力例:**
```
v20.19.2
10.8.2
```

**トラブルシューティング:**
- コマンドが認識されない場合は、Node.jsが正しくインストールされていないか、PATHが設定されていません
- Node.jsを再インストールし、インストーラーの「Add to PATH」オプションが有効になっていることを確認してください

### 1.2 Gitのバージョン確認

```bash
git --version
```

**期待される出力例:**
```
git version 2.34.1
```

## ステップ2: プロジェクトの取得とセットアップ

### 2.1 プロジェクトディレクトリへの移動

```bash
# プロジェクトのルートディレクトリに移動
cd /path/to/ai-driven-development-workshop
```

**注意:** `/path/to/` は実際のプロジェクトがある場所に置き換えてください。

### 2.2 プロジェクト構造の確認

```bash
# ディレクトリ構造を確認
ls -la
```

**確認すべきファイル・ディレクトリ:**
- `package.json` - プロジェクト設定ファイル
- `src/` - Vue.jsソースコードディレクトリ
- `public/` - 静的ファイルディレクトリ
- `vue.config.js` - Vue CLI設定ファイル

### 2.3 パッケージ情報の確認

```bash
# package.jsonの内容を確認
cat package.json
```

**重要な設定項目:**
- `name`: "factory-management-system"
- `version`: "1.0.0"
- `dependencies`: Vue.js関連の依存関係
- `scripts`: 実行可能なコマンド

## ステップ3: 依存関係のインストール

### 3.1 npmキャッシュのクリア（推奨）

```bash
# npmキャッシュをクリア（問題回避のため）
npm cache clean --force
```

### 3.2 依存関係のインストール

```bash
# 全ての依存関係をインストール
npm install
```

**インストール処理中に表示される情報:**
- パッケージダウンロード進行状況
- 警告メッセージ（非推奨パッケージなど）は通常は問題ありません
- エラーメッセージが表示された場合は、ステップ7のトラブルシューティングを参照

**インストール完了の確認:**
```bash
# インストール済みパッケージの確認
npm list --depth=0
```

**期待される主要パッケージ:**
- `vue@^3.4.0`
- `vue-router@^4.2.0`
- `@vue/cli-service@^5.0.0`

### 3.3 インストール状況の詳細確認

```bash
# node_modulesディレクトリの存在確認
ls -la node_modules/ | head -10

# package-lock.jsonの存在確認
ls -la package-lock.json
```

## ステップ4: 開発サーバーでの動作確認

### 4.1 開発サーバーの起動

```bash
# 開発サーバーを起動
npm run serve
```

**または:**

```bash
# 別の起動方法
npm start
```

### 4.2 起動完了の確認

**成功時の出力例:**
```
 DONE  Compiled successfully in 1325ms

  App running at:
  - Local:   http://localhost:8080/ 
  - Network: http://[IPアドレス]:8080/

  Note that the development build is not optimized.
  To create a production build, run npm run build.
```

### 4.3 ブラウザでのアクセス確認

1. ブラウザを開く
2. アドレスバーに `http://localhost:8080/` を入力
3. Enterキーを押してアクセス

**確認すべき画面要素:**
- ページタイトル: "工場設備管理システム"
- ナビゲーションメニュー: "ホーム"、"設備稼働状況"
- コンテンツエリアにダッシュボード情報が表示される

### 4.4 画面遷移の動作確認

1. **ホーム画面の確認:**
   - ナビゲーションメニューの "ホーム" をクリック
   - URLが `http://localhost:8080/` になることを確認

2. **設備稼働状況画面の確認:**
   - ナビゲーションメニューの "設備稼働状況" をクリック
   - URLが `http://localhost:8080/equipment-status` になることを確認

### 4.5 開発サーバーの停止

開発サーバーを停止するには、ターミナルで以下のキーボード操作を行います：

**Windows/Linux:**
```
Ctrl + C
```

**macOS:**
```
Cmd + C
```

## ステップ5: 本番ビルドでの動作確認

### 5.1 本番用ビルドの実行

```bash
# 本番用にビルド
npm run build
```

**ビルド完了時の出力例:**
```
 DONE  Compiled successfully in 2864ms

  File                                 Size                                   Gzipped

  dist/js/chunk-vendors.79a21576.js    92.37 KiB                              34.60 KiB
  dist/js/app.dc2cc5f8.js              23.66 KiB                              6.70 KiB
  dist/css/app.c58f2999.css            11.83 KiB                              2.46 KiB

 DONE  Build complete. The dist directory is ready to be deployed.
```

### 5.2 ビルド結果の確認

```bash
# dist ディレクトリの内容確認
ls -la dist/

# サンプルデータの確認
ls -la dist/sample-data/
```

**期待されるファイル構造:**
```
dist/
├── index.html          # メインHTMLファイル
├── css/               # CSSファイル
├── js/                # JavaScriptファイル
└── sample-data/       # サンプルデータファイル
```

### 5.3 本番ビルドのローカル確認（オプション）

```bash
# 簡易HTTPサーバーでdistディレクトリを配信
npx serve -s dist -l 3000
```

ブラウザで `http://localhost:3000/` にアクセスして動作確認。

**HTTPサーバーの停止:**
```
Ctrl + C (Windows/Linux) または Cmd + C (macOS)
```

## ステップ6: オフライン動作の確認

### 6.1 ネットワーク接続の無効化テスト

1. **Wi-Fiまたは有線LAN接続を一時的に無効化**
2. **既に起動している開発サーバーがある場合は停止**

### 6.2 完全オフライン状態での起動

```bash
# オフライン状態で開発サーバーを起動
npm run serve
```

**確認ポイント:**
- サーバーが正常に起動すること
- ブラウザでアプリケーションにアクセスできること
- サンプルデータが正しく表示されること
- 画面遷移が正常に動作すること

### 6.3 サンプルデータの動作確認

アプリケーションで以下のデータが正しく表示されることを確認：

1. **ホーム画面:**
   - 設備情報の表示
   - センサーデータの表示
   - アラート情報の表示

2. **設備稼働状況画面:**
   - 設備リストの表示
   - フィルター機能の動作
   - 詳細情報の表示

## ステップ7: トラブルシューティング

### 7.1 依存関係インストール時のエラー

**問題:** `npm install` でエラーが発生する

**解決方法:**
```bash
# 1. node_modulesとpackage-lock.jsonを削除
rm -rf node_modules package-lock.json

# 2. npmキャッシュをクリア
npm cache clean --force

# 3. 再インストール
npm install
```

**Windows用コマンド:**
```cmd
# node_modulesとpackage-lock.jsonを削除
rmdir /s node_modules
del package-lock.json

# npmキャッシュをクリア
npm cache clean --force

# 再インストール
npm install
```

### 7.2 ポート競合エラー

**問題:** `Port 8080 is already in use`

**解決方法:**
```bash
# 1. ポート使用状況を確認
netstat -tulpn | grep :8080

# 2. 別のポートで起動
npm run serve -- --port 8081
```

**Windows用コマンド:**
```cmd
# ポート使用状況を確認
netstat -an | findstr :8080
```

### 7.3 メモリ不足エラー

**問題:** `JavaScript heap out of memory`

**解決方法:**
```bash
# Node.jsのメモリ制限を増加
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build
```

**Windows用コマンド:**
```cmd
set NODE_OPTIONS=--max-old-space-size=4096
npm run build
```

### 7.4 ブラウザ表示の問題

**問題:** ブラウザで画面が正しく表示されない

**解決方法:**
1. **ブラウザキャッシュのクリア**
   - Ctrl+F5 (Windows/Linux) または Cmd+Shift+R (macOS)
   
2. **開発者ツールでエラー確認**
   - F12キーで開発者ツールを開く
   - Consoleタブでエラーメッセージを確認

3. **ブラウザの再起動**

### 7.5 サンプルデータが表示されない

**問題:** アプリケーションは起動するがデータが表示されない

**確認項目:**
```bash
# 1. サンプルデータファイルの存在確認
ls -la public/sample-data/

# 2. ファイル内容の確認
cat public/sample-data/equipment.json
```

**解決方法:**
- サンプルデータファイルが正しい場所にあることを確認
- JSONファイルの形式が正しいことを確認

### 7.6 Vue CLI関連のエラー

**問題:** `@vue/cli-service` が見つからない

**解決方法:**
```bash
# Vue CLIをグローバルインストール
npm install -g @vue/cli

# またはローカルでの実行
npx vue-cli-service serve
```

## ステップ8: 開発環境のカスタマイズ（オプション）

### 8.1 エディタの設定

**推奨エディタ:**
- Visual Studio Code
- WebStorm
- Atom

**推奨Vue.js拡張機能（VS Code）:**
- Vetur
- Vue Language Features (Volar)

### 8.2 デバッグ設定

**Vue.js Developer Tools:**
1. ブラウザの拡張機能ストアから「Vue.js devtools」をインストール
2. 開発者ツールでVueタブが利用可能になります

## ステップ9: 自動検証ツール

### 9.1 セットアップ検証スクリプトの実行

プロジェクトには自動検証スクリプトが含まれており、セットアップが正しく完了しているかを確認できます：

```bash
# 検証スクリプトの実行
./validate-vue-setup.sh
```

**Windows環境の場合：**
```bash
# Git Bashまたは WSL で実行
bash validate-vue-setup.sh
```

### 9.2 検証項目

スクリプトは以下の項目を自動的にチェックします：

1. **基本環境**
   - Node.js のインストール状況
   - npm のインストール状況
   - Git のインストール状況

2. **プロジェクトファイル**
   - 必要な設定ファイルの存在確認
   - ソースコードファイルの存在確認
   - サンプルデータの存在確認

3. **依存関係**
   - Vue.js本体のインストール確認
   - Vue Routerのインストール確認
   - Vue CLI Serviceのインストール確認

4. **ビルド機能**
   - 開発サーバーの起動テスト
   - 本番ビルドの実行テスト

### 9.3 検証結果の解釈

- **🎉 全ての確認項目をパス**: セットアップ完了、すぐに開発を開始できます
- **⚠ 大部分をパス**: 軽微な問題あり、基本動作は可能
- **❌ 複数の問題**: セットアップを最初からやり直すことを推奨

## ステップ10: バックアップとリストア

### 9.1 セットアップ検証スクリプトの実行

プロジェクトには自動検証スクリプトが含まれており、セットアップが正しく完了しているかを確認できます：

```bash
# 検証スクリプトの実行
./validate-vue-setup.sh
```

**Windows環境の場合：**
```bash
# Git Bashまたは WSL で実行
bash validate-vue-setup.sh
```

### 9.2 検証項目

スクリプトは以下の項目を自動的にチェックします：

1. **基本環境**
   - Node.js のインストール状況
   - npm のインストール状況
   - Git のインストール状況

2. **プロジェクトファイル**
   - 必要な設定ファイルの存在確認
   - ソースコードファイルの存在確認
   - サンプルデータの存在確認

3. **依存関係**
   - Vue.js本体のインストール確認
   - Vue Routerのインストール確認
   - Vue CLI Serviceのインストール確認

4. **ビルド機能**
   - 開発サーバーの起動テスト
   - 本番ビルドの実行テスト

### 9.3 検証結果の解釈

- **🎉 全ての確認項目をパス**: セットアップ完了、すぐに開発を開始できます
- **⚠ 大部分をパス**: 軽微な問題あり、基本動作は可能
- **❌ 複数の問題**: セットアップを最初からやり直すことを推奨

## ステップ10: バックアップとリストア

### 10.1 プロジェクトのバックアップ

```bash
# プロジェクト全体をバックアップ（node_modules除く）
tar --exclude='node_modules' -czf vue-project-backup.tar.gz .
```

### 10.2 リストア手順

```bash
# バックアップからリストア
tar -xzf vue-project-backup.tar.gz

# 依存関係を再インストール
npm install

# セットアップ確認
./validate-vue-setup.sh
```

## 付録: コマンド一覧

### 基本コマンド

| コマンド | 説明 |
|---------|------|
| `npm install` | 依存関係のインストール |
| `npm run serve` | 開発サーバーの起動 |
| `npm run build` | 本番ビルドの実行 |
| `npm start` | 開発サーバーの起動（別名） |

### トラブルシューティングコマンド

| コマンド | 説明 |
|---------|------|
| `npm cache clean --force` | npmキャッシュのクリア |
| `rm -rf node_modules package-lock.json` | 依存関係の完全削除 |
| `npm list --depth=0` | インストール済みパッケージの確認 |
| `netstat -tulpn \| grep :8080` | ポート使用状況の確認 |

## よくある質問（FAQ）

### Q1: インターネット接続なしで初回セットアップは可能ですか？

**A:** いいえ、初回の `npm install` では依存関係をダウンロードするためインターネット接続が必要です。一度セットアップが完了すれば、その後は完全にオフラインで動作します。

### Q2: 他のポートで起動できますか？

**A:** はい、以下のコマンドで可能です：
```bash
npm run serve -- --port 3000
```

### Q3: 本番環境にデプロイするにはどうすればよいですか？

**A:** `npm run build` で生成される `dist/` ディレクトリの内容を、Webサーバーのドキュメントルートにアップロードしてください。

### Q4: Vue.jsのバージョンを確認するには？

**A:** 以下のコマンドで確認できます：
```bash
npm list vue
```

### Q5: 開発サーバーが他のデバイスからアクセスできません

**A:** `vue.config.js` の設定で `host: '0.0.0.0'` が設定されていることを確認してください。ファイアウォール設定も確認が必要です。

## まとめ

この手順書に従うことで、Vue.jsアプリケーションを完全にオフラインのローカル環境で動作させることができます。問題が発生した場合は、トラブルシューティングセクションを参照し、それでも解決しない場合は開発者ツールのコンソールログを確認して、具体的なエラーメッセージを調べてください。

## 関連ドキュメント

- [Vue.js公式ドキュメント](https://vuejs.org/guide/)
- [Vue CLI公式ドキュメント](https://cli.vuejs.org/guide/)
- [Vue Router公式ドキュメント](https://router.vuejs.org/guide/)
- [README-vue.md](./README-vue.md) - プロジェクト固有の詳細情報