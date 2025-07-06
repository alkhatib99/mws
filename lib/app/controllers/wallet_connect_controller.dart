// lib/controllers/wallet_connect_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart' show allowInterop;
import 'package:mws/web/js/phantom_bridge.dart';
import 'package:mws/app/data/models/wallet_status.dart';
import 'package:mws/app/routes/app_routes.dart';
import 'package:mws/services/secure_storage_service.dart';
import 'package:mws/services/session_service.dart';
import 'package:mws/services/wallet_connect_service.dart';
import 'package:mws/services/web3_service.dart';
import 'package:mws/utils/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../theme/app_theme.dart';

class WalletConnectController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ReownWalletKit? _walletKit;
  ReownAppKit? _appKit;
  SessionData? _session;
  final Web3Service _web3Service = Get.find<Web3Service>();
  final WalletConnectService _walletConnectService = WalletConnectService();
  // final SessionService _sessionService = Get.find<SessionService>();

  final RxList<Map<String, dynamic>> wallets = <Map<String, dynamic>>[
    {
      'name': 'MetaMask',
      'icon': 'assets/images/metamask_logo.png',
      'description': 'Connect via MetaMask browser extension or mobile app',
      'type': 'extension',
    },
    {
      'name': 'Phantom',
      'icon': 'assets/images/phantom_logo.png', // make sure this asset exists
      'description': 'Connect to Phantom wallet (Solana)',
      'type': 'extension',
      'isAvailable': false, // set to true when you support Solana
      'isWalletConnect': false,
    },
    {
      'name': 'WalletConnect',
      'icon': 'assets/images/walletconnect_logo.png',
      'description': 'Connect any mobile wallet via WalletConnect protocol',
      'type': 'walletconnect',
    },
  ].obs;
  // Form controllers
  final SessionService _sessionService = Get.find<SessionService>();
  final RxString hoveredCardName = ''.obs;
  final RxString selectedWallet = ''.obs;

  final TextEditingController privateKeyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  // Focus nodes
  final FocusNode privateKeyFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void onInit() {
    print("WalletConnectController initialized");

    _initializeAnimations();
    _initializeServices();
    _setupEventListeners();
    print("WalletConnectController onInit called");
    super.onInit();
  }

  // Animation controllers
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Reactive state
  final RxBool isLoading = false.obs;
  // final RxString selectedWallet = "".obs;
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

  final RxBool isConnecting = false.obs;
  final RxBool sessionEstablished = false.obs;
  final RxString connectedAddress = ''.obs;
  final RxString qrCodeData = ''.obs;
  final RxString pairingUri = ''.obs;
  // Future<void> initialize(ReownWalletKit walletKit, ReownAppKit appKit) async {
  //   _walletKit = walletKit;
  //   _appKit = appKit;
  //   _initializeAnimations();
  //   _appKit?.core.relayClient.connect();
  //   _setupEventListeners();
  //   _checkExistingSessions();
  // }

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
    print("Initializing animations in WalletConnectController");
    // Initialize the fade and slide animations
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
    fadeController.forward();
    print("Animations initialized in WalletConnectController");
  }

  void _initializeServices() {
    print("Initializing services in WalletConnectController");
    const projectId = "c828aec3b3a8cdbc7a2fbf0ffe3be04a";
    if (projectId.isNotEmpty) {
      _walletConnectService.initialize();
    } else {
      print("Project ID is empty in WalletConnectController");
    }
    print("Services initialized in WalletConnectController");
    // _web3Service.initialize();
  }

  void _setupEventListeners() {
    print("Setting up event listeners in WalletConnectController");
    // _web3Service.walletStatus.listen((status) {
    //   if (status == WalletStatus.disconnected) {
    //     _clearConnectionData();
    //   }
    // });

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
    print("Event listeners set up in WalletConnectController successfully");
  }

  void _handleWalletConnectSessionEstablished(Map<String, String> data) {
    _web3Service.connectedAddress.value = data['address']!;
    _web3Service.walletStatus.value = WalletStatus.connected;
    _web3Service.currentWalletType.value = WalletType.walletconnect;
    _handleSuccessfulConnection(data['walletName']!);
  }

  void _handleSuccessfulConnection(String walletName) {
    _sessionService.startSession(
        walletName, _web3Service.connectedAddress.value);
    _showSnackbar('Success', 'Connected to $walletName!');
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offNamed(Routes.multiSend);
    });
  }

  void _cancelSubscriptions() {
    _walletConnectService.dispose();
  }

  _showSnackbar(String title, String message) {
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

  // Connection management
  void _clearConnectionData() {
    // _sessionService.endSession();
  }

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

  Future<void> connectWallet({String? walletName}) async {
    if (_appKit == null) return;
    if (_walletKit == null) return;
    if (sessionEstablished.value) {
      _showSnackbar(
          'Already Connected', 'You are already connected to a wallet.');
      return;
    }

    isConnecting.value = true;
    try {
      final connectResponse = await _appKit!.connect(
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: ['eip155:1'], // Default to Ethereum mainnet
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign'
            ],
            events: ['chainChanged', 'accountsChanged'],
          )
        },
      );
      qrCodeData.value = connectResponse.uri!.toString();
    } catch (e) {
      rethrow;
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> switchNetwork(int chainId) async {
    if (_walletKit == null || !sessionEstablished.value) return;

    try {
      final newNamespaces = {
        'eip155': Namespace(
          chains: ['eip155:$chainId'],
          methods: _session!.namespaces['eip155']?.methods ??
              [
                'eth_sendTransaction',
                'eth_signTransaction',
                'eth_sign',
                'personal_sign'
              ],
          events: _session!.namespaces['eip155']?.events ??
              ['chainChanged', 'accountsChanged'],
          accounts: _session!.namespaces['eip155']?.accounts
                  .map((a) =>
                      a.replaceFirst(RegExp(r'eip155:\d+'), 'eip155:$chainId'))
                  .toList() ??
              [],
        )
      };

      await _walletKit!.updateSession(
        topic: _session!.topic,
        namespaces: newNamespaces,
      );

      final address = connectedAddress.value.split(':').last;
      connectedAddress.value = 'eip155:$chainId:$address';

      final web3Service = Get.find<Web3Service>();
      final network = AppConstants.networks.values.firstWhere(
        (net) => net['chainId'] == chainId,
        orElse: () => AppConstants.networks['Ethereum']!,
      );

      web3Service.networkInfo.value = network;
      var newClient = Web3Client(
        network['rpc'],
        http.Client(),
      );
      web3Service.client = newClient;
    } catch (e) {
      debugPrint('Network switch failed: $e');
      rethrow;
    }
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   _initializeAnimations();
  //   _appKit?.core.relayClient.connect();
  //   _setupEventListeners();
  //   _checkExistingSessions();
  // }

  // Responsive design properties
  void updateScreenSize(Size size) {
    screenWidth.value = size.width;
    screenHeight.value = size.height;
  }

  @override
  void onReady() {
    super.onReady();
    print("WalletConnectController is ready");
  }

  bool get isMobile => screenWidth.value < 600;
  bool get isTablet => screenWidth.value >= 600 && screenWidth.value < 1024;
  bool get isDesktop => screenWidth.value >= 1024;
  double get maxContentWidth => isDesktop ? 800 : double.infinity;
  double get horizontalPadding => isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);
  double get verticalSpacing => isDesktop ? 48.0 : (isTablet ? 36.0 : 24.0);

  get sectionSpacing => isDesktop ? 48.0 : (isTablet ? 36.0 : 24.0);
  get sectionSpacingSmall => isDesktop ? 24.0 : (isTablet ? 18.0 : 12.0);

  get logoSize => isDesktop ? 64.0 : (isTablet ? 48.0 : 32.0);

  get gridCrossAxisCount => isDesktop ? 3 : (isTablet ? 2 : 1);
  get gridChildAspectRatio => isDesktop ? 1.2 : (isTablet ? 1.1 : 1.0);
  get gridSpacing => isDesktop ? 20.0 : (isTablet ? 16.0 : 12.0);

  get subtitleFontSize => isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

  get privateKeyFormKey => GlobalKey<FormState>();
  get privateKeyFormLabel => "Private Key";
  get privateKeyFormHint => "Enter your private key";
  get privateKeyFormError => "Invalid private key";

  Future<String> signAndSendTransaction(Transaction transaction) async {
    if (_appKit == null || _session == null) {
      throw Exception("Wallet not connected");
    }

    try {
      final response = await _appKit!.request(
        topic: _session!.topic,
        chainId: 'eip155:${Get.find<Web3Service>().networkInfo['chainId']}',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': connectedAddress.value,
              'to': transaction.to?.hex,
              'value': '0x${transaction.value?.getInWei.toRadixString(16)}',
              'gas': '0x${transaction.maxGas?.toRadixString(16)}',
              if (transaction.data != null)
                'data': bytesToHex(transaction.data!),
            }
          ],
          // chainId: 'eip155:${Get.find<Web3Service>().networkInfo['chainId']}',
        ),
      );

      return response as String;
    } catch (e) {
      Get.snackbar('Transaction Error', 'Failed to send transaction: $e');
      rethrow;
    }
  }

  Future<void> _updateWeb3ServiceNetwork(int chainId) async {
    final web3Service = Get.find<Web3Service>();
    final network = AppConstants.networks.values.firstWhere(
      (net) => net['chainId'] == chainId,
      orElse: () => AppConstants.networks['Ethereum']!,
    );

    web3Service.networkInfo.value = network;
    var newClient = Web3Client(
      network['rpc'],
      http.Client(),
    );
    web3Service.client = newClient;
  }

  Future<void> disconnect() async {
    if (_walletKit == null || _session == null) return;

    try {
      await _walletKit!.disconnectSession(
        topic: _session!.topic,
        reason: const ReownSignError(
          code: 6000, // Standard WC disconnect code
          message: 'User disconnected',
        ),
      );

      // Clear local session state
      _session = null;
      sessionEstablished.value = false;
      connectedAddress.value = '';

      // Update Web3Service state
      final web3Service = Get.find<Web3Service>();
      web3Service.disconnectWallet();
    } catch (e) {
      debugPrint('Disconnection error: $e');
      rethrow;
    }
  }

  void _checkExistingSessions() {
    if (_appKit?.getActiveSessions().isNotEmpty ?? false) {
      _session = _appKit!.getActiveSessions().values.first;
      sessionEstablished.value = true;

      final eip155Account =
          _session!.namespaces['eip155']?.accounts.first ?? '';
      connectedAddress.value = eip155Account.split(':')[2];
    }
  }

  void _showQRCodeDialog(String uri) {
    Get.dialog(
      AlertDialog(
        title: const Text('Scan QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrCodeData.value ?? uri,
              size: 240,
              backgroundColor: AppTheme.glassBackground,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
              padding: const EdgeInsets.all(8),
            ),
            const SizedBox(height: 16),
            const Text('Scan with your wallet app to connect'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void retryLastConnection() {
    if (canRetry.value) {
      canRetry.value = false;
      hasError.value = false;
      lastError.value = '';
      connectWallet();
    }
  }

  Future<void> connectPhantomWallet() async {
    isConnecting.value = true;
    lastError.value = '';
    hasError.value = false;

    try {
      final phantomInstance = phantom;

      if (phantomInstance == null || phantomInstance.isPhantom != true) {
        hasError.value = true;
        lastError.value =
            'Phantom wallet is not installed.\nInstall it from https://phantom.app/';
        return;
      }

      await phantomInstance.connect().then(
        allowInterop((res) {
          final address = phantomInstance.publicKey?.toString();
          if (address == null || address.isEmpty) {
            throw 'Failed to retrieve your Phantom address.';
          }

          connectedAddress.value = address;
          Get.snackbar(
            'Connected',
            'Phantom wallet connected successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          print('[Phantom Connected] $address');
        }),
        allowInterop((err) {
          throw 'Connection to Phantom was cancelled by user.';
        }),
      );
    } catch (e) {
      hasError.value = true;
      lastError.value = e.toString();
      print('[Phantom Error] $e');
    } finally {
      isConnecting.value = false;
    }
  }

  void showWalletConnectModal() {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Connect Wallet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: qrCodeData.value,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scan with your wallet app to connect',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // void showWalletConnectModal() {
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text('Connect Wallet'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           QrImageView(
  //             data: qrCodeData.value,
  //             size: 200,
  //             backgroundColor: Colors.white,
  //           ),
  //           const SizedBox(height: 16),
  //           const Text('Scan with your wallet app to connect'),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //     barrierDismissible: true,
  //   );
  // }

  void navigateToMultiSendFromPrivateKey() async {
    // Validate the private key input
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;
      final privateKey = privateKeyController.text.trim();
      _web3Service.importPrivateKey(privateKey).then((_) {
        isLoading.value = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(Routes.multiSend);
        });
      }).catchError((error) {
        isLoading.value = false;
        Get.snackbar('Error', error.toString());
      });
    } else {
      Get.snackbar('Error', 'Please enter a valid private key');
    }
  }
}
