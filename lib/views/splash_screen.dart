// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../routes/app_routes.dart';
// import '../themes/app_theme.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize animation controller
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     // Fade animation
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
//     ));

//     // Scale animation
//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
//     ));

//     // Start animation
//     _animationController.forward();

//     // Navigate to home screen after delay
//     Future.delayed(const Duration(milliseconds: 2500), () {
//       if (mounted) {
//         Get.offNamed(AppRoutes.home);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.primaryBackground,
//       body: Center(
//         child: AnimatedBuilder(
//           animation: _animationController,
//           builder: (context, child) {
//             return FadeTransition(
//               opacity: _fadeAnimation,
//               child: ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Logo container with shadow
//                     Container(
//                       width: 250,
//                       height: 250,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.network(
//                           'https://i.ibb.co/j9v2nvjT/new.png',
//                           width: 250,
//                           height: 250,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               width: 250,
//                               height: 250,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Center(
//                                 child: CircularProgressIndicator(
//                                   color: AppTheme.primaryAccent,
//                                 ),
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               width: 250,
//                               height: 250,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.image_not_supported,
//                                     size: 64,
//                                     color: Colors.grey,
//                                   ),
//                                   SizedBox(height: 16),
//                                   Text(
//                                     'BAG Logo',
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // App title
//                     Text(
//                       'BAG MWS DApp | Web3 Multi Wallet Sender - v1.0.0',
//                       style:
//                           Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                 color: AppTheme.whiteText,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                       textAlign: TextAlign.center,
//                     ),

//                     const SizedBox(height: 16),

//                     // Subtitle
//                     Text(
//                       'BAG Community Tool',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color: AppTheme.lightGrayText,
//                           ),
//                       textAlign: TextAlign.center,
//                     ),

//                     const SizedBox(height: 40),

//                     // Loading indicator
//                     const SizedBox(
//                       width: 40,
//                       height: 40,
//                       child: CircularProgressIndicator(
//                         color: AppTheme.primaryAccent,
//                         strokeWidth: 3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
