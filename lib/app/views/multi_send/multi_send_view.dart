import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/widgets/address_input.dart';
import 'package:mws/widgets/network_dropdown.dart';
import 'package:mws/widgets/send_button.dart';
import 'package:mws/widgets/social_links.dart';
import 'package:mws/widgets/transaction_output.dart';
import 'package:mws/utils/constants.dart';
import 'package:mws/widgets/custom_text_field.dart';

class MultiSendView extends StatelessWidget {
  const MultiSendView({super.key});

  @override
  Widget build(BuildContext context) {
    final MultiSendController controller = Get.find();

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Multi Wallet Sender',
          style:
              TextStyle(fontFamily: 'Montserrat'), // Ensure Montserrat is used
        ),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Coming Soon',
                  'Wallet connection will be implemented here.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.primaryAccent,
                  colorText: Colors.white,
                );
              },
              icon:
                  const Icon(Icons.account_balance_wallet, color: Colors.white),
              label: const Text('Connect Wallet',
                  style: TextStyle(color: Colors.white)),
              style: AppTheme.primaryButtonStyle, // Use new primaryButtonStyle
            ),
          ),
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

                    // Amount Input

                    CustomTextField(
                      label: 'Amount (ETH):',
                      hint: 'Enter amount in ETH',
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => controller.amount.value = value,
                    ),

                    const SizedBox(height: 16),

                    // Network Dropdown
                    NetworkDropdown(controller: controller),
                    const SizedBox(height: 16),

                    // Add Custom Network Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.showAddNetworkDialog(),
                        style: AppTheme
                            .secondaryButtonStyle, // Use new secondaryButtonStyle
                        child: const Text('Add Custom Network'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Addresses Input
                    AddressInput(controller: controller),
                    const SizedBox(height: 24),

                    // Send Button
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
