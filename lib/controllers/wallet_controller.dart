import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:math';

class NetworkInfo {
  final String rpc;
  final int chainId;
  final String explorer;

  NetworkInfo({
    required this.rpc,
    required this.chainId,
    required this.explorer,
  });

  Map<String, dynamic> toJson() => {
    'rpc': rpc,
    'chain_id': chainId,
    'explorer': explorer,
  };

  factory NetworkInfo.fromJson(Map<String, dynamic> json) => NetworkInfo(
    rpc: json['rpc'],
    chainId: json['chain_id'],
    explorer: json['explorer'],
  );
}

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

  // Networks map
  final RxMap<String, NetworkInfo> networks = <String, NetworkInfo>{
    'Base': NetworkInfo(
      rpc: 'https://mainnet.base.org',
      chainId: 8453,
      explorer: 'https://basescan.org/tx/',
    ),
    'Ethereum': NetworkInfo(
      rpc: 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY',
      chainId: 1,
      explorer: 'https://etherscan.io/tx/',
    ),
    'BNB Chain': NetworkInfo(
      rpc: 'https://bsc-dataseed.binance.org/',
      chainId: 56,
      explorer: 'https://bscscan.com/tx/',
    ),
  }.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with default network
    selectedNetwork.value = 'Base';
  }

  @override
  void onClose() {
    privateKeyController.dispose();
    amountController.dispose();
    addressesController.dispose();
    super.onClose();
  }

  // Set selected network
  void setSelectedNetwork(String network) {
    selectedNetwork.value = network;
  }

  // Add custom network
  void addCustomNetwork(String name, String rpc, int chainId, String explorer) {
    networks[name] = NetworkInfo(
      rpc: rpc,
      chainId: chainId,
      explorer: explorer,
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
        final explorerLink = '${networkInfo.explorer}$txHash';
        
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

