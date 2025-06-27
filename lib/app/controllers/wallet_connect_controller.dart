import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/widgets/custom_text_field.dart';
import '../routes/app_routes.dart';
import 'package:mws/app/theme/app_theme.dart';

class WalletConnectController extends GetxController {
  final TextEditingController privateKeyController = TextEditingController();

  @override
  void onClose() {
    privateKeyController.dispose();
    super.onClose();
  }

  /// Navigate to the MultiSend view if a private key is present.
  void navigateToMultiSend() {
    if (privateKeyController.text.trim().isNotEmpty) {
      Get.offNamed(Routes.multiSend);
    } else {
      _showSnackbar('Error', 'Please enter a private key to proceed.');
    }
  }

  /// Display dialog for wallet selection.
  void showWalletSelectionDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.primaryBackground,
        title:
            const Text('Connect Wallet', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _walletOption('MetaMask', 'assets/images/metamask_logo.png',
                () => connectWallet('MetaMask')),
            const SizedBox(height: 10),
            _walletOption('Coinbase Wallet', 'assets/images/coinbase_logo.png',
                () => connectWallet('Coinbase Wallet')),
            const SizedBox(height: 10),
            _walletOption('Trust Wallet', 'assets/images/trustwallet_logo.png',
                () => connectWallet('Trust Wallet')),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _showSnackbar(
                'Info',
                'You can create a new wallet using MetaMask, Coinbase, or Trust Wallet.',
              ),
              child: const Text(
                'I don\'t have a wallet',
                style: TextStyle(color: AppTheme.lightGrayText),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  /// Show dialog to enter private key manually.
  void showPrivateKeyInput() {
    Get.back(); // Close wallet dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.primaryBackground,
        title: const Text('Enter Private Key',
            style: TextStyle(color: Colors.white)),
        content: CustomTextField(
          label: 'Private Key:',
          hint: 'Enter your private key (e.g., 0x...)',
          obscureText: true,
          controller: privateKeyController,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: navigateToMultiSend,
            style: AppTheme.primaryButtonStyle,
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  /// Show "coming soon" placeholder for wallets.
  void connectWallet(String walletType) {
    _showSnackbar('Coming Soon', '$walletType integration is coming soon.');
  }

  /// Build wallet option button.
  Widget _walletOption(String title, String iconPath, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(iconPath, height: 24),
        label: Text(title),
        style: AppTheme.primaryButtonStyle,
      ),
    );
  }

  /// Reusable snackbar
  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primaryAccent,
      colorText: Colors.white,
    );
  }
}
