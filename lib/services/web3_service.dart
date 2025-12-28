// lib/services/web3_service.dart
import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mws/app/controllers/wallet_connect_controller.dart';
import 'package:mws/app/data/models/transaction_info.dart';
import 'package:mws/app/data/models/wallet_status.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:reown_appkit/reown_appkit.dart';

import '../utils/constants.dart';

class Web3Service extends GetxService {
  // Reactive state
  final Rx<WalletStatus> walletStatus = WalletStatus.disconnected.obs;
  final RxString connectedAddress = ''.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxMap<String, dynamic> networkInfo = <String, dynamic>{}.obs;
  final RxBool isConnecting = false.obs;
  final Rx<WalletType> currentWalletType = WalletType.none.obs;
  final RxList<TransactionInfo> transactionHistory = <TransactionInfo>[].obs;

  late Web3Client _client;
  Timer? _sessionTimer;
  final Duration _sessionTimeout = const Duration(minutes: 30);

  @override
  void onInit() {
    super.onInit();
    _initializeDefaultNetwork();
  }

  void _initializeDefaultNetwork() {
    networkInfo.value = AppConstants.networks['Ethereum']!;
    _client = Web3Client(networkInfo['rpc'], http.Client());
  }

  Future<void> initializeWalletConnect() async {
    final walletKit = await ReownWalletKit.createInstance(
      projectId: AppConstants.REOWN_PROJECT_ID,
      metadata: const PairingMetadata(
        name: AppConstants.REOWN_APP_NAME,
        description: 'Multi Wallet Sender',
        url: 'https://alkhatibcrypto.xyz',
        icons: ['https://alkhatibcrypto.xyz/favicon.ico'],
      ),
      relayUrl: 'wss://relay.walletconnect.com',
    );

    final appKit = await ReownAppKit.createInstance(
      projectId: AppConstants.REOWN_PROJECT_ID,
      metadata: const PairingMetadata(
        name: AppConstants.REOWN_APP_NAME,
        description: 'Multi Wallet Sender',
        url: 'https://alkhatibcrypto.xyz',
        icons: ['https://alkhatibcrypto.xyz/favicon.ico'],
      ),
    );

    final controller = Get.find<WalletConnectController>();
    }

