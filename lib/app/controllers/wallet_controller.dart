import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import '../data/models/network_model.dart';
import '../data/models/token_model.dart';
import '../../services/web3_service.dart';
import '../../services/price_service.dart';

class WalletController extends GetxController {
  // Text controllers
  final TextEditingController privateKeyController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressesController = TextEditingController();

  // Observable variables
  final RxString privateKey = ''.obs;
  final RxString amount = ''.obs;
  final RxString addresses = ''.obs;
  final RxString selectedNetwork = 'Base'.obs;
  final RxBool isLoading = false.obs;
  final RxList<String> transactionLinks = <String>[].obs;
  final RxDouble balance = 0.0.obs; // New: Wallet balance
  final RxMap<String, double> tokenBalances = <String, double>{}.obs; // New: Token balances
  final RxMap<String, double> tokenPricesUSD = <String, double>{}.obs; // New: Token prices in USD
  final RxDouble balanceUSD = 0.0.obs; // New: Balance in USD
  final Rx<Token?> selectedToken = Rx<Token?>(null); // New: Selected token

  // Services
  final Web3Service _web3Service = Web3Service();

  // Networks map
  final RxMap<String, Network> networks = <String, Network>{
    'Base': Network(
      name: 'Base',
      rpcUrl: 'https://mainnet.base.org',
      chainId: 8453,
      explorerUrl: 'https://basescan.org/tx/',
      currency: 'ETH',
      logoPath: 'assets/networks/base.png',
      supportedTokens: [
        Token(name: 'Ethereum', symbol: 'ETH', logoPath: 'assets/tokens/eth.png'),
        Token(name: 'USD Coin', symbol: 'USDC', contractAddress: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913', logoPath: 'assets/tokens/usdc.png'),
        Token(name: 'Dai Stablecoin', symbol: 'DAI', contractAddress: '0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb', logoPath: 'assets/tokens/dai.png'),
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
        Token(name: 'Ethereum', symbol: 'ETH', logoPath: 'assets/tokens/eth.png'),
        Token(name: 'USD Coin', symbol: 'USDC', contractAddress: '0xA0b86a33E6441b8435b662f0E2d0c8b7c6b5b1e8', logoPath: 'assets/tokens/usdc.png'),
        Token(name: 'Tether USD', symbol: 'USDT', contractAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7', logoPath: 'assets/tokens/usdt.png'),
        Token(name: 'Dai Stablecoin', symbol: 'DAI', contractAddress: '0x6B175474E89094C44Da98b954EedeAC495271d0F', logoPath: 'assets/tokens/dai.png'),
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
        Token(name: 'BNB', symbol: 'BNB', logoPath: 'assets/tokens/bnb.png'),
        Token(name: 'USD Coin', symbol: 'USDC', contractAddress: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d', logoPath: 'assets/tokens/usdc.png'),
        Token(name: 'Tether USD', symbol: 'USDT', contractAddress: '0x55d398326f99059fF775485246999027B3197955', logoPath: 'assets/tokens/usdt.png'),
        Token(name: 'PancakeSwap Token', symbol: 'CAKE', contractAddress: '0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82', logoPath: 'assets/tokens/cake.png'),
      ],
    ),
  }.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with default network
    selectedNetwork.value = 'Base';
    // Set default token to the first token of the default network
    _setDefaultToken();
    // Listen for private key changes to fetch balance
    ever(privateKey, (_) => _fetchBalance());
    // Listen for network changes to fetch balance and update default token
    ever(selectedNetwork, (_) {
      _setDefaultToken();
      _fetchBalance();
    });
    // Listen for token changes to fetch balance
    ever(selectedToken, (_) => _fetchBalance());
  }

  @override
  void onClose() {
    privateKeyController.dispose();
    amountController.dispose();
    addressesController.dispose();
    super.onClose();
  }

  // Set default token for the selected network
  void _setDefaultToken() {
    final network = networks[selectedNetwork.value];
    if (network != null && network.supportedTokens.isNotEmpty) {
      selectedToken.value = network.supportedTokens.first;
    }
  }

  // Set selected network
  void setSelectedNetwork(String network) {
    selectedNetwork.value = network;
  }

  // Set selected token
  void setSelectedToken(Token token) {
    selectedToken.value = token;
    // Update balance and USD value for the selected token
    balance.value = tokenBalances[token.symbol] ?? 0.0;
    final price = tokenPricesUSD[token.symbol] ?? 0.0;
    balanceUSD.value = balance.value * price;
  }

  // Add custom network
  void addCustomNetwork(String name, String rpc, int chainId, String explorer, String currency) {
    networks[name] = Network(
      name: name,
      rpcUrl: rpc,
      chainId: chainId,
      explorerUrl: explorer,
      currency: currency,
      logoPath: 'assets/networks/default.png',
      supportedTokens: [
        Token(name: currency, symbol: currency, logoPath: 'assets/tokens/default.png'),
      ],
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

  // Show add network dialog
  void showAddNetworkDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController rpcController = TextEditingController();
    final TextEditingController chainIdController = TextEditingController();
    final TextEditingController explorerController = TextEditingController();
    final TextEditingController currencyController = TextEditingController();

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
              const SizedBox(height: 16),
              TextField(
                controller: currencyController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Currency Symbol (e.g., ETH, BNB)',
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
              final currency = currencyController.text.trim();

              if (name.isEmpty || rpc.isEmpty || chainIdText.isEmpty || currency.isEmpty) {
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

              addCustomNetwork(name, rpc, chainId, explorer, currency);
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

  // Fetch wallet balance
  Future<void> _fetchBalance() async {
    if (privateKey.value.isEmpty) {
      balance.value = 0.0;
      balanceUSD.value = 0.0;
      tokenBalances.clear();
      tokenPricesUSD.clear();
      return;
    }

    try {
      final networkInfo = networks[selectedNetwork.value];
      if (networkInfo == null) {
        throw Exception("Network not found");
      }

      _web3Service.initialize(networkInfo.rpcUrl);
      final credentials = EthPrivateKey.fromHex(privateKey.value);
      final address = credentials.address;

      // Fetch native currency balance
      final nativeBalance = await _web3Service.getBalance(address);
      tokenBalances[networkInfo.currency] = nativeBalance.getValueInUnit(EtherUnit.ether);

      // Fetch ERC-20 token balances
      for (var token in networkInfo.supportedTokens) {
        if (token.contractAddress != null) {
          final tokenBalance = await _web3Service.getTokenBalance(
            EthereumAddress.fromHex(token.contractAddress!),
            address,
          );
          // Assuming 18 decimals for simplicity, adjust if needed
          tokenBalances[token.symbol] = tokenBalance.getValueInUnit(EtherUnit.ether);
        }
      }

      // Fetch USD prices for all tokens
      final tokenSymbols = [networkInfo.currency, ...networkInfo.supportedTokens.map((t) => t.symbol)];
      final prices = await PriceService.getMultipleTokenPrices(tokenSymbols);
      tokenPricesUSD.addAll(prices);

      // Update the main balance observable based on the selected token
      if (selectedToken.value != null) {
        balance.value = tokenBalances[selectedToken.value!.symbol] ?? 0.0;
        final price = tokenPricesUSD[selectedToken.value!.symbol] ?? 0.0;
        balanceUSD.value = balance.value * price;
      } else {
        balance.value = tokenBalances[networkInfo.currency] ?? 0.0;
        final price = tokenPricesUSD[networkInfo.currency] ?? 0.0;
        balanceUSD.value = balance.value * price;
      }

    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch balance: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      balance.value = 0.0;
      balanceUSD.value = 0.0;
      tokenBalances.clear();
      tokenPricesUSD.clear();
    }
  }

  // Load addresses from file
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

  // Validate inputs
  bool _validateInputs() {
    if (privateKey.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your private key',
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

  // Generate dummy transaction hash
  String _generateDummyTxHash() {
    const chars = '0123456789abcdef';
    final random = Random();
    return '0x${List.generate(64, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  // Send funds (simulated)
  Future<void> sendFunds() async {
    if (!_validateInputs()) return;

    isLoading.value = true;
    transactionLinks.clear();

    try {
      // Get network info
      final networkInfo = networks[selectedNetwork.value];
      if (networkInfo == null) {
        throw Exception('Network not found');
      }

      // Parse addresses
      final addressList = addresses.value
          .split('\n')
          .map((addr) => addr.trim())
          .where((addr) => addr.isNotEmpty)
          .toList();

      if (addressList.isEmpty) {
        throw Exception('No valid addresses found');
      }

      // Simulate transaction processing
      for (int i = 0; i < addressList.length; i++) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Generate dummy transaction hash
        final txHash = _generateDummyTxHash();
        final explorerLink = '${networkInfo.explorerUrl}$txHash';
        
        transactionLinks.add(explorerLink);

        // Update UI
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

  // Placeholder for connecting wallet (e.g., Metamask)
  void connectWallet() {
    Get.snackbar(
      'Connect Wallet',
      'Metamask connection functionality will be implemented here.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Clear transaction links
  void clearTransactionLinks() {
    transactionLinks.clear();
  }

  // Clear all fields
  void clearAllFields() {
    privateKeyController.clear();
    amountController.clear();
    addressesController.clear();
    privateKey.value = '';
    amount.value = '';
    addresses.value = '';
    clearTransactionLinks();
  }
}


