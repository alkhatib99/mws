import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:html' as html;

import 'package:mws/app/controllers/wallet_connect_controller.dart';
import 'package:mws/app/controllers/wallet_controller.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/wallet_service_interface.dart';
import 'package:mws/web/js/phantom_bridge.dart';
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
    final WalletConnectController controller;
    try {
      controller = Get.find<WalletConnectController>();
    } catch (e) {
      return Scaffold(
        body: Center(child: Text('Error initializing wallet controller: $e')),
      );
    } // Ensure the controller is initialized
    // final   walletController = Get.find<WalletController>();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.updateScreenSize(MediaQuery.of(context).size);
    // });

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
    return Center(
      child: Column(
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
      ),
    );
  }

  Widget _buildMainContent(WalletConnectController controller) {
    try {
      return Column(
        children: [
          Obx(() => _buildConnectionStatus(controller)),
  Obx(() {
  if (controller.hasError.value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InlineErrorWidget(
        message: controller.lastError.value,
        onRetry: controller.canRetry.value
            ? () => controller.retryLastConnection()
            : null,
        showRetry: controller.canRetry.value,
      ),
    );
  }
  return const SizedBox.shrink();
}),

          _buildWalletOptions(controller),
          SizedBox(height: controller.sectionSpacing),
          PrivateKeySection(controller: controller),
        ],
      );
    } catch (e) {
      return ErrorDisplayWidget(
          title: 'Error',
          message: 'An error occurred while connecting to the wallet.');
    }
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
        walletName: controller.selectedWallet.value == WalletType.metamask
            ? 'MetaMask'
            : controller.selectedWallet.value == WalletType.walletConnect
                ? 'WalletConnect'
                : controller.selectedWallet.value == WalletType.privateKey
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
            textAlign: TextAlign.center,  
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
            textAlign: TextAlign.center,
            color: AppTheme.lightGrayText,
          ),
          SizedBox(height: controller.verticalSpacing),
          Obx(() => Column(
                children: controller.wallets.mapIndexed((index, wallet) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom:
                            index != controller.wallets.length - 1 ? 16.0 : 0),
                    child: _buildWalletCard(
                      controller,
                      wallet['name'] ?? 'Unknown Wallet',
                      wallet['icon'] ?? 'assets/images/default_wallet.png',
                      wallet['description'] ?? '',
                      wallet['isAvailable'] ?? true,
                      wallet['isWalletConnect'] ?? false,
                    ),
                  );
                }).toList(),
              ))

          // Obx(() => ResponsiveGrid(
          //       mobileColumns: 1,
          //       tabletColumns: 2,
          //       desktopColumns: controller.gridCrossAxisCount,
          //       spacing: controller.isDesktop ? 20 : 16,
          //       runSpacing: controller.isDesktop ? 20 : 16,
          //       childAspectRatio: controller.gridChildAspectRatio,
          //       children: controller.wallets.map((wallet) {
          //         // Add null checks and default values
          //         return _buildWalletCard(
          //           controller,
          //           wallet['name'] ?? 'Unknown Wallet',
          //           wallet['icon'] ?? 'assets/images/default_wallet.png',
          //           wallet['description'] ?? '',
          //           wallet['isAvailable'] ?? true,
          //           wallet['isWalletConnect'] ?? false,
          //         );
          //       }).toList(),
          //     )),
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
  final isPhantom = name.toLowerCase() == 'phantom';
  final isPhantomInstalled = phantom != null && phantom!.isPhantom;

  final shouldShowInstall = isPhantom && !isPhantomInstalled;

  return WalletCard(
    name: name,
    iconPath: iconPath,
    description: shouldShowInstall
        ? 'Phantom wallet is not installed. Click below to install it.'
        : description,
    isAvailable: isAvailable,
    isConnecting: controller.isConnecting.value &&
        controller.selectedWallet.value == name,
    isSelected: controller.selectedWallet.value == name,
    isDesktop: controller.isDesktop,
    isTablet: controller.isTablet,
    onTap: () {
      controller.selectedWallet.value = name;
      if (shouldShowInstall) {
        html.window.open('https://phantom.app/', '_blank');
      } else if (name == 'Phantom') {
        controller.connectPhantomWallet();
      } else if (name == 'MetaMask') {
        controller.connectWallet(walletName: name);
      } else if (name == 'WalletConnect') {
        controller.connectWallet();
        controller.showWalletConnectModal();
      }
    },
  );
}

  // Widget _buildWalletCard(
  //   WalletConnectController controller,
  //   String name,
  //   String iconPath,
  //   String description,
  //   bool isAvailable,
  //   bool isWalletConnect,
  // ) {
  //   // Add null checks for controller properties
  //   final isConnecting = controller.isConnecting.value;
  //   final isDesktop = controller.isDesktop;
  //   final isTablet = controller.isTablet;

  //   return WalletCard(
  //     name: name,
  //     iconPath: iconPath,
  //     description: description,
  //     isAvailable: isAvailable,
  //     isConnecting: isConnecting &&
  //         (controller.selectedWallet.value == name ||
  //             (isWalletConnect &&
  //                 controller.selectedWallet.value == 'WalletConnect')),
  //     isDesktop: isDesktop,
  //     isTablet: isTablet,
  //     // onTap: () async {
  //     //   controller.selectedWallet.value = name;
  //     //   if (name == 'WalletConnect') {
  //     //     await controller.connectWallet(); // ensure QR is set
  //     //     controller.showWalletConnectModal();
  //     //   } else if (name == 'MetaMask') {
  //     //     await controller.connectWallet(
  //     //       walletName: name, // pass wallet type
  //     //     ); // implement MetaMask connect logic inside controller
  //     //   } else if (name == 'Phantom') {
  //     //     Get.snackbar('Coming Soon', 'Phantom Wallet support is coming soon!');
  //     //   }
  //     // },
  //   );
  // }

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
