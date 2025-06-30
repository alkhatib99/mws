// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mws/app/controllers/wallet_connect_controller.dart';
// import 'package:mws/app/theme/app_theme.dart';
// import 'package:mws/utils/constants.dart';
// import 'package:mws/widgets/custom_text_field.dart';

// class EnhancedWalletConnectView extends StatefulWidget {
//   const EnhancedWalletConnectView({super.key});

//   @override
//   State<EnhancedWalletConnectView> createState() =>
//       _EnhancedWalletConnectViewState();
// }

// class _EnhancedWalletConnectViewState extends State<EnhancedWalletConnectView>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOutCubic,
//     ));

//     // Start animations
//     _fadeController.forward();
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _slideController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final WalletConnectController controller = Get.find();
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 768;
//     final isMobile = size.width < 600;

//     return Scaffold(
//       backgroundColor: AppTheme.primaryBackground,
//       body: SafeArea(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 16.0 : 24.0,
//                 vertical: 20.0,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _buildHeader(isMobile),
//                   SizedBox(height: isMobile ? 32 : 48),
//                   _buildMainContent(controller, isMobile, isTablet),
//                   SizedBox(height: isMobile ? 24 : 32),
//                   _buildFooter(isMobile),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(bool isMobile) {
//     return Column(
//       children: [
//         _buildAnimatedLogo(isMobile),
//         SizedBox(height: isMobile ? 24 : 32),
//         Text(
//           'Connect Your Wallet',
//           style: TextStyle(
//             fontSize: isMobile ? 28 : 36,
//             fontWeight: FontWeight.bold,
//             color: AppTheme.whiteText,
//             fontFamily: 'Montserrat',
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: isMobile ? 8 : 12),
//         Text(
//           'Choose your preferred wallet to get started with multi-send transactions',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             color: AppTheme.lightGrayText,
//             fontFamily: 'Montserrat',
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildAnimatedLogo(bool isMobile) {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 1000),
//       tween: Tween(begin: 0.8, end: 1.0),
//       curve: Curves.elasticOut,
//       builder: (context, scale, child) {
//         return Transform.scale(
//           scale: scale,
//           child: Container(
//             width: isMobile ? 120 : 150,
//             height: isMobile ? 120 : 150,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppTheme.primaryAccent.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(24),
//               child: Image.asset(
//                 AppConstants.bagLogoPath,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [AppTheme.primaryAccent, AppTheme.blueAccent],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.account_balance_wallet,
//                     size: 60,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMainContent(
//       WalletConnectController controller, bool isMobile, bool isTablet) {
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: isTablet ? 600 : double.infinity,
//       ),
//       child: Column(
//         children: [
//           _buildWalletOptions(controller, isMobile),
//           SizedBox(height: isMobile ? 24 : 32),
//           _buildDivider(),
//           SizedBox(height: isMobile ? 24 : 32),
//           _buildPrivateKeySection(controller, isMobile),
//         ],
//       ),
//     );
//   }

//   Widget _buildWalletOptions(
//       WalletConnectController controller, bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4, bottom: 16),
//           child: Text(
//             'Popular Wallets',
//             style: TextStyle(
//               fontSize: isMobile ? 18 : 20,
//               fontWeight: FontWeight.bold,
//               color: AppTheme.whiteText,
//               fontFamily: 'Montserrat',
//             ),
//           ),
//         ),
//         _buildWalletGrid(controller, isMobile),
//       ],
//     );
//   }

//   Widget _buildWalletGrid(WalletConnectController controller, bool isMobile) {
//     final wallets = [
//       {
//         'name': 'MetaMask',
//         'icon': 'assets/images/metamask_logo.png',
//         'description': 'Most popular Ethereum wallet',
//         'status': 'available',
//       },
//       {
//         'name': 'Coinbase Wallet',
//         'icon': 'assets/images/coinbase_logo.png',
//         'description': 'Easy-to-use wallet by Coinbase',
//         'status': 'available',
//       },
//       {
//         'name': 'Trust Wallet',
//         'icon': 'assets/images/trustwallet_logo.png',
//         'description': 'Multi-chain mobile wallet',
//         'status': 'available',
//       },
//       {
//         'name': 'WalletConnect',
//         'icon': 'assets/images/walletconnect_logo.png',
//         'description': 'Connect any mobile wallet',
//         'status': 'coming_soon',
//       },
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: isMobile ? 1 : 2,
//         childAspectRatio: isMobile ? 4 : 3,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: wallets.length,
//       itemBuilder: (context, index) {
//         final wallet = wallets[index];
//         return _buildWalletCard(
//           wallet['name']!,
//           wallet['icon']!,
//           wallet['description']!,
//           wallet['status']! == 'available',
//           () => controller.connectWallet(wallet['name']!),
//           isMobile,
//         );
//       },
//     );
//   }

