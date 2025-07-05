import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/wallet_connect_controller.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/widgets/animated_logo.dart';
import 'package:mws/widgets/glass_card.dart';
import 'package:mws/widgets/responsive_text.dart';
import 'package:mws/widgets/responsive_grid.dart';
import 'package:mws/widgets/wallet_card.dart';
import 'package:mws/widgets/private_key_section.dart';
import 'package:mws/widgets/error_display_widget.dart';
import 'package:mws/utils/constants.dart';
import 'package:collection/collection.dart';

class WalletConnectView extends StatelessWidget {
  const WalletConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletConnectController controller = Get.find();
    // Ensure the controller is initialized

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: controller.horizontalPadding,
                        vertical: 20.0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: controller.maxContentWidth,
                            minHeight: constraints.maxHeight - 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
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
          },
        ),
      ),
    );
  }

  Widget _buildHeader(WalletConnectController controller) {
    return Column(
      children: [
        AnimatedLogo(
          size: controller.logoSize,
          title: 'BAG MWS DApp',
        ),
        SizedBox(height: controller.verticalSpacing),
        ResponsiveTitle(
          'Connect Your Wallet',
          textAlign: TextAlign.center,
          color: AppTheme.whiteText,
        ),
        SizedBox(height: 12),
        ResponsiveSubtitle(
          'Choose your preferred method to connect and start sending crypto to multiple addresses',
          textAlign: TextAlign.center,
          color: AppTheme.lightGrayText,
        ),
      ],
    );
  }

  Widget _buildMainContent(WalletConnectController controller) {
    return Column(
      children: [
        // Connection Status Widget
        Obx(() => _buildConnectionStatus(controller)),

        // Error Display (if any)
        Obx(() => controller.hasError.value
            ? Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: InlineErrorWidget(
                  message: controller.lastError.value,
                  onRetry: controller.canRetry.value
                      ? () => controller.retryLastConnection()
                      : null,
                  showRetry: controller.canRetry.value,
                ),
              )
            : const SizedBox.shrink()),

        _buildWalletOptions(controller),
        SizedBox(height: controller.sectionSpacing),
        PrivateKeySection(controller: controller),
      ],
    );
  }

  Widget _buildConnectionStatus(WalletConnectController controller) {
    if (!controller.isConnecting.value &&
        !controller.hasError.value &&
        controller.connectedAddress.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ConnectionStatusWidget(
        isConnected: controller.connectedAddress.value.isNotEmpty,
        isConnecting: controller.isConnecting.value,
        errorMessage:
            controller.hasError.value ? controller.lastError.value : null,
        onRetry: controller.canRetry.value
            ? () => controller.retryLastConnection()
            : null,
        walletName: controller.connectionType.value == 'metamask'
            ? 'MetaMask'
            : controller.connectionType.value == 'walletconnect'
                ? 'WalletConnect'
                : controller.connectionType.value == 'privatekey'
                    ? 'Private Key'
                    : null,
      ),
    );
  }

  Widget _buildWalletOptions(WalletConnectController controller) {
    return GlassCard(
      padding: EdgeInsets.all(controller.isDesktop
          ? 32
          : controller.isTablet
              ? 24
              : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Connect Wallet',
            mobileFontSize: 18.0,
            tabletFontSize: 20.0,
            desktopFontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppTheme.whiteText,
            fontFamily: 'Montserrat',
          ),
          SizedBox(height: controller.isDesktop ? 12 : 8),
          ResponsiveSubtitle(
            'Connect using your preferred wallet or browser extension',
            color: AppTheme.lightGrayText,
          ),
          SizedBox(height: controller.verticalSpacing),
          Obx(() => ResponsiveGrid(
                mobileColumns: 1,
                tabletColumns: 2,
                desktopColumns: controller.gridCrossAxisCount,
                spacing: controller.isDesktop ? 20 : 16,
                runSpacing: controller.isDesktop ? 20 : 16,
                childAspectRatio: controller.gridChildAspectRatio,
                children: controller.wallets.map((wallet) {
                  return _buildWalletCard(
                    controller,
                    wallet['name']!,
                    wallet['icon']!,
                    wallet['description']!,
                    wallet['status']! == 'available',
                    wallet['isWalletConnect']! as bool,
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
    WalletConnectController controller,
    String name,
    String iconPath,
    String description,
    bool isAvailable,
    bool isWalletConnect,
  ) {
    return WalletCard(
      name: name,
      iconPath: iconPath,
      description: description,
      isAvailable: isAvailable,
      isLoading: controller.isWalletConnecting(name),
      isDesktop: controller.isDesktop,
      isTablet: controller.isTablet,
      onTap: () {
        if (isWalletConnect) {
          controller.showWalletConnectModal();
        } else {
          controller.connectWallet(name);
        }
      },
    );
  }

  Widget _buildFooter(WalletConnectController controller) {
    return Column(
      children: [
        SizedBox(height: controller.verticalSpacing),
        // Multilingual footer text (preserving Arabic content)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            AppConstants.arabicFooterText,
            style: TextStyle(
              fontSize: controller.subtitleFontSize - 2,
              color: AppTheme.lightGrayText,
              height: 1.5,
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          AppConstants.copyright,
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
