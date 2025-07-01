import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/widgets/address_input.dart';
import 'package:mws/widgets/network_dropdown.dart';
import 'package:mws/widgets/token_dropdown.dart';
import 'package:mws/widgets/conditional_amount_input.dart';
import 'package:mws/widgets/send_button.dart';
import 'package:mws/widgets/social_links.dart';
import 'package:mws/widgets/transaction_output.dart';
import 'package:mws/utils/constants.dart';

class MultiSendView extends StatelessWidget {
  const MultiSendView({super.key});

  @override
  Widget build(BuildContext context) {
    final MultiSendController controller = Get.find();

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'BAG Multi Wallet Sender DApp',
          style:
              TextStyle(fontFamily: 'Montserrat'), // Ensure Montserrat is used
        ),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16.0),
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       Get.snackbar(
          //         'Coming Soon',
          //         'Wallet connection will be implemented here.',
          //         snackPosition: SnackPosition.BOTTOM,
          //         backgroundColor: AppTheme.primaryAccent,
          //         colorText: Colors.white,
          //       );
          //     },
          //     icon:
          //         const Icon(Icons.account_balance_wallet, color: Colors.white),
          //     label: const Text('Connect Wallet',
          //         style: TextStyle(color: Colors.white)),
          //     style: AppTheme.primaryButtonStyle, // Use new primaryButtonStyle
          //   ),
          // ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                        child: Image.asset(
                          AppConstants.bagLogoPath,
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

                    // Step 1: Network Selection
                    NetworkDropdown(controller: controller),
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

                    // Step 2: Token Selection (only show if network is selected)
                    Obx(() {
                      if (!controller.isNetworkSelected.value) {
                        return const SizedBox.shrink();
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: [
                            TokenDropdown(controller: controller),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    }),

                    // Step 3: Addresses Input (only show if token is selected)
                    Obx(() {
                      if (!controller.isTokenSelected.value) {
                        return const SizedBox.shrink();
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: [
                            AddressInput(controller: controller),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    }),

                    // Step 4: Amount Input (only show if addresses are valid)
                    ConditionalAmountInput(controller: controller),
                    const SizedBox(height: 24),

                    // Step 5: Send Button (conditional)
                    SendButton(controller: controller),
                    const SizedBox(height: 24),

                    // Transaction Output
                    TransactionOutput(controller: controller),
                    const SizedBox(height: 32),

                    // Social Links
                    const SocialLinks(),
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
