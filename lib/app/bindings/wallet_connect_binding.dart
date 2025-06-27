import 'package:get/get.dart';
import '../controllers/wallet_connect_controller.dart';

class WalletConnectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletConnectController>(() => WalletConnectController());
  }
}


