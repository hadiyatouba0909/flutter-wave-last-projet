import 'package:get/get.dart';
import 'package:vendredi/app/modules/tranfertSimple/controllers/tranfert_simple_controller.dart';
class TranfertSimpleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferSimpleController>(
      () => TransferSimpleController(),
    );
  }
}


