import 'dart:async';
import 'dart:html' as html;
import 'package:get/get.dart';
import '../../../app/controllers/wallet_connect_controller.dart';
import '../../../app/routes/app_routes.dart';

class SessionService extends GetxService {
  static const String _storageKey = 'mws_session_data';
  
  final RxBool isSessionActive = false.obs;
  final RxString connectedWallet = ''.obs;
  final RxString connectedAddress = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSessionManagement();
    _setupVisibilityListener();
  }

  /// Initialize session management
  void _initializeSessionManagement() {
    // Check for existing session on startup
    _checkExistingSession();
  }

  /// Check if there's an existing valid session
  void _checkExistingSession() {
    try {
      final sessionData = html.window.localStorage[_storageKey];
      if (sessionData != null) {
        final data = sessionData.split('|');
        if (data.length >= 3) {
          final wallet = data[1];
          final address = data[2];
          
          // Restore session without time check
          _restoreSession(wallet, address);
          return;
        }
      }
    } catch (e) {
      print('Error checking existing session: $e');
    }
    
    // Clear invalid session data
    _clearSessionData();
  }

  /// Restore a valid session
  void _restoreSession(String wallet, String address) {
    isSessionActive.value = true;
    connectedWallet.value = wallet;
    connectedAddress.value = address;
    
    // Update wallet connect controller if available
    try {
      final walletController = Get.find<WalletConnectController>();
      walletController.connectedAddress.value = address;
    } catch (e) {
      // Controller not found, that's okay
    }
    
    print('Session restored: $wallet - $address');
  }

  /// Start a new session
  void startSession(String walletName, String walletAddress) {
    isSessionActive.value = true;
    connectedWallet.value = walletName;
    connectedAddress.value = walletAddress;
    
    // Store session data
    _storeSessionData(walletName, walletAddress);
    
    print('Session started: $walletName - $walletAddress');
  }

  /// End the current session
  void endSession({bool showMessage = true}) {
    isSessionActive.value = false;
    connectedWallet.value = '';
    connectedAddress.value = '';
    
    // Clear stored session data
    _clearSessionData();
    
    // Clear wallet controller data
    try {
      final walletController = Get.find<WalletConnectController>();
      walletController.connectedAddress.value = '';
      walletController.walletBalance.value = 0.0;
    } catch (e) {
      // Controller not found, that's okay
    }
    
    if (showMessage) {
      Get.snackbar(
        'Session Ended',
        'Your wallet has been disconnected.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
    
    // Navigate to wallet connect page
    Get.offAllNamed(Routes.walletConnect);
    
    print('Session ended');
  }

  /// Switch to a different account in the same wallet
  void switchAccount(String newAddress) {
    if (isSessionActive.value && connectedWallet.value.isNotEmpty) {
      connectedAddress.value = newAddress;
      
      // Update stored session data
      _storeSessionData(connectedWallet.value, newAddress);
      
      // Update wallet controller
      try {
        final walletController = Get.find<WalletConnectController>();
        walletController.connectedAddress.value = newAddress;
      } catch (e) {
        // Controller not found, that's okay
      }
      
      Get.snackbar(
        'Account Switched',
        'Switched to account: ${newAddress.substring(0, 6)}...${newAddress.substring(newAddress.length - 4)}',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      
      print('Account switched to: $newAddress');
    }
  }

  /// Store session data in local storage
  void _storeSessionData(String wallet, String address) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sessionData = '$timestamp|$wallet|$address';
      html.window.localStorage[_storageKey] = sessionData;
    } catch (e) {
      print('Error storing session data: $e');
    }
  }

  /// Clear session data from local storage
  void _clearSessionData() {
    try {
      html.window.localStorage.remove(_storageKey);
    } catch (e) {
      print('Error clearing session data: $e');
    }
  }

  /// Setup page visibility listener for tab/window close detection
  void _setupVisibilityListener() {
    // Listen for beforeunload event (tab/window closing)
    html.window.addEventListener('beforeunload', (event) {
      if (isSessionActive.value) {
        endSession(showMessage: false);
      }
    });
  }

  void validateSession() {
    if (isSessionActive.value) {
      print('Session is valid: ${connectedWallet.value} - ${connectedAddress.value}');
    } else {
      print('No active session found.');
    }
  }
}

