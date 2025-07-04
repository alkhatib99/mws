import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart'; // Corrected import
import 'package:url_launcher/url_launcher.dart';
import 'package:reown_sign/models/session_models.dart'; // Import SessionRequest
import 'package:reown_core/models/basic_models.dart'; // Import Errors
import 'package:reown_core/verify/models/verify_context.dart'; // Import VerifyContext
import 'package:reown_sign/models/json_rpc_models.dart'; // Import SessionRequestParams
import 'package:reown_sign/models/basic_models.dart'; // Import ReownSignError
import 'package:reown_sign/models/json_rpc_models.dart'; // Import RequiredNamespace

class WalletConnectService {
  ReownAppKit? _appKit;
  String? _connectedAddress;
  String? _connectedWalletName;
  String? _sessionTopic; // Store the session topic

  Function(String address, String walletName)? onSessionEstablished;
  Function()? onSessionDisconnected;
  Function(String error)? onConnectionError;

  Future<void> initialize({required String projectId}) async {
    _appKit = ReownAppKit(
      core: ReownCore(
        projectId: projectId,
      ),
      metadata: PairingMetadata(
        name: 'BAG MWS DApp',
        description: 'Multi Wallet Sender DApp',
        url: 'https://your-dapp-url.com/', // Replace with your DApp's URL
        icons: ['https://your-dapp-url.com/logo.png'], // Replace with your DApp's logo
        redirect: Redirect(
          native: 'mwsdapp://',
          universal: 'https://your-dapp-url.com/redirect',
        ),
      ),
    );

    await _appKit!.init();

    _appKit!.onSessionConnect.subscribe((SessionConnect? event) {
      if (event != null && event.session.namespaces.isNotEmpty) {
        final address = event.session.namespaces['eip155']?.accounts.first.split(':').last;
        final walletName = event.session.peer.metadata.name;
        if (address != null && walletName != null) {
          _connectedAddress = address;
          _connectedWalletName = walletName;
          _sessionTopic = event.session.topic;
          onSessionEstablished?.call(address, walletName);
        }
      }
    });

    _appKit!.onSessionDelete.subscribe((SessionDelete? event) {
      _connectedAddress = null;
      _connectedWalletName = null;
      _sessionTopic = null;
      onSessionDisconnected?.call();
    });
  }

  Future<String?> createPairingUri({required List<String> chains, required Map<String, RequiredNamespace> requiredNamespaces}) async {
    try {
      final uri = await _appKit!.connect(
        requiredNamespaces: requiredNamespaces,
      );
      return uri.uri.toString();
    } catch (e) {
      onConnectionError?.call('Failed to create pairing URI: ${e.toString()}');
      return null;
    }
  }

  Future<void> disconnect() async {
    if (_appKit != null && _sessionTopic != null) {
      try {
        await _appKit!.disconnectSession(topic: _sessionTopic!, reason: ReownSignError(code: 1000, message: 'User disconnected')); // Corrected Errors to ReownErrors
      } catch (e) {
        onConnectionError?.call('Failed to disconnect: ${e.toString()}');
      }
    }
  }

  Future<String?> sendTransaction({
    required String chainId,
    required String from,
    required String to,
    required String data,
    required String value,
    required String gasPrice,
    required String gasLimit,
  }) async {
    if (_sessionTopic == null) {
      onConnectionError?.call('No active session to send transaction.');
      return null;
    }
    try {
      final result = await _appKit!.request(
        topic: _sessionTopic!,
        chainId: chainId,
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': from,
              'to': to,
              'data': data,
              'value': value,
              'gasPrice': gasPrice,
              'gasLimit': gasLimit,
            }
          ],
        ),
      );
      return result.toString();
    } catch (e) {
      onConnectionError?.call('Transaction failed: ${e.toString()}');
      return null;
    }
  }

  Future<String?> personalSign({
    required String chainId,
    required String message,
    required String address,
  }) async {
    if (_sessionTopic == null) {
      onConnectionError?.call('No active session to sign message.');
      return null;
    }
    try {
      final result = await _appKit!.request(
        topic: _sessionTopic!,
        chainId: chainId,
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [message, address],
        ),
      );
      return result.toString();
    } catch (e) {
      onConnectionError?.call('Personal sign failed: ${e.toString()}');
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
        'deepLink': 'metamask://open_url?url=',
      },
      {
        'name': 'Trust Wallet',
        'icon': 'assets/images/trustwallet_logo.png',
        'description': 'Connect via Trust Wallet mobile app',
        'status': 'available',
        'deepLink': 'trust://open_url?url=',
      },
      {
        'name': 'Coinbase Wallet',
        'icon': 'assets/images/coinbase_logo.png',
        'description': 'Connect via Coinbase Wallet mobile app',
        'status': 'available',
        'deepLink': 'coinbase://dapp?url=',
      },
    ];
  }
}



