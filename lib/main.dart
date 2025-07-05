import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/routes/app_pages.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/session_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // await dotenv.load(fileName: ".env");
  // Initialize session service
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


