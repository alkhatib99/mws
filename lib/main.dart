import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/routes/app_pages.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/session_service.dart';
import 'package:mws/services/web3_service.dart';
import 'package:mws/utils/constants.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as reown_wk;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // await dotenv.load(fileName: ".env");
  // Initialize session service  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Reown WalletKit before runApp
  // await reown_wk.ReownWalletKit.createInstance(
  //   projectId: AppConstants.REOWN_PROJECT_ID,
  //   metadata: reown_wk.PairingMetadata(
  //     name: 'MWS DApp',
  //     description: 'A decentralized application for MWS',
  //     url: 'https://example.com', // Replace with your app URL
  //     icons: ['https://example.com/icon.png'], // Replace with your app icon URL
  //   ),
  //   appName: 'MWS DApp',
  //   appIcon: 'https://example.com/icon.png', // Replace with your app icon URL
  //   appDescription: 'A decentralized application for MWS',
  //   appUrl: 'https://example.com', // Replace with your app URL
  // );
  
  // Register services
  await Get.putAsync<Web3Service>(() async => Web3Service());
  
  Get.put(SessionService(), permanent: true);

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MWS DApp',
      theme: AppTheme.darkTheme.copyWith(
        cardTheme: AppTheme.darkTheme.cardTheme, // Use the CardThemeData from AppTheme
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}