//   Widget _buildWalletCard(
//     String name,
//     String iconPath,
//     String description,
//     bool isAvailable,
//     VoidCallback onTap,
//     bool isMobile,
//   ) {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 200),
//       tween: Tween(begin: 1.0, end: 1.0),
//       builder: (context, scale, child) {
//         return Transform.scale(
//           scale: scale,
//           child: GestureDetector(
//             onTapDown: (_) => setState(() {}),
//             onTapUp: (_) => setState(() {}),
//             onTapCancel: () => setState(() {}),
//             onTap: isAvailable ? onTap : null,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               decoration: AppTheme.walletCardDecoration,
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(16),
//                   onTap: isAvailable ? onTap : null,
//                   child: Padding(
//                     padding: EdgeInsets.all(isMobile ? 16 : 20),
//                     child: Row(
//                       children: [
//                         _buildWalletIcon(iconPath, name, isAvailable),
//                         SizedBox(width: isMobile ? 12 : 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       name,
//                                       style: TextStyle(
//                                         fontSize: isMobile ? 16 : 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: isAvailable
//                                             ? AppTheme.whiteText
//                                             : AppTheme.lightGrayText,
//                                         fontFamily: 'Montserrat',
//                                       ),
//                                     ),
//                                   ),
//                                   if (!isAvailable)
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 4,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: AppTheme.goldAccent
//                                             .withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         'Soon',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.bold,
//                                           color: AppTheme.goldAccent,
//                                           fontFamily: 'Montserrat',
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               SizedBox(height: isMobile ? 4 : 6),
//                               Text(
//                                 description,
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 12 : 14,
//                                   color: AppTheme.lightGrayText,
//                                   fontFamily: 'Montserrat',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           size: isMobile ? 16 : 18,
//                           color: isAvailable
//                               ? AppTheme.primaryAccent
//                               : AppTheme.lightGrayText,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildWalletIcon(String iconPath, String name, bool isAvailable) {
//     return Container(
//       width: 48,
//       height: 48,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: AppTheme.textFieldBackground,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.asset(
//           iconPath,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppTheme.primaryAccent.withOpacity(0.8),
//                   AppTheme.blueAccent.withOpacity(0.8),
//                 ],
//               ),
//             ),
//             child: Icon(
//               Icons.account_balance_wallet,
//               size: 24,
//               color: isAvailable ? Colors.white : AppTheme.lightGrayText,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             height: 1,
//             color: AppTheme.neutralGray,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'OR',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: AppTheme.lightGrayText,
//               fontFamily: 'Montserrat',
//             ),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             height: 1,
//             color: AppTheme.neutralGray,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPrivateKeySection(
//       WalletConnectController controller, bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4, bottom: 16),
//           child: Text(
//             'Import with Private Key',
//             style: TextStyle(
//               fontSize: isMobile ? 18 : 20,
//               fontWeight: FontWeight.bold,
//               color: AppTheme.whiteText,
//               fontFamily: 'Montserrat',
//             ),
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.all(isMobile ? 20 : 24),
//           decoration: AppTheme.glassCardDecoration,
//           child: Column(
//             children: [
//               CustomTextField(
//                 label: 'Private Key',
//                 hint: 'Enter your private key (0x...)',
//                 obscureText: true,
//                 controller: controller.privateKeyController,
//               ),
//               SizedBox(height: isMobile ? 16 : 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: controller.navigateToMultiSend,
//                   style: AppTheme.primaryButtonStyle.copyWith(
//                     padding: MaterialStateProperty.all(
//                       EdgeInsets.symmetric(
//                         vertical: isMobile ? 16 : 18,
//                         horizontal: 24,
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'Continue with Private Key',
//                     style: TextStyle(
//                       fontSize: isMobile ? 16 : 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: isMobile ? 12 : 16),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.security,
//                     size: 16,
//                     color: AppTheme.lightGrayText,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Your private key is stored locally and never shared',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.lightGrayText,
//                         fontFamily: 'Montserrat',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFooter(bool isMobile) {
//     return Column(
//       children: [
//         TextButton(
//           onPressed: () => _showHelpDialog(),
//           child: Text(
//             "I don't have a wallet",
//             style: TextStyle(
//               fontSize: isMobile ? 14 : 16,
//               color: AppTheme.primaryAccent,
//               fontFamily: 'Montserrat',
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//         SizedBox(height: isMobile ? 16 : 20),
//         Text(
//           'Secure • Decentralized • Your Keys, Your Crypto',
//           style: TextStyle(
//             fontSize: 12,
//             color: AppTheme.lightGrayText,
//             fontFamily: 'Montserrat',
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   void _showHelpDialog() {
//     Get.dialog(
//       Dialog(
//         backgroundColor: AppTheme.secondaryBackground,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.help_outline,
//                 size: 48,
//                 color: AppTheme.primaryAccent,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Need a Wallet?',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.whiteText,
//                   fontFamily: 'Montserrat',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'You can create a new wallet using:\n\n• MetaMask (Browser extension)\n• Coinbase Wallet (Mobile app)\n• Trust Wallet (Mobile app)\n\nThese are free and secure options to get started with crypto.',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: AppTheme.lightGrayText,
//                   fontFamily: 'Montserrat',
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () => Get.back(),
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(
//                           color: AppTheme.lightGrayText,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Get.back();
//                         // Could open MetaMask download page
//                       },
//                       style: AppTheme.primaryButtonStyle,
//                       child: const Text('Get MetaMask'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
