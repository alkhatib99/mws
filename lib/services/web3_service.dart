import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:async';
import 'package:flutter/foundation.dart';

class  Web3Service {
  late Web3Client _web3client;
  String? connectedWebAddress;
  String? _currentChainId;
  bool _isConnected = false;
  String _currentRpcUrl = '';
  
  // Event streams for wallet events
  final StreamController<String> _accountChangedController = StreamController<String>.broadcast();
  final StreamController<String> _chainChangedController = StreamController<String>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  Stream<String> get onAccountChanged => _accountChangedController.stream;
  Stream<String> get onChainChanged => _chainChangedController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  // Network configurations
  static const Map<String, Map<String, dynamic>> networks = {
    '1': {
      'name': 'Ethereum Mainnet',
      'rpcUrl': 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY',
      'chainId': 1,
      'symbol': 'ETH',
      'blockExplorer': 'https://etherscan.io',
    },
    '56': {
      'name': 'BSC Mainnet',
      'rpcUrl': 'https://bsc-dataseed.binance.org/',
      'chainId': 56,
      'symbol': 'BNB',
      'blockExplorer': 'https://bscscan.com',
    },
    '137': {
      'name': 'Polygon Mainnet',
      'rpcUrl': 'https://polygon-rpc.com/',
      'chainId': 137,
      'symbol': 'MATIC',
      'blockExplorer': 'https://polygonscan.com',
    },
    '8453': {
      'name': 'Base Mainnet',
      'rpcUrl': 'https://mainnet.base.org',
      'chainId': 8453,
      'symbol': 'ETH',
      'blockExplorer': 'https://basescan.org',
    },
  };

  void initialize(String rpcUrl) {
    _currentRpcUrl = rpcUrl;
    _web3client = Web3Client(rpcUrl, Client());
    _setupEventListeners();
  }

  void _setupEventListeners() {
    if (kIsWeb && isWeb3Available) {
      try {
        final ethereum = js.context['ethereum'];
        if (ethereum != null) {
          // Listen for account changes
          js_util.callMethod(ethereum, 'on', ['accountsChanged', js.allowInterop((accounts) {
            if (accounts != null && accounts.length > 0) {
              final newAddress = accounts[0] as String;
              if (newAddress != connectedWebAddress) {
                connectedWebAddress = newAddress;
                _accountChangedController.add(newAddress);
              }
            } else {
              _disconnect();
            }
          })]);

          // Listen for chain changes
          js_util.callMethod(ethereum, 'on', ['chainChanged', js.allowInterop((chainId) {
            final newChainId = chainId as String;
            if (newChainId != _currentChainId) {
              _currentChainId = newChainId;
              _chainChangedController.add(newChainId);
              // Update RPC URL based on new chain
              _updateRpcForChain(newChainId);
            }
          })]);

          // Listen for disconnect events
          js_util.callMethod(ethereum, 'on', ['disconnect', js.allowInterop((error) {
            _disconnect();
          })]);
        }
      } catch (e) {
        print('Error setting up event listeners: $e');
      }
    }
  }

  void _updateRpcForChain(String chainId) {
    final chainIdDecimal = int.tryParse(chainId.replaceFirst('0x', ''), radix: 16)?.toString();
    if (chainIdDecimal != null && networks.containsKey(chainIdDecimal)) {
      final networkConfig = networks[chainIdDecimal]!;
      initialize(networkConfig['rpcUrl'] as String);
    }
  }

  void _disconnect() {
    _isConnected = false;
    connectedWebAddress = null;
    _currentChainId = null;
    _connectionController.add(false);
  }

  // MetaMask (Web3) related methods
  bool get isWeb3Available {
    if (!kIsWeb) return false;
    try {
      return js.context.hasProperty('ethereum');
    } catch (e) {
      return false;
    }
  }

  bool get isConnected => _isConnected && connectedWebAddress != null;

