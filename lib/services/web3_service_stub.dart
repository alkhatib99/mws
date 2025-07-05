import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'package:flutter/foundation.dart';

class Web3Service {
  late Web3Client _web3client;
  String? connectedWebAddress;
  bool _isConnected = false;

  void initialize(String rpcUrl) {
    _web3client = Web3Client(rpcUrl, Client());
  }

  /// Check if MetaMask is available (stub for testing)
  static bool isMetaMaskAvailable() {
    return kIsWeb; // Return true only on web
  }

  bool get isConnected => _isConnected && connectedWebAddress != null;
  bool get isWeb3Available => kIsWeb && isMetaMaskAvailable();

  Future<bool> connectWebWallet() async {
    if (!kIsWeb) {
      print('Web wallet connection only available on web platform');
      return false;
    }

    // Stub implementation for testing
    try {
      // Simulate successful connection
      connectedWebAddress = '0x742d35Cc6634C0532925a3b8D4C2C2C8b8C8b8C8';
      _isConnected = true;
      return true;
    } catch (e) {
      print('Error connecting wallet: $e');
      return false;
    }
  }

  void disconnect() {
    connectedWebAddress = null;
    _isConnected = false;
  }

  Future<EtherAmount> getBalance(String address) async {
    try {
      final ethAddress = EthereumAddress.fromHex(address);
      return await _web3client.getBalance(ethAddress);
    } catch (e) {
      print('Error getting balance: $e');
      return EtherAmount.zero();
    }
  }

  Future<EtherAmount> getWebWalletBalance() async {
    if (connectedWebAddress != null) {
      return await getBalance(connectedWebAddress!);
    }
    return EtherAmount.zero();
  }

  bool isValidPrivateKey(String privateKey) {
    try {
      // Remove 0x prefix if present
      String cleanKey = privateKey.toLowerCase();
      if (cleanKey.startsWith('0x')) {
        cleanKey = cleanKey.substring(2);
      }
      
      // Check length (64 hex characters = 32 bytes)
      if (cleanKey.length != 64) {
        return false;
      }
      
      // Check if all characters are valid hex
      final hexRegex = RegExp(r'^[0-9a-f]+$');
      if (!hexRegex.hasMatch(cleanKey)) {
        return false;
      }
      
      // Check if key is not zero
      final keyInt = BigInt.parse(cleanKey, radix: 16);
      if (keyInt == BigInt.zero) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getAddressFromPrivateKey(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      return credentials.address.hex;
    } catch (e) {
      throw Exception('Invalid private key: $e');
    }
  }

  Future<String> sendTransaction({
    required String to,
    required EtherAmount amount,
    EthPrivateKey? privateKey,
  }) async {
    try {
      if (privateKey != null) {
        // Send transaction using private key
        final transaction = Transaction(
          to: EthereumAddress.fromHex(to),
          value: amount,
        );
        
        return await _web3client.sendTransaction(privateKey, transaction);
      } else if (kIsWeb && _isConnected) {
        // Stub for web transaction
        return '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
      } else {
        throw Exception('No wallet connected');
      }
    } catch (e) {
      print('Error sending transaction: $e');
      rethrow;
    }
  }

  void dispose() {
    _web3client.dispose();
  }
}

