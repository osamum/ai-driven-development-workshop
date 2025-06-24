const CACHE_NAME = 'factory-management-v1'
const urlsToCache = [
  '/',
  '/index.html',
  '/static/js/bundle.js',
  '/static/css/main.css',
  // Vue.js アプリケーションのルート
  '/login',
  '/dashboard',
  '/equipment',
  '/alerts',
  '/maintenance',
  '/reports',
  '/settings'
]

// Service Worker のインストール
self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        console.log('キャッシュを開きました')
        return cache.addAll(urlsToCache)
      })
  )
})

// キャッシュからのレスポンス
self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        // キャッシュにあればそれを返す
        if (response) {
          return response
        }

        return fetch(event.request).then(
          function(response) {
            // 有効なレスポンスかチェック
            if(!response || response.status !== 200 || response.type !== 'basic') {
              return response
            }

            // レスポンスをクローンしてキャッシュに保存
            var responseToCache = response.clone()

            caches.open(CACHE_NAME)
              .then(function(cache) {
                cache.put(event.request, responseToCache)
              })

            return response
          }
        ).catch(function() {
          // ネットワークエラーの場合、オフライン用のフォールバックページを返す
          if (event.request.destination === 'document') {
            return caches.match('/index.html')
          }
        })
      })
  )
})

// 古いキャッシュの削除
self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheName !== CACHE_NAME) {
            console.log('古いキャッシュを削除:', cacheName)
            return caches.delete(cacheName)
          }
        })
      )
    })
  )
})