  Future<bool> connectWebWallet() async {
    try {
      if (!isWeb3Available) {
        print('MetaMask not detected');
        return false;
      }

      final ethereum = js.context['ethereum'];
      if (ethereum == null) {
        return false;
      }

      // Request account access
      final accounts = await js_util.promiseToFuture(
        js_util.callMethod(ethereum, 'request', [
          js_util.jsify({'method': 'eth_requestAccounts'})
        ])
      );

      if (accounts != null && accounts.length > 0) {
        connectedWebAddress = accounts[0];
        _isConnected = true;
        
        // Get current chain ID
        final chainId = await js_util.promiseToFuture(
          js_util.callMethod(ethereum, 'request', [
            js_util.jsify({'method': 'eth_chainId'})
          ])
        );
        _currentChainId = chainId as String?;
        
        _connectionController.add(true);
        print('Connected to MetaMask: $connectedWebAddress on chain $_currentChainId');
        return true;
      }

      return false;
    } catch (e) {
      print('Error connecting to MetaMask: $e');
      _disconnect();
      return false;
    }
  }

  Future<String?> getCurrentChainId() async {
    if (!isConnected) return null;
    
    try {
      final ethereum = js.context['ethereum'];
      if (ethereum == null) return null;

      final chainId = await js_util.promiseToFuture(
        js_util.callMethod(ethereum, 'request', [
          js_util.jsify({'method': 'eth_chainId'})
        ])
      );
      return chainId as String?;
    } catch (e) {
      print('Error getting chain ID: $e');
      return null;
    }
  }

  Future<bool> switchChain(String chainId) async {
    if (!isConnected) return false;
    
    try {
      final ethereum = js.context['ethereum'];
      if (ethereum == null) return false;

      await js_util.promiseToFuture(
        js_util.callMethod(ethereum, 'request', [
          js_util.jsify({
            'method': 'wallet_switchEthereumChain',
            'params': [{'chainId': chainId}]
          })
        ])
      );
      
      _currentChainId = chainId;
      _updateRpcForChain(chainId);
      return true;
    } catch (e) {
      print('Error switching chain: $e');
      // If chain doesn't exist, try to add it
      if (e.toString().contains('4902')) {
        return await _addChain(chainId);
      }
      return false;
    }
  }

  Future<bool> _addChain(String chainId) async {
    try {
      final chainIdDecimal = int.tryParse(chainId.replaceFirst('0x', ''), radix: 16)?.toString();
      if (chainIdDecimal == null || !networks.containsKey(chainIdDecimal)) {
        return false;
      }

      final networkConfig = networks[chainIdDecimal]!;
      final ethereum = js.context['ethereum'];
      if (ethereum == null) return false;

      await js_util.promiseToFuture(
        js_util.callMethod(ethereum, 'request', [
          js_util.jsify({
            'method': 'wallet_addEthereumChain',
            'params': [{
              'chainId': chainId,
              'chainName': networkConfig['name'],
              'rpcUrls': [networkConfig['rpcUrl']],
              'nativeCurrency': {
                'name': networkConfig['symbol'],
                'symbol': networkConfig['symbol'],
                'decimals': 18,
              },
              'blockExplorerUrls': [networkConfig['blockExplorer']],
            }]
          })
        ])
      );
      
      return true;
    } catch (e) {
      print('Error adding chain: $e');
      return false;
    }
  }

  Future<double?> getWebWalletBalance() async {
    try {
      if (!isConnected || connectedWebAddress == null) {
        return null;
      }

      final address = EthereumAddress.fromHex(connectedWebAddress!);
      final balance = await getBalance(address);
      return balance.getInEther.toDouble();
    } catch (e) {
      print('Error getting web wallet balance: $e');
      return null;
    }
  }

  // Enhanced transaction methods
  Future<BigInt> estimateGas({
    required String from,
    required String to,
    required EtherAmount value,
    String? data,
  }) async {
    try {
      final fromAddress = EthereumAddress.fromHex(from);
      final toAddress = EthereumAddress.fromHex(to);
      
      final gasEstimate = await _web3client.estimateGas(
        sender: fromAddress,
        to: toAddress,
        value: value,
        data: data != null ? hexToBytes(data) : null,
      );
      
      return gasEstimate;
    } catch (e) {
      print('Error estimating gas: $e');
      // Return a default gas limit if estimation fails
      return BigInt.from(21000);
    }
  }

