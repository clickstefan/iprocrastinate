// Service Worker for iProcrastinate PWA
const CACHE_NAME = 'iprocrastinate-v1';
const urlsToCache = [
  './',
  './index.html',
  './styles.css',
  './main.dart.js',
  './manifest.json'
];

// Install event - cache resources
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Opened cache');
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      }
    )
  );
});

// Notification click event
self.addEventListener('notificationclick', event => {
  event.notification.close();

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then(clients => {
        // Focus existing app window or open new one
        if (clients.length > 0) {
          return clients[0].focus();
        } else {
          return clients.openWindow('./');
        }
      })
  );
});

// Background sync for notifications (future enhancement)
self.addEventListener('sync', event => {
  if (event.tag === 'background-sync') {
    event.waitUntil(
      // Handle background sync
      console.log('Background sync triggered')
    );
  }
});