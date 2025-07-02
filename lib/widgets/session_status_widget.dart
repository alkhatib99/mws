import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/session_service.dart';
import '../../../services/web3_service.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';

class SessionStatusWidget extends StatelessWidget {
  const SessionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = Get.find<SessionService>();

    return Obx(() {
      if (!sessionService.isSessionActive.value) {
        return const SizedBox.shrink();
      }

      final walletName = sessionService.connectedWallet.value;
      final address = sessionService.connectedAddress.value;
      final shortAddress = address.isNotEmpty 
          ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
          : '';

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryAccent.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primaryAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  walletName,
                  style: const TextStyle(
                    color: AppTheme.whiteText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  shortAddress,
                  style: TextStyle(
                    color: AppTheme.lightGrayText,
                    fontSize: 10,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppTheme.lightGrayText,
                size: 16,
              ),
              color: AppTheme.secondaryBackground,
              onSelected: (value) {
                switch (value) {
                  case 'switch_account':
                    _showSwitchAccountDialog(context, sessionService);
                    break;
                  case 'switch_wallet':
                    sessionService.endSession();
                    Get.offAllNamed(Routes.walletConnect);
                    break;
                  case 'disconnect':
                    sessionService.endSession();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'switch_account',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: AppTheme.whiteText, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Switch Account',
                        style: TextStyle(
                          color: AppTheme.whiteText,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'switch_wallet',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: AppTheme.whiteText, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Switch Wallet',
                        style: TextStyle(
                          color: AppTheme.whiteText,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'disconnect',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Disconnect',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showSwitchAccountDialog(BuildContext context, SessionService sessionService) {
    final TextEditingController addressController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Account',
                style: TextStyle(
                  color: AppTheme.whiteText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the new account address:',
                style: TextStyle(
                  color: AppTheme.lightGrayText,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                style: TextStyle(
                  color: AppTheme.whiteText,
                  fontFamily: 'Montserrat',
                ),
                decoration: InputDecoration(
                  hintText: '0x...',
                  hintStyle: TextStyle(
                    color: AppTheme.lightGrayText,
                    fontFamily: 'Montserrat',
                  ),
                  filled: true,
                  fillColor: AppTheme.textFieldBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.lightGrayText,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final newAddress = addressController.text.trim();
                      if (newAddress.isNotEmpty && newAddress.startsWith('0x') && newAddress.length == 42) {
                        sessionService.switchAccount(newAddress);
                        Get.back();
                      } else {
                        Get.snackbar(
                          'Invalid Address',
                          'Please enter a valid Ethereum address',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Switch',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

