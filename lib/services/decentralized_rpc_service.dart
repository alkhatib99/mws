import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class DecentralizedRpcService {
  static const Map<String, List<String>> _publicRpcEndpoints = {
    '1': [
      'https://eth.llamarpc.com',
      'https://rpc.ankr.com/eth',
      'https://ethereum.publicnode.com',
      'https://eth.rpc.blxrbdn.com',
      'https://cloudflare-eth.com',
    ],
    '56': [
      'https://bsc-dataseed.binance.org',
      'https://rpc.ankr.com/bsc',
      'https://bsc.publicnode.com',
      'https://bsc.rpc.blxrbdn.com',
      'https://binance.llamarpc.com',
    ],
    '137': [
      'https://polygon-rpc.com',
      'https://rpc.ankr.com/polygon',
      'https://polygon.publicnode.com',
      'https://polygon.rpc.blxrbdn.com',
      'https://polygon.llamarpc.com',
    ],
    '8453': [
      'https://mainnet.base.org',
      'https://rpc.ankr.com/base',
      'https://base.publicnode.com',
      'https://base.rpc.blxrbdn.com',
      'https://base.llamarpc.com',
    ],
    '42161': [
      'https://arb1.arbitrum.io/rpc',
      'https://rpc.ankr.com/arbitrum',
      'https://arbitrum.publicnode.com',
      'https://arbitrum.rpc.blxrbdn.com',
      'https://arbitrum.llamarpc.com',
    ],
    '10': [
      'https://mainnet.optimism.io',
      'https://rpc.ankr.com/optimism',
      'https://optimism.publicnode.com',
      'https://optimism.rpc.blxrbdn.com',
      'https://optimism.llamarpc.com',
    ],
  };

  static const Map<String, Map<String, dynamic>> _networkConfigs = {
    '1': {
      'name': 'Ethereum Mainnet',
      'chainId': 1,
      'symbol': 'ETH',
      'decimals': 18,
      'blockExplorer': 'https://etherscan.io',
      'coingeckoId': 'ethereum',
    },
    '56': {
      'name': 'BSC Mainnet',
      'chainId': 56,
      'symbol': 'BNB',
      'decimals': 18,
      'blockExplorer': 'https://bscscan.com',
      'coingeckoId': 'binancecoin',
    },
    '137': {
      'name': 'Polygon Mainnet',
      'chainId': 137,
      'symbol': 'MATIC',
      'decimals': 18,
      'blockExplorer': 'https://polygonscan.com',
      'coingeckoId': 'matic-network',
    },
    '8453': {
      'name': 'Base Mainnet',
      'chainId': 8453,
      'symbol': 'ETH',
      'decimals': 18,
      'blockExplorer': 'https://basescan.org',
      'coingeckoId': 'ethereum',
    },
    '42161': {
      'name': 'Arbitrum One',
      'chainId': 42161,
      'symbol': 'ETH',
      'decimals': 18,
      'blockExplorer': 'https://arbiscan.io',
      'coingeckoId': 'ethereum',
    },
    '10': {
      'name': 'Optimism',
      'chainId': 10,
      'symbol': 'ETH',
      'decimals': 18,
      'blockExplorer': 'https://optimistic.etherscan.io',
      'coingeckoId': 'ethereum',
    },
  };

  // User-defined custom RPC endpoints
  static final Map<String, List<String>> _customRpcEndpoints = {};
  
  // RPC endpoint health cache
  static final Map<String, bool> _endpointHealth = {};
  static final Map<String, DateTime> _lastHealthCheck = {};
  static const Duration _healthCheckInterval = Duration(minutes: 5);

  /// Add custom RPC endpoint for a chain
  static void addCustomRpcEndpoint(String chainId, String rpcUrl) {
    if (!_customRpcEndpoints.containsKey(chainId)) {
      _customRpcEndpoints[chainId] = [];
    }
    if (!_customRpcEndpoints[chainId]!.contains(rpcUrl)) {
      _customRpcEndpoints[chainId]!.add(rpcUrl);
    }
  }

  /// Remove custom RPC endpoint
  static void removeCustomRpcEndpoint(String chainId, String rpcUrl) {
    _customRpcEndpoints[chainId]?.remove(rpcUrl);
  }

  /// Get all available RPC endpoints for a chain (custom + public)
  static List<String> getRpcEndpoints(String chainId) {
    final List<String> endpoints = [];
    
    // Add custom endpoints first (higher priority)
    if (_customRpcEndpoints.containsKey(chainId)) {
      endpoints.addAll(_customRpcEndpoints[chainId]!);
    }
    
    // Add public endpoints
    if (_publicRpcEndpoints.containsKey(chainId)) {
      endpoints.addAll(_publicRpcEndpoints[chainId]!);
    }
    
    return endpoints;
  }

  /// Get the best available RPC endpoint for a chain
  static Future<String?> getBestRpcEndpoint(String chainId) async {
    final endpoints = getRpcEndpoints(chainId);
    
    for (final endpoint in endpoints) {
      if (await _isEndpointHealthy(endpoint)) {
        return endpoint;
      }
    }
    
    // If no healthy endpoint found, return the first one as fallback
    return endpoints.isNotEmpty ? endpoints.first : null;
  }

  /// Check if an RPC endpoint is healthy
  static Future<bool> _isEndpointHealthy(String rpcUrl) async {
    // Check cache first
    final lastCheck = _lastHealthCheck[rpcUrl];
    if (lastCheck != null && 
        DateTime.now().difference(lastCheck) < _healthCheckInterval) {
      return _endpointHealth[rpcUrl] ?? false;
    }

    try {
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_blockNumber',
          'params': [],
          'id': 1,
        }),
      ).timeout(const Duration(seconds: 5));

      final isHealthy = response.statusCode == 200;
      _endpointHealth[rpcUrl] = isHealthy;
      _lastHealthCheck[rpcUrl] = DateTime.now();
      
      return isHealthy;
    } catch (e) {
      _endpointHealth[rpcUrl] = false;
      _lastHealthCheck[rpcUrl] = DateTime.now();
      return false;
    }
  }

  /// Create Web3Client with the best available RPC
  static Future<Web3Client?> createWeb3Client(String chainId) async {
    final rpcUrl = await getBestRpcEndpoint(chainId);
    if (rpcUrl == null) return null;
    
    return Web3Client(rpcUrl, http.Client());
  }

  /// Get network configuration
  static Map<String, dynamic>? getNetworkConfig(String chainId) {
    return _networkConfigs[chainId];
  }

  /// Get all supported networks
  static List<Map<String, dynamic>> getSupportedNetworks() {
    return _networkConfigs.entries.map((entry) {
      final config = Map<String, dynamic>.from(entry.value);
      config['chainId'] = entry.key;
      config['hexChainId'] = '0x${int.parse(entry.key).toRadixString(16)}';
      config['rpcEndpoints'] = getRpcEndpoints(entry.key);
      return config;
    }).toList();
  }

  /// Test RPC endpoint connectivity
  static Future<Map<String, dynamic>> testRpcEndpoint(String rpcUrl) async {
    final startTime = DateTime.now();
    
    try {
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_blockNumber',
          'params': [],
          'id': 1,
        }),
      ).timeout(const Duration(seconds: 10));

      final latency = DateTime.now().difference(startTime).inMilliseconds;
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final blockNumber = data['result'];
        
        return {
          'success': true,
          'latency': latency,
          'blockNumber': blockNumber,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'latency': latency,
          'blockNumber': null,
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      return {
        'success': false,
        'latency': latency,
        'blockNumber': null,
        'error': e.toString(),
      };
    }
  }

  /// Get gas price from multiple RPC endpoints and return median
  static Future<BigInt?> getDecentralizedGasPrice(String chainId) async {
    final endpoints = getRpcEndpoints(chainId);
    final List<BigInt> gasPrices = [];
    
    // Query multiple endpoints
    final futures = endpoints.take(3).map((endpoint) async {
      try {
        final client = Web3Client(endpoint, http.Client());
        final gasPrice = await client.getGasPrice();
        client.dispose();
        return gasPrice.getInWei;
      } catch (e) {
        return null;
      }
    });
    
    final results = await Future.wait(futures);
    
    for (final result in results) {
      if (result != null) {
        gasPrices.add(result);
      }
    }
    
    if (gasPrices.isEmpty) return null;
    
    // Return median gas price
    gasPrices.sort();
    final middle = gasPrices.length ~/ 2;
    return gasPrices[middle];
  }

  /// Get block number from multiple RPC endpoints
  static Future<int?> getDecentralizedBlockNumber(String chainId) async {
    final endpoints = getRpcEndpoints(chainId);
    
    for (final endpoint in endpoints.take(3)) {
      try {
        final client = Web3Client(endpoint, http.Client());
        final blockNumber = await client.getBlockNumber();
        client.dispose();
        return blockNumber;
      } catch (e) {
        continue;
      }
    }
    
    return null;
  }

  /// Validate custom RPC endpoint
  static Future<bool> validateCustomRpcEndpoint(String rpcUrl, String expectedChainId) async {
    try {
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'jsonrpc': '2.0',
          'method': 'eth_chainId',
          'params': [],
          'id': 1,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chainIdHex = data['result'] as String?;
        if (chainIdHex != null) {
          final chainId = int.parse(chainIdHex.substring(2), radix: 16).toString();
          return chainId == expectedChainId;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear endpoint health cache
  static void clearHealthCache() {
    _endpointHealth.clear();
    _lastHealthCheck.clear();
  }

  /// Get endpoint health status
  static Map<String, bool> getEndpointHealthStatus() {
    return Map.from(_endpointHealth);
  }

  /// Get custom RPC endpoints
  static Map<String, List<String>> getCustomRpcEndpoints() {
    return Map.from(_customRpcEndpoints);
  }
}

