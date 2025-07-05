import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/services/wallet_connect_service.dart';
import 'package:mws/services/web3_service.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/credentials.dart'; 
import 'package:mws/services/secure_storage_service.dart';
import 'package:mws/services/wallet_service_interface.dart';
import 'package:mws/app/routes/app_routes.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/session_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

class WalletController extends GetxController
    with GetSingleTickerProviderStateMixin {
  
  // Form controllers
  final TextEditingController privateKeyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  
  // Focus nodes
  final FocusNode privateKeyFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // Services
  final  Web3Service _web3Service = Web3Service();
  final  WalletConnectService _walletConnectService =  WalletConnectService();
  final SessionService _sessionService = Get.find<SessionService>();

  // Animation controllers
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString selectedWallet = "".obs;
  final RxBool isPrivateKeyVisible = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxDouble screenWidth = 0.0.obs;
  final RxDouble screenHeight = 0.0.obs;
  final RxString privateKeyError = "".obs;
  final RxString passwordError = "".obs;
  final RxString connectedAddress = "".obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxString connectionType = "".obs; // 'metamask', 'walletconnect', 'privatekey'
  final RxString currentChainId = "1".obs; // Default to Ethereum mainnet
  final RxString currentNetworkName = "Ethereum Mainnet".obs;
  final RxString currentNetworkSymbol = "ETH".obs;
  final RxBool isConnected = false.obs;
  final RxBool showPasswordDialog = false.obs;
  final RxBool rememberPassword = false.obs;

  // Error handling
  final RxBool hasError = false.obs;
  final RxString lastError = "".obs;
  final RxBool canRetry = false.obs;

  // Subscription for service events
  StreamSubscription? _accountChangedSubscription;
  StreamSubscription? _chainChangedSubscription;
  StreamSubscription? _connectionChangedSubscription;
  StreamSubscription? _wcSessionEstablishedSubscription;
  StreamSubscription? _wcSessionDisconnectedSubscription;
  StreamSubscription? _wcConnectionErrorSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _initializeServices();
    _setupEventListeners();
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
    _web3Service.dispose();
    _walletConnectService.dispose();
    super.onClose();
  }

  void _initializeAnimations() {
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeInOut,
    ));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    fadeController.forward();
  }

  void _initializeServices() {
    // Initialize Web3 service with default RPC
    _web3Service.initialize('https://mainnet.infura.io/v3/YOUR_INFURA_KEY');
    
    // Initialize WalletConnect service
    final projectId = dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';
    if (projectId.isNotEmpty) {
      _walletConnectService.initialize(projectId: projectId);
    }
  }

  void _setupEventListeners() {
    // Web3 service events
    _accountChangedSubscription = _web3Service.onAccountChanged.listen((address) {
      connectedAddress.value = address;
      _updateBalance();
    });

    _chainChangedSubscription = _web3Service.onChainChanged.listen((chainId) {
      currentChainId.value = chainId;
      _updateNetworkInfo(chainId);
      _updateBalance();
    });

    _connectionChangedSubscription = _web3Service.onConnectionChanged.listen((connected) {
      isConnected.value = connected;
      if (!connected) {
        _clearConnectionData();
      }
    });

    // WalletConnect service events
    _wcSessionEstablishedSubscription = _walletConnectService.onSessionEstablished.listen((data) {
      connectedAddress.value = data['address']!;
      connectionType.value = 'walletconnect';
      currentChainId.value = data['chainId']!;
      isConnected.value = true;
      _updateNetworkInfo(data['chainId']!);
      _updateBalance();
      _sessionService.startSession(data['walletName']!, data['address']!);
      _showSnackbar('Success', 'Connected to ${data['walletName']}!');
      Get.offNamed(Routes.multiSend);
    });

    _wcSessionDisconnectedSubscription = _walletConnectService.onSessionDisconnected.listen((_) {
      _clearConnectionData();
      _showSnackbar('Disconnected', 'Wallet disconnected');
    });

    _wcConnectionErrorSubscription = _walletConnectService.onConnectionError.listen((error) {
      _showSnackbar('Error', error);
      isLoading.value = false;
      selectedWallet.value = '';
    });
  }

  void _cancelSubscriptions() {
    _accountChangedSubscription?.cancel();
    _chainChangedSubscription?.cancel();
    _connectionChangedSubscription?.cancel();
    _wcSessionEstablishedSubscription?.cancel();
    _wcSessionDisconnectedSubscription?.cancel();
    _wcConnectionErrorSubscription?.cancel();
  }

  void _clearConnectionData() {
    isConnected.value = false;
    connectedAddress.value = '';
    connectionType.value = '';
    walletBalance.value = 0.0;
    _sessionService.endSession();
  }

  Future<void> _checkExistingConnection() async {
    // Check if there's an existing MetaMask connection
    if (_web3Service.isWeb3Available && _web3Service.isConnected) {
      connectedAddress.value = _web3Service.connectedWebAddress ?? '';
      connectionType.value = 'metamask';
      isConnected.value = true;
      final chainId = await _web3Service.getCurrentChainId();
      if (chainId != null) {
        currentChainId.value = chainId;
        _updateNetworkInfo(chainId);
      }
      _updateBalance();
    }

    // Check if there's a stored private key
    if (await SecureStorageService.hasPrivateKey()) {
      // Could show a dialog to unlock with password
    }
  }

  void _updateNetworkInfo(String chainId) {
    currentNetworkName.value = _web3Service.getNetworkName(chainId);
    currentNetworkSymbol.value = _web3Service.getNetworkSymbol(chainId);
  }

  Future<void> _updateBalance() async {
    if (!isConnected.value || connectedAddress.value.isEmpty) return;

    try {
      double? balance;
      if (connectionType.value == 'metamask') {
        balance = await _web3Service.getWebWalletBalance();
      } else if (connectionType.value == 'privatekey') {
        final address = EthereumAddress.fromHex(connectedAddress.value);
        final balanceWei = await _web3Service.getBalance(address);
        balance = balanceWei.getInEther.toDouble();
      }
      
      if (balance != null) {
        walletBalance.value = balance;
      }
    } catch (e) {
      print('Error updating balance: $e');
    }
  }

  // Update screen dimensions for responsive design
  void updateScreenSize(Size size) {
    screenWidth.value = size.width;
    screenHeight.value = size.height;
  }

  // Responsive design properties
  bool get isMobile => screenWidth.value < 600;
  bool get isTablet => screenWidth.value >= 600 && screenWidth.value < 1024;
  bool get isDesktop => screenWidth.value >= 1024;

  double get maxContentWidth => isDesktop ? 800 : double.infinity;
  double get horizontalPadding {
    if (isDesktop) return 48.0;
    if (isTablet) return 32.0;
    return 20.0;
  }

  double get verticalSpacing {
    if (isDesktop) return 48.0;
    if (isTablet) return 36.0;
    return 24.0;
  }

  // Wallet data
  final RxList<Map<String, dynamic>> wallets = <Map<String, dynamic>>[
    {
      'name': 'MetaMask',
      'icon': 'assets/images/metamask_logo.png',
      'description': 'Connect via MetaMask browser extension or mobile app',
      'status': 'available',
      'type': 'extension',
    },
    {
      'name': 'WalletConnect',
      'icon': 'assets/images/walletconnect_logo.png',
      'description': 'Connect any mobile wallet via WalletConnect protocol',
      'status': 'available',
      'type': 'walletconnect',
    },
    {
      'name': 'Trust Wallet',
      'icon': 'assets/images/trustwallet_logo.png',
      'description': 'Connect via Trust Wallet mobile app',
      'status': 'available',
      'type': 'walletconnect',
    },
    {
      'name': 'Coinbase Wallet',
      'icon': 'assets/images/coinbase_logo.png',
      'description': 'Connect via Coinbase Wallet mobile app',
      'status': 'available',
      'type': 'walletconnect',
    },
  ].obs;

  final  subtitleFontSize = 14.0;

   navigateToMultiSendFromPrivateKey() async {
    
   }

  // final transactionLinks  =  ; // Default subtitle font size

  // Validation methods
  String? validatePrivateKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Private key is required';
    }

    final trimmedValue = value.trim();
    if (!_web3Service.isValidPrivateKey(trimmedValue)) {
      return 'Invalid private key format';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
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
      bool success = false;

      if (walletName == 'MetaMask') {
        success = await _connectMetaMask();
      } else if (walletName == 'WalletConnect' || 
                 walletName == 'Trust Wallet' || 
                 walletName == 'Coinbase Wallet') {
        success = await _connectWalletConnect(walletName);
      }

      if (success && connectedAddress.value.isNotEmpty) {
        _sessionService.startSession(walletName, connectedAddress.value);
        _showSnackbar('Success', 'Connected to $walletName!');
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(Routes.multiSend);
        });
      }
    } catch (e) {
      hasError.value = true;
      lastError.value = e.toString();
      canRetry.value = true;
      _showSnackbar('Error', 'Connection failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
      selectedWallet.value = '';
    }
  }

  Future<bool> _connectMetaMask() async {
    if (!_web3Service.isWeb3Available) {
      throw Exception('MetaMask not detected. Please install MetaMask extension.');
    }

    final success = await _web3Service.connectWebWallet();
    if (success && _web3Service.isConnected) {
      connectedAddress.value = _web3Service.connectedWebAddress ?? '';
      connectionType.value = 'metamask';
      isConnected.value = true;
      
      final chainId = await _web3Service.getCurrentChainId();
      if (chainId != null) {
        currentChainId.value = chainId;
        _updateNetworkInfo(chainId);
      }
      
      await _updateBalance();
      return true;
    }
    
    return false;
  }

  Future<bool> _connectWalletConnect(String walletName) async {
    try {
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
        if (walletName != 'WalletConnect') {
          // Open specific wallet app
          await _walletConnectService.openWalletApp(walletName, uri);
        } else {
          // Show QR code or wallet selection
          _showWalletConnectModal(uri);
        }
        return true; // Connection will be handled by event listeners
      }
      
      return false;
    } catch (e) {
      throw Exception('Failed to initiate WalletConnect: ${e.toString()}');
    }
  }

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
                'Scan QR code with your mobile wallet or choose a wallet below',
                style: TextStyle(
                  color: AppTheme.lightGrayText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // QR Code would go here
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('QR Code\n(Implementation needed)'),
                ),
              ),
              const SizedBox(height: 24),
              ...(_walletConnectService.getSupportedWallets().map((wallet) => 
                ListTile(
                  leading: Icon(Icons.account_balance_wallet, color: AppTheme.primaryAccent),
                  title: Text(wallet['name']!, style: TextStyle(color: AppTheme.whiteText)),
                  subtitle: Text(wallet['description']!, style: TextStyle(color: AppTheme.lightGrayText)),
                  onTap: () {
                    Get.back();
                    _walletConnectService.openWalletApp(wallet['name']!, uri);
                  },
                ),
              )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: TextStyle(color: AppTheme.lightGrayText)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Private key import methods
  Future<void> importPrivateKey() async {
    privateKeyError.value = '';

    if (!formKey.currentState!.validate()) {
      return;
    }

    final privateKey = privateKeyController.text.trim();
    final validationError = validatePrivateKey(privateKey);

    if (validationError != null) {
      privateKeyError.value = validationError;
      _showSnackbar('Validation Error', validationError);
      return;
    }

    // Show password dialog for encryption
    showPasswordDialog.value = true;
    _showPasswordDialog();
  }

  void _showPasswordDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isDesktop ? 400 : screenWidth.value * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassCardDecoration,
          child: Form(
            key: passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Secure Your Private Key',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.whiteText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter a password to encrypt your private key',
                  style: TextStyle(color: AppTheme.lightGrayText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  obscureText: !isPasswordVisible.value,
                  validator: validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.lightGrayText,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => CheckboxListTile(
                  title: Text(
                    'Remember password for this session',
                    style: TextStyle(color: AppTheme.lightGrayText, fontSize: 14),
                  ),
                  value: rememberPassword.value,
                  onChanged: (value) => rememberPassword.value = value ?? false,
                  controlAffinity: ListTileControlAffinity.leading,
                )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          showPasswordDialog.value = false;
                          passwordController.clear();
                        },
                        child: Text('Cancel', style: TextStyle(color: AppTheme.lightGrayText)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _processPrivateKeyImport,
                        style: AppTheme.primaryButtonStyle,
                        child: const Text('Import'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _processPrivateKeyImport() async {
    if (!passwordFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final privateKey = privateKeyController.text.trim();
      final password = passwordController.text.trim();

      // Store encrypted private key
      final stored = await SecureStorageService.savePrivateKey(privateKey, password);
      if (!stored) {
        throw Exception('Failed to store private key securely');
      }

      // Get address from private key
      final address = await _web3Service.getAddressFromPrivateKey(privateKey);
      if (address != null) {
        connectedAddress.value = address;
        connectionType.value = 'privatekey';
        isConnected.value = true;

        // Get balance
        final ethAddress = EthereumAddress.fromHex(address);
        final balance = await _web3Service.getBalance(ethAddress);
        walletBalance.value = balance.getInEther.toDouble();

        // Start session
        _sessionService.startSession("Private Key Import", address);

        Get.back(); // Close password dialog
        showPasswordDialog.value = false;
        passwordController.clear();
        privateKeyController.clear();

        _showSnackbar("Success", "Wallet imported successfully!");

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(Routes.multiSend);
        });
      } else {
        throw Exception("Failed to derive address from private key");
      }
    } catch (e) {
      privateKeyError.value = e.toString();
      _showSnackbar('Import Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Network switching
  Future<void> switchNetwork(String chainId) async {
    if (!isConnected.value) return;

    try {
      bool success = false;
      
      if (connectionType.value == 'metamask') {
        success = await _web3Service.switchChain('0x${int.parse(chainId).toRadixString(16)}');
      } else if (connectionType.value == 'walletconnect') {
        final result = await _walletConnectService.switchChain(chainId);
        success = result != null;
      }

      if (success) {
        currentChainId.value = chainId;
        _updateNetworkInfo(chainId);
        await _updateBalance();
        _showSnackbar('Success', 'Switched to ${_web3Service.getNetworkName('0x${int.parse(chainId).toRadixString(16)}')}');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to switch network: ${e.toString()}');
    }
  }

  // Disconnect wallet
  Future<void> disconnect() async {
    try {
      if (connectionType.value == 'metamask') {
        _web3Service.disconnect();
      } else if (connectionType.value == 'walletconnect') {
        await _walletConnectService.disconnect();
      } else if (connectionType.value == 'privatekey') {
        await SecureStorageService.clearPrivateKey();
      }

      _clearConnectionData();
      _showSnackbar('Disconnected', 'Wallet disconnected successfully');
    } catch (e) {
      _showSnackbar('Error', 'Failed to disconnect: ${e.toString()}');
    }
  }

  // Retry connection
  void retryLastConnection() {
    if (canRetry.value && lastError.value.isNotEmpty) {
      hasError.value = false;
      lastError.value = '';
      canRetry.value = false;
      // Implement retry logic based on last attempted connection
    }
  }

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
}