  /// Connect to MetaMask wallet.
  ///
  /// Throws [Exception] if MetaMask is not detected or if no accounts are found.
  ///
  Future<void> connectMetaMask() async {
    if (!js.context.hasProperty('ethereum')) {
      throw Exception('MetaMask not detected');
    }

    isConnecting.value = true;
    try {
      final ethereum = js.context['ethereum'];
      final accounts =
          await js_util.promiseToFuture(ethereum.callMethod('request', [
        {'method': 'eth_requestAccounts'}
      ]));

      if (accounts.isEmpty) throw Exception('No accounts found');

      connectedAddress.value = accounts[0];
      final chainId = await _getChainId(ethereum);
      await _updateNetwork(chainId);
      await fetchNativeBalance(connectedAddress.value);

      walletStatus.value = WalletStatus.connected;
      currentWalletType.value = WalletType.metamask;
      _resetSessionTimer();
    } catch (e) {
      _handleError('MetaMask connection failed', e);
      walletStatus.value = WalletStatus.disconnected;
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> connectWalletConnect() async {
    isConnecting.value = true;
    try {
      final controller = Get.find<WalletConnectController>();
      await controller.connectWallet();

      // Connection status will be updated via event listeners
    } catch (e) {
      _handleError('WalletConnect connection failed', e);
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> fetchNativeBalance(String address) async {
    try {
      final balance =
          await _client.getBalance(EthereumAddress.fromHex(address));
      walletBalance.value = balance.getValueInUnit(EtherUnit.ether).toDouble();
    } catch (e) {
      debugPrint('Balance fetch error: $e');
    }
  }

  Future<String?> importPrivateKey(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();
      connectedAddress.value = address.hex;
      walletStatus.value = WalletStatus.connected;
      currentWalletType.value = WalletType.privatekey;
      await fetchNativeBalance(connectedAddress.value);
      return connectedAddress.value;
    } catch (e) {
      _handleError('Private key import failed', e);
      return null;
    }
  }

  Future<void> connectPrivateKey(String privateKey) async {
    if (!isValidPrivateKey(privateKey)) {
      throw Exception('Invalid private key');
    }

    isConnecting.value = true;
    try {
      final address = await importPrivateKey(privateKey);
      if (address == null) throw Exception('Failed to import private key');

      final chainId = AppConstants.networks['Ethereum']!['chainId'];
      await _updateNetwork(chainId);
      _resetSessionTimer();
    } catch (e) {
      _handleError('Private key connection failed', e);
    } finally {
      isConnecting.value = false;
    }
  }

  // Network methods
  Future<void> switchNetwork(String chainId) async {
    if (currentWalletType.value == WalletType.metamask) {
      await _switchMetaMaskNetwork(chainId);
    } else if (currentWalletType.value == WalletType.walletconnect) {
      await Get.find<WalletConnectController>()
          .switchNetwork(int.parse(chainId));
    }
    _updateClientNetwork(chainId);
  }

  Future<void> _switchMetaMaskNetwork(String chainId) async {
    final ethereum = js.context['ethereum'];
    await js_util.promiseToFuture(ethereum.callMethod('request', [
      {
        'method': 'wallet_switchEthereumChain',
        'params': [
          {'chainId': '0x${int.parse(chainId).toRadixString(16)}'}
        ]
      }
    ]));
  }

  void _updateClientNetwork(String chainId) {
    // Update client with new RPC URL based on chainId
    // Implementation depends on your network configuration
  }

  // Disconnection
  Future<void> disconnectWallet() async {
    if (currentWalletType.value == WalletType.walletconnect) {
      await Get.find<WalletConnectController>().disconnect();
    }

    walletStatus.value = WalletStatus.disconnected;
    connectedAddress.value = '';
    walletBalance.value = 0.0;
    currentWalletType.value = WalletType.none;
  }

  // Utility methods
  bool get isWeb3Available => js.context.hasProperty('ethereum');
  bool get isConnected => walletStatus.value == WalletStatus.connected;

  bool isValidPrivateKey(String privateKey) {
    try {
      EthPrivateKey.fromHex(privateKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _handleError(String message, dynamic error) {
    debugPrint('$message: $error');
    Get.snackbar('Error', message, backgroundColor: AppTheme.warningRed);
  }

  @override
  Future<String> sendTransaction({
    required String to,
    required double amount,
    String? data,
  }) async {
    if (!isConnected) throw Exception('Wallet not connected');

    final transaction = Transaction(
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount),
      maxGas: 21000,
      data: data != null ? hexToBytes(data) : null,
    );

    switch (currentWalletType.value) {
      case WalletType.metamask:
        return _sendViaMetaMask(transaction);
      case WalletType.walletconnect:
        return _sendViaWalletConnect(transaction);
      default:
        throw Exception('Unsupported wallet type');
    }
  }

  Future<String> _sendViaMetaMask(Transaction transaction) async {
    final ethereum = js.context['ethereum'];
    final txHash =
        await js_util.promiseToFuture(ethereum.callMethod('request', [
      {
        'method': 'eth_sendTransaction',
        'params': [
          {
            'from': connectedAddress.value,
            'to': transaction.to?.hex,
            'value': '0x${transaction.value!.getInWei.toRadixString(16)}',
            'gas': '0x${transaction.maxGas?.toRadixString(16)}',
            if (transaction.data != null) 'data': bytesToHex(transaction.data!),
          }
        ]
      }
    ]));

    _addTransactionToHistory(transaction, txHash);
    return txHash;
  }

  Future<String> _sendViaWalletConnect(Transaction transaction) async {
    final controller = Get.find<WalletConnectController>();
    final txHash = await controller.signAndSendTransaction(
      transaction,
    );

    _addTransactionToHistory(transaction, txHash);
    return txHash;
  }

  void _addTransactionToHistory(Transaction transaction, String txHash) {
    transactionHistory.insert(
        0,
        TransactionInfo(
          hash: txHash,
          from: connectedAddress.value,
          to: transaction.to?.hex ?? '',
          value: transaction.value!.getValueInUnit(EtherUnit.ether).toDouble(),
          status: TransactionStatus.pending,
          timestamp: DateTime.now(),
          network: networkInfo['name'],
        ));
  }

  Future<void> _updateNetwork(int chainId) async {
    final network = AppConstants.networks.values.firstWhere(
      (net) => net['chainId'] == chainId,
      orElse: () => AppConstants.networks['Ethereum']!,
    );

    networkInfo.value = network;
    _client = Web3Client(network['rpc'], http.Client());
  }

  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, () {
      disconnectWallet();
      Get.snackbar(
          'Session Expired', 'You have been disconnected due to inactivity');
    });
  }

  Future<int> _getChainId(js.JsObject ethereum) async {
    final chainId =
        await js_util.promiseToFuture(ethereum.callMethod('request', [
      {'method': 'eth_chainId'}
    ]));
    return int.parse(chainId.substring(2), radix: 16);
  }

  // set _client(Web3Client _client) {}
  Web3Client get client => _client;
  set client(Web3Client client) {
    _client = client;
  }

  @override
  void onClose() {
    _sessionTimer?.cancel();
    super.onClose();
  }
}
