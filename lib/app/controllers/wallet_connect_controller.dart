import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/widgets/custom_text_field.dart';
import '../routes/app_routes.dart';
import 'package:mws/app/theme/app_theme.dart';

class WalletConnectController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TextEditingController privateKeyController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
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
    return 4.0; // Taller cards for mobile
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
      'name': 'Rainbow',
      'icon': 'assets/images/rainbow_logo.png',
      'description': 'Connect via Rainbow wallet',
      'status': 'available',
      'isWalletConnect': false,
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
      'name': 'Rainbow',
      'icon': 'assets/images/rainbow_logo.png',
      'description': 'Connect via Rainbow wallet',
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

  /// Navigate to the MultiSend view with form validation
  void navigateToMultiSend() {
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

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      isLoading.value = false;
      _showSnackbar('Success', 'Wallet imported successfully!');

      // Navigate to multi-send
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offNamed(Routes.multiSend);
      });
    });
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

  /// Handle WalletConnect wallet selection
  void connectWalletConnectWallet(String walletName) {
    Get.back(); // Close modal
    selectedWallet.value = walletName;
    isLoading.value = true;

    // Simulate WalletConnect connection process
    Future.delayed(const Duration(milliseconds: 3000), () {
      isLoading.value = false;
      selectedWallet.value = '';
      _showSnackbar('Success',
          'Connected via WalletConnect! Please check your $walletName app.');

      // Navigate to multi-send after successful connection
      Future.delayed(const Duration(milliseconds: 1000), () {
        Get.offNamed(Routes.multiSend);
      });
    });
  }

  /// Handle direct wallet connection (e.g., MetaMask, Trust Wallet)
  void connectWallet(String walletName) {
    selectedWallet.value = walletName;
    isLoading.value = true;

    // Simulate connection process
    Future.delayed(const Duration(milliseconds: 2000), () {
      isLoading.value = false;
      selectedWallet.value = '';
      _showSnackbar('Success', 'Connected to $walletName!');

      // Navigate to multi-send after successful connection
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offNamed(Routes.multiSend);
      });
    });
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
                  size: isDesktop ? 28 : 24,
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect with WalletConnect',
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 24
                        : isTablet
                            ? 20
                            : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.whiteText,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: isDesktop ? 6 : 4),
                Text(
                  'Choose your preferred wallet',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: AppTheme.lightGrayText,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: AppTheme.lightGrayText,
              size: isDesktop ? 28 : 24,
            ),
          ),
        ],
      ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Need help?',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: AppTheme.lightGrayText,
              fontFamily: 'Montserrat',
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Implement help/support functionality
              _showSnackbar('Help', 'Help functionality not yet implemented.');
            },
            child: Text(
              'Visit our support page',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
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

  Widget _buildWalletConnectOptions() {
    return Obx(() => Padding(
          padding: EdgeInsets.all(isDesktop
              ? 24
              : isTablet
                  ? 20
                  : 16),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: walletConnectOptions.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: isDesktop ? 16 : 12),
            itemBuilder: (context, index) {
              final wallet = walletConnectOptions[index];
              return _buildWalletConnectOption(
                wallet['name']!,
                wallet['icon']!,
                wallet['description']!,
                wallet['status']! == 'available',
              );
            },
          ),
        ));
  }

  Widget _buildWalletConnectOption(
    String name,
    String iconPath,
    String description,
    bool isAvailable,
  ) {
    return Obx(() {
      final isConnecting = selectedWallet.value == name && isLoading.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isConnecting
              ? AppTheme.primaryAccent.withOpacity(0.1)
              : AppTheme.textFieldBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnecting
                ? AppTheme.primaryAccent.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isAvailable && !isLoading.value
                ? () => connectWalletConnectWallet(name)
                : null,
            child: Padding(
              padding: EdgeInsets.all(isDesktop
                  ? 24
                  : isTablet
                      ? 20
                      : 16),
              child: Row(
                children: [
                  Container(
                    width: isDesktop ? 48 : 40,
                    height: isDesktop ? 48 : 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.textFieldBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        iconPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryAccent.withOpacity(0.8),
                                AppTheme.blueAccent.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: isDesktop ? 24 : 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isDesktop ? 20 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: isAvailable
                                ? AppTheme.whiteText
                                : AppTheme.lightGrayText,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: isDesktop ? 6 : 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            color: AppTheme.lightGrayText,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isConnecting)
                    SizedBox(
                      width: isDesktop ? 24 : 20,
                      height: isDesktop ? 24 : 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryAccent,
                        ),
                      ),
                    )
                  else
                    Icon(
                      isWalletConnecting(name)
                          ? Icons.open_in_new
                          : Icons.arrow_forward_ios,
                      size: isDesktop ? 20 : 16,
                      color: isAvailable
                          ? AppTheme.primaryAccent
                          : AppTheme.lightGrayText,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primaryAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void showHelpDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.primaryBackground,
        title: Text(
          'Need Help?',
          style: TextStyle(
            color: AppTheme.whiteText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'For assistance, please visit our support page or contact our team.',
          style: TextStyle(
            color: AppTheme.lightGrayText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
