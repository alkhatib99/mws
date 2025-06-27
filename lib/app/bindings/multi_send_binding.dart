import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';

class MultiSendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MultiSendController>(() => MultiSendController());
  }
}
