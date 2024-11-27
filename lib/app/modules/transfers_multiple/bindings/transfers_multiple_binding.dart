// Dans lib/app/modules/transfers_multiple/bindings/transfers_multiple_binding.dart
import 'package:get/get.dart';
import '../controllers/transfers_multiple_controller.dart';

class TransfersMultipleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransfersMultipleController>(
      () => TransfersMultipleController(),
    );
  }
}