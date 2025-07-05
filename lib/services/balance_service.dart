import 'dart:async';
import 'package:web3dart/web3dart.dart';
import 'package:mws/services/decentralized_rpc_service.dart';
import 'package:mws/services/cache_service.dart';
import 'package:mws/services/performance_service.dart';
import 'package:http/http.dart' as http;

class  BalanceService {
  static final Map<String, StreamController<BalanceUpdate>> _balanceStreams = {};
  static final Map<String, Timer> _refreshTimers = {};
  static const Duration _refreshInterval = Duration(seconds: 30);
  static const Duration _fastRefreshInterval = Duration(seconds: 10);

  // ERC-20 ABI for balance checking
  static const String _erc20Abi = '''[
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [{"name": "", "type": "uint8"}],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "symbol",
      "outputs": [{"name": "", "type": "string"}],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "name",
      "outputs": [{"name": "", "type": "string"}],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
  ]''';

  /// Get native token balance (ETH, BNB, MATIC, etc.)
  static Future<BalanceResult> getNativeBalance({
    required String address,
    required String chainId,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    return await PerformanceService.measureAsync(
      'getNativeBalance',
      () => _getNativeBalanceInternal(address, chainId, useCache, forceRefresh),
      metadata: {'address': address, 'chainId': chainId, 'useCache': useCache},
    );
  }

  static Future<BalanceResult> _getNativeBalanceInternal(
    String address,
    String chainId,
    bool useCache,
    bool forceRefresh,
  ) async {
    try {
      // Check cache first
      if (useCache && !forceRefresh) {
        final cachedBalance = CacheService.getBalance(address, chainId);
        if (cachedBalance != null) {
          return BalanceResult(
            success: true,
            balance: cachedBalance,
            symbol: _getNetworkSymbol(chainId),
            decimals: 18,
            fromCache: true,
          );
        }
      }

      final client = await DecentralizedRpcService.createWeb3Client(chainId);
      if (client == null) {
        throw Exception('No available RPC endpoint for chain $chainId');
      }

      final ethAddress = EthereumAddress.fromHex(address);
      final balance = await client.getBalance(ethAddress);
      final balanceEth = balance.getInEther.toDouble();

      // Cache the result
      if (useCache) {
        CacheService.setBalance(address, chainId, balanceEth);
      }

      client.dispose();

      return BalanceResult(
        success: true,
        balance: balanceEth,
        symbol: _getNetworkSymbol(chainId),
        decimals: 18,
        fromCache: false,
      );
    } catch (e) {
      return BalanceResult(
        success: false,
        error: e.toString(),
        symbol: _getNetworkSymbol(chainId),
        decimals: 18,
      );
    }
  }

  /// Get ERC-20 token balance
  static Future<BalanceResult> getTokenBalance({
    required String address,
    required String tokenAddress,
    required String chainId,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    return await PerformanceService.measureAsync(
      'getTokenBalance',
      () => _getTokenBalanceInternal(address, tokenAddress, chainId, useCache, forceRefresh),
      metadata: {'address': address, 'tokenAddress': tokenAddress, 'chainId': chainId},
    );
  }

  static Future<BalanceResult> _getTokenBalanceInternal(
    String address,
    String tokenAddress,
    String chainId,
    bool useCache,
    bool forceRefresh,
  ) async {
    try {
      final cacheKey = '${address}_${tokenAddress}_$chainId';
      
      // Check cache first
      if (useCache && !forceRefresh) {
        final cachedBalance = CacheService.getBalance(cacheKey, 'token');
        final cachedMetadata = CacheService.getTokenMetadata(tokenAddress, chainId);
        
        if (cachedBalance != null && cachedMetadata != null) {
          return BalanceResult(
            success: true,
            balance: cachedBalance,
            symbol: cachedMetadata['symbol'] ?? 'TOKEN',
            decimals: cachedMetadata['decimals'] ?? 18,
            name: cachedMetadata['name'],
            fromCache: true,
          );
        }
      }

      final client = await DecentralizedRpcService.createWeb3Client(chainId);
      if (client == null) {
        throw Exception('No available RPC endpoint for chain $chainId');
      }

      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(tokenAddress),
      );

      // Get token metadata
      final symbolFunction = contract.function('symbol');
      final decimalsFunction = contract.function('decimals');
      final nameFunction = contract.function('name');
      final balanceOfFunction = contract.function('balanceOf');

      final futures = await Future.wait([
        client.call(contract: contract, function: symbolFunction, params: []),
        client.call(contract: contract, function: decimalsFunction, params: []),
        client.call(contract: contract, function: nameFunction, params: []),
        client.call(contract: contract, function: balanceOfFunction, params: [EthereumAddress.fromHex(address)]),
      ]);

      final symbol = futures[0][0] as String;
      final decimals = (futures[1][0] as BigInt).toInt();
      final name = futures[2][0] as String;
      final balanceWei = futures[3][0] as BigInt;

      final balance = balanceWei.toDouble() / BigInt.from(10).pow(decimals).toDouble();

      // Cache the results
      if (useCache) {
        CacheService.setBalance(cacheKey, 'token', balance);
        CacheService.setTokenMetadata(tokenAddress, chainId, {
          'symbol': symbol,
          'decimals': decimals,
          'name': name,
        });
      }

      client.dispose();

      return BalanceResult(
        success: true,
        balance: balance,
        symbol: symbol,
        decimals: decimals,
        name: name,
        fromCache: false,
      );
    } catch (e) {
      return BalanceResult(
        success: false,
        error: e.toString(),
        symbol: 'TOKEN',
        decimals: 18,
      );
    }
  }

  /// Get multiple token balances at once
  static Future<Map<String, BalanceResult>> getMultipleTokenBalances({
    required String address,
    required List<String> tokenAddresses,
    required String chainId,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    return await PerformanceService.measureAsync(
      'getMultipleTokenBalances',
      () => _getMultipleTokenBalancesInternal(address, tokenAddresses, chainId, useCache, forceRefresh),
      metadata: {'address': address, 'tokenCount': tokenAddresses.length, 'chainId': chainId},
    );
  }

  static Future<Map<String, BalanceResult>> _getMultipleTokenBalancesInternal(
    String address,
    List<String> tokenAddresses,
    String chainId,
    bool useCache,
    bool forceRefresh,
  ) async {
    final results = <String, BalanceResult>{};
    
    // Process tokens in batches to avoid overwhelming the RPC
    const batchSize = 5;
    for (int i = 0; i < tokenAddresses.length; i += batchSize) {
      final batch = tokenAddresses.skip(i).take(batchSize).toList();
      
      final futures = batch.map((tokenAddress) => 
        getTokenBalance(
          address: address,
          tokenAddress: tokenAddress,
          chainId: chainId,
          useCache: useCache,
          forceRefresh: forceRefresh,
        )
      );
      
      final batchResults = await Future.wait(futures);
      
      for (int j = 0; j < batch.length; j++) {
        results[batch[j]] = batchResults[j];
      }
      
      // Small delay between batches
      if (i + batchSize < tokenAddresses.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    return results;
  }

  /// Get comprehensive wallet balance (native + tokens)
  static Future<WalletBalance> getWalletBalance({
    required String address,
    required String chainId,
    List<String>? tokenAddresses,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    return await PerformanceService.measureAsync(
      'getWalletBalance',
      () => _getWalletBalanceInternal(address, chainId, tokenAddresses, useCache, forceRefresh),
      metadata: {'address': address, 'chainId': chainId, 'tokenCount': tokenAddresses?.length ?? 0},
    );
  }

  static Future<WalletBalance> _getWalletBalanceInternal(
    String address,
    String chainId,
    List<String>? tokenAddresses,
    bool useCache,
    bool forceRefresh,
  ) async {
    try {
      // Get native balance
      final nativeBalance = await getNativeBalance(
        address: address,
        chainId: chainId,
        useCache: useCache,
        forceRefresh: forceRefresh,
      );

      // Get token balances if requested
      Map<String, BalanceResult> tokenBalances = {};
      if (tokenAddresses != null && tokenAddresses.isNotEmpty) {
        tokenBalances = await getMultipleTokenBalances(
          address: address,
          tokenAddresses: tokenAddresses,
          chainId: chainId,
          useCache: useCache,
          forceRefresh: forceRefresh,
        );
      }

      return WalletBalance(
        address: address,
        chainId: chainId,
        nativeBalance: nativeBalance,
        tokenBalances: tokenBalances,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return WalletBalance(
        address: address,
        chainId: chainId,
        nativeBalance: BalanceResult(
          success: false,
          error: e.toString(),
          symbol: _getNetworkSymbol(chainId),
          decimals: 18,
        ),
        tokenBalances: {},
        lastUpdated: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Start real-time balance monitoring
  static Stream<BalanceUpdate> startBalanceMonitoring({
    required String address,
    required String chainId,
    List<String>? tokenAddresses,
    Duration? refreshInterval,
  }) {
    final key = '${address}_$chainId';
    
    // Close existing stream if any
    stopBalanceMonitoring(address, chainId);
    
    final controller = StreamController<BalanceUpdate>.broadcast();
    _balanceStreams[key] = controller;
    
    // Set up periodic refresh
    final interval = refreshInterval ?? _refreshInterval;
    _refreshTimers[key] = Timer.periodic(interval, (timer) async {
      try {
        final walletBalance = await getWalletBalance(
          address: address,
          chainId: chainId,
          tokenAddresses: tokenAddresses,
          useCache: false, // Always fetch fresh data for monitoring
          forceRefresh: true,
        );
        
        controller.add(BalanceUpdate(
          address: address,
          chainId: chainId,
          walletBalance: walletBalance,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        controller.addError(e);
      }
    });
    
    // Send initial balance
    getWalletBalance(
      address: address,
      chainId: chainId,
      tokenAddresses: tokenAddresses,
      useCache: true,
    ).then((balance) {
      controller.add(BalanceUpdate(
        address: address,
        chainId: chainId,
        walletBalance: balance,
        timestamp: DateTime.now(),
      ));
    }).catchError((e) {
      controller.addError(e);
    });
    
    return controller.stream;
  }

  /// Stop balance monitoring
  static void stopBalanceMonitoring(String address, String chainId) {
    final key = '${address}_$chainId';
    
    _refreshTimers[key]?.cancel();
    _refreshTimers.remove(key);
    
    _balanceStreams[key]?.close();
    _balanceStreams.remove(key);
  }

  /// Stop all balance monitoring
  static void stopAllMonitoring() {
    for (final timer in _refreshTimers.values) {
      timer.cancel();
    }
    _refreshTimers.clear();
    
    for (final controller in _balanceStreams.values) {
      controller.close();
    }
    _balanceStreams.clear();
  }

  /// Check if balance is sufficient for transaction
  static Future<SufficientBalanceResult> checkSufficientBalance({
    required String address,
    required String chainId,
    required double amount,
    required double estimatedGasCost,
    String? tokenAddress,
  }) async {
    try {
      if (tokenAddress != null) {
        // Check token balance
        final tokenBalance = await getTokenBalance(
          address: address,
          tokenAddress: tokenAddress,
          chainId: chainId,
        );
        
        final nativeBalance = await getNativeBalance(
          address: address,
          chainId: chainId,
        );
        
        return SufficientBalanceResult(
          sufficient: tokenBalance.success && 
                     tokenBalance.balance >= amount && 
                     nativeBalance.success && 
                     nativeBalance.balance >= estimatedGasCost,
          tokenBalance: tokenBalance.balance,
          nativeBalance: nativeBalance.balance,
          requiredAmount: amount,
          requiredGas: estimatedGasCost,
          tokenSymbol: tokenBalance.symbol,
          nativeSymbol: nativeBalance.symbol,
        );
      } else {
        // Check native balance
        final nativeBalance = await getNativeBalance(
          address: address,
          chainId: chainId,
        );
        
        final totalRequired = amount + estimatedGasCost;
        
        return SufficientBalanceResult(
          sufficient: nativeBalance.success && nativeBalance.balance >= totalRequired,
          nativeBalance: nativeBalance.balance,
          requiredAmount: amount,
          requiredGas: estimatedGasCost,
          nativeSymbol: nativeBalance.symbol,
        );
      }
    } catch (e) {
      return SufficientBalanceResult(
        sufficient: false,
        error: e.toString(),
      );
    }
  }

  /// Get network symbol
  static String _getNetworkSymbol(String chainId) {
    final config = DecentralizedRpcService.getNetworkConfig(chainId);
    return config?['symbol'] ?? 'ETH';
  }

  /// Clear all cached balances
  static void clearCache() {
    // This would clear balance-related cache entries
    // Implementation depends on cache service structure
  }

  /// Get balance monitoring status
  static Map<String, dynamic> getMonitoringStatus() {
    return {
      'activeStreams': _balanceStreams.length,
      'activeTimers': _refreshTimers.length,
      'monitoredAddresses': _balanceStreams.keys.toList(),
    };
  }
}

// Data classes
class BalanceResult {
  final bool success;
  final double balance;
  final String symbol;
  final int decimals;
  final String? name;
  final String? error;
  final bool fromCache;

  BalanceResult({
    required this.success,
    this.balance = 0.0,
    required this.symbol,
    required this.decimals,
    this.name,
    this.error,
    this.fromCache = false,
  });

  String get formattedBalance {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M $symbol';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K $symbol';
    } else if (balance >= 1) {
      return '${balance.toStringAsFixed(4)} $symbol';
    } else if (balance > 0) {
      return '${balance.toStringAsFixed(6)} $symbol';
    } else {
      return '0 $symbol';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'balance': balance,
      'symbol': symbol,
      'decimals': decimals,
      'name': name,
      'error': error,
      'fromCache': fromCache,
      'formattedBalance': formattedBalance,
    };
  }
}

class WalletBalance {
  final String address;
  final String chainId;
  final BalanceResult nativeBalance;
  final Map<String, BalanceResult> tokenBalances;
  final DateTime lastUpdated;
  final String? error;

  WalletBalance({
    required this.address,
    required this.chainId,
    required this.nativeBalance,
    required this.tokenBalances,
    required this.lastUpdated,
    this.error,
  });

  bool get hasError => error != null || !nativeBalance.success;
  
  List<BalanceResult> get allBalances {
    final balances = <BalanceResult>[nativeBalance];
    balances.addAll(tokenBalances.values.where((b) => b.success));
    return balances;
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'chainId': chainId,
      'nativeBalance': nativeBalance.toJson(),
      'tokenBalances': tokenBalances.map((k, v) => MapEntry(k, v.toJson())),
      'lastUpdated': lastUpdated.toIso8601String(),
      'error': error,
    };
  }
}

class BalanceUpdate {
  final String address;
  final String chainId;
  final WalletBalance walletBalance;
  final DateTime timestamp;

  BalanceUpdate({
    required this.address,
    required this.chainId,
    required this.walletBalance,
    required this.timestamp,
  });
}

class SufficientBalanceResult {
  final bool sufficient;
  final double? tokenBalance;
  final double? nativeBalance;
  final double? requiredAmount;
  final double? requiredGas;
  final String? tokenSymbol;
  final String? nativeSymbol;
  final String? error;

  SufficientBalanceResult({
    required this.sufficient,
    this.tokenBalance,
    this.nativeBalance,
    this.requiredAmount,
    this.requiredGas,
    this.tokenSymbol,
    this.nativeSymbol,
    this.error,
  });

  String get message {
    if (error != null) return 'Error checking balance: $error';
    if (sufficient) return 'Sufficient balance available';
    
    if (tokenBalance != null) {
      return 'Insufficient balance. Required: ${requiredAmount?.toStringAsFixed(4)} $tokenSymbol + ${requiredGas?.toStringAsFixed(6)} $nativeSymbol for gas';
    } else {
      final total = (requiredAmount ?? 0) + (requiredGas ?? 0);
      return 'Insufficient balance. Required: ${total.toStringAsFixed(6)} $nativeSymbol, Available: ${nativeBalance?.toStringAsFixed(6)} $nativeSymbol';
    }
  }
}

