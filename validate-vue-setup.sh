#!/bin/bash

# Vue.js オフライン環境 動作確認スクリプト
# このスクリプトはVue.jsアプリケーションのセットアップが正しく完了しているかを確認します

echo "==================================="
echo "Vue.js オフライン環境 動作確認スクリプト"
echo "==================================="
echo ""

# 色付きテキスト用の設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 成功/失敗カウンター
SUCCESS_COUNT=0
TOTAL_CHECKS=0

# チェック関数
check_command() {
    local command_name=$1
    local command_check=$2
    local expected_pattern=$3
    
    echo -e "${BLUE}[チェック $((++TOTAL_CHECKS))]${NC} $command_name の確認..."
    
    if command -v $command_check >/dev/null 2>&1; then
        local version_output=$($command_check --version 2>&1)
        if [[ $version_output =~ $expected_pattern ]]; then
            echo -e "${GREEN}✓ 成功:${NC} $command_name がインストールされています - $version_output"
            ((SUCCESS_COUNT++))
        else
            echo -e "${YELLOW}⚠ 警告:${NC} $command_name はインストールされていますが、バージョンを確認してください - $version_output"
            ((SUCCESS_COUNT++))
        fi
    else
        echo -e "${RED}✗ エラー:${NC} $command_name がインストールされていません"
    fi
    echo ""
}

# ファイル存在チェック関数
check_file() {
    local file_path=$1
    local file_description=$2
    
    echo -e "${BLUE}[チェック $((++TOTAL_CHECKS))]${NC} $file_description の確認..."
    
    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✓ 成功:${NC} $file_path が存在します"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}✗ エラー:${NC} $file_path が見つかりません"
    fi
    echo ""
}

# ディレクトリ存在チェック関数
check_directory() {
    local dir_path=$1
    local dir_description=$2
    
    echo -e "${BLUE}[チェック $((++TOTAL_CHECKS))]${NC} $dir_description の確認..."
    
    if [ -d "$dir_path" ]; then
        local file_count=$(ls -1 "$dir_path" 2>/dev/null | wc -l)
        echo -e "${GREEN}✓ 成功:${NC} $dir_path が存在します ($file_count ファイル)"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}✗ エラー:${NC} $dir_path が見つかりません"
    fi
    echo ""
}

# npm パッケージチェック関数
check_npm_package() {
    local package_name=$1
    local package_description=$2
    
    echo -e "${BLUE}[チェック $((++TOTAL_CHECKS))]${NC} $package_description の確認..."
    
    if npm list "$package_name" >/dev/null 2>&1; then
        local version=$(npm list "$package_name" --depth=0 2>/dev/null | grep "$package_name" | sed 's/.*@//' | sed 's/ .*//')
        echo -e "${GREEN}✓ 成功:${NC} $package_name@$version がインストールされています"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}✗ エラー:${NC} $package_name がインストールされていません"
    fi
    echo ""
}

# メイン確認処理
echo "基本環境の確認を開始します..."
echo ""

# 1. Node.js確認
check_command "Node.js" "node" "v[0-9]"

# 2. npm確認
check_command "npm" "npm" "[0-9]"

# 3. Git確認（オプション）
check_command "Git" "git" "git version"

echo "プロジェクトファイルの確認を開始します..."
echo ""

# 4. package.json確認
check_file "package.json" "プロジェクト設定ファイル"

# 5. main.js確認
check_file "src/main.js" "Vueアプリケーションエントリーポイント"

# 6. App.vue確認
check_file "src/App.vue" "メインVueコンポーネント"

# 7. vue.config.js確認
check_file "vue.config.js" "Vue CLI設定ファイル"

# 8. public/index.html確認
check_file "public/index.html" "HTMLテンプレート"

# 9. コンポーネントディレクトリ確認
check_directory "src/components" "Vueコンポーネントディレクトリ"

# 10. サンプルデータディレクトリ確認
check_directory "public/sample-data" "サンプルデータディレクトリ"

