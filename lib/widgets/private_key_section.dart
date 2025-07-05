import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/wallet_controller.dart'; // Changed from wallet_connect_controller.dart
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/widgets/glass_card.dart';

class PrivateKeySection extends StatelessWidget {
  final WalletController controller; // Changed type

  const PrivateKeySection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return GlassCard(
      padding: EdgeInsets.all(isDesktop
          ? 32
          : isTablet
              ? 24
              : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Import Wallet',
            style: TextStyle(
              fontSize: isDesktop
                  ? 24
                  : isTablet
                      ? 20
                      : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteText,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            'Enter your private key to import an existing wallet',
            style: TextStyle(
              fontSize: isDesktop
                  ? 16
                  : isTablet
                      ? 14
                      : 12,
              color: AppTheme.lightGrayText,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(
              height: isDesktop
                  ? 24
                  : isTablet
                      ? 20
                      : 16),

          // Private key input form
          Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Private key input field
                Obx(
                  () => TextFormField(
                      controller: controller.privateKeyController,
                      obscureText: !controller.isPrivateKeyVisible.value,
                      maxLines: controller.isPrivateKeyVisible.value
                          ? (controller.isDesktop ? 2 : 3)
                          : 1,
                      style: TextStyle(
                        color: AppTheme.whiteText,
                        fontSize: controller.subtitleFontSize,
                        fontFamily: 'Montserrat',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Private Key',
                        labelStyle: TextStyle(
                          color: AppTheme.lightGrayText,
                          fontFamily: 'Montserrat',
                        ),
                        hintText: 'Enter your private key (64 characters)',
                        hintStyle: TextStyle(
                          color: AppTheme.lightGrayText.withOpacity(0.7),
                          fontFamily: 'Montserrat',
                        ),
                        filled: true,
                        fillColor: AppTheme.textFieldBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryAccent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryAccent,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.warningRed,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.warningRed,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: controller.togglePrivateKeyVisibility,
                          icon: Icon(
                            controller.isPrivateKeyVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.lightGrayText,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isDesktop ? 20 : 16,
                        ),
                      )),
                ),

                // Error message
                Obx(() => controller.privateKeyError.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          controller.privateKeyError.value,
                          style: TextStyle(
                            color: AppTheme.warningRed,
                            fontSize: (isDesktop
                                ? 14
                                : isTablet
                                    ? 12
                                    : 10),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),

                SizedBox(
                    height: isDesktop
                        ? 24
                        : isTablet
                            ? 20
                            : 16),

                // Import button
                SizedBox(
                  width: double.infinity,
                  height: isDesktop
                      ? 56
                      : isTablet
                          ? 52
                          : 48,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.importPrivateKey(
                              // controller.privateKeyController.text, controller.passwordController.text
                              ), // Pass parameters
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryBackground,
                          foregroundColor: AppTheme.whiteText,
                          elevation: 0,
                          shadowColor:
                              AppTheme.secondaryBackground.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.whiteText,
                                  ),
                                ),
                              )
                            : Text(
                                'Import Wallet',
                                style: TextStyle(
                                  fontSize: isDesktop
                                      ? 16
                                      : isTablet
                                          ? 14
                                          : 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


