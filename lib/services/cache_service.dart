import 'dart:async';
import 'dart:convert';

class CacheService {
  static final Map<String, CacheEntry> _cache = {};
  static final Map<String, Timer> _timers = {};
  
  // Default cache durations
  static const Duration _defaultDuration = Duration(minutes: 5);
  static const Duration _balanceCacheDuration = Duration(minutes: 2);
  static const Duration _gasPriceCacheDuration = Duration(minutes: 1);
  static const Duration _blockNumberCacheDuration = Duration(seconds: 30);
  static const Duration _networkConfigCacheDuration = Duration(hours: 1);
  
  // Cache size limits
  static const int _maxCacheSize = 1000;
  static const int _cleanupThreshold = 800;

  /// Store data in cache with expiration
  static void set<T>(String key, T data, {Duration? duration}) {
    final expiration = DateTime.now().add(duration ?? _defaultDuration);
    
    // Clean up cache if it's getting too large
    if (_cache.length > _maxCacheSize) {
      _cleanup();
    }
    
    // Cancel existing timer for this key
    _timers[key]?.cancel();
    
    // Store the data
    _cache[key] = CacheEntry(
      data: data,
      expiration: expiration,
      createdAt: DateTime.now(),
    );
    
    // Set up automatic cleanup timer
    _timers[key] = Timer(duration ?? _defaultDuration, () {
      _cache.remove(key);
      _timers.remove(key);
    });
  }

  /// Get data from cache
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Check if expired
    if (DateTime.now().isAfter(entry.expiration)) {
      remove(key);
      return null;
    }
    
