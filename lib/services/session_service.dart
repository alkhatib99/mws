import 'dart:async';
import 'dart:html' as html;
import 'package:get/get.dart';
import '../../app/controllers/wallet_connect_controller.dart';
import '../../app/routes/app_routes.dart';

class SessionService extends GetxService {
  static const int _sessionTimeoutMinutes = 10;
  static const String _storageKey = 'mws_session_data';
  
  Timer? _sessionTimer;
  Timer? _activityTimer;
  DateTime? _lastActivity;
  
  final RxBool isSessionActive = false.obs;
  final RxString connectedWallet = ''.obs;
  final RxString connectedAddress = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSessionManagement();
    _setupVisibilityListener();
    _setupActivityListeners();
  }

  @override
  void onClose() {
    _sessionTimer?.cancel();
    _activityTimer?.cancel();
    super.onClose();
  }

  /// Initialize session management
  void _initializeSessionManagement() {
    // Check for existing session on startup
    _checkExistingSession();
    
    // Start activity monitoring
    _startActivityMonitoring();
  }

  /// Check if there's an existing valid session
  void _checkExistingSession() {
    try {
      final sessionData = html.window.localStorage[_storageKey];
      if (sessionData != null) {
        final data = sessionData.split('|');
        if (data.length >= 3) {
          final timestamp = int.tryParse(data[0]);
          final wallet = data[1];
          final address = data[2];
          
          if (timestamp != null) {
            final sessionAge = DateTime.now().millisecondsSinceEpoch - timestamp;
            final maxAge = _sessionTimeoutMinutes * 60 * 1000; // Convert to milliseconds
            
            if (sessionAge < maxAge) {
              // Session is still valid
              _restoreSession(wallet, address);
              return;
            }
          }
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
    
    _resetSessionTimer();
    print('Session restored: $wallet - $address');
  }

  /// Start a new session
  void startSession(String walletName, String walletAddress) {
    isSessionActive.value = true;
    connectedWallet.value = walletName;
    connectedAddress.value = walletAddress;
    
    // Store session data
    _storeSessionData(walletName, walletAddress);
    
    // Start session timer
    _resetSessionTimer();
    
    print('Session started: $walletName - $walletAddress');
  }

  /// End the current session
  void endSession({bool showMessage = true}) {
    isSessionActive.value = false;
    connectedWallet.value = '';
    connectedAddress.value = '';
    
    // Clear stored session data
    _clearSessionData();
    
    // Cancel timers
    _sessionTimer?.cancel();
    
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
        'Your wallet has been disconnected for security.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
    
    // Navigate to wallet connect page
    Get.offAllNamed(Routes.walletConnect);
    
    print('Session ended');
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

  /// Reset the session timeout timer
  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(
      Duration(minutes: _sessionTimeoutMinutes),
      () => endSession(),
    );
    _lastActivity = DateTime.now();
  }

  /// Start monitoring user activity
  void _startActivityMonitoring() {
    _activityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _checkActivity(),
    );
  }

  /// Check for user activity and reset timer if needed
  void _checkActivity() {
    if (!isSessionActive.value) return;
    
    final now = DateTime.now();
    if (_lastActivity != null) {
      final inactiveTime = now.difference(_lastActivity!);
      
      if (inactiveTime.inMinutes >= _sessionTimeoutMinutes) {
        endSession();
      }
    }
  }

  /// Record user activity
  void recordActivity() {
    if (isSessionActive.value) {
      _lastActivity = DateTime.now();
    }
  }

  /// Setup page visibility listener for tab/window close detection
  void _setupVisibilityListener() {
    html.document.addEventListener('visibilitychange', (event) {
      if (html.document.hidden == true) {
        // Page is hidden (tab switched or window minimized)
        _handlePageHidden();
      } else {
        // Page is visible again
        _handlePageVisible();
      }
    });

    // Listen for beforeunload event (tab/window closing)
    html.window.addEventListener('beforeunload', (event) {
      if (isSessionActive.value) {
        endSession(showMessage: false);
      }
    });
  }

  /// Handle page becoming hidden
  void _handlePageHidden() {
    // Start a shorter timer for hidden state
    if (isSessionActive.value) {
      _sessionTimer?.cancel();
      _sessionTimer = Timer(
        const Duration(minutes: 2), // Shorter timeout when hidden
        () => endSession(),
      );
    }
  }

  /// Handle page becoming visible
  void _handlePageVisible() {
    if (isSessionActive.value) {
      recordActivity();
      _resetSessionTimer(); // Reset to full timeout
    }
  }

  /// Setup activity listeners for mouse and keyboard events
  void _setupActivityListeners() {
    // Mouse movement
    html.document.addEventListener('mousemove', (event) {
      recordActivity();
    });

    // Mouse clicks
    html.document.addEventListener('click', (event) {
      recordActivity();
    });

    // Keyboard activity
    html.document.addEventListener('keypress', (event) {
      recordActivity();
    });

    // Scroll activity
    html.document.addEventListener('scroll', (event) {
      recordActivity();
    });

    // Touch events for mobile
    html.document.addEventListener('touchstart', (event) {
      recordActivity();
    });
  }

  /// Get remaining session time in minutes
  int getRemainingSessionTime() {
    if (!isSessionActive.value || _lastActivity == null) return 0;
    
    final elapsed = DateTime.now().difference(_lastActivity!);
    final remaining = _sessionTimeoutMinutes - elapsed.inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if session is about to expire (less than 2 minutes remaining)
  bool isSessionExpiringSoon() {
    return getRemainingSessionTime() <= 2;
  }

  /// Extend session (reset timer)
  void extendSession() {
    if (isSessionActive.value) {
      _resetSessionTimer();
      Get.snackbar(
        'Session Extended',
        'Your session has been extended for another $_sessionTimeoutMinutes minutes.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

