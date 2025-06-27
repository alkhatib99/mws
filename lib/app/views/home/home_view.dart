import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/widgets/custom_text_field.dart';
import '../../controllers/wallet_controller.dart';
 
import '../components/network_dropdown.dart';
import '../components/send_button.dart';
import '../components/tx_output_list.dart';
import '../components/social_links_bar.dart';
import '../../theme/app_theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find();
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final contentWidth = isWideScreen ? 720.0 : MediaQuery.of(context).size.width;
    final MultiSendController  multiSendController = Get.find<MultiSendController>();

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Multi Wallet Sender'),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        actions: [
          // Connect Wallet Button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => controller.connectWallet(),
              icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
              label: const Text('Connect Wallet', style: TextStyle(color: Colors.white)),
              style: AppTheme.primaryButtonStyle,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive design
          final isWideScreen = constraints.maxWidth > 800;
          final contentWidth = isWideScreen ? 720.0 : constraints.maxWidth;
          
          return Center(
            child: Container(
              width: contentWidth,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://i.ibb.co/j9v2nvjT/new.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Private Key Input
                    CustomTextField(
                      label: 'Private Key:',
                      hint: 'Enter your private key',
                      controller: controller.privateKeyController,
                      obscureText: true,
                      onChanged: (value) => controller.privateKey.value = value,
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    CustomTextField(
                      label: 'Amount (ETH):',
                      hint: 'Enter amount in ETH',
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => controller.amount.value = value,
                    ),
                    const SizedBox(height: 16),

                    // Netw,,ork Dropdown
                        NetworkDropdown(controller: multiSendController),
                    const SizedBox(height: 16),

                    // Add Custom Network Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.showAddNetworkDialog(),
                        style: AppTheme.secondaryButtonStyle,
                        child: const Text('Add Custom Network'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Addresses Input
                    CustomTextField(
                      label: 'Recipient Addresses (one per line):',
                      hint: 'Paste wallet addresses here, one per line',
                      controller: controller.addressesController,
                      maxLines: 4,
                      onChanged: (value) => controller.addresses.value = value,
                    ),
                    const SizedBox(height: 16),

                    // Load Addresses from File Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.loadAddressesFromFile(),
                        style: AppTheme.neutralButtonStyle,
                        child: const Text('Load Addresses from .txt'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Send Button
                    const SizedBox(height: 24),

                    // Transaction Output
                    const TxOutputList(),
                    const SizedBox(height: 32),

                    // Social Links
                    const SocialLinksBar(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