    return entry.data as T?;
  }

  /// Check if key exists and is not expired
  static bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    
    if (DateTime.now().isAfter(entry.expiration)) {
      remove(key);
      return false;
    }
    
    return true;
  }

  /// Remove specific key from cache
  static void remove(String key) {
    _cache.remove(key);
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Clear all cache
  static void clear() {
    _cache.clear();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Clean up expired entries
  static void _cleanup() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (now.isAfter(entry.value.expiration)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      remove(key);
    }
    
    // If still too large, remove oldest entries
    if (_cache.length > _cleanupThreshold) {
      final sortedEntries = _cache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final toRemove = _cache.length - _cleanupThreshold;
      for (int i = 0; i < toRemove; i++) {
        remove(sortedEntries[i].key);
      }
    }
  }

  /// Get cache statistics
  static CacheStats getStats() {
    final now = DateTime.now();
    int expiredCount = 0;
    
    for (final entry in _cache.values) {
      if (now.isAfter(entry.expiration)) {
        expiredCount++;
      }
    }
    
    return CacheStats(
      totalEntries: _cache.length,
      expiredEntries: expiredCount,
      activeTimers: _timers.length,
    );
  }

  // Specialized cache methods for common data types

  /// Cache wallet balance
  static void setBalance(String address, String chainId, double balance) {
    final key = 'balance_${address}_$chainId';
    set(key, balance, duration: _balanceCacheDuration);
  }

  /// Get cached wallet balance
  static double? getBalance(String address, String chainId) {
    final key = 'balance_${address}_$chainId';
    return get<double>(key);
  }

  /// Cache gas price
  static void setGasPrice(String chainId, BigInt gasPrice) {
    final key = 'gasPrice_$chainId';
    set(key, gasPrice.toString(), duration: _gasPriceCacheDuration);
  }

  /// Get cached gas price
  static BigInt? getGasPrice(String chainId) {
    final key = 'gasPrice_$chainId';
    final cached = get<String>(key);
    return cached != null ? BigInt.parse(cached) : null;
  }

  /// Cache block number
  static void setBlockNumber(String chainId, int blockNumber) {
    final key = 'blockNumber_$chainId';
    set(key, blockNumber, duration: _blockNumberCacheDuration);
  }

  /// Get cached block number
  static int? getBlockNumber(String chainId) {
    final key = 'blockNumber_$chainId';
    return get<int>(key);
  }

  /// Cache network configuration
  static void setNetworkConfig(String chainId, Map<String, dynamic> config) {
    final key = 'networkConfig_$chainId';
    set(key, json.encode(config), duration: _networkConfigCacheDuration);
  }

  /// Get cached network configuration
  static Map<String, dynamic>? getNetworkConfig(String chainId) {
    final key = 'networkConfig_$chainId';
    final cached = get<String>(key);
    return cached != null ? json.decode(cached) as Map<String, dynamic> : null;
  }

  /// Cache transaction receipt
  static void setTransactionReceipt(String txHash, Map<String, dynamic> receipt) {
    final key = 'txReceipt_$txHash';
    set(key, json.encode(receipt), duration: const Duration(hours: 24));
  }

  /// Get cached transaction receipt
  static Map<String, dynamic>? getTransactionReceipt(String txHash) {
    final key = 'txReceipt_$txHash';
    final cached = get<String>(key);
    return cached != null ? json.decode(cached) as Map<String, dynamic> : null;
  }

  /// Cache RPC endpoint health
  static void setRpcHealth(String rpcUrl, bool isHealthy) {
    final key = 'rpcHealth_$rpcUrl';
    set(key, isHealthy, duration: const Duration(minutes: 5));
  }

  /// Get cached RPC endpoint health
  static bool? getRpcHealth(String rpcUrl) {
    final key = 'rpcHealth_$rpcUrl';
    return get<bool>(key);
  }

  /// Cache token metadata
  static void setTokenMetadata(String contractAddress, String chainId, Map<String, dynamic> metadata) {
    final key = 'tokenMetadata_${contractAddress}_$chainId';
    set(key, json.encode(metadata), duration: const Duration(hours: 6));
  }

  /// Get cached token metadata
  static Map<String, dynamic>? getTokenMetadata(String contractAddress, String chainId) {
    final key = 'tokenMetadata_${contractAddress}_$chainId';
    final cached = get<String>(key);
    return cached != null ? json.decode(cached) as Map<String, dynamic> : null;
  }

  /// Cache gas estimation
  static void setGasEstimate(String txHash, Map<String, dynamic> estimate) {
    final key = 'gasEstimate_$txHash';
    set(key, json.encode(estimate), duration: const Duration(minutes: 10));
  }

  /// Get cached gas estimation
  static Map<String, dynamic>? getGasEstimate(String txHash) {
    final key = 'gasEstimate_$txHash';
    final cached = get<String>(key);
    return cached != null ? json.decode(cached) as Map<String, dynamic> : null;
  }

  /// Preload common data
  static Future<void> preloadCommonData(String chainId, String? address) async {
    // This method can be used to preload frequently accessed data
    // Implementation would depend on specific use cases
  }

  /// Get cache key for debugging
  static List<String> getAllKeys() {
    return _cache.keys.toList();
  }

  /// Get cache entry details for debugging
  static Map<String, dynamic> getCacheDetails(String key) {
    final entry = _cache[key];
    if (entry == null) return {};
    
    return {
      'key': key,
      'hasData': entry.data != null,
      'dataType': entry.data.runtimeType.toString(),
      'createdAt': entry.createdAt.toIso8601String(),
      'expiration': entry.expiration.toIso8601String(),
      'isExpired': DateTime.now().isAfter(entry.expiration),
      'timeToExpiry': entry.expiration.difference(DateTime.now()).inSeconds,
    };
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiration;
  final DateTime createdAt;

  CacheEntry({
    required this.data,
    required this.expiration,
    required this.createdAt,
  });
}

class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int activeTimers;

  CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.activeTimers,
  });

  int get validEntries => totalEntries - expiredEntries;
  double get hitRatio => totalEntries > 0 ? validEntries / totalEntries : 0.0;

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries, timers: $activeTimers, hitRatio: ${(hitRatio * 100).toStringAsFixed(1)}%)';
  }
}

