import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/wallet_connect_controller.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/utils/constants.dart';
import 'package:mws/widgets/custom_text_field.dart';
 
class WalletConnectView extends StatelessWidget {
  const WalletConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletConnectController controller = Get.find();

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Connect Wallet',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              CustomTextField(
                label: 'Private Key:',
                hint: 'Enter your private key (e.g., 0x...)',
                obscureText: true,
                controller: controller.privateKeyController,
              ),
              const SizedBox(height: 24),
              _buildContinueButton(controller),
              const SizedBox(height: 16),
              _buildWalletConnectButton(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.only(bottom: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          AppConstants.bagLogoPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.white,
            child: const Icon(Icons.image_not_supported,
                size: 60, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(WalletConnectController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.navigateToMultiSend,
        style: AppTheme.primaryButtonStyle,
        child: const Text('Continue with Private Key'),
      ),
    );
  }

  Widget _buildWalletConnectButton(WalletConnectController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showWalletDialog(controller),
        icon: const Icon(Icons.wallet, color: Colors.white),
        label: const Text('Connect with Wallet',
            style: TextStyle(color: Colors.white)),
        style: AppTheme.secondaryButtonStyle,
      ),
    );
  }

  void _showWalletDialog(WalletConnectController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.primaryBackground,
        title:
            const Text('Connect Wallet', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWalletOption(
              'MetaMask',
              'assets/images/metamask_logo.png',
              () => controller.connectWallet('MetaMask'),
            ),
            const SizedBox(height: 10),
            _buildWalletOption(
              'Coinbase Wallet',
              'assets/images/coinbase_logo.png',
              () => controller.connectWallet('Coinbase Wallet'),
            ),
            const SizedBox(height: 10),
            _buildWalletOption(
              'Trust Wallet',
              'assets/images/trustwallet_logo.png',
              () => controller.connectWallet('Trust Wallet'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
  onPressed: () {
    Get.snackbar(
      'Coming Soon',
      'Native wallet connections are only supported on mobile.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.lightGrayText,
      colorText: Colors.white,
    );
  },
  icon: const Icon(Icons.phonelink_lock),
  label: const Text('Mobile Wallet (Unavailable on Web)'),
  style: AppTheme.secondaryButtonStyle,
),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.snackbar(
                'Info',
                'You can create a new wallet using providers like MetaMask or Coinbase.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.lightGrayText,
                colorText: Colors.white,
              ),
              child: const Text(
                "I don't have a wallet",
                style: TextStyle(color: AppTheme.lightGrayText),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOption(
      String title, String iconPath, VoidCallback onPressed) {
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
}
