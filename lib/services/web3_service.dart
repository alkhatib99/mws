import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_web3/flutter_web3.dart' as web3;

class Web3Service {
  // Web-only state
  String? connectedWebAddress;

  bool get isWeb3Available => kIsWeb && web3.ethereum != null;

  Future<bool> initializeConnection(String rpcUrl) async {
    // For now, just simulate successful connection
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> connectWebWallet() async {
    if (!isWeb3Available) {
      print('Web3 not supported or Ethereum provider not found.');
      return false;
    }

    try {
      final accounts = await web3.ethereum!.requestAccount();
      connectedWebAddress = accounts.first;
      print('Connected to $connectedWebAddress');
      return true;
    } catch (e) {
      print('Failed to connect to wallet: $e');
      return false;
    }
  }

  Future<double?> getWebWalletBalance() async {
    if (connectedWebAddress == null) return null;

    try {
      final balance = await web3.provider!.getBalance(connectedWebAddress!);
      return balance.toDouble() / pow(10, 18);
    } catch (e) {
      print('Error getting balance: $e');
      return null;
    }
  }

  Future<String?> sendWebTransaction({
    required String to,
    required double amountEth,
  }) async {
    if (!isWeb3Available || connectedWebAddress == null) {
      print('Web3 is not available or wallet is not connected.');
      return null;
    }

    try {
      final valueInWei = BigInt.from(amountEth * pow(10, 18));

      final txParams = {
        'from': connectedWebAddress,
        'to': to,
        'value': '0x${valueInWei.toRadixString(16)}',
      };

      final txHash = await web3.ethereum!.request(
        // method:
        'eth_sendTransaction',
        // params:
        [txParams],
      );

      return txHash as String;
    } catch (e) {
      print('Transaction error: $e');
      return null;
    }
  }

  bool isValidPrivateKey(String privateKey) {
    final cleanKey =
        privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey;
    final hexRegex = RegExp(r'^[0-9a-fA-F]{64}\$');
    return hexRegex.hasMatch(cleanKey);
  }

  bool isValidAddress(String address) {
    final hexRegex = RegExp(r'^0x[0-9a-fA-F]{40}\$');
    return hexRegex.hasMatch(address);
  }

  Future<String?> getAddressFromPrivateKey(String privateKey) async {
    if (!isValidPrivateKey(privateKey)) return null;
    await Future.delayed(const Duration(milliseconds: 200));
    return '0x${_generateRandomHex(40)}';
  }

  Future<double?> getBalance(String address, String rpcUrl) async {
    if (!isValidAddress(address)) return null;
    await Future.delayed(const Duration(milliseconds: 300));
    return Random().nextDouble() * 10;
  }

  Future<BigInt?> estimateGasPrice(String rpcUrl) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final gasPriceGwei = 20 + Random().nextInt(30);
    return BigInt.from(gasPriceGwei * 1000000000);
  }

  Future<String?> sendTransaction({
    required String privateKey,
    required String toAddress,
    required double amountEth,
    required String rpcUrl,
    required int chainId,
  }) async {
    if (!isValidPrivateKey(privateKey) ||
        !isValidAddress(toAddress) ||
        amountEth <= 0) {
      return null;
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    return '0x${_generateRandomHex(64)}';
  }

  Future<List<String>> sendMultipleTransactions({
    required String privateKey,
    required List<String> toAddresses,
    required double amountEth,
    required String rpcUrl,
    required int chainId,
  }) async {
    List<String> hashes = [];

    for (var addr in toAddresses) {
      final hash = await sendTransaction(
        privateKey: privateKey,
        toAddress: addr,
        amountEth: amountEth,
        rpcUrl: rpcUrl,
        chainId: chainId,
      );
      if (hash != null) hashes.add(hash);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return hashes;
  }

  String _generateRandomHex(int length) {
    const chars = '0123456789abcdef';
    final random = Random();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  Map<String, dynamic> getNetworkInfo(String networkName) {
    final networks = {
      'Base': {
        'rpc': 'https://mainnet.base.org',
        'chainId': 8453,
        'explorer': 'https://basescan.org/tx/',
        'currency': 'ETH',
      },
      'Ethereum': {
        'rpc': 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY',
        'chainId': 1,
        'explorer': 'https://etherscan.io/tx/',
        'currency': 'ETH',
      },
      'BNB Chain': {
        'rpc': 'https://bsc-dataseed.binance.org/',
        'chainId': 56,
        'explorer': 'https://bscscan.com/tx/',
        'currency': 'BNB',
      },
      'Polygon': {
        'rpc': 'https://polygon-rpc.com/',
        'chainId': 137,
        'explorer': 'https://polygonscan.com/tx/',
        'currency': 'MATIC',
      },
      'Arbitrum': {
        'rpc': 'https://arb1.arbitrum.io/rpc',
        'chainId': 42161,
        'explorer': 'https://arbiscan.io/tx/',
        'currency': 'ETH',
      },
    };
    return networks[networkName] ?? networks['Ethereum']!;
  }

  void dispose() {
    // No resources to clean up in flutter_web3 yet
  }
}
