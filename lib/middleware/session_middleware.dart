import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/routes/app_routes.dart';
import 'package:mws/services/session_service.dart';

class SessionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final sessionService = Get.find<SessionService>();
    if (sessionService.isSessionActive.value) {
      return null; // Continue to the requested route
    } else {
      return const RouteSettings(name: Routes.walletConnect); // Redirect to wallet connect
    }
  }
}


