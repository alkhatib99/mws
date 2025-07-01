import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/routes/app_pages.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/session_service.dart';

void main() {
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
      theme: AppTheme.darkTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

