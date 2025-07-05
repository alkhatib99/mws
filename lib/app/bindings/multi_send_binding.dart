import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/app/controllers/wallet_controller.dart';

class MultiSendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MultiSendController>(() => MultiSendController());
    Get.lazyPut<WalletController>(() => WalletController());
    
  }
}
