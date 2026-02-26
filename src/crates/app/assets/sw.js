// TEMPLATE_TODO: change my-app to your app name.
var cacheName = 'egui-my-app';

/* Start the service worker and cache all of the app's content.
   We do not hardcode filenames because trunk generates hashed filenames (e.g. app-abc123_bg.wasm).
   Instead, we cache everything fetched during the page load via the fetch handler below. */
self.addEventListener('install', function (e) {
    e.waitUntil(
        caches.open(cacheName).then(function (cache) {
            return cache.addAll(['./', './index.html']);
        })
    );
});

/* Cache every successful GET request and serve cached content when offline */
self.addEventListener('fetch', function (e) {
    e.respondWith(
        caches.match(e.request).then(function (response) {
            if (response) {
                return response;
            }
            return fetch(e.request).then(function (networkResponse) {
                if (networkResponse.ok && e.request.method === 'GET') {
                    var responseClone = networkResponse.clone();
                    caches.open(cacheName).then(function (cache) {
                        cache.put(e.request, responseClone);
                    });
                }
                return networkResponse;
            });
        })
    );
});
