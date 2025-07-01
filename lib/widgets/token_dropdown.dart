import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/multi_send_controller.dart';
import '../../app/data/models/token_model.dart';
import '../../app/theme/app_theme.dart';

class TokenDropdown extends StatelessWidget {
  final MultiSendController controller;

  const TokenDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedNetworkName = controller.selectedNetwork.value;
      final network = controller.networks[selectedNetworkName];
      final tokens = network?.supportedTokens ?? [];

      if (tokens.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: const Text(
            'No tokens available for this network',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Token',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            ...tokens.map((token) => _buildTokenOption(token)),
          ],
        ),
      );
    });
  }

  Widget _buildTokenOption(Token token) {
    return Obx(() {
      final isSelected = controller.selectedToken.value?.symbol == token.symbol;
      
      return InkWell(
        onTap: () => controller.setSelectedToken(token),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryAccent.withOpacity(0.1) : Colors.transparent,
            border: isSelected ? Border.all(color: AppTheme.primaryAccent, width: 2) : null,
          ),
          child: Row(
            children: [
              // Token Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    token.logoPath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.currency_exchange,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Token Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      token.symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      token.name,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Balance Display
              Obx(() {
                final balance = controller.tokenBalances[token.symbol] ?? '0.0';
                final usdValue = controller.tokenUsdValues[token.symbol] ?? '0.00';
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      '\$$usdValue',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                );
              }),
              
              // Selection Indicator
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryAccent,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

