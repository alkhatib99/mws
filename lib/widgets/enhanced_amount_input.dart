import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../app/controllers/wallet_controller.dart';
import '../app/theme/app_theme.dart';
import '../services/price_service.dart';

class EnhancedAmountInput extends StatefulWidget {
  final WalletController controller;

  const EnhancedAmountInput({
    super.key,
    required this.controller,
  });

  @override
  State<EnhancedAmountInput> createState() => _EnhancedAmountInputState();
}

class _EnhancedAmountInputState extends State<EnhancedAmountInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isHovered = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedToken = widget.controller.selectedToken.value;
      final isTokenSelected = selectedToken != null;
      final tokenSymbol = selectedToken?.symbol ?? 'Token';
      final tokenPrice = widget.controller.tokenPricesUSD[tokenSymbol] ?? 0.0;
      
      // Calculate USD value of entered amount
      final enteredAmount = double.tryParse(widget.controller.amount.value) ?? 0.0;
      final usdValue = enteredAmount * tokenPrice;

      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered || _focusNode.hasFocus
                  ? AppTheme.primaryAccent
                  : AppTheme.primaryAccent.withOpacity(0.3),
              width: _isHovered || _focusNode.hasFocus ? 2 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.secondaryBackground,
                AppTheme.secondaryBackground.withOpacity(0.8),
              ],
            ),
            boxShadow: _isHovered || _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppTheme.primaryAccent.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: AppTheme.whiteText.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (isTokenSelected && selectedToken.logoPath != null)
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            selectedToken.logoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.currency_bitcoin,
                                  color: AppTheme.whiteText,
                                  size: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    Text(
                      tokenSymbol,
                      style: TextStyle(
                        color: AppTheme.primaryAccent,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Input Field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: widget.controller.amountController,
                  focusNode: _focusNode,
                  enabled: isTokenSelected,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: TextStyle(
                    color: isTokenSelected ? AppTheme.whiteText : AppTheme.whiteText.withOpacity(0.5),
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: isTokenSelected 
                        ? 'Enter amount in $tokenSymbol'
                        : 'Select a token first',
                    hintStyle: TextStyle(
                      color: AppTheme.whiteText.withOpacity(0.4),
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    widget.controller.amount.value = value;
                  },
                ),
              ),
              
              // USD Estimation
              if (isTokenSelected && enteredAmount > 0 && tokenPrice > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    '≈ ${PriceService.formatUSDValue(usdValue)}',
                    style: TextStyle(
                      color: AppTheme.whiteText.withOpacity(0.6),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              // Max Button
              if (isTokenSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        final balance = widget.controller.balance.value;
                        widget.controller.amountController.text = balance.toString();
                        widget.controller.amount.value = balance.toString();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.primaryAccent.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'MAX',
                          style: TextStyle(
                            color: AppTheme.primaryAccent,
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

