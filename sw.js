/* Coach Erick — service worker: deixa o app abrir sem internet e trata o toque no lembrete. */
var CACHE = "coach-erick-v1";
var SHELL = ["app.html", "manifest.webmanifest", "icon-192.png", "icon-512.png", "icon-180.png"];

self.addEventListener("install", function(e){
  e.waitUntil(caches.open(CACHE).then(function(c){ return c.addAll(SHELL); }).then(function(){ return self.skipWaiting(); }));
});

self.addEventListener("activate", function(e){
  e.waitUntil(caches.keys().then(function(ks){
    return Promise.all(ks.map(function(k){ return k === CACHE ? null : caches.delete(k); }));
  }).then(function(){ return self.clients.claim(); }));
});

self.addEventListener("fetch", function(e){
  var req = e.request;
  if (req.method !== "GET") return;
  var url = new URL(req.url);
  if (url.origin !== self.location.origin) return;   // YouTube e afins passam direto
  e.respondWith(
    fetch(req).then(function(res){
      var copia = res.clone();
      caches.open(CACHE).then(function(c){ c.put(req, copia); }).catch(function(){});
      return res;
    }).catch(function(){
      return caches.match(req).then(function(hit){ return hit || caches.match("app.html"); });
    })
  );
});

self.addEventListener("notificationclick", function(e){
  e.notification.close();
  e.waitUntil(self.clients.matchAll({ type: "window", includeUncontrolled: true }).then(function(cs){
    for (var i = 0; i < cs.length; i++){ if (cs[i].url.indexOf("app.html") > -1 && "focus" in cs[i]) return cs[i].focus(); }
    if (self.clients.openWindow) return self.clients.openWindow("app.html");
  }));
});
