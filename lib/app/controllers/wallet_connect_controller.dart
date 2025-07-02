import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/credentials.dart'; // For EthereumAddress
import 'package:mws/widgets/wallet_card.dart';
import 'package:mws/widgets/custom_text_field.dart';
import 'package:mws/app/routes/app_routes.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/web3_service.dart';
import 'package:mws/services/wallet_connect_service.dart';
import 'package:mws/services/session_service.dart';
import 'package:mws/services/balance_service.dart';

class WalletConnectController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TextEditingController privateKeyController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Services
  final Web3Service _web3Service = Web3Service();
  final WalletConnectService _walletConnectService = WalletConnectService();
  final SessionService _sessionService = Get.find<SessionService>();

  // Animation controllers
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Reactive variables for UI state
  final RxBool isLoading = false.obs;
  final RxString selectedWallet = ''.obs;
  final RxBool isPrivateKeyVisible = false.obs;
  final RxDouble screenWidth = 0.0.obs;
  final RxDouble screenHeight = 0.0.obs;
  final RxString privateKeyError = ''.obs;
  final RxString connectedAddress = ''.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxString connectionType = ''.obs; // 'metamask', 'walletconnect', 'privatekey'

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _initializeWalletConnect();
  }

  @override
  void onReady() {
    super.onReady();
    _startAnimations();
  }

  @override
  void onClose() {
    privateKeyController.dispose();
    fadeController.dispose();
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

  // Update screen dimensions for responsive design
  void updateScreenSize(Size size) {
    screenWidth.value = size.width;
    screenHeight.value = size.height;
  }

  // Enhanced responsive design properties
  bool get isMobile => screenWidth.value < 600;
  bool get isTablet => screenWidth.value >= 600 && screenWidth.value < 1024;
  bool get isDesktop => screenWidth.value >= 1024;

  // Responsive layout properties
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

  double get sectionSpacing {
    if (isDesktop) return 64.0;
    if (isTablet) return 48.0;
    return 32.0;
  }

  // Typography
  double get logoSize {
    if (isDesktop) return 180.0;
    if (isTablet) return 150.0;
    return 120.0;
  }

  double get titleFontSize {
    if (isDesktop) return 42.0;
    if (isTablet) return 36.0;
    return 28.0;
  }

  double get subtitleFontSize {
    if (isDesktop) return 18.0;
    if (isTablet) return 16.0;
    return 14.0;
  }

  double get sectionTitleFontSize {
    if (isDesktop) return 24.0;
    if (isTablet) return 20.0;
    return 18.0;
  }

  double get buttonFontSize {
    if (isDesktop) return 18.0;
    if (isTablet) return 16.0;
    return 16.0;
  }

  double get walletConnectButtonHeight {
    if (isDesktop) return 60.0;
    if (isTablet) return 56.0;
    return 52.0;
  }

  // Grid layout properties
  int get gridCrossAxisCount {
    if (isDesktop) return 3;
    if (isTablet) return 2;
    return 1;
  }

  double get gridChildAspectRatio {
    if (isDesktop) return 3.5; // Wider cards for desktop
    if (isTablet) return 3.0; // Slightly wider for tablets
    return 2.7; // Taller cards for mobile
  }

  // Wallet data
  final RxList<Map<String, dynamic>> wallets = <Map<String, dynamic>>[
    {
      'name': 'MetaMask',
      'icon': 'assets/images/metamask_logo.png',
      'description': 'Connect via MetaMask browser extension or mobile app',
      'status': 'available',
      'isWalletConnect': false,
    },
    {
      'name': 'Trust Wallet',
      'icon': 'assets/images/trustwallet_logo.png',
      'description': 'Connect via Trust Wallet mobile app',
      'status': 'available',
      'isWalletConnect': false,
    },
    {
      'name': 'Coinbase Wallet',
      'icon': 'assets/images/coinbase_logo.png',
      'description': 'Connect via Coinbase Wallet mobile app',
      'status': 'available',
      'isWalletConnect': false,
    },
    {
      'name': 'WalletConnect',
      'icon': 'assets/images/walletconnect_logo.png',
      'description': 'Connect any mobile wallet via WalletConnect protocol',
      'status': 'available',
      'isWalletConnect': true,
    },
    {
      'name': 'Ledger',
      'icon': 'assets/images/ledger_logo.png',
      'description': 'Connect via Ledger hardware wallet',
      'status': 'available',
      'isWalletConnect': false,
    },
    {
      'name': 'Phantom',
      'icon': 'assets/images/phantom_logo.png',
      'description': 'Connect via Phantom (Solana blockchain)',
      'status': 'available',
      'isWalletConnect': false,
    },
    {
      'name': 'Other Wallets',
      'icon': 'assets/images/other_wallets_icon.png',
      'description': 'Connect other supported wallets',
      'status': 'available',
      'isWalletConnect': true,
    },
  ].obs;

  // WalletConnect modal wallet options
  final RxList<Map<String, dynamic>> walletConnectOptions =
      <Map<String, dynamic>>[
    {
      'name': 'MetaMask',
      'icon': 'assets/images/metamask_logo.png',
      'description': 'Connect via MetaMask mobile app',
      'status': 'available',
    },
    {
      'name': 'Trust Wallet',
      'icon': 'assets/images/trustwallet_logo.png',
      'description': 'Connect via Trust Wallet mobile app',
      'status': 'available',
    },
    {
      'name': 'Coinbase Wallet',
      'icon': 'assets/images/coinbase_logo.png',
      'description': 'Connect via Coinbase Wallet mobile app',
      'status': 'available',
    },
    {
      'name': 'Ledger',
      'icon': 'assets/images/ledger_logo.png',
      'description': 'Connect via Ledger hardware wallet',
      'status': 'available',
    },
    {
      'name': 'Phantom',
      'icon': 'assets/images/phantom_logo.png',
      'description': 'Connect via Phantom (Solana)',
      'status': 'available',
    },
  ].obs;

  // Check if a wallet is currently connecting
  bool isWalletConnecting(String walletName) {
    return selectedWallet.value == walletName && isLoading.value;
  }

  /// Validate private key format
  String? validatePrivateKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Private key is required';
    }

    final trimmedValue = value.trim();

    // Check if it starts with 0x and has correct length
    if (trimmedValue.startsWith('0x')) {
      if (trimmedValue.length != 66) {
        return 'Private key must be 64 characters long (excluding 0x)';
      }
      // Check if it contains only hex characters
      final hexPart = trimmedValue.substring(2);
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexPart)) {
        return 'Private key must contain only hexadecimal characters';
      }
    } else {
      if (trimmedValue.length != 64) {
        return 'Private key must be 64 characters long';
      }
      // Check if it contains only hex characters
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(trimmedValue)) {
        return 'Private key must contain only hexadecimal characters';
      }
    }

    return null;
  }

  /// Toggle private key visibility
  void togglePrivateKeyVisibility() {
    isPrivateKeyVisible.value = !isPrivateKeyVisible.value;
  }

  /// Show WalletConnect modal with wallet options
  void showWalletConnectModal() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dialogWidth = isDesktop
                ? 600.0
                : isTablet
                    ? constraints.maxWidth * 0.8
                    : constraints.maxWidth * 0.9;

            final dialogHeight = isDesktop
                ? constraints.maxHeight * 0.7
                : constraints.maxHeight * 0.8;

            return Container(
              width: dialogWidth,
              constraints: BoxConstraints(
                maxHeight: dialogHeight,
                minHeight: 400,
              ),
              decoration: AppTheme.glassCardDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModalHeader(),
                  Flexible(
                    child: _buildWalletConnectOptions(),
                  ),
                  _buildModalFooter(),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Handle direct wallet connection (e.g., MetaMask, Trust Wallet)
  Future<void> connectWallet(String walletName) async {
    selectedWallet.value = walletName;
    isLoading.value = true;

    try {
      bool success = false;

      if (walletName == 'MetaMask') {
        // Real MetaMask connection - check if MetaMask is available
        if (_web3Service.isWeb3Available) {
          success = await _web3Service.connectWebWallet();
          if (success && _web3Service.isConnected) {
            connectedAddress.value = _web3Service.connectedWebAddress ?? '';
            // Get balance
            final balance = await _web3Service.getWebWalletBalance();
            if (balance != null) {
              walletBalance.value = balance;
            }
          } else {
            success = false;
          }
        } else {
          _showSnackbar('Error', 'MetaMask not detected. Please install MetaMask extension.');
          success = false;
        }
      } else if (walletName == 'WalletConnect' ||
          walletName == 'Other Wallets') {
        // Handle WalletConnect flow for these specific names
        await _connectWalletConnectFlow(walletName);
        success = true; // _connectWalletConnectFlow handles navigation and success internally
      } else {
        // For other wallets, show that they're not implemented yet
        _showSnackbar('Info', '$walletName integration coming soon. Please use MetaMask or WalletConnect for now.');
        success = false;
      }

      if (success && connectedAddress.value.isNotEmpty && (walletName != 'WalletConnect' && walletName != 'Other Wallets')) {
        // Start session with connected wallet
        _sessionService.startSession(walletName, connectedAddress.value);
        
        _showSnackbar('Success', 'Connected to $walletName!');
        // Navigate to multi-send after successful connection
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(Routes.multiSend);
        });
      } else if (!success && (walletName != 'WalletConnect' && walletName != 'Other Wallets')) {
        _showSnackbar(
            'Error', 'Failed to connect to $walletName. Please try again.');
      }
    } catch (e) {
      _showSnackbar('Error', 'Connection failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
      selectedWallet.value = '';
    }
  }

  /// Initialize WalletConnect service
  void _initializeWalletConnect() {
    _walletConnectService.initialize(projectId: 'YOUR_PROJECT_ID');
    
    // Set up callbacks
    _walletConnectService.onSessionEstablished = (address, walletName) {
      connectedAddress.value = address;
      connectionType.value = 'walletconnect';
      _sessionService.startSession(walletName, address);
      _showSnackbar('Success', 'Connected to $walletName!');
      Get.offNamed(Routes.multiSend);
    };

    _walletConnectService.onSessionDisconnected = () {
      connectedAddress.value = '';
      connectionType.value = '';
      _sessionService.endSession();
      _showSnackbar('Disconnected', 'Wallet disconnected');
    };

    _walletConnectService.onConnectionError = (error) {
      _showSnackbar('Error', error);
    };
  }
  /// Internal method to handle WalletConnect specific flow
  Future<void> _connectWalletConnectFlow(String walletName) async {
    try {
      isLoading.value = true;
      selectedWallet.value = walletName;

      // Show wallet selection dialog for WalletConnect
      final supportedWallets = _walletConnectService.getSupportedWallets();
      
      Get.dialog(
        AlertDialog(
          backgroundColor: AppTheme.secondaryBackground,
          title: Text(
            "Choose Wallet",
            style: TextStyle(color: AppTheme.whiteText),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supportedWallets.length,
              itemBuilder: (context, index) {
                final wallet = supportedWallets[index];
                return ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primaryAccent,
                  ),
                  title: Text(
                    wallet['name'],
                    style: TextStyle(color: AppTheme.whiteText),
                  ),
                  subtitle: Text(
                    wallet['description'],
                    style: TextStyle(color: AppTheme.lightGrayText),
                  ),
                  onTap: () async {
                    Get.back();
                    await _connectToSpecificWallet(wallet['name']);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                isLoading.value = false;
                selectedWallet.value = '';
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: AppTheme.lightGrayText),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackbar('Error', 'Failed to show wallet options: ${e.toString()}');
      isLoading.value = false;
      selectedWallet.value = '';
    }
  }

  /// Connect to a specific wallet via WalletConnect
  Future<void> _connectToSpecificWallet(String walletName) async {
    try {
      isLoading.value = true;
      
      final success = await _walletConnectService.connectWallet(walletName: walletName);
      
      if (!success) {
        _showSnackbar('Error', 'Failed to connect to $walletName');
      }
    } catch (e) {
      _showSnackbar('Error', 'Connection failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
      selectedWallet.value = '';
    }
  }

  /// Navigate to the MultiSend view with form validation (for private key import)
  Future<void> navigateToMultiSendFromPrivateKey() async {
    // Clear previous errors
    privateKeyError.value = '';

    // Validate form
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

    isLoading.value = true;

    String? address;
    try {
      // Validate private key with Web3Service
      if (!_web3Service.isValidPrivateKey(privateKey)) {
        throw Exception("Invalid private key format");
      }

      // Get address from private key
      address = await _web3Service.getAddressFromPrivateKey(privateKey);
      if (address != null) {
        connectedAddress.value = address;

        // Get balance for the derived address
        final balance =
            await _web3Service.getBalance(EthereumAddress.fromHex(address));
        if (balance != null) {
          walletBalance.value = balance.getInEther.toDouble();
        }
        
        // Start session with imported wallet
        _sessionService.startSession("Private Key Import", address);

        _showSnackbar("Success", "Wallet imported successfully!");

        // Navigate to multi-send
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

  String _generateRandomHex(int length) {
    const chars = '0123456789abcdef';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (i) => chars[(random + i) % chars.length])
        .join();
  }

  Widget _buildModalHeader() {
    return Container(
      padding: EdgeInsets.all(isDesktop
          ? 32
          : isTablet
              ? 24
              : 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neutralGray.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 48 : 40,
            height: isDesktop ? 48 : 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.primaryAccent.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/walletconnect_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.link,
                  color: AppTheme.primaryAccent,
                  size: isDesktop
                      ? 28
                      : isTablet
                          ? 26
                          : 24,
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Connect via WalletConnect',
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 20
                        : isTablet
                            ? 18
                            : 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.whiteText,
                    fontFamily: 'Montserrat',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Scan QR code with your mobile wallet',
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 14
                        : isTablet
                            ? 13
                            : 12,
                    color: AppTheme.lightGrayText,
                    fontFamily: 'Montserrat',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppTheme.lightGrayText),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletConnectOptions() {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(isDesktop
          ? 32
          : isTablet
              ? 24
              : 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        crossAxisSpacing: isDesktop ? 20 : 16,
        mainAxisSpacing: isDesktop ? 20 : 16,
        childAspectRatio: isDesktop ? 3.0 : 4.0,
      ),
      itemCount: walletConnectOptions.length,
      itemBuilder: (context, index) {
        final wallet = walletConnectOptions[index];
        return WalletCard(
          name: wallet['name']!,
          iconPath: wallet['icon']!,
          description: wallet['description']!,
          isAvailable: wallet['status']! == 'available',
          onTap: () => connectWallet(wallet['name']!),
          isDesktop: isDesktop,
          isTablet: isTablet,
        );
      },
    );
  }

  Widget _buildModalFooter() {
    return Container(
      padding: EdgeInsets.all(isDesktop
          ? 32
          : isTablet
              ? 24
              : 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.neutralGray.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Having trouble connecting?',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              color: AppTheme.lightGrayText,
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // TODO: Implement help/troubleshooting link
              _showSnackbar('Help', 'Opening help documentation...');
            },
            child: Text(
              'Get Help',
              style: TextStyle(
                fontSize: isDesktop ? 14 : 13,
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
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
