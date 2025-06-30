import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/wallet_connect_controller.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/utils/constants.dart';
import 'package:mws/widgets/custom_text_field.dart';
import 'package:collection/collection.dart';

class WalletConnectView extends StatelessWidget {
  const WalletConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletConnectController controller = Get.find();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateScreenSize(MediaQuery.of(context).size);
    });

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller.fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: controller.fadeAnimation,
              child: SlideTransition(
                position: controller.slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: controller.horizontalPadding,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(controller),
                      SizedBox(height: controller.verticalSpacing + 16),
                      _buildMainContent(controller),
                      SizedBox(height: controller.verticalSpacing),
                      _buildFooter(controller),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(WalletConnectController controller) {
    return Column(
      children: [
        _buildAnimatedLogo(controller),
        SizedBox(height: controller.verticalSpacing),
        Text(
          'Connect Your Wallet',
          style: TextStyle(
            fontSize: controller.titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.whiteText,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: controller.isMobile ? 8 : 12),
        Text(
          'Choose your preferred wallet to get started with multi-send transactions',
          style: TextStyle(
            fontSize: controller.subtitleFontSize,
            color: AppTheme.lightGrayText,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnimatedLogo(WalletConnectController controller) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.8, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: controller.logoSize,
            height: controller.logoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                AppConstants.bagLogoPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryAccent, AppTheme.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(WalletConnectController controller) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: controller.maxContentWidth,
      ),
      child: Column(
        children: [
          _buildWalletOptions(controller),
          SizedBox(height: controller.verticalSpacing),
          _buildDivider(),
          SizedBox(height: controller.verticalSpacing),
          _buildPrivateKeySection(controller),
        ],
      ),
    );
  }

  Widget _buildWalletOptions(WalletConnectController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Popular Wallets',
            style: TextStyle(
              fontSize: controller.sectionTitleFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteText,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        _buildWalletGrid(controller),
      ],
    );
  }

  Widget _buildWalletGrid(WalletConnectController controller) {
    return Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: controller.gridCrossAxisCount,
            childAspectRatio: controller.gridChildAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.wallets.length,
          itemBuilder: (context, index) {
            final wallet = controller.wallets[index];
            return _buildWalletCard(
              controller,
              wallet['name']!,
              wallet['icon']!,
              wallet['description']!,
              wallet['status']! == 'available',
            );
          },
        ));
  }

  Widget _buildWalletCard(
    WalletConnectController controller,
    String name,
    String iconPath,
    String description,
    bool isAvailable,
  ) {
    return Obx(() {
      final wallet =
          controller.wallets.firstWhereOrNull((w) => w['name'] == name);
      if (wallet == null) return const SizedBox();
      final isWalletConnect = wallet['isWalletConnect'] == true;
      final isConnecting = controller.isWalletConnecting(name);
      final isLoading = controller.isLoading.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isConnecting
            ? AppTheme.walletCardHoverDecoration
            : AppTheme.walletCardDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isAvailable && !isLoading
                ? () => controller.connectWallet(name)
                : null,
            child: Padding(
              padding: EdgeInsets.all(controller.isMobile ? 16 : 20),
              child: Row(
                children: [
                  _buildWalletIcon(iconPath, name, isAvailable, isConnecting),
                  SizedBox(width: controller.isMobile ? 12 : 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: controller.isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: isAvailable
                                      ? AppTheme.whiteText
                                      : AppTheme.lightGrayText,
                                  fontFamily: 'Montserrat',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isWalletConnect)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Modal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryAccent,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: controller.isMobile ? 4 : 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: controller.isMobile ? 12 : 14,
                            color: AppTheme.lightGrayText,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isConnecting)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryAccent,
                        ),
                      ),
                    )
                  else
                    Icon(
                      isWalletConnect
                          ? Icons.open_in_new
                          : Icons.arrow_forward_ios,
                      size: controller.isMobile ? 16 : 18,
                      color: isAvailable
                          ? AppTheme.primaryAccent
                          : AppTheme.lightGrayText,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWalletIcon(
      String iconPath, String name, bool isAvailable, bool isConnecting) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.textFieldBackground,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              iconPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryAccent.withOpacity(0.8),
                      AppTheme.blueAccent.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 24,
                  color: isAvailable ? Colors.white : AppTheme.lightGrayText,
                ),
              ),
            ),
            if (isConnecting)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.neutralGray)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightGrayText,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.neutralGray)),
      ],
    );
  }

  Widget _buildPrivateKeySection(WalletConnectController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Import with Private Key',
            style: TextStyle(
              fontSize: controller.sectionTitleFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteText,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(controller.isMobile ? 20 : 24),
          decoration: AppTheme.glassCardDecoration,
          child: Column(
            children: [
              Stack(
                children: [
                  Obx(() => CustomTextField(
                        label: 'Private Key',
                        hint: 'Enter your private key (0x...)',
                        obscureText: !controller.isPrivateKeyVisible.value,
                        controller: controller.privateKeyController,
                        validator: controller.validatePrivateKey,
                        maxLines: controller.isPrivateKeyVisible.value
                            ? (controller.isDesktop ? 2 : 3)
                            : 1,
                      )),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Obx(() => IconButton(
                          onPressed: controller.togglePrivateKeyVisibility,
                          icon: Icon(
                            controller.isPrivateKeyVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.lightGrayText,
                            size: 20,
                          ),
                        )),
                  ),
                ],
              ),
              Obx(() {
                if (controller.privateKeyError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      controller.privateKeyError.value,
                      style: TextStyle(
                        color: AppTheme.warningRed,
                        fontSize: controller.subtitleFontSize - 2,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              SizedBox(height: controller.verticalSpacing),
              SizedBox(
                width: double.infinity,
                height: controller.walletConnectButtonHeight,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.navigateToMultiSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: AppTheme.whiteText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.primaryAccent.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(
                      horizontal: controller.horizontalPadding,
                    ),
                  ),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.whiteText),
                        )
                      : Text(
                          'Import Wallet',
                          style: TextStyle(
                            fontSize: controller.buttonFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(WalletConnectController controller) {
    return Column(
      children: [
        SizedBox(height: controller.verticalSpacing),
        Text(
          '© 2023 MWS. All rights reserved.',
          style: TextStyle(
            fontSize: controller.subtitleFontSize - 2,
            color: AppTheme.lightGrayText,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}



