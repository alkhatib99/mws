import 'package:get/get.dart';

import 'package:mws/app/bindings/multi_send_binding.dart';
import 'package:mws/app/bindings/splash_binding.dart';
import 'package:mws/app/bindings/wallet_connect_binding.dart';
import 'package:mws/app/views/multi_send/multi_send_view.dart';
import 'package:mws/app/views/splash/splash_view.dart';
import 'package:mws/app/views/wallet_connect/wallet_connect_view.dart';

import 'app_routes.dart'; // Import app_routes.dart directly

class AppPages {
  AppPages._();

  static const INITIAL = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.walletConnect,
      page: () => const WalletConnectView(),
      binding: WalletConnectBinding(),
    ),
    GetPage(
      name: Routes.multiSend,
      page: () => const MultiSendView(),
      binding: MultiSendBinding(),
    ),
  ];
}
