import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/data/models/wallet_status.dart';
import 'package:mws/services/wallet_connect_service.dart';
import 'package:mws/services/web3_service.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:mws/services/secure_storage_service.dart';
import 'package:mws/app/routes/app_routes.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/session_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class WalletController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Services
  final Web3Service _web3Service = Get.find<Web3Service>();
  final WalletConnectService _walletConnectService = WalletConnectService();
  final SessionService _sessionService = Get.find<SessionService>();

  // Form controllers
  final TextEditingController privateKeyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  // Focus nodes
  final FocusNode privateKeyFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // Animation controllers
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString selectedWallet = "".obs;
  final RxBool isPrivateKeyVisible = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxDouble screenWidth = 0.0.obs;
  final RxDouble screenHeight = 0.0.obs;
  final RxString privateKeyError = "".obs;
  final RxString passwordError = "".obs;
  final RxBool showPasswordDialog = false.obs;
  final RxBool rememberPassword = false.obs;
  final RxBool hasError = false.obs;
  final RxString lastError = "".obs;
  final RxBool canRetry = false.obs;

  // Wallet data
  final RxList<Map<String, dynamic>> wallets = <Map<String, dynamic>>[
    {
      'name': 'MetaMask',
      'icon': 'assets/images/metamask_logo.png',
      'description': 'Connect via MetaMask browser extension or mobile app',
      'type': 'extension',
    },
    {
      'name': 'WalletConnect',
      'icon': 'assets/images/walletconnect_logo.png',
      'description': 'Connect any mobile wallet via WalletConnect protocol',
      'type': 'walletconnect',
    },
  ].obs;

  var privateKeyFormKey;

  @override
  void onInit() {
    _initializeAnimations();
    _initializeServices();
    _setupEventListeners();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _startAnimations();
    _checkExistingConnection();
  }

  @override
  void onClose() {
    privateKeyController.dispose();
    passwordController.dispose();
    privateKeyFocusNode.dispose();
    passwordFocusNode.dispose();
    fadeController.dispose();
    _cancelSubscriptions();
    _walletConnectService.dispose();
    super.onClose();
  }

  // Initialization methods
  void _initializeAnimations() {
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() {
    fadeController.forward();
  }

  void _initializeServices() {
    const projectId = "c828aec3b3a8cdbc7a2fbf0ffe3be04a";
    if (projectId.isNotEmpty) {
      _walletConnectService.initialize();
    }
  }

  void _setupEventListeners() {
    print("Setting up event listeners in WalletController and WalletConnectController");
    _web3Service.walletStatus.listen((status) {
      if (status == WalletStatus.disconnected) {
        _clearConnectionData();
      }
    });

    _walletConnectService.onSessionEstablished.listen((data) {
      _handleWalletConnectSessionEstablished(data);
    });

    _walletConnectService.onSessionDisconnected.listen((_) {
      _clearConnectionData();
      _showSnackbar('Disconnected', 'Wallet disconnected');
    });

    _walletConnectService.onConnectionError.listen((error) {
      _showSnackbar('Error', error);
      isLoading.value = false;
      selectedWallet.value = '';
    });
  }

  void _cancelSubscriptions() {
    _walletConnectService.dispose();
  }

  // Connection management
  void _clearConnectionData() {
    _sessionService.endSession();
  }

  Future<void> _checkExistingConnection() async {
    if (_web3Service.isConnected) {
      await _updateBalance();
    } else if (await SecureStorageService.hasPrivateKey()) {
      showPasswordDialog.value = true;
      _showUnlockWalletDialog();
    }
  }

  // UI methods
  void togglePrivateKeyVisibility() {
    isPrivateKeyVisible.value = !isPrivateKeyVisible.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool isWalletConnecting(String walletName) {
    return selectedWallet.value == walletName && isLoading.value;
  }

  // Connection methods
  Future<void> connectWallet(String walletName) async {
    selectedWallet.value = walletName;
    isLoading.value = true;
    hasError.value = false;
    lastError.value = '';

    try {
      if (walletName == 'MetaMask') {
        await _connectMetaMask();
      } else if (walletName == 'WalletConnect') {
        await _connectWalletConnect();
      }

      if (_web3Service.isConnected) {
        _handleSuccessfulConnection(walletName);
      }
    } catch (e) {
      _handleConnectionError(e);
    } finally {
      isLoading.value = false;
      selectedWallet.value = '';
    }
  }

  Future<void> _connectMetaMask() async {
    await _web3Service.connectMetaMask();
  }

  Future<void> _connectWalletConnect() async {
    final uri = await _walletConnectService.createPairingUri(
      chains: ['eip155:1', 'eip155:56', 'eip155:137', 'eip155:8453'],
      requiredNamespaces: {
        'eip155': RequiredNamespace(
          methods: ['eth_sendTransaction', 'personal_sign'],
          chains: ['eip155:1', 'eip155:56', 'eip155:137', 'eip155:8453'],
          events: ['chainChanged', 'accountsChanged'],
        ),
      },
    );

    if (uri != null) {
      _showWalletConnectModal(uri);
    }
  }

  void _handleSuccessfulConnection(String walletName) {
    _sessionService.startSession(
        walletName, _web3Service.connectedAddress.value);
    _showSnackbar('Success', 'Connected to $walletName!');
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offNamed(Routes.multiSend);
    });
  }

  void _handleWalletConnectSessionEstablished(Map<String, String> data) {
    _web3Service.connectedAddress.value = data['address']!;
    _web3Service.walletStatus.value = WalletStatus.connected;
    _web3Service.currentWalletType.value = WalletType.walletconnect;
    _handleSuccessfulConnection(data['walletName']!);
  }

  void _handleConnectionError(dynamic error) {
    hasError.value = true;
    lastError.value = error.toString();
    canRetry.value = true;
    _showSnackbar('Error', 'Connection failed: ${error.toString()}');
  }

  // WalletConnect modal
  void _showWalletConnectModal(String uri) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isDesktop ? 600 : screenWidth.value * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassCardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connect Your Wallet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.whiteText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan QR code with your mobile wallet',
                style: TextStyle(color: AppTheme.lightGrayText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('QR Code')),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel',
                    style: TextStyle(color: AppTheme.lightGrayText)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Private key import methods
  Future<void> importPrivateKey() async {
    if (!formKey.currentState!.validate()) return;

    final privateKey = privateKeyController.text.trim();
    if (!_validatePrivateKey(privateKey)) return;

    showPasswordDialog.value = true;
    _showPasswordDialog();
  }

  bool _validatePrivateKey(String privateKey) {
    if (privateKey.isEmpty) {
      privateKeyError.value = 'Private key is required';
      return false;
    }
    if (!_web3Service.isValidPrivateKey(privateKey)) {
      privateKeyError.value = 'Invalid private key format';
      return false;
    }
    return true;
  }

  Future<void> _processPrivateKeyImport() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final privateKey = privateKeyController.text.trim();
      final password = passwordController.text.trim();

      await SecureStorageService.savePrivateKey(privateKey, password);
      final address = await _web3Service.importPrivateKey(privateKey);

      if (address != null) {
        _handleSuccessfulPrivateKeyImport(address);
      }
    } catch (e) {
      privateKeyError.value = e.toString();
      _showSnackbar('Import Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _unlockWalletWithPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final password = passwordController.text.trim();
      final privateKey = await SecureStorageService.getPrivateKey(password);

      if (privateKey != null) {
        final address = await _web3Service.importPrivateKey(privateKey);
        if (address != null) {
          _handleSuccessfulPrivateKeyImport(address);
        }
      }
    } catch (e) {
      passwordError.value = e.toString();
      _showSnackbar('Error', 'Failed to unlock wallet: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleSuccessfulPrivateKeyImport(String address) {
    _web3Service.connectedAddress.value = address;
    _web3Service.walletStatus.value = WalletStatus.connected;
    _web3Service.currentWalletType.value = WalletType.privatekey;

    Get.back();
    showPasswordDialog.value = false;
    passwordController.clear();
    privateKeyController.clear();

    _showSnackbar("Success", "Wallet imported successfully!");
    Get.offNamed(Routes.multiSend);
  }

  // Network switching
  Future<void> switchNetwork(String chainId) async {
    try {
      await _web3Service.switchNetwork(chainId);
      _showSnackbar('Success', 'Network switched successfully');
    } catch (e) {
      _showSnackbar('Error', 'Failed to switch network: ${e.toString()}');
    }
  }

  // Disconnect wallet
  Future<void> disconnect() async {
    try {
      _web3Service.disconnectWallet();
      _showSnackbar('Disconnected', 'Wallet disconnected successfully');
    } catch (e) {
      _showSnackbar('Error', 'Failed to disconnect: ${e.toString()}');
    }
  }

  // Helper methods
  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.secondaryBackground,
      colorText: AppTheme.whiteText,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Responsive design properties
  void updateScreenSize(Size size) {
    screenWidth.value = size.width;
    screenHeight.value = size.height;
  }

  bool get isMobile => screenWidth.value < 600;
  bool get isTablet => screenWidth.value >= 600 && screenWidth.value < 1024;
  bool get isDesktop => screenWidth.value >= 1024;
  double get maxContentWidth => isDesktop ? 800 : double.infinity;
  double get horizontalPadding => isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);
  double get verticalSpacing => isDesktop ? 48.0 : (isTablet ? 36.0 : 24.0);

  _updateBalance() async {
    try {
      // final balance =
      await _web3Service.fetchNativeBalance(
        _web3Service.connectedAddress.value,
      );
      // _web3Service.walletBalance.value = balance;
    } catch (e) {
      _showSnackbar('Error', 'Failed to fetch balance: ${e.toString()}');
    }
  }

  void _showUnlockWalletDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Unlock Wallet'),
        content: Form(
          key: passwordFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText: !isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _unlockWalletWithPassword,
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  /// Displays a dialog prompting the user to enter their password.
  ///
  /// This dialog is shown when a password is required to unlock the wallet.
  /// It includes a password input field and buttons to cancel or confirm the action.

  void _showPasswordDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Enter Password'),
        content: Form(
          key: passwordFormKey,
          child: TextFormField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            obscureText: !isPasswordVisible.value,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _processPrivateKeyImport,
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
