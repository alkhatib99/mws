import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/widgets/custom_text_field.dart';
import '../../controllers/wallet_controller.dart';

import 'package:mws/widgets/network_dropdown.dart';
import 'package:mws/widgets/token_dropdown.dart';
import 'package:mws/widgets/send_button.dart';
import 'package:mws/widgets/tx_output_list.dart';
import 'package:mws/widgets/social_links_bar.dart';
import 'package:mws/widgets/enhanced_button.dart';
import 'package:mws/widgets/balance_card.dart';
 import '../../theme/app_theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find();
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final contentWidth =
        isWideScreen ? 720.0 : MediaQuery.of(context).size.width;
    final MultiSendController multiSendController =
        Get.find<MultiSendController>();

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('BAG MWS DApp'),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        actions: [
          // Connect Wallet Button
          // Padding(
          //   padding: const EdgeInsets.only(right: 16.0),
          //   child: EnhancedButton(
          //     text: 'Connect Wallet',
          //     icon:
          //         const Icon(Icons.account_balance_wallet, color: Colors.white),
          //     onPressed: () => controller.connectWallet(),
          //     isPrimary: true,
          //   ),
          // ),
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
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Title
                    Text(
                      'BAG MWS DApp',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.whiteText,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Private Key Input
                    CustomTextField(
                      label: 'Private Key:',
                      hint: 'Enter your private key',
                      controller: controller.privateKeyController,
                      obscureText: true,
                      onChanged: (value) => controller
                      .privateKeyController.text= value,
                    ),
                    const SizedBox(height: 16),

                    // Balance Card
                    Obx(
                      () => BalanceCard(
                        balance: controller.walletBalance.value,
                        symbol: controller.selectedToken.value?.symbol ?? '',
                        tokenName: controller.selectedToken.value?.name,
                        logoPath: controller.selectedToken.value?.logoPath,
                        usdValue: controller.balanceUSD.value,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Network Dropdown
                    NetworkDropdown(controller: multiSendController),
                    const SizedBox(height: 16),

                    // Token Dropdown
                    Obx(
                      () => multiSendController.selectedNetwork.value != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Token:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.whiteText,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TokenDropdown(controller: multiSendController),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

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
                      child: EnhancedButton(
                        text: 'Load Addresses from .txt',
                        onPressed: () => controller.loadAddressesFromFile(),
                        isPrimary: false,
                        icon: const Icon(Icons.file_upload,
                            color: AppTheme.primaryAccent),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount Input
                    Obx(
                      () => multiSendController.selectedNetwork.value != null &&
                              controller.selectedToken.value != null &&
                              controller.addresses.value
                                  .isNotEmpty // Assuming addresses are validated elsewhere
                          ? Column(
                              children: [
                                EnhancedAmountInput(controller: controller),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

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