echo "依存関係の確認を開始します..."
echo ""

# 11. Vue.js確認
check_npm_package "vue" "Vue.js"

# 12. Vue Router確認
check_npm_package "vue-router" "Vue Router"

# 13. Vue CLI Service確認
check_npm_package "@vue/cli-service" "Vue CLI Service"

echo "ビルド確認を開始します..."
echo ""

# 14. 開発ビルドテスト
echo -e "${BLUE}[チェック $((++TOTAL_CHECKS))]${NC} 開発サーバー起動テスト..."
if timeout 30 npm run serve 2>&1 | grep -q "App running at"; then
    echo -e "${GREEN}✓ 成功:${NC} 開発サーバーが正常に起動します"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}✗ エラー:${NC} 開発サーバーの起動に失敗しました"
fi
echo ""

# 15. 本番ビルドテスト
echo -e "${BLUE}[チェック $((++TOTAL_CHECKS))]${NC} 本番ビルドテスト..."
if npm run build >/dev/null 2>&1; then
    echo -e "${GREEN}✓ 成功:${NC} 本番ビルドが正常に完了します"
    ((SUCCESS_COUNT++))
    
    # ビルド結果確認
    if [ -d "dist" ]; then
        echo -e "${GREEN}✓ 成功:${NC} distディレクトリが生成されました"
        
        if [ -f "dist/index.html" ]; then
            echo -e "${GREEN}✓ 成功:${NC} HTMLファイルが生成されました"
        fi
        
        if [ -d "dist/js" ] && [ "$(ls -A dist/js)" ]; then
            echo -e "${GREEN}✓ 成功:${NC} JavaScriptファイルが生成されました"
        fi
        
        if [ -d "dist/css" ] && [ "$(ls -A dist/css)" ]; then
            echo -e "${GREEN}✓ 成功:${NC} CSSファイルが生成されました"
        fi
        
        if [ -d "dist/sample-data" ] && [ "$(ls -A dist/sample-data)" ]; then
            echo -e "${GREEN}✓ 成功:${NC} サンプルデータが正しくコピーされました"
        fi
    fi
else
    echo -e "${RED}✗ エラー:${NC} 本番ビルドに失敗しました"
fi
echo ""

# 結果サマリー
echo "==================================="
echo "確認結果サマリー"
echo "==================================="
echo ""

if [ $SUCCESS_COUNT -eq $TOTAL_CHECKS ]; then
    echo -e "${GREEN}🎉 全ての確認項目をパスしました! ($SUCCESS_COUNT/$TOTAL_CHECKS)${NC}"
    echo -e "${GREEN}Vue.jsアプリケーションは正常にセットアップされています。${NC}"
    echo ""
    echo "次のステップ:"
    echo "1. 開発サーバーを起動: npm run serve"
    echo "2. ブラウザで http://localhost:8080/ にアクセス"
    echo "3. アプリケーションの動作を確認"
elif [ $SUCCESS_COUNT -gt $((TOTAL_CHECKS * 3 / 4)) ]; then
    echo -e "${YELLOW}⚠ 大部分の確認項目をパスしました ($SUCCESS_COUNT/$TOTAL_CHECKS)${NC}"
    echo -e "${YELLOW}いくつかの問題がありますが、基本的な動作は可能な可能性があります。${NC}"
    echo "失敗した項目については、vue-offline-setup-guide.md のトラブルシューティングセクションを確認してください。"
else
    echo -e "${RED}❌ 複数の確認項目で問題が見つかりました ($SUCCESS_COUNT/$TOTAL_CHECKS)${NC}"
    echo -e "${RED}セットアップが完了していない可能性があります。${NC}"
    echo ""
    echo "推奨される対処法:"
    echo "1. vue-offline-setup-guide.md を最初から実行"
    echo "2. npm install を再実行"
    echo "3. Node.jsのバージョンを確認"
fi

echo ""
echo "詳細な手順については vue-offline-setup-guide.md を参照してください。"
echo "==================================="