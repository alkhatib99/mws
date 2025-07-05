import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/utils/responsive_helper.dart';
import 'package:mws/widgets/custom_text_field.dart';
import 'package:mws/widgets/enhanced_wallet_card.dart';
import 'package:mws/widgets/network_selector.dart';
import 'package:mws/widgets/wallet_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _recipientsController = TextEditingController();
  final _amountController = TextEditingController();
  final _scrollController = ScrollController();

  // Mock wallet controller - replace with actual GetX controller
  final _walletController = Get.put(EnhancedWalletController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipientsController.dispose();
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: ResponsiveHelper.buildResponsiveSafeArea(
        context: context,
        child: ResponsiveHelper.buildConstrainedContainer(
          context: context,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              _buildSliverAppBar(context),

              // Main Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                        height: ResponsiveHelper.getSpacing(context,
                            multiplier: 2)),

                    // Wallet Status Card
                    _buildWalletStatusSection(context),

                    SizedBox(
                        height: ResponsiveHelper.getSpacing(context,
                            multiplier: 2)),

                    // Main Content Tabs
                    _buildMainContent(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: ResponsiveHelper.getValue(
        context,
        mobile: 120,
        tablet: 140,
        desktop: 160,
      ),
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryBackground,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Multi Wallet Sender',
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: AppTheme.whiteText,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryAccent.withOpacity(0.1),
                AppTheme.primaryBackground,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height:
                        ResponsiveHelper.getSpacing(context, multiplier: 3)),
                Icon(
                  Icons.send_rounded,
                  size: ResponsiveHelper.getLargeIconSize(context),
                  color: AppTheme.primaryAccent,
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Send crypto to multiple wallets',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getCaptionFontSize(context),
                    color: AppTheme.lightGrayText,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: AppTheme.primaryAccent,
            size: ResponsiveHelper.getIconSize(context),
          ),
          onPressed: () {
            // TODO: Open settings
          },
        ),
        SizedBox(width: ResponsiveHelper.getSpacing(context)),
      ],
    );
  }

  Widget _buildWalletStatusSection(BuildContext context) {
    return Obx(() {
      return WalletStatusCard(
        connectedAddress: _walletController.connectedAddress.value,
        walletName: _walletController.walletName.value,
        networkName: _walletController.networkName.value,
        networkSymbol: _walletController.networkSymbol.value,
        balance: _walletController.balance.value,
        isConnected: _walletController.isConnected.value,
        isDesktop: ResponsiveHelper.isDesktop(context),
        onDisconnect: () => _walletController.disconnect(),
        onSwitchNetwork: () => _showNetworkSelector(context),
      );
    });
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: ResponsiveHelper.getCardBorderRadius(context),
      ),
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.neutralGray.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryAccent,
              unselectedLabelColor: AppTheme.lightGrayText,
              indicatorColor: AppTheme.primaryAccent,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: ResponsiveHelper.getBodyFontSize(context),
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
              tabs: const [
                Tab(text: 'Connect Wallet'),
                Tab(text: 'Multi Send'),
              ],
            ),
          ),

          // Tab Content
          SizedBox(
            height: ResponsiveHelper.getValue(
              context,
              mobile: 600,
              tablet: 700,
              desktop: 800,
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWalletConnectionTab(context),
                _buildMultiSendTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletConnectionTab(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          // Title
          Text(
            'Connect Your Wallet',
            style: TextStyle(
              fontSize: ResponsiveHelper.getHeadlineFontSize(context),
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteText,
              fontFamily: 'Montserrat',
            ),
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          Text(
            'Choose your preferred wallet to get started with multi-send transactions.',
            style: TextStyle(
              fontSize: ResponsiveHelper.getBodyFontSize(context),
              color: AppTheme.lightGrayText,
              fontFamily: 'Montserrat',
            ),
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context, multiplier: 2)),

          // Wallet Options
          Expanded(
            child: _buildWalletOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOptions(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Obx(() {
      return ListView(
        children: [
          // MetaMask
          EnhancedWalletCard(
            name: 'MetaMask',
            iconPath: 'assets/images/metamask.png',
            description: 'Connect using MetaMask browser extension',
            isAvailable: true,
            isConnecting: _walletController.isConnecting.value &&
                _walletController.connectingWallet.value == 'MetaMask',
            isSelected: _walletController.walletName.value == 'MetaMask',
            isDesktop: isDesktop,
            isTablet: isTablet,
            onTap: () => _walletController.connectMetaMask(),
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          // WalletConnect
          EnhancedWalletCard(
            name: 'WalletConnect',
            iconPath: 'assets/images/walletconnect.png',
            description: 'Connect using WalletConnect protocol',
            isAvailable: true,
            isConnecting: _walletController.isConnecting.value &&
                _walletController.connectingWallet.value == 'WalletConnect',
            isSelected: _walletController.walletName.value == 'WalletConnect',
            isDesktop: isDesktop,
            isTablet: isTablet,
            onTap: () => _walletController.connectWalletConnect(),
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          // Private Key Import
          EnhancedWalletCard(
            name: 'Private Key',
            iconPath: 'assets/images/private_key.png',
            description: 'Import wallet using private key (Advanced)',
            isAvailable: true,
            isConnecting: _walletController.isConnecting.value &&
                _walletController.connectingWallet.value == 'PrivateKey',
            isSelected: _walletController.walletName.value == 'Private Key',
            isDesktop: isDesktop,
            isTablet: isTablet,
            onTap: () => _showPrivateKeyImport(context),
          ),
        ],
      );
    });
  }

  Widget _buildMultiSendTab(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          // Title
          Text(
            'Multi Send Transaction',
            style: TextStyle(
              fontSize: ResponsiveHelper.getHeadlineFontSize(context),
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteText,
              fontFamily: 'Montserrat',
            ),
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          // Network Selector
          NetworkSelector(
            selectedChainId: _walletController.selectedChainId.value,
            onNetworkChanged: (chainId) =>
                _walletController.switchNetwork(chainId),
            isEnabled: _walletController.isConnected.value,
            showBalance: true,
            balance: _walletController.balance.value,
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context, multiplier: 2)),

          // Recipients, Input
          CustomTextField(
            label: 'Recipients',
            hint: 'Enter wallet addresses (one per line)',
            controller: _recipientsController,
            maxLines: 5,
            enabled: _walletController.isConnected.value,
            helperText: 'Enter multiple Ethereum addresses, one per line',
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context, multiplier: 2)),

          // Amount Input
          AmountTextField(
            label: 'Amount per Address',
            hint: '0.0',
            controller: _amountController,
            enabled: _walletController.isConnected.value,
            currency: _walletController.networkSymbol.value,
            onMaxPressed: () {
              // TODO: Set max amount
            },
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context, multiplier: 2)),

          // Send Button
          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.getButtonSize(context).height,
            child: ElevatedButton.icon(
              onPressed:
                  _walletController.isConnected.value ? _sendTransaction : null,
              icon: Icon(
                Icons.send_rounded,
                size: ResponsiveHelper.getIconSize(context),
              ),
              label: Text(
                'Send Transaction',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              style: AppTheme.primaryButtonStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _showNetworkSelector(BuildContext context) {
    ResponsiveHelper.showResponsiveBottomSheet(
      context: context,
      child: Container(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Network',
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.whiteText,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getSpacing(context, multiplier: 2)),
            NetworkSelector(
              selectedChainId: _walletController.selectedChainId.value,
              onNetworkChanged: (chainId) {
                _walletController.switchNetwork(chainId);
                Navigator.pop(context);
              },
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivateKeyImport(BuildContext context) {
    final privateKeyController = TextEditingController();
    final passwordController = TextEditingController();

    ResponsiveHelper.showResponsiveBottomSheet(
      context: context,
      child: Container(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Import Private Key',
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.whiteText,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: AppTheme.warningRed,
                    size: ResponsiveHelper.getIconSize(context),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Expanded(
                    child: Text(
                      'Only use this feature on trusted devices. Never share your private key.',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getCaptionFontSize(context),
                        color: AppTheme.warningRed,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getSpacing(context, multiplier: 2)),
            CustomTextField(
              label: 'Private Key',
              hint: 'Enter your private key',
              controller: privateKeyController,
              obscureText: true,
            ),
            SizedBox(
                height: ResponsiveHelper.getSpacing(context, multiplier: 2)),
            CustomTextField(
              label: 'Password',
              hint: 'Enter a password to encrypt your key',
              controller: passwordController,
              obscureText: true,
            ),
            SizedBox(
                height: ResponsiveHelper.getSpacing(context, multiplier: 2)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _walletController.importPrivateKey(
                        privateKeyController.text,
                        passwordController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Import'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendTransaction() {
    // TODO: Implement transaction sending
    ResponsiveHelper.showResponsiveSnackBar(
      context: context,
      message: 'Transaction functionality will be implemented',
      backgroundColor: AppTheme.primaryAccent,
    );
  }
}
