import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:math';
import '../data/models/network_model.dart';
import '../data/models/token_model.dart';
import '../data/models/transaction_model.dart';
import 'package:mws/app/controllers/wallet_connect_controller.dart';
import 'package:mws/services/balance_service.dart';
import 'package:mws/services/session_service.dart';
import 'package:mws/services/price_service.dart';

class MultiSendController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressesController = TextEditingController();

  final RxString amount = ''.obs;
  final RxString addresses = ''.obs;
  final RxString selectedNetwork = 'Base'.obs;
  final Rx<Token?> selectedToken = Rx<Token?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingBalances = false.obs;
  final RxList<Transaction> transactionLinks = <Transaction>[].obs;
  
  // Balance management
  final RxMap<String, String> tokenBalances = <String, String>{}.obs;
  final RxMap<String, String> tokenUsdValues = <String, String>{}.obs;
  
  // Form validation states
  final RxBool isNetworkSelected = false.obs;
  final RxBool isTokenSelected = false.obs;
  final RxBool areAddressesValid = false.obs;
  final RxBool isAmountValid = false.obs;

  // Services
  final SessionService _sessionService = Get.find<SessionService>();
  final PriceService _priceService = PriceService();

  final RxMap<String, Network> networks = <String, Network>{
    'Base': Network(
      name: 'Base',
      rpcUrl: 'https://mainnet.base.org',
      chainId: 8453,
      explorerUrl: 'https://basescan.org/tx/',
      currency: 'ETH',
      logoPath: 'assets/networks/base.png',
      supportedTokens: [
        Token(
          name: 'Ethereum',
          symbol: 'ETH',
          contractAddress: '',
          decimals: 18,
          logoPath: 'assets/tokens/eth.png',
        ),
        Token(
          name: 'USD Coin',
          symbol: 'USDC',
          contractAddress: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
          decimals: 6,
          logoPath: 'assets/tokens/usdc.png',
        ),
      ],
    ),
    'Ethereum': Network(
      name: 'Ethereum',
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY',
      chainId: 1,
      explorerUrl: 'https://etherscan.io/tx/',
      currency: 'ETH',
      logoPath: 'assets/networks/ethereum.png',
      supportedTokens: [
        Token(
          name: 'Ethereum',
          symbol: 'ETH',
          contractAddress: '',
          decimals: 18,
          logoPath: 'assets/tokens/eth.png',
        ),
        Token(
          name: 'USD Coin',
          symbol: 'USDC',
          contractAddress: '0xA0b86a33E6441b8435b662c8b0b0e6b2b5b5b5b5',
          decimals: 6,
          logoPath: 'assets/tokens/usdc.png',
        ),
        Token(
          name: 'Tether USD',
          symbol: 'USDT',
          contractAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
          decimals: 6,
          logoPath: 'assets/tokens/usdt.png',
        ),
        Token(
          name: 'Dai Stablecoin',
          symbol: 'DAI',
          contractAddress: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
          decimals: 18,
          logoPath: 'assets/tokens/dai.png',
        ),
      ],
    ),
    'BNB Chain': Network(
      name: 'BNB Chain',
      rpcUrl: 'https://bsc-dataseed.binance.org/',
      chainId: 56,
      explorerUrl: 'https://bscscan.com/tx/',
      currency: 'BNB',
      logoPath: 'assets/networks/bnb.png',
      supportedTokens: [
        Token(
          name: 'BNB',
          symbol: 'BNB',
          contractAddress: '',
          decimals: 18,
          logoPath: 'assets/tokens/bnb.png',
        ),
        Token(
          name: 'USD Coin',
          symbol: 'USDC',
          contractAddress: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
          decimals: 18,
          logoPath: 'assets/tokens/usdc.png',
        ),
        Token(
          name: 'Tether USD',
          symbol: 'USDT',
          contractAddress: '0x55d398326f99059fF775485246999027B3197955',
          decimals: 18,
          logoPath: 'assets/tokens/usdt.png',
        ),
        Token(
          name: 'PancakeSwap Token',
          symbol: 'CAKE',
          contractAddress: '0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82',
          decimals: 18,
          logoPath: 'assets/tokens/cake.png',
        ),
      ],
    ),
  }.obs;

  // No longer requires privateKey in constructor
  MultiSendController();

  @override
  void onInit() {
    super.onInit();
    selectedNetwork.value = 'Base';
    isNetworkSelected.value = true;
    
    // Listen to address changes for validation
    addressesController.addListener(_validateAddresses);
    amountController.addListener(_validateAmount);
    
    // Load initial token balances for Base network
    _loadTokenBalances();
  }

  @override
  void onClose() {
    amountController.dispose();
    addressesController.dispose();
    super.onClose();
  }

  void setSelectedNetwork(String network) {
    selectedNetwork.value = network;
    isNetworkSelected.value = true;
    
    // Clear selected token when network changes
    selectedToken.value = null;
    isTokenSelected.value = false;
    
    // Load balances for new network
    _loadTokenBalances();
  }
  
  void setSelectedToken(Token token) {
    selectedToken.value = token;
    isTokenSelected.value = true;
    
    // Update amount label based on selected token
    _updateAmountValidation();
  }
  
  void _loadTokenBalances() async {
    final network = networks[selectedNetwork.value];
    if (network == null) return;
    
    // Get connected wallet address
    final walletAddress = _sessionService.connectedAddress.value;
    if (walletAddress.isEmpty) {
      print('No wallet connected');
      return;
    }
    
    isLoadingBalances.value = true;
    tokenBalances.clear();
    tokenUsdValues.clear();
    
    try {
      // Fetch real balances from blockchain      final balances = await BalanceService.getAllTokenBalances(
      final balances = await BalanceService.getAllTokenBalances(
         walletAddress,
         network.name,
         network.supportedTokens,
      );
      
      // Get USD prices for tokens
      for (final token in network.supportedTokens) {
        final balance = balances[token.symbol] ?? 0.0;
        final formattedBalance = BalanceService.formatBalance(balance);
        tokenBalances[token.symbol] = formattedBalance;
        
        // Get USD value
        try {
          final usdPrice = await PriceService.getTokenPrice(token.symbol);
          final usdValue = balance * usdPrice;
          tokenUsdValues[token.symbol] = BalanceService.formatBalance(usdValue, decimals: 2);
        } catch (e) {
          print('Error fetching price for ${token.symbol}: $e');
          tokenUsdValues[token.symbol] = '0.00';
        }
      }
    } catch (e) {
      print('Error loading token balances: $e');
      // Fallback to zero balances
      for (final token in network.supportedTokens) {
        tokenBalances[token.symbol] = '0.0';
        tokenUsdValues[token.symbol] = '0.00';
      }
    } finally {
      isLoadingBalances.value = false;
    }
  }
  
  void _validateAddresses() {
    final addressText = addressesController.text.trim();
    if (addressText.isEmpty) {
      areAddressesValid.value = false;
      return;
    }
    
    final addressList = addressText
        .split('\n')
        .map((addr) => addr.trim())
        .where((addr) => addr.isNotEmpty)
        .toList();
    
    // Use BalanceService for proper address validation
    bool allValid = addressList.every((addr) => 
        BalanceService.isValidAddress(addr));
    
    areAddressesValid.value = allValid && addressList.isNotEmpty;
    addresses.value = addressText;
  }
  
  void _validateAmount() {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      isAmountValid.value = false;
      return;
    }
    
    final amountValue = double.tryParse(amountText);
    isAmountValid.value = amountValue != null && amountValue > 0;
    amount.value = amountText;
  }
  
  void _updateAmountValidation() {
    _validateAmount();
  }
  
  // Computed property for send button state
  bool get canSendFunds {
    return isNetworkSelected.value && 
           isTokenSelected.value && 
           areAddressesValid.value && 
           isAmountValid.value;
  }

  void addCustomNetwork(String name, String rpc, int chainId, String explorer) {
    networks[name] = Network(
      name: name,
      rpcUrl: rpc,
      chainId: chainId,
      explorerUrl: explorer,
      currency: 'ETH', // Default currency
      logoPath: 'assets/networks/custom.png', // Default logo
      supportedTokens: [], // Empty tokens list for custom networks
    );
    Get.snackbar(
      'Success',
      'Network "$name" added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void showAddNetworkDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController rpcController = TextEditingController();
    final TextEditingController chainIdController = TextEditingController();
    final TextEditingController explorerController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3A),
        title: const Text(
          'Add Custom Network',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Network Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rpcController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'RPC URL',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: chainIdController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chain ID',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: explorerController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Explorer URL (optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final rpc = rpcController.text.trim();
              final chainIdText = chainIdController.text.trim();
              final explorer = explorerController.text.trim();

              if (name.isEmpty || rpc.isEmpty || chainIdText.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please fill in all required fields',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final chainId = int.tryParse(chainIdText);
              if (chainId == null) {
                Get.snackbar(
                  'Error',
                  'Invalid Chain ID',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              addCustomNetwork(name, rpc, chainId, explorer);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Add Network'),
          ),
        ],
      ),
    );
  }

  Future<void> loadAddressesFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final content = utf8.decode(bytes);
        final lines = content.split('\n');
        final addressList = lines
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        addressesController.text = addressList.join('\n');
        addresses.value = addressesController.text;

        Get.snackbar(
          'Success',
          'Loaded ${addressList.length} addresses from file',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  bool _validateInputs() {
    // Access privateKey from WalletConnectController
    final WalletConnectController walletConnectController =
        Get.find<WalletConnectController>();
    final String privateKey = walletConnectController.privateKeyController.text;

    if (privateKey.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Private key is missing. Please go back and enter it.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (amount.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    final amountValue = double.tryParse(amount.value.trim());
    if (amountValue == null || amountValue <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (addresses.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter recipient addresses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  String _generateDummyTxHash() {
    const chars = '0123456789abcdef';
    final random = Random();
    return '0x${List.generate(64, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  Future<void> sendFunds() async {
    if (!_validateInputs()) return;

    isLoading.value = true;
    transactionLinks.clear();

    try {
      final networkInfo = networks[selectedNetwork.value];
      if (networkInfo == null) {
        throw Exception('Network not found');
      }

      final addressList = addresses.value
          .split('\n')
          .map((addr) => addr.trim())
          .where((addr) => addr.isNotEmpty)
          .toList();

      if (addressList.isEmpty) {
        throw Exception('No valid addresses found');
      }

      for (int i = 0; i < addressList.length; i++) {
        await Future.delayed(const Duration(milliseconds: 500));

        final txHash = _generateDummyTxHash();
        final explorerLink = '${networkInfo.explorerUrl}$txHash';

        transactionLinks.add(Transaction(
          hash: txHash,
          status: 'Success',
          explorerUrl: explorerLink,
        ));

        transactionLinks.refresh();
      }

      Get.snackbar(
        'Success',
        'Funds sent to ${addressList.length} addresses successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send funds: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearTransactionLinks() {
    transactionLinks.clear();
  }

  void clearAllFields() {
    amountController.clear();
    addressesController.clear();
    amount.value = '';
    addresses.value = '';
    clearTransactionLinks();
  }
}
