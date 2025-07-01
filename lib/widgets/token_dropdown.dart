import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/wallet_controller.dart';
import '../app/data/models/token_model.dart';
import '../app/theme/app_theme.dart';

class TokenDropdown extends StatelessWidget {
  final WalletController controller;

  const TokenDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final network = controller.networks[controller.selectedNetwork.value];
      if (network == null || network.supportedTokens.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryAccent.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Token>(
            value: controller.selectedToken.value,
            isExpanded: true,
            dropdownColor: AppTheme.secondaryBackground,
            style: const TextStyle(
              color: AppTheme.whiteText,
              fontSize: 16,
              fontFamily: 'Montserrat',
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.primaryAccent,
            ),
            items: network.supportedTokens.map((Token token) {
              return DropdownMenuItem<Token>(
                value: token,
                child: Row(
                  children: [
                    // Token Logo
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          token.logoPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.currency_bitcoin,
                                color: AppTheme.whiteText,
                                size: 16,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Token Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            token.symbol,
                            style: const TextStyle(
                              color: AppTheme.whiteText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          Text(
                            token.name,
                            style: TextStyle(
                              color: AppTheme.whiteText.withOpacity(0.7),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Token? newToken) {
              if (newToken != null) {
                controller.setSelectedToken(newToken);
              }
            },
          ),
        ),
      );
    });
  }
}

