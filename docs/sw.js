// Service Worker for iProcrastinate PWA
const CACHE_NAME = 'iprocrastinate-v1';
const urlsToCache = [
  './',
  './index.html',
  './styles.css',
  './main.dart.js',
  './manifest.json'
];

console.log('[SW] Service Worker loaded');

// Install event - cache resources
self.addEventListener('install', event => {
  console.log('[SW] Installing Service Worker');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[SW] Opened cache');
        return cache.addAll(urlsToCache);
      })
      .then(() => {
        console.log('[SW] All files cached successfully');
      })
      .catch(error => {
        console.error('[SW] Cache installation failed:', error);
      })
  );
});

// Activate event
self.addEventListener('activate', event => {
  console.log('[SW] Service Worker activated');
  event.waitUntil(self.clients.claim());
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
  console.log('[SW] Notification clicked:', event.notification.title);
  event.notification.close();

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then(clients => {
        console.log('[SW] Found clients:', clients.length);
        // Focus existing app window or open new one
        if (clients.length > 0) {
          console.log('[SW] Focusing existing window');
          return clients[0].focus();
        } else {
          console.log('[SW] Opening new window');
          return clients.openWindow('./');
        }
      })
      .catch(error => {
        console.error('[SW] Error handling notification click:', error);
      })
  );
});

// Handle show notification requests from main thread
self.addEventListener('message', event => {
  console.log('[SW] Received message:', event.data);

  if (event.data && event.data.type === 'SHOW_NOTIFICATION') {
    const { title, options } = event.data;
    console.log('[SW] Showing notification:', title, options);

    self.registration.showNotification(title, options)
      .then(() => {
        console.log('[SW] Notification shown successfully');
        event.ports[0].postMessage({ success: true });
      })
      .catch(error => {
        console.error('[SW] Failed to show notification:', error);
        event.ports[0].postMessage({ success: false, error: error.message });
      });
  }
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