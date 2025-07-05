import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:url_launcher/url_launcher.dart';

class  WalletConnectService {
  ReownAppKit? _appKit;
  String? _connectedAddress;
  String? _connectedWalletName;
  String? _sessionTopic;
  String? _currentChainId;
  
  // Event streams
  final StreamController<Map<String, String>> _sessionEstablishedController = 
      StreamController<Map<String, String>>.broadcast();
  final StreamController<void> _sessionDisconnectedController = 
      StreamController<void>.broadcast();
  final StreamController<String> _connectionErrorController = 
      StreamController<String>.broadcast();
  final StreamController<String> _chainChangedController = 
      StreamController<String>.broadcast();

  Stream<Map<String, String>> get onSessionEstablished => _sessionEstablishedController.stream;
  Stream<void> get onSessionDisconnected => _sessionDisconnectedController.stream;
  Stream<String> get onConnectionError => _connectionErrorController.stream;
  Stream<String> get onChainChanged => _chainChangedController.stream;

  // Getters
  bool get isConnected => _connectedAddress != null && _sessionTopic != null;
  String? get connectedAddress => _connectedAddress;
  String? get connectedWalletName => _connectedWalletName;
  String? get currentChainId => _currentChainId;

  Future<void> initialize({required String projectId}) async {
    try {
      _appKit = ReownAppKit(
        core: ReownCore(
          projectId: projectId,
        ),
        metadata: PairingMetadata(
          name: 'BAG MWS DApp',
          description: 'Multi Wallet Sender - Send crypto to multiple addresses at once',
          url: 'https://mws-dapp.com',
          icons: ['https://mws-dapp.com/logo.png'],
          redirect: Redirect(
            native: 'mwsdapp://',
            universal: 'https://mws-dapp.com/redirect',
          ),
        ),
      );

      await _appKit!.init();
      _setupEventListeners();
    } catch (e) {
      _connectionErrorController.add('Failed to initialize WalletConnect: ${e.toString()}');
    }
  }

  void _setupEventListeners() {
    if (_appKit == null) return;

    // Session connect event
    _appKit!.onSessionConnect.subscribe((SessionConnect? event) {
      if (event != null && event.session.namespaces.isNotEmpty) {
        try {
          final namespace = event.session.namespaces['eip155'];
          if (namespace != null && namespace.accounts.isNotEmpty) {
            final accountString = namespace.accounts.first;
            final parts = accountString.split(':');
            if (parts.length >= 3) {
              _connectedAddress = '0x${parts[2]}';
              _currentChainId = parts[1];
              _connectedWalletName = event.session.peer.metadata.name;
              _sessionTopic = event.session.topic;
              
              _sessionEstablishedController.add({
                'address': _connectedAddress!,
                'walletName': _connectedWalletName!,
                'chainId': _currentChainId!,
              });
            }
          }
        } catch (e) {
          _connectionErrorController.add('Error processing session connect: ${e.toString()}');
        }
      }
    });

    // Session delete event
    _appKit!.onSessionDelete.subscribe((SessionDelete? event) {
      _clearSession();
      _sessionDisconnectedController.add(null);
    });

    // Session update event (for chain changes)
    _appKit!.onSessionUpdate.subscribe((SessionUpdate? event) {
      if (event != null && event.namespaces.isNotEmpty) {
        try {
          final namespace = event
          .namespaces['eip155'];
          if (namespace != null && namespace.accounts.isNotEmpty) {
            final accountString = namespace.accounts.first;
            final parts = accountString.split(':');
            if (parts.length >= 3) {
              final newChainId = parts[1];
              if (newChainId != _currentChainId) {
                _currentChainId = newChainId;
                _chainChangedController.add(newChainId);
              }
            }
          }
        } catch (e) {
          _connectionErrorController.add('Error processing session update: ${e.toString()}');
        }
      }
    });
  }

  void _clearSession() {
    _connectedAddress = null;
    _connectedWalletName = null;
    _sessionTopic = null;
    _currentChainId = null;
  }