  Future<int> getTransactionCount(String address) async {
    try {
      final ethAddress = EthereumAddress.fromHex(address);
      return await _web3client.getTransactionCount(ethAddress);
    } catch (e) {
      print('Error getting transaction count: $e');
      return 0;
    }
  }

  // General Web3 methods
  Future<EtherAmount> getBalance(EthereumAddress address) async {
    return await _web3client.getBalance(address);
  }

  Future<EtherAmount> getTokenBalance(EthereumAddress tokenContractAddress, EthereumAddress ownerAddress) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(
        '[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]',
        'ERC20',
      ),
      tokenContractAddress,
    );
    final balanceOf = contract.function("balanceOf");
    final result = await _web3client.call(
      contract: contract,
      function: balanceOf,
      params: [ownerAddress],
    );
    return EtherAmount.fromUnitAndValue(EtherUnit.wei, result[0] as BigInt);
  }

  Future<String> sendTransaction({
    required String privateKey,
    required String recipientAddress,
    required EtherAmount amount,
    required int chainId,
    EtherAmount? gasPrice,
    BigInt? gasLimit,
    int? nonce,
  }) async {
    final credentials = EthPrivateKey.fromHex(privateKey);
    
    // Get nonce if not provided
    final txNonce = nonce ?? await getTransactionCount(credentials.address.hex);
    
    // Estimate gas if not provided
    final txGasLimit = gasLimit ?? await estimateGas(
      from: credentials.address.hex,
      to: recipientAddress,
      value: amount,
    );
    
    // Get gas price if not provided
    final txGasPrice = gasPrice ?? await getGasPrice();
    
    final transaction = Transaction(
      to: EthereumAddress.fromHex(recipientAddress),
      value: amount,
      gasPrice: txGasPrice,
      maxGas: txGasLimit.toInt(),
      nonce: txNonce,
    );
    
    final txHash = await _web3client.sendTransaction(credentials, transaction, chainId: chainId);
    return txHash;
  }

  Future<EtherAmount> getGasPrice() async {
    return await _web3client.getGasPrice();
  }

  // Enhanced private key methods
  bool isValidPrivateKey(String privateKey) {
    try {
      final cleanKey = privateKey.trim();
      if (cleanKey.startsWith('0x')) {
        if (cleanKey.length != 66) return false;
        EthPrivateKey.fromHex(cleanKey);
      } else {
        if (cleanKey.length != 64) return false;
        EthPrivateKey.fromHex('0x$cleanKey');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAddressFromPrivateKey(String privateKey) async {
    try {
      final cleanKey = privateKey.trim().startsWith('0x') 
          ? privateKey.trim() 
          : '0x${privateKey.trim()}';
      final credentials = EthPrivateKey.fromHex(cleanKey);
      final address = credentials.address;
      return address.hex;
    } catch (e) {
      print('Error getting address from private key: $e');
      return null;
    }
  }

  void disconnect() {
    _disconnect();
  }

  void dispose() {
    _accountChangedController.close();
    _chainChangedController.close();
    _connectionController.close();
  }

  // Utility methods
  String getNetworkName(String chainId) {
    final chainIdDecimal = int.tryParse(chainId.replaceFirst('0x', ''), radix: 16)?.toString();
    return networks[chainIdDecimal]?['name'] ?? 'Unknown Network';
  }

  String getNetworkSymbol(String chainId) {
    final chainIdDecimal = int.tryParse(chainId.replaceFirst('0x', ''), radix: 16)?.toString();
    return networks[chainIdDecimal]?['symbol'] ?? 'ETH';
  }

  List<Map<String, dynamic>> getSupportedNetworks() {
    return networks.entries.map((entry) => {
      'chainId': entry.key,
      'hexChainId': '0x${int.parse(entry.key).toRadixString(16)}',
      'name': entry.value['name'],
      'symbol': entry.value['symbol'],
      'rpcUrl': entry.value['rpcUrl'],
      'blockExplorer': entry.value['blockExplorer'],
    }).toList();
  }
}

