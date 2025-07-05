import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/routes/app_routes.dart';
import 'package:mws/services/session_service.dart';

/// Middleware to protect routes that require wallet authentication
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final SessionService sessionService = Get.find<SessionService>();
    
    // Routes that require authentication
    final protectedRoutes = [
      Routes.multiSend,
    ];
    
    // Check if the current route requires authentication
    if (route != null && protectedRoutes.contains(route)) {
      // Check if user is authenticated (has active session)
      if (!sessionService.isSessionActive.value || 
          sessionService.connectedAddress.value.isEmpty) {
        // Redirect to wallet connect if not authenticated
        return const RouteSettings(name: Routes.walletConnect);
      }
    }
    
    // Allow access if authenticated or route doesn't require auth
    return null;
  }
}

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


