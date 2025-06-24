const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  transpileDependencies: true,
  productionSourceMap: false,
  
  // PWA設定
  pwa: {
    name: '工場設備管理システム',
    themeColor: '#3498db',
    msTileColor: '#2c3e50',
    appleMobileWebAppCapable: 'yes',
    appleMobileWebAppStatusBarStyle: 'black',
    
    // Service Worker の設定
    workboxPluginMode: 'InjectManifest',
    workboxOptions: {
      swSrc: 'public/service-worker.js',
      swDest: 'service-worker.js'
    }
  },
  
  // 開発サーバー設定
  devServer: {
    port: 8080,
    host: '0.0.0.0',
    allowedHosts: 'all',
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  },
  
  // ビルド設定
  configureWebpack: {
    optimization: {
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            priority: 10,
            chunks: 'initial'
          }
        }
      }
    }
  },
  
  // CSS設定
  css: {
    extract: {
      ignoreOrder: true
    }
  }
})