  Future<String?> createPairingUri({
    required List<String> chains,
    required Map<String, RequiredNamespace> requiredNamespaces,
  }) async {
    try {
      if (_appKit == null) {
        throw Exception('WalletConnect not initialized');
      }

      final connectResponse = await _appKit!.connect(
        requiredNamespaces: requiredNamespaces,
        optionalNamespaces: {
          'eip155': RequiredNamespace(
            methods: ['eth_sendTransaction', 'personal_sign', 'eth_signTypedData'],
            chains: chains,
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );
      
      return connectResponse.uri.toString();
    } catch (e) {
      _connectionErrorController.add('Failed to create pairing URI: ${e.toString()}');
      return null;
    }
  }

  Future<void> disconnect() async {
    if (_appKit != null && _sessionTopic != null) {
      try {
        await _appKit!.disconnectSession(
          topic: _sessionTopic!,
          reason: ReownSignError(code: 1000, message: 'User disconnected'),
        );
      } catch (e) {
        _connectionErrorController.add('Failed to disconnect: ${e.toString()}');
      }
    }
    _clearSession();
  }

  Future<String?> sendTransaction({
    required String chainId,
    required String from,
    required String to,
    required String value,
    String? data,
    String? gasPrice,
    String? gasLimit,
  }) async {
    if (!isConnected || _sessionTopic == null) {
      _connectionErrorController.add('No active session to send transaction.');
      return null;
    }

    try {
      final params = <String, dynamic>{
        'from': from,
        'to': to,
        'value': value,
      };

      if (data != null) params['data'] = data;
      if (gasPrice != null) params['gasPrice'] = gasPrice;
      if (gasLimit != null) params['gas'] = gasLimit;

      final result = await _appKit!.request(
        topic: _sessionTopic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [params],
        ),
      );
      
      return result.toString();
    } catch (e) {
      _connectionErrorController.add('Transaction failed: ${e.toString()}');
      return null;
    }
  }

  Future<String?> personalSign({
    required String chainId,
    required String message,
    required String address,
  }) async {
    if (!isConnected || _sessionTopic == null) {
      _connectionErrorController.add('No active session to sign message.');
      return null;
    }

    try {
      final result = await _appKit!.request(
        topic: _sessionTopic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [message, address],
        ),
      );
      
      return result.toString();
    } catch (e) {
      _connectionErrorController.add('Personal sign failed: ${e.toString()}');
      return null;
    }
  }

  Future<String?> switchChain(String chainId) async {
    if (!isConnected || _sessionTopic == null) {
      _connectionErrorController.add('No active session to switch chain.');
      return null;
    }

    try {
      final hexChainId = '0x${int.parse(chainId).toRadixString(16)}';
      
      await _appKit!.request(
        topic: _sessionTopic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'wallet_switchEthereumChain',
          params: [{'chainId': hexChainId}],
        ),
      );
      
      _currentChainId = chainId;
      return chainId;
    } catch (e) {
      _connectionErrorController.add('Chain switch failed: ${e.toString()}');
      return null;
    }
  }

  List<Map<String, dynamic>> getSupportedWallets() {
    return [
      {
        'name': 'MetaMask',
        'icon': 'assets/images/metamask_logo.png',
        'description': 'Connect via MetaMask mobile app',
        'status': 'available',
        'deepLink': 'metamask://wc',
        'universalLink': 'https://metamask.app.link/wc',
      },
      {
        'name': 'Trust Wallet',
        'icon': 'assets/images/trustwallet_logo.png',
        'description': 'Connect via Trust Wallet mobile app',
        'status': 'available',
        'deepLink': 'trust://wc',
        'universalLink': 'https://link.trustwallet.com/wc',
      },
      {
        'name': 'Coinbase Wallet',
        'icon': 'assets/images/coinbase_logo.png',
        'description': 'Connect via Coinbase Wallet mobile app',
        'status': 'available',
        'deepLink': 'coinbase://wc',
        'universalLink': 'https://go.cb-w.com/wc',
      },
      {
        'name': 'Rainbow',
        'icon': 'assets/images/rainbow_logo.png',
        'description': 'Connect via Rainbow mobile app',
        'status': 'available',
        'deepLink': 'rainbow://wc',
        'universalLink': 'https://rnbwapp.com/wc',
      },
      {
        'name': 'Ledger Live',
        'icon': 'assets/images/ledger_logo.png',
        'description': 'Connect via Ledger Live',
        'status': 'available',
        'deepLink': 'ledgerlive://wc',
        'universalLink': 'https://ledger.com/wc',
      },
    ];
  }

  Future<void> openWalletApp(String walletName, String uri) async {
    final wallets = getSupportedWallets();
    final wallet = wallets.firstWhere(
      (w) => w['name'] == walletName,
      orElse: () => {},
    );

    if (wallet.isEmpty) {
      _connectionErrorController.add('Wallet $walletName not supported');
      return;
    }

    try {
      final encodedUri = Uri.encodeComponent(uri);
      
      // Try deep link first
      final deepLink = '${wallet['deepLink']}?uri=$encodedUri';
      if (await canLaunchUrl(Uri.parse(deepLink))) {
        await launchUrl(Uri.parse(deepLink), mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to universal link
      final universalLink = '${wallet['universalLink']}?uri=$encodedUri';
      if (await canLaunchUrl(Uri.parse(universalLink))) {
        await launchUrl(Uri.parse(universalLink), mode: LaunchMode.externalApplication);
        return;
      }

      // If both fail, show error
      _connectionErrorController.add('Could not open $walletName. Please make sure it is installed.');
    } catch (e) {
      _connectionErrorController.add('Failed to open $walletName: ${e.toString()}');
    }
  }

  void dispose() {
    _sessionEstablishedController.close();
    _sessionDisconnectedController.close();
    _connectionErrorController.close();
    _chainChangedController.close();
  }
}

