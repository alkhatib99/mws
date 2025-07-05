import 'dart:async';

abstract class WalletServiceInterface {
  // Connection status
  bool get isConnected;
  String? get connectedAddress;
  String? get connectedWalletName;
  String? get currentChainId;

  // Event streams
  Stream<String> get onAccountChanged;
  Stream<String> get onChainChanged;
  Stream<bool> get onConnectionChanged;

  // Connection methods
  Future<bool> connect();
  Future<void> disconnect();
  
  // Transaction methods
  Future<String?> sendTransaction({
    required String to,
    required String value,
    String? data,
    String? gasPrice,
    String? gasLimit,
  });
  
  Future<String?> signMessage(String message);
  
  // Network methods
  Future<bool> switchChain(String chainId);
  Future<double?> getBalance();
  
  // Utility methods
  void dispose();
}

enum WalletType {
  metamask,
  walletConnect,
  privateKey,
  coinbase,
  trust,
  ledger,
}

class WalletConnectionResult {
  final bool success;
  final String? address;
  final String? walletName;
  final String? chainId;
  final String? error;

  WalletConnectionResult({
    required this.success,
    this.address,
    this.walletName,
    this.chainId,
    this.error,
  });

  factory WalletConnectionResult.success({
    required String address,
    required String walletName,
    String? chainId,
  }) {
    return WalletConnectionResult(
      success: true,
      address: address,
      walletName: walletName,
      chainId: chainId,
    );
  }

  factory WalletConnectionResult.failure(String error) {
    return WalletConnectionResult(
      success: false,
      error: error,
    );
  }
}

class TransactionResult {
  final bool success;
  final String? transactionHash;
  final String? error;

  TransactionResult({
    required this.success,
    this.transactionHash,
    this.error,
  });

  factory TransactionResult.success(String transactionHash) {
    return TransactionResult(
      success: true,
      transactionHash: transactionHash,
    );
  }

  factory TransactionResult.failure(String error) {
    return TransactionResult(
      success: false,
      error: error,
    );
  }
}

