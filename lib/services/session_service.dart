import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// Conditional import for web platform
import 'package:mws/web_stub.dart' as html_stub;
// import 'package:g';

//  'dart:html' if (dart.library.io) 

import 'package:mws/app/data/models/session_data.dart';

class SessionService {
  static const String _storageKey = 'mws_session';

  // Reactive variables
  final connectedAddress = ''.obs;
  final connectedWallet = ''.obs; // To store the name of the connected wallet
  final isSessionActive = false.obs;

  SessionService() {
    _loadSession();
    _setupAutoLogout();
  }

  /// Load session data from local storage
  void _loadSession() {
    if (kIsWeb) {
      final storedData = html.window.localStorage[_storageKey];
      if (storedData != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(storedData);
          final session = SessionData.fromJson(data);
          if (session.expiry.isAfter(DateTime.now())) {
            connectedAddress.value = session.address;
            connectedWallet.value = session.walletName;
            isSessionActive.value = true;
            print('Session loaded for ${session.address}');
          } else {
            print('Session expired');
            endSession();
          }
        } catch (e) {
          print('Error loading session: $e');
          endSession();
        }
      }
    }
  }

  /// Start a new session
  void startSession(String walletName, String address) {
    final expiry = DateTime.now().add(const Duration(hours: 24)); // Session lasts 24 hours
    final session = SessionData(walletName: walletName, address: address, expiry: expiry);
    if (kIsWeb) {
      html_stub.html.window.localStorage[_storageKey] = jsonEncode(session.toJson());
    }
    connectedAddress.value = address;
    connectedWallet.value = walletName;
    isSessionActive.value = true;
    print('Session started for $address');
  }

  /// End the current session
  void endSession() {
    if (kIsWeb) {
      html_stub.html.window.localStorage.remove(_storageKey);
    }
    connectedAddress.value = '';
    connectedWallet.value = '';
    isSessionActive.value = false;
    print('Session ended');
  }

  /// Switch connected account (for MetaMask/Web3 wallets)
  void switchAccount(String newAddress) {
    connectedAddress.value = newAddress;
    // Update session in local storage if needed
    if (kIsWeb) {
      final storedData = html_stub.html.window.localStorage[_storageKey];
      if (storedData != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(storedData);
          final session = SessionData.fromJson(data);
          final updatedSession = SessionData(
            walletName: session.walletName,
            address: newAddress,
            expiry: session.expiry,
          );
          html_stub.html.window.localStorage[_storageKey] = jsonEncode(updatedSession.toJson());
        } catch (e) {
          print('Error updating session on account switch: $e');
        }
      }
    }
    print('Account switched to $newAddress');
  }

  /// Set up auto-logout on page close/refresh for web
  void _setupAutoLogout() {
    if (kIsWeb) {
      html_stub.html.window.addEventListener('beforeunload', (event) {
        endSession();
      });
    }
  }
}


