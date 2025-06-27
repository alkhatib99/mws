import 'package:get/get.dart';

abstract class Routes {
  static const String splash = _Paths.splash;
  static const String walletConnect = _Paths.walletConnect;
  static const String multiSend = _Paths.multiSend;
}

abstract class _Paths {
  static const String splash = '/splash';
  static const String walletConnect = '/wallet_connect';
  static const String multiSend = '/multi_send';
}


