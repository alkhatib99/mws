'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "b354a321eee6187c9150c60c12a83643",
"assets/AssetManifest.bin.json": "3aa77e6e43c3a742870b385358e41769",
"assets/AssetManifest.json": "fc08f2da429948eee7411f2a1b17e857",
"assets/assets/fonts/Montserrat-Bold.ttf": "5ce2f7a911f9b17a9aa0edf19b9e19ef",
"assets/assets/fonts/Montserrat-Regular.ttf": "62d08c41cefb66a1825ac1611f5d5439",
"assets/assets/images/coinbase_logo.png": "a400f36c5dde8a307da75b3609bf0160",
"assets/assets/images/ledger_logo.png": "8f19ac835c875b1905f90e7c6b92d386",
"assets/assets/images/logo.png": "25140bbcf2e13dc5b0976b37ce17a142",
"assets/assets/images/metamask_logo.png": "860b1f43a9ee3a687eb26a1c8fe62849",
"assets/assets/images/other_wallets_icon.png": "3ef768d915ced48d5b6131a66d544ec5",
"assets/assets/images/phantom_logo.png": "2282a46aed6be1cfecb40d7999bf7708",
"assets/assets/images/trustwallet_logo.png": "5583397184e2080c50bdf5dcdcc2d4e2",
"assets/assets/images/walletconnect_logo.png": "85deda8a8e77c5db336faaa8d681ccae",
"assets/assets/networks/base.png": "23b07e50136919bc4715ff0c1994ee7c",
"assets/assets/networks/bnb.png": "9faf561e1bbd427d5d739b539249357f",
"assets/assets/networks/custom.png": "26b6e46417f9862e8ace3e119c0f75d1",
"assets/assets/networks/ethereum.png": "c9a8ef076ec0ead3b621028c2088a829",
"assets/assets/tokens/bnb.png": "9faf561e1bbd427d5d739b539249357f",
"assets/assets/tokens/cake.png": "bdd7c45a6d32a54702dd4440d3471dc2",
"assets/assets/tokens/dai.png": "26d4501f9d3f49e0a1fa9e86cd462de3",
"assets/assets/tokens/eth.png": "86b356aa4636232f3e200c65d2a8b6b4",
"assets/assets/tokens/usdc.png": "c76b33ca42c5730ab77f3341ce9764a7",
"assets/assets/tokens/usdt.png": "a440d4b512f4d2b9b63d3ab8818fc9e3",
"assets/FontManifest.json": "9be2b8cd0402f03049e51af5c2e7d221",
"assets/fonts/MaterialIcons-Regular.otf": "431a097ec942e186ac621b67cca16f26",
"assets/NOTICES": "e624cbb4fea63bc536761e0cd8f77ecc",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"demo.html": "de5c7aa78612e9b3cb8af6735ed79355",
"favicon.png": "77af7c615a53b6fa7e4ca9f107966c18",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "4de9df0a68e2579610094d91cef907b7",
"icons/Icon-192.png": "4ce382d4ce1a4b2cfebb25940bae8f61",
"icons/Icon-512.png": "59d9462cc6636f2abf2b97facce17b90",
"icons/Icon-maskable-192.png": "4ce382d4ce1a4b2cfebb25940bae8f61",
"icons/Icon-maskable-512.png": "59d9462cc6636f2abf2b97facce17b90",
"index.html": "9946970686893a6caa5758612f23ee75",
"/": "9946970686893a6caa5758612f23ee75",
"main.dart.js": "2ab4145ff217ccf1132551ad6e3f4760",
"manifest.json": "73ea27828b3277cda97c049627d42c3f",
"version.json": "921f42e1f99d1e0ea2eaed21b46a6587"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
