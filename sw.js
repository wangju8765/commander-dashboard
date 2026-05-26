// 主宰面板 · Service Worker v0.2.0
const CACHE = 'commander-v2';

self.addEventListener('install', e => {
  self.skipWaiting();
  // Don't cache HTML on install - let network-first handle it
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll([
      '/commander-dashboard/',
      '/commander-dashboard/index.html'
    ]))
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(ks => Promise.all(
      ks.filter(k => k !== CACHE).map(k => caches.delete(k))
    ))
  );
});

self.addEventListener('fetch', e => {
  var url = e.request.url;

  // API calls: network first, fallback to cache
  if (url.includes('supabase.co')) {
    e.respondWith(
      fetch(e.request)
        .then(r => { const c = r.clone(); caches.open(CACHE).then(ca => ca.put(e.request, c)); return r; })
        .catch(() => caches.match(e.request))
    );
    return;
  }

  // HTML pages: network first (always get latest, fallback to cache when offline)
  if (url.endsWith('commander-dashboard/') || url.endsWith('index.html')) {
    e.respondWith(
      fetch(e.request)
        .then(r => { const c = r.clone(); caches.open(CACHE).then(ca => ca.put(e.request, c)); return r; })
        .catch(() => caches.match(e.request))
    );
    return;
  }

  // Other static assets: cache first
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request).then(r => {
      const c = r.clone();
      caches.open(CACHE).then(ca => ca.put(e.request, c));
      return r;
    }))
  );
});
