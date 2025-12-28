import 'dart:async';
import 'dart:math';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:mws/services/decentralized_rpc_service.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  static const int _defaultGasLimit = 21000;
  static const double _gasPriceMultiplier = 1.1; // 10% buffer for gas price
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Estimate gas for a transaction
  static Future<TransactionGasEstimate> estimateGas({
    required String chainId,
    required String from,
    required String to,
    required String value,
    String? data,
    Web3Client? customClient,
  }) async {
    try {
      final client = customClient ?? await DecentralizedRpcService.createWeb3Client(chainId);
      if (client == null) {
        throw Exception('No available RPC endpoint for chain $chainId');
      }

      final fromAddress = EthereumAddress.fromHex(from);
      final toAddress = EthereumAddress.fromHex(to);
      final valueWei = EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.parse(value));

      // Estimate gas limit
      BigInt gasLimit;
      try {
        gasLimit = await client.estimateGas(
          sender: fromAddress,
          to: toAddress,
          value: valueWei,
          data: data != null ? hexToBytes(data) : null,
        );
        
        // Add 20% buffer to gas limit
        gasLimit = BigInt.from((gasLimit.toDouble() * 1.2).ceil());
      } catch (e) {
        // If estimation fails, use default gas limit
        gasLimit = BigInt.from(_defaultGasLimit);
      }

      // Get gas price from multiple sources
      BigInt gasPrice;
      try {
        final decentralizedGasPrice = await DecentralizedRpcService.getDecentralizedGasPrice(chainId);
        if (decentralizedGasPrice != null) {
          gasPrice = BigInt.from((decentralizedGasPrice.toDouble() * _gasPriceMultiplier).ceil());
        } else {
          final clientGasPrice = await client.getGasPrice();
          gasPrice = BigInt.from((clientGasPrice.getInWei.toDouble() * _gasPriceMultiplier).ceil());
        }
      } catch (e) {
        // Fallback gas price (20 gwei)
        gasPrice = BigInt.from(20000000000);
      }

      // Calculate total cost
      final totalCost = gasLimit * gasPrice;
      final totalCostEth = EtherAmount.fromUnitAndValue(EtherUnit.wei, totalCost);

      if (customClient == null) {
        client.dispose();
      }

      return TransactionGasEstimate(
        gasLimit: gasLimit,
        gasPrice: gasPrice,
        totalCost: totalCost,
        totalCostEth: totalCostEth.getInEther .toDouble(),
        success: true,
      );
    } catch (e) {
      return TransactionGasEstimate(
        gasLimit: BigInt.from(_defaultGasLimit),
        gasPrice: BigInt.from(20000000000),
        totalCost: BigInt.from(_defaultGasLimit * 20000000000),
        totalCostEth: 0.0004, // Approximate fallback
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Send a single transaction
  static Future<TransactionResult> sendTransaction({
    required String chainId,
    required String privateKey,
    required String to,
    required String value,
    String? data,
    BigInt? gasLimit,
    BigInt? gasPrice,
    int? nonce,
    Web3Client? customClient,
  }) async {
    try {
      final client = customClient ?? await DecentralizedRpcService.createWeb3Client(chainId);
      if (client == null) {
        throw Exception('No available RPC endpoint for chain $chainId');
      }

      final credentials = EthPrivateKey.fromHex(privateKey);
      final fromAddress = credentials.address;
      final toAddress = EthereumAddress.fromHex(to);
      final valueWei = EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.parse(value));

      // Get nonce if not provided
      final txNonce = nonce ?? await client.getTransactionCount(fromAddress);

      // Estimate gas if not provided
      BigInt txGasLimit = gasLimit ?? BigInt.from(_defaultGasLimit);
      BigInt txGasPrice = gasPrice ?? BigInt.from(20000000000);

      if (gasLimit == null || gasPrice == null) {
        final gasEstimate = await estimateGas(
          chainId: chainId,
          from: fromAddress.hex,
          to: to,
          value: value,
          data: data,
          customClient: client,
        );

        if (gasEstimate.success) {
          txGasLimit = gasLimit ?? gasEstimate.gasLimit;
          txGasPrice = gasPrice ?? gasEstimate.gasPrice;
        }
      }

      // Create transaction
      final transaction = Transaction(
        to: toAddress,
        value: valueWei,
        gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.wei, txGasPrice),
        maxGas: txGasLimit.toInt(),
        nonce: txNonce,
        data: data != null ? hexToBytes(data) : null,
      );

      // Send transaction with retry logic
      String? txHash;
      Exception? lastError;

      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          final networkConfig = DecentralizedRpcService.getNetworkConfig(chainId);
          final networkChainId = networkConfig?['chainId'] ?? int.parse(chainId);
          
          txHash = await client.sendTransaction(credentials, transaction, chainId: networkChainId);
          break;
        } catch (e) {
          lastError = Exception('Attempt ${attempt + 1} failed: ${e.toString()}');
          if (attempt < _maxRetries - 1) {
            await Future.delayed(_retryDelay);
          }
        }
      }

      if (customClient == null) {
        client.dispose();
      }

      if (txHash != null) {
        return TransactionResult(
          success: true,
          transactionHash: txHash,
          gasUsed: txGasLimit,
          gasPrice: txGasPrice,
          nonce: txNonce,
        );
      } else {
        return TransactionResult(
          success: false,
          error: lastError?.toString() ?? 'Transaction failed after $_maxRetries attempts',
        );
      }
    } catch (e) {
      return TransactionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Send multiple transactions (multi-send)
  static Future<MultiSendResult> sendMultipleTransactions({
    required String chainId,
    required String privateKey,
    required List<TransactionRequest> transactions,
    BigInt? baseGasPrice,
    Web3Client? customClient,
  }) async {
    final results = <TransactionResult>[];
    final client = customClient ?? await DecentralizedRpcService.createWeb3Client(chainId);
    
    if (client == null) {
      return MultiSendResult(
        success: false,
        results: [],
        error: 'No available RPC endpoint for chain $chainId',
      );
    }

    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final fromAddress = credentials.address;

      // Get starting nonce
      int currentNonce = await client.getTransactionCount(fromAddress);

      // Get base gas price if not provided
      BigInt gasPrice = baseGasPrice ?? BigInt.from(20000000000);
      if (baseGasPrice == null) {
        try {
          final decentralizedGasPrice = await DecentralizedRpcService.getDecentralizedGasPrice(chainId);
          if (decentralizedGasPrice != null) {
            gasPrice = BigInt.from((decentralizedGasPrice.toDouble() * _gasPriceMultiplier).ceil());
          }
        } catch (e) {
          // Use fallback gas price
        }
      }

      // Process transactions sequentially to maintain nonce order
      for (int i = 0; i < transactions.length; i++) {
        final txRequest = transactions[i];
        
        final result = await sendTransaction(
          chainId: chainId,
          privateKey: privateKey,
          to: txRequest.to,
          value: txRequest.value,
          data: txRequest.data,
          gasLimit: txRequest.gasLimit,
          gasPrice: txRequest.gasPrice ?? gasPrice,
          nonce: currentNonce + i,
          customClient: client,
        );

        results.add(result);

        // If transaction fails, decide whether to continue or stop
        if (!result.success) {
          // For now, continue with remaining transactions
          // In the future, this could be configurable
        }

        // Small delay between transactions to avoid overwhelming the RPC
        if (i < transactions.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (customClient == null) {
        client.dispose();
      }

      final successCount = results.where((r) => r.success).length;
      final totalCount = results.length;

      return MultiSendResult(
        success: successCount > 0,
        results: results,
        successCount: successCount,
        totalCount: totalCount,
        error: successCount == 0 ? 'All transactions failed' : null,
      );
    } catch (e) {
      if (customClient == null) {
        client.dispose();
      }

      return MultiSendResult(
        success: false,
        results: results,
        error: e.toString(),
      );
    }
  }

  /// Check transaction status
  static Future<TransactionStatus> getTransactionStatus({
    required String chainId,
    required String transactionHash,
    Web3Client? customClient,
  }) async {
    try {
      final client = customClient ?? await DecentralizedRpcService.createWeb3Client(chainId);
      if (client == null) {
        throw Exception('No available RPC endpoint for chain $chainId');
      }

      final receipt = await client.getTransactionReceipt(transactionHash);
      
      if (customClient == null) {
        client.dispose();
      }

      if (receipt != null) {
        return TransactionStatus(
          hash: transactionHash,
          status: receipt.status! ? TransactionStatusType.success : TransactionStatusType.failed,
          blockNumber:receipt.blockNumber. blockNum,
          gasUsed: receipt.gasUsed?.toInt(),
          confirmations: receipt.blockNumber != null 
              ? await _getConfirmations(chainId, receipt.blockNumber.blockNum, customClient)
              : 0,
        );
      } else {
        return TransactionStatus(
          hash: transactionHash,
          status: TransactionStatusType.pending,
        );
      }
    } catch (e) {
      return TransactionStatus(
        hash: transactionHash,
        status: TransactionStatusType.unknown,
        error: e.toString(),
      );
    }
  }

  /// Get number of confirmations for a transaction
  static Future<int> _getConfirmations(String chainId, int txBlockNumber, Web3Client? customClient) async {
    try {
      final client = customClient ?? await DecentralizedRpcService.createWeb3Client(chainId);
      if (client == null) return 0;

      final currentBlockNumber = await client.getBlockNumber();
      
      if (customClient == null) {
        client.dispose();
      }

      return max(0, currentBlockNumber - txBlockNumber);
    } catch (e) {
      return 0;
    }
  }

  /// Validate transaction parameters
  static TransactionValidationResult validateTransaction({
    required String to,
    required String value,
    String? data,
  }) {
    final errors = <String>[];

    // Validate recipient address
    try {
      EthereumAddress.fromHex(to);
    } catch (e) {
      errors.add('Invalid recipient address');
    }

    // Validate value
    try {
      final valueBigInt = BigInt.parse(value);
      if (valueBigInt < BigInt.zero) {
        errors.add('Value cannot be negative');
      }
    } catch (e) {
      errors.add('Invalid value format');
    }

    // Validate data if provided
    if (data != null && data.isNotEmpty) {
      if (!data.startsWith('0x')) {
        errors.add('Data must start with 0x');
      } else {
        try {
          hexToBytes(data);
        } catch (e) {
          errors.add('Invalid data format');
        }
      }
    }

    return TransactionValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

// Data classes
class TransactionGasEstimate {
  final BigInt gasLimit;
  final BigInt gasPrice;
  final BigInt totalCost;
  final double totalCostEth;
  final bool success;
  final String? error;

  TransactionGasEstimate({
    required this.gasLimit,
    required this.gasPrice,
    required this.totalCost,
    required this.totalCostEth,
    required this.success,
    this.error,
  });
}

class TransactionResult {
  final bool success;
  final String? transactionHash;
  final BigInt? gasUsed;
  final BigInt? gasPrice;
  final int? nonce;
  final String? error;

  TransactionResult({
    required this.success,
    this.transactionHash,
    this.gasUsed,
    this.gasPrice,
    this.nonce,
    this.error,
  });
}

class TransactionRequest {
  final String to;
  final String value;
  final String? data;
  final BigInt? gasLimit;
  final BigInt? gasPrice;

  TransactionRequest({
    required this.to,
    required this.value,
    this.data,
    this.gasLimit,
    this.gasPrice,
  });
}

class MultiSendResult {
  final bool success;
  final List<TransactionResult> results;
  final int? successCount;
  final int? totalCount;
  final String? error;

  MultiSendResult({
    required this.success,
    required this.results,
    this.successCount,
    this.totalCount,
    this.error,
  });
}

enum TransactionStatusType {
  pending,
  success,
  failed,
  unknown,
}

class TransactionStatus {
  final String hash;
  final TransactionStatusType status;
  final int? blockNumber;
  final int? gasUsed;
  final int confirmations;
  final String? error;

  TransactionStatus({
    required this.hash,
    required this.status,
    this.blockNumber,
    this.gasUsed,
    this.confirmations = 0,
    this.error,
  });
}

class TransactionValidationResult {
  final bool isValid;
  final List<String> errors;

  TransactionValidationResult({
    required this.isValid,
    required this.errors,
  });
}

