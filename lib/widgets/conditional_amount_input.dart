import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/multi_send_controller.dart';
import '../../app/theme/app_theme.dart';

class ConditionalAmountInput extends StatelessWidget {
  final MultiSendController controller;

  const ConditionalAmountInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only show amount input if addresses are valid and token is selected
      if (!controller.areAddressesValid.value || !controller.isTokenSelected.value) {
        return const SizedBox.shrink();
      }

      final selectedToken = controller.selectedToken.value;
      if (selectedToken == null) {
        return const SizedBox.shrink();
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Amount Input Section
            Container(
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with token info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Token Logo
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              selectedToken.logoPath,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.currency_exchange,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        Text(
                          'Amount (${selectedToken.symbol})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Balance info
                        Obx(() {
                          final balance = controller.tokenBalances[selectedToken.symbol] ?? '0.0';
                          final usdValue = controller.tokenUsdValues[selectedToken.symbol] ?? '0.00';
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Balance: $balance ${selectedToken.symbol}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              Text(
                                '\$$usdValue',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  // Amount Input Field
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.0',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 18,
                                    fontFamily: 'Montserrat',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppTheme.primaryAccent),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.primaryBackground,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // MAX Button
                            Obx(() {
                              final balance = controller.tokenBalances[selectedToken.symbol] ?? '0.0';
                              
                              return ElevatedButton(
                                onPressed: () {
                                  controller.amountController.text = balance;
                                  controller.amount.value = balance;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'MAX',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // USD Estimation
                        Obx(() {
                          final amountText = controller.amountController.text;
                          final amount = double.tryParse(amountText) ?? 0.0;
                          final usdValue = controller.tokenUsdValues[selectedToken.symbol] ?? '0.00';
                          final usdPrice = double.tryParse(usdValue.replaceAll(',', '')) ?? 0.0;
                          final totalUsd = amount * (usdPrice / (controller.tokenBalances[selectedToken.symbol] != null ? 
                              double.tryParse(controller.tokenBalances[selectedToken.symbol]!.replaceAll(',', '')) ?? 1.0 : 1.0));
                          
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '≈ \$${totalUsd.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

