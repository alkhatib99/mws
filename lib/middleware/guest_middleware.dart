import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/routes/app_routes.dart';
import 'package:mws/services/session_service.dart';

/// Middleware to redirect authenticated users away from auth pages
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final SessionService sessionService = Get.find<SessionService>();
    
    // Routes that should redirect authenticated users
    final guestOnlyRoutes = [
      Routes.walletConnect,
    ];
    
    // Check if the current route is for guests only
    if (route != null && guestOnlyRoutes.contains(route)) {
      // Check if user is already authenticated
      if (sessionService.isSessionActive.value && 
          sessionService.connectedAddress.value.isNotEmpty) {
        // Redirect to multi-send if already authenticated
        return const RouteSettings(name: Routes.multiSend);
      }
    }
    
    // Allow access if not authenticated or route allows authenticated users
    return null;
  }
